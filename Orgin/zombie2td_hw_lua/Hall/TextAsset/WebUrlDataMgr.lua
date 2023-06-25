local CC = require("CC")

local WebData = {}

local WebUrlDataMgr = {}

local agentKey = "E8FE168AD73Fqp*s$yGAME"

local webKey = "50E851DE-357F-4268-9FC6-B18755C5898D"

-- 原始URL,第一个访问的地址
local orgUrlPrefix = nil

-- 基础URL,访问到地址后,取到的nginx地址(指向Web资源服和游戏管理服)
local urlPrefix = ""

--入口相对路径: /pre 为灰度
local entryPath = ""

-- 是否正在使用备用链路
local bIsUseBackup = false

function WebUrlDataMgr.GetWebKey()
	return webKey
end

function WebUrlDataMgr.SetEntryPath(path)
	if CC.DebugDefine.GetDebugMode() and not CC.DebugDefine.CheckReleaseServer() then
		return
	end

	if string.find(path, "\n") then
		entryPath = string.gsub(path, "\n", "")
	else
		entryPath = path
	end
end

function WebUrlDataMgr.GetEntryPath()
	if CC.DebugDefine.GetDebugMode() and CC.DebugDefine.CheckPreServer() then
		return "/pre"
	end
	return entryPath
end

function WebUrlDataMgr.GetOrgUrlPrefix()
	return orgUrlPrefix
end

function WebUrlDataMgr.SetOrgUrlPrefix(url)
	orgUrlPrefix = url
end

function WebUrlDataMgr.SetIsUseBackup(state)
	bIsUseBackup = state
end

function WebUrlDataMgr.GetIsUseBackup()
	return bIsUseBackup
end

function WebUrlDataMgr.SetUrlPrefix(webUrl, protocol)
	--单独加个protocol兼容老代码以支持可配置http或者https协议
	protocol = protocol or "http"
	urlPrefix = string.format("%s://%s%s", protocol, string.match(webUrl, "://(.-)/"), WebUrlDataMgr.GetEntryPath())
	log("urlPrefix = " .. urlPrefix)
end

-- 对子游戏暴露nginx转发的接口
function WebUrlDataMgr.GetUrlPrefix()
	if CC.DebugDefine.GetPrefixAddress() then
		return CC.DebugDefine.GetPrefixAddress()
	end
	return urlPrefix
end

-- 对子游戏暴露nginx转发的接口
function WebUrlDataMgr.GetNginxPrefix()
	if CC.DebugDefine.GetPrefixAddress() then
		return CC.DebugDefine.GetPrefixAddress()
	end
	return urlPrefix
end

function WebUrlDataMgr.GetDev()
	return "http://172.13.0.53:1999"
end

function WebUrlDataMgr.GetWebUrlPrefix()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/web/", url)
end

function WebUrlDataMgr.GetWebConfigUrlPrefix()
	local url = urlPrefix
	if not CC.ChannelMgr.GetTrailStatus() then
		if not bIsUseBackup then
			if CC.DebugDefine.GetWebConfigPrefixByEnv() then
				url = CC.DebugDefine.GetWebConfigPrefixByEnv()
			end
		end
	end
	return string.format("%s/web2/%s/", url, AppInfo.Country)
end

function WebUrlDataMgr.GetAgentUrlPrefix()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	local switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")
	if switchDataMgr.GetSwitchStateByKey("AgentUnlock") then
		return string.format("%s/agent/v1/", url)
	end
	return string.format("%s/agent/", url)
end

function WebUrlDataMgr.GetPromotionsUrlPrefix()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/promotions/", url)
end

function WebUrlDataMgr.GetsupplyUrlPrefix()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/supply?", url)
end

function WebUrlDataMgr.GetMSignUrlPrefix()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/promotions/msign?", url)
end

function WebUrlDataMgr.GetEntryUrl()
	local entryUrl = WebUrlDataMgr.GetOrgUrlPrefix()
	local deviceId = CC.Platform.GetDeviceId()

	if CC.DebugDefine.GetDebugMode() then
		if not WebUrlDataMgr.GetIsUseBackup() then
			entryUrl = CC.DebugDefine.GetEntryUrlPrefixByEnv()
		end
		deviceId = CC.DebugDefine.GetAccount() or deviceId
	end
	return string.format("%s/entry?imei=%s", entryUrl, deviceId)
