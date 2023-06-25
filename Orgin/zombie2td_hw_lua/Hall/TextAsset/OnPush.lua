
local CC = require("CC")

local OnPush = {}

function OnPush.OnFriendApplied(data)
	log("收到好友申请！")
    local friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend")
	friendDataMgr.SetNewApplyFriendsData(data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushFriendRequest)
end

function OnPush.OnPropChanged(data)
	CC.uu.Log(data, "道具修改推送:");
	CC.Player.Inst():ChangeProp(data);
end

function OnPush.OnMailComming(data)
	log("收到邮件！")
	--新邮件id推送
	CC.DataMgrCenter.Inst():GetDataByKey("Mail").AddMailId(data);

	CC.HallNotificationCenter.inst():post(CC.Notifications.MailAdd);
end

function OnPush.OnInviteNotification(data)
	if CC.ChannelMgr.GetTrailStatus() then return end
	log("收到邀请")
	if CC.ViewManager.IsHallScene() then
		local invitationCB = function  ()
			OnPush.invitationTip = nil
		end
		if not OnPush.invitationTip then
			OnPush.invitationTip = CC.ViewManager.Open("InvitationTip",data,invitationCB)
		end
	end
end

function OnPush.OnChat(data)
	if data.Message and #data.Message > 0 then
		if not CC.ChannelMgr.GetTrailStatus() then
			if data.MessageType == CC.ChatConfig.CHATTYPE.GAMESYSTEM then
				CC.ChatManager.OnGameSystemMsg(data)
			elseif data.MessageType == CC.ChatConfig.CHATTYPE.ACTIVITY_NORMAL then
				CC.ChatManager.OnRcvSystemMsg(data)
			elseif data.MessageType == CC.ChatConfig.CHATTYPE.ACTIVITY_TIMER then
				CC.ChatManager.OnRcvSystemMsg(data)
			elseif CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("PhysicalLock") and data.MessageType == CC.ChatConfig.CHATTYPE.SYSTEM then
				CC.ChatManager.OnRcvSystemMsg(data)
			elseif CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("PhysicalLock") and data.MessageType == CC.ChatConfig.CHATTYPE.IMMEDIATELY then
				CC.ChatManager.OnRcvSystemMsg(data)
			end
		end
		if data.MessageType == CC.ChatConfig.CHATTYPE.Gold then
			CC.ChatManager.OnRcvWordMsg(data)
		elseif data.MessageType == CC.ChatConfig.CHATTYPE.HORN then
			CC.ChatManager.OnRcvSpeakMsg(data)
		end
	end
	if data.PlayerId ~= CC.Player.Inst():GetSelfInfoByKey("Id") then
		CC.HallNotificationCenter.inst():post(CC.Notifications.ChatFlash,true)
	end
end

function OnPush.OnChatData(data)
	if CC.LocalGameData.GetPrivateToggle() then return end
	CC.ChatManager.OnRcvPriChat(data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.ChatFlash,true)
	CC.HallNotificationCenter.inst():post(CC.Notifications.PriChatPush,true)
end

function OnPush.OnJackpots(data)
	CC.Player.Inst():SetJackpots(data.Items)
end

function OnPush.OnPayMent(data)
	log("接收到救济金的推送")
	CC.ViewManager.Open("BenefitsView", data);
end

function OnPush.OnFristPay(data)
	CC.Player.Inst():SetFristPayState(data.state)
end

function OnPush.OnPurchaseNotify(data)
	log("充值成功,wareId:"..tostring(data.WareId))
	local language = CC.LanguageManager.GetLanguage("L_StoreView");
	CC.ViewManager.ShowTip(language.paySuccess);
	if CC.Platform.isAndroid or CC.Platform.isIOS then
		local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");
		local wareData = wareCfg[data.WareId];

		if wareData then
			--if wareData.SubChannel == "GooglePay" then
				--CC.GooglePlayIABPlugin.Consume(wareData.ProductId)
			--end
			if wareData.Currency == CC.shared_enums_pb.PCT_Money then
				CC.AppsFlyerPlugin.TrackInAppPurchase(wareData.Price/100, 1, wareData.CommodityType)
				CC.FacebookPlugin.TrackInAppPurchase(wareData.Price/100, 1, wareData.CommodityType)
				CC.FirebasePlugin.TrackInAppPurchase(wareData.Price/100, 1, wareData.CommodityType)
			end
			if wareData.IsGift then
				CC.FirebasePlugin.TrackGiftPurchase(wareData);
			end
		end
	end

	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPurchaseNotify, data);

	if CC.Player.Inst():GetSelfInfoByKey("EPC_TotalRecharge") <= 0 then
		--首次充值
		if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") <= 0 then
			CC.ViewManager.Open("VipUpgradeView")
		end
	end
