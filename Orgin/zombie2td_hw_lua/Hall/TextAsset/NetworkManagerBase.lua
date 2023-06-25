--------------------------------------------
--@Description:
--@Author: Xie Ling Yun
--------------------------------------------

local CC = require("CC")
local NetworkTools = require("SubGame/NetworkFramework/NetworkTools")
local M = CC.class2("NetworkManagerBase")

function M:ctor(gameProto)
    self.bDebug = false
    self.gameProto = gameProto
    self.hallProto = CC.proto
    self.comsumeRecordArray = {}
    self.nConsumeCount = 1
end

function M:Destroy()
end

function M:MakeMessage(name, buff)
    local msg = self.gameProto[name] or self.hallProto.client_pb[name]
    if msg == nil then
        if self.bDebug then
            log("[NetworkManagerBase]Proto not found：" .. name)
        end
	else
		msg = msg()
		if buff and buff ~= "" then
            msg:ParseFromString(buff)
        end
    end
	return msg
end

function M:MakeCSMessage(name, buff)
    local messageName = NetworkTools.GetReqMessageName(name)
    return self:MakeMessage(messageName, buff)
end

function M:GetResponseNotificationName(name)
    local key = NetworkTools.GetRspMessageName(name)
    return self.networkLocalNotifications[key]
end

function M:GetPushNotificationName(name)
    local key = NetworkTools.GetPushMessageName(name)
    return self.networkLocalNotifications[key]
end

function M:GetRequestOps(name)
    name = NetworkTools.ReqOpsSuffix..name
    return self.gameProto[name]
end

function M:GetHttpRequestOps(name)
    return self.gameProto[name]
end

function M:GetRequestMsg(name)
    local msg = self.gameProto[name]
    if msg == nil then
        logError("pb not found:" .. name)
        return
    end
    return msg()
end

function M:GetTimeConsumeKey(name)
    name = string.format("Consume_%s_%d", name, self.nConsumeCount)
    self.nConsumeCount = self.nConsumeCount+1
    if self.nConsumeCount > 10000 then
        self.nConsumeCount = 1
    end
    return name
end

function M:SetDebug(status)
    self.bDebug = status
end

return M