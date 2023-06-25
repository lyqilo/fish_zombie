local CC = require("CC")

local WorldCupDataMgr = {}
local homePageData
local scheduleDateList = {}
local jackpotData
local score = 0
local matchJpData
local marqueeList
local worldCupGiftData = {}
local giftBtnPos = {}

function WorldCupDataMgr.SetHomePageData(data)
    homePageData = data;
end

function WorldCupDataMgr.GetHomePageData()
    return homePageData;
end

function WorldCupDataMgr.SetScheduleDateList(data)
	scheduleDateList = {}
	local i = 1
	local ts = data.WorldCupStartTime
	local timeInfo = CC.TimeMgr.GetConvertTimeInfo(ts)
	local endTimeInfo = CC.TimeMgr.GetConvertTimeInfo(data.WorldCupEndTime)
	repeat
		scheduleDateList[i] = ts
		i = i + 1
		ts = ts + 86400
		timeInfo = CC.TimeMgr.GetConvertTimeInfo(ts)
	until (timeInfo.year == endTimeInfo.year and timeInfo.yday > endTimeInfo.yday)
end

function WorldCupDataMgr.GetScheduleDateList()
	return scheduleDateList
end

function WorldCupDataMgr.SetScore(value)
	score = value;
end

function WorldCupDataMgr.GetScore()
	return score;
end

function WorldCupDataMgr.SetGiftBtnV2(value)
	giftBtnPos = value;
end

function WorldCupDataMgr.GetGiftBtnV2()
	return giftBtnPos;
end

function WorldCupDataMgr.SetMatchJackpotData(data)
	matchJpData = data
end

function WorldCupDataMgr.GetMatchJackpotData()
	return matchJpData
end

function WorldCupDataMgr.SetMarqueeList(data)
	marqueeList = data
end

function WorldCupDataMgr.GetMarqueeList()
	return marqueeList
end

function WorldCupDataMgr.SetWorldCupGiftData(data)
	worldCupGiftData = data
end

function WorldCupDataMgr.GetWorldCupGiftData()
	return worldCupGiftData
end

function WorldCupDataMgr.ChangeWorldCupGiftStatus(status)
	--1、充值成功  2、购买世界杯礼包成功
	local data = worldCupGiftData
	if status == 1 then
		data.HasPurchaseToday = true
	elseif status == 2 then
		data.CurrentPurchaseCount = data.CurrentPurchaseCount +1
		if data.CurrentPurchaseCount >=3 then
			data.HasGetFinalReward = true
		end
	end
end

function WorldCupDataMgr.IsShowWorldCupGift(betNum,isCard)
	--isCard 是否竞猜卡
	
	if isCard then return false end --竞猜卡不需要付费、金币判断
	
	local data = worldCupGiftData
	local chip = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
	local cm = betNum and chip-betNum or chip

	local lastPurchaseTime = CC.Player.Inst():GetSelfInfoByKey("EPC_TotalRecharge")

	--历史无付费，弹出礼包
	if lastPurchaseTime <= 0 then
		local param = {}
		param.Index = 1
		if cm < data.MinimumChip then
			param.IsEnough = false
		else
			param.IsEnough = true
		end
		param.IsPurchase = false
		param.CloseCb = function ()
			CC.ViewManager.Open("WorldCupGiftView",data)
		end
		param.SureBtnCb = function ()
			CC.ViewManager.Open("WorldCupGiftView",data)
		end
		CC.ViewManager.Open("WorldCupTipsView",param)
		return true
	end

	if cm< data.MinimumChip and not isCard then
		local param = {}
		param.Index = 1
		param.IsEnough = false
		param.IsPurchase = true
		local viewStr = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetGiftStatus("30329") and "WorldCupGiftView" or "StoreView"
		--弹窗口，提示去商店
		param.CloseCb = function ()
			CC.ViewManager.Open(viewStr)
		end
		param.SureBtnCb = function ()
			CC.ViewManager.Open(viewStr)
		end
		CC.ViewManager.Open("WorldCupTipsView",param)

		return true
	end

	return false
end

return WorldCupDataMgr