end

function OnPush.OnSevenDays(data)
	if data.Day == 1 then
		if data.State == 1 then
			CC.Player.Inst():SetSevenDays(data)
			CC.Player.Inst():OpenSevenDaysView()
		else
			CC.Player.Inst():SetSevenDays(data)
		end
	else
		CC.Player.Inst():SetSevenDays(data)
	end
end

function OnPush.OnFriendAdded(data)
    log(CC.uu.Dump(data,"FriendAdded =",10))
	local friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend")
	friendDataMgr.SetNewFriendListData(data)
	friendDataMgr.DeleteApplyFriendsByPlayerId(data.FriendInfo.PlayerId)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushFriendAdded)
end

function OnPush.OnFriendOffline(data)
	log(CC.uu.Dump(data,"Offline =",11))
	local friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend")
	friendDataMgr.SetFriendsList_IsOnline(data.PlayerId,false)
	--CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushFriendIsLine)
end

function OnPush.OnFriendOnline(data)
	log(CC.uu.Dump(data,"Online =",11))
	local friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend")
	friendDataMgr.SetFriendsList_IsOnline(data.PlayerId,true)
	--CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushFriendIsLine)
end

function OnPush.OnFriendDeleted(data)
	log(CC.uu.Dump(data,"OnFriendDeleted =",11))
	local friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend")
	friendDataMgr.SetDeletePersonData(data.PlayerId)
end

function OnPush.OnKickedPlayer(data)
	local language = CC.LanguageManager.GetLanguage("L_Common");
	--踢回登录界面，如果在登录界面大厅不处理
	if CC.ViewManager.IsHallScene() and CC.ViewManager.GetCurrentView().viewName ~= "LoginView" then
		if data.Type == CC.shared_enums_pb.KT_ReplaceACC then
			CC.ViewManager.ShowTip(language.kick_ReplaceACC)
		elseif data.Type == CC.shared_enums_pb.KT_Web then
			CC.ViewManager.ShowTip(language.kick_KT_Web)
		elseif data.Type == CC.shared_enums_pb.KT_CloseAcc then
			CC.ViewManager.ShowTip(language.kick_CloseAcc)
		elseif data.Type == CC.shared_enums_pb.KT_Game then
			CC.ViewManager.ShowTip(language.kick_KT_Game)
		end
		CC.ViewManager.BackToLogin(CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.Kickedout);
	end
	local cb = function()
		CC.SubGameInterface.KickedOutTip();
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushKickedOut, data.Type, cb);
end

function OnPush.OnResourceVersonChanged(data)

	CC.HallNotificationCenter.inst():post(CC.Notifications.OnFroceUpdateVersionChanged, data);
end

function OnPush.OnOnlineRewardStatusChanged()
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnlineRewardStatusChanged);
end

--推送泼水节信息
function OnPush.OnPushSplashInfo(data)
	--log(CC.uu.Dump(data,"OnPushSplashInfo =",10))
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushSplashInfo,data.Info);
end

