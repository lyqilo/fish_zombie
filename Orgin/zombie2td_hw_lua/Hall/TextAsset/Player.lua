local CC = require("CC")

local Player = CC.class2("Player")

local dataPath = Util.userPath

local _player = nil
function Player.Inst()
	if not _player then
		_player = Player.new()
	end
	return _player
end

function Player:ctor()
	--self.onlineData = {}   从服务器获取

	self.localData = {}
	self.localData.loginName = ""
	self.localData.password = ""

	-- self.LoginData = nil
	--救济金限制(默认值3000)
	self.threshold = 3000
	self.leftTimes = 2
	self.serviceUpTime = 0

	self.thirdPartyToken = nil --第三方登录token
	self.thirdPartyUserId = ""

	self.reqDataState = false
	self.noticeState = false
	self.blessState = false
	self.fundState = false -- 七天基金红点状态
	self.NoviceFlag = true -- 新手礼包是否第一次点击
	self.dailyGiftState = false -- 每日礼包购买状态
	self.FortunebagFlag = true
	-- 春节活动是否第一次点击
	self.actSignTipState = false --签到提示状态
	self.hasSendOrRecieved = false --是否赠送或接收过赠送

	self.portraitTexture = nil --头像纹理
	self.worldCupGiftData = {} --世界杯礼包状态
end

function Player:SetBlessState(b)
	self.blessState = b
end

function Player:GetBlessState()
	return self.blessState
end

function Player:SetNoticeData(b)
	self.noticeState = b
end

function Player:GetNoticeData()
	return self.noticeState
end

--7天红点状态
function Player:SetFundState(b)
	self.fundState = b
end

function Player:GetFundState()
	return self.fundState
end

-- function Player:SetLoginData(data)
-- 	self.LoginData = data
-- end

-- function Player:GetLoginData()
-- 	return self.LoginData
-- end

function Player:SetData(loginName, password)
	self.localData.loginName = loginName
	self.localData.password = password
end

function Player:CheckSelfInfo()
	if self.localData and self.localData.selfInfo then
		return true
	end
	return false
end

function Player:SetSelfInfo(selfInfo)
	CC.uu.Log(selfInfo, "Player.SetSelfInfo selfInfo = ")
	self.localData.selfInfo = selfInfo
end

function Player:GetSelfInfo()
	return self.localData.selfInfo
end

function Player:GetSelfInfoByKey(key)
	--key值参考shared_common.proto里的PlayerData,以及share_enums.proto里的PropConfigID
	if not self.localData.selfInfo then
		return
	end
	local info = self.localData.selfInfo.Data.Player[key]
	if not info then
		local index = type(key) == "number" and key or self:ConvertKeyToIndex(key)
		for k, v in pairs(self.localData.selfInfo.Data.Props) do
			local aPropConfigId = v.ConfigId
			if aPropConfigId == index then
				info = v.Count
			end
		end
	end
	return info
end

function Player:ConvertKeyToIndex(key)
	return CC.shared_enums_pb[key]
end

function Player:GetCurLoginWay()
	return tonumber(Util.GetFromPlayerPrefs("curLoginWay"))
end

function Player:SetCurLoginWay(curLoginWay)
	Util.SaveToPlayerPrefs("curLoginWay", tostring(curLoginWay))
end

function Player:ChangeProp(data)
	self:DealWithPropData(data)

	local selfInfo = self.localData.selfInfo
	if selfInfo then
		for _, propData in ipairs(data.Items) do
			for k, v in pairs(selfInfo.Data.Props) do
				if propData.ConfigId == v.ConfigId then
					v.Count = propData.Count
					break
				end
			end
		end
	end

	CC.HallNotificationCenter.inst():post(CC.Notifications.changeSelfInfo, data.Items, data.Source)
end

