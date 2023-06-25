local CC = require("CC")
local ActivityCollectionView = CC.uu.ClassView("ActivityCollectionView")

--[[
@param
currentView: 打开合集后第一个显示的界面
viewParams:  各个界面的传参(需把viewName作为key)
openFunc:    打开界面的回调
closeFunc:   界面关闭的回调
]]
function ActivityCollectionView:ctor(param)
	self:InitVar(param);
	self:RegisterEvent();
end

function ActivityCollectionView:InitVar(param)
	self.param = param or {}
	self.subViewCfg = {
		-- {viewName = "ComposeCapsuleView", btnName = "btn_ComposeCapsule"},
		-- {viewName = "CompositeView", btnName = "btn_Composite"},
		-- {viewName = "CompositeGiftView", btnName = "btn_CompositeGift"},
		{viewName = "MonopolyView", btnName = "btn_Monopoly"},
		{viewName = "MonopolyRankView", btnName = "btn_MonopolyRank"},
		{viewName = "SuperDailyGiftView", btnName = "btn_SuperDailyGift"},
		{viewName = "ActSignInView", btnName = "BtnActSignIn",},
		{viewName = "WaterCaptureRankView", btnName = "waterCaptureBtn",},
		{viewName = "WaterOtherRankView", btnName = "waterOtherBtn",},
		-- {viewName = "OnlineLottery", btnName = "BtnOnlineLottery"},
		-- {viewName = "DailyLotteryView", btnName = "BtnDailyLottery"},
        {viewName = "GiftExchangeView", btnName = "btn_TreasureGift"},
        {viewName = "SuperTreasureView", btnName = "btn_SuperTreasure"},
		{viewName = "MonthRankView", btnName = "btn_Rank"},
	}

	self.btnList = {};
	self.currentView = nil;
	self.language = CC.LanguageManager.GetLanguage("L_ActivityCollectionView")
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");
	self.musicName = CC.Sound.GetMusicName()
	if not CC.ViewManager.IsHallScene() then
		self.saveTimeScale = Time:SetTimeScale(1)
	end
end

function ActivityCollectionView:OnCreate()
	if self.param.openFunc then
		self.param.openFunc()
	end

	self.btnRoot = self:FindChild("LeftPanel/BtnList")
	self.btnPrefab = self:FindChild("LeftPanel/BtnList/Btn")
	self.btnPrefab:SetActive(false)
	--设置当前显示的界面
	local btnIndex = 1;
	for i, cfg in ipairs(self:GetSelectGiftTab()) do
		local activityData = self.activityDataMgr.GetActivityInfoByKey(cfg.viewName)
		if activityData then
			local switchOn = activityData.switchOn or activityData.Show
			local btnItem = self:CreateBtnItem(cfg);
			table.insert(self.btnList, btnItem);
			if not switchOn then
				if btnIndex == i then
					btnIndex = btnIndex + 1
				end
			end
			btnItem.btn:SetActive(switchOn)
		end
	end

	self:AddClick("BtnClose", "ActionOut");
	self:AddClick("BtnShare", "OnClickShareActivity");
	self:FindChild("BtnShare"):SetActive(false)

	if self.param.currentView then
		for index, v in ipairs(self.btnList) do
			if self.param.currentView == v.viewName and self.activityDataMgr.GetActivityInfoByKey(v.viewName).switchOn then
                btnIndex = index;
                break
			end
		end
    end
    if self.btnList[btnIndex] then
        self.btnList[btnIndex].btn:GetComponent("Toggle").isOn = true;
    end
	self:DelayRun(0.1, function()
			CC.Sound.PlayHallBackMusic("BGM_Hall_Water");
		end)
end

--得到礼包界面
function ActivityCollectionView:GetSelectGiftTab()
	local temp = {}
	if self.param.SelectGiftTab then
		for _,v in pairs(self.param.SelectGiftTab) do
			for _,k in ipairs(self.subViewCfg) do
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