function OnPush.OnNotifyPlayerIntoGame(param)
	if CC.ChannelMgr.GetTrailStatus() then return end
	--登录界面不弹窗
	local view = CC.ViewManager.GetCurrentView();
	if view and view.viewName == "LoginView" then return end;
	local data = param.NotifyInfo
	local language = CC.LanguageManager.GetLanguage("L_Tip");
	local matchType = Json.decode(data.ExtraMsg)
	local message = nil
	if matchType.tip then
		message = matchType.tip
	else
		message = language["match_"..data.GameId.."_"..matchType.ServerType]
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnNotifyPlayerIntoGame,data.GameId)
	if CC.ViewManager.IsHallScene() then
		local callback = function ()
			local param = {}
			param.GameId = data.GameId
			param.RoomId = data.GroupId
			param.ExtraMsg = data.ExtraMsg
			param.gameData =  CC.DataMgrCenter.Inst():GetDataByKey("Game").GetInfoByID(data.GameId)
			CC.uu.Log(param, " EnterGameParam:")
			CC.HallUtil.CheckAndEnter(data.GameId,param)
		end

		local tip = CC.ViewManager.ShowTip(message,15,callback)
		tip:SetOneButton()
		tip:SetButtonText(language.button)
	else
		CC.ViewManager.ShowTip(message,5)
	end
end

function OnPush.OnPushSupplyLucky()
	CC.DataMgrCenter.Inst():GetDataByKey("ShakeData").SetExistState(true)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnpushShake)
	-- local function func()
--        print("xxxxxxxxxx")
--    end
	--  CC.ViewManager.OpenAndReplace("ShakeView",1005,func)
end

function OnPush.OnPhysicalGoodsInfo(data)
	-- CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData").RefreshGoodsInfo(data)
	-- CC.HallNotificationCenter.inst():post(CC.Notifications.RefreshPhysicalGoodsInfo)
end

function OnPush.OnPhysicalGoodsBuyInfo(data)
	CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData").AddAllBuyGoodsInfo(data)
end

function OnPush.OnPushMsignRollRank(data)
	log(CC.uu.Dump(data,"OnPushMsignRollRank =",10))
	CC.DataMgrCenter.Inst():GetDataByKey("SignData").SetRollItemData(data)
end

function OnPush.OnPushChipReplenish(data)
	CC.uu.Log(data,"OnPushChipReplenish:")
	CC.Player.Inst():SetChipReplenish(data)
end

function OnPush.OnPushTradeRankChanged(data)
	CC.uu.Log(data,"OnPushTradeRankChanged:")
	CC.ChatManager.SetSendRanks(data)
end

function OnPush.OnDailySpinChanged(data)

	CC.HallNotificationCenter.inst():post(CC.Notifications.DailySpinChanged, data)
end

function OnPush.OnSpecialDailySpinChanged(data)

	CC.HallNotificationCenter.inst():post(CC.Notifications.SpecialDailySpinChanged, data)
end

function OnPush.OnPushOnlineWelfare(param)
	log(CC.uu.Dump(param,"OnPushOnlineWelfare",10))
	local data = {};
	data.switchOn = param.Show
	data.redDot = param.Show and param.Open
	CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetActivityInfoByKey("OnlineLottery", data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.PushOnlineWelfare, param)
end

function OnPush.OnPushOnlineWelfareShow(param)
	log(CC.uu.Dump(param,"OnPushOnlineWelfareShow",10))
	local data = {};
	if param and param.Show~=nil then
		data.switchOn = param.Show
		data.redDot = param.Show
	else
		data.switchOn = true
		data.redDot = true
	end
	CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetActivityInfoByKey("OnlineLottery", data)
end

function OnPush.OnPushOnlineWelfarePre(param)
	log(CC.uu.Dump(param,"OnPushOnlineWelfarePre",10))
	local OnlineWelfareDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("OnlineWelfareDataMgr")
	local Props = {}
	Props.ConfigId = OnlineWelfareDataMgr.GetMyBigRewardConfigId()
	Props.Count = 1
	local time
	if param and param.Seconds then
		time = param.Seconds
	end
	CC.ViewManager.ShowRewardNoticeView({type=0,Props=Props,time=time})
end

function OnPush.OnPushOnlineWelfareReward(data)
	log(CC.uu.Dump(data,"OnPushOnlineWelfareReward",10))
	local Props = data.Props
	CC.ViewManager.ShowRewardNoticeView({type=2,Props=Props})
end

function OnPush.OnPushOnlineWelfareBigReward(data)
	log(CC.uu.Dump(data,"OnPushOnlineWelfareBigReward",10))
	local Props = data.Props
	local PlayerId = data.PlayerId
	local Name = data.Name
	CC.ViewManager.ShowRewardNoticeView({type=1,Props=Props,name=Name})
