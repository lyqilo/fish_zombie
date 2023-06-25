
---------------------------------
-- region FreeChipsIcon.lua    -
-- Date: 2019.8.14        -
-- Desc: 免费合集按钮,管理红点显示以及提供游戏创建  -
-- Author: Bin        -
---------------------------------
local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local FreeChipsIcon = CC.class2("FreeChipsIcon",ViewUIBase)

function FreeChipsIcon:OnCreate(param)

	self:InitVar(param);
	self:InitContent();
	if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetPingSwitch() then
		self:InitData();
	end
	self:RegisterEvent();
end

function FreeChipsIcon:InitVar(param)
	self._timers = {}

	self.param = param or {};

	self.collectView = nil;

	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");

	self.signDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SignData");
end

function FreeChipsIcon:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self, self.OnDailySpinInfoRsp, CC.Notifications.NW_ReqGetDailySpinInfo);

	CC.HallNotificationCenter.inst():register(self, self.OnLimmitAwardInfoRsp, CC.Notifications.NW_GetLoginRewardInfo);

	CC.HallNotificationCenter.inst():register(self,self.OnAskBoxRsp, CC.Notifications.NW_ReqAskBox);

	CC.HallNotificationCenter.inst():register(self, self.OnRefreshRedDot, CC.Notifications.OnRefreshActivityRedDotState);

	CC.HallNotificationCenter.inst():register(self, self.OnlineRewardInfo, CC.Notifications.NW_GetOnlineRewardInfo)

	CC.HallNotificationCenter.inst():register(self, self.OnReqOnlineWelfare, CC.Notifications.NW_ReqOnlineWelfare)
end

function FreeChipsIcon:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetDailySpinInfo);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetLoginRewardInfo);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqAskBox);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnRefreshActivityRedDotState);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetOnlineRewardInfo)

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqOnlineWelfare)
end

function FreeChipsIcon:InitContent()

	-- self.transform = CC.uu.LoadHallPrefab("prefab", "FreeChipsIcon", self.param.parent);

	-- self.transform.gameObject.layer = self.param.parent.transform.gameObject.layer;

	self.redDot = self.transform:FindChild("RedDot");

	local icon = self.transform:FindChild("Icon");

	self:AddClick(icon, "OnOpenFreeChipsCollection");

	if self.param.sprite then
		local img = icon:GetComponent("Image");
		img.sprite = self.param.sprite;
		icon.width = self.param.width and self.param.width or img.sprite.rect.width;
		icon.height = self.param.height and self.param.height or img.sprite.rect.height;
	end
end

function FreeChipsIcon:InitData()
	--每日转盘
	-- if self.activityDataMgr.GetActivityInfoByKey("DailyTurntableView").switchOn then
		CC.Request("ReqGetDailySpinInfo");
	-- end
	--限时登录奖励
	-- if self.activityDataMgr.GetActivityInfoByKey("LimmitAwardView").switchOn then
	-- 	CC.Request("GetLoginRewardInfo");
	-- end
	-- --30天签到宝箱
	-- if self.activityDataMgr.GetActivityInfoByKey("SignInView").switchOn then
	-- 	CC.Request("ReqAskBox")
	-- 	--每日第一次登录都提示红点
	-- 	local clicksignInView = CC.LocalGameData.GetSignState();
	-- 	if not clicksignInView then
	-- 		self.activityDataMgr.SetActivityInfoByKey("SignInView", {redDot = true});
	-- 	end
	-- end
	-- --在线奖励
	-- if self.activityDataMgr.GetActivityInfoByKey("OnlineAward").switchOn then
	-- 	local playerId=CC.Player.Inst():GetSelfInfoByKey("Id")
	--     CC.Request("GetOnlineRewardInfo",{PlayerId=playerId})
	-- end
	-- --在线福利
	-- if self.activityDataMgr.GetActivityInfoByKey("OnlineLottery").switchOn then
	-- 	CC.Request("ReqOnlineWelfare")
	-- end

	-- self:OnRefreshRedDot()
end