function Player:DealWithPropData(data)
	-- logError("data.Source = "..data.Source)
	if
		data.Source == CC.shared_transfer_source_pb.TS_ModLevel or data.Source == CC.shared_transfer_source_pb.TS_Agent_Trade or
			data.Source == CC.shared_transfer_source_pb.TS_SystemMail
	 then
		local lastLevel = self:GetSelfInfoByKey("EPC_Level")
		local curLevel
		for _, v in ipairs(data.Items) do
			if v.ConfigId == CC.shared_enums_pb.EPC_Level then
				curLevel = v.Count
				break
			end
		end
		self:InitVIPRewards(curLevel, lastLevel)
	elseif data.Source == CC.shared_transfer_source_pb.TS_PayCrit then
		-- CC.ViewManager.OpenEx("ViolentAttackView",data.Items)
		log("ViolentAttackView has been deleted")
	elseif data.Source == CC.shared_transfer_source_pb.TS_LimitTimeGift then
		log(CC.uu.Dump(data, "OnLimitTimeGift = ", 10))
		CC.DataMgrCenter.Inst():GetDataByKey("AchievementGift").OnLimitTimeGiftBuy()
		CC.ViewManager.OpenRewardsView({items = data.Items, title = "LimitTimeGift"})
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnLimitTimeGiftReward, data)
	elseif
		data.Source == CC.shared_transfer_source_pb.TS_VIPGiftPackage_Android or
			data.Source == CC.shared_transfer_source_pb.TS_VIPGiftPackage_IOS
	 then
		CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetActivityInfoByKey("NoviceGiftView", {switchOn = false})
		CC.ViewManager.OpenRewardsView({items = data.Items, title = "NoviceGift"})
		CC.HallNotificationCenter.inst():post(CC.Notifications.NoviceReward, data)
	elseif data.Source == CC.shared_transfer_source_pb.TS_Fund then --购买基金成功
		log(CC.uu.Dump(data, "OnFundReward = ", 10))
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnFundReward, data)
	elseif data.Source == CC.shared_transfer_source_pb.TS_FundDaily then --领取基金成功
		log(CC.uu.Dump(data, "OnFundDailyReward = ", 10))
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnFundDailyReward, data)
	elseif data.Source == CC.shared_transfer_source_pb.TS_DailyGift then
		-- 每日礼包购买成功后设置本地存储状态
		CC.ViewManager.OpenRewardsView({items = data.Items})
		self:SetDailyGiftState(false)
		CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetActivityInfoByKey("Act_EveryGift", {redDot = false})
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnDailyGiftReward, data)
	elseif data.Source == CC.shared_transfer_source_pb.TS_Bind then --TS_InfomationComplete
		CC.ViewManager.OpenRewardsView(
			{
				items = data.Items,
				title = "BindPhone",
				callback = function()
					if
						not CC.Player.Inst():GetSafeCodeData().GuideStatus and CC.ViewManager.IsHallScene() and
							CC.ViewManager.GetCurrentView().viewName == "PersonalInfoView"
					 then
						--开启保险箱引导
						CC.ViewManager.Open("SafeBoxGuideView")
					end
				end
			}
		)
	elseif data.Source == CC.shared_transfer_source_pb.TS_PhysicalGoods then
		local propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
		if propCfg[data.Items[1].ConfigId].Physical then
			CC.ViewManager.OpenRewardsView(
				{items = data.Items, title = "ExchangeGoods", source = CC.shared_transfer_source_pb.TS_PhysicalGoods}
			)
		else
			CC.ViewManager.OpenRewardsView({items = data.Items, title = "ExchangeGoods"})
		end
	elseif data.Source == CC.shared_transfer_source_pb.TS_Vip_GoStraightTo then
		-- elseif data.Source == CC.shared_transfer_source_pb.TS_Daily_Lottery then
		-- 	CC.HallNotificationCenter.inst():post(CC.Notifications.OnDailyLotteryReward, data)
		for _, v in ipairs(data.Items) do
			if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
				--奖励为筹码时，打开奖励界面，推送消息(经验奖励也是同样源，防止多次打开推送)
				CC.ViewManager.OpenRewardsView({items = data.Items, title = "VipThreeCard"})
				CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetActivityInfoByKey("VipThreeCardView", {switchOn = false})
				CC.HallNotificationCenter.inst():post(CC.Notifications.VipThreeCard, data)
				break
			end
		end
	elseif data.Source == CC.shared_transfer_source_pb.TS_DailyGiftSign_Click then
		CC.ViewManager.OpenRewardsView({items = data.Items})
	elseif data.Source == CC.shared_transfer_source_pb.Ts_Crystal_Shop then
		CC.ViewManager.OpenRewardsView({items = data.Items, title = "ExchangeGoods"})
	elseif
		data.Source == CC.shared_transfer_source_pb.TS_PlayerRegress or
			data.Source == CC.shared_transfer_source_pb.TS_Regression_50 or
			data.Source == CC.shared_transfer_source_pb.TS_Regression_300
	 then
		CC.ViewManager.OpenRewardsView({items = data.Items}) --老玩家回归
	elseif data.Source == CC.shared_transfer_source_pb.TS_Halloween_PayBag_Rewards then
		--万圣节10Thb礼包
		CC.ViewManager.OpenRewardsView({items = data.Items})
	elseif data.Source == CC.shared_transfer_source_pb.TS_Star_Praise then
		CC.ViewManager.OpenRewardsView({items = data.Items}) --五星好评
	elseif
		data.Source == CC.shared_transfer_source_pb.TS_PropExchange or data.Source == CC.shared_transfer_source_pb.TS_Shop
	 then
		CC.ViewManager.OpenRewardsView({items = data.Items})
	elseif data.Source == CC.shared_transfer_source_pb.TS_AirPlane_Daily_WelfarePackage then
		log("TS_AirPlane_Daily_WelfarePackage:飞机每日特惠2")
		CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetActivityInfoByKey("DailyDealsView", {redDot = false})
		--飞机每日特惠礼包
		CC.ViewManager.OpenRewardsView({items = data.Items})
	elseif
		data.Source == CC.shared_transfer_source_pb.TS_Holiday_PromotionalPackage or
			data.Source == CC.shared_transfer_source_pb.TS_Splash_DailyGift_50 or
			data.Source == CC.shared_transfer_source_pb.TS_Splash_DailyGift_270
	 then --通用节日促销礼包
		CC.ViewManager.OpenRewardsView({items = data.Items})
	elseif
		data.Source == CC.shared_transfer_source_pb.TS_Redpacket_Shop_Capture or
			data.Source == CC.shared_transfer_source_pb.TS_Redpacket_Shop_Card
	 then
		local propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
		if not propCfg[data.Items[1].ConfigId].Physical then
			CC.ViewManager.OpenRewardsView({items = data.Items, title = "ExchangeGoods"})
		end
	end
