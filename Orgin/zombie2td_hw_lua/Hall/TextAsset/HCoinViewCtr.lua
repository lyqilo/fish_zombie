local CC = require("CC")
local HCoinViewCtr = CC.class2("HCoinViewCtr")

function HCoinViewCtr:ctor(view, param)
	self:InitVar(view, param);
    self.index = 1
end

function HCoinViewCtr:InitVar(view, param)
	self.param = param;
    self.view = view;
    self.ID = CC.Player.Inst():GetSelfInfoByKey("Id")
    self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
    self.switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")
    self.TaskData = {
        List = {
                {TaskID = 1, TaskType = 1, ReceiveLevel = 0,PendingLevel = 0, PropNum = 1, Status = 1,},
                {TaskID = 2, TaskType = 1, ReceiveLevel = 0,PendingLevel = 0, PropNum = 5, Status = 1,},
                {TaskID = 3, TaskType = 1, ReceiveLevel = 0,PendingLevel = 0, PropNum = 10, Status = 1,onClick = function(self)
                    local param = {}
                    param.imgName = "share_1_520210525"
                    param.shareCallBack = function()
                        --请求完成分享
                        CC.Request("ReqBCShare",{PlayerID = self.ID})
                    end
                    --param.callback = function() CC.Request("ReqBCShare",{PlayerID = self.ID}) end
                    CC.ViewManager.Open("ImageShareView",param)
                end},
                {TaskID = 4, TaskType = 1, ReceiveLevel = 0,PendingLevel = 0, PropNum = 100, Status = 1,onClick = function(self)
                    CC.ViewManager.Open("StoreView")
                end},
                {TaskID = 5, TaskType = 2, ReceiveLevel = 0,PendingLevel = 0, PropNum = 500, Status = 1,onClick = function(self)
                    CC.ViewManager.Open("PersonalInfoView",{Upgrade = 1})
                end},
                {TaskID = 6, TaskType = 2, ReceiveLevel = 0,PendingLevel = 0, PropNum = 100, Status = 1},
                {TaskID = 7, TaskType = 2, ReceiveLevel = 0,PendingLevel = 0, PropNum = 500, Status = 1,onClick = function(self)
                    if self.switchDataMgr.GetSwitchStateByKey("AgentUnlock") and not self.agentDataMgr.GetForbiddenAgentSatus()
                       and (self.agentDataMgr.GetAgentSatus() or self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel")) then
                        CC.ViewManager.Open("AgentNewView")
                    else
                        CC.ViewManager.ShowTip(self.view.language.WJS)
                    end
                end},
                {TaskID = 8, TaskType = 2, ReceiveLevel = 0,PendingLevel = 0, PropNum = 100, Status = 1,onClick = function(self)
                    if not CC.ChannelMgr.GetSwitchByKey("bHasRealStore") or CC.ChannelMgr.GetTrailStatus() or not self.switchDataMgr.GetSwitchStateByKey("TreasureView") then
                        CC.ViewManager.ShowTip(self.view.language.WJS)
                        return
                    end
                    CC.ViewManager.Open("TreasureView",{OpenViewId = 2})
                end},
                {TaskID = 9, TaskType = 2, ReceiveLevel = 0,PendingLevel = 0, PropNum = 100, Status = 1,onClick = function(self)
                    if not CC.ChannelMgr.GetSwitchByKey("bHasRealStore") or CC.ChannelMgr.GetTrailStatus() or not self.switchDataMgr.GetSwitchStateByKey("TreasureView") then
                        CC.ViewManager.ShowTip(self.view.language.WJS)
                        return
                    end
                    CC.ViewManager.Open("TreasureView",{OpenViewId = 1})
                end},
                {TaskID = 10, TaskType = 2, ReceiveLevel = 0,PendingLevel = 0, PropNum = 100, Status = 1,onClick = function(self)
                    CC.ViewManager.Open("PersonalInfoView")
                end},
                {TaskID = 11, TaskType = 2, ReceiveLevel = 0,PendingLevel = 0, PropNum = 100, Status = 1,onClick = function(self)
                    CC.ViewManager.Open("BindTelView",{callback = function()
                        CC.Request("ReqBCTaskList",{PlayerID = self.ID})
                    end})
                end},
               },
    }
end

function HCoinViewCtr:OnCreate()
    self:RegisterEvent()
    --默认展示
    self.view:ShowTask(self.TaskData,true)
    CC.Request("ReqBCTaskList",{PlayerID = self.ID})
    CC.Request("ReqBCPowerList",{PlayerID = self.ID})
    CC.Request("ReqBCHCoinList",{PlayerID = self.ID})
end

function HCoinViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnTaskListResp,CC.Notifications.NW_ReqBCTaskList)
    CC.HallNotificationCenter.inst():register(self,self.OnTokenResp,CC.Notifications.NW_ReqBCToken)
    CC.HallNotificationCenter.inst():register(self,self.OnReceiveResp,CC.Notifications.NW_ReqBCReceive)
    CC.HallNotificationCenter.inst():register(self,self.OnReceiveHCoinResp,CC.Notifications.NW_ReqBCReceiveHCoin)
    CC.HallNotificationCenter.inst():register(self,self.OnPowerListResp,CC.Notifications.NW_ReqBCPowerList)
    CC.HallNotificationCenter.inst():register(self,self.OnHCoinListResp,CC.Notifications.NW_ReqBCHCoinList)
    CC.HallNotificationCenter.inst():register(self,self.OnBcShareResp,CC.Notifications.NW_ReqBCShare)
    CC.HallNotificationCenter.inst():register(self,self.OnTimeNotify,CC.Notifications.OnTimeNotify)
    CC.HallNotificationCenter.inst():register(self,self.CloseCollectionView,CC.Notifications.OnDisconnect)
