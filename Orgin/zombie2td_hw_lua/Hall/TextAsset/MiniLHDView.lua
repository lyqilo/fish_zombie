local CC = require("CC")
local GC = require("GC")

local VERSION_CODE = 1
local VERSION_NAME = "1.0.1"

local MiniLHDView = CC.uu.ClassView("MiniLHDView")
local MNSBConfig = require("View/MiniLHDView/MiniLHDConfig")
local proto = require("View/MiniLHDView/MiniLHDNetwork/game_pb")
local MiniLHDLocalData = require("View/MiniLHDView/MiniLHDLocalData")
local MiniLHDViewManager = require("View/MiniLHDView/MiniLHDViewManager")
local MNLHDConfig = require("View/MiniLHDView/MiniLHDConfig")
local MiniLHDNotification = require("View/MiniLHDView/MiniLHDNetwork/MiniLHDNotification")

-- function
local initContext
local bindClickListener
local onBetBtnClick
local initPaiHeCardNodes

local showConnectingView
local hideConnectingView

local logger
-- timer
local COUNTDOWN_TIMER = "COUNTDOWN_TIMER" -- 倒计时定时器
local BETING_TIMER = "BETING_TIMER" -- 开局动效定时器
local RESULT_TIMER = "RESULT_TIMER" -- 结算动效定时器
local HIGHLIGHT_TIMER = "HIGHLIGHT_TIMER" -- 下注区域闪光动效定时器

-- constant
local FLY_BET_ANI_TIME = 0.4

local BET_TEXT_COLOR_FORMAT = "<color='#d79bb9'>%s/</color><color='#f2f76b'>%s</color>"

local BetChipCfg = {1000, 10000, 100000, 200000, 500000, 1000000}
local AreasCfgList = {
    [1000] = 1,
    [10000] = 2,
    [100000] = 3,
    [200000] = 4,
    [500000] = 5,
    [1000000] = 6
}

local PlayersPosition = {x = -313, y = 10} -- 玩家们的位置，筹码飞出去和飞回来的点
local AreasPosition = {
    [proto.Long] = {x = -235, y = 140, x2 = -12, y2 = 95}, --龙的筹码位置范围
    [proto.Hu] = {x = 101, y = 140, x2 = 324, y2 = 95}, --虎的筹码位置范围
    [proto.He] = {x = -185, y = 260, x2 = 261, y2 = 216} --和的筹码位置范围
}

local EffectPos = {
    FullScreen = -80,
    Window = 50
}

local ConnectingViewPos = {
    FullScreen = -134,
    Window = 0
}

local ResultPosition = {x = 42, y = 427} -- 结算后筹码票到中间
local MyWinPosition = {x = -141, y = 552} -- 小厅筹码位置

local HistoryNodeImageNames = {
    [proto.Long] = "ts_long",
    [proto.Hu] = "ts_hu",
    [proto.He] = "ts_he"
}

-- 位置
local LineMapPositions = {}
-- 最近历史
local RecentlyHistorys = {}
-- 路数图显示，分上下两个tab
local ShowTop = true

-- 上次推送别人下注的筹码
local OtherLastBets

-- 因为服务器是三秒推送一次下注信息，将推送的值，手动分成三次更新
local RandomBetTables = {}

-- 所有的下注信息
local BetInfo = {}

-- 点击效果缓存
local ClickEffectCache = {}

function MiniLHDView:ctor(param)
    log("MiniLHDView:ctor, Version code = " .. VERSION_CODE .. ", Version Name = " .. VERSION_NAME)
    self.param = param
    self.firstTimesOpenChatView = false
    OtherLastBets = {}
    ClickEffectCache = {}
    self.quaternion = Quaternion()
    self:resetBetInfo()
    self:resetOtherLastBets()
end

function MiniLHDView:OnCreate()
    MiniLHDNotification.ResetTable()
    self.language = self:GetLanguage()
    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewNode = self:FindChild("Node")
    self:registerEvent()
    self.viewCtr:OnCreate()
    initContext(self)
    bindClickListener(self)
    initPaiHeCardNodes(self)

    self:resetMyBets()
    self:resetBetText()
end

function MiniLHDView:OnDestroy()
    self:StopTimer(COUNTDOWN_TIMER)
    self:StopTimer(BETING_TIMER)
    self:StopTimer(RESULT_TIMER)
    self:StopTimer(HIGHLIGHT_TIMER)
    self:unregisterEvent()

    if self.chatView then
        self.chatView:ActionOut()
        self.chatView = nil
    end

    if self.viewCtr then
        self.viewCtr:Destroy()
        self.viewCtr = nil
    end
end

function MiniLHDView:registerEvent()
    CC.HallNotificationCenter.inst():register(self, self.toWindowsSize, CC.Notifications.OnSetWindowScreen)
    CC.HallNotificationCenter.inst():register(self, self.toFullScreenSize, CC.Notifications.OnSetFullScreen)

    MiniLHDNotification.GameRegister(self, "ShowConnecting", showConnectingView)
    MiniLHDNotification.GameRegister(self, "HideConnecting", hideConnectingView)
end

function MiniLHDView:unregisterEvent()
    MiniLHDNotification.GameUnregisterAll(self)
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetWindowScreen)
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetFullScreen)
end

-- 日志，如果不是当前的小游戏，就不打日志了
logger = function(str)
    local curGameId = CC.MiniGameMgr.GetCurMiniGameId()

    if curGameId == MNLHDConfig.GameId then
        log(str)
    end
end

--牌盒里的牌 初始化
initPaiHeCardNodes = function(self)
    self.dropCardNodes = {}
    local paihe2 = self:FindChild("Node/View/Desk/Paihe2")
    local image1 = paihe2:FindChild("Image1")
    local sX = image1.localPosition.x
    local sY = image1.localPosition.y
    table.insert(self.dropCardNodes, image1)
    for i = 2, 26 do
        local node = CC.uu.UguiAddChild(paihe2, image1)
        node.name = "Image" .. i
        node.localPosition = Vector3(sX - (0.4 * (i - 1)), sY + (0.8 * (i - 1)))
        table.insert(self.dropCardNodes, node)
    end

    self.useCardNodes = {}
    local paihe = self:FindChild("Node/View/Desk/Paihe")
    local image1_1 = paihe:FindChild("Image1")
    local image1_2 = paihe:FindChild("Image2")
    local sX_2 = image1_2.localPosition.x
    local sY_2 = image1_2.localPosition.y
    table.insert(self.useCardNodes, image1_1)
    table.insert(self.useCardNodes, image1_2)
    for i = 3, 26 do
        local node = CC.uu.UguiAddChild(paihe, image1_2)
        node.name = "Image" .. i
        node.localPosition = Vector3(sX_2 + (0.55 * (i - 2)), sY_2 + (0.9 * (i - 2)))
        table.insert(self.useCardNodes, node)
    end
end

