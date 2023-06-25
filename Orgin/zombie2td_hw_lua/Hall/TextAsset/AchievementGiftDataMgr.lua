-- 成就礼包控制管理类
local CC = require("CC")

local Mgr = {} -- CC.class2("AchievementGiftDataMgr")

local _giftData = nil
local GiftBeginTime = nil -- os.difftime(s2, s1)

local hasReq = false

function Mgr.ReqGift(param)
	if not Mgr.IsReady() or Mgr.IsShow() then -- 现在只有一个礼包，存在就不再请求了
		return
	end
	if param == nil then
		return
	end
	hasReq = true
	-- req
	local data={}
	data.dwPlayerId = param.dwPlayerId or CC.Player.Inst():GetSelfInfoByKey("Id")
    data.nVipLevel = param.nVipLevel or CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
    data.lPlayerMoney = param.lPlayerMoney or 0
    data.lDelta = param.lDelta or 0
    CC.Request("ReqLimitTimeGift",data,function (code,data)
			if code and code == 0 and data then
				log(CC.uu.Dump(data,"ReqLimitTimeGift =",10))
				_giftData = data.arrLimitTimeGift
				if Mgr.IsShow() then
					Mgr.GiftBegin(Mgr.GiftDataTime())
					CC.HallNotificationCenter.inst():post(CC.Notifications.OnLimitTimeGiftShow)
				end
			end
		end,
		function (code)
			hasReq = false
			logError(code)
		end)
end

function Mgr.IsShow()
	if _giftData == nil then
		return false
	end

	if #_giftData == 0 then
		return false
	end

	return true
end

function Mgr.GetGiftData(nGiftID)
	if _giftData then
		return _giftData[nGiftID or 1]
	end
end

function Mgr.GetGiftType()
	if Mgr.IsShow() then
		return _giftData[1].nGiftType
	end
end

function Mgr.GetCountDown()
	if Mgr.IsShow() and GiftBeginTime then
		local countDown = Mgr.GiftDataTime() - os.difftime(os.time(), GiftBeginTime)
		if countDown < 0 then
			return 0
		end
		return countDown
	else
		return 0
	end
end

function Mgr.GiftDataTime()
	local time = 0
	for i,v in ipairs(_giftData or {}) do
		if v.lLeftTimeSec and time < v.lLeftTimeSec then
			time = v.lLeftTimeSec
		end
	end
	return time
end

local _isReady = true -- 玩家每日登陆后累计在线时长达到10分钟（8-12分钟区间）

function Mgr.IsReady()
	local vip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	local canBuy = CC.ChannelMgr.GetSwitchByKey("bHasGift")
	return _isReady and canBuy and vip == 0 and not hasReq -- and not Mgr.IsTodayOpen()
end

function Mgr.ResetReq()
	hasReq = false
end

local reqIntervalConst = 30 -- 定时检查时间，s
local _isTodayOpen = false

-- function Mgr.IsTodayOpen()
-- 	return _isTodayOpen
-- end

-- local reqCo = nil

-- function Mgr.ReqReadyState()
-- 	if Mgr.IsReady() then
-- 		return
-- 	end

-- 	local readyState = false
-- 	-- req
-- 	if readyState then
-- 		_isReady = true
-- 		if reqCo then
-- 			uu.CancelDelayRun(reqCo)
-- 		end
-- 	else
-- 		reqCo = uu.DelayRun( reqIntervalConst, Mgr.ReqReadyState)
-- 	end
-- end

local timeCo = nil
local checkTimer = nil
local checkInterval = 60

function Mgr.GiftBegin(time)
	local activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	GiftBeginTime = os.time()
	-- activityDataMgr.SetActivityInfoByKey("AchievementGiftMainView", {redDot = true, switchOn = true})
	if timeCo then
		CC.uu.CancelDelayRun(timeCo)
	end
	timeCo = CC.uu.DelayRun(time, Mgr.GiftEnd)
	if checkTimer then
		CC.uu.StopTimer(checkTimer)
	end
	checkTimer = CC.uu.StartTimer(checkInterval,Mgr.CheckGiftExist,math.ceil(time/checkInterval))
end

function Mgr.GiftEnd()
	-- CC.HallNotificationCenter.inst():post(CC.Notifications.OnLimitTimeGiftTimeOut)
	local activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	if timeCo then
		CC.uu.CancelDelayRun(timeCo)
	end
	if checkTimer then
		CC.uu.StopTimer(checkTimer)
	end
	-- activityDataMgr.SetActivityInfoByKey("AchievementGiftMainView", {redDot = false, switchOn = false})
	GiftBeginTime = nil
	_giftData = nil
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshSelectGiftIcon)
end

function Mgr.OnLimitTimeGiftBuy()
	Mgr.GiftEnd()
end

function Mgr.CheckGiftExist()
	CC.Request("ReqLimitTimeGiftStatus",nil,function (code,data)
			if code and code == 0 and data then
				-- log(CC.uu.Dump(data,"ReqLimitTimeGiftStatus =",10))
				_giftData = data.arrLimitTimeGift
				if Mgr.IsShow() then
					Mgr.GiftBegin(Mgr.GiftDataTime())
					CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshSelectGiftIcon)
				else
					Mgr.GiftEnd()
				end
			end
		end,
		function (code)
			logError(code)
		end)

	-- testing
	-- local param = {}
	-- param.lPlayerMoney = 0
	-- param.lDelta = 0
	-- Mgr.ReqGift(param,function ()
	-- 	CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshSelectGiftIcon)
	-- end)
end

return Mgr