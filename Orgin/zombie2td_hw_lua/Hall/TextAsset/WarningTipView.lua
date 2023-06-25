
local CC = require("CC")
local WarningTipView = CC.uu.ClassView("WarningTipView")

function WarningTipView:ctor(param)
	self:InitVar(param);
	self.language = self:GetLanguage()
end

function WarningTipView:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();

	self:InitTextByLanguage()
	self:BtnClickEvent()
end

function WarningTipView:InitVar(param)

	self.param = param;
end

function WarningTipView:InitContent()

end

function WarningTipView:InitTextByLanguage()
	self:FindChild("Panel/Image/TipText").text = self.language.tips1;
end

function WarningTipView:BtnClickEvent()

	self:AddClick(self:FindChild("Panel/Image/KefuBtn"),function ()
		-- local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLocalServiceUrl();
		-- Client.OpenURL(url)
		CC.ViewManager.OpenServiceView()
	end)

	self:AddClick(self:FindChild("Panel/Image/XBtn"),function ()
		self:ActionOut();
	end)
	
end

function WarningTipView:OnDestroy()

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return WarningTipView