function FreeChipsIcon:OnDailySpinInfoRsp(err, result)

	if err ~= 0 then return end

	local data = {};
	data.switchOn = result.IsOpen;
	data.redDot = (result.SpinTimes +result.CostSpinTimes + result.LockSpinTimes) > 0;
	self.activityDataMgr.SetActivityInfoByKey("DailyTurntableView", data);
end

function FreeChipsIcon:OnDailyLotteryInfoRsp(err, result)
	if err ~= 0 then return end
	local data = {};
	data.switchOn = result.IsOpen
	data.redDot = (result.SpinTimes+result.CostSpinTimes + result.LockSpinTimes) > 0;
	self.activityDataMgr.SetActivityInfoByKey("DailyLotteryView", data);
end

function FreeChipsIcon:OnLimmitAwardInfoRsp(err, result)

	if err ~= 0 then return end

	local data = {};
	data.switchOn = result.Open;
	data.redDot = result.redPoint;
	self.activityDataMgr.SetActivityInfoByKey("LimmitAwardView", data);
end

function FreeChipsIcon:OnAskBoxRsp(err, result)

	if err == CC.shared_en_pb.MsignClose then

		local data = {};
		data.switchOn = false;
		self.activityDataMgr.SetActivityInfoByKey("SignInView", data);
	elseif err == 0 then

		self.signDataMgr.SetAskBox(result)

		for i,v in ipairs(result.Value) do
			if v.CanOpen and CC.LocalGameData.GetSignState() then
				self.activityDataMgr.SetActivityInfoByKey("SignInView", {redDot = v.CanOpen});
				break;
			end
		end
	end
end

function FreeChipsIcon:OnOpenFreeChipsCollection()

	local param = {};
	param.openFunc = self.param.openFunc;
	param.closeFunc = function()
			self.collectView = nil;
			if self.param.closeFunc then
				self.param.closeFunc();
			end
		end
	if self.param.isHall then
		self.gameDataMgr.SetSwitchClick("FreeChipsCollectionView")
	end
	self.collectView = CC.ViewManager.Open("FreeChipsCollectionView", param);
end

function FreeChipsIcon:OnRefreshRedDot()

	local freeChipsInfo = self.activityDataMgr.GetFreeChipsInfo();

	for _,v in pairs(freeChipsInfo) do

		if v.redDot then
			self.redDot:SetActive(true);
			return;
		end
	end

	self.redDot:SetActive(false);

end

function FreeChipsIcon:OnlineRewardInfo(err,param)
	-- CC.uu.Log(param)
	local data = {}
	if err == 0 then
		if param.Open then
			data.switchOn = true
			if param.HasReward then
				data.redDot = true
			elseif param.RestSeconds > 0 then
				local time = 0
				local lastTime = 0
				data.redDot = false
				self:StartTimer("OnlineAward",0,function ()
					time = time + Time.deltaTime
					if lastTime < math.floor(time) then
						lastTime = math.floor(time)
					end
					if lastTime >= param.RestSeconds then
						data.redDot = true
						self.activityDataMgr.SetActivityInfoByKey("OnlineAward", data);
						self:StopTimer("OnlineAward")
        			end
				end,-1)
			else
				data.redDot = false
			end
		else
			data.switchOn = false
		end
	else
		local data = {}
		data.switchOn = false
		data.redDot = false
	end
	self.activityDataMgr.SetActivityInfoByKey("OnlineAward", data);
end

function FreeChipsIcon:OnReqOnlineWelfare(err,param)
	local data = {}
	if err == 0 then
		-- CC.uu.Log(param)

		data.switchOn = param.Show
		data.redDot = param.Show and param.Open
		self.activityDataMgr.SetActivityInfoByKey("OnlineLottery", data);
		CC.HallNotificationCenter.inst():post(CC.Notifications.PushOnlineWelfare, param)
	else
		-- data.switchOn = false
		-- data.redDot = false
		-- self.activityDataMgr.SetActivityInfoByKey("OnlineLottery", data);
		log("在线福利拉取失败")
	end

end

function FreeChipsIcon:OnDestroy()
	if self.collectView then
		self.collectView:Destroy();
	end
	self:UnRegisterEvent();
end

return FreeChipsIcon