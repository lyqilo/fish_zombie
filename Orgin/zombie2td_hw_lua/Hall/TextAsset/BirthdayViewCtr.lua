local CC = require("CC")
local BirthdayViewCtr = CC.class2("BirthdayViewCtr")

function BirthdayViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function BirthdayViewCtr:InitVar(view, param)
	self.param = param
	self.view = view
end

function BirthdayViewCtr:OnCreate()
	self:RegisterEvent()
end

function BirthdayViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.BirthdayGiftReward, CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():register(self,self.ReqTimesbuyResq, CC.Notifications.NW_ReqTimesbuy)
end

function BirthdayViewCtr:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqTimesbuy)
end

function BirthdayViewCtr:ReqTimesbuyGift()
    CC.Request("ReqTimesbuy",{PackIDs = {"30233","30234","30235","30236"}})
end

function BirthdayViewCtr:ReqTimesbuyResq(err, data)
    log(CC.uu.Dump(data, "ReqTimesbuy"))
    if err == 0 then
        if data.TimesBuy then
            for _,info in ipairs(data.TimesBuy) do
                for _, gift in ipairs(self.view.giftInfo) do
                    if info.PackID == gift.wareId then
                        gift.status = info.RemainShortTimes > 0
                        break
                    end
                end
            end
        end
        self.view:RefreshView()
    end
end

function BirthdayViewCtr:BirthdayGiftReward(param)
    log(CC.uu.Dump(param,"BirthdayGiftReward",10))
    local isCurGift = false
    for _, v in ipairs(self.view.giftInfo) do
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
    self:ReqTimesbuyGift()
end

function BirthdayViewCtr:Destroy()
	self:unRegisterEvent()
end

return BirthdayViewCtr