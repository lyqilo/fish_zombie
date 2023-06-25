local CC = require("CC")
local DailyGiftCollectionView = CC.uu.ClassView("DailyGiftCollectionView")

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
function DailyGiftCollectionView:ctor(param)
	self:InitVar(param);
	self:LoadGiftStatus()
	self:RegisterEvent();
end

function DailyGiftCollectionView:InitVar(param)
	self.param = param or {}
	self.subViewCfg = {
		--月末假日礼包
		{viewName = "HolidayDiscountsView", btnName = "btn_Holiday", Source = {},},
		--游戏每日礼包
		{viewName = "DailyGiftBuyu", btnName = "btn_Buyu", Source = {CC.shared_transfer_source_pb.TS_2Fish_DailyGift_29,
			CC.shared_transfer_source_pb.TS_2Fish_DailyGift_50, CC.shared_transfer_source_pb.TS_2Fish_DailyGift_150,
			CC.shared_transfer_source_pb.TS_2Fish_DailyGift_500, CC.shared_transfer_source_pb.TS_2Fish_DailyGift_1000,},},
		{viewName = "DailyGiftFourBuyu", btnName = "btn_FourBuyu", Source = {CC.shared_transfer_source_pb.TS_4Fish_DailyGift_29,
			CC.shared_transfer_source_pb.TS_4Fish_DailyGift_50, CC.shared_transfer_source_pb.TS_4Fish_DailyGift_150,
			CC.shared_transfer_source_pb.TS_4Fish_DailyGift_500, CC.shared_transfer_source_pb.TS_4Fish_DailyGift_1000,}},
        {viewName = "DailyGiftDummy", btnName = "btn_Dummy", Source = {CC.shared_transfer_source_pb.TS_Dummy_DailyGift_29,
			CC.shared_transfer_source_pb.TS_Dummy_DailyGift_50, CC.shared_transfer_source_pb.TS_Dummy_DailyGift_150,
			CC.shared_transfer_source_pb.TS_Dummy_DailyGift_500, CC.shared_transfer_source_pb.TS_Dummy_DailyGift_1000,}},
		{viewName = "DailyGiftAirplane", btnName = "btn_Airplane", Source = {CC.shared_transfer_source_pb.TS_Plane_DailyGift_29,
			CC.shared_transfer_source_pb.TS_Plane_DailyGift_50, CC.shared_transfer_source_pb.TS_Plane_DailyGift_150,
			CC.shared_transfer_source_pb.TS_Plane_DailyGift_500, CC.shared_transfer_source_pb.TS_Plane_DailyGift_1000,}},
		{viewName = "DailyGiftDiglett", btnName = "btn_Diglett", Source = {CC.shared_transfer_source_pb.TS_Rat_DailyGift_29,
			CC.shared_transfer_source_pb.TS_Rat_DailyGift_50, CC.shared_transfer_source_pb.TS_Rat_DailyGift_150,
			CC.shared_transfer_source_pb.TS_Rat_DailyGift_500, CC.shared_transfer_source_pb.TS_Rat_DailyGift_1000,}},
		{viewName = "DailyGiftZombie", btnName = "btn_Zombie", Source = {CC.shared_transfer_source_pb.TS_TD_DailyGift_29,
			CC.shared_transfer_source_pb.TS_TD_DailyGift_50, CC.shared_transfer_source_pb.TS_TD_DailyGift_150,
			CC.shared_transfer_source_pb.TS_TD_DailyGift_500, CC.shared_transfer_source_pb.TS_TD_DailyGift_1000,}},
		{viewName = "DailyGiftPokdeng", btnName = "btn_Pokdeng", Source = {CC.shared_transfer_source_pb.TS_Pokdeng_DailyGift_29,
			CC.shared_transfer_source_pb.TS_Pokdeng_DailyGift_50, CC.shared_transfer_source_pb.TS_Pokdeng_DailyGift_150,
			CC.shared_transfer_source_pb.TS_Pokdeng_DailyGift_500, CC.shared_transfer_source_pb.TS_Pokdeng_DailyGift_1000,}},
		-- {viewName = "DailyGiftBull", btnName = "btn_Bull", Source = {CC.shared_transfer_source_pb.TS_Cow_DailyGift_29,
		-- 	CC.shared_transfer_source_pb.TS_Cow_DailyGift_50, CC.shared_transfer_source_pb.TS_Cow_DailyGift_150,
		-- 	CC.shared_transfer_source_pb.TS_Cow_DailyGift_500, CC.shared_transfer_source_pb.TS_Cow_DailyGift_1000,}},
		-- {viewName = "DailyGiftPharaoh", btnName = "btn_Pharaoh", Source = {CC.shared_transfer_source_pb.TS_RatLuan_DailyGift_29,
		-- 	CC.shared_transfer_source_pb.TS_RatLuan_DailyGift_50, CC.shared_transfer_source_pb.TS_RatLuan_DailyGift_150,
		-- 	CC.shared_transfer_source_pb.TS_RatLuan_DailyGift_500, CC.shared_transfer_source_pb.TS_RatLuan_DailyGift_1000,}},
	}

	--监听隐藏或显示消息时，不需要多次执行位移操作
	self.showState = nil
	self.hideState = nil

	self.isInit = true
	self.btnList = {};
	self.currentView = nil;
	self.language = CC.LanguageManager.GetLanguage("L_DailyGiftCollectionView")
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");
	self.musicName = nil
