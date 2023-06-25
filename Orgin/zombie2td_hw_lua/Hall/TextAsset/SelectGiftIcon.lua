
---------------------------------
-- region SelectGiftIcon.lua    -
-- Date: 2019.8.19       -
-- Desc: 免费合集按钮,管理红点显示以及提供游戏创建  -
-- Author: Bin        -
---------------------------------
local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local SelectGiftIcon = CC.class2("SelectGiftIcon",ViewUIBase)

function SelectGiftIcon:OnCreate(param)

	--限时类礼包倒计时
	self.CountDownTab = {}
	self:InitVar(param);
	self:InitContent();
	if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetPingSwitch() then
		self:InitData();
	end
	self:RegisterEvent();
end

function SelectGiftIcon:InitVar(param)
	self._timers = {}

	self.param = param or {};

	self.collectView = nil;
	self.dailyView = nil
	self.giftView = nil

	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")

	self.achievementGiftMgr = CC.DataMgrCenter.Inst():GetDataByKey("AchievementGift")

	self.signDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SignData")

	self.FundDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("FundData")

	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
	--幸运礼包请求标记
	self.initLuckyReq = false
end

function SelectGiftIcon:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshSelectGiftIcon,CC.Notifications.OnRefreshSelectGiftIcon)
	CC.HallNotificationCenter.inst():register(self,self.LuckyCountDown,CC.Notifications.LuckyCountDown)
	CC.HallNotificationCenter.inst():register(self,self.CheckActiveSwitch,CC.Notifications.ActivitySwitch)
	CC.HallNotificationCenter.inst():register(self,self.BrokeGiftStatusResq,CC.Notifications.NW_ReqBrokeGiftStatus)
	CC.HallNotificationCenter.inst():register(self,self.BrokeBigGiftStatusResq,CC.Notifications.NW_ReqBrokeBigGiftStatus)
	CC.HallNotificationCenter.inst():register(self,self.LuckySpinInfoResq,CC.Notifications.NW_ReqLuckySpinInfo)
	CC.HallNotificationCenter.inst():register(self,self.ReqOrderStatusResq,CC.Notifications.NW_GetOrderStatus)
	CC.HallNotificationCenter.inst():register(self,self.ReqGetSevenFundInfoResp,CC.Notifications.NW_ReqGetSevenFundInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnSelectGiftIconTimeNotify,CC.Notifications.OnTimeNotify)
end

function SelectGiftIcon:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end


function SelectGiftIcon:CheckActiveSwitch()
	local switchCfg = self.activityDataMgr.GetSelectGiftInfo()
	for k,v in pairs(switchCfg) do
		local activeId = k
		if activeId == "NoviceGiftView" then
			if CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
				--设置小红点点儿
				self.activityDataMgr.SetActivityInfoByKey("NoviceGiftView", {redDot = true})
			else
				self.activityDataMgr.SetActivityInfoByKey("NoviceGiftView", {switchOn = false})
			end
		elseif activeId == "FundView" then
			if CC.Player.Inst():GetFundState() == false then
				self.activityDataMgr.SetActivityInfoByKey("FundView", {redDot = true})
			end
		end
	end
	-- self:OnRefreshRedDot()
	self:OnRefreshSelectGiftIcon()
end


function SelectGiftIcon:InitContent()

	-- self.transform = CC.uu.LoadHallPrefab("prefab", "SelectGiftIcon", self.param.parent);

	-- self.transform.gameObject.layer = self.param.parent.transform.gameObject.layer;

	self.redDot = self.transform:FindChild("RedDot");

	self.effect = self.transform:FindChild("Effect");

	self.animation = self.transform:SubGet("Icon","Animator");

	self.countDown = self.transform:FindChild("CountDown")

	self.countDownText = self.transform:SubGet("CountDown/Text","Text")

	self:AddClick(self.transform:FindChild("Icon"), "OnOpenSelectGiftCollection");

	self:AddClick(self.transform:FindChild("specialIcon"), "OnOpenSelectGiftCollection");
	self.effect:SetActive(true)
end

function SelectGiftIcon:InitData()
	-- CC.ViewManager.ShowConnecting(true)
	-- self:ReqFundPurchaseStatus()
	-- self:CheckActiveSwitch()
	local buyuWareId = CC.PaymentManager.GetActiveWareIdByKey("buyu")
	local airWareId = "com.huoys.royalcasino.FJ10"

	local wareIds = {buyuWareId, "22006", "23006",airWareId}
	CC.uu.Log(wareIds,"GetOrderStatus-->>wareIds:")
	CC.Request("GetOrderStatus",wareIds)
	CC.Request("ReqBrokeGiftStatus")
	CC.Request("ReqBrokeBigGiftStatus")
