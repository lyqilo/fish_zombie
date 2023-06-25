--------------------------------------------
--@Description: 
--@Author: Xie Ling Yun
--------------------------------------------
local CC = require("CC")
local NetworkTools = require("SubGame/NetworkFramework/NetworkTools")
local TCPManagerBase = require("SubGame/NetworkFramework/TCPManagerBase")
local M = CC.class2("TCPManager", TCPManagerBase)

local string_format = string.format

local logTag = "TCPManager"
local NetState = {
    Origin = 0,
    Ready = 1,
    InGame = 2,
}
M.NetState = NetState

local _OnOpen
local _OnPush
local _OnError
local _OnClose
local _StartReconnet
local _DealConnectException
local _GetTimeoutTimerName
local _GetDisconnectTimerName
local _StartTimeoutTimer
local _StopTimeoutTimer
local _StartDisconnectTimer
local _StopDisconnectTimer
local _ClearAllTimersAndTips
local _StartPingLag
local _StopPingLag
local _UpdatePingLag
local _OnPongLag

-- @gameServerTag. 
function M:ctor(gameProto, messageCenter, gameServerTag)
    self.gameServerTag = gameServerTag

    self.bAutoReconnect = true
    self.nTryTimes = 3
    self.nLeftTryTimes = 0 
    self.bReconnectIng = false 
    self.fShowWaitingFunc = function(status) 
        if status then
            log(string_format("[%s]Waiting...", logTag)) 
        end 
    end
    self.nTimeout = 3*1000
    self.nDisconnect = 20*1000
    self.serverState = NetState.Origin

    self.nTimeoutTimerCount = 1
    self.nDisconnectTimerCount = 1
    self.nConsumeCount = 1
    self.bTimeoutIng = false
    self.timers = {}
    self.serverAddress = nil

    self.nCheckLagInterval = 1
    self.nCheckLagCount = self.nCheckLagInterval
    self.nMaxLagValue = 460
    self.bIsLagging = false
    self.bNeedCheckLag = true

    self.launcher = IO.Launcher
    self.requestMessageName = "Message"
    self.pushMessageName = "Message"
end

function M:Destroy()
    _StopPingLag(self)
    _ClearAllTimersAndTips(self)
    TCPManagerBase.Destroy(self)
end

function M:SetLauncher(launcher)
    self.launcher = launcher
end

function M:GetLauncher()
    return self.launcher
end

function M:GetGameServerTag()
    return self.gameServerTag
end

function M:Start(serverAddress)
    self.serverAddress = serverAddress
    local args = IO.LauncherArgs()
    args.ConnectionStr = serverAddress
    args.AutoReconnectEnabled = false
    log(string_format("[%s]Start() serverAddress=%s, Tag=%s", logTag, serverAddress, self.gameServerTag))
    self.serverState = NetState.Ready
    self.launcher.Start(self.gameServerTag,args,function(itype,msg,data) 
        if itype == "OnOpen" then
            _OnOpen(self)
            _StartPingLag(self)
        elseif itype == "OnPush" then
            _OnPush(self, data)
        elseif itype == "OnClose" then
            _OnClose(self, msg)
            _StopPingLag(self)
        elseif itype == "OnError" then
            _OnError(self, msg)
            _StopPingLag(self)
        end
    end)
end

function M:Stop()
    _StopPingLag(self)
    _ClearAllTimersAndTips(self)
    self.serverAddress = nil
    self.launcher.Stop(self.gameServerTag)
end