end

function DailyGiftCollectionView:LoadGiftStatus()
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
		"30129", "30130", "30131", "30132", "30133"
	}
	CC.Request("GetOrderStatus",wareIds)
end

function DailyGiftCollectionView:OnCreate()
	if self.param.openFunc then
		self.param.openFunc()
	end

	--每日礼包每日签到入口
	self.signInSpine = self:FindChild("SignInBtn/Spine"):GetComponent("SkeletonGraphic")
	self.signFreeIcon = self:FindChild("SignInBtn/FreeChip")

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
			btnItem.btn:SetActive(switchOn)
		end
	end

	self:AddClick("BtnClose", "ActionOut");

	self:AddClick("SignInBtn","OpenSignInView")

	if self.param.currentView then
		for index, v in ipairs(self.btnList) do
			if self.param.currentView == v.viewName and self.activityDataMgr.GetActivityInfoByKey(v.viewName).switchOn then
                btnIndex = index;
                break
			end
		end
	end
	self.btnList[btnIndex].btn:GetComponent("Toggle").isOn = true;

	--self:OnRefreshRedDot();

	self:DelayRun(0.1, function()
			self.musicName = CC.Sound.GetMusicName()
			CC.Sound.PlayHallBackMusic("BGM_SelectGiftCollection");
		end)

	if self.activityDataMgr.GetActivityInfoByKey("GiftSignInView").switchOn then
		CC.Request("ReqLoadDailyGiftSignInfo")
	end
end

--得到礼包界面
function DailyGiftCollectionView:GetSelectGiftTab()
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

function DailyGiftCollectionView:CreateBtnItem(cfg)
	local t = {};
	t.btn = CC.uu.newObject(self.btnPrefab, self.btnRoot)
	t.btn.name = cfg.btnName
	t.btn:SetActive(true);
	t.redDot = t.btn:FindChild("RedDot");
	t.viewName = cfg.viewName;
	t.parent = self:FindChild("Content")
	t.toggle = t.btn:GetComponent("Toggle");
	UIEvent.AddToggleValueChange(t.btn, function(selected)
			if selected then
				--选中按钮后销毁上一个显示的界面并创建当前按钮指向的界面
				if self.currentView then
					if self.currentView.viewName == t.viewName then
						--选中和当前界面一样
						return
					end
					self.currentView:ActionOut();
				end
				self.currentView = CC.uu.CreateHallView(cfg.viewName, t.parent,self.language, self.param.isHall);
				self.currentView.transform:SetParent(self:FindChild("Content"), false);
				self.currentView:ActionIn();
				
				if self:IsPortraitView() then
					if CC.DefineCenter.Inst():getConfigDataByKey("HallDefine").PortraitSupport[cfg.viewName] then
						self:FindChild("Content").localScale = Vector3.one
						self:FindChild("Content").localPosition = Vector3(0,-80,0)
						self:FindChild("Content").sizeDelta = Vector2(0, -560)
					else
						--没做竖屏适配的界面先简单做个缩放
						self:FindChild("Content").localScale = Vector3(0.65,0.65,0.65)
						self:FindChild("Content").localPosition = Vector3(-45,-80,0)
						self:FindChild("Content").sizeDelta = Vector2(90, -560)
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

function DailyGiftCollectionView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshSwitchOn,CC.Notifications.OnRefreshActivityBtnsState)
	CC.HallNotificationCenter.inst():register(self,self.OnSetViewState,CC.Notifications.OnShowDailyGiftCollectionView);
	CC.HallNotificationCenter.inst():register(self,self.OnLoadDailyGiftSignInfoRsp,CC.Notifications.NW_ReqLoadDailyGiftSignInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnDailyGiftSignRsp,CC.Notifications.NW_ReqDailyGiftSign)
	CC.HallNotificationCenter.inst():register(self,self.DailyGiftBuy,CC.Notifications.OnDailyGiftGameReward)
	CC.HallNotificationCenter.inst():register(self,self.GetOrderStatusResp,CC.Notifications.NW_GetOrderStatus)

end

function DailyGiftCollectionView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function DailyGiftCollectionView:GetOrderStatusResp(err,data)
	log(CC.uu.Dump(data, "wareIds", 10))
	if err == 0 then
		if data.Items then
			for _, v in ipairs(data.Items) do
				self.activityDataMgr.SetGiftStatus(v.WareId, v.Enabled)
			end
		end
		self.activityDataMgr.SetReqGiftState(true)
	end
end

function DailyGiftCollectionView:OnLoadDailyGiftSignInfoRsp(err,data)
	if err == 0 then
		--local clickFlag = data.ClickFlag
		self.signFreeIcon:SetActive(false)
		self:RefreshGiftSignInBtn(data)
	end
end

function DailyGiftCollectionView:OnDailyGiftSignRsp(err,data)
	if err == 0 then
		self:RefreshGiftSignInBtn(data)
	end
