local CC = require("CC")
local GC = require("GC")

local VERSION_CODE = 1
local VERSION_NAME = "1.0.1"

local MiniSBView = CC.uu.ClassView("MiniSBView")
local MNSBConfig = require("View/MiniSBView/MiniSBConfig")
local proto = require("View/MiniSBView/MiniSBNetwork/game_pb")
local MiniSBLocalData = require("View/MiniSBView/MiniSBLocalData")
local MiniSBViewManager = require("View/MiniSBView/MiniSBViewManager")
local MiniSBNotification = require("View/MiniSBView/MiniSBNetwork/MiniSBNotification")

-- function
local logger
local initContext
local initPanel
local initBtns
local initBetBoard
local initRoundHistory
local initStreakInfo

local bindClickListener
local betBtnClick
local betNumberBtnClick

local refreshTempBetChipText
local showResultCover
local showHistoryEffectNode
local hideHistoryEffectNode
local setButtonClickEffect

local showConnectingView
local hideConnectingView

local showTest
local hideTest

-- params
local leftClickCount = 0
local rightClickCount = 0

local isBetPanelMove  -- 如果下注面板移动了，则点击其他地方，不会初始化他的位置

local longPhoneResult  -- 用作记录出现龙凤时，下一局开始时，消除状态

local moveOut  -- 是否移开

local BetCounts = {} --所有的下注总额
local MyBetCount = 0

-- timer
local COUNTDOWN_TIMER = "COUNTDOWN_TIMER" -- 倒计时定时器

local COVER_TIMER = "COVER_TIMER" -- 盖子消失定时器

local ConnectingViewPos = {
    FullScreen = -125,
    Window = 13
}

local LongFengEffectInfo = {
    [proto.Long] = {bundleName = "MiniSBView/Frefab", effectName = "Effect_UI_long"},
    [proto.Phone] = {bundleName = "MiniSBView/Frefab", effectName = "Effect_UI_feng"}
}

function MiniSBView:ctor(param)
    log("MiniSBView:ctor, Version code = " .. VERSION_CODE .. ", Version Name = " .. VERSION_NAME)
    self.param = param
    self.openResult = nil
    self.firstTimesOpenChatView = true

    self.timeLeft = 0 -- 倒计时时间

    self.smallBet = 0
    self.bigBet = 0

    leftClickCount = 0
    leftClickCount = 0

    BetCounts[proto.Big] = 0
    BetCounts[proto.Small] = 0

    moveOut = false
    isBetPanelMove = false
    longPhoneResult = MNSBConfig.LONG_FENG_RESULT.Invalid

    self.childViews = {} --子view
end

function MiniSBView:OnCreate()
    MiniSBNotification.ResetTable()
    self.language = self:GetLanguage()
    self.viewNode = self:FindChild("Node")
    self.viewCtr = self:CreateViewCtr(self.param)
    initContext(self)
    bindClickListener(self)

    local window = CC.MiniGameMgr.GetCurWindowMode()
    if window then
        self:toWindowsSize()
        self.firstTimesOpenChatView = false
    else
        --全屏默认打开聊天
        self:onChatBtnClick()
    end

    self:registerEvent()
    self.viewCtr:OnCreate()
end

function MiniSBView:registerEvent()
    MiniSBNotification.GameRegister(self, "ShowConnecting", showConnectingView)
    MiniSBNotification.GameRegister(self, "HideConnecting", hideConnectingView)
    CC.HallNotificationCenter.inst():register(self, self.toWindowsSize, CC.Notifications.OnSetWindowScreen)
    CC.HallNotificationCenter.inst():register(self, self.toFullScreenSize, CC.Notifications.OnSetFullScreen)
end

function MiniSBView:unregisterEvent()
    MiniSBNotification.GameUnregisterAll(self)
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetWindowScreen)
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetFullScreen)
end

function MiniSBView:OnDestroy()
    --清理子view
    for s, v in pairs(self.childViews) do
        if v then
            v:Destroy()
        end
    end
    -- if self.chatView then
    --     self.chatView:ActionOut()
    --     self.chatView = nil
    -- end
    self:unregisterEvent()

    local position = self.betPanel.localPosition
    MiniSBLocalData.SetBetPanelPosition(position)
    self:StopTimer(COUNTDOWN_TIMER)
    self:StopTimer(COVER_TIMER)
    if self.viewCtr then
        self.viewCtr:Destroy()
        self.viewCtr = nil
    end
end

-- 日志，如果不是当前的小游戏，就不打日志了
logger = function(str)
    local curGameId = CC.MiniGameMgr.GetCurMiniGameId()

    if curGameId == MNSBConfig.GameId then
        log(str)
    end
end

initContext = function(self)
    self.parentView = self:FindChild("Node/View")
    self.parentViewPos = self.parentView.localPosition
    self.subViewParent = self:FindChild("SubViewParent")
    self.chatViewParent = self:FindChild("ChatParent")
    initPanel(self)
    initBtns(self)
    initBetBoard(self)
    initRoundHistory(self)
    initStreakInfo(self)

    self.debugBtn = self:FindChild("Node/View/Debug")
    self.debugParent = self:FindChild("Node/View/DebugView")

    self.debugCount = 0
    if CC.DebugDefine.GetEnvState() == 3 or CC.DebugDefine.GetEnvState() == 4 then
        self.debugBtn:SetActive(true)
    else
        self.debugBtn:SetActive(false)
    end

    -- self:setViewDrag(self.parentView)
    -- self:setBetPanelDrag(self.betPanel)
end

