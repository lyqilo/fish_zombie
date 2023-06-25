local CC = require("CC")
local SuperDailyGiftViewCtr = CC.class2("SuperDailyGiftViewCtr")

function SuperDailyGiftViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function SuperDailyGiftViewCtr:InitVar(view, param)
	self.param = param or {}
    self.view = view
end

function SuperDailyGiftViewCtr:OnCreate()
    self:RegisterEvent()
end

function SuperDailyGiftViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqOrderStatusResq,CC.Notifications.NW_GetOrderStatus)

    CC.HallNotificationCenter.inst():register(self,self.OnPurchaseNotifyResp,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():register(self,self.DailyGiftReward,CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():register(self,self.LoadGiftStatus,CC.Notifications.OnTimeNotify)
    CC.HallNotificationCenter.inst():register(self,self.UserVipChanged,CC.Notifications.VipChanged)
end

function SuperDailyGiftViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function SuperDailyGiftViewCtr:ReqOrderStatusResq(err,data)
    log(CC.uu.Dump(data, "ReqOrderStatusResq"))
    if err == 0 and data.Items and #(data.Items) > 0 then
        for _, v in ipairs(data.Items) do
			for _, giftdata in ipairs(self.view.ShowGiftData) do
				if v.WareId == giftdata.WareId then
                    giftdata.Status = v.Enabled
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

function SuperDailyGiftViewCtr:LoadGiftStatus()
    local wareIds = self.view.GiftLevel[self.view.Level]
    log(CC.uu.Dump(wareIds, "ReqOrderStatus:"))
    CC.Request.GetOrderStatus(wareIds)
end

function SuperDailyGiftViewCtr:UserVipChanged(curLevel)
    --VIP等级变化，刷新礼包档位
    self.view:SelectGiftLevel(curLevel)
end

--购买成功
function SuperDailyGiftViewCtr:OnPurchaseNotifyResp(data)
    log(CC.uu.Dump(data, "OnPurchaseNotifyResp"))
	for i,v in ipairs(self.view.ShowGiftData) do
		if v.WareId == data.WareId then
			CC.Request.GetOrderStatus({data.WareId})
			return
		end
	end
end

function SuperDailyGiftViewCtr:DailyGiftReward(data)
    local isShowReward = data.Source == CC.shared_transfer_source_pb.TS_Promotional_DailyTreasure1 or data.Source ==CC.shared_transfer_source_pb.TS_Promotional_DailyTreasure2
                        or data.Source==CC.shared_transfer_source_pb.TS_Promotional_DailyTreasure3 or data.Source ==CC.shared_transfer_source_pb.TS_Promotional_DailyTreasure4
                        or data.Source==CC.shared_transfer_source_pb.TS_Promotional_DailyTreasure5 or data.Source ==CC.shared_transfer_source_pb.TS_Promotional_DailyTreasure6
                        or data.Source ==CC.shared_transfer_source_pb.TS_Promotional_DailyTreasure7
    if not isShowReward then return end
    log(CC.uu.Dump(data, "DailyGiftReward:"))

    CC.ViewManager.OpenRewardsView({items = data.Rewards})
end

function SuperDailyGiftViewCtr:Destroy()
	self:UnRegisterEvent();
end

return SuperDailyGiftViewCtr;
