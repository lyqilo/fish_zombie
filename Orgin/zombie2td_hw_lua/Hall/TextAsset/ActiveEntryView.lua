local CC = require("CC")

local View = CC.uu.ClassView("ActiveEntryView")

function View:ctor(param)
	self.language = self:GetLanguage()
	self.param = param or {}
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self.createTime = os.time()+math.random()
	self.curPanel = nil
	--使用Panel_1 时修改
	self.OpenViewList = {"FreeChipsCollectionView","SelectGiftCollectionView","DailyGiftCollectionView","FreeChipsCollectionView"}
	self.OpenSubViewList = {"DailyLotteryView","NewPayGiftView","HolidayDiscountsView","HalloweenLoginGiftView"}
	--使用Panel_2 时修改
	self.OpenViewListMid = {"FreeChipsCollectionView","SelectGiftCollectionView","RankCollectionView","RankCollectionView"}
	self.OpenSubViewListMid = {"BlessLotteryView","SuperDailyGiftView", "WaterCaptureRankView", "WaterOtherRankView"}
	--使用Panel_3 时修改
	self.OpenViewListSp = {"FreeChipsCollectionView","DailyGiftCollectionView","SelectGiftCollectionView","FreeChipsCollectionView"}
	self.OpenSubViewListSp = {"DailyLotteryView","HolidayDiscountsView","NewPayGiftView","HalloweenLoginGiftView"}

	self.BannerList = {1001,1001,1001,3002,3007}
	--滚动组的数量
	self.rollNum = 0
	self.musicName = nil
end

function View:OnCreate()
	self:InitContent()
	self:InitTextByLanguage()
	self:RegisterEvent();

	-- if self.param.mid then
	 	self.musicName = CC.Sound.GetMusicName();
	 	CC.Sound.PlayHallBackMusic("BGM_ActivityMonthly");
	-- end
end

function View:InitContent()
    --self:SetCanClick(false)
	self.btnList = {}

	local showBanner = true
	if self.param.mid then
		self.curPanel = self:FindChild("Panel_2")
		self.OpenSubViewList = self.OpenSubViewListMid
		self.OpenViewList = self.OpenViewListMid
	elseif self.param.special then
		self.curPanel = self:FindChild("Panel_3")
		self.OpenSubViewList = self.OpenSubViewListSp
		self.OpenViewList = self.OpenViewListSp
		showBanner = false
	else
		self.curPanel = self:FindChild("Panel_1")
	end
	self.curPanel:SetActive(true)
	-- self.curPanel:FindChild("Banner"):SetActive(showBanner)
	--self.curPanel:FindChild("BannerTopPic"):SetActive(showBanner)

	self:AddClick(self.curPanel:FindChild("BtnClose"),function()
		local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level");
		if vipLevel < 3 and not CC.LocalGameData.GetLocalStateToKey("firstActiveEntry") then
			CC.LocalGameData.SetLocalStateToKey("firstActiveEntry", true);
			self:OnClickBtnVip3();
			return
		end
		self:Destroy();
	end)

	for i=1, #self.OpenSubViewList do
		local viewKey = self.OpenSubViewList[i];
		local item = self:CreateActBtn(i, viewKey);
		table.insert(self.btnList, item)
	end

	self:AddClick(self.curPanel:FindChild("BtnShare"), "OnClickShareActivity");
	self.curPanel:FindChild("BtnShare"):SetActive(false)
	self:AddClick("BtnGroup/BtnVip3/zsk", "OnClickBtnVip3");
	self:AddClick("BtnGroup/BtnBattery/Icon", function()
		-- CC.ViewManager.Open("SelectGiftCollectionView", {currentView = "BatteryLotteryView"})
		CC.ViewManager.Open("FreeChipsCollectionView", {currentView = "CapsuleView"})
	end)
	self:AddClick("BtnGroup/BtnCapsule/Icon", function()
		CC.ViewManager.Open("FreeChipsCollectionView", {currentView = "CapsuleView"})
	end)
	self:AddClick("BtnGroup/BtnHolidayGift/Icon",function ()
			CC.ViewManager.Open("SelectGiftCollectionView", {currentView = "CommonHolidayGiftView"})
		end)
	if self.param.mid then
		-- for i = 2, self.rollNum do
		-- 	local bannerId = i
		-- 	local obj = self:FindChild("Panel_2/Banner/group"..bannerId)
		-- 	self:AddClick(obj,function ()
		-- 		CC.ViewManager.Open("ArenaView")
		-- 		self:Destroy()
		-- 	end)
		-- 	obj:SetActive(true)
		-- end
		-- --跳转游戏
		-- self:AddClick(string.format("Panel_2/Banner/group%s", 1),function ()
		-- 	self:GoToGame(3003);
		-- end)
	else
		for i = 1, self.rollNum do
			local bannerId = i
			local obj = self:FindChild("Panel_1/Banner/group"..bannerId)
			self:AddClick(obj,function ()
				if i < 4 then
					CC.ViewManager.Open("ArenaView")
					self:Destroy()
				end
			end)
			obj:SetActive(true) 
		end
	end

	local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level");
	self:VipChanged(vipLevel)
	self:RefreshBtnStatus()

	self:BannerInitRoll(true)

	-- if self.param.mid then
	-- 	self:BannerInitRoll()
	-- else
	-- 	self:BannerInit()
	-- end

	local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("Monthendrebate") and CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("MonthRebateView").switchOn
	self:FindChild("RebateBtn"):SetActive(switchOn)
	self:AddClick("RebateBtn",function ()
		CC.ViewManager.Open("MonthRebateView")
	end)
