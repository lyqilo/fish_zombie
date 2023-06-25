local lan =
{
	--Tab
	tabIntroduce = "信息",
	tabProcess = "头衔",

	taskTitle = "头衔:",
	totalChips = "筹码:",
	totalDiamond = "钻石:",
	bindPhoneTips = "温馨提示:信息完善后可领取奖励哦",

	integralTips = "进入“实物商城”,\n可用“礼券”兑换实物奖品",

	nextVIPLevel = "下一等级",

	btnFB = "Facebook",
	btnDetermine = "Determine",
	btnBindPhone = "完善信息",
	btnBackpack = "我的背包",
	btnDelete = "删除",
	btnGiving = "赠送",
	btnAddFriend = "添加好友",
	unLockTitle = "即将解锁头衔:",
	unLockTask = "解锁任务",

	phoneNumberDes = "电话号码:",
	verCodeDes = "验证码:",
	phonePlaceholder = "请输入手机号 (0XX XXX XXXX)",
	verCodePlaceholder = "请输入验证码",
	btnGetCode = "获取验证码",
	btnOk = "确定",
	btnSend ="请求已发送",
	phoneNumberTip = "请输入正确的手机号码",
	verCodeTip = "请输入正确的6位验证码",
	idTitle = "ID:",

	bindSuccess = "手机绑定成功",
	bindFailed = "手机绑定失败",
	sendSMSSuccess = "验证码已发送",
	sendSMSFailed = "验证码发送失败",

	facebookLoginTips1 = "绑定失败，该账户已经绑定过Facebook",
	facebookLoginTips2 = "登录失败",
	facebookLoginTips3 = "绑定成功",
	facebookLoginTips4 = "绑定失败",
	facebookLoginTips5 = "Facebook绑定成功，赠送给您5000筹码",

	lineLoginTips1 = "绑定失败，该账户已经绑定过Line",
	lineLoginTips2 = "登录失败",
	lineLoginTips3 = "绑定成功",
	lineLoginTips4 = "绑定失败",
	lineLoginTips5 = "Line绑定成功，赠送给您5000筹码",

	blinded = "已绑定",
	birthTips = "请填写出生日期",
	sexTips = "请选择性别",
	yearTips = "年份输入不合法",
	dayTips = "日期输入不合法",
	saveFailed = "信息保存失败",
	onlyOne = "个人信息可能会影响到您的奖励接收，请谨慎填写",

	realName = "生日认证",
	realName_tip1 = "上传身份证进行生日认证，生日当天将获得大额金币奖励",
	realName_tip2 = "ps：当天进行生日认证，奖励将在明年生日发送",


	nickInputTip = "名字不能为空",
	changeHead = "更换头像",
	changeHeadFrame = "更换头像框",
	entryEffect = "入场特效",
	effectDes = "入场特效",
	freeMode = "当前头像设置为自由状态",
	lockMode = "当前头像设置为锁定状态",
	lockModeTip = "当前为锁定状态，请切换自由模式后再选择",

	deleteSuccess = "删除成功",

	second = "秒",

	selfInfo = "个人信息",
	VipInfo = "VIP权益",
	GiftInfo = "VIP礼包",
	baseInfo = "基础信息",
	nickName = "昵称:",
	birth = "生日:",
	sex = "性别:",
	male = "男",
	female = "女",
	day = "日",
	mon = "月",
	year = "年",
	maxWinChips = "最高赢取筹码:",
	totalWin = "总赢取:",
	signature = "个性签名:",
	completeInfo = "完善信息",
	curVipLevel = "当前VIP等级",
	anyPay = "完成任意付费即可解锁以下VIP权益",
	btnUnlock = "去解锁",
	btnLevel = "去升级",
	vipRights = "VIP%s特权",
	vipPoint = "VIP点",
	exchange = "兑换",
	rechargeTips = "充值升级:",
	curVip = "当前VIP",
	UpGradeAward = "升级道具%s筹码",
	GiveLimit = "赠送筹码上限%s/天",
	GiveLimitLow = "赠送筹码上限%s/永生",
	GiveTax = "赠送税收减少%s%%",
	PointExchange = "VIP点兑换比%s倍",
	LotteryMarkup = "彩票奖金额外加成%s%%",
	CardFragment = "点卡碎片兑换%s次数",
	MinGive = "最低赠送额度%s",
	GiveTime = "赠送时间锁定%s/天",
	Relief = "救济金%s筹码",
	CardCount = "每日点卡额度兑换上限%s",
	unlimited = "无限制",
	birthTitle = "修改生日",
	birthTip = "生日只能修改一次，请谨慎填写",

	rightsIcon = {
		[10001] = {name = "流水升级", tip ="解锁后可通过流水升级VIP权益"},
		[10002] = {name ="救济金", tip ="以提升至%s"},
		[10003] = {name ="新功能", tip =""},
		[10004] = {name ="赠送上限", tip ="以提升至%s"},
		[10005] = {name ="游戏特权", tip =""},
		[10006] = {name ="最低赠送额", tip ="以提升至%s"},
		[10007] = {name ="升级奖励", tip ="以提升至%s"},
		[10008] = {name ="发言权限", tip ="解锁后可在大厅及私聊发起聊天权益"},
		[10009] = {name ="mimi游戏", tip ="龙虎斗单次下注提升至%s\nmini骰宝单次下注提升至%s"},
		[10010] = {name ="DummyVIP积分赛", tip ="解锁后可参与DummyVIP积分赛"},
		[10011] = {name ="PokdengVIP积分赛", tip ="解锁后可参与PokdengVIP积分赛"},
		[10012] = {name ="7日基金", tip ="参与7日基金连续登陆\n可获得保底%s最高%s筹码"},
		[10013] = {name ="黄金骰子", tip ="解锁黄金骰子玩法，出现后可代替任意面，重复只计算一次"},
		[10014] = {name ="三叉戟", tip ="充满三叉戟之后,你可以选择下注来使用三叉戟来增加获得筹码的机会"},
		[10015] = {name ="赠送税收减少", tip ="以提升至%s"},
		[10016] = {name ="狼主英雄", tip ="《冰与火之歌》特殊英雄，具有减速和连击能力"},
		[10017] = {name ="特权卡", tip ="周卡礼包购买获得，获得《冰与火之歌》特权\n1、解锁英雄【龙母】\n2、解锁【一键部署】功能\n3、行动点消耗-1"},
	},

	CapacityTitle = "新功能解锁",
	UnlockGame = "解锁游戏",
	UnlockRoom = "解锁房间",
	GoTo = "前往",
	CapacityMore = "更多功能",
	GameTitle = "解锁游戏",
	GameMore = "场次解锁",
	download_tip = "等待中",
	CatchType = "捕获类",
	BetType = "下注类",
	ChessType = "棋牌类",
	SlotsType = "拉霸类",
	GameIdName = {
		[1001] = "007",
		[1003] = "恭喜发财",
		[1004] = "快活楼",
		[1005] = "丛林密宝",
		[1006] = "金瓶梅",
		[1007] = "新财神",
		[1008] = "连环夺宝",
		[2001] = "百家乐",
		[2002] = "PD",
		[2004] = "德州扑克",
		[3001] = "鱼虾蟹",
		[3002] = "二人捕鱼",
		[3003] = "打地鼠",
		[3004] = "骰宝",
		[3005] = "四人捕鱼",
		[3007] = "打飞机",
		[3009] = "僵尸塔防",
		[31002] = "西游争霸",
		[3010] = "猎牛达人",
		[3008] = "木乃伊归来",
	},
	FieldName = {
		[10001] = "新手场",
		[10002] = "初级场",
		[10003] = "中级场",
		[10004] = "高级场",
		[10005] = "精英场",
		[10006] = "专家场",
		[10007] = "大师场",
		[10008] = "VIP1场",
		[10009] = "VIP5场",
		[10010] = "VIP7场",
		[10011] = "王者场",
		[10012] = "海王场",
		[10013] = "刺激战场",
		[10014] = "传奇场",
		[10015] = "荒漠蝎王",
	},
	CapacityInfo = {
		[1] = "每日转盘(%s次)",
		[2] = "每日转盘——解锁第%s层奖励",
		[3] = "转盘次数增加%s次（付费）",
		[4] = "平日登陆奖励%s",
		[5] = "周末登陆奖励%s",
	},
	exchangeCenter = "兑换中心",
	VIPSpotRatio_exchange = "当前等级，可享受<color=#FFF900FF>%s</color>倍兑换比例",
	tip_vipSpotMax = "已达单次兑换上限",
	tip_vipSpot = "每次兑换最少需消耗10000VIP点",

	lookRights = "vip特权礼包",
	anyContinue = "点击任意屏幕继续",

	guideText = "ผูกเบอร์โทรศัพท์ตอนนี้ได้รับรางวัล10000ชิปฟรีทันที",

	needRenameCard = "修改昵称将消耗1张改名卡\n请购买后重试",
	needUnbindTelCard = "解绑手机将消耗1张解绑卡\n请购买后重试",
	unbindTelTitle = "解绑手机",
	unbindTelTip = "如当前手机号码已更换，请联系客服",
	consume = "消耗:",
	unbindTelSucc = "解绑成功",
	unbindTelFail = "解绑失败",
	bindTel = "绑定手机",
	unbindTel = "解绑手机将消耗1张解绑卡",
	box = "保险箱",
	confirmUnbind = "确定解绑手机？",
	otpClose = "系统繁忙，请稍后再试",
	setsex = "设置性别",

	example = "例子",
	verifiedTitle = "生日实名认证",
	verifiedTip1 = "ใช้สำหรับยืนยันวันเกิดตนเอง\nที่เกมรอยัลเท่านั้น",
	verifiedTip2 = "1.手持身份证正面位于胸前位置\n2.露出清晰的脸部及身份证正面\n3.身份证上的文字需要清晰\n4.拍照上传",
	verifiedTip3 = "Ps:上传成功后，等待客服审核通过后既实名成功",
	verifiedBtn = "确认提交",
}

return lan