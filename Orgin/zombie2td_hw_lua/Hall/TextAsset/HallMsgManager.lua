

local CC = require("CC")
local TCPManagerBase = require("SubGame/NetworkFramework/TCPManagerBase")
local M = CC.class2("HallMsgManager", TCPManagerBase)

local _OnPushTransferGameMessage

function M:ctor(gameProto, messageCenter, gameId)
    self.gameId = gameId

    self.hallNotificationCenter = CC.HallNotificationCenter.inst()
    self.hallNotifications = CC.Notifications
    self.hallNotificationCenter:register(self, _OnPushTransferGameMessage, self.hallNotifications.OnPushTransferGameMessage)
end

function M:Destroy()
    self.hallNotificationCenter:unregisterAll(self)
end

_OnPushTransferGameMessage = function(self, data)
    local gameId = data.GameId
    if gameId == self.gameId then
        local Data = data.TransferMessage.Data
        local Ops = data.TransferMessage.Ops
        self:OnPush(0, Data, Ops, true)
    end
end

return M