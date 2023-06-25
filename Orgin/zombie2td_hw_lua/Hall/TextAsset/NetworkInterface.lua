local CC = require("CC")
local NetworkMessageCenter = require("SubGame/NetworkFramework/NetworkMessageCenter")
local TCPManager = require("SubGame/NetworkFramework/TCPManager")
local HallMsgManager = require("SubGame/NetworkFramework/HallMsgManager")
local HttpManager = require("SubGame/NetworkFramework/HttpManager")
local M = CC.class2("NetworkInterface")

function M:ctor(gameId, gameProto)
    local gameServerTag = "Tag_"..gameId
    self.messageCenter = NetworkMessageCenter.new(gameServerTag, gameProto)
    self.tcpManager = TCPManager.new(gameProto, self.messageCenter, gameServerTag)
    self.hallMsgManager = HallMsgManager.new(gameProto, self.messageCenter, gameId)
    self.httpManager = HttpManager.new(gameProto, self.messageCenter)
end

function M:Destroy()
    self.tcpManager:Destroy()
    self.hallMsgManager:Destroy()
    self.httpManager:Destroy()
end

function M:Init(param)
    param = param or {}
    if param.launcherType == "WebSocket" then
        self.tcpManager:SetLauncher(IO.WebSocketLauncher)
    end

    if param.bAutoReconnect ~= nil then
        self.tcpManager:SetAutoReconnect(param.bAutoReconnect)
    end

    if param.nTryTimes then
        self.tcpManager:SetReconnectTryTimes(param.nTryTimes)
    end

    if param.nTimeout then
        self.tcpManager:SetTimeoutTime(param.nTimeout)
    end

    if param.nDisconnect then
        self.tcpManager:SetDisconnectTime(param.nDisconnect)
    end

    if param.bNeedCheckLag ~= nil then
        self.tcpManager:SetNeedCheckLag(param.bNeedCheckLag)
    end

    if param.fShowWaitingFunc then
        self.tcpManager:SetShowWaitingFunc(param.fShowWaitingFunc)
    end

    if param.bDebug ~= nil then
        self.tcpManager:SetDebug(param.bDebug)
        self.httpManager:SetDebug(param.bDebug)
    end

    if param.requestMessageName ~= nil then
        self.tcpManager:SetRequestMessageName(param.requestMessageName)
    end

    if param.pushMessageName ~= nil then
        self.tcpManager:SetPushMessageName(param.pushMessageName)
    end
end

function M:StartTcp(serverAddress)
    self.tcpManager:Start(serverAddress)
end

function M:StopTcp()
    self.tcpManager:Stop()
end

function M:ReconnectTcp()
    self.tcpManager:Reconnect()
end

local MakeReqData = function(name, dataOrFunc, networkManager)
    local req
    if CC.uu.isFunction(dataOrFunc) then
        req = networkManager:MakeCSMessage(name)
        req = dataOrFunc(req)
    elseif CC.uu.isTable(dataOrFunc) and not dataOrFunc._fields then
        req = networkManager:MakeCSMessage(name)
        for k,v in pairs(dataOrFunc) do
            if CC.uu.isTable(v) then
                for _,value in pairs(v) do
                    table.insert(req[k], value)
                end
            else
                req[k] = v
            end
        end
    else
        req = dataOrFunc
    end

    return req
end

function M:RequestByTcp(messageName, dataOrFunc, ...)
    local req = MakeReqData(messageName, dataOrFunc, self.tcpManager)
    self.tcpManager:Request(messageName, req, unpack({...}))
end

function M:GetNotificationCenter()
    return self.messageCenter:GetNotificationCenter()
end

function M:GetLocalNotification()
    return self.messageCenter:GetLocalNotification()
end

function M:GetGameServerTag()
    return self.tcpManager:GetGameServerTag()
end

function M:GetLauncher()
    return self.tcpManager:GetLauncher()
end

function M:RequestJsonByHttpPost(name, dataOrFunc, url)
    self.httpManager:HttpRequestJsonWithJson(name, dataOrFunc, url)
end

function M:RequestJsonByHttpPostWithProto(name, dataOrFunc, url)
    local req = MakeReqData(name, dataOrFunc, self.httpManager)
    self.httpManager:HttpRequestJsonWithProto(name, req, url)
end

function M:RequestProtoByHttpPost(name, makeReqFunc, url)
    local req = MakeReqData(name, makeReqFunc, self.httpManager)
    
    self.httpManager:HttpRequestProtoWithProto(name, req, url)
end


return M