local CC = require("CC")
local SelectGiftIcon = require("View/SelectGiftCollectionView/SelectGiftIcon")
local this = CC.class2("SlotSelectGiftIcon",SelectGiftIcon)

function this:InitContent()
	-- self.transform = CC.uu.LoadHallPrefab("prefab", "SlotSelectGiftIcon", self.param.parent);

	-- local layer = self.param.parent.transform.gameObject.layer;

	-- self.transform.gameObject.layer = layer

	self.icon = self.transform:FindChild("Icon")

	self.specialIcon = self.transform:FindChild("specialIcon")

	self.redDot = self.transform:FindChild("RedDot");

	self.effect = self.transform:FindChild("Effect");

	self.transform:FindChild("Effect/SaoGuang01").gameObject.layer = self.transform.gameObject.layer

	self.transform:FindChild("Effect/Glow01").gameObject.layer = self.transform.gameObject.layer

	self.animation = self.transform:SubGet("Icon","Animator");

	self.countDown = self.transform:FindChild("CountDownText");

	self.countDownText = self.transform:SubGet("CountDownText","Text");

	self.iconText = self.transform:FindChild("Text");
	self.iconText.text = CC.LanguageManager.GetLanguage("L_SelectGiftCollectionView").slot_icon

	self:AddClick(self.transform:FindChild("Icon"), "OnOpenSelectGiftCollection");

	self:AddClick(self.transform:FindChild("specialIcon"), "OnOpenSelectGiftCollection");
end

function this:OnRefreshSelectGiftIcon()
	if self.achievementGiftMgr.IsShow() then
		local countDown = self.achievementGiftMgr.GetCountDown()
		-- self:SetGiftCountDown(countDown, "AchievementGiftMainView")
	end
end

--幸运礼包倒计时
function this:LuckyCountDown(countdown)
	self:SetGiftCountDown(countdown, "LuckyTurntableView")
end

--viewName:礼包界面，如：LuckyTurntableView，不包含限时礼包
function this:SetGiftCountDown(countDown, viewName)
	self.CountDownTab[viewName] = countDown
	if self.CountDownTab[viewName] and self.CountDownTab[viewName] > 0 then
		self:SetSelectGiftSwitch(viewName, true)
	else
		self:SetSelectGiftSwitch(viewName, false)
	end
	self:SetCountDown()
end

function this:SetSelectGiftSwitch(viewName, isOn)
	self.activityDataMgr.SetActivityInfoByKey(viewName, {switchOn = isOn})
end

function this:SetCountDown()
	local timer = self:GetShortCountDown()
	if timer and timer > 0 then
		if self.countDownTimer then
			self.countDownTimer:SetActive(true)
		end
		self.iconText.y = 18
		self:StopTimer("countDown")
		self:StartTimer("countDown", 1, function()
			if timer < 0 then
				self:StopTimer("countDown")
				self:SetCountDown()
				return
			end
			if self.countDownTimer then
				self.countDownTimer.text = CC.uu.TicketFormat3(timer)
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
		if self.countDownTimer then
			self.countDownTimer:SetActive(false)
		end
		self.iconText.y = 7
		self:StopTimer("countDown")
	end
end

function this:GetShortCountDown()
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

return this