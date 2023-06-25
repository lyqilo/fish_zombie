-- local CC = require("CC")
-- local DTproto = CC.proto
local MNSBProto = require("View/MiniSBView/MiniSBNetwork/game_pb")
local Response = require("View/MiniSBView/MiniSBNetwork/Response")
local MessageConfig = {}

--客户端请求。请求是名称找协议号
---定义协议名称，协议号，ResName表示返回数据的协议名称，为nil时表示不处理数据
MessageConfig.request = {
	CSLoginGameWithToken = {
		name = "CSLoginGameWithToken",
		Ops = MNSBProto.OPLogin,
		ResName = "SCLoginWithTokenRsp" --先用这个 嵌套的有问题
	},
	CSPingReq = {
		name = "CSPingReq",
		Ops = MNSBProto.OPPing,
		ResName = "SCPingRsp"
	},
	CSBetReq = {
		name = "CSBetReq",
		Ops = MNSBProto.OPBet,
		ResName = "SCBetRsp" --返回数据的协议名称
	},
	CSRevokeBetReq = {
		name = "CSRevokeBetReq",
		Ops = MNSBProto.OPRevokeBet,
		ResName = "SCRevokeBetRsp" --返回数据的协议名称
	},
	CSLoadPlayerRankReq = {
		name = "CSLoadPlayerRankReq",
		Ops = MNSBProto.OPLoadRank,
		ResName = "SCLoadPlayerRankRsp" --返回数据的协议名称
	},
	CSLoadGameResultHistoryReq = {
		name = "CSLoadGameResultHistoryReq",
		Ops = MNSBProto.OPLoadGRHistory,
		ResName = "SCLoadGameResultHistoryRsp" --返回数据的协议名称
	},
	CSLoadRoundRecordReq = {
		name = "CSLoadRoundRecordReq",
		Ops = MNSBProto.OPLoadRoundRecords,
		ResName = "SCLoadRoundRecordRsp"
	},
	CSLoadPlayerRecordReq = {
		name = "CSLoadPlayerRecordReq",
		Ops = MNSBProto.OPLoadPlayerRecords,
		ResName = "SCLoadPlayerRecordRsp"
	},
	CSLoadMsgChatReq = {
		name = "CSLoadMsgChatReq",
		Ops = MNSBProto.OPLoadChatMsg,
		ResName = "SCLoadMsgChatRsp"
	},
	CSLongphoneRankReq = {
		name = "CSLongphoneRankReq",
		Ops = MNSBProto.OPLoadLongphoneRank,
		ResName = "SCLongphoneRankRsp"
	},
	MsgChat = {
		name = "MsgChat",
		Ops = MNSBProto.OPSendChatMsg,
		ResName = ""
	}
}

--服务器的推送。推送是协议号找名称
---定义协议名称，协议号，CallBack表示处理回调的接口
MessageConfig.onPush = {
	[MNSBProto.OPUpdate] = {
		Name = "SCUpdate",
		CallBack = Response.Update
	},
	[MNSBProto.OPNextRound] = {
		Name = "SCNextRound",
		CallBack = Response.NextGame
	},
	[MNSBProto.OPGameResult] = {
		Name = "SCGameResult",
		CallBack = Response.GameResult
	},
	[MNSBProto.OPSendChatMsg] = {
		Name = "PlayerChatMsg",
		CallBack = Response.PlayerChatMsg
	}
}

return MessageConfig
