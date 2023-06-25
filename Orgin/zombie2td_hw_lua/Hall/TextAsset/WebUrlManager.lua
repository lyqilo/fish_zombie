local CC = require("CC")

local WebUrlManager = {}

-- IOS 检查是否是美国IP
local needCheck = false

-- 网络测试
local NetworkTest
-- 备用链路配置测试
local BackupConfigTest

function WebUrlManager.Init()
	-- 设置原始URL
	CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").SetOrgUrlPrefix(CC.UrlConfig.EntryUrl.Release)
	-- 非debug模式直接请求入口配置
	if not CC.DebugDefine.GetDebugMode() then
		local callBack = function()
			WebUrlManager.UpdateAPI()
			CC.ReportManager.SetDot("STARTAPP")
		end
		WebUrlManager.ReqEntryConfig(callBack)
	end
end

function WebUrlManager.ReqEntryConfig(callback)
	local Func = function()
		local webUrlDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
		local webConfig = CC.ConfigCenter.Inst():getConfigDataByKey("WebConfig")

		local tryTimes = 1
		local doReqUrl = nil
		local url = webUrlDataMgr.GetEntryUrl()
		local language = CC.LanguageManager.GetLanguage("L_Common")

		local onResponse = function(www)
			CC.uu.Log("WebUrlManager.reqEntryUrl success")

			webUrlDataMgr.SetEntryPath(www.downloadHandler.text)

			if CC.Platform.isIOS and needCheck then
				WebUrlManager.CheckFormAmerica(
					function()
						WebUrlManager.ReqResConfigJson(callback)
					end
				)
			else
				WebUrlManager.ReqResConfigJson(callback)
			end
		end

		local onError = function()
			CC.uu.Log("WebUrlManager.reqEntryUrl failed")
			tryTimes = tryTimes + 1
			if tryTimes <= webConfig.Entry.TryTimes then
				log(string.format("WebUrlManager.reqEntryUrl 第%d次尝试", tryTimes))
				doReqUrl()
			else
				local TipsFunc = function()
					CC.ViewManager.ShowMessageBox(
						language.tip3,
						function()
							doReqUrl()
						end,
						function()
							Application.Quit()
						end
					)
				end

				if webUrlDataMgr.GetIsUseBackup() then
					TipsFunc()
				else
					log(string.format("WebUrlManager.reqEntryUrl 尝试%d次之后，还是失败，进入网络测试", webConfig.Entry.TryTimes))
					NetworkTest(
						function(bPass)
							if bPass then
								BackupConfigTest(
									function(data)
										if data then
											webUrlDataMgr.SetIsUseBackup(true)
											webUrlDataMgr.SetOrgUrlPrefix(data.OrgUrlPrefix)
											webUrlDataMgr.SetUrlPrefix(data.OrgUrlPrefix)
											webUrlDataMgr.InitHallAddress(data.ServerAddress)

											WebUrlManager.ReqEntryConfig(callback)
										else
											TipsFunc()
										end
									end
								)
							else
								TipsFunc()
							end
						end
					)
				end
			end
		end
		local onFinish = function()
		end

		local timeOut = webConfig.Entry.RequestTimeout
		doReqUrl = function()
			CC.HttpMgr.Get(url, onResponse, onError, onFinish, timeOut)
		end
		doReqUrl()
	end

	-- --先检测IP
	-- if Util.GetFromPlayerPrefs("CheckIPLAN") == "true" then
	-- 	log("本地有标记，跳过IP检测")
	-- 	Func()
	-- else
	-- log("本地无标记，进行IP检测")
	WebUrlManager.CheckIPAddress(Func)
	-- end
end

function WebUrlManager.CheckIPAddress(callback)
	--条件
	local isCN = false
	local isAuth = false
	local isWhiteList = false

	local doFunc = function()
		CC.uu.SafeDoFunc(callback)
		-- Util.SaveToPlayerPrefs("CheckIPLAN","true")
	end

	local noFunc = function()
		local box =
			CC.ViewManager.OpenMessageBoxEx(
			"Error",
			function()
				Application.Quit()
			end
		)
		box:SetOneButton()
	end

	if CC.DebugDefine.GetDebugMode() then
		doFunc()
		return
	end

	--系统语言
	local str = Client.GetDeviceLanguage()
	if string.find(str, "zh_TW") or string.find(str, "zh_CN") then
		log("本地语言为中文")
		isCN = true
	end

	---检测玩家本地登录标记
	local param = {}
	param.IMei = CC.Platform.GetDeviceId()
	CC.Request(
		"ReqAuthIPReq",
		param,
		function(err, data)
			if err == 0 then
				local checkLan = data.IsLanguageStatus
				isAuth = data.IsAuth
				isWhiteList = data.IsWhiteList
				log("IP通过验证:" .. tostring(isAuth))
				log("是否白名单:" .. tostring(isWhiteList))
				if isWhiteList then
					doFunc()
				elseif isAuth then
					if checkLan and isCN then
						noFunc()
					else
						doFunc()
					end
				else
					noFunc()
				end
			end
		end,
		function()
			--请求失败
			local language = CC.LanguageManager.GetLanguage("L_Common")
			local box =
				CC.ViewManager.OpenMessageBoxEx(
				language.checkIP_tip,
				function()
					Application.Quit()
				end
			)
			box:SetOneButton()
		end
	)
