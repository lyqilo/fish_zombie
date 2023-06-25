local CC = require("CC")

local HallDefine = {}

--红点汇总
--一级开关:
-- ActiveBtn:活动：高V，广告，CDK;消息：公告，隐私政策
-- GiftBtn:礼包
-- FreeBtn:免费筹码
--ex：key = parent = "一级开关",state = 默认状态(true or false)｝
HallDefine.redDotSwitch = {
	["mail"] = {parent = "MailBtn", state = false, node = "Panel/TopBG/RightMgr/MailBtn/RedDot"},
	["friend"] = {parent = "FriendBtn", state = false, node = "Panel/DownBG/MoreBtn/MoreBG/FriendBtn/RedDot"}
	-- ["fund"] = {parent = "GiftBtn",state = false,node = "GiftPanel/DownBG/FundBtn/Fund/RedDot"},
	-- ["novice"] = {parent = "GiftBtn",state = false,node = "GiftPanel/DownBG/NoviceBtn/Novice/RedDot"},
	-- ["limmitAward"] = {parent = "FreeBtn",state = false,node = "FreePanel/DownBG/LimmitAwardBtn/RedDot"},
	-- ["SignBtn"] = {parent = "FreeBtn",state = false,node = "FreePanel/DownBG/SignBtn/RedDot"},
	-- ["onlineAward"] = {parent = "FreeBtn",state = false,node = nil},
	-- ["dailyGift"] = {parent = "ActiveBtn",state = false,node = nil},
}

--各小红点节点
HallDefine.redDotNode = {
	["MailBtn"] = "Panel/TopBG/RightMgr/MailBtn/RedDot",
	["FriendBtn"] = "Panel/DownBG/MoreBtn/MoreBG/FriendBtn/RedDot"
	-- ["GiftBtn"] = "Panel/DownBG/GiftBtn/RedDot",
	-- ["ActiveBtn"] = "Panel/DownBG/ActiveBtn/RedDot",
	-- ["FreeBtn"] = "Panel/DownBG/FreeBtn/RedDot",
}

--游戏列表icon
--prefab 有自己的预制体
--isHall 大厅功能，不需要下载
HallDefine.GameListIcon = {
	["yxrk_1001"] = {path = "img_yxrk_1001.png", prefab = false},
	["yxrk_1002"] = {path = "img_yxrk_1002.png", prefab = false},
	["yxrk_1003"] = {path = "img_yxrk_1003.png", prefab = false},
	["yxrk_1004"] = {path = "img_yxrk_1004.png", prefab = false},
	["yxrk_1005"] = {path = "img_yxrk_1005.png", prefab = false},
	["yxrk_1006"] = {path = "img_yxrk_1006.png", prefab = false},
	["yxrk_1007"] = {path = "img_yxrk_1007.png", prefab = false},
	["yxrk_1008"] = {path = "img_yxrk_1008.png", prefab = false},
	["yxrk_1009"] = {path = "img_yxrk_1009.png", prefab = false},
	["yxrk_1010"] = {path = "img_yxrk_1010.png", prefab = false},
	["yxrk_1011"] = {path = "img_yxrk_1011.png", prefab = false},
	["yxrk_1012"] = {path = "img_yxrk_1012.png", prefab = false},
	["yxrk_1015"] = {path = "img_yxrk_5007003.png", prefab = false},
	["yxrk_2001"] = {path = "img_yxrk_2001.png", prefab = true},
	["yxrk_2002"] = {path = "img_yxrk_2002.png", prefab = true},
	["yxrk_2003"] = {path = "img_yxrk_2003.png", prefab = false},
	["yxrk_2004"] = {path = "img_yxrk_2004.png", prefab = true, isHall = true},
	["yxrk_2005"] = {path = "img_yxrk_2005.png", prefab = true},
	["yxrk_2010"] = {path = "img_yxrk_2010.png", prefab = false},
	["yxrk_2011"] = {path = "img_yxrk_2011.png", prefab = false},
	["yxrk_3001"] = {path = "img_yxrk_3001.png", prefab = true},
	["yxrk_3002"] = {path = "img_yxrk_3002.png", prefab = false},
	["yxrk_3003"] = {path = "img_yxrk_3003.png", prefab = true},
	["yxrk_3004"] = {path = "img_yxrk_3004.png", prefab = false},
	["yxrk_3005"] = {path = "img_yxrk_3005.png", prefab = false},
	["yxrk_3007"] = {path = "img_yxrk_3007.png", prefab = true},
	["yxrk_3008"] = {path = "img_yxrk_3008.png", prefab = false},
	["yxrk_3009"] = {path = "img_yxrk_3009.png", prefab = false},
	["yxrk_3010"] = {path = "img_yxrk_3010.png", prefab = false},
	["yxrk_3012"] = {path = "img_yxrk_3012.png", prefab = false},
	["yxrk_4001"] = {path = "img_yxrk_4001.png", prefab = false, isHall = true},
	["yxrk_4002"] = {path = "img_yxrk_4002.png", prefab = false, isHall = true},
	["yxrk_5007"] = {path = "img_yxrk_5007.png", prefab = false, isHall = true},
	["yxrk_5008"] = {path = "img_yxrk_5008.png", prefab = false},
	["yxrk_7001"] = {path = "img_yxrk_7001.png", prefab = false},
	["yxrk_31002"] = {path = "img_yxrk_31002.png", prefab = false},
	["third_5007001"] = {path = "img_5007001.png", prefab = true},
	["third_5007002"] = {path = "img_5007002.png", prefab = true},
	["yxrk_5007003"] = {path = "img_yxrk_5007003.png", prefab = false},
	["third_5007004"] = {path = "img_5007004.png", prefab = true},
	["yxrk_5002001"] = {path = "img_yxrk_5002001.png", prefab = false},
	["yxrk_5002002"] = {path = "img_yxrk_5002002.png", prefab = false},
	["yxrk_5002003"] = {path = "img_yxrk_5002003.png", prefab = false},
	["yxrk_5002004"] = {path = "img_yxrk_5002004.png", prefab = false},
	["yxrk_5002005"] = {path = "img_yxrk_5002005.png", prefab = false},
	["yxrk_3011"] = {path = "img_yxrk_3011.png", prefab = false},
	["yxrk_1013"] = {path = "img_yxrk_1013.png", prefab = false},
	["yxrk_1014"] = {path = "img_yxrk_1014.png", prefab = false},
	["yxrk_1017"] = {path = "img_yxrk_1017.png", prefab = false},
	["yxrk_1018"] = {path = "img_yxrk_1018.png", prefab = false},
	["yxrk_1019"] = {path = "img_yxrk_1019.png", prefab = false},
	["yxrk_1020"] = {path = "img_yxrk_1020.png", prefab = false},
	["yxrk_3013"] = {path = "img_yxrk_3013.png", prefab = false},
	["yxrk_1026"] = {path = "img_yxrk_1026.png", prefab = false},
	["yxrk_1028"] = {path = "img_yxrk_1028.png", prefab = false},
	["yxrk_1024"] = {path = "img_yxrk_1024.png", prefab = false},
	["yxrk_1025"] = {path = "img_yxrk_1025.png", prefab = false},
	["yxrk_1021"] = {path = "img_yxrk_1021.png", prefab = false},
	["yxrk_1027"] = {path = "img_yxrk_1027.png", prefab = false},
	["yxrk_1033"] = {path = "img_yxrk_1033.png", prefab = false},
	["yxrk_1030"] = {path = "img_yxrk_1030.png", prefab = false},
}