end

function Player:InitVIPRewards(level, lastLevel)
	if not level or not lastLevel then
		return
	end
	local vipRight = CC.ConfigCenter.Inst():getConfigDataByKey("VIPRights")
	local totalReward = 0
	for i = lastLevel + 1, level do
		totalReward = totalReward + vipRight[i + 1].Freeprop[1].Count
	end
	local param = {}
	param[1] = {
		ConfigId = CC.shared_enums_pb.EPC_ChouMa,
		Delta = totalReward
	}
	--CC.ViewManager.OpenRewardsView({items = param,title = "VIP"})
	if CC.ViewManager.IsViewOpen("VipUpgradeView") then
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnVipUpgradeView, level)
	else
		CC.ViewManager.Open("VipUpgradeView", {items = param, level = level})
	end
	if level and lastLevel ~= level then
		log("lastLevel:" .. lastLevel .. "  curLevel:" .. level)
		CC.HallNotificationCenter.inst():post(CC.Notifications.VipChanged, level)
	end
end

function Player:SetJackpots(changeJackpots)
	-- print("打印奖金池数据-----------------------------")
	-- for i = 1,#changeJackpots do
	-- 	local v = changeJackpots[i]
	-- 	print("*********************************")
	-- 	print("游戏ID：")
	-- 	print(v.GameId)
	-- 	print("游戏场ID：")
	-- 	print(v.GroupId)
	-- 	print("奖金池数量：")
	-- 	print(v.Num)
	-- end
	-- print("-------------------------------------------")
	if not self.jackpots then
		self.jackpots = changeJackpots
	else
		for i = 1, #changeJackpots do
			local aChange = changeJackpots[i]
			local isFinded = false
			for j = 1, #self.jackpots do
				local aOrigin = self.jackpots[j]
				if aChange.GameId == aOrigin.GameId and aChange.GroupId == aOrigin.GroupId then
					--修改
					aOrigin.Num = aChange.Num
					isFinded = true
					break
				end
			end
			if not isFinded then
				--新增
				table.insert(self.jackpots, aChange)
			end
		end
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.InitGameJackpots, true)
end