initPanel = function(self)
    local panelPath = "Node/View/Panel"

    -- 押大按钮
    self.bigButton = self:FindChild(panelPath .. "/BigButton")
    -- 押小按钮
    self.smallButton = self:FindChild(panelPath .. "/SmallButton")

    -- 押大特效
    self.betBigEffectNode = self:FindChild(panelPath .. "/BigInputImg/Effect_UI_Dat_1")
    -- 押小特效
    self.betSmallEffectNode = self:FindChild(panelPath .. "/SmallInputImg/Effect_UI_Dat_2")

    -- 开大开小特效
    self.openBigEffect = self:FindChild(panelPath .. "/Effect_UI_tai")
    self.openSmallEffect = self:FindChild(panelPath .. "/Effect_UI_xiu")

    self.smallImg = self:FindChild(panelPath .. "/SmallImg")
    self.bigImg = self:FindChild(panelPath .. "/BigImg")

    -- 押大的人数区域
    self.bigPeopleText = self:FindChild(panelPath .. "/BigPeopleText"):GetComponent("Text")

    self.bigTextNode = self:FindChild(panelPath .. "/BigText")
    -- 押大的总筹码区域
    self.bigText = self.bigTextNode:GetComponent("Text")

    -- 我押大的筹码区域
    self.myBigTextNode = self:FindChild(panelPath .. "/MyBigText")
    self.myBigText = self.myBigTextNode:GetComponent("Text")
    self.myBigEffect = self:FindChild(panelPath .. "/MyBigText/Effect_UI_guang_1")

    -- 押小的人数区域
    self.smallPeopleText = self:FindChild(panelPath .. "/SmallPeopleText"):GetComponent("Text")
    -- 押小的总筹码区域
    self.smallTextNode = self:FindChild(panelPath .. "/SmallText")
    self.smallText = self.smallTextNode:GetComponent("Text")
    -- 我押小的筹码区域
    self.mySmallTextNode = self:FindChild(panelPath .. "/MySmallText")
    self.mySmallText = self.mySmallTextNode:GetComponent("Text")
    self.mySmallEffect = self:FindChild(panelPath .. "/MySmallText/Effect_UI_guang_2")

    -- 押小临时下注区
    self.smallTempText = self:FindChild(panelPath .. "/SmallTempText"):GetComponent("Text")
    -- 押大临时下注区
    self.bigTempText = self:FindChild(panelPath .. "/BigTempText"):GetComponent("Text")

    -- 骰盘外圈光
    self.siZiGuang = self:FindChild(panelPath .. "/Effect_UI_siziguang")

    -- 倒计时，用作设位置
    self.countDownView = self:FindChild(panelPath .. "/CountDownView")
    -- 倒计时，用作控制大小
    self.countDownNode = self.countDownView:FindChild("CountDownNode")
    self.CountDownText = self.countDownNode:GetComponent("Text")

    -- 房间局数
    self.roomIdNode = self:FindChild(panelPath .. "/RoomId")
    self.roomIdText = self.roomIdNode:GetComponent("Text")
    -- 骰子显示区域
    self.diceResult = self:FindChild(panelPath .. "/DiceResult")
    self.diceResult:SetActive(false)

    self.resultWin = self:FindChild(panelPath .. "/DiceResult/Win")
    self.awardText = self.diceResult:FindChild("Win/AwardText")
    self.resultWin:SetActive(false)

    self.dianshuView = self:FindChild(panelPath .. "/dianshu")
    self.returnView = self:FindChild(panelPath .. "/return")

    self.bettingCountDownPos = self:FindChild(panelPath .. "/CountDownPos1").localPosition
    self.resultCountDownPos = self:FindChild(panelPath .. "/CountDownPos2").localPosition

    -- 盖子
    self.gaizi = self:FindChild(panelPath .. "/Gaizi")
    self.gaizi:SetActive(false)
    self:setGaiziDrag(self.gaizi)

    -- 三个骰子位置
    self.diceNodePositions = {}
    for i = 1, 3 do
        local node = self.diceResult:FindChild("Dice" .. i .. "Position")
        table.insert(self.diceNodePositions, node)
    end
    self.diceParent = self.diceResult:FindChild("DiceParent")

    -- 6个骰子特效节点
    self.diceEffects = {}
    -- 6个骰子图片节点
    self.diceImages = {}
    for i = 1, 6 do
        local node = self.parentView:FindChild("ForClone/Effects/Effect_touzi_0" .. i)
        table.insert(self.diceEffects, node)
        local node = self.parentView:FindChild("ForClone/Images/touzi_0" .. i)
        table.insert(self.diceImages, node)
    end

    -- 龙凤结果特效
    self.longPhoneEffects = {}

    self.longPhoneEffects[proto.Long] = self:FindChild("Effect/Effect_UI_long")
    self.longPhoneEffects[proto.Phone] = self:FindChild("Effect/Effect_UI_feng")

    self.myBetTextFields = {}
    self.myBetTextFields[proto.InvalidAreas] = nil
    self.myBetTextFields[proto.Small] = self.mySmallText
    self.myBetTextFields[proto.Big] = self.myBigText

    self.myTempBetTextFields = {}
    self.myTempBetTextFields[proto.InvalidAreas] = nil
    self.myTempBetTextFields[proto.Small] = self.smallTempText
    self.myTempBetTextFields[proto.Big] = self.bigTempText

    self.connectingView = self:FindChild("ConnectingView/View")
    self.connectingView:FindChild("Content/Text"):GetComponent("Text").text = self.language.ConnectText
    for i=1,3 do
        self.connectingView:FindChild("Content/Point/0"..i):GetComponent("Text").text = "."
    end
end

initBtns = function(self)
    local btnsPath = "Node/View/Btns"
    self.streakBtn = self:FindChild(btnsPath .. "/Streak")
    self.rankBtn = self:FindChild(btnsPath .. "/Rank")
    self.ruleBtn = self:FindChild(btnsPath .. "/Rule")
    self.historyBtn = self:FindChild(btnsPath .. "/History")
    self.lineHistoryBtn = self:FindChild(btnsPath .. "/LineHistory")
    self.closeBtn = self:FindChild(btnsPath .. "/Close")
    self.chatBtn = self:FindChild(btnsPath .. "/Chat")
    self.resultEffectBtn = self:FindChild(btnsPath .. "/ResultEffect")
    self.playerRecordsBtn = self:FindChild(btnsPath .. "/PlayerRecords")

    -- local openDragEffect = MiniSBLocalData.GetResultEffect()
    -- self.resultEffectBtn:GetComponent("Toggle").isOn = openDragEffect

    MiniSBLocalData.SetResultEffect(false)
    self.resultEffectBtn:GetComponent("Toggle").isOn = false
    self.resultEffectBtn:GetComponent("Toggle").interactable = false
end