end

-- 获取大厅活动URL
function WebUrlDataMgr.GetActivityUrl()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/hall/activity/?", url)
end

-- 获取
function WebUrlDataMgr.GetCompositeUrl()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/compose?", url)
end

-- 每日抽奖特有请求地址
function WebUrlDataMgr.GetLotteryUrl()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/dailylottery/lottery?", url)
end

-- 新手任务
function WebUrlDataMgr.GetTaskUrl()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/task?", url)
end

-- 高V
function WebUrlDataMgr.GetAgentUrl()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/agent/v1/?", url)
end

function WebUrlDataMgr.GetUserWelfareUrl()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/userwelfare?", url)
end

-- 实物商城
function WebUrlDataMgr.GetRealShopUrl()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/realshop?", url)
end

-- 新游预约
function WebUrlDataMgr.GetOnlineLimitUrl()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/onlineLimit?", url)
end

--每日礼包签到
function WebUrlDataMgr.GetGiftSignUrl1()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/gift/gifts?", url)
end

function WebUrlDataMgr.GetGiftSignUrl2()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/gift/lottery?", url)
end

function WebUrlDataMgr.GetGiftSignUrl3()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/gift/prizes?", url)
end

--入口json配置文件下载地址
function WebUrlDataMgr.GetFileUrl()
	if CC.DebugDefine.GetDebugMode() and not CC.DebugDefine.CheckReleaseServer() then
		return string.format("%s/res/HW_PLATFORM_II/config/", CC.DebugDefine.GetUrlPrefixByEnv())
	end
	return string.format("%s%s/res/HW_PLATFORM_II/config/", orgUrlPrefix, WebUrlDataMgr.GetEntryPath())
end

--root场景loading图下载地址
function WebUrlDataMgr.GetLoadingImgUrl()
	if CC.DebugDefine.GetDebugMode() and not CC.DebugDefine.CheckReleaseServer() then
		return string.format("%s/res/HW_PLATFORM_II/common/loading.jpg", CC.DebugDefine.GetUrlPrefixByEnv())
	end
	return string.format("%s%s/res/HW_PLATFORM_II/common/loading.jpg", orgUrlPrefix, WebUrlDataMgr.GetEntryPath())
end

function WebUrlDataMgr.GetTimeAndSign()
	local ts = os.time()
	local sign = Util.Md5(ts .. webKey)
	return ts, sign
end

function WebUrlDataMgr.InitHallAddress(data)
	CC.uu.Log(data, "InitHallAddress data = ")
	-- tcp
	WebData.ServerAddress = data.Hall
	-- https with hall
	WebData.AuthAddress = WebUrlDataMgr.FormatAuthAddress(data.Auth)
	-- https address
	WebData.HttpAddress = data.Http or string.gsub(data.Auth, "com/hall", "com")

	CC.uu.Log(WebData, "InitHallAddress WebData = ")
end

function WebUrlDataMgr.GetServerAddress()
	if CC.DebugDefine.GetHallAddress() then
		return CC.DebugDefine.GetHallAddress()
	else
		return WebData.ServerAddress
	end
end

function WebUrlDataMgr.GetHallHttpAddress()
	if CC.DebugDefine.GetHallHttpAddress() then
		return CC.DebugDefine.GetHallHttpAddress()
	else
		return WebData.HttpAddress
	end
end

function WebUrlDataMgr.GetHallHttpAddressWithOps()
	if CC.DebugDefine.GetHallHttpAddress() then
		return CC.DebugDefine.GetHallHttpAddress() .. "/hall/?ops=%s&playerid=%s&token=%s"
	else
		return WebData.HttpAddress .. "/hall/?ops=%s&playerid=%s&token=%s"
	end
end

--authAddress需要考虑灰度/pre路径
function WebUrlDataMgr.FormatAuthAddress(address)
	local isHttps = string.find(address, "https")
	local str = isHttps and "https" or "http"
	return str ..
		"://" ..
			string.gsub(
				address,
				str .. "://(.-)/",
				string.match(address, str .. "://(.-)/") .. WebUrlDataMgr.GetEntryPath() .. "/"
			)
end

