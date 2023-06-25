-- local CC = require("CC")
local GC = require("GC")
local NetworkManager = require("View/MiniLHDView/MiniLHDNetwork/MiniLHDNetworkManager")
local MessageManager = require("View/MiniLHDView/MiniLHDNetwork/MiniLHDMessageManager")
local proto = require("View/MiniLHDView/MiniLHDNetwork/game_pb")
local Request = {}

local REQUESTLIST = NetworkManager.REQUESTLIST

local MakeMessage = function(name)
    local config = MessageManager.Inst():GetRequestProConfig(name)
    local req = NetworkManager.MakeMessage(config.name)
    return req
end

function Request.LoginWithToken(id, token, cb)
    local pbName = REQUESTLIST.LOGIN
    local req = MakeMessage(pbName)
    req.playerId = id
    req.token = token
    NetworkManager.Request(pbName, req, cb)
end

function Request.Ping(time)
    local pbName = REQUESTLIST.OPPing
    local req = MakeMessage(pbName)
    req.lTimeStamp = time
    NetworkManager.Request(pbName, req)
end

function Request.Bet(betChip, betAreas, cb)
    local pbName = REQUESTLIST.OPBet
    local req = MakeMessage(pbName)
    req.placeBet.betValue = betChip
    req.placeBet.area = betAreas
    NetworkManager.Request(pbName, req, cb)
end

function Request.RevokeBet(cb)
    local pbName = REQUESTLIST.OPRevokeBet
    local req = MakeMessage(pbName)
    NetworkManager.Request(pbName, req, cb)
end

function Request.RankListReq(start, stop, cb)
    local pbName = REQUESTLIST.OPLoadRank
    local req = MakeMessage(pbName)
    req.start = start
    req.stop = stop
    NetworkManager.Request(pbName, req, cb)
end

function Request.LoadGameResultHistory(start, stop, cb)
    local pbName = REQUESTLIST.OPLoadGRHistory
    local req = MakeMessage(pbName)
    req.start = start
    req.stop = stop
    NetworkManager.Request(pbName, req, cb)
end
--玩家自己的局记录
function Request.LoadPlayerRecords(start, stop, cb)
    local pbName = REQUESTLIST.OPLoadPlayerRecords
    local req = MakeMessage(pbName)
    req.start = start
    req.stop = stop
    NetworkManager.Request(pbName, req, cb)
end
--所有的局记录
function Request.LoadRecords(start, stop, cb, roundID)
    local pbName = REQUESTLIST.OPLoadRoundRecords
    local req = MakeMessage(pbName)
    req.start = start
    req.stop = stop
    if roundID then
        req.roundID = roundID
    end
    NetworkManager.Request(pbName, req, cb)
end
--聊天信息
function Request.LoadMsgChat(start, stop, cb)
    local pbName = REQUESTLIST.OPLoadChatMsg
    local req = MakeMessage(pbName)
    req.start = start
    req.stop = stop
    NetworkManager.Request(pbName, req, cb)
end
--发送聊天消息
function Request.SendMsgChat(msg, cb)
    local taken = GC.Player.Inst():GetLoginInfo()
    local pbName = REQUESTLIST.OPSendChatMsg
    local req = MakeMessage(pbName)
    req.from = taken.PlayerId
    local jsonString = Json.encode({msg = msg})
    req.data = jsonString
    req.dataType = proto.Text
    req.scope = proto.InServer
    NetworkManager.Request(pbName, req, cb)
end

--龙凤活动
function Request.LoadLongphoneData(index, cb)
    local pbName = REQUESTLIST.OPLoadLongphoneRank
    local req = MakeMessage(pbName)
    req.index = index
    NetworkManager.Request(pbName, req, cb)
end

return Request
