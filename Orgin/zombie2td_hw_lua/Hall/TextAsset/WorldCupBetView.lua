local CC = require("CC")
local WorldCupBetView = CC.uu.ClassView("WorldCupBetView")
local M = WorldCupBetView

local textColor = {
	likesDark = "<color=#6F6F6F>%d</color>",
	likesLight = "<color=#16DB3B>%d</color>",
	refreshG = "<color=#0BE74E>%s</color>",
	refreshY = "<color=#FFD821>%s</color>",
	refreshR = "<color=#FF4520>%s</color>",
}

function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param
    self.language = CC.LanguageManager.GetLanguage("L_WorldCupView")
	self.curPage = 1
	self.curBetNum = 1
	self.curSelect = 0
	self.clickDay = 0
end

function M:OnCreate()
    self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()

    self:InitContent()
	self:InitTextByLanguage()
	
	self.viewCtr:StartRequest()
end

function M:CreateViewCtr(...)
	local viewCtrClass = require("View/WorldCupView/"..self.viewName.."Ctr");
	return viewCtrClass.new(self, ...);
end

function M:InitContent()
	
	self.leftPanel = self:FindChild("LeftPanel")
	self.matchDateText = self.leftPanel:FindChild("Match/Date")
	self.matchTimeText = self.leftPanel:FindChild("Match/Time/Text")
	self.matchTeamNode = self.leftPanel:FindChild("Match/Team")
	self.vsAnimator = self.leftPanel:FindChild("Match/Team"):GetComponent("Animator")
	self.pageText = self.leftPanel:FindChild("Match/Down/Page")
	self.mascotNode = self.leftPanel:FindChild("Node")
	
	self.rightPanel = self:FindChild("RightPanel")
	self.jpEffect = self.rightPanel:FindChild("JP/Effect")
	self.remainTimeText = self.rightPanel:FindChild("Remain/Time")
	self.betStopTips = self.rightPanel:FindChild("BetStop")
	self.btnSub = self.rightPanel:FindChild("Bet/Sub/Btn")
	self.btnAdd = self.rightPanel:FindChild("Bet/Add/Btn")
	self.btnMax = self.rightPanel:FindChild("Bet/BtnMax")
	self.btnBet = self.rightPanel:FindChild("Bet/BtnBet")
	self.btnBetGray = self.rightPanel:FindChild("Bet/BtnBetGray")
	self.btnRefresh = self.rightPanel:FindChild("Bet/BtnRefresh")
	self.refreshTimeText = self.rightPanel:FindChild("Bet/BtnRefresh/Text")
	self.betNumText = self.rightPanel:FindChild("Bet/Num")
	self.betTimesText = self.rightPanel:FindChild("Bet/Tips")
	self.maxSlider = self.rightPanel:FindChild("Bet/MaxSlider"):GetComponent("Slider")
	
	self.dayItem = {}
	self.pagePoint = {}
	self.guestToggleList = {}
	for i=1,4 do
		self.dayItem[i] = self.leftPanel:FindChild("Day/"..i)
		self.pagePoint[i] = self.leftPanel:FindChild("Match/Down/Point/"..i)
		self:AddClick(self.dayItem[i],function ()
				if self.clickDay == i then return end
				self:OnSwitchMatchDate(i)
			end)
	end
	for i=1,3 do
		self.guestToggleList[i] = self.rightPanel:FindChild("Guest/"..i)
		UIEvent.AddToggleValueChange(self.guestToggleList[i], function(selected)
				self:OnGuestToggleChange(selected,i)
			end)
	end
	
	self:AddClick(self.btnSub,"OnClickBtnSub")
	self:AddClick(self.btnAdd,"OnClickBtnAdd","WorldCupClick")
	self:AddClick(self.btnMax,"OnClickBtnMax","WorldCupClick")
	self:AddClick(self.btnBet,"OnClickBtnBet")
	
	self:AddClick("RightPanel/Bet/Sub",function ()	self.viewCtr:GetCanBet() end)	
	self:AddClick("RightPanel/Bet/Add",function ()	self.viewCtr:GetCanBet() end)	
	self:AddClick(self.btnBetGray,function () self.viewCtr:GetCanBet() end)
	
	self:AddClick("LeftPanel/Match/Down/Page/Front",function ()
			self:OnSwitchMatchPage(self.curPage-1)
		end)
	self:AddClick("LeftPanel/Match/Down/Page/Next",function ()
			self:OnSwitchMatchPage(self.curPage+1)
		end)
	
	UIEvent.AddSliderOnValueChange(self.maxSlider.transform, function (value)
		self:OnSliderValueChange(value)
	end)
	
	
	self.mascot = CC.uu.CreateHallView("WorldCupMascot");
	self.mascot.transform:SetParent(self.mascotNode, false);