end

--获取基金购买状态
function SelectGiftIcon:ReqFundPurchaseStatus()
	CC.Request("ReqGetSevenFundInfo")

end

function SelectGiftIcon:ReqGetSevenFundInfoResp(err,data)
	if err == 0 then
		-- CC.uu.Log(data.Infos,"FundData:",3)
		self.FundDataMgr.SetFundStatus(data.Infos)
		local redDot = self.FundDataMgr.IsRedDot()
		self.activityDataMgr.SetActivityInfoByKey("FundView", {redDot = redDot})
	end
end

function SelectGiftIcon:OnOpenSelectGiftCollection()
	if not self.param.isHall and self:GetShortCountDown() <= 0 then
		--游戏内没有限时礼包
		self:OnGameOpenDailyGift()
		-- local param = {}
		-- param.isOpenGift = true
		-- param.closeFunc = slot(function()
		-- 	if self.giftView then
		-- 		self.giftView:Destroy()
		-- 		self.giftView = nil
		-- 	end
		-- end,self)
		-- self.giftView = CC.ViewManager.Open("AchievementGiftMainView",param)
	else
		self:OnGameOpenSelectGift()
	end
end

--游戏打开特惠礼包
function SelectGiftIcon:OnGameOpenSelectGift(openDaily)
	local param = {}
	param.viewParams = self.param.viewParams
	param.SelectGiftTab = self.param.SelectGiftTab
	param.openFunc = self.param.openFunc
	param.closeFunc = function()
		self.collectView = nil;
		if self.param.closeFunc then
			self.param.closeFunc();
		end
		if not self.param.isHall and not openDaily then
			self:OnGameOpenDailyGift(true)
		end
	end
	self.gameDataMgr.SetSwitchClick("SelectGiftCollectionView")
	self.collectView = CC.ViewManager.Open("SelectGiftCollectionView",param)
end

--游戏打开每日礼包
function SelectGiftIcon:OnGameOpenDailyGift(openSelect)
	local param = {}
	param.currentView = self.param.currentView
	param.closeFunc = function()
		self.dailyView = nil;
		if not self.param.isHall and not openSelect then
			self:OnGameOpenSelectGift(true)
		end
	end
	self.dailyView = CC.ViewManager.Open("DailyGiftCollectionView",param)
end

function SelectGiftIcon:OnRefreshRedDot()

	local freeChipsInfo = self.activityDataMgr.GetSelectGiftInfo();

	for _,v in pairs(freeChipsInfo) do

		if v.switchOn and v.redDot then
			self.redDot:SetActive(true);
			return;
		end
	end

	self.redDot:SetActive(false);

end

--礼包状态
function SelectGiftIcon:ReqOrderStatusResq(err, data)
	log(CC.uu.Dump(data,"OrderStatusData",10))
	if err ~= 0 then return end
	if data.Items then
        for _, v in ipairs(data.Items) do
			if v.WareId == "22006" and v.Enabled and not self.initLuckyReq then
				--幸运礼包
				CC.Request("ReqLuckySpinInfo")
				self.initLuckyReq = true
			elseif v.WareId == "23006" then
				--vip3直升卡
				local bState = CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < 3 and v.Enabled
				self.activityDataMgr.SetActivityInfoByKey("VipThreeCardView", {switchOn = bState})
			elseif v.WareId == CC.PaymentManager.GetActiveWareIdByKey("buyu") then
				--捕鱼新手礼包
				local bState = v.Enabled
				self.activityDataMgr.SetActivityInfoByKey("Act_EveryGift", {redDot = bState})
				CC.Player.Inst():SetDailyGiftState(bState)
			elseif v.WareId == "com.huoys.royalcasino.FJ10" then
				--飞机礼包
				local bState = v.Enabled
				self.activityDataMgr.SetActivityInfoByKey("DailyDealsView", {redDot = bState})
            end
        end
	end
end

function SelectGiftIcon:LuckySpinInfoResq(err, data)
	if err == 0 then
		--推送幸运礼包倒计时
		self.initLuckyReq = true
		if data.IsOpen and data.Active and data.Countdown > 0 then
			self:LuckyCountDown(data.Countdown)
		end
	end
