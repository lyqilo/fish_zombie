local CC = require("CC")
local NetworkTools = require("SubGame/NetworkFramework/NetworkTools")
local NetworkManagerBase = require("SubGame/NetworkFramework/NetworkManagerBase")
local M = CC.class2("TCPManagerBase", NetworkManagerBase)

local string_format = string.format
local string_find = string.find
local string_gsub = string.gsub
local logTag = "TCPManagerBase"
local _GetMessageNameKey

function M:ctor(gameProto, messageCenter)
    self.messageCenter = messageCenter

    self.messageNameArray = {}

    self.bIsDiscard = false
end

function M:OnPush(Data, Ops, bForcePush)
    local name = _GetMessageNameKey(self, Ops)
    if not name then 
        logError(string_format("[%s]_OnPush() ops %d not correct", logTag, Ops)) 
        return
    end

    if not self.bIsDiscard or bForcePush then
        local messageName = NetworkTools.GetPushMessageName(name)
        local result = self:MakeMessage(messageName, Data)
        if result then
            if self.bDebug then
                CC.uu.Log(result, string_format("[%s]OnPush %s", logTag, messageName))
            end
            
            self.messageCenter:PostPush(name, result)
        else
            log(string_format("[%s]proto not found:%s", logTag, Ops))
        end
    end
end

_GetMessageNameKey = function(self, ops)
    if self.messageNameArray[ops] then
        return self.messageNameArray[ops]
    end

    for key,value in pairs(self.gameProto) do
        if string_find(key, NetworkTools.PushOpsSuffix) == 1 and ops == value then
            local name = string_gsub(key, NetworkTools.PushOpsSuffix, "")
            self.messageNameArray[ops] = name
            return name
        end
    end
end

return M