end

function M:InitTextByLanguage()
	self.pageText.text = string.format(self.language.matchOrder,1)
	self.rightPanel:FindChild("Remain").text = self.language.remainBetTime
	self.betTimesText = string.format(self.language.totalBet,0)
	for i=1,2 do
		local team = self.rightPanel:FindChild("Guest/"..i)
		team:FindChild("Background/Text").text =  self.language.win
		team:FindChild("Checkmark/Text").text =  self.language.win
	end
	self.rightPanel:FindChild("Guest/3/Background/Text").text =  self.language.draw
	self.rightPanel:FindChild("Guest/3/Checkmark/Text").text =  self.language.draw
	self.btnMax:FindChild("Text").text = "MAX"
	self.rightPanel:FindChild("Bet/MaxSlider/Text").text = "MAX"
	self.betStopTips:FindChild("Node/Text").text = self.language.betStop
end

function M:RefreshUI(param)
	
	if param.matchData then
		self:RefreshMatch(param.matchData)
	end
	
	if param.betData then
		self:RefreshBetPanel(param.betData)
	end
	
end

function M:RefreshDayItem(param)
	for i=1,4 do
		if param[i] then
			local info = param[i]
			local timeInfo = CC.TimeMgr.GetConvertTimeInfo(info.ts)
			self.dayItem[i]:FindChild("Lock"):SetActive(info.lock)
			self.dayItem[i]:FindChild("Dark"):SetActive(not info.lock)
			self.dayItem[i]:FindChild("Text").text = string.format("%02d/%02d",timeInfo.day,timeInfo.month)
			self.dayItem[i]:FindChild("Light/Text").text = string.format("%02d/%02d",timeInfo.day,timeInfo.month)
		else
			self.dayItem[i]:SetActive(false)
		end
	end
	self:OnSwitchMatchDate(1)
end

function M:RefreshMatch(param)
	
	local timeInfo = CC.TimeMgr.GetConvertTimeInfo(param.GameStartTime)
	self.matchDateText.text = string.format("%02d/%02d",timeInfo.day,timeInfo.month)
	self.matchTimeText.text = string.format("%02d:%02d",timeInfo.hour,timeInfo.min)
	self.matchTeamNode:FindChild("Group").text = param.GameName
	for i=1,2 do
		local team = self.matchTeamNode:FindChild("Team"..i)
		local data = param.Countrys[i]
		self:SetImage(team,self:GetCircleIconById(data.CountryId))
		team:FindChild("Name").text = self.language.countryName[data.CountryId]
		
		local likeBtn = self.leftPanel:FindChild("Match/Likes/Btn"..i)
		local showLight = param.LikeCountryId == data.CountryId
		local color = showLight and textColor.likesLight or textColor.likesDark
		likeBtn:FindChild("Text").text = string.format(color,data.LikeCount)
		likeBtn:FindChild("Light"):SetActive(showLight)
		likeBtn.interactable = param.LikeCountryId == 0
		self:AddClick(likeBtn,function ()
				self:OnClickLikesBtn(param.GameId,data.CountryId)
			end)
	end
	local svrTime = CC.TimeMgr.GetSvrTimeStamp()
	local notStart = svrTime < param.StartBetTime
	local isStop = svrTime >= param.EndBetTime
	self.matchNotStart = notStart
	if notStart then
		self:SetStopBetText(2)
	elseif isStop then
		self:SetStopBetText(0)
	end
	self.betStopTips:SetActive(notStart or isStop)
	if isStop or notStart then
		self:StopTimer("RemainTimer")
		self:SetRemainTimeText(0)
	else
		self:SetRemainTimer(param.EndBetTime)
	end
	self:PlayVsAnimation()
