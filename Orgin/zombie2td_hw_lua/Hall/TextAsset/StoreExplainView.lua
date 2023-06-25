
local CC = require("CC")

local StoreExplainView = CC.uu.ClassView("StoreExplainView")

function StoreExplainView:OnCreate(param)
	self.param = param or {}
	self.initCap = self.param.InitCap or 39900
	self.limitCap = self.param.LimitCap or 299900
	self:InitContent();
end

function StoreExplainView:InitContent()

	self:AddClick("Frame/BtnClose", "ActionOut");

	self:InitTextByLanguage();
end

function StoreExplainView:InitTextByLanguage()

	local language = self:GetLanguage();

	local title = self:FindChild("Frame/Title");
	title.text = language.title;

	local content = self:FindChild("Frame/ScrollText/Viewport/Content/Text");
	if CC.Platform.isIOS then
		content.text = string.format(language.contentIOS, self.initCap / 100, self.limitCap / 100);
	else
		content.text = language.content;
	end
end

return StoreExplainView;