end

function OnPush.OnPushAugGiftPayPopBigReward(data)
	log(CC.uu.Dump(data,"OnPushAugGiftPayPopBigReward",10))
	local param = {}
	param.type = 5
	param.Props = data.Props
	param.name = data.Name
	param.showTime = 6
	param.openView = "DailyGiftCollectionView"
	param.currentView = "HolidayDiscountsView"
	CC.ViewManager.ShowRewardNoticeView(param)
end

function OnPush.OnInvitePlayerIntoGame(data)
	if CC.ChannelMgr.GetTrailStatus() then return end
	--登录界面不弹窗
	local view = CC.ViewManager.GetCurrentView();
	if view and view.viewName == "LoginView" then return end;
	local data = data.InviteInfo;
	local language = CC.LanguageManager.GetLanguage("L_Tip");
	local gameName = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetProNameByID(data.GameId)
	local param = {}
	param.GameId = data.GameId
	param.RoomId = data.GroupId
	param.inviteData = {}
	param.inviteData.extraMsg = data.ExtraMsg
	param.inviteData.roomNo = data.RoomNo
	param.inviteData.invitor = data.Invitor
	param.inviteData.invitee = data.Invitee
	param.gameData =  CC.DataMgrCenter.Inst():GetDataByKey("Game").GetInfoByID(data.GameId)
	if CC.ViewManager.IsHallScene() then
		local callback = function ()
			CC.HallUtil.CheckAndEnter(data.GameId,param)
		end
		local tip = CC.ViewManager.ShowTip(string.format(language["invite_"..data.GameId], data.Invitor.Nick, data.RoomNo),30,callback)
		tip:SetOneButton()
		tip:SetButtonText(language.button)
	else
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnNotifyGameInvited, param)
	end
end

function OnPush.OnPushActivityInfo(data)
	log(CC.uu.Dump(data,"OnPushActivityInfo =",10))
	CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetInfo( data )
end

function OnPush.OnPushGameArena( data )
	log(CC.uu.Dump(data,"OnPushGameArena",10))
	CC.DataMgrCenter.Inst():GetDataByKey("ArenaData").HandleArenaData(data)
end

function OnPush.OnPushTransferGameMessage(data)

	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushTransferGameMessage,data)
end

function OnPush.OnPushWaterLampWish(data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnUpdateWaterLampWishDataInfo, data)
end

function OnPush.OnPushSuperTreasureOpenPrize(data)
	if not data.Remain then
		local NickName = data.LuckyPlayer.NickName
		local language = CC.LanguageManager.GetLanguage("L_SuperTreasureView")
		local param = {}
		param.type = 5
		param.Props = {ConfigId = data.LuckyPlayer.PropID,Count = data.LuckyPlayer.PropCount}
		param.des = string.format(language.pushText,NickName)
		param.showTime = 6
		param.openView = "ActivityCollectionView"
	    param.currentView = "SuperTreasureView"
		CC.ViewManager.ShowRewardNoticeView(param)
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushSuperTreasureOpenPrize, data)
end

function OnPush.OnPushTreasureOpenPrize(data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushTreasureOpenPrize, data)
end

function OnPush.OnPushLoadNews(data)
	log(CC.uu.Dump(data,"LoadNews =",11))
	local giftDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("GiftData")
	giftDataMgr:SetReInformation(data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshLoadNews)
end

function OnPush.OnPushClearNew(data)
	log(CC.uu.Dump(data,"ClearNew =",11))
	local giftDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("GiftData")
	giftDataMgr:ClearNewInformation(data.PlayerID)
end

function OnPush.OnPushHallFunctionUpdate(data)
	if data.ExtraData == "Switch" then
		CC.WebUrlManager.ReqSwitchInfo();
	elseif data.ExtraData == "GameChargeConfig" then
		CC.WebUrlManager.ReqStoreInfo();
	else
		CC.uu.Log(data,"web配置修改推送参数错误",3)
	end
end

