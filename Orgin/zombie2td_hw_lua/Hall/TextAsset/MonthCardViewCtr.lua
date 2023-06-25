
local CC = require("CC")
local MonthCardViewCtr = CC.class2("MonthCardViewCtr")

function MonthCardViewCtr:ctor(view, param)
	self:InitVar(view, param)
end

function MonthCardViewCtr:InitVar(view, param)
	self.param = param
	self.view = view
end

function MonthCardViewCtr:OnCreate()
	self:RegisterEvent()
	CC.Request("ReqGetMothCardUseInfo")
end

function MonthCardViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnReqGetMothCardUseInfoResp,CC.Notifications.NW_ReqGetMothCardUseInfo)
    CC.HallNotificationCenter.inst():register(self,self.OnReqTakeMothCardDailyResp,CC.Notifications.NW_ReqTakeMothCardDaily)

    CC.HallNotificationCenter.inst():register(self,self.OnMonthCardReward,CC.Notifications.OnDailyGiftGameReward)
end

function MonthCardViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function MonthCardViewCtr:OnReqGetMothCardUseInfoResp(err,data)
    log(string.format("err: %s   OnReqGetMothCardUseInfoResp: %s",err,tostring(data)))
    
	if err == 0 then
        self.view.time1 = data.Super.RemainTimes
        self.view.time2 = data.Supreme.RemainTimes
        if CC.Player.Inst():GetSelfInfoByKey("EPC_Super") > 0 and data.Super.RemainTimes <= 0 then
            CC.Player.Inst():ChangeProp({Items = {{ConfigId = CC.shared_enums_pb.EPC_Super,Count = 0}}})
        end
        if CC.Player.Inst():GetSelfInfoByKey("EPC_Supreme") > 0 and data.Supreme.RemainTimes <= 0 then
            CC.Player.Inst():ChangeProp({Items = {{ConfigId = CC.shared_enums_pb.EPC_Supreme,Count = 0}}})
        end

        for i = 1,2 do
            local prop = i == 1 and "EPC_Super" or "EPC_Supreme"
            local cardInfo = i == 1 and data.Super or data.Supreme
            local card = CC.Player.Inst():GetSelfInfoByKey(prop) or 0
            local btn1 = not (card > 0)
            local btn2 = card > 0 and not cardInfo.IsDailyLogin
            local btn3 = card > 0 and cardInfo.IsDailyLogin
            local time = self:GetTime(cardInfo.RemainTimes,i)
            self.view:RefreshUI(i == 1 and self.view.monthcard_pb.Super or self.view.monthcard_pb.Supreme,{time = time,buyBtn = btn1,receBtn = btn2,grayBtn = btn3})
        end

        self:RefreshRedDot()
    end
end

function MonthCardViewCtr:GetTime(time,type)
    if not time then return "" end
    
    local color = type == 1 and "color=#0D8D20FF" or "color=#EA2701FF"
    local temp_time = CC.uu.TicketFormat2(time):split(":")
    if time >= 86400 then
        return string.format(self.view.language.day,color,math.ceil(time/86400))
    elseif time >= 3600 then
        return string.format(self.view.language.hour,color,math.ceil(time/3600))
    elseif time >= 1800 then 
        return string.format(self.view.language.minute,color,math.ceil(time/60))
    elseif time > 0 then
        return self.view.language.lose
    else 
        return ""
    end
end

function MonthCardViewCtr:OnReqTakeMothCardDailyResp(err,data)
    log(string.format("err: %s   OnReqTakeMothCardDailyResp: %s",err,tostring(data)))
	if err == 0 then
        local rewards = {}
        for i,v in ipairs(data.awardInfoList) do
            table.insert(rewards,{ConfigId = v.PropID,Count = v.PropNum})
        end
        CC.ViewManager.OpenRewardsView({items = rewards}) 
        self.view:RefreshUI(data.cardType,{receBtn = false,grayBtn = true})

        self:RefreshRedDot()
    end
end

function MonthCardViewCtr:OnMonthCardReward(data)
	local source_pb = CC.shared_transfer_source_pb
    if data.Source == source_pb.TS_MonthlyCard_30253 or data.Source == source_pb.TS_MonthlyCard_30254 then
        local type = data.Source == source_pb.TS_MonthlyCard_30253 and self.view.monthcard_pb.Super or self.view.monthcard_pb.Supreme
        local rew = {}
        for i,v in ipairs(self.view.rewardCfg[type]) do
            local des = v.des
            if CC.LanguageManager.GetType() == "Thai" and (i == 2 or (type == self.view.monthcard_pb.Super and i == 3) or (type == self.view.monthcard_pb.Super and i == 4)) then
                 des = string.format(des,"\n") 
            else
                des = string.format(des,"") 
            end
            table.insert(rew,{ConfigId = v.icon,Count = v.count,Des = des})
        end
        local param = {
            showCard1 = data.Source == source_pb.TS_MonthlyCard_30253,
            showCard2 = data.Source == source_pb.TS_MonthlyCard_30254,
            rewards = rew,
            moreFun = function() CC.ViewManager.Open("MonthCardPriviView") end
        }
        CC.ViewManager.Open("SpecialRewardView",param)
        self.view:RefreshUI(type,{buyBtn = false})

        CC.Request("ReqGetMothCardUseInfo")
    end
end

function MonthCardViewCtr:RefreshRedDot()
	local obj1 = self.view:FindChild("Left/ReceBtn")
    local obj2 = self.view:FindChild("Right/ReceBtn")
    CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetActivityInfoByKey("MonthCardView",{redDot = obj1.activeSelf or obj2.activeSelf}) --设置红点
end

function MonthCardViewCtr:Destroy()
	self:UnRegisterEvent()
end

return MonthCardViewCtr