function WebUrlDataMgr.GetServerIP()
	local address = CC.DebugDefine.GetHallAddress() or WebData.ServerAddress
	--先截掉"http://"
	local pos = string.find(address, "//")
	if pos then
		address = string.sub(address, pos + string.len("//"))
	end
	--再截掉端口号
	local pos = string.find(address, ":")
	if pos then
		address = string.sub(address, 1, pos - string.len(":"))
	end
	return address
end

function WebUrlDataMgr.GetLotAddress()
	if CC.DebugDefine.GetExtraAddress() then
		return CC.DebugDefine.GetExtraAddress()
	else
		return false
	end
end

--游戏serverIP配置地址
function WebUrlDataMgr.GetGameIPUrl()
	local fileName = "GameServerFilter"
	if CC.DebugDefine.GetEnvState() == CC.DebugDefine.EnvState.StableDev then
		fileName = "StableGameServerFilter"
	end
	return string.format("%s/web2/%s/API/%s.aspx", urlPrefix, AppInfo.Country, fileName)
end

--广告页配置地址
function WebUrlDataMgr.GetADUrl()
	return string.format("%sAPI/%s/MessageList.aspx", WebUrlDataMgr.GetWebConfigUrlPrefix(), AppInfo.ChannelID)
end

--游戏列表配置地址
function WebUrlDataMgr.GetGameInfoUrl()
	return string.format("%sAPI/GroupList.aspx", WebUrlDataMgr.GetWebConfigUrlPrefix())
end

--第三方游戏列表配置地址
function WebUrlDataMgr.GetThirdGameInfoUrl()
	return string.format("%sAPI/ThirdPartyConfig.aspx", WebUrlDataMgr.GetWebConfigUrlPrefix())
end

-- 游戏版本及组信息
function WebUrlDataMgr.GetGroupConfigUrl(gameProName)
	return string.format(
		"%sAPI/Game/%s/GroupConfig.aspx?timestamp=%s",
		WebUrlDataMgr.GetWebConfigUrlPrefix(),
		gameProName,
		Util.GetTimeStamp(false)
	)
end

--游戏配置地址
function WebUrlDataMgr.GetUpdateUrl()
	return string.format(
		"%sAPI/%s/VersionConfig.aspx?timestamp=%s",
		WebUrlDataMgr.GetWebConfigUrlPrefix(),
		AppInfo.ChannelID,
		Util.GetTimeStamp(false)
	)
end

--竞技场配置地址
function WebUrlDataMgr.GetArenaInfoUrl()
	return string.format("%sAPI/ArenaConfig.aspx", WebUrlDataMgr.GetWebConfigUrlPrefix())
end

--比赛场配置地址
function WebUrlDataMgr.GetMatchInfoUrl()
	return string.format("%sAPI/MatchConfig.aspx", WebUrlDataMgr.GetWebConfigUrlPrefix())
end

--功能配置开关地址
function WebUrlDataMgr.GetSwitchInfoUrl()
	return string.format("%sAPI/%s/Switch.aspx", WebUrlDataMgr.GetWebConfigUrlPrefix(), AppInfo.ChannelID)
end

--商店配置地址
function WebUrlDataMgr.GetStoreInfoUrl()
	return string.format("%sAPI/%s/GameChargeConfig.aspx", WebUrlDataMgr.GetWebConfigUrlPrefix(), AppInfo.ChannelID)
end

--获取公告配置地址
function WebUrlDataMgr.GetNoticeUrl()
	return string.format("%sAPI/%s/AiffcheConfig.aspx", WebUrlDataMgr.GetWebConfigUrlPrefix(), AppInfo.ChannelID)
end

--亲友房配置地址
function WebUrlDataMgr.GetRoomfeeInfoUrl()
	return string.format("%sAPI/Roomfee.aspx", WebUrlDataMgr.GetWebConfigUrlPrefix())
end

--客服反馈地址
function WebUrlDataMgr.GetFeedBackUrl()
	return string.format("%sAPI/ReceiveFeedBackInfo.aspx", WebUrlDataMgr.GetWebUrlPrefix())
end

--限时活动开关
function WebUrlDataMgr.GetActiveSwitchUrl()
	local os = CC.Platform.GetOSEnum()
	return string.format("%sswitch/status?os=%s", WebUrlDataMgr.GetPromotionsUrlPrefix(), os)
end

