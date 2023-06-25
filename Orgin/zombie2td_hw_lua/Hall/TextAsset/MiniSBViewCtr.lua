local CC = require("CC")
local GC = require("GC")
local NetworkManager = require("View/MiniSBView/MiniSBNetwork/NetworkManager")
local MiniSBViewCtr = CC.class2("MiniSBViewCtr")
local Request = require("View/MiniSBView/MiniSBNetwork/Request")
local proto = require("View/MiniSBView/MiniSBNetwork/game_pb")
local MiniSBNotification = require("View/MiniSBView/MiniSBNetwork/MiniSBNotification")
local MNSBConfig = require("View/MiniSBView/MiniSBConfig")
local MiniSBViewManager = require("View/MiniSBView/MiniSBViewManager")

local MiniSBLocalData = require("View/MiniSBView/MiniSBLocalData")

-- function
local unRegisterNotification
local startNetwork
local onNetworkClose
local registerNotification

local ceateSocketSuccessCB
local socketCloseCB
local loginGameWithTokenCB

local handleMsgUpdate
local handleGameResult
local handleNextRound
local refreshMyBet

local Responce = true -- 开关变量，长按时查看服务器是否已经返回

function MiniSBViewCtr:ctor(view, param)
    self.view = view
    self.serverIp = param and param.serverIp
    -- self.serverIp = "172.12.10.68:30001"
    Responce = true

    self.vipBetLimits = {}
    -- 已经下注的信息
    self.betInfo = {}
    self.betInfo.betChip = 0
    self.betInfo.betAreas = proto.InvalidAreas
    -- 当前状态
    self.gameState = proto.Invalid

    -- 临时下注的筹码
    self.tempBetChip = 0
    -- 临时下注的下注选择
    self.tempBetAreas = proto.InvalidAreas

    MiniSBLocalData.Init()
end

function MiniSBViewCtr:OnCreate()
    registerNotification(self)
    startNetwork(self)
end

function MiniSBViewCtr:Destroy()
    NetworkManager.Stop()
    unRegisterNotification(self)

    self.view = nil
end

function MiniSBViewCtr:getGameState()
    return self.gameState
end

function MiniSBViewCtr:getTempBetAreas()
    return self.tempBetAreas
end

function MiniSBViewCtr:clearTempBetChip()
    self.tempBetChip = 0
end

function MiniSBViewCtr:setTempBetChip(tempBetChip)
    -- 不是下注状态
    if self.gameState == proto.HandleResult or self.gameState == proto.Invalid then
        local errStr = MNSBConfig.ERROR_STRING[MNSBConfig.GameLanguage][proto.ErrStateNotMatch]
        CC.ViewManager.ShowTip(errStr)
        return
    end
    local myChip = CC.MiniGameMgr.GetHallChips()
    if tempBetChip > myChip then
        tempBetChip = myChip

        --TODO: POS 事件，让小厅展示 上分效果
        local errStr = MNSBConfig.ERROR_STRING[MNSBConfig.GameLanguage][proto.ErrCoinNotEnough]
        CC.ViewManager.ShowTip(errStr)

        --CC.HallNotificationCenter.inst():post(CC.Notifications.OnMiniGameBetShortage)
    end
    self.tempBetChip = tempBetChip
end

-------------------------------------------------
-- 添加筹码
-------------------------------------------------
function MiniSBViewCtr:addTempBetChip(addChip)
    -- 不是下注状态
    if self.gameState == proto.HandleResult or self.gameState == proto.Invalid then
        local errStr = MNSBConfig.ERROR_STRING[MNSBConfig.GameLanguage][proto.ErrStateNotMatch]
        CC.ViewManager.ShowTip(errStr)
        return
    end
    local chip = self.tempBetChip + addChip
    local myChip = CC.MiniGameMgr.GetHallChips()
    if chip > myChip then
        local errStr = MNSBConfig.ERROR_STRING[MNSBConfig.GameLanguage][proto.ErrCoinNotEnough]
        CC.ViewManager.ShowTip(errStr)

        --TODO: POS 事件，让小厅展示 上分效果
        --CC.HallNotificationCenter.inst():post(CC.Notifications.OnMiniGameBetShortage)
        chip = myChip
    end
    self.tempBetChip = chip
end

function MiniSBViewCtr:getTempBetChip()
    return self.tempBetChip
end

-------------------------------------------------
--注册通知
-------------------------------------------------
registerNotification = function(self)
    MiniSBNotification.GameRegister(
        self,
        "CreateSocketSuccess",
        function()
            ceateSocketSuccessCB(self)
        end
    )
    MiniSBNotification.GameRegister(self, "NetworkClose", socketCloseCB)
    MiniSBNotification.GameRegister(self, "ServerClose", onNetworkClose)
    MiniSBNotification.GameRegister(self, "SCUpdate", handleMsgUpdate)
    MiniSBNotification.GameRegister(self, "SCGameResult", handleGameResult)
    MiniSBNotification.GameRegister(self, "SCNextRound", handleNextRound)
end

