
local CC = require("CC")

local PeriodicSignCfg = require("Model/Config/CSVExport/NewPlayerSign")
local EffectPropCfg = require("Model/Config/CSVExport/NoviceSignEffect")

local NoviceSignInViewCtr = CC.class2("NoviceSignInViewCtr")

local testMode = false;
local testSign = 1;
local testResign = 1;
local testOffset = 9;
local testSigned = false;

function NoviceSignInViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function NoviceSignInViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function NoviceSignInViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
	--签到奖励数据
	self.rewardItemData = {};

	--当前显示的奖励
	self.curSelect = nil;
	--补签消耗
	self.resignCostData = {};

	self.resignOffset = nil;

	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop");

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");

	self.signDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SignActivityDataMgr");
end

function NoviceSignInViewCtr:InitData()
	self.resignCostData = self:GetResignData();

	local actSignInCfg = self:GetSignConfig();
	for _,v in ipairs(actSignInCfg) do
		local data = self:GetRewardItemData(v);
		table.insert(self.rewardItemData, data);
	end

	local data = {};
	data.rewardItemData = self.rewardItemData;
	self.view:RefreshUI(data);

	--测试代码
	if testMode then
		self.view:DelayRun(0, function()
				self:OnNewSignInfoRsp(0, {Info = {Sign = testSign, Resign = testResign, Offset = testOffset, SignedToday = testSigned}});
			end)
		return
	end

	self:ReqSignInfo();

	-- self.activityDataMgr.SetActivityInfoByKey("ActSignInView", {redDot = false});
end

function NoviceSignInViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnNewPlayerSignRecordRsp,CC.Notifications.NW_ReqNewPlayerSignRecord)

	CC.HallNotificationCenter.inst():register(self,self.RefreshRecord,CC.Notifications.AddNoviceSignAwardInfo)

	CC.HallNotificationCenter.inst():register(self,self.OnNewSignInfoRsp,CC.Notifications.NW_ReqLoadNewPlayerSign);

	CC.HallNotificationCenter.inst():register(self,self.OnNewSignRsp,CC.Notifications.NW_ReqNewPlayerSign);

	CC.HallNotificationCenter.inst():register(self,self.OnNewSignRsp,CC.Notifications.NW_ReqNewPlayerResign);
end

function NoviceSignInViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqNewPlayerSignRecord);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.AddNoviceSignAwardInfo);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqLoadNewPlayerSign);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqNewPlayerSign);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqNewPlayerResign);
end

function NoviceSignInViewCtr:GetSignConfig()

	local data = {};
	local signCfg = PeriodicSignCfg[1].Sign;
	for index,effectId in ipairs(signCfg) do
		local item = {};
		local cfg = EffectPropCfg[effectId];
		item.Id = index;
		item.Awards = cfg.Awards;
		item.Rewards = {};
		table.insert(item.Rewards, cfg.Items[1]);
		table.insert(data, item);
	end
	return data;
end

function NoviceSignInViewCtr:GetResignData()

	local data = {};
	local resignCfg = PeriodicSignCfg[1].Resign;
	for _,v in ipairs(resignCfg) do
		local item = {};
		item.propId = v.ConfigId;
		item.cost = v.Count;
		table.insert(data, item);
	end
	return data;
end

function NoviceSignInViewCtr:ReqSignInfo()
	CC.Request("ReqLoadNewPlayerSign");

	CC.Request("ReqNewPlayerSignRecord");
end

function NoviceSignInViewCtr:OnNewPlayerSignRecordRsp(err,data)
	if err == 0 then
		self.signDataMgr.SetNoviceSignAwardInfo(data)
	else
		log("ReqNewPlayerSignRecord,err = "..err)
	end
	self.view:CheckMarquee()
end

function NoviceSignInViewCtr:RefreshRecord()
	self.view:CheckMarquee()
end

function  NoviceSignInViewCtr:OnNewSignInfoRsp(err, data)
    local result = data.Info
	if err == 0 then
		local sign = result.Sign;
		local resign = result.Resign;
		local signday = result.Offset+1;
		local signed = result.SignedToday;
		for _,v in ipairs(self.rewardItemData) do
			if v.id <= sign + resign then
				v.alreadyGet = true;
			end
			local offset = signed and 0 or 1;
			if v.id > sign + resign + offset and v.id <= signday then
				v.reSignState = true;
			end
			self:RefreshRewardItem(v);
		end
		self.resignOffset = resign;
		--刷新当前选中效果
		self:RefreshCurRewardItem(result);
		local param = {}
		local beginTime = os.date("%d/%m/%Y",data.BeginStamp)
		local endTime = os.date("%d/%m/%Y",data.EndStamp-1)
		param.time = beginTime.." - "..endTime
		self.view:RefreshUI(param);
	end
end

function NoviceSignInViewCtr:ReqSignIn()
	local param = {}
	param.PlayerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	param.GameId = CC.ViewManager.GetCurGameId() or 1
	param.GroupId = CC.ViewManager.GetCurGroupId() or 0
	CC.Request("ReqNewPlayerSign",param);
end