initContext = function(self)
    local view = self:FindChild("Node/View")
    self.subViewParent = self:FindChild("SubViewParent")
    self.chatViewParent = self:FindChild("ChatViewParent")
    -- 押和按钮
    self.heGuangButton = view:FindChild("Desk/HeGuang")
    -- 押龙按钮
    self.longGuangButton = view:FindChild("Desk/LongGuang")
    -- 押虎按钮
    self.huGuangButton = view:FindChild("Desk/HuGuang")
    self.betGuangTexts = {}
    self.betGuangImages = {}
    -- 押和数量
    self.betGuangTexts[proto.He] = self.heGuangButton:FindChild("Text")
    -- 押龙数量
    self.betGuangTexts[proto.Long] = self.longGuangButton:FindChild("Text")
    -- 押虎数量
    self.betGuangTexts[proto.Hu] = self.huGuangButton:FindChild("Text")
    -- 押和光
    self.betGuangImages[proto.He] = self.heGuangButton:FindChild("Effect_UI_CJliang_He")
    -- 押龙光
    self.betGuangImages[proto.Long] = self.longGuangButton:FindChild("Effect_UI_CJliang_Long")
    -- 押虎光
    self.betGuangImages[proto.Hu] = self.huGuangButton:FindChild("Effect_UI_CJliang_Hu")

    self.roundIdText = view:FindChild("Desk/roundID")
    self.statusText = view:FindChild("Desk/status")
    self.playerNumText = view:FindChild("Desk/PlayerCount/Text")
    --剩牌
    self.card2Text = view:FindChild("Desk/BgCount2/Text")
    --废牌
    self.card1Text = view:FindChild("Desk/BgCount1/Text")

    -- 倒计时
    self.countDownBg = view:FindChild("CountDownBg")
    self.countDownText = self.countDownBg:FindChild("Text")
    self.countDownEffect1 = self.countDownBg:FindChild("Effect_UI_djs1")
    self.countDownEffect2 = self.countDownBg:FindChild("Effect_UI_djs2")
    -- vs
    self.vsBg = view:FindChild("vsBg")

    -- 点击效果
    self.clickEffect = view:FindChild("Desk/ForClone/ClickEffect")
    self.clickEffectParent = view:FindChild("Desk/ClickEffectParent")

    -- 下注筹码
    self.betToggles = {}
    -- 下注按下的显示筹码
    self.betPressToggles = {}

    for i = 1, 6 do
        local toggle = view:FindChild("Desk/BetChipOptions/" .. i)
        local pressToggle = view:FindChild("Desk/BetChipOptions/Press" .. i)
        table.insert(self.betToggles, toggle)
        table.insert(self.betPressToggles, pressToggle)
    end

    self.historyNodes = {}
    local lineMap = self:FindChild("Node/HigherLayer/LineHistory/History")
    local childCount = lineMap.childCount
    -- 最多显示198个节点 6 *33
    for i = 1, childCount do
        local node = lineMap:GetChild(i - 1)
        node.name = i
        table.insert(self.historyNodes, node)
    end

    self.longText = self:FindChild("Node/HigherLayer/LineHistory/LongText"):GetComponent("Text")
    self.huText = self:FindChild("Node/HigherLayer/LineHistory/HuText"):GetComponent("Text")
    self.heText = self:FindChild("Node/HigherLayer/LineHistory/HeText"):GetComponent("Text")

    self.chatBtn = view:FindChild("Desk/Chat")
    self.ruleBtn = self:FindChild("Node/HigherLayer/RuleBtn")
    self.historyBtn = self:FindChild("Node/HigherLayer/HistoryBtn")

    local cardsNode = view:FindChild("Desk/Cards")
    -- 发牌动效
    self.faCard = cardsNode:FindChild("Effect_UI_F")

    -- 龙牌 (翻开的)
    self.longCardKai = cardsNode:FindChild("Effect_UI_Fanpai")
    -- 虎牌 (翻开的)
    self.huCardKai = cardsNode:FindChild("Effect_UI_Fanpai2")
    --收牌动效
    self.shouCard = cardsNode:FindChild("Effect_UI_Shou")
    --下注提示动效
    -- self.betAniEffect = self:FindChild("TipsEffect/Effect_UI_Xiazhu")
    --停止下注动效
    self.stopBetEffect = self:FindChild("TipsEffect/Effect_UI_TZxiazhu")
    --获得筹码动效
    self.WinEffect = self:FindChild("TipsEffect/Win")
    self.AwardText = self.WinEffect:FindChild("AwardText")

    -- 虎牌的牌背
    self.huPaiBei = cardsNode:FindChild("HuPaiBei")

    --飘筹码节点
    local betChipAnis = self:FindChild("Node/View/Desk/BetChipAnis")
    self.betChipAnis = betChipAnis
    --飘筹码父节点
    self.betChipAnisParent = betChipAnis:FindChild("Clone")
    self.betChipAnisChilds = {}
    self.betChipAnisChildsCache = {{}, {}, {}, {}, {}, {}} --筹码缓存节点
    self.betChipAnisChildsUsed = {{}, {}, {}, {}, {}, {}} --已使用的缓存节点
    self.myBetChipAnisChilds = {{}, {}, {}, {}, {}, {}} --我的筹码节点
    for i = 1, 6 do
        local node = betChipAnis:FindChild("bet" .. i)
        table.insert(self.betChipAnisChilds, node)
    end

    local resultEffect = self:FindChild("Node/HigherLayer/ResultEffect")
    self.longWinEffect = resultEffect:FindChild("Effects_UI_long")
    self.huWinEffect = resultEffect:FindChild("Effects_UI_hu")
    self.heWinEffect = resultEffect:FindChild("Effects_UI_he")
    self.vsEffect = resultEffect:FindChild("Effects_UI_vs")

    self.connectingView = self:FindChild("ConnectingView/View")
    self.connectingView:FindChild("Content/Text").text = self.language.ConnectText
    for i=1,3 do
        self.connectingView:FindChild("Content/Point/0"..i).text = "."
    end

    self.debugBtn = self:FindChild("Node/HigherLayer/DebugBtn")
    self.debugParent = self:FindChild("Node/HigherLayer/DebugView")

    self.debugCount = 0
    if CC.DebugDefine.GetEnvState() == 3 or CC.DebugDefine.GetEnvState() == 4 then
        self.debugBtn:SetActive(true)
    else
        self.debugBtn:SetActive(false)
    end

    self.parentWidth = self.transform.rect.width
    self.parentHeight = self.transform.rect.height
    self:AddDragEvent()
end

function MiniLHDView:AddDragEvent()
    self.transform.onMove = function(obj, pos)
		self:moveLimit(obj)
    end
end

function MiniLHDView:moveLimit(obj)
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

function MiniLHDView:setBetLongClick()
    self.betBtns = {}
    local betInfoLong = {btn = self.longGuangButton, area = proto.Long}
    local betInfoHu = {btn = self.huGuangButton, area = proto.Hu}
    local betInfoHe = {btn = self.heGuangButton, area = proto.He}

    table.insert(self.betBtns, betInfoLong)
    table.insert(self.betBtns, betInfoHu)
    table.insert(self.betBtns, betInfoHe)

    for i, v in ipairs(self.betBtns) do
        v.btn.transform.onDown = function()
            onBetBtnClick(self, v.area)
            local totalTime = 3000
            self:StartTimer(
                "desktopFun",
                0.05,
                function()
                    totalTime = totalTime - 1

                    if totalTime < 0 then
                        self:StopTimer("desktopFun")
                    elseif totalTime < 2999 then
                        onBetBtnClick(self, v.area)
                    end
                end,
                totalTime
            )
        end
        v.btn.transform.onBeginDrag = function()
            self:StopTimer("desktopFun")
        end
        v.btn.transform.onUp = function()
            self:StopTimer("desktopFun")
        end
    end
end

