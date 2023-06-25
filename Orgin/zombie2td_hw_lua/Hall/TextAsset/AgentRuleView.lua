--[[
	规则页
]]

local CC = require("CC")

local BaseClass = CC.uu.ClassView("AgentRuleView")

function BaseClass:ctor()
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView");
end

function BaseClass:OnCreate()
	self:InitContent()
	self:InitTextByLanguage();

end

function BaseClass:InitContent()
	self.mask = self:FindChild("mask")

	self:AddClick(self:FindChild("content/closeBtn"),slot(self.ActionOut,self))

end

function BaseClass:InitTextByLanguage()
	self:FindChild("content/title").text = self.language.ruletitle

	self:FindChild("content/Text").text = self.language.rulemaintext

	self:FindChild("content/content1/titleText").text = self.language.e1
	self:FindChild("content/content1/context").text = self.language.rulecontent1

	self:FindChild("content/content2/titleText").text = self.language.e2
	self:FindChild("content/content2/context").text = self.language.rulecontent2

	self:FindChild("content/content3/titleText").text = self.language.e3
	self:FindChild("content/content3/context").text = self.language.rulecontent3
	
end

function BaseClass:OnDestroy()

end

-- function BaseClass:ActionIn() end

-- function BaseClass:ActionOut() end

return BaseClass