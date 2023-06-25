-- 配置表ChannelSwitch ，多渠道（包括提审和私包）功能开关配置 管理类
-- TODO
-- 后续考虑整合SDKConfig、StoreViewCtr:GetStoreCfg()中配置

local CC = require("CC")
local ChannelSwitchManager = {}
local this = ChannelSwitchManager

local _switchChannelId = tonumber(AppInfo.ChannelID)
local _isTrail = false
-- local _switchChannelId = 19999
-- local _isTrail = true

local channelSwitchData
local function GetChannelSwitchData()
	if channelSwitchData == nil then
		channelSwitchData = CC.ConfigCenter.Inst():getConfigDataByKey("ChannelSwitch")
	end
	if channelSwitchData[_switchChannelId] then
		return channelSwitchData[_switchChannelId]
	else
		return channelSwitchData[1]
	end
end

function this.GetChannelID()
	return AppInfo.ChannelID
end

function this.SetTrailStatus(isTrail)
	-- if CC.DebugDefine.GetDebugMode() then
	-- 	return
	-- end

	_isTrail = isTrail

	if _isTrail then
		if CC.Platform.isIOS then
			_switchChannelId = 19999
		end

		if CC.Platform.isAndroid then
			_switchChannelId = 29999
		end

		--屏蔽vip经验值弹窗
		local propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
		propCfg[CC.shared_enums_pb.EPC_Experience].IsReward = false
	end
end

-- 只有提审或者私包需要特殊处理时使用
function this.GetTrailStatus()
	return _isTrail
end

function this.GetIosTrailStatus()
	return CC.Platform.isIOS and _isTrail
end

function this.GetAndroidTrailStatus()
	return CC.Platform.isAndroid and _isTrail
end

function this.GetIOSPrivateStatus()
	return CC.Platform.isIOS and AppInfo.ChannelID == "10000"
end

function this.CheckOppoChannel()
	return AppInfo.ChannelID == "20002" and CC.Platform.isAndroid
end

function this.CheckVivoChannel()
	return AppInfo.ChannelID == "20003" and CC.Platform.isAndroid
end

-- 官网渠道
function this.CheckOfficialWebChannel()
	return AppInfo.ChannelID == "20010"
end

-- 不同渠道不同处理时，增加配置key
function this.GetSwitchByKey(key)
	local switch = GetChannelSwitchData()[key]
	if switch ~= nil then
		return switch
	else
		logError(key)
	end
end

local TrailViewDefine = {
	[19999] = {
		HallView = "TrailIOSHallView",
		StoreView = "TrailStoreView",
		PersonalInfoView = "TrailPersonalInfoView",
		LoginView = "TrailIOSLoginView"
	},
	[29999] = {
		HallView = "TrailAndroidHallView",
		PersonalInfoView = "TrailPersonalInfoView",
		LoginView = "TrailLoginView"
	}
}

function this.GetTrailView(viewName)
	if TrailViewDefine[_switchChannelId] then
		return TrailViewDefine[_switchChannelId][viewName]
	end
end

return this
