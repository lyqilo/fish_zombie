-- 每日抽奖客户端配置

-- 点卡			บัตรเติมเงิน
-- 钻石			เพชร
-- 礼票			บัตรของขวัญ
-- 筹码         ชิป

--actTime:活动时间

--[[
award:奖励配置（与服务器配置一致）
    PropId           -- 道具Id
    PropNum          -- 道具数量
    PropIcon         -- 道具资源图片
    Message          -- 奖励描述
    Entity           -- 是否是实物(是实物道具也具备有分享功能)
]]

--[[
showCfg:客户端展示配置
    vipMin、vipMax  -- VIP区间
    showList        -- 奖励列表（填award的id）
]]

local cfg = {
    --活动时间
	actTime = "29.05.2023 - 04.06.2023",
    --奖励配置（与服务器配置一致）
	award = {
		[1001]={
			PropId = 10004,
			PropNum = 1,
			PropIcon = "prop_img_10004",
			Message = "บัตรเติมเงิน500",
			Entity = true,
		},
		[1002]={
			PropId = 2,
			PropNum = 999,
			PropIcon = "prop_img_2",
			Message = "ชิป999",
			Entity = false,
		},
		[1003]={
			PropId = 10001,
			PropNum = 1,
			PropIcon = "prop_img_10001",
			Message = "บัตรเติมเงิน50",
			Entity = true,
		},
		[1004]={
			PropId = 2,
			PropNum = 3999,
			PropIcon = "lottery_icon_2",
			Message = "ชิป3999",
			Entity = false,
		},
		[1005]={
			PropId = 71,
			PropNum = 1,
			PropIcon = "prop_img_71",
			Message = "เหรียญกาชาปอง1",
			Entity = false,
		},
		[1006]={
			PropId = 10006,
			PropNum = 1,
			PropIcon = "prop_img_10006",
			Message = "บัตรเติมเงิน90",
			Entity = true,
		},
		[1007]={
			PropId = 46,
			PropNum = 30,
			PropIcon = "prop_img_46",
			Message = "บัตรของขวัญ30",
			Entity = false,
		},
		[1008]={
			PropId = 71,
			PropNum = 2,
			PropIcon = "prop_img_71",
			Message = "เหรียญกาชาปอง2",
			Entity = false,
		},
		[1009]={
			PropId = 2,
			PropNum = 400000,
			PropIcon = "lottery_icon_1",
			Message = "ชิป400000",
			Entity = false,
		},
		[1010]={
			PropId = 2,
			PropNum = 600000,
			PropIcon = "lottery_icon_2",
			Message = "เพชร600000",
			Entity = false,
		},
		[1011]={
			PropId = 71,
			PropNum = 3,
			PropIcon = "prop_img_71",
			Message = "เหรียญกาชาปอง3",
			Entity = false,
		},
		[1012]={
			PropId = 46,
			PropNum = 5000,
			PropIcon = "prop_img_46",
			Message = "บัตรของขวัญ5000",
			Entity = false,
		},
		[1013]={
			PropId = 10003,
			PropNum = 1,
			PropIcon = "prop_img_10003",
			Message = "บัตรเติมเงิน300",
			Entity = true,
		},
		[1014]={
			PropId = 46,
			PropNum = 2400,
			PropIcon = "prop_img_46",
			Message = "บัตรของขวัญ2400",
			Entity = false,
		},
		[1015]={
			PropId = 71,
			PropNum = 10,
			PropIcon = "prop_img_71",
			Message = "เหรียญกาชาปอง10",
			Entity = false,
		},
		[1016] = {
			PropId = 2,
			PropNum = 1399,
			PropIcon = "prop_img_2",
			Message = "",
			Entity = false,
		},

		[1017] = {
			PropId = 46,
			PropNum = 40,
			PropIcon = "prop_img_46",
			Message = "บัตรของขวัญ40",
			Entity = false,
		},
		[1018] = {
			PropId = 2,
			PropNum = 2599,
			PropIcon = "prop_img_2",
			Message = "",
			Entity = false,
		},
		[1019] = {
			PropId = 46,
			PropNum = 60,
			PropIcon = "prop_img_46",
			Message = "บัตรของขวัญ60",
			Entity = false,
		},
		[1020] = {
			PropId = 2,
			PropNum = 3999,
			PropIcon = "prop_img_2",
			Message = "",
			Entity = false,
		},
		[1021] = {
			PropId = 46,
			PropNum = 120,
			PropIcon = "prop_img_46",
			Message = "บัตรของขวัญ120",
			Entity = false,
		},
		[1022] = {
			PropId = 2,
			PropNum = 6999,
			PropIcon = "prop_img_2",
			Message = "",
			Entity = false,
		},
		[1023] = {
			PropId = 10002,
			PropNum = 1,
			PropIcon = "prop_img_10002",
			Message = "บัตรเติมเงิน150",
			Entity = true,
		},
		[1024] = {
			PropId = 46,
			PropNum = 160,
			PropIcon = "prop_img_46",
			Message = "บัตรของขวัญ160",
			Entity = false,
		},
		[1025] = {
			PropId = 2,
			PropNum = 29999,
			PropIcon = "prop_img_2",
			Message = "",
			Entity = false,
		},
		[1026] = {
			PropId = 71,
			PropNum = 5,
			PropIcon = "prop_img_71",
			Message = "เหรียญกาชาปอง5",
			Entity = false,
		},
		[1027] = {
			PropId = 71,
			PropNum = 8,
			PropIcon = "prop_img_71",
			Message = "เหรียญกาชาปอง8",
			Entity = false,
		},
		[1028] = {
			PropId = 2,
			PropNum = 700000,
			PropIcon = "prop_img_2",
			Message = "",
			Entity = false,
		},
		[1029] = {
			PropId = 46,
			PropNum = 2600,
			PropIcon = "prop_img_46",
			Message = "บัตรของขวัญ2600",
			Entity = false,
		},
		[1030] = {
			PropId = 46,
			PropNum = 6000,
			PropIcon = "prop_img_46",
			Message = "บัตรของขวัญ6000",
			Entity = false,
		},
		[1031] = {
			PropId = 2,
			PropNum = 1200000,
			PropIcon = "prop_img_2",
			Message = "",
			Entity = false,
		},
		[1032] = {
			PropId = 71,
			PropNum = 20,
			PropIcon = "prop_img_71",
			Message = "เหรียญกาชาปอง20",
			Entity = false,
		},
	},
	
	--展示页
	showCfg = {
		[1] = {
			vipMin = 0,
			vipMax = 0,
			showList = {1005,1016,1002,1007,1008,1018,1003,1017}
		},
		[2] = {
			vipMin = 1,
			vipMax = 2,
			showList = {1007,1005,1018,1003,1004,1019,1008,1006}
		},
		[3] = {
			vipMin = 3,
			vipMax = 9,
			showList = {1023,1019,1008,1020,1021,1011,1006,1022}
		},
		[4] = {
			vipMin = 10,
			vipMax = 19,
			showList = {1013,1021,1011,1022,1024,1026,1025,1023}
		},
		[5] = {
			vipMin = 20,
			vipMax = 24,
			showList = {1001,1009,1010,1015,1012,1013,1014,1027}
		},
		[6] = {
			vipMin = 25,
			vipMax = 30,
			showList = {1001,1029,1015,1030,1031,1032,1013,1028}
		},
	},
}
return cfg