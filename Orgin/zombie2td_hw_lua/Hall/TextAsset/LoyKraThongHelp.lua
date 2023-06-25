local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local baseClass = CC.class2("LoyKraThongWish",ViewUIBase)

function baseClass:ctor()

end

function baseClass:OnCreate(...)
	self.language = CC.LanguageManager.GetLanguage("L_LoyKraThong");
	self:InitContent()
	self:InitTextByLanguage()
end

function baseClass:InitContent()
	self.TopText = self:SubGet("Frame/Top/TopText","Text")

	self.TitleText = self:SubGet("Frame/notice/Scroll View/Viewport/Content/TitleText","Text")
	self.Text = self:SubGet("Frame/notice/Scroll View/Viewport/Content/Text","Text")

	self:AddClick("Frame/BtnClose",slot(self.OnBtnCloseClick,self))
end

function baseClass:InitTextByLanguage()
	self.TopText.text = self.language.helpTopText
	self.TitleText.text = self.language.helpTitle
	self.Text.text = self.language.helpContent
end

function baseClass:OnBtnCloseClick()
	self:SetActive(false)
end

function baseClass:OnShow( ... )
	-- body
end

function baseClass:OnHide( ... )
	-- body
end

function baseClass:OnDestroy( ... )
	-- body
end

return baseClass