--所有配置放这里
local Config = {}
local M = {}
M.__index = M
M.__newindex = function(tb, key, value)
	error("MNLHD_Config only read...\n" .. debug.traceback())
end
setmetatable(Config, M)

local proto = require("View/MiniLHDView/MiniLHDNetwork/game_pb")
local CC = require("CC")

M.GameId = 31003
M.GameName = "MNLHD"
M.GameLanguage = CC.LanguageManager.GetType()

M.BET_DATA = {
	[1] = 1000, --1K
	[2] = 10000, --10K
	[3] = 100000, --100K
	[4] = 200000, --200K
	[5] = 500000, --500K
	[6] = 1000000 --1M
}

M.ERROR_STRING = {
	Chinese = {
		[proto.ErrSuccess] = "成功",
		[proto.ErrDecode] = "解码错误",
		[proto.ErrEncode] = "编码错误",
		[proto.ErrVerifyTokeFailed] = "认证失败",
		[proto.ErrLoadPlayerDataFailed] = "拉取用户数据失败",
		[proto.ErrLoadPlayerPropsFailed] = "拉取用户数据失败",
		[proto.ErrParams] = "参数错误",
		[proto.ErrStateNotMatch] = "状态不匹配",
		[proto.ErrPlayerBetNotExist] = "玩家赌注不存在",
		[proto.ErrModProps] = "筹码操作失败",
		[proto.ErrCoinNotEnough] = "下注筹码不足"
	},
	Thai = {
		[proto.ErrSuccess] = "สำเร็จ",
		[proto.ErrDecode] = "ถอดรหัสผิดพลาด",
		[proto.ErrEncode] = "หมายเลขผิดพลาด",
		[proto.ErrVerifyTokeFailed] = "ตรวจสอบล้มเหลว",
		[proto.ErrLoadPlayerDataFailed] = "ดึงข้อมูลบัญชีล้มเหลว",
		[proto.ErrLoadPlayerPropsFailed] = "ดึงข้อมูลบัญชีล้มเหลว",
		[proto.ErrParams] = "พารามิเตอร์ผิดพลาด",
		[proto.ErrStateNotMatch] = "สถานะไม่ตรงกัน",
		[proto.ErrPlayerBetNotExist] = "ผู้เล่นไม่มีการลงเดิมพัน",
		[proto.ErrModProps] = "ลงชิปล้มเหลว",
		[proto.ErrCoinNotEnough] = "ชิปเดิมพันไม่พอ"
	}
}

M.LOCAL_ERR_STR = {
	Chinese = {
		["lessThen1K"] = "下注筹码小于1K",
		["sametimeError"] = "不能同时下注龙和虎"
	},
	Thai = {
		["lessThen1K"] = "การเดิมพันน้อยกว่า 1K",
		["sametimeError"] = "ไม่สามารถลงเดิมพันมังกรและเสือพร้อมกัน"
	}
}

-- // 游戏状态，正在下注或者结算
-- enum GameState {
--     Invalid = 0;        // 无效状态
--     Betting = 1;        // 等待下注
--     HandleResult = 2;   // 正在处理结果
-- }

M.GAME_STATE = {
	["StartBetting"] = proto.Betting,
	["HandleResult"] = proto.HandleResult,
	["DealCards"] = 3,
	["Betting"] = 4,
	["ShowCards"] = 5,
	["SendAwards"] = 6,
	["Ready"] = 7
}

M.LOCAL_TEXT_STR = {
	Chinese = {
		["roundID"] = "场次:",
		["state_1"] = "开始下注",
		["state_2"] = "停止下注",
		["state_3"] = "发牌中",
		["state_4"] = "下注中",
		["state_5"] = "开牌中",
		["state_6"] = "派奖中",
		["state_7"] = "准备中"
	},
	Thai = {
		["roundID"] = "เกมที่:",
		["state_1"] = "เริ่มลงเดิมพัน",
		["state_2"] = "สิ้นสุดลงเดิมพัน",
		["state_3"] = "กำลังแจกไพ่",
		["state_4"] = "กำลังลงเดิมพัน",
		["state_5"] = "กำลังเปิดไพ่",
		["state_6"] = "กำลังแจกรางวัล",
		["state_7"] = "กำลังเตรียมพร้อม"
	}
}

M.LOCAL_TIPS_STR = {
	Chinese = {
		["vipBetLimit"] = "当前VIP下注限制为 ",
		["pleaseBuyVip"] = "您好，需要VIP1才能下注，VIP等级越高，单局下注越多"
	},
	Thai = {
		["vipBetLimit"] = "สวัสดีค่ะ ระดับVIPปัจจุบันลงเดิมพันจำกัดคือ",
		["pleaseBuyVip"] = "สวัสดีค่ะ ต้องเป็นVIP1ถึงลงเดิมพันได้ ระดับVIPยิ่งสูง ลงเดิมพันได้ยิ่งมาก"
	}
}

M.LOCAL_CHAT = {
	Chinese = {
		["MessageLimit"] = "消息不符合长度限制",
		["EmptyMessage"] = "不可发送空消息",
	},
	Thai = {
		["MessageLimit"] = "ความยาวของข้อความไม่ถูกต้อง",
		["EmptyMessage"] = "ไม่สามารถส่งข้อความได้",
	}
}

return Config
