local CC = require("CC")
local BatteryBookView = CC.uu.ClassView("BatteryBookView")

function BatteryBookView:ctor(param)
    self.param = param or {}
    self.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")

    self.batteryRankConfig = CC.ConfigCenter.Inst():getConfigDataByKey("BatteryRankConfig")
    --右边背包炮台
    self.BatteryList = {}
    --左边展示炮台
    self.BatteryShowList = {}
    self.GameList = {}
    self.SpineList = {}
end

function BatteryBookView:OnCreate()
    self.language = CC.LanguageManager.GetLanguage("L_BatteryRankView")
    self:RegisterEvent()
    self:InitUI()
    self:InitBackPack()
end

function BatteryBookView:InitUI()
    self.Content = self:FindChild("Content/Viewport/Content")
    self.item = self:FindChild("Item")
    self.Battery = self:FindChild("Battery")
    self.GameList[3005] = self:FindChild("Game/3005")
    self.GameList[3002] = self:FindChild("Game/3002")
    self.GameList[3007] = self:FindChild("Game/3007")
    self:AddClick("BtnClose","ActionOut")
end

function BatteryBookView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqOnGetMyBatterysRsp,CC.Notifications.NW_ReqOnGetMyBatterys)
end

function BatteryBookView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function BatteryBookView:InitBackPack()
    for _, v in ipairs(self.batteryRankConfig.batteryInfo) do
        self:CreateProp(v)
    end
    CC.Request("ReqOnGetMyBatterys", {PlayerId = self.playerId})
end

function BatteryBookView:CreateProp(param)
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
        self:AddClick(item, function ()
            self:UpdateRightBattery(id, param)
        end)
        self.BatteryList[id] = item
    end
end

function BatteryBookView:UpdateRightBattery(configId, param)
    for _, v in pairs(self.BatteryShowList) do
        v:SetActive(false)
    end
    if self.BatteryShowList[configId] then
        self.BatteryShowList[configId]:SetActive(true)
    else
        local battery = nil
        battery = CC.uu.LoadHallPrefab("prefab", param.prefab, self.Battery)
        if battery then
            if param.Animator then
                battery:GetComponent("Animator").enabled = true
            end
            if param.Spine then
                self.SpineList[configId] = battery:FindChild("Spine"):GetComponent("SkeletonGraphic")
                self.SpineList[configId].AnimationState:ClearTracks()
                self.SpineList[configId].AnimationState:SetAnimation(0, "shot", true)
            end
            self.BatteryShowList[configId] = battery
        end
    end
    self:FindChild("1127"):SetActive(configId == 1127)
    self:FindChild("1125"):SetActive(configId == 1125)
    self:FindChild("1151"):SetActive(configId == 1151)
    self:FindChild("4023"):SetActive(configId == 4023)
    self:FindChild("Score").text = string.format("%s:%s", self.language.score, param.Score)
    self:FindChild("Name").text = param.Name
    --所属游戏显示
    for _, v in pairs(self.GameList) do
        v:FindChild("mask"):SetActive(true)
    end
    for _, v in ipairs(param.GameType) do
        if self.GameList[v] then
            self.GameList[v]:FindChild("mask"):SetActive(false)
        end
    end
end

function BatteryBookView:ReqOnGetMyBatterysRsp(err,result)
    log(CC.uu.Dump(result, "ReqWaterRankData"))
    if err == 0 then
        self:RefreshBattery(result)
    end
end

function BatteryBookView:RefreshBattery(param)
    local items = param.Items or {}
    local index = 0
    for _, v in ipairs(items) do
        local configId = v.ConfigId
        if configId and self.BatteryList[configId] then
            self.BatteryList[configId]:SetSiblingIndex(index)
            self.BatteryList[configId]:FindChild("mask"):SetActive(false)
            self.BatteryList[configId]:FindChild("Lock"):SetActive(false)
            index = index + 1
        end
    end
end

function BatteryBookView:OnDestroy()
    self:UnRegisterEvent()
    if self.co_InitProp then
        coroutine.stop(self.co_InitProp)
        self.co_InitProp = nil
    end
    for _, v in pairs(self.SpineList) do
        v = nil
    end
end

return BatteryBookView