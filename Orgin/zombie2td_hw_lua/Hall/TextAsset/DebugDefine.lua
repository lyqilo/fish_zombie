local CC = require("CC")

--客户端测试用的字段放到这里面来

local DebugDefine = {}

local pcLocalClientPath = "C:/mnt/sdcard/huoys.game.cache/client.json"
local phoneLocalClientPath = "/mnt/sdcard/huoys.game.cache/client.json"

--本地保存debug界面设置的数据
local _localClientData = {}

DebugDefine.DebugMode = false
DebugDefine.HysMode = false
-- 提审状态
-- DebugDefine.CheckTrail = false;

DebugDefine.DebugInfo = {}

--运行环境枚举
DebugDefine.EnvState = {
	Release = 1,
	Test = 2,
	StableDev = 3,
	Dev = 4,
	TH_Release = 5,
	PreRelease = 6
}

DebugDefine.WebConfigState = {
	Release = 1,
	Test = 2,
	Dev = 3,
	TH_Release = 4,
	PreRelease = 5
}

DebugDefine.GameUpdataState = {
	NORMAL = 1,
	SKIP = 2,
	FORCE = 3
}

--广告状态枚举
DebugDefine.ADState = {
	NORMAL = 1,
	CLOSE = 2,
	RESET = 3
}

--当前运行环境
DebugDefine.CurEnvState = 1

function DebugDefine.Init()
	DebugDefine.LoadDebugConfig()

	local fullpath = CC.Platform.isWin32 and pcLocalClientPath or phoneLocalClientPath

	_localClientData = DebugDefine.LoadLocalConfig(fullpath)

	if not _localClientData then
		local userPath = Util.userPath .. "client.json"
		_localClientData = DebugDefine.LoadLocalConfig(userPath)
	end
	if _localClientData then
		DebugDefine.SetDebugMode(_localClientData.RYCDebugMode)
		return
	end

	local debugCache = CC.LocalGameData.GetLocalStateToKey("HysMode")
	debugCache = debugCache == "true" and true or false
	DebugDefine.SetDebugMode(debugCache)
end

function DebugDefine.LoadLocalConfig(fullpath)
	local file = io.open(fullpath, "r")
	if file then
		local content = file:read("*a")
		local data = Json.decode(content)
		file:close()
		return data
	end
end

function DebugDefine.LoadDebugConfig()
	local cfg = CC.UserData.Load("DebugConfig", {})

	cfg.lan = cfg.lan or 1
	cfg.hall = cfg.hall or 1
	cfg.game = cfg.game or 1
	cfg.log = cfg.log or 1
	cfg.guide = cfg.guide or 1
	cfg.package = cfg.package or 1
	cfg.ad = cfg.ad or 1
	cfg.dot = cfg.dot or 1
	cfg.envState = cfg.envState or 1
	cfg.webConfig = cfg.webConfig or 1
	cfg.hallIP = cfg.hallIP or ""
	cfg.http = cfg.http or ""
	cfg.gameIP = cfg.gameIP or ""
	cfg.extraAddress = cfg.extraAddress or ""
	cfg.account = cfg.account or ""
	cfg.googleiap = cfg.googleiap or 1
	cfg.lock = cfg.lock or 1
	cfg.lowhttp = cfg.lowhttp or 1

	DebugDefine.DebugInfo = cfg
end

function DebugDefine.GetDebugConfig()
	return DebugDefine.DebugInfo
end

function DebugDefine.GetDebugMode()
	if CC.Platform.isWin32 then
		return true
	end
	return DebugDefine.HysMode
end

function DebugDefine.SetDebugMode(flag)
	if flag == nil then
		return
	end
	if type(flag) ~= "boolean" then
		return
	end
	CC.LocalGameData.SetLocalStateToKey("HysMode", tostring(flag))
	DebugDefine.HysMode = flag
end

local debugKey = "hys0922" -- 1.hyskey1909 2.ryc7907 3.hys0922
function DebugDefine.CheckDebugKey(key)
	if key == debugKey then
		DebugDefine.SetDebugMode(true)
	end
end

function DebugDefine.GetDebugKey()
	return CC.LocalGameData.GetLocalStateToKey("HysModeKey")
end

