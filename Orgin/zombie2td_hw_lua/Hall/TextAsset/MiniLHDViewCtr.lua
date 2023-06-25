local CC = require("CC")
local GC = require("GC")
local NetworkManager = require("View/MiniLHDView/MiniLHDNetwork/MiniLHDNetworkManager")
local MiniLHDViewCtr = CC.class2("MiniLHDViewCtr")
local Request = require("View/MiniLHDView/MiniLHDNetwork/MiniLHDRequest")
local proto = require("View/MiniLHDView/MiniLHDNetwork/game_pb")
local MiniLHDNotification = require("View/MiniLHDView/MiniLHDNetwork/MiniLHDNotification")
local MNLHDConfig = require("View/MiniLHDView/MiniLHDConfig")

local MiniLHDLocalData = require("View/MiniLHDView/MiniLHDLocalData")

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

function MiniLHDViewCtr:ctor(view, param)
    Responce = true
    self.view = view
    self.serverIp = param and param.serverIp
    -- self.serverIp = "172.12.10.68:30201"

    self.vipBetLimits = {}
    -- 当前状态
    self.gameState = proto.Invalid

    -- 下注状态
    self.hasBet = false
    self.betInfo = {}
    self.betInfo[proto.Long] = 0
    self.betInfo[proto.Hu] = 0
    self.betInfo[proto.He] = 0

    -- 下注区域，龙虎只能压一个，不包括 和
    self.betArea = proto.Invalid
    MiniLHDLocalData.Init()
end

function MiniLHDViewCtr:OnCreate()
    registerNotification(self)
    startNetwork(self)
end

function MiniLHDViewCtr:Destroy()
    NetworkManager.Stop()
    unRegisterNotification(self)

    self.view = nil
end

function MiniLHDViewCtr:getGameState()
    return self.gameState
end

function MiniLHDViewCtr:setGameState(gameState)
    self.gameState = gameState
end

-------------------------------------------------
--注册通知
-------------------------------------------------

registerNotification = function(self)
    MiniLHDNotification.GameRegister(self, "CreateSocketSuccess", ceateSocketSuccessCB)
    MiniLHDNotification.GameRegister(self, "NetworkClose", socketCloseCB)
    MiniLHDNotification.GameRegister(self, "ServerClose", onNetworkClose)
    MiniLHDNotification.GameRegister(self, "SCUpdate", handleMsgUpdate)
    MiniLHDNotification.GameRegister(self, "SCGameResult", handleGameResult)
    MiniLHDNotification.GameRegister(self, "SCNextRound", handleNextRound)
end

-------------------------------------------------
--取消通知
-------------------------------------------------
unRegisterNotification = function(self)
    MiniLHDNotification.GameUnregisterAll(self)
    MiniLHDNotification.NetworkUnregisterAll(self)
end

function MiniLHDViewCtr:sendBetFromDebug(betChip, betArea)
    local cb = function(err, data)
        Responce = true
        if err == 0 then
            self.hasBet = true
            self.view:showClickEffect(betArea)
            refreshMyBet(self, data.allBet, data.placeBet.area)
        else
            log("sendBetFromDebug err = " .. err)
        end
    end
    Responce = false
    Request.Bet(betChip, betArea, cb)
end

-------------------------------------------------
--下注
-------------------------------------------------
function MiniLHDViewCtr:sendBet2Server(betChip, betArea)
    if not Responce then
        log("前个下注尚未回复")
        return
    end
    -- 不是下注状态
    if self.gameState == proto.HandleResult or self.gameState == proto.Invalid then
        -- local errStr = MNLHDConfig.ERROR_STRING[MNLHDConfig.GameLanguage][proto.ErrStateNotMatch]
        -- CC.ViewManager.ShowTip(errStr)
        return
    end

    -- 不可同时下注龙和虎
    if self.betArea ~= proto.Invalid and self.betArea ~= betArea and betArea ~= proto.He then
        local errStr = MNLHDConfig.LOCAL_ERR_STR[MNLHDConfig.GameLanguage]["sametimeError"]
        CC.ViewManager.ShowTip(errStr)
        return
    end

    local myChip = CC.MiniGameMgr.GetHallChips()
    if betChip > myChip then
        --TODO: POS 事件，让小厅展示 上分效果
        -- local errStr = MNLHDConfig.ERROR_STRING[MNLHDConfig.GameLanguage][proto.ErrCoinNotEnough]
        -- CC.ViewManager.ShowTip(errStr)
        -- CC.HallNotificationCenter.inst():post(CC.Notifications.OnMiniGameBetShortage)
        return
    end

    local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level") + 1 --vip等级 0 对应数组vipBetLimits 第一个元素 所以要加1
    if vipLevel == 1 then
        local errStr = MNLHDConfig.LOCAL_TIPS_STR[MNLHDConfig.GameLanguage]["pleaseBuyVip"]
        CC.ViewManager.ShowTip(errStr)
        return
    end
    local limitVa = -1
    if vipLevel <= #self.vipBetLimits then
        limitVa = self.vipBetLimits[vipLevel]
    end
    local tempBetChip = self.betInfo[betArea] + betChip
    if limitVa >= 0 and tempBetChip > limitVa then
        local errStr = MNLHDConfig.LOCAL_TIPS_STR[MNLHDConfig.GameLanguage]["vipBetLimit"] .. limitVa
        CC.ViewManager.ShowTip(errStr)
        return
    end

    local cb = function(err, data)
        Responce = true
        if err == 0 then
            self.hasBet = true
            self.view:showClickEffect(betArea)
            refreshMyBet(self, data.allBet, data.placeBet.area)
        else
            log("sendBet2Server err = " .. err)
        end
    end
    Responce = false
    Request.Bet(betChip, betArea, cb)
