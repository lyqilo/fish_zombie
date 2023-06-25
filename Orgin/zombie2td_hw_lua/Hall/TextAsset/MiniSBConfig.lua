--所有配置放这里
local Config = {}
local M = {}
M.__index = M
M.__newindex = function(tb, key, value)
	error("MNSB_Config only read...\n" .. debug.traceback())
end
setmetatable(Config, M)

local proto = require("View/MiniSBView/MiniSBNetwork/game_pb")
local CC = require("CC")

M.GameName = "MNSB"
M.GameLanguage = CC.LanguageManager.GetType()
M.GameId = 31001

M.LONG_FENG_RESULT = {
	["Invalid"] = 0,
	["Long"] = 1,
	["Feng"] = 2,
	["Both"] = 3
}

M.BET_DATA = {
	[1] = 1000, --1K
	[2] = 5000, --5K
	[3] = 10000, --10K
	[4] = 50000, --50K
	[5] = 100000, --100K
	[6] = 500000, --500K
	[7] = 1000000, --1M
	[8] = 5000000 --5M
}

M.BET_DATA_Str = {
	[1] = "1K",
	[2] = "5K",
	[3] = "10K",
	[4] = "50K",
	[5] = "100K",
	[6] = "500K",
	[7] = "1M",
	[8] = "5M"
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
		[proto.ErrCoinNotEnough] = "下注筹码不足",
		[proto.ErrVip0Limit] = "非VIP下注不能超过5K"
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
		[proto.ErrCoinNotEnough] = "ชิปเดิมพันไม่พอ",
		[proto.ErrVip0Limit] = "ไม่สามารถลงเดิมพันเกินได้"
	}
}

M.LOCAL_TIPS_STR = {
	Chinese = {
		["lessThen1K"] = "下注筹码小于1K",
		["returnText"] = "返还剩余金额 ",
		["vipBetLimit"] = "当前VIP下注限制为 ",
		["pleaseBuyVip"] = "您好，需要VIP1才能下注，VIP等级越高，单局下注越多",
		["betAreasLimit"] = "不能同时下注大和小"
	},
	Thai = {
		["lessThen1K"] = "ลงเดิมพันชิปต่ำกว่า1K",
		["returnText"] = "ยอดการคืนคงเหลือ",
		["vipBetLimit"] = "สวัสดีค่ะ ระดับVIPปัจจุบันลงเดิมพันจำกัดคือ",
		["pleaseBuyVip"] = "สวัสดีค่ะ ต้องเป็นVIP1ถึงลงเดิมพันได้ ระดับVIPยิ่งสูง ลงเดิมพันได้ยิ่งมาก",
		["betAreasLimit"] = "ไม่สามารถลงสูงและต่ำพร้อมกันได้"
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
