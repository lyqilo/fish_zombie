-------------------------------------
-- region CardFragExchangeView.lua  -
-- Date: 2020.10.13                 -
-- Desc: 点卡碎片兑换界面             -
-- Author: Kevin                    -
-------------------------------------
local CC = require("CC")

local CardFragExchangeView = CC.uu.ClassView("CardFragExchangeView")

function CardFragExchangeView:ctor(param)
	self:InitVar(param)
end

function CardFragExchangeView:InitVar(param)
	self.goodsID = param.goodsID
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("PhysicalShop")
    self.realDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData")
end

function CardFragExchangeView:OnCreate()
	self.language = CC.LanguageManager.GetLanguage("L_TreasureView")

    self:AddClickEvent()

	self:InitUIContent()
    
end

function CardFragExchangeView:AddClickEvent()
	self.upBtn = self:FindChild("BG/upAll/upBtn")
	self:AddClick(self.upBtn,function()
		local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
        if vipLevel == 0 and CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
        	local param = {}
        	param.SelectGiftTab = {"NoviceGiftView"}
        	CC.ViewManager.Open("SelectGiftCollectionView",param)  
        elseif vipLevel > 0 and vipLevel < 3 then
            CC.ViewManager.Open("VipThreeCardView")
        elseif vipLevel>=3 then
        	CC.ViewManager.Open("StoreView")     	
        end   
        self:Destroy()  
	end)
	self:AddClick("BG/closeBtn",function () self:ActionOut() end)
end

function CardFragExchangeView:InitUIContent()
	self:FindChild("BG/upAll/upText").text = self.language.upTipText
	self.upBtn:FindChild("Text").text = self.language.upText
	local exchangeCount = CC.Player.Inst():GetSelfInfoByKey("EPC_Card_Pieces_Exchange_Count") 
	self:FindChild("BG/exchangeCountText").text = self.language.canExchangePCCount..exchangeCount
	self.TreasureItemDown = self:FindChild("BG/TreasureItem/Base/Down")

	self.TreasureItemDown:FindChild("Name").text = CC.ConfigCenter.Inst():getDescByKey("ware_"..self.wareCfg[self.goodsID].ProductId)
	local pcfNum = CC.Player.Inst():GetSelfInfoByKey("EPC_PointCard_Fragment")
	self.TreasureItemDown:FindChild("Price/Text").text = pcfNum..'/'..self.wareCfg[self.goodsID].Price
	local node = self.TreasureItemDown:FindChild("Icon")
	self:SetImage(node,self.wareCfg[self.goodsID].Icon)     
	node:GetComponent("Image"):SetNativeSize()
	local cfgIcon = self.TreasureItemDown:FindChild("Price/Text/Icon")
	self:SetImage(cfgIcon, self.realDataMgr.GetPriceIcon(self.wareCfg[self.goodsID].Currency))
	cfgIcon:GetComponent("Image"):SetNativeSize()
end

function CardFragExchangeView:ActionOut()
	self:SetCanClick(false);
    self:RunAction(self, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    		self:Destroy();
    	end})
end

function CardFragExchangeView:OnDestroy()
end

return CardFragExchangeView