-- 点击事件
bindClickListener = function(self)
    self:AddClick(
        self.debugBtn,
        function()
            self.debugCount = self.debugCount + 1

            if self.debugCount >= 3 then
                MiniLHDViewManager.OpenView("MiniLHDDebugView", self.debugParent, {mainView = self})
                self.debugCount = 0
            end
        end
    )

    self:setBetLongClick()

    self:AddClick(self.chatBtn, "onChatBtnClick")
    self:AddClick(self.ruleBtn, "openMiniLHDRuleView")
    self:AddClick(self.historyBtn, "openMiniLHDHistoryView")

    self:AddClick("Node/View/Desk/RevokeButton", "onRevokeBetClick")
    self:AddClick(self:FindChild("Node/View/Desk/BtnClose"), "CloseView")
    self:AddClick(self:FindChild("Node/View/Desk"), "DeskClick")

    local Style1Btn = self:FindChild("Node/HigherLayer/LineHistory/Style1Btn")
    local Style2Btn = self:FindChild("Node/HigherLayer/LineHistory/Style2Btn")

    UIEvent.AddToggleValueChange(
        Style1Btn,
        function(selected)
            if selected then
                self:onTopBtnClick()
            end
        end
    )
    UIEvent.AddToggleValueChange(
        Style2Btn,
        function(selected)
            if selected then
                self:onBottomBtnClick()
            end
        end
    )

    for i, v in ipairs(self.betToggles) do
        UIEvent.AddToggleValueChange(
            v,
            function(selected)
                if selected then
                    self:selectBet(i)
                end
            end
        )
    end
    -- 默认选择第一个筹码
    local selectChip = MiniLHDLocalData.GetSelectChip()
    self:selectBet(selectChip)
end

function MiniLHDView:selectBet(index, toggle)
    MiniLHDLocalData.SetSelectChip(index)
    for i, _ in ipairs(self.betPressToggles) do
        if i == index then
            self.betPressToggles[i]:SetActive(true)
            self.tempBetChip = BetChipCfg[i]
        else
            self.betPressToggles[i]:SetActive(false)
        end
    end
end

-- 点击下注区域
onBetBtnClick = function(self, betArea)
    self.viewCtr:sendBet2Server(self.tempBetChip, betArea)
end

-- 点击规则
function MiniLHDView:openMiniLHDRuleView()
    MiniLHDViewManager.OpenView("MiniLHDRuleView", self.subViewParent, {mainView = self})
end

-- 点击下注历史
function MiniLHDView:openMiniLHDHistoryView()
    MiniLHDViewManager.OpenView("MiniLHDHistoryView", self.subViewParent, {mainView = self})
end

function MiniLHDView:CloseView()
    CC.MiniGameMgr.OnMiniGameClose(MNLHDConfig.GameId)
end

--选择游戏界面
function MiniLHDView:DeskClick()
    CC.MiniGameMgr.SetCurMiniGameId(MNLHDConfig.GameId)
end

function MiniLHDView:SetSortingOrder(orderLayer)
    local canvasTable = self.transform:GetComponentsInChildren(typeof(UnityEngine.Canvas), true)
    for _,v in pairs(canvasTable:ToTable())  do
        v.sortingOrder = v.sortingOrder % 50 + orderLayer
	end
    local layerTable = self.transform:GetComponentsInChildren(typeof(UnityEngine.Renderer),true)
    for _,v in pairs(layerTable:ToTable())  do
        v.sortingOrder = v.sortingOrder % 50 + orderLayer
    end
end

-- 点击聊天
function MiniLHDView:onChatBtnClick()
    if self.chatView then
        self.chatView:ActionOut()
    else
        self.chatView = MiniLHDViewManager.OpenView("MiniLHDChatView", self.chatViewParent, {mainView = self})
    end
end

-- 刷新倒计时时间
function MiniLHDView:refreshCountDown(timeLeft, gameState)
    self.timeLeft = timeLeft
    self.countDownText.text = self.timeLeft

    if self.gameState ~= gameState then
        self:countDownEffectAction(false, false)
        -- 如果状态切换并且是下注状态，则重新计时
        local isBetting = gameState == proto.Betting
        if isBetting then
            self:StopTimer(COUNTDOWN_TIMER)
            self.stopBetEffect:SetActive(false)
            self.countDownText.text = self.timeLeft
            self:countDownEffectAction(true, false)

            self:StartTimer(
                COUNTDOWN_TIMER,
                1,
                function()
                    self:countDownEffectAction(false, false)
                    if self.timeLeft >= 1 then
                        self.timeLeft = self.timeLeft - 1
                        self.countDownText.text = self.timeLeft
                        self:countDownAni(self.timeLeft)
                    else
                        self:countDownEffectAction(false, false)
                        self:StopTimer(COUNTDOWN_TIMER)
                    end
                end,
                -1
            )
        end
        self.vsBg:SetActive(not isBetting)
        self.countDownBg:SetActive(isBetting)
    end
    self.gameState = gameState
end

function MiniLHDView:countDownEffectAction(action1, action2)
    self.countDownEffect1:SetActive(action1)
    self.countDownEffect2:SetActive(action2)
end

function MiniLHDView:countDownAni(timeLeft)
    if timeLeft <= 3 and self.gameState == proto.Betting then
        self:playSound("countdown")
        self:numberChangeAction(self.countDownText)
        self:countDownEffectAction(false, true)
    else
        self:countDownEffectAction(true, false)
    end
end

-- 设置场次ID
function MiniLHDView:setRoomId(roundName)
    local str = MNSBConfig.LOCAL_TEXT_STR[MNSBConfig.GameLanguage]["roundID"]
    self.roundIdText.text = str .. roundName
end

-- 设置下注状态
function MiniLHDView:setStateText(state)
    local str = MNSBConfig.LOCAL_TEXT_STR[MNSBConfig.GameLanguage]["state_" .. state]
    self.statusText.text = str
end

-- 设置玩家数量
function MiniLHDView:setPlayerNum(playerNum)
    self.playerNumText.text = tostring(playerNum)
end

-- 设置剩牌数量
function MiniLHDView:setCardsNum(cardLeft, dropCard)
    --TODO 界面也要更新
    local cardLeftNum = math.ceil(cardLeft / 16) --16 = 8 * 2
    local dropCardNum = math.ceil(dropCard / 16)

    self.card2Text.text = tostring(cardLeft)
    self.card1Text.text = tostring(dropCard)

    for i = 1, cardLeftNum do
        self.useCardNodes[i]:SetActive(true)
    end
    for i = 1, dropCardNum do
        self.dropCardNodes[i]:SetActive(true)
    end
    for i = cardLeftNum + 1, 26 do
        self.useCardNodes[i]:SetActive(false)
    end
    for i = dropCardNum + 1, 26 do
        self.dropCardNodes[i]:SetActive(false)
    end
end

-------------------------------------------------
--毁注后清除下注信息
-------------------------------------------------
function MiniLHDView:revokeSuccess(data)
    self:resetMyBets()
    self:revokeBetOnTable(self.myBetChipAnisChilds)
end

--刷新下注数额
function MiniLHDView:updateBets(betStat)
    for i, b in ipairs(betStat) do
        local myBet = self.myPlaceBets[b.area]
        -- 这次别人的下注
        local otherPeopleBet = b.allBet - myBet

        -- 保存所有下注
        BetInfo[b.area] = b.allBet

        -- 这次下注和上次下注的差值，差值可能为负数，因为别人毁注
        local diffCount = otherPeopleBet - OtherLastBets[b.area]
        -- 只展示一次，因为是自己下注的，或者下注值是最小值.或者被人毁注
        -- 根据差值飘筹码或者隐藏筹码

        -- 因为分两次，最小筹码为1000，如果不够2000.则一次飘完,如果时间快到了。也只飘一次了

        if diffCount < 2000 or self.timeLeft <= 2 then
            self:setBetText(b.area, b.allBet, myBet)
            self:betAnis(diffCount, b.area, false)
        else
            -- 因为服务器是两秒推送一次下注信息，所以这里启动定时器，将两秒推送的值，手动分成两次更新
            self:startTimerForAni(diffCount, b.area, OtherLastBets[b.area], myBet)
        end

        --保存这次别人下注的筹码
        OtherLastBets[b.area] = otherPeopleBet
    end
