
local CC = require("CC")

local BlessLotteryViewCtr = CC.class2("BlessLotteryViewCtr")

function BlessLotteryViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function BlessLotteryViewCtr:OnCreate()
	self:RegisterEvent();

	-- self:ReqAwardMessage();
	self.activityDataMgr.SetActivityInfoByKey("BlessLotteryView", {redDot = false});

	self:Req_UW_PLotteryData()
	self:Req_UW_PLotteryRank()
	self:Req_UW_PLotteryWinPrize()
end

function BlessLotteryViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;

	self.blessAction = nil;

	self.rewardData = nil;

	self.language = self.view:GetLanguage();

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");

	self.blessDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("BlessData");

	self.lotterying = false;

	self.itemIndex = 1;

	self.realAwardCfg = {
		CC.shared_enums_pb.EPC_Props_20103,
		CC.shared_enums_pb.EPC_150Card,
		CC.shared_enums_pb.EPC_500Card,
	}
	self.blessProp = false
	self.dropDownList = {1,10,30,50,100}
	self.taskInfo = {[1] = {TaskID = 1, Level = 1}, [2] = {TaskID = 2, Level = 1}}
	self.bigRecord = {}
    self.countRecord = {}
	self.taskReceive = false
	self.RewardConfig = {{rank = "1",rew1 = {id = 20006,count = 1}},
                        {rank = "2",rew1 = {id = 20007,count = 1}},
                        {rank = "3",rew1 = {id = 20024,count = 1}},
                        {rank = "4",rew1 = {id = 20103,count = 1}},
                        {rank = "5",rew1 = {id = 20103,count = 1}},
                        {rank = "6",rew1 = {id = 20103,count = 1}},
                        {rank = "7",rew1 = {id = 20103,count = 1}},
                        {rank = "8",rew1 = {id = 20103,count = 1}},
                        {rank = "9",rew1 = {id = 20103,count = 1}},
                        {rank = "10",rew1 = {id = 20103,count = 1}},
    }
end

function BlessLotteryViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnVIPLevelUp,CC.Notifications.VipChanged);

	CC.HallNotificationCenter.inst():register(self,self.OnCostSendFarewell,CC.Notifications.NW_CostSendFarewell);

	CC.HallNotificationCenter.inst():register(self,self.OnSetBlessAwardData,CC.Notifications.NW_ReqBlessAwardMessage);

	CC.HallNotificationCenter.inst():register(self,self.OnRefreshAwardMsg,CC.Notifications.OnPushBlessAwardMsg);

	CC.HallNotificationCenter.inst():register(self,self.Req_UW_PLotteryDataResp,CC.Notifications.NW_Req_UW_PLotteryData);
	CC.HallNotificationCenter.inst():register(self,self.Req_UW_PLLotteryResp,CC.Notifications.NW_Req_UW_PLLottery);
	CC.HallNotificationCenter.inst():register(self,self.Req_UW_PLotteryTaskReceiveResp,CC.Notifications.NW_Req_UW_PLotteryTaskReceive);
	CC.HallNotificationCenter.inst():register(self,self.Req_UW_PLotteryRankResp,CC.Notifications.NW_Req_UW_PLotteryRank);
	CC.HallNotificationCenter.inst():register(self,self.Req_UW_PLotteryWinPrizeResp,CC.Notifications.NW_Req_UW_PLotteryWinPrize);
	CC.HallNotificationCenter.inst():register(self,self.OnPropChange,CC.Notifications.changeSelfInfo)
end

function BlessLotteryViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self);
end

function BlessLotteryViewCtr:OnVIPLevelUp(level)

	self.view:RefreshUI({showResult = self.lotterying and 1 or 0});
end

function BlessLotteryViewCtr:OnSetBlessAwardData(err, data)

	if err == 0 then
		if #data.Message > 0 then
			self.blessDataMgr.SetBlessData(data.Message);
			self:OnRefreshAwardMsg();
		end
	end
end

function BlessLotteryViewCtr:ReqAwardMessage()
	if self.blessDataMgr.GetBlessData() then
		self:OnRefreshAwardMsg();
		return;
	end
    CC.Request("ReqBlessAwardMessage");
end

function BlessLotteryViewCtr:OnRefreshAwardMsg()
	self.view:RefreshUI({showBoardMsg = true});
end


--任务信息
function BlessLotteryViewCtr:Req_UW_PLotteryData()
    CC.Request("Req_UW_PLotteryData")
end

function BlessLotteryViewCtr:Req_UW_PLotteryDataResp(err, data)
	log(CC.uu.Dump(data, "Req_UW_PLotteryData"))
    if err == 0 then
		if data.TaskList then
			self.view:RefreshUI({taskList = data.TaskList})
        end
	end
