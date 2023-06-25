local CC = {}

--说明：除了语言包需要动态加载外，其他大厅lua文件都放这里面声明
--并且用到的lua文件都从这里面取

--这个数组记录的就只是大厅用的类，子游戏不给用
---！！！Attentions！！！子游戏不允许访问CC里面的内容
function CC.Init()
	--[[
		说明:这四个文件最基础的文件在后面require的文件的函数体外需要用到，所需必须按顺序先定义！
		例如：
		local CC = require("CC")
		local SpeakerBord = CC.uu.ClassView("SpeakerBord")

		其中ClassView方法：
		function uu.ClassView( viewName, bundleName, super )
		    local CC = require("CC")
		    local c = CC.class2(viewName, super or CC.ViewBase)
		    c.viewName = viewName
		    c.bundleName = bundleName or "prefab"
		    return c
		end
		否则在调用uu，clsaa2，ViewBase会得到空值.

		PS:除了这4个文件，其他lua文件禁止在函数体外定义CC.xxx,否则可能赋予空值
	]]
	--string扩展方法
	require("Common/string")
	--table扩展方法
	require("Common/table")
	--导入lua内置bit库
	require("bit")

	--下面文件是子游戏可以访问的
	CC.class = require("Common/class")
	CC.class2 = require("Common/class2")
	CC.uu = require("Common/uu")
	CC.ViewBase = require("Common/ViewBase")
	CC.HallViewBase = require("Common/HallViewBase")

	CC.SetFileRequire()

	CC.Action = require("Common/Action")
	CC.Queue = require("Common/Queue")
	CC.List = require("Common/List")
	CC.Platform = require("Common/Platform")
	CC.Sound = require("Common/Sound")
	CC.UserData = require("Common/UserData")
	CC.NotificationCenter = require("Common/NotificationCenter")
	CC.HallNotificationCenter = require("Model/Common/HallNotificationCenter")
	CC.HallUtil = require("Model/HallUtil")
	CC.HttpMgr = require("Model/Manager/HttpManager")
	CC.TimeMgr = require("Model/Manager/TimeManager")
	-- CC.ViewManager = require("Model/Manager/ViewManager")
	-- CC.HeadManager = require("Model/Manager/HeadManager")
	-- CC.PaymentManager = require("Model/Manager/PaymentManager")
	-- CC.ReliefManager = require("Model/Manager/ReliefManager")
	-- CC.FreeChipsManager = require("Model/Manager/FreeChipsManager")
	-- CC.OnlineManager = require("Model/Manager/OnlineManager")
	-- CC.ElephantManager = require("Model/Manager/ElephantManager")
	-- CC.FlyCoinManager = require("Model/Manager/FlyCoinManager")
	-- CC.RankIconManager = require("Model/Manager/RankIconManager")
	-- CC.SelectGiftManager = require("Model/Manager/SelectGiftManager")
	-- CC.ReportManager = require("Model/Manager/ReportManager")
	-- CC.CashCowIconManager = require("Model/Manager/CashCowIconManager")
	-- CC.IconManager = require("Model/Manager/IconManager")
	-- --slot游戏管理器
	-- CC.SlotMatchManager = require("Model/Manager/SlotMatchManager")
	-- CC.SlotCommonNoticeManager = require("Model/Manager/SlotCommonNoticeManager")

	CC.DefineCenter = require("Model/Define/DefineCenter")
	CC.Player = require("Model/Manager/Player")
	CC.NetworkHelper = require("Model/Network/NetworkHelper")
	CC.Request = require("Model/Network/Request")
	CC.WebUrlManager = require("Model/Manager/WebUrlManager")
	CC.OnPush = require("Model/Network/OnPush")
	CC.ConfigCenter = require("Model/Config/ConfigCenter")
	CC.Notifications = require("Model/Common/Notifications")
	CC.LanguageManager = require("Model/Manager/LanguageManager")
	CC.OverlappingManager = require("Model/Manager/OverlappingManager")

	CC.SubGameUiView = require("SubGame/SubGameUiView")
	CC.SubGameInterface = require("SubGame/SubGameInterface")
	CC.CardTool = require("SubGame/CardTool")
	CC.NetworkState = require("SubGame/NetworkState")
	CC.NetworkInterface = require("SubGame/NetworkFramework/NetworkInterface")
	CC.NetworkTools = require("SubGame/NetworkFramework/NetworkTools")

	CC.proto = require("Model/Network/proto")
	CC.shared_message_pb = require("Model/Network/protos/shared_message_pb")
	CC.client_pb = require("Model/Network/protos/client_client_pb")
	CC.shared_operation_pb = require("Model/Network/protos/shared_ops_pb")
	CC.shared_common_pb = require("Model/Network/protos/shared_common_pb")
	CC.shared_en_pb = require("Model/Network/protos/shared_en_pb")
	CC.shared_enums_pb = require("Model/Network/protos/shared_enums_pb")
	CC.shared_transfer_source_pb = require("Model/Network/protos/shared_transfer_source_pb")
	CC.client_supply_pb = require("Model/Network/protos/client_supply_pb")
	CC.client_treasure_pb = require("Model/Network/protos/client_treasure_pb")
	CC.client_msign_pb = require("Model/Network/protos/client_msign_pb")
	CC.slotMatch_message_pb = require "Model/SlotMatchNetwork/slotMatch_message_pb"
	CC.client_gift_pb = require("Model/Network/protos/client_gift_pb")
	CC.server_log_pb = require("Model/Network/protos/server_log_pb")
	CC.client_agent_pb = require("Model/Network/protos/client_agent_pb")
	CC.DataMgrCenter = require("Model/Data/DataMgrCenter")

	CC.BaiduMapWeb = require("Model/BaiduMapWeb")

	CC.DebugDefine = require("Model/Define/DebugDefine")

	CC.MOLTHPlugin = require("Model/Plugin/MOLTHPlugin")
	CC.TiKiPayPlugin = require("Model/Plugin/TiKiPayPlugin")
	CC.GuPayPlugin = require("Model/Plugin/GuPayPlugin")

	CC.ChatConfig = require("Model/Config/ChatConfig")
	CC.CurrencyDefine = require("Model/Define/CurrencyDefine")

	CC.HallTool = require("Tool/HallTool")

	CC.ResCommitTime = require("Model/ResCommitTime")

	CC.GC = require("GC")

	CC.InitHallClasses()
