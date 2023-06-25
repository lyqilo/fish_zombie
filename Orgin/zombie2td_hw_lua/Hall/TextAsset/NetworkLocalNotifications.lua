--[[
@Description: define notification。
@special：
NETWORKOPEN（socket is open）、
NETWORKCLOSE（socket stop by manual stop）、
NETWORKCLOSE_RECONNECT（socket stop, cannot reconnect）、
NETWORKDISCONNECT（socket diconnect, can try reconnect）、
NETWORKNOTRESPOND（）、
NETWORKUNDERMAINTANCEN（）、
NETWORKUPDATELAG（）
@Author: Xie Ling Yun
]]
local CC = require("CC")
local NetworkTools = require("SubGame/NetworkFramework/NetworkTools")
local M = CC.class2("NetworkLocalNotifications")

local _GetNext
local _MakeNotificationDefine

function M:ctor(gameServerTag, gameProto)
    self.nCount = 1
    self.gameServerTag = gameServerTag
    self.gameProto = gameProto
    _MakeNotificationDefine(self)
end

function M:GetEvent(key)
    return self.eventArray[key]
end

_GetNext = function(self)
    local name = string.format("Network_%s_%d", self.gameServerTag, self.nCount)
    self.nCount = self.nCount + 1
    return name
end

_MakeNotificationDefine = function(self)
    self.eventArray = {}

	self.eventArray[NetworkTools.NETWORKOPEN] = _GetNext(self)
    self.eventArray[NetworkTools.NETWORKCLOSE] = _GetNext(self)
    self.eventArray[NetworkTools.NETWORKCLOSE_RECONNECT] = _GetNext(self)
    self.eventArray[NetworkTools.NETWORKDISCONNECT] = _GetNext(self)
    self.eventArray[NetworkTools.NETWORKNOTRESPOND] = _GetNext(self)
    self.eventArray[NetworkTools.NETWORKUNDERMAINTANCEN] = _GetNext(self)
    self.eventArray[NetworkTools.NETWORKUPDATELAG] = _GetNext(self)

    local string_find = string.find
    local string_gsub = string.gsub
    for key,_ in pairs(self.gameProto) do
        if string_find(key, NetworkTools.CSMessageSuffix) == 1 then
            self.eventArray[string_gsub(key, NetworkTools.CSMessageSuffix, NetworkTools.SCRspMessageSuffix)] = _GetNext(self)
        elseif string_find(key, "Req", -3, -1) then
            self.eventArray[NetworkTools.ConvertReqToRsp(key)] = _GetNext(self)
        elseif string_find(key, NetworkTools.SCPushMessageSuffix) == 1 then
            self.eventArray[key] = _GetNext(self)
        end
    end
end

return M