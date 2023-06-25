local lan = {
	[-1] = "",
	[1] = "周一",
	[2] = "周二",
	[3] = "周三",
	[4] = "周四",
	[5] = "周五",
	[6] = "周六",
	[0] = "周天",
	download_tip = "等待中",
	matching = "比赛中",
	enterGame_tip = "需VIP%d解锁该游戏，是否要成为VIP？",

	helpTitle = "开赛时间",
	gameName = "游戏",
	gameTime = "时间",
	gameType = "比赛性质",
	gameAward = "大奖",
	gameNameList = {[1] = "飞机", [2] = "老虎机", [3] = "kaeng牌", [4] = "百家乐", [5] = "Pokdeng", [6] = "二人捕鱼",[7] = "Dummy",[8] = "四人捕鱼",[9] = "Pokdeng",[10] = "骰子",},
	gameTimeList = {[1] = {"1月27日\n21:30-22:20", "1月27日\n21:00-21:50", "1月27日\n21:20-21:50", "1月27日\n22:00-22:50", "1月28日\n21:00-22:00",
						"1月28日\n21:30-22:30", "1月28日\n22:00-23:00", "1月29日\n21:00-22:00", "1月29日\n22:00-22:50", "1月29日\n21:00-21:30"},
					[2] = {"1月13日\n21:30-22:20", "1月13日\n21:00-21:50", "1月13日\n21:20-21:50", "1月13日\n22:00-22:50", "1月14日\n21:00-22:00",
						"1月14日\n21:30-22:30", "1月14日\n22:00-23:00", "1月15日\n21:00-22:00", "1月15日\n22:00-22:50", "1月15日\n21:00-21:30"},
					[3] = {"1月20日\n21:30-22:20", "1月20日\n21:00-21:50", "1月20日\n21:20-21:50", "1月20日\n22:00-22:50", "1月21日\n21:00-22:00",
						"1月21日\n21:30-22:30", "1月21日\n22:00-23:00", "1月22日\n21:00-22:00", "1月22日\n22:00-22:50", "1月22日\n21:00-21:30"},
					[4] = {"2月3日\n21:30-22:20", "2月3日\n21:00-21:50", "2月3日\n21:20-21:50", "2月3日\n22:00-22:50", "2月4日\n21:00-22:00",
						"2月4日\n21:30-22:30", "2月4日\n22:00-23:00", "2月5日\n21:00-22:00", "2月5日\n22:00-22:50", "2月5日\n21:00-21:30"},
					[5] = {"2月10日\n21:30-22:20", "2月10日\n21:00-21:50", "2月10日\n21:20-21:50", "2月10日\n22:00-22:50", "2月11日\n21:00-22:00",
						"2月11日\n21:30-22:30", "2月11日\n22:00-23:00", "2月12日\n21:00-22:00", "2月12日\n22:00-22:50", "2月12日\n21:00-21:30"},
					[6] = {"2月17日\n21:30-22:20", "2月17日\n21:00-21:50", "2月17日\n21:20-21:50", "2月17日\n22:00-22:50", "2月18日\n21:00-22:00",
					"2月18日\n21:30-22:30", "2月18日\n22:00-23:00", "2月19日\n21:00-22:00", "2月19日\n22:00-22:50", "2月19日\n21:00-21:30"},
					},
	gameMatchType = {[1] = "积分赛", [2] = "全民赛", [3] = "流水赛"},
	gameMatchMonth = "月末赛",
	gameMatchWeek = "周赛",
	RewardConfig = {
		[1] = {{10003}, {10004}, {10003}, {10004}, {10004},{10004}, {20116}, {10004}, {10003}, {10004}},
		[2] = {{10003, 10002, 10001}, {10004, 10002, 10001}, {10003, 10002, 10006}, {10003, 10002, 10006}, {10003, 10002, 10006},
			{10004, 10003, 10001}, {10003, 10002, 10006}, {10004, 10003, 10001}, {10003, 10006, 10001}, {10003, 10002, 10006}},
		[3] = {{10003, 10002, 10001}, {10004, 10002, 10001}, {10003, 10002, 10006}, {10003, 10002, 10006}, {10003, 10002, 10006},
			{10004, 10003, 10001}, {10003, 10002, 10006}, {10004, 10003, 10001}, {10003, 10006, 10001}, {10003, 10002, 10006}},
		[4] = {{10003, 10002, 10001}, {10004, 10002, 10001}, {10003, 10002, 10006}, {10003, 10002, 10006}, {10003, 10002, 10006},
			{10004, 10003, 10001}, {10003, 10002, 10006}, {10004, 10003, 10001}, {10003, 10006, 10001}, {10003, 10002, 10006}},
		[5] = {{10003, 10002, 10001}, {10004, 10002, 10001}, {10003, 10002, 10006}, {10003, 10002, 10006}, {10003, 10002, 10006},
			{10004, 10003, 10001}, {10003, 10002, 10006}, {10004, 10003, 10001}, {10003, 10006, 10001}, {10003, 10002, 10006}},
		[6] = {{10003, 10002, 10001}, {10004, 10002, 10001}, {10003, 10002, 10006}, {10003, 10002, 10006}, {10003, 10002, 10006},
		{10004, 10003, 10001}, {10003, 10002, 10006}, {10004, 10003, 10001}, {10003, 10006, 10001}, {10003, 10002, 10006}},
	}
}

return lan