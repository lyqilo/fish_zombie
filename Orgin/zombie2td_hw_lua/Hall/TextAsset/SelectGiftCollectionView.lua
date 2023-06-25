
---------------------------------
-- region SelectGiftCollectionView.lua    -
-- Date: 2019.8.19        -
-- Desc: 礼包合集  -
-- Author: Chris        -
---------------------------------
local CC = require("CC")
local SelectGiftCollectionView = CC.uu.ClassView("SelectGiftCollectionView")

--[[
@param
currentView: 打开合集后第一个显示的界面
viewParams:  各个界面的传参(需把viewName作为key)

示例:
param = {
	currentView = "DailyTurntableView",
	viewParams = {
		DailyTurntableView = {...},
	}
}
]]
function SelectGiftCollectionView:ctor(param)
	self:InitVar(param);
	self:RegisterEvent();
end

function SelectGiftCollectionView:InitVar(param)
	self.param = param or {};

	self.subViewCfg = {
		{viewName = "BatteryGiftView", btnName = "btn_BatteryGift",},
		{viewName = "SuperDailyGiftView", btnName = "btn_SuperDailyGift",},
		{viewName = "CommonHolidayGiftView", btnName = "CommonHolidayGiftBtn",},
		{viewName = "SpecialOfferGiftView", btnName = "SpecialOfferGiftBtn",},
		{viewName = "BatteryLotteryView", btnName = "BatteryLotteryBtn",},
		{viewName = "MonthCardView", btnName = "MonthCardBtn",},
		{viewName = "ElkLimitGiftView", btnName = "ElkLimitGiftBtn",},
		{viewName = "NewPayGiftView", btnName = "PayBtn",},
		{viewName = "BirthdayView", btnName = "Birthday",},
		{viewName = "FortuneCatView", btnName = "FortuneCatBtn",},
		{viewName = "BrokeBigGiftView", btnName = "BrokeBigBtn",},
		{viewName = "BrokeGiftView", btnName = "BrokeBtn",},
		-- {viewName = "AchievementGiftMainView", btnName = "AchievementGiftBtn",},
		{viewName = "LuckyTurntableView", btnName = "LuckyBtn",},
		-- {viewName = "TreasureBoxGiftView", btnName = "TreasureBtn",},
		{viewName = "NoviceGiftView", btnName = "NoviceBtn",},
		{viewName = "Act_EveryGift", btnName = "btn_EveryGift",},
		{viewName = "DailyDealsView", btnName = "AirDeals",},
		{viewName = "DragonTurntableView", btnName = "DragonBtn",},
		{viewName = "AirplaneTurntableView", btnName = "AirplaneBtn",},
		{viewName = "FundView", btnName = "FundBtn",},
		{viewName = "VipThreeCardView", btnName = "VipThreeCard",},
	}

	self.btnList = {};

	self.currentView = nil;

	self.language = CC.LanguageManager.GetLanguage("L_SelectGiftCollectionView");

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");
	self.achievementGiftMgr = CC.DataMgrCenter.Inst():GetDataByKey("AchievementGift")

	self.musicName = nil

	self.batteryIdList = {{id = 1138, type = "Spine",wareId = "30353",save = "20%"},{id = 1136, type = "Spine",wareId = "30352",save = "20%"},
	{id = 1129, type = "Spine",wareId = "30351",save = "30%"},{id = 1123, type = "Animator",wareId = "30252",save = "50%"},
	{id = 1110, type = "Animator",wareId = "30250",save = "50%"}}
end

function SelectGiftCollectionView:GetSelectGiftTab()
	local temp = {}
	self:SortSubViewCfg()
	if self.param.SelectGiftTab then
		for i,v in pairs(self.param.SelectGiftTab) do
			for j,k in ipairs(self.subViewCfg) do
				if v == k.viewName then
					table.insert(temp, k)
				end
			end
		end
	else
		temp = self.subViewCfg
	end
	return temp
end

