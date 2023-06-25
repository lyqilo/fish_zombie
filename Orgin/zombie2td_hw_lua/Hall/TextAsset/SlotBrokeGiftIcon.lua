
---------------------------------
-- region SlotBrokeGiftIcon.lua    -
-- Date: 2020.8.04       -
-- Desc: slot游戏破产礼包icon -
-- Author: lijd        -
---------------------------------
local CC = require("CC")
local SelectGiftIcon = require("View/SelectGiftCollectionView/SelectGiftIcon")
local this = CC.class2("SlotSelectGiftIcon",SelectGiftIcon)

function this:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshRedDot,CC.Notifications.OnRefreshActivityRedDotState)
	CC.HallNotificationCenter.inst():register(self,self.BrokeGiftStatusResq,CC.Notifications.NW_ReqBrokeGiftStatus)
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshSwitchOn,CC.Notifications.OnRefreshActivityBtnsState)
end

function this:InitContent()
	-- self.transform = CC.uu.LoadHallPrefab("prefab", "SlotBrokeGiftIcon", self.param.parent);

	-- self.transform.gameObject.layer = self.param.parent.transform.gameObject.layer;

	self.redDot = self.transform:FindChild("RedDot");

	self.effect = self.transform:FindChild("Effect");

	self.animation = self.transform:SubGet("Icon","Animator");

	self.countDown = self.transform:FindChild("CountDownText");

	self.countDownText = self.transform:SubGet("CountDownText","Text");

	self:AddClick(self.transform:FindChild("Icon"), "OnOpenSelectGift");

	self:AddClick(self.transform:FindChild("specialIcon"), "OnOpenSelectGift");
end

function this:InitData()
	self:OnRefreshSwitchOn()
	self:OnRefreshRedDot()
	self:OnRefreshEffect()
	if self.param.requestStatus then
		CC.Request("ReqBrokeGiftStatus")
	end
end

function this:OnOpenSelectGift()
	self.giftView = CC.ViewManager.Open("BrokeGiftView")
	self.activityDataMgr.SetActivityInfoByKey("BrokeGiftView", {redDot = false})
end

function this:OnRefreshSwitchOn()
	local switchOn = self.activityDataMgr.GetActivityInfoByKey("BrokeGiftView").switchOn
	self.transform:SetActive(switchOn)
	self.activityDataMgr.SetActivityInfoByKey("BrokeGiftView", {redDot = switchOn})
end

function this:OnRefreshRedDot()

	local freeChipsInfo = self.activityDataMgr.GetActivityInfo();
	local brokeGiftInfo = freeChipsInfo["BrokeGiftView"]
	if brokeGiftInfo and brokeGiftInfo.switchOn and brokeGiftInfo.redDot then
		self.redDot:SetActive(true);
	else
		self.redDot:SetActive(false);
	end

end

function this:OnRefreshEffect()

	local freeChipsInfo = self.activityDataMgr.GetActivityInfo();
	local brokeGiftInfo = freeChipsInfo["BrokeGiftView"]
	if brokeGiftInfo and brokeGiftInfo.switchOn then
		self.effect:SetActive(true);
		self.animation.enabled = true
	else
		self.effect:SetActive(false);
		self.animation.enabled = false
	end
end

return this