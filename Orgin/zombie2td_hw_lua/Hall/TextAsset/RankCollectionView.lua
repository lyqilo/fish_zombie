---------------------------------
-- region RankCollectionView.lua    -
-- Date: 2020.03.20        -
-- Desc: 排行榜合集  -
-- Author: Chaoe        -
---------------------------------
local CC = require("CC")
local RankCollectionView = CC.uu.ClassView("RankCollectionView")

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


function RankCollectionView:ctor(param)
    self:InitVar(param);

	self:RegisterEvent();
end

function RankCollectionView:InitVar(param)
    self.param = param or {};

	self.subViewCfg = {
		{
			viewName = "TotalWaterRankView",
			btnName = "TotalWaterBtn",
		},
		{
			viewName = "WaterCaptureRankView",
			btnName = "waterCaptureBtn",
		},
		{
			viewName = "WaterOtherRankView",
			btnName = "waterOtherBtn",
		},
		{
			viewName = "BatteryRankView",
			btnName = "BatteryRankBtn"
		},
		{
			viewName = "MonthRankView",
			btnName = "MonthRankBtn"
		},
		{
			viewName = "SongkranRankView",
			btnName = "SongkranRankBtn"
		},
		{
			viewName = "RankingListView",
			btnName = "RankingListBtn",
		},
		{
			viewName = "WeekRankView",
			btnName = "WeekRankBtn",
		}
    }

    self.btnList = {};

	self.currentView = nil;

	self.musicName = nil;

	self.language = CC.LanguageManager.GetLanguage("L_RankCollectionView");

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");
end

function RankCollectionView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnRefreshRankBtnsList, CC.Notifications.OnRefreshActivityBtnsState)

end

function RankCollectionView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnRefreshActivityBtnsState)

end

function RankCollectionView:GetSelectGiftTab()
	local temp = {}
	if self.param.selectTab then
		for _,v in pairs(self.param.selectTab) do
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

function RankCollectionView:OnCreate()

	if self.param.openFunc then
		self.param.openFunc();
	end

	self.btnRoot = self:FindChild("LeftPanel/Scroll View/Viewport/BtnList")
	self.btnPrefab = self:FindChild("LeftPanel/Scroll View/Viewport/BtnList/Btn")
	self.btnPrefab:SetActive(false)

	--设置当前显示的界面
	local btnIndex = 1;

	for i, cfg in ipairs(self:GetSelectGiftTab()) do
		local activityData = self.activityDataMgr.GetActivityInfoByKey(cfg.viewName)
		if activityData then
			local switchOn = activityData.switchOn

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

	self:AddClick("BtnClose", "ActionOut");

	if self.param.currentView then

		for index, v in ipairs(self.btnList) do

			if self.param.currentView == v.viewName and self.activityDataMgr.GetActivityInfoByKey(self.param.currentView).switchOn then

				btnIndex = index;
			end
		end
    end

	self.btnList[btnIndex].toggle.isOn = true;

	-- self:DelayRun(0.1, function()
	-- 	self.musicName = CC.Sound.GetMusicName();
	-- 	--周年庆期间合集用这个背景音乐
	-- 	CC.Sound.PlayHallBackMusic("HalloweenBg");
	-- end)
end

function RankCollectionView:CreateBtnItem(cfg)

	local t = {};

	t.btn = CC.uu.newObject(self.btnPrefab, self.btnRoot)
	t.btn.name = cfg.btnName

	t.btn:SetActive(true);

	-- t.redDot = t.btn:FindChild("RedDot");

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
				end
				self.currentView = CC.uu.CreateHallView(viewName, t.viewParam);

				self.currentView.transform:SetParent(self:FindChild("Content"), false);

				self.currentView:ActionIn();

				-- t.redDot.x = 115;
			else
				-- t.redDot.x = 95;
			end
        end)

	t.btn:FindChild("Text").text = self.language[cfg.btnName];

	t.btn:FindChild("Selected/Text").text = self.language[cfg.btnName];

	return t;
end

function RankCollectionView:OnFocusIn()

	if not self.currentView or not self.currentView.OnFocusIn then return end;

	self.currentView:OnFocusIn();
end

function RankCollectionView:OnFocusOut()

	if not self.currentView or not self.currentView.OnFocusOut then return end;

	self.currentView:OnFocusOut();
end

function RankCollectionView:OnRefreshRankBtnsList(key,switchOn)
	for i,v in ipairs(self.btnList) do
		if key == v.viewName then
			-- 关闭了当前界面，自动选择最前面一个界面
			if switchOn == false and self.currentView and self.currentView.viewName == key then
				local btnIndex = 0
				for j,v2 in ipairs(self.btnList) do
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
		end
	end
end

function RankCollectionView:ActionIn()

	self:SetCanClick(false);

	local leftPanel = self:FindChild("LeftPanel");
	self:RunAction(leftPanel, {"localMoveBy", 200, 0, 0.5, ease = CC.Action.EOutCubic});

	local btnClose = self:FindChild("BtnClose");
	self:RunAction(btnClose, {"localMoveBy", -110, 0, 0.5, ease = CC.Action.EOutCubic});

	local mask = self:FindChild("Mask");
	self:RunAction(mask, {"fadeTo", 200, 0.5, function() self:SetCanClick(true); end});
end

function RankCollectionView:ActionOut(openView)

	self:SetCanClick(false);

	local leftPanel = self:FindChild("LeftPanel");
	self:RunAction(leftPanel, {"localMoveBy", -200, 0, 0.5, ease = CC.Action.EOutCubic});

	local btnClose = self:FindChild("BtnClose");
	self:RunAction(btnClose, {"localMoveBy", 110, -10, 0.5, ease = CC.Action.EOutCubic});

	self.currentView:ActionOut();

	self.currentView = nil;

	local mask = self:FindChild("Mask");
	self:RunAction(mask, {"fadeTo", 0, 0.5, function()
		if openView then
			CC.ViewManager.Open(openView)
		end
		self:Destroy()
		if self.param.closeFunc then
			self.param.closeFunc();
		end
	end});

	self:UnRegisterEvent();
end

function RankCollectionView:OnDestroy()

	-- if self.musicName then
	-- 	CC.Sound.PlayHallBackMusic(self.musicName);
	-- else
	-- 	CC.Sound.StopBackMusic();
	-- end

	CC.DataMgrCenter.Inst():GetDataByKey("RankData").ClearData()

	self:UnRegisterEvent();

	if self.currentView then
		self.currentView:Destroy();
	end

	for _,v in ipairs(self.btnList) do
		v.toggle = nil
	end
	self.btnList = {}
end


return RankCollectionView