end

function CC.SetFileRequire()
	local safeRequire = function(path)
		return require(path)
	end
	local mt = {
		__index = function(t, k)
			if not rawget(t, k) then
				local ret, file
				if string.find(k, "Manager") then
					ret, file = pcall(safeRequire, "Model/Manager/" .. k)
				else
					return
				end
				t[k] = file
			end
			return t[k]
		end
	}
	setmetatable(CC, mt)
end

function CC.InitHallClasses()
	--下面文件仅仅在大厅访问，子游戏不允许访问
	CC.HallCenter = require("Model/HallCenter")

	CC.LocalGameData = require("Model/Manager/LocalGameData")
	CC.TaskManager = require("Model/Manager/TaskManager")
	CC.ChatManager = require("Model/Manager/ChatManager")
	CC.MessageManager = require("Model/Manager/MessageManager")

	CC.ChannelMgr = require("Model/Manager/ChannelSwitchManager")
	CC.ApkDownloader = require("Model/ResDownload/ApkDownloader")
	CC.ResDownloader = require("Model/ResDownload/ResDownloader")
	CC.ResDownloadManager = require("Model/ResDownload/ResDownloadManager")
	CC.TestTool = require("Model/Manager/TestTool")

	CC.Network = require("Model/Network/Network")
	CC.ReconnectManager = require("Model/Network/ReconnectManager")
	CC.Push = require("Model/Network/Push")

	CC.AFInAppEvents = require("Model/Plugin/AFInAppEvents")
	CC.AppsFlyerPlugin = require("Model/Plugin/AppsFlyerPlugin")
	CC.FacebookPlugin = require("Model/Plugin/FacebookPlugin")
	CC.GooglePlayIABPlugin = require("Model/Plugin/GooglePlayIABPlugin")
	CC.ApplePayPlugin = require("Model/Plugin/ApplePayPlugin")
	CC.LinePlugin = require("Model/Plugin/LinePlugin")
	CC.OppoPlugin = require("Model/Plugin/OppoPlugin")
	CC.GoogleAdsPlugin = require("Model/Plugin/GoogleAdsPlugin")
	CC.VivoPlugin = require("Model/Plugin/VivoPlugin")
	CC.FirebasePlugin = require("Model/Plugin/FirebasePlugin")
	CC.GooglePlayReviewPlugin = require("Model/Plugin/GooglePlayReviewPlugin")
	CC.NativeSharePlugin = require("Model/Plugin/NativeSharePlugin")

	CC.ViewCenter = require("View/ViewCenter")
	CC.ViewDefine = require("Model/Define/ViewDefine")

	CC.shared_enums_pb = require("Model/Network/protos/shared_enums_pb")

	CC.UrlConfig = require("Model/Config/UrlConfig")
end

return CC