end

--抽奖
function BlessLotteryViewCtr:Req_UW_PLLottery()
	local count = CC.Player.Inst():GetSelfInfoByKey("EPC_Props_83");
	if count <= 0 then
		local vip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level");
		if vip == 0 and CC.Player.Inst():GetFirstGiftState() then
			CC.ViewManager.Open("FirstBuyGiftView")
		elseif vip < 3 then
			CC.ViewManager.Open("VipThreeCardView")
		else
			CC.ViewManager.Open("StoreView")
		end
		return;
	end
	if count < self.view.LotteryNum then
		CC.ViewManager.ShowTip(self.language.countTip)
		return
	end

	self:SetCanClick(false)
    CC.Request("Req_UW_PLLottery", {LotteryNum = self.view.LotteryNum})
end

function BlessLotteryViewCtr:Req_UW_PLLotteryResp(err, data)
	log(CC.uu.Dump(data, "Req_UW_PLLottery"))
    if err == 0 then
		self:Req_UW_PLotteryRank()
		self:Req_UW_PLotteryWinPrize()
		self.rewardData = nil
		local RewardId = data.AwardIDS[1]
		if RewardId then
			self:LotteryRoll(self:GetItemIndexByRewardId(RewardId))
		end
		local t = {}
		for _,v in ipairs(data.AwardIDS) do
			local configId, count = self:GetItemIndexByRewardData(v)
			if configId == 18 then
				self.blessProp = true
			end
			table.insert(t,{ConfigId = configId, Count = count})
		end
		self.rewardData = t
	else
		self:SetCanClick(true)
	end
end

--领取任务奖励
function BlessLotteryViewCtr:Req_UW_PLotteryTaskReceive(index)
	if self.taskReceive then return end
	local param = {}
	if self.taskInfo[index] then
		param.TaskID = self.taskInfo[index].TaskID
		param.Level = self.taskInfo[index].Level
	end
	self.taskReceive = true
	CC.Request("Req_UW_PLotteryTaskReceive", param)
end

function BlessLotteryViewCtr:Req_UW_PLotteryTaskReceiveResp(err,data)
	log(CC.uu.Dump(data, "Req_UW_PLotteryTaskReceive"))
	if err == 0 then
		self:Req_UW_PLotteryData()
	end
	self.taskReceive = false
end

--次数排行榜
function BlessLotteryViewCtr:Req_UW_PLotteryRank()
	CC.Request("Req_UW_PLotteryRank")
end

function BlessLotteryViewCtr:Req_UW_PLotteryRankResp(err,data)
	log(CC.uu.Dump(data, "Req_UW_PLotteryRank"))
	if err == 0 then
		local t = {}
		for _,v in ipairs(data.RankList) do
			table.insert(t,v)
		end
		self.countRecord = t
		self.view:RefreshUI({myRank = data.RankID, myScore = data.score})
	end
end

--中奖名单
function BlessLotteryViewCtr:Req_UW_PLotteryWinPrize()
	CC.Request("Req_UW_PLotteryWinPrize")
end

function BlessLotteryViewCtr:Req_UW_PLotteryWinPrizeResp(err,data)
	log(CC.uu.Dump(data, "Req_UW_PLotteryWinPrize"))
	if err == 0 then
		local t = {}
		for _,v in ipairs(data.List) do
			table.insert(t,v)
		end
		self.bigRecord = t
	end
end

function BlessLotteryViewCtr:OnClickBlessing()
	-- local result = {
	-- 	RewardId = 1,
	-- 	Prop = {
	-- 		ConfigId = 2,
	-- 		Count = 9999,
	-- 	}
	-- }
	-- self.rewardData = result.Prop;
	-- self:LotteryRoll(self:GetItemIndexByRewardId(result.RewardId));
	-- do return end

	local count = CC.Player.Inst():GetSelfInfoByKey("EPC_Props_83");
	if count <= 0 then
		local vip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level");
		if vip == 0 then
			local switchOn = self.activityDataMgr.GetActivityInfoByKey("NoviceGiftView").switchOn;
	
			if switchOn and CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
				CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, false);
	
				CC.ViewManager.Open("SelectGiftCollectionView", {closeFunc = function() CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, true); end});
			else
				CC.ViewManager.Open("StoreView");
			end
			return;
		end
	end

	self:SetCanClick(false);
	CC.Request("CostSendFarewell",{Word=""})
end

