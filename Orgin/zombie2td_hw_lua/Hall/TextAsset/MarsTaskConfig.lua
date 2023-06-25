local MarsTaskConfig = {
	--一阶段配置
	[1] = {
		--任务目标预制体
		targetPrefab = "MarsTaskTarget1",
		--任务目标Image前缀,后缀01-10
		targetImg = "hxrw_fj_1_%02d",
		--小任务进度奖励Icon
		taskIcon = "hxrw_rw_rw_sp",
		--排行榜进度Icon
		rankIcon = "hxrw_fj_tj_1_%02d",
		--图鉴Icon
		atlasIcon = "hxrw_fj_tj_1_%02d",
	},
	--二阶段配置
	[2] = {
		--任务目标预制体
		targetPrefab = "MarsTaskTarget2",
		--任务目标Image前缀,后缀01-10
		targetImg = "hxrw_fj_2_%02d",
		--小任务进度奖励Icon
		taskIcon = "hxrw_rw_rw_sp",
		--排行榜进度Icon
		rankIcon = "hxrw_fj_tj_2_%02d",
		--图鉴Icon
		atlasIcon = "hxrw_fj_tj_2_%02d",
	},
	--三阶段配置
	[3] = {
		--任务目标预制体
		targetPrefab = "MarsTaskTarget3",
		--任务目标Image前缀,后缀01-10
		targetImg = "hxrw_fj_3_%02d",
		--小任务进度奖励Icon
		taskIcon = "hxrw_gj_pd",
		--排行榜进度Icon
		rankIcon = "hxrw_fj_tj_3_%02d",
		--图鉴Icon
		atlasIcon = "hxrw_fj_tj_3_%02d",
	},
	
	--红包Buff
	buff = {
		[1] = {min=1},
		[2] = {min=1},
		[3] = {min=1,max=2},
		[4] = {min=1,max=2},
		[5] = {min=1,max=3},
		[6] = {min=2,max=4},
		[7] = {min=2,max=5},
		[8] = {min=2,max=6},
		[9] = {min=3,max=7},
		[10] = {min=5,max=10},
	},
}

return MarsTaskConfig