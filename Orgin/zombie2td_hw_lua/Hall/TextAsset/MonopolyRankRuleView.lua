local CC = require("CC")
local MonopolyRankRuleView = CC.uu.ClassView("MonopolyRankRuleView")
local M = MonopolyRankRuleView

--[[
@param
curLevel:当前等级
]]
function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param or {}
    self.language = CC.LanguageManager.GetLanguage("L_MonopolyRankView")
	self.rankCfg = CC.ConfigCenter.Inst():getConfigDataByKey("MonopolyConfig").rankCfg
end

function M:OnCreate()
    self:InitContent()
	self:InitTextByLanguage()
	self:RefreshUI()
end

function M:InitContent()
	
	self.cardItem = self:FindChild("Frame/ItemGroup/Item")
	self.cardParent = self:FindChild("Frame/ItemGroup")
	
	self:AddClick("BtnClose","ActionOut")

end

function M:InitTextByLanguage()
	self:FindChild("Frame/Top/Title").text = self.language.rankTitle
	self:FindChild("Frame/Top/Time").text = self.language.actTime
	self:FindChild("Frame/Desc1").text = self.language.ruleDesc1
	self:FindChild("Frame/Desc2").text = self.language.ruleDesc2
end

function M:RefreshUI()
	
	for i=0,29 do
		local isMask = self.param.curLevel < i
		local cardImg,iconImg = self:GetCardImgByLevel(i)
		local item = CC.uu.newObject(self.cardItem, self.cardParent)
		self:SetImage(item,cardImg)
		self:SetImage(item:FindChild("Icon"),iconImg)
		item:FindChild("Mask"):SetActive(isMask)
		item:FindChild("Text").text = "Lv."..i
		item:SetActive(true)
	end
end

function M:GetCardImgByLevel(level)
	local lv = Mathf.Clamp(level,0,29)
	local cardImg = string.format("cgxb_gl_dxdk%02d",lv%2==0 and 1 or 2)
	local iconImg = string.format("cgxb_gl_dx%02d",math.floor(lv/3)+1)
	return cardImg,iconImg
end

function M:OnDestroy()

end

return MonopolyRankRuleView