end

-- 重置下注值
function MiniLHDView:resetBetText()
    for _, betGuangText in ipairs(self.betGuangTexts) do
        betGuangText.text = string.format(BET_TEXT_COLOR_FORMAT, 0, 0)
    end
end

-- ************************************************************
-- setBetText 设置下注信息
-- @area : 下注区域
-- @allBet : 全部下注值
-- @myBet : 我的下注值
-- ************************************************************
function MiniLHDView:setBetText(area, allBet, myBet)
    if myBet > allBet then
        logger(string.format("setBetText error, mybet = %s , allbet = %s", myBet, allBet))
        return
    end

    local allBetText = CC.uu.ChipFormat(allBet)
    local myBetText = CC.uu.ChipFormat(myBet)
    self.betGuangTexts[area].text = string.format(BET_TEXT_COLOR_FORMAT, allBetText, myBetText)
end

function MiniLHDView:playSound(soundName)
    local curGameId = CC.MiniGameMgr.GetCurMiniGameId()
    -- log("play sound ,name = " .. soundName .. ",curGameId = " .. curGameId)
    if curGameId == MNLHDConfig.GameId then
        CC.Sound.PlayHallEffect(soundName)
    end
end

-- ************************************************************
-- startTimerForAni 启动定时器分2次刷新上次下注的值
-- @diffCount : 变化的总值
-- @area :变化的区域
-- @lastBet :上次的下注值
-- @myBet :我的下注值
-- ************************************************************
function MiniLHDView:startTimerForAni(diffCount, area, lastBet, myBet)
    -- 保存增加的筹码
    RandomBetTables.otherBetStats[area] = diffCount
    -- 定时器次数,三次后取消定时器
    RandomBetTables.countTimes[area] = 0
    -- 上次下注,用作显示
    RandomBetTables.areasLastBets[area] = lastBet

    -- 先执行一次
    local changeBet = self:randomBetCount(area, myBet)
    self:betAnis(changeBet, area, false)

    self:StopTimer("aniTimer" .. area)
    -- 启动定时器，执行剩下一次
    self:StartTimer(
        "aniTimer" .. area,
        1,
        function()
            -- 次数
            RandomBetTables.countTimes[area] = RandomBetTables.countTimes[area] + 1

            local changeBet = self:randomBetCount(area, myBet)
            self:betAnis(changeBet, area, false)
            -- 动作两次后，取消定时器
            if RandomBetTables.countTimes[area] == 1 then
                self:StopTimer("aniTimer" .. area)
            end
        end,
        -1
    )
end

-----------------------------------
-- randomBetCount 平均下注值
-- @area: 下注区域
-- @myBet: 我的下注值
-----------------------------------
function MiniLHDView:randomBetCount(area, myBet)
    local times = RandomBetTables.countTimes[area]

    local finalCount = 0
    local proportion = 1
    if times == 0 then
        proportion = 2 -- 二分之一
    elseif times == 1 then
        proportion = 1 -- 剩下的
    end
    local firstTimesWeight = RandomBetTables.otherBetStats[area] / proportion
    local firstTimesCount = math.floor(firstTimesWeight / 1000)
    local changeBet = firstTimesCount * 1000
    RandomBetTables.otherBetStats[area] = RandomBetTables.otherBetStats[area] - changeBet
    RandomBetTables.areasLastBets[area] = RandomBetTables.areasLastBets[area] + changeBet

    self:setBetText(area, RandomBetTables.areasLastBets[area], myBet)

    return changeBet
end

-----------------------------------
-- getBetValueCount 或者飘筹码的面值和个数
-- @betValue: 筹码面值
-- @aniType: 动作类型，飘筹码或毁注
-----------------------------------
function MiniLHDView:getBetValueCount(betValue, aniType)
    local betValueCount = {0, 0, 0, 0, 0, 0} --保存每个筹码面值 需要多少个
    betValue = math.abs(betValue)

    for i = #BetChipCfg, 1, -1 do
        local betChip = BetChipCfg[i]
        if betValue >= betChip and betValue > 0 then
            local count = math.floor(betValue / betChip)

            -- 毁注
            if aniType == false then
                local nodesCount = #self.betChipAnisChildsUsed[i]
                -- 如果牌桌上的筹码不足，则往低面值的筹码继续找
                if count <= nodesCount then
                    betValueCount[i] = count
                    betValue = betValue - count * betChip
                else
                    --如果有，那就有多少个，就顶多少个
                    betValueCount[i] = nodesCount
                    betValue = betValue - nodesCount * betChip
                end
            else
                betValueCount[i] = count
                betValue = betValue - count * betChip
            end
        end
    end
    -- 当返还的时候，可能会出现面值小于一千的
    if betValue < 1000 and betValue > 0 then
        betValueCount[1] = betValueCount[1] + 1
    end
    -- log(CC.uu.Dump(betValueCount, "+++++++++++++++++++betValueCount =", 10))
    return betValueCount
end

-- ************************************************************
-- betAnis 筹码动作
-- @betValue :筹码数值
-- @area :区域
-- @isMe :自己下的注
-- @exStartPositon :开始位置
-- @exEndPositon :结束位置
-- ************************************************************
function MiniLHDView:betAnis(betValue, area, isMe, exStartPositon, exEndPositon)
    local aniType = betValue > 0

    local betValueCount = self:getBetValueCount(betValue, aniType)

    -- 撤回筹码，自己已经从毁注回调撤回了
    if aniType == false and isMe == false then
        for i, b in ipairs(betValueCount) do
            local list = self.betChipAnisChildsUsed[i]
            if list and b > 0 then
                logger("第" .. i .. "个筹码，撤回" .. b .. "个")
                for j = 1, b do
                    self:betRevokeAni(list, nil, i)
                end
            end
        end
    else
        -- 飘筹码
        self:playSound("bet")
        for i, b in ipairs(betValueCount) do
            local bet = BetChipCfg[i]
            for _ = 1, b do
                local node = self:getBetNodes(bet, isMe, area)
                node:SetActive(true)

                --起始位置
                local startPosition = self:nodeAniStartPosition(i, isMe, exStartPositon)
                node.localPosition = Vector3(startPosition.x, startPosition.y, 0)

                -- 终点位置
                local position = self:nodeAniEndPosition(area, exEndPositon)

                -- 随机角度
                local rotationRandom = math.random(-360, 0)
                node.transform.localRotation = self.quaternion:SetEuler(0, 0, rotationRandom)

                self:RunAction(
                    node,
                    {
                        "spawn",
                        {"scaleTo", 0.4, 0.4, 0.4, ease = CC.Action.EInOutSine},
                        {
                            "localMoveTo",
                            position.x,
                            position.y,
                            FLY_BET_ANI_TIME,
                            ease = CC.Action.EOutQuart
                        }
                    }
                )
            end
        end
    end
end

-----------------------------------
-- nodeAniEndPosition 节点的终点位置
-- @area: 区域
-- @exEndPositon: 额外的位置
-----------------------------------
function MiniLHDView:nodeAniEndPosition(area, exEndPositon)
    local x
    local y

    if exEndPositon then
        x = exEndPositon.x
        y = exEndPositon.y
    else
        local as = AreasPosition[area]
        x = math.random(as.x, as.x2)
        y = math.random(as.y, as.y2)
    end

    return {["x"] = x, ["y"] = y}
end