--消费榜
function WebUrlDataMgr.GetActiveRankUrl()
	local playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	local ts, sign = WebUrlDataMgr.GetTimeAndSign()
	local length = 50
	return string.format(
		"%stotal_bet?playerid=%s&length=%s&_ts=%s",
		WebUrlDataMgr.GetPromotionsUrlPrefix(),
		playerId,
		50,
		ts
	)
end

--高V查询
function WebUrlDataMgr.GetAgentInfoUrl()
	local gameId = 1
	local playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	local dataType = "AgentInfo"
	local sign = Util.Md5(dataType .. agentKey .. gameId .. playerId)
	return string.format(
		"%sPromoter/Api?DataType=AgentInfo&GameID=%s&UserID=%s&Sign=%s",
		WebUrlDataMgr.GetAgentUrlPrefix(),
		gameId,
		playerId,
		sign
	)
end

--高V绑定
function WebUrlDataMgr.GetAgentBindUrl(agentCode)
	local gameId = 1
	local playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	local nickName = CC.uu.urlEncode(CC.Player.Inst():GetSelfInfoByKey("Nick"))
	local dataType = "BindAgent"
	local sign = Util.Md5(dataType .. agentKey .. gameId .. agentCode .. playerId)
	return string.format(
		"%sPromoter/Api?DataType=BindAgent&GameID=%s&UserID=%s&Sign=%s&AgentCode=%s&NickName=%s",
		WebUrlDataMgr.GetAgentUrlPrefix(),
		gameId,
		playerId,
		sign,
		agentCode,
		nickName
	)
end

--CDKey兑换
function WebUrlDataMgr.GetCDKeyUrl()
	local playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	return string.format(
		"%sCdkeyPage/index.html?userID=%s&VIPLevel=%s",
		WebUrlDataMgr.GetWebUrlPrefix(),
		playerId,
		vipLevel
	)
end

--获取泼水节信息
function WebUrlDataMgr.GetSplashingUrl()
	local playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	return string.format("%ssplashwater/info?playerid=%s", WebUrlDataMgr.GetPromotionsUrlPrefix(), playerId)
end

-- 泼水
function WebUrlDataMgr.GetsplashwaterUrl(times, friendid)
	local playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	return string.format(
		"%ssplashwater/splash?playerid=%s&times=%s&friendid=%s",
		WebUrlDataMgr.GetPromotionsUrlPrefix(),
		playerId,
		times,
		friendid
	)
end

--获取排行榜
function WebUrlDataMgr.GetsplashrankUrl(len)
	local playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	return string.format("%ssplashwater/rank?playerid=%s&length=%s", WebUrlDataMgr.GetPromotionsUrlPrefix(), playerId, len)
end

--询问是否中暗补
function WebUrlDataMgr.GetsupplyUrl()
	local playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	return string.format("%sops=%s&playerid=%s", WebUrlDataMgr.GetsupplyUrlPrefix(), 1, playerId)
end

--http://172.13.0.53:1998/supply?ops=1&playerid=1032768
--http://127.0.0.1:4445/splashwater/info?playerid=1001088
--http://127.0.0.1:4445/splashwater/splash?playerid=1001024&times=75&friendid=1016384
--http://127.0.0.1:4445/splashwater/rank?playerid=1001024&length=50

function WebUrlDataMgr.GetSupplyAddressWithOps()
	return WebUrlDataMgr.GetsupplyUrlPrefix() .. "ops=%s&playerid=%s&token=%s"
end

--30天签到  服务器
function WebUrlDataMgr.GetMSignAddressWithOps()
	-- http://172.13.0.53/promotions/msign?ops=1
	return WebUrlDataMgr.GetMSignUrlPrefix() .. "ops=%s&playerid=%s&token=%s"
	--return "http://172.12.10.205:20008/msign?ops=%s&playerid=%s&token=%s"
end

--30天签到上传身份证， web
function WebUrlDataMgr.GetRealRewardUrl()
	return string.format("%sAPI/RealReward.aspx", WebUrlDataMgr.GetWebUrlPrefix())
end

--30天签到 web
function WebUrlDataMgr.GetLogisticsInfoUrl()
	return string.format("%sAPI/GetLogisticsInfo.aspx", WebUrlDataMgr.GetWebUrlPrefix())
end

