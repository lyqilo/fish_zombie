
local CC = require("CC")

local PeriodicSignCfg = require("Model/Config/CSVExport/Periodic_sign")
local EffectPropCfg = require("Model/Config/CSVExport/Effect_prop_dancing")
local ExchangeCfg = require("Model/Config/CSVExport/Exchange_v1")

local ActSignInViewCtr = CC.class2("ActSignInViewCtr")

local amountColorRed = "#FFFFFF"
local amountColorGreen = "#3AD848"
local amountColorWhite = "#FFFFFF"

local btnColorWhite = Color(255,255,255,255)/255;
local btnColorGray = Color(213,213,213,255)/255;
local btnColorGreen = Color(6,82,53,255)/255;

local commonbtnWhite = Color(255,255,255,255)/255;
local commonbtnGray = Color(255,255,255,255)/255;

local color = Color(255,37,0,255)/255;

local textFormat = "<color=%s>%s</color>/<color=%s>%s</color>";

local specialPropId = CC.shared_enums_pb.EPC_Lucky_Star;

local exDefine = {
	Special = 1,
	Common = 2,
}

--是否可以补签
local canResign = false

local testMode = false;
local testSign = 0;
local testResign = 1;
local testOffset = 6;
local testSigned = false;

function ActSignInViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function ActSignInViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function ActSignInViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
	--签到奖励数据
	self.rewardItemData = {};
	--兑换数据
	self.exchangeItemData = {};

	self.commonExItemData = nil;
	--当前显示的奖励
	self.curSelect = nil;
	--补签消耗
	self.resignCostData = {};

	self.resignOffset = nil;

	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop");

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");
	
	self.propDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")

	self.color = color
	
	self.curSignedDay = 0
end

function ActSignInViewCtr:InitData()

	self.resignCostData = self:GetResignData();

	local actSignInCfg = self:GetSignConfig();
	for _,v in ipairs(actSignInCfg) do
		local data = self:GetRewardItemData(v);
		table.insert(self.rewardItemData, data);
	end

	local exchangeCfg = self:GetExchangeConfig();
	for _,v in ipairs(exchangeCfg.Special) do
		local data = self:GetExchangeItemData(v);
		table.insert(self.exchangeItemData, data);
	end

	self.commonExItemData = self:GetCommonExItemData(exchangeCfg.Common);
	CC.uu.Log(self.commonExItemData)

	local data = {};
	data.rewardItemData = self.rewardItemData;
	data.exchangeItemData = self.exchangeItemData;
	data.commonExItemData = self.commonExItemData;
	data.refreshCount = self:GetCurPropCountById(specialPropId);
	self.view:RefreshUI(data);

	--测试代码
	if testMode then
		self.view:DelayRun(0, function()
				self:OnActSignInfoRsp(0, {Sign = testSign, Resign = testResign, Offset = testOffset, SignedToday = testSigned});
			end)
		return
	end

	self:ReqSignInfo();

	self.activityDataMgr.SetActivityInfoByKey("ActSignInView", {redDot = false});
end

function ActSignInViewCtr:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self,self.OnActSignInfoRsp,CC.Notifications.NW_ReqActLoadSign);

	CC.HallNotificationCenter.inst():register(self,self.OnActSignRsp,CC.Notifications.NW_ReqActSign);

	CC.HallNotificationCenter.inst():register(self,self.OnActSignRsp,CC.Notifications.NW_ReqActResign);

	CC.HallNotificationCenter.inst():register(self,self.OnExchangeRsp,CC.Notifications.NW_ReqExchange);

	CC.HallNotificationCenter.inst():register(self,self.RefreshSpPropCount,CC.Notifications.changeSelfInfo);
end

function ActSignInViewCtr:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqActLoadSign);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqActSign);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqActResign);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqExchange);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.changeSelfInfo);
end

function ActSignInViewCtr:GetSignConfig()

	local data = {};
	local signCfg = PeriodicSignCfg[1].Sign;
	for index,effectId in ipairs(signCfg) do
		local item = {};
		local cfg = EffectPropCfg[effectId];
		item.Id = index;
		item.Rewards = {};
		table.insert(item.Rewards, cfg.Items[1]);
		table.insert(data, item);
	end
	return data;
end

function ActSignInViewCtr:GetExchangeConfig()

	local data = {};
	data.Special = {};
	data.Common = {};
	local exchangeCfg = PeriodicSignCfg[1].Exchanges;
	for index,v in ipairs(exchangeCfg) do
		local item = {};
		local cfg = ExchangeCfg[v.ID];
		item.Id = v.ID;
		item.From = cfg.From;
		item.To = cfg.To;
		if v.Type == exDefine.Special then
			table.insert(data.Special, item);
		elseif v.Type == exDefine.Common then
			table.insert(data.Common, item);
		end
	end
	return data;
