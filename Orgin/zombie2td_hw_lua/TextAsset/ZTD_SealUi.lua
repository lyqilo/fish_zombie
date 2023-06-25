local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local SealUi = GC.class2("ZTD_SealUi")
local Seal_FRAME_PB1 = "Effect_UI_fenwei02"
local HitRat_PB = "Effect_HitRat"
local sealStateList = {}

function SealUi:ctor(_, battleView)
    self.battleview = battleView
    self:InitData()
    self:AddRegister()
end

function SealUi:InitData()
    self.leftParent = self.battleview:FindChild("UIScreen/X_Left")
    self.rightParent = self.battleview:FindChild("UIScreen/X_Right")
    self._uiLeftFrame = ZTD.EffectManager.PlayEffect(Seal_FRAME_PB1, self.leftParent.transform, true)
    self._uiLeftFrame.localPosition = Vector3(560, 0, 0)
    self._uiRightFrame = ZTD.EffectManager.PlayEffect(Seal_FRAME_PB1, self.rightParent.transform, true)
    self._uiRightFrame.localPosition = Vector3(-560, 0, 0)
    self._uiRightFrame.localScale = Vector3(-1, 1, 1)
    self._uiLeftFrame:SetActive(false)
    self._uiRightFrame:SetActive(false)
    self.effectParent = GameObject.Find("effectContainer").transform
    self.sealUi = self.battleview:FindChild("ZTD_SealUi")
    self.sealValue = self.sealUi:FindChild("sealValue"):GetComponent("Text")
    self.sealSlider = self.sealUi:FindChild("sealSlider")
    self.sealSliderTrans = self.sealSlider:GetComponent("Slider")
    self.bg = self.sealUi:FindChild("bg")
    self.sealUi:SetActive(false)
    self.sealValue.text = ""
    self.oriWidth = self.sealSlider.width
    self.bgWidth = self.bg.width
    self.isSliderInit = false
    self.isPlayEffSelf = false
    self.isPlayHitRat = false
    self.effList = {}
    self.timerList = {}
end

function SealUi:AddRegister()
    ZTD.Notification.NetworkRegister(self, "SCAcquireSeal", self.OnPushAcquireSeal)
    ZTD.Notification.GameRegister(self, ZTD.Define.OnPushSealConvertMoney, self.OnPushSealConvertMoney)
    ZTD.Notification.GameRegister(self, ZTD.Define.RefreshSealMoney, self.RefreshSealMoney)
end

--触发封印
function SealUi:OnPushAcquireSeal(data)
    -- logError("OnPushAcquireSeal")
    self:RefreshEffSingle(true, data)
end

--真气值转钱
function SealUi:OnPushSealConvertMoney(isSelf, sealValue, sealMoney, callFunc)
    if isSelf then
        local sortingOrder = self.battleview.transform:GetComponent("Canvas").sortingOrder + 14
        local confirmFunc = function()
            if callFunc then
                callFunc()
            end
        end
        local cancelFunc = function()
        end
        ZTD.ViewManager.Open("ZTD_ExtendPopView", string.format(self.battleview.language.txt_sealToMoney, sealValue, sealMoney), confirmFunc, cancelFunc, nil, nil, sortingOrder)
    end
end

--刷新封印
function SealUi:RefreshSealMoney(data)
    -- logError("data="..GC.uu.Dump(data))
    -- logError("000 money="..data.MxlSealMoney)
    local money = data.MxlSealMoney
    local playerId = data.PlayerId
    local isSelf = (playerId == ZTD.PlayerData.GetPlayerId())
    sealStateList[playerId] = (money > 0)
    -- logError("isSelf="..tostring(isSelf))
    -- logError("MxlSealAddAwardRatio="..tostring(data.MxlSealAddAwardRatio))
    if isSelf then
        self:RefreshEffSelf(money, data.MxlSealAddAwardRatio)
        self:RefreshSlider(money)
    end
    if money > 0 then
        self:RefreshEffAll(true, playerId)
    else
        self:RefreshEffAll(false, playerId)
    end
end

--刷新封印特效(针对马小玲)
function SealUi:RefreshEffSingle(state, data)
    if not data.HeroPositionId then return end
    local gi, si = ZTD.MainScene.HeroPosId2GS(data.HeroPositionId)
    local heroPos = self.battleview._hero_pos[gi][si]
    if not heroPos then return end
    local heroCtrl = heroPos:GetHeroCtrl()
    if not heroCtrl then return end
    if not heroCtrl._heroObj then return end
    local playerId = data.PlayerId
    local isSelf = (playerId == ZTD.PlayerData.GetPlayerId())
	local uiPb = isSelf and "Effect_UI_WXzi02" or "Effect_UI_WXzi01"
    local sound = isSelf and "ZTD_mxlzi_self" or "ZTD_mxlzi_others"
    local wxUi, effID = ZTD.EffectManager.PlayEffect(uiPb, self.effectParent, true)
    ZTD.PlayMusicEffect(sound)
    table.insert(self.effList, {eff = wxUi, effID = effID})
	local uiPos = ZTD.MainScene.SetupPos2UiPos(heroCtrl._heroObj._obj.position)
	wxUi.position = Vector3(uiPos.x, uiPos.y + 4, uiPos.z)
	local wxUiTimer = ZTD.GameTimer.DelayRun(1, function()
		if wxUi then
            ZTD.EffectManager.RemoveEffectByID(effID)
			table.remove(self.effList)
		end
	end)
    table.insert(self.timerList, wxUiTimer)
end

