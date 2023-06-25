local CC = require("CC")
local WorldCupBetViewCtr = CC.class2("WorldCupBetViewCtr")
local M = WorldCupBetViewCtr

function M:ctor(view,param)
	self:InitVar(view,param)
end

function M:InitVar(view,param)
    self.view = view
	self.param = param
	self.baseBet = 10000
	self.minKeep = 0
	self.dateList = {}
	self.curDaySchedule = {}
	self.laseReqScheduleTime = 0
	self.cardValue = 1000
	self.worldCupData = CC.DataMgrCenter.Inst():GetDataByKey("WorldCupData")
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnGetWorldCupTimeRangeRsp, CC.Notifications.NW_ReqGetWorldCupTimeRange)
	CC.HallNotificationCenter.inst():register(self, self.OnGetWorldCupScheduleRsp, CC.Notifications.NW_ReqGetWorldCupSchedule)
	CC.HallNotificationCenter.inst():register(self, self.OnGetWorldCupGameInfoRsp, CC.Notifications.NW_ReqGetWorldCupGameInfo)
	CC.HallNotificationCenter.inst():register(self, self.OnGetWorldCupBetInfoRsp, CC.Notifications.NW_ReqGetWorldCupBetInfo)
	CC.HallNotificationCenter.inst():register(self, self.OnPlayerBetRsp, CC.Notifications.NW_ReqPlayerBet)
	CC.HallNotificationCenter.inst():register(self, self.OnWorldCupPlayerLikeRsp, CC.Notifications.NW_ReqWorldCupPlayerLike)
	CC.HallNotificationCenter.inst():register(self, self.OnPropChange, CC.Notifications.changeSelfInfo)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function M:OnCreate()
	self:RegisterEvent()
end

function M:StartRequest()
	local dateList = self.worldCupData.GetScheduleDateList()
	if dateList and not table.isEmpty(dateList) then
		self:SetDateList(dateList)
	else
		self:ReqGetWorldCupTimeRange()
	end
end

function M:ReqGetWorldCupTimeRange()
	CC.Request("ReqGetWorldCupTimeRange")
end

function M:OnGetWorldCupTimeRangeRsp(err,data)
	if err ~= 0 then
		logError("ReqGetWorldCupTimeRange err:"..err)
		return
	end
	CC.uu.Log(data,"OnGetWorldCupTimeRangeRsp",1)
	self.worldCupData.SetScheduleDateList(data)
	local allDateList = self.worldCupData.GetScheduleDateList()
	self:SetDateList(allDateList)

end

function M:SetDateList(allDateList,targetTs)
	self.dateList = {}
	local serverTS = CC.TimeMgr.GetSvrTimeStamp()
	local startTs = targetTs or serverTS
	for _,v in ipairs(allDateList) do
		local timeInfo1 = CC.TimeMgr.GetConvertTimeInfo(startTs)
		local timeInfo2 = CC.TimeMgr.GetConvertTimeInfo(v)
		if (timeInfo1.year<=timeInfo2.year and timeInfo1.yday <= timeInfo2.yday) and #self.dateList<4 then
			local t = {}
			t.ts = v
			--t.lock = v > serverTS + 86400*3
			t.lock = false--最后几场不锁了
			table.insert(self.dateList,t)
		end
	end
	self.view:RefreshDayItem(self.dateList)
end

function M:ReqGetWorldCupSchedule(index)
	local timeStamp = self.dateList[index].ts
	self.view:SetCanClick(false)
	self.reqScheduleIdx = index
	CC.Request("ReqGetWorldCupSchedule",{SpecifyDay = timeStamp})
end

function M:OnGetWorldCupScheduleRsp(err,data)
	self.view:SetCanClick(true)
	if err ~= 0 then
		logError("ReqGetWorldCupSchedule err:"..err)
		return
	end
	CC.uu.Log(data,"OnGetWorldCupScheduleRsp",1)
	
	local endBetNum = 0
	local param = {}
	local ts = CC.TimeMgr.GetSvrTimeStamp()
	for _,v in ipairs(data.SpecifyDayGames) do
		if ts >= v.EndBetTime then
			endBetNum = endBetNum +1
		end
		table.insert(param,v)
	end
	self.showNextDay = false
	if table.isEmpty(param) and self.reqScheduleIdx ~= 1 then 
		self.view:SetEmptyView()
		return
	elseif endBetNum == #param and self.dateList[2] then
		--当天比赛全都停止投注
		local allDateList = self.worldCupData.GetScheduleDateList()
		if self.dateList[2] then
			self.showNextDay = true
			self:SetDateList(allDateList,self.dateList[2].ts)
		end
		return
	end
	
	local _sort = function(a,b)
		if a.GameResult then
			return false
		end
		if b.GameResult then
			return true
		end
		if ts >= a.EndBetTime then
			return false
		end
		if ts >= b.EndBetTime then
			return true
		end
		
		return a.StartBetTime < b.StartBetTime
	end
	table.sort(param,_sort)
	self.curDaySchedule = param
	self.view:RefreshPagePoint()
	self.view:OnSwitchMatchPage(1)
end