function ActivityCollectionView:CreateBtnItem(cfg)
	local t = {};
	t.btn = CC.uu.newObject(self.btnPrefab, self.btnRoot)
	t.btn.name = cfg.btnName
	t.btn:SetActive(true);
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
				local viewName = cfg.viewName
				if cfg.viewName == "WaterCaptureRankView" or cfg.viewName == "WaterOtherRankView" then
					viewName = "WaterRankView"
					t.viewParam.gameType = cfg.btnName
					t.viewParam.viewName = cfg.viewName
					t.viewParam.isOffset = true
				end
				self.currentView = CC.uu.CreateHallView(viewName, t.viewParam,self.language);
				self.currentView.transform:SetParent(self:FindChild("Content"), false);
				self.currentView:ActionIn();
			end
		end)

	t.btn:FindChild("Text").text = self.language[cfg.btnName];
	t.btn:FindChild("Selected/Text").text = self.language[cfg.btnName];
	return t;
end

function ActivityCollectionView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshSwitchOn,CC.Notifications.OnRefreshActivityBtnsState)
	CC.HallNotificationCenter.inst():register(self,self.JumpToView,CC.Notifications.OnCollectionViewJumpToView)
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshMidActive,CC.Notifications.OnRefreshMidActiveBtn)
end

function ActivityCollectionView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function ActivityCollectionView:OnRefreshSwitchOn(key, switchOn)
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

--跳转到指定界面
function ActivityCollectionView:JumpToView(viewName)
	if self.currentView and self.currentView.viewName == viewName then return end
	local btnIndex = nil
	for index, v in ipairs(self.btnList) do
		if viewName == v.viewName and self.activityDataMgr.GetActivityInfoByKey(viewName).switchOn then
			btnIndex = index;
			break
		end
	end
	if btnIndex then
        self.btnList[btnIndex].btn:GetComponent("Toggle").isOn = true;
    end
end

function ActivityCollectionView:OnRefreshMidActive(isShow)
	if not isShow then
		self:ActionOut()
	end
end

function ActivityCollectionView:OnClickShareActivity()
	CC.ViewManager.Open("ActiveShareBoard");
end

function ActivityCollectionView:OnFocusIn()
	if not self.currentView or not self.currentView.OnFocusIn then return end;
	self.currentView:OnFocusIn();
end

function ActivityCollectionView:OnFocusOut()
	if not self.currentView or not self.currentView.OnFocusOut then return end;
	self.currentView:OnFocusOut();
end

function ActivityCollectionView:ActionIn()
	self:SetCanClick(false);
	local leftPanel = self:FindChild("LeftPanel");
	self:RunAction(leftPanel, {"localMoveBy", 200, 0, 0.5, ease = CC.Action.EOutCubic});
	local btnClose = self:FindChild("BtnClose");
	self:RunAction(btnClose, {"localMoveBy", -110, 0, 0.5, ease = CC.Action.EOutCubic});

	local mask = self:FindChild("Mask");
	self:RunAction(mask, {"fadeTo", 200, 0.5, function() self:SetCanClick(true); end});
end

function ActivityCollectionView:ActionOut()
	self:SetCanClick(false);
	local leftPanel = self:FindChild("LeftPanel");
	self:RunAction(leftPanel, {"localMoveBy", -200, 0, 0.5, ease = CC.Action.EOutCubic});
	local btnClose = self:FindChild("BtnClose");
	self:RunAction(btnClose, {"localMoveBy", 110, 0, 0.5, ease = CC.Action.EOutCubic});

    if self.currentView then
        self.currentView:ActionOut()
        self.currentView = nil
    end

	local mask = self:FindChild("Mask");
	self:RunAction(mask, {"fadeTo", 0, 0.5, function()
		self:Destroy()
		if self.param.closeFunc then
			self.param.closeFunc();
		end
	end});
	self:UnRegisterEvent();
end

function ActivityCollectionView:OnDestroy()
	self:UnRegisterEvent();
	if self.currentView then
		self.currentView:Destroy();
	end
	if self.musicName then
		CC.Sound.PlayHallBackMusic(self.musicName);
	else
		CC.Sound.StopBackMusic();
	end
	if self.saveTimeScale then
		Time:SetTimeScale(self.saveTimeScale)
	end

	for _,v in ipairs(self.btnList) do
		v.toggle = nil
	end
end

return ActivityCollectionView