-------------------------------------------------
--取消通知
-------------------------------------------------
unRegisterNotification = function(self)
    MiniSBNotification.GameUnregisterAll(self)
    MiniSBNotification.NetworkUnregisterAll(self)
end

function MiniSBViewCtr:onLineHistoryBtnClick()
    local cb = function(err, data)
        if err == proto.ErrSuccess then
            -- log(CC.uu.Dump(data, "LoadGameResultHistory rep =", 3))
            local view =
                MiniSBViewManager.OpenView(
                "MiniSBLineHistoryView",
                self.view.subViewParent,
                {mainView = self.view, history = data}
            )
            self.view.childViews["MiniSBLineHistoryView"] = view
        else
            log("LoadGameResultHistory err = " .. err)
        end
    end
    Request.LoadGameResultHistory(0, 20, cb)
end

-------------------------------------------------
--押大或押小
-------------------------------------------------
function MiniSBViewCtr:changeTempBetAreas(tempBetAreas)
    local success = false
    -- 还未确定下注，或者下注的是同一个区域 下注区域可以变,临时筹码变为0
    if self.betInfo.betAreas == proto.InvalidAreas or self.betInfo.betAreas == tempBetAreas then
        -- self.tempBetChip = 0
        self.tempBetAreas = tempBetAreas
        success = true
    end

    return success
end

-------------------------------------------------
--下注
-------------------------------------------------
function MiniSBViewCtr:sendBet2Server()
    if not Responce then
        log("前个下注尚未回复")
        return
    end
    -- 不是下注状态
    if self.gameState == proto.HandleResult or self.gameState == proto.Invalid then
        local errStr = MNSBConfig.ERROR_STRING[MNSBConfig.GameLanguage][proto.ErrStateNotMatch]
        CC.ViewManager.ShowTip(errStr)
        return
    end

    if self.tempBetChip < 1000 then
        local errStr = MNSBConfig.LOCAL_TIPS_STR[MNSBConfig.GameLanguage]["lessThen1K"]
        CC.ViewManager.ShowTip(errStr)
        return
    end

    local myChip = CC.MiniGameMgr.GetHallChips()
    if self.tempBetChip > myChip then
        local errStr = MNSBConfig.ERROR_STRING[MNSBConfig.GameLanguage][proto.ErrCoinNotEnough]
        CC.ViewManager.ShowTip(errStr)
        --CC.HallNotificationCenter.inst():post(CC.Notifications.OnMiniGameBetShortage)
        return
    end

    local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level") + 1 --vip等级 0 对应数组vipBetLimits 第一个元素 所以要加1
    if vipLevel == 1 then
        -- CC.HallNotificationCenter.inst():post(CC.Notifications.OnMiniGameNotVip, MNSBConfig.GameId)
        local errStr = MNSBConfig.LOCAL_TIPS_STR[MNSBConfig.GameLanguage]["pleaseBuyVip"]
        CC.ViewManager.ShowTip(errStr)
        return
    end
    local limitVa = -1
    if vipLevel <= #self.vipBetLimits then
        limitVa = self.vipBetLimits[vipLevel]
    end
    if limitVa >= 0 and (self.tempBetChip > limitVa or self.betInfo.betChip + self.tempBetChip > limitVa) then
        local errStr = MNSBConfig.LOCAL_TIPS_STR[MNSBConfig.GameLanguage]["vipBetLimit"] .. limitVa
        CC.ViewManager.ShowTip(errStr)
        return
    end

    local cb = function(err, data)
        Responce = true
        if err == proto.ErrSuccess then
            self:clearTempBetChip()
            refreshMyBet(self, data.all, data.areas)
        else
            log("sendBet2Server err = " .. err)
        end
    end
    Responce = false
    Request.Bet(self.tempBetChip, self.tempBetAreas, cb)
end

function MiniSBViewCtr:testBet(areas, count)
    log("testBet     areas =  " .. areas .. ", count = " .. count)
    local cb = function(err, data)
        if err == proto.ErrSuccess then
            self:clearTempBetChip()
            refreshMyBet(self, data.all, data.areas)
        else
            log("sendBet2Server err = " .. err)
        end
    end
    Request.Bet(count, areas, cb)
end

-------------------------------------------------
--毁注 ，策划说不能毁注了
-------------------------------------------------
function MiniSBViewCtr:revokeBet()
    -- 还没下注，不用向服务器发毁注
    -- if self.betInfo.betAreas == proto.InvalidAreas then
    --     self:revokeBetCB()
    -- else
    --     local cb = function(err, data)
    --         if err ~= proto.ErrSuccess then
    --             log("revokeBet err = " .. err)
    --         else
    --             self:revokeBetCB()
    --         end
    --     end
    --     Request.RevokeBet(cb)
    -- end

    self:revokeBetCB()
end

function MiniSBViewCtr:revokeBetCB()
    -- 毁注成功, 重置状态
    -- self.tempBetAreas = proto.InvalidAreas
    self.tempBetChip = 0

    -- refreshMyBet(self, 0, proto.InvalidAreas)

    self.view:revokeSuccess()
end

