local CC = require("CC")
local MonopolyRuleView = CC.uu.ClassView("MonopolyRuleView")
local M = MonopolyRuleView

function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param or {}
    self.language = CC.LanguageManager.GetLanguage("L_MonopolyView")
end

function M:OnCreate()
    self:InitContent()
	self:InitTextByLanguage()
end

function M:InitContent()
	self:AddClick("BtnClose","ActionOut")
end

function M:InitTextByLanguage()
	self:FindChild("Frame/Title").text = self.language.ruleTitle
	self:FindChild("Frame/Desc1").text = self.language.ruleText
	self:FindChild("Frame/Desc2").text = self.language.ruleText2
end

function M:OnDestroy()
end

return MonopolyRuleView