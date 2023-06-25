
---------------------------------
-- region FreeChipsCollectionView.lua    -
-- Date: 2019.8.12        -
-- Desc: 免费筹码合集  -
-- Author: Bin        -
---------------------------------
local CC = require("CC")
local FreeChipsCollectionView = CC.uu.ClassView("FreeChipsCollectionView")

--[[
@param
currentView: 打开合集后第一个显示的界面
viewParams:  各个界面的传参(需把viewName作为key)
openFunc:    打开界面的回调
closeFunc:   界面关闭的回调

示例:
param = {
	currentView = "DailyTurntableView",
	viewParams = {
		DailyTurntableView = {...},
	}
}
]]
function FreeChipsCollectionView:ctor(param)

	self:InitVar(param);

	self:RegisterEvent();
end

function FreeChipsCollectionView:InitVar(param)

	self.param = param or {};

	self.subViewCfg = {
		{
			viewName = "WorldCupADPageView",
			btnName = "BtnWorldCup",
		},
		{
			viewName = "MarsTaskEntryView",
			btnName = "BtnMarsTaskEntry",
		},
		{
			viewName = "HolidayTaskView",
			btnName = "BtnHolidayTask",
		},
		{
			viewName = "ChristmasTaskView",
			btnName = "BtnChristmasTask",
		},
		{
			viewName = "CapsuleView",
			btnName = "BtnCapsule"
		},
		{
			viewName = "DailyLotteryView",
			btnName = "BtnDailyLottery",
		},
		{
			viewName = "HalloweenLoginGiftView",
			btnName = "BtnHalloweenLogin",
		},
		{
			viewName = "NoviceSignInView",
			btnName = "BtnNoviceSignInView",
		},
		{
			viewName = "NewbieTaskView",
			btnName = "BtnNewbieTaskView",
		},
		-- {
		-- 	viewName = "OnlineLottery",
		-- 	btnName = "BtnOnlineLottery",
		-- },
		{
			viewName = "ActSignInView",
			btnName = "BtnActSignIn",
		},

		{
			viewName = "BlessLotteryView",
			btnName = "BtnBlessLottery",
		},
		{
			viewName = "DailyTurntableView",
			btnName = "BtnTurntable",
		},
		{
			viewName = "FragmentTaskView",
			btnName = "BtnFragmentTaskView",
		},
		-- {
		-- 	viewName = "LoyKraThong",
		-- 	btnName = "BtnLoyKraThong",
		-- },
		{
			viewName = "SignInView",
			btnName = "BtnSignIn",
		},
		-- {
		-- 	viewName = "HCoinView",
		-- 	btnName = "BtnHCoin",
		-- },
		{
			viewName = "OnlineAward",
			btnName = "BtnOnlineAward",
		},
		{
			viewName = "LimmitAwardView",
			btnName = "BtnLimmitAward",
		},
	}

	self.btnList = {};

	self.currentView = nil;

	self.musicName = nil;

	self.language = CC.LanguageManager.GetLanguage("L_FreeChipsCollectionView");

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");

	self.noviceDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("NoviceDataMgr");
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
end

function FreeChipsCollectionView:GetSelectTab()
	local temp = {}
	if self.param.SelectTab then
		for i,v in pairs(self.param.SelectTab) do
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

function FreeChipsCollectionView:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self,self.OnRefreshRedDot,CC.Notifications.OnRefreshActivityRedDotState);

	CC.HallNotificationCenter.inst():register(self,self.OnRefreshClickState,CC.Notifications.FreeChipsCollectionClickState);

	CC.HallNotificationCenter.inst():register(self,self.OnSetViewState,CC.Notifications.OnShowFreeChipsCollectionView);

	CC.HallNotificationCenter.inst():register(self,self.OnRefreshBtnsList,CC.Notifications.OnRefreshActivityBtnsState);

	CC.HallNotificationCenter.inst():register(self,self.OnChangeViewByKey,CC.Notifications.OnChangeFreeChipsView);
	--跳转选择礼包合集
    CC.HallNotificationCenter.inst():register(self,self.OnChangeSelectGiftCollection,CC.Notifications.OnGoToSelectGiftCollectionView);

	CC.HallNotificationCenter.inst():register(self,self.ActionOut,CC.Notifications.EnterWorldCupPage);
end

function FreeChipsCollectionView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.EnterWorldCupPage);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnRefreshActivityRedDotState);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.FreeChipsCollectionClickState);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnShowFreeChipsCollectionView);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnRefreshActivityBtnsState);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnChangeFreeChipsView);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnGoToSelectGiftCollectionView)
end