end

-------------------------------------------------
--毁注
-------------------------------------------------
function MiniLHDViewCtr:revokeBet()
    -- 还没下注，不用向服务器发毁注
    if self.gameState == proto.HandleResult then
        log("结算阶段，不可毁注")
        return
    end
    if self.hasBet == false then
        log("未下注，不可毁注")
        return
    end

    local cb = function(err, data)
        if err ~= 0 then
            log("revokeBet err = " .. err)
        else
            self:revokeBetCB(data)
        end
    end
    Request.RevokeBet(cb)
end

function MiniLHDViewCtr:revokeBetCB(data)
    -- 毁注成功, 重置状态
    self.hasBet = false
    self.betArea = proto.Invalid
    self.betInfo[proto.Long] = 0
    self.betInfo[proto.Hu] = 0
    self.betInfo[proto.He] = 0

    CC.MiniGameMgr.SetMiniGameBet(MNLHDConfig.GameId, 0)
    self.view:revokeSuccess(data)
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
    -- log(CC.uu.Dump(loginData, "+++++++++++++++++++loginData =", 10))

    -- 登录成功后，拉取聊天，因为默认打开聊天
    if self.view.chatView then
        self.view.chatView:queryChatHistory()
    end

    --下注限制
    self.vipBetLimits = loginData.vipBetLimits

    self.view:updateRecentlyHistroy(loginData.results)
    self.gameState = proto.Invalid --重连的时候 先重置这个状态 确保后面能重新倒计时

    -- 场次ID
    self.view:setRoomId(loginData.roundName)

    -- 回复我的下注额
    self.view:setPlaceBets(loginData.placeBets) --设置我的下注额
    if loginData.placeBets then
        for _, placeBet in ipairs(loginData.placeBets) do
            if placeBet.betValue > 0 then
                self.betInfo[placeBet.area] = placeBet.betValue
            end
        end
    end

    -- 结算状态
    if loginData.update.state == proto.HandleResult then
        self.view:showResultFormLogin(loginData)
    else
        self.view:showDealCards()
        handleMsgUpdate(self, loginData.update, true)
    end

    --设置剩牌
    self.view:setCardsNum(loginData.cardLeft, loginData.dropCard)
    Responce = true
end

socketCloseCB = function(self)
    log("socketCloseCB server close----------------")
    -- CC.ViewManager.ShowConfirmBox(
    --     "服务器关闭",
    --     function()
    --         self.view:Destroy()
    --     end
    -- )
end

-------------------------------------------------
-- 刷新我的下注信息
-------------------------------------------------
refreshMyBet = function(self, betChip, betArea)
    -- 记录下压龙或者压虎，和不记录
    if betArea == proto.Long or betArea == proto.Hu then
        self.betArea = betArea
    end
    log("刷新下注信息 ", betChip)
    self.betInfo[betArea] = betChip

    self.view:setPlaceBets({{area = betArea, betValue = betChip}})

    local allBet = self.view:getMyAllBet()
    CC.MiniGameMgr.SetMiniGameBet(MNLHDConfig.GameId, allBet)
end
-------------------------------------------------
-- 处理下注信息刷新
-------------------------------------------------
handleMsgUpdate = function(self, sCUpdate, formLogin)
    self.sCUpdate = sCUpdate
    if formLogin then
        self:setGameState(sCUpdate.state)
    end
    -- log(CC.uu.Dump(sCUpdate, "sCUpdate =", 10))
    self.view:refreshPanel(sCUpdate)
end

-------------------------------------------------
-- 处理游戏结果
-------------------------------------------------
handleGameResult = function(self, sCGameResult)
    self:setGameState(proto.HandleResult)

    self.view:showResult(sCGameResult)
end

-------------------------------------------------
-- 新游戏开局
-------------------------------------------------
handleNextRound = function(self, sCNextRound)
    Responce = true
    self.hasBet = false
    self.betArea = proto.InvalidArea
    self.betInfo[proto.Long] = 0
    self.betInfo[proto.Hu] = 0
    self.betInfo[proto.He] = 0
    -- 动画完成才可设置为下注状态
    -- self:setGameState(proto.Betting)
    self.view:handleNewRound(sCNextRound)
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

return MiniLHDViewCtr