initBetBoard = function(self)
    local betBoardPath = "Node/BetBoard"
    -- 下注面板
    self.betPanel = self:FindChild(betBoardPath)
    -- 下注面板取消按钮
    self.cancelBtn = self:FindChild(betBoardPath .. "/ButtonCancel")
    -- 下注面板确定按钮
    self.confirmBtn = self:FindChild(betBoardPath .. "/ButtonConfirm")

    -- 下注面板，其他下注按钮
    self.inputBetBtn = self:FindChild(betBoardPath .. "/ButtonSelectNumber")

    self.betOptionsPanel = self:FindChild(betBoardPath .. "/betOptions")

    -- 下注面板 筹码按钮
    self.betOptionBtns = {}
    for i = 1, 8 do
        local btn = self:FindChild(betBoardPath .. "/betOptions/Button" .. i)
        btn:FindChild("Text"):GetComponent("Text").text = MNSBConfig.BET_DATA_Str[i]
        table.insert(self.betOptionBtns, btn)
    end

    self.betInputPanel = self:FindChild(betBoardPath .. "/betInputPanel")
    -- 下注面板 其他下注按钮
    self.betInputPanelBtns = {}
    for i = 1, 10 do
        local btn = self:FindChild(betBoardPath .. "/betInputPanel/Button" .. i - 1)
        table.insert(self.betInputPanelBtns, btn)
    end

    self.button000 = self.betInputPanel:FindChild("Button000")
    self.buttonBack = self.betInputPanel:FindChild("ButtonBack")

    self.parentWidth = self.transform.rect.width
    self.parentHeight = self.transform.rect.height
    self:AddDragEvent()
end

initRoundHistory = function(self)
    local roundHistoryPath = "Node/View/RoundHistory"

    self.roundHistoryNodeEffectParent = self:FindChild(roundHistoryPath .. "/EffectNode")
    self.redEffect = self.parentView:FindChild("ForClone/Effects/Effect_UI_xiaohong")
    self.blueEffect = self.parentView:FindChild("ForClone/Effects/Effect_UI_xiaolan")

    self.roundHistoryNodes = {}
    for i = 1, 15 do
        local btn = self:FindChild(roundHistoryPath .. "/" .. i)
        table.insert(self.roundHistoryNodes, btn)
    end
end

initStreakInfo = function(self)
    local streakInfoPath = "Node/View/StreakInfo"

    self.streakInfoView = self:FindChild(streakInfoPath)

    self.streakWinTextNode = self:FindChild(streakInfoPath .. "/StreakWinText")
    self.streakLoseTextNode = self:FindChild(streakInfoPath .. "/StreakLoseText")

    self.streakWinText = self.streakWinTextNode:GetComponent("Text")
    self.streakLoseText = self.streakLoseTextNode:GetComponent("Text")

    -- 15 连胜的特效
    self.roundHistoryEffect = self:FindChild(streakInfoPath .. "/Effect_UI_bianguang")

    self.winningStreakNodes = {}
    self.losingStreakNodes = {}
    for i = 1, 15 do
        local winNode = self:FindChild(streakInfoPath .. "/Win/" .. i)
        local loseNode = self:FindChild(streakInfoPath .. "/Lose/" .. i)
        table.insert(self.winningStreakNodes, winNode)
        table.insert(self.losingStreakNodes, loseNode)
    end
end

--点击筹码
betBtnClick = function(self, index)
    local addChip = MNSBConfig.BET_DATA[index]
    self.viewCtr:addTempBetChip(addChip)
    refreshTempBetChipText(self)
end

--点击按钮筹码
betNumberBtnClick = function(self, index)
    local betChip = self.viewCtr:getTempBetChip()
    local newBetChipStr = betChip
    if betChip == 0 then
        newBetChipStr = ""
    end

    newBetChipStr = newBetChipStr .. index
    local newBetChip = tonumber(newBetChipStr)

    self.viewCtr:setTempBetChip(newBetChip)
    refreshTempBetChipText(self)
end

--刷新我的临时下注区
refreshTempBetChipText = function(self)
    local betOption = self.viewCtr:getTempBetAreas()
    local textFiled = self.myTempBetTextFields[betOption]

    if textFiled ~= nil then
        local betChip = self.viewCtr:getTempBetChip()
        local chipFormat = CC.uu.ChipFormat(betChip)
        textFiled.text = chipFormat
    end
end

-- 点击事件
bindClickListener = function(self)
    self:AddClick(
        self.debugBtn,
        function()
            self.debugCount = self.debugCount + 1
            if self.debugCount >= 3 then
                MiniSBViewManager.OpenView("MiniSBDebugView", self.debugParent, {mainView = self})
                self.debugCount = 0
            end
        end
    )

    self:AddClick(self.bigButton, "onBigBlindBtnClick")
    self:AddClick(self.smallButton, "onSmallBlindBtnClick")
    self:AddClick(self.cancelBtn, "onCancelBtnClick")
    self:AddClick(self.confirmBtn, "onConfirmBtnClick")

    self:AddClick(self.closeBtn, "onCloseBtnClick")
    self:AddClick(self.chatBtn, "onChatBtnClick")
    --self:AddClick(self.resultEffectBtn, "onResultEffectBtnClick")
    self:AddClick(self:FindChild("Node/BtnClose"), "CloseView")
    self:AddClick(self:FindChild("Node/View/Panel"), "DeskClick")

    self:AddClick(self.streakBtn, "openMiniSBActivityView")
    self:AddClick(self.rankBtn, "openMiniSBRankView")
    self:AddClick(self.ruleBtn, "openMiniSBRuleView")
    self:AddClick(self.historyBtn, "openMiniSBHistoryView")
    self:AddClick(self.lineHistoryBtn, "openMiniSBLineHistoryView")
    self:AddClick(self.playerRecordsBtn, "openMiniSBMyHistoryView")

    self:AddClick(self.inputBetBtn, "onInputBetBtnClick")

    -- 下注面板 筹码按钮点击事件
    for i = 1, 8 do
        local btn = self.betOptionBtns[i]
        self:AddClick(
            btn,
            function()
                betBtnClick(self, i)
            end
        )

        setButtonClickEffect(self, btn)
    end

    -- 下注面板 其他下注点击事件
    for i = 1, 10 do
        local btn = self.betInputPanelBtns[i]
        self:AddClick(
            btn,
            function()
                betNumberBtnClick(self, i - 1)
            end
        )
        setButtonClickEffect(self, btn)
    end

    self:AddClick(
        self.button000,
        function()
            betNumberBtnClick(self, "000")
        end
    )
    self:AddClick(self.buttonBack, "onButtonBackClick")
    setButtonClickEffect(self, self.button000)
    setButtonClickEffect(self, self.buttonBack)
end

setButtonClickEffect = function(self, btn)
    btn.transform.onDown = function()
        self:RunAction(btn.transform, {"scaleTo", 0.95, 0.95, 0.05, ease = CC.Action.EOutBack})
    end

    btn.transform.onUp = function()
        self:RunAction(btn.transform, {"scaleTo", 1, 1, 0.05, ease = CC.Action.EOutBack})
    end
end

