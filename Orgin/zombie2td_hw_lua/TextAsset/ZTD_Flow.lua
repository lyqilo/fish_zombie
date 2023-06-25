local GC = require("GC")
local CC = require("CC")
local ZTD = require("ZTD")
local tools = GC.uu
local TF = {}

local __updateInterval = 0.5;
local __lastInterval = 0;
local __frames = 0;	
TF.cameraIdx = 1
TF.maxIdx = 100	
function TF.Init()	

	if TF.IsActive then
		return
	end

	TF.language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig")
	TF.IsActive = true
	TF.IsReadyExit = false
	TF.ExitData = {}
	TF.UpdateList = {}
	TF.TimeFuncs = {}
	
	ZTD.GlobalTimer.StartTimer(function ()
		collectgarbage("collect")
	end, 90, -1)
	
	ZTD.MainScene.Init()
	ZTD.TableData.Init()
	ZTD.EffectManager.Init()
	
	if TF.TouchMgr == nil then
		TF.TouchMgr = ZTD.TouchManager:new()
	end		
	if TF.TdEnemyMgr == nil then
		TF.TdEnemyMgr = ZTD.EnemyMgr:new(ZTD.EnemyController)
	end
	if TF.TdHeroMgr == nil then
		TF.TdHeroMgr = ZTD.HeroMgr:new(ZTD.HeroController)
	end
	if TF.TdBulletMgr == nil then
		TF.TdBulletMgr = ZTD.BulletMgr:new(ZTD.BulletController)
	end	
	if TF.SkillMgr == nil then
		TF.SkillMgr = ZTD.SkillMgr:new()
	end
	
	TF.TouchMgr:Init()
	TF.TdEnemyMgr:Init()
	TF.TdHeroMgr:Init()
	TF.TdBulletMgr:Init()
	TF.SkillMgr:Init()

	ZTD.UpdateAdd(TF.Update, TF)
	ZTD.FixedUpdateAdd(TF.FixedUpdate, TF)
	TF.InitUnloadTimer()

	--退出房间的推送
	ZTD.Notification.NetworkRegister(TF, "SCLeaveTowerTable", TF.OnPlayerLeave)
	--刚登录时和有玩家加入时都会获得该推送
	ZTD.Notification.NetworkRegister(TF, "SCNotifyTowerTablePlayer", TF.OnPlayerJoin)
	--自己主动退出时和被服务器踢掉时候，都会获得该推送
	ZTD.Notification.NetworkRegister(TF, "SCLogoutGame", TF.OnLogoutGame)	
	--道具推送
	ZTD.Notification.NetworkRegister(TF, "SCPushPropsInfo", TF.OnPushPropsInfo)
	--碎片掉落推送
	ZTD.Notification.NetworkRegister(TF, "SCPushDropMaterials", TF.OnPushDropMaterials)
	--功能开关推送
	ZTD.Notification.NetworkRegister(TF, "SCFunctionSwitch", TF.OnFunctionSwitch)
	--退出游戏消息
	ZTD.Notification.GameRegister(TF, ZTD.Define.MsgDoExit, TF.OnDoExit);
	--大厅消息 被人顶号
    GC.HallNotificationCenter.inst():register(TF, TF.OnForceDisconnected, GC.Notifications.OnPushKickedOut);
	--后台切换操作	
	GC.HallNotificationCenter.inst():register(TF, TF.OnPause, GC.Notifications.OnPause)
	GC.HallNotificationCenter.inst():register(TF, TF.OnResume, GC.Notifications.OnResume)
	--下载监听
	GC.HallNotificationCenter.inst():register(TF,TF.Downloading, GC.Notifications.DownloadGame)
	--暗补
	-- GC.HallNotificationCenter.inst():register(TF,TF.OnpushShake, GC.Notifications.OnpushShake)
	-- GC.HallNotificationCenter.inst():register(TF,TF.OnpushShakeClose, GC.Notifications.OnpushShakeClose)
	--周卡礼包
	GC.HallNotificationCenter.inst():register(TF,TF.OnDailyGiftGameReward, GC.Notifications.OnDailyGiftGameReward)
	--刷新玩家信息
    GC.HallNotificationCenter.inst():register(TF, TF.changeSelfInfo, GC.Notifications.changeSelfInfo)
	--推送这一批次连接怪
	ZTD.Notification.NetworkRegister(TF, "SCPushConnectMonster", TF.OnPushConnectMonster)