function OnPush.OnPushBlessAwardMessage(data)
	CC.DataMgrCenter.Inst():GetDataByKey("BlessData").InsertBlessData(data.Message);
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushBlessAwardMsg)
end

function OnPush.OnPushMysteryElephantPiggy(data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.MysteryElephantPiggy, data)
end

function OnPush.OnPushLuckySpinReward(data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.LuckySpinRecord, data)
end

function OnPush.OnPushLuckySpinRewardMsg(data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.LuckySpinRewardMsg, data)
end

function OnPush.OnPushLuckySpinRecord(data)
	-- log(CC.uu.Dump(data,"OnPushLuckySpinRecord =",11))
	local activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	activityDataMgr.SetLuckyRollData(data)
end

-- 小厅
function OnPush.OnPushMiniNotification(data)
	-- log(CC.uu.Dump(data))
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushMiniNotification, data)

end

function OnPush.OnTwistEggReward(data)
	CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData").InsertEggRecord(data)
end

function OnPush.OnPushDailyTreasureReward(data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.TreasureReward, data)
end

function OnPush.OnPushDailyGiftRewards(data)
	CC.uu.Log(data,"==============>OnPushDailyGiftRewards",3)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnDailyGiftGameReward, data)
end

-- 文字滚动播报
function OnPush.OnPushActivityMsg(data)
	log(CC.uu.Dump(data,"OnPushActivityMsg =",11))
	if data.ActivityId == CC.shared_enums_pb.AE_TaskNotify then
		local msg = Json.decode(data.Msg)
		if msg.TaskID then
			local language = CC.LanguageManager.GetLanguage("L_NewbieTaskView");
			local num = math.floor(msg.TaskID / 1000)
			local count = msg.TaskID % 1000
			if num > 7 and num < 13 then return end
			local numName = string.format("taskName%s", num)
			local taskName = language[numName]
			if num == 6 and count then
				--比赛任务
				if count == 3 then
					count = 2
				elseif count > 3 then
					count = count - 2
				end
			end
			if num == 6 then
				taskName = string.format(taskName, count)
			end
			local tip = CC.ViewManager.ShowTip(taskName, 3)
			tip:SetFulfillIcon()
			if num > 12 then
				--新加任务完成刷新界面
				CC.Request("ReqTaskListInfo")
			end
		end
	else
		local DailyLotteryDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("DailyLotteryDataMgr")
		DailyLotteryDataMgr.InsertScrollData(data.Msg)
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushActivityMsg, data)
end

function OnPush.OnNewPlayerSignBigRewardPush(data)
	--签到大奖
	CC.DataMgrCenter.Inst():GetDataByKey("SignActivityDataMgr").AddNoviceSignAwardInfo(data)
end

function OnPush.OnPushTimeNotify(data)
	CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetReqGiftState(false)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnTimeNotify, data)
end

function OnPush.OnPushDailyGiftSignBigReward(data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnGiftSignInBigReward, data)
end

function OnPush.OnPushAgentAttrNotify(data)
	--[[
	message AgentAttrNotify{
		optional int64 PlayerId = 1;
		optional string ExtraData = 2;
	}
	]]
	if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("AgentUnlock") then return end
	local jsonData = nil
	if data.ExtraData and data.ExtraData ~= "" and CC.uu.SafeCallFunc(function() jsonData = Json.decode(data.ExtraData) end) then
		if jsonData and jsonData.notifyType then
			local isForbiddenAgent = jsonData.notifyType == 7
			CC.DataMgrCenter.Inst():GetDataByKey("Agent").SetAgentSatus({isAgent = 1, IsForbiddenAgent = isForbiddenAgent})
			-- CC.DataMgrCenter.Inst():GetDataByKey("Agent").SetAgentSatus({true, isForbiddenAgent = isForbiddenAgent})
		end
	end
end

function OnPush.OnPushTeamNotify(data)
	if data.Type == CC.shared_enums_pb.TNT_Invite then
		-- 暂时只有dummy有这个功能，所以写死gameId
		local gameId = 2003
		local language = CC.LanguageManager.GetLanguage("L_InviteTip")
		local str = string.format(language.DummyGame, data.WhoNick)
		CC.ViewManager.ShowInviteTip(str, 5, data.TeamId, gameId)
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushTeamNotify, data)
end

