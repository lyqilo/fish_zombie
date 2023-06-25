-- region ShakeDataManager.lua
-- Date: 2019.6.05
-- Desc: ShakeDataManager
-- Author: chris

local CC = require("CC")

local ShakeDataManager = CC.class2("ShakeDataManager")

local Exist = false
local ShakeOpenTab = {}
local RankTab = {}
local RankLen = 0
local MyRankTab = {}

--写入是否暗补
function ShakeDataManager.SetExistState(b)
	Exist = b
end

--读取是否暗补
function ShakeDataManager.GetExistState()
	return Exist
end

--写入开奖请求 返回体
function ShakeDataManager.SetShakeOpen(data)
	ShakeOpenTab = data
end

--获取开奖的色子点数
function ShakeDataManager.GetPoints()
	if not ShakeOpenTab then
		return
	end
	return ShakeOpenTab.Points
end

--获取开奖的金额
function ShakeDataManager.GetScore()
	if not ShakeOpenTab then
		return
	end
	return ShakeOpenTab.Score or 0
end

function ShakeDataManager:PointsSum()	
	local Sum = 0
	for i,v in ipairs(ShakeDataManager.GetPoints()) do
		Sum = Sum + v
	end
	return Sum
end

--获取系数
function ShakeDataManager.GetNum()
	if not ShakeOpenTab then
		return
	end
	local num =  ShakeDataManager.GetScore() / ShakeDataManager.PointsSum()
	return num
end 

--写入排行榜
function ShakeDataManager.SetRankData(i,data)
	RankTab[i] = {}
	RankTab[i] = data.Ranks
	MyRankTab[i] = {}
	MyRankTab[i] = data.MyRank
end 

--获取排行榜
function ShakeDataManager.GetRankItem(i,j)
	if not RankTab[i] then
		return
	end
	return RankTab[i][j]
end 


--获取排行榜长度
function ShakeDataManager.GetRankLen(j)
	RankLen = 0
	if not RankTab[j] then
		return 0
	end
	for i,v in ipairs(RankTab[j]) do
		RankLen = RankLen + 1
	end
	return RankLen
end 

--获取排行榜
function ShakeDataManager.GetSelfRankItem(i)
	if not MyRankTab[i] then
		return
	end
	return MyRankTab[i]
end 

return ShakeDataManager