HallDefine.SelectIcon = {
	["select_1001"] = {path = "img_select_1001.png"},
	["select_1002"] = {path = "img_select_1002.png"},
	["select_1003"] = {path = "img_select_1003.png"},
	["select_1004"] = {path = "img_select_1004.png"},
	["select_1005"] = {path = "img_select_1005.png"},
	["select_1006"] = {path = "img_select_1006.png"},
	["select_1007"] = {path = "img_select_1007.png"},
	["select_1009"] = {path = "img_select_1009.png"},
	["select_1010"] = {path = "img_select_1010.png"},
	["select_1011"] = {path = "img_select_1011.png"},
	["select_1012"] = {path = "img_select_1012.png"},
	["select_1015"] = {path = "img_select_1015.png"},
	["select_3001"] = {path = "img_select_3001.png"},
	["select_3004"] = {path = "img_select_3004.png"},
	["select_1013"] = {path = "img_select_1013.png"},
	["select_1014"] = {path = "img_select_1014.png"},
	["select_1017"] = {path = "img_select_1017.png"},
	["select_1018"] = {path = "img_select_1018.png"},
	["select_1019"] = {path = "img_select_1019.png"},
	["select_1020"] = {path = "img_select_1020.png"},
	["select_1026"] = {path = "img_select_1026.png"},
	["select_1028"] = {path = "img_select_1028.png"},
	["select_1024"] = {path = "img_select_1024.png"},
	["select_1025"] = {path = "img_select_1025.png"},
	["select_1021"] = {path = "img_select_1021.png"},
	["select_1027"] = {path = "img_select_1027.png"},
	["select_1033"] = {path = "img_select_1033.png"},
	["select_1030"] = {path = "img_select_1030.png"},
}

--[[
Prop(解锁道具)
View(解锁礼包)
Lock(实物锁)
]]
HallDefine.UnlockCondition = {
	[1008] = {Prop = "EPC_Lhdb_Unlock_9001", View = "PirateTreasureGiftView", Lock = true},
	[3007] = {Prop = "EPC_AirPlane_Unlock_9002", View = "AirplaneUnlockGiftView", Lock = false},
	[3009] = {Prop = "EPC_TD_Unlock_9003", View = "ZombieUnLockGiftView", Lock = false}
}

