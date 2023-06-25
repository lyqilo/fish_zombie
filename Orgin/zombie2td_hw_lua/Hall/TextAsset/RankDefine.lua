local ranklist = {}

ranklist.HallRank = {
	{
		PropConfigID = 2, --chouma
		Name = "hallRankName1",
		key = "EPC_ChouMa"
	},
	{
		PropConfigID = 5, --like
		Name = "hallRankName2",
		key = "EPC_Like"
	},
	{
		PropConfigID = 6, --honor
		Name = "hallRankName3",
		key = "EPC_Honor"
	}
}

ranklist.GameRank = {
	{
		GameName = "gameRankName1",
		Max = {
			PropConfigID = 6011,
			Name = "gameRankDes1",
			key = "EPC_SM_MaxWin"
		},
		Single = {
			PropConfigID = 6012,
			Name = "gameRankDes2",
			key = "EPC_SM_MaxSingleWin"
		}
	},
	{
		GameName = "gameRankName2",
		Max = {
			PropConfigID = 6021,
			Name = "gameRankDes1",
			key = "EPC_BAC_MaxWin"
		},
		Single = {
			PropConfigID = 6022,
			Name = "gameRankDes2",
			key = "EPC_BAC_MaxSingleWin"
		}
	}
}

return ranklist
