
local CC = require("CC")

local PayGiftExplainView = CC.uu.ClassView("PayGiftExplainView")

function PayGiftExplainView:ctor(param)

	self.param = param or {};
end

function PayGiftExplainView:OnCreate()

	self:InitContent();
end

function PayGiftExplainView:InitContent()

	--设置布局属性
	local content = self:FindChild("Frame/ScrollText/Viewport/Content");
	local layoutGroup = content:GetComponent("LayoutGroup");
	if self.param.alignment then
		layoutGroup.childAlignment = self.param.alignment;
	end
	if self.param.padding then
		for k,v in pairs(self.param.padding) do
			layoutGroup.padding[k] = v;
		end
	end

	local text = content:FindChild("Text"):GetComponent("Text");
	if self.param.alignment then
		text.alignment = self.param.alignment;
	end
	if self.param.lineSpace then
		text.lineSpacing = self.param.lineSpace;
	end

	self:AddClick("Frame/BtnClose", "ActionOut");

	self:InitTextByLanguage();
end

function PayGiftExplainView:InitTextByLanguage()

	local title = self:FindChild("Frame/Tittle/Text");
	title.text = self.param.title;

	local content = self:FindChild("Frame/ScrollText/Viewport/Content/Text");
	content.text = self.param.content;
end

return PayGiftExplainView;
