local CC = require("CC")

local ReconnectManager = {}

function ReconnectManager.Start()
	CC.HallNotificationCenter.inst():register(ReconnectManager,ReconnectManager.ReLoginDisconnectToLogin,CC.Notifications.OnReLoginDisconnectToLogin)
	CC.HallNotificationCenter.inst():register(ReconnectManager,ReconnectManager.ReLoginDisconnect,CC.Notifications.OnReLoginDisconnect)
	CC.HallNotificationCenter.inst():register(ReconnectManager,ReconnectManager.Disconnect,CC.Notifications.OnDisconnect)
	CC.HallNotificationCenter.inst():register(ReconnectManager,ReconnectManager.ReLogin,CC.Notifications.OnReConnectServer)
end

function ReconnectManager.ReLoginDisconnectToLogin()
	CC.ViewManager.CloseConnecting()
	local language = CC.LanguageManager.GetLanguage("L_ReconnectManager")
    --TODO！！！case1：大厅场景，收到该消息，弹出提示框返回登录，必须返回
    --TODO！！！case2：游戏场景，收到该消息，在游戏退回大厅时检测网络状态，直接返回登录界面
    if CC.ViewManager.IsHallScene() then
    	local box = CC.ViewManager.ShowMessageBox(language.DisconnectToLogin, 
			function()
				CC.ReportManager.SetDot("RECONNECTTOLOGIN")
				CC.ViewManager.BackToLogin(CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.Reconnect, true);
			end)
    	box:SetOneButton();
    else
    	--游戏切回大厅时处理
    	CC.ViewManager.TagGameDisconnected()
    end
end

function ReconnectManager.ReLoginDisconnect()
    --TODO！！！case1：大厅场景，收到该消息，提示网络重连中
    --TODO！！！case2：游戏场景，收到该消息，不用理会
    if CC.ViewManager.IsHallScene() then
		CC.ReportManager.SetDot("RECONNECTFAIL")
    	-- CC.ViewManager.ShowConnecting()
    else
    	CC.ViewManager.TagGameDisconnecting()
    end
end

function ReconnectManager.Disconnect()
    --TODO！！！case1：大厅场景，收到该消息，提示网络重连中
    --TODO！！！case2: 游戏场景，收到该消息，不用理会
    if CC.ViewManager.IsHallScene() then
		CC.ReportManager.SetDot("ONRECONNECT")
    	-- CC.ViewManager.ShowConnecting()
    else
    	CC.ViewManager.TagGameDisconnecting()
    end
end

function ReconnectManager.ReLogin()
	-- CC.ViewManager.CloseConnecting()
	local data = CC.Player.Inst():GetLoginInfo()
	--登录数据为空，则玩家在登录前就掉线
	if not data then return end

	if CC.ViewManager.IsHallScene() then
		CC.ReportManager.SetDot("RECONNECTSUCC")
	end
	local curLoginWay = CC.Player.Inst():GetCurLoginWay()
	local loginDefine = CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine")

	if curLoginWay == loginDefine.LoginWay.Guest then
		ReconnectManager.LoginWithToken(data)

	elseif curLoginWay == loginDefine.LoginWay.Facebook then
		local partnerToken = CC.Player:Inst():GetThirdPartyToken()
		ReconnectManager.LoginWithToken(data, partnerToken, CC.shared_enums_pb.RT_Facebook)

	elseif curLoginWay == loginDefine.LoginWay.Line then
		local partnerToken = CC.Player:Inst():GetThirdPartyToken()
		ReconnectManager.LoginWithToken(data, partnerToken, CC.shared_enums_pb.RT_Line)
	end
end

function ReconnectManager.LoginWithToken(data,partnerToken,registerType)
	
	local imei = CC.Platform.GetDeviceId();

	local param = {}
	param.PlayerId = data.PlayerId;
	param.Token = data.Token;
	param.PartnerToken = partnerToken;
	param.Imei = imei;
	param.OS = CC.Platform.GetOSEnum();
	param.AccountType =registerType;
	local index = CC.Request("LoginWithToken",param,function(err,data)
			-- CC.Player.Inst():SetLoginData(data)
			ReconnectManager.LoadPlayerWithPropType(data.Id, data)
			CC.uu.Log("reconnect Request.LoginWithToken success")
		end, function(err)
			ReconnectManager.ReconnectFailed()
			CC.uu.Log("reconnect Request.LoginWithToken failed")
		end)
	CC.HttpMgr.CacheRequest(index);
end

function ReconnectManager.LoadPlayerWithPropType(PlayerId, logindata)
	--先获取玩家个人信息数据
	local param = {
		playerId = PlayerId,
		propTypes = {
			CC.shared_enums_pb.EPT_Wealth,
			CC.shared_enums_pb.EPT_Title,
			CC.shared_enums_pb.EPT_Lot,
			CC.shared_enums_pb.EPT_Statistic,
			CC.shared_enums_pb.EPT_MidMonth_Treasure,
		}
	}
	local index = CC.Request("ReqLoadPlayerWithPropType", param, function(err,data)
			CC.uu.Log("reconnect Request.ReqLoadPlayerWithPropType success")
			CC.Player.Inst():SetSelfInfo(data)
			ReconnectManager.RegToPublisher(logindata)
			CC.HallNotificationCenter.inst():post(CC.Notifications.changeSelfInfo, {})
		end, function()
			ReconnectManager.ReconnectFailed()
			CC.uu.Log("reconnect Request.ReqLoadPlayerWithPropType failed")
		end)
	CC.HttpMgr.CacheRequest(index);
end

function ReconnectManager.RegToPublisher(logindata)
	
	local data = {};
	data.Id = logindata.Id;
	data.Token = logindata.Nick;
	CC.Request("RegToPublisher",data,function (err)
		CC.uu.Log("reconnect Request.RegToPublisher success")
		-- CC.ViewManager.CloseConnecting()
	end, function()
		ReconnectManager.ReconnectFailed()
		CC.uu.Log("reconnect Request.RegToPublisher failed")
	end)
end

function ReconnectManager.ReconnectFailed()
	CC.uu.Log("socket reconnect but other reconnect operation failed")
	if CC.Network.GetReconnectTimes() <= CC.Network.GetMaxReconnectTimes() then return end
	if not CC.ViewManager.IsHallScene() then
		CC.Network.StopServer()
		CC.ViewManager.TagGameDisconnected();
		return
	end
	local language = CC.LanguageManager.GetLanguage("L_ReconnectManager")
	local box = CC.ViewManager.ShowMessageBox(language.DisconnectToLogin, 
		function()
			--Socket重连后,由于后续请求返回失败,踢回登录时需要把Socket断掉,否则返回登录界面调用network.Start报错
			CC.Network.StopServer()
			CC.ViewManager.BackToLogin(CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.Reconnect, true);

		end)
	box:SetOneButton();
end

return ReconnectManager