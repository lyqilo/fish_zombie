local CC = require("CC")

local BackUseViewCtr = CC.class2("BackUseViewCtr")

function BackUseViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function BackUseViewCtr:InitVar(view,param)
    self.view = view
    self.param = param

    self:RegisterEvent()
end

function BackUseViewCtr:OnCreate()
end

function BackUseViewCtr:PropSaleReq(ConfigId,Count)
    local data = {}
    data.ConfigId = ConfigId
    data.Count = Count
	data.GameId = CC.ViewManager.GetCurGameId() or 1
	data.GroupId = CC.ViewManager.GetCurGroupId() or 0
    CC.Request("PropSaleReq",data)
end

function BackUseViewCtr:PropUse(ConfigId,Count)
    local data = {}
    data.ConfigId = ConfigId
    data.Count = Count
    data.GameId = CC.ViewManager.GetCurGameId() or 1
	data.GroupId = CC.ViewManager.GetCurGroupId() or 0
    CC.Request("PropUse",data)
end

function BackUseViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnPropSaleReq,CC.Notifications.NW_PropSaleReq)
    CC.HallNotificationCenter.inst():register(self,self.OnPropUse,CC.Notifications.NW_PropUse)
end

function BackUseViewCtr:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_PropSaleReq)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_PropUse)
end

function BackUseViewCtr:OnPropSaleReq(err,data)
    if err == 0 then
        local param = {}
        param.items = data.Items
        CC.ViewManager.OpenRewardsView(param)
        self.view:ActionOut()
    else
        logError("PropSaleErr:"..err)
    end
end

function BackUseViewCtr:OnPropUse(err,data)
    if err == 0 then
        local param = {}
        param.items = data.Items
        CC.ViewManager.OpenRewardsView(param)
        self.view:ActionOut()
    else
        logError("PropUseErr:"..err)
    end
end

function BackUseViewCtr:Destroy()
    self:unRegisterEvent()
end

return BackUseViewCtr