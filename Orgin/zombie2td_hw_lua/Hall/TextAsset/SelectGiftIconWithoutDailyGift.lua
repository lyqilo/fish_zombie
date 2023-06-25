local CC = require("CC")
local SelectGiftIcon = require("View/SelectGiftCollectionView/SelectGiftIcon")
local M = CC.class2("SelectGiftIconWithoutDailyGift",SelectGiftIcon)

local tableContain = function(tab,val)
	for k,v in pairs(tab) do
		if v == val then
			return true;
		end
	end
	return false
end

function M:OnCreate(param)
    self.super.OnCreate(self,param)
    self:InitContentEx()
end

function M:RegisterEvent()
    self.super.RegisterEvent(self)
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshRedDot,CC.Notifications.OnRefreshActivityRedDotState)
end

function M:InitContentEx()
    local icon = self.transform:FindChild("Icon");
	if self.param.sprite then
		local img = icon:GetComponent("Image");
		img.sprite = self.param.sprite;
		icon.width = self.param.width and self.param.width or img.sprite.rect.width;
		icon.height = self.param.height and self.param.height or img.sprite.rect.height;
	end

	if self.param.SelectGiftTab and tableContain(self.param.SelectGiftTab,"NoviceGiftView") then
		if not CC.SubGameInterface.Novice_Bool() then
			self.transform.gameObject:SetActive(false)
		end
	end
end

function M:CheckActiveSwitch()
	self.super.CheckActiveSwitch(self)
	self:OnRefreshRedDot()
end

function M:OnRefreshRedDot()

	if self.param.showRedDot ~= true then
		return;
	end

	local freeChipsInfo = self.activityDataMgr.GetSelectGiftInfo();
	self:StopShake();
	self.redDot:SetActive(false);

	if self.param.SelectGiftTab then
		for _,v in pairs(self.param.SelectGiftTab) do
			if freeChipsInfo[v] and freeChipsInfo[v].switchOn and freeChipsInfo[v].redDot then
				self.redDot:SetActive(true);
				break;
			end
		end
	else
		for _,v in pairs(freeChipsInfo) do
			if v.switchOn and v.redDot then
				self.redDot:SetActive(true);
				break;
			end
		end
	end

	if self.redDot.activeSelf == true  then
		if self.param.shakeIfRedDot == true then
			self:StartShake();
		end
	end

end

--游戏打开每日礼包
function M:OnGameOpenDailyGift(openSelect)
    self:OnGameOpenSelectGift(true)
end

--viewName:礼包界面，如：LuckyTurntableView，不包含限时礼包
function M:SetGiftCountDown(countDown, viewName)
	if self.param.SelectGiftTab and not tableContain(self.param.SelectGiftTab,viewName) then
		return;
    end

    self.super.SetGiftCountDown(self, countDown, viewName)
end

function M:StartShake()
	self.shakeAction = CC.Action.RunAction(self.transform, {
		{"delay",0.75},
		{"rotateTo", -9.92 , 0.083 , ease = CC.Action.ELinear},
		{"rotateTo", 6.01 , 0.083 , ease = CC.Action.ELinear},
		{"rotateTo", -360 , 0.083 , ease = CC.Action.ELinear,function () self:StartShake() end}
	})
end

function M:StopShake(beComplete)
	if self.shakeAction then
		self.shakeAction:Kill(beComplete or false)
    	self.shakeAction = nil;
    end

    -- 复原到0角度
    CC.Action.RunAction(self.transform, {
		{"rotateTo", 0 ,0},
	})
end

function M:OnDestroy()
    self:StopShake();
    self.super.OnDestroy(self)
end

return M