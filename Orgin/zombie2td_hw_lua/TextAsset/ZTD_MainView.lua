local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu
local Version = "1.0.3";

local MainView = ZTD.ClassView("ZTD_MainView")

function MainView:ctor()
	
end
	
function MainView:OnCreate()
    self:Init()
    self:AddEvent()
end

function MainView:Init()
    MainView.inst = self
    self.mMenuOpen = false
    self.mMenuBtnCanTouch = true
    self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");

    self.gameData = ZTD.MJGame.gameData
    self.arenaConfig = ZTD.ArenaConfig.ArenaLimit
    self.exit = self:FindChild("above/exit")
    self.headNode = self:FindChild("above/playerNode/headNode")
    self.name = self:FindChild("above/playerNode/name")
    self.id = self:FindChild("above/playerNode/id")
    self.chouma = self:FindChild("above/infoNode/choumaNode/dikuang")
    self.diamond = self:FindChild("above/infoNode/diamondNode/dikuang")
    self.arenaNode = self:FindChild("above/arenaNode")
    self.exit = self:FindChild("above/exit")
    self.menu = self:FindChild("above/menuNode/menu")
    self.menuBg = self:FindChild("above/menuNode/bg")
    self.setting = self:FindChild("above/menuNode/bg/settingIcon")
    self.role = self:FindChild("above/menuNode/bg/roleIcon")
    
    self:FindChild("above/version"):GetComponent("Text").text = Version;
    
    GC.SubGameInterface.SetCurGroupId(0)
    ZTD.SetEffectMute(ZTD.isEffectMute)
    ZTD.PlayBackMusic("ZTD_bgm01")
    GC.SubGameInterface.SetNoticeBordPos(Vector3(80, -5, 0))
    self:changeSelfInfo()
    for i = 1, 4 do
        local arenaTrans = self.arenaNode:FindChild(i)
        local cfg = self.arenaConfig[i]
        local data = Json.decode(self.gameData[i].UnlockCondition)
        self:SetText(arenaTrans:FindChild("score"), GC.uu.numberToStrWithComma(cfg.multipleMin).."~"..GC.uu.numberToStrWithComma(cfg.multipleMax).."เท่า")
        self:SetText(arenaTrans:FindChild("icon/limit"), GC.uu.numberToStrWithComma(data.Min[1].Count).."เข้าห้อง")
        arenaTrans:FindChild("vip"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "xc_VIP"..data.VipLocked)
    end
    self.headIcon = GC.SubGameInterface.CreateHeadIcon({parent=self.headNode})

    --刷新玩家信息
    GC.HallNotificationCenter.inst():register(self, self.changeSelfInfo, GC.Notifications.changeSelfInfo)

    --跳场
    ZTD.Notification.GameRegister(self, ZTD.Define.OnPushMainToGame, self.OnPushMainToGame)
    -- 刷新玩家信息
    ZTD.Notification.GameRegister(self, ZTD.Define.changeSelfInfo, self.changeSelfInfo)
end

function MainView:OnPushMainToGame(id)
    self:MainToGame(id)
end

function MainView:changeSelfInfo(data)
    -- log("changeSelfInfo data="..GC.uu.Dump(data))
    local chouma = GC.uu.numberToStrWithComma(GC.SubGameInterface.GetHallMoney())
    self:SetText("above/infoNode/choumaNode/Text", chouma)
    local diamond = GC.uu.numberToStrWithComma(GC.SubGameInterface.GetHallDiamond())
    self:SetText("above/infoNode/diamondNode/Text", diamond)
    self:SetText("above/playerNode/name", GC.SubGameInterface.GetNickName())
    self:SetText("above/playerNode/id", "ID "..GC.SubGameInterface.GetPlayerId())
end

--打开商城
function MainView:OpenShop(ChouMa, Integral)
    local param = {
        ChouMa = ChouMa,
        Integral = Integral,
    }
    GC.SubGameInterface.ExOpenShop(param)
end

function MainView:AddEvent()
    self:AddClick(self.exit, function()
        UnityEngine.GL.Clear(false, true, Color.black)
		ZTD.MJGame.Back2Hall(true)
    end, false)	
    self:AddClick(self.chouma, function()
        local ChouMa = GC.SubGameInterface.GetHallMoney()
        local Integral = GC.SubGameInterface.GetHallIntegral()
        self:OpenShop(ChouMa, Integral)
    end, false)	
    self:AddClick(self.diamond, function()
        local ChouMa = GC.SubGameInterface.GetHallMoney()
        local Integral = GC.SubGameInterface.GetHallIntegral()
        self:OpenShop(ChouMa, Integral)
    end, false)	
    for i = 1, 4 do
        local arenaTrans = self.arenaNode:FindChild(i)
        self:AddClick(arenaTrans, function()
            self:MainToGame(i)
        end, false)	
    end
    self:AddClick(self.menu, function()
        if self.mMenuOpen then
            self:OnCloseMenu()
        else
            self:OnOpenMenu()
        end
    end, false)	
    self:AddClick(self.setting, function()
        ZTD.ViewManager.OpenMessageBox("ZTD_PauseView")
    end, false)	
    self:AddClick(self.role, function()
        ZTD.ViewManager.OpenMessageBox("ZTD_HelpView")
    end, false)