--打印日志URL
function WebUrlDataMgr.GetLogAddress()
	return WebUrlDataMgr.GetHallHttpAddress() .. "/client/record?ops=%s"
end

-- 每日抽奖特有请求
function WebUrlDataMgr.GetLotteryAddressWithOps()
	return WebUrlDataMgr.GetLotteryUrl() .. "ops=%s&playerid=%s&token=%s"
end

-- 新手任务请求
function WebUrlDataMgr.GetTaskAddressWithOps()
	return WebUrlDataMgr.GetTaskUrl() .. "ops=%s&PlayerID=%s&token=%s"
end

--万圣节大作战固定url type=3
function WebUrlDataMgr.GetHalloweenTaskAddressWithOps()
	return WebUrlDataMgr.GetTaskUrl() .. "ops=%s&Type=3&PlayerID=%s&token=%s"
end

--水灯节派对固定url type=4
function WebUrlDataMgr.GetWaterLightAddressWithOps()
	return WebUrlDataMgr.GetTaskUrl() .. "ops=%s&Type=4&PlayerID=%s&token=%s"
end

function WebUrlDataMgr.GetActivityAddressWithOps()
	return WebUrlDataMgr.GetActivityUrl() .. "ops=%s&playerid=%s&token=%s"
end

function WebUrlDataMgr.GetAgentAddressWithOps()
	return WebUrlDataMgr.GetAgentUrl() .. "ops=%s&playerid=%s&token=%s"
end

function WebUrlDataMgr.GetRealShopAddressWithOps()
	return WebUrlDataMgr.GetRealShopUrl() .. "ops=%s&PlayerID=%s&token=%s"
end

function WebUrlDataMgr.GetOnlineLimitAddressWithOps()
	return WebUrlDataMgr.GetOnlineLimitUrl() .. "ops=%s&playerId=%s&token=%s"
end

function WebUrlDataMgr.GetGiftSignAddressWithOps1()
	return WebUrlDataMgr.GetGiftSignUrl1() .. "player_id=%s&token=%s"
end

function WebUrlDataMgr.GetGiftSignAddressWithOps2()
	return WebUrlDataMgr.GetGiftSignUrl2() .. "player_id=%s&token=%s"
end

function WebUrlDataMgr.GetGiftSignAddressWithOps3()
	return WebUrlDataMgr.GetGiftSignUrl3() .. "player_id=%s&token=%s"
end

function WebUrlDataMgr.GetCompositeAddressWithOps()
	return WebUrlDataMgr.GetCompositeUrl() .. "ops=%s&playerId=%s&token=%s"
end

function WebUrlDataMgr.GetUserWelfareAddressWithOps()
	return WebUrlDataMgr.GetUserWelfareUrl() .. "ops=%s&playerId=%s&token=%s"
end

function WebUrlDataMgr.GetSwitchClickReportUrl(str)
	local ts, sign = WebUrlDataMgr.GetTimeAndSign()
	return string.format(
		"%sAPI/FunctionFrequency.aspx?FunctionName=%s&ts=%s&sign=%s",
		WebUrlDataMgr.GetWebUrlPrefix(),
		str,
		ts,
		sign
	)
end

function WebUrlDataMgr.GetFPSReportUrl(data)
	local ts, sign = WebUrlDataMgr.GetTimeAndSign()
	return string.format(
		"%sAPI/PhoneFPSLog.aspx?PhoneDev=%s&GameID=%s&Version=%s&Frame15=%s&Frame20=%s&Frame25=%s&FrameAll=%s&ts=%s&sign=%s",
		WebUrlDataMgr.GetWebUrlPrefix(),
		data.deviceModel,
		data.gameId,
		data.version,
		data.otherFrameCount[15],
		data.otherFrameCount[20],
		data.otherFrameCount[25],
		data.totalFrameCount,
		ts,
		sign
	)
end

function WebUrlDataMgr.GetOpenRoyalCasinoAppUrl(data)
	return string.format(
		"%sAPI/Jump.html?channelId=%s&extraData=%s",
		WebUrlDataMgr.GetWebUrlPrefix(),
		data.channelId,
		data.extraData
	)
end