function SelectGiftCollectionView:SortSubViewCfg()
	local brokeGiftData = self.activityDataMgr.GetBrokeGiftData()
	local countDown = self.achievementGiftMgr.GetCountDown()
	if countDown > 0 and brokeGiftData and brokeGiftData.nStatus == 1 then
		--破产礼包和限时礼包比较，后触发放前面
		if brokeGiftData.lLeftTimeSec and brokeGiftData.lLeftTimeSec < countDown then
			local temp = self.subViewCfg[4]
			self.subViewCfg[4] = self.subViewCfg[5]
			self.subViewCfg[5] = temp
		end
	end
end

function SelectGiftCollectionView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshRedDot,CC.Notifications.OnRefreshActivityRedDotState)
	CC.HallNotificationCenter.inst():register(self,self.OnClickNoviceDes,CC.Notifications.OnClickNoviceDes)
	CC.HallNotificationCenter.inst():register(self,self.OnJumpNovice,CC.Notifications.OnRefreshJumpNovice)
	CC.HallNotificationCenter.inst():register(self,self.RefreshNovice,CC.Notifications.NoviceReward)
	CC.HallNotificationCenter.inst():register(self,self.OnLimitTimeGiftReward,CC.Notifications.OnLimitTimeGiftReward)
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshSwitchOn,CC.Notifications.OnRefreshActivityBtnsState)
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshClickState,CC.Notifications.GiftCollectionClickState);
	CC.HallNotificationCenter.inst():register(self,self.SetLuckyCountDownView,CC.Notifications.LuckyCountDown)
end

function SelectGiftCollectionView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function SelectGiftCollectionView:OnRefreshSwitchOn(key, switchOn)
	for i,v in ipairs(self.btnList) do
		if key == v.viewName then
			-- 关闭了当前界面，自动选择最前面一个界面
			if switchOn == false and self.currentView and self.currentView.viewName == key then
				local btnIndex = 0
				for j, v2 in ipairs(self.btnList) do
					if i~=j and self.activityDataMgr.GetActivityInfoByKey(v2.viewName).switchOn then
						btnIndex = j
						break
					end
				end
				if btnIndex == 0 then
					self:ActionOut()
					return
				end
				self.btnList[btnIndex].toggle.isOn = true
			end
			v.btn:SetActive(switchOn)
			break
		end
	end
end

function SelectGiftCollectionView:OnRefreshClickState(flag)
	self:SetCanClick(flag);
	for _,v in ipairs(self.btnList) do
		v.toggle.enabled = flag;
	end
end

function SelectGiftCollectionView:SetLuckyCountDownView(countdown)
	if countdown <= 0 then
		self.activityDataMgr.SetActivityInfoByKey("LuckyTurntableView", {switchOn = false})
	end
end

function SelectGiftCollectionView:RefreshNovice()
	local NoviceIndex
	self.activityDataMgr.SetActivityInfoByKey("NoviceGiftView", {switchOn = false})
	for index, v in ipairs(self.btnList) do
		if "NoviceGiftView" == v.viewName then
			NoviceIndex = index
			v.toggle.isOn = false
			v.btn:SetActive(false)
		end
	end
	local currentIndex = NoviceIndex + 1
	if currentIndex > #self.btnList then
		currentIndex = 1
	end
	self.btnList[currentIndex].toggle.isOn = true

	self:ActionOut();
end

function SelectGiftCollectionView:OnLimitTimeGiftReward()
	log("OnLimitTimeGiftReward")
	self:ActionOut();
end

function SelectGiftCollectionView:OnJumpNovice()
	for index, v in ipairs(self.btnList) do
		if "NoviceGiftView" == v.viewName then
			self.btnList[index].toggle.isOn = true
			return
		end
	end
end

function SelectGiftCollectionView:OnClickNoviceDes(isShow)
	self:FindChild("LeftPanel"):SetActive(isShow)
	self:FindChild("BtnClose"):SetActive(isShow)
end