end

-- 推送这一批次连接怪
function TF.OnPushConnectMonster(_, data)
	--log("OnPushConnectMonster data="..GC.uu.Dump(data))
	ZTD.Notification.GamePost(ZTD.Define.OnPushConnectMonster, data)
end

--资源卸载
function TF.InitUnloadTimer()
	TF.unloadIdx = 0
	TF.unloadTimer = ZTD.GlobalTimer.StartTimer(function ()
		TF.unloadIdx = TF.unloadIdx + 1
		UnityEngine.Resources.UnloadUnusedAssets()
		if TF.unloadIdx % 10 == 0 then
			Util.ClearMemory()
		end
	end, 120)
end

function TF.changeSelfInfo(_, data)
	--log("!!! changeSelfInfo data = "..GC.uu.Dump(data))
	ZTD.Notification.GamePost(ZTD.Define.changeSelfInfo, data)
end

function TF.OnPushDropMaterials(_, data)
	-- log("!!! OnPushDropMaterials data = "..GC.uu.Dump(data))
	ZTD.Notification.GamePost(ZTD.Define.OnPushDropMaterials, data)
end

function TF.OnFunctionSwitch(_, data)
	-- logError("!!! OnFunctionSwitch data = "..GC.uu.Dump(data))
	TF.SwithData = data
	ZTD.Notification.GamePost(ZTD.Define.OnFunctionSwitch, data)
end

function TF.OnPushPropsInfo(_, data)
	--log("OnPushPropsInfo"..GC.uu.Dump(data))
	if ZTD.BattleView.inst then
		ZTD.BattleView.inst:ReleaseCountDown()
	end
	for k, v in pairs(data.Info) do
		if v.PropsID == 3 then
			ZTD.PlayerData.SetDiamond(v.TotalNum)
		end
	end
	ZTD.Notification.GamePost(ZTD.Define.OnPushPropsInfo, data)
end

function TF.OnDailyGiftGameReward(data)
	-- log("周卡礼包收到【大厅】监听！！！"..GC.uu.Dump(data))
	ZTD.Notification.GamePost(ZTD.Define.OnDailyGiftGameReward, data)
end

-- function TF.OnpushShake()
-- 	ZTD.Notification.GamePost(ZTD.Define.OnpushShake);
-- end

-- function TF.OnpushShakeClose()
-- 	ZTD.Notification.GamePost(ZTD.Define.OnpushShakeClose);
-- end

function TF.StartNetWork()
	ZTD.Utils.ShowWaitTip()
	ZTD.NetworkManager.Init(ZTD.MJGame.gameData, function(serverIp)
		ZTD.NetworkManager.Start(serverIp)
		ZTD.Utils.CloseWaitTip()
		local cfg = ZTD.ConstConfig[1];
		
		local function onLoginSucc(_, data)
			-- log("登录数据 data="..GC.uu.Dump(data))
			-- 重置重连标记
			TF.InReconnect = false;
			-- 重设游戏赔率值
			ZTD.PlayerData.SetMultiple(data.UseRatio);					
			ZTD.Notification.GamePost(ZTD.Define.MsgRefreshRadio);		
		end	
		ZTD.Notification.GameRegister(ZTD.GameCenter.GetInstance(), ZTD.Define.MsgLoginSuccess, onLoginSucc);
    end)
end

function TF.Downloading(gameId, progress)
	-- 如果退出时，正好碰上了热更,则直接退出到大厅
	local gameId = tonumber(gameId)
	
	local confirmFunc = function ()
		ZTD.Notification.GamePost(ZTD.Define.MsgDoExit, {isGoHall = true})
	end
	
	if gameId == 10101 and TF.__isShowOut10101 == nil then
		TF.__isShowOut10101 = true
		local str = TF.language.update_fuck_out

		local msgBox = ZTD.ViewManager.OpenExitGameBox(0,str,confirmFunc)
		if msgBox then
			local oldDestroyFinish = msgBox.OnDestroyFinish
			msgBox.OnDestroyFinish = function( msgBox )
				oldDestroyFinish(msgBox)
			end
		else
			TF.__isShowOut10101 = true
			confirmFunc()
		end
	end	
