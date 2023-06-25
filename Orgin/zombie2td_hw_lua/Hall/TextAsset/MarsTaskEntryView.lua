local CC = require("CC")
local MarsTaskEntryView = CC.uu.ClassView("MarsTaskEntryView")
local M = MarsTaskEntryView

function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param
	self.language = CC.LanguageManager.GetLanguage("L_MarsTaskView")
end

function M:OnCreate()

    self:InitContent()
	self:InitTextByLanguage()
	self:RegisterEvent()
	self:RefreshRedPacket()
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnSwitchStateChange, CC.Notifications.OnRefreshActivityBtnsState)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function M:InitContent()
	self:AddClick("Frame/BtnGo","OnClickBtnGo")
end

function M:InitTextByLanguage()
	self:FindChild("Frame/BtnGo/Text").text = self.language.entryBtn
end

function M:OnClickBtnGo()
	CC.HallNotificationCenter.inst():post(CC.Notifications.JumpToMarsTask)
end

function M:OnSwitchStateChange(key,switchOn)
	if key == "MarsTaskEntryView" and not switchOn then
		CC.ViewManager.ShowTip(self.language.entryOverTip)
	end
end

function M:RefreshRedPacket()
	local num = CC.Player.Inst():GetSelfInfoByKey("EPC_One_Red_env")
	self:FindChild("Frame/Counter/Icon/Text").text = num or 0
end

function M:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					self:SetCanClick(true);
				end}
		});
end

function M:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function M:OnDestroy()
	self:UnRegisterEvent()
end

return MarsTaskEntryView