local CC = require("CC")

local HallViewCtr = CC.class2("HallViewCtr")

function HallViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function HallViewCtr:InitVar(view,param)
	self.param = param

	self.view = view

	self.mailDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Mail")

	self.friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend")

	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")

	self.FundDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("FundData")

	self.webDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")

	self.switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")

	self.FortunebagData = CC.DataMgrCenter.Inst():GetDataByKey("FortunebagData")

	self.SplashingData = CC.DataMgrCenter.Inst():GetDataByKey("SplashingData")

	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")

	self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine");
	self.GiftDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("GiftData")
	self.noviceDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("NoviceDataMgr")

	self.ApplyRequestBool = true

	self.guideState = false
	self.RenameCardState = false
	self.wakeupGameId = nil;

	self.stockTime = 0
	--动态链接extraData
	self.urlExtraData = nil;

end

function HallViewCtr:OnCreate()

	local curLoginWay = CC.Player.Inst():GetCurLoginWay()
	if CC.Player.Inst():GetAppleLoginState() then
		CC.ReportManager.SetDot("APPLEENTERHALL")
	elseif curLoginWay == CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginWay.Guest then
		CC.ReportManager.SetDot("GUESTENTERHALL")
	elseif curLoginWay == CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginWay.Facebook then
		CC.ReportManager.SetDot("FBENTERHALL")
	elseif curLoginWay == CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginWay.Line then
		CC.ReportManager.SetDot("LINEENTERHALL")
	end

	CC.LocalGameData.SetFrames()

	local HorseRaceLamp = self.switchDataMgr.GetSwitchStateByKey("HorseRaceLamp")
	CC.ChatManager.SetSpeakBordState(HorseRaceLamp and self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel"))
	CC.ChatManager.SetNoticeBordState(HorseRaceLamp)

	CC.ViewManager.SetNoticeBordPos(Vector3(0,0,0))
    CC.ViewManager.SetSpeakBoardPos(Vector3(0,0,0))

    CC.ViewManager.SetNoticeBordWidth(915)
	CC.ViewManager.SetSpeakBoardWidth(915)

	CC.ViewManager.SetNoticeBordEffectState(true)
	CC.ViewManager.SetRewardNoticeView(true, false, 0)
	CC.ViewManager.SetArenaNoticeView(true, false, 0)

	self:RegisterEvent()
	self:InitData()

	-- --上报数据后台
	-- CC.ReportQManager.Upload()

	self.view:DelayRun(0.1, function()
		CC.Sound.PlayHallBackMusic("BGM_Hall")
	end)

	local toDoList = {
		function()
			local guide = self.gameDataMgr.GetGuide()
			if not (guide.state and guide.Flag < 1) then
				CC.Request("ReqStockChangedTime")
			end
		end,
		function ()
			CC.Request("ReqSubscribeList",{PlayerID = CC.Player.Inst():GetSelfInfoByKey("Id")})
		end
	}

	if self.switchDataMgr.GetPingSwitch() then
		for i,func in ipairs(toDoList) do
			self.view:DelayRun(0.05 * i, func);
		end
	end

	-- self.view:DelayRun(1, function()
	-- 	CC.LocalGameData.CheckLoadImge(28)--每月28号清理一次
	-- end)
end

function HallViewCtr:InitData()
	-- if self.switchDataMgr.GetPingSwitch() then
	self.view:DelayRun(2,function ()
			self:ReliefInfo()
		end)
	-- end

	-- self:GetResourceVersionInfo()
	if CC.Player.Inst():GetLoginState() then

		self.view:DelayRun(1,function ()
			self.view:FindChild("Mask"):SetActive(false)
			if CC.ChannelMgr.GetTrailStatus() then
				return false;
			end

			local funcList = {
				self.CheckDynamicLinkInstallData,
				self.CheckDynamicLinkWakeupData,
				self.CheckFacebookDeepLinkData,
				self.CheckGuide,
				self.CheckBehindView
			}
			for _,func in ipairs(funcList) do
				if func(self) then
					break;
				end
			end
			--Vivo转移官方包
			self:VivoToGoogleMarket()
		end)

		CC.Player.Inst():SetLoginState(false)

		self:ReConnectGame()

		if self.switchDataMgr.GetPingSwitch() then
			--请求历史聊天记录
			-- self:LoadHisChatData();
			--拉取私聊信息
			-- self:LoadPrivate()
			--请求邮件数据
			self:LoadMailData();
			--请求好友数据
			self:LoadFriendData();
			--活动统一开关
			self.activityDataMgr.ReqInfo()
			--拉取礼包状态
			self:LoadGiftStatus()
			--月卡
			CC.SelectGiftManager.CheckMonthCard()

			CC.DataMgrCenter.Inst():GetDataByKey("AchievementGift").ResetReq()
			CC.DataMgrCenter.Inst():GetDataByKey("AchievementGift").CheckGiftExist()
		end
		--超v白名单
		self:ReqGetWhiteAccount()
		--安全码
		CC.Request("ReqSafeData",{IMei = CC.Platform.GetDeviceId()})

		--查询是否拥有未完成的googleplay订单
		if CC.Platform.isAndroid then
			CC.GooglePlayIABPlugin.QueryInventory()
			--self:CheckGoogleOrderList()
		elseif CC.Platform.isIOS then
			CC.ApplePayPlugin.QueryInventory()
		end
		if self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") then
			self.view:ShowTreasureTip(CC.LocalGameData.GetLocalDataToKey("TreasureTips", CC.Player.Inst():GetSelfInfoByKey("Id")),true)
		end
	else
		self:LoadPlayerWithPropIds()
		
		--五星好评
		self.view:DelayRun(3,function ()
			--延迟3秒等游戏数据同步到大厅
			self:CheckStarRating()
		end)
		
		self.view:DelayRun(1,function ()
			self.view:FindChild("Mask"):SetActive(false)
			if not self:CheckGuide() then
				if CC.Player.Inst():GetBirthdayGiftData().Status == 1 then
					CC.ViewManager.OpenEx("BirthdayAwardView")
				else
					self:GameBackHallTip()
				end
			end
			if CC.ChannelMgr.GetTrailStatus() then
				return false;
			end
		end)
	end

	--红点刷新
	self:RefreshFriendRedPoint()
	self:RefreshMailRedPoint()

	if self.switchDataMgr.GetPingSwitch() then

		--在大厅发起的一些请求
		self:SomeRequest()

		if self.switchDataMgr.GetSwitchStateByKey("AgentUnlock") then
			self.view:SetAgentBtnStatus()
			self.agentDataMgr.LoadUnReceiveEarn()
		end
	end
end

function HallViewCtr:SomeRequest()
	--首冲礼包
	self:LoadFirstGift()
	--大象礼包流水
	--self:LoadElephantExtra()
	--请求充值礼包抽奖状态
	self:ReqGetRechargeActivity()
	--请求炮台抽奖信息
	self:ReqGetBatteryLotteryInfo()
	--邀请抽奖
	self:OnReqFreeTimesGet()
	--老玩家回归
	self:OnReqCheckOldPlayerReturn()
end

function HallViewCtr:GetDynamicLink()
	local link = CC.FirebasePlugin.GetDynamicLink();
	link = link ~= "" and link or CC.FacebookPlugin.GetDynamicLink();
	if link == "" then return end;
	CC.uu.Log(link, "GetDynamicLink");
	local data = CC.uu.parseUrlParam(CC.uu.urlDecode(link));
	CC.FirebasePlugin.ClearDynamicLink();
	CC.FacebookPlugin.ClearDynamicLink();
	return data;
end

function HallViewCtr:CheckGuide()
	if CC.DebugDefine.GetGuideDebugState() then
		--跳过新手引导
		self:CheckNeedToGoGame()
		return false
	end
	if self.gameDataMgr.GetPlayerType() == "" and not CC.HallUtil.IsFromADSource() then
		self.gameDataMgr.SetPlayerType("Organic")
	end
	--检查新手引导
	local guideData = self.gameDataMgr.GetGuide()
	--local treasure = self.switchDataMgr.GetSwitchStateByKey("TreasureView")
	if guideData.state and guideData.Flag < 8 then
		--新手引导
		if self.guideView then
			self.guideView:Destroy()
			self.guideView = nil
		end
		self.guideView = CC.uu.CreateHallView("GuideView")
		return true
	end
	log(CC.uu.Dump(guideData, "guideData",10))
	if guideData.TotalFlag then
		if self:SigninGuide() then
			return true
		-- elseif self.agentDataMgr.GetAgentSatus() and self:CheckAdvancedVipGuide() then
		-- 	return true
		elseif self:CheckRenameGuide() then
			return true
		end
	end
	if self.switchDataMgr.GetPingSwitch() then
		if self:CheckNews() then
			return true
		end
	end
	self:CheckNeedToGoGame()

	return false
end

--签到引导
function HallViewCtr:SigninGuide()
	local signOpen = self.activityDataMgr.GetActivityInfoByKey("NoviceSignInView").switchOn and self.noviceDataMgr.GetNoviceDataByKey("NoviceSignInView").open
	local taskOpen = CC.Player.Inst():GetSelfInfoByKey("EPC_TaskLevel")
	log(CC.uu.Dump(taskOpen, "taskOpen",10))
	if signOpen and taskOpen > 0  then
		if not self.gameDataMgr.GetSingleFlag(10) then
			if not self.guideView then
				self.guideView = CC.uu.CreateHallView("GuideView", {singleFlag = 10})
			end
			return true
		end
	end
	return false
end

function HallViewCtr:CheckNews(level)
	if not CC.ChannelMgr.GetSwitchByKey("bShowSendChip") then
		return;
	end
	--检查赠送咨询
	if self.switchDataMgr.GetSwitchStateByKey("CV") and self.switchDataMgr.GetSwitchStateByKey("BSGuide") then
		--资讯满足条件
		if not self.GiftDataMgr:GetLoadNews() then
			CC.Request("ReqLoadNews")
		end
		if self.gameDataMgr.GetGuide().TotalFlag and not self.gameDataMgr.GetSingleFlag(30) then
			if level then
				self.guideState = true
			else
				--vip3直升卡引导
				self:OpenGuideGive()
				return true
			end
		end
	end
end

function HallViewCtr:CheckRenameGuide()
	--改名卡引导
	if not self.gameDataMgr.GetSingleFlag(28) and CC.Player.Inst():GetSelfInfoByKey("EPC_Mod_Name_Card") >= 1 then
		if not self.guideView then
			self.guideView = CC.uu.CreateHallView("GuideView", {singleFlag = 32})
			self:GuideGetVector(32)
			return true
		end
	end
	return false
end

function HallViewCtr:CheckAdvancedVipGuide()
	--高级vip引导
	if not self.gameDataMgr.GetSingleFlag(27) and self.agentDataMgr.GetAgentSatus() then
		self.guideView = CC.uu.CreateHallView("GuideView", {singleFlag = 27})
		self:GuideGetVector(27)
		return true
	end
	return false
end

function HallViewCtr:OpenGuideGive()
	if self.guideView then
		self.guideView:Destroy()
		self.guideView = nil
	end
	self.guideView = CC.uu.CreateHallView("GuideView", {singleFlag = 30})
	self:GuideGetVector(30)
	self.guideState = false
end

function HallViewCtr:GameBackHallTip()
	--游戏返回大厅不足5分钟
	if not CC.LocalGameData.GetDailyStateByKey("FiveMinTip") and CC.Player.Inst():GetSelfInfoByKey("EPC_Daily_OnlineTime") < 300 then
		CC.LocalGameData.SetDailyStateByKey("FiveMinTip", true)
		local param = {}
		param.tipType = 3
		param.okFunc = function ()
			CC.ViewManager.Open("FreeChipsCollectionView", {currentView = "OnlineAward"})
		end
		CC.ViewManager.Open("GameTipView", param)
	end
end

function HallViewCtr:LoadPlayerWithPropIds()
	--刷新玩家常用道具信息
	local data = {}
	data.propIds = {
		CC.shared_enums_pb.EPC_ChouMa,		--筹码
		CC.shared_enums_pb.EPC_ZuanShi,		--钻石
		CC.shared_enums_pb.EPC_New_GiftVoucher, --新礼票
		CC.shared_enums_pb.EPC_Daily_OnlineTime, --玩家每日累积在线时长
		CC.shared_enums_pb.EPC_Super,  --小月卡
		CC.shared_enums_pb.EPC_Supreme,  --大月卡
	}
	data.succCb = function()
		CC.FirebasePlugin.TrackRegisterTotalLose();
	end
	CC.HallUtil.ReqPlayerPropByIds(data)
end

function HallViewCtr:CheckInvited()

	local param = self.urlExtraData or Client.GetBrowserParams();
	CC.uu.Log(param, "====CheckInvited=======")
	if param == "" then return false end
	--[[
		@param
		gameId:游戏id(必传)
		其他参数回传给游戏
	]]
	self.urlExtraData = nil;
	Client.ClearBrowserParams();
	param = Json.decode(Util.DecodeBase64(self:ReplaceLinkChar(param)));
	CC.uu.Log(param, "====CheckInvited-decode=======")
	if not param.gameId or param.gameId == 1 then
		return false;
	end
	local gameData = table.copy(self.gameDataMgr.GetInfoByID(param.gameId))
	gameData.inviteData = param
	CC.HallUtil.CheckAndEnter(param.gameId,gameData)
	return true;
end

function HallViewCtr:ReliefInfo()
	if not CC.ChannelMgr.GetSwitchByKey("bHasRelief") then
		return;
	end
	CC.Request("GetReliefInfo",nil,function (err,data)
		if data.LeftTimes > 0 and CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") < data.Threshold then
			local param = {}
			param.Type = data.Type
			param.UnderAmount = data.Threshold
			param.Amount = data.Amount
			param.Type = data.Type
			param.LeftTimes = data.LeftTimes
			CC.ViewManager.Open("BenefitsView",param)
		end
		CC.Player.Inst():SetThreshold(data.Threshold);
		CC.Player.Inst():SetLeftTimes(data.LeftTimes);
	end,
	function (err,data)
		logError("拉取救济金失败:"..err)
	end)


end

--检查后续弹窗
function HallViewCtr:CheckBehindView()
	if self:CheckInvited() then
		return
	end

	if self.switchDataMgr.GetPingSwitch() then
		local param = {}
		param.closeFunc = function ()
			--请求竞技场信息
			CC.DataMgrCenter.Inst():GetDataByKey("ArenaData").GetGameArena()
		end
		if CC.Player.Inst():GetBirthdayGiftData().Status == 1 then
			CC.ViewManager.OpenEx("BirthdayAwardView")
		end
		if self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") and self.activityDataMgr.GetActivityInfoByKey("HalloweenView").switchOn then
			CC.ViewManager.OpenEx("HalloweenView",param)
		else
			CC.ViewManager.OpenEx("FreeChipsCollectionView",param)
		end
		if CC.LocalGameData.GetLocalDataToKey("BirthdayGift", CC.Player.Inst():GetSelfInfoByKey("Id")) then
			--生日礼包
			if CC.Player.Inst():GetBirthdayGiftData().Status == 1 or CC.Player.Inst():GetBirthdayGiftData().GiftStatus == 1 then
				CC.ViewManager.OpenEx("BirthdayView")
			end
		end
		-- CC.ViewManager.OpenEx("SelectGiftCollectionView")
		if CC.LocalGameData.GetLocalDataToKey("LuckyTurntable", CC.Player.Inst():GetSelfInfoByKey("Id")) then
			--每日首次关闭,打开幸运礼包
			CC.ViewManager.OpenEx("LuckyTurntableView")
			CC.LocalGameData.SetLocalDataToKey("LuckyTurntable", CC.Player.Inst():GetSelfInfoByKey("Id"))
		end
	end

	-- --绑定手机弹窗
	-- local playerData = CC.Player.Inst():GetSelfInfo()
	-- local bindingFlag = CC.Player.Inst():GetLoginInfo().BindingFlag or 0
	-- local showBtnBindPhone = bit.band(bindingFlag, CC.shared_enums_pb.EF_TelBinded) == 0 or playerData.Data.Player.Birth == ""
	-- if showBtnBindPhone and self.switchDataMgr.GetSwitchStateByKey("BindPhone", false) and CC.LocalGameData.GetLocalDataToKey("ShowBindPhone", CC.Player.Inst():GetSelfInfoByKey("Id")) then
	-- 	--流水在线，本地记录，是否绑定手机
	-- 	--CC.ViewManager.OpenEx("PersonalBindPhoneView", {guide = true})
	-- 	CC.LocalGameData.SetLocalDataToKey("ShowBindPhone", CC.Player.Inst():GetSelfInfoByKey("Id"))
	-- end

	self:CheckOpenPopView()
	if self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") and self.activityDataMgr.GetActivityInfoByKey("AnniversaryTurntableView").switchOn and
	(CC.LocalGameData.GetLocalDataToKey("CelebrationView", "AnniversaryTurntableView") or CC.Player.Inst():GetSelfInfoByKey("EPC_Props_81") > 0) then
		CC.ViewManager.OpenEx("AnniversaryTurntableView")
		CC.LocalGameData.SetLocalDataToKey("CelebrationView", "AnniversaryTurntableView")
	end
end

function HallViewCtr:CheckOpenPopView()
	local popListCount = #(CC.MessageManager.GetPopupList())
	local unreadIndex = CC.MessageManager.GetUnreadPouupIndex()
	--Debug模式设置广告状态(1-广告线上状态，2-关闭广告，3-重置广告状态为今天未打开)
	local showPop = true
	if CC.DebugDefine.GetAdDebugState() == 2 then
		showPop = false
	elseif CC.DebugDefine.GetAdDebugState() == 3 then
		CC.LocalGameData.SetPopupState("")
		unreadIndex = CC.MessageManager.GetUnreadPouupIndex()
	end
	------------------------------------------------------------------------------------------------------------------------------------------
	if popListCount > 0 and showPop and unreadIndex and self.switchDataMgr.GetSwitchStateByKey("PhysicalLock") then
		CC.ViewManager.OpenEx("PopupView", unreadIndex);
    else
		CC.Player.Inst():GetChipReplenish()
    end
end

-- function HallViewCtr:GetResourceVersionInfo()
-- 	CC.Request.GetAllResourceVersionInfo()
-- end

function HallViewCtr:SetResourceVersionInfo(err,data)
	if err == 0 then
		self:CheckFroceUpdateVersion(data);
	end
end

function HallViewCtr:CheckFroceUpdateVersion(data)
	local hallId = 1;
	local hallVersion;
	for _,v in ipairs(data.Items) do
		if v.GameID == hallId then
			hallVersion = v.Version;
		end
	end
	-- CC.uu.Log(data, "forceUpdateVerison====", 3)
	if hallVersion and self.gameDataMgr.GetHallForceUpdateVersion() then
		if tonumber(hallVersion) > self.gameDataMgr.GetHallForceUpdateVersion() then
			local language = self.view.language;
			local box = CC.ViewManager.ShowMessageBox(language.check_hall_forceUpdate, function()
					Application.Quit();
				end);
			box:SetOneButton();
		end
	end

	self.gameDataMgr.SetForceUpdateVersion(data.Items);
end

function HallViewCtr:ReConnectGame()
	local language = self.view.language
	local info =  CC.Player.Inst():GetReConnectInfo()
	local allocServer = nil
	allocServer = function ()
	log("GameID:"..info.GameId.."   GroupID:"..info.GroupId.. "    IsReload:"..self.gameDataMgr.GetIsReloadByID(info.GameId))
		if info.GameId ~= 0 and info.GroupId ~= 0 and self.gameDataMgr.GetIsReloadByID(info.GameId) == 1 then

			local data = {}
            data.GameId=info.GameId
            data.GroupId=info.GroupId

            CC.Request("ReqAllocServer",data,
            function (err,data)
				local box = CC.ViewManager.ShowMessageBox(language.tip_reconnect,
				function ()
					self:EnterGame(data.Address,info.GameId,info.GroupId)
				end)
				box:SetOneButton()
			end,
			function (err,data)
				local box = CC.ViewManager.ShowMessageBox(language.tip_allocServer,
				function ()
					allocServer()
				end)
				box:SetOkText(language.btn_retry)
				box:SetOneButton()
			end)


		end
	end
	allocServer()
end

function HallViewCtr:EnterGame(ip,gameID,groupID)
	local param = {}
	param.serverIp = ip
	param.RoomId = groupID
	param.GameId = gameID
	param.gameData =  self.gameDataMgr.GetInfoByID(gameID)
	CC.uu.Log(param, " EnterGameParam:")
	CC.HallUtil.EnterGame(gameID,param)
end

-- function HallViewCtr:LoadHisChatData()
--     local data=CC.ChatManager.GetHisInfoNum()
-- 	CC.Request("LoadChatList",{Count=data},function(err,data)
-- 			-- log("拉取历史聊天记录成功！")
-- 			CC.ChatManager.InitCache(data.Chats)
-- 		end, function()
-- 			logError("HallViewCtr:LoadHisChatData failed");
-- 		end)

-- end

-- function HallViewCtr:LoadPrivate()
-- 	CC.Request("LoadPChatSummary",nil,function (err,data)
-- 		CC.ChatManager.InitPrivateList(data)
-- 	end,function ()
-- 		logError("HallViewCtr: LoadPrivate failed");
-- 	end)

-- end

function HallViewCtr:LoadMailData()
	--再获取未读邮件数
    CC.Request("ReqMailLoadAll")
end

function HallViewCtr:SetMailData(err,data)
	if err == 0 then
		-- log("拉取邮件列表成功！")
		self.mailDataMgr.SetMailData(data);
		self:RefreshMailRedPoint();
	else
		logError("HallViewCtr: LoadMailData failed"..err);
	end
end

function HallViewCtr:LoadFriendData(callback)
	--拉取好友列表
	CC.Request("ReqLoadFriendsList",{Index = 1}, function(err,data)
			-- log("拉取好友列表成功！")
			CC.DataMgrCenter.Inst():GetDataByKey("Friend").SetFriendListData(data);
		end, function(err)
			logError("HallViewCtr: loadFriendData failed");
		end)

	--拉取好友申请列表
	CC.Request("ReqLoadApplyFriendsList",{Index = 1})
end

function HallViewCtr:LoadGiftStatus()
	if self.activityDataMgr.GetReqGiftState() then return end
	--local wareIds = {"22011", "22012", "22013", "22014", "22015","22016","30015"}
	local wareIds = {"22011", "22012", "22013", "22014", "22015","22016","30015",
		"30083", "30084", "30085", "30086", "30087",
		"30088", "30089", "30090", "30091", "30092",
		"30093", "30094", "30095", "30096", "30097",
		"30098", "30099", "30100", "30101", "30102",
		"30103", "30104", "30105", "30106", "30107",
		"30108", "30109", "30110", "30111", "30112",
		"30113", "30114", "30115", "30116", "30117",
		"30124", "30125", "30126", "30127", "30128",
		"30129", "30130", "30131", "30132", "30133",
		"30312","30329"
	}
	CC.Request("GetOrderStatus",wareIds, function(err, data)
		-- log(CC.uu.Dump(data, "wareIds", 10))
		if data.Items then
			for _, v in ipairs(data.Items) do
				self.activityDataMgr.SetGiftStatus(v.WareId, v.Enabled)
			end
			self.activityDataMgr.SetReqGiftState(true)
		end
	end)
end

function HallViewCtr:SetLoadApplyFriendsList(err,data)
	--if self.ApplyRequestBool == true then
		if err == 0 then
			CC.DataMgrCenter.Inst():GetDataByKey("Friend").SetApplyFriendsData(data)
			self:RefreshFriendRedPoint()
		else
			logError("HallViewCtr: loadFriendData failed");
		end
	--	self.ApplyRequestBool = false
	-- end
end

function HallViewCtr:OnRefreshSwitchOn(key,switchOn)
	-- CC.uu.Log(switchOn,"OnRefreshSwitchOn-->>switchOn")
	if key == "ElephantPiggy" then --大象礼包
		self.view:DelayRun(1,function()
			self.view:ShowElephant(CC.ChannelMgr.GetSwitchByKey("bHasGift") and switchOn)
		end)
	elseif key == "FirstBuyGift" then --首冲礼包
		if switchOn then
			self:LoadFirstGift()
		else
			self.view:ShowFirstGift(false)
		end
	elseif (key == "BatteryLotteryView" or key == "NewPayGiftView") and (not switchOn) then --炮台、累充
		if self.view.effectTipTex then self.view.effectTipTex.text = self.view.initTxt end
		if key == "NewPayGiftView" then CC.Player.Inst():SetPayGiftRedState(false) end
	elseif key == "GobackRewardView" then --老玩家回归
		if switchOn then
			self:OnReqCheckOldPlayerReturn()
		else
			self:ShowHallObj("GobackBtn",false)
		end
	elseif key == "InviteLotteryView" then --邀请新老玩家抽奖
		if switchOn then
			self:OnReqFreeTimesGet()
		else
			self:ShowHallObj("FreeLotteryBtn",false)
		end
	elseif key == "AnniversaryTurntableView" then--周年庆活动
		self.view:ShowAnniversaryIcon()
	elseif key == "HalloweenView" then
		self.view:ShowLockLevelStatus()
	elseif key == "MonopolyView" then --泼水节活动
		self.view:RefreshWaterSprinklingBtnStatus()
	elseif key == "WorldCupADPageView" then --世界杯活动
		if switchOn then
			self.view:ShowWorldCupIcon()
		end
	elseif key == "BatteryLotteryView" then
		self.view:ShowWorldCupBatteryIcon()
	elseif key == "MonthRebateView" then
		self.view:RefreshBtnStatus(key)
	end
end

function HallViewCtr:LoadFirstGift()
	if not CC.ChannelMgr.GetSwitchByKey("bHasGift") or not self.activityDataMgr.GetActivityInfoByKey("FirstBuyGift").switchOn then
		self.view:ShowFirstGift(false) --首冲礼包没开请求大象礼包
		return
	end
	CC.Request("ReqTenFristGiftInfo")
end

function HallViewCtr:OnTenFristGiftInfoRsp(err,data)
	log(CC.uu.Dump(data, "OnTenFristGiftInfoRsp"))
	if err == 0 then
		local isShow = false
		if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") <= 0 or data.IsValid then
			isShow = true
			if data.PayTimes > data.CanPayTimes or (data.PayTimes >= data.CanPayTimes and data.AbleTimes <= 0) then
				isShow = false
			end
	    end
		self.view:ShowFirstGift(isShow)
	end
end

function HallViewCtr:LoadElephantExtra()
	if not CC.ChannelMgr.GetSwitchByKey("bHasGift") or not self.activityDataMgr.GetActivityInfoByKey("ElephantPiggy").switchOn then
		return
	end
	CC.Request("ReqElephantPiggy")
end

function HallViewCtr:SetElephantPiggy(err,data)
	log(CC.uu.Dump(data, "SetElephantPiggy",10))
	if err == 0 then
		local isElephantEffect = false
		if data.Info.Extra and data.Info.Extra >= 93000 then
			isElephantEffect = true
		end
		self.view:InitElephantEffect(isElephantEffect)
		self.view:ShowElephant(data.Info.Open)
	end
end

function HallViewCtr:RefreshMailRedPoint()

	if self.mailDataMgr.GetUnOpenMailCount() >0 then
		self:TurnRedPointState({key = "mail",state = true})
	else
		self:TurnRedPointState({key = "mail",state = false})
	end
end

function HallViewCtr:RefreshFriendRedPoint(param)
	self:TurnRedPointState({key = "friend",state = self.friendDataMgr.GetApplyFriendsLen() > 0})
end

function HallViewCtr:TurnRedPointState(param)
	local parent = self.HallDefine.redDotSwitch[param.key].parent
	local selfNode = self.HallDefine.redDotSwitch[param.key].node
	self.HallDefine.redDotSwitch[param.key].state = param.state
	self.view:RefreshSubRedDot({node = selfNode,state = param.state})
	for k,v in pairs(self.HallDefine.redDotSwitch) do
		if v.parent == parent and v.state then
			self.view:RefreshMainRedDot({node = self.HallDefine.redDotNode[parent],state = true})
			return
		end
	end
	self.view:RefreshMainRedDot({node = self.HallDefine.redDotNode[parent],state = false})
end

function HallViewCtr:CheckDynamicLinkInstallData()
	if CC.LocalGameData.GetLocalStateToKey("CheckFirstInstall") then return end
	CC.LocalGameData.SetLocalStateToKey("CheckFirstInstall",true);
	local data = self:GetDynamicLink();
	if not data or table.isEmpty(data) then return end;
	--通过链接进来的新用户都直接打开一级锁
	CC.Request("ReqUnlockLevel");

	if data.landPage then
		return self:CheckLandPage(data);
	end
	if data.agentId or data.applyAgent then
		self:CheckBindAgent(data)
	end
	if data.isDeepPlayer == "true" then
		CC.uu.Log("---重度玩家---")
		self.gameDataMgr.SetPlayerType("isDeepPlayer")
	elseif data.isDeepPlayer == "false" then
		self.gameDataMgr.SetPlayerType("IsFromADSource")
	end
	if data.extraData then
		self.urlExtraData = data.extraData;

		local re = Json.decode(Util.DecodeBase64(self:ReplaceLinkChar(data.extraData)))
		if re.inviteUserId then
			self:FreeLotteryInvite(re.inviteUserId)
		end
	end
	return false;
end

function HallViewCtr:CheckDynamicLinkWakeupData()
	local data = self:GetDynamicLink();
	if not data or table.isEmpty(data) then return end;
	if data.landPage then
		return self:CheckLandPage(data);
	end
	if data.extraData then
		self.urlExtraData = data.extraData;

		local re = Json.decode(Util.DecodeBase64(self:ReplaceLinkChar(data.extraData)))
		if re.inviteUserId then
			self:FreeLotteryInvite(re.inviteUserId)
		end
	end
	return false;
end

function HallViewCtr:FreeLotteryInvite(inviter)
	log(string.format("InvitePlayerID: %s      InvitedPlayerID: %s",inviter,CC.Player.Inst():GetSelfInfoByKey("Id")))
	local data = {}
	data.InvitePlayerID = inviter
	data.InvitedPlayerID = CC.Player.Inst():GetSelfInfoByKey("Id")
	data.Ime = CC.Platform.GetDeviceId()
	CC.Request("ReqFreeTimesAdd",data)
end

local supportPage = {
	StoreView = true,
	MailView = true,
	ArenaView = true,
	GameScene = true,
	GiveGiftSearchView = true,
	SelectGiftCollectionView = true,
	DailyGiftCollectionView = true,
}
function HallViewCtr:CheckLandPage(data)
	local param = data;
	if param.landPage then
		if not supportPage[param.landPage] then CC.uu.Log("not support page:"..tostring(param.landPage)) return end
		if param.landPage == "GameScene" then
			local gameId = tonumber(param.id);
			if self:CheckCanEnterGameById(gameId) and self.gameDataMgr.GetInfoByID(tonumber(gameId)) then
				self.wakeupGameId = gameId;
				CC.HallUtil.EnterGame(gameId)
			end
		elseif param.landPage == "SelectGiftCollectionView" or param.landPage == "DailyGiftCollectionView" then
			local viewId = param.id;
			CC.ViewManager.Open(param.landPage, {currentView = viewId});
		else
			CC.ViewManager.Open(param.landPage);
		end
		return true;
	end
	return false;
end

function HallViewCtr:CheckBindAgent(bindData)
	--android模拟器不能绑定高V
	if Client.IsEmulator() then return false end
	local agentId
	if bindData.agentId and CC.uu.SafeCallFunc(function() agentId = tonumber(bindData.agentId) end) then
		self.agentDataMgr.BindAgent(agentId,function (code,data)
			CC.uu.Log(data, "BindAgentSucc:");
		end, function(code, data)
			CC.uu.Log(code, "BindAgentFailed:");
		end)
	end

	if bindData.applyAgent then
		self.agentDataMgr.ApplyRootAgent(function (code,data)
			CC.uu.Log(data, "ApplyRootAgentSucc:");
		end, function(code, data)
			CC.uu.Log(code, "ApplyRootAgentFailed:");
		end)
	end

	return false
end

function HallViewCtr:CheckFacebookDeepLinkData()
	local param = Client.GetBrowserParams();
	if param == "" then return end;
	param = Json.decode(Util.DecodeBase64(self:ReplaceLinkChar(param)));
	if param and param.landPage then
		Client.ClearBrowserParams();
		return self:CheckLandPage(param);
	end
	return false;
end

function HallViewCtr:ReplaceLinkChar(data)
	--生成链接的地方替换了，这里换回来
	data = string.gsub(data,'#','=')
	return data
end

function HallViewCtr:OnUrlOpenApplicationCallback(data)

	self:CheckInvited();
end

function HallViewCtr:RefreshChatState(state)
	self.view:RefreshChat(state)
end

function HallViewCtr:RefreshChatPri(state)
	self.view:RefreshChatPri(state)
end

function HallViewCtr:SetCanClick(flag)
	self.view:SetCanClick(flag)
end

function HallViewCtr:RefreshSwitchState()
	self.view:RefreshSwitchState()
end

function HallViewCtr:GuideFirst()
	self.view:GuideShowButton()
end

function HallViewCtr:GuideGetVector(index)
	self.view:GuideGetVector(index)
end

function HallViewCtr:OnLoadUnReceiveEarn(err, data)
	log(CC.uu.Dump(data, "高级vip收益",10))
	if err == 0 then
		if data.earnFromShare > 0 or data.earnFromNewer > 0 or data.earnFromTrade > 0 then
			self.view:SetAgentBtnEffet(true)
		else
			self.view:SetAgentBtnEffet(false)
		end
	end
end

function HallViewCtr:SetAgentBtnStatus()
	if self.switchDataMgr.GetSwitchStateByKey("AgentUnlock") then
		self.view:SetAgentBtnStatus()
	end
end

function HallViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.RefreshMailRedPoint,CC.Notifications.MailAdd)
	CC.HallNotificationCenter.inst():register(self,self.RefreshMailRedPoint,CC.Notifications.MailOpen)
	CC.HallNotificationCenter.inst():register(self,self.RefreshFriendRedPoint,CC.Notifications.OnPushFriendRequest)
	CC.HallNotificationCenter.inst():register(self,self.RefreshFriendRedPoint,CC.Notifications.OnPushFriendAdded)
	CC.HallNotificationCenter.inst():register(self,self.RefreshChatState,CC.Notifications.ChatFlash)
	CC.HallNotificationCenter.inst():register(self,self.RefreshChatPri,CC.Notifications.PriChatPush)
	CC.HallNotificationCenter.inst():register(self,self.SetCanClick,CC.Notifications.GameClick)
	CC.HallNotificationCenter.inst():register(self,self.TurnRedPointState,CC.Notifications.OnRefreshRedPointState)
	CC.HallNotificationCenter.inst():register(self,self.CheckFroceUpdateVersion,CC.Notifications.OnFroceUpdateVersionChanged)
	CC.HallNotificationCenter.inst():register(self,self.OnUrlOpenApplicationCallback, CC.Notifications.OnUrlOpenApplicationCallback)


	CC.HallNotificationCenter.inst():register(self, self.SetElephantPiggy, CC.Notifications.NW_ReqElephantPiggy)
	CC.HallNotificationCenter.inst():register(self, self.SetMailData, CC.Notifications.NW_ReqMailLoadAll)
	CC.HallNotificationCenter.inst():register(self, self.SetLoadApplyFriendsList, CC.Notifications.NW_ReqLoadApplyFriendsList)
	CC.HallNotificationCenter.inst():register(self, self.SetResourceVersionInfo, CC.Notifications.NW_GetAllResourceVersionInfo)
	CC.HallNotificationCenter.inst():register(self, self.RefreshSwitchState, CC.Notifications.HallFunctionUpdate)
	CC.HallNotificationCenter.inst():register(self,self.CheckNews,CC.Notifications.VipChanged);
	CC.HallNotificationCenter.inst():register(self,self.GuideFirst,CC.Notifications.OnNotifyHallFirst);
	CC.HallNotificationCenter.inst():register(self,self.CheckGuide,CC.Notifications.OnNotifyExitSelection);
	CC.HallNotificationCenter.inst():register(self,self.GuideGetVector,CC.Notifications.OnNotifyHallPos);
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshSwitchOn,CC.Notifications.OnRefreshActivityBtnsState)

	CC.HallNotificationCenter.inst():register(self,self.OnPropChange,CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():register(self,self.LoadGiftStatus,CC.Notifications.OnTimeNotify)
	CC.HallNotificationCenter.inst():register(self,self.OnDownloadGameProgress,CC.Notifications.DownloadGame)

	CC.HallNotificationCenter.inst():register(self,self.OnLoadUnReceiveEarn,CC.Notifications.NW_LoadUnReceiveEarn)
	CC.HallNotificationCenter.inst():register(self,self.SetAgentBtnStatus,CC.Notifications.OnNewAgentStatus)

	CC.HallNotificationCenter.inst():register(self,self.OnTenFristGiftInfoRsp,CC.Notifications.NW_ReqTenFristGiftInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnTenFristGiftInfoRsp,CC.Notifications.NW_ReqTenFristGiftLottery)
	CC.HallNotificationCenter.inst():register(self,self.ReqRechargeInfoResp,CC.Notifications.NW_ReqRechargeInfo)
	CC.HallNotificationCenter.inst():register(self,self.ReqCommonBatteryInfoHall,CC.Notifications.NW_ReqCommonBatteryInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnResqGetWhiteAccount,CC.Notifications.NW_ReqGetWhiteAccount)
	CC.HallNotificationCenter.inst():register(self,self.OnResqStockChangedTime,CC.Notifications.NW_ReqStockChangedTime)
	CC.HallNotificationCenter.inst():register(self,self.OnRespSubscribeList,CC.Notifications.NW_ReqSubscribeList)
	CC.HallNotificationCenter.inst():register(self,self.OnReqFreeTimesGetResp,CC.Notifications.NW_ReqFreeTimesGet)
	CC.HallNotificationCenter.inst():register(self,self.OnReqLoadOldPlayerReturnStatusResp,CC.Notifications.NW_ReqLoadOldPlayerReturnStatus)

	CC.HallNotificationCenter.inst():register(self, self.OnPushLuckyRoulette, CC.Notifications.OnPushLuckyRoulette)
	CC.HallNotificationCenter.inst():register(self, self.OnReqSafeDataRsp, CC.Notifications.NW_ReqSafeData)
	CC.HallNotificationCenter.inst():register(self, self.OnGetAppRateInfoRsp, CC.Notifications.NW_ReqGetAppRateInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnGoogleOrderListRsp,CC.Notifications.NW_ReqGetGoogleVerifyingOrder)
end

function HallViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function HallViewCtr:OnResqStockChangedTime(err,data)
	if err == 0 then
		local oldTime = CC.LocalGameData.GetDataByKey("StockTime",CC.Player.Inst():GetSelfInfoByKey("Id")) or 0
		self.stockTime = data.ChangedTime
		if oldTime ~= data.ChangedTime then
			self.view:ShowTreasureTip(true)
		end
	end
end

function HallViewCtr:OnPropChange(props, source)
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_Mod_Name_Card and v.Delta and v.Delta> 0 then
			self.RenameCardState = true
		end
		-- if v.ConfigId == CC.shared_enums_pb.EPC_LockLevel and v.Delta and v.Delta > 0 then
        --     self:SetAgentBtnStatus()
		-- 	self.view:ShowLockLevelStatus()
		-- end
		if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
			self.view:ChipChange()
		end
		if v.ConfigId == CC.shared_enums_pb.EPC_Merits then
			self.view:RefreshDonateRedDot()
		end
	end

end

function HallViewCtr:Destroy()
	self:unRegisterEvent()
	if self.guideView then
		self.guideView:Destroy()
	end
end

function HallViewCtr:EnterLot()
	if CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLotAddress() then
		CC.ViewManager.Open("LotteryView",{serverIp = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLotAddress()})
	else
        local data = {}
        data.GameId=4001
        data.GroupId=1
        CC.Request("ReqAllocServer",data,function (err,data)
			CC.ViewManager.Open("LotteryView",{serverIp = data.Address})
		end,
		function (err,data)
			logError("EnterLot Fail")
		end)
	end
end

function HallViewCtr:CheckNeedToGoGame()
	-- 有新手引导则不操作
    if self.guideView then
        return
	end

    local needToGoGameId = CC.ViewManager.GetNeedToGoGameId()
	if needToGoGameId then
		CC.ViewManager.SetNeedToGoGameId(nil)

		if self:CheckCanEnterGameById(needToGoGameId) then
			CC.HallUtil.CheckAndEnter(needToGoGameId)
		end
    end
end

function HallViewCtr:CheckCanEnterGameById(gameId)
	local vipLimit = self.gameDataMgr.GetVipUnlockByID(gameId)
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < vipLimit then
		local language = self.view.language;
		CC.ViewManager.ShowMessageBox(string.format(language.enterGame_tip,vipLimit),
			function ()
				if CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
					CC.ViewManager.OpenEx("SelectGiftCollectionView")
				else
					CC.ViewManager.Open("StoreView")
				end
			end)
		return false
	end
	return true
end

function HallViewCtr:OnDownloadGameProgress(data)
	if data.gameID ~= self.wakeupGameId then
		self.wakeupGameId = nil;
		return
	end;
	if not data.isFinish then return end;
	self.wakeupGameId = nil;
	local curView = CC.ViewManager.GetCurrentView();
	if curView.viewName ~= "HallView" then return end;
	CC.HallUtil.EnterGame(data.gameID)
end

function HallViewCtr:ReqGetRechargeActivity()
	if not self.activityDataMgr.GetActivityInfoByKey("NewPayGiftView").switchOn then
		return
	end
	CC.Request("ReqRechargeInfo")
end

function HallViewCtr:ReqRechargeInfoResp(err,data)
	if err == 0  then
		if not self.view.effectTipTex then return end
		local lan = CC.LanguageManager.GetLanguage("L_NewPayGiftView")
		local PayTar = self.HallDefine.Recharge[CC.ChannelMgr.CheckOppoChannel() and 2 or 1]
		for i,v in ipairs(data.InfoList) do
			if not v.IsOpen and data.RechargeNum >= PayTar[i] then
				self.view.effectTipTex.text = lan.Lottery
				CC.Player.Inst():SetPayGiftRedState(true)
				return
			end
		end
		self.view.effectTipTex.text = self.view.initTxt
		CC.Player.Inst():SetPayGiftRedState(false)
	end
end

function HallViewCtr:ReqGetBatteryLotteryInfo()
	if not self.activityDataMgr.GetActivityInfoByKey("BatteryLotteryView").switchOn then
		return
	end
	CC.Request("ReqCommonBatteryInfo")
end

function HallViewCtr:ReqCommonBatteryInfoHall(err,data)
	if not self.view.effectTipTex then return end
	if err == 0 then
		if data.LastDay then
			local lan = CC.LanguageManager.GetLanguage("L_BatteryLotteryView")
			self.view.effectTipTex.text = lan.CompoundSprint
		end
	end
end

--超v白名单
function HallViewCtr:ReqGetWhiteAccount()
	CC.Request("ReqGetWhiteAccount")
end

function HallViewCtr:OnResqGetWhiteAccount(err, data)
	log("err = ".. err.."  "..CC.uu.Dump(data,"OnResqGetWhiteAccount",10))
	if err == 0 then
		self.GiftDataMgr:SetSuperWhiteAccount(data)
	end
end

function HallViewCtr:OnRespSubscribeList(err,data)
	if err == 0 then
		CC.DataMgrCenter.Inst():GetDataByKey("Game").SetSubscribeList(data)
	end
end

function HallViewCtr:OnReqFreeTimesGet()
	if not self.activityDataMgr.GetActivityInfoByKey("InviteLotteryView").switchOn then
		return
	end
	CC.Request("ReqFreeTimesGet",{PlayerID = CC.Player.Inst():GetSelfInfoByKey("Id")})
end

function HallViewCtr:OnReqFreeTimesGetResp(err,data)
	--log("err = ".. err.."  OnReqFreeTimesGetResp:\n"..tostring(data))
	--self:ShowHallObj("FreeLotteryBtn",true)
	if err == 0 then
		if data.OldTimes > 0 or data.NewTimes > 0 then
			self:ShowHallObj("FreeLotteryRedDot",true) --有抽奖次数打开红点
			CC.Player.Inst():SetFreeLotRedState(true)
		else
			CC.Player.Inst():SetFreeLotRedState(false)
		end
    end
end

function HallViewCtr:OnReqCheckOldPlayerReturn()
	if not self.activityDataMgr.GetActivityInfoByKey("GobackRewardView").switchOn then
		return
	end
	CC.Request("ReqLoadOldPlayerReturnStatus")
end

function HallViewCtr:OnReqLoadOldPlayerReturnStatusResp(err,data)
	log(string.format("err: %s     OnReqLoadOldPlayerReturnStatusResp: %s",err,tostring(data)))
	if err == 0 and data.RewardFlag and data.EndStamp and data.EndStamp > 0 then
		local unclaimed = false
		local showRed = false
		for i = 1,7 do --i 代表任务id
			local receive = bit.band(data.RewardFlag,bit.lshift(1,i)) == 0 --等于0是未领取
			if i == 6 then
				--次日登录的任务这里特殊处理下，玩家第二天没有登录，任务就没完成，奖励还是未领取状态，这里设置为已领取，不显示礼包入口了
				if data.EndStamp < 86400*5 and not string.find(data.TaskComplete,tostring(6)) then
					receive = false
				end
			end
			if receive and not unclaimed then unclaimed = true end

            if i ~= 4 and i ~= 5 and not showRed and receive and string.find(data.TaskComplete,tostring(i)) then
				showRed = true
            end
        end
		self:ShowHallObj("GobackRedDot",showRed) --红点
		self:ShowHallObj("GobackBtn",data.EndStamp > 0 and unclaimed) --按钮

		--第一次打开、在活动时间内、还有奖励未领取，满足以上条件才自动弹出回归礼包
		if CC.LocalGameData.GetLocalDataToKey("GobackRewardGobackReward", CC.Player.Inst():GetSelfInfoByKey("Id")) and data.EndStamp > 0 and unclaimed then
			if not CC.ViewManager.IsHallScene() then return end

			if self.view.hideHallPanel then
				self.view:GuideShowButton()
			end
			CC.ViewManager.OpenEx("GobackRewardView",{data = data})
		end
    end
end

function HallViewCtr:OnPushLuckyRoulette(data)
	if not self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") then return end
	if data then
		if data.BigReward == 1 then
			--CC.uu.Log(data,"Anni Marquee",1)
			--大厅右侧弹出提示框
			local language = CC.LanguageManager.GetLanguage("L_AnniversaryTurntableView")
			local propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
			local tipText = string.format(language["Marquee0"],data.Nickname,propLanguage[data.RewardId],data.RewardNum)
			local param = {}
			param.type = 6
			param.Props = {ConfigId = data.RewardId, Count = data.RewardNum}
			param.title = language.title
			param.des = tipText
			param.showTime = 6
			param.Player = {playerId = data.PlayerId, portrait = data.Portrait, headFrame = data.Background, vipLevel = data.Level}
			param.openView = "AnniversaryTurntableView"
			CC.ViewManager.ShowRewardNoticeView(param)

			--聊天
			local chatdata = {}
			chatdata.Who = {}
			chatdata.Message = tipText
			chatdata.MessageType = CC.ChatConfig.CHATTYPE.REWARDS
			CC.ChatManager.OnRcvSystemMsg(chatdata)
			CC.HallNotificationCenter.inst():post(CC.Notifications.ChatFlash,true)
		end
	end
end

function HallViewCtr:OnReqSafeDataRsp(err,data)
	log(string.format("err: %s    OnReqSafeDataRsp: %s",err,tostring(data)))
	if err == 0 then
		CC.Player.Inst():SetSafeCodeData(data)
	elseif err == CC.NetworkHelper.DelayErrCode then
		--请求超时继续请求
		CC.Request("ReqSafeData",{IMei = CC.Platform.GetDeviceId()})
	end
end

function HallViewCtr:ShowHallObj(key,show)
	if not self.view[key] then
		logError("不存在的key")
		return
	end
	self.view[key]:SetActive(show)
end

function HallViewCtr:CheckStarRating()
	if AppInfo.ChannelID == "20003" then return end
	if CC.LocalGameData.GetLocalDataToKey("StarRatingView", CC.Player.Inst():GetSelfInfoByKey("Id")) 
		and CC.LocalGameData.GetLocalDataToKey("StarRatingReward", CC.Player.Inst():GetSelfInfoByKey("Id")) then
		CC.Request("ReqGetAppRateInfo")
	end
end

function HallViewCtr:OnGetAppRateInfoRsp(err,data)
	if err ~= 0 then
		logError("ReqGetAppRateInfo err:"..err)
		return
	end
	CC.uu.Log(data,"Rate Info:",1)
	
	if data.HasRewarded then
		CC.LocalGameData.SetLocalDataToKey("StarRatingReward", CC.Player.Inst():GetSelfInfoByKey("Id"))
	else
		if data.ConditionPassed then
			local reward = data.Reward[1]
			CC.ViewManager.Open("StarRatingView",{reward = reward.Count})
		end
	end
end

function HallViewCtr:CheckGoogleOrderList()
	CC.Request("ReqGetGoogleVerifyingOrder")
end

function HallViewCtr:OnGoogleOrderListRsp(err,data)
	if err ~= 0 then
		logError("CheckGoogleOrderList err:"..err)
		return
	end
	CC.uu.Log(data,"CheckGoogleOrderList",1)
	if #data.ProductIds <= 0 then return end
	CC.GooglePlayIABPlugin.DealWithNotConsumedOrders(data.ProductIds)
end

--ViVo前往谷歌商店官方包
function HallViewCtr:VivoToGoogleMarket()

	if not CC.ChannelMgr.CheckVivoChannel() then
		return
	end
	
	local language = self.view.language
	local param = {}
	param.str = language.updateMsg
	param.btnOkText = language.btnGo
	param.btnNoText = language.btnCancel
	param.okFunc = function()
		local marketUrl = "market://details?id=com.huoys.royalcasinoonline"
		Client.GotoAPPStore(marketUrl)
	end
	CC.ViewManager.MessageBoxExtend(param)
end

return HallViewCtr