function M:Request(name, reqData, ...)
    if self.serverState == NetState.InGame then 
        local extraArg = {...}
        local msg = self:MakeMessage(self.requestMessageName)
        local ops = self:GetRequestOps(name)
        if ops == self.startRequestOps then
            self.bIsDiscard = true
        end
        msg.Ops = ops
        msg.Data = reqData:SerializeToString()
        if self.bDebug then
            CC.uu.Log(reqData, string_format("[%s]req data name=%s", logTag, name))
        end

        local comsumeKey = self:GetTimeConsumeKey(self, name)
        self.comsumeRecordArray[comsumeKey] = os.clock()

        local timeoutTimerName = _StartTimeoutTimer(self, name)
        local disconnectTimerName = _StartDisconnectTimer(self, name)
        local req_send = msg:SerializeToString()
        self.launcher.Request(self.gameServerTag, req_send, function(code, data)
            if self.serverState == NetState.InGame then 
                local t = self.comsumeRecordArray[comsumeKey] - os.clock()
                if self.bDebug then
                    log(string_format("[%s]reqeust %s -> response comsume %dms",logTag,name,t))
                end

                _StopTimeoutTimer(self, timeoutTimerName)
                _StopDisconnectTimer(self, disconnectTimerName, timeoutTimerName)

                if ops == self.startRequestOps then
                    self.bIsDiscard = false
                end

                if not self.bIsDiscard then
                    local rspName = NetworkTools.GetRspMessageName(name)
                    local result = self:MakeMessage(rspName, data)
                    if result then
                        if self.bDebug then
                            CC.uu.Log(result, string_format("[%s]receive data name=%s code=%d", logTag, rspName, code))
                        end
                    else
                        if self.bDebug then
                            log(string_format("[%s]receive data name=%s code=%d", logTag, rspName, code))
                        end
                    end

                    self.messageCenter:PostResponse(name, code, result, unpack(extraArg))
                end
            else
                log(string_format("[%s]socket is disconnect，cannot request %s", logTag, name))
            end
        end)
    else
        log(string_format("[%s]socket is disconnect，cannot request %s", logTag, name))
    end
end

function M:Reconnect()
    if self.serverState == NetState.InGame then
        log(string_format("[%s]socket not disconnect",logTag))
        return
    end
    if self.bAutoReconnect then
        log(string_format("[%s]auto reconenct",logTag))
        return
    end
    if self.bReconnectIng then
        log(string_format("[%s]reconencting",logTag))
        return
    end

    _StartReconnet(self)
end


function M:SetAutoReconnect(status)
    self.bAutoReconnect = status
end


function M:SetReconnectTryTimes(tryTimes)
    self.nTryTimes = tryTimes
end


function M:SetTimeoutTime(n)
    self.nTimeout = n
end


function M:SetDisconnectTime(n)
    self.nDisconnect = n
end


function M:SetShowWaitingFunc(func)
    self.fShowWaitingFunc = func
end


function M:SetNeedCheckLag(status)
    self.bNeedCheckLag = status
end

function M:GetNetState()
    return self.serverState
end

function M:GetServerAddress()
    return self.serverAddress
end

function M:SetRequestMessageName(name)
    self.requestMessageName = name
end

function M:SetPushMessageName(name)
    self.pushMessageName = name
end

_OnOpen = function(self)
    log(string_format("[%s]_OnOpen() Tag=%s", logTag, self.gameServerTag))
    self.serverState = NetState.InGame
    
    local bReconnect = self.bReconnectIng
    if self.bReconnectIng then
        self.fShowWaitingFunc(false)
    end
    self.bReconnectIng = false
    self.nLeftTryTimes = self.nTryTimes
    self.messageCenter:Post("NETWORKOPEN", bReconnect)
end

_OnPush = function(self, data)
    local msg = self:MakeMessage(self.pushMessageName, data)
    self:OnPush(msg.Data, msg.Ops)
end

_OnError = function(self, msg)
    log(string_format("[%s]_OnError() msg=%s", logTag, msg))
    _ClearAllTimersAndTips(self)

    if self.serverState == NetState.Ready then
        self.messageCenter:Post("NETWORKUNDERMAINTANCEN")
    else
        self.serverState = NetState.Origin
        _DealConnectException(self)
    end
end

_OnClose = function(self, msg)
    log(string_format("[%s]_OnClose() msg=%s", logTag, msg))
    _ClearAllTimersAndTips(self)

    self.serverState = NetState.Origin
    if string.lower(msg) == "stop" then
        self.messageCenter:Post("NETWORKCLOSE")
    else
        _DealConnectException(self)
    end
end

_StartReconnet = function(self)
    if self.nLeftTryTimes <= 0 then return end

    log(string_format("[%s]_StartReconnet()", logTag))
    self.fShowWaitingFunc(true)
    self.bReconnectIng = true
    self.nLeftTryTimes = self.nLeftTryTimes - 1
    self.launcher.Reconnect(self.gameServerTag)
end

