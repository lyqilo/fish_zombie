local CC = require("CC")

local ElephantExplainView = CC.uu.ClassView("ElephantExplainView")

function ElephantExplainView:OnCreate()

	self:InitContent();
end

function ElephantExplainView:InitContent()

	self:AddClick("Frame/BtnClose", "ActionOut");

	self:InitTextByLanguage();
end

function ElephantExplainView:InitTextByLanguage()

	local language = CC.LanguageManager.GetLanguage("L_GoldenElephant");

	local title = self:FindChild("Frame/Tittle/Text");
	title.text = language.Rule;

	local content = self:FindChild("Frame/ScrollText/Viewport/Content/Text");
	content.text = language.explainContent;
end

return ElephantExplainView;