end

function M:RefreshBetPanel(param)
	
	for i=1,3 do
		local data = param.AreaBetInfo[i]
		local team = self.guestToggleList[i]
		if data then
			if data.CountryId ~= 888 then
				self:SetImage(team:FindChild("Icon"),self:GetCircleIconById(data.CountryId))
			end
			team:FindChild("People").text = self.matchNotStart and 0 or data.BetCount
			team:FindChild("Odds").text = data.Odds
			team:GetComponent("Toggle").isOn = false
			team:SetActive(true)
		else
			team:SetActive(false)
		end
	end 
	self:RefreshJackpot(param.JackPot)
	if param.NextRefreshTime == 0 or self.matchNotStart then
		self:StopTimer("RefreshTimer")
		self:SetRefreshTimeText(0)
	else
		self:SetRefreshTimer(param.NextRefreshTime)
	end
	
	self:RefreshBetBtn()
end

function M:RefreshBetBtn()
	self.isQuizCard = self.viewCtr:GetQuizCardNum() >= self.viewCtr:GetCardNumPerBet()
	self.btnBet:FindChild("Chip"):SetActive(not self.isQuizCard)
	self.btnBet:FindChild("Coin"):SetActive(self.isQuizCard)
	self.btnBetGray:FindChild("Chip"):SetActive(not self.isQuizCard)
	self.btnBetGray:FindChild("Coin"):SetActive(self.isQuizCard)
	self.maxSlider.transform:SetActive(false)
	self.maxSlider.value = 1
	self:SetBetNum(1)
end

function M:RefreshJackpot(num)
	local data = self.viewCtr.curMatchInfo
	local id = self.viewCtr.reqGameId
	local isStop = false
	local notStart = false
	if data then
		local svrTime = CC.TimeMgr.GetSvrTimeStamp()
		id = data.GameId
		notStart = svrTime < data.StartBetTime
		isStop = svrTime >= data.EndBetTime
	end

	if notStart then
		self.rightPanel:FindChild("JP/Num").text = 0
		if self.jpRoller then
			self.jpRoller:UpdateGoldPool(0,id)
		end
	elseif isStop then
		if self.jpRoller then
			self.jpRoller:StopRoller()
		end
		self.rightPanel:FindChild("JP/Num").text = CC.uu.numberToStrWithComma(num)
	else
		if not self.jpRoller then
			local param = {}
			param.num = num
			param.textNode = self.rightPanel:FindChild("JP/Num")
			param.id = id
			param.JpData = self.viewCtr.worldCupData.GetMatchJackpotData()
			self.jpRoller = CC.ViewCenter.JackpotRoller.new()
			self.jpRoller:Create(param)
		else
			self.jpRoller:UpdateGoldPool(num,id)
		end
	end

end