function SelectGiftCollectionView:OnCreate()

	if self.param.openFunc then
		self.param.openFunc()
	end

	self.btnRoot = self:FindChild("LeftPanel/Scroll View/Viewport/BtnList")
	self.btnPrefab = self:FindChild("LeftPanel/Scroll View/Viewport/BtnList/Btn")
	self.btnPrefab:SetActive(false)

	--设置当前显示的界面
	local btnIndex = 1;

	for i, cfg in ipairs(self:GetSelectGiftTab()) do
		local activityData = self.activityDataMgr.GetActivityInfoByKey(cfg.viewName)
		if activityData then
			local switchOn = activityData.switchOn;

			local btnItem = self:CreateBtnItem(cfg);
			table.insert(self.btnList, btnItem);

			if not switchOn then
				if btnIndex == i then
					btnIndex = btnIndex + 1
				end
			end

			if cfg.viewName == "BatteryGiftView" then
				local isShow = false
				for i, v in ipairs(self.batteryIdList) do
					local isHaveBattery = CC.Player.Inst():GetSelfInfoByKey(v.id) or 0
					if isHaveBattery <= 0 then
						isShow = true
					end
				end
				if not isShow then
					switchOn = false
				end
			end
			
			btnItem.btn:SetActive(switchOn)
		end
	end
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= 3 then
		self.activityDataMgr.SetActivityInfoByKey("VipThreeCardView", {switchOn = false})
	end
	self:AddClick("BtnClose", "ActionOut");

	if self.param.currentView then
		for index, v in ipairs(self.btnList) do
			if self.param.currentView == v.viewName and self.activityDataMgr.GetActivityInfoByKey(v.viewName).switchOn then
				btnIndex = index
				break
			end
		end
	end
	if btnIndex <= #self.btnList then
		self.btnList[btnIndex].toggle.isOn = true;
	end
	self:OnRefreshRedDot();

	self:DelayRun(0.1, function()
			self.musicName = CC.Sound.GetMusicName();
			-- CC.Sound.PlayHallBackMusic("BGM_SelectGiftCollection");
			CC.Sound.PlayHallBackMusic("turntableBg");
		end)
end

function SelectGiftCollectionView:CreateBtnItem(cfg)
	local t = {};

	t.btn = CC.uu.newObject(self.btnPrefab, self.btnRoot)
	t.btn.name = cfg.btnName

	t.btn:SetActive(false);

	t.redDot = t.btn:FindChild("RedDot");

	t.viewName = cfg.viewName;

	t.viewParam = self.param.viewParams and self.param.viewParams[cfg.viewName] or {};
	t.toggle = t.btn:GetComponent("Toggle");

	if t.viewName == "BatteryGiftView" then
		t.viewParam.BatteryList = {}
		t.viewParam.CloseView = function ()
			self:ActionOut()
		end
		-- for i, v in ipairs(self.batteryIdList) do
		-- 	local isHaveBattery = CC.Player.Inst():GetSelfInfoByKey(v.id) or 0
		-- 	if isHaveBattery <= 0 then
		-- 		table.insert(t.viewParam.BatteryList,v)
		-- 	end
		-- end
		-- if #t.viewParam.BatteryList <= 0 then
		-- 	t.btn:SetActive(false);
		-- 	t.viewParam.BatteryList = self.batteryIdList
		-- end
	end

	UIEvent.AddToggleValueChange(t.btn, function(selected)
			if selected then
				--选中按钮后销毁上一个显示的界面并创建当前按钮指向的界面
				if self.currentView then
					if self.currentView.viewName == t.viewName then return end;
					self.currentView:ActionOut();
				end
				if t.viewName == "LuckyTurntableView" or t.viewName == "VipThreeCardView" or t.viewName == "BrokeGiftView" or t.viewName == "BrokeBigGiftView" or t.viewName == "BirthdayView" then
					t.viewParam.isGiftCollection = true
					if t.viewName == "LuckyTurntableView" then
						t.viewParam.callBack = function (isShow)
							self:FindChild("BtnClose"):SetActive(isShow)
						end
					end
				end
				if t.viewName == "BatteryGiftView" then
					t.viewParam.CloseView = function ()
						self:ActionOut()
					end
				end
				

				self.currentView = CC.uu.CreateHallView(cfg.viewName, t.viewParam,self.language,cfg.btnName,self);

				self.currentView.transform:SetParent(self:FindChild("Content"), false);
				self.currentView:ActionIn();

				if self:IsPortraitView() then
					if CC.DefineCenter.Inst():getConfigDataByKey("HallDefine").PortraitSupport[cfg.viewName] then
						self:FindChild("Content").localScale = Vector3.one
						self:FindChild("Content").sizeDelta = Vector2(0, -560)
					else
						--没做竖屏适配的界面先简单做个缩放
						self:FindChild("Content").localScale = Vector3(0.65,0.65,0.65)
						self:FindChild("Content").sizeDelta = Vector2(180, -560)
					end
				end
				
				local x = self:IsPortraitView() and 75 or 115
				t.redDot.x = x;
			else
				local x = self:IsPortraitView() and 65 or 95
				t.redDot.x = x;
			end
		end)

	t.btn:FindChild("Text").text = self.language[cfg.btnName];
	t.btn:FindChild("Selected/Text").text = self.language[cfg.btnName];

	return t;