function DebugDefine.SaveDebugKey()
	if DebugDefine.GetDebugKey() == debugKey then
		return
	end
	DebugDefine.SetDebugMode(false)
	CC.LocalGameData.SetLocalStateToKey("HysModeKey", tostring(debugKey))
end

function DebugDefine.SaveDebugInfo(param)
	DebugDefine.DebugInfo = param
end

function DebugDefine.GetEnvState()
	if DebugDefine.GetDebugMode() then
		return DebugDefine.DebugInfo.envState
	else
		return DebugDefine.EnvState.Release
	end
end

function DebugDefine.GetWebConfigState()
	if DebugDefine.GetDebugMode() then
		return DebugDefine.DebugInfo.webConfig
	else
		return DebugDefine.WebConfigState.Release
	end
end

function DebugDefine.StateTurnBool(state)
	if state == 1 then
		return false
	elseif state == 2 then
		return true
	else
		return false
	end
end

function DebugDefine.GetEntryUrlPrefixByEnv()
	local envState = DebugDefine.GetEnvState()
	if envState == DebugDefine.EnvState.Release then
		return CC.UrlConfig.EntryUrl.Release
	elseif envState == DebugDefine.EnvState.PreRelease then
		return CC.UrlConfig.EntryUrl.Release
	elseif envState == DebugDefine.EnvState.Test then
		return CC.UrlConfig.EntryUrl.Test
	elseif envState == DebugDefine.EnvState.Dev then
		return CC.UrlConfig.EntryUrl.Dev
	elseif envState == DebugDefine.EnvState.StableDev then
		return CC.UrlConfig.EntryUrl.StableDev
	elseif envState == DebugDefine.EnvState.TH_Release then
		return CC.UrlConfig.EntryUrl.TH_Release
	end
end

function DebugDefine.GetUrlPrefixByEnv()
	local envState = DebugDefine.GetEnvState()
	if envState == DebugDefine.EnvState.Release then
		return CC.UrlConfig.EntryUrl.Release
	elseif envState == DebugDefine.EnvState.PreRelease then
		return CC.UrlConfig.EntryUrl.Release .. "/pre"
	elseif envState == DebugDefine.EnvState.Test then
		return CC.UrlConfig.EntryUrl.Test
	elseif envState == DebugDefine.EnvState.Dev or envState == DebugDefine.EnvState.StableDev then
		return CC.UrlConfig.EntryUrl.Dev
	elseif envState == DebugDefine.EnvState.TH_Release then
		return CC.UrlConfig.EntryUrl.TH_Release
	end
end

function DebugDefine.GetWebConfigPrefixByEnv()
	if DebugDefine.GetWebConfigState() == DebugDefine.WebConfigState.Release then
		return CC.UrlConfig.EntryUrl.Release
	elseif DebugDefine.GetWebConfigState() == DebugDefine.WebConfigState.PreRelease then
		return CC.UrlConfig.EntryUrl.Release .. "/pre"
	elseif DebugDefine.GetWebConfigState() == DebugDefine.WebConfigState.Test then
		return CC.UrlConfig.EntryUrl.Test
	elseif DebugDefine.GetWebConfigState() == DebugDefine.WebConfigState.Dev then
		return CC.UrlConfig.EntryUrl.Dev
	end
end

function DebugDefine.GetLanguageDebugState()
	if DebugDefine.GetDebugMode() then
		return DebugDefine.StateTurnBool(DebugDefine.DebugInfo.lan)
	else
		return false
	end
end

function DebugDefine.GetHallDebugState()
	if DebugDefine.GetDebugMode() then
		return DebugDefine.StateTurnBool(DebugDefine.DebugInfo.hall)
	else
		return false
	end
end

function DebugDefine.GetGameDebugSkipState()
	if DebugDefine.GetDebugMode() then
		if DebugDefine.DebugInfo.game == DebugDefine.GameUpdataState.NORMAL then
			return false
		elseif DebugDefine.DebugInfo.game == DebugDefine.GameUpdataState.SKIP then
			return true
		else
			return false
		end
	else
		return false
	end
end

function DebugDefine.GetGameDebugUpdateState()
	if DebugDefine.GetDebugMode() then
		if DebugDefine.DebugInfo.game == DebugDefine.GameUpdataState.NORMAL then
			return false
		elseif DebugDefine.DebugInfo.game == DebugDefine.GameUpdataState.SKIP then
			return false
		else
			return true
		end
	else
		return false
	end