--[[
	月中排行榜
]]
HallDefine.MonthRank = {
	[1001] = {Open = true, Type = CC.shared_enums_pb.GST_NotCatch},
	[1002] = {Open = false, Type = CC.shared_enums_pb.GST_NotCatch},
	[1003] = {Open = true, Type = CC.shared_enums_pb.GST_NotCatch},
	[1004] = {Open = true, Type = CC.shared_enums_pb.GST_NotCatch},
	[1005] = {Open = true, Type = CC.shared_enums_pb.GST_NotCatch},
	[1006] = {Open = true, Type = CC.shared_enums_pb.GST_NotCatch},
	[1007] = {Open = true, Type = CC.shared_enums_pb.GST_NotCatch},
	[1008] = {Open = true, Type = CC.shared_enums_pb.GST_NotCatch},
	[1009] = {Open = true, Type = CC.shared_enums_pb.GST_NotCatch},
	[2001] = {Open = true, Type = CC.shared_enums_pb.GST_NotCatch},
	[2002] = {Open = true, Type = CC.shared_enums_pb.GST_NotCatch},
	[2003] = {Open = false, Type = CC.shared_enums_pb.GST_NotCatch},
	[2004] = {Open = false, Type = CC.shared_enums_pb.GST_NotCatch},
	[2005] = {Open = false, Type = CC.shared_enums_pb.GST_NotCatch},
	[3001] = {Open = true, Type = CC.shared_enums_pb.GST_NotCatch},
	[3002] = {Open = true, Type = CC.shared_enums_pb.GST_Catch},
	[3003] = {Open = true, Type = CC.shared_enums_pb.GST_Catch},
	[3004] = {Open = true, Type = CC.shared_enums_pb.GST_NotCatch},
	[3005] = {Open = true, Type = CC.shared_enums_pb.GST_Catch},
	[3007] = {Open = true, Type = CC.shared_enums_pb.GST_Catch},
	[3008] = {Open = true, Type = CC.shared_enums_pb.GST_Catch},
	[3009] = {Open = true, Type = CC.shared_enums_pb.GST_Catch},
	[3010] = {Open = true, Type = CC.shared_enums_pb.GST_Catch},
	[4001] = {Open = false, Type = CC.shared_enums_pb.GST_NotCatch},
	[4002] = {Open = false, Type = CC.shared_enums_pb.GST_NotCatch},
	[31002] = {Open = false, Type = CC.shared_enums_pb.GST_NotCatch}
}

--[[
	炮台排行榜
]]
HallDefine.BatteryRank = {
	[3002] = {Open = true, Type = CC.shared_enums_pb.GST_Catch},
	[3005] = {Open = true, Type = CC.shared_enums_pb.GST_Catch},
	[3007] = {Open = true, Type = CC.shared_enums_pb.GST_Catch}
}

--[[
	vip权益图标
]]
HallDefine.VIPNewRights = {
	[10001] = {Icon = "grzx_icon_01.png", openTip = true},
	[10002] = {Icon = "grzx_icon_04.png", openTip = false},
	[10003] = {Icon = "grzx_icon_07.png", openTip = false},
	[10004] = {Icon = "grzx_icon_02.png", openTip = false},
	[10005] = {Icon = "grzx_icon_05.png", openTip = false},
	[10006] = {Icon = "grzx_icon_03.png", openTip = false},
	[10007] = {Icon = "grzx_icon_06.png", openTip = false},
	[10008] = {Icon = "grzx_icon_08.png", openTip = true},
	[10009] = {Icon = "grzx_icon_11.png", openTip = true},
	[10010] = {Icon = "grzx_icon_09.png", openTip = true},
	[10011] = {Icon = "grzx_icon_12.png", openTip = true},
	[10012] = {Icon = "grzx_icon_15.png", openTip = true},
	[10013] = {Icon = "grzx_icon_10.png", openTip = true},
	[10014] = {Icon = "grzx_icon_13.png", openTip = true},
	[10015] = {Icon = "grzx_icon_16.png", openTip = false},
	[10016] = {Icon = "grzx_icon_17.png", openTip = true},
	[10017] = {Icon = "grzx_icon_18.png", openTip = true}
}

--累充宝箱充值额度配置（Mol，OPPO）
HallDefine.Recharge = {{10, 59, 279, 599, 1299, 2599, 5599, 10000}, {10, 59, 279, 599, 1299, 2599, 5599, 10000}}

--竖屏支持界面
HallDefine.PortraitSupport = {
	["PersonalInfoView"] = "PersonalInfoViewPortrait",
	["FundView"] = "FundViewPortrait",
	["BenefitsView"] = "BenefitsViewPortrait",
	["CashCowView"] = "CashCowViewPortrait",
	["SetUpSoundView"] = "SetUpSoundViewPortrait",
	["BrokeGiftView"] = "BrokeGiftView",
	["BrokeBigGiftView"] = "BrokeBigGiftView",
	["StoreView"] = "StoreViewPortrait",
	["GameExitTipView"] = "GameExitTipViewPortrait",
	["SelectGiftCollectionView"] = "SelectGiftCollectionViewPortrait",
	["NoviceGiftView"] = "NoviceGiftViewPortrait",
	["SetUpView"] = "SetUpView",
	["FreeChipsCollectionView"] = "FreeChipsCollectionViewPortrait",
	["DailyGiftCollectionView"] = "DailyGiftCollectionViewPortrait",
	["Tip"] = "TipPortrait",
	["ChatPanel"] = "ChatPanel",
}

return HallDefine