end

function WebUrlManager.CheckFormAmerica(callback)
	local doFunc = function(result)
		CC.ChannelMgr.SetTrailStatus(result)
		CC.uu.SafeDoFunc(callback)
	end

	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetOrgUrlPrefix()
	local baseURLFormat = "%s/geoip/AnalysisIP?Language=zh-CN"
	url = string.format(baseURLFormat, url)
	log("CheckFormAmerica, url = " .. url)
	local successCB = function(www)
		log("CheckFormAmerica success, www.text" .. www.downloadHandler.text)
		local msg = Json.decode(www.downloadHandler.text)
		if msg.code == 0 then
			local address = msg.data.Country
			if address and string.find(address, "美国") then
				doFunc(true)
			else
				doFunc(false)
			end
		else
			log("GetIsAbleHotUpdate failed, msg  == " .. msg.code)
			doFunc(true)
		end
	end

	local errorCB = function(www)
		logError("GetIsAbleHotUpdate failed   " .. tostring(www))
		doFunc(true)
	end

	CC.HttpMgr.Get(url, successCB, errorCB)
end

function WebUrlManager.ReqResConfigJson(callback)
	if CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetIsUseBackup() then
		if callback then
			callback()
		end
	else
		local language = CC.LanguageManager.GetLanguage("L_Common")
		local suffix = "ios"
		if CC.Platform.isAndroid then
			suffix = "android"
		elseif CC.Platform.isWin32 then
			suffix = "android"
		end
		local fileName = string.format("%s%s.json", suffix, AppInfo.ChannelID)
		local fileUrl = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetFileUrl()
		local url = fileUrl .. fileName .. "?timestamp=" .. Util.GetTimeStamp(false)
		local doReqUrl = nil
		local webUrl = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetOrgUrlPrefix() .. "/"

		doReqUrl = function()
			CC.HttpMgr.Get(
				url,
				function(www)
					CC.uu.Log("WebUrlManager.reqResUrl success")
					local data = Json.decode(www.downloadHandler.text)
					if not data.checkTrial then
						--不是提审状态直接请求配置的onlineWebAPI
						if data.onlineWebAPI and data.onlineWebAPI ~= "" then
							webUrl = data.onlineWebAPI
						end
					else
						--提审状态下需要判断版本号
						if data.trialVersion then
							if tonumber(AppInfo.version) < tonumber(data.trialVersion) then
								if data.onlineWebAPI and data.onlineWebAPI ~= "" then
									webUrl = data.onlineWebAPI
								end
							else
								if data.trialWebAPI and data.trialWebAPI ~= "" then
									webUrl = data.trialWebAPI
									--只有连提审服的时候才需要设置本地的提审状态字段
									CC.ChannelMgr.SetTrailStatus(data.checkTrial)
								end
							end
						end
					end
					--设置请求降级延迟
					CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").SetPingSwitch(data.delayPing)
					CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").SetLoginQueueSwitch(data.loginQueue)
					CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").SetPhoneLoginSwitch(data.phoneLogin)
					CC.DebugDefine.SetDebugMode(data.debugMode)
					CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").SetUrlPrefix(webUrl, data.protocol)
					-- WebUrlManager.CheckLoadingImgVer(data.loadingImgVer);
					if callback then
						callback()
					end
				end,
				function(www)
					CC.uu.Log("WebUrlManager.reqResUrl failed")
					local tips =
						CC.ViewManager.ShowMessageBox(
						language.tip3,
						function()
							doReqUrl()
						end,
						function()
							Application.Quit()
						end
					)
				end
			)
		end
		doReqUrl()
	end
end

