local CC = require("CC")

local BrokeGiftViewCtr = CC.class2("BrokeGiftViewCtr")

function BrokeGiftViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function BrokeGiftViewCtr:InitVar(view,param)
	self.param = param
	self.view = view
end

function BrokeGiftViewCtr:OnCreate()
	self:InitData()
	self:RegisterEvent()
end

function BrokeGiftViewCtr:InitData()
    self.giftInfo = {["23001"] = {status = true, min = 280000, max = 3000000, price = 269}, ["23002"] = {status = true, min = 850000, max = 10000000, price = 799}, ["23003"] = {status = true, min = 3000000, max = 30000000, price = 2699}}

    self.rankData = {}
end

function BrokeGiftViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnRefreshPropChange,CC.Notifications.changeSelfInfo)
    CC.HallNotificationCenter.inst():register(self,self.OnPurchaseNotifyResp,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():register(self,self.ReqBrokeGiftStatusResp,CC.Notifications.NW_ReqBrokeGiftStatus)
    CC.HallNotificationCenter.inst():register(self,self.ReqBrokeRankRecordResp,CC.Notifications.NW_ReqBrokeGiftRank)
end

function BrokeGiftViewCtr:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.changeSelfInfo)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqBrokeGiftStatus)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqBrokeGiftRank);
end

function BrokeGiftViewCtr:OnRefreshPropChange(props, source)
    local ChouMa = 0
	for _,v in ipairs(props) do
        if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
			ChouMa = v.Delta
		end
    end
	if source == CC.shared_transfer_source_pb.TS_BrokenGift_269 or source == CC.shared_transfer_source_pb.TS_BrokenGift_999 or source == CC.shared_transfer_source_pb.TS_BrokenGift_2699 then
		self.view:RewardGold(ChouMa)
    end
end

--购买成功
function BrokeGiftViewCtr:OnPurchaseNotifyResp(data)
    if self.giftInfo[data.WareId] then
        self.giftInfo[data.WareId].status = false
        self.view:SetBuyBtnState(data.WareId, false)
        self.view:SetRulePanel(data.WareId)
        self.view.activityDataMgr.SetBrokeGiftGrade(data.WareId)
        self.view.buyInBroke = true
    end
end

function BrokeGiftViewCtr:ReqBrokeGiftStatus()
    CC.Request("ReqBrokeGiftStatus")
end

function BrokeGiftViewCtr:ReqBrokeGiftStatusResp(err, result)
    log("err = ".. err.."  "..CC.uu.Dump(result,"ReqBrokeGiftStatusResp",10))
    if err == 0 then
        self.view.activityDataMgr.SetBrokeGiftData(result)
        if result.nStatus == 1 then
            self.view:SetGiftInfo(result)
            self.view.activityDataMgr.SetActivityInfoByKey("BrokeGiftView", {switchOn = true})
        end
    end
end

function BrokeGiftViewCtr:ReqBrokeRankRecord(grade)
    CC.Request("ReqBrokeGiftRank", {nGiftType = grade})
end

function BrokeGiftViewCtr:ReqBrokeRankRecordResp(err,result)
	log("err = ".. err.."  "..CC.uu.Dump(result,"ReqBrokeRankRecord",10))
    if err == 0 and result.nGiftType then
        self.rankData[result.nGiftType] = result.arrPlayerInfo
		self.view:SetAwardInfo(result.arrPlayerInfo)
	end
end

function BrokeGiftViewCtr:Destroy()
	self:unRegisterEvent()
end

return BrokeGiftViewCtr