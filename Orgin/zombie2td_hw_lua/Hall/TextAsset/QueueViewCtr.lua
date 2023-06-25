local CC = require("CC")

local QueueViewCtr = CC.class2("QueueViewCtr")

function QueueViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function QueueViewCtr:InitVar(view,param)
    self.view = view
    self.param = param
end

function QueueViewCtr:OnCreate()
    self:RegisterEvent()
end

function QueueViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.LimitStatusResp,CC.Notifications.NW_ReqLimitStatus)
    CC.HallNotificationCenter.inst():register(self,self.EnterGame,CC.Notifications.OnPushInGameInfo)
end

function QueueViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqLimitStatus)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPushInGameInfo)
end

function QueueViewCtr:ReqState()
    local param = {}
    param.GameID = self.param.GameId
    param.PlayerID = CC.Player.Inst():GetSelfInfoByKey("Id")
    CC.Request("ReqLimitStatus",param)
end

function QueueViewCtr:LimitStatusResp(err,data)
    if err == 0 then
        CC.uu.Log(data,"LimitStatusResp:",3)
        local param = {}
        param.Status = data.Status
        param.QueueStatus = data.QueueStatus
        param.QueueIndex = data.QueueIndex
        param.QueueTotalNum = data.QueueTotalNum
        param.QueueEvaluateTime = data.QueueEvaluateTime
        self.view:InitState(param)
    else
        log("ReqState Fail:"..err)
    end
end

function QueueViewCtr:ReqCannel()
    local param = {}
    param.GameID = self.param.GameId
    param.PlayerID = CC.Player.Inst():GetSelfInfoByKey("Id")
    CC.Request("ReqCancelQueue",param)
end

function QueueViewCtr:EnterGame(data)
    self.view:EnterGame(data)
end

function QueueViewCtr:Destroy()
    self:UnRegisterEvent()
end

return QueueViewCtr