-------------------------------------------------
-- 盖子
-------------------------------------------------
showResultCover = function(self)
    self:StopTimer(COVER_TIMER)
    self.gaizi:SetActive(true)

    local time = 5

    self:StartTimer(
        COVER_TIMER,
        1,
        function()
            if time >= 1 then
                time = time - 1
            else
                self.gaizi:SetActive(false)
                self:showWinResultAfterAni()
            end
        end,
        -1
    )
end

showHistoryEffectNode = function(self, effectNodePosition, locationAreas)
    local name = "effect"
    local newNode = self.roundHistoryNodeEffectParent:FindChild(name)

    local child = self.redEffect
    if locationAreas == proto.Big then
        child = self.blueEffect
    end

    if newNode ~= nil then
        --删掉之前的
        CC.uu.destroyObject(newNode)
    end

    newNode = CC.uu.UguiAddChild(self.roundHistoryNodeEffectParent, child, name)
    newNode.localPosition = Vector3(0, 0, 0)

    self.roundHistoryNodeEffectParent.localPosition = effectNodePosition
    -- newNode:GetComponent("Animator"):Play("Effect_UI_xiaohong")
    newNode:SetActive(true)
end

hideHistoryEffectNode = function(self)
    local name = "effect"
    local newNode = self.roundHistoryNodeEffectParent:FindChild(name)

    if newNode ~= nil then
        newNode:SetActive(false)
    end
end


function MiniSBView:AddDragEvent()
    self.transform.onMove = function(obj, pos)
		self:moveWinLimit(obj)
    end
end

function MiniSBView:moveWinLimit(obj)
	local moveX = math.abs(obj.localPosition.x)
	local moveY = math.abs(obj.localPosition.y)

    local limitX = self.parentWidth / 2
	local limitY = self.parentHeight / 2

	if moveX > limitX then
		local x = obj.localPosition.x > 0 and limitX or 0 - limitX
		obj.localPosition = Vector3(x, obj.localPosition.y, 0)
	end

	if moveY > limitY then
		local y = obj.localPosition.y > 0 and limitY or 0 - limitY
		obj.localPosition = Vector3(obj.localPosition.x, y, 0)
	end
end

-- 点击压大
function MiniSBView:onBigBlindBtnClick()
    if self.timeLeft <= 3 or self.viewCtr:getGameState() == proto.HandleResult then
        logger("时间小于三秒或者不是下注阶段，禁止下注了")
        return
    end
    local success = self.viewCtr:changeTempBetAreas(proto.Big)

    if success then
        self:switch2BigAreas()
        self:showBetPanel()
    else
        -- logger("已经下注到押小了，不能切换下注区域了")
        local str = MNSBConfig.LOCAL_TIPS_STR[MNSBConfig.GameLanguage]["betAreasLimit"]
        CC.ViewManager.ShowTip(str)
    end
end

-- 点击压小
function MiniSBView:onSmallBlindBtnClick()
    if self.timeLeft <= 3 or self.viewCtr:getGameState() == proto.HandleResult then
        logger("时间小于三秒或者不是下注阶段，禁止下注了")
        return
    end
    local success = self.viewCtr:changeTempBetAreas(proto.Small)

    if success then
        self:switch2SmallAreas()
        self:showBetPanel()
    else
        -- logger("已经下注到押大了，不能切换下注区域了")
        local str = MNSBConfig.LOCAL_TIPS_STR[MNSBConfig.GameLanguage]["betAreasLimit"]
        CC.ViewManager.ShowTip(str)
    end
end

function MiniSBView:showBetPanel()
    -- local position = MiniSBLocalData.GetBetPanelPosition()
    -- if position and not isBetPanelMove then
    --     self.betPanel.localPosition = position
    -- end
    self.betPanel:SetActive(true)
end

function MiniSBView:hideBetPanel()
    if self.betPanel.activeSelf then
        self.betPanel:SetActive(false)
        local position = self.betPanel.localPosition
        isBetPanelMove = false
        MiniSBLocalData.SetBetPanelPosition(position)
    end
end

function MiniSBView:stopBet()
    -- 不用每次都刷
    if self.bigButton.interactable == false then
        return
    end

    self.viewCtr:clearTempBetChip()
    self.bigButton:SetActive(true)
    self.smallButton:SetActive(true)

    self.bigButton.interactable = false
    self.smallButton.interactable = false

    self.betSmallEffectNode:SetActive(false)
    self.betBigEffectNode:SetActive(false)

    self:hideBetPanel()
end

-- 点击下注面板取消
function MiniSBView:onCancelBtnClick()
    self.viewCtr:revokeBet()
    self:hideBetPanel()
end

-- 点击下注面板确定
function MiniSBView:onConfirmBtnClick()
    self.viewCtr:sendBet2Server()
end

function MiniSBView:onButtonBackClick()
    local betChip = self.viewCtr:getTempBetChip()

    local newbetChip = betChip / 10
    betChip = math.floor(newbetChip)

    self.viewCtr:setTempBetChip(betChip)
    refreshTempBetChipText(self)
end

-- 点击下注面板 其他下注
function MiniSBView:onInputBetBtnClick()
    self.viewCtr:clearTempBetChip()
    refreshTempBetChipText(self)
    if self.betOptionsPanel.activeSelf then
        self.betOptionsPanel:SetActive(false)
        self.betInputPanel:SetActive(true)
    else
        self.betOptionsPanel:SetActive(true)
        self.betInputPanel:SetActive(false)
    end
end

-- 点击连胜
function MiniSBView:openMiniSBActivityView()
    local view = MiniSBViewManager.OpenView("MiniSBActivityView", self.subViewParent, {mainView = self})
    self.childViews["MiniSBActivityView"] = view
end

-- 点击排行榜
function MiniSBView:openMiniSBRankView()
    local view = MiniSBViewManager.OpenView("MiniSBRankingView", self.subViewParent, {mainView = self})
    self.childViews["MiniSBRankingView"] = view
end

-- 点击规则
function MiniSBView:openMiniSBRuleView()
    -- self:showLongPhoneEffect()
    local view = MiniSBViewManager.OpenView("MiniSBRuleView", self.subViewParent, {mainView = self})
    self.childViews["MiniSBRuleView"] = view
end
-- 点击个人历史
function MiniSBView:openMiniSBMyHistoryView()
    local view = MiniSBViewManager.OpenView("MiniSBHistoryView", self.subViewParent, {mainView = self})
    self.childViews["MiniSBHistoryView"] = view
