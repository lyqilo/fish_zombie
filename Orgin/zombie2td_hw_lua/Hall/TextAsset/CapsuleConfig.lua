local Config = {
	--主界面展示
	mainShow = {
		--特别大奖，顺序从左到右
		special = {
			{id = 10003, num = 1, text = ""},
			{id = 10001, num = 1, text = ""},
			{id = 20093, num = 1, text = ""},
			{id = 20113, num = 1, text = ""},
			{id = 20117, num = 1, text = ""},
			{id = 2, num = 10000000, text = "10M"},
		},
		--大奖列表
		big = {
			{id = 2, num = 999999, text = "999999"},
			{id = 2, num = 599999, text = "599999"},
			{id = 2, num = 199999, text = "199999"}
		},
		--普通奖品
		normal = {
			{id = 46, num = 2000, text = "2000"},
			{id = 46, num = 600, text = "600"},
			{id = 46, num = 400, text = "400"},
			{id = 46, num = 200, text = "200"},
			{id = 46, num = 160, text = "160"},
			{id = 46, num = 80, text = "80"},
			{id = 46, num = 60, text = "60"},
		}
	},
	
	--奖池列表
	rewardsList = {
		--钻石扭蛋
		[1] = {
			--对应扭蛋图片索引
			onceAnimIndex = 2,--单次
			animIndex = 2,	  --十连
			--列表
			list = {
				{id = 10003, num = 1, text = ""},
				{id = 10001, num = 1, text = ""},
				{id = 20093, num = 1, text = ""},
				{id = 20113, num = 1, text = ""},
				{id = 20117, num = 1, text = ""},
				{id = 2, num = 10000000, text = "10M"},
			}
		},
		--黄金扭蛋
		[2] = {
			--对应扭蛋图片索引
			onceAnimIndex = 1,--单次
			animIndex = 3,	  --十连
			--列表
			list = {
				{id = 2, num = 999999, text = "999999"},
				{id = 2, num = 599999, text = "599999"},
				{id = 2, num = 199999, text = "199999"},
			}
		},
		--普通扭蛋
		[3] = {
			--对应扭蛋图片索引
			onceAnimIndex = 3,--单次
			animIndex = 1,	  --十连
			--列表
			list = {
				{id = 46, num = 2000, text = "2000"},
				{id = 46, num = 600, text = "600"},
				{id = 46, num = 400, text = "400"},
				{id = 46, num = 200, text = "200"},
				{id = 46, num = 160, text = "160"},
				{id = 46, num = 80, text = "80"},
				{id = 46, num = 60, text = "60"},
			}
		}
	},
	
	--排行榜奖励
	rankRewards = {
		{rank = "1",rew1 = {id = 2,count = 20000000}},
		{rank = "2",rew1 = {id = 2,count = 10000000}},
		{rank = "3",rew1 = {id = 2,count = 5000000}},
		{rank = "4",rew1 = {id = 2,count = 3000000}},
		{rank = "5",rew1 = {id = 2,count = 3000000}},
		{rank = "6",rew1 = {id = 2,count = 3000000}},
		{rank = "7",rew1 = {id = 2,count = 3000000}},
		{rank = "8",rew1 = {id = 2,count = 3000000}},
		{rank = "9",rew1 = {id = 2,count = 3000000}},
		{rank = "10",rew1 = {id = 2,count = 3000000}},
	}
	
}

return Config