-------------------------------------------------
-- 连接Socket成功
-------------------------------------------------
ceateSocketSuccessCB = function(self)
    local taken = GC.Player.Inst():GetLoginInfo()
    -- 登录
    Request.LoginWithToken(
        taken.PlayerId,
        taken.Token,
        function(err, data)
            loginGameWithTokenCB(self, data)
        end
    )
end

-------------------------------------------------
-- 登录成功
-------------------------------------------------
loginGameWithTokenCB = function(self, loginData)
    -- 登录成功后，拉取聊天，因为默认打开聊天
    if self.view.chatView then
        self.view.chatView:queryChatHistory()
    end

    log(CC.uu.Dump(loginData, "loginData =", 10))

    self.gameState = proto.Invalid --重连的时候 先重置这个状态 确保后面能重新倒计时

    --下注限制
    self.vipBetLimits = loginData.vipBetLimits
    --最近15局大小情况
    self.historyAreas = loginData.historyAreas
    self.view:refreshRoundHistory(loginData.historyAreas)
    --连胜连败纪录
    self.view:refreshStreakInfo(loginData.winStreak, loginData.losStreak, true, 0)

    -- 是否隐藏连胜记录节点
    self.view:setStreakInfoViewState(loginData.isLongphongFull)

    -- 房号
    local roomId = loginData.numOfGame
    self.view:setRoomId("#" .. roomId)

    -- 下注状态，并且有下注
    if loginData.myBet > 0 and loginData.myAreas > 0 then
        refreshMyBet(self, loginData.myBet, loginData.myAreas)
    end

    -- 结算状态
    if loginData.update.state == proto.HandleResult then
        local result = loginData.result
        local myGain = loginData.myGain
        self.view:showResultFormLogin(result, myGain)
    end

    handleMsgUpdate(self, loginData.update)
    Responce = true
end

socketCloseCB = function(self)
    log("socketCloseCB server close----------------")
    -- CC.ViewManager.ShowConfirmBox(
    --     "พารามิเตอร์ผิดพลาด",
    --     function()
    --         self.view:Destroy()
    --     end
    -- )
end

-------------------------------------------------
-- 刷新我的下注信息
-------------------------------------------------
refreshMyBet = function(self, betChip, betAreas)
    self.betInfo.betChip = betChip
    self.betInfo.betAreas = betAreas

    CC.MiniGameMgr.SetMiniGameBet(MNSBConfig.GameId, betChip)

    -- 如果不是初始化状态，则去刷新界面
    if betAreas ~= proto.InvalidAreas then
        self.view:setBetChipText(betChip, betAreas)
    end
end
-------------------------------------------------
-- 处理下注信息刷新
-------------------------------------------------
handleMsgUpdate = function(self, sCUpdate)
    self.sCUpdate = sCUpdate
    --刷新界面信息 data (SCUpdate)
    -- 如果状态切换，则重新计时
    if self.gameState ~= sCUpdate.state then
        local timeLeft = sCUpdate.timeLeft
        self.view:refreshCountDown(timeLeft, sCUpdate.state)
    end
    self.gameState = sCUpdate.state

    -- 刷新面板
    self.view:refreshPanel(sCUpdate)
end

-------------------------------------------------
-- 处理游戏结果
-------------------------------------------------
handleGameResult = function(self, sCGameResult)
    -- log(CC.uu.Dump(sCGameResult, "gameResult =", 10))
    --修改游戏状态
    self.gameState = proto.HandleResult
    -- 结算持续时间
    local timeLeft = sCGameResult.timeLeft
    self.view:refreshCountDown(timeLeft, self.gameState)

    refreshMyBet(self, 0, proto.InvalidAreas)

    -- 更新路数数据  (用这个数据刷新界面)
    if #self.historyAreas == 15 then
        table.remove(self.historyAreas, 1)
    end
    table.insert(self.historyAreas, sCGameResult.result.locationAreas)

    -- 显示骰子，高亮闪烁赢的区域，闪烁，显示值
    self.view:showResult(sCGameResult)
end

-------------------------------------------------
-- 新游戏开局
-------------------------------------------------
handleNextRound = function(self, sCNextRound)
    -- log(CC.uu.Dump(sCNextRound, "handleNextRound =", 10))
    Responce = true
    self.view:setRoomId("#" .. sCNextRound.roundID)

    -- 清除状态
    self.view:handleNewRound(sCNextRound)

    refreshMyBet(self, 0, proto.InvalidAreas)

    -- 刷新界面 把之前的SCUpdate再刷一遍 但是要改状态
    self.sCUpdate.timeLeft = sCNextRound.timeLeft
    self.sCUpdate.state = proto.Betting
    self.sCUpdate.bigAreaValue = 0
    self.sCUpdate.smallAreaValue = 0
    self.sCUpdate.bigAreaPlayerNum = 0
    self.sCUpdate.smallAreaPlayerNum = 0
    handleMsgUpdate(self, self.sCUpdate)
end

startNetwork = function(self)
    local data = {
        serverIp = self.serverIp
    }
    NetworkManager.Start(data)
end

onNetworkClose = function(self)
    self.view:Destroy()
end

return MiniSBViewCtr
