-- 高V数据管理类
local CC = require("CC")

local AgentDataMgr = {}
local this = AgentDataMgr

local EarnType = {
	Total = 0,
	Share = CC.proto.client_agent_pb.EarnFromShare,
	Newer = CC.proto.client_agent_pb.EarnFromNewer,
	Trade = CC.proto.client_agent_pb.EarnFromTrade,
	ByUnlock = CC.proto.client_agent_pb.EarnFromGiveByUnlockView,
	Task = CC.proto.client_agent_pb.EarnFromTask
}

local shareUrl = nil
function this.GetAgentUrl()
	return shareUrl
end

function this.SetAgentUrl(url)
	shareUrl = url
end

function this.ReqAgentUrl(textureUrl, callback)
	local agentId = CC.Player.Inst():GetSelfInfoByKey("Id") or "0"
	local channelCode = AppInfo.ChannelID or "0"
	local data = {
		textureUrl = textureUrl,
		callback = callback,
		urlData = {
			channelCode = channelCode,
			agentId = agentId,
			isDeepPlayer = CC.HallUtil.CheckDeepPlayer()
		}
	}
	CC.FirebasePlugin.CreateAgentLink(data)
end

local gList = {}
local oldAgentSum = 0

local gList_month = {}

local jCount = 0
local jMap = {} -- {[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6}

local jList_sortList = {}

local jList_sortList_reversal = {}

local SortKeyEnum = {
	"vip",
	"totalEarn",
	"totalEarnFromShare",
	"totalEarnFromNewer",
	"totalEarnFromTrade",
	"joinTime",
	"lastActivityTime"
}

local function sortFunc(list, key)
	table.sort(
		list,
		function(a, b)
			return a[key] > b[key]
		end
	)
end

local unReceiveEarnData = nil
local historyEarnData = {}
local historyEarnTotal = {}
local historyIntegralEarn = 0
local hCount = 0
local shareTotalEran = {}
--高级vip状态
local agentStatus = false
local IsForbiddenAgent = false
local PromotionRemainTime = -1
local LockStatus = false
local LockTime = -1

function this.SetAgentSatus(data)
	local oldAgentStatus = agentStatus
	agentStatus = data.AgentType == 1
	IsForbiddenAgent = data.IsForbiddenAgent
	PromotionRemainTime = data.PromotionRemainTime
	LockStatus = data.RewardLockStatus == 1
	LockTime = data.RewardLockTime
	if agentStatus ~= oldAgentStatus then
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnNewAgentStatus)
	end
end
function this.GetAgentSatus()
	return agentStatus
end
function this.GetForbiddenAgentSatus()
	return IsForbiddenAgent
end
function this.GetRemainTime()
	return PromotionRemainTime or 0
end
function this.GetAgentLockStatus()
	return LockStatus
end
function this.GetAgentLockTime()
	return LockTime or 0
end

function this.GetHistoryEarnCount()
	return hCount
end

function this.CurHistoryEarnCount()
	return historyEarnData[EarnType.Total] and #historyEarnData[EarnType.Total] or 0
end

--[[
	{
		-- year
		[2020] = {
			-- month
			[1] = {
				-- day
				[6] = 1,[7] = 3,...
			},
			...
			[12] = {
				...
			}
		},
		[2021] = {
			...
		}
	}
]]
function this.GetGeneralizeDataList()
	return gList
end

function this.GetGeneralizeMonthDataList(monthInYear)
	return gList_month[monthInYear]
end

function this.GetGeneralizeCount()
	local sum = 0
	for _, year in pairs(gList) do
		for k, m in pairs(year) do
			sum = sum + m
		end
	end
	sum = sum + oldAgentSum
	return sum
end

function this.GetJuniorCount()
	return jCount
end

function this.GetJuniorByID(id)
	return jMap[id]
end

function this.GetJuniorDataListBySortType(typeIndex, reversal)
	local list
	if reversal then
		list = jList_sortList_reversal[typeIndex]
	else
		list = jList_sortList[typeIndex]
	end
	return list
end

function this.CurYear()
	return tonumber(os.date("%Y"))
end

function this.CurMonth()
	return tonumber(os.date("%m"))
end