function M:RefreshPagePoint()
	for i=1,4 do
		self.pagePoint[i]:SetActive(i<= #self.viewCtr.curDaySchedule)
	end
end

function M:SetEmptyView()
	self.matchDateText.text = ""
	self.matchTimeText.text = ""
	self.matchTeamNode:FindChild("Group").text = ""
	for i=1,2 do
		local team = self.matchTeamNode:FindChild("Team"..i)
		self:SetImage(team,self:GetCircleIconById(0))
		team:FindChild("Name").text = ""

		local likeBtn = self.leftPanel:FindChild("Match/Likes/Btn"..i)
		likeBtn:FindChild("Text").text = 0
		likeBtn.interactable = false
		self:AddClick(likeBtn,function () end)
	end
	for i=1,3 do
		local team = self.guestToggleList[i]
		self:SetImage(team:FindChild("Icon"),self:GetCircleIconById(0))
		team:FindChild("People").text = 0
		team:FindChild("Odds").text = 0
		team:GetComponent("Toggle").isOn = false
		team:SetActive(true)
	end
	self.btnSub:SetActive(false)
	self.btnAdd:SetActive(false)
	self.btnMax:SetActive(false)
	self.btnBetGray:SetActive(true)
	self.maxSlider.transform:SetActive(false)
	self:StopAllTimer()
	self:SetRemainTimeText(0)
	self:SetRefreshTimeText(0)
	self:SetStopBetText(1)
	self.betStopTips:SetActive(true)
	if self.jpRoller then
		self.jpRoller:UpdateGoldPool(0,0)
	end
	self.viewCtr.curDaySchedule = {}
	self:RefreshPagePoint()
end

function M:SetRemainTimer(ts)
	local countDown = ts - CC.TimeMgr.GetSvrTimeStamp()
	self:SetRemainTimeText(countDown)
	self:StartTimer("RemainTimer", 1, function ()
			countDown = countDown - 1
			if countDown < 0 then
				self:StopTimer("RefreshTimer")
				for i=1,3 do
					self.guestToggleList[i]:GetComponent("Toggle").isOn = false
				end
				self.viewCtr:ReqGetWorldCupBetInfo(self.viewCtr.curMatchInfo.GameId)
				self:SetStopBetText(0)
				self.betStopTips:SetActive(true)

			else
				self:SetRemainTimeText(countDown)
			end
		end,-1)
end

function M:SetRemainTimeText(sec)
	local countdown = sec > 0 and sec or 0
	self.remainTimeText.text = CC.uu.TicketFormat(countdown)
end

function M:SetRefreshTimer(ts)
	local countDown = ts - CC.TimeMgr.GetSvrTimeStamp()
	self:SetRefreshTimeText(countDown)
	self:StartTimer("RefreshTimer", 1, function ()
			countDown = countDown - 1
			if countDown < 0 then
				self:StopTimer("RefreshTimer")
				self.viewCtr:ReqGetWorldCupBetInfo(self.viewCtr.curMatchInfo.GameId)
				CC.HallNotificationCenter.inst():post(CC.Notifications.WorldCupTipsViewNotify)
			else
				self:SetRefreshTimeText(countDown)
			end
		end,-1)
end

function M:SetRefreshTimeText(sec)
	local countdown = sec > 0 and sec or 0
	local color
	if sec < 10 then
		color = textColor.refreshR
	elseif sec < 20 then
		color = textColor.refreshY
	else
		color = textColor.refreshG
	end
	self.refreshTimeText.text = string.format(color,CC.uu.TicketFormat(countdown,true))
end

function M:SetBetNum(num)

	self.curBetNum = num
	self.betNumText.text = num
	
	if self.isQuizCard then
		local str = num*self.viewCtr:GetCardNumPerBet()
		self.btnBet:FindChild("Text").text = str
		self.btnBetGray:FindChild("Text").text = str
	else
		local betCount = num*self.viewCtr.baseBet
		local str = CC.uu.ChipFormat(betCount,betCount < 1000000)
		self.btnBet:FindChild("Text").text = str
		self.btnBetGray:FindChild("Text").text = str
	end
end

--1:今日无比赛 2:投注时间未开始 其他：停止投注
function M:SetStopBetText(type)
	if type == 1 then
		self.betStopTips:FindChild("Node/Text").text = self.language.noMatch
	elseif type == 2 then
		self.betStopTips:FindChild("Node/Text").text = self.language.betNotStart
	else
		self.betStopTips:FindChild("Node/Text").text = self.language.betStop
	end
end

function M:OnClickLikesBtn(gameId,countryId)
	self.viewCtr:ReqWorldCupPlayerLike(gameId,countryId)
end

function M:OnClickBtnSub()
	if not self.viewCtr:GetCanBet() then return end
	if self.curBetNum <= 1 then return end
	self:SetBetNum(self.curBetNum - 1)
end

function M:OnClickBtnAdd()
	if not self.viewCtr:GetCanBet() then return end
	if self.curBetNum >= self.viewCtr:GetMaxBetNum(self.curSelect,self.isQuizCard) then return end
	self:SetBetNum(self.curBetNum + 1)
end

function M:OnClickBtnMax()
	if not self.viewCtr:GetCanBet() then return end
	local isActive = self.maxSlider.transform.activeSelf
	self.maxSlider.transform:SetActive(not isActive)
end

function M:OnClickBtnBet()
	if not self.viewCtr:GetCanBet() or self.curSelect == 0 or self.curBetNum <= 0 then return end
	local areaInfo = self.viewCtr.areaInfo[self.curSelect]
	local param = {}
	param.Index = 2
	param.Odds = areaInfo.Odds
	param.SpriteName = self:GetSquareIconById(areaInfo.CountryId)
	param.CountryID = areaInfo.CountryId
	param.Amount = self.curBetNum*self.viewCtr.baseBet
	param.SureBtnCb = function()
		self.viewCtr:ReqPlayerBet(areaInfo.AreaId,self.curBetNum,self.isQuizCard,areaInfo.Odds)
	end
	param.CanelBtnCb = function()
		
	end
	CC.ViewManager.OpenEx("WorldCupTipsView",param)
end

function M:OnSliderValueChange(value)
	self:SetBetNum(value)
end

function M:OnSwitchMatchDate(index)
	self.clickDay = index
	local data = self.viewCtr.dateList[index]
	if not data then
		self:SetEmptyView()
		return
	elseif data.lock and not self.viewCtr.showNextDay then
		return
	end
	
	for i=1,4 do
		self.dayItem[i]:FindChild("Light"):SetActive(i==index)
	end
	self.viewCtr:ReqGetWorldCupSchedule(index)
end

function M:OnSwitchMatchPage(page)
	if page < 1 or page > #self.viewCtr.curDaySchedule then return end
	
	self.curPage = page
	for i=1,4 do
		self.pagePoint[i]:FindChild("Light"):SetActive(i==page)
	end
	self.pageText.text = string.format(self.language.matchOrder,page)
	local data = self.viewCtr.curDaySchedule[page]
	self.viewCtr:ReqGetWorldCupGameInfo(data.GameId)
	self.viewCtr:ReqGetWorldCupBetInfo(data.GameId)
end

--index: 1-队伍1 2-队伍2 3-平
function M:OnGuestToggleChange(isSelect,index)
	if isSelect then
		if not self.viewCtr:GetCanBet() then return end
		self.curSelect = index
		self:SetBtnState(true)
		local maxNum = self.viewCtr:GetMaxBetNum(index,self.isQuizCard)
		self.maxSlider.maxValue = maxNum > 0 and maxNum or 1
	elseif index == self.curSelect then
		self.curSelect = 0
		self:SetBtnState(false)
		self.maxSlider.transform:SetActive(false)
	end
end

function M:SetBtnState(state)
	self.btnBetGray:SetActive(not state)
	self.btnAdd:SetActive(state)
	self.btnSub:SetActive(state)
	self.btnMax:SetActive(state)
end

function M:PlayVsAnimation()
	self.vsAnimator:Play("ef_dt_sjb_vs",0,0)
end

function M:GetCircleIconById(id)
	return "circle_"..id
end

function M:GetSquareIconById(id)
	return "square_"..id
end

function M:ActionIn()
	local node = self:FindChild("RightPanel");
	local x,y = node.x,node.y;
	node.x = -950;
	self:RunAction(node, {"localMoveTo", x, y, 0.3, ease = CC.Action.EOutSine, function() end})

	local node = self:FindChild("LeftPanel");
	local x,y = node.x,node.y;
	node.x = -1470;
	self:RunAction(node, {"localMoveTo", x, y, 0.3, delay = 0.1, ease = CC.Action.EOutSine, function() end})
end

function M:ActionOut(cb)

	local node = self:FindChild("LeftPanel");
	self:RunAction(node, {"localMoveTo", -1470, node.y, 0.3, ease = CC.Action.EOutSine, function() end})

	local node = self:FindChild("RightPanel");
	self:RunAction(node, {"localMoveTo", -950, node.y, 0.3, delay = 0.1, ease = CC.Action.EOutSine, function()
				self:Destroy();
				if cb then cb() end
			end})
end

function M:OnDestroy()
	
	self:StopAllTimer()
	
	if self.jpRoller then
		local data = self.jpRoller:GetJackpotData()
		self.viewCtr.worldCupData.SetMatchJackpotData(data)
		self.jpRoller:Destroy()
		self.jpRoller = nil
	end
	
	if self.mascot then
		self.mascot:Destroy()
		self.mascot = nil
	end
	
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end

end

return WorldCupBetView