end

function MainView:MainToGame(id)
    -- log("id="..tostring(id))
    ZTD.PlayerData.SetRoomArenaID(id)
    local cfg = self.arenaConfig[id]
    local data = Json.decode(self.gameData[id].UnlockCondition)
    local chouma = GC.SubGameInterface.GetHallMoney()
    local vip = GC.SubGameInterface.GetVipLevel()
    local isUnlockProp = GC.SubGameInterface.CheckUnlockPropState(self.gameData.GameID)
    -- log("isUnlockProp="..tostring(isUnlockProp))
    if vip < data.VipLocked then
        if id == 4 then
            GC.SubGameInterface.OpenVipView()
        elseif id == 2 or id == 3 then
            self:OpenLockPopOrTip(id)
        elseif id == 1 then
            if isUnlockProp then
                ZTD.Flow.groupId = self.gameData[id].GroupID
                ZTD.MainView.inst:SetActive(false)
                ZTD.ViewManager.Open("ZTD_LoadingView")
            else
                GC.SubGameInterface.OpenUnlockGift({vipLimit = data.VipLocked})
            end
        end
        return
    end
    if chouma < data.Min[1].Count then
        -- ZTD.ViewManager.ShowTip(self.language.txt_choumaLimit)
        local ChouMa = GC.SubGameInterface.GetHallMoney()
        local Integral = GC.SubGameInterface.GetHallIntegral()
        self:OpenShop(ChouMa, Integral)
        return
    end
    ZTD.Flow.groupId = self.gameData[id].GroupID
    ZTD.MainView.inst:SetActive(false)
    ZTD.ViewManager.Open("ZTD_LoadingView")
end

function MainView:OpenLockPopOrTip(id)
    if id == 2 or id == 3 then
        local key = ""
        if id == 2 then
            key = "EliteArena"
        elseif id == 3 then
            key = "MasterArena"
        end
        ZTD.LockPop.OpenLockPopView(self.language.txt_v3Pop, function()
            local param = {}
            param.currentView = "VipThreeCardView"
            GC.SubGameInterface.OpenGiftSelectionView(param)
        end)
    else
        ZTD.ViewManager.ShowTip(self.language.txt_viplevelLimit)
    end
end

function MainView:OnOpenMenu()
    if self.mMenuOpen then return end
    if not self.mMenuBtnCanTouch then return end
    ZTD.PlayMusicEffect("zb_expandMenu", nil, nil, true)
    self.mMenuBtnCanTouch = false;
   
    self.role:SetActive(true)
    self:RunAction(self.menuBg, {
        {
            "localMoveBy",0,-200,0.075,
            onEnd = function()
                self.setting:SetActive(true)
            end
        },
        {
            "localMoveBy",0,-100,0.1,
        },
        {
            "delay",0.1,
            onEnd = function()
                self.mMenuBtnCanTouch = true;
                self.mMenuOpen = true;
            end
        }
    } );
end

function MainView:OnCloseMenu()
    ZTD.PlayMusicEffect("zb_expandMenu", nil, nil, true)
    
    if not self.mMenuOpen then return end
    if not self.mMenuBtnCanTouch then return end
    self.mMenuBtnCanTouch = false;

    self.role:SetActive(true)
    self:RunAction(self.menuBg, {
        {
            "localMoveBy",0,100,0.1,
            onEnd = function()
                self.setting:SetActive(false);
            end
        },
        {
            "localMoveBy",0,200,0.075,
            onEnd = function()
                self.role:SetActive(false)
            end
        },
        {
            "delay",0.1,
            onEnd = function()
                self.mMenuBtnCanTouch = true;
                self.mMenuOpen = false;
            end
        }
    } );
end

function MainView:OnDestroy()	
    MainView.inst = nil;
    GC.SubGameInterface.DestroyHeadIcon(self.headIcon)
    ZTD.Notification.GameUnregisterAll(self)
    GC.HallNotificationCenter.inst():unregisterAll(self)
end

return MainView