function WebUrlManager.UpdateAPI()
	--请求更新列表
	WebUrlManager.ReqUpdateInfo()
	--请求竞技场信息
	WebUrlManager.ReqArenaInfo()
	--请求开关列表
	WebUrlManager.ReqSwitchInfo()
	--请求商店配置
	WebUrlManager.ReqStoreInfo()
	--请求广告配置
	CC.MessageManager.ReqInfo()
end

function WebUrlManager.InitServerAddress()
	if CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetIsUseBackup() then
		log("走备用链路，已经提前获取到ServerAddress，不需要再获取")
		CC.HallNotificationCenter.inst():post(CC.Notifications.ReqServerAddress, {})
		return
	end

	local language = CC.LanguageManager.GetLanguage("L_Common")
	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetGameIPUrl()
	CC.uu.Log(url, "reqHallInfoUrl:")
	local ReqHallAddress = nil
	local delayTime = 0
	ReqHallAddress = function()
		CC.HttpMgr.Get(
			url,
			function(www)
				local table = Json.decode(www.downloadHandler.text)
				CC.uu.Log("WebUrlManager.reqHallInfoUrl success")
				CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").InitHallAddress(table.data.ServerAddress)
				CC.HallNotificationCenter.inst():post(CC.Notifications.ReqServerAddress, {})
			end,
			function()
				CC.uu.Log("WebUrlManager.reqHallInfoUrl failed")
				delayTime = delayTime + 1
				CC.uu.DelayRun(
					delayTime,
					function()
						ReqHallAddress()
					end
				)
			end
		)
	end
	ReqHallAddress()
end

function WebUrlManager.ReqArenaInfo()
	--先拉取竞技场信息
	local language = CC.LanguageManager.GetLanguage("L_Common")
	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetArenaInfoUrl()

	local doReq = nil
	local delayTime = 0
	doReq = function()
		CC.HttpMgr.Get(
			url,
			function(www)
				CC.uu.Log("WebUrlManager.ReqArenaInfo success")
				local info = Json.decode(www.downloadHandler.text)
				CC.DataMgrCenter.Inst():GetDataByKey("Game").SetArenaInfo(info)
			end,
			function()
				CC.uu.Log("WebUrlManager.ReqArenaInfo failed")
				delayTime = delayTime + 1
				CC.uu.DelayRun(
					delayTime,
					function()
						doReq()
					end
				)
			end
		)
	end
	doReq()
end

--获取更新列表数据
function WebUrlManager.ReqUpdateInfo(isRefresh)
	local language = CC.LanguageManager.GetLanguage("L_Common")
	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetUpdateUrl()

	local doReq = nil
	local refreshReq = nil
	doReq = function()
		CC.HttpMgr.Get(
			url,
			function(www)
				local data = Json.decode(www.downloadHandler.text)
				CC.DataMgrCenter.Inst():GetDataByKey("Update").Init(data)
				CC.HallNotificationCenter.inst():post(CC.Notifications.ReqUpdateFinish)
				CC.uu.Log("WebUrlManager.ReqUpdateInfo success")
			end,
			function()
				CC.uu.Log("WebUrlManager.ReqUpdateInfo failed")
				local tips =
					CC.ViewManager.ShowMessageBox(
					language.tip6,
					function()
						doReq()
					end,
					function()
						Application.Quit()
					end
				)
			end
		)
	end
	doReq()
end

function WebUrlManager.ReqSwitchInfo()
	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetSwitchInfoUrl()

	local doReq = nil
	local delayTime = 0
	doReq = function()
		CC.HttpMgr.Get(
			url,
			function(www)
				CC.uu.Log("WebUrlManager.ReqSwitchInfo success")
				local data = Json.decode(www.downloadHandler.text)
				-- CC.DataMgrCenter.Inst():GetDataByKey("Game").SetSwitchCfg(data)
				CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").SetSwitchData(data)
			end,
			function()
				CC.uu.Log("WebUrlManager.ReqSwitchInfo failed")
				delayTime = delayTime + 1
				CC.uu.DelayRun(
					delayTime,
					function()
						doReq()
					end
				)
			end
		)
	end
	doReq()
end

function WebUrlManager.ReqStoreInfo()
	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetStoreInfoUrl()

	local doReq = nil
	local delayTime = 0
	doReq = function()
		CC.HttpMgr.Get(
			url,
			function(www)
				CC.uu.Log("WebUrlManager.ReqStoreInfo success")
				local data = Json.decode(www.downloadHandler.text)
				if data.status ~= 0 then
					CC.DataMgrCenter.Inst():GetDataByKey("Game").SetStoreCfg(data)
				end
			end,
			function()
				CC.uu.Log("WebUrlManager.ReqStoreInfo failed")
				delayTime = delayTime + 1
				CC.uu.DelayRun(
					delayTime,
					function()
						doReq()
					end
				)
			end
		)
	end
	doReq()
