
local CC = require("CC")
local BaseClass = CC.uu.ClassView("AchievementGiftMainView")

function BaseClass:ctor(param)
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self.achievementGiftMgr = CC.DataMgrCenter.Inst():GetDataByKey("AchievementGift")
	self.language = CC.LanguageManager.GetLanguage("L_AchievementGiftMainView");
	if param == nil then
		return
	end
	self.isOpenGift = param.isOpenGift or false
	self.closeFunc = param.closeFunc
end

function BaseClass:OnCreate()
	self:InitContent()
	self:InitTextByLanguage();
	self:RegisterEvent()

	self:UpdateShow()
end

function BaseClass:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnLimitTimeGiftReward,CC.Notifications.OnLimitTimeGiftReward)
end

function BaseClass:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnLimitTimeGiftReward)
end

function BaseClass:OnLimitTimeGiftReward()
	log("OnLimitTimeGiftReward")
	if self.isOpenGift and self.closeFunc then
		self.closeFunc()
	end
end

function BaseClass:InitContent()
	self.mask = self:FindChild("Layer_Mask")

	self.girlTipsText = self:SubGet("Layer_BG/content/girl/tips/Text", "Text")
	self.radioImage = self:SubGet("Layer_BG/content/zi/radio","Image")
	self.clockText = self:SubGet("Layer_BG/content/clock/Text", "Text")

	for i=1,5 do
		local iconBtn = self:FindChild("Layer_BG/content/icon"..i)
		local tipWindow = self:FindChild("tips"..i)
		self:AddClick(iconBtn,function ()
			tipWindow:SetActive(true)
		end)
		local tipMask = self:FindChild("tips"..i.."/mask")
		self:AddClick(tipMask,function ()
			tipWindow:SetActive(false)
		end)
	end

	self.closeBtn = self:FindChild("Layer_BG/closeBtn")
	self:AddClick(self.closeBtn,function ()
		if self.closeFunc then
			self.closeFunc()
		end
	end)

	local buyBtn = self:FindChild("Layer_BG/content/Button")
	self:AddClick(buyBtn,function ()
		logError("AchievementGiftMainView Buy !!!")
		local wareId = CC.PaymentManager.GetActiveWareIdByKey("limitGift")
		local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");
		local wareData = wareCfg[wareId]
		if wareData then
			local param = {}
			param.wareId = wareData.Id
			param.subChannel = wareData.SubChannel
			param.price = wareData.Price
			param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
			param.errCallback = function ()	end
			CC.PaymentManager.RequestPay(param)
		end
	end)
end

function BaseClass:InitTextByLanguage()
	self:FindChild("Layer_BG/content/icon1/Text").text = self.language.iconText1
	self:FindChild("Layer_BG/content/icon2/Text").text = self.language.iconText2
	self:FindChild("Layer_BG/content/icon3/Text").text = self.language.iconText3
	self:FindChild("Layer_BG/content/icon4/Text").text = self.language.iconText4
	self:FindChild("Layer_BG/content/icon5/Text").text = self.language.iconText5

	self:FindChild("Layer_BG/content/Button/Text").text = self.language.button

	self:FindChild("tips1/content/context/Text").text = self.language.tipsContext1
	self:FindChild("tips2/content/context/titleText").text = self.language.tipsTitleText2
	self:FindChild("tips2/content/context/Text").text = self.language.tipsContext2
	self:FindChild("tips3/content/context/titleText").text = self.language.iconText3
	self:FindChild("tips3/content/context/Text").text = self.language.tipsContext3
	self:FindChild("tips4/content/context/titleText").text = self.language.tipsTitleText4
	self:FindChild("tips4/content/context/Text").text = self.language.tipsContext4
	self:FindChild("tips5/content/context/titleText").text = self.language.iconText5
	self:FindChild("tips5/content/context/Text").text = self.language.tipsContext5
end

function BaseClass:UpdateShow()
	local giftType = self.achievementGiftMgr.GetGiftType() or 1
	self.mask:SetActive(self.isOpenGift)
	self.closeBtn:SetActive(self.isOpenGift)
	self.girlTipsText.text = self.language["girlTips"..giftType]
	CC.Sound.PlayHallEffect("limitGiftGirlTips"..giftType);
	local spriteName = "xslb_nr_wz_2000"
	if giftType == 2 then
		spriteName = "xslb_nr_wz_7000"
	end
	self:SetImage(self.radioImage,spriteName)

	local countDown = self.achievementGiftMgr.GetCountDown()
	self:StopTimer("countDown")
	self:StartTimer("countDown",1,function ()
		if countDown < 0 then
			self.clockText.text = "00:00:00"
			self:StopTimer("countDown")
			return
		end
		self.clockText.text = CC.uu.TicketFormat3(countDown) -- "00:00:00"
		countDown = countDown - 1
	end,-1)
end

function BaseClass:OnDestroy()
	CC.Sound.StopEffect()
	self:UnRegisterEvent()
end

function BaseClass:ActionOut()
	self:SetCanClick(false)
	CC.HallUtil.HideByTagName("Effect", false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function BaseClass:ActionIn()
	self:SetCanClick(false);

	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

return BaseClass