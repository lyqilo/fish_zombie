local GC = require("GC")
local CC = require("CC")
local ZTD = require("ZTD")

local GiftCollectionView = ZTD.ClassView("ZTD_GiftCollectionView")

local toggleNameCfg = 
{
    [1] = "dragonTreasure",
    [2] = "weeksCard",
}

function GiftCollectionView:ctor(curToggleKey, dayIdx)
    self.curToggleKey = curToggleKey or "dragonTreasure"
    self.dayIdx = dayIdx
end

function GiftCollectionView:OnCreate()
    self:RegisterNotification()
    self:PlayAnimAndEnter()
    self:InitData()
    self:InitUI()
end

function GiftCollectionView:RegisterNotification()
    ZTD.Notification.GameRegister(self, ZTD.Define.OnDailyGiftGameReward, self.OnDailyGiftGameReward)
    ZTD.Notification.GameRegister(self, ZTD.Define.OnPushPropsInfo, self.OnPushPropsInfo)
    ZTD.Notification.GameRegister(self, ZTD.Define.OnPushDropMaterials, self.OnPushPropsInfo)
end

function GiftCollectionView:OnPushPropsInfo(data)
    -- log("OnPushPropsInfo data="..GC.uu.Dump(data))
    for k, v in ipairs(data.Info) do
        if not v.PropsID then return end
        if v.PropsID == 3 then
            ZTD.PlayerData.SetDiamond(v.TotalNum)
            self.viewList[self.curToggleKey]:RefreshDiamond()
        elseif v.PropsID >= 1112 and v.PropsID <= 1115 then
            if self.curToggleKey == "dragonTreasure" then
                local num = v.TotalNum and v.TotalNum or v.Num
                local isDrop = nil
                if v.TotalNum then
                    isDrop = false
                else
                    isDrop = true
                end
                -- log("num="..tostring(num).."  isDrop="..tostring(isDrop))
                self.viewList[self.curToggleKey]:RefreshChip(v.PropsID, num, isDrop)
            end
        end
    end
end

function GiftCollectionView:OnDailyGiftGameReward(data)
    if self.curToggleKey ~= "weeksCard" then return end
    -- log("OnDailyGiftGameReward data="..GC.uu.Dump(data))
    self.viewList["weeksCard"]:RefreshDiamond()
    self.viewList["weeksCard"]:ShowRewards(data)
    self:Destroy()
end

function GiftCollectionView:InitData()
    self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_GiftCollectionView")
    self.toggleList = {}
    self.panelList = {}
    self.viewList = {}

    self.pushChipInfo = false
    self.pushBoxID = nil
    self.pushBuyChipNum = nil
end

function GiftCollectionView:InitUI()
    self:InitToggle()
    self:AddEvent()
    self:InitView()	
end

function GiftCollectionView:InitToggle()
    for k, v in ipairs(toggleNameCfg) do
        self.toggleList[v] = self:FindChild("root/toggleList/toggle_"..v)
        self.panelList[v] = self:FindChild("root/panelList/panel_"..v)
        self.toggleList[v]:FindChild("Label"):GetComponent("Text").text = self:GetToggleText(v)
        if self.curToggleKey == v then
            self:RefreshTogglePanel(v, true)
        else
           self:RefreshTogglePanel(v, false)
        end
        UIEvent.AddToggleValueChange(self.toggleList[v], function(isOn)
            if isOn then
                if v == self.curToggleKey then
                    return
                end
                self.curToggleKey = v
                self.panelList[v]:SetActive(true)
                self.toggleList[v]:FindChild("Label"):GetComponent("Text").text = "<color=#ffee7b>"..self:GetToggleText(v).."</color>"
                self.viewList[v]:Init()
            else
                if v == "weeksCard" then
                    self.viewList[v]:CloseAllItemPanel()
                elseif v == "dragonTreasure" then
                    self.viewList["dragonTreasure"].tipNode:SetActive(false)
                end
                self.panelList[v]:SetActive(false)
                self.toggleList[v]:FindChild("Label"):GetComponent("Text").text = "<color=#8e5c3e>"..self:GetToggleText(v).."</color>"
                self.viewList[v]:Release()
            end	
        end)
    end
end

function GiftCollectionView:AddEvent()
    self:AddClick("root/btn_close", "PlayAnimAndExit")
end

function GiftCollectionView:InitView()
     --巨龙宝匣
    local dragonTreasureView = ZTD.DragonTreasureView:new(self)
    self.viewList["dragonTreasure"] = dragonTreasureView
    --周卡礼包
    local weeksCardView = ZTD.WeeksCardView:new(self, self.dayIdx)
    self.viewList["weeksCard"] = weeksCardView
    
    self.viewList[self.curToggleKey]:Init()
end

--根据key获取页签名
function GiftCollectionView:GetToggleText(key)
    if key == "dragonTreasure" then
        return self.language.txt_dragonTreasure 
    elseif key == "weeksCard" then
        return self.language.txt_weeksCard
    end
end

--刷新页签
function GiftCollectionView:RefreshTogglePanel(key, state)
    self.toggleList[key]:GetComponent("Toggle").isOn = state
    self.panelList[key]:SetActive(state)
    local str = state == true and "<color=#ffee7b>" or "<color=#8e5c3e>"
    self.toggleList[key]:FindChild("Label"):GetComponent("Text").text = str..self:GetToggleText(key).."</color>"
end

function GiftCollectionView:UnRegisterNotification()
    ZTD.Notification.NetworkUnregisterAll(self)
    ZTD.Notification.GameUnregisterAll(self)
end

function GiftCollectionView:OnDestroy()
    self:UnRegisterNotification()
    for k, v in ipairs(toggleNameCfg) do
        if self.viewList[v] then
            self.viewList[v]:Release()
        end
    end
    self.viewList = nil
end

return GiftCollectionView