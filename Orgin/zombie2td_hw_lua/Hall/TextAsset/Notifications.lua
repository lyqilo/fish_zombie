local Notifications = {
    changeSelfInfo = "changeSelfInfo",
    changeSelfHeadIcon = "changeSelfHeadIcon",
    changeSelfCountryIcon = "changeSelfCountryIcon",
    delFriend = "delFriend",
    reloadFriendList = "reloadFriendList",
    changeFriendRequestCount = "changeFriendRequestCount",
    showBtnAddFriend = "showBtnAddFriend",
    sendGifts = "sendGifts",
    changeBindingChips = "changeBindingChips",
    ReqUpdateFinish = "ReqUpdateFinish",
    ReqGroupListInfo = "ReqGroupListInfo",
    ReqServerAddress = "ReqServerAddress",
    --下载AssetsList文件
    DownloadAssetsList = "DownloadAssetsList",
    --游戏下载进度
    DownloadGame = "DownloadGame",
    --游戏下载失败
    DownloadFail = "DownloadFail",
    --大厅游戏可点击状态
    GameClickState = "GameClickState",
    --游戏暂停监听
    OnPause = "OnPause",
    --游戏唤醒监听
    OnResume = "OnResume", --ANdroid返回键点击监听
    OnMenuBack = "OnMenuBack",
    OnSocketStop = "OnSocketStop",
    --主动断开Socket
    OnConnectServer = "OnConnectServer",
    --重连链接服务器成功（断线重连--回到游戏）
    OnReConnectServer = "OnReConnectServer",
    --（登录--游戏）过程中网络Close或者Error
    OnLoginDisconnect = "OnLoginDisconnect",
    --(重连--游戏)过程中网络Close或者Error
    OnReLoginDisconnect = "OnReLoginDisconnect",
    --游戏中监听到网络Close或者Error
    OnDisconnect = "OnDisconnect",
    --(重连--游戏)过程中网络Close或者Error尝试重连多次无果，返回登录
    OnReLoginDisconnectToLogin = "OnReLoginDisconnectToLogin",
    unClickedBtnPlayTogether = "unClickedBtnPlayTogether",
    VipChanged = "VipChanged",
    OnSevenAward = "OnSevenAward",
    --二期
    --GiftRankClose = "GiftRankClose",

    ------------二期开发-----------
    --通知游戏回到大厅进行引导
    ExitToGuide = "ExitToGuide",
    --新增邮件
    MailAdd = "MailAdd",
    --读邮件
    MailOpen = "MailOpen",
    GiftRankClose = "GiftRankClose",
    GiftRankToChat = "GiftRankToChat",
    OnFriendRequestRedPoint = "OnFriendRequestRedPoint",
    OnPickPhotoBack = "OnPickPhotoBack",
	OnPickPhotoBytesBack = "OnPickPhotoBytesBack",
    OnPickIOSPhotoBack = "OnPickIOSPhotoBack",
    --充值成功
    OnPurchaseNotify = "OnPurchaseNotify",
    OnPushFriendRequest = "OnPushFriendRequest",
    OnPushFriendAdded = "OnPushFriendAdded",
    OnPushFriendIsLine = "OnPushFriendIsLine",
    SetDeleteFriend = "SetDeleteFriend",
    --奖池
    InitGameJackpots = "InitGameJackpots",
    --头像切换
    ChangeHeadIcon = "ChangeHeadIcon",
    --账号被顶,踢回登录界面
    OnPushKickedOut = "OnPushKickedOut",
    --昵称修改
    ChangeNick = "ChangeNick",
    --生日日期修改
    ChangeBirth = "ChangeBirth",
    --生日实名上传
    OnBirthUploadImage = "OnBirthUploadImage",
	--手机号修改
	ChangeTelephone = "ChangeTelephone",
    --聊天信息
    ChatFlash = "ChatFlash",
    --卡牌点击
    GameClick = "GameClick",
    --刷新大厅在线奖励状态
    OnlineAwardState = "OnlineAwardState",
    --刷新大厅在线奖励状态
    NoviceReward = "NoviceReward",
    -- 限时礼包购买成功
    OnLimitTimeGiftReward = "OnLimitTimeGiftReward",
    --强更版本号修改推送
    OnFroceUpdateVersionChanged = "OnFroceUpdateVersionChanged",
    --七日基金购买领取
    OnFundReward = "OnFundReward",
    --七日基金每日领取
    OnFundDailyReward = "OnFundDailyReward",
    --新手在线奖励直接切换活跃度在线奖励，
    OnlineRewardStatusChanged = "OnlineRewardStatusChanged",
    --每日礼包购买成功
    OnDailyGiftReward = "OnDailyGiftReward",
    --刷新聊天
    RefreshChat = "RefreshChat",
    --刷新私聊
    PriChat = "PriChat",
    PriChatPush = "PriChatPush",
    --提供给子游戏消息
    SubRcvSystemMsg = "SubRcvSystemMsg",
    --刷新红点状态
    OnRefreshRedPointState = "OnRefreshRedPointState",
    --推送泼水节信息
    OnPushSplashInfo = "OnPushSplashInfo",
    -- 水灯节
    OnUpdateWaterLampWishDataInfo = "OnUpdateWaterLampWishDataInfo",
    -- OnUpdateJackpot = "OnUpdateJackpot",
    -- OnUpdateWishProcess = "OnUpdateWishProcess",
    -- OnUpdateSelfWishTimes = "OnUpdateSelfWishTimes",
    -- OnLoyKraThongWishShow = "OnLoyKraThongWishShow",

    ReqGameInfoFinish = "ReqGameInfoFinish",
    OnpushShake = "OnpushShake",
    OnpushShakeClose = "OnpushShakeClose",
    -- 在线福利
    PushOnlineWelfare = "PushOnlineWelfare",
    --实物商城
    RefreshPhysicalGoodsInfo = "RefreshPhysicalGoodsInfo",
    RefreshRecordRecent = "RefreshRecordRecent",
    --一元夺宝
    SetTreasureInfoFinish = "SetTreasureInfoFinish",
    --超级夺宝
    SetSuperTreasureInfoFinish = "SetSuperTreasureInfoFinish",
    --推送夺宝开奖
    OnPushTreasureOpenPrize = "OnPushTreasureOpenPrize",
    --推送超级夺宝开奖
    OnPushSuperTreasureOpenPrize = "OnPushSuperTreasureOpenPrize",
    --开奖结束
    OnOpenPrizeFinish = "OnOpenPrizeFinish",
    -- 泼水节按钮状态
    OnRefreshWaterSprinklingBtn = "OnRefreshWaterSprinklingBtn",
    -- 排行榜合集
    OnRefreshRankBtnsList = "OnRefreshRankBtnsList",
    --每日转盘抽奖推送
    DailySpinChanged = "DailySpinChanged",
    --每日转盘vip0特殊逻辑推送
    SpecialDailySpinChanged = "SpecialDailySpinChanged",
    --刷新活动按钮
    OnRefreshActivityBtnsState = "OnRefreshActivityBtnsState",
    --刷新活动红点
    OnRefreshActivityRedDotState = "OnRefreshActivityRedDotState",
    --刷新礼包合集红点
    OnRefreshGiftRedDotState = "OnRefreshGiftRedDotState",
    --刷新礼包合集特效
    OnRefreshGiftEffectState = "OnRefreshGiftEffectState",
    --刷新跳转到新手礼包
    OnClickNoviceDes = "OnClickNoviceDes",
    OnRefreshJumpNovice = "OnRefreshJumpNovice",
    OnLimitTimeGiftShow = "OnLimitTimeGiftShow",
    OnLimitTimeGiftTimeOut = "OnLimitTimeGiftTimeOut",
    OnRefreshSelectGiftIcon = "OnRefreshSelectGiftIcon",
    FreeChipsCollectionClickState = "FreeChipsCollectionClickState",
    SelectGiftSwitchOnState = "SelectGiftSwitchOnState",
    GiftCollectionClickState = "GiftCollectionClickState",
    DailyGiftSwitchOnState = "DailyGiftSwitchOnState",
    OnShowFreeChipsCollectionView = "OnShowFreeChipsCollectionView",
    OnUrlOpenApplicationCallback = "OnUrlOpenApplicationCallback",
    OnNotifyGameInvited = "OnNotifyGameInvited",
    OnPlayerToArenaClick = "OnPlayerToArenaClick",
    OnPushTransferGameMessage = "OnPushTransferGameMessage",
    --开关变更推送
    HallFunctionUpdate = "HallFunctionUpdate",

    OnPushBlessAwardMsg = "OnPushBlessAwardMsg",
    OnChangeFreeChipsView = "OnChangeFreeChipsView",

    --排队推送进入游戏
    OnPushInGameInfo = "OnPushInGameInfo",
    --刷新预约游戏状态
    OnRefreshSubscribeList = "OnRefreshSubscribeList",

    -- 高V
    OnGuideStepAgent = "OnGuideStepAgent",
    OnReflashAgentReceiveBtns = "OnReflashAgentReceiveBtns",
    OnNewAgentStatus = "OnNewAgentStatus",
    OnChangeAgentView = "OnChangeAgentView",
    ----------彩票系统------------
    LotteryNetworkOpen = "LotteryNetworkOpen",
    LotteryNetworkClose = "LotteryNetworkClose",
    LotteryGameInfo = "LotteryGameInfo",
    PastLotteryRecord = "PastLotteryRecord",
    PurchaseRecord = "PurchaseRecord",
    PurchaseDetail = "PurchaseDetail",
    LoginWithTokenRsp = "LoginWithTokenRsp",
    PurchaseLotteryRsp = "PurchaseLotteryRsp",
    RandLotteryNumberRsp = "RandLotteryNumberRsp",
    RewardPoolDataChangeNtf = "RewardPoolDataChangeNtf",
    LotteryPropChange = "LotteryPropChange",
    LotteryLatternNtf = "LotteryLatternNtf",
    OpenRewardNtf = "OpenRewardNtf",
    FirstPrizeRecodeRsp = "FirstPrizeRecodeRsp",
    LotteryRankListRsp = "LotteryRankListRsp",
    LotteryPingRsp = "LotteryPingRsp",
    MysteryElephantPiggy = "MysteryElephantPiggy",
    --新手引导
    OnNotifyGuide = "OnNotifyGuide",
    OnNotifyExitSelection = "OnNotifyExitSelection",
    OnNotifyHallFirst = "OnNotifyHallFirst",
    OnNotifyHallPos = "OnNotifyHallPos",
    OnHighlightInfo = "OnHighlightInfo",
    --slot子游戏新手引导
    OnSlotNotifyGamePos = "OnSlotNotifyGamePos",
    OnSlotGuideOver = "OnSlotGuideOver",
    --幸运转盘奖上奖
    LuckyCountDown = "LuckyCountDown",
    LuckySpinRecord = "LuckySpinRecord",
    LuckySpinRewardMsg = "LuckySpinRewardMsg",
    -- mini hall
    OnMiniHallChipsChange = "OnMiniHallChipsChange",
    OnPushMiniNotification = "OnPushMiniNotification",
    OnMiniStatusUpdate = "OnMiniStatusUpdate",
    OnMiniGameClose = "OnMiniGameClose",
    OnSetMiniGameAuto = "OnSetMiniGameAuto",
    OnSetMiniGameBet = "OnSetMiniGameBet",
    OnSetMiniGameResult = "OnSetMiniGameResult",
    OnSetWindowScreen = "OnSetWindowScreen",
    OnSetWindowScreenComplete = "OnSetWindowScreenComplete",
    OnSetFullScreen = "OnSetFullScreen",
    OnMiniGameNotVip = "OnMiniGameNotVip",
    OnSetMiniIconPos = "OnSetMiniIconPos",
    OnSetMiniCurGame = "OnSetMiniCurGame",
    --收到游戏开始推送
    OnNotifyPlayerIntoGame = "OnNotifyPlayerIntoGame",
    --扭蛋奖励推送
    RefrshEggRecord = "RefrshEggRecord",
    RefrshCombineEggMarquee = "RefrshCombineEggMarquee",
    --每日寻宝
    TreasureReward = "TreasureReward",
    --小游戏筹码不足通知
    OnMiniGameBetShortage = "OnMiniGameBetShortage",
    --游戏每日礼包
    OnDailyGiftGameReward = "OnDailyGiftGameReward",
    --道具使用
    OnPropUse = "OnPropUse",
    --月末活动入口状态
    OnRefreshActiveEntryBtn = "OnRefreshActiveEntryBtn",
    --月中活动入口
    OnRefreshMidActiveBtn = "OnRefreshMidActiveBtn",
    --vip3直升卡
    VipThreeCard = "VipThreeCard",
    --活动开关
    ActivitySwitch = "ActivitySwitch",
    -- 每日抽奖奖励推送
    OnDailyLotteryReward = "OnDailyLotteryReward",
    OnPushActivityMsg = "OnPushActivityMsg",
    --零点通知礼包刷新
    OnTimeNotify = "OnTimeNotify",
    --物理截屏回调
    OnGetDisScreenShotBack = "OnGetDisScreenShotBack",
    --每日礼包合集界面
    OnShowDailyGiftCollectionView = "OnShowDailyGiftCollectionView",
    --每日礼包记录推送
    OnGiftSignInBigReward = "OnGiftSignInBigReward",
    --游戏解锁礼包购买成功通知刷新
    OnGameUnlockGift = "OnGameUnlockGift",
    --组队：邀请、同意、拒绝、解散推送
    OnPushTeamNotify = "OnPushTeamNotify",
    OnTeamUpAgree = "OnTeamUpAgree",

    ------------------slot比赛---------------------
    SLOTMATCHCONTEXT = "slotMatchContext",--比赛上下文
	MATCHSTAGE = "matchStage",--比赛阶段请求
	MATCHRANK = "matchRank",--排行榜请求
	MATCHREWARDRANK = "matchRewardRank",--奖励排行榜请求
    MATCHGIFT = "matchGift",---礼包信息请求

	READYMATCHINFO = "readyMatchInfo",---准备状态数据推送
    PROCESSMATCHINFO = "processMatchInfo",---比赛状态数据推送
    ALLREALTIMERANKINFO = "allRealtimeRankInfo",---所有实时排行榜
	BALANCEMATCHINFO = "balanceMatchInfo",---结算状态数据推送
    STAGECHANGE = "stageChange",---结算改变推送
    GIFTPURCHASE = "giftPurchase",--礼包购买推送

    MATCHTIP = "matchTip",--比赛期动态提示
    MATCHGIFTGUIDE = "matchGiftGuide",---手指引导点击礼包
    LIMITREFRESHREALTIMERANK = "limitRefreshRealtimeRank",--限制刷新实时排行榜，特殊模式下禁止刷新，为了不让新数据在效果之前就出现，比如免费模式
    ----------------slot共同的--------------------------
    OnAddSlotNotice = "OnAddSlotNotice",----消息弹框等
    OnCanShowNotice = "OnCanShowNotice",----可以显示通用消息展示
    ---------------------------------------------------------

    --假日礼包中奖推送
    OnAugGiftPayRewardRecordPush = "OnAugGiftPayRewardRecordPush",
    --合集跳转到指定界面推送
    OnCollectionViewJumpToView = "OnCollectionViewJumpToView",
    --资讯更新
    OnRefreshLoadNews = "OnRefreshLoadNews",

    --实物商城切换页签
    OnTreasureSwitch = "OnTreasureSwitch",
    --刷新大厅首冲礼包入口显示
    FirstGiftIcon = "FirstGiftIcon",
    --通知子游戏首冲礼包状态
    FirstGiftState = "FirstGiftState",
    --vip升级权益
    OnVipUpgradeView = "OnVipUpgradeView",
    --合成招财猫炮台
    PushCatBatteryRecord = "PushCatBatteryRecord",
    PushPayGiftBigReward = "PushPayGiftBigReward",
    PayGiftGetState = "PayGiftGetState",
    ShowRightGift = "ShowRightGift",
    --跳转选择礼包合辑
    OnGoToSelectGiftCollectionView = "OnGoToSelectGiftCollectionView",
    PushCommonBatteryRecord = "PushCommonBatteryRecord",

    OnClickFloatActionButton = "OnClickFloatActionButton",
    --私聊信息已读
    PriChatRead = "PriChatRead",

	--周年庆幸运转盘跑马灯
	OnPushLuckyRoulette = "OnPushLuckyRoulette",

    OnSearchFriend = "OnSearchFriend",
    ReqTradeSuccess = "ReqTradeSuccess",
    --刷新游戏列表类型推送
    RefreshGameList = "RefreshGameList",
    --设置安全码成功
    SetSafePassWordSucc = "SetSafePassWordSucc",
    --性别修改
    ChangeSex = "ChangeSex",
	--应用评价回调
	OnAppRateCallBack = "OnAppRateCallBack",

    OnRefreshBatterySkin = "OnRefreshBatterySkin",
	--跳转火星任务
	JumpToMarsTask = "JumpToMarsTask",
    --世界杯页面切换
    WorldCupSubViewChange = "WorldCupSubViewChange",
    --进入世界杯页面
    EnterWorldCupPage = "EnterWorldCupPage",
    --奖池节点切换
    WorldCupJackpotChange = "WorldCupJackpotChange",
    --世界杯弹窗监听
    WorldCupTipsViewNotify = "WorldCupTipsViewNotify",

    -- 音乐音量大小改变
    SoundVolumeChange = "SoundVolumeChange",
    -- 音效音量大小改变
    EffectVolumeChange = "EffectVolumeChange",
}

return Notifications