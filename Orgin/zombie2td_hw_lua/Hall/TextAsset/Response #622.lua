-- local CC = require("CC")
-- local Notifications = CC.Notifications
-- local HallNotificationCenter = CC.HallNotificationCenter
-- local MNSB_ClientProto = require("View/MiniSBView/MiniSBNetwork/game_pb")
local MiniSBNotification = require("View/MiniSBView/MiniSBNetwork/MiniSBNotification")
local Response = {}
--所有信息处理
function Response.Update(data)
    MiniSBNotification.GamePost("SCUpdate", data)
end
function Response.NextGame(data)
    MiniSBNotification.GamePost("SCNextRound", data)
end
-- 游戏结果
function Response.GameResult(data)
    MiniSBNotification.GamePost("SCGameResult", data)
end
-- 聊天消息
function Response.PlayerChatMsg(data)
    MiniSBNotification.GamePost("PlayerChatMsg", data)
end

return Response
