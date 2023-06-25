local CC = require("CC")
local HalloweenLoginGiftView = CC.uu.ClassView("HalloweenLoginGiftView")

function HalloweenLoginGiftView:ctor(param)
	self:InitVar(param)
end

function HalloweenLoginGiftView:InitVar(param)
	self.param = param
	self.itemList = {}
	self.wareId = "30256"
	self.language = self:GetLanguage()
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
end

function HalloweenLoginGiftView:OnCreate()
	
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
	
	self:InitContent()
	self:InitTextByLanguage()
end

function HalloweenLoginGiftView:InitContent()
	
	self.buyBtn = self:FindChild("Frame/BuyBtn")
	self.getBtn = self:FindChild("Frame/GetBtn")
	self.previewPanel = self:FindChild("PreviewPanel")
	self.itemEffect = self:FindChild("Frame/RewardsGroup/ItemEffect")
	for i=1,4 do
		self.itemList[i] = self:FindChild("Frame/RewardsGroup/Item"..i)
	end
	
	self:AddClick("Mask","ActionOut")
	self:AddClick(self.buyBtn,"OnClickBuyBtn")
	self:AddClick(self.getBtn,"OnClickGetBtn")
	self:AddClick("Effec/UI/Box",function ()
		self.previewPanel:SetActive(true)
	end)
	self:AddClick("PreviewPanel/Close",function ()
		self.previewPanel:SetActive(false)
	end)
	self:AddClick("PreviewPanel/Btn",function ()
		self.previewPanel:SetActive(false)
	end)
	
	self:FindChild("Frame/BuyBtn/Text").text = self.wareCfg[self.wareId].Price
	self:RefreshRewardItem()
	self.walletView = CC.uu.CreateHallView("WalletView", {parent = self.transform, exchangeWareId = self.wareId})
end

function HalloweenLoginGiftView:InitTextByLanguage()
	self:FindChild("Frame/Top/ActTime").text = self.language.actTime
	self:FindChild("Frame/Tips").text = self.language.tipDes
	self:FindChild("Frame/LTip/Text").text = self.language.leftTips
	self:FindChild("Frame/RTip/Text").text = self.language.rightTips
	self:FindChild("Frame/GetBtn/Text").text = self.language.btnGet
	self:FindChild("Frame/GrayBtn/Text").text = self.language.btnGray
	self:FindChild("Frame/AllGetBtn/Text").text = self.language.btnAllGet
	self:FindChild("PreviewPanel/BG/Title/Text").text = self.language.previewTitle
	self:FindChild("PreviewPanel/Text1").text = self.language.previewText1
	self:FindChild("PreviewPanel/Text2").text = self.language.previewText2
	self:FindChild("PreviewPanel/Btn/Text").text = self.language.btnOK
end

--1:未购买	2:未领取  3:已领取
function HalloweenLoginGiftView:RefreshBtnStatus(state)
	local isCanBuy = CC.HallUtil.IsHalloweenLoginGiftCanBuy()
	self:FindChild("Frame/BuyBtn"):SetActive(state==1 and isCanBuy)
	self:FindChild("Frame/GetBtn"):SetActive(state==2)
	self:FindChild("Frame/GrayBtn"):SetActive(state==3)
	self:FindChild("Frame/AllGetBtn"):SetActive(state==4)
end

function HalloweenLoginGiftView:RefreshRewardItem()
	for k,v in ipairs(self.viewCtr.rewardsCfg) do
		self:SetImage(self.itemList[k]:FindChild("Prop"),self.propCfg[v.Id].Icon)
		self.itemList[k]:FindChild("Prop"):GetComponent("Image"):SetNativeSize()
		self.itemList[k]:FindChild("Num").text = string.format("x%s",v.Num)
		
	end
	for k,v in ipairs(self.viewCtr.finalRewardsCfg) do
		local item = self:FindChild("PreviewPanel/Content/Item"..k)
		self:SetImage(item:FindChild("Icon"),self.propCfg[v.Id].Icon)
		item:FindChild("Icon"):GetComponent("Image"):SetNativeSize()
		item:FindChild("Num").text = string.format("x%s",v.Num)
	end
end

function HalloweenLoginGiftView:ShowItemLight(index,isShowEffect)
	self.itemList[index]:GetComponent("Toggle").isOn = true
	if isShowEffect then
		self.itemEffect.localPosition = self.itemList[index].localPosition
		self.itemEffect:SetActive(true)
	end
end

function HalloweenLoginGiftView:ShowRewardsView(rewards)
	local callbackFun = function()
		self.viewCtr:ReqGiftInfo()
	end
	CC.ViewManager.OpenRewardsView({items = {rewards}, callback = callbackFun})
end

function HalloweenLoginGiftView:OnClickBuyBtn()
	
	local price = self.wareCfg[self.wareId].Price
	
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
		CC.Request("ReqBuyWithId",{WareId=self.wareId,ExchangeWareId=self.wareId})
	else
		if self.walletView then
			self.walletView:PayRecharge()
		end
	end
	
end

function HalloweenLoginGiftView:OnClickGetBtn()
	self.viewCtr:ReqGetRewards()
end

function HalloweenLoginGiftView:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					self:SetCanClick(true);
				end}
		});
end

function HalloweenLoginGiftView:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.2, function() self:Destroy() end},
		});
end

function HalloweenLoginGiftView:OnDestroy()
	
	if self.walletView then
		self.walletView:Destroy()
		self.walletView = nil
	end

	if self.viewCtr then
		self.viewCtr:OnDestroy()
		self.viewCtr = nil
	end
	
end

return HalloweenLoginGiftView