--刷新封印特效（针对所有英雄包括马小玲）
function SealUi:RefreshEffAll(state, PlayerId)
    local heroinfo = ZTD.TableData.GetData(PlayerId, "heroInfo")
    -- logError("heroinfo="..GC.uu.Dump(heroinfo))
    if not heroinfo then
        return
    end
    for k, v in pairs(heroinfo) do
        if v.PositionId then
            local gi, si = ZTD.MainScene.HeroPosId2GS(v.PositionId)
            local heroPos = self.battleview._hero_pos[gi][si]
            if heroPos then
                local heroCtrl = heroPos:GetHeroCtrl()
                if heroCtrl and heroCtrl._heroObj then
                    local isSelf = (PlayerId == ZTD.PlayerData.GetPlayerId())
                    heroCtrl._heroObj:SetSealEff2(isSelf, state)
                end
            end
        end
    end
end

--刷新进度条
function SealUi:RefreshSlider(money)
    if money > 0 then
        self.sealValue.text = money
        if not self.isSliderInit then
            self.oriMoney = money
            self.bg.width = self.bgWidth
            self.sealSlider.width = self.oriWidth
            self.sealSliderTrans.maxValue = money
            self.sealSliderTrans.value = money
            self.isSliderInit = true
        else
            local maxValue = self.sealSliderTrans.maxValue
            if money > maxValue then
                self.bg.width = money / self.oriMoney * self.bgWidth
                self.sealSlider.width = money / self.oriMoney * self.oriWidth
                self.sealSliderTrans.maxValue = money
            end
            self.sealSliderTrans.value = money
        end
        self.sealUi:SetActive(true)
    else
        self.isSliderInit = false
        self.sealUi:SetActive(false)
        self.sealValue.text = ""
        self.bg.width = self.bgWidth
        self.sealSlider.width = self.oriWidth
    end
end

--刷新自己玩家马小玲特效
function SealUi:RefreshEffSelf(money, MxlSealAddAwardRatio, playerId)
    if money > 0 then
        if not self.isPlayEffSelf then
            self.isPlayEffSelf = true
            local uiFuStartTimer = ZTD.GameTimer.DelayRun(1, function()
                ZTD.PlayMusicEffect("ZTD_mxl_fu")
                self.eff, self.effID = ZTD.EffectManager.PlayEffect("Effect_UI_baojiang01", self.effectParent, true)
            end)
            table.insert(self.timerList, uiFuStartTimer)
            local uiFuEndTimer = ZTD.GameTimer.DelayRun(5, function()
                self.eff:SetActive(false)
                self._uiLeftFrame:SetActive(true)
                self._uiRightFrame:SetActive(true)
                self.isPlayHitRat = true
                self:RefreshHitRatEffAll(money, MxlSealAddAwardRatio)
            end)
            table.insert(self.timerList, uiFuEndTimer)
        else
            if self.isPlayHitRat then
                self:RefreshHitRatEffAll(money, MxlSealAddAwardRatio)
            end
        end
    else
        self._uiLeftFrame:SetActive(false)
        self._uiRightFrame:SetActive(false)
        self.isPlayEffSelf = false
        self.isPlayHitRat = false
        self:RefreshHitRatEffAll(money, MxlSealAddAwardRatio)
    end
end

--刷新自己玩家所有英雄命中率特效
function SealUi:RefreshHitRatEffAll(money, MxlSealAddAwardRatio)
    local hitRatStr = tostring(MxlSealAddAwardRatio)
    local len = #hitRatStr
    -- logError("len="..tostring(len))
    local hitRatList = {}
    for i = 1, len, 1 do
        table.insert(hitRatList, tonumber(string.sub(hitRatStr, i, i)))
    end
    -- logError("hitRatList="..GC.uu.Dump(hitRatList))
    local heroinfo = ZTD.TableData.GetData(ZTD.PlayerData.GetPlayerId(), "heroInfo")
    -- logError("heroinfo="..GC.uu.Dump(heroinfo))
    if not heroinfo then
        return
    end
    for k, v in pairs(heroinfo) do
        if v.PositionId then
            local gi, si = ZTD.MainScene.HeroPosId2GS(v.PositionId)
            local heroPos = self.battleview._hero_pos[gi][si]
            if heroPos then
                local heroCtrl = heroPos:GetHeroCtrl()
                if heroCtrl and heroCtrl._heroObj then
                    local posY = heroCtrl._cfg.id == 1005 and 1.3 or 0.8
                    heroCtrl._heroObj:SetSealEff1(money > 0, len, hitRatList, posY)
                end
            end
        end
    end
end

--获取封印状态
function SealUi:GetSealState(playerId)
    -- logError("playerId="..tostring(playerId))
    -- logError("222 sealStateList="..GC.uu.Dump(sealStateList))
    return sealStateList[playerId]
end

function SealUi:Reset()
end

function SealUi:RemoveRegister()
    ZTD.Notification.NetworkUnregisterAll(self)
    ZTD.Notification.GameUnregisterAll(self)
end

function SealUi:RemoveTimer()
    for k, v in ipairs(self.timerList) do
        if v then 
            ZTD.GameTimer.StopTimer(v)
        end
    end
    self.timerList = {}
end

function SealUi:RemoveEff()
    if self.effList then
        for k, v in ipairs(self.effList) do
            if v and v.effID then 
                ZTD.EffectManager.RemoveEffectByID(v.effID)
            end
        end
        self.effList = {}
    end
    if self.effID then
        ZTD.EffectManager.RemoveEffectByID(self.effID)
        self.eff = nil
    end
end

function SealUi:Release()
    self:RemoveRegister()
    self:RemoveEff()
    self:RemoveTimer()
end

return SealUi