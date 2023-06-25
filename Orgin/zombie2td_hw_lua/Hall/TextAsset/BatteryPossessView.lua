local CC = require("CC")
local BatteryPossessView = CC.uu.ClassView("BatteryPossessView")

function BatteryPossessView:ctor(param)
    self.param = param or {}
    --playerId必传
    self.playerId = self.param.playerId

    self.batteryRankConfig = CC.ConfigCenter.Inst():getConfigDataByKey("BatteryRankConfig")
    self.batteryList = {}
end

function BatteryPossessView:OnCreate()
    self:RegisterEvent()
    self:InitUI()
    self:InitBackPack()
end

function BatteryPossessView:InitUI()
    self.Content = self:FindChild("Content/Viewport/Content")
    self.item = self:FindChild("Item")
    self:AddClick("BtnClose","ActionOut")
end

function BatteryPossessView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqOnGetMyBatterysRsp,CC.Notifications.NW_ReqOnGetMyBatterys)
end

function BatteryPossessView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function BatteryPossessView:InitBackPack()
    -- self.co_InitProp = coroutine.start(function ()
    --     for _, v in ipairs(self.batteryRankConfig.batteryInfo) do
    --         self:CreateProp(v)
    --         coroutine.step(0)
    --     end
    -- end)
    for _, v in ipairs(self.batteryRankConfig.batteryInfo) do
        self:CreateProp(v)
    end
    CC.Request("ReqOnGetMyBatterys", {PlayerId = self.playerId})
end

function BatteryPossessView:CreateProp(param)
    local id = param.id
    local item = nil
    item = CC.uu.newObject(self.item, self.Content)
    if item then
        item.name = id
        item:FindChild("Name").text = param.Name
        -- item:FindChild("Name").text = param.Des
        local parent = item:FindChild("Icon")
        local battery = CC.uu.LoadHallPrefab("prefab", param.prefab, parent)
        battery.localScale = Vector3(0.6,0.6,1)
        local bgSprite = param.colour or "Green"
        item:FindChild(bgSprite):SetActive(true)
        item:FindChild("mask"):SetActive(true)
        item:FindChild("Lock"):SetActive(true)
        item:SetActive(true)
        self.batteryList[id] = item
    end
end

function BatteryPossessView:ReqOnGetMyBatterysRsp(err,result)
    log(CC.uu.Dump(result, "ReqWaterRankData"))
    if err == 0 then
        self:RefreshBattery(result)
    end
end

function BatteryPossessView:RefreshBattery(param)
    local items = param.Items or {}
    local index = 0
    for _, v in ipairs(items) do
        local configId = v.ConfigId
        if configId and self.batteryList[configId] then
            self.batteryList[configId]:SetSiblingIndex(index)
            self.batteryList[configId]:FindChild("mask"):SetActive(false)
            self.batteryList[configId]:FindChild("Lock"):SetActive(false)
            index = index + 1
        end
    end
end

function BatteryPossessView:OnDestroy()
    self:UnRegisterEvent()
    if self.co_InitProp then
        coroutine.stop(self.co_InitProp)
        self.co_InitProp = nil
    end
end

return BatteryPossessView