end

function View:InitTextByLanguage()
	self:FindChild("BtnGroup/BtnHolidayGift/Text").text =self.language.btnHolidayGift
	self:FindChild("BtnGroup/BtnCapsule/BtnGo/Text").text = self.language.btnGo
	self:FindChild("BtnGroup/BtnBattery/Text").text = self.language.BatteryEntryName
end

function View:BannerInitRoll(isRoll)
    self.bannerHeight = self.curPanel:FindChild("Banner"):GetComponent('RectTransform').rect.height
	self.bannerGroupLong = self.curPanel:FindChild("Banner"):GetComponent('RectTransform').rect.width
    self.groupAll = {}
	for i = 1, self.rollNum do
		self.groupAll[i] = self.curPanel:FindChild("Banner/group" .. i)
		if isRoll then
			self.groupAll[i].localPosition = Vector3(0, (1 - i) * self.bannerHeight, 0)
		else
			self.groupAll[i].localPosition = Vector3((i - 1) * self.bannerGroupLong, -5, 0)
		end
	end

	if #self.groupAll < 2 then return end
	local countDown = 1
	local initTime = 3
	self:StartTimer("countDown"..self.createTime, 1, function ()
		countDown = countDown - 1
		if countDown < 0 then
			countDown = initTime
			if isRoll then
				self:AutoRoll()
			else
				self:BannerMoveLoop()
			end
		end
	end,-1)
end

--上下滑动
function View:AutoRoll()
    for i = 1, self.rollNum do
		local obj = self.groupAll[i]
		self:RunAction(obj,  {"localMoveTo", 0, obj.localPosition.y + self.bannerHeight, 2 , function ()
			if obj.localPosition.y >= self.bannerHeight then
				obj.localPosition = Vector3(0, obj.localPosition.y - self.rollNum * self.bannerHeight, 0)
			end
		end})
	end
end

--左右滑动
function View:BannerMoveLoop()
	for i = 1, self.rollNum do
		local obj = self.groupAll[i]
		self:RunAction(obj,  {"localMoveTo", obj.localPosition.x - self.bannerGroupLong, -5, 5, function ()
			if obj.localPosition.x <= -self.bannerGroupLong then
				obj.localPosition = Vector3(obj.localPosition.x + self.rollNum * self.bannerGroupLong, -5, 0)
			end
		end})
	end
end

