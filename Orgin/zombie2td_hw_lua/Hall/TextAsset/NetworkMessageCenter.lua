local CC = require("CC")
local NetworkLocalNotifications = require("SubGame/NetworkFramework/NetworkLocalNotifications")
local NetworkTools = require("SubGame/NetworkFramework/NetworkTools")
local M = CC.class2("NetworkMessageCenter")

function M:ctor(gameServerTag, gameProto)
    self.notificationCenter = CC.NotificationCenter.new()
    self.networkLocalNotifications = NetworkLocalNotifications.new(gameServerTag, gameProto)
end

function M:GetNotificationCenter()
    return self.notificationCenter
end

function M:GetLocalNotification()
    return self.networkLocalNotifications
end

function M:Post(key, ...)
    self.notificationCenter:post(self.networkLocalNotifications:GetEvent(key), ...)
end

function M:PostResponse(name, ...)
    local key = NetworkTools.GetRspMessageName(name)
    self.notificationCenter:post(self.networkLocalNotifications:GetEvent(key), ...)
end

function M:PostPush(name, ...)
    local key = NetworkTools.GetPushMessageName(name)
    self.notificationCenter:post(self.networkLocalNotifications:GetEvent(key), ...)
end

return M