function this.CurDay()
	return tonumber(os.date("%d"))
end

function this.SetShareTotalEarn(data)
	shareTotalEran = data
end

function this.GetShareTotalEarn()
	return shareTotalEran
end

function this.Init()
end

function this.GetUnReceiveEarn()
	return unReceiveEarnData
end

function this.SetUnReceiveEarn(code, data)
	log(CC.uu.Dump(data, "SetUnReceiveEarn", 10))
	if code == 0 then
		if unReceiveEarnData and data then
			local earnType = data.earnType
			if earnType == EarnType.Trade then
				unReceiveEarnData.earnFromTrade = 0
			elseif earnType == EarnType.Share then
				unReceiveEarnData.earnFromShare = 0
			elseif earnType == EarnType.Newer then
				unReceiveEarnData.earnFromNewer = 0
			end
			CC.HallNotificationCenter.inst():post(CC.Notifications.OnReflashAgentReceiveBtns, unReceiveEarnData)
		end
	end
end

local function DealHistoryEarn()
	local data = historyEarnData[EarnType.Total]
	local list1 = {}
	local list2 = {}
	local list3 = {}
	local sum1 = 0
	local sum2 = 0
	local sum3 = 0
	for i, v in ipairs(data) do
		if v.earnType == EarnType.Share then
			table.insert(list1, v)
			sum1 = sum1 + v.earn
		elseif v.earnType == EarnType.Task then
			table.insert(list2, v)
			sum2 = sum2 + v.earn
		elseif v.earnType == EarnType.Trade then
			table.insert(list3, v)
			sum3 = sum3 + v.earn
		end
	end
	historyEarnData[EarnType.Share] = list1
	historyEarnData[EarnType.Task] = list2
	historyEarnData[EarnType.Trade] = list3
	historyEarnTotal[EarnType.Share] = sum1
	historyEarnTotal[EarnType.Task] = sum2
	historyEarnTotal[EarnType.Trade] = sum3
end

function this.GetHistoryEarn(earnType)
	if earnType == EarnType.Newer then
		earnType = EarnType.Task
	end
	return historyEarnData[earnType] or {}
end

function this.GetHistoryEarnTotal(earnType)
	return historyEarnTotal[earnType] or 0
end
function this.GetHistoryIntegralEarn()
	return historyIntegralEarn or 0
end

function this.LoadUnReceiveEarn(func, param)
	local func = func or function()
		end
	if unReceiveEarnData and false then
		CC.uu.DelayRun(0, func, unReceiveEarnData)
	else
		CC.Request(
			"LoadUnReceiveEarn",
			nil,
			function(code, data)
				log(CC.uu.Dump(data))
				unReceiveEarnData = data
				if func then
					func(unReceiveEarnData)
				end
			end,
			function(code, data)
				logError(code)
				log(CC.uu.Dump(data))
				func()
			end
		)
	end
end

function this.LoadHistoryEarn(func, earnType, cursor)
	if historyEarnData and historyEarnData[EarnType.Total] and false then
		CC.uu.DelayRun(0, func, historyEarnData)
	else
		local param = {}
		if earnType == EarnType.Newer then
			earnType = EarnType.Task
		end
		param.earnType = earnType
		param.cursor = cursor
		CC.Request(
			"LoadHistoryEarn",
			param,
			function(code, data)
				log(CC.uu.Dump(data))
				if data then
					if historyEarnData[EarnType.Total] == nil then
						historyEarnData[EarnType.Total] = {}
					end
					local list = historyEarnData[EarnType.Total]
					local isDirty = false
					for i, v in ipairs(data.historyEarns) do
						-- table.insert(list,v)
						local old = list[cursor + i]
						list[cursor + i] = v
						if old and old.endTime ~= v.endTime then
							isDirty = true
						end
					end
					if isDirty then
						for i = #list, cursor + #data.historyEarns + 1, -1 do
							list[i] = nil
						end
					end
					historyEarnTotal[EarnType.Total] = data.totalEarn
					hCount = data.totalNum
					historyIntegralEarn = data.totalGiftEarn

					DealHistoryEarn()
				end
				func(data)
			end,
			function(code, data)
				logError(code)
				log(CC.uu.Dump(data))
				func()
			end
		)
	end
