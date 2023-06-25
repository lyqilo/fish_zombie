
local CC = require("CC")
local GiftExchangeViewCtr = CC.class2("GiftExchangeViewCtr")

function GiftExchangeViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function GiftExchangeViewCtr:OnCreate()

	self:RegisterEvent();
    self:ReqGiftTurnTableRecord()
end

function GiftExchangeViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
    --记录列表
    self.recordList = nil

    --跑马灯下标
    self.MarqueeIndex = 1
    self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
end

function GiftExchangeViewCtr:ReqGiftTurnTableRecord()
    CC.Request("ReqGiftTurnTableRecord")
end

function GiftExchangeViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.GiftExchangeReward,CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():register(self,self.OnGiftTurnTableRecordRsp,CC.Notifications.NW_ReqGiftTurnTableRecord)
end

function GiftExchangeViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward);
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGiftTurnTableRecord)
end

function GiftExchangeViewCtr:GiftExchangeReward(data)
    if data.Source ~= CC.shared_transfer_source_pb.TS_MidMonth_Treasure then return end
    log(CC.uu.Dump(data, "GiftExchangeReward"))
    local Rewards={}
    for _,v in ipairs(data.Rewards) do
        table.insert(Rewards,{id = v.ConfigId,count = v.Count})
    end

    self:RewardGold(Rewards)
end

--奖励
function GiftExchangeViewCtr:RewardGold(Rewards)
    local param = {}
    for i,v in ipairs(Rewards) do
        param[i]=
        {
            ConfigId=v.id,
            Delta=v.count
        }
    end
    CC.ViewManager.OpenRewardsView({items = param})
end


--中奖记录
function GiftExchangeViewCtr:OnGiftTurnTableRecordRsp(err,data)
    if err == 0 then
        self.recordList = {}
        for i,v in ipairs(data.RecordList) do
            table.insert(self.recordList,v)
        end
        self.view:InitRecordPanel(#self.recordList)

    end
end

function GiftExchangeViewCtr:GetMarqueeText()
    if self.MarqueeIndex > #self.recordList then
            local nick = ""
            local reward = ""
            self.MarqueeIndex = 1
            self.view:StopMarquee()
        return nick,reward
    end
    if self.recordList[self.MarqueeIndex] then
        local info = self.recordList[self.MarqueeIndex]
        local nick = info.PlayerName
        local reward = self.PropDataMgr.GetLanguageDesc(info.PropID,info.PropNum)
        self.MarqueeIndex = self.MarqueeIndex + 1
        return nick,reward
    end
end


function GiftExchangeViewCtr:Destroy()

	self:UnRegisterEvent();
end

return GiftExchangeViewCtr;
