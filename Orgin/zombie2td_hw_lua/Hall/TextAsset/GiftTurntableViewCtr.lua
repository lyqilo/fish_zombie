local CC = require("CC")

local GiftTurntableViewCtr = CC.class2("GiftTurntableViewCtr")

function GiftTurntableViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function GiftTurntableViewCtr:InitVar(view,param)
    self.view = view
    self.param = param
    self.curType = nil
    --奖品列表数据
    self.TurnTableListInfo ={items ={{block = 1,rewardId = 10006,rewardCount = 1},
                {block = 2,rewardId = 5000002,rewardCount = 2},
                {block = 3,rewardId = 2,rewardCount = 500},
                {block = 4,rewardId = 5000001,rewardCount = 2},
                {block = 5,rewardId = 46,rewardCount = 20},
                {block = 6,rewardId = 2,rewardCount = 10000},
                {block = 7,rewardId = 2,rewardCount = 2000},
                {block = 8,rewardId = 2,rewardCount = 5000}
                }
            }
    self:RegisterEvent()
end

function GiftTurntableViewCtr:OnCreate()
    self:ReqLotteryInfo()

end

function GiftTurntableViewCtr:ReqLotteryInfo()
    CC.Request("ReqLotteryInfo")
end


function GiftTurntableViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnReqLotteryInfo,CC.Notifications.NW_ReqLotteryInfo)
    CC.HallNotificationCenter.inst():register(self,self.OnRespLottery,CC.Notifications.NW_Req_Turntable_lottery)
end

function GiftTurntableViewCtr:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqLotteryInfo)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_Req_Turntable_lottery)

end
--self.curType  1 免费抽奖 2 抽1次 3 抽10次
function GiftTurntableViewCtr:ReqFreeLottery(choosetype)
    self.curType = choosetype
    CC.Request("Req_Turntable_lottery",{Type = self.curType})
end

function GiftTurntableViewCtr:ReqTenLottery(choosetype)
    self.curType = choosetype
    CC.Request("Req_Turntable_lottery",{Type = self.curType})
end

function GiftTurntableViewCtr:OnReqLotteryInfo(err,data)
    if err == 0 then
        self.view:RefreshTurntableItem(self.TurnTableListInfo,data)
    end
end

function GiftTurntableViewCtr:OnRespLottery(err,data)
    --模拟data数据
    --local data = {block = 1,rewardId = 10001,rewardCount = 2}
    ----------------------------------------------
    if err == 0 then
        if self.curType == 1 or self.curType == 2 then
            local awardData = {}
            if data.AwardList[1] then
                local blockID = data.AwardList[1].AwardID - 1000
                if blockID == 9 then
                    blockID = 3
                elseif blockID == 10 then
                    blockID = 5
                elseif blockID == 11 then
                    blockID = 7
                end
                awardData.block = blockID
                awardData.rewardId = data.AwardList[1].PropID
                awardData.rewardCount = data.AwardList[1].PropNum
                self.view:FreeLotteryEvent(awardData)
            end
        elseif self.curType == 3 then
            local awardData = {}
            if data.AwardList then
                for i,v in ipairs(data.AwardList) do
                    local blockID = v.AwardID - 1000
                    if blockID == 9 then
                        blockID = 3
                    elseif blockID == 10 then
                        blockID = 5
                    elseif blockID == 11 then
                        blockID = 7
                    end
                    local infoData = {}
                    infoData.block = blockID
                    infoData.rewardId = v.PropID
                    infoData.rewardCount = v.PropNum
                    table.insert(awardData,infoData)
                end
                self.view:TenLotteryEvent(awardData)
            end
        end
    else
        self.view:SetCanClick(true)
    end
end

function GiftTurntableViewCtr:Destroy()
    self:unRegisterEvent()
end

return GiftTurntableViewCtr