local ranklist = {}

--每个实物id的图片资源名称
ranklist.SpriteTab = {
	10001,
	10003,
	10004,
	10005,
	2,
	22
}

--次日宝箱对应的 奖品
ranklist.DayilyBox = {
	[1] = {EntityId = 10001, value = "50"},
	[2] = {EntityId = 2, value = "500K"},
	[3] = {EntityId = 2, value = "10000"},
	[4] = {EntityId = 2, value = "8000"},
	[5] = {EntityId = 2, value = "5000"},
	[6] = {EntityId = 2, value = "3000"},
	[7] = {EntityId = 22, value = "4"},
	[8] = {EntityId = 2, value = "1000"}
}

--七日宝箱对应的 奖品
ranklist.SevenDayBox = {
	[1] = {EntityId = 10003, value = "300"},
	[2] = {EntityId = 2, value = "3M"},
	[3] = {EntityId = 22, value = "60"},
	[4] = {EntityId = 2, value = "24000"},
	[5] = {EntityId = 2, value = "15000"},
	[6] = {EntityId = 2, value = "9000"},
	[7] = {EntityId = 2, value = "6000"},
	[8] = {EntityId = 22, value = "6"}
}

--十五日宝箱对应的 奖品
ranklist.FivteeenDayBox = {
	[1] = {EntityId = 10004, value = "500"},
	[2] = {EntityId = 2, value = "5M"},
	[3] = {EntityId = 22, value = "100"},
	[4] = {EntityId = 2, value = "48000"},
	[5] = {EntityId = 2, value = "30000"},
	[6] = {EntityId = 2, value = "18000"},
	[7] = {EntityId = 2, value = "12000"},
	[8] = {EntityId = 22, value = "12"}
}

--三十日宝箱对应的 奖品
ranklist.ThreetyDayBox = {
	[1] = {EntityId = 10005, value = "1000"},
	[2] = {EntityId = 2, value = "10M"},
	[3] = {EntityId = 22, value = "200"},
	[4] = {EntityId = 2, value = "96000"},
	[5] = {EntityId = 2, value = "60000"},
	[6] = {EntityId = 2, value = "36000"},
	[7] = {EntityId = 2, value = "24000"},
	[8] = {EntityId = 22, value = "24"}
}

return ranklist
