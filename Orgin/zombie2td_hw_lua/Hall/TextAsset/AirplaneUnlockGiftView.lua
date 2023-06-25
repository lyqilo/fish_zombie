local CC = require("CC")
local AirplaneUnlockGiftView = CC.uu.ClassView("AirplaneUnlockGiftView")

function AirplaneUnlockGiftView:ctor(param)
    self.param = param;
end

function AirplaneUnlockGiftView:OnCreate()
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    self.wareId = "30006"
	self.giftPrice = self.wareCfg[self.wareId].Price or 143
	self:RegisterEvent()
	self:InitUI()
end

function AirplaneUnlockGiftView:InitUI()
	self:FindChild("BuyBtn/Text").text = self.giftPrice

	self:AddClick(self:FindChild("BtnClose"), "ActionOut")
    self:AddClick(self:FindChild("BuyBtn"), "OnBuyGift")

    self.walletView = CC.uu.CreateHallView("WalletView", {parent = self.transform, exchangeWareId = self.wareId})
	 CC.Request("GetOrderStatus",{self.wareId})
end

function AirplaneUnlockGiftView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.AirPlaneUnLockReward,CC.Notifications.OnDailyGiftGameReward)
end

function AirplaneUnlockGiftView:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
end

function AirplaneUnlockGiftView:OnBuyGift()
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= self.giftPrice then
		local data={}
        data.WareId=self.wareId
        data.ExchangeWareId=self.wareId
        CC.Request("ReqBuyWithId",data)

	else
		if self.walletView then
			self.walletView:PayRecharge()
		end
	end
end

function AirplaneUnlockGiftView:AirPlaneUnLockReward(param)
	log(CC.uu.Dump(param,"param",10))
    if param.Source == CC.shared_transfer_source_pb.TS_AirPlane_Unlock then
        local data = {};
		for k,v in ipairs(param.Rewards) do
			if v.ConfigId ~= CC.shared_enums_pb.EPC_AirPlane_Unlock_9002 then
				data[k] = {}
				data[k].ConfigId = v.ConfigId
				data[k].Count = v.Count
			end
		end
		local Cb = function()
			self:ActionOut()
		end
		CC.ViewManager.OpenRewardsView({items = data, callback = Cb})
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnGameUnlockGift, {GameId = 3007})
    end
end

function AirplaneUnlockGiftView:ActionIn()
end
function AirplaneUnlockGiftView:ActionOut()
    self:Destroy()
end

function AirplaneUnlockGiftView:OnDestroy()
	--CC.Sound.StopEffect()
	if self.param and self.param.callBack then
		self.param.callBack(true)
	end
	if self.walletView then
		self.walletView:Destroy()
	end
	self:unRegisterEvent()
end

return AirplaneUnlockGiftView;