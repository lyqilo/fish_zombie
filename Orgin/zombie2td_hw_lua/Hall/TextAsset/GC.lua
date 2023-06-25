--[[子游戏用到的大厅类或者全局对象，从这里面取]]
local CC = require("CC")
local GC = {}

-- local CC2GC_MAP = {
-- 	--[[
-- 		lua文件定义
-- 	]]
-- 	class = CC.class,
-- 	class2 = CC.class2,
-- 	uu = CC.uu,
-- 	ViewBase = CC.ViewBase,

-- 	Action = CC.Action,
-- 	Platform = CC.Platform,
-- 	Sound = CC.Sound,
-- 	UserData = CC.UserData,
-- 	NotificationCenter = CC.NotificationCenter,
-- 	HallNotificationCenter = CC.HallNotificationCenter,

-- 	ViewManager = CC.ViewManager,
-- 	DefineCenter = CC.DefineCenter,
-- 	Player = CC.Player,
-- 	NetworkHelper = CC.NetworkHelper,
-- 	Request = CC.Request,
-- 	WebUrlManager = CC.WebUrlManager,
-- 	OnPush = CC.OnPush,
-- 	ConfigCenter = CC.ConfigCenter,
-- 	Notifications = CC.Notifications,
-- 	LanguageManager = CC.LanguageManager,
-- 	ChannelMgr = CC.ChannelMgr,
-- 	SlotMatchManager = CC.SlotMatchManager,
-- 	SlotCommonNoticeManager = CC.SlotCommonNoticeManager,

-- 	SubGameUiView = CC.SubGameUiView,
--     SubGameInterface = CC.SubGameInterface,
-- 	CardTool = CC.CardTool,
-- 	NetworkState = CC.NetworkState,
-- NetworkInterface = CC.NetworkInterface,
-- NetworkTools = CC.NetworkTools,

-- 	proto = CC.proto,
-- 	shared_message_pb = CC.shared_message_pb,
-- 	client_pb = CC.client_pb,
-- 	shared_operation_pb = CC.shared_operation_pb,
-- 	shared_common_pb = CC.shared_common_pb,
-- 	shared_en_pb = CC.shared_en_pb,
-- 	shared_enums_pb = CC.shared_enums_pb,
-- 	slotMatch_message_pb = CC.slotMatch_message_pb,

-- 	DataMgrCenter = CC.DataMgrCenter,
-- 	BaiduMapWeb = CC.BaiduMapWeb,
--     DebugDefine = CC.DebugDefine,
-- 	MOLTHPlugin = CC.MOLTHPlugin,
-- 	ChatConfig = CC.ChatConfig,
-- }

local CC2GC_MAP = {
	"class",
	"class2",
	"uu",
	"ViewBase",
	"Action",
	"Platform",
	"Sound",
	"UserData",
	"NotificationCenter",
	"HallNotificationCenter",
	"ViewManager",
	"DefineCenter",
	"Player",
	"NetworkHelper",
	"Request",
	"WebUrlManager",
	"OnPush",
	"ConfigCenter",
	"Notifications",
	"LanguageManager",
	"ChannelMgr",
	"SlotMatchManager",
	"SlotCommonNoticeManager",
	"SubGameInterface",
	"SubGameUiView",
	"CardTool",
	"NetworkState",
	"NetworkInterface",
	"NetworkTools",
	"proto",
	"shared_message_pb",
	"client_pb",
	"shared_operation_pb",
	"shared_common_pb",
	"shared_en_pb",
	"shared_enums_pb",
	"slotMatch_message_pb",
	"DataMgrCenter",
	"BaiduMapWeb",
	"DebugDefine",
	"MOLTHPlugin",
	"ChatConfig",
	"shared_transfer_source_pb",
	"HttpMgr",
	"TimeMgr",
	"ViewDefine"
}
function GC.Init()
	local GCMAP = {}
	for _, GCKey in pairs(CC2GC_MAP) do
		GCMAP[GCKey] = CC[GCKey]
	end

	for GCkey, CCfile in pairs(GCMAP) do
		if CCfile and type(CCfile) == "table" and not getmetatable(CCfile) then
			local t = {}
			CCfile.__index = CCfile
			CCfile.__newindex = function()
				logError("不允许直接修改大厅任何表内数据！！！")
			end
			setmetatable(t, CCfile)
			GC[GCkey] = t
		else
			GC[GCkey] = CCfile
		end
	end
end

return GC