function NoviceSignInViewCtr:OnNewSignRsp(err, result)
	if err == 0 then
		local sign = result.Info.Sign;
		local resign = result.Info.Resign;
		local item = self.rewardItemData[sign+resign];
		item.alreadyGet = true;
		if item.propCount < result.Items[1].Count then
			item.critEffect = true;
		end
		local rewards = {};
		rewards.Items = {};
		rewards.Info = result.Info;
		for _,v in ipairs(result.Items) do
			self:DealWithPropId(v.ConfigId);
			local t = {};
			t.ConfigId = v.ConfigId;
			t.Count = v.Count;
			t.Crit = item.critEffect;
			table.insert(rewards.Items, t);
		end
		self:RefreshRewardItem(item, rewards);
	end
end

function NoviceSignInViewCtr:ReqResignIn()
	local param = {}
	param.PlayerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	param.GameId = CC.ViewManager.GetCurGameId() or 1
	param.GroupId = CC.ViewManager.GetCurGroupId() or 0
	CC.Request("ReqNewPlayerResign",param);
end

function NoviceSignInViewCtr:DealWithPropId(id)

	if id == CC.shared_enums_pb.EPC_Newbie_Sign_Frame then
		--兑换成功直接使用
		local data = {};
		data.Background = tostring(id);
		CC.Request.ReqSavePlayer(data, function()
			--本地保存一下头像id
			local selfInfo = CC.Player.Inst():GetSelfInfo();
			selfInfo.Data.Player.Background = id;
			--发消息通知头像换icon
			CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeHeadIcon, {headFrame = id});
		end);
	end
end

function NoviceSignInViewCtr:OnShowRewards(rewards)
	local data = {};
	for _,v in ipairs(rewards) do
		local t = {};
		t.ConfigId = v.ConfigId;
		t.Delta = v.Count;
		t.Crit = v.Crit;
		table.insert(data, t);
	end
	CC.ViewManager.OpenRewardsView({items = data});
end

function NoviceSignInViewCtr:GetRewardItemData(param)
	local data = {};
	data.id = param.Id;
	data.propId = param.Rewards[1].ConfigID ;
	data.propCount = param.Rewards[1].Amount;
	if type(data.propId) == "string" then
		data.propIcon = "fd_"..data.propId
		data.awards = param.Awards;
	else
		data.propIcon = self.propCfg[data.propId].Icon;
	end
	data.reSignState = false;
	data.alreadyGet = false;
	data.critEffect = false;
	return data;
end

function NoviceSignInViewCtr:GetCurPropCountById(id)

	return CC.Player.Inst():GetSelfInfoByKey(id);
end

function NoviceSignInViewCtr:RefreshCurRewardItem(param)
	local data = {};
	data.showSelected = true;
	if param.Offset + 1 - param.Sign - param.Resign <= 0 then
		data.showSelected = false;
	end
	if data.showSelected then
		data.curSelect = param.Sign + param.Resign + 1;
		self.curSelect = data.curSelect;
		if param.SignedToday then
			self.resignOffset = param.Resign;
			data.resign = self.resignCostData[self.resignOffset+1];
		end
	end
	self.view:RefreshUI(data);
end

function NoviceSignInViewCtr:RefreshRewardItem(param, result)

	local data = {};
	data.id = param.id;
	data.alreadyGet = param.alreadyGet;
	data.critEffect = param.critEffect;
	if result then
		data.rewards = result.Items;
		data.info = result.Info;
	end
	self.view:RefreshUI({refreshRewardItem = data});
end

function NoviceSignInViewCtr:OnGetRewardItem(param)
	if param.id ~= self.curSelect then return end

	--测试代码
	if testMode then
		if param.reSignState then
			testResign = testResign + 1;
		else
			testSign = testSign + 1;
		end
		local item = self.rewardItemData[testSign+testResign];
		local t = {};
		t.ConfigId = item.propId;
		t.Count = item.propCount * 2;
		testSigned = true;
		self:OnNewSignRsp(0, {Info = {Sign = testSign, Resign = testResign, Offset = testOffset, SignedToday = testSigned}, Items = {t}});
		return
	end

	if param.reSignState then

		local diamond = CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi");

		local resignData = self.resignCostData[self.resignOffset+1];
		if diamond < resignData.cost then
			--提示补签砖石不足
			CC.ViewManager.ShowTip(self.view.language.resignTip);
			return;
		end
		--补签
		self:ReqResignIn();
		return;
	end

	--请求签到
	self:ReqSignIn();
end

function NoviceSignInViewCtr:OnOpenExplainView()

	local language = self.view.language;
	local data = {
		title = language.explainTitle,
		content = language.explainContent,
		alignment = UnityEngine.TextAnchor.MiddleCenter,
		padding = {left = 0},
		lineSpace = 1.9,
	}
	CC.ViewManager.Open("CommonExplainView", data);
end

function NoviceSignInViewCtr:SetCanClick(flag)

	self.view:SetCanClick(flag);

	CC.HallNotificationCenter.inst():post(CC.Notifications.FreeChipsCollectionClickState, flag);
end

function NoviceSignInViewCtr:Destroy()

	self:UnRegisterEvent();
end

return NoviceSignInViewCtr;