end

function ActSignInViewCtr:GetResignData()

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

function ActSignInViewCtr:ReqSignInfo()

    CC.Request("ReqActLoadSign")
end

function  ActSignInViewCtr:OnActSignInfoRsp(err, result)
	CC.uu.Log(result, "SignInfo:")

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
				v.reSignState = canResign and true;
			end
			self:RefreshRewardItem(v);
		end
		self.resignOffset = resign;
		self.curSignedDay = sign+resign
		--刷新当前选中效果
		self:RefreshCurRewardItem(result);
		self.view:RefreshSignInRound()
	end
end

function ActSignInViewCtr:ReqSignIn()
	local param = {}
	param.PlayerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	param.GameId = CC.ViewManager.GetCurGameId() or 1
	param.GroupId = CC.ViewManager.GetCurGroupId() or 0
    CC.Request("ReqActSign",param)
end

function ActSignInViewCtr:OnActSignRsp(err, result)
	CC.uu.Log(result," SignRsp:")
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
			local t = {};
			t.ConfigId = v.ConfigId;
			t.Count = v.Count;
			t.Crit = item.critEffect;
			table.insert(rewards.Items, t);
		end
		self.curSignedDay = sign+resign
		self:RefreshRewardItem(item, rewards);
	end
end

function ActSignInViewCtr:ReqResignIn()
	local param = {}
	param.PlayerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	param.GameId = CC.ViewManager.GetCurGameId() or 1
	param.GroupId = CC.ViewManager.GetCurGroupId() or 0
    CC.Request("ReqActResign",param)
end

function ActSignInViewCtr:ReqExchange(param)
	local data = {};
	data.ID = param.id;
	data.Amount = 1;
	data.GameId = CC.ViewManager.GetCurGameId() or 1
	data.GroupId = CC.ViewManager.GetCurGroupId() or 0
	CC.Request("ReqExchange",data);
end

function ActSignInViewCtr:OnExchangeRsp(err, result)

	if err == 0 then
		for _,v in ipairs(result.Items) do
			self:DealWithPropId(v.ConfigId);
		end
		self:OnShowRewards(result.Items);
	end
end

function ActSignInViewCtr:DealWithPropId(id)

	if id == CC.shared_enums_pb.EPC_Christ_Commom_Box or id == CC.shared_enums_pb.EPC_Christ_High_Box then
		--兑换成功直接使用
		local data = {};
		data.Background = tostring(id);
		CC.Request("ReqSavePlayer",data, function()
				--本地保存一下头像id
				local selfInfo = CC.Player.Inst():GetSelfInfo();
				selfInfo.Data.Player.Background = id;
				--发消息通知头像换icon
				CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeHeadIcon, {headFrame = id});
			end);

		for _,v in pairs(self.exchangeItemData) do
			if id == v.rewardPropId then
				v.alreadyGet = true;
				v.btnTextColor = btnColorGreen;
			end
		end
		self.view:RefreshUI({refreshExchangeItem = true});
	end
end

function ActSignInViewCtr:OnShowRewards(rewards)
	local data = {};
	for _,v in ipairs(rewards) do
		local t = {};
		t.ConfigId = v.ConfigId;
		t.Delta = v.Count;
		t.Crit = v.Crit;
		table.insert(data, t);
	end
	local btnText = CC.LanguageManager.GetLanguage("L_RewardsView").btnText;
	CC.ViewManager.OpenRewardsView({items = data,btnText = btnText});
end

function ActSignInViewCtr:GetRewardItemData(param)
	local data = {};
	data.id = param.Id;
	data.propId = param.Rewards[1].ConfigID;
	data.propCount = param.Rewards[1].Amount;
	data.propIcon = self.propDataMgr.GetIcon(data.propId, data.propCount)
	data.reSignState = false;
	data.alreadyGet = false;
	data.critEffect = false;
	return data;
end

function ActSignInViewCtr:GetExchangeItemData(param)

	local data = {};
	data.id = param.Id;
	data.rewardPropId = param.To[1].ConfigId;
	data.rewardCount = param.To[1].Count;
	data.alreadyGet = self:GetCurPropCountById(data.rewardPropId) > 0;
	data.canExchange = true;
	data.costProps = {};
	--其中一个道具不满足兑换条件都不能够兑换
	for _,v in ipairs(param.From) do
		local t = {};
		t.id = v.ConfigId;
		t.costCount = v.Count;
		t.icon = self.propCfg[t.id].Icon;
		t.curCount = self:GetCurPropCountById(t.id);
		local enough = true;
		if t.curCount < t.costCount then
			data.canExchange = false;
			enough = false;
		end
		local curColor,costColor = self:GetCostAmountColor(data.alreadyGet, enough);
		--筹码特殊处理
		if t.id == CC.shared_enums_pb.EPC_ChouMa then
			t.amountText = t.costCount;
		else
			t.amountText = string.format(textFormat, curColor, t.curCount, costColor, t.costCount);
		end
		table.insert(data.costProps, t);
	end

	data.btnTextColor = (data.alreadyGet and btnColorGreen) or (data.canExchange and btnColorWhite) or btnColorGray;
	data.type = exDefine.Special;
	return data;
