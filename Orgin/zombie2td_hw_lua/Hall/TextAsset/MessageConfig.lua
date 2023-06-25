local CC = require("CC")
local DTproto = CC.proto
local LotteryProto = require("Model/LotteryNetwork/game_message_pb")
local Response = require("Model/LotteryNetwork/Response")
local MessageConfig = {}



--客户端请求。请求是名称找协议号
---定义协议名称，协议号，ResName表示返回数据的协议名称，为nil时表示不处理数据
MessageConfig.request = {
	CSLoginWithTokenReq = {
		name = "CSLoginWithTokenReq",
		Ops = LotteryProto.Ops_ReqLoginWithToken,--协议号
		ResName = "CSLoginWithTokenReq" --返回数据的协议名称
	},
	CSPurchaseLotteryReq = {
		name = "CSPurchaseLotteryReq",
		Ops = LotteryProto.Ops_PurchaseLottery,--协议号
		ResName = "SCPurchaseLotteryRsp" --返回数据的协议名称
	},
	CSRandLotteryNumberReq = {
		name = "CSRandLotteryNumberReq",
		Ops = LotteryProto.Ops_RandLotteryNumber,--协议号
		ResName = "SCRandLotteryNumberRsp" --返回数据的协议名称
	},
	CSLotteryPurchaseRecodeReq = {
		name = "CSLotteryPurchaseRecodeReq",
		Ops = LotteryProto.Ops_LotteryPuchaseRecode,--协议号
		ResName = "SCLotteryPurchaseRecodeRsp" --返回数据的协议名称
	},
	CSLotteryHistoryRecodeReq = {
		name = "CSLotteryHistoryRecodeReq",
		Ops = LotteryProto.Ops_LotteryHistoryRecode,--协议号
		ResName = "SCLotteryHistoryRecodeRsp" --返回数据的协议名称
	},
	CSLotteryDetailRecodeReq = {
		name = "CSLotteryDetailRecodeReq",
		Ops = LotteryProto.Ops_LotteryDetailRecode,--协议号
		ResName = "SCLotteryDetailRecodeRsp" --返回数据的协议名称
	},
	CSLotteryLatternReq = {
		name = "CSLotteryLatternReq",
		Ops = LotteryProto.Ops_LotteryLattern,--协议号
		ResName = "SCLotteryLatternRsp" --返回数据的协议名称
	},
	CSFirstPrizeRecodeReq = {
		name = "CSFirstPrizeRecodeReq",
		Ops = LotteryProto.Ops_FirstPrizeRecode,--协议号
		ResName = "SCFirstPrizeRecodeRsp" --返回数据的协议名称
	},
	CSLotteryRankReq = {
		name = "CSLotteryRankReq",
		Ops = LotteryProto.Ops_LotteryRank,--协议号
		ResName = "SCLotteryRankRsp" --返回数据的协议名称
    },
    CSPingReq = {
		name = "CSPingReq",
		Ops = LotteryProto.Ops_CS_Ping,--协议号
		ResName = "SCPingRsp" --返回数据的协议名称
	},
}


--服务器的推送。推送是协议号找名称
---定义协议名称，协议号，CallBack表示处理回调的接口
MessageConfig.onPush={
	[LotteryProto.Ops_SC_PushPropChange] = {
		Name = "SCRefreshGamePropsNtf",
		CallBack = Response.Push_PropChanged
	},
	[LotteryProto.Ops_SC_PushGameInfo] = {
		Name = "SCGameInfoNtf",
		CallBack = Response.PushGameInfo
	},
	[LotteryProto.Ops_SC_PushOpenReward] = {
		Name = "SCOpenRewardNtf",
		CallBack = Response.OpenRewardNtf
	},
	[LotteryProto.Ops_ReqLoginWithToken]={
		Name = "SCLoginWithTokenRsp",
		CallBack = Response.LoginWithTokenRsp
	},
	[LotteryProto.Ops_PurchaseLottery] = {
		Name = "SCPurchaseLotteryRsp",
		CallBack = Response.PurchaseLotteryRsp
	},
	[LotteryProto.Ops_RandLotteryNumber] = {
		Name = "SCRandLotteryNumberRsp",
		CallBack = Response.RandLotteryNumberRsp
	},
	[LotteryProto.Ops_LotteryPuchaseRecode] = {
		Name = "SCLotteryPurchaseRecodeRsp",
		CallBack = Response.PushPurchaseRecord
	},
	[LotteryProto.Ops_LotteryDetailRecode] = {
		Name = "SCLotteryDetailRecodeRsp",
		CallBack = Response.PushPurchaseDetail
	},
	[LotteryProto.Ops_LotteryHistoryRecode] = {
		Name = "SCLotteryHistoryRecodeRsp",
		CallBack = Response.PushPastLotteryRecord
	},
	[LotteryProto.Ops_SC_PushRewardPoolData] = {
		Name = "SCRewardPoolDataChangeNtf",
		CallBack = Response.RewardPoolDataChangeNtf
	},
	[LotteryProto.Ops_SC_PushLotteryLattern] = {
		Name = "SCLotteryLatternNtf",
		CallBack = Response.LotteryLatternNtf
	},
	[LotteryProto.Ops_LotteryLattern] = {
		Name = "SCLotteryLatternRsp",
		CallBack = Response.Nil
	},
	[LotteryProto.Ops_FirstPrizeRecode] = {
		Name = "SCFirstPrizeRecodeRsp",
		CallBack = Response.FirstPrizeRecodeRsp
	},
	[LotteryProto.Ops_LotteryRank] = {
		Name = "SCLotteryRankRsp",
		CallBack = Response.LotteryRankRsp
    },
    [LotteryProto.Ops_CS_Ping] = {
		Name = "SCPingRsp",
		CallBack = Response.LotteryPingRsp
	},
}

--主动推送
--服务的推送
MessageConfig.push = {
	-- xxx = {
	-- 	Name = "xxx", --协议名称
	-- 	Ops = LotteryProto.xxxx,--协议号
	-- },
}


return MessageConfig