end

function SelectGiftIcon:BrokeGiftStatusResq(err, data)
	log("err = ".. err.."  "..CC.uu.Dump(data,"BrokeGiftStatusResq",10))
	if err == 0 then
		self.activityDataMgr.SetBrokeGiftData(data)
		if data.nStatus == 1 then
			if data.arrBrokenGift then
				local bState = false
				for _, v in ipairs(data.arrBrokenGift) do
					if v.bStatus then
						--有档位没有购买
						bState = true
						break
					end
				end
				self:SetSelectGiftSwitch("BrokeGiftView", bState)
				if bState then
					self:SetGiftCountDown(data.lLeftTimeSec, "BrokeGiftView")
				end
			end
		else
			self:SetSelectGiftSwitch("BrokeGiftView", false)
		end
	end
end

--大额破产
function SelectGiftIcon:BrokeBigGiftStatusResq(err, data)
	if err == 0 then
		self.activityDataMgr.SetBrokeBigGiftData(data)
		if data.nStatus == 1 then
			if data.arrBrokenGift then
				local bState = false
				for _, v in ipairs(data.arrBrokenGift) do
					if v.bStatus then
						--有档位没有购买
						bState = true
						break
					end
				end
				self:SetSelectGiftSwitch("BrokeBigGiftView", bState)
				if bState then
					self:SetGiftCountDown(data.lLeftTimeSec, "BrokeBigGiftView")
				end
			end
		else
			self:SetSelectGiftSwitch("BrokeBigGiftView", false)
		end
	end
end

function SelectGiftIcon:OnRefreshSelectGiftIcon()
	local countDown = self.achievementGiftMgr.GetCountDown()
	-- self:SetGiftCountDown(countDown, "AchievementGiftMainView")
end

--幸运礼包倒计时
function SelectGiftIcon:LuckyCountDown(countdown)
	self:SetGiftCountDown(countdown, "LuckyTurntableView")
end

--viewName:礼包界面，如：LuckyTurntableView，不包含限时礼包
function SelectGiftIcon:SetGiftCountDown(countDown, viewName)
	self.CountDownTab[viewName] = countDown
	if self.CountDownTab[viewName] and self.CountDownTab[viewName] > 0 then
		self:SetSelectGiftSwitch(viewName, true)
	else
		self:SetSelectGiftSwitch(viewName, false)
	end
	self:SetCountDown()
end

function SelectGiftIcon:SetSelectGiftSwitch(viewName, isOn)
	self.activityDataMgr.SetActivityInfoByKey(viewName, {switchOn = isOn})
end

function SelectGiftIcon:SetCountDown()
	local timer = self:GetShortCountDown()
	if timer and timer > 0 then
		self.countDown:SetActive(true)
		self:StopTimer("countDown")
		self:StartTimer("countDown", 1, function()
			if timer < 0 then
				self:StopTimer("countDown")
				self:SetCountDown()
				return
			end
			if self.countDownText then
				self.countDownText.text = CC.uu.TicketFormat3(timer)
			end
			timer = timer - 1
			for k, _ in pairs(self.CountDownTab) do
				if self.CountDownTab[k] > 0 then
					self.CountDownTab[k] = self.CountDownTab[k] - 1
					if self.CountDownTab[k] <= 0 then
						self:SetSelectGiftSwitch(k, false)
					end
				end
			end
		end, -1)
	else
		self.countDown:SetActive(false)
		self:StopTimer("countDown")
	end
end

function SelectGiftIcon:GetShortCountDown()
	local shortCountDownt = 0
	for _, v in pairs(self.CountDownTab) do
		if v > 0 then
			if shortCountDownt <= 0 or shortCountDownt - v > 0 then
				shortCountDownt = v
			end
		end
	end
	return shortCountDownt
end

function SelectGiftIcon:OnSelectGiftIconTimeNotify()
	--月卡
	if CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("MonthCardView").switchOn then
		CC.SelectGiftManager.CheckMonthCard()
	end
end

function SelectGiftIcon:OnDestroy()
	self:StopTimer("countDown")
	if self.collectView then
		self.collectView:Destroy();
	end
	if self.giftView then
		self.giftView:Destroy()
		self.giftView = nil
	end
	if self.dailyView then
		self.dailyView:Destroy()
		self.dailyView = nil
	end
	self:UnRegisterEvent();
end

return SelectGiftIcon