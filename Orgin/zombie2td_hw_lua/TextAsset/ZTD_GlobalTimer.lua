--	游戏定时器类
--  一种是每帧调用指定函数，超时调用超时函数
--  一种是间隔interval调用一次指定函数，超时调用超时函数

local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local M = {}
function M.Init()
    --定时器列表
    M.timerList = {}
	--带暂停的定时器列表
    M.timerPauseList = {}
	--定时器id
	M.timerKey = 0
	
	ZTD.UpdateAdd(M.Update)
end

function M.Update()
    for _,v in pairs(M.timerList) do
        v.timerObj:Update()
    end
    for _,v in pairs(M.timerPauseList) do
        v.timerObj:Update()
    end
end

--公共定时器
--func 超时回调函数
--interval 间隔时间
--times 重复次数 -1为无限次数
--withPause 暂停游戏是否暂停计时
-- ...  回调函数的可变参数列表
function M.StartTimer(func, interval, times, withPause, ...)
    local timerKey = M._StartTimer(nil, func, interval, times, withPause, ...)
    return timerKey
end

--指定key  key不能用数字
function M.StartTimerWithKey(key, func, interval, times, withPause, ...)
    local timerKey = M._StartTimer(key, func, interval, times, withPause, ...)
    return timerKey
end

--延迟执行1次函数
--func 超时回调函数
--interval 间隔时间
--withPause 暂停游戏是否暂停计时
-- ...  回调函数的可变参数列表
function M.DelayRun(interval, func, withPause, ...)
	local timerKey = M.StartTimer(func, interval, 1, withPause, ...)
	return timerKey
end

function M._StartTimer(key, func, interval, times, withPause, ...)
    M.timerKey = M.timerKey + 1
	key = key or M.timerKey
	local timerObj = ZTD.GlobalTimeClock:new(key)
	timerObj:StartNormalTimer(func, interval, times, withPause, ...)
	if withPause then
		M.timerPauseList[key] = {}
		M.timerPauseList[key].timerObj = timerObj
	else
		M.timerList[key] = {}
		M.timerList[key].timerObj = timerObj
	end

    return key
end

--每帧回调以及超时回调
--totalTime 总时长
--updateFunc 每帧回调函数
--timerOverFunc 超时回调函数
--withPause 暂停游戏是否暂停计时
function M.StartUpdateTimer(totalTime,updateFunc,timerOverFunc,withPause)
	local timerKey = M._StartUpdateTimer(nil,totalTime,updateFunc,timerOverFunc,withPause)
	return timerKey
end

--指定key key不能用数字
function M.StartUpdateTimerWithKey(key,totalTime,updateFunc,timerOverFunc,withPause)
	local timerKey = M._StartUpdateTimer(key,totalTime,updateFunc,timerOverFunc,withPause)
	return timerKey
end

function M._StartUpdateTimer(key,totalTime,updateFunc,timerOverFunc,withPause)
	M.timerKey = M.timerKey + 1
	key = key or M.timerKey
	local timerObj = ZTD.GlobalTimeClock:new(key)
	timerObj:StartUpdateTimer(totalTime,updateFunc,timerOverFunc,withPause)
	if withPause then
		M.timerPauseList[key] = {}
		M.timerPauseList[key].timerObj = timerObj
	else
		M.timerList[key] = {}
		M.timerList[key].timerObj = timerObj
	end
	return key
end


function M._GetTimerObj(key)
	local timerObj
	if M.timerList[key] then
		timerObj = M.timerList[key].timerObj 
	elseif M.timerPauseList[key] then
		timerObj = M.timerPauseList[key].timerObj 
	end
	return timerObj
end
--拿到剩余时间
function M.GetLeftTime(key)
	local timerObj = M._GetTimerObj(key)
	if not timerObj then
		return -1
	else
		return timerObj.leftTime
	end
end

--设置更新Func
function M.SetUpdateFunc(key, updateFunc)
	local timerObj = M._GetTimerObj(key)
	if timerObj then
		timerObj.updateFunc = updateFunc
	end
end
--设置超时Func
function M.SetTimerOverFunc(key, timerOverFunc)
	local timerObj = M._GetTimerObj(key)
	if timerObj then
		timerObj.timerOverFunc = timerOverFunc
	end
end

--暂停所有暂停游戏相关的timer
function M.PauseTimers()
	for key,v in pairs(M.timerPauseList) do
		v.timerObj:PauseTimer()
    end
end
--恢复所有暂停游戏相关的timer
function M.ResumeTimers()
	for key,v in pairs(M.timerPauseList) do
		v.timerObj:ResumeTimer()
    end
end
--暂停指定timer
function M.PauseTimer(key)
	local timerObj = M._GetTimerObj(key)
	if timerObj then
		timerObj:PauseTimer()
	end
end
--恢复指定timer
function M.ResumeTimer(key)
	local timerObj = M._GetTimerObj(key)
	if timerObj then
		timerObj:ResumeTimer()
	end
end
--重新设置interval（重新开始计时）
function M.ResetInterval(key,interval)
	local timerObj = M._GetTimerObj(key)
	if timerObj then
		timerObj:ResetInterval(interval)
	end
end
--停止指定timer
function M.StopTimer(key)
	local timerObj = M._GetTimerObj(key)
	if timerObj then
		timerObj:Stop()
		M.timerList[key] = nil
		M.timerPauseList[key] = nil
	end
end
--停止pause timer
function M.StopPauseTimers(key)
	for key,v in pairs(M.timerPauseList) do
        v.timerObj:Stop()
        M.timerPauseList[key] = nil
    end
	M.timerPauseList = {}
end

function M.Release()
    for key,v in pairs(M.timerList) do
        v.timerObj:Stop()
        M.timerList[key] = nil
    end
    for key,v in pairs(M.timerPauseList) do
        v.timerObj:Stop()
        M.timerPauseList[key] = nil
    end
	M.timerList = {}
	M.timerPauseList = {}
	ZTD.UpdateRemove(M.Update)
end

return M