end
-- 点击历史
function MiniSBView:openMiniSBHistoryView()
    local view = MiniSBViewManager.OpenView("MiniSBMyHistoryView", self.subViewParent, {mainView = self})
    self.childViews["MiniSBMyHistoryView"] = view
end
-- 点击线路图
function MiniSBView:openMiniSBLineHistoryView()
    self.viewCtr:onLineHistoryBtnClick()
end
-- 点击关闭
function MiniSBView:onCloseBtnClick()
    self:ActionOut()
end
-- 点击聊天
function MiniSBView:onChatBtnClick()
    if self.chatView then
        self.chatView:ActionOut()
    else
        self.chatView = MiniSBViewManager.OpenView("MiniSBChatView", self.chatViewParent, {mainView = self})
        self.childViews["MiniSBChatView"] = self.chatView
    end
end

function MiniSBView:CloseView()
    CC.MiniGameMgr.OnMiniGameClose(MNSBConfig.GameId)
end

--选择游戏界面
function MiniSBView:DeskClick()
    CC.MiniGameMgr.SetCurMiniGameId(MNSBConfig.GameId)
end

function MiniSBView:SetSortingOrder(orderLayer)
    local canvasTable = self.transform:GetComponentsInChildren(typeof(UnityEngine.Canvas), true)
    for _,v in pairs(canvasTable:ToTable())  do
        v.sortingOrder = v.sortingOrder % 50 + orderLayer
	end
    local layerTable = self.transform:GetComponentsInChildren(typeof(UnityEngine.Renderer),true)
    for _,v in pairs(layerTable:ToTable())  do
        v.sortingOrder = v.sortingOrder % 50 + orderLayer
	end
end

-- 点击开盖效果
function MiniSBView:onResultEffectBtnClick()
    local openDragEffect = MiniSBLocalData.GetResultEffect()

    if openDragEffect then
        MiniSBLocalData.SetResultEffect(false)
    else
        MiniSBLocalData.SetResultEffect(true)
    end
    self.resultEffectBtn:GetComponent("Toggle").isOn = not openDragEffect
end

-- 选择压大
function MiniSBView:switch2BigAreas()
    self.bigButton:SetActive(false)
    self.smallButton:SetActive(true)
    self.betBigEffectNode:SetActive(true)
    self.betSmallEffectNode:SetActive(false)
    refreshTempBetChipText(self)
end

-- 选择压小
function MiniSBView:switch2SmallAreas()
    self.bigButton:SetActive(true)
    self.smallButton:SetActive(false)
    self.betSmallEffectNode:SetActive(true)
    self.betBigEffectNode:SetActive(false)
    refreshTempBetChipText(self)
end

-------------------------------------------------
-- 下注成功，去掉临时下注区域的值，将值刷新到我的下注区
-------------------------------------------------
function MiniSBView:setBetChipText(betChip, areas)
    self.smallTempText.text = 0
    self.bigTempText.text = 0

    local node = nil

    if areas == proto.Big then
        node = self.myBigTextNode
    elseif areas == proto.Small then
        node = self.mySmallTextNode
    end
    if node ~= nil then
        self:numberChangeAction(node)
    end

    local textFiled = self.myBetTextFields[areas]

    local addCount = betChip - MyBetCount
    -- 保存我的下注值
    MyBetCount = betChip

    local bigAdded = 0
    local smallAdded = 0

    if areas == proto.Big then
        bigAdded = addCount
    else
        smallAdded = addCount
    end

    self.bigText.text = CC.uu.ChipFormat(BetCounts[proto.Big] + bigAdded)
    self.smallText.text = CC.uu.ChipFormat(BetCounts[proto.Small] + smallAdded)

    if textFiled ~= nil then
        textFiled.text = CC.uu.ChipFormat(betChip)
    end
end

-------------------------------------------------
-- 重新开始刷新我的下注区
-------------------------------------------------
function MiniSBView:clearBetChipText()
    self.mySmallText.text = 0
    self.myBigText.text = 0
end

-------------------------------------------------
--毁注后清除下注信息，包括 临时下注区，我的下注区，两边区域的选择
-------------------------------------------------
function MiniSBView:revokeSuccess()
    self.smallTempText.text = 0
    self.bigTempText.text = 0

    MyBetCount = 0

    self.bigButton:SetActive(true)
    self.smallButton:SetActive(true)

    self.betSmallEffectNode:SetActive(false)
    self.betBigEffectNode:SetActive(false)

    self.betPanel:SetActive(false)
end

-------------------------------------------------
-- 刷新时间
-------------------------------------------------
function MiniSBView:refreshCountDown(timeLeft, gameState)
    self:StopTimer(COUNTDOWN_TIMER)
    self.countDownView:SetActive(false)
    self.timeLeft = timeLeft
    self.CountDownText.text = self.timeLeft
    if gameState == proto.HandleResult then
        self.countDownView.localPosition = self.resultCountDownPos
        self.countDownNode.localScale = Vector3(0.36, 0.36, 1)
    else
        self.countDownView.localPosition = self.bettingCountDownPos
        self.countDownNode.localScale = Vector3(1, 1, 1)
    end
    self.countDownView:SetActive(true)

    self:StartTimer(
        COUNTDOWN_TIMER,
        1,
        function()
            if self.timeLeft >= 1 then
                self.timeLeft = self.timeLeft - 1

                self.CountDownText.text = self.timeLeft

                if self.timeLeft <= 3 and gameState == proto.Betting then
                    self:stopBet()
                end
                -- 结算状态下，数字跳动
                if gameState == proto.HandleResult then
                    self:numberChangeAction(self.countDownView)
                end
            else
                self:StopTimer(COUNTDOWN_TIMER)
            end
        end,
        -1
    )
end

function MiniSBView:setRoomId(numOfGame)
    self.roomIdText.text = numOfGame
    self:numberChangeAction(self.roomIdNode)
end

function MiniSBView:numberChangeAction(node)
    self:RunAction(
        node,
        {{"scaleTo", 1.25, 1.25, 0.15, ease = CC.Action.EOutBack}, {"scaleTo", 1, 1, 0.15, ease = CC.Action.EOutBack}}
    )
end