-----------------------------------
-- nodeAniStartPosition 节点的起始位置
-- @i: 下注筹码
-- @isMe: 是否是自己下注
-- @exStartPositon: 额外的位置
-----------------------------------
function MiniLHDView:nodeAniStartPosition(i, isMe, exStartPositon)
    local x = PlayersPosition.x
    local y = PlayersPosition.y

    -- 额外位置的优先
    if exStartPositon then
        x = exStartPositon.x
        y = exStartPositon.y
    else
        if isMe then
            local pos = self.betToggles[i].localPosition
            x = pos.x
            y = pos.y
        else
            x = PlayersPosition.x
            y = PlayersPosition.y
        end
    end

    return {["x"] = x, ["y"] = y}
end

--------------------------------
-- 撤销筹码
--------------------------------
function MiniLHDView:betRevokeAni(list, i, j, winArea)
    local nodeInfo
    if i ~= nil then
        local info = list[i]
        if info.area == winArea then
            return
        end
        nodeInfo = table.remove(list, i)
    else
        nodeInfo = table.remove(list)
    end
    --把筹码从 已用列表 移回 未用列表
    if nodeInfo.node then
        --把筹码从 已用列表 移回 未用列表
        table.insert(self.betChipAnisChildsCache[j], nodeInfo.node)
        nodeInfo.node:SetActive(false)
        nodeInfo.node.localPosition = Vector3(PlayersPosition.x, PlayersPosition.y, 0)
    end
end

--------------------------------
-- 撤销掉筹码
--------------------------------
function MiniLHDView:revokeBetOnTable(childList, winArea)
    for j = 1, 6 do
        local list = childList[j]
        if list then
            for i = #list, 1, -1 do
                self:betRevokeAni(list, i, j, winArea)
            end
        end
    end
end

function MiniLHDView:getBetNodes(betValue, isMe, area)
    local index = AreasCfgList[betValue]
    local betNodes = self.betChipAnisChildsCache[index]
    local betNode = table.remove(betNodes)
    if betNode == nil then
        local child = self.betChipAnisChilds[index]
        betNode = CC.uu.UguiAddChild(self.betChipAnisParent, child)
    end

    -- 如果飘得是自己的筹码。则存进自己的使用节点，否则就是别人的，用作毁注时，撤销掉自己飘的筹码
    local nodeInfo = {["node"] = betNode, ["area"] = area}

    if isMe then
        table.insert(self.myBetChipAnisChilds[index], nodeInfo)
    else
        table.insert(self.betChipAnisChildsUsed[index], nodeInfo)
    end
    return betNode
end

--重置飘筹码
function MiniLHDView:resetBetAniNodes(winArea)
    -- 自己的筹码
    self:revokeBetOnTable(self.myBetChipAnisChilds, winArea)
    -- 别人的筹码
    self:revokeBetOnTable(self.betChipAnisChildsUsed, winArea)
end

-- 刷新面板
function MiniLHDView:refreshPanel(sCUpdate)
    self:setStateText(sCUpdate.state)
    self:refreshCountDown(sCUpdate.timeLeft, sCUpdate.state)
    self:updateBets(sCUpdate.betStat)
    self:setPlayerNum(sCUpdate.playerNum)
end

-- 显示结算 data:SCGameResult
function MiniLHDView:showResult(sCGameResult)
    logger(CC.uu.Dump(sCGameResult, "MiniLHDView gameResult =", 10))

    self.sCGameResult = sCGameResult

    -- 最后一次，同步下注值
    self:updateBets(sCGameResult.betStat)
    self:setPlayerNum(sCGameResult.playerNum)
    -- 停止下注
    self:setStateText(proto.HandleResult)

    self:playSound("stopBet")
    self.stopBetEffect:SetActive(true)
    -- 下注高亮区域隐藏
    self:betAreaEffect(false)

    -- 等动效完成，显示结果
    self:DelayRun(
        2,
        function()
            -- 这个特效会挡住点击，要隐藏掉
            self:setStateText(MNLHDConfig.GAME_STATE["ShowCards"])
            self.stopBetEffect:SetActive(false)
            self:showResultCards(sCGameResult.result, sCGameResult.myWin, false)
            self:refreshCountDown(sCGameResult.timeLeft - 2, proto.HandleResult)
        end
    )
end

function MiniLHDView:delaySetCardImage(node, card)
    self:DelayRun(
        0.2,
        function()
            self:showCrad(node, card)
        end
    )
end

-----------------------------------
-- showResultCards 显示结果牌
-- @result: 结果信息
-- @myWin: 我赢的钱
-- @formLogin: 登录进来是结算状态
-----------------------------------
function MiniLHDView:showResultCards(result, myWin, formLogin)
    self.longCard = result.long
    self.huCard = result.hu
    -- 虎牌延时显示，这里显示虎牌牌背
    self.huPaiBei:SetActive(true)
    self.faCard:SetActive(false)

    -- 先显示龙牌
    self.longCardKai:SetActive(true)
    self:delaySetCardImage(self.longCardKai:FindChild("pai1"), result.long)

    if formLogin then
        self.huPaiBei:SetActive(false)
        self.huCardKai:SetActive(true)
        self:showCrad(self.huCardKai:FindChild("pai1"), result.hu)
    else
        -- 后显示虎牌
        self:DelayRun(
            0.7,
            function()
                self.huPaiBei:SetActive(false)
                self.huCardKai:SetActive(true)
                self:delaySetCardImage(self.huCardKai:FindChild("pai1"), result.hu)
            end
        )

        -- 显示结果动效
        self:DelayRun(
            1.3,
            function()
                if result.locationArea == proto.Long then
                    self:showLongWinEffect(myWin)
                elseif result.locationArea == proto.Hu then
                    self:showHuWinEffect(myWin)
                elseif result.locationArea == proto.He then
                    self:showHeWinEffect(myWin)
                end

                self:highLightBetAreaEffect(result.locationArea, 3)
                self:insertHistory(result.locationArea)
            end
        )
    end
end

-- 显示龙虎VS动效
function MiniLHDView:showVsEffect()
    self:playSound("longhu")
    self:playGameResultEffect(self.vsEffect, 2, "stand", proto.He)
end

-- 显示龙赢动效
function MiniLHDView:showLongWinEffect(myWin)
    self:playSound("long")
    self:playGameResultEffect(self.longWinEffect, 0, "attack", proto.Long,myWin)
end

-- 显示虎赢动效
function MiniLHDView:showHuWinEffect(myWin)
    self:playSound("hu")
    self:playGameResultEffect(self.huWinEffect, 1, "attack2", proto.Hu,myWin)
end

-- 显示和赢动效
function MiniLHDView:showHeWinEffect(myWin)
    self:playSound("he")
    self.heWinEffect:SetActive(true)

    -- 2秒后开始筹码动作
    self:DelayRun(
        2,
        function()
            self:awardAni(proto.He,myWin)
        end
    )
end

-- 隐藏和赢动效
function MiniLHDView:hideHeWinEffect()
    self.heWinEffect:SetActive(false)
end

-----------------------------------
-- playGameResultEffect 赢的动效
-- @effectNode: 节点信息
-- @aniIndex: 动效序号
-- @aniName: 动效名称
-- @winArea: 赢的区域
-----------------------------------
function MiniLHDView:playGameResultEffect(effectNode, aniIndex, aniName, winArea,myWin)
    effectNode:SetActive(true)
    local spine = effectNode:FindChild("Image"):GetComponent("SkeletonGraphic")
    if spine ~= nil and spine.AnimationState ~= nil then
        -- log("playGameResultEffect ")
        spine.AnimationState:SetAnimation(aniIndex, aniName, false)
        local testFun
        testFun = function()
            if winArea ~= proto.He then
                self:awardAni(winArea,myWin)
            end
            effectNode:SetActive(false)
            spine.AnimationState:ClearTracks()
            spine.AnimationState.Complete = spine.AnimationState.Complete - testFun
        end
        spine.AnimationState.Complete = spine.AnimationState.Complete + testFun
    else
        -- 如果父节点隐藏的情况下，播放spine动画可能失败
        effectNode:SetActive(false)
        log("playGameResultEffect spine == nil ")
    end