function OnPush.OnAugGiftPayRewardRecord(data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnAugGiftPayRewardRecordPush, data)
end

function OnPush.OnPushTenFristGiftBigReward(data)
	log(CC.uu.Dump(data, "OnPushTenFristGiftBigReward",10))
	local EPC_Level = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	local Result = EPC_Level >= 0 and EPC_Level <= 5 and CC.Player.Inst():GetFirstGiftState()
	if not Result or data.data.PlayerId == CC.Player.Inst():GetSelfInfoByKey("Id") then
		return
	end
	for i,v in ipairs(data.data.Rewards) do
		local language = CC.LanguageManager.GetLanguage("L_FirstBuyGiftView")
		local param = {}
		param.type = 5
		param.Props = {ConfigId = v.ConfigId,Count = v.Count}
		local tex = language.BigReward
		if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa or v.ConfigId == CC.shared_enums_pb.EPC_PointCard_Fragment then
			tex = language.BigReward..v.Count
		end
		param.des = string.format(tex,data.data.Name)
		param.showTime = 6
		param.openView = "FirstBuyGiftView"
		CC.ViewManager.ShowRewardNoticeView(param)
	end
end

function OnPush.OnPushCatBatteryRecord(data)
	if data then
		if data.PlayerId ~= CC.Player.Inst():GetSelfInfoByKey("Id") then
			local language = CC.LanguageManager.GetLanguage("L_FortuneCatView")
			local param = {}
			param.type = 5
			param.Props = data.Rewards[1]
			param.des = string.format(language.GetBattery,data.Name,"\n")
			param.showTime = 6
			param.openView = "SelectGiftCollectionView"
	        param.currentView = "FortuneCatView"
			CC.ViewManager.ShowRewardNoticeView(param)
		end
		CC.HallNotificationCenter.inst():post(CC.Notifications.PushCatBatteryRecord, data)
	end
end

function OnPush.OnPushCommonBatteryRecord(data)
	if data then
		if data.PlayerId ~= CC.Player.Inst():GetSelfInfoByKey("Id") then
			local language = CC.LanguageManager.GetLanguage("L_BatteryLotteryView")
			local param = {}
			param.type = 5
			param.Props = data.Rewards[1]
			param.des = string.format(language.BroadCast,data.Name,"\n")
			param.showTime = 6
			param.openView = "SelectGiftCollectionView"
	        param.currentView = "BatteryLotteryView"
			CC.ViewManager.ShowRewardNoticeView(param)
		end
		CC.HallNotificationCenter.inst():post(CC.Notifications.PushCommonBatteryRecord, data)
	end
end

function OnPush.OnCombineEggReward(data)
	--扭蛋只显示所有建立排行榜，暂时不用
end

function OnPush.OnCombineEggMarquee(data)
	--排行榜每次打开都拉取，推送可以不处理了
	-- CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData").InsertCombineEggMarquee(data)
end

function OnPush.OnPushInGameInfo(data)
	CC.uu.Log(data,"游戏进入推送：",3)
	if data.PlayerID == CC.Player.Inst():GetSelfInfoByKey("Id") then
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushInGameInfo, data)
	end
end

--周年庆幸运转盘跑马灯
function OnPush.OnPushLuckyRoulette(data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushLuckyRoulette, data)
end

function OnPush.OnPushSafePlayerFreeze()
	log("收到服务器推送，重新请求安全码状态")
	
	CC.Request("ReqSafeData",{IMei = CC.Platform.GetDeviceId()},function() end,function(err)
		if err == CC.NetworkHelper.DelayErrCode then
            CC.Request("ReqSafeData",{IMei = CC.Platform.GetDeviceId()}) 
        end
	end)
end

function OnPush.OnPushGoogleUnconsume(data)
	CC.uu.Log(data,"OnPushGoogleUnconsume",1)
	if #data.ProductIds <= 0 then return end
	CC.GooglePlayIABPlugin.DealWithNotConsumedOrders(data.ProductIds)
end

return OnPush