-------------------------------------------------
-- 刷新面板
-------------------------------------------------
function MiniSBView:refreshPanel(sCUpdate)
    self.bigPeopleText.text = sCUpdate.bigAreaPlayerNum
    self.bigText.text = CC.uu.ChipFormat(sCUpdate.bigAreaValue)

    self.smallPeopleText.text = sCUpdate.smallAreaPlayerNum
    self.smallText.text = CC.uu.ChipFormat(sCUpdate.smallAreaValue)

    self.smallBet = sCUpdate.smallAreaValue
    self.bigBet = sCUpdate.bigAreaValue

    if sCUpdate.bigAreaValue ~= 0 then
        self:numberChangeAction(self.bigTextNode)
    end

    if sCUpdate.smallAreaValue ~= 0 then
        self:numberChangeAction(self.smallTextNode)
    end

    BetCounts[proto.Big] = sCUpdate.bigAreaValue
    BetCounts[proto.Small] = sCUpdate.smallAreaValue

    if sCUpdate.state == proto.Betting then
        -- 下注阶段
        self.diceResult:SetActive(false)
        self.resultWin:SetActive(false)
    elseif sCUpdate.state == proto.HandleResult then
    -- 结算阶段
    end
end

-------------------------------------------------
-- 显示结算 data:SCGameResult
-------------------------------------------------
function MiniSBView:showResult(sCGameResult)
    self:stopBet()

    -- 越南平台 平衡下注值
    if MNSBConfig.GameLanguage == "Vietnam" then
        local balanceValue
        if self.smallBet >= self.bigBet then
            balanceValue = self.bigBet
        else
            balanceValue = self.smallBet
        end
        self.bigText.text = CC.uu.ChipFormat(balanceValue)
        self.smallText.text = CC.uu.ChipFormat(balanceValue)
    end

    -- 保存结果
    self.openResult = sCGameResult
    -- 盖子开关
    local openDragEffect = MiniSBLocalData.GetResultEffect()

    local myReturn = sCGameResult.myReturn

    -- 返还
    if myReturn > 0 then
        local returnFormat = CC.uu.ChipFormat(myReturn)
        local returnText = MNSBConfig.LOCAL_TIPS_STR[MNSBConfig.GameLanguage]["returnText"] .. returnFormat
        self:showReturn(returnText)
    end

    -- 显示盖子，如果有盖子，其他结果都是等盖子拿开或时间到后显示
    if openDragEffect then
        showResultCover(self)
    end

    local lppayers = sCGameResult.lppayers

    -- 显示神龙 神风
    if #lppayers > 0 then
        if #lppayers == 2 then
            longPhoneResult = MNSBConfig.LONG_FENG_RESULT.Both
        else
            longPhoneResult = lppayers[1].longphoneType
        end

        self:showLongPhoneEffect(lppayers)
    end

    -- 显示骰子动画
    self:refreshDiceResult(sCGameResult.result, false)
end

function MiniSBView:showResultFormLogin(result, myWin)
    -- 显示骰子，高亮闪烁赢的区域，闪烁
    self:refreshDiceResult(result, true)
    self:stopBet()
    -- 显示数值
    if myWin ~= nil then
        self:showGain(myWin)
    end
end

function MiniSBView:showLongPhoneEffect(lppayers)
    -- lppayers = {
    --     [1] = {
    --         ["award"] = 2592734,
    --         ["longphoneType"] = 1,
    --         ["nick"] = "Royal_luo",
    --         ["playerID"] = 1015232
    --     },
    --     [2] = {
    --         ["award"] = 5259052,
    --         ["longphoneType"] = 2,
    --         ["nick"] = "Royal_luogizz",
    --         ["playerID"] = 1021568
    --     }
    -- }
    log(CC.uu.Dump(lppayers, "lppayers =", 10))

    local lastNode = nil

    -- 现在没设置回调，直接设置定时器，播放完成后关掉特效
    for i, player in ipairs(lppayers) do
        local transform = self.longPhoneEffects[player.longphoneType]
        -- if transform == nil then
        --     local effctInfo = LongFengEffectInfo[player.longphoneType]
        --     -- function CC.uu.LoadHallPrefab(bundleName, prefabName, parent, name, useSelfLayer)

        --     transform = CC.uu.LoadHallPrefab("MiniSBView/Frefab", effctInfo.effectName, self:FindChild("Effect"))
        --     self.longPhoneEffects[player.longphoneType] = transform
        -- end

        if transform ~= nil then
            local chipFormat = CC.uu.ChipFormat(player.award)
            transform:FindChild("text"):GetComponent("Text").text = self.language.Congratulations
            transform:FindChild("Name"):GetComponent("Text").text = "<b>" .. player.nick .. "</b>"
            transform:FindChild("WinChip"):GetComponent("Text").text = chipFormat
            local time = i - 1
            self:DelayRun(
                3.5 * time,
                function()
                    if player.longphoneType == proto.Long then
                        self:playEffectSount("long")
                    else
                        self:playEffectSount("phone")
                    end

                    if lastNode ~= nil then
                        lastNode:SetActive(false)
                    end
                    lastNode = transform
                    transform:SetActive(true)
                    transform:GetComponent("Animator"):Play("Effect_UI_long")
                    self:delayHideEffectNode(transform, 3.5)
                end
            )
        end
    end
end

function MiniSBView:delayHideEffectNode(node, time)
    self:DelayRun(
        time,
        function()
            node:SetActive(false)
        end
    )
end

-- 日志，如果不是当前的小游戏，就不打日志了
function MiniSBView:playEffectSount(str)
    local curGameId = CC.MiniGameMgr.GetCurMiniGameId()

    if curGameId == MNSBConfig.GameId then
        CC.Sound.PlayHallEffect(str)
    end
end

function MiniSBView:showOrHideEffect(isShow, locationAreas)
    self.openBigEffect:SetActive(false)
    self.openSmallEffect:SetActive(false)
    self.myBigEffect:SetActive(false)
    self.mySmallEffect:SetActive(false)
    self.siZiGuang:SetActive(false)
    self.roundHistoryEffect:SetActive(false)
    self.smallImg:SetActive(true)
    self.bigImg:SetActive(true)

    -- hideHistoryEffectNode(self)

    if isShow then
        local openResult = self.openResult
        if openResult ~= nil then
            if openResult.winStreak == 15 or openResult.losStreak == 15 then
                self.roundHistoryEffect:SetActive(true)
            end
        end

        -- if self.viewCtr.historyAreas ~= nil then
        --     local len = #self.viewCtr.historyAreas
        --     local effectNodePosition = self.roundHistoryNodes[len].localPosition
        --     showHistoryEffectNode(self, effectNodePosition, locationAreas)
        -- end

        self.siZiGuang:SetActive(true)

        if locationAreas == proto.Small then
            self.openSmallEffect:SetActive(true)
            self.smallImg:SetActive(false)
            self.mySmallEffect:SetActive(true)
        elseif locationAreas == proto.Big then
            self.openBigEffect:SetActive(true)
            self.bigImg:SetActive(false)
            self.myBigEffect:SetActive(true)
        end
    end