end

-----------------------------------
-- returnBet2WinArea 返还赌注給赢的区域
-- @winArea: 赢的区域
-----------------------------------
function MiniLHDView:returnBet2WinArea(winArea)
    local winAreaAllBet = BetInfo[winArea]
    -- 自己的下注
    local myWin = 0
    local myReturn = 0

    if self.sCGameResult then
        myWin = self.sCGameResult.myWin or 0
        myReturn = self.sCGameResult.myReturn or 0
    end
    -- 别人的下注
    local myBet = self.myPlaceBets[winArea]
    local otherPeoplesBet = winAreaAllBet - myBet

    -- 飘得筹码开始的位置
    local startPos = ResultPosition

    -- 和 翻9倍,除开本金，只需8倍
    if winArea == proto.He then
        otherPeoplesBet = otherPeoplesBet * 8

        local myLongBet = self.myPlaceBets[proto.Long]
        local myHuBet = self.myPlaceBets[proto.Hu]

        local otherLongBet = (BetInfo[proto.Long] - myLongBet)
        local otherHuBet = (BetInfo[proto.Hu] - myHuBet)

        local myLongReturn = myLongBet / 2
        local myHuReturn = myHuBet / 2

        local otherLongReturn = otherLongBet / 2
        local otherHuReturn = otherHuBet / 2

        if myLongReturn > 0 then
            self:betAnis(myLongReturn, proto.Long, true, startPos)
        else
            self:betAnis(myHuReturn, proto.Hu, true, startPos)
        end

        self:betAnis(otherLongReturn, proto.Long, false, startPos)
        self:betAnis(otherHuReturn, proto.Hu, false, startPos)
    end

    if myWin > 0 then
        myWin = myWin - myBet
    end

    -- logger("myWin = " .. myWin)

    if otherPeoplesBet > 0 then
        -- 别人的下注，筹码飘回赢的区域
        self:betAnis(otherPeoplesBet, winArea, false, startPos)
    end
    --
    if myWin > 0 then
        -- 自己的下注，筹码飘回赢的区域
        self:betAnis(myWin, winArea, true, startPos)
    end
end

-----------------------------------
-- returnBet2Player 返还奖金給玩家
-- @list: 节点列表
-- @position: 最终位置
-----------------------------------
function MiniLHDView:returnBet2Player(list, position)
    for _, nodeList in ipairs(list) do
        for _, nodeInfo in ipairs(nodeList) do
            local cb = function(nodeInfo)
                self:DelayRun(
                    1,
                    function()
                        nodeInfo.node:SetActive(false)
                    end
                )
            end
            self:runBetAniAction(nodeInfo, position.x, position.y, cb)
        end
    end
end

-----------------------------------
-- betAniSound 一堆筹码动作时候的声音
-- @list: 节点列表
-- @winArea: 赢的区域
-----------------------------------
function MiniLHDView:betAniSound(list, winArea)
    for _, nodeList in ipairs(list) do
        for _, nodeInfo in ipairs(nodeList) do
            if nodeInfo then
                -- 回收筹码
                if winArea == nil then
                    self:playSound("bet")
                    return
                else
                    if nodeInfo.area ~= winArea then
                        self:playSound("bet")
                        return
                    end
                end
            end
        end
    end
end

-----------------------------------
-- awardAni 返还赌注动效
-- @winArea: 赢的区域
-----------------------------------
function MiniLHDView:awardAni(winArea,myWin)
    self:showGain(myWin)
    self:setStateText(MNLHDConfig.GAME_STATE["SendAwards"])

    -- 回收别人其他区域的筹码
    self:betAniSound(self.betChipAnisChildsUsed, winArea)
    for _, nodeList in ipairs(self.betChipAnisChildsUsed) do
        for _, nodeInfo in ipairs(nodeList) do
            if nodeInfo.area ~= winArea then
                local rs = ResultPosition
                self:runBetAniAction(nodeInfo, rs.x, rs.y)
            end
        end
    end
    -- 回收我其他区域的筹码
    self:betAniSound(self.myBetChipAnisChilds, winArea)
    for _, nodeList in ipairs(self.myBetChipAnisChilds) do
        for i, nodeInfo in ipairs(nodeList) do
            if nodeInfo.area ~= winArea then
                local rs = ResultPosition
                self:runBetAniAction(nodeInfo, rs.x, rs.y)
            end
        end
    end

    -- 返还筹码給赢的区域
    self:DelayRun(
        FLY_BET_ANI_TIME * 2,
        function()
            -- 前面收起来的筹码先撤销掉
            self:resetBetAniNodes(winArea)
            -- 返还筹码到赢的
            self:returnBet2WinArea(winArea)
        end
    )

    -- 筹码最终飘回到玩家处和自己的地方
    self:DelayRun(
        FLY_BET_ANI_TIME * 4,
        function()
            self:betAniSound(self.betChipAnisChildsUsed)
            self:returnBet2Player(self.betChipAnisChildsUsed, PlayersPosition)
            self:betAniSound(self.myBetChipAnisChilds)

            local pos = CC.MiniGameMgr:GetChipNodePos()
            if pos then
                local newPos = self.betChipAnis.transform:InverseTransformPoint(pos)
                self:returnBet2Player(self.myBetChipAnisChilds, newPos)
            end
        end
    )

    self:DelayRun(
        FLY_BET_ANI_TIME * 5,
        function()
            -- 最后飘回去才通知
            local myWin = 0
            if self.sCGameResult then
                myWin = self.sCGameResult.myWin
            end
            CC.MiniGameMgr.SetMiniGameResult(MNLHDConfig.GameId, myWin)
        end
    )
end

-----------------------------------
-- runBetAniAction 节点动作
-- @nodeInfo: 节点信息
-- @x: 位置x
-- @y: 位置y
-- @cb: 回调
-----------------------------------
function MiniLHDView:runBetAniAction(nodeInfo, x, y, cb)
    self:RunAction(
        nodeInfo.node,
        {
            "localMoveTo",
            x,
            y,
            FLY_BET_ANI_TIME,
            ease = CC.Action.EOutQuart,
            function()
                if cb then
                    cb(nodeInfo)
                end
            end
        }
    )
end

--登录后在结算状态通知
function MiniLHDView:showResultFormLogin(loginData)
    self:showResultCards(loginData.result, nil, true)
    self:highLightBetAreaEffect(loginData.result.locationArea)

    self.vsBg:SetActive(true)
    self:setStateText(MNLHDConfig.GAME_STATE["SendAwards"])
    local betStat = loginData.update.betStat
    if #betStat > 0 then
        for i, b in ipairs(betStat) do
            local myBet = self.myPlaceBets[b.area]
            self.betGuangTexts[b.area].text = string.format(BET_TEXT_COLOR_FORMAT, b.allBet, myBet)
        end
    end
end

--初始化我的下注额
function MiniLHDView:setPlaceBets(placeBets)
    if placeBets then
        for _, placeBet in ipairs(placeBets) do
            -- 上次推送后我的下注值
            if placeBet.betValue > 0 then
                local addChip = placeBet.betValue - self.myPlaceBets[placeBet.area]
                self:betAnis(addChip, placeBet.area, true)
            end
            self.myPlaceBets[placeBet.area] = placeBet.betValue

            local otherBet = RandomBetTables.areasLastBets[placeBet.area]

            self:setBetText(placeBet.area, otherBet + placeBet.betValue, placeBet.betValue)
        end
    end
