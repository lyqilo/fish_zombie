local CC = require("CC")
local NewElkLimitGiftViewCtr = CC.class2("NewElkLimitGiftViewCtr")

function NewElkLimitGiftViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function NewElkLimitGiftViewCtr:InitVar(view, param)
	self.param = param;
    self.view = view;
    self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
end

function NewElkLimitGiftViewCtr:OnCreate()
    self:RegisterEvent()
    CC.Request("ReqRemainTime",{packType = CC.proto.client_pack_pb.TemporaryPack})
end

function NewElkLimitGiftViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.NewElkLimitGiftReward,CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():register(self,self.OnBroadcastRecordResp,CC.Notifications.NW_ReqRecordGet)
    CC.HallNotificationCenter.inst():register(self,self.OnPackStockResp,CC.Notifications.NW_ReqStockPackGet)
    CC.HallNotificationCenter.inst():register(self,self.OnRemainTimeResp,CC.Notifications.NW_ReqRemainTime)
end

function NewElkLimitGiftViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqRecordGet)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqStockPackGet)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqRemainTime)
end

function NewElkLimitGiftViewCtr:NewElkLimitGiftReward(data)
    if data.Source ~= CC.shared_transfer_source_pb.TS_Monthly_Seckill_Gift then return end

    CC.ViewManager.OpenRewardsView({items = data.Rewards,callback = function()
        for i,v in ipairs(data.Rewards) do
            if v.ConfigId == CC.shared_enums_pb.EPC_Oppo_A15s or v.ConfigId == CC.shared_enums_pb.EPC_DianKa_truemoney_50
                or  v.ConfigId == CC.shared_enums_pb.EPC_DianKa_truemoney_90 then
                 CC.ViewManager.Open("MailView") --有实物奖励打开邮箱
                 break
            end
        end
    end})
    
    CC.Request("ReqStockPackGet",{PackIDs = self.view.curWareId})
end

function NewElkLimitGiftViewCtr:CheckSourceid(id)
	for i=1,3 do
		if id == CC.shared_transfer_source_pb["Ts_Christmas_All_Gift_"..i] then
			return true,i
        end
    end
	return false
end

function NewElkLimitGiftViewCtr:OnBroadcastRecordResp(err,data)
    log(CC.uu.Dump(data, "OnBroadcastRecordResp"))
    if err == 0 and data.RecordList and table.length(data.RecordList) > 0 then
        self.view.Marquee.MessageTable = {}
        for i,info in ipairs(data.RecordList) do
            local reward = self.propLanguage[info.PropID]
            local prop = self.propLanguage[info.Currency]

            if info.PropID == CC.shared_enums_pb.EPC_ChouMa then
                reward = info.PropNum..reward
            end
           
            if reward and prop then
                self.view.Marquee:Report(string.format(self.view.language.report,info.PlayerName,info.Price..prop,reward))
            end
        end
    end
end

function NewElkLimitGiftViewCtr:OnPackStockResp(err,data)
    log(CC.uu.Dump(data, "OnPackStockResp"))
    if err == 0 and data.PackStock and table.length(data.PackStock) > 0 then
       for i,info in ipairs(data.PackStock) do
            for j,id in ipairs(self.view.curWareId) do
                if info.PackID == id then
                    self.view.curStock[j] = info.StockNum
                    break
                end
            end
       end
       self.view:RefreshView({refreshStock = true})
    end
end

function NewElkLimitGiftViewCtr:OnRemainTimeResp(err,data)
    log(CC.uu.Dump(data, "OnRemainTimeResp"))
    if err == 0  then
        if (data:HasField("IsFinished") and data.IsFinished) or (data:HasField("IsDayFinished") and data.IsDayFinished) then
            self.view:StopTimer("ReqStockPackGetReqStockPackGet")
            self.view.countDown = 0
            self.view.isStart = false
            self.view.curStock = {0,0,0}
            self.view:RefreshView({refreshTime = true,activityOver = true,refreshStock = true,refreshBatch = self.view.totalTimes})
        else
            if data:HasField("ToOpenTime") and data:HasField("ToEndTime") then
                self.view.countDown = data.ToOpenTime > 0 and data.ToOpenTime or data.ToEndTime
                self.view.isStart = data.ToEndTime > 0
            end
            self.view:RefreshView({refreshTime = true,refreshBatch = data.OpenTimes})
            if self.view.isStart then
                CC.Request("ReqStockPackGet",{PackIDs = self.view.curWareId})
            end
        end
        
    end
end

function NewElkLimitGiftViewCtr:GetPropId(currency)
    if currency == CC.shared_enums_pb.PCT_Chouma then
        return CC.shared_enums_pb.EPC_ChouMa
    elseif currency == CC.shared_enums_pb.PCT_GiftVoucher then
        return CC.shared_enums_pb.EPC_New_GiftVoucher
    elseif currency == CC.shared_enums_pb.PCT_Diamond then
        return CC.shared_enums_pb.EPC_ZuanShi
    end
    return nil
end

function NewElkLimitGiftViewCtr:Destroy()
	self:UnRegisterEvent()
end

return NewElkLimitGiftViewCtr