end

--检查是否需要下载新的Loading图
function WebUrlManager.CheckLoadingImgVer(loadingImgVer)
	if not loadingImgVer then
		return
	end
	if CC.ChannelMgr.GetTrailStatus() then
		return
	end
	local saveTag = "hall_loadingImgVer"
	local localLoadingImgVer = tonumber(Util.GetFromPlayerPrefs(saveTag)) or 0
	local savePath = Util.userPath .. "loading.jpg"
	CC.uu.Log("localVer:" .. tostring(localLoadingImgVer) .. "  loadingImgVer:" .. tostring(loadingImgVer))
	if localLoadingImgVer ~= loadingImgVer then
		local loadingImgUrl = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLoadingImgUrl()
		local imageUrl = CC.uu.UrlWithTimeStamp(loadingImgUrl)
		CC.HttpMgr.Get(
			imageUrl,
			function(www)
				CC.uu.Log("WebUrlManager.CheckLoadingImgVer download Image success")
				Util.WriteBytes(savePath, www.downloadHandler.data)
				Util.SaveToPlayerPrefs(saveTag, tostring(loadingImgVer))
			end
		)
	end
end

NetworkTest = function(cb)
	if CC.DebugDefine.GetDebugMode() and not CC.DebugDefine.CheckReleaseServer() then
		log("NetworkTest 不连正式服，永不通过测试")
		log("NetworkTest Not Pass")
		CC.uu.SafeCallFunc(cb, false)
		return
	end
	-- 判断网络是否可用

	-- 判断网络信号强度

	-- 是否能访问本地知名网站
	local webConfig = CC.ConfigCenter.Inst():getConfigDataByKey("WebConfig")
	local tryTimes = 1

	local doReq = nil

	local url = webConfig.Test.Url
	local onResponse = function()
		log("可以访问本地知名网站 " .. webConfig.Test.Url)
		log("NetworkTest Pass")
		CC.uu.SafeCallFunc(cb, true)
	end
	local onError = function()
		tryTimes = tryTimes + 1
		if tryTimes <= webConfig.Test.TryTimes then
			log(string.format("第%d次尝试访问知名网站 %s", tryTimes, webConfig.Test.Url))
			doReq()
		else
			log("不能访问本地知名网站 " .. webConfig.Test.Url)
			log("NetworkTest Not Pass")
			CC.uu.SafeCallFunc(cb, false)
		end
	end
	local onFinish = function()
	end
	local timeOut = webConfig.Test.RequestTimeout

	doReq = function()
		CC.HttpMgr.Get(url, onResponse, onError, onFinish, timeOut)
	end
	doReq()
end

BackupConfigTest = function(cb)
	if CC.DebugDefine.GetDebugMode() and not CC.DebugDefine.CheckReleaseServer() then
		log("BackupConfigTest 不连正式服，永不通过测试")
		CC.uu.SafeCallFunc(cb, nil)
		return
	end

	local webConfig = CC.ConfigCenter.Inst():getConfigDataByKey("WebConfig")
	local tryTimes = 1

	local doReq = nil

	local orgUrlPrefix = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetOrgUrlPrefix()
	local url = orgUrlPrefix .. webConfig.Backup.Url
	local onResponse = function(www)
		local data = Json.decode(www.downloadHandler.text)
		CC.uu.Log(data, "请求备用链路信息配置文件成功")
		if data.isOpen then
			local t = {
				OrgUrlPrefix = data.onlineWebAPI,
				ServerAddress = data.ServerAddress
			}
			CC.uu.SafeCallFunc(cb, t)
		else
			log("备用链路开关目前是关闭状态")
			CC.uu.SafeCallFunc(cb, nil)
		end
	end
	local onError = function()
		tryTimes = tryTimes + 1
		if tryTimes <= webConfig.Backup.TryTimes then
			log(string.format("第%d次尝试请求备用链路信息配置文件", tryTimes))
			doReq()
		else
			log("请求备用链路信息配置文件失败")
			CC.uu.SafeCallFunc(cb, nil)
		end
	end
	local onFinish = function()
	end
	local timeOut = webConfig.Backup.RequestTimeout

	doReq = function()
		CC.HttpMgr.Get(url, onResponse, onError, onFinish, timeOut)
	end
	doReq()
end

return WebUrlManager
