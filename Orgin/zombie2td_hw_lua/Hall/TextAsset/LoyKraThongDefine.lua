local CC = require("CC")
local config = {}

config.wishListData1 = {
	{
		Number = 1,
		ConfigId = CC.shared_enums_pb.EPC_ChouMa,
		Count = 5990000,
		Score = 10,
	},
	{
		Number = 2,
		ConfigId = CC.shared_enums_pb.EPC_ChouMa,
		Count = 2990000,
		Score = 6,
	},
	{
		Number = 3,
		ConfigId = CC.shared_enums_pb.EPC_ChouMa,
		Count = 1590000,
		Score = 4,
	},
	{
		Number = 4,
		ConfigId = CC.shared_enums_pb.EPC_ChouMa,
		Count = 390000,
		Score = 2,
	},
}

config.wishListData2 = {
	{
		Number = 1,
		ConfigId = CC.shared_enums_pb.EPC_90Card,
		Count = 1,
		Score = 10,
	},
	{
		Number = 2,
		ConfigId = CC.shared_enums_pb.EPC_ChouMa,
		Count = 800000,
		Score = 6,
	},
	{
		Number = 3,
		ConfigId = CC.shared_enums_pb.EPC_ChouMa,
		Count = 500000,
		Score = 4,
	},
	{
		Number = 4,
		ConfigId = CC.shared_enums_pb.EPC_ChouMa,
		Count = 150000,
		Score = 2,
	},
}

return config