end

function MiniLHDView:showClickEffect(area)
    local clickEffect = self:getClickEffectNode()

    local pos
    if area == proto.Long then
        pos = self.longGuangButton.localPosition
    elseif area == proto.Hu then
        pos = self.huGuangButton.localPosition
    elseif area == proto.He then
        pos = self.heGuangButton.localPosition
    end

    clickEffect.localPosition = Vector3(pos.x, pos.y, pos.z)
    clickEffect:SetActive(true)

    self:DelayRun(
        1,
        function()
            clickEffect:SetActive(false)
            table.insert(ClickEffectCache, clickEffect)
        end
    )
end

function MiniLHDView:getClickEffectNode()
    local clickEffect

    if #ClickEffectCache > 0 then
        clickEffect = table.remove(ClickEffectCache)
        clickEffect:SetParent(self.clickEffectParent, false)
        clickEffect.localPosition = Vector3(0, 0, 0)
    else
        clickEffect = CC.uu.UguiAddChild(self.clickEffectParent, self.clickEffect)
    end

    return clickEffect
end

function MiniLHDView:getMyAllBet()
    return self.myPlaceBets[proto.Long] + self.myPlaceBets[proto.Hu] + self.myPlaceBets[proto.He]
end

--重置我的下注额
function MiniLHDView:resetMyBets()
    self.myPlaceBets = {}
    self.myPlaceBets[proto.Long] = 0
    self.myPlaceBets[proto.Hu] = 0
    self.myPlaceBets[proto.He] = 0
end

-- 重置别人上次的下注额
function MiniLHDView:resetOtherLastBets()
    OtherLastBets = {}
    OtherLastBets[proto.Long] = 0
    OtherLastBets[proto.Hu] = 0
    OtherLastBets[proto.He] = 0
end

function MiniLHDView:resetBetInfo()
    BetInfo = {}
    BetInfo[proto.Long] = 0
    BetInfo[proto.Hu] = 0
    BetInfo[proto.He] = 0

    -- 别人下注的值
    RandomBetTables.otherBetStats = {}
    -- 飘的次数
    RandomBetTables.countTimes = {}
    -- 分三次加，用作显示的值
    RandomBetTables.areasLastBets = {}
    -- 初始化
    for i = 1, 3 do
        RandomBetTables.otherBetStats[i] = 0
        RandomBetTables.countTimes[i] = 0
        RandomBetTables.areasLastBets[i] = 0
        BetInfo[i] = 0
    end
end

--高亮牌桌下注区域
function MiniLHDView:highLightBetAreaEffect(area, times)
    -- 闪 times 次
    if times then
        times = times - 1
        self:highLightBetAreaEffectActinon(area)

        self:StartTimer(
            HIGHLIGHT_TIMER,
            0.7,
            function()
                times = times - 1
                self:highLightBetAreaEffectActinon(area)
                if times == 0 then
                    self:StopTimer(HIGHLIGHT_TIMER)
                end
            end,
            -1
        )
    else
        self:highLightBetAreaEffectActinon(area)
    end
end

function MiniLHDView:highLightBetAreaEffectActinon(area)
    self.betGuangImages[area]:SetActive(false)
    self.betGuangImages[area]:SetActive(true)
end

function MiniLHDView:betAreaEffect(show)
    for _, betGuangImage in ipairs(self.betGuangImages) do
        betGuangImage:SetActive(show)
    end
end

--下一局通知
function MiniLHDView:handleNewRound(sCNextRound)
    -- 重置
    self:resetForNewRound(sCNextRound.roundName)
    self:setStateText(MNLHDConfig.GAME_STATE["DealCards"])

    -- 动效完成
    local effectFinish = function()
        -- 状态文字
        self:setStateText(proto.Betting)
        -- 开始计时
        self:refreshCountDown(sCNextRound.timeLeft - 4, proto.Betting)

        -- 动效完成才允许下注
        self.viewCtr:setGameState(proto.Betting)
    end
    -- 设置剩牌
    self:setCardsNum(sCNextRound.cardLeft, sCNextRound.dropCard)
    -- 显示开始动效
    self:showStartBetAni(effectFinish)
end

function MiniLHDView:resetForNewRound(roundName)
    -- 重置结果
    self.sCGameResult = nil
    -- 下注高亮区域隐藏
    self:betAreaEffect(false)
    -- 隐藏和赢
    self:hideHeWinEffect()
    -- 牌重置
    self:resetCards()
    -- 重置我的下注值
    self:resetMyBets()
    -- 重置别人上次的下注值
    self:resetOtherLastBets()
    -- 重置所有下注信息
    self:resetBetInfo()
    -- 初始化下注Text
    self:resetBetText()
    -- 收回筹码
    self:resetBetAniNodes()
    -- 场次ID
    self:setRoomId(roundName)

    -- 重置牌局
    if roundName == 1 then
        -- 重置历史
        self:resetRecentlyHistroy()
    end
end

function MiniLHDView:showStartBetAni(finish)
    self.betingTimerLeft = 0

    self.faCard:SetActive(true)

    self:StartTimer(
        BETING_TIMER,
        1,
        function()
            self.betingTimerLeft = self.betingTimerLeft + 1
            if self.betingTimerLeft == 1 then --第2s  播龙虎VS特效
                -- self.betAniEffect:SetActive(true)
                -- self:playSound("startBet")
                self:setStateText(MNLHDConfig.GAME_STATE["Ready"])
                self:showVsEffect()
            elseif self.betingTimerLeft == 3 then --第4s 播完特效，高亮下注区域
                self:betAreaEffect(true)
                -- self.betAniEffect:SetActive(false)
                self:StopTimer(BETING_TIMER)
                finish()
            end
        end,
        -1
    )
end

function MiniLHDView:hideKaiCard()
    self.longCardKai:SetActive(false)
    self.huCardKai:SetActive(false)

    self.huCardKai:FindChild("pai1/dian"):SetActive(false)
    self.huCardKai:FindChild("pai1/hua"):SetActive(false)
    self.huCardKai:FindChild("pai1/tu1"):SetActive(false)
    self.huCardKai:FindChild("pai1/tu2"):SetActive(false)

    self.longCardKai:FindChild("pai1/dian"):SetActive(false)
    self.longCardKai:FindChild("pai1/hua"):SetActive(false)
    self.longCardKai:FindChild("pai1/tu1"):SetActive(false)
    self.longCardKai:FindChild("pai1/tu2"):SetActive(false)
end

function MiniLHDView:resetCards()
    self:hideKaiCard()

    self:showCrad(self.shouCard:FindChild("pai"), self.longCard)
    self:showCrad(self.shouCard:FindChild("pai1"), self.huCard)
    self.shouCard:SetActive(false)
    self.shouCard:SetActive(true)

    -- 收完牌就隐藏
    self:DelayRun(
        0.3,
        function()
            self.shouCard:SetActive(false)
        end
    )
end

function MiniLHDView:showDealCards()
    self:hideKaiCard()
    self.faCard:SetActive(true)
end

function MiniLHDView:numberChangeAction(node)
    self:RunAction(
        node,
        {{"scaleTo", 2, 2, 0.15, ease = CC.Action.EOutBack}, {"scaleTo", 1, 1, 0.15, ease = CC.Action.EOutBack}}
    )
end