end

function MiniSBView:handleNewRound(sCNextRound)
    -- 重新开始，刷新状态
    self:clearBetChipText()
    -- 清除特效
    self:showOrHideEffect(false)

    MyBetCount = 0

    BetCounts[proto.Big] = 0
    BetCounts[proto.Small] = 0

    self.smallBet = 0
    self.bigBet = 0

    self.bigButton.interactable = true
    self.smallButton.interactable = true

    -- 是否隐藏连胜记录节点
    self:setStreakInfoViewState(sCNextRound.isLongphongFull)
    -- 隐藏点数
    self:hideResultDianshu()

    -- 出现龙凤，清除掉状态
    if longPhoneResult ~= MNSBConfig.LONG_FENG_RESULT.Invalid then
        self:clearLongPhoneStreak()
        longPhoneResult = MNSBConfig.LONG_FENG_RESULT.Invalid
    end

    longPhoneResult = MNSBConfig.LONG_FENG_RESULT.Invalid

    self.openResult = nil
end

function MiniSBView:clearLongPhoneStreak()
    if longPhoneResult == MNSBConfig.LONG_FENG_RESULT.Both then
        self:clearStreakNodes(true, true)
        self.streakWinText.text = 0
        self.streakWinText.text = 0
    else
        self:clearStreakNodes(
            longPhoneResult == MNSBConfig.LONG_FENG_RESULT.Long,
            longPhoneResult == MNSBConfig.LONG_FENG_RESULT.Feng
        )

        if longPhoneResult == MNSBConfig.LONG_FENG_RESULT.Long then
            self.streakWinText.text = 0
        end

        if longPhoneResult == MNSBConfig.LONG_FENG_RESULT.Feng then
            self.streakLoseText.text = 0
        end
    end
end

function MiniSBView:clearStreakNodes(long, feng)
    if long then
        for i = 1, 15 do
            self.winningStreakNodes[i]:SetActive(false)
        end
    end
    if feng then
        for i = 1, 15 do
            self.losingStreakNodes[i]:SetActive(false)
        end
    end
end

-------------------------------------------------
-- 如果出现七次龙凤，则隐藏
-------------------------------------------------
function MiniSBView:setStreakInfoViewState(longphongFull)
    if longphongFull then
        self.streakInfoView:SetActive(false)
    else
        self.streakInfoView:SetActive(true)
    end
end

-------------------------------------------------
-- 显示结算数值
-------------------------------------------------
function MiniSBView:showGain(count)
    if count > 0 then
        self.resultWin:SetActive(true)
    end
    if count > 0 then
        self.awardText.text = "+" .. CC.uu.ChipFormat(count)
    else
        self.awardText.text = ""
    end

    self:DelayRun(
        3,
        function()
            self:hideGain()
        end
    )
end

-------------------------------------------------
-- 隐藏结算数值
-------------------------------------------------
function MiniSBView:hideGain()
    self.resultWin:SetActive(false)
end
----
-------------------------------------------------
-- 显示骰子,动画或者图片·
-------------------------------------------------
function MiniSBView:refreshDiceResult(gameResult, fromLogin)
    self.diceResult:SetActive(true)
    -- 三个骰子
    local showEffect
    local resource
    local openDragEffect = MiniSBLocalData.GetResultEffect()

    -- 用图片或者特效,优先考虑是否登录带下来的 ， 显示骰子，如果是没盖子，则显示动画，要不然就显示图片
    if fromLogin or openDragEffect then
        resource = self.diceImages
        showEffect = false
    else
        resource = self.diceEffects
        showEffect = true
    end

    for i, node in ipairs(self.diceNodePositions) do
        local dice = gameResult.dices[i]
        local child = resource[dice]
        local name = "Dice" .. i
        local diceEffectNode = self.diceParent:FindChild(name)
        if diceEffectNode ~= nil then
            --删掉之前的
            CC.uu.destroyObject(diceEffectNode)
        end

        diceEffectNode = CC.uu.UguiAddChild(self.diceParent, child, name)
        diceEffectNode.localPosition = Vector3(node.x, node.y, 0)
        diceEffectNode:SetActive(true)
    end
    -- 如果是播放动画，则延时两秒后，等骰子结果摇出来，再播放结果动画
    if showEffect then
        self:DelayRun(
            2,
            function()
                self:showWinResultAfterAni()
            end
        )
    end

    if fromLogin then
        self:showOrHideEffect(true, gameResult.locationAreas)
    end
end

-------------------------------------------------
-- 刷新最近十五局历史
-------------------------------------------------
function MiniSBView:refreshRoundHistory(historyAreas)
    for i = 1, 15 do
        self.roundHistoryNodes[i]:SetActive(false)
    end

    for i, v in ipairs(historyAreas) do
        local bigNode = self.roundHistoryNodes[i]:FindChild("Big")
        local smallNode = self.roundHistoryNodes[i]:FindChild("Small")
        bigNode:SetActive(false)
        smallNode:SetActive(false)

        local small = v == proto.Small
        if small then
            smallNode:SetActive(true)
        else
            bigNode:SetActive(true)
        end
        self.roundHistoryNodes[i]:SetActive(true)

        if i == #historyAreas then
            local effectNodePosition = self.roundHistoryNodes[i].localPosition
            showHistoryEffectNode(self, effectNodePosition, v)
        end
    end
end

-------------------------------------------------
-- 刷新连胜或连败
-------------------------------------------------
function MiniSBView:refreshStreakInfo(winStreak, losStreak, formLogin, mybet)
    if mybet > 0 then
        self:showStreakInfo(winStreak, losStreak)

        if winStreak > 0 then
            self:numberChangeAction(self.streakWinTextNode)
        end
        if losStreak > 0 then
            self:numberChangeAction(self.streakLoseTextNode)
        end
    else
        if formLogin then
            self:showStreakInfo(winStreak, losStreak)
        end
    end
end

function MiniSBView:showStreakInfo(winStreak, losStreak)
    for i = 1, 15 do
        self.winningStreakNodes[i]:SetActive(false)
    end

    for i = 1, 15 do
        self.losingStreakNodes[i]:SetActive(false)
    end

    self:setStreakInfo(winStreak, losStreak)
    self:showStreakNode(winStreak, losStreak)
