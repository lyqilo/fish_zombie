local CC = require("CC")

local SubscribeViewCtr = CC.class2("SubscribeViewCtr")

function SubscribeViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function SubscribeViewCtr:InitVar(view,param)
    self.view = view
    self.param = param
    self.gameID = self.param.currentView
end

function SubscribeViewCtr:OnCreate()
    self:RegisterEvent()
    self:ReqState()
    local info = self.view.gameDataMgr.GetSubscribeGameInfoById(self.gameID)
    if info then
        self.view:InitGameInfo(info)
    else
        CC.Request("ReqLimitGameTimeList")
    end
end

function SubscribeViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.LimitStatusResp,CC.Notifications.NW_ReqLimitStatus)
    CC.HallNotificationCenter.inst():register(self,self.LimitGameTimeListResp,CC.Notifications.NW_ReqLimitGameTimeList)
    CC.HallNotificationCenter.inst():register(self,self.SubscribeAddResp,CC.Notifications.NW_ReqSubscribeAdd)
end

function SubscribeViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqLimitStatus)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqLimitGameTimeList)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqSubscribeAdd)
end

function SubscribeViewCtr:ReqState()
    local param = {}
    param.GameID = self.gameID
    param.PlayerID = CC.Player.Inst():GetSelfInfoByKey("Id")
    CC.Request("ReqLimitStatus",param)
end

function SubscribeViewCtr:LimitStatusResp(err,data)
    if err == 0 then
        CC.uu.Log(data,"LimitStatusResp:",3)
        local param = {}
        param.Status = data.Status
        param.SubscribeStatus =  data.SubscribeStatus ~= 0 and data.SubscribeStatus or data.QueueStatus
        self.view:InitState(param)
    else
        log("ReqState Fail:"..err)
        local param = {}
        param.Status = 1
        param.SubscribeStatus = 1
        self.view:InitState(param)
    end
end

function SubscribeViewCtr:ReqSubscribe()
    if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < 3 then
        CC.ViewManager.ShowTip(self.view.language.SubscribeVIP)
        return
    end
    local param = {}
    param.GameID = self.gameID
    param.PlayerID = CC.Player.Inst():GetSelfInfoByKey("Id")
    CC.Request("ReqSubscribeAdd",param)
end

function SubscribeViewCtr:SubscribeAddResp(err,data)
    if err == 0 then
        CC.uu.Log(data,"SubscribeAddResp:",3)
        self.view:RefreshUI(data.Status)
    else
        log("ReqSubscribe Fail:"..err)
    end
end

function SubscribeViewCtr:LimitGameTimeListResp(err,data)
    if err == 0 then
        CC.uu.Log(data,"Test:",3)
        self.view.gameDataMgr.SetSubscribeGameInfo(data.gameTimeList)
        for i,v in ipairs(data.gameTimeList) do
            if v.Id == self.gameID then
                self.view:InitGameInfo(v)
                break
            end
        end
    end
end

function SubscribeViewCtr:Destroy()
    self:UnRegisterEvent()
end

return SubscribeViewCtr