function MiniLHDView:showCrad(node, artID)
    local dianShu = math.floor(artID / 4) + 1
    local huaSe = artID % 4

    local dianShuImage
    local huaSeImage
    local huaSeImageBig

    if huaSe == 1 then --方块
        dianShuImage = dianShu .. "_2"
        huaSeImage = "fk"
        huaSeImageBig = "fk"
    elseif huaSe == 2 then --梅花
        dianShuImage = dianShu .. ""
        huaSeImage = "meihua"
        huaSeImageBig = "meihua"
    elseif huaSe == 0 then --红桃
        dianShuImage = dianShu .. "_2"
        huaSeImage = "hx"
        huaSeImageBig = "hx"
    else --黑桃
        dianShuImage = dianShu .. ""
        huaSeImage = "heitao"
        huaSeImageBig = "heitao"
    end

    local isBig = false
    if dianShu > 10 and dianShu < 14 then
        huaSeImageBig = "tu_" .. dianShuImage
        isBig = true
    end
    local dianNode = node:FindChild("dian")
    self:SetImage(dianNode, "lhdCard_" .. dianShuImage)
    local huaNode = node:FindChild("hua")
    self:SetImage(huaNode, "lhdCard_" .. huaSeImage)
    local tu1Node = node:FindChild("tu1")
    local tu2Node = node:FindChild("tu2")
    if isBig then
        self:SetImage(tu1Node, "lhdCard_" .. huaSeImageBig)
        tu1Node:GetComponent("Image"):SetNativeSize()
    else
        self:SetImage(tu2Node, "lhdCard_" .. huaSeImageBig)
        tu2Node:GetComponent("Image"):SetNativeSize()
    end

    dianNode:SetActive(true)
    huaNode:SetActive(true)
    tu1Node:SetActive(isBig)
    tu2Node:SetActive(not isBig)

    node:SetActive(true)
end

-------------------------------
-- 点击毁注
-------------------------------
function MiniLHDView:onRevokeBetClick()
    self.viewCtr:revokeBet()
end

----------------------------------------------------路数图------------------------------------------------
-------------------------------
-- 路数图显示效果1
-------------------------------
function MiniLHDView:onTopBtnClick()
    if not ShowTop then
        ShowTop = true
        self:refreshAllHistoryNodes()
    end
end

-------------------------------
-- 路数图显示效果2
-------------------------------
function MiniLHDView:onBottomBtnClick()
    if ShowTop then
        ShowTop = false
        self:refreshBrokenHistoryNodes()
    end
end

-------------------------------
-- 隐藏所有节点
-------------------------------
function MiniLHDView:hideNodes()
    for i, v in ipairs(self.historyNodes) do
        v:SetActive(false)
    end
end

-------------------------------
-- 结果出现次数统计
-------------------------------
function MiniLHDView:updateHistoryText()
    local long = 0
    local he = 0
    local hu = 0
    for i, result in ipairs(RecentlyHistorys) do
        if result == proto.Long then
            long = long + 1
        elseif result == proto.Hu then
            hu = hu + 1
        elseif result == proto.He then
            he = he + 1
        end
    end

    self.longText.color = Color(1, 1, 1, 1)
    self.huText.color = Color(1, 1, 1, 1)
    self.heText.color = Color(1, 1, 1, 1)
    self.longText.text = string.format("<color=#0F5BC3>มังกร %s</color>", long)
    self.huText.text = string.format("<color=#BF280F>เสือ %s</color>", hu)
    self.heText.text = string.format("<color=#1A7F02>เสมอ %s</color>", he)
end

function MiniLHDView:resetRecentlyHistroy()
    -- body
    RecentlyHistorys = {}
    self:updateHistoryText()
    if ShowTop then
        self:refreshAllHistoryNodes()
    else
        self:refreshBrokenHistoryNodes()
    end
end

function MiniLHDView:updateRecentlyHistroy(results)
    RecentlyHistorys = results
    ShowTop = true
    self:updateHistoryText()
    self:refreshAllHistoryNodes()
end

-----------------------------------
-- 新的结果出现时，重新绘制
-----------------------------------
function MiniLHDView:insertHistory(result)
    if #RecentlyHistorys == 198 then
        table.remove(RecentlyHistorys, 1)
    end
    table.insert(RecentlyHistorys, result)
    self:updateHistoryText()
    if ShowTop then
        self:refreshAllHistoryNodes()
    else
        self:refreshBrokenHistoryNodes()
    end
end

function MiniLHDView:refreshAllHistoryNodes()
    self:hideNodes()

    for i, v in ipairs(RecentlyHistorys) do
        local node = self.historyNodes[i]

        if node then
            self:setHistoryNodeImage(node, v, 2)
        end
    end
end

function MiniLHDView:findNodesUsed(row, column)
    for i, v in ipairs(LineMapPositions) do
        if v.row == row and v.column == column then
            return true
        end
    end

    return false
end

function MiniLHDView:refreshBrokenHistoryNodes()
    self:hideNodes()
    -- 画底部节点
    local locationAreas = proto.InvalidArea
    local drift = false --甩尾
    local column = 0 --列
    local row = 0 --行
    -- 显示的点的位置,重新计算
    LineMapPositions = {}

    -- 重置后，历史为0
    if #RecentlyHistorys == 0 then
        return
    end

    for i, result in ipairs(RecentlyHistorys) do
        -- 起始点为 1 * 1
        if locationAreas == proto.InvalidArea then
            column = 1
            row = 1
        elseif locationAreas == result then
            if row < 6 then
                -- 如果甩尾，则用下一列
                if drift then
                    drift = true
                    column = column + 1
                else
                    -- 如果不甩尾，看下一行是不是被甩尾了，被占用了
                    local used = self:findNodesUsed(row + 1, column)
                    if used then
                        -- 如果被占用，则需要甩尾
                        drift = true
                        column = column + 1
                    else
                        -- 否则继续下一行
                        row = row + 1
                    end
                end
            else
                -- 如果到达6，则甩尾
                drift = true
                column = column + 1
                row = 6
            end
        else
            -- 另外一种结果，重新计算
            drift = false
            local used = self:findNodesUsed(1, column)

            if not used then
                row = 1
            else
                column = column + 1
                row = 1
            end
        end

        local pos = {row = row, column = column, locationAreas = result}
        table.insert(LineMapPositions, pos)
        locationAreas = result
    end

    local len = #LineMapPositions

    -- 最后一个列数，也是最大的
    local maxColumn = LineMapPositions[len].column

    -- 起始列数,下面会做减法，初始值为0
    local minColumn = 0
    if maxColumn > 33 then
        minColumn = maxColumn - 33
    end

    for i, v in ipairs(LineMapPositions) do
        if v.column > minColumn then
            local column = v.column - minColumn
            local pos = (column - 1) * 6 + v.row
            local node = self.historyNodes[pos]

            if node then
                self:setHistoryNodeImage(node, v.locationAreas, 1)
            else
                logger("doesn't has node row = " .. v.row .. " column = " .. v.column)
            end
        end
    end
end

function MiniLHDView:setHistoryNodeImage(node, area, imageIndex)
    node:SetActive(true)
    local imageName = HistoryNodeImageNames[area]
    imageName = imageName .. imageIndex

    if imageName then
        self:SetImage(node, imageName)
    end
end

---------------------------------------------缩小放大-------------------
function MiniLHDView:toWindowsSize()
end

function MiniLHDView:toFullScreenSize()
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

function MiniLHDView:showGain(count)
    if count and count > 0 then
        self.WinEffect:SetActive(true)
    end
    self.AwardText.text = "+" .. CC.uu.ChipFormat(count)

    self:DelayRun(
        3,
        function()
            self.WinEffect:SetActive(false)
            self.AwardText.text = 0
        end
    )
end

return MiniLHDView