function BlessLotteryViewCtr:OnCostSendFarewell(err,result)
	-- local result = {
	-- 	Prop = {
	-- 		{ConfigId = 10002, Count = 1}
	-- 	},
	-- 	RewardId = 2
	-- }
	if err == 0 then
		self.rewardData = result.Prop;
		self:LotteryRoll(self:GetItemIndexByRewardId(result.RewardId));
	else
		self:SetCanClick(true);
	end
end

--获得奖励id的位置
function BlessLotteryViewCtr:GetItemIndexByRewardId(rewardId)
	for i,v in ipairs(self.view.itemQueue) do
		if v.rewardId == rewardId then
			return i;
		end
	end
	logError("BlessLotteryViewCtr: not find the rewardId");
end

function BlessLotteryViewCtr:GetItemIndexByRewardData(rewardId)
	for _,v in ipairs(self.view.itemQueue) do
		if v.rewardId == rewardId then
			return v.ConfigId, v.Count
		end
	end
	logError("BlessLotteryViewCtr: not find the rewardId");
end

function BlessLotteryViewCtr:LotteryRoll(itemIndex)
	self.lotterying = true;
	self.itemIndex = itemIndex;

	self.view:RefreshUI({showResult = 1});

	local itemQueue = {};
	--插入20个随机的item下标
	for _ = 1, 20 do
		table.insert(itemQueue, math.random(1, 9));
	end
	--最后插入中奖id
	table.insert(itemQueue, itemIndex);

	--启动协程播放抽奖滚动动画
	self.blessAction = coroutine.start(function()
		local flag = true;
		--开始转动,所有item先闪两下
		for i = 1, 4 do
			self.view:RefreshUI({allItemActive = flag});
			flag = not flag;
			coroutine.wait(0.2);
		end
		local times = 1;
		repeat
			--设置一个偏移值用于动画播放缓冲
			local delta = 0;
			if times <= 5 then
				delta = 0.2 - (times-1) * 0.04;
			elseif times >= #itemQueue - 10 then
				delta = (times - #itemQueue + 10) * 0.04;
			end
			--根据随机好的item队列显示选中框
			self.view:RefreshUI({itemActiveIndex = itemQueue[times]});
			coroutine.wait(0.1 + delta);

			times = times + 1;
		until(times == #itemQueue+1)
		--对中奖item再闪3下
		for i = 1, 6 do
			if i%2 == 1 then
				self.view:RefreshUI({allItemActive = false});
			else
				self.view:RefreshUI({itemActiveIndex = itemIndex});
			end
			coroutine.wait(0.2);
		end

		--动画播完后处理
		self:SetCanClick(true);

		self:ShowResult(itemIndex);
	end)
end

function BlessLotteryViewCtr:ShowResult(itemIndex)
	if self.blessProp then
		CC.ViewManager.Open("BlessSearchView")
	end
	if self.rewardData and not table.isEmpty(self.rewardData) then
		local isShowTips = false;
		local data = {};
		for _,v in ipairs(self.rewardData) do
			local tb = {};
			tb.ConfigId = v.ConfigId;
			tb.Delta = v.Count;
			table.insert(data, tb);

			if not isShowTips then
				for _,itemId in ipairs(self.realAwardCfg) do
					if v.ConfigId == itemId then
						isShowTips = true
						break
					end
				end
			end
		end
		if #data > 1 then
			CC.ViewManager.OpenRewardsView({items = data,title = "BlessLotteryAward",tips = isShowTips and "MailRewardTips", gameTips = self.language.rewardTip})
		else
			CC.ViewManager.OpenRewardsView({items = data,title = "BlessLotteryAward",tips = isShowTips and "MailRewardTips"})
		end
	end
	self.view:RefreshUI({itemActiveIndex = itemIndex, showResult = 0});

	self.lotterying = false;
	self.blessProp = false
end

function BlessLotteryViewCtr:ShowFinishImmediately()
	if self.blessAction then
		CC.uu.CancelDelayRun(self.blessAction);
	end

	self.view:RefreshUI({itemActiveIndex = self.itemIndex, showResult = 0});

	self:ShowResult(self.itemIndex);

	self:SetCanClick(true);
end

function BlessLotteryViewCtr:SetCanClick(flag)

	self.view:SetCanClick(flag);

	CC.HallNotificationCenter.inst():post(CC.Notifications.FreeChipsCollectionClickState, flag);
end

function BlessLotteryViewCtr:OnPropChange(props, source)
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_Props_83 then
			self.view:UpdateCount()
			if v.Delta > 0 then
				CC.ViewManager.OpenRewardsView({items = props});
			end
		end
	end
end

function BlessLotteryViewCtr:Destroy()

	if self.blessAction then
		CC.uu.CancelDelayRun(self.blessAction);
	end

	self:UnRegisterEvent();
end

return BlessLotteryViewCtr;