end

function TF.OnPause()
	if ZTD.BattleView.inst == nil then
		return
	end	
	TF._pauseTime = os.time()
	TF.IsPause = true
	log("请求切后台")
	ZTD.Request.CSChangeBackgroundReq({IsBack = true})
	-- 进后台时必发心跳包
	ZTD.Request.CSPingReq()
	TF.TdEnemyMgr:OnPause()
end

function TF.OnResume()
	if ZTD.BattleView.inst == nil then
		return
	end
	
	TF.BackStageTime = os.time() - TF._pauseTime;

	local function sussCb()
		ZTD.Notification.GamePost(ZTD.Define.MsgGameResume, true);
	end
	
	local function errCb()	
		
	end
	
	-- 调用Resume清空队列
	TF.TdEnemyMgr:OnResume();
	ZTD.Request.CSChangeBackgroundReq({IsBack = false}, sussCb, errCb);	
	
	-- 后台回来必发心跳包
	--ZTD.Request.CSPingReq();
end

function TF.OnForceDisconnected()
	--如果不是正常退出,强制回到大厅
	TF.OnLogoutGame(TF, {LogoutType = 4})
end

function TF.OnPlayerJoin(_, Data)
	log("Data="..GC.uu.Dump(Data))
	if ZTD.TableData.Update(Data) then
		if TF.IsPlayerTableInit == nil then
			local playerId = ZTD.PlayerData.GetPlayerId()
			local scMoney = ZTD.TableData.GetData(playerId, "Money") or 0
			ZTD.GoldData.Gold:Set(scMoney)
			ZTD.ViewManager.CloseAllView()
			ZTD.ViewManager.Open("ZTD_BattleView")
			TF.IsPlayerTableInit = true
		else
			ZTD.Notification.GamePost(ZTD.Define.MsgPlayerJoin, Data)
		end
	end	
end

function TF.OnPlayerLeave(_, Data)
	ZTD.Notification.GamePost(ZTD.Define.MsgPlayerLeave, Data)
end

function TF.GetBulletMgr()
	return TF.TdBulletMgr
end

function TF.GetHeroMgr()
	return TF.TdHeroMgr
end

function TF.GetEnemyMgr()
	return TF.TdEnemyMgr
end

function TF.GetSkillMgr()
	return TF.SkillMgr
end

function TF.GetTouchMgr()
	return TF.TouchMgr
end

function TF.OnDoExit(_, exitData)
	TF.ExitData = exitData
	
	local function tdCallback(enterGame, data)
		TF.IsReadyExit = true
		ZTD.Utils.ShowWaitTip();
		-- 和服务器请求退出
		local succCb2 = function(err, data)
			ZTD.Utils.CloseWaitTip();
		end
		local errCb2 = function(err,data)
			ZTD.Utils.CloseWaitTip();
			logError("_______LogoutGame Error:"..err)
		end
		-- 请求登出游戏,如果成功就会产生OnLogoutGame推送
		ZTD.Request.CSLogoutGameReq(succCb2, errCb2)
	end
	if exitData.isGoHall or exitData.isChangeRoom or exitData.isChangeArena or exitData.isSkipArena then	
		tdCallback()
	end
end

function TF.ReleaseAll()
	if TF.IsActive == false then
		return
	end
	TF.IsActive = false
	ZTD.UpdateRemove(TF.Update, TF)
	ZTD.FixedUpdateRemove(TF.FixedUpdate, TF)
	
	TF.TdEnemyMgr:Release()
	TF.TdHeroMgr:Release()
	TF.TdBulletMgr:Release()
	TF.SkillMgr:Release()
	TF.TouchMgr:Release()
	TF.IsPlayerTableInit = nil
	ZTD.GuideData.Release()
	ZTD.MainScene.Release()
	ZTD.EffectManager.Release()

	ZTD.Notification.GameUnregisterAll(TF)
	ZTD.Notification.NetworkUnregisterAll(TF)
	GC.HallNotificationCenter.inst():unregisterAll(TF)

	-- 推送在回调之前，所以在这里关闭battleview
	ZTD.Notification.GamePost(ZTD.Define.MsgRelease)
	
	ZTD.NetworkManager.StopServer()
	ZTD.GameTimer.Release()
	ZTD.Extend.StopAllTimer()
	ZTD.Extend.StopAllAction()