function Player:GetJackpotsByID(GameId)
	local param = {}
	if self.jackpots then
		for i = 1, #self.jackpots do
			if self.jackpots[i].GameId == GameId then
				table.insert(param, self.jackpots[i])
			end
		end
	end
	return param
end

function Player:GetJackpotsNumByKey(GameId)
	local num = 0
	if self.jackpots then
		for i = 1, #self.jackpots do
			local aJackpot = self.jackpots[i]
			if aJackpot.GameId == GameId then
				num = num + aJackpot.Num
			end
		end
	end
	return num
end

function Player:SetIsBinded(isBinded)
	self.isBinded = isBinded
end

function Player:GetIsBinded()
	return self.isBinded
end

function Player:SetPortraitTexture(texture)
	self.portraitTexture = texture
end

function Player:GetPortraitTexture()
	return self.portraitTexture
end

function Player:ReleasePortraitTexture()
	if not self.portraitTexture then
		return
	end
	GameObject.Destroy(self.portraitTexture)
	self.portraitTexture = nil
end

function Player:SetLoginToken(data)
	self.loginToken = data
end

function Player:GetLoginToken()
	CC.uu.Log("该API已弃用,请调用GetLoginInfo()!!")
	return self:GetLoginInfo()
end

function Player:SetThirdPartyToken(token)
	self.thirdPartyToken = token
end

function Player:GetThirdPartyToken()
	return self.thirdPartyToken
end

function Player:SetVipLoginAward(data)
	self.vipLoginAward = data
end

function Player:GetVipLoginAward()
	if self.vipLoginAward and self.vipLoginAward ~= 0 then
		local param = {}
		param[1] = {
			ConfigId = 2,
			Count = self.vipLoginAward
		}
		CC.ViewManager.OpenRewardsView({items = param, title = "VIPLogin"})
		self.vipLoginAward = nil
	end
end

function Player:SetSevenDays(data)
	self.sevenDaysData = data
end

function Player:GetSevenDays()
	return self.sevenDaysData
end

function Player:OpenSevenDaysView()
	if self.sevenDaysData ~= nil and self.sevenDaysData.State == 1 then
		local param = {}
		param[1] = {
			ConfigId = 2,
			Count = self.sevenDaysData.Count
		}
		CC.ViewManager.OpenRewardsView({items = param, title = "SevenDays"})
		self.sevenDaysData.State = 0
	else
		return
	end
end

function Player:SetLoginInfo(data)
	self.loginInfo = data

	-- 设置bugly用户标识，方便查bug
	BuglyUtil.SetUserId(data.PlayerId)
end

function Player:GetLoginInfo()
	return self.loginInfo
end

----------------首充礼包状态-------------------
function Player:SetFristPayState(data)
	self.FristPayState = data
end

function Player:GetFristPayState()
	return self.FristPayState
end
-----------------------------------------------

-------------------重连信息--------------------
function Player:SetReConnectInfo(data)
	self.ReConnectInfo = data
end

function Player:GetReConnectInfo()
	return self.ReConnectInfo
end

function Player:SetLoginState(state)
	self.LoginState = state
end

function Player:GetLoginState()
	return self.LoginState
end
-----------------------------------------------

----------------登录状态-------------------
function Player:SetDailyReward(data)
	self.DailyReward = data
end

function Player:GetDailyReward()
	return self.DailyReward
end
-----------------------------------------------

----------------补齐奖励-------------------
function Player:SetChipReplenish(data)
	for i, v in ipairs(data.Props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
			self.ChipReplenish = v.Count
		end
	end
end

function Player:GetChipReplenish()
	if self.ChipReplenish and self.ChipReplenish > 0 then
		local param = {}
		param[1] = {
			ConfigId = 2,
			Count = self.ChipReplenish
		}
		CC.ViewManager.OpenRewardsView({items = param, title = "ChipReplenish"})
		self.ChipReplenish = 0
	end
end
-----------------------------------------------

----------------救济金领取限制-------------------
function Player:SetThreshold(count)
	self.threshold = count
end

function Player:GetThreshold()
	return self.threshold
end

--剩余次数
function Player:SetLeftTimes(count)
	self.leftTimes = count
end

function Player:GetLeftTimes()
	return self.leftTimes
end
-----------------------------------------------

--记录点击客服反馈时间
function Player:SetServiceUpTime(time)
	self.serviceUpTime = time
end

function Player:GetServiceUpTime()
	return self.serviceUpTime
end

--记录玩家点击新手礼包
function Player:SetNoviceFlag(b)
	self.NoviceFlag = b
end

--获取玩家点击状态
function Player:GetNoviceFlag()
	return self.NoviceFlag
end

function Player:SetDailyGiftState(flag)
	self.dailyGiftState = flag
	--CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshRedPointState, {key = "dailyGift",state = flag});