end

function DebugDefine.GetGuideDebugState()
	if DebugDefine.GetDebugMode() then
		return DebugDefine.StateTurnBool(DebugDefine.DebugInfo.guide)
	else
		return false
	end
end

function DebugDefine.GetAdDebugState()
	if DebugDefine.GetDebugMode() then
		if DebugDefine.DebugInfo.ad == DebugDefine.ADState.NORMAL then
			return DebugDefine.ADState.NORMAL
		elseif DebugDefine.DebugInfo.ad == DebugDefine.ADState.CLOSE then
			return DebugDefine.ADState.CLOSE
		else
			return DebugDefine.ADState.RESET
		end
	else
		return DebugDefine.ADState.NORMAL
	end
end

function DebugDefine.GetDotDebugState()
	if DebugDefine.GetDebugMode() then
		return not DebugDefine.StateTurnBool(DebugDefine.DebugInfo.dot)
	else
		return false
	end
end

function DebugDefine.GetLockDebugState()
	if DebugDefine.GetDebugMode() then
		return DebugDefine.StateTurnBool(DebugDefine.DebugInfo.lock)
	else
		return false
	end
end

function DebugDefine.GetLowHttpDebugState()
	if DebugDefine.GetDebugMode() then
		return DebugDefine.StateTurnBool(DebugDefine.DebugInfo.lowhttp)
	else
		return false
	end
end

function DebugDefine.GetPackageDebugState()
	if DebugDefine.GetDebugMode() then
		return DebugDefine.StateTurnBool(DebugDefine.DebugInfo.package)
	else
		return false
	end
end

function DebugDefine.GetHallAddress()
	if DebugDefine.GetDebugMode() then
		if DebugDefine.DebugInfo.hallIP ~= nil and DebugDefine.DebugInfo.hallIP ~= "" then
			return DebugDefine.DebugInfo.hallIP
		end
	end
	return false
end

function DebugDefine.GetHallHttpAddress()
	if DebugDefine.GetDebugMode() then
		if DebugDefine.DebugInfo.http ~= nil and DebugDefine.DebugInfo.http ~= "" then
			return DebugDefine.DebugInfo.http
		end
	end
	return false
end

function DebugDefine.GetAuthAddress()
	if DebugDefine.GetDebugMode() then
		if DebugDefine.DebugInfo.http ~= nil and DebugDefine.DebugInfo.http ~= "" then
			if DebugDefine.CheckPreServer() then
				return "http://" .. DebugDefine.DebugInfo.http .. "/pre/hall"
			else
				return "http://" .. DebugDefine.DebugInfo.http .. "/hall"
			end
		end
	-- if DebugDefine.DebugInfo.hallIP ~= nil and DebugDefine.DebugInfo.hallIP ~= "" then
	-- 	local address = CC.DebugDefine.GetHallAddress()
	-- 	--截掉端口号
	-- 	local pos = string.find(address, ":")
	-- 	if pos then
	-- 		address = string.sub(address, 1, pos - string.len(":"))
	-- 	end
	-- 	if DebugDefine.CheckPreServer() then
	-- 		return "http://" .. address .. "/pre/hall"
	-- 	else
	-- 		return "http://" .. address .. "/hall"
	-- 	end
	-- end
	end
	return false
end

function DebugDefine.GetPrefixAddress()
	if DebugDefine.GetDebugMode() then
		if DebugDefine.DebugInfo.gameHttp ~= nil and DebugDefine.DebugInfo.gameHttp ~= "" then
			return DebugDefine.DebugInfo.gameHttp
		end
		-- 兼容开发二服
		if DebugDefine.GetEnvState() == DebugDefine.EnvState.StableDev then
			return CC.UrlConfig.EntryUrl.StableDev
		end
	end
	return false
end