end

function DailyGiftCollectionView:RefreshGiftSignInBtn(data)
	if self.isInit then
		self.isInit = false
		self:DelayRun(1,function ()
			self:ShowSignInBtn(true)
		end)
	end
	local ableSignTimes = data.AbleSignTimes
	if ableSignTimes > 0 then
		if self.signInSpine then
			self.signInSpine.AnimationState:ClearTracks()
			self.signInSpine.AnimationState:SetAnimation(0, "stand02", true)
		end
	else
		if self.signInSpine then
			self.signInSpine.AnimationState:ClearTracks()
			self.signInSpine.AnimationState:SetAnimation(0, "stand01", true)
		end
	end
end

function DailyGiftCollectionView:OnRefreshSwitchOn(key, switchOn)
	--目前只控制每日礼包签到抽奖
	self:ShowSignInBtn(self.activityDataMgr.GetActivityInfoByKey("GiftSignInView").switchOn)
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
			break
		end
	end
end

function DailyGiftCollectionView:ShowSignInBtn(bState)
	local btnSignIn = self:FindChild("SignInBtn")
	if bState then
		btnSignIn.localPosition = Vector3(605,265,0)
	else
		btnSignIn.localPosition = Vector3(1300,250,0)
	end
end

function DailyGiftCollectionView:OnRefreshRedDot(key,redDot)
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

function DailyGiftCollectionView:DailyGiftBuy(param)
	if not self.activityDataMgr.GetActivityInfoByKey("GiftSignInView").switchOn then return end
	for _,k in ipairs(self.subViewCfg) do
		for _, v in ipairs(k.Source) do
			if param.Source == v then
				self:OpenSignInView()
				break
			end
		end
	end
end

function DailyGiftCollectionView:OpenSignInView()
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowDailyGiftCollectionView, false);

	CC.ViewManager.Open("GiftSignInView", {closeFunc = function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowDailyGiftCollectionView, true);
	end});
end

function DailyGiftCollectionView:OnFocusIn()
	if not self.currentView or not self.currentView.OnFocusIn then return end;
	self.currentView:OnFocusIn();
end

function DailyGiftCollectionView:OnFocusOut()
	if not self.currentView or not self.currentView.OnFocusOut then return end;
	self.currentView:OnFocusOut();
end

function DailyGiftCollectionView:ActionIn()

	self:SetCanClick(false);
	
	local x = self:IsPortraitView() and 0 or 200
	local leftPanel = self:FindChild("LeftPanel");
	self:RunAction(leftPanel, {"localMoveBy", x, 0, 0.5, ease = CC.Action.EOutCubic});
	
	x = self:IsPortraitView() and 0 or -110
	local btnClose = self:FindChild("BtnClose");
	self:RunAction(btnClose, {"localMoveBy", x, 0, 0.5, ease = CC.Action.EOutCubic});
	
	if self.activityDataMgr.GetActivityInfoByKey("GiftSignInView").switchOn and not self.isInit then
		self:ShowSignInBtn(true)
	end

	local mask = self:FindChild("Mask");
	self:RunAction(mask, {"fadeTo", 200, 0.5, function() self:SetCanClick(true); end});
end

function DailyGiftCollectionView:ActionOut()

	self:SetCanClick(false);
	
	local x = self:IsPortraitView() and 0 or -200
	local leftPanel = self:FindChild("LeftPanel");
	self:RunAction(leftPanel, {"localMoveBy", x, 0, 0.5, ease = CC.Action.EOutCubic});
	
	x = self:IsPortraitView() and 0 or 110
	local btnClose = self:FindChild("BtnClose");
	self:RunAction(btnClose, {"localMoveBy", x, 0, 0.5, ease = CC.Action.EOutCubic});
	
	self:ShowSignInBtn(false)

	if self.currentView then
		self.currentView:ActionOut();
		self.currentView = nil;
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

function DailyGiftCollectionView:OnSetViewState(flag)
	if flag then
		self.showState = true
		self.hideState = false
		self:ActionShow();
	else
		self.showState = false
		self.hideState = true
		self:ActionHide();
	end
end

function DailyGiftCollectionView:ActionShow()
	if self.showState then return end
	self:ActionIn();

	self.currentView:ActionShow();
end

function DailyGiftCollectionView:ActionHide()
	if self.hideState then return end
	self:SetCanClick(false);

	local x = self:IsPortraitView() and 0 or -200
	local leftPanel = self:FindChild("LeftPanel");
	self:RunAction(leftPanel, {"localMoveBy", x, 0, 0.5, ease = CC.Action.EOutCubic});

	x = self:IsPortraitView() and 0 or 110
	local btnClose = self:FindChild("BtnClose");
	self:RunAction(btnClose, {"localMoveBy", 110, 0, 0.5, ease = CC.Action.EOutCubic});

	self:ShowSignInBtn(false)

	local mask = self:FindChild("Mask");
	self:RunAction(mask, {"fadeTo", 0, 0.5});

	self.currentView:ActionHide();
end

function DailyGiftCollectionView:OnDestroy()
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
end

return DailyGiftCollectionView