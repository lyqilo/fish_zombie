
local CC = require("CC")
local BatteryGiftViewCtr = CC.class2("BatteryGiftViewCtr")

function BatteryGiftViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function BatteryGiftViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function BatteryGiftViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
end

function BatteryGiftViewCtr:InitData()

end

function BatteryGiftViewCtr:OnPay(wareId,price)
	self.wareId = wareId
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
		CC.Request("ReqBuyWithId",{WareId=wareId,ExchangeWareId=wareId})
	else
		if self.view.walletView then
			self.view.walletView:SetBuyExchangeWareId(wareId)
			self.view.walletView:PayRecharge()
		end
	end
end

function BatteryGiftViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnPurchaseNotifyResp,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():register(self,self.GiftReward,CC.Notifications.OnDailyGiftGameReward)
	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function BatteryGiftViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

--购买成功
function BatteryGiftViewCtr:OnPurchaseNotifyResp(data)
	--购买成功返回WareId
end

function BatteryGiftViewCtr:GiftReward(data)
	CC.uu.Log(data,"GiftReward-->>data:")
    local isShowReward = data.Source == CC.shared_transfer_source_pb.TS_Battery_LimitTimeGift
    if not isShowReward then return end
    local param = {}
    for k,v in ipairs(data.Rewards) do
        param[k] = {}
        param[k].ConfigId = v.ConfigId
        param[k].Count = v.Count
    end
    CC.ViewManager.OpenRewardsView({items = param})
	self.view:ShowBuyGaeyBtn()
end

function BatteryGiftViewCtr:Destroy()

	self:UnRegisterEvent();
end

return BatteryGiftViewCtr;