function M:ReqGetWorldCupGameInfo(gameId)
	self.reqGameId = gameId
	local param = {}
	param.GameId = gameId
	CC.Request("ReqGetWorldCupGameInfo",param)
end

function M:OnGetWorldCupGameInfoRsp(err,data)
	if err ~= 0 then
		logError("ReqGetWorldCupGameInfo err:"..err)
		return
	end
	CC.uu.Log(data,"OnGetWorldCupGameInfoRsp",1)
	self.curMatchInfo = data
	self.baseBet = data.BaseBet
	self.minKeep = data.GuaranteedCoins
	self.cardValue = data.QuizCardValue
	self.view:RefreshUI({matchData = data})
end

function M:ReqGetWorldCupBetInfo(gameId)
	self.view:SetCanClick(false)
	self.reqGameId = gameId
	local param = {}
	param.GameId = gameId
	param.GameType = CC.shared_enums_pb.WC_GroupGame
	CC.Request("ReqGetWorldCupBetInfo",param)
end

function M:OnGetWorldCupBetInfoRsp(err,data)
	self.view:SetCanClick(true)
	if err ~= 0 then
		logError("ReqGetWorldCupBetInfo err:"..err)
		return
	end
	CC.uu.Log(data,"OnGetWorldCupBetInfoRsp",1)
	local i = 1
	self.areaInfo = {}
	for _,v in ipairs(data.AreaBetInfo) do
		if v.CountryId == 888 then
			self.areaInfo[3] = v
		else
			self.areaInfo[i] = v
			i = i + 1
		end
	end
	
	local param = {}
	param.JackPot = data.JackPot
	param.AreaBetInfo = self.areaInfo
	param.NextRefreshTime = data.NextRefreshTime
	self.view:RefreshUI({betData = param})
end

function M:ReqPlayerBet(areaId,count,isQuizCard,odds)
	local param = {}
	param.GameId = self.curMatchInfo.GameId
	param.AreaId = areaId
	param.Count = count
	if isQuizCard then
		param.BetType = CC.shared_enums_pb.WC_PropCard
	else
		param.BetType = CC.shared_enums_pb.WC_ChouMa
	end
	param.GameType = CC.shared_enums_pb.WC_GroupGame
	param.Odds = odds
	CC.Request("ReqPlayerBet",param)
end

function M:OnPlayerBetRsp(err,data)
	if err ~= 0 then
		if err == 616 then
			CC.ViewManager.ShowTip(self.view.language.betFaile)
			self:ReqGetWorldCupBetInfo(self.curMatchInfo.GameId)
		end
		logError("ReqPlayerBet err:"..err)
		return
	end
	CC.uu.Log(data,"OnPlayerBetRsp",1)
	local param = {}
	param.Index = 3
	param.TicketNum = data.OrderId
	param.SureBtnCb = function()
		self:ReqGetWorldCupBetInfo(self.curMatchInfo.GameId)
	end
	CC.ViewManager.OpenEx("WorldCupTipsView",param)
end

function M:ReqWorldCupPlayerLike(gameId,countryId)
	local param = {}
	param.GameId = gameId
	param.CountryId = countryId
	CC.Request("ReqWorldCupPlayerLike",param)
end

function M:OnWorldCupPlayerLikeRsp(err,data)
	if err ~= 0 then
		logError("ReqWorldCupPlayerLike err:"..err)
		return
	end
	self:ReqGetWorldCupGameInfo(self.curMatchInfo.GameId)
end

function M:OnPropChange(props, source)
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_WorldCup_QuizCard then
			self.view:RefreshBetBtn()
			break
		end
	end
end

function M:GetCanBet()
	if not self.curMatchInfo then return false end
	local betChipNum = self.view.isQuizCard and 0 or self.view.curBetNum*self.baseBet
	local serverTS = CC.TimeMgr.GetSvrTimeStamp()
	if serverTS < self.curMatchInfo.StartBetTime then
		CC.ViewManager.ShowTip(self.view.language.betNotStart)
		return false
	elseif CC.DataMgrCenter.Inst():GetDataByKey("WorldCupData").IsShowWorldCupGift(betChipNum,self.view.isQuizCard) then
		return false
	end
	return true
end

function M:GetQuizCardNum()
	return CC.Player.Inst():GetSelfInfoByKey("EPC_WorldCup_QuizCard") or 0
end

function M:GetMaxBetNum(index,isQuizCard)
	
	if not self.areaInfo or table.isEmpty(self.areaInfo) then return 0 end
	local maxBet = math.floor(self.areaInfo[index].BetMax/self.baseBet)
	
	if isQuizCard then
		local own = self:GetQuizCardNum()
		local perBet = self:GetCardNumPerBet()
		local canBetNum = math.floor(own/perBet)
		return canBetNum < maxBet and canBetNum or maxBet
	else
		local chip = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
		local canBetNum = chip>self.minKeep and math.floor((chip-self.minKeep)/self.baseBet) or 0
		return canBetNum < maxBet and canBetNum or maxBet
	end
end

function M:GetCardNumPerBet()
	return self.baseBet/self.cardValue
end

function M:Destroy()
	self:UnRegisterEvent()
end

return WorldCupBetViewCtr