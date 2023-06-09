local lan =
{
	[2] = "筹码",
	[3] = "钻石",
	[7] = "喇叭",
	[22] = "礼券", -- EPC_GiftVoucher
	[23] = "K卡",
	[26] = "鸡蛋花",
	[28] = "改名卡",
	[29] = "点卡碎片",
	[35] = "万圣节南瓜道具",
	[36] = "水晶",
	[37] = "圣诞帽道具",
	[38] = "春节灯笼道具",
	[39] = "合成扭蛋钥匙",
	[46] = "新礼券",
	[47] = "周年庆钥匙",
	[48] = "周年庆抽奖券",
	[49] = "周年庆头像框",
	[50] = "免交易税道具",
	[51] = "解绑手机道具",
	[52] = "改名卡",
	[54] = "超值月卡",
	[55] = "至尊月卡",
	[56] = "巫师帽",
	[57] = "万圣节签到卡",
	[58] = "孔明灯",
	[59] = "水灯节10元礼包卡",
	[60] = "保险箱余额",
	[61] = "圣诞节10元礼包卡",
	[62] = "truemoney兑换卡",
	[63] = "春节10元礼包卡",
	[64] = "2月末10元礼包卡",
	[65] = "truemoney兑换点卡",
	[66] = "3月末10thb礼包卡",
	[67] = "沙丘",
	[68] = "4月末10元礼包卡",
	[69] = "5月末10元礼包卡",
	[70] = "6月末10元礼包卡",
	[71] = "扭蛋币",
	[72] = "truemoney50THB兑换卡",
	[73] = "红包",
	[74] = "7月末10元礼包卡",
	[75] = "8月末10元礼包卡",
	[76] = "9月末10元礼包卡",
	[77] = "10月末10元礼包卡",
	[78] = "11月末10元礼包卡",
	[79] = "12月末10元礼包卡",
	[80] = "灵珠",
	[81] = "龙鳞石",
	[82] = "红包",
	[83] = "橘子",
	[84] = "1月末10元礼包卡",
	[85] = "2月末10元礼包卡",
	[86] = "3月末10元礼包卡",
	[87] = "4月末10元礼包卡",
	[88] = "5月末10元礼包卡",
	[89] = "6月末10元礼包卡",
	[90] = "7月末10元礼包卡",
	[91] = "8月末10元礼包卡",
	[92] = "9月末10元礼包卡",
	[93] = "10月末10元礼包卡",
	[94] = "11月末10元礼包卡",
	[95] = "12月末10元礼包卡",
	[96] = "水滴碎片",
	[97] = "水滴",
	[98] = "神秘奖励图标",
	[99] = "Lucky time经验值",
	[100] = "水枪",
	[101] = "水管",
	[102] = "水桶",
	[103] = "水瓢",
	[501] = "青蛙",
	[502] = "乌龟",
	[503] = "河豚",
	[504] = "地鲶鱼",
	[505] = "冰冻鱼",
	[506] = "飞鱼",
	[507] = "炸弹鱼",
	[508] = "大白鲨",
	[509] = "灯笼鱼",
	[510] = "刺鳐",
	[511] = "蓝鲸",
	[512] = "鸿运当头鱼",
	[513] = "章鱼",
	[514] = "醒狮鱼",
	[515] = "美人鱼",
	[516] = "火龙神",
	[1001] = "青铜鱼雷",
	[1002] = "白银鱼雷",
	[1003] = "黄金鱼雷",
	[1004] = "天使鱼雷",
	[1005] = "火龙鱼雷",
	[1006] = "白银鱼雷(赠)",
	[1007] = "黄金鱼雷(赠)",
	[1008] = "白银鱼雷(赠送)奖励",
	[1009] = "黄金鱼雷(赠送)奖励",
	[1012] = "青铜火箭炮",
	[1013] = "白银火箭炮",
	[1014] = "黄金火箭炮",
	[1015] = "铂金火箭炮",
	[1016] = "青铜鱼雷(赠)",
	[1017] = "天使鱼雷(赠)",
	[1018] = "火龙鱼雷(赠)",
	[1019] = "青铜鱼雷(赠送)奖励",
	[1020] = "天使鱼雷(赠送)奖励",
	[1021] = "火龙鱼雷(赠送)奖励",
	[1022] = "青铜火箭炮(赠)",
	[1023] = "白银火箭炮(赠)",
	[1024] = "黄金火箭炮(赠)",
	[1025] = "铂金火箭炮(赠)",
	[1026] = "青铜火箭炮(赠送)奖励",
	[1027] = "白银火箭炮(赠送)奖励",
	[1028] = "黄金火箭炮(赠送)奖励",
	[1029] = "铂金火箭炮(赠送)奖励",
	[1030] = "召唤道具",
	[1031] = "青铜核弹头",
	[1032] = "白银核弹头",
	[1033] = "黄金核弹头",
	[1034] = "铂金核弹头",
	[1035] = "青铜核弹头(赠)",
	[1036] = "白银核弹头(赠)",
	[1037] = "黄金核弹头(赠)",
	[1038] = "铂金核弹头(赠)",
	[1039] = "青铜核弹头(赠送)奖励",
	[1040] = "白银核弹头(赠送)奖励",
	[1041] = "黄金核弹头(赠送)奖励",
	[1042] = "铂金核弹头(赠送)奖励",
	[1043] = "飞机召唤道具",
	[1044] = "初级轮盘武器碎片",
	[1045] = "中级轮盘武器碎片",
	[1046] = "高级轮盘武器碎片",
	[1047] = "专家轮盘武器碎片",
	[1048] = "初级轮盘武器",
	[1049] = "中级轮盘武器",
	[1050] = "高级轮盘武器",
	[1051] = "专家轮盘武器",
	[1101] = "打地鼠钉耙道具",
	[1102] = "冰与火之歌青铜令",
	[1103] = "冰与火之歌白银令",
	[1104] = "冰与火之歌黄金令",
	[1105] = "冰与火之歌钻石令",
	[1106] = "冰与火之歌特权卡",
	[1107] = "打地鼠拖鞋武器",
	[1109] = "招财猫皮肤卷",
	[1110] = "招财猫炮台",
	[1111] = "巨龙令(不朽)",
	[1112] = "普通碎片",
	[1113] = "中级碎片",
	[1114] = "高级碎片",
	[1115] = "特级碎片",
    [1116] = "炸弹羊",
    [1117] = "蜘蛛侠",
    [1118] = "法老王",	
	[1119] = "神龙转轮1",
    [1120] = "神龙转轮2",
    [1121] = "神龙转轮3",
	[1122] = "炽焰炮台碎片",
	[1123] = "炽焰炮台",
	[1124] = "朱雀炮台碎片",
	[1125] = "朱雀炮台",
	[1126] = "白虎炮台碎片",
	[1127] = "白虎炮台",
	[1128] = "玉兔炮台碎片",
	[1129] = "玉兔炮台",
	[1130] = "万圣节兑换宝箱1",
	[1131] = "万圣节兑换宝箱2",
	[1132] = "万圣节兑换宝箱3",
	[1133] = "万圣节兑换宝箱4",
	[1134] = "万圣节兑换宝箱5",
	[1135] = "蛋糕炮台碎片",
	[1136] = "蛋糕炮台",
	[1137] = "水枪炮台碎片",
	[1138] = "水枪炮台",
	[1139] = "金色战机",
	[1140] = "绿色战机",
	[1141] = "蓝色战机",
	[1142] = "1级炮台",
	[1143] = "2级炮台",
	[1144] = "3级炮台",
	[1145] = "4级炮台",
	[1146] = "5级炮台",
	[1147] = "黄金甲炮台",
	[1148] = "圣骑炮台",
	[1149] = "五福熊猫炮台",
	[1150] = "青龙鳞片",
	[1151] = "青龙炮台",
	[1152] = "冰冻卡",
	[1153] = "电音炮台碎片",
	[1154] = "电音炮台",
	[2006] = "50点卡",
	[2007] = "150点卡",
	[2008] = "300点卡",
	[2009] = "500点卡",
	[2010] = "1000点卡",
	[2011] = "90点卡",
	[3001] = "春天花环头像框",
	[3002] = "春天花苞头像框",
	[3003] = "新手签到头像框",
	[3004] = "万圣节紫色头像框",
	[3005] = "万圣节金色头像框",
	[3006] = "青铜水晶头像框",
	[3007] = "白银水晶头像框",
	[3008] = "黄金水晶头像框",
	[3009] = "铂金水晶头像框",
	[3010] = "钻石水晶头像框",
	[3011] = "雪花入场特效",
	[3012] = "圣诞帽入场特效",
	[3013] = "圣诞老人入场特效",
	[3014] = "麋鹿圣诞特效",
	[3015] = "雪人圣诞特效",
	[3016] = "圣诞普通头像框",
	[3017] = "圣诞高级头像框",
	[3018] = "双鱼报喜入场特效",
	[3019] = "牛转乾坤入场特效",
	[3020] = "河东狮吼入场特效",
	[3021] = "财神降临入场特效",
	[3022] = "双狮迎福入场特效",
	[3023] = "春节普通头像框",
	[3024] = "春节高级头像框",
	[3025] = "泼水节风调雨顺入场特效",
	[3026] = "泼水节雨过天晴入场特效",
	[3027] = "泼水节大象同欢入场特效",
	[3028] = "泼水节湿身派对入场特效",
	[3029] = "泼水节夏日水枪入场特效",
	[3030] = "泼水节紫金头像框",
	[3031] = "泼水节贵族头像框",
	[3032] = "VVIP头像框",
	[3033] = "功德头像框",
	[3034] = "月卡限时头像框",
	[3035] = "ROYAL DADDY头像框",
	[3036] = "ROYAL MOMMY头像框",
	[3037] = "ROYAL SPONSOR头像框",
	[3038] = "ROYAL FAMILY头像框",
	[3039] = "周年庆3周年头像框",
	[3040] = "2021万圣节头像框",
	[3041] = "2021水灯节头像框",
	[3042] = "2021圣诞节雪花",
	[3043] = "未中奖道具",
	[3044] = "欢乐激斗特权卡",
	[3045] = "欢乐激斗青铜导弹",
	[3046] = "欢乐激斗白银导弹",
	[3047] = "欢乐激斗黄金导弹",
	[3048] = "欢乐激斗铂金导弹",
	[3049] = "泼水节蓝色头像框",
	[3050] = "泼水节金色头像框",
	[3051] = "月球之夜头像框",
	[3052] = "探索火星头像框",
	[3053] = "星际巡航头像框",
	[3054] = "金龙入场特效",
	[3055] = "跑车入场特效",
	[3056] = "轿车入场特效",
	[3057] = "青龙头像框",
	[3058] = "2023泼水节头像框",
	[3059] = "2023泼水节入场特效1",
	[3060] = "2023泼水节入场特效1",
	[3061] = "2023泼水节入场特效1",
	[4001] = "Dummy积分赛门票",
	[4002] = "Dummy积分赛复活券",
	[4003] = "Dummy实物赛门票",
	[4004] = "Dummy实物赛复活券",
	[4005] = "DummyVIP赛门票",
	[4006] = "DummyVIP赛复活券",
	[4007] = "Dummy勇士赛门票",
	[4008] = "合金弹头",
	[4009] ="午夜赛报名券",
	[4010] ="午夜赛复活券",
	[4011] ="高级召唤卡道具",
	[4012] ="未来之翼ver.2",
	[4013] ="2022圣诞入场特效1",
	[4014] ="2022圣诞入场特效2",
	[4015] ="2022圣诞入场特效3",
	[4016] ="2022圣诞入场特效4",
	[4017] ="2022圣诞入场特效5",
	[4018] ="2022圣诞普通头像框",
	[4019] ="2022圣诞高级头像框",
	[4020] ="2022排行榜入场特效1",
	[4021] ="2022排行榜入场特效2",
	[4022] ="2022排行榜入场特效3",
	[4023] ="玄武炮台",
	[4024] ="幸运星",
	[4025] ="太极图腾",
	[7011] = "Dummy2Q牌型密函",
	[8001] = "牌型增益卡",
	[9005] = "slot500免费卡片",
	[9006] = "slot1000免费卡片",
	[9007] = "slot10000免费卡片",
	[9008] = "CLMB能量球",
	[9009] = "slot超值积分",
	[9010] = "slot助力积分",
	[9011] = "slot冲刺积分",
	[9012] = "slot大神积分",
	[9013] = "slot50000免费卡片",
	[9014] = "DM火箭",
	[9015] = "DM彩虹",
	[9016] = "DM圣诞帽",
	[9017] = "DM啤酒",
	[9018] = "DM鲜花",
	[9019] = "DM香吻",
	[9020] = "DM喇叭",
	[9021] = "DM雷电",
	[9022] = "DM打枪",
	[9023] = "DM雪球",
	[9024] = "DM倒水",
	[9025] = "DM炸弹",
	[9026] = "DM香蕉",
	[9027] = "DM西红柿",
	[9028] = "slot50免费卡",
	[9029] = "slot100免费卡",
	[9030] = "slot300免费卡",
	[9031] = "slot3000免费卡",
	[9032] = "slot5000免费卡",
	[9033] = "slot20000免费卡",
	[9034] = "slot30000免费卡",
	[9035] = "slot300000免费卡",
	[9037] ="CLMB能量球1",
    [9038] ="CLMB能量球2",
    [9039] ="CLMB能量球3",
    [9040] ="CLMB能量球4",
    [9041] ="CLMB能量球5",
    [9042] ="CLMB能量球6",
    [9043] ="CLMB能量球7",
    [9044] ="CLMB能量球8",
    [9045] ="CLMB能量球9",
    [9046] ="CLMB能量球10",
    [9047] ="CLMB能量球11",
    [9048] ="CLMB能量球12",
    [9049] ="CLMB能量球13",
    [9050] ="CLMB能量球14",
    [9051] ="CLMB能量球15",
    [9052] ="CLMB能量球16",
	[9053] ="飞机幸运转盘1",
	[9054] ="飞机幸运转盘2",
	[9055] ="飞机幸运转盘3",
	[9056] ="龙虎斗召唤币",
	[9057] ="",
	[9058] ="FAFAFA 免费卡(450)",
	[9059] ="FAFAFA 免费卡(1350)",
	[9060] ="FAFAFA 免费卡(4500)",
	[9061] ="FAFAFA 免费卡(18000)",
	[9062] ="roma3免费卡(450)",
	[9063] ="roma3免费卡(1410)",
	[9064] ="roma3免费卡(7500)",
	[9065] ="roma3免费卡(22500)",
	[9066] ="roma免费卡(450)",
	[9067] ="roma免费卡(1410)",
	[9068] ="roma免费卡(7500)",
	[9069] ="roma免费卡(22500)",
	[9070] ="romax免费卡(450)",
	[9071] ="romax免费卡(1410)",
	[9072] ="romax免费卡(7500)",
	[9073] ="romax免费卡(22500)",
	[9074] ="dfdc免费卡(500)",
	[9075] ="dfdc免费卡(1000)",
	[9076] ="dfdc免费卡(5000)",
	[9077] ="dfdc免费卡(20000)",
	[9078] ="AZTEC免费卡(500)",
	[9079] ="AZTEC免费卡(1000)",
	[9080] ="AZTEC免费卡(5000)",
	[9081] ="AZTEC免费卡(20000)",
	[9082] = "时空守卫炮台",
	[9083] = "未来之翼翅膀",
	[9084] = "2022万圣节头像框",
	[9085] = "2022世界杯冠军头像框",
	[9086] = "2022世界杯亚军头像框",
	[9087] = "2022世界杯季军头像框",
	[9088] = "2022世界杯限定头像框",
	[9089] = "竞猜卡",
	[9093] = "竞猜积分",
	[9094] = "足球派对炮台",
	[9095] = "炮台碎片",
	[9098] = "月球之夜头像框",
	[9099] = "探索火星头像框",
	[9100] = "星际巡航头像框",
	[9101] = "蒸汽时代炮台",
	[9102] = "机械之翼",
	[9103] = "机械之翼ver.2",
	[9104] = "幻云之翼",
	[9105] = "幻云之翼ver.2",
	[9106] = "藏宝图",
	[9107] = "航海者徽章",
	[9108] = "月球之夜",
	[9109] = "金箍棒",
	[9110] = "九齿钉耙",
	[9111] = "降魔宝杖",
	[9112] = "白龙吟",
	[9113] = "锁定",
	[9114] = "光棱",
	[9115] = "九霄风雷炮",
	[9116] = "青锋月华炮",
	[9117] = "鱼跃潮生炮",
	[9118] = "蟠龙啸日炮",
	[9119] = "四月战令通行证",
	[9120] = "永恒之翼",
	[9121] = "永恒之翼ver.2",
	[9122] = "牌背-蓝色圆点",
	[9123] = "牌背-浅蓝方块",
	[9124] = "选场-夜幕海岛",
	[9125] = "桌面-夜幕海滩",
	[9126] = "牌背-精灵",
	[9127] = "电牌人物-包子头",
	[9128] = "电牌人物-精灵",
	[9129] = "kaeng升级礼包标识",
	[9130] = "kaeng抽奖礼包标识",
	[9131] = "恶魔之翼",
	[9132] = "恶魔之翼ver.2",
	[9133] = "电玩派对",
	[9134] = "撒旦之翼",
	[9135] = "撒旦之翼ver.2",
	[10001] = "50点卡",
	[10002] = "150点卡",
	[10003] = "300点卡",
	[10004] = "500点卡",
	[10005] = "1000点卡",
	[10006] = "90点卡",
	[10011] = "ZGold-50充值卡",
	[10012] = "ZGold-100充值卡",
	[10013] = "ZGold-300充值卡",
	[10014] = "ZGold-500充值卡",
	[10015] = "ZGold-1000充值卡",
	[10021] = "AIS-50充值卡",
	[10022] = "AIS-100充值卡",
	[10023] = "AIS-300充值卡",
	[10024] = "AIS-500充值卡",
	[20001] = "Oppo A3s",
	[20002] = "Vivo Y17",
	[20003] = "小牌黄金",
	[20004] = "iPhone XR",
	[20005] = "Samsung A80",
	[20006] = "黄金项链-1THB",
	[20007] = "黄金项链-0.5THB",
	[20008] = "Samsung A30",
	[20009] = "Vivo S1",
	[20010] = "Oppo A9 2020",
	[20011] = "Oppo A5 2020",
	[20012] = "iPhone11 64GB",
	[20013] = "iPhone11 Pro 64GB",
	[20014] = "Samsung S10+",
	[20015] = "Galaxy Note10+",
	[20016] = "Huiwei Y7",
	[20017] = "Vivo Y11",
	[20018] = "Samsung A10s",
	[20019] = "Oppo A31 2020",
	[20020] = "ipad10.2",
	[20021] = "iPhoneSE 2020",
	[20022] = "Oppo A92 2020",
	[20023] = "vivo Y50",
	[20024] = "黄金项链-0.25THB",
	[20025] = "iPad Gen8",
	[20026] = "Razer Kraken BT - Kitty Edition",
	[20027] = "Razer头戴耳机",
	[20028] = "Razer无线耳机",
	[20029] = "Razer Nommo",
	[20030] = "Samsung A21s",
	[20031] = "Oppo A53 2020",
	[20032] = "Oppo A93 2020",
	[20033] = "iPhone 12 Pro",
	[20034] = "iPhone 12 Mini",
	[20035] = "Reno4 Pro(8+128)",
	[20036] = "Oppo Watch ECG",
	[20037] = "Oppo Enco X",
	[20038] = "桌面手机懒人折叠支架",
	[20039] = "Samsung S21+5G",
	[20040] = "Samsung S21 5G",
	[20041] = "iPhone 12(128G) 红色",
	[20042] = "iPhone 12(128G) 黑色",
	[20043] = "Razer Kraken BT Kitty Edition - Quartz",
	[20044] = "Razer Hammerhead True Wireless Earbuds - Black",
	[20045] = "Razer Hammerhead True Wireless Earbuds - Mercury",
	[20046] = "Razer Hammerhead Duo",
	[20047] = "Oppo A15s",
	[20048] = "Oppo Reno 5 Pro 5G",
	[20049] = "Oppo A94",
	[20050] = "OPPO Find X3",
	[20051] = "Honda City",
	[20052] = "黄金大牌2THB",
	[20053] = "黄金中牌1THB",
	[20054] = "黄金小牌0.5THB",
	[20055] = "黄金小牌0.25THB",
	[20056] = "iPhone 12 Pro 128GB(周年庆版)",
	[20057] = "Razer-雷蛇战锤入耳耳机(有线)",
	[20058] = "Razer-战锤狂鲨入耳式耳塞(无线)",
	[20059] = "Razer-雷蛇猫耳耳机粉色(无线)",
	[20060] = "iPad 11 Pro Wifi+Cellular 256GB",
	[20061] = "OPPO A54",
	[20062] = "OPPO A15",
	[20063] = "OPPO A74 5G",
	[20064] = "3周年庆充电宝",
	[20065] = "iPhone 13 Pro",
	[20066] = "iPhone 13",
	[20067] = "iPad Mini",
	[20068] = "samsung z flip",
	[20069] = "OPPO Reno6 Pro",
	[20070] = "OPPO A16",
	[20071] = "Samsung Galaxy A03s",
	[20072] = "Razer-锤头鲨无线耳机",
	[20073] = "Razer-Nari Ultimate",
	[20074] = "Razer Opus X",
	[20075] = "Razer Kraken X",
	[20076] = "圣诞杯子",
	[20077] = "圣诞玩偶",
	[20078] = "truemoney 20THB(兑换卡)",
	[20079] = "OPPO A95",
	[20080] = "Razer BlackShark V2 X - Green",
	[20081] = "Razer Kraken BT - Hello Kitty and Friends Edition",
	[20082] = "Razer Opus X - 绿色",
	[20083] = "ipad air 5",
	[20084] = "Galaxy S22 Ultra",
	[20085] = "truemoney 50THB(钱包)",
	[20086] = "truemoney 20THB(钱包)",
	[20087] = "Razer BlackShark V2 X - White",
	[20088] = "Razer BlackShark V2 Pro - Six Siege Special Edition",
	[20089] = "Razer BlackShark V2 - ESL Edition",
	[20090] = "Razer BlackShark V2 Special Edition",
	[20091] = "Razer BlackShark V2 CouRageJD Edition",
	[20092] = "truemoney 20THB(钱包)",
	[20093] = "truemoney 20THB(兑换卡)",
	[20094] = "truemoney 20THB",
	[20095] = "truemoney 50THB",
	[20096] = "truemoney 90THB",
	[20097] = "truemoney 150THB",
	[20098] = "truemoney 300THB",
	[20099] = "truemoney 500THB",
	[20100] = "Vespa LX 125 I-GET",
	[20101] = "iPhone 14 Pro Max 128GB",
	[20102] = "iPhone 14 128GB",
	[20103] = "黄金半小牌 0.125THB",
	[20104] = "Apple Watch Series 7",
	[20105] = "OPPO Reno8 Z 5G",
	[20106] = "OPPO A96",
	[20107] = "V0专属truemoney 20THB",
	[20108] = "4周年庆定制衣服",
	[20109] = "Apple Watch Series 8",
	[20110] = "iPhone 14 Plus 128GB",
	[20111] = "Galaxy A53 5G 128GB",
	[20112] = "Galaxy A23 128GB",
	[20113] = "小牌黄金1克",
	[20114] = "OPPO Reno8 5G",
	[20115] = "OPPO A96",
	[20116] = "OPPO A17",
	[20117] = "游戏定制枕头",
	[20118] = "iPad 10.9 256G WIFI",
	[20119] = "Apple Watch SE",
	[20120] = "truemoney 50THB",
	[20121] = "truemoney 90THB",
	[20122] = "truemoney 150THB",
	[20123] = "truemoney 300THB",
	[20124] = "truemoney 300THB",
	[20125] = "Hold Me Black(LV)",
	[20126] = "Trunk(LV)",
	

	--道具描述
	des2 = "可用于各个游戏",
	des3 = "",
	des7 = "可用于聊天栏发言",
	des22 = "可用于实物商城实物兑换,可参与实物商城免费夺宝",
	des23 = "dummy中,用于创建K房,与好友一起玩耍",
	des26 = "收集后可在泼水节签到活动中兑换节日专属头像框",
	des28 = "可修改昵称使用",
	des29 = "收集后可兑换点卡使用",
	des35 = "可通过参与七日签到或万圣节扭蛋活动中获取,收集兑换特定活动头像框",
	des36 = "购买特权礼包获得可用于水晶商城兑换使用",
	des37 = "收集后可兑换圣诞节专属头像框",
	des38 = "收集后可兑换春节专属头像框",
	des39 = "收集后可在合成扭蛋活动抽奖",
	des46 = "可用于实物商城实物兑换,可参与实物商城免费夺宝",
	des47 = "",
	des48 = "用于参与周年庆转盘道具",
	des49 = "",
	des50 = "自动激活,激活后赠送免交易税一周",
	des51 = "使用后可解绑当前手机号码",
	des52 = "可修改昵称使用",
	des54 = "购买后享受超值月卡权益",
	des55 = "购买后享受至尊月卡权益",
	des56 = "2021年万圣节活动中间货币",
	des57 = "2021年万圣节活动购买签到礼包获得,购买后立即生效,在接下来登录的7天,每天都可获得登录奖励",
	des58 = "2021年水灯节活动中间货币",
	des59 = "2021年水灯节活动购买签到礼包获得,购买后立即生效,在接下来登录的7天,每天都可获得登录奖励",
	des60 = "",
	des61 = "",
	des62 = "可在实物商城兑换truemoney wallet 价值20THB",
	des63 = "",
	des64 = "",
	des65 = "",
	des66 = "",
	des67 = "",
	des68 = "",
	des69 = "",
	des70 = "",
	des71 = "",
	des72 = "可在实物商城兑换truemoney wallet 价值50THB",
	des73 = "",
	des74 = "",
	des75 = "",
	des76 = "",
	des77 = "",
	des78 = "",
	des79 = "",
	des80 = "",
	des81 = "",
	des82 = "",
	des83 = "",
	des84 = "",
	des85 = "",
	des86 = "",
	des87 = "",
	des88 = "",
	des89 = "",
	des90 = "",
	des91 = "",
	des92 = "",
	des93 = "",
	des94 = "",
	des95 = "",
	des96 = "",
	des97 = "限定活动道具不可出售",
	des98 = "",
	des99 = "",
	des100 = "",
	des101 = "",
	des102 = "",
	des103 = "",
	des501 = "合成大作战内,合成稀有鱼所需材料,也可兑换筹码使用",
	des502 = "合成大作战内,合成稀有鱼所需材料,也可兑换筹码使用",
	des503 = "合成大作战内,合成稀有鱼所需材料,也可兑换筹码使用",
	des504 = "合成大作战内,合成稀有鱼所需材料,也可兑换筹码使用",
	des505 = "合成大作战内,合成史诗鱼所需材料,也可兑换筹码使用",
	des506 = "合成大作战内,合成史诗鱼所需材料,也可兑换筹码使用",
	des507 = "合成大作战内,合成史诗鱼所需材料,也可兑换筹码使用",
	des508 = "合成大作战内,合成史诗鱼所需材料,也可兑换筹码使用",
	des509 = "合成大作战内,合成传说鱼所需材料,也可兑换筹码使用",
	des510 = "合成大作战内,合成传说鱼所需材料,也可兑换筹码使用",
	des511 = "合成大作战内,合成传说鱼所需材料,也可兑换筹码使用",
	des512 = "合成大作战内,合成逆天鱼所需材料,也可兑换筹码使用",
	des513 = "合成大作战内,合成逆天鱼所需材料,也可兑换筹码使用",
	des514 = "合成大作战内,合成逆天鱼所需材料,也可兑换筹码使用",
	des515 = "可在合成大作战内兑换筹码使用",
	des516 = "可在合成大作战内兑换筹码使用",
	des1001 = "二人捕鱼大乱斗中,使用后可获得小额筹码奖励",
	des1002 = "二人捕鱼大乱斗中,使用后可获得小额筹码奖励",
	des1003 = "二人捕鱼大乱斗中,使用后可获得中额筹码奖励",
	des1004 = "二人捕鱼大乱斗中,使用后可获得巨额筹码奖励",
	des1005 = "二人捕鱼大乱斗中,使用后可获得海量筹码奖励",
	des1006 = "二人捕鱼大乱斗中,使用后可获得x筹码奖励",
	des1007 = "二人捕鱼大乱斗中,使用后可获得x筹码奖励",
	des1012 = "四人捕鱼中,使用后可获得x筹码奖励 ",
	des1013 = "四人捕鱼中,使用后可获得x筹码奖励 ",
	des1014 = "四人捕鱼中,使用后可获得x筹码奖励 ",
	des1015 = "四人捕鱼中,使用后可获得x筹码奖励 ",
	des1016 = "二人捕鱼大乱斗中,使用后可获得x筹码奖励",
	des1017 = "二人捕鱼大乱斗中,使用后可获得x筹码奖励",
	des1018 = "二人捕鱼大乱斗中,使用后可获得海量筹码奖励",
	des1022 = "四人捕鱼中,使用后可获得筹码奖励",
	des1023 = "四人捕鱼中,使用后可获得筹码奖励",
	des1024 = "四人捕鱼中,使用后可获得筹码奖励",
	des1025 = "四人捕鱼中,使用后可获得筹码奖励",
	des1030 = "使用后,可在场景内召唤出一条大型鱼种",
	des1031 = "PlaneWar中,使用后可获得中额筹码奖励",
	des1032 = "PlaneWar中,使用后可获得中额筹码奖励",
	des1033 = "PlaneWar中,使用后可获得大额筹码奖励",
	des1034 = "PlaneWar中,使用后可获得巨额筹码奖励",
	des1035 = "PlaneWar中,使用后可获得中额筹码奖励",
	des1036 = "PlaneWar中,使用后可获得中额筹码奖励",
	des1037 = "PlaneWar中,使用后可获得大额筹码奖励",
	des1038 = "PlaneWar中,使用后可获得巨额筹码奖励",
	des1043 = "飞机捕鱼中使用可召唤出飞机",
	des1044 = "可用于飞机捕鱼初级场,召唤出轮盘武器",
	des1045 = "可用于飞机捕鱼中级场,召唤出轮盘武器",
	des1046 = "可用于飞机捕鱼高级场,召唤出轮盘武器",
	des1047 = "可用于飞机捕鱼专家场,召唤出轮盘武器",
	des1048 = "可用于飞机捕鱼初级场,使用钻石召唤轮盘武器",
	des1049 = "可用于飞机捕鱼中级场,使用钻石召唤轮盘武器",
	des1050 = "可用于飞机捕鱼高级场,使用钻石召唤轮盘武器",
	des1101 = "使用之后可获得最高50次,最高12000倍的免费次数",
	des1102 = "在冰与火之歌中,免费释放一次价值为 50*100 的巨龙之怒",
	des1103 = "在冰与火之歌中,免费释放一次价值为 200*100 的巨龙之怒",
	des1104 = "在冰与火之歌中,免费释放一次价值为 1000*100 的巨龙之怒",
	des1105 = "在冰与火之歌中,免费释放一次价值为 5000*100 的巨龙之怒",
	des1106 = "在冰与火之歌中,享受行动点消耗-1、一键部署功能和特殊英雄等特权",
	des1107 = "打地鼠限定拖鞋武器",
	des1109 = "活动道具背包内使用可兑换10000筹码",
	des1110 = "该炮台可在二人四人捕鱼和飞机游戏中使用",
	des1111 = "《冰与火之歌》中免费释放价值为2000*100的巨龙之怒",
	des1112 = "《冰与火之歌》中兑换宝箱的材料",
	des1113 = "《冰与火之歌》中兑换宝箱的材料",
	des1114 = "《冰与火之歌》中兑换宝箱的材料",
	des1115 = "《冰与火之歌》中兑换宝箱的材料",
	des1116 = "猎牛达人游戏内",
	des1117 = "地鼠大乱斗游戏内",
	des1118 = "木乃伊归来游戏内",
	des1119 = "二人捕鱼初级道具,可触发一次200倍率神龙转轮,最大价值600000",
	des1120 = "二人捕鱼中级道具,可触发一次700倍率神龙转轮,最大价值2100000",
	des1121 = "二人捕鱼高级道具,可触发一次2000倍率神龙转轮,最大价值6000000",	
	des1122 = "抽奖活动产出的炽焰炮台碎片,20个兑换炮台",	
	des1123 = "炽焰龙击炮,由20个碎片合成",	
	des1124 = "抽奖活动产出的朱雀炮台碎片,20个兑换炮台",
	des1125 = "朱雀炮台,由20个碎片合成",
	des1126 = "抽奖活动产出的白虎炮台碎片,20个兑换炮台",
	des1127 = "白虎炮台,由20个碎片合成",
	des1128 = "抽奖活动产出的玉兔炮台碎片,20个兑换炮台",
	des1129 = "玉兔炮台,由20个碎片合成",
	des1130 = "2021万圣节挑战活动-兑换商城的奖励宝箱",
	des1131 = "2021万圣节挑战活动-兑换商城的奖励宝箱",
	des1132 = "2021万圣节挑战活动-兑换商城的奖励宝箱",
	des1133 = "2021万圣节挑战活动-兑换商城的奖励宝箱",
	des1134 = "2021万圣节挑战活动-兑换商城的奖励宝箱",
	des1135 = "活动中集齐20个可合成蛋糕炮台,在背包中可兑换1000筹码",
	des1136 = "",
	des1137 = "",
	des1138 = "活动中集齐20个可合成蛋糕炮台,在背包中可兑换1000筹码",
	des1139 = "",
	des1140 = "",
	des1141 = "",
	des1142 = "",
	des1143 = "",
	des1144 = "",
	des1145 = "",
	des1146 = "",
	des1147 = "",
	des1148 = "",
	des1149 = "",
	des1150 = "在活动时间内,收集达到20个,可以合成青龙炮台。在背包里可以兑换成筹码  1 个碎片 可以兑换：1000 筹码",
	des1151 = "",
	des1152 = "使用后，可冰冻场景内的鱼",
	des1153 = "抽奖活动产出的电音炮台碎片,20个兑换炮台",
	des1154 = "",
	des2006 = "",
	des2007 = "",
	des2008 = "",
	des2009 = "",
	des2010 = "",
	des2011 = "",
	des3001 = "2020年泼水节绝版头像框,祝你生活幸福！",
	des3002 = "2020年泼水节绝版头像框,祝你节日快乐！",
	des3003 = "可通过新手签到活动获取",
	des3004 = "通过万圣节南瓜道具兑换获得",
	des3005 = "通过万圣节南瓜道具兑换获得",
	des3006 = "购买特权礼包获得",
	des3007 = "购买特权礼包获得",
	des3008 = "购买特权礼包获得",
	des3009 = "购买特权礼包获得",
	des3010 = "购买特权礼包获得",
	des3011 = "获得后可在游戏内使用专属入场特效",
	des3012 = "获得后可在游戏内使用专属入场特效",
	des3013 = "获得后可在游戏内使用专属入场特效",
	des3014 = "获得后可在游戏内使用专属入场特效",
	des3015 = "获得后可在游戏内使用专属入场特效",
	des3016 = "圣诞签到活动专属头像框",
	des3017 = "圣诞签到活动专属头像框",
	des3018 = "获得后可在游戏内使用专属入场特效",
	des3019 = "获得后可在游戏内使用专属入场特效",
	des3020 = "获得后可在游戏内使用专属入场特效",
	des3021 = "获得后可在游戏内使用专属入场特效",
	des3022 = "获得后可在游戏内使用专属入场特效",
	des3023 = "春节签到活动专属头像框",
	des3024 = "春节签到活动专属头像框",
	des3025 = "获得后可在游戏内使用专属入场特效",
	des3026 = "获得后可在游戏内使用专属入场特效",
	des3027 = "获得后可在游戏内使用专属入场特效",
	des3028 = "获得后可在游戏内使用专属入场特效",
	des3029 = "获得后可在游戏内使用专属入场特效",
	des3030 = "泼水节专属道具",
	des3031 = "泼水节专属道具",
	des3032 = "线下VIP福利赠送",
	des3033 = "功德活动享有",
	des3034 = "购买超值月卡享有",
	des3035 = "",
	des3036 = "",
	des3037 = "",
	des3038 = "",
	des3039 = "",
	des3040 = "2021万圣节挑战活动专属头像框",
	des3041 = "2021水灯节挑战活动专属头像框",
	des3042 = "",
	des3043 = "",
	des3044 = "",
	des3045 = "欢乐激斗任意场使用,释放导弹随机获得筹码奖励,最大可获得30000",
	des3046 = "欢乐激斗任意场使用,释放导弹随机获得筹码奖励,最大可获得150000",
	des3047 = "欢乐激斗任意场使用,释放导弹随机获得筹码奖励,最大可获得750000",
	des3048 = "欢乐激斗任意场使用,释放导弹随机获得筹码奖励,最大可获得37500000",
	des3049 = "",
	des3050 = "",
	des3051 = "",
	des3052 = "",
	des3053 = "",
	des3054 = "",
	des3055 = "",
	des3056 = "",
	des3057 = "",
	des3058 = "",
	des3059 = "",
	des3060 = "",
	des3061 = "",
	des4001 = "dummy中,用于参加积分赛",
	des4002 = "dummy中,用于积分赛免费复活一次",
	des4003 = "dummy中,用于参加实物赛",
	des4004 = "dummy中,用于实物赛免费复活一次",
	des4005 = "dummy中,用于参加vip赛",
	des4006 = "dummy中,用于vip赛免费复活一次",
	des4007 = "dummy中,用于参加勇士赛",
	des4008 = "二人捕鱼大乱斗最高等级的鱼雷,价值500万",
	des4009 = "用来午夜赛免费报名1次",
	des4010 = "用来午夜赛免费复活1次",
	des4011 = "",
	des4012 = "",
	des4013 = "",
	des4014 = "",
	des4015 = "",
	des4016 = "",
	des4017 = "",
	des4018 = "",
	des4019 = "",
	des4020 = "",
	des4021 = "",
	des4022 = "",
	des4023 = "",
	des4024 = "",
	des4025 = "用于四神兽召唤活动使用，收集可兑换对应道具",
	des7011 = "Dummy中特殊牌型解锁",
	des8001 = "增益卡用于pok deng中抽取特殊牌型、倍数及局数； 当局最高可获得4000万",
	des9005 = "仅限在新财神初级场使用,以500下注额进入免费模式",
	des9006 = "仅限在新财神中级场使用,以1000下注额进入免费模式",
	des9007 = "以10000下注额进入的免费模式的礼包玩法",
	des9008 = "在丛林密宝内使用可进入猴子或狗熊模式",
	des9009 = "基础赛超值礼包中购买所获得的积分,积分范围在1000-3000",
	des9010 = "精英赛助力礼包中购买所获得的积分,积分范围在1000-3000",
	des9011 = "精英赛冲刺礼包中购买所获得的积分,积分范围在30000-70000",
	des9012 = "牛人赛冲刺礼包中购买所获得的积分,积分范围在50000-100000",
	des9013 = "以50000下注额进入的免费模式的礼包玩法",
	des9014 = "游戏内在头像处选择使用",
	des9015 = "游戏内在头像处选择使用",
	des9016 = "游戏内在头像处选择使用",
	des9017 = "游戏内在头像处选择使用",
	des9018 = "游戏内在头像处选择使用",
	des9019 = "游戏内在头像处选择使用",
	des9020 = "游戏内在头像处选择使用",
	des9021 = "游戏内在头像处选择使用",
	des9022 = "游戏内在头像处选择使用",
	des9023 = "游戏内在头像处选择使用",
	des9024 = "游戏内在头像处选择使用",
	des9025 = "游戏内在头像处选择使用",
	des9026 = "游戏内在头像处选择使用",
	des9027 = "游戏内在头像处选择使用",
	des9028 = "仅限在新财神初级场使用,以50下注额进入免费模式",
    des9029 = "仅限在新财神初级场使用,以100下注额进入免费模式",
    des9030 = "仅限在新财神初级场使用,以300下注额进入免费模式",
    des9031 = "仅限在新财神中级场使用,以3000下注额进入免费模式",
    des9032 = "仅限在新财神中级场使用,以5000下注额进入免费模式",
    des9033 = "仅限在新财神高级场使用,以20000下注额进入免费模式",
    des9034 = "仅限在新财神高级场使用,以30000下注额进入免费模式",
    des9035 = "仅限在新财神专家场使用,以300000下注额进入免费模式",
	des9037 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9038 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9039 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9040 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9041 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9042 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9043 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9044 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9045 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9046 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9047 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9048 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9049 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9050 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9051 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9052 = "仅在JUNGLE TREASURE游戏初级场使用",
	des9053 = "飞机捕鱼任意场使用,可触发一次200倍率幸运转盘,最大价值300000",
	des9054 = "飞机捕鱼任意场使用,可触发一次700倍率幸运转盘,最大价值1050000",
	des9055 = "飞机捕鱼任意场使用,可触发一次6000倍率幸运转盘,最大价值9000000",
	des9056 = "消耗召唤币,召唤龙虎斗魔物",
	des9057 = "",
	des9058 = "能够在FAFAFA游戏中使用450的下注额度进入免费模式",
	des9059 = "能够在FAFAFA游戏中使用1350的下注额度进入免费模式",
	des9060 = "能够在FAFAFA游戏中使用4500的下注额度进入免费模式",
	des9061 = "能够在FAFAFA游戏中使用18000的下注额度进入免费模式",
	des9062 = "能够在roma3游戏中使用450的下注额度进入免费模式",
	des9063 = "能够在roma3游戏中使用1410的下注额度进入免费模式",
	des9064 = "能够在roma3游戏中使用7500的下注额度进入免费模式",
	des9065 = "能够在roma3游戏中使用22500的下注额度进入免费模式",
	des9066 = "能够在roma游戏中使用450的下注额度进入免费模式",
	des9067 = "能够在roma游戏中使用1410的下注额度进入免费模式",
	des9068 = "能够在roma游戏中使用7500的下注额度进入免费模式",
	des9069 = "能够在roma游戏中使用22500的下注额度进入免费模式",
	des9070 = "能够在romax游戏中使用450的下注额度进入免费模式",
	des9071 = "能够在romax游戏中使用1410的下注额度进入免费模式",
	des9072 = "能够在romax游戏中使用7500的下注额度进入免费模式",
	des9073 = "能够在romax游戏中使用22500的下注额度进入免费模式",
	des9074 = "能够在dfdc游戏中使用500的下注额度进入免费模式",
	des9075 = "能够在dfdc游戏中使用1000的下注额度进入免费模式",
	des9076 = "能够在dfdc游戏中使用5000的下注额度进入免费模式",
	des9077 = "能够在dfdc游戏中使用20000的下注额度进入免费模式",
	des9078 = "能够在AZTEC游戏中使用500的下注额度进入免费模式",
	des9079 = "能够在AZTEC游戏中使用1000的下注额度进入免费模式",
	des9080 = "能够在AZTEC游戏中使用5000的下注额度进入免费模式",
	des9081 = "能够在AZTEC游戏中使用20000的下注额度进入免费模式",
	des9082 = "",
	des9083 = "",
	des9084 = "",
	des9085 = "",
	des9086 = "",
	des9087 = "",
	des9088 = "",
	des9089 = "",
	des9093 = "参与比赛竞猜，猜中比赛结果将获得竞猜积分，每场比赛下注赢取越多，获得的积分就越高！",
	des9094 = "炮台抽奖活动获得,收集炮台碎片满20个可兑换",
	des9095 = "炮台抽奖活动获得,收集满20个可兑换足球派对炮台",
	des9098 = "",
	des9099 = "",
	des9100 = "",
	des9101 = "",
	des9102 = "",
	des9103 = "",
	des9104 = "装备后可提升开炮速度",
	des9105 = "装备后可提升开炮速度",
	des9106 = "可在深海寻宝功能内进行抽奖",
	des9107 = "可在深海寻宝功能内进行商品兑换",
	des9108 = "",
	des9109 = "西游捕鱼中捕获孙悟空掉落，使用后攻击特定怪物",
	des9110 = "西游捕鱼中捕获猪八戒掉落，使用后攻击特定怪物",
	des9111 = "西游捕鱼中捕获沙僧掉落，使用后攻击特定怪物",
	des9112 = "西游捕鱼中捕获白龙马掉落，使用后攻击特定怪物",
	des9113 = "",
	des9114 = "",
	des9115 = "",
	des9116 = "",
	des9117 = "",
	des9118 = "",
	des9119 = "",
	des9120 = "",
	des9121 = "",
	des9122 = "",
	des9123 = "",
	des9124 = "",
	des9125 = "",
	des9126 = "",
	des9127 = "",
	des9128 = "",
	des9129 = "",
	des9130 = "",
	des9131 = "专属外观",
	des9132 = "S3赛季内装备可提升开炮速度",
	des9133 = "专属外观",
	des9134 = "活动期间装备可提升开炮速度（小）",
	des9135 = "活动期间装备可提升开炮速度（大）",
	des10001 = "",
	des10002 = "",
	des10003 = "",
	des10004 = "",
	des10005 = "",
	des10006 = "",
	des10011 = "",
	des10012 = "",
	des10013 = "",
	des10014 = "",
	des10015 = "",
	des10021 = "",
	des10022 = "",
	des10023 = "",
	des10024 = "",
	des20011 = "",
	des20012 = "",
	des20013 = "",
	des20014 = "",
	des20015 = "",
	des20016 = "",
	des20017 = "",
	des20018 = "",
	des20019 = "",
	des20020 = "",
	des20021 = "",
	des20022 = "",
	des20023 = "",
	des20024 = "",
	des20025 = "",
	des20026 = "",
	des20027 = "",
	des20028 = "",
	des20029 = "",
	des20030 = "",
	des20031 = "",
	des20032 = "",
	des20033 = "",
	des20034 = "",
	des20035 = "",
	des20036 = "",
	des20037 = "",
	des20038 = "",
	des20039 = "",
	des20040 = "",
	des20041 = "",
	des20042 = "",
	des20043 = "",
	des20044 = "",
	des20045 = "",
	des20046 = "",
	des20047 = "",
	des20048 = "",
	des20049 = "",
	des20050 = "",
	des20051 = "",
	des20052 = "",
	des20053 = "",
	des20054 = "",
	des20055 = "",
	des20056 = "",
	des20057 = "",
	des20058 = "",
	des20059 = "",
	des20060 = "",
	des20061 = "",
	des20062 = "",
	des20063 = "",
	des20064 = "",
	des20065 = "",
	des20066 = "",
	des20067 = "",
	des20068 = "",
	des20069 = "",
	des20070 = "",
	des20071 = "",
	des20072 = "",
	des20073 = "",
	des20074 = "",
	des20075 = "",
	des20076 = "",
	des20077 = "",
	des20078 = "",
	des20079 = "",
	des20080 = "",
	des20081 = "",
	des20082 = "",
	des20083 = "",
	des20084 = "",
	des20085 = "",
	des20086 = "",
	des20087 = "",
	des20088 = "",
	des20089 = "",
	des20090 = "",
	des20091 = "",
	des20092 = "",
	des20093 = "可在实物商城兑换truemoney wallet 价值20THB",
	des20094 = "",
	des20095 = "",
	des20096 = "",
	des20097 = "",
	des20098 = "",
	des20099 = "",
	des20100 = "",
	des20101 = "",
	des20102 = "",
	des20103 = "",
	des20104 = "",
	des20105 = "",
	des20106 = "",
	des20107 = "",
	des20108 = "",
	des20109 = "",
	des20110 = "",
	des20111 = "",
	des20112 = "",
	des20113 = "",
	des20114 = "",
	des20115 = "",
	des20116 = "",
	des20117 = "",
	des20118 = "",
	des20119 = "",
	des20120 = "",
	des20121 = "",
	des20122 = "",
	des20123 = "",
	des20124 = "",
	des20125 = "",
	des20126 = "",

}

return lan