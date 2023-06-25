local CC = require("CC")
local DragonTurntableViewCtr = CC.class2("DragonTurntableViewCtr")

function DragonTurntableViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function DragonTurntableViewCtr:InitVar(view, param)
	self.param = param;
    self.view = view;
    self.WareIdList = {
        {WareId="30153", Status = true, CountDown = -2},
        {WareId="30154", Status = true, CountDown = -2},
        {WareId="30155", Status = true, CountDown = -2},}
end

function DragonTurntableViewCtr:OnCreate()
    self:RegisterEvent()
    self:LoadGiftStatus()
end

function DragonTurntableViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqOrderStatusResq,CC.Notifications.NW_GetOrderStatus)

    CC.HallNotificationCenter.inst():register(self,self.OnPurchaseNotifyResp,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():register(self,self.GiftReward,CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():register(self,self.LoadGiftStatus,CC.Notifications.OnTimeNotify)
end

function DragonTurntableViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetOrderStatus)

    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnTimeNotify)
end

function DragonTurntableViewCtr:LoadGiftStatus()
    CC.Request("GetOrderStatus",{"30153", "30154", "30155"})
end

function DragonTurntableViewCtr:ReqOrderStatusResq(err,data)
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
function DragonTurntableViewCtr:OnPurchaseNotifyResp(data)
	for _,v in ipairs(self.WareIdList) do
		if v.WareId == data.WareId then
            CC.Request("GetOrderStatus",{data.WareId})
			return
		end
	end
end

function DragonTurntableViewCtr:GiftReward(data)
    local isShowReward = data.Source == CC.shared_transfer_source_pb.TS_Dragon_Turntable1 or data.Source ==CC.shared_transfer_source_pb.TS_Dragon_Turntable2
                        or data.Source == CC.shared_transfer_source_pb.TS_Dragon_Turntable3
    if not isShowReward then return end
    local param = {}
    for k,v in ipairs(data.Rewards) do
        param[k] = {}
        param[k].ConfigId = v.ConfigId
        param[k].Count = v.Count
    end
    CC.ViewManager.OpenRewardsView({items = param})

end

function DragonTurntableViewCtr:Destroy()
	self:UnRegisterEvent();
end

return DragonTurntableViewCtr;
