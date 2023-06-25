local CC = require("CC")
local BaseClass = CC.uu.ClassView("AchievementGiftIcon")

function BaseClass:ctor()
	
end

function BaseClass:Create(param)
	if param.parent == nil then
		logError("AchievementGiftIcon param.parent is nil !!!")
		return
	end
	self.transform = CC.uu.LoadHallPrefab("prefab", "AchievementGiftIcon", param.parent);
end

function BaseClass:OnCreate()
	self:InitContent()
	self:RegisterEvent()
end

function BaseClass:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self, self.OnDailySpinInfoRsp, CC.Notifications.NW_ReqGetDailySpinInfo);

end

function BaseClass:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetDailySpinInfo);

end

function BaseClass:InitContent()
	-- self.timeText
end

local timerName = "Play"

function BaseClass:Play()
	local time = 5
	self:StartTimer(timerName,1,function ()
		self.timeText.text = time.."s"
		if time < 0 then
			self:StopTimer(timerName)
			self:PlayMoveAnim()
		end
	end,-1)
end

function BaseClass:PlayMoveAnim()
	-- body
end

function BaseClass:OnDestroy()

	self:UnRegisterEvent();
end

return BaseClass