function WebUrlDataMgr.GetGameInvitationUrl(data)
	local ts, sign = WebUrlDataMgr.GetTimeAndSign()
	local title = data.title or ""
	local desc = data.desc or ""
	return string.format(
		"%sAPI/GameInvitation.aspx?title=%s&desc=%s&channelId=%s&extraData=%s&ts=%s&sign=%s",
		WebUrlDataMgr.GetWebUrlPrefix(),
		title,
		desc,
		data.channelId,
		data.extraData,
		ts,
		sign
	)
end

--facebook客服反馈地址
function WebUrlDataMgr.GetLocalServiceUrl()
	return "https://lin.ee/DrVfRhSb"
end

function WebUrlDataMgr.GetSpecialServiceUrl()
	return "https://lin.ee/gfczqU2"
end

function WebUrlDataMgr.GetOppoPayCallbackUrl()
	return string.format("%s/oppo/webapi", WebUrlDataMgr.GetHallHttpAddress())
end

function WebUrlDataMgr.GetVivoPayCallbackUrl()
	return string.format("%s/vivo/webapi", WebUrlDataMgr.GetHallHttpAddress())
end

function WebUrlDataMgr.GetLongToShortUrl(url)
	local ts, sign = WebUrlDataMgr.GetTimeAndSign()
	return string.format(
		"%sAPI/LongToShortUrl.aspx?LongUrl=%s&ts=%s&sign=%s",
		WebUrlDataMgr.GetWebUrlPrefix(),
		CC.uu.urlEncode(url),
		ts,
		sign
	)
end

function WebUrlDataMgr.GetTreasureUrl()
	return WebUrlDataMgr.GetPromotionsUrlPrefix() .. "treasure?ops=%s&playerid=%s&token=%s"
end

function WebUrlDataMgr.GetGuideUrl(step)
	local playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	local ts, sign = WebUrlDataMgr.GetTimeAndSign()
	return string.format(
		"%sAPI/NoviceGuideEntrance.aspx?PlayerId=%s&SetpID=%s&ts=%s&sign=%s",
		WebUrlDataMgr.GetWebUrlPrefix(),
		playerId,
		step,
		ts,
		sign
	)
end

--web重定向链接
function WebUrlDataMgr.GetRedirectUrl(data)
	local ts, sign = WebUrlDataMgr.GetTimeAndSign()
	data.webTitle = data.webTitle or ""
	data.webText = data.webText or ""
	data.keeplive = data.keeplive or 0
	data.textureUrl = data.textureUrl or ""
	return string.format(
		"%sAPI/FirebaseUrlOSS.aspx?ImgAdress=%s&acturl=%s&title=%s&desc=%s&keeplive=%s&ts=%s&sign=%s",
		WebUrlDataMgr.GetWebUrlPrefix(),
		data.textureUrl,
		CC.uu.urlEncode(data.url),
		data.webTitle,
		data.webText,
		data.keeplive,
		ts,
		sign
	)
end

--图片分享长链接
function WebUrlDataMgr.GetTextureShareUrl()
	return string.format("%sAPI/ShareUploadImage.aspx", WebUrlDataMgr.GetWebUrlPrefix())
end

--图片上传接口，返回图片地址
function WebUrlDataMgr.GetUpLoadImgUrl()
	local ts, sign = WebUrlDataMgr.GetTimeAndSign()
	return string.format("%sAPI/GetUpLoadImgUrlOSS?ts=%s&sign=%s", WebUrlDataMgr.GetWebUrlPrefix(), ts, sign)
end

--固定图片地址(先在web后台上传预生成)
function WebUrlDataMgr.GetTextureFixedShareUrl(data)
	local url = CC.UrlConfig.WebApiUrl.Release
	if CC.DebugDefine.GetDebugMode() and not CC.DebugDefine.CheckReleaseServer() then
		url = CC.UrlConfig.WebApiUrl.Test
	end

	return string.format("%s/FixedShare/Img/%s.jpg", url, data)
end

function WebUrlDataMgr.GetLotteryListUrl()
	return string.format("%sAPI/LotteryList", WebUrlDataMgr.GetWebUrlPrefix())
end

function WebUrlDataMgr.GetGiftPackUrl()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/giftpack?", url)
end

function WebUrlDataMgr.GetGiftPackAddressWithOps()
	return WebUrlDataMgr.GetGiftPackUrl() .. "ops=%s&PlayerID=%s&token=%s"
end

