local CC = require("CC")
local ChatConfig = {}

--Tog类型
ChatConfig.TOGGLETYPE = {
	SYSTEM = 1,
	PUBLIC = 2,
	PRIVATE = 3
}

--聊天类型
ChatConfig.CHATTYPE = {
	Gold = CC.shared_enums_pb.CMT_Gold,
	HORN = CC.shared_enums_pb.CMT_LaBa,
	GAMESYSTEM = CC.shared_enums_pb.CMT_Game,
	ACTIVITY_NORMAL = CC.shared_enums_pb.CMT_Activity_Normal,
	ACTIVITY_TIMER = CC.shared_enums_pb.CMT_Activity_Timer,
	SYSTEM = CC.shared_enums_pb.CMT_Sys,
	IMMEDIATELY = CC.shared_enums_pb.CMT_Immediately_Marquee,
	PRIVATE = 8,
	REWARDS = 9,
}

--聊天显示限制数目
ChatConfig.CHATSETTING = {
	--喇叭VIP限制
	HORNVIPLIMIT = 1,
	--VIP限制
	VIPLIMIT = 3,
	--私聊筹码留底
	PRIVATELIMIT = 1000000,
	--Emoji长度限制
	EMOJIMAXLENGTH = 50,
	--聊天间隔30秒
	INTERVALTIME = 30,
	--喇叭时间间隔
	HORNINTERVALTIME = 300,
	--发送消息字符上线
	MSGMAXLENGTH = 720,
	--最多每种聊天显示50条
	CACHEMSGMAXLEN = 50
}

-- 聊天表情标识长度,例如[1] = 1
ChatConfig.CHAT_FACE_LENGHT = 1

return ChatConfig