_DealConnectException = function (self)
    if self.bReconnectIng then
        if self.nLeftTryTimes > 0 then
            log(string_format("[%s]try reconnect，leftTime %d", logTag, self.nLeftTryTimes))
            self.nLeftTryTimes = self.nLeftTryTimes - 1
            self.launcher.Reconnect(self.gameServerTag)
        else
            self.fShowWaitingFunc(false)
            self.bReconnectIng = false
            self.messageCenter:Post("NETWORKCLOSE_RECONNECT")
        end
    else
        if self.bAutoReconnect then
            _StartReconnet(self)
        else
            self.messageCenter:Post("NETWORKDISCONNECT")
        end
    end
end

_GetTimeoutTimerName = function(self, name)
    name = string_format("Timeout_%s_%d", name, self.nTimeoutTimerCount)
    self.nTimeoutTimerCount = self.nTimeoutTimerCount+1
    if self.nTimeoutTimerCount > 10000 then
        self.nTimeoutTimerCount = 1
    end
    return name
end

_GetDisconnectTimerName = function(self, name)
    name = string_format("Disconnect_%s_%d", name, self.nDisconnectTimerCount)
    self.nDisconnectTimerCount = self.nDisconnectTimerCount+1
    if self.nDisconnectTimerCount > 10000 then
        self.nDisconnectTimerCount = 1
    end
    return name
end

_StartTimeoutTimer = function(self, name)
    if self.nTimeout > 0 then
        name = _GetTimeoutTimerName(self, name)
        if self.bDebug then
            log(string_format("[%s]%s startTimer", logTag, name))
        end
        self.timers[name] = CC.uu.StartTimer(self.nTimeout*0.001, function() 
            self.bTimeoutIng = true
            if self.bDebug then
                logError(string_format("[%s]%s timeout, %dms）", logTag, name, self.nTimeout))
            end
            self.fShowWaitingFunc(true) 
        end, 1, false)
        return name
    end
end

_StopTimeoutTimer = function(self, name)
    if self.bTimeoutIng then
        self.bTimeoutIng = false
        self.fShowWaitingFunc(false)
    end
    local co = self.timers[name]
    CC.uu.StopTimer(co)
end

_StartDisconnectTimer = function(self, name)
    if self.nDisconnect > 0 then
        name = _GetDisconnectTimerName(self, name)
        self.timers[name] = CC.uu.StartTimer(self.nDisconnect*0.001, function() 
            if self.bTimeoutIng then
                self.bTimeoutIng = false
                self.fShowWaitingFunc(false)
                self.messageCenter:Post("NETWORKNOTRESPOND")
            end
        end, 1, false)
        return name
    end
end

_StopDisconnectTimer = function(self, disconnectName, timeoutName)
    _StopTimeoutTimer(self, timeoutName)
    local co = self.timers[disconnectName]
    CC.uu.StopTimer(co)
end

_ClearAllTimersAndTips = function(self)
    for _,co in pairs(self.timers) do
        CC.uu.StopTimer(co)
    end
    if self.bTimeoutIng then
        self.bTimeoutIng = false
        self.fShowWaitingFunc(false)
    end
end

_StartPingLag = function(self)
    if self.bIsLagging then
        return
    end

    self.bIsLagging = true
    UpdateBeat:Add(_UpdatePingLag, self)
end

_StopPingLag = function(self)
    self.bIsLagging = false
    UpdateBeat:Remove(_UpdatePingLag, self)
end

_UpdatePingLag = function(self)
    local delta = 1/Application.targetFrameRate*Time.timeScale
    self.nCheckLagCount = self.nCheckLagCount + delta
    if self.nCheckLagCount >= self.nCheckLagInterval then
        self.nCheckLagCount = self.nCheckLagCount - self.nCheckLagInterval
        if self.bNeedCheckLag then
            if self.serverState == NetState.Origin then
                _OnPongLag(self, self.nMaxLagValue)
            else
                self.launcher.Lag(self.gameServerTag, function(value) _OnPongLag(self, value) end)
            end
        end
    end
end

_OnPongLag = function(self, value)
    if self.bDebug then
        if value > 200 then
            log(string_format("[%s]_OnPongLag() lagValue=%dms", logTag, value))
        end
    end
    value = math.min(value, self.nMaxLagValue)
    self.messageCenter:Post("NETWORKUPDATELAG", value)
end

return M


