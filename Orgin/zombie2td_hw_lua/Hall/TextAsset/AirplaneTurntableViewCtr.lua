local CC = require("CC")
local AirplaneTurntableViewCtr = CC.class2("AirplaneTurntableViewCtr")

function AirplaneTurntableViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function AirplaneTurntableViewCtr:InitVar(view, param)
	self.param = param;
    self.view = view;
    self.WareIdList = {
        {WareId="30239", Status = true, multi = 6000, CountDown = -2},
        {WareId="30238", Status = true, multi = 700, CountDown = -2},
        {WareId="30237", Status = true, multi = 200, CountDown = -2},}
end

function AirplaneTurntableViewCtr:OnCreate()
    self:RegisterEvent()
    self:LoadGiftStatus()
end

function AirplaneTurntableViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqOrderStatusResq,CC.Notifications.NW_GetOrderStatus)

    CC.HallNotificationCenter.inst():register(self,self.OnPurchaseNotifyResp,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():register(self,self.GiftReward,CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():register(self,self.LoadGiftStatus,CC.Notifications.OnTimeNotify)
end

function AirplaneTurntableViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetOrderStatus)

    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnTimeNotify)
end

function AirplaneTurntableViewCtr:LoadGiftStatus()
    CC.Request("GetOrderStatus",{"30237", "30238", "30239"})
end

function AirplaneTurntableViewCtr:ReqOrderStatusResq(err,data)
    log(CC.uu.Dump(data, "ReqOrderStatusResq"))
    if data.Items then
        for _, v in ipairs(data.Items) do
			for _, giftdata in ipairs(self.WareIdList) do
				if v.WareId == giftdata.WareId then
                    giftdata.Status = v.Enabled
                    giftdata.CountDown = v.CountDown
                    if v.CountDown > 0 then
                        self.view.countDown = v.CountDown
                    end
					break
				end
            end
        end
    end
    self.view:RefreshUI()
end

--购买成功
function AirplaneTurntableViewCtr:OnPurchaseNotifyResp(data)
	for _,v in ipairs(self.WareIdList) do
		if v.WareId == data.WareId then
            CC.Request("GetOrderStatus",{data.WareId})
			return
		end
	end
end

function AirplaneTurntableViewCtr:GiftReward(data)
    local isShowReward = data.Source == CC.shared_transfer_source_pb.TS_Planwar_Spin_138 or data.Source ==CC.shared_transfer_source_pb.TS_Planwar_Spin_548
                        or data.Source == CC.shared_transfer_source_pb.TS_Planwar_Spin_5600
    if not isShowReward then return end
    local param = {}
    for k,v in ipairs(data.Rewards) do
        param[k] = {}
        param[k].ConfigId = v.ConfigId
        param[k].Count = v.Count
    end
    CC.ViewManager.OpenRewardsView({items = param})

end

function AirplaneTurntableViewCtr:Destroy()
	self:UnRegisterEvent();
end

return AirplaneTurntableViewCtr;