end	

--返回选场
function TF.BackToArena()
	TF.IsSkipLogOutDlg = true
	TF.ReleaseAll()
	ZTD.PoolManager.Release()
	ZTD.ViewManager.Replace("ZTD_MainView")
end

function TF.OpenReconnectDlg(str)
	-- 如果是要不弹窗，则跳过一次后复原，用于切房间和手动退出的流程时，不弹重连窗
	if TF.IsSkipLogOutDlg then
		TF.IsSkipLogOutDlg = false
		return
	end
	TF.isExitGamePop = true
	local confirmFunc = function()
		
		local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig")
		local str = language.txt_exitGameLimit
		local callFunc = function()
			TF.BackToArena()
		end
		if ZTD.Utils.IsNotMatchArenaLimit(str, callFunc) then return end
		
		TF.IsTrusteeship = false
		TF.isExitGamePop = false
		-- 记录重连标志
		TF.InReconnect = true
		-- 链接网络
		TF.Init()
		TF.StartNetWork()
	end
	local cancelFunc = function ()
		ZTD.Utils.ForceCloseWaitTip()
		TF.BackToArena()
	end
	-- 如果连一次连不成功，强制返回大厅
	if TF.InReconnect then
		TF.isExitGamePop = true
		ZTD.Utils.ForceCloseWaitTip()
		local str2 = TF.language.serverDissconnect
		local confirmFunc2 = function ()
			ZTD.MJGame.Back2Hall()
		end	
		ZTD.ViewManager.OpenExitGameBox(3, str2, confirmFunc2)
	else	
		ZTD.ViewManager.OpenExitGameBox(0, str, confirmFunc, cancelFunc, TF.language.BtnConnect, TF.language.BtnLeave)
	end	
end

--Type:0,服务器异常关闭；1,正常退出；2,心跳断开；3,超过攻击次数退出；4,账号在其他设备登陆;
-- 99 服务器定义，无行为释放
function TF.OnLogoutGame(_, data)
	local logoutType = data.LogoutType
	log(os.date("%Y-%m-%d %H:%M:%S:") .. "!!!!!!!!!!!OnLogoutGameOnLogoutGameOnLogoutGameOnLogoutGame:" .. tostring(logoutType));
	
	if logoutType == 2 then
		ZTD.NetworkManager.CloseManual("server ping disconnect!")
		return
	end	
	
	if ZTD.BattleView.inst == nil then
		local str = TF.language.serverDissconnect
		local confirmFunc = function ()
			ZTD.MJGame.Back2Hall()
		end	
		ZTD.ViewManager.OpenExitGameBox(3,str,confirmFunc)		
		return
	end	
	TF.ReleaseAll()

	if logoutType == 99 then
		return;
	elseif logoutType == 1 then
		TF.IsSkipLogOutDlg = true
		if TF.ExitData.isGoHall then		
			-- 清理子游戏lua资源
			vModuleLuaPathClear();
			ZTD.MJGame.Back2Hall(true)
		elseif TF.ExitData.isChangeRoom then
			-- 成功走完退出流程时候，标记正在换房的状态
			-- 什么都不做，等待net on close事件
			local function onNetClose()				
				TF.IsSkipLogOutDlg = false
				TF.Init()
				TF.StartNetWork()
				ZTD.Notification.GameUnregister(TF, ZTD.Define.MsgNetClose)
			end
			-- 重复预防
			ZTD.Notification.GameUnregister(TF, ZTD.Define.MsgNetClose)
			ZTD.Notification.GameRegister(TF, ZTD.Define.MsgNetClose, onNetClose)
		elseif TF.ExitData.isChangeArena then
			ZTD.ViewManager.Replace("ZTD_MainView")
		elseif TF.ExitData.isSkipArena then
			ZTD.Notification.GamePost(ZTD.Define.OnPushMainToGame, ZTD.Flow.groupId + 1)
		else				
			-- 清理子游戏lua资源
			vModuleLuaPathClear()
			ZTD.MJGame.Back2Hall(true)
		end
	-- 超时未攻击处理	
	elseif logoutType == 5 then
		ZTD.MainScene.ShowMaskBg()
	else
		--如果不是正常退出,强制回到大厅
		ZTD.MainScene.ShowMaskBg()

		local str, confirmFunc
		if logoutType == 4 then
			str = TF.language.on_sc_other_player_login
			confirmFunc = function ()
				GC.SubGameInterface.KickedOutTip()
			end	
			ZTD.ViewManager.OpenExitGameBox(3,str,confirmFunc)
		else
			str = TF.language.serverDissconnect
			confirmFunc = function ()
				ZTD.MJGame.Back2Hall(true)
			end	
			ZTD.ViewManager.OpenExitGameBox(3,str,confirmFunc)
		end
	end	
