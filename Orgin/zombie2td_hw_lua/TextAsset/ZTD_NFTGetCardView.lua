local GC = require("GC")
local ZTD = require("ZTD")
--NFT卡装备界面
local NFTGetCardView = ZTD.ClassView("ZTD_NFTGetCardView")

--cardType 1合成成功  2强化成功  3购买卡片 4每日赠送
function NFTGetCardView:OnCreate()
	self:InitLan()
	if #self._args > 0 then
		self.id = self._args[1]
		self.cardType = self._args[2]
		self.cb = self._args[3]
		self.data = self._args[4] or nil
	end
	local data = ZTD.NFTData.GetCard(self.id)
	self.card = ZTD.NFTCard:new(data, self:FindChild("Card"))
	
	if self.cardType == 4 then
		local lan = ZTD.LanguageManager.GetLanguage("L_ZTD_NFTView");
		self:SetText("CardType4/Text", lan.dayGetCardHint)
	end

	GC.Sound.PlayEffect("ZTD_nftGet")
	for i=1, 4 do
		if i == self.cardType then
			self:FindChild("CardType"..i):Show()
		else
			self:FindChild("CardType"..i):Hide()
		end
	end
    
	self:AddClick("Mask", function()
		if self.cardType == 4 then
			self:PlayAni()
		else
        	self:Destroy()
		end
    end)
end

function NFTGetCardView:PlayAni()
	self:FindChild("Mask"):SetActive(false)
	self:FindChild("Image"):SetActive(false)
	self:FindChild("CardType4"):SetActive(false)
	self.ImgCard = self:FindChild("Card")

	local scale = {"scaleTo", 0.4, 0.4, 0.4, 0.7, ease = ZTD.Action.EOutQuad}
	local delay = {"delay", 0.2}
	local move = {"localMoveTo", self.data.localPos.x, self.data.localPos.y, self.data.localPos.z, 0.5, 
	onEnd = function ()
		self:Destroy()
	end}
	
	ZTD.Extend.RunAction(self.ImgCard, {delay, move})
	ZTD.Extend.RunAction(self.ImgCard, {scale})
end

--设置强化+多少
function NFTGetCardView:SetPowerAdd(base,add)
	
end

function NFTGetCardView:OnDestroy()
	if self.card then
		self.card:Release()
	end
	if self.cb then
		self.cb()
	end
end




return NFTGetCardView