function WebUrlDataMgr.GetRechargeUrl()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/recharge?", url)
end

function WebUrlDataMgr.GetRechargeAddressWithOps()
	return WebUrlDataMgr.GetRechargeUrl() .. "ops=%s&playerId=%s&token=%s"
end

function WebUrlDataMgr.GetBlockchainAddressWithOps()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return string.format("%s/blockchain?", url) .. "ops=%s&PlayerId=%s&token=%s"
end

function WebUrlDataMgr.GetBlockchainWebStoreAddress()
	local url = CC.UrlConfig.BlockchainWebStore.Release
	if CC.DebugDefine.GetDebugMode() and not CC.DebugDefine.CheckReleaseServer() then
		url = CC.UrlConfig.BlockchainWebStore.Test
	end
	return url .. "/?token=%s"
end

function WebUrlDataMgr.GetReportQUrl()
	local url = CC.UrlConfig.ReportUrl.Release
	if CC.DebugDefine.GetDebugMode() and not CC.DebugDefine.CheckReleaseServer() then
		url = CC.UrlConfig.ReportUrl.Test
	end
	return url
end

-- 周年庆邀请免费抽奖请求URL
function WebUrlDataMgr.GetFreeLotteryAddressWithOps()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return url .. "/dailylottery/lottery?ops=%s&playerid=%s&token=%s&lotteryType=2"
end

--登录排队请求URL
function WebUrlDataMgr.GetLoginQueueAddressWithOps()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return url .. "/queue?ops=%s&PlayerId=%s&token=%s"
end

--限时活动请求
function WebUrlDataMgr.GetTimeActivitiesAddressWithOps()
	local url = WebUrlDataMgr.GetHallHttpAddress()
	return url .. "/timeActivities?ops=%s&PlayerID=%s&token=%s&ActivityType=1"
end

--生日实名验证
function WebUrlDataMgr.GetRealNameBrithDayUrl()
	local url = CC.UrlConfig.WebApiUrl.Release
	if CC.DebugDefine.GetDebugMode() and not CC.DebugDefine.CheckReleaseServer() then
		url = CC.UrlConfig.WebApiUrl.Test
	end

	return string.format("%s/GameSeveice/BirthdayRealNameAuthentication", url)
end

-- 周年庆youtube分享链接
function WebUrlDataMgr.GetAnniversaryShareUrl()
	return string.format("%s/QjyEFj", CC.UrlConfig.WebApiUrl.Release)
end

--银行渠道实名验证
function WebUrlDataMgr.GetIdentityVerificationUrl()
	local url = CC.UrlConfig.WebApiUrl.Release
	if CC.DebugDefine.GetDebugMode() and not CC.DebugDefine.CheckReleaseServer() then
		url = CC.UrlConfig.WebApiUrl.Test
	end

	return string.format("%s/GameSeveice/PayRealNameAuthentication", url)
end

--银行渠道实名验证 查询历史实名照片
function WebUrlDataMgr.GetRealNameImage()
	local url = CC.UrlConfig.WebApiUrl.Release
	if CC.DebugDefine.GetDebugMode() and not CC.DebugDefine.CheckReleaseServer() then
		url = CC.UrlConfig.WebApiUrl.Test
	end
	return string.format("%s/GameSeveice/GetRealNameImage", url)
end

function WebUrlDataMgr.GetWebServiceUrl()
	local playerId = CC.Player.Inst():GetSelfInfoByKey("Id") or 0
	local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level") or 0

	return string.format(
		"%s/livechat.html?PlayerId=%s&VipLevel=%s",
		CC.UrlConfig.WebApiServiceUrl.Release,
		playerId,
		vipLevel
	)
end

--------------------------------------------------- 暂时不用 --------------------------------------------------------------

function WebUrlDataMgr.GetAuthAddress()
	if CC.DebugDefine.GetAuthAddress() then
		return CC.DebugDefine.GetAuthAddress() .. "/"
	else
		return WebData.AuthAddress .. "/"
	end
end

function WebUrlDataMgr.GetAuthAddressWithOps()
	if CC.DebugDefine.GetAuthAddressWithOps() then
		return CC.DebugDefine.GetAuthAddressWithOps()
	else
		return WebData.AuthAddress .. "/?ops=%s&playerid=%s&token=%s"
	end
end

return WebUrlDataMgr