-- function DebugDefine.GetPrefixAddress()
-- 	local url = false
-- 	if DebugDefine.GetDebugMode() then
-- 		-- url = DebugDefine.GetEntryUrlPrefixByEnv()
-- 		if DebugDefine.DebugInfo.http ~= nil and DebugDefine.DebugInfo.http ~= "" then
-- 			local address = DebugDefine.DebugInfo.http
-- 			--截掉端口号
-- 			local pos = string.find(address, ":")
-- 			if pos then
-- 				address = string.sub(address, 1, pos - string.len(":"))
-- 			end
-- 			if DebugDefine.CheckPreServer() then
-- 				url = "http://" .. address .. "/pre"
-- 			else
-- 				url = "http://" .. address .. ""
-- 			end
-- 		elseif DebugDefine.GetEnvState() == DebugDefine.EnvState.StableDev then
-- 			url = CC.UrlConfig.EntryUrl.StableDev
-- 		end
-- 	end
-- 	return url
-- end

function DebugDefine.GetLotAddress()
	if DebugDefine.GetDebugMode() then
		if DebugDefine.DebugInfo.lotIP ~= nil and DebugDefine.DebugInfo.lotIP ~= "" then
			return DebugDefine.DebugInfo.lotIP
		end
	end
	return false
end

function DebugDefine.GetGameAddress()
	if DebugDefine.GetDebugMode() then
		if DebugDefine.DebugInfo.gameIP ~= nil and DebugDefine.DebugInfo.gameIP ~= "" then
			return DebugDefine.DebugInfo.gameIP
		end
	end
	return false
end

function DebugDefine.GetExtraAddress()
	if DebugDefine.GetDebugMode() then
		if DebugDefine.DebugInfo.extraAddress ~= nil and DebugDefine.DebugInfo.extraAddress ~= "" then
			return DebugDefine.DebugInfo.extraAddress
		end
	end
	return false
end

function DebugDefine.GetAuthAddressWithOps()
	if DebugDefine.GetDebugMode() then
		if DebugDefine.DebugInfo.http ~= nil and DebugDefine.DebugInfo.http ~= "" then
			local address = CC.DebugDefine.GetHallAddress()
			--截掉端口号
			local pos = string.find(address, ":")
			if pos then
				address = string.sub(address, 1, pos - string.len(":"))
			end
			if DebugDefine.CheckPreServer() then
				return "http://" .. address .. "/pre/hall/?ops=%s&playerid=%s&token=%s"
			else
				return "http://" .. address .. "/hall/?ops=%s&playerid=%s&token=%s"
			end
		end
	end
	return false
end

function DebugDefine.GetAccount()
	if DebugDefine.GetDebugMode() then
		if DebugDefine.DebugInfo.account ~= nil and DebugDefine.DebugInfo.account ~= "" then
			return tostring(DebugDefine.DebugInfo.account)
		end
	end
	return false
end

-- function DebugDefine.SetTrailState(flag)
-- 	if DebugDefine.GetDebugMode() and DebugDefine.CheckTrail then
-- 		return;
-- 	end
-- 	DebugDefine.CheckTrail = flag;
-- end

function DebugDefine.CheckIOSTrail()
	CC.uu.Log("该API已弃用,请调用CC.ChannelMgr.GetIosTrailStatus()")
	return CC.ChannelMgr.GetIosTrailStatus()
	-- if CC.Platform.isIOS and DebugDefine.CheckTrail then
	-- 	return true;
	-- end
	-- return false;
end

function DebugDefine.CheckAndroidTrail()
	CC.uu.Log("该API已弃用,请调用CC.ChannelMgr.GetAndroidTrailStatus()")
	return CC.ChannelMgr.GetAndroidTrailStatus()
	-- if CC.Platform.isAndroid and DebugDefine.CheckTrail then
	-- 	return true;
	-- end
	-- return false;
end

function DebugDefine.CheckIOSPrivate()
	CC.uu.Log("该API已弃用,请调用CC.ChannelMgr.GetIOSPrivateStatus()")
	return CC.ChannelMgr.GetIOSPrivateStatus()
	-- if CC.Platform.isIOS then
	-- 	return CC.Platform.GetOSValueByChannel() == 3;
	-- end
	-- return false;
end

function DebugDefine.CheckPreServer()
	return DebugDefine.DebugInfo.envState == DebugDefine.EnvState.PreRelease
end

function DebugDefine.CheckReleaseServer()
	return DebugDefine.DebugInfo.envState == DebugDefine.EnvState.Release
end

return DebugDefine
