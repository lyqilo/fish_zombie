local ZTD = require("ZTD")
local GC = require("GC")
local tools = GC.uu

--登录
local GameLogin = {}
local _retryLoginTime = 0
local _retryReconnectTime = 0
local _firstLogin = true

function GameLogin.LoginSuccess(data)
    GameLogin.IsFirstLogin = data.IsFirstLogin
	GameLogin.OtherInfomationReq()
end


function GameLogin.OtherInfomationReq()
    --Ping包开启
    GameLogin.StartPing()
end

function GameLogin.RemovePing()
	if GameLogin.co_Ping then
		ZTD.GameTimer.StopTimer(GameLogin.co_Ping)
		GameLogin.co_Ping = nil
	end
end

function GameLogin.StartPing()
	GameLogin.PingCount = 0;
	GameLogin.RemovePing()
	GameLogin.PingReq()
	GameLogin.co_Ping = ZTD.GameTimer.StartTimer(function()
		GameLogin.PingReq()
	end, 10, -1)
end

function GameLogin.PingReq()
	local function doDisconnect()
		GameLogin.RemovePing();
		ZTD.NetworkManager.CloseManual("client ping disconnect!");
		GameLogin.PingCount = 0;	
	end
	local succCb = function()
--		logError("succCb succCb PingReqPingReqPingReq:" .. os.date("%Y-%m-%d %H:%M:%S:"));
		GameLogin.PingCount = 0;
	end
	
	local errCb = function(err,data)
		if err == 99999 then
			logError("!!!!!!!!!!PingReq err == 99999!!!!!!!!!!!!")
			doDisconnect();
		end
	end
--	logError("dodododododo PingReqPingReqPingReq:" .. os.date("%Y-%m-%d %H:%M:%S:"));

	if GameLogin.PingCount > 20 then
		logError("!!!!!!!!!!心跳包没有回应，网络断开")
		doDisconnect();
	end

	GameLogin.PingCount = GameLogin.PingCount + 1;
	ZTD.Request.CSPingReq(succCb, errCb)
end

--重连
function GameLogin.Reconnect(pIoReconnectFunc)
	GameLogin.isReConnect = true
	local str = languageg.reconnectServer
	
	local cancelFunc = function ()
		ZTD.MJGame.Back2Hall()
	end
	
	-- 等待1秒看有没重连成功，没有则重复弹窗
	local openWaitDlg;
	openWaitDlg	= function()
		ZTD.Utils.ShowWaitTip()		
		ZTD.GameTimer.DelayRun(1, function()
			_retryReconnectTime = _retryReconnectTime + 1;
			ZTD.Utils.CloseWaitTip()
			-- 如果不在重连状态了，丢掉等待步骤
			if GameLogin.isReConnect then
				if _retryReconnectTime >= 5 then
					ZTD.MJGame.Back2Login()
				else
					ZTD.ViewManager.OpenExitGameBox(1, str, openWaitDlg, cancelFunc);
				end
			end
		end)		
	end	
	
	local confirmFunc = function ()
		-- 使用大厅的重连接口
		pIoReconnectFunc();	
		-- 打开纯等待窗口
		openWaitDlg();
	end

	ZTD.Utils.ForceCloseWaitTip()
	ZTD.ViewManager.OpenExitGameBox(1,str,confirmFunc,cancelFunc);	
end
--exitgame
function GameLogin.ExitGame()
	-- 退出游戏，关闭所有可能的转菊花
	ZTD.ViewManager.CloseWaitTip();
	ZTD.Utils.ForceCloseWaitTip();
	
	-- 弹出网络断开的窗口
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	local str = language.serverDissconnect2;
	ZTD.Flow.OpenReconnectDlg(str);
end

function GameLogin.Login()
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");

	_retryReconnectTime = 0
	_firstLogin = false
    local PlayerId = ZTD.PlayerData.GetPlayerId()
	local Token = GC.Player.Inst():GetLoginInfo().Token
    local param = {}
    param.PlayerId = PlayerId
    param.Token = Token
    local successCb = function(err, data)
        log("====>> Login Successed!!!")
        GameLogin.LoginSuccess(data) 
		ZTD.ViewManager.CloseWaitTip()
		_retryLoginTime = 0
		if GameLogin.isReConnect then
			ZTD.ViewManager.ShowTip(language.loginSuccess)
			GameLogin.isReConnect = false
			if ZTD.BattleView.inst then
				ZTD.Notification.GamePost(ZTD.Define.MsgReconnect);
			else
				ZTD.Notification.GamePost(ZTD.Define.MsgLoginSuccess, data);
			end
		else
			ZTD.Notification.GamePost(ZTD.Define.MsgLoginSuccess, data);
		end	
    end

    local errorCb = function(err, data)	
        logError("====>> Login Failed!!!：" .. tostring(err))
		
		local confirmFunc = function ()
			ZTD.Flow.BackToArena()
		end
		--各种登录失败错误码（获取大厅数据失败，无效的token，服务器房间已满,或其他登录失败情况）
		if err == 10093 or err == 10092 or err == 10074 then
			local str = language.connectFailed
			ZTD.ViewManager.OpenExitGameBox(0,str,confirmFunc)
			return
		end

		GameLogin.isReConnect = false 
		if _retryLoginTime < 1 then
			GameLogin.isReConnect = true
			GameLogin.Login()
			_retryLoginTime = _retryLoginTime + 1
		else
			GameLogin.RetryLogin()
		end
    end
    ZTD.Request.LoginReq(param,successCb,errorCb)
end

function GameLogin.RetryLogin()
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	local str = language.connectFailed
	local confirmFunc = function ()
		GameLogin.isReConnect = true 
		GameLogin.Login()
	end
	ZTD.ViewManager.OpenExitGameBox(0,str,confirmFunc)
end

return GameLogin