function View:CreateActBtn(index, viewKey)
	local item = {};
	item.viewKey = viewKey;
	item.btn = self.curPanel:FindChild("Group/btn"..index);
	item.des = item.btn:FindChild("Text")
	item.des.text = self.language[viewKey]
	item.time = item.btn:FindChild("Image/Time")
	if self.param.mid then
		item.time.text = self.language[string.format("time%s_2", index)]
	else
		item.time.text = self.language["time"..index]
	end
	item.corner = item.btn:FindChild("Effect_UI_psj_qp/TuBiao/Text");
	item.corner.text = self.language.tips1;

	item.refreshUI = function()
		local switchOn = self.activityDataMgr.GetActivityInfoByKey(viewKey).switchOn
		if viewKey == "HalloweenLoginGiftView" then
			switchOn = switchOn and CC.HallUtil.ShowHalloweenLoginGift()
		end
		item.btn:SetActive(switchOn);
	end
	item.refreshUI();

	self:AddClick(item.btn,function()
		    local switchOn = self.activityDataMgr.GetActivityInfoByKey(viewKey).switchOn
		    if viewKey == "HalloweenLoginGiftView" then
				switchOn = switchOn and CC.HallUtil.ShowHalloweenLoginGift()
			end
		
			if not switchOn then return end;
			CC.ViewManager.Open(self.OpenViewList[index],{currentView = viewKey});
			self:Destroy();
		end)

	return item
end

function View:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnRefreshRankBtnsList, CC.Notifications.OnRefreshActiveEntryBtn)
	CC.HallNotificationCenter.inst():register(self,self.RefreshBtnStatus,CC.Notifications.OnRefreshActivityBtnsState)
	CC.HallNotificationCenter.inst():register(self,self.VipChanged,CC.Notifications.VipChanged)
end

function View:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function View:GoToGame(gameId)
	local gameInfo = self.gameDataMgr.GetInfoByID(gameId)
	if gameInfo.IsCommingSoon == 1 then
		CC.ViewManager.ShowTip(self.language.tips2)
	else
		CC.HallUtil.CheckAndEnter(gameId)
	end
end

function View:OnRefreshRankBtnsList()
	for i,v in ipairs(self.btnList) do
		v.refreshUI();
	end
	self:RefreshBtnStatus()
end

function View:RefreshBtnStatus()
	-- local switchOn = self.activityDataMgr.GetActivityInfoByKey("BatteryLotteryView").switchOn
	-- self:FindChild("BtnGroup/BtnBattery"):SetActive(switchOn)

	local switchOn = self.activityDataMgr.GetActivityInfoByKey("CapsuleView").switchOn
	-- if switchOn then
	-- 	if self.curPanel:FindChild("Image") then
	-- 		self.curPanel:FindChild("Image"):SetActive(false)
	-- 	end
	-- end
	--新年活动，产品要求把扭蛋机放到炮台位置
	-- self:FindChild("BtnGroup/BtnBattery"):SetActive(switchOn)
	self:FindChild("BtnGroup/BtnCapsule"):SetActive(switchOn)
	
	switchOn = self.activityDataMgr.GetActivityInfoByKey("CommonHolidayGiftView").switchOn
	self:FindChild("BtnGroup/BtnHolidayGift"):SetActive(switchOn)
	
end

function View:VipChanged(level)
	self:FindChild("BtnGroup/BtnVip3"):SetActive(level <= 2)
end

function View:OnClickShareActivity()
	CC.ViewManager.Open("ActiveShareBoard");
end

function View:OnClickBtnVip3()
	CC.ViewManager.Open("VipThreeCardView");
end

function View:OnDestroy()
	self:StopTimer("countDown"..self.createTime)
	 if self.musicName then
	 	CC.Sound.PlayHallBackMusic(self.musicName);
	 else
	 	CC.Sound.StopBackMusic();
	 end
	self:UnRegisterEvent()
	CC.uu.CancelDelayRun(self.co1)
	CC.uu.CancelDelayRun(self.co2)
end

function View:ActionIn()

end

function View:ActionOut()

end

return View