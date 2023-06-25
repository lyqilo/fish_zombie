local CC = require("CC")
local GobackRewardViewCtr = CC.class2("GobackRewardViewCtr")

function GobackRewardViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function GobackRewardViewCtr:InitVar(view, param)
	self.param = param;
    self.view = view;
end

function GobackRewardViewCtr:OnCreate()
    self:RegisterEvent()
    if self.param.data then
        self:OnReqLoadOldPlayerReturnStatus(0,self.param.data)
    else
        CC.Request("ReqLoadOldPlayerReturnStatus")
    end
end

function GobackRewardViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnReqLoadOldPlayerReturnStatus,CC.Notifications.NW_ReqLoadOldPlayerReturnStatus)
    CC.HallNotificationCenter.inst():register(self,self.OnReqSendReturnRewardResp,CC.Notifications.NW_ReqSendReturnReward)
    CC.HallNotificationCenter.inst():register(self,self.OnReqBuyWithIdResp,CC.Notifications.NW_ReqBuyWithId)

    CC.HallNotificationCenter.inst():register(self,self.GobackGiftGameReward,CC.Notifications.OnDailyGiftGameReward)
end

function GobackRewardViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function GobackRewardViewCtr:OnReqLoadOldPlayerReturnStatus(err,data)
    log(string.format("err: %s     OnReqLoadOldPlayerReturnStatus: %s",err,tostring(data)))
    if err == 0 then
        self.view.countDown = data.EndStamp
        self.view.totalLose = data.FlowTask

        local index1 = nil
        local index2 = nil
        local isrece_1 = false
        local isrece_2 = false
        for i,v in ipairs(self.view.Rewardcfg) do
            local flag = bit.band(data.RewardFlag,bit.lshift(1,v.taskId))
            v.isComplete = string.find(data.TaskComplete,tostring(v.taskId)) and true or false

            if flag == 0 and v.isComplete and not index1 then index1 = i end --未领取奖励并且任务已完成
            if flag == 0 and not v.isComplete and not index2 then index2 = i end --未领取奖励并且任务未完成

            if flag ~= 0 and i == 1 then isrece_1 = true end
            if flag ~= 0 and i == 2 then isrece_2 = true end

            self.view:SetTaskState(i,flag == 0)
            self.view:ShowProgress(i,data.FlowTask)
        end

        --优先选择未领取并且任务已完成的
        if index1 then
            self.view.giftItem[index1]:GetComponent("Toggle").isOn = true
        elseif index2 then
            self.view.giftItem[index2]:GetComponent("Toggle").isOn = true
        else
            self.view:OnAllFinish()
        end
        --前两个任务奖励领取完了往左边挪
        if not self.init then
            self.init = true
            if isrece_1 and isrece_2 then
                self.view.scrollRect.horizontalNormalizedPosition = 1
            elseif isrece_1 then
                self.view.scrollRect.horizontalNormalizedPosition = 0.5
            end
        end
        
    end
    self.view.isCanClick = true
end

function GobackRewardViewCtr:OnReqSendReturnRewardResp(err,data)
    if err == 0 then
        CC.Request("ReqLoadOldPlayerReturnStatus")
    else
        self.view.isCanClick = true
    end
end

function GobackRewardViewCtr:OnReqBuyWithIdResp(err,data)
    if err ~= 0 then
        self.view.isCanClick = true
    end
end

function GobackRewardViewCtr:GobackGiftGameReward(data)
    if data.Source == CC.shared_transfer_source_pb.TS_Regression_50 or data.Source == CC.shared_transfer_source_pb.TS_Regression_300 then
        CC.Request("ReqLoadOldPlayerReturnStatus")
    end
end

function GobackRewardViewCtr:Destroy()
	self:UnRegisterEvent()
end

return GobackRewardViewCtr
