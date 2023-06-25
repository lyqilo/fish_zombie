-- region RankDataManager.lua
-- Date: 2018.12.10
-- Desc: 任务管理类
-- Author: Chaoe

local CC = require("CC")

local RankDataManager = {}

local WeeklyRank = nil
local DailyRank = nil
local SuperRank = nil

local WeeklyMyRank = nil
local DailyMyRank = nil
local SuperMyRank = nil
local SuperMyScore = nil

--月末赢分榜
local MonthRank = nil

---泼水节排行榜数据
local SongkranTotalRank = nil	--总榜
local SongkranLeisureRank = nil	--休闲
local SongkranSlotRank = nil	--老虎机
local SongkranPokerRank = nil	--棋牌

local SongkranSuccCount = 0

--周榜数据
function RankDataManager.SetWeeklyRankData(data)
	WeeklyRank = data.Rank
	WeeklyMyRank = data.MyRank
end

--每日赢取排行榜数据
function RankDataManager.SetDailyRankData(data)
	DailyRank = data.Rank
	DailyMyRank = data.MyRank
end


--最大筹码榜数据
function RankDataManager.SetSuperRankData(data)
	SuperRank = data.Rank
	SuperMyRank = data.MyRank
	SuperMyScore = data.MyScore
end

--根据下标获取最大筹码榜数据
function RankDataManager.GetSuperRankItemData(index)
	if not SuperRank then
		return nil
	end
	return SuperRank[index]
end

--根据下标获取每日赢取数据
function RankDataManager.GetDailyRankItemData(index)
	if not DailyRank then
		return
	end
	return DailyRank[index]
end

--获取相应下标的周榜数据
function RankDataManager.GetWeeklyRankItemData(index)
	if not WeeklyRank then
		return nil
	end
	return WeeklyRank[index]
end

--根据id获取最大筹码榜/每日赢取榜/周榜
function RankDataManager.GetDataByIndexAndPageIndex(pageindex,rankId)
	if pageindex == 1 then
		return RankDataManager.GetSuperRankItemData(rankId)
	elseif pageindex == 2 then
		return RankDataManager.GetDailyRankItemData(rankId)
	elseif pageindex == 3 then
		return RankDataManager.GetWeeklyRankItemData(rankId)
	end
end

--获取最大筹码榜长度
function RankDataManager.GetSuperRankLen()
	if not SuperRank then
		return 0
	else
		return #SuperRank
	end
end
--获取周榜长度
function RankDataManager.GetWeeklyRankLen()
	if not WeeklyRank then
		return 0
	else
		return #WeeklyRank
	end
end

--获取日榜数据
function RankDataManager.GetDailyRankLen()
	if not DailyRank then
		return 0
	else
		return #DailyRank
	end
end

--根据玩家id修改最大筹码榜昵称
function RankDataManager.SetSuperRankitemName(Id,name)
	for i,v in ipairs(SuperRank) do
		if v.Player.Id == Id then
			SuperRank[i].Player.Nick = name
		end
	end
end

--根据玩家id修改每日赢取榜昵称
function RankDataManager.SetDailyRankitemName(Id,name)
	for i,v in ipairs(DailyRank) do
		if v.Player.Id == Id then
			DailyRank[i].Player.Nick = name
		end
	end
end

--根据玩家id修改每周赢取榜昵称
function RankDataManager.SetWeeklyRankitemName(Id,name)
	for i,v in ipairs(WeeklyRank) do
		if v.Player.Id == Id then
			WeeklyRank[i].Player.Nick = name
		end
	end
end

--玩家排名
function RankDataManager.GetMyRank(pageindex)
	if pageindex == 1 then
		if SuperMyRank ~= 0 then
			return SuperMyRank
		else
			return "No ranking"
		end
	elseif pageindex == 2 then
		if DailyMyRank ~= 0 then
			return DailyMyRank
		else
			return "No ranking"
		end
	elseif pageindex == 3 then
		if WeeklyMyRank ~= 0 then
			return WeeklyMyRank
		else
			return "No ranking"
		end
	end
end

function RankDataManager.GetSuperMyScore()
	return SuperMyScore
end

--根据id获取最大筹码榜/每日赢取榜/周榜长度
function RankDataManager.GetRankMgrLen(pageindex)
	if pageindex == 1 then
		return RankDataManager.GetSuperRankLen()
	elseif pageindex == 2 then
		return RankDataManager.GetDailyRankLen()
	elseif pageindex == 3 then
		return RankDataManager.GetWeeklyRankLen()
	end
end

-------------------------------------------------泼水节-------------------------------------------------
function RankDataManager.SetSongkranRankData(data)
	if data.Type == 0 then
		SongkranTotalRank = data.Datas
		SongkranSuccCount = SongkranSuccCount + 1
	elseif data.Type == 1 then
		SongkranLeisureRank = data.Datas
		SongkranSuccCount = SongkranSuccCount + 1
	elseif data.Type == 2 then
		SongkranSlotRank = data.Datas
		SongkranSuccCount = SongkranSuccCount + 1
	elseif data.Type == 3 then
		SongkranPokerRank = data.Datas
		SongkranSuccCount = SongkranSuccCount + 1
	end
end

function RankDataManager.GetSongkranSuccCount()
	return SongkranSuccCount
end

function RankDataManager.GetSongkranRankInfo(Type,rank)
	if Type == 0 then
		if SongkranTotalRank and SongkranTotalRank[rank] then
			return SongkranTotalRank[rank]
		else
			return nil
		end
	elseif Type == 1 then
		if SongkranLeisureRank and SongkranLeisureRank[rank] then
			return SongkranLeisureRank[rank]
		else
			return nil
		end
	elseif Type == 2 then
		if SongkranSlotRank and SongkranSlotRank[rank] then
			return SongkranSlotRank[rank]
		else
			return nil
		end
	elseif Type == 3 then
		if SongkranPokerRank and SongkranPokerRank[rank] then
			return SongkranPokerRank[rank]
		else
			return nil
		end
	end
end

function RankDataManager.GetSongkranRankCount(Type)
	if Type == 0 and SongkranTotalRank then
		return #SongkranTotalRank
	elseif Type == 1 and SongkranLeisureRank then
		return #SongkranLeisureRank
	elseif Type == 2 and SongkranSlotRank then
		return #SongkranSlotRank
	elseif Type == 3 and SongkranPokerRank then
		return #SongkranPokerRank
	end
end

function RankDataManager.SetMonthRankData(data)
	if not MonthRank then
		MonthRank = {}
	end
	MonthRank[data.Type] = data.Datas or {}
end

function RankDataManager.GetMonthRankData(Type)
	if not MonthRank then
		return nil
	else
		return MonthRank[Type]
	end
end


function RankDataManager.ClearData()
	WeeklyRank = nil
	DailyRank = nil
	SuperRank = nil
	WeeklyMyRank = nil
	DailyMyRank = nil
	SuperMyRank = nil
	SuperMyScore = nil

	--月末排行榜
	MonthRank = nil

	--泼水节
	SongkranTotalRank = nil	--总榜
	SongkranLeisureRank = nil	--休闲
	SongkranSlotRank = nil	--老虎机
	SongkranPokerRank = nil	--棋牌
	SongkranSuccCount = 0
end

return RankDataManager