end

function HCoinViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function HCoinViewCtr:OnTaskListResp(err,data)
    log(CC.uu.Dump(data, "OnTaskListResp"))
    if err == 0 then
        if data.WaitInCome > 0 and not self.openHcoinRewardView then
            local param = {}
            param.items = {{ConfigId = CC.shared_enums_pb.EPC_HCoin,Count = data.WaitInCome}}
            param.title = self.view.language.GetFRT
            if data:HasField("GrandTime") and data.GrandTime > 60000 then
                data.GrandTime = data.GrandTime / 1000
                local nHour = math.modf(data.GrandTime / 3600)
                local nMin = math.modf((data.GrandTime - nHour * 3600) / 60)
                local nHourTex = nHour > 0 and nHour..self.view.language.Hour or ""
                local nMinTex = nMin > 0 and nMin..self.view.language.Min or ""
                param.timeTip = string.format(self.view.language.RewardTip1,nHour < 48 and nHourTex..nMinTex or "48"..self.view.language.Hour)
            end
            param.getTip = self.view.language.RewardTip2
            param.btnText = self.view.language.Get
            param.callback = function()
                    --请求领取火币
                    self.openHcoinRewardView = false
                    CC.Request("ReqBCReceiveHCoin",{PlayerID = self.ID})
                end
            self.openHcoinRewardView = true
            CC.ViewManager.OpenRewardsView(param)
        end
        if data:HasField("Countdown") and data.Countdown > 0 then self.view.countDown = data.Countdown / 1000 end
        self.view:RefreshHashRateAndHCoin(data.Power,data.Balance + data.InCome)
        self.view:ShowTask(data)
    else
        CC.ViewManager.ShowTip(self.view.language.RefreshFail)
    end
end

function HCoinViewCtr:OnTokenResp(err,data)
    log(CC.uu.Dump(data, "OnTokenResp"))
    if err == 0 then
        self.Token = data.Token
        self:OpenWebStore()
    end
end

function HCoinViewCtr:OpenWebStore()
    if not self.webview then
        self.webview = self.view:SubAdd("WebPanel/Bg/View",WebViewBehavior)
        self.webview:Init(self.view:GlobalCamera())
    end
    local url = string.format(CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetBlockchainWebStoreAddress(),self.Token)
    log(url)
    self.webview:LoadURL(url)
    self.view.History_HCoin:SetActive(false)
    self.view:OpenPanel(3)
end

function HCoinViewCtr:OnReceiveResp(err,data)
    log(CC.uu.Dump(data, "OnReceiveResp"))
    if err == 0 then
        --刷新任务列表
        CC.Request("ReqBCTaskList",{PlayerID = self.ID})
        --刷新算力流水
        CC.Request("ReqBCPowerList",{PlayerID = self.ID})
        local param = {
            items = {{ConfigId = data.PropID,Count = data.PropNum}},
            title = self.view.language.GetSL,
        }
        CC.ViewManager.OpenRewardsView(param)
    else
        CC.ViewManager.ShowTip(self.view.language.GetFail)
    end
end

function HCoinViewCtr:OnReceiveHCoinResp(err,data)
    log(CC.uu.Dump(data, "OnReceiveHCoinResp"))
    if err == 0 then
        if data.InCome > 0 then
            --刷新任务列表
            CC.Request("ReqBCTaskList",{PlayerID = self.ID})
            --刷新火币流水
            CC.Request("ReqBCHCoinList",{PlayerID = self.ID})
        end
    else
        CC.ViewManager.ShowTip(self.view.language.GetFail)
    end
end

function HCoinViewCtr:OnPowerListResp(err,data)
    log(CC.uu.Dump(data, "OnPowerListResp"))
    if err == 0 then
        if data.List and #data.List > 0 then
            self.view:ShowHashRateHistory(data)
        end
    else
        CC.ViewManager.ShowTip(self.view.language.GetRecordFail)
    end
end

function HCoinViewCtr:OnHCoinListResp(err,data)
    log(CC.uu.Dump(data, "OnHCoinListResp"))
    if err == 0 then
        if data.List and #data.List > 0 then
            self.view:ShowHCoinHistory(data)
        end
    else
        CC.ViewManager.ShowTip(self.view.language.GetRecordFail)
    end
end

function HCoinViewCtr:OnBcShareResp(err,data)
    if err == 0 then
        log("请求分享成功,刷新任务列表")
        CC.Request("ReqBCTaskList",{PlayerID = self.ID})
    end
end

function HCoinViewCtr:OnTimeNotify()
    CC.Request("ReqBCTaskList",{PlayerID = self.ID})
end

--重连当打开webview时，webview的层级会高于一切无法点击,这里自动关闭webview
function HCoinViewCtr:CloseCollectionView()
    if not CC.uu.IsNil(self.view.transform) and self.view.WbePanel.activeSelf then
        self.view:ClosePanel(3)
    end
end

function HCoinViewCtr:Destroy()
	self:UnRegisterEvent()
end

return HCoinViewCtr