end

function Player:GetDailyGiftState()
	return self.dailyGiftState
end

--记录玩家点击春节活动
function Player:SetFortunebagFlag(b)
	self.FortunebagFlag = b
end

--获取玩家春节活动
function Player:GetFortunebagFlag()
	return self.FortunebagFlag
end

function Player:IsShowRoomCard()
	if CC.ChannelMgr.GetTrailStatus() then
		return false
	end
	local storeCfg = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetStoreCfg() or {}
	if table.isEmpty(storeCfg.Prop) then
		return false
	end
	for _, v in ipairs(storeCfg.Prop) do
		if v.CommodityType == CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine").CommodityType.RoomCard then
			return true
		end
	end
	return false
end

function Player:SetThirdPartyUserId(userId)
	if not userId then
		return
	end
	self.thirdPartyUserId = userId
end

function Player:GetThirdPartyUserId()
	return self.thirdPartyUserId
end

function Player:SetActSignTipState(flag)
	self.actSignTipState = flag
end

function Player:GetActSignTipState()
	return self.actSignTipState
end

--10元首冲礼包
function Player:SetFirstGiftState(State)
	self.FirstGiftState = State
end

function Player:GetFirstGiftState()
	return self.FirstGiftState or false
end

--生日礼物
function Player:SetBirthdayGiftData(data)
	self.birthdatGiftData = data
	if data.GiftStatus == 1 then
		CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetActivityInfoByKey("BirthdayView", {switchOn = true})
	end
end

function Player:GetBirthdayGiftData()
	return self.birthdatGiftData or {}
end

function Player:SetAppleLoginState(state)
	self.isAppleLogin = state
end

function Player:GetAppleLoginState()
	return self.isAppleLogin or false
end

function Player:SetSendOrRecievedState(state)
	self.hasSendOrRecieved = state
end

function Player:GetSendOrRecievedState()
	return self.hasSendOrRecieved
end

function Player:SetPayGiftRedState(state)
	self.payRed = state
end

function Player:GetPayGiftRedState()
	return self.payRed or false
end

function Player:SetFreeLotRedState(state)
	self.freeLotRed = state
end

function Player:GetFreeLotRedState()
	return self.freeLotRed or false
end

function Player:SetSafeCodeData(data)
	self.safeCodeData = {}
	self.safeCodeData.FreezeStatus = data.FreezeStatus --安全码是否锁定，false：没有锁定    true：锁定
	self.safeCodeData.SafeStatus = data.SafeStatus --是否设置安全码 ，0：未设置     1：已设置
	self.safeCodeData.GuideStatus = data.GuideStatus --引导状态，true：已引导   false：未引导
	self.safeCodeData.SafeService = {}
	--Type表示验证服务ID: 1:实物商城 2:夺宝 3:超级夺宝  4:交易  5:保险箱  6:解绑手机。Status表示进行此项操作时是否要验证安全码,true:免验证，false:需要验证
	for i, v in ipairs(data.SafeService) do
		self.safeCodeData.SafeService[v.Type] = v
	end
end

function Player:GetSafeCodeData()
	local data = {
		FreezeStatus = false,
		SafeStatus = 0,
		GuideStatus = true,
		SafeService = {
			{Status = false},
			{Status = false},
			{Status = false},
			{Status = false},
			{Status = false},
			{Status = false}
		}
	}
	return self.safeCodeData or data
end

function Player:SetMarsTaskList(data)
	self.marsTaskList = data
end

function Player:GetMarsTaskList()
	return self.marsTaskList
end

return Player
