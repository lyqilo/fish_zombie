-- region SplashingDataManager.lua
-- Date: 2019.3.25
-- Desc: SplashingDataManager管理类
-- Author: chris

local CC = require("CC")

local SplashingDataManager = CC.class2("SplashingDataManager")

local SplashingTab = {}
local SelfSplashing = {}
local RankTab = {}

--写入泼水信息
function SplashingDataManager.SetSplashingInfo(data)
	SplashingTab = data
end

--读取泼水信息
function SplashingDataManager.GetFundInfo()
	if not SplashingTab then return end
	return SplashingTab
end

--读取泼水回合
function SplashingDataManager.GetSplashingRound()
	if not SplashingTab then return end
	return SplashingTab.Round
end

--读取泼水池剩余
function SplashingDataManager.GetSplashingRest()
	if not SplashingTab then return end
	if SplashingTab.Rest <= 0 then
		SplashingTab.Rest = 0
	end
	return SplashingTab.Rest
end

--读取泼水池总数
function SplashingDataManager.GetSplashingTotal()
	if not SplashingTab then return end
	if SplashingTab.Total <= 0 then
		SplashingTab.Total = 0
	elseif SplashingTab.Total >= 500 then
		SplashingTab.Total = 500
	end
	return SplashingTab.Total
end

--读取泼水池个人泼水信息
function SplashingDataManager.GetSplashingSplash()
	--if not SelfSplashing  then return end
	return SelfSplashing
end

-- -1 - 异常状态 0 - 发奖，倒计时30秒 1 - 正常泼水状态
function SplashingDataManager.GetSplashingSplashStatus()
	if not SplashingTab then return end
	return SplashingTab.SplashStatus
end

--  发奖，倒计时秒数
function SplashingDataManager.GetSplashingSplashCountDown()
	if not SplashingTab then return end
	return SplashingTab.CountDown
end

--中奖信息
function SplashingDataManager.GetSplashingSplashRewardInfo()
	-- logError(type(SplashingTab.RewardInfo))
	if not SplashingTab.RewardInfo or table.isEmpty(SplashingTab.RewardInfo)  then return nil end
	--if tostring(SplashingTab.RewardInfo) ~= "userdata: NULL" then
	return SplashingTab.RewardInfo
	--end
end

--获得中奖名单长度
function SplashingDataManager.GetRewardInfoLen()
	if not SplashingTab.RewardInfo and tostring(SplashingTab.RewardInfo) == "userdata: NULL" then
		return 0
	end
	return #SplashingTab.RewardInfo or 0
end

--根据id获得中奖名单信息
function SplashingDataManager.GetRewardInfoIndex(index)
	if not SplashingTab.RewardInfo and tostring(SplashingTab.RewardInfo) == "userdata: NULL" then
		return
	end
	return SplashingTab.RewardInfo[index]
end


--奖池总筹码
function SplashingDataManager.GetSplashingSplashTotalCost()
	if not SplashingTab then return end
	return SplashingTab.TotalCost
end

--写入泼水排行榜
function SplashingDataManager.SetRankInfo(data)
	RankTab = data
end


--获得泼水长度
function SplashingDataManager.GetRankLen()
	if not RankTab.Ranks then
		return
	end
	return #RankTab.Ranks or 0
end

--根据id获得排行榜信息
function SplashingDataManager.GetRankIndex(index)
	if not RankTab.Ranks then
		return
	end
	return RankTab.Ranks[index]
end

--获取自身排名
function SplashingDataManager.GetMyRank()
	if not RankTab.MyRank then
		return
	end
	return RankTab.MyRank.Rank
end

--获取自身排名信息
function SplashingDataManager.GetMyRankData()
	if not RankTab.MyRank then
		return
	end
	return RankTab.MyRank.Data
end

--推送/请求的信息是自己的信息的话保存下来
function SplashingDataManager.SetSplashingSelf(data)
--     logError(CC.uu.Dump(data,"SetSplashingSelf =",10))
	SelfSplashing = data
end

--回合结束后  个人泼水次数会重新设置回75
function SplashingDataManager.SetSplashingSelfRest()
	SelfSplashing.Rest = 75
end

return SplashingDataManager

