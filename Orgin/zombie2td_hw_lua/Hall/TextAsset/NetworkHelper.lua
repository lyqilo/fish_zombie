
local CC = require("CC")

local NetworkHelper = {}


--转菊花超时客户端返回[[-1错误码]]
NetworkHelper.DelayErrCode = -1


function NetworkHelper.Init()

	--大厅协议配置
	NetworkHelper.Cfg = {
		-- ReqLoadPlayerWithPropType = {
		-- 	Ops = 操作码,
		-- 	ReqProto = "请求协议",
		-- 	RspProto = "响应协议",
		-- 	Timeout = 客户端转菊花时间设定,
		--  ReqUrlMethod = 请求的服务地址(封包工具使用),
		--  Note = 协议描述，
		--	ExceptView = 不显示connecting的界面
		-- },
		Register = {
			Ops = CC.proto.shared_operation_pb.OP_ReqRegister,
			ReqProto = "Register",
			Note = "账号注册",
			ReqUrlMethod = CC.Network.RequestAuthHttp,
		},
		Login = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLogin,
			ReqProto = "Login",
			RspProto = "TokenInfo",
			Note = "游客登录",
			ReqUrlMethod = CC.Network.RequestAuthHttp,
		},
		AppleLogin = {
			Ops = CC.proto.shared_operation_pb.OP_ReqIOSLogin,
			ReqProto = "IOSLogin",
			RspProto = "TokenInfo",
			Note = "苹果登录",
			ReqUrlMethod = CC.Network.RequestAuthHttp,
		},
		ResetLogout = {
			Ops = CC.proto.shared_operation_pb.OP_ReqIOSLogout,
			ReqProto = "Logout",
			-- RspProto = "ErrorCode",
			Note = "苹果注销",
			-- ReqUrlMethod = CC.Network.RequestAuthHttp,
		},
		FacebookLogin = {
			Ops = CC.proto.shared_operation_pb.OP_ReqFacebookLogin,
			ReqProto = "FacebookLogin",
			RspProto = "TokenInfo",
			Note = "FB登录",
			ReqUrlMethod = CC.Network.RequestAuthHttp,
		},
		LineLogin = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLineLogin,
			ReqProto = "LineLogin",
			RspProto = "TokenInfo",
			Note = "Line登录",
			ReqUrlMethod = CC.Network.RequestAuthHttp,
		},
		OppoLogin = {
			Ops = CC.proto.shared_operation_pb.OP_ReqOPPOLogin,
			ReqProto = "OPPOLogin",
			RspProto = "TokenInfo",
			Note = "OPPO登录",
			ReqUrlMethod = CC.Network.RequestAuthHttp,
		},
		BindFacebook = {
			Ops = CC.proto.shared_operation_pb.OP_ReqFacebookBind,
			ReqProto = "FacebookBind",
			Timeout = 15,
			Note = "FB绑定",
		},
		BindLine = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLineBind,
			ReqProto = "LineBind",
			Timeout = 15,
			Note = "Line绑定",
		},
		RegToPublisher = {
			Ops = CC.proto.shared_operation_pb.OP_ReqReg2Publisher,
			ReqProto = "RegToPublisher",
			Note = "注册publish",
			ReqUrlMethod = CC.Network.Request
		},
		LoginWithToken = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoginWithToken,
			ReqProto = "LoginWithToken",
			RspProto = "PlayerData",
			Note = "token验证",
		},
		ReqSavePlayer = {
			Ops = CC.proto.shared_operation_pb.OP_ReqSavePlayer,
			ReqProto = "SavePlayer",
			Note = "保存玩家基本信息",
		},
		ReqLoadPlayerWithProps ={
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadPlayerWithProps,
			ReqProto = "LoadPlayerWithProps",
			RspProto = "LoadPlayerWithPropsResp",
			Note = "获取玩家道具信息",
		},
		ReqLoadPlayerWithPropType = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadPlayerWithPropType,
			ReqProto = "LoadPlayerWithPropType",
			RspProto = "LoadPlayerWithPropsResp",
			Note = "获取玩家道具信息",
		},
		ReqGetSpecialProps = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetSpecialProps,
			ReqProto = "GetSpecialProps",
			RspProto = "GetSpecialPropsResp",
			Note = "根据道具Id获取道具信息",
		},
		ReqLoadTitles = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadTitle,
			RspProto = "TitleData",
			Timeout = 15,
			Note = "头衔数据",
		},
		ReqGetNewPlayerFlag = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetNewPlayerFlag,
			RspProto = "GetNewPlayerFlag",
			Note = "获取新手引导状态",
		},
		ReqSaveNewPlayerFlag = {
			Ops = CC.proto.shared_operation_pb.OP_ReqSaveNewPlayerFlag,
			ReqProto = "SaveNewPlayerFlag",
			RspProto = "SaveNewPlayerFlag",
			Note = "保存新手引导状态",
		},
		ReqNewPlayerRewardProp = {
			Ops = CC.proto.shared_operation_pb.OP_ReqNewPlayerRewardProp,
			ReqProto = "GiveNewPlayerReward",
			RspProto = "GiveNewPlayerRewardResp",
			Timeout = 15,
			Note = "新手引导奖励",
		},
		ReqAddFriend = {
			Ops = CC.proto.shared_operation_pb.OP_ReqAddFriend,
			ReqProto = "AddFriend",
			RspProto = "AddFriendResp",
			Timeout = 15,
			Note = "请求添加好友",
		},
		ReqDelFriend = {
			Ops = CC.proto.shared_operation_pb.OP_ReqDelFriend,
			ReqProto = "DelFriend",
			Timeout = 15,
			Note = "请求删除好友",
		},
		ReqLoadRecommandedFriends = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadRecommandedGuies,
			RspProto = "RecommandedList",
			Timeout = 15,
			Note = "加载推荐好友列表",
		},
		ReqLoadFriendsList = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadFriendsList,
			ReqProto = "LoadFriendsList",
			RspProto = "LoadFriendsListResp",
			Timeout = 15,
			Note = "加载好友列表",
			ExceptView = {"HallView"},
		},
		ReqLoadNews = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadNews,
			RspProto = "LoadNews",
		},
		ReqLoadModifyNews = {
			Ops = CC.proto.shared_operation_pb.OP_ReqModNew,
			ReqProto = "ModNew",
			RspProto = "ModNewResp",
		},
		ReqLoadApplyFriendsList = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadApplyFriendsList,
			ReqProto = "LoadApplyFriendsList",
			RspProto = "LoadApplyFriendsListResp",
			Timeout = 15,
			Note = " 拉取好友申请列表",
			ExceptView = {"HallView"}
		},
		ReqAgreeFriend = {
			Ops = CC.proto.shared_operation_pb.OP_ReqAgreeFriend,
			ReqProto = "AgreeFriend",
		},
		ReqIsFriend = {
			Ops = CC.proto.shared_operation_pb.OP_ReqIsFriend,
			ReqProto = "IsFriend",
			RspProto = "IsFriendResp",
		},
		ReqFriendsRefuseAll = {
			Ops = CC.proto.shared_operation_pb.OP_ReqFriendsRefuseAll,
		},
		ReqFriendsAgreeAll = {
			Ops = CC.proto.shared_operation_pb.OP_ReqFriendsAgreeAll,
		},
		ReqRefuseFriend = {
			Ops = CC.proto.shared_operation_pb.OP_ReqRefuseFriend,
			ReqProto = "RefuseFriend",
		},
		ReqBuyWithId = {
			Ops = CC.proto.shared_operation_pb.OP_ReqBuyWithId,
			ReqProto = "BuyWithId",
		},
		Chat = {
			Ops = CC.proto.shared_operation_pb.OP_ReqChat,
			ReqProto = "Chat",
		},
		ReqTrade = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTrade,
			ReqProto = "Trade",
			Timeout = 15,
			Note = "赠送请求",
		},
		ReqTradeInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetTradeInfo,
			RspProto = "TradeInfo",
			Timeout = 15,
			ExceptView = {"LoginView", "TreasureView"},
			Note = "赠送相关信息",
		},
		ReqGetAgentRevenue = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetAgentRevenue,
			ReqProto = "GetAgentRevenueReq",
			RspProto = "GetAgentRevenueRsp",
			Timeout = 15,
			Note = "拉取赠送高V收益",
		},
		ReqOpenOtpValid = {
			Ops = CC.proto.shared_operation_pb.OP_ReqOpenOtpValid,
			ReqProto = "OpenOtpValid",
		},
		ReqCancelOtpValid = {
			Ops = CC.proto.shared_operation_pb.OP_ReqCancelOtpValid,
			ReqProto = "CancelOtpValid",
		},
		ReqMailLoad = {
			Ops = CC.proto.shared_operation_pb.OP_ReqMailLoad,
			ReqProto = "LoadMails",
			RspProto = "LoadMailsResp",
			Timeout = 15,
			Note = "拉取邮件数据",
		},
		ReqMailLoadAll = {
			Ops = CC.proto.shared_operation_pb.OP_ReqMailLoadAll,
			RspProto = "LoadMailsResp"
		},
		ReqMailTakeAttachments = {
			Ops = CC.proto.shared_operation_pb.OP_ReqMailTakeAttachments,
			ReqProto = "TakeAttachments",
			Timeout = 15,
			Note = "领取邮件附件",
		},
		ReqMailTakeAllSys = {
			Ops = CC.proto.shared_operation_pb.OP_ReqMailTakeAllSys,
			RspProto = "TakeAllAttachmentsResp",
			Timeout = 15,
		},
		ReqMailTakeAllPersonal = {
			Ops = CC.proto.shared_operation_pb.OP_ReqMailTakeAllPersonal,
			RspProto = "TakeAllAttachmentsResp",
			Timeout = 15,
			Note = "领取所有个人邮件附件",
		},
		ReqMailOpen = {
			Ops = CC.proto.shared_operation_pb.OP_ReqMailOpen,
			ReqProto = "OpenMail",
		},
		ReqMailDeleteAllSys = {
			Ops = CC.proto.shared_operation_pb.OP_ReqMailDelAllSys,
			RspProto = "DeleteAllMailsWithoutAttachmentsResp",
			Timeout = 15,
			Note = "删除所有系统邮件",
		},
		ReqMailDeleteAllPersonal = {
			Ops = CC.proto.shared_operation_pb.OP_ReqMailDelAllPersonal,
			RspProto = "DeleteAllMailsWithoutAttachmentsResp",
			Timeout = 15,
			Note = "刪除所有个人邮件",
		},
		-- Silent = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqSilent,
		-- },
		ReqLoadPlayerGameInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadPlayerGameInfo,
			ReqProto = "LoadPlayerGameInfo",
			RspProto = "PlayerGameInfo",
			Timeout = 10,
			ExceptView = {"LoginView"},
			Note = "拉取玩家游戏信息",
		},
		ReqAllocServer = {
			Ops = CC.proto.shared_operation_pb.OP_ReqAllocServer,
			ReqProto = "AllocServer",
			RspProto = "AllocServerAddressResp",
			Timeout = 15,
			Note = "拉取游戏IP地址",
		},
		SendPChat = {
			Ops = CC.proto.shared_operation_pb.OP_ReqPChat,
			ReqProto = "SendPChat",
		},
		MarkPChatAsReaded = {
			Ops = CC.proto.shared_operation_pb.OP_ReqMarkPChatAsReaded,
			ReqProto = "MarkPChatAsReaded",
		},
		LoadPChatSummary = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadPChatSummary,
			RspProto = "LoadPChatSummaryResp",
		},
		LoadPChatList = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadPChatList,
			ReqProto = "LoadPChatList",
			RspProto = "LoadPChatListResp",
			Timeout = 5,
			Note = "拉取私聊数据",
		},
		LoadJackpots = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadJackpots,
			RspProto = "Jackpots",
		},
		ReqTableList = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetGameTableList,
			ReqProto = "TableList",
			RspProto = "TableListResp",
		},
		GetOrder = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetOrder,
			ReqProto = "GetOrder",
			RspProto = "GetOrderResp",
			Timeout = 15,
			Note = "创建支付订单",
		},
		MolCashCardPurchase = {
			Ops = CC.proto.shared_operation_pb.OP_ReqMolCashCardPurchase,
			ReqProto = "MolCashCardPurchase",
			Timeout = 15,
			Note = "Mol点卡支付",
		},
		LoadPlayerBaseInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadPlayerBaseInfo,
			ReqProto = "LoadPlayerBaseInfo",
			RspProto = "LoadPlayerBaseInfoResp",
			Timeout = 15,
		},
		GooglePurchaseVerify = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGooglePurchaseVerify,
			ReqProto = "GooglePurchaseVerify",
		},
		IOSPurchaseVerify = {
			Ops = CC.proto.shared_operation_pb.OP_ReqIOSPurchaseVerify,
			ReqProto = "IOSPurchaseVerify",
		},
		LoadChatList = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadChatList,
			ReqProto = "LoadChatList",
			RspProto = "LoadChatListResp",
		},
		ReqLoadTradeSended = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadTradeSended,
			ReqProto = "GetTradeRecords",
			RspProto = "TradeRecords",
		},
		ReqLoadTradeReceived = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadTradeReceived,
			ReqProto = "GetTradeRecords",
			RspProto = "TradeRecords",
		},
		ReqLoadTradeSummaries = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadTradeSummaries,
			RspProto = "TradeSummaries",
		},
		ReqGetWeeklyRank = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWeeklyRank,
			ReqProto = "GetRank",
			RspProto = "GetRankResp",
			Note = "拉取周赢取榜",
		},
		ReqGetDailyRank = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetDailyRank,
			ReqProto = "GetRank",
			RspProto = "GetRankResp",
			Note = "拉取每日赢取榜",
		},
		ReqGetSuperRank = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetSuperRank,
			ReqProto = "GetRank",
			RspProto = "GetRankResp",
			Note = "拉取筹码榜",
		},
		ReqGetTradeRank = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetTradeRank,
			ReqProto = "GetRank",
			RspProto = "GetRankResp",
			Note = "拉取赠送榜",
		},
		ReqGetSmsToken = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetSmsTOken,
			ReqProto = "GetSmsToken",
		},
		ReqTelBind = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTelBind,
			ReqProto = "TelBind",
			Timeout = 15,
			Note = "手机绑定",
		},
		VipPointChange = {
			Ops = CC.proto.shared_operation_pb.OP_ReqVipPointExchange,
			ReqProto = "VipPointChange",
		},
		ReqLoadCreditLine = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadCreditLine,
			RspProto = "CreditLine",
		},
		GetReliefInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetReliefInfo,
			RspProto = "Relief",
			Note = "拉取救济金信息",
		},
		TakeRelief = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTakeRelief,
			Timeout = 15,
			Note = "领取救济金",
		},
		ReqUnreg2Publisher = {
			Ops = CC.proto.shared_operation_pb.OP_ReqUnreg2Publisher,
			Timeout = 15,
			ReqUrlMethod = CC.Network.Request,
			Note = "断开publisher",
		},
		DelPChat = {
			Ops = CC.proto.shared_operation_pb.OP_ReqDelPChat,
			ReqProto = "DelPChat",
		},
		GetFirstPayState = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetFirstPayState,
			RspProto = "FristPay",
		},
		Take7DaysReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTake7DaysReward,
			RspProto = "SevenDays",
		},
		GetOnlineRewardInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetOnlineRewardInfo,
			ReqProto = "GetOnlineRewardInfo",
			RspProto = "GetOnlineRewardInfoRsp",
		},
		TakeOnlineReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTakeOnlineReward,
			ReqProto = "TakeOnlineReward",
			RspProto = "TakeOnlineRewardRsp",
			Timeout = 15,
			Note = "领取在线奖励",
		},
		GetResourceVersionInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetResourceVersionInfo,
			ReqProto = "GetResourceVersionInfo",
			RspProto = "GetResourceVersionInfoRsp",
			ReqUrlMethod = CC.Network.RequestAuthHttp,
		},
		GetAllResourceVersionInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetAllResourceVersionInfo,
			RspProto = "GetResourceVersionInfoRsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestAuthHttp,
		},
		GetLoginRewardInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetLoginRewardInfo,
			RspProto = "GetLoginRewardInfoRsp",
		},
		TakeLoginReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTakeLoginReward,
			RspProto = "TakeLoginRewardRsp",
		},
		CostSendFarewell = {
			Ops = CC.proto.shared_operation_pb.OP_ReqCostSendFarewell,
			ReqProto = "CostSendFarewell",
			RspProto = "CostSendFarewellRsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "祈福活动抽奖",
		},
		SendFarewell = {
			Ops = CC.proto.shared_operation_pb.OP_ReqSendFarewell,
			ReqProto = "SendFarewell",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		TakeFestivalReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTakeFestivalReward,
			ReqProto = "TakeFestivalReward",
			RspProto = "TakeFestivalRewardRsp",
			Timeout = 15,
			Note = "领取春节福袋奖励",
		},
		GetFestivalInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetFestivalInfo,
			ReqProto = "GetFestivalInfo",
			RspProto = "GetFestivalInfoRsp",
			Timeout = 15,
		},
		GetFestivalLoginReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetFestivalLoginReward,
			ReqProto = "GetFestivalLoginReward",
			RspProto = "GetFestivalLoginRewardRsp",
			Timeout = 15,
			Note = "领取春节登录奖励",
		},
		GetFestivalRechargeReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetFestivalRechargeReward,
			ReqProto = "GetFestivalRechargeReward",
			RspProto = "GetFestivalRechargeRewardRsp",
			Timeout = 15,
			Note = "领取春节充值奖励",
		},
		GetServerDateTime = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetServerDateTime,
			-- ReqProto = "GetServerDateTime",
			RspProto = "GetServerDateTimeRsp",
		},
		GetOrderStatus = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetOrderStatus,
			ReqProto = "GetOrderStatus",
			RspProto = "GetOrderStatusResp",
			Note = "获取计费点购买状态",
		},
		Exchange = {
			Ops = CC.proto.shared_operation_pb.OP_ReqExchangeProp,
			ReqProto = "Exchange",
			Timeout = 15,
			Note = "钻石兑换其他道具",
		},
		ReqGetDailySpinInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetDailySpinInfo,
			RspProto = "DailySpinInfo",
			Note = "获取每日转盘信息",
		},
		ReqDailySpin = {
			Ops = CC.proto.shared_operation_pb.OP_ReqDailySpin,
			RspProto = "DailySpinInfo",
			Timeout = 15,
			Note = "每日转盘免费抽奖",
		},
		ReqSpecialDailySpin = {
			Ops = CC.proto.shared_operation_pb.OP_ReqSpecialDailySpin,
			RspProto = "DailySpinInfo",
			Timeout = 15,
			Note = "每日转盘特殊抽奖",
		},
		ReqCostDailySpin = {
			Ops = CC.proto.shared_operation_pb.OP_ReqCostDailySpin,
			RspProto = "DailySpinInfo",
			Timeout = 15,
			Note = "每日转盘筹码抽奖",
		},
		ReqShakeAsk = {
			Ops = CC.proto.client_supply_pb.Req_Ask,
			RspProto = "SpAskResp",
			ReqUrlMethod = CC.Network.RequestSupplyHttp,
			Note = "获取财神摇摇乐状态",
		},
		ReqShakeOpen = {
			Ops = CC.proto.client_supply_pb.Req_Open,
			ReqProto = "SpOpenReq",
			RspProto = "SpOpenResp",
			Timeout = 10,
			ReqUrlMethod = CC.Network.RequestSupplyHttp,
			Note = "摇摇乐开奖",
		},
		ReqShakeConfirm = {
			Ops = CC.proto.client_supply_pb.Req_Confirm,
			ReqProto = "SpConfirmReq",
			Timeout = 10,
			ReqUrlMethod = CC.Network.RequestSupplyHttp,
			Note = "摇摇乐领奖确认",
		},
		ReqShakeDailyRank = {
			Ops = CC.proto.client_supply_pb.Req_DailyRank,
			RspProto = "SpRanksResp",
			Timeout = 10,
			ReqUrlMethod = CC.Network.RequestSupplyHttp,
			Note = "摇摇乐每日榜",
		},
		ReqShakeWeeklyRank = {
			Ops = CC.proto.client_supply_pb.Req_WeeklyRank,
			RspProto = "SpRanksResp",
			Timeout = 10,
			ReqUrlMethod = CC.Network.RequestSupplyHttp,
			Note = "摇摇乐每周榜",
		},
		-- ReqGetPhysicalGoodsInfo = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqGetPhysicalGoodsInfo,
		-- 	RspProto = "PhysicalGoodsInfo",
		-- 	Timeout = 15,
		-- },
		-- ReqBuyPhysicalGoods = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqBuyPhysicalGoods,
		-- 	ReqProto = "BuyPhysicalGoods",
		-- },
		-- ReqGetPhysicalGoodsBuyInfo = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqGetPhysicalGoodsBuyInfo,
		-- 	RspProto = "PhysicalGoodsBuyInfo",
		-- },
		-- ReqGetPhysicalGoodsSelfBuyInfo = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqGetPhysicalGoodsSelfBuyInfo,
		-- 	RspProto = "PhysicalGoodsBuyInfo",
		-- 	Timeout = 15,
		-- },

        ReqGetGoodsList = {
			Ops = CC.proto.client_shop_pb.Req_Goods_List,
			RspProto = "ShopListResp",
			ReqProto = "ShopListReq",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestRealShopHttp,
			Note = "获取实物商城商品列表",
		},
        ReqGoodsBuy = {
			Ops = CC.proto.client_shop_pb.Req_Goods_Buy,
			ReqProto = "ShopBuyReq",
			ReqUrlMethod = CC.Network.RequestRealShopHttp,
		},
		ReqRecordBuy = {
			Ops = CC.proto.client_shop_pb.Req_Record_Buy,
			RspProto = "RecordBuyResp",
			ReqUrlMethod = CC.Network.RequestRealShopHttp,
		},
		ReqRecordRecent = {
			Ops = CC.proto.client_shop_pb.Req_Record_Recent,
			RspProto = "RecordRecentResp",
			ReqUrlMethod = CC.Network.RequestRealShopHttp,
		},
		ReqStockChangedTime = {
			Ops = CC.proto.client_shop_pb.Req_Stock_Changed_Time,
			RspProto = "StockChangedTimeResp",
			ReqUrlMethod = CC.Network.RequestRealShopHttp,
		},
		ReqExchangeTimes = {
			Ops = CC.proto.client_shop_pb.Req_Exchange_Times,
			ReqProto = "ExchangeTimesReq",
			RspProto = "ExchangeTimesResp",
			ReqUrlMethod = CC.Network.RequestRealShopHttp,
		},
		-- ReqAskSign = {
		-- 	Ops = CC.proto.client_msign_pb.Req_AskSign,
		-- 	RspProto = "MsAskSignResp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestMSignHttp,
		-- },
		-- ReqSign = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqSign,
		-- 	RspProto = "MsSignResp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestMSignHttp,
		-- },
		-- ReqAskReplenish = {
		-- 	Ops = CC.proto.client_msign_pb.Req_AskReplenish,
		-- 	RspProto = "MsAskReplenishResp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestMSignHttp,
		-- },
		-- ReqReplenish = {
		-- 	Ops = CC.proto.client_msign_pb.Req_Replenish,
		-- 	ReqProto = "MsReplenishReq",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestMSignHttp,
		-- },
		-- ReqAskBox = {
		-- 	Ops = CC.proto.client_msign_pb.Req_AskBox,
		-- 	RspProto = "MsAskBoxResp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestMSignHttp,
		-- },
		-- ReqOpenBoxDay = {
		-- 	Ops = CC.proto.client_msign_pb.Req_OpenBoxDay,
		-- 	RspProto = "MsBoxContent",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestMSignHttp,
		-- },
		-- ReqOpenBoxWeek = {
		-- 	Ops = CC.proto.client_msign_pb.Req_OpenBoxWeek,
		-- 	RspProto = "MsBoxContent",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestMSignHttp,
		-- },
		-- ReqOpenBoxHalfMonth = {
		-- 	Ops = CC.proto.client_msign_pb.Req_OpenBoxHalfMonth,
		-- 	RspProto = "MsBoxContent",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestMSignHttp,
		-- },
		-- ReqOpenBoxMonth = {
		-- 	Ops = CC.proto.client_msign_pb.Req_OpenBoxMonth,
		-- 	RspProto = "MsBoxContent",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestMSignHttp,
		-- },
		-- ReqAskRoll = {
		-- 	Ops = CC.proto.client_msign_pb.Req_AskRoll,
		-- 	RspProto = "MsRollResp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestMSignHttp,
		-- },
		-- ReqAskRank = {
		-- 	Ops = CC.proto.client_msign_pb.Req_AskRank,
		-- 	RspProto = "MsRankResp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestMSignHttp,
		-- },
		ReqOnlineWelfare = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetOnlineWelfare,
			RspProto = "OnlineWelfareInfo",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqPrivateGameRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadGameRecord,
			ReqProto = "LoadGameRecord",
			RspProto = "GameRecordRsp",
			Timeout = 15,
		},
		ReqPrivateTotalProp = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadTotalProp,
			ReqProto = "LoadGameProp",
			RspProto = "LoadGamePropRsp",
			Timeout = 15,
		},
		ReqPrivateTodayProp = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadTodayProp,
			ReqProto = "LoadGameProp",
			RspProto = "LoadGamePropRsp",
			Timeout = 15,
		},
		ReqPrivateRoomList = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadRoom,
			ReqProto = "LoadRoom",
			RspProto = "LoadRoomRsp",
			Timeout = 15,
		},
		ReqGetActivityInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetActivityInfo,
			RspProto = "ActivityDataResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqGetGameArena = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetGameArena,
			RspProto = "GameArenaResp",
		},
		ReqGetWaterLampWishInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWaterLampWishInfo,
			RspProto = "WaterLampWishInfoResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqGetWaterLampWishRank = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWaterLampWishRank,
			ReqProto = "WaterLampWishRankReq",
			RspProto = "WaterLampWishRankResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqWaterLampWish = {
			Ops = CC.proto.shared_operation_pb.OP_ReqWaterLampWish,
			ReqProto = "WaterLampWishReq",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqLimitTimeGift = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLimitTimeGift,
			ReqProto = "CSLimitTimeGiftReq",
			RspProto = "SCLimitTimeGiftRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqLimitTimeGiftInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLimitTimeGiftInfo,
			ReqProto = "CSLimitTimeGiftInfoReq",
			RspProto = "SCLimitTimeGiftInfoRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqLimitTimeGiftStatus = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLimitTimeGiftStatus,
			RspProto = "SCLimitTimeGiftStatusRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqBlessAwardMessage = {
			Ops = CC.proto.shared_operation_pb.OP_ReqNewYearMesage,
			RspProto = "NewYearMesage",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		Req_Super_PrizeList = {
			Ops = CC.proto.client_treasure_pb.Req_Super_PrizeList,
			RspProto = "TsPrizeListResp",
			Timeout = 10,
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
			Note = "月中夺宝奖品列表",
		},
		Req_PrizeList = {
			Ops = CC.proto.client_treasure_pb.Req_PrizeList,
			RspProto = "TsPrizeListResp",
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
		},
		Req_Super_PrizePurchase = {
			Ops = CC.proto.client_treasure_pb.Req_Super_PrizePurchase,
			ReqProto = "TsPrizePuarchaseReq",
			RspProto = "TsPlayerLuckyCodeResp",
			Timeout = 10,
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
			Note = "月中夺宝购买中奖码",
		},
		Req_PrizePuarchase = {
			Ops = CC.proto.client_treasure_pb.Req_PrizePuarchase,
			ReqProto = "TsPrizePuarchaseReq",
			RspProto = "TsPlayerLuckyCodeResp",
			Timeout = 10,
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
			Note = "普通夺宝购买中奖码",
		},
		Req_PrizeLuckyRecord = {
			Ops = CC.proto.client_treasure_pb.Req_PrizeLuckyRecord,
			ReqProto = "TsLuckyRecordReq",
			RspProto = "TsLuckyRecordResp",
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
		},
		Req_PurchaseRecord = {
			Ops = CC.proto.client_treasure_pb.Req_PuarchaseRecord,
			ReqProto = "TsPurchaseRecordReq",
			RspProto = "TsPurchaseRecordResp",
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
		},
		Req_PlayerLuckyRecord = {
			Ops = CC.proto.client_treasure_pb.Req_PlayerLuckyRecord,
			ReqProto = "TsPlayerLuckyRecordReq",
			RspProto = "TsPlayerLuckyRecordResp",
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
		},
		Req_PlayerLuckyCode = {
			Ops = CC.proto.client_treasure_pb.Req_PlayerLuckyCode,
			ReqProto = "TsPlayerLuckyCodeReq",
			RspProto = "TsPlayerLuckyCodeResp",
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
			Note = "当前参与夺宝商品的所有中奖码",
		},
		Req_Super_LatelyPlayerLuckyRecord = {
			Ops = CC.proto.client_treasure_pb.Req_Super_LatelyPlayerLuckyRecord,
			RspProto = "TsLatelyLuckyPlayerResp",
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
		},
		Req_LatelyPlayerLuckyRecord = {
			Ops = CC.proto.client_treasure_pb.Req_LatelyPlayerLuckyRecord,
			RspProto = "TsLatelyLuckyPlayerResp",
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
		},
		GetPointInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetPointCardInfo,
			ReqProto = "GetPointInfo",
			RspProto = "GetPointInfoResp",
			Timeout = 15,
			Note = "邮件内查看点卡附件信息",
		},
		ReqElephantPiggy = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetElephantPiggy,
			RspProto = "ElephantPiggyInfoResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "大象礼包相关信息",
		},
		ReqElephantPiggyRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetElephantPiggyRecord,
			RspProto = "ElephantPiggyRecordResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqDailySpinJPRank = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetDailySpinJPRank,
			RspProto = "DailySpinJPRankResp",
		},
		ReqLuckySpinInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetLuckySpinInfo,
			RspProto = "LuckySpinInfo",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "幸运转盘礼包相关信息",
		},
		ReqLuckySpinRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetLuckySpinRecord,
			RspProto = "LuckSpinRecordResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqLuckySpin = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLuckySpin,
			RspProto = "LuckySpinRewardInfo",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqTriggerLuckySpin = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTriggerLuckySpin,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqExchangeChmToMini = {
			Ops = CC.proto.shared_operation_pb.OP_ReqExchangeChmToMini,
			ReqProto = "ExchageChmToMini",
		},
		ReqExchangeMiniToChm = {
			Ops = CC.proto.shared_operation_pb.OP_ReqExchangeMiniToChm,
			ReqProto = "ExchangeMiniToChm",
		},
		ReqLoadMiniStatus = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadMiniStatus,
			RspProto = "LoadMiniStatusResp",
		},
		ReqActLoadSign = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadSign_v1,
			RspProto = "SignInfo",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "七日签到相关信息",
		},
		ReqActSign = {
			Ops = CC.proto.shared_operation_pb.OP_ReqSign_v1,
			ReqProto = "PeriodSign",
			RspProto = "SignV1Rsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "七日签到请求签到",
		},
		ReqActResign = {
			Ops = CC.proto.shared_operation_pb.OP_ReqResign,
			ReqProto = "PeriodSign",
			RspProto = "SignV1Rsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "七日签到补签",
		},
		ReqExchange = {
			Ops = CC.proto.shared_operation_pb.OP_ReqExchange_v1,
			ReqProto = "ExchangeV1",
			RspProto = "ExchangeV1Rsp",
			Timeout = 15,
			Note = "道具兑换",
		},
		GetTopWins = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetTopWins,
			ReqProto = "GetTopWins",
			RspProto = "GetTopWinsResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "拉取流水排行榜",
		},
		GetTwistEggInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetTwistEggInfo,
			RspProto = "TwistEggInfo",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "拉取扭蛋活动相关信息",
		},
		GetTwistEgg = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTwistEgg,
			ReqProto = "TwistEgg",
			RspProto = "TwistEggReward",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "扭蛋活动抽奖",
		},
		GetTwistEggRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetTwistEggRecord,
			RspProto = "TwistEggRecordResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		GetTwistEggPlayerRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetTwistEggPlayerRecord,
			RspProto = "TwistEggRecordResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		GetTwistEggRank = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetTwistEggRank,
			ReqProto = "TwistEggRankReq",
			RspProto = "TwistEggRankResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqTwistEggShareNotice  = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTwistEggShareNotice,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "扭蛋活动分享通知",
		},
		-- ReqTreasureReward = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqGetDailyTreasureReward,
		-- 	ReqProto = "GetDailyTreasureReward",
		-- 	RspProto = "GetDailyTreasureRewardResp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestActivityHttp,
		-- },
		-- 高V
		LoadUnReceiveEarn = {
			Ops = CC.proto.client_agent_pb.Req_LoadUnReceiveEarn,
			RspProto = "SC_LoadUnReceiveEarnRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "拉取高V待领取的收益",
		},
		ReceiveEarn = {
			Ops = CC.proto.client_agent_pb.Req_ReceiveEarn,
			ReqProto = "CS_ReceiveEarnReq",
			RspProto = "SC_ReceiveEarnRsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "领取高V收益",
		},
		LoadHistoryEarn = {
			Ops = CC.proto.client_agent_pb.Req_LoadHistoryEarn,
			ReqProto = "CS_LoadHistoryEarnReq",
			RspProto = "SC_LoadHistoryEarnRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "拉取高V收益领取记录",
		},
		LoadSubAgentList = {
			Ops = CC.proto.client_agent_pb.Req_LoadSubAgentList,
			ReqProto = "CS_LoadSubAgentListReq",
			RspProto = "SC_LoadSubAgentListRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "拉取高V下级信息列表",
		},
		SearchSubAgent = {
			Ops = CC.proto.client_agent_pb.Req_SearchSubAgent,
			ReqProto = "CS_SearchSubAgentReq",
			RspProto = "SC_SearchSubAgentRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "拉取高V指定下级信息",
		},
		LoadMonthPromote = {
			Ops = CC.proto.client_agent_pb.Req_LoadMonthPromote,
			RspProto = "SC_LoadMonthPromoteRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "拉取高V月推广数据",
		},
		LoadDayPromote = {
			Ops = CC.proto.client_agent_pb.Req_LoadDayPromote,
			ReqProto = "CS_LoadDayPromoteReq",
			RspProto = "SC_LoadDayPromoteRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "拉取高V日推广数据",
		},
		BindAgent = {
			Ops = CC.proto.client_agent_pb.Req_BindAgent,
			ReqProto = "CS_BindAgentReq",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "绑定高V",
		},
		-- CheckMeIfAgent = {
		-- 	Ops = CC.proto.client_agent_pb.Req_CheckMeIfAgent,
		-- 	RspProto = "SC_CheckMeIfAgentRsp",
		-- 	ReqUrlMethod = CC.Network.RequestAgentHttp,
		-- 	Note = "查询自己是否有高V绑定关系",
		-- },
		ApplyRootAgent = {
			Ops = CC.proto.client_agent_pb.Req_ApplyRootAgent,
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "超V绑定",
		},
		PromoteTask = {
			Ops = CC.proto.client_agent_pb.Req_PromoteTask,
			RspProto = "SC_PromoteTaskRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "拉取高v任务列表",
		},
		PromoteTaskDetail = {
			Ops = CC.proto.client_agent_pb.Req_PromoteTaskDetail,
			ReqProto = "CS_PromoteTaskDetailReq",
			RspProto = "SC_PromoteTaskDetailRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "高v任务信息",
		},
		PromoteTaskReceive = {
			Ops = CC.proto.client_agent_pb.Req_PromoteTaskReceive,
			ReqProto = "CS_PromoteTaskReceiveReq",
			RspProto = "SC_PromoteTaskReceiveRsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "高v任务奖励领取",
		},
		GrandTotalEarn = {
			Ops = CC.proto.client_agent_pb.Req_GrandTotalEarn,
			ReqProto = "CS_GrandTotalEarnReq",
			RspProto = "CS_GrandTotalEarnEarnTotalReq",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "高v累计收益",
		},
		ReqAgentData = {
			Ops = CC.proto.client_agent_pb.Req_AgentData,
			RspProto = "SC_AgentDataRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			ExceptView = {"LoginView", "AgentNewView"},
			Note = "高v信息",
		},
		ReqHomePageData = {
			Ops = CC.proto.client_agent_pb.Req_HomePageData,
			RspProto = "SC_HomePageDataRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "高v邀请人界面信息",
		},
		ReqHomeStatus = {
			Ops = CC.proto.client_agent_pb.Req_HomeStatus,
			ReqProto = "CS_HomeOpenReq",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "高v通知服务器状态",
		},
		ReqReceiveAllEarn = {
			Ops = CC.proto.client_agent_pb.Req_ReceiveAllEarn,
			RspProto = "SC_ReceiveAllEarnRsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "高v领取所有收益",
		},
		ReqAgentBroadcast = {
			Ops = CC.proto.client_agent_pb.Req_AgentBroadcast,
			RspProto = "SC_AgentBroadcastRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "高v跑马灯信息",
		},
		ReqWeekRank = {
			Ops = CC.proto.client_agent_pb.Req_WeekRank,
			RspProto = "SC_WeekRankRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "高v周排行榜",
		},
		ReqNewAgentData = {
			Ops = CC.proto.client_agent_pb.Req_NewAgentData,
			RspProto = "SC_NewAgentDataRsp",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Note = "新高V界面展示",
		},
		ReqReceiveNewAgentPrize = {
			Ops = CC.proto.client_agent_pb.Req_ReceiveNewAgentPrize,
			ReqProto = "cs_ReceiveInvitePrizeReq",
			ReqUrlMethod = CC.Network.RequestAgentHttp,
			Timeout = 15,
			Note = "新高V完成任务领奖",
		},
		PropSaleReq = {
			Ops = CC.proto.shared_operation_pb.OP_ReqPropSale,
			ReqProto = "PropSaleReq",
			RspProto = "PropSaleResp",
		},
		PropUse = {
			Ops = CC.proto.shared_operation_pb.OP_ReqPropUse,
			ReqProto = "PropUse",
			RspProto = "PropUseResp",
		},
		ReqSavePlayerNick = {
			Ops = CC.proto.shared_operation_pb.OP_ReqSavePlayerNick,
			ReqProto = "SavePlayerNickReq",
			Timeout = 15,
			Note = "修改名字",
		},
		ReqGetSevenFundInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetSevenFundInfo,
			RspProto = "SevenFundInfoResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "7日基金购买状态",
		},
		ReqGetSevenFundReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetSevenFundReward,
			ReqProto = "GetSevenFundReward",
			RspProto = "SevenFundRewardResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "7日基金奖励",
		},
		ReqGetDailyLotteryInfo = {
			Ops = CC.proto.client_daily_lotery_pb.Req_Times_Get,
			ReqProto = "LotteryTimesReq",
			RspProto = "LotteryTimesResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestLotteryHttp,
			Note = "每日抽奖信息",
		},
		ReqLottery = {
			Ops = CC.proto.client_daily_lotery_pb.Req_Lottery,
			ReqProto = "LotteryReq",
			RspProto = "LotteryResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestLotteryHttp,
			Note = "每日抽奖请求抽奖",
		},
		ReqAddLotteryTimes = {
			Ops = CC.proto.client_daily_lotery_pb.Req_Times_Add,
			ReqProto = "LotteryTimesAddReq",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestLotteryHttp,
			Note = "每日抽奖增加次数",
		},
		ReqLotteryRankInfo = {
			Ops = CC.proto.client_daily_lotery_pb.Req_Award_Rank,
			RspProto = "AwardRankResp",
			ReqUrlMethod = CC.Network.RequestLotteryHttp,
			Note = "每日抽奖排行榜",
		},
		-- 新手七日签到
		ReqNewPlayerSignStatus = {
			Ops = CC.proto.shared_operation_pb.OP_ReqNewPlayerSignStatus,
			RspProto = "NewPlayerSignStatusRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "查询新手签到状态",
		},
		ReqLoadNewPlayerSign = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadNewPlayerSign,
			RspProto = "NewPlayerSignInfo",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "查询新手签到信息",
		},
		ReqNewPlayerSign = {
			Ops = CC.proto.shared_operation_pb.OP_ReqNewPlayerSign,
			ReqProto = "PeriodSign",
			RspProto = "SignV1Rsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "新手7日签到",
		},
		ReqNewPlayerResign = {
			Ops = CC.proto.shared_operation_pb.OP_ReqNewPlayerResign,
			ReqProto = "PeriodSign",
			RspProto = "SignV1Rsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "新手签到补签",
		},
		ReqNewPlayerSignRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqNewPlayerSignRecord,
			RspProto = "NewPlayerSignBigRewardRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "拉取新手签到大奖记录",
		},
		ReqBrokeGiftInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqBrokenGift,
			RspProto = "SCBrokenGiftRsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "小额破产礼包信息",
		},
		ReqBrokeGiftStatus = {
			Ops = CC.proto.shared_operation_pb.OP_ReqBrokenGiftStatus,
			RspProto = "SCBrokenGiftRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "小额破产礼包状态",
		},
		ReqBrokeGiftRank = {
			Ops = CC.proto.shared_operation_pb.OP_ReqBrokenGiftRank,
			ReqProto = "CSBrokenGiftRankReq",
			RspProto = "SCBrokenGiftRankRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqBrokeBigGiftInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqBrokenBigGift,
			RspProto = "SCBrokenGiftRsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "大额破产礼包信息",
		},
		ReqBrokeBigGiftStatus = {
			Ops = CC.proto.shared_operation_pb.OP_ReqBrokenBigGiftStatus,
			RspProto = "SCBrokenGiftRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "大额破产礼包状态",
		},
		ReqBrokeBigGiftRank = {
			Ops = CC.proto.shared_operation_pb.OP_ReqBrokenBigGiftRank,
			ReqProto = "CSBrokenGiftRankReq",
			RspProto = "SCBrokenGiftRankRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqPirateRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetLhdbRewardRecords ,
			RspProto = "LhdbRewardRecordResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "连环夺宝解锁礼包记录",
		},
		ReqLoadFriendsForTeam = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadFriendsForTeam,
			ReqProto = "LoadFriendsForTeamReq",
			RspProto = "LoadFriendsForTeamResp",
		},
		ReqInviteFriend = {
			Ops = CC.proto.shared_operation_pb.OP_ReqInviteFriend,
			ReqProto = "InviteFriendReq",
		},
		ReqInviteAnswer = {
			Ops = CC.proto.shared_operation_pb.OP_ReqInviteAnswer,
			ReqProto = "InviteAnswerReq",
			RspProto = "InviteAnswerResp",
		},
		ReqDisbandTeam = {
			Ops = CC.proto.shared_operation_pb.OP_ReqDisbandTeam,
			ReqProto = "DisbandTeam",
		},
		ReqLoadPlayerTeam = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadPlayerTeam,
			RspProto = "LoadPlayerTeamResp",
		},
		-- ReqNewTask = {
		-- 	Ops = CC.proto.client_task_pb.Req_New,
		-- 	ReqProto = "NewTaskReq",
		-- 	RspProto = "NewTaskResp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestTaskHttp,
		-- },
		-- ReqTask = {
		-- 	Ops = CC.proto.client_task_pb.Req_Task,
		-- 	RspProto = "TaskInfo",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestTaskHttp,
		-- },
		ReqTaskListInfo = {
			Ops = CC.proto.client_task_pb.Req_List,
			RspProto = "NewTaskListResp",
			ReqUrlMethod = CC.Network.RequestTaskHttp,
			ExceptView = {"LoginView"},
			Note = "新手任务信息",
		},
		ReqGetReward = {
			Ops = CC.proto.client_task_pb.Req_Next,
			ReqProto = "NextTaskReq",
			RspProto = "NextTaskResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestTaskHttp,
			Note = "新手任务奖励",
		},
		ReqGetBoxReward = {
			Ops = CC.proto.client_task_pb.Req_Act_Box_Award,
			ReqProto = "ActBoxAwardReq",
			RspProto = "ActBoxAwardResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestTaskHttp,
			Note = "新手任务活跃度宝箱奖励",
		},
		ReqLoadDailyGiftSignInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadDailyGiftSignInfo,
			RspProto = "DailyGiftSignInfoRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "每日礼包签到信息",
		},
		ReqHalloweenInfo = {
			Ops = CC.proto.client_task_pb.Req_List,
			RspProto = "NewTaskListResp",
			ReqUrlMethod = CC.Network.RequestHalloweenTaskHttp,
			Note = "万圣节大作战固定请求",
		},
		ReqHalloweenReward = {
			Ops = CC.proto.client_task_pb.Req_Next,
			ReqProto = "NextTaskReq",
			RspProto = "NextTaskResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestHalloweenTaskHttp,
			Note = "万圣节大作战领取奖励",
		},
		ReqHalloweenShopBuy = {
			Ops = CC.proto.client_task_pb.Req_Task_Shop_Buy,
			ReqProto = "TaskShopBuyReq",
			RspProto = "TaskShopBuyResp",
			ReqUrlMethod = CC.Network.RequestHalloweenTaskHttp,
			Note = "万圣节兑换商品",
		},
		ReqHalloweenShopList = {
			Ops = CC.proto.client_task_pb.Req_Task_Shop_Goods_List,
			RspProto = "TaskShopGoodsListResp",
			ReqUrlMethod = CC.Network.RequestHalloweenTaskHttp,
			Note = "万圣节兑换商品列表",
		},
		ReqHalloweenShopBroad = {
			Ops = CC.proto.client_task_pb.Req_Task_Shop_BroadCast,
			RspProto = "TaskShopBroadCastResp",
			ReqUrlMethod = CC.Network.RequestHalloweenTaskHttp,
			Note = "万圣节兑换商品中奖记录",
		},
		ReqWaterLightInfo = {
			Ops = CC.proto.client_task_pb.Req_List,
			RspProto = "NewTaskListResp",
			ReqUrlMethod = CC.Network.RequestWaterLightHttp,
			Note = "水灯节派对固定请求",
		},
		ReqWaterLightReward = {
			Ops = CC.proto.client_task_pb.Req_Next,
			ReqProto = "NextTaskReq",
			RspProto = "NextTaskResp",
			ReqUrlMethod = CC.Network.RequestWaterLightHttp,
			Note = "水灯节派对领取流水任务奖励",
		},
		ReqWaterLightSignAward = {
			Ops = CC.proto.client_task_pb.Req_Act_Box_Award,
			ReqProto = "ActBoxAwardReq",
			RspProto = "ActBoxAwardResp",
			ReqUrlMethod = CC.Network.RequestWaterLightHttp,
			Note = "水灯节派对领取签到奖励",
		},
		ReqWaterLightShopBuy = {
			Ops = CC.proto.client_task_pb.Req_Task_Shop_Buy,
			ReqProto = "TaskShopBuyReq",
			RspProto = "TaskShopBuyResp",
			ReqUrlMethod = CC.Network.RequestWaterLightHttp,
			Note = "水灯节派对兑换商品",
		},
		ReqWaterLightShopList = {
			Ops = CC.proto.client_task_pb.Req_Task_Shop_Goods_List,
			RspProto = "TaskShopGoodsListResp",
			ReqUrlMethod = CC.Network.RequestWaterLightHttp,
			Note = "水灯节派对兑换商品列表",
		},
		ReqWaterLightShopBroad = {
			Ops = CC.proto.client_task_pb.Req_Task_Shop_BroadCast,
			RspProto = "TaskShopBroadCastResp",
			ReqUrlMethod = CC.Network.RequestWaterLightHttp,
			Note = "水灯节派对兑换商品中奖记录",
		},
		ReqWaterLightAllTaskList = {
			Ops = CC.proto.client_task_pb.Req_AllTaskList,
			RspProto = "AllTaskListResp",
			ReqUrlMethod = CC.Network.RequestWaterLightHttp,
			Note = "请求水灯节派对所有的子任务",
		},
		-- ReqLoadDailyGiftSignJP = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqLoadDailyGiftSignJP,
		-- 	RspProto = "DailyGiftSignJPRsp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestActivityHttp,
		-- },
		-- ReqDailyGiftSignClick = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqDailyGiftSignClick,
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestActivityHttp,
		-- },
		-- ReqDailyGiftSign = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqDailyGiftSign,
		-- 	RspProto = "DailyGiftSignRsp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestActivityHttp,
		-- },
		-- ReqDailyGiftSignRecord = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqDailyGiftSignRecord,
		-- 	RspProto = "DailyGiftSignBigRewardRsp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestActivityHttp,
		-- },
		ReqDailySpinJackpot = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetDailySpinJP,
			RspProto = "DailySpinJPResp",
			Note = "每日转盘奖池数据"
		},
		ReqAugGiftPayRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqAugGiftPayRecord,
			RspProto = "AugGiftPayRewardRecordResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "假日特惠记录",
		},
		ReqTenFristGiftInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTenFristGiftInfo,
			RspProto = "TenFristGiftInfoRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "首冲礼包信息",
		},
		ReqTenFristGiftLottery = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTenFristGiftLottery,
			RspProto = "TenFristGiftInfoRsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "首冲礼包抽奖",
		},
		ReqTenFristGiftJP = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTenFristGiftJP,
			RspProto = "TenFristGiftJPRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "首冲礼包JP数据",
		},
		ReqTenFristGiftBigReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTenFristGiftBigReward,
			RspProto = "TenFristGiftBigRewardRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "首冲礼包大奖记录",
		},
		ReqOnClientShare = {
			Ops = CC.proto.shared_operation_pb.OP_ReqOnClientShare,
			ReqProto = "OnClientShareNotify",
			Note = "分享成功，新手分享任务完成使用",
		},
		ReqCatBatteryInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqCatBatteryInfo,
			RspProto = "CatBatteryInfoRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "招财猫炮台信息",
		},
		ReqCatBatteryRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqCatBatteryRecord ,
			RspProto = "CatBatteryRecordRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "招财猫炮台记录",
		},
		-- ReqGetRechargeActivityInfo = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqGetRechargeActivityInfo,
		-- 	RspProto = "RechargeActivityInfoResp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestActivityHttp,
		-- },
		-- ReqGetRechargeActivityRank = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqGetRechargeActivityRank,
		-- 	RspProto = "RechargeActivityRankResp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestActivityHttp,
		-- },
		-- ReqGetRechargeActivityRecords = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqGetRechargeActivityRecords,
		-- 	RspProto = "RechargeActivityRewardRecordResp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestActivityHttp,
		-- },
		-- ReqGetRechargeActivityReward = {
		-- 	Ops = CC.proto.shared_operation_pb.OP_ReqGetRechargeActivityReward,
		-- 	ReqProto = "RechargeActivityRewardReq",
		-- 	RspProto = "RechargeActivityRewardResp",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestActivityHttp,
		-- },
		ReqChristTaskInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqChristTaskInfo,
			RspProto = "ChristTaskInfoRsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "圣诞任务信息",
		},
		ReqChristTaskJP = {
			Ops = CC.proto.shared_operation_pb.OP_ReqChristTaskJP,
			RspProto = "ChristTaskJPRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "圣诞任务JP数据",
		},
		ReqChristTaskRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqChristTaskRecord,
			RspProto = "ChristTaskRecordRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "圣诞任务记录",
		},
		ReqChristTaskReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqChristTaskReward,
			ReqProto = "ChristTaskRewardReq",
			RspProto = "ChristTaskRewardRsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "圣诞任务点亮奖励",
		},
		-- ReqStatusBuy = {
		-- 	Ops = CC.proto.client_pack_pb.Req_Status_Buy,
		-- 	ReqProto = "BuyStatusReq",
		-- 	Timeout = 15,
		-- 	ReqUrlMethod = CC.Network.RequestGiftPackHttp,
		-- },
		ReqRecordGet = {
			Ops = CC.proto.client_pack_pb.Req_Record_Get,
			ReqProto = "BroadCastRecordReq",
			RspProto = "BroadcastRecordResp",
			ReqUrlMethod = CC.Network.RequestGiftPackHttp,
			Note = "秒杀礼包跑马灯信息",
		},
		Req_Gift_Data = {
			Ops = CC.proto.client_gift_pb.Req_Gift_Data,
			ReqProto = "GiftDataReq",
			RspProto = "GiftDataResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestGiftSignHttp1,
			Note = "每日礼盒信息",
		},
		Req_Gift_Lottery = {
			Ops = CC.proto.client_gift_pb.Req_Gift_Lottery,
			ReqProto = "GiftLotteryReq",
			RspProto = "GiftLotteryResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestGiftSignHttp2,
			Note = "每日礼盒抽奖",
		},
		Req_Gift_Prizes = {
			Ops = CC.proto.client_gift_pb.Req_Prizes,
			RspProto = "GiftPrizeRewardRsp",
			ReqUrlMethod = CC.Network.RequestGiftSignHttp3,
		},
		ReqTimesbuy = {
			Ops = CC.proto.client_pack_pb.Req_Times_buy,
			ReqProto = "PackTimesBuyReq",
			RspProto = "PackTimesBuyResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestGiftPackHttp,
			Note = "礼包购买次数",
		},
		ReqStockPackGet = {
			Ops = CC.proto.client_pack_pb.Req_Stock_Pack_Get,
			ReqProto = "PackStockReq",
			RspProto = "PackStockResp",
			ReqUrlMethod = CC.Network.RequestGiftPackHttp,
			Note = "秒杀礼包库存",
		},
		ReqRemainTime = {
			Ops = CC.proto.client_pack_pb.Req_Remain_Time,
			ReqProto = "RemainTimeReq",
			RspProto = "RemainTimeResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestGiftPackHttp,
			Note = "秒杀礼包剩余时间",
		},
		ReqGiftTurnTableRecord = {
            Ops = CC.proto.client_treasure_pb.Req_Turntable_BroadCast,
			RspProto = "TsBroadcastRecordResp",
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
			Note = "夺宝转盘跑马灯",
		},
		Req_Turntable_lottery = {
            Ops = CC.proto.client_treasure_pb.Req_Turntable_lottery,
			ReqProto = "TsLotteryReq",
			RspProto = "TsLotteryResp",
			Timeout = 10,
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
			Note = "夺宝转盘抽奖",
		},
		ReqLotteryInfo = {
            Ops = CC.proto.client_treasure_pb.Req_Turntable_Times,
			RspProto = "TsLotteryTimesResp",
			Timeout = 10,
			ReqUrlMethod = CC.Network.RequestTreasureHttp,
			Note = "夺宝转盘次数",
		},
		ReqCommonBatteryInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqCommonBatteryInfo,
			RspProto = "CommonBatteryInfoRsp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			ExceptView = {"HallView"},
			Note = "炮台合成信息",
		},
		ReqCommonBatteryRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqCommonBatteryRecord,
			RspProto = "CommonBatteryRecordRsp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "炮台合成记录",
		},
		ReqCommonBatteryFree = {
			Ops = CC.proto.shared_operation_pb.OP_ReqCommonBatteryFree,
			RspProto = "PropExchangeData",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqCommonBatteryShare = {
			Ops = CC.proto.shared_operation_pb.OP_ReqCommonBatteryShare,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqGetExchangeList = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetExchangeList,
			ReqProto = "GetExchangeListReq",
			RspProto = "GetExchangeListResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqExchangeBattery = {
			Ops = CC.proto.shared_operation_pb.OP_ReqExchange,
			ReqProto = "ExchangeReq",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqHolyBeastBatteryLottery = {
			Ops = CC.proto.shared_operation_pb.OP_ReqHolyBeastBatteryLottery,
			ReqProto = "HolyBeastBatteryLotteryReq",
			RspProto = "HolyBeastBatteryLotteryResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqCompositeJPPool = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetCombineEggPool,
			RspProto = "CombineEggJPResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqCompositeMulRank = {
			Ops = CC.proto.client_compose_pb.Ops_Rank,
			ReqProto = "MulRankReq",
			RspProto = "MulRankResp",
			ReqUrlMethod = CC.Network.RequestCompositeHttp,
		},
		ReqCompositeBroadcast = {
			Ops = CC.proto.client_compose_pb.Ops_Broadcast,
			RspProto = "MulBroadcastResp",
			ReqUrlMethod = CC.Network.RequestCompositeHttp,
		},
		ReqCompositeDo = {
			Ops = CC.proto.client_compose_pb.Ops_Compose,
			ReqProto = "ComposeReq",
			RspProto = "ComposeResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestCompositeHttp,
			Note = "合成活动合成请求",
		},
		ReqCompositeHasJP = {
			Ops = CC.proto.client_compose_pb.Ops_JP_Info,
			RspProto = "GetHitJPInfoResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestCompositeHttp,
			Note = "合成JP中奖详情",
		},
		ReqCompositeGetJP = {
			Ops = CC.proto.client_compose_pb.Ops_JP_Award,
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestCompositeHttp,
			Note = "合成JP奖励",
		},
		ReqCompositeExchange = {
			Ops = CC.proto.client_compose_pb.Ops_Exchange,
			ReqProto = "MaterialExchangeReq",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestCompositeHttp,
			Note = "合成材料兑换",
		},
		ReqGetWhiteAccount = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWhiteAccount,
			RspProto = "GetWhiteAccountResp",
			Note = "超v白名单",
		},
		ReqCombineEgg = {
			Ops = CC.proto.shared_operation_pb.OP_ReqCombineEgg,
			ReqProto = "TwistEgg",
			RspProto = "TwistEggReward",
			timeout = 15,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "合成扭蛋",
		},
		ReqGetCombineEggRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetCombineEggRecord,
			RspProto = "TwistEggRecordResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqGetCombineEggMarquee = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetCombineEggMarquee,
			RspProto = "CombineEggMarqueeResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqBirthdayData = {
			Ops = CC.proto.client_ops_pb.Req_BirthdayData,
			ReqProto = "BirthdayDataReq",
			RspProto = "BirthdayDataResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
		},
		ReqBirthdayPrize = {
			Ops = CC.proto.client_ops_pb.Req_ReceiveGift,
			ReqProto = "BirthdayPrizeReq",
			RspProto = "BirthdayPrizeResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
		},
		ReqUpdateBirth = {
			Ops = CC.proto.client_ops_pb.Req_UpdateBirth,
			ReqProto = "UpdateBirthReq",
			RspProto = "UpdateBirthResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
		},
		ReqWaterRankData = {
			Ops = CC.proto.client_ops_pb.Req_Uc_Rank_Data,
			ReqProto = "RankReq",
			RspProto = "RankResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "流水排行榜",
		},
		ReqOpenPrize = {
			Ops = CC.proto.client_ops_pb.Req_Uc_OpenPrize,
			ReqProto = "ReceiveRankReq",
			RspProto = "ReceiveRankResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "流水榜宝箱",
		},
		ReqManageOneTimeLimit = {
			Ops = CC.proto.shared_operation_pb.OP_ReqManageOneTimeLimit,
			ReqProto = "SetOneTimeLimit",
			RspProto = "SetOneTimeLimitResp",
			Timeout = 15,
			Note = "赠送设置单笔限制",
		},
		ReqManageDailyLimit = {
			Ops = CC.proto.shared_operation_pb.OP_ReqManageDailyLimit,
			ReqProto = "SetDailyLimit",
			RspProto = "SetDailyLimitResp",
			Timeout = 15,
			Note = "赠送设置每日限制",
		},
		ReqRechargeInfo = {
			Ops = CC.proto.client_ops_pb.Req_Recharge_Info,
			RspProto = "RechargeInfoResp",
			ReqUrlMethod = CC.Network.RequestRechargeHttp,
			ExceptView = {"HallView"},
			Note = "累冲信息",
		},
		ReqRechargeJP = {
			Ops = CC.proto.client_ops_pb.Req_Recharge_JP,
			RspProto = "JPInfoResp",
			ReqUrlMethod = CC.Network.RequestRechargeHttp,
		},
		ReqRechargeOpenBox  = {
			Ops = CC.proto.client_ops_pb.Req_Recharge_OpenBox,
			ReqProto = "OpenBoxReq",
			RspProto = "OpenBoxResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestRechargeHttp,
			Note = "累冲打开宝箱",
		},
		ReqRechargeLotteryList   = {
			Ops = CC.proto.client_ops_pb.Req_Recharge_LotteryList,
			RspProto = "LotteryListResp",
			ReqUrlMethod = CC.Network.RequestRechargeHttp,
		},
		ReqRechargeRank   = {
			Ops = CC.proto.client_ops_pb.Req_Recharge_Rank,
			RspProto = "RechargeRankResp",
			ReqUrlMethod = CC.Network.RequestRechargeHttp,
		},
		ReqBCTaskList   = {
			Ops = CC.proto.client_ops_pb.Req_BC_TaskList,
			ReqProto = "TaskListReq",
			RspProto = "TaskListResp",
			ReqUrlMethod = CC.Network.RequestBlockchainHttp,
			Note = "火币获取任务列表",
		},
		ReqBCToken   = {
			Ops = CC.proto.client_ops_pb.Req_BC_Token,
			ReqProto = "TokenReq",
			RspProto = "TokenResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestBlockchainHttp,
			Note = "火币获取Token",
		},
		ReqBCReceive   = {
			Ops = CC.proto.client_ops_pb.Req_BC_Receive,
			ReqProto = "ReceiveReq",
			RspProto = "ReceiveResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestBlockchainHttp,
			Note = "领取算力值",
		},
		ReqBCReceiveHCoin   = {
			Ops = CC.proto.client_ops_pb.Req_BC_ReceiveHCoin,
			ReqProto = "ReceiveHCoinReq",
			RspProto = "ReceiveHCoinResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestBlockchainHttp,
			Note = "领取火币",
		},
		ReqBCPowerList   = {
			Ops = CC.proto.client_ops_pb.Req_BC_PowerList,
			ReqProto = "PowerListReq",
			RspProto = "PowerListResp",
			ReqUrlMethod = CC.Network.RequestBlockchainHttp,
			Note = "算力记录",
		},
		ReqBCHCoinList   = {
			Ops = CC.proto.client_ops_pb.Req_BC_HCoinList,
			ReqProto = "HCoinListReq",
			RspProto = "HCoinListResp",
			ReqUrlMethod = CC.Network.RequestBlockchainHttp,
			Note = "火币记录",
		},
		ReqBCShare   = {
			Ops = CC.proto.client_ops_pb.Req_BC_Share,
			ReqProto = "BcShareReq",
			RspProto = "BcShareResp",
			Timeout = 15,
			ReqUrlMethod = CC.Network.RequestBlockchainHttp,
			Note = "火币分享",
		},
		Req_ClientRecord = {
			Ops = CC.proto.client_ops_pb.Req_ClientRecord,
			ReqUrlMethod = CC.Network.RequestLogHttp,
			Note = "客户端打点",
		},
		TikipayPurchase = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTikipayPurchase,
			ReqProto = "TikipayPurchase",
			RspProto = "TikipayPurchaseResp",
			Timeout = 15,
			Note = "Tikipay支付",
		},
		---------------------新游上线---------------------
		ReqLimitStatus = {
			Ops = CC.proto.client_ops_pb.Req_limit_status,
			ReqProto = "LimitStatusReq",
			RspProto = "LimitStatusResp",
			ReqUrlMethod = CC.Network.RequestOnlineLimitHttp,
			Timeout = 15,
			Note = "新游预约状态",
		},
		ReqSubscribeAdd = {
			Ops = CC.proto.client_ops_pb.Req_limit_subscribeAdd,
			ReqProto = "SubscribeAddReq",
			RspProto = "SubscribeAddResp",
			ReqUrlMethod = CC.Network.RequestOnlineLimitHttp,
			Timeout = 15,
			Note = "新游立即预约请求",
		},
		ReqSubscribeList = {
			Ops = CC.proto.client_ops_pb.Req_limit_subscribeList,
			ReqProto = "SubscribeListReq",
			RspProto = "SubscribeListResp",
			ReqUrlMethod = CC.Network.RequestOnlineLimitHttp,
		},
		ReqCancelQueue = {
			Ops = CC.proto.client_ops_pb.Req_limit_cancelQueue,
			ReqProto = "CancelQueueReq",
			RspProto = "CancelQueueResp",
			ReqUrlMethod = CC.Network.RequestOnlineLimitHttp,
		},
		ReqLimitGameTimeList = {
			Ops = CC.proto.client_ops_pb.Req_limit_getGameTimeList,
			RspProto = "GetGameTimeListResp",
			ReqUrlMethod = CC.Network.RequestOnlineLimitHttp,
		},
		ReqNewVersionReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqNewVersionReward,
			ReqProto = "VersionReward",
			Note = "版本更新奖励",
		},
		ReqUnlockLevel = {
			Ops = CC.proto.shared_operation_pb.OP_ReqUnlockLevel,
			Note = "打开一级锁"
		},
		---------------------------------------------------
		ReqUnbindTelBySMS = {
			Ops = CC.proto.shared_operation_pb.OP_ReqUnbindTelBySMS,
			ReqProto = "UnbindTelBySMS",
			Note = "解绑手机"
		},
		ReqModifyNicknameByCard = {
			Ops = CC.proto.shared_operation_pb.OP_ReqModifyNicknameByCard,
			ReqProto = "ModifyNicknameByCard",
			Note = "改名卡52"
		},
		ReqBuy = {
			Ops = CC.proto.client_pack_pb.Req_Buy,
			ReqProto = "BuyStatusReq",
			ReqUrlMethod = CC.Network.RequestGiftPackHttp,
			Note = "临时秒杀礼包购买"
		},

		ReqFreeTimesAdd = {
			Ops = CC.proto.client_daily_lotery_pb.Req_Free_Times_Add,
			ReqProto = "LotteryFreeTimesAddReq",
			ReqUrlMethod = CC.Network.RequestFreeLotteryHttp,
		},
		ReqFreeTimesGet = {
			Ops = CC.proto.client_daily_lotery_pb.Req_Free_Times_Get,
			ReqProto = "LotteryFreeTimesGetReq",
			RspProto = "LotteryFreeTimesGetResp",
			ReqUrlMethod = CC.Network.RequestFreeLotteryHttp,
		},
		ReqFreeLottery = {
			Ops = CC.proto.client_daily_lotery_pb.Req_Free_Lottery,
			ReqProto = "LotteryFreeReq",
			RspProto = "LotteryFreeResp",
			ReqUrlMethod = CC.Network.RequestFreeLotteryHttp,
		},
		ReqFreeInviteList = {
			Ops = CC.proto.client_daily_lotery_pb.Req_Free_Invite_List,
			ReqProto = "LotteryFreeInviteListReq",
			RspProto = "LotteryFreeInviteListRes",
			ReqUrlMethod = CC.Network.RequestFreeLotteryHttp,
		},
		ReqFreeAwardList = {
			Ops = CC.proto.client_daily_lotery_pb.Req_Free_Award_List,
			ReqProto = "LotteryFreeAwardListReq",
			RspProto = "LotteryFreeAwardListRes",
			ReqUrlMethod = CC.Network.RequestFreeLotteryHttp,
		},
		ReqTradeProp = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTradeProp,
			ReqProto = "TradeProp",
		},
		ReqLoadTradePropSended = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadTradePropSended,
			RspProto = "TradePropRecords",
		},
		---------------------------------------------------
		ReqGetLuckyRouletteTaskInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetLuckyRouletteTaskInfo,
			RspProto = "GetLuckyRouletteTaskInfoResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqGetGoldOwnerList = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetGoldOwnerList,
			RspProto = "GetGoldOwnerListResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqGetLuckyRouletteTaskReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetLuckyRouletteTaskReward,
			ReqProto = "GetLuckyRouletteTaskReward",
			RspProto = "GetLuckyRouletteTaskRewardResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqGetLuckyRouletteResult = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetLuckyRouletteResult,
			ReqProto = "GetLuckyRouletteResult",
			RspProto = "GetLuckyRouletteResultResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqGetLuckyRouletteRewardRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetLuckyRouletteRewardRecord,
			ReqProto = "GetLuckyRouletteRewardRecord",
			RspProto = "GetLuckyRouletteRewardRecordResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqGetLuckyRouletteRank = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetLuckyRouletteRank,
			ReqProto = "GetLuckyRouletteRank",
			RspProto = "GetLuckyRouletteRankResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqGetGetKeyBoxInfoList = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetGetKeyBoxInfoList,
			RspProto = "GetKeyBoxInfoListResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqOpenKeyBox = {
			Ops = CC.proto.shared_operation_pb.OP_ReqOpenKeyBox,
			ReqProto = "OpenKeyBox",
			RspProto = "OpenKeyBoxResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqLoadOldPlayerReturnStatus = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoadOldPlayerReturnStatus,
			RspProto = "LoadOldPlayerReturnStatusResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqSendReturnReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqSendReturnReward,
			ReqProto = "SendReturnRewardReq",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqCheckOldPlayer = {
			Ops = CC.proto.shared_operation_pb.OP_ReqCheckOldPlayer,
			RspProto = "CheckOldPlayerResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqOldPlayerReturnShare = {
			Ops = CC.proto.shared_operation_pb.OP_ReqOldPlayerReturnShare,
			ReqUrlMethod = CC.Network.RequestActivityHttp,
		},
		ReqQueueData = {
			Ops = CC.proto.client_ops_pb.Req_Queue_Data,
			RspProto = "QueueDataResp",
			ReqUrlMethod = CC.Network.RequestLoginQueueHttp,
			NotErrorTip = true
		},
		ReqQueueHeartbeat = {
			Ops = CC.proto.client_ops_pb.Req_Queue_Heartbeat,
			ReqUrlMethod = CC.Network.RequestLoginQueueHttp,
			NotErrorTip = true
		},
		ReqQueuePush = {
			Ops = CC.proto.client_ops_pb.Req_Queue_Push,
			ReqUrlMethod = CC.Network.RequestLoginQueueHttp,
			NotErrorTip = true
		},
		ReqDonateNums = {
			Ops = CC.proto.client_time_activities_pb.Req_Donate_Nums,
			ReqProto = "DonateNumsReq",
			RspProto = "DonateNumsResp",
			ReqUrlMethod = CC.Network.RequestTimeActivitiesHttp,
			Note = "请求功德捐献数量"
		},
		ReqDonate = {
			Ops = CC.proto.client_time_activities_pb.Req_Donate,
			ReqProto = "DonateReq",
			ReqUrlMethod = CC.Network.RequestTimeActivitiesHttp,
			Note = "请求捐献"
		},
		ReqDonateRankRecord = {
			Ops = CC.proto.client_time_activities_pb.Req_Rank_Record,
			ReqProto = "RankRecordReq",
			RspProto = "RankRecordResp",
			ReqUrlMethod = CC.Network.RequestTimeActivitiesHttp,
			Note = "请求捐献排行榜"
		},
		ReqDonateBroadCast = {
			Ops = CC.proto.client_time_activities_pb.Req_BroadCast_Record,
			ReqProto = "BroadCastReq",
			RspProto = "BroadCastResp",
			ReqUrlMethod = CC.Network.RequestTimeActivitiesHttp,
			Note = "请求捐献跑马灯"
		},
		ReqSynOnlineTime = {
			Ops = CC.proto.shared_operation_pb.OP_ReqPing,
			Note = "请求同步在线时长"
		},
		ReqGetMothCardUseInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetMothCardUseInfo,
			RspProto = "GetMothCardPowerInfoResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "查询月卡权益使用详情"
		},
		ReqTakeMothCardDaily = {
			Ops = CC.proto.shared_operation_pb.OP_ReqTakeMothCardDaily,
			ReqProto = "OnTakeMothCardDailyReq",
			RspProto = "OnTakeMothCardDailyResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "领取月卡每日奖励"
		},
		GetHalloween10thbGiftInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetHalloween10thbGiftInfo,
			RspProto = "Halloween10thbGiftInfoResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "请求万圣节10THB礼包信息",
		},
		GetHalloween10thbGiftReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetHalloween10thbGiftReward,
			RspProto = "Halloween10thbGiftRewardResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "请求领取万圣节10THB礼包每日奖励",
		},
		ReqSetSafe = {
			Ops = CC.proto.client_ops_pb.Req_Set_Safe,
			ReqProto = "SetSafePwdReq",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "请求设置安全码",
		},
		ReqSafeData = {
			Ops = CC.proto.client_ops_pb.Req_Safe_Data,
			ReqProto = "GetSafeReq",
			RspProto = "GetSafeResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "查询安全码以及服务状态",
		},
		ReqCofferGuide = {
			Ops = CC.proto.client_ops_pb.Req_Coffer_Guide,
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "请求设置保险箱引导",
		},
		ReqSafeVerify = {
			Ops = CC.proto.client_ops_pb.Req_Safe_Verify,
			ReqProto = "SafeVerifyReq",
			RspProto = "SafeVerifyResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "请求校验安全码",
		},
		ReqSafeReset = {
			Ops = CC.proto.client_ops_pb.Req_Safe_Reset,
			ReqProto = "ResetSafeReq",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "请求重置安全码",
		},
		ReqCofferData = {
			Ops = CC.proto.client_ops_pb.Req_Coffer_Data,
			RspProto = "CofferDataResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "请求保险箱信息",
		},
		ReqCofferDeposit = {
			Ops = CC.proto.client_ops_pb.Req_Coffer_Deposit,
			ReqProto = "DepositReq",
			RspProto = "DepositResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "请求转入到保险箱",
		},
		ReqCofferWithdrawal = {
			Ops = CC.proto.client_ops_pb.Req_Coffer_Withdrawal,
			ReqProto = "WithdrawalReq",
			RspProto = "WithdrawalResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "请求从保险箱转出",
		},
		ReqCofferReceive = {
			Ops = CC.proto.client_ops_pb.Req_Coffer_Receive,
			RspProto = "GetReceiveListReq",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "请求保险箱转入转出记录",
		},
		ReqGetRealAuthInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetRealAuthInfo,
			ReqProto = "GetRealAuth",
			RspProto = "GetRealAuthResp",
			Note = "查询实名认证状态请求",
		},
		ReqGetBrithRealInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetBirthAuthInfo,
			ReqProto = "GetBrithAuthReq",
			RspProto = "GetBirthAuthResp",
			Note = "查询生日实名认证状态",
		},
		ReqGetPlayerType = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetPlayerType,
			RspProto = "GetPlayerTypeResp",
			Note = "查询玩家异常状态",
		},
		ActivityRankData = {
			Ops = CC.proto.client_ops_pb.Req_Activity_Rank_Data,
			ReqProto = "RankReq",
			RspProto = "RankResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "活动总流水排行榜",
		},
		--IP查询
		ReqAuthIPReq = {
			Ops = CC.proto.client_ops_pb.Req_Auth_Ip_req,
			ReqProto = "AnalysisIPReq",
			RspProto = "AuthIpResp",
			ReqUrlMethod = CC.Network.RequestIPHttp,
			Note = "IP检测",
		},
		--手机登录
		ReqGetTokenByPhone = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetTokenByPhone,
			ReqProto = "GetTokenByPhoneReq",
			ReqUrlMethod = CC.Network.RequestAuthHttp,
			Note = "获取验证码",
		},
		ReqVerifyPhoneToken = {
			Ops = CC.proto.shared_operation_pb.OP_ReqVerifyPhoneToken,
			ReqProto = "VerifyPhoneTokenReq",
			RspProto = "VerifyPhoneTokenResp",
			ReqUrlMethod = CC.Network.RequestAuthHttp,
			Note = "校验验证码",
		},
		ReqLoginByPhone = {
			Ops = CC.proto.shared_operation_pb.OP_ReqLoginByPhone,
			ReqProto = "LoginByPhoneRes",
			RspProto = "TokenInfo",
			ReqUrlMethod = CC.Network.RequestAuthHttp,
			Note = "手机登录",
		},
		ReqGetAppRateInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetAppRateInfo,
			RspProto = "VerifyAppRateResp",
			Note = "请求五星好评状态"
		},
		ReqSendRewardForAppRate = {
			Ops = CC.proto.shared_operation_pb.OP_ReqSendRewardForAppRate,
			Note = "请求五星好评奖励"
		},
		-------------google结算库v3-----------
		ReqGetGooglePurchaseVerify = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetGooglePurchaseVerify,
			ReqProto = "GooglePurchaseVerify",
			Note = "google新校验接口",
		},
		ReqGetGoogleVerifyingOrder = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetGoogleVerifyingOrder,
			RspProto = "GetVerifyingOrderResp",
			Note = "获取未消耗的google订单",
		},
		ReqGoolePurchaseSendReward = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGoolePurchaseSendReward,
			ReqProto = "GooglePurchaseVerify",
			Note = "google商品消耗成功通知",
		},
		---------------泼水节任务Start---------------
		Req_UW_GetTask = {
			Ops = CC.proto.client_ops_pb.Req_UW_GetTask,
			RspProto = "UWTaskListResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "泼水节任务-获取任务",
		},
		Req_UW_Upgrade = {
			Ops = CC.proto.client_ops_pb.Req_UW_Upgrade,
			RspProto = "UWUpgradeTaskResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "泼水节任务-沙塔升级",
		},
		Req_UW_BuyUnLockGirt = {
			Ops = CC.proto.client_ops_pb.Req_UW_BuyUnLockGirt,
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "泼水节任务-购买解锁礼包",
		},
		Req_UW_GetWinPrizeList = {
			Ops = CC.proto.client_ops_pb.Req_UW_GetWinPrizeList,
			RspProto = "UWJpPrizeList",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "泼水节任务-中奖名单",
		},
		Req_UW_ShareTask = {
			Ops = CC.proto.client_ops_pb.Req_UW_ShareTask,
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "泼水节任务-分享",
		},
		----------------泼水节任务End----------------
		ReqGetPortraitList = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetPortraitList,
			RspProto = "GetPortraitListResp",
			Note = "获取头像列表",
		},
		----------------火星任务Start----------------
		Req_UW_MarsGetTask = {
			Ops = CC.proto.client_ops_pb.Req_UW_MarsGetTask,
			RspProto = "UWTaskListResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "火星任务-获取当前任务详情",
		},
		Req_UW_MarsUpgrade = {
			Ops = CC.proto.client_ops_pb.Req_UW_MarsUpgrade,
			RspProto = "UWUpgradeTaskResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "火星任务-升级",
		},
		Req_UW_MarsBuyUnLockGirt = {
			Ops = CC.proto.client_ops_pb.Req_UW_MarsBuyUnLockGirt,
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "火星任务-购买解锁礼包",
		},
		Req_UW_MarsGetWinPrizeList = {
			Ops = CC.proto.client_ops_pb.Req_UW_MarsGetWinPrizeList,
			RspProto = "UWJpPrizeList",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "火星任务-中奖名单",
		},
		Req_UW_MarsShareTask = {
			Ops = CC.proto.client_ops_pb.Req_UW_MarsShareTask,
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "火星任务-分享",
		},
		Req_UW_MarsGetList = {
			Ops = CC.proto.client_ops_pb.Req_UW_MarsGetList,
			RspProto = "UWMTaskListResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "火星任务-获取任务列表",
		},
		Req_UW_MarsReceiveSubTaskAward = {
			Ops = CC.proto.client_ops_pb.Req_UW_MarsReceiveSubTaskAward,
			ReqProto = "UWMSubTaskAwardReq",
			RspProto = "UWMSubTaskAwardResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "火星任务-领取子任务奖励",
		},
		Req_UW_MarsGetLevelAwardList = {
			Ops = CC.proto.client_ops_pb.Req_UW_MarsGetLevelAwardList,
			RspProto = "UWMLevelAwardListResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "火星任务-获取阶层奖品列表",
		},
		Req_UW_MarsReceiveLevelAward = {
			Ops = CC.proto.client_ops_pb.Req_UW_MarsReceiveLevelAward,
			ReqProto = "UWMSReceiveLevelAwardReq",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "火星任务-领取阶层奖励",
		},
		Req_UW_MarsGetMTaskRank = {
			Ops = CC.proto.client_ops_pb.Req_UW_MarsGetMTaskRank,
			RspProto = "UWMRankResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "火星任务-获取排名榜",
		},
		-----------------火星任务End-----------------
		ReqGetBatteryRank = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetBatteryRank,
			ReqProto = "GetRank",
			RspProto = "GetRankResp",
			Note = "炮台排行榜",
		},
		ReqOnGetMyBatterys = {
			Ops = CC.proto.shared_operation_pb.OP_ReqOnGetMyBatterys,
			ReqProto = "GetMyBatterys",
			RspProto = "LoadPropsResp",
			-- ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "获取玩家拥有炮台",
		},
		ReqGetWorldCupHomePage = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWorldCupHomePage,
			RspProto = "WorldCupHomePageResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "世界杯主界面信息",
		},
		ReqGetWorldCupTimeRange = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWorldCupTimeRange,
			RspProto = "WorldCupTimeRangeResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "世界杯赛程起止时间",
		},
		ReqGetWorldCupSchedule = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWorldCupSchedule,
			ReqProto = "WorldCupScheduleReq",
			RspProto = "WorldCupScheduleResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "世界杯赛程信息",
		},
		ReqGetWorldCupChampionSchedule = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWorldCupChampionSchedule,
			RspProto = "WorldCupChampionScheduleResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "世界杯冠军赛赛程信息",
		},
		ReqGetWorldCupMarquee = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWorldCupMarquee,
			RspProto = "WorldCupMarqueeResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "世界杯随机跑马灯",
		},
		ReqGetWorldCupGameInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWorldCupGameInfo,
			ReqProto = "WorldCupGameInfoReq",
			RspProto = "WorldCupGameInfoResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "世界杯单场比赛信息",
		},
		ReqGetWorldCupBetInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWorldCupBetInfo,
			ReqProto = "WorldCupGameInfoReq",
			RspProto = "WorldCupBetInfoResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "世界杯单场比赛下注信息",
		},
		ReqPlayerBet = {
			Ops = CC.shared_operation_pb.OP_ReqPlayerBet,
			ReqProto = "PlayerBetReq",
			RspProto = "PlayerBetResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "世界杯1v1比赛下注",
		},
		ReqWorldCupPlayerLike = {
			Ops = CC.shared_operation_pb.OP_ReqWorldCupPlayerLike,
			ReqProto = "WorldCupPlayerLikeReq",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "世界杯1v1比赛点赞",
		},
		ReqWorldCupGuessInfo = {
			Ops = CC.shared_operation_pb.OP_ReqGetWorldCupChampionGameInfo,
			RspProto = "WorldCupChampionGameInfoResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "世界杯冠军竞猜信息",
		},
		ReqGetWorldCupRank = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWorldCupRankInfo,
			ReqProto = "GetRank",
			RspProto = "GetWorldCupRankInfo",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "拉取世界杯排行榜",
		},
		ReqGetWorldJackpot = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWorldCupJackpotInfo,
			RspProto = "WorldCupJackpotInfoResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "拉取世界杯Jackpot",
		},
		ReqGetWorldCupBetRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWorldCupBetRecord,
			ReqProto = "GetWorldCupBetRecordReq",
			RspProto = "WorldCupBetRecordResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "投注记录",
		},
		ReqGetWorldCupWinRecord = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWorldCupWinRecord,
			ReqProto = "GetWorldCupBetRecordReq",
			RspProto = "WorldCupBetRecordResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "中奖记录",
		},
		ReqWorldCupBuyGiftInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetWorldCupGiftPackInfo,
			RspProto = "GetWorldCupGiftPackResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "请求世界杯礼包信息",
		},
		ReqGetChampionInfo = {
			Ops = CC.proto.shared_operation_pb.OP_ReqGetChampionCountry,
			RspProto = "GetChampionCountryResp",
			ReqUrlMethod = CC.Network.RequestActivityHttp,
			Note = "请求世界冠军信息",
		},
		ReqFlowTaskList = {
			Ops = CC.proto.client_ops_pb.Req_UW_FlowTaskList,
			RspProto = "UWFlowTaskResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "世界杯流水任务",
		},
		ReqFlowTaskReceive = {
			Ops = CC.proto.client_ops_pb.Req_UW_FlowTaskReceive,
			ReqProto = "UWFlowTaskReceiveReq",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "世界杯流水任务领取",
		},
		ReqFlowTaskShare = {
			Ops = CC.proto.client_ops_pb.Req_UW_FlowTaskShare,
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "世界杯流水任务分享",
		},
		Req_UW_PLLottery = {
			Ops = CC.proto.client_ops_pb.Req_UW_PLLottery,
			ReqProto = "UWPrayLLotteryReq",
			RspProto = "UWPrayLLotteryResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "新年祈福抽奖",
		},
		Req_UW_PLotteryData = {
			Ops = CC.proto.client_ops_pb.Req_UW_PLotteryData,
			RspProto = "UWPrayLotteryResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "新年祈福抽奖信息",
		},
		Req_UW_PLotteryTaskReceive = {
			Ops = CC.proto.client_ops_pb.Req_UW_PLotteryTaskReceive,
			ReqProto = "UWPrayLotteryReceiveReq",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "新年祈福任务领取",
		},
		Req_UW_PLotteryRank = {
			Ops = CC.proto.client_ops_pb.Req_UW_PLotteryRank,
			RspProto = "UWPrayLotteryRankResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "新年祈福抽奖次数排行榜",
		},
		Req_UW_PLotteryWinPrize = {
			Ops = CC.proto.client_ops_pb.Req_UW_PLotteryWinPrize,
			RspProto = "UWPrayLotteryPrizeResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "新年祈福中奖名单",
		},
		Req_UW_MonopolyGetUserInfo = {
			Ops = CC.proto.client_ops_pb.Req_UW_MonopolyGetUserInfo,
			ReqProto = "UWMonopolyInfoReq",
			RspProto = "UWMonopolyInfoResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "大富翁基础信息",
		},
		Req_UW_MonopolyPlay = {
			Ops = CC.proto.client_ops_pb.Req_UW_MonopolyPlay,
			ReqProto = "UWMonopolyPlayReq",
			RspProto = "UWMonopolyPlayResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "大富翁投骰",
		},
		Req_UW_MonopolyGiftBagList = {
			Ops = CC.proto.client_ops_pb.Req_UW_MonopolyGiftBagList,
			ReqProto = "UWMonopolyGiftBagReq",
			RspProto = "UWMonopolyGiftBagResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "大富翁礼包列表",
		},
		Req_UW_MonopolyGiftChange = {
			Ops = CC.proto.client_ops_pb.Req_UW_MonopolyGiftBagChange,
			ReqProto = "UWMonopolyGiftBagChangeReq",
			RspProto = "UWMonopolyGiftBagChangeResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "大富翁礼包购买完成",
		},
		Req_UW_MonopolyListRanks = {
			Ops = CC.proto.client_ops_pb.Req_UW_MonopolyListRanks,
			ReqProto = "UWMonopolyRankReq",
			RspProto = "UWMonopolyRankResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "泼水节大富翁排行榜",
		},
		Req_UW_MonthData = {
			Ops = CC.proto.client_ops_pb.Req_UW_MonthData,
			RspProto = "UWMonthDataResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "月度返利数据",
		},
		Req_UW_MonthReceive = {
			Ops = CC.proto.client_ops_pb.Req_UW_MonthReceive,
			ReqProto = "UWMonthReceiveReq",
			RspProto = "UWMonthReceiveResp",
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "月度返利领取奖励",
		},
		Req_UW_UpdateStatus = {
			Ops = CC.proto.client_ops_pb.Req_UW_UpdateStatus,
			ReqUrlMethod = CC.Network.RequestUserWelfareHttp,
			Note = "月度返利状态修改",
		},
	}


	--服务器主推协议号
	NetworkHelper.OnPushName = {}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushFriendApplied] = {proto = "FriendApplied", method = "OnFriendApplied"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushPropChanged] = {proto = "PropChanged", method = "OnPropChanged"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushChat] = {proto = "Chat", method = "OnChat"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushMailComming] = {proto = "MailComming", method = "OnMailComming"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushInviteNotification] = {proto = "InviteNotification", method = "OnInviteNotification"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushChatData] = {proto = "PChat", method = "OnChatData"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushJackpots] = {proto = "Jackpots", method = "OnJackpots"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushPayMent] = {proto = "PayMent", method = "OnPayMent"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushFristPay] = {proto = "FristPay", method = "OnFristPay"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushPurchase] = {proto = "PurchaseNotify", method = "OnPurchaseNotify"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushSevenDays] = {proto = "SevenDays", method = "OnSevenDays"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushFriendAdded] = {proto = "FriendAdded", method = "OnFriendAdded"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushNotifyFriendsOnline] = {proto = "FriendOnline", method = "OnFriendOnline"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushNotifyFriendsOffline] = {proto = "FriendOffline", method = "OnFriendOffline"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushFriendDeleted] = {proto = "FriendDeleted", method = "OnFriendDeleted"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushKicked] = {proto = "KickPlayer", method = "OnKickedPlayer"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushResourceVersionChanged] = {proto = "GetResourceVersionInfoRsp", method = "OnResourceVersonChanged"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushPromotionStatusChange] = {proto = "PromotionStatus", method = "OnPromotionStatusChanged"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushOnlineRewardStatusChanged] = {proto = "OnlineRewardStatusNotify",method = "OnOnlineRewardStatusChanged"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushSplashInfo] = {proto = "SplashInfoResp",method = "OnPushSplashInfo"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushNotifyPlayerIntoGame] = {proto = "NotifyPlayerIntoGameResp",method = "OnNotifyPlayerIntoGame"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushSupplyLucky] = {proto = nil,method = "OnPushSupplyLucky"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushPhysicalGoodsBuyInfo] = {proto = "RecordRecentResp",method = "OnPhysicalGoodsBuyInfo"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushPhysicalGoodsInfo] = {proto = "PhysicalGoodsInfo",method = "OnPhysicalGoodsInfo"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushMsignRollRank] = {proto = "MsBarrage",method = "OnPushMsignRollRank"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushChipReplenish] = {proto = "ChipReplenishInfo",method = "OnPushChipReplenish"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushTradeRankChanged ] = {proto = "TradeRankChanged",method = "OnPushTradeRankChanged"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushDailySpinInfo] = {proto = "DailySpinInfo",method = "OnDailySpinChanged"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushSpecialDailySpinInfo] = {proto = "DailySpinInfo",method = "OnSpecialDailySpinChanged"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushOnlineWelfare] = {proto = "OnlineWelfareInfo",method = "OnPushOnlineWelfare"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushOnlineWelfareShow] = {proto = "OnlineWelfareInfo",method = "OnPushOnlineWelfareShow"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushOnlineWelfarePre] = {proto = "OnlineWelfarePre",method = "OnPushOnlineWelfarePre"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushOnlineWelfareReward] = {proto = "OnlineWelfareReward",method = "OnPushOnlineWelfareReward"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushOnlineWelfareBigReward] = {proto = "OnlineWelfareBigReward",method = "OnPushOnlineWelfareBigReward"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushInviteIntoGame] = {proto = "InvitePlayerIntoGameResp",method = "OnInvitePlayerIntoGame"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushActivityInfo] = {proto = "ActivityDataResp",method = "OnPushActivityInfo"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushTransferGameMessage] = {proto = "TransferGameMessageResp",method = "OnPushTransferGameMessage"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushGameArena] = {proto = "GameArenaResp",method = "OnPushGameArena"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushWaterLampWish] = {proto = "WaterLampWishInfoResp",method = "OnPushWaterLampWish"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushTreasureOpenPrize] = {proto = "TsLuckyRecord",method = "OnPushTreasureOpenPrize"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushSuperTreasureOpenPrize] = {proto = "TsLuckyRecord",method = "OnPushSuperTreasureOpenPrize"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushLoadNews] = {proto = "LoadNews",method = "OnPushLoadNews"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushHallFunctionUpdate ] = {proto = "HallFunctionUpdate",method = "OnPushHallFunctionUpdate"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushNewYearMesage] = {proto = "NewYearMesage", method = "OnPushBlessAwardMessage"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushClearNew] = {proto = "ClearNew",method = "OnPushClearNew"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushMysteryElephantPiggy] = {proto = "MysteryElephantPiggy",method = "OnPushMysteryElephantPiggy"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushLuckySpinReward] = {proto = "LuckySpinRewardInfo",method = "OnPushLuckySpinReward"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushLuckySpinRewardMsg] = {proto = "LuckySpinRewardMsg",method = "OnPushLuckySpinRewardMsg"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushLuckySpinRecord] = {proto = "LuckSpinRecordResp",method = "OnPushLuckySpinRecord"}
	--扭蛋
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushTwistEggReward] = {proto = "TwistEggReward",method = "OnTwistEggReward"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushCombineEggReward] = {proto = "TwistEggReward",method = "OnCombineEggReward"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushCombineEggMarquee] = {proto = "CommonRewardRecord",method = "OnCombineEggMarquee"}

	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushDailyTreasureReward] = {proto = "DailyTreasureReward",method = "OnPushDailyTreasureReward"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushCommonRewards] = {proto = "CommonRewards",method = "OnPushDailyGiftRewards"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushMiniNotification] = {proto = "MiniNotify",method = "OnPushMiniNotification"}
	--NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushTimeNotify] = {proto = "TimeNotify",method = "OnPushTimeNotify"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushTimeNotify] = {proto = "TimeNotify",method = "OnPushTimeNotify"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushDailyGiftSignBigReward] = {proto = "DailyGiftSignBigRewardPush",method = "OnPushDailyGiftSignBigReward"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushAgentAttrNotify] = {proto = "AgentAttrNotify",method = "OnPushAgentAttrNotify"}
	-- 跑马灯滚幕播报
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushPublishActivityMsg] = {proto = "PublishActivityMsg",method = "OnPushActivityMsg"}
	-- 组队比赛
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushTeamNotify] = {proto = "TeamNotify",method = "OnPushTeamNotify"}
    --假日特惠
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushAugGiftPayBigRecord ] = {proto = "AugGiftPayRewardRecordPush",method = "OnAugGiftPayRewardRecord"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushAugGiftPayPopBigReward ] = {proto = "AugGiftPayPopBigRewardPush",method = "OnPushAugGiftPayPopBigReward"}
	--新手7日签到推送
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushNewPlayerSignBigReward] = {proto = "CommonRewards",method = "OnNewPlayerSignBigRewardPush"}
	--10元首冲
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushTenFristGiftBigReward  ] = {proto = "TenFristGiftBigRewardPush",method = "OnPushTenFristGiftBigReward"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushCatBatteryRecord] = {proto = "CommonRewardRecord",method = "OnPushCatBatteryRecord"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushRechargeActivityHasReward] = {proto = "",method = "PushRechargeActivityHasReward"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushRechargeActivityBigReward] = {proto = "CommonRewardRecord",method = "PushRechargeActivityBigReward"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushCommonBatteryRecord] = {proto = "CommonRewardRecord",method = "OnPushCommonBatteryRecord"}
	--新游预约可进游戏推送
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushOnlineLimitInGame] = {proto = "InGameInfo",method = "OnPushInGameInfo"}
	--周年庆幸运转盘跑马灯推送
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushLuckyRoulette] = {proto = "LuckyRouletteRewardNotify",method = "OnPushLuckyRoulette"}
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushSafePlayerFreeze] = {method = "OnPushSafePlayerFreeze"}
	--Google未消耗订单推送
	NetworkHelper.OnPushName[CC.proto.shared_operation_pb.OP_PushGoogleUnconsumedOrder] = {proto = "GetVerifyingOrderResp",method = "OnPushGoogleUnconsume"}

	--给每条请求协议配置一个消息事件
	for k,v in pairs(NetworkHelper.Cfg) do

		local key = string.format("NW_%s", k);

		CC.Notifications[key] = key;
	end