end

function this.LoadMonthPromote(func, param)
	if gList and false then
		CC.uu.DelayRun(0, func, gList)
	else
		CC.Request(
			"LoadMonthPromote",
			nil,
			function(code, data)
				log(CC.uu.Dump(data))
				if data then
					local jsonData
					if
						data.json and data.json ~= "" and
							CC.uu.SafeCallFunc(
								function()
									jsonData = Json.decode(data.json)
								end
							)
					 then
						gList = jsonData
					end
					oldAgentSum = data.oldAgentChildNum
				end
				func(gList)
			end,
			function(code, data)
				logError(code)
				log(CC.uu.Dump(data))
				func(gList)
			end
		)
	end
end

function this.LoadDayPromote(func, monthInYear)
	if gList_month and gList_month[monthInYear] and false then
		CC.uu.DelayRun(0, func, gList_month)
	else
		CC.Request(
			"LoadDayPromote",
			{monthInYear = monthInYear},
			function(code, data)
				log(CC.uu.Dump(data))
				if data then
					local jsonData
					if
						data.json and
							CC.uu.SafeCallFunc(
								function()
									jsonData = Json.decode(data.json)
								end
							)
					 then
						gList_month[monthInYear] = jsonData
					end
				end
				func(gList_month[monthInYear])
			end,
			function(code, data)
				logError(code)
				log(CC.uu.Dump(data))
				func(gList_month[monthInYear])
			end
		)
	end
end

function this.LoadSubAgentList(func, sortType, cursor, smallToBig)
	local list
	if smallToBig then
		if jList_sortList_reversal[sortType] == nil then
			jList_sortList_reversal[sortType] = {}
		end
		list = jList_sortList_reversal[sortType]
	else
		if jList_sortList[sortType] == nil then
			jList_sortList[sortType] = {}
		end
		list = jList_sortList[sortType]
	end
	local param = {}
	param.sortType = sortType
	if sortType == 3 or sortType == 5 then
		param.sortType = 8
	elseif sortType == 4 or sortType == 6 then
		param.sortType = sortType - 1
	end
	param.cursor = cursor
	param.smallToBig = smallToBig

	CC.Request(
		"LoadSubAgentList",
		param,
		function(code, data)
			log(CC.uu.Dump(data))
			if data then
				local isDirty = false
				for i, v in ipairs(data.agentInfos) do
					-- table.insert(list,v)
					local old = list[cursor + i]
					list[cursor + i] = v
					if old and old.agentId ~= v.agentId then
						isDirty = true
					end
					jMap[v.agentId] = v
				end
				if isDirty or (#list ~= data.subAgentNum) then
					for i = #list, cursor + #data.agentInfos + 1, -1 do
						list[i] = nil
					end
				end
				jCount = data.subAgentNum
			end
			func(list)
		end,
		function(code, data)
			logError(code)
			log(CC.uu.Dump(data))
			func(list)
		end
	)
end

function this.SearchSubAgent(func, subAgentId)
	if jMap and jMap[subAgentId] then
		logError(subAgentId)
		CC.uu.DelayRun(0, func, {jMap[subAgentId]})
	else
		CC.Request(
			"SearchSubAgent",
			{subAgentId = subAgentId},
			function(code, data)
				log(CC.uu.Dump(data))
				local info = nil
				if data then
					info = data.agentInfos
				end
				func(info)
			end,
			function(code, data)
				logError(code)
				log(CC.uu.Dump(data))
				local info = nil
				func(info)
			end
		)
	end
end

function this.BindAgent(agentid, cb)
	CC.Request("BindAgent", {agentid = agentid, imei = CC.Platform.GetDeviceId()}, cb, cb)
end

-- function this.CheckMeIfAgent()
-- 	CC.Request("CheckMeIfAgent")
-- end

function this.ApplyRootAgent(cb)
	CC.Request("ApplyRootAgent", nil, cb, cb)
end

function this.Request(ReqFunc, func, param)
	ReqFunc(
		param,
		function(code, data)
			log(CC.uu.Dump(data))
			func(data)
		end,
		function(code, data)
			logError(code)
			log(CC.uu.Dump(data))
			func()
		end
	)
end

return this
