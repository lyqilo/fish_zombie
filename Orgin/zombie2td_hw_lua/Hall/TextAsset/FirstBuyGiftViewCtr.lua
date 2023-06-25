
local CC = require("CC")
local FirstBuyGiftViewCtr = CC.class2("FirstBuyGiftViewCtr")

function FirstBuyGiftViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function FirstBuyGiftViewCtr:InitVar(view, param)
	self.param = param;
	self.view = view;
	self.BigRewardValue = 0
end

function FirstBuyGiftViewCtr:OnCreate()

	self:RegisterEvent();
	CC.Request("ReqTenFristGiftJP")
	CC.Request("ReqTenFristGiftInfo")
	CC.Request("ReqTenFristGiftBigReward")

	--定时请求奖池数据
	self.view:StartTimer("RefreJackPot",5,function()
		CC.Request("ReqTenFristGiftJP")
    end,-1)

end

function FirstBuyGiftViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnTenFristGiftInfoRsp,CC.Notifications.NW_ReqTenFristGiftInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnReqTenFristGiftLotteryRsp,CC.Notifications.NW_ReqTenFristGiftLottery)
	CC.HallNotificationCenter.inst():register(self,self.OnReqTenFristGiftJPRsp,CC.Notifications.NW_ReqTenFristGiftJP)
	CC.HallNotificationCenter.inst():register(self,self.OnReqTenFristGiftBigRewardRsp,CC.Notifications.NW_ReqTenFristGiftBigReward)

	CC.HallNotificationCenter.inst():register(self,self.FirstGiftBuyReward,CC.Notifications.OnDailyGiftGameReward)
	CC.HallNotificationCenter.inst():register(self,self.RefreshViewActivity,CC.Notifications.OnRefreshActivityBtnsState)
end

function FirstBuyGiftViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function FirstBuyGiftViewCtr:OnTenFristGiftInfoRsp(err,data)
	self.view.isCanClick = true
	log(CC.uu.Dump(data, "OnTenFristGiftInfoRsp"))
	if err == 0 and data and CC.uu.isTable(data) then
		self.view:RefreshGiftState(data.PayTimes,data.CanPayTimes,data.AbleTimes)
	end
end

function FirstBuyGiftViewCtr:OnReqTenFristGiftLotteryRsp(err,data)
	self.view.isCanClick = true
	log(CC.uu.Dump(data, "OnReqTenFristGiftLotteryRsp"))
	if err == 0 and data and CC.uu.isTable(data) then
		if data.PayTimes > data.CanPayTimes then
			self.view.isCanBuy = false
			self.view.isCanLottery = false
			return
		end
	    if data.rewards and data.rewards[1] then
		    self.view:StartLotter({Rewards = data.rewards,data = data})
		end
		local Case1 = data.rewards[1].ConfigId == CC.shared_enums_pb.EPC_ChouMa and data.rewards[1].Count >= data.BigRewardValue
		local Case2 = data.rewards[1].ConfigId == CC.shared_enums_pb.EPC_PointCard_Fragment
		local Case3 = data.rewards[1].ConfigId == CC.shared_enums_pb.EPC_50Card
		if Case1 or Case2 or Case3 then
			CC.Request("ReqTenFristGiftBigReward")
			if Case1 then
				CC.Request("ReqTenFristGiftJP")
			end
		end
	end
end

function FirstBuyGiftViewCtr:OnReqTenFristGiftJPRsp(err,data)
	if err == 0 and data and data.JackPot then
		self.view:RefreshJackPot(data.JackPot)
	end
end

function FirstBuyGiftViewCtr:OnReqTenFristGiftBigRewardRsp(err,data)
	log(CC.uu.Dump(data, "OnReqTenFristGiftBigRewardRsp",10))
	if err == 0 and data and data.List and table.length(data.List) > 0 then
		self.view:DelayRun(1,function ()
			self.view:ShowWinner(data.List)
		end)
	end
end

function FirstBuyGiftViewCtr:FirstGiftBuyReward(data)
	log(CC.uu.Dump(data, "FirstGiftBuyReward"))
	if data.Source == CC.shared_transfer_source_pb.TS_FristPay_Treasure_10 then
		self.view.isCanBuy = false
		CC.Request("ReqTenFristGiftInfo") --收到礼包奖励请求礼包状态

		CC.ViewManager.OpenRewardsView({items = data.Rewards})
	end
end

function FirstBuyGiftViewCtr:RefreshViewActivity(key,switchOn)
	if key == "FirstBuyGift" and not switchOn then
		self.view.activityOver = true --活动关闭，不让购买和抽奖
	end
end

function FirstBuyGiftViewCtr:Destroy()
	self:UnRegisterEvent()
end

return FirstBuyGiftViewCtr;
