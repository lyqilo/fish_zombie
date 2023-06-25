local CC = require("CC")

local View = CC.uu.ClassView("WaterSprinklingView")


local OpenSubViewList = {"ActSignInView","HolidayTaskView","SpecialOfferGiftView","BatteryLotteryView"}
local BannerGameId = 3007



function View:ctor()
	self.language = self:GetLanguage()
	self.mainScrollList = {}
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")

	self.OpenRCollectionList = {"SelectGiftCollectionView","FreeChipsCollectionView","SelectGiftCollectionView","DailyGiftCollectionView","FreeChipsCollectionView"}
	self.OpenLCollectionList = {"FreeChipsCollectionView","SelectGiftCollectionView","StoreView","FreeChipsCollectionView","RankCollectionView", "RankCollectionView"}
	self.OpenRViewList  = {"BatteryLotteryView","HolidayTaskView","ElkLimitGiftView","HolidayDiscountsView","DailyLotteryView"}
	self.OpenLViewList = {"ActSignInView","NewPayGiftView","StoreView","HalloweenLoginGiftView","TotalWaterRankView","BatteryRankView"}
end

function View:OnCreate()
	-- self:InitContent()
	self:InitTextByLanguage()
	self:RegisterEvent();
	self:ClickEvent()
	self:InitChristmas()
end

function View:InitChristmas()
	self:Timer()
	self:SetBtnState()
end

function View:SetBtnState()
	--设置按钮状态
	for key, value in pairs(self.OpenLViewList) do
		if value ~= "StoreView" then
			local b = self.activityDataMgr.GetActivityInfoByKey(value).switchOn
			self:FindChild("LPanel/"..key.."/Gray"):SetActive(not b)
		end
	end

	for key, value in pairs(self.OpenRViewList) do
		local b = self.activityDataMgr.GetActivityInfoByKey(value).switchOn
		self:FindChild("RPanel/"..key.."/Gray"):SetActive(not b)
	end
	
end

