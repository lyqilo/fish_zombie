local CC = require("CC")
local ChipNotEnoughTips = CC.uu.ClassView("ChipNotEnoughTips")
local M = ChipNotEnoughTips

--[[
金币不足提示
@param
tips:提示文本
needValue:需求数量
]]
function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param or {}
    self.language = CC.LanguageManager.GetLanguage("L_TreasureView")
end

function M:OnCreate()
    self:InitContent()
	self:InitTextByLanguage()
end

function M:InitContent()
	local haveChip = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
	local needChip = self.param.needValue
	self:FindChild("Frame/Chip/Text").text = string.format("<color=#FF0000>%d</color>/%d",haveChip,needChip)
	self:AddClick("Frame/BtnFitter/BtnOk","ActionOut")
end

function M:InitTextByLanguage()
	self:FindChild("Frame/Message").text = self.param.tips or ""
	self:FindChild("Frame/BtnFitter/BtnOk/Text").text = self.language.btnOk
end

function M:OnDestroy()
	
end

return ChipNotEnoughTips