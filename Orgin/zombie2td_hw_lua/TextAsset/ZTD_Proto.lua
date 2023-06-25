
local game_message_pb = require("_ZTD_Network/protos/game_message_pb")
local shared_message_pb = require("_ZTD_Network/protos/shared_message_pb")
local proto = {}

local M = {}

proto.client = M
proto.shared_operation_pb = game_message_pb
setmetatable(M, {
    __index = function(tb, key)
        return game_message_pb[key] or shared_message_pb[key]
    end
})

return proto
