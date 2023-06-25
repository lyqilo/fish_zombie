local CC = require("CC")
local SpecialOfferGiftViewCtr = CC.class2("SpecialOfferGiftViewCtr")

function SpecialOfferGiftViewCtr:ctor(view,param)
	self:InitVar(view,param)
end

function SpecialOfferGiftViewCtr:InitVar(view,param)
    self.view = view
	self.param = param
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.giftInfo = {
		{wareId = "30265", price = self.wareCfg["30265"].Price, rewards ={{id=2,num=62000},{id=4,num=3}}, status = true, source = CC.shared_transfer_source_pb.TS_Splash_DailyGift_50},--泼水节每日礼包1
		{wareId = "30266", price = self.wareCfg["30266"].Price, rewards ={{id=2,num=320000},{id=4,num=50}},status = true, source = CC.shared_transfer_source_pb.TS_Splash_DailyGift_270},--泼水节每日礼包2
		{wareId = "30267", price = self.wareCfg["30267"].Price, rewards ={{id=2,num=3400000},{id=28,num=1},{id=51,num=1}}, status = true, source = CC.shared_transfer_source_pb.TS_Splash_SpecialGift}}--泼水节特价礼包
end

function SpecialOfferGiftViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnGiftRewards, CC.Notifications.OnDailyGiftGameReward)
	CC.HallNotificationCenter.inst():register(self,self.OnGiftStatusRsp, CC.Notifications.NW_ReqTimesbuy)
end

function SpecialOfferGiftViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function SpecialOfferGiftViewCtr:OnCreate()
	self:RegisterEvent()
	self:ReqGiftStatus()
end

function SpecialOfferGiftViewCtr:ReqGiftStatus()
	local wareIds = {}
	for k,v in ipairs(self.giftInfo) do
		wareIds[k] = v.wareId
	end
	CC.Request("ReqTimesbuy",{PackIDs = wareIds})
end

function SpecialOfferGiftViewCtr:OnGiftStatusRsp(err,data)
	if err ~= 0 then
		logError("ReqTimesbuy err:"..err)
		return
	end
	CC.uu.Log(data,"OnTimesbuyRsp",1)
	if data.TimesBuy then
		for _,info in ipairs(data.TimesBuy) do
			for _, gift in ipairs(self.giftInfo) do
				if info.PackID == gift.wareId then
					if info.PackID == self.giftInfo[3].wareId then
						gift.status = info.RemainTotalTimes > 0
					else
						gift.status = info.RemainDayTimes > 0
					end
					break
				end
			end
		end
	end
	self.view:RefreshView()
	self.view:SetCanClick(true)
end

function SpecialOfferGiftViewCtr:OnPay(WareId)
	local price = self.wareCfg[WareId].Price
	if CC.Player:Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
		local data={}
		data.WareId = WareId
		data.ExchangeWareId = WareId
		CC.Request("ReqBuyWithId",data)
	else
		if self.view.walletView then
			self.view.walletView:SetBuyExchangeWareId(WareId)
			self.view.walletView:PayRecharge()
		end
	end
end

function SpecialOfferGiftViewCtr:OnGiftRewards(param)
	CC.uu.Log(param,"OnGiftRewards",1)
	local isCurGift = false
	for _, v in ipairs(self.giftInfo) do
		if param.Source == v.source then
			isCurGift = true
			break
		end
	end
	if not isCurGift then return end
	local data = {};
	for k,v in ipairs(param.Rewards) do
		data[k] = {}
		data[k].ConfigId = v.ConfigId
		data[k].Count = v.Count
	end
	CC.ViewManager.OpenRewardsView({items = data})
	self:ReqGiftStatus()
end

function SpecialOfferGiftViewCtr:Destroy()
	self:UnRegisterEvent()
end

return SpecialOfferGiftViewCtr