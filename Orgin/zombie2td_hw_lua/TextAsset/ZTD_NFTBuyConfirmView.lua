local GC = require("GC")
local ZTD = require("ZTD")
--NFT卡装备界面
local NFTBuyConfirmView = ZTD.ClassView("ZTD_NFTBuyConfirmView")

--cardType 1合成成功  2强化成功  3购买卡片
function NFTBuyConfirmView:OnCreate()
	self.data = self._args[1]
	self.cb = self._args[2]
	
	self.card = ZTD.NFTCard:new(self.data, self:FindChild("root/Card"))
	
	local lan = ZTD.LanguageManager.GetLanguage("L_ZTD_NFTView");
	local str = string.format(lan.buyConfirm, self.data.price)
	self:SetText("root/TextTip", str)
	self:SetText("root/ButtonSure/Text", lan.sure)
	self:SetText("root/ButtonCancel/Text", lan.cancel)
    
	self:AddClick("Mask", function()
        self:Destroy()
    end)
	self:AddClick("root/BtnClose", function()
        self:Destroy()
    end)
	self:AddClick("root/ButtonSure", function()
		self.buySure = true
		self:Destroy()
    end)
	self:AddClick("root/ButtonCancel", function()
        self:Destroy()
    end)
end


function NFTBuyConfirmView:OnDestroy()
	if self.card then
		self.card:Release()
	end
	if self.cb then
		self.cb(self.buySure)
	end
end




return NFTBuyConfirmView