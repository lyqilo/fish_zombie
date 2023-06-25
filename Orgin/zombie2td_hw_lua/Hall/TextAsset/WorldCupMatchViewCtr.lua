local CC = require("CC")
local WorldCupMatchViewCtr = CC.class2("WorldCupMatchViewCtr")
local M = WorldCupMatchViewCtr

function M:ctor(view,param)
	self:InitVar(view,param)
end

function M:InitVar(view,param)
    self.view = view
	self.param = param
	self.dateRange = {}
	self.dateInfoList = {}
	self.worldCupData = CC.DataMgrCenter.Inst():GetDataByKey("WorldCupData")
	self.scheduleList = {}
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnGetWorldCupTimeRangeRsp, CC.Notifications.NW_ReqGetWorldCupTimeRange)
	CC.HallNotificationCenter.inst():register(self, self.OnGetWorldCupScheduleRsp, CC.Notifications.NW_ReqGetWorldCupSchedule)
	CC.HallNotificationCenter.inst():register(self, self.OnGetWorldCupChampionScheduleRsp, CC.Notifications.NW_ReqGetWorldCupChampionSchedule)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function M:OnCreate()
	self:RegisterEvent()
end

function M:StartRequest()
	self:ReqGetWorldCupTimeRange()
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
	self.dateInfoList = self.worldCupData.GetScheduleDateList()
	local svrTimeStamp = CC.TimeMgr.GetSvrTimeStamp()
	local timeInfo1 = CC.TimeMgr.GetConvertTimeInfo(svrTimeStamp)
	local endTimeInfo = CC.TimeMgr.GetConvertTimeInfo(data.WorldCupEndTime)
	if (timeInfo1.year <= endTimeInfo.year and timeInfo1.yday < endTimeInfo.yday) then
		for k,v in ipairs(self.dateInfoList) do
			local timeInfo2 = CC.TimeMgr.GetConvertTimeInfo(v)
			if (timeInfo1.year <= timeInfo2.year and timeInfo1.yday < timeInfo2.yday) then
				self.view.dateStartIndex = k
				break
			end
		end
	else
		self.view.dateStartIndex = #self.dateInfoList
	end
	
	self.view:RefreshDate()
end

function M:ReqGetWorldCupSchedule(index)
	local timeStamp = self.dateInfoList[index]
	if not timeStamp then return end
	if self.scheduleList[index] then
		self.view:RefreshMatchList(self.scheduleList[index])
	else
		self.view:SetCanClick(false)
		self.reqIndex = index
		CC.Request("ReqGetWorldCupSchedule",{SpecifyDay = timeStamp})
	end
end

function M:OnGetWorldCupScheduleRsp(err,data)
	self.view:SetCanClick(true)
	if err ~= 0 then
		logError("ReqGetWorldCupSchedule err:"..err)
		return
	end
	CC.uu.Log(data,"OnGetWorldCupScheduleRsp",1)
	local param = {}
	for _,v in ipairs(data.SpecifyDayGames) do
		local t = {}
		t.gameName = v.GameName
		t.startTime = v.GameStartTime
		t.countrys = v.Countrys
		if v.GameResult then
			--比赛结束
			t.status = 2
		elseif CC.TimeMgr.GetSvrTimeStamp() > v.GameStartTime then
			--比赛中
			t.status = 1
		else
			--比赛未结束
			t.status = 0
		end
		table.insert(param,t)
	end
	if self.reqIndex then
		self.scheduleList[self.reqIndex]  = param
	end
	self.view:RefreshMatchList(param)
end

function M:ReqGetWorldCupChampionSchedule()
	self.view:SetCanClick(false)
	CC.Request("ReqGetWorldCupChampionSchedule")
end

function M:OnGetWorldCupChampionScheduleRsp(err,data)
	self.view:SetCanClick(true)
	if err ~= 0 then
		logError("ReqGetWorldCupChampionSchedule err:"..err)
		return
	end
	CC.uu.Log(data,"OnGetWorldCupChampionScheduleRsp",1)
	local param = {}
	for _,v in ipairs(data.ChampionSchedule) do
		local t = {}
		t.gameResult = v.GameResult
		t.gameStartTime = v.GameStartTime
		t.country = v.Country
		t.status = v.Country[1].CountryId == 0 and 0 or 1
		
		if not param[v.Phase] then
			param[v.Phase] = {}
		end
		table.insert(param[v.Phase],t)
	end
	self.view:RefreshEliminatorList(param)
end

function M:Destroy()
	self:UnRegisterEvent()
end

return WorldCupMatchViewCtr