end

function TF.Update()
	--切换前后台测试按钮
	-- if (UnityEngine.Input.GetKeyDown("1")) then
	-- 	logError("111111")
    --     ZTD.Flow.OnPause()
    -- end

	-- if (UnityEngine.Input.GetKeyDown("2")) then
	-- 	logError("222222")
    --     ZTD.Flow.OnResume()
    -- end
	__frames = __frames + 1
	local timeNow = Time.realtimeSinceStartup
	if (timeNow > __lastInterval + __updateInterval) then
		local fps = (__frames / (timeNow - __lastInterval))
		__frames = 0
		__lastInterval = timeNow
		ZTD.MainScene.SetFps(fps)
	end
	
	ZTD.MainScene.screenPosition = Input.mousePosition
    ZTD.MainScene.PressDown = Input.GetMouseButton(0)
end

function TF.FixedUpdate()
	if TF.IsActive == false then
		return
	end
	
	if TF.IsPause then
		return
	end	
		
	local dt = Time.fixedDeltaTime
	TF.SkillMgr:FixedUpdate(dt)
	TF.TdEnemyMgr:FixedUpdate(dt)
	TF.TdHeroMgr:FixedUpdate(dt)
	TF.TdBulletMgr:FixedUpdate(dt)
	TF.TouchMgr:FixedUpdate(dt)
	ZTD.MainScene.FixedUpdate(dt)
	
	for _, v in ipairs (TF.UpdateList) do
		if type(v) == "function" then
			v(dt)
		else
			v:FixedUpdate(dt)
		end	
	end
	
	TF.UpdateTimeFunc(dt)
	
	-- 重置后台时间
	if TF.BackStageTime then
		TF.BackStageTime = nil
	end
end

function TF.AddUpdateList(var)
	table.insert(TF.UpdateList, var)
end

function TF.AddTimeFunc(callTime, func)
	table.insert(TF.TimeFuncs, {time = 0, callTime = callTime, callFunc = func})
	return func;
end

function TF.UpdateTimeFunc(dt)
	local removeMark = {}
	for k, v in ipairs(TF.TimeFuncs) do
		if v.time >= v.callTime then
			v.callFunc()
			table.insert(removeMark, k - #removeMark)
		end
		v.time = v.time + dt
	end
	for k, removeKey in ipairs(removeMark) do
		table.remove(TF.TimeFuncs, removeKey)
	end	
end

function TF.ForceTimeFunc(callFunc)
	local removeMark = {}
	for k, v in ipairs(TF.TimeFuncs) do
		if v.callFunc == callFunc then
			v.callFunc()
			table.insert(removeMark, k - #removeMark)
		end
	end
	for k, removeKey in ipairs(removeMark) do
		table.remove(TF.TimeFuncs, removeKey)
	end	
end

function TF.RemoveUpdateList(var)
	for i, v in ipairs (TF.UpdateList) do
		if v == var then
			table.remove(TF.UpdateList, i, v)
			break
		end
	end	
end

return TF

 