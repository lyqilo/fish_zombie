
local CC = require("CC")
local MonopolyGiftViewCtr = CC.class2("MonopolyGiftViewCtr")

function MonopolyGiftViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function MonopolyGiftViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function MonopolyGiftViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
	self.wareId = nil
end

function MonopolyGiftViewCtr:InitData()

end

function MonopolyGiftViewCtr:OnPay(wareId)
	self.wareId = wareId
	local price = self.view.wareCfg[wareId].Price
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
		CC.Request("ReqBuyWithId",{WareId=wareId,ExchangeWareId=wareId})
	else
		if self.view.walletView then
			self.view.walletView:SetBuyExchangeWareId(wareId)
			self.view.walletView:PayRecharge()
		end
	end
end

function MonopolyGiftViewCtr:ReqGfitBuyCompleted(wareId)
    CC.Request("Req_UW_MonopolyGiftChange", {GameId = CC.shared_enums_pb.AE_Breakthrough_party, Id = wareId})
end

function MonopolyGiftViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnPurchaseNotifyResp,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():register(self,self.GiftReward,CC.Notifications.OnDailyGiftGameReward)
	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function MonopolyGiftViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

--购买成功
function MonopolyGiftViewCtr:OnPurchaseNotifyResp(data)
	if not self.wareId or self.wareId ~= data.WareId then
		return
	end
	self.view.isBuyGift = true
	self:ReqGfitBuyCompleted(data.WareId)
	self.view:ActionOut()
end

function MonopolyGiftViewCtr:GiftReward(data)
    local isShowReward = data.Source == CC.shared_transfer_source_pb.TS_Monopoly_GiftPack1 or data.Source ==CC.shared_transfer_source_pb.TS_Monopoly_GiftPack2
                        or data.Source == CC.shared_transfer_source_pb.TS_Monopoly_GiftPack3 or data.Source == CC.shared_transfer_source_pb.TS_Monopoly_GiftPack4
						or data.Source == CC.shared_transfer_source_pb.TS_Monopoly_GiftPack5
    if not isShowReward then return end
    local param = {}
    for k,v in ipairs(data.Rewards) do
        param[k] = {}
        param[k].ConfigId = v.ConfigId
        param[k].Count = v.Count
    end
    CC.ViewManager.OpenRewardsView({items = param})
end

function MonopolyGiftViewCtr:Destroy()

	self:UnRegisterEvent();
end

return MonopolyGiftViewCtr;
