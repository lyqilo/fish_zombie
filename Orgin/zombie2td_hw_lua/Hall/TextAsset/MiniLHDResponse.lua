-- local CC = require("CC")
-- local Notifications = CC.Notifications
-- local HallNotificationCenter = CC.HallNotificationCenter
-- local MNSB_ClientProto = require("View/MiniLHDView/MiniLHDNetwork/game_pb")
local MiniLHDNotification = require("View/MiniLHDView/MiniLHDNetwork/MiniLHDNotification")
local Response = {}
--所有信息处理
function Response.Update(data)
    MiniLHDNotification.GamePost("SCUpdate", data)
end
function Response.NextGame(data)
    MiniLHDNotification.GamePost("SCNextRound", data)
end
-- 游戏结果
function Response.GameResult(data)
    MiniLHDNotification.GamePost("SCGameResult", data)
end
-- 聊天消息
function Response.PlayerChatMsg(data)
    MiniLHDNotification.GamePost("PlayerChatMsg", data)
end

return Response
