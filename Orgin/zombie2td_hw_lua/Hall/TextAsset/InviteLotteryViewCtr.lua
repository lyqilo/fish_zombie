local CC = require("CC")
local InviteLotteryViewCtr = CC.class2("InviteLotteryViewCtr")

function InviteLotteryViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function InviteLotteryViewCtr:InitVar(view, param)
	self.param = param;
    self.view = view;
    self.myId = CC.Player.Inst():GetSelfInfoByKey("Id")
    self.proplanguage = CC.LanguageManager.GetLanguage("L_Prop")
end

function InviteLotteryViewCtr:OnCreate()
    self:RegisterEvent()
    CC.Request("ReqFreeTimesGet",{PlayerID = self.myId})
    CC.Request("ReqFreeInviteList",{PlayerID = self.myId})
    CC.Request("ReqFreeAwardList",{PlayerID = self.myId})
end

function InviteLotteryViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnReqFreeTimesGetResp,CC.Notifications.NW_ReqFreeTimesGet)
    CC.HallNotificationCenter.inst():register(self,self.OnReqFreeLotteryResp,CC.Notifications.NW_ReqFreeLottery)
    CC.HallNotificationCenter.inst():register(self,self.OnReqFreeInviteListResp,CC.Notifications.NW_ReqFreeInviteList)
    CC.HallNotificationCenter.inst():register(self,self.OnReqFreeAwardListResp,CC.Notifications.NW_ReqFreeAwardList)
end

function InviteLotteryViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function InviteLotteryViewCtr:OnReqFreeTimesGetResp(err,data)
    log("err = ".. err.."  OnReqFreeTimesGetResp:\n"..tostring(data))
    if err == 0 then
        self.view.LotCountOld = data.OldTimes
        self.view.LotCountNew = data.NewTimes
        self.view:RefreshLotTex("Old",data.oldTask)
        self.view:RefreshLotTex("New",data.newTask)
    end
    self.view.isCanClick = true
end

function InviteLotteryViewCtr:OnReqFreeLotteryResp(err,data)
    log("err = ".. err.."  OnReqFreeLotteryResp:\n"..tostring(data))
    if err == 0 then
        local block = self:GetBlock(data.Type,data.PropID,data.PropNum)
        if not block then
            logError(string.format("邀请 %s 抽奖客户端没有该奖励配置，ProId: %s PropNum: %s AwardId: %s",data.Type == 2 and "老玩家" or "新玩家",data.PropID,data.PropNum,data.AwardID))
            return
        end

        local reward = {{ConfigId = data.PropID,Count = data.PropNum,Block = block}}

        self.view:StartLottery(data.Type == 2 and "Old" or "New",reward)
    end
    self.view.isCanClick = true
end

function InviteLotteryViewCtr:GetBlock(type,propId,propNum)
    local index = type == 2 and 1 or 2
    for i,v in ipairs(self.view.RewardCfg[index]) do
        if v.id == propId and v.count == propNum then
            return i
        end
    end
    return nil
end

function InviteLotteryViewCtr:GetIsReport(propId)
    for i,v in ipairs(self.view.needReportProp) do
        if v == propId then
            return true
        end
    end
    return false
end

function InviteLotteryViewCtr:OnReqFreeInviteListResp(err,data)
    log("err = ".. err.."  OnReqFreeInviteListResp:\n"..tostring(data))
    if err == 0 and not table.isEmpty(data.InviteList) and data.InviteList[1] then
        self.view:ShowRecord(data)
    end
end

function InviteLotteryViewCtr:OnReqFreeAwardListResp(err,data)
    log("err = ".. err.."  OnReqFreeAwardListResp:\n"..tostring(data))
    if err == 0 and table.length(data.AwardList) > 0  then
        for i,v in ipairs(data.AwardList) do
            self:OnReport(v.PropID,v.PlayerName,false)
        end
    end
end

function InviteLotteryViewCtr:OnReport(propId,player,isNext)
	local type = propId == CC.shared_enums_pb.EPC_AnniRaffleTicket and 2 or 1
    local reward = propId == CC.shared_enums_pb.EPC_AnniRaffleTicket and "" or self.proplanguage[propId]
    if self.view.Marquee then
        self.view.Marquee:Report(string.format(self.view.language["Report"..type],player,reward),isNext)
    end
end

function InviteLotteryViewCtr:Destroy()
	self:UnRegisterEvent()
end

return InviteLotteryViewCtr