end

function MiniSBView:setStreakInfo(win, lose)
    self.streakWinText.text = win or 0
    self.streakLoseText.text = lose or 0
end

function MiniSBView:showStreakNode(winStreak, losStreak)
    if winStreak and winStreak > 0 then
        for i = 1, winStreak do
            self.winningStreakNodes[i]:SetActive(true)
        end
    elseif losStreak and losStreak > 0 then
        for i = 1, losStreak do
            self.losingStreakNodes[i]:SetActive(true)
        end
    end
end

-------------------------------------------------
--移开盖子后或者动画结束显示结果
-------------------------------------------------
function MiniSBView:showWinResultAfterAni()
    if self.openResult == nil then
        logger("Already show result")
        return
    end
    self:StopTimer(COVER_TIMER)

    CC.MiniGameMgr.SetMiniGameResult(MNSBConfig.GameId, self.openResult.myWin)

    local result = self.openResult.result
    -- 刷新路数图 最近15局大小情况
    self:refreshRoundHistory(self.viewCtr.historyAreas)
    -- 刷新连胜连败
    self:refreshStreakInfo(self.openResult.winStreak, self.openResult.losStreak, false, self.openResult.myBet)

    -- 结算结果
    self:showGain(self.openResult.myWin)
    -- 特效
    self:showOrHideEffect(true, result.locationAreas)

    -- 显示点数
    local dianshu = 0
    for i, v in ipairs(result.dices) do
        dianshu = dianshu + v
    end
    self:showResultDianshu(dianshu)

    self.openResult = nil
end

function MiniSBView:showResultDianshu(dianshu)
    self.dianshuView:SetActive(true)
    self.dianshuView:FindChild("Text"):GetComponent("Text").text = dianshu
end

function MiniSBView:hideResultDianshu(dianshu)
    self.dianshuView:SetActive(false)
end

function MiniSBView:showReturn(returnText)
    -- body
    self.returnView:FindChild("Text"):GetComponent("Text").text = returnText
    self.returnView.localScale = Vector3(0, 0, 0)
    self.returnView:SetActive(true)

    self:RunAction(
        self.returnView,
        {
            "scaleTo",
            1,
            1,
            0.2,
            ease = CC.Action.EOutBack,
            function()
                self:DelayRun(
                    1.6,
                    function()
                        self:hideReturn()
                    end
                )
            end
        }
    )
end
function MiniSBView:hideReturn()
    self:RunAction(
        self.returnView,
        {
            "scaleTo",
            0,
            0,
            0.2,
            ease = CC.Action.EOutQuad,
            function()
                self.returnView:SetActive(false)
            end
        }
    )
end

-------------------------------------------------
--两点距离
-------------------------------------------------
function MiniSBView:twoPointToDistance(x1, y1, x2, y2)
    return math.sqrt(math.pow((y2 - y1), 2) + math.pow((x2 - x1), 2))
end

-------------------------------------------------
--盖子拖动事件
-------------------------------------------------
function MiniSBView:setGaiziDrag(dragGo)
    local startPos = dragGo.localPosition
    local width = dragGo.width

    dragGo.onMove = function(obj, pos)
        if moveOut then
            return
        end

        local distance = self:twoPointToDistance(startPos.x, startPos.y, obj.localPosition.x, obj.localPosition.y)

        if distance > width then
            moveOut = true
            self:showWinResultAfterAni()
        end
    end

    dragGo.onEndDrag = function(obj, eventData)
        moveOut = false
        obj:SetActive(false)
        obj.localPosition = startPos
        self:showWinResultAfterAni()
    end
end
-------------------------------------------------
--View拖动事件
-------------------------------------------------
function MiniSBView:setViewDrag(dragGo)
    dragGo.onMove = function(obj, pos)
        if not isBetPanelMove then
            isBetPanelMove = true
        end
    end
end

function MiniSBView:moveLimit(obj, limitLeft, limitRight, limitTop, limitDown)
    local x = obj.localPosition.x
    local y = obj.localPosition.y

    if x < 0 and x < limitLeft then
        obj.localPosition = Vector3(limitLeft, obj.localPosition.y, 0)
    end

    if x > 0 and x > limitRight then
        obj.localPosition = Vector3(limitRight, obj.localPosition.y, 0)
    end

    if y > 0 and y > limitTop then
        obj.localPosition = Vector3(obj.localPosition.x, limitTop, 0)
    end

    if y < 0 and y < limitDown then
        obj.localPosition = Vector3(obj.localPosition.x, limitDown, 0)
    end
end

-------------------------------------------------
--下注面板拖动事件
-------------------------------------------------
function MiniSBView:setBetPanelDrag(dragGo)
    dragGo.onMove = function(obj, pos)
        if not isBetPanelMove then
            isBetPanelMove = true
        end
        self:moveLimit(obj, -320, 195, 226, -237)
    end
end

function MiniSBView:toWindowsSize(cb)
    -- local pos = self.viewNode.localPosition
    -- local chatBgWidth = 278
    -- local halfOfchatBgWidth = chatBgWidth / 2
    -- self.viewNode.transform.localPosition = Vector3(halfOfchatBgWidth, pos.y, 0)

    -- if self.chatView then
    --     self.chatView:ActionOut()
    -- end

    -- self:setEffectPos("Window")
    -- CC.HallNotificationCenter.inst():post(CC.Notifications.OnSetWindowScreenComplete, chatBgWidth)
end

function MiniSBView:toFullScreenSize()
    local pos = self.viewNode.localPosition
    self.viewNode.transform.localPosition = Vector3(0, pos.y, 0)

    if self.chatView then
        self.chatView:hideBlockBtn()
    else
        self.chatView = MiniSBViewManager.OpenView("MiniSBChatView", self.chatViewParent, {mainView = self})
    end
    self:setEffectPos("FullScreen")
end

function MiniSBView:setEffectPos(sizeName)
    local pos = self.connectingView:FindChild("Content").localPosition
    self.connectingView:FindChild("Content").localPosition = Vector3(ConnectingViewPos[sizeName], pos.y, 0)
end

showConnectingView = function(self, delayTime)
    self.showDelay = true
    -- 收完牌就隐藏
    self:DelayRun(
        delayTime or 0,
        function()
            if self.showDelay then
                self.connectingView:SetActive(true)
            end
        end
    )
end

hideConnectingView = function(self)
    self.showDelay = false
    self.connectingView:SetActive(false)
end

return MiniSBView
