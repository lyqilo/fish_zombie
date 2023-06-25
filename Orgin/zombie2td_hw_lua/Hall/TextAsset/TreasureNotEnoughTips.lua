local CC = require("CC")
local TreasureNotEnoughTips = CC.uu.ClassView("TreasureNotEnoughTips")
local M = TreasureNotEnoughTips

function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param
    self.language = CC.LanguageManager.GetLanguage("L_TreasureView")
	self.realDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData")
end

function M:OnCreate()
    self:InitContent()
	self:InitTextByLanguage()
end

function M:InitContent()
	
	local goodsIcon = self:FindChild("Content/Goods/Icon")
	self:SetImage(goodsIcon,self.param.wareInfo.Icon)
	goodsIcon:GetComponent("Image"):SetNativeSize()
	
	local currencyId = self.param.wareInfo.Currency
	local currencyIcon = self:FindChild("Content/Currency")
	local haveNum = CC.Player.Inst():GetSelfInfoByKey(currencyId) or 0
	self:SetImage(currencyIcon, self.realDataMgr.GetPriceIcon(currencyId))
	currencyIcon:FindChild("Num").text = string.format("%d/%d",haveNum,self.param.wareInfo.Price)
	
	self:AddClick("BtnClose","ActionOut")
end

function M:InitTextByLanguage()
	self:FindChild("Title").text = self.param.tips or self.language.exNotEnought
end

function M:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					self:SetCanClick(true);
				end}
		});
end

function M:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function M:OnDestroy()
	
end

return TreasureNotEnoughTips