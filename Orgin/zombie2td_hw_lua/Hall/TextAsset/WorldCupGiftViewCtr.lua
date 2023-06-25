
local CC = require("CC")
local WorldCupGiftViewCtr = CC.class2("WorldCupGiftViewCtr")

function WorldCupGiftViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function WorldCupGiftViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function WorldCupGiftViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
end

function WorldCupGiftViewCtr:InitData()

end

function WorldCupGiftViewCtr:RequestInfo()
	CC.Request("ReqWorldCupBuyGiftInfo",nil,function (err,data)
		self.view:SetParam(data)
	end,function (err,data)
		CC.uu.Log(err,"ReqWorldCupBuyGiftInfo-->>err:")
	end)
end

function WorldCupGiftViewCtr:RequestBuy()

	if not CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetGiftStatus(self.view.WareId) then
		CC.ViewManager.ShowTip(self.view.language.Gift_Buy_Limit)
		return
	end

	local price = self.view.wareCfg[self.view.WareId].Price
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
		CC.Request("ReqBuyWithId",{WareId=self.view.WareId,ExchangeWareId=self.view.WareId})
	else
		if self.view.walletView then
			self.view.walletView:SetBuyExchangeWareId(self.view.WareId)
			self.view.walletView:PayRecharge()
		end
	end

end

function WorldCupGiftViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.DailyGiftReward,CC.Notifications.OnDailyGiftGameReward)
	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function WorldCupGiftViewCtr:DailyGiftReward(data)

	if data.Source == CC.shared_transfer_source_pb.TS_WorldCup_Quizgift then
		local param = {};
		for k,v in ipairs(data.Rewards) do
			param[k] = {}
			param[k].ConfigId = v.ConfigId
			param[k].Count = v.Count
		end
		CC.ViewManager.OpenRewardsView({items = param})
		CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetGiftStatus(self.view.WareId, false)
		self.view:RefreshSlider()
	end
end

function WorldCupGiftViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward);

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

function WorldCupGiftViewCtr:Destroy()

	self:UnRegisterEvent();
end

return WorldCupGiftViewCtr;