end

function NetworkHelper.MakeReqMessage(name)
	local reqCfg = NetworkHelper.Cfg[name];
	if not reqCfg then
		logError("---协议未配置：" .. name);
		return;
	end
	return NetworkHelper.MakeMessage(reqCfg.ReqProto);
end

function NetworkHelper.MakeMessage(name,buff)
	local msg = CC.proto.client_pb[name]
	if msg == nil then
		log("--------------协议不存在：" .. name)
	else
		msg = msg()
		if buff and buff ~= "" then
			if not CC.uu.SafeCallFunc( function () msg:ParseFromString(buff) end) then
				logError("--------------协议解析错误：" .. name)
				return
            end
        end
	end
	return msg
end

function NetworkHelper.MakeHttpMessage(name)
    local msg = NetworkHelper.MakeMessage("HttpMessage")
    if not NetworkHelper.RequestOps[name] then
        logError("---协议名字不存在：" .. name)
        return
    end
    msg.Ops = NetworkHelper.RequestOps[name]
    return msg
end

function NetworkHelper.DealHttpMessage(buff)
	local msg = CC.proto.client_pb["HttpResult"]
	msg = msg()
	if buff and buff ~="" then
		msg:ParseFromString(buff)
	end
	return msg
end

function NetworkHelper.RetrunOps(name)
	if not NetworkHelper.Cfg[name] then
		logError("---协议名字不存在：" .. name)
		return
	end
	return NetworkHelper.Cfg[name].Ops;
end

return NetworkHelper