function FreeChipsCollectionView:OnCreate()

	if self.param.openFunc then
		self.param.openFunc();
	end

	self.btnRoot = self:FindChild("LeftPanel/Scroll/Viewport/BtnList")
	self.btnPrefab = self:FindChild("LeftPanel/Scroll/Viewport/BtnList/Btn")

	--设置当前显示的界面
	local btnIndex = 1;

	for i, cfg in ipairs(self:GetSelectTab()) do

		local activityData = self.activityDataMgr.GetActivityInfoByKey(cfg.viewName)
		local reqState = self.noviceDataMgr.GetNoviceDataByKey(cfg.viewName)
		if activityData then
			local switchOn = activityData.switchOn --and CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey(cfg.viewName)
			if reqState then
				if (cfg.viewName == "NoviceSignInView" or cfg.viewName == "NewbieTaskView") and not self.gameDataMgr.GetSingleFlag(10) then
					--签到引导没做，按钮不显示
					switchOn = false
				else
					switchOn = switchOn and reqState.open
				end
			end
			if cfg.viewName == "HalloweenLoginGiftView" then
				switchOn = switchOn and CC.HallUtil.ShowHalloweenLoginGift()
			elseif cfg.viewName == "HolidayTaskView" then
				switchOn = switchOn and CC.ViewManager.IsHallScene()
			elseif cfg.viewName == "WorldCupADPageView" then
				switchOn = switchOn and CC.ViewManager.IsHallScene()
			elseif cfg.viewName == "MarsTaskEntryView" then
				switchOn = switchOn and CC.ViewManager.IsHallScene()
			end

			local btnItem = self:CreateBtnItem(cfg);
			table.insert(self.btnList, btnItem);
			if not switchOn then
				if btnIndex == i then
					btnIndex = btnIndex + 1
				end
				btnItem.btn:SetActive(false);
			end
		end
	end
	CC.Request("ReqSynOnlineTime");
	self:AddClick("BtnClose", "ActionOut");



	if self.param.currentView then
		for index, v in ipairs(self.btnList) do
			if self.param.currentView == v.viewName then
				local switchOn = self.activityDataMgr.GetActivityInfoByKey(v.viewName).switchOn
				local reqState = self.noviceDataMgr.GetNoviceDataByKey(v.viewName)
				if reqState then
					switchOn = reqState.open
				end
				if switchOn then
					btnIndex = index;
				end
			end
		end
	end
	self.btnList[btnIndex].toggle.isOn = true;

	self:OnRefreshRedDot();

	self:DelayRun(0.1, function()
			self.musicName = CC.Sound.GetMusicName();
			--CC.Sound.PlayHallBackMusic("BGM_FreeChipsCollection");
			CC.Sound.PlayHallBackMusic("BGM_ActivityMonthly");
		end)

	--游戏内模糊处理直接调用
	if not CC.ViewManager.IsHallScene() then

		self.GaussBlur = GameObject.Find("HallCamera/GaussCamera"):GetComponent("GaussBlur");
		self.GaussBlur.enabled = true;
	end
end

function FreeChipsCollectionView:OnChangeSelectGiftCollection(param)
	self:OnSetViewState(false)
	local fun = function()
		self:OnSetViewState(true)
	end
	param.closeFunc = fun
	CC.ViewManager.Open("SelectGiftCollectionView",param);
end


