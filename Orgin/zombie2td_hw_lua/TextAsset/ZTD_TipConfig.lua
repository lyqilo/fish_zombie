--语言相关
local TipConfig = {}
TipConfig = {
	--服务器错误码
	--服务器错误码
	[10000] = "成功",
	[10001] = "请求房间失败，你在其他房间的游戏还没结束",
	[10002] = "获取亲朋用户失败",
	[10003] = "读取金币失败",
	[10004] = "金币不足进入此服务器",
	[10005] = "加载玩家数据失败",
	-- [10006] = "参数错误",
	[10007] = "金币不足",
	[10008] = "序列化错误 ",
	[10009] = "创建玩家失败",
	--[10010] = "玩家不存在",
	[10011] = "玩家已经登录",
	[10012] = "配置中不存在该英雄",
	[10013] = "玩家没有这个英雄",
	--[10014] = "英雄的位置不符合要求",
	[10015] = "英雄已经更新到最大等级",
	[10016] = "没有足够的生物酶",
	[10017] = "配置中不存在该怪物",
	[10018] = "更新或者增加一个英雄的信息失败",
	[10019] = "已经存在该英雄",
	[10020] = "击杀失败",
	[10021] = "怪物分数有误",
	[10022] = "配置中没有找到该药水",
	[10023] = "没有足够的药水",
	[10024] = "没有找到实验室研究能力",
	[10025] = "该能力已经升级到最大等级",
	--[10026] = "没有找到实验研究室解锁公式",
	[10027] = "解锁参数有误",
	[10028] = "该能力还没解锁",
	[10029] = "没有找到生物酶消耗公式",
	[10030] = "该能力还没达到解锁等级",
	[10031] = "该能力已经解锁",
	[10032] = "不存在该任务",
	[10033] = "不存在该任务配置",
	[10034] = "已经领取了该任务奖励",
	[10035] = "该任务还未完成",
	[10036] = "还没达到任务进度奖励领取条件",
	[10037] = "任务id错误",
	[10038] = "该任务已完成",
	[10039] = "不是闯关模式",
	--[10040] = "该模式下出现错误的特殊怪",
	[10041] = "不存在尸鬼龙王",
	[10042] = "已经达到购买药水最大数或者购买数量不正确",
	[10043] = "爽翻模式下设置的特殊怪出现配置不符",
	--[10044] = "怪物已经被击杀，请勿连续击杀多次",
	--[10045] = "挂机已经结束，不能再击杀怪物",
	[10046] = "挂机配置设置不符合设置范围",
	[10047] = "会员天数不足，无法挂机",
	[10048] = "同一时间不能使用同一类型药水",
	--[10049] = "玩家未挂机",
	[10050] = "玩家存在等待保存数据内中",
	--[10051] = "发送协议太频繁，直接返回不做任何操作",
	[10052] = "毒爆怪次数或者倍率不正确",
	--[10053] = "没有找到毒爆次数",
	[10054] = "没有达到解锁条件",
	[10055] = "已经领取该进度奖励",
	[10056] = "不存在该任务进度配置",
	[10057] = "每次购买秘药数量只能是1个",
	[10058] = "该英雄等级还未解锁",
	[10059] = "不存在合体技能奖励",
	[10060] = "没有足够的突破石",
	
	[10066] = "该位置已有其他玩家的英雄",
	
	-- [10067] = "行动点不足",
	[10068] = "该位置上没有此英雄",
	[10084] = "该位置已有英雄",
	--[10086] = "巨龙之怒没有释放",
	[10087] = "巨龙之怒正在释放",
	[11088] = "巨龙之怒冷却中",
	[10089] = "巨龙之怒释放扣除金币到达挂机结束下限",
	[10106] = "唯一英雄只能上阵一个",
	
	[99999] = "请求超时",
	
	BtnConnect = "重连",
	BtnLeave = "退出",
	
	DrugCool = "药水尚在冷却中",
	LackOfEnzyme = "所需生物酶不足",
	LackOfWisdom = "所需智慧结晶不足",
	LackOfBreak = "所需突破石不足",
    propNotEnough = "药水使用完了",
    propBuyLimit = "药水购买已达上限",
    propUseLimit = "药水使用已达上限",
    buySuccess = "购买成功",
    useSuccess = "使用成功",
    synthetiseNeedNotEnough = "所需%s不足，无法合成!",
    getSuccess = "成功领取 ",
    rewardRecieved = "奖励已领取",
    missionNotDone = "任务未完成",
    progressNotReach = "激活宝箱后可领取 ",
    oneHeroMustBe = "场上至少有一个英雄 ",
    HeroUpgradeTimes = "升级%d级",
    upgradeSuccess = "升级成功",
    unlockSuccess = "解锁成功",
    serverDissconnect = "服务器已经断开，请返回大厅",
    connectFailed = "连接失败，是否重试",
    reconnectServer = "连接断开，是否重连",
    loginSuccess = "连接成功",
	shareTitle = "亲朋打僵尸2",
	shareContent = {
    "全新激爽3D大作《亲朋打僵尸2》震撼登场！爆爽手感，满屏僵尸，金币刷到停不下来！！",
    "神秘异魔入侵世界，龙与狼的宿命英雄前来助阵，快来《亲朋打僵尸2》中谱写冰与火的史诗吧！！",
    "自从玩了《亲朋打僵尸2》，心情爽了，荷包鼓了，走路都更有劲了。思前想后，还是给老铁们分享一下！！",
    "什么鬼？有人在《亲朋打僵尸2》里刷金币刷到手软？兄弟姐妹们速度走起，盘它！！",
    "都9102年了还有人在抓小鱼敲蘑菇？是成年人就该来《亲朋打僵尸2》当僵尸猎人啦！！",
	},

    EffectMute = {
    	On = "音效静音",
    	Off = "取消音效静音",
    },

    MusicMute = {
    	On = "音乐静音",
    	Off = "取消音乐静音",
    },

    SaveMode = {
    	On = "打开省电模式",
    	Off = "关闭省电模式",
    },
	
	trusteeWin = "盈利：",
	trusteeLose = "亏损：",
	trusteeProtectTip = "至少要开启一项保护",
	trusteeProtectTip2 = "至少要上阵一个英雄",
	trusteeMask = "设置已锁定，如需更改请先取消挂机",
	heroMaxLevel = "已经是最高等级",
	
	--
	view_trust_tip1 = "%s小时",
	
	kick_out_tips = "由于长时间未攻击，已退出当前房间。点击“重连”重新进入游戏",
	
	over_capacity = "服务器房间已满",
	
	place_play = "挂机中",
	
	cost_over = "剩余分值不足以放置英雄",
	
	less_money = "金币不足，请及时充值",
	
	update_fuck_out = "该游戏正在更新，请返回大厅",
	
	serverDissconnect2 = "服务器已经断开，是否重连",
	
	on_sc_other_player_login = "你的账号在其他设备登录，请重新登录",
	
	exchangeGold = "是否全部兑换成金币？",	
	
	cost_tip = "剩余分值，用于放置英雄",
	
	enemy_select_tip = "勾选你想要攻击的怪物，不勾选的只有手动锁定时才会攻击",
	
	txt_btn_select = "怪物筛选",
	
	txt_trust_tip1 = "上限保护无限制",
	
	txt_trust_tip2 = "下限保护无限制",
	
	txt_trust_tip3 = "时间保护无限制",
	
	txt_btn_onekey1 = "一键部署",
	
	txt_btn_onekey2 = "长按设置",
	
	one_key_tip1 = "至少保留一个英雄",

	TD_COUNT_DOWN = "长时间未攻击\n即将退出",

	nodeOneKeyTxt1 = "点击英雄图标设置快捷栏位",

	nodeOneKeyTxt2 = "点击空白区域关闭列表",

	txt_btn_confirm = "确定",

	txt_btn_cancle = "取消",

	txt_guide_border = "点击选择闯关模式",

	connectText = "连接中",

	reconnectText = "重连中",
	
	loadingText = "加载中",
	
	txt_viplevelLimit = "VIP等级不足！",

	txt_choumaLimit = "当前金币不足！",

	txt_changeroomLimit = "金币不足，无法进入本场其他房间",

	txt_exitGameLimit = "金币不足，无法进入本场",

	txt_v2Lock = "VIP2解锁",

	txt_v3Lock = "VIP3解锁 ",

	txt_privilegeLock = "特权卡解锁 ",

	txt_v3Pop = "需要VIP3解锁，是否前往充值？",

	txt_privilegePop = "需要特权卡解锁，是否前往购买？",

	txt_v2Pop = "需要VIP2解锁，是否前往充值？",

	txt_batteryPop = "更高VIP等级可以解锁更多行动点，是否前往充值？",

	txt_confirmPop = "好的",

	txt_cancelPop = "不用了",

	tips_gift = "礼包已经购买过了，请稍后再来哦",

	tips_giftColling = "商品冷却中",

	content = "省电模式可以让游戏更加流畅，是否开启?",
    btn_open = "开启",
    btn_noopen = "不开启",

	turnTableTimes = "叠加次数：",
	
}
return TipConfig