function View:ClickEvent()
	self:AddClick("closeBtn",slot(self.Destroy,self))

	for i = 1, 6, 1 do
		--左侧按钮点击事件
		self:AddClick("LPanel/"..i,function ()
			if self.OpenLCollectionList[i] == "StoreView" then
				CC.ViewManager.Open(self.OpenLCollectionList[i])
			else
				CC.ViewManager.Open(self.OpenLCollectionList[i],{currentView = self.OpenLViewList[i]});
			end
		end)
		self:AddClick("LPanel/"..i.."/Gray",function ()
			CC.ViewManager.ShowTip(self.language.Tips)
		end)
		--右侧按钮点击事件
		if i < 6 then
			self:AddClick("RPanel/"..i,function ()
				CC.ViewManager.Open(self.OpenRCollectionList[i],{currentView = self.OpenRViewList[i]});
			end)
			self:AddClick("RPanel/"..i.."/Gray",function ()
				CC.ViewManager.ShowTip(self.language.Tips)
			end)
		end
	end
	self:AddClick("MPanel/Capsule",function ()
		self:ActionOut()
		CC.ViewManager.Open("FreeChipsCollectionView", {currentView = "CapsuleView"})
	end)
	self:AddClick("LPanel/Image",function ()
		
		CC.ViewManager.Open("StoreView", {channelTab = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine").CommodityType.Battery})
	end)
end

function View:Timer()

	self.cur = 1
	local pos = -128
	local i = 1
	self:StartTimer("WaterSprinklingTimer",1,function()

		if i%4 == 2 then
			self.last = self.cur
			self.cur = self.cur + 1
			if self.cur > 4 then
				self.cur = 1
			end

			self:RunAction(self:FindChild("LPanel/Image/Icon"..self.last),  {"localMoveTo", pos, 0, 0.5, function ()
				self:FindChild("LPanel/Image/Icon"..self.last):SetActive(false)
			end})
			self:FindChild("LPanel/Image/Icon"..self.cur):SetActive(true)
			self:FindChild("LPanel/Image/Icon"..self.cur).transform.localPosition = Vector3(-pos, 0, 0)
			self:RunAction(self:FindChild("LPanel/Image/Icon"..self.cur),  {"localMoveTo", 0, 0, 0.5})

		end
        i = i+1
    end,-1)
end

function View:InitContent()

	self.btnList = {}

	self:AddClick("closeBtn",slot(self.Destroy,self))

	for i=1,4 do
		local btn = self:FindChild("group/btn"..i)
		local viewKey = OpenSubViewList[i]
		local info = self.activityDataMgr.GetActivityInfoByKey(viewKey)
		local isShow = info.switchOn
		if self.OpenRCollectionList[i] == "SelectGiftCollectionView" and not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
			isShow = false
		end
		self:AddClick(btn,function ()
			local param = {}
			param.currentView = viewKey
			CC.ViewManager.Open(self.OpenRCollectionList[i],param)
			-- self:Destroy()
		end)
		btn:SetActive(isShow)
		table.insert(self.btnList,btn)
	end

	local gameInfo = self.gameDataMgr.GetInfoByID(BannerGameId)

	self:AddClick("banner",function ()
		if gameInfo.IsCommingSoon == 1 then
			CC.ViewManager.ShowTip(self.language.game_close)
		else
			CC.HallUtil.CheckAndEnter(BannerGameId)
		end
	end)

	self.marquee = self:FindChild("SpeakerBord")
	self.marqueeText = self:FindChild("SpeakerBord/SpeakerImg/TextTip")
	self.marqueeWidth = (self:FindChild("SpeakerBord/SpeakerImg"):GetComponent('RectTransform').rect.width - 15)/2

	self.marquee:SetActive(true)
	self:PlayMarquee()
end

function View:InitTextByLanguage()
	-- self.marqueeText.text = self.language.marqueeText
	-- self:FindChild("group/btn2/Effect_UI_psj_qp/TuBiao/Text").text = self.language.tips2
	-- self:FindChild("group/btn3/Effect_UI_psj_qp/TuBiao/Text").text = self.language.tips3
	-- self:FindChild("banner/Image/Text").text = self.language.btnText
	-- for i=1,4 do
	-- 	self:FindChild("group/btn"..i.."/Tag").text = self.language.btnList[i].tag
	-- 	self:FindChild("group/btn"..i.."/Text").text = self.language.btnList[i].name
	-- end
	for i = 1, 6, 1 do
		self:FindChild("LPanel/"..i.."/Text").text = self.language.ChristmasBtnListL[i]
		self:FindChild("LPanel/"..i.."/Gray/Text").text = self.language.ChristmasBtnListL[i]
		if i < 6 then
			self:FindChild("RPanel/"..i.."/Text").text = self.language.ChristmasBtnListR[i]
			self:FindChild("RPanel/"..i.."/Gray/Text").text = self.language.ChristmasBtnListR[i]
			self:FindChild("RPanel/"..i.."/Red/Text").text = self.language.ChristmasBtnListR[i]
		end
	end

end

function View:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnRefreshRankBtnsList, CC.Notifications.OnRefreshActivityBtnsState)
end

function View:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnRefreshActivityBtnsState)
end

function View:OnRefreshRankBtnsList(key,switchOn)
	for i,view in ipairs(OpenSubViewList) do
		if key == view then
			self.btnList[i]:SetActive(switchOn)
			break
		end
	end
end

function View:PlayMarquee()
	self.marqueeText.localPosition = Vector3(10000,10000,10000)
	self:DelayRun(0.1,function()
		local textW = self.marqueeText:GetComponent('RectTransform').rect.width
		local half = textW/2
		self.marqueeText.localPosition = Vector3(half + self.marqueeWidth, 0, 0)
		self.action = self:RunAction(self.marqueeText, {"localMoveTo", -half - self.marqueeWidth, 0, 0.65 * math.max(16,textW/40), function()
			self:PlayMarquee(true)
		end})
	end)
end

function View:OnDestroy()
	self:UnRegisterEvent()
	self:StopTimer("WaterSprinklingTimer")
end

function View:ActionIn()

end

function View:ActionOut()
	self:Destroy()
end

return View