end

function SelectGiftCollectionView:OnRefreshRedDot(key,redDot)
	for _,v in ipairs(self.btnList) do
		if key then
			if key == v.viewName then
				v.redDot:SetActive(redDot)
				return
			end
		else
			local showRedDot = self.activityDataMgr.GetActivityInfoByKey(v.viewName).redDot
			v.redDot:SetActive(showRedDot);
		end
	end
end

function SelectGiftCollectionView:OnFocusIn()

	if not self.currentView or not self.currentView.OnFocusIn then return end;

	self.currentView:OnFocusIn();
end

function SelectGiftCollectionView:OnFocusOut()

	if not self.currentView or not self.currentView.OnFocusOut then return end;

	self.currentView:OnFocusOut();
end

function SelectGiftCollectionView:ActionIn()

	self:SetCanClick(false);

	local x = self:IsPortraitView() and 0 or 200

	local leftPanel = self:FindChild("LeftPanel");
	self:RunAction(leftPanel, {"localMoveBy", x, 0, 0.5, ease = CC.Action.EOutCubic});

	x = self:IsPortraitView() and 0 or -110
	local y = self:IsPortraitView() and 0 or -10
	local btnClose = self:FindChild("BtnClose");
	self:RunAction(btnClose, {"localMoveBy", x, y, 0.5, ease = CC.Action.EOutCubic});

	local mask = self:FindChild("Mask");
	self:RunAction(mask, {"fadeTo", self.param.maskAlpha or 200, 0.5, function() self:SetCanClick(true); end});
end

function SelectGiftCollectionView:ActionOut()

	self:SetCanClick(false);

	local x = self:IsPortraitView() and 0 or -200

	local leftPanel = self:FindChild("LeftPanel");
	self:RunAction(leftPanel, {"localMoveBy", x, 0, 0.5, ease = CC.Action.EOutCubic});

	x = self:IsPortraitView() and 0 or 110
	local y = self:IsPortraitView() and 0 or -10

	local btnClose = self:FindChild("BtnClose");
	self:RunAction(btnClose, {"localMoveBy", x, y, 0.5, ease = CC.Action.EOutCubic});

	if self.currentView then
		self.currentView:ActionOut();
	end
	self.currentView = nil;

	local mask = self:FindChild("Mask");
	self:RunAction(mask, {"fadeTo", 0, 0.5, function()
		self:Destroy()
		if self.param.closeFunc then
			self.param.closeFunc();
		end
	end});

	self:UnRegisterEvent();
end

function SelectGiftCollectionView:OnDestroy()

	self:UnRegisterEvent();

	if self.currentView then
		self.currentView:Destroy();
	end

	if self.musicName then
		CC.Sound.PlayHallBackMusic(self.musicName);
	else
		CC.Sound.StopBackMusic();
	end

	for _,v in ipairs(self.btnList) do
		v.toggle = nil
	end
	self.btnList = {}
end

return SelectGiftCollectionView