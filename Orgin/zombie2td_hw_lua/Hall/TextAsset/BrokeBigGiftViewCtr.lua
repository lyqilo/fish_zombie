local CC = require("CC")
local BrokeBigGiftViewCtr = CC.class2("BrokeBigGiftViewCtr")

function BrokeBigGiftViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function BrokeBigGiftViewCtr:InitVar(view,param)
	self.param = param
	self.view = view
end

function BrokeBigGiftViewCtr:OnCreate()
	self:InitData()
	self:RegisterEvent()
end

function BrokeBigGiftViewCtr:InitData()
    self.giftInfo = {
        ["30080"] = {status = true, min = 6300000, max = 11000000, price = 5299},
        ["30081"] = {status = true, min = 31000000, max = 60000000, price = 25999},
        ["30082"] = {status = true, min = 65000000, max = 120000000, price = 52999}
    }
    self.rankData = {}
end

function BrokeBigGiftViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnRefreshPropChange,CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():register(self,self.OnPurchaseNotifyResp,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():register(self,self.ReqBrokeBigGiftStatusResp,CC.Notifications.NW_ReqBrokeBigGiftStatus)
    CC.HallNotificationCenter.inst():register(self,self.ReqBrokeRankRecordResp,CC.Notifications.NW_ReqBrokeBigGiftRank)
end

function BrokeBigGiftViewCtr:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqBrokeBigGiftStatus)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqBrokeBigGiftRank);
end

function BrokeBigGiftViewCtr:OnRefreshPropChange(param)
    local ChouMa = 0
    if param.Source == CC.shared_transfer_source_pb.TS_BrokenBigGift_5299 or param.Source == CC.shared_transfer_source_pb.TS_BrokenBigGift_25999 or param.Source == CC.shared_transfer_source_pb.TS_BrokenBigGift_52999 then
        for _,v in ipairs(param.Rewards) do
            if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
                ChouMa = ChouMa + v.Count
            end
        end
        self.view:RewardGold(ChouMa)
    end
end

--购买成功
function BrokeBigGiftViewCtr:OnPurchaseNotifyResp(data)
    if self.giftInfo[data.WareId] then
        self.giftInfo[data.WareId].status = false
        self.view:SetBuyBtnState(data.WareId, false)
        self.view:SetRulePanel(data.WareId)
        self.view.activityDataMgr.SetBrokeBigGiftGrade(data.WareId)
        self.view.buyInBroke = true
    end
end

function BrokeBigGiftViewCtr:ReqBrokeGiftStatus()
    CC.Request("ReqBrokeBigGiftStatus")
end

function BrokeBigGiftViewCtr:ReqBrokeBigGiftStatusResp(err, result)
    log("err = ".. err.."  "..CC.uu.Dump(result,"ReqBrokeBigGiftStatusResp",10))
    if err == 0 then
        self.view.activityDataMgr.SetBrokeBigGiftData(result)
        if result.nStatus == 1 then
            self.view:SetGiftInfo(result)
            self.view.activityDataMgr.SetActivityInfoByKey("BrokeBigGiftView", {switchOn = true})
        end
    end
end

function BrokeBigGiftViewCtr:ReqBrokeRankRecord(grade)
    CC.Request("ReqBrokeBigGiftRank", {nGiftType = grade})
end

function BrokeBigGiftViewCtr:ReqBrokeRankRecordResp(err,result)
    log("err = ".. err.."  "..CC.uu.Dump(result,"ReqBrokeBigGiftRank",10))
    if err == 0 and result.nGiftType then
        self.rankData[result.nGiftType] = result.arrPlayerInfo
		self.view:SetAwardInfo(result.arrPlayerInfo)
	end
end

function BrokeBigGiftViewCtr:Destroy()
	self:unRegisterEvent()
end

return BrokeBigGiftViewCtr