end

function ActSignInViewCtr:GetCommonExItemData(param)
	local cfg = param[1];
	local data = {};
	data.id = cfg.Id;
	data.rewardPropId = cfg.To[1].ConfigId;
	data.rewardCount = cfg.To[1].Count;
	data.costPropId = cfg.From[1].ConfigId;
	data.costCount = cfg.From[1].Count;
	data.rewardIcon = self.propCfg[data.rewardPropId].Icon;
	data.costIcon = self.propCfg[data.costPropId].Icon;
	data.curCount = self:GetCurPropCountById(data.costPropId);
	data.canExchange = data.curCount >= data.costCount;
	data.btnTextColor = data.canExchange and commonbtnWhite or commonbtnGray;
	data.type = exDefine.Common;
	return data;
end

function ActSignInViewCtr:GetCurPropCountById(id)

	return CC.Player.Inst():GetSelfInfoByKey(id) or 0;
end

function ActSignInViewCtr:RefreshCurRewardItem(param)
	local data = {};
	data.showSelected = true;
	if ((param.Offset+1) - param.Sign - param.Resign <= 0) or
		(not canResign and param.SignedToday) then
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

function ActSignInViewCtr:RefreshRewardItem(param, result)

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

--刷新道具数量
function ActSignInViewCtr:RefreshSpPropCount(data)
	local needRefresh;
	for _,v in ipairs(data) do
		if v.ConfigId == specialPropId or v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
			needRefresh = true;
		end
	end

	if not needRefresh then return end;

	for _,v in pairs(self.exchangeItemData) do
		v.canExchange = true;
		for _,t in pairs(v.costProps) do
			t.curCount = self:GetCurPropCountById(t.id);
			local enough = true;
			if t.curCount < t.costCount then
				v.canExchange = false;
				enough = false;
			end
			local curColor,costColor = self:GetCostAmountColor(v.alreadyGet, enough);
			--筹码特殊处理
			if t.id == CC.shared_enums_pb.EPC_ChouMa then
				t.amountText = t.costCount;
			else
				t.amountText = string.format(textFormat, curColor, t.curCount, costColor, t.costCount);
			end
		end
	end
	local specialPropCount = self:GetCurPropCountById(specialPropId);
	self.commonExItemData.curCount = specialPropCount;
	self.commonExItemData.canExchange = self.commonExItemData.curCount >= self.commonExItemData.costCount;

	self.view:RefreshUI({refreshExchangeItem = true, refreshCount = specialPropCount});
end

function ActSignInViewCtr:GetCostAmountColor(alreadyGet, enough)
	local curColor,costColor = amountColorGreen,amountColorGreen;
	if not enough then
		curColor,costColor = amountColorRed,amountColorWhite;
	end
	if alreadyGet then
		curColor,costColor = amountColorWhite,amountColorWhite;
	end
	return curColor,costColor;
end

function ActSignInViewCtr:OnGetRewardItem(param)
	-- CC.uu.Log(param)
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
		self:OnActSignRsp(0, {Info = {Sign = testSign, Resign = testResign, Offset = testOffset, SignedToday = testSigned}, Items = {t}});
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


function ActSignInViewCtr:OnExchangeItem(param)

	if param.type == exDefine.Common and not CC.Player.Inst():GetActSignTipState() then
		local data = {};
		data.callback = function()
			self:ReqExchange(param);
		end
		CC.ViewManager.Open("ActSignInBox", data);
		return;
	end
	self:ReqExchange(param);
end

function ActSignInViewCtr:OnOpenExplainView()

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

function ActSignInViewCtr:OnChangeToCapsule()
	--跳转圣诞秒杀
	-- CC.HallNotificationCenter.inst():post(CC.Notifications.OnGoToSelectGiftCollectionView,{currentView = "ElkLimitGiftView"})
	-- CC.HallNotificationCenter.inst():post(CC.Notifications.OnGoToSelectGiftCollectionView,{currentView = "ElkLimitGiftView"})
	CC.ViewManager.Open("DailyGiftCollectionView");
end

function ActSignInViewCtr:SetCanClick(flag)

	self.view:SetCanClick(flag);

	CC.HallNotificationCenter.inst():post(CC.Notifications.FreeChipsCollectionClickState, flag);
end

function ActSignInViewCtr:Destroy()

	self:UnRegisterEvent();
end

return ActSignInViewCtr;
