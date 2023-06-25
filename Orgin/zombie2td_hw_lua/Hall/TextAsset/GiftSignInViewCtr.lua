local CC = require("CC")

local EffectPropCfg = require("Model/Config/CSVExport/GiftSignCfg")

local GiftSignInViewCtr = CC.class2("GiftSignInViewCtr")

function GiftSignInViewCtr:ctor(view,param)
    self.view = view
    self.param = param
    --礼盒列表
    self.rewardBoxList = {}
    --当前消耗钻石
    self.curCostDiamond = nil

    --记录列表
    self.recordList = nil

    --跑马灯下标
    self.MarqueeIndex = 1

    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop");

    self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
end

function GiftSignInViewCtr:OnCreate()
	self:InitData();
	self:RegisterEvent();
end

function GiftSignInViewCtr:InitData()
    --获取宝箱数据
    self:Req_Gift_Data()
    --请求中奖记录列表
    self:Req_Gift_Prizes()
end

function GiftSignInViewCtr:Req_Gift_Data()
    local playerID = CC.Player.Inst():GetSelfInfoByKey("Id")
    CC.Request("Req_Gift_Data",{PlayerID = playerID})
end

function GiftSignInViewCtr:Req_Gift_Lottery(boxId)
    local playerID = CC.Player.Inst():GetSelfInfoByKey("Id")
    CC.Request("Req_Gift_Lottery",{PlayerID = playerID, GiftID = boxId})
end

function GiftSignInViewCtr:Req_Gift_Prizes()
    CC.Request("Req_Gift_Prizes")
end

function GiftSignInViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnReq_Gift_DataRsp,CC.Notifications.NW_Req_Gift_Data)
    CC.HallNotificationCenter.inst():register(self,self.OnReq_Gift_LotteryRsp,CC.Notifications.NW_Req_Gift_Lottery)
    CC.HallNotificationCenter.inst():register(self,self.OnDailyGiftSignRecordRsp,CC.Notifications.NW_Req_Gift_Prizes)
    --CC.HallNotificationCenter.inst():register(self,self.OnGiftSignInBigReward,CC.Notifications.OnGiftSignInBigReward)
end

function GiftSignInViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_Req_Gift_Data)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_Req_Gift_Lottery)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_Req_Gift_Prizes)
    --CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnGiftSignInBigReward)
end

function GiftSignInViewCtr:OnReq_Gift_DataRsp(err,data)
    if err == 0 then
        self.rewardBoxList = {}
        self.curCostDiamond = data.Amount   
        for k,v in ipairs(data.GiftLists) do
            self.rewardBoxList[v.GiftID] = v
        end
        self.view:RefreshBoxState(self.rewardBoxList)
        self.view:RefreshSliderProgress(self.curCostDiamond)
    else
        self.view:ActionOut()
    end
end

function GiftSignInViewCtr:OnReq_Gift_LotteryRsp(err,data)
    if err == 0 then
        local reward = {}
        reward.ConfigId = data.PropID
        if data.PrizeType == CC.client_gift_pb.Point_Card then
            reward.Count = data.PrizeCount
        else
            reward.Count = data.PrizeValue            
        end   
        reward.PrizeType = data.PrizeType
        self.view:PlayLotteryAnim(reward)        
    end
end

function GiftSignInViewCtr:OnDailyGiftSignRecordRsp(err,data)
    if err == 0 then
        self.recordList = {}
        for i,v in ipairs(data.List) do
            table.insert(self.recordList,v)
        end
        self.view:InitRecordPanel(#self.recordList)     
        
    end
end
--服务器主推的中奖记录
-- function GiftSignInViewCtr:OnGiftSignInBigReward(param)
--     if self.recordList then
--         table.insert(self.recordList,1,param.data)
--     end
--     self.view:InitRecordPanel(#self.recordList)
--     self.MarqueeIndex = 1
-- end

function GiftSignInViewCtr:SetRecordInfo(tran,dataIndex,cellIndex)
    local info = self.recordList[dataIndex + 1]
    local param = {}
    param.id = info.PlayerId
    param.portrait = info.Portrait
    param.vip = info.VIP
    param.nick = info.Name
    --服务器用Rank字段传时间戳
    param.time = CC.uu.TimeOut3(info.Rank)
    if info.Reward.ConfigId == 10004 and info.Reward.Count == 1000 then
      param.des = self.PropDataMgr.GetLanguageDesc(info.Reward.ConfigId,info.Reward.Count).." x2"
    else
        param.des = self.PropDataMgr.GetLanguageDesc(info.Reward.ConfigId,info.Reward.Count)
    end
    
    self.view:SetRecordItem(tran,param,dataIndex + 1)
end

function GiftSignInViewCtr:GetMarqueeText()
    if self.recordList[self.MarqueeIndex] then
        local info = self.recordList[self.MarqueeIndex]
        local nick = info.Name
        local extraCount = ""
        if info.Reward.ConfigId == 10004 and info.Reward.Count == 1000 then
            extraCount = " x2"
        end
        local reward = self.PropDataMgr.GetLanguageDesc(info.Reward.ConfigId,info.Reward.Count)..extraCount
        self.MarqueeIndex = self.MarqueeIndex + 1   
        if self.MarqueeIndex > #self.recordList then
            nick = ""
            reward = ""
            self.MarqueeIndex = 1
            self.view:StopMarquee()
        end
        return nick,reward
    end
end

function GiftSignInViewCtr:Destroy()

	self:UnRegisterEvent();
end

return GiftSignInViewCtr