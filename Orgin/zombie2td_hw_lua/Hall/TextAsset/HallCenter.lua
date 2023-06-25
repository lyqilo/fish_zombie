--[[
	整个大厅最上层的管理中心，UI统筹，数据统筹，事件分发中心
]]
local CC = require("CC")

local HallCenter = {}

--在进入登录界面之前（Loading界面，检测热更时），需要先初始化以下数据
function HallCenter.InitBeforeLogin()
	CC.Platform.Init()
	CC.LocalGameData.Init()
	CC.DebugDefine.Init()
	DoTween.Init()
	CC.Sound.Init()
	CC.GC.Init()
	CC.proto.Init()
	CC.NetworkHelper.Init()
	CC.WebUrlManager.Init()
	-- CC.ReportQManager.Init()
	HallCenter.UnityToLuaListen()
end

--热更检测完成，再初始化以下数据
function HallCenter.InitAfterLoading()
	CC.TimeMgr.Start()
	CC.ViewManager.Start()
	CC.ReconnectManager.Start()
	CC.FacebookPlugin.Init()
	CC.PaymentManager.Init()
	CC.LinePlugin.Init()
	CC.OppoPlugin.Init()
	-- CC.GoogleAdsPlugin.Init()
	CC.TestTool.Init()

	--定位相关
	-- CC.BaiduMapWeb.InitBaiduMap()
	-- CC.BaiduMapWeb.StartGPS()
end

--C#-->lua的监听
function HallCenter.UnityToLuaListen()
	--注册C# 到 Lua 的监听

	--横竖屏切换通知
	VK.NotificationToLua.OnSupportScreenRotate = function(rotateType)
	end

	--屏幕动态适配监听
	VK.NotificationToLua.OnAdaptScreenListener = function(delta)
	end

	--百度工具相关
	VK.NotificationToLua.OnPhoneLocationResponseResult = function(str1, str2, str3)
		CC.BaiduMapWeb.OnPhoneLocationResponseResult(str1, str2, str3)
	end

	--百度工具相关
	VK.NotificationToLua.OnBaiduLocationResponseResult = function(str1, str2)
		CC.BaiduMapWeb.OnBaiduLocationResponseResult(str1, str2)
	end

	--百度工具相关
	VK.NotificationToLua.OnBaiduCDTansformResponseResult = function(str1, str2)
		CC.BaiduMapWeb.OnBaiduCDTansformResponseResult(str1, str2)
	end

	--百度工具相关
	VK.NotificationToLua.OnBaiduDistanceResponseResult = function(str1, str2)
		CC.BaiduMapWeb.OnBaiduDistanceResponseResult(str1, str2)
	end

	--游戏暂停监听
	VK.NotificationToLua.OnPause = function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnPause)
	end

	--游戏唤醒监听
	VK.NotificationToLua.OnResume = function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnResume)
	end

	--ANdroid返回键点击监听
	VK.NotificationToLua.OnMenuBack = function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnMenuBack)
	end

	VK.NotificationToLua.OnPickPhotoBack = function(imagePath)
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnPickPhotoBack, imagePath)
	end

	VK.NotificationToLua.OnPickPhotoBytesBack = function(imageBytes)
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnPickPhotoBytesBack, imageBytes)
	end

	VK.NotificationToLua.OnPickIOSPhotoBack = function(imageBytes, imageType)
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnPickIOSPhotoBack, imageBytes, imageType)
	end

	VK.NotificationToLua.OnCloudMessageReceived = function(messageId, title, body)
		log(string.format("Firebase received message: messageId = %s, title = %s, body = %s", messageId, title, body))
	end

	VK.NotificationToLua.OnUrlOpenApplicationCallback = function()
		if CC.ViewManager.IsHallScene() then
			CC.HallNotificationCenter.inst():post(CC.Notifications.OnUrlOpenApplicationCallback)
			return
		end
		local param = Client.GetBrowserParams()
		if param ~= "" then
			param = Json.decode(Util.DecodeBase64(param))
			CC.HallNotificationCenter.inst():post(CC.Notifications.OnUrlOpenApplicationCallback, param)
			Client.ClearBrowserParams()
		end
	end

	--网络协议监听
	VK.NotificationToLua.OnSocketMessage = function(socketClient, cmd, buffer)
	end

	VK.NotificationToLua.OnGetDisScreenShotBack = function(imageBytes)
		if CC.ViewManager.GetCurGameId() == 0 then
			return
		end
		if CC.ChannelMgr.GetTrailStatus() then
			return
		end
		CC.ViewManager.Open("DisScreenShotShareView", {imageBytes = imageBytes})
	end

	--ANdroid返回键点击监听
	VK.NotificationToLua.OnClickFloatActionButton = function(msg)
		log("OnClickFloatActionButton")
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnClickFloatActionButton, msg)
	end

	--应用评价回调
	VK.NotificationToLua.OnAppRateCallBack = function(msg)
		log("OnAppRateCallBack")
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnAppRateCallBack, msg)
	end

	if CC.FirebasePlugin.CheckVersionCompatible() then
		VK.NotificationToLua.OnFirebaseMsgReceived = function(json)
			local data = Json.decode(json)
			CC.uu.Log(data, "OnFirebaseMsgReceived", 1)
		end
	end
end

return HallCenter
