
local CC = require("CC")
local WorldCupADPageView = CC.uu.ClassView("WorldCupADPageView")

function WorldCupADPageView:ctor(param)

	self:InitVar(param);
end

function WorldCupADPageView:CreateViewCtr(...)
	local viewCtrClass = require("View/WorldCupView/"..self.viewName.."Ctr")
	return viewCtrClass.new(self, ...)
end

function WorldCupADPageView:OnCreate()
	self.language = CC.LanguageManager.GetLanguage("L_WorldCupView")

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitTextByLanguage()
	self:AddClickEvent()
end

function WorldCupADPageView:InitVar(param)

	self.param = param;
end

function WorldCupADPageView:InitContent()

end

function WorldCupADPageView:InitTextByLanguage()
	self:FindChild("Frame/BtnGo/Text").text = self.language.entryBtn
end

function WorldCupADPageView:AddClickEvent()
	self:AddClick("Frame/BtnGo",function ()
		CC.HallNotificationCenter.inst():post(CC.Notifications.EnterWorldCupPage)
		CC.ViewManager.Open("WorldCupView")
	end)
end

function WorldCupADPageView:OnDestroy()

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return WorldCupADPageView