function FreeChipsCollectionView:CreateBtnItem(cfg)

	local t = {};

	t.btn = CC.uu.newObject(self.btnPrefab, self.btnRoot)
	t.btn.name = cfg.btnName

	t.btn:SetActive(true);

	t.redDot = t.btn:FindChild("RedDot");

	t.viewName = cfg.viewName;

	t.viewParam = self.param.viewParams and self.param.viewParams[cfg.viewName] or {};

	t.toggle = t.btn:GetComponent("Toggle");

	UIEvent.AddToggleValueChange(t.btn, function(selected)

			if selected then
				--选中按钮后销毁上一个显示的界面并创建当前按钮指向的界面
				if self.currentView then

					if self.currentView.viewName == t.viewName then return end;

					self.currentView:ActionOut();
				end

				self.currentView = CC.uu.CreateHallView(cfg.viewName, t.viewParam,self);
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

function FreeChipsCollectionView:OnRefreshRedDot(key,redDot)

	for _,v in ipairs(self.btnList) do

		if key then
			if key == v.viewName then
				v.redDot:SetActive(redDot)
				return
			end
		else
			local showRedDot = self.activityDataMgr.GetActivityInfoByKey(v.viewName).redDot;
			v.redDot:SetActive(showRedDot);
		end
	end
end

function FreeChipsCollectionView:OnRefreshClickState(flag)

	self:SetCanClick(flag);

	for _,v in ipairs(self.btnList) do

		v.toggle.enabled = flag;
	end
end

function FreeChipsCollectionView:OnRefreshBtnsList(key,switchOn)

	for i,v in ipairs(self.btnList) do
		if key == v.viewName then
			if (key == "NoviceSignInView" or key == "NewbieTaskView") and not self.gameDataMgr.GetSingleFlag(10) then
				--签到引导没做，新手签到，任务按钮不显示
				switchOn = false
			end
			-- 关闭了当前界面，自动选择最前面一个界面
			if switchOn == false and self.currentView and self.currentView.viewName == key then
				local btnIndex = 0
				for j,v2 in ipairs(self.btnList) do
					local reqState = self.noviceDataMgr.GetNoviceDataByKey(v2.viewName)
					if i~=j and self.activityDataMgr.GetActivityInfoByKey(v2.viewName).switchOn then
						if reqState then
							if reqState.open then
								btnIndex = j
								break
							end
						else
							btnIndex = j
							break
						end
					end
				end
				if btnIndex == 0 then
					self:ActionOut()
					return
				end
				self.btnList[btnIndex].toggle.isOn = true
			end
			local reqState = self.noviceDataMgr.GetNoviceDataByKey(key)
			if reqState then
				switchOn = switchOn and reqState.open
			end
			v.btn:SetActive(switchOn)
		end
	end
end

function FreeChipsCollectionView:OnChangeViewByKey(key)
	--合集内切换页签
	for i,v in ipairs(self.btnList) do
		if key == v.viewName then
			v.toggle.isOn = true;
		end
	end
end

function FreeChipsCollectionView:OnSetViewState(flag)

	if flag then
		self:ActionShow();
	else
		self:ActionHide();
	end
end

function FreeChipsCollectionView:OnFocusIn()

	if not self.currentView or not self.currentView.OnFocusIn then return end;

	self.currentView:OnFocusIn();
end

function FreeChipsCollectionView:OnFocusOut()

	if not self.currentView or not self.currentView.OnFocusOut then return end;

	self.currentView:OnFocusOut();
end

function FreeChipsCollectionView:ActionIn()

	self:SetCanClick(false);

	local x = self:IsPortraitView() and 0 or 220
	local leftPanel = self:FindChild("LeftPanel");
	self:RunAction(leftPanel, {"localMoveBy", x, 0, 0.5, ease = CC.Action.EOutCubic});

	x = self:IsPortraitView() and 0 or -110
	local y = self:IsPortraitView() and 0 or -10
	local btnClose = self:FindChild("BtnClose");
	self:RunAction(btnClose, {"localMoveBy", x, y, 0.5, ease = CC.Action.EOutCubic});

	local mask = self:FindChild("Mask");
	self:RunAction(mask, {"fadeTo", 200, 0.5, function() self:SetCanClick(true); end});
end

function FreeChipsCollectionView:ActionOut()
	self:SetCanClick(false);

	local x = self:IsPortraitView() and 0 or -220
	local leftPanel = self:FindChild("LeftPanel");
	self:RunAction(leftPanel, {"localMoveBy", x, 0, 0.5, ease = CC.Action.EOutCubic});

	x = self:IsPortraitView() and 0 or 110
	local btnClose = self:FindChild("BtnClose");
	self:RunAction(btnClose, {"localMoveBy", x, 0, 0.5, ease = CC.Action.EOutCubic});

	local mask = self:FindChild("Mask");
	self:RunAction(mask, {"fadeTo", 0, 0.5, function()
			self:Destroy();
			if self.param.closeFunc then
				self.param.closeFunc();
			end
		end});

	self.currentView:ActionOut();

	self.currentView = nil;

	self:UnRegisterEvent();
end

function FreeChipsCollectionView:ActionShow()

	self:ActionIn();

	self.currentView:ActionShow();
end

function FreeChipsCollectionView:ActionHide()

	self:SetCanClick(false);

	local x = self:IsPortraitView() and 0 or -220
	local leftPanel = self:FindChild("LeftPanel");
	self:RunAction(leftPanel, {"localMoveBy", x, 0, 0.5, ease = CC.Action.EOutCubic});

	x = self:IsPortraitView() and 0 or 110
	local btnClose = self:FindChild("BtnClose");
	self:RunAction(btnClose, {"localMoveBy", x, 0, 0.5, ease = CC.Action.EOutCubic});

	local mask = self:FindChild("Mask");
	self:RunAction(mask, {"fadeTo", 0, 0.5});

	self.currentView:ActionHide();
end

function FreeChipsCollectionView:OnDestroy()

	self:UnRegisterEvent();

	if self.currentView then

		self.currentView:Destroy();
	end

	if self.musicName then
		CC.Sound.PlayHallBackMusic(self.musicName);
	else
		CC.Sound.StopBackMusic();
	end

	if self.GaussBlur then

		self.GaussBlur.enabled = false;
	end

	for _,v in ipairs(self.btnList) do
		v.toggle = nil
	end
	self.btnList = {}
end

return FreeChipsCollectionView