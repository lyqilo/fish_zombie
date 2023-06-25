local CC = require("CC")

local BackpackViewCtr = CC.class2("BackpackViewCtr")

local Type = {
    Game = 1,
    Hall = 2
}

function BackpackViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function BackpackViewCtr:InitVar(view,param)
    self.view = view
    self.param = param
    self.selectedID = self.param.SelectedID

    --背包配置表
    self.BackpackCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Backpack")

    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")

    self.Cfg = {}

    self:RegisterEvent()
end

function BackpackViewCtr:OnCreate()
    self:InitPropCfg()
end

function BackpackViewCtr:InitPropCfg()
    for k, v in pairs(self.BackpackCfg) do
        table.insert(self.Cfg,v)
    end
    --排序
    local function _sort(a,b)
        local r
        local aType = a.Type
        local bType = b.Type
        local aId = a.Id
        local bId = b.Id
        if aType == bType then
            r = aId < bId
        else
            r = aType < bType
        end
        return r
    end
    table.sort(self.Cfg,_sort)
    self:InitProp(self.Cfg)
end

function BackpackViewCtr:InitProp(cfg)
    local result = {}
    for i, v in ipairs(cfg) do
        local count = CC.Player.Inst():GetSelfInfoByKey(v.Id)
        if count and count > 0 then
            if v.Id == self.selectedID then
                self:InitSelectInfo(v)
            end
            local param = v
            param.count = count
            table.insert(result,param)
        end
    end
    self.view:InitBackPack(result)
end

function BackpackViewCtr:InitSelectInfo(param)
    local data = {}
    data.Type = param.Page
    data.Id = param.Id
    self.view:InitSelectInfo(data)
end

function BackpackViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self, self.OnChangeSelfInfo, CC.Notifications.changeSelfInfo)
end

function BackpackViewCtr:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.changeSelfInfo)
end

function BackpackViewCtr:OnChangeSelfInfo(props)
    local result = {}
    for i, v in ipairs(self.Cfg) do
        local count = CC.Player.Inst():GetSelfInfoByKey(v.Id)
        local param = v
        param.count = count
        table.insert(result,param)
    end
    self.view:RefrshBackPack(result)
end

function BackpackViewCtr:Destroy()
    self:unRegisterEvent()
end

return BackpackViewCtr