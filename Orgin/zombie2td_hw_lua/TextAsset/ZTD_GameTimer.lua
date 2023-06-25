--	游戏定时器类
--  一种是每帧调用指定函数，超时调用超时函数
--  一种是间隔interval调用一次指定函数，超时调用超时函数

local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu
--isDone 确保一次初始化对应一次释放
local isDone

local GameTimer = {}
function GameTimer.Init()
	if isDone then
		return
	end
	isDone = true
    --定时器列表
    GameTimer.timerList = {}
	--带暂停的定时器列表
    GameTimer.timerPauseList = {}
	--定时器id
	GameTimer.timerKey = 0
	
	ZTD.UpdateAdd(GameTimer.Update)
end

function GameTimer.Update()
    for _,v in pairs(GameTimer.timerList) do
        v.timerObj:Update()
    end
    for _,v in pairs(GameTimer.timerPauseList) do
        v.timerObj:Update()
    end
end

--公共定时器
--func 超时回调函数
--interval 间隔时间
--times 重复次数 -1为无限次数
--withPause 暂停游戏是否暂停计时
-- ...  回调函数的可变参数列表
function GameTimer.StartTimer(func, interval, times, withPause, ...)
    local timerKey = GameTimer._StartTimer(nil, func, interval, times, withPause, ...)
    return timerKey
end

--指定key  key不能用数字
function GameTimer.StartTimerWithKey(key, func, interval, times, withPause, ...)
    local timerKey = GameTimer._StartTimer(key, func, interval, times, withPause, ...)
    return timerKey
end

--延迟执行1次函数
--func 超时回调函数
--interval 间隔时间
--withPause 暂停游戏是否暂停计时
-- ...  回调函数的可变参数列表
function GameTimer.DelayRun(interval, func, withPause, ...)
	local timerKey = GameTimer.StartTimer(func, interval, 1, withPause, ...)
	return timerKey
end

function GameTimer._StartTimer(key, func, interval, times, withPause, ...)
    GameTimer.timerKey = GameTimer.timerKey + 1
	key = key or GameTimer.timerKey
	local timerObj = ZTD.GameTimeClock:new(key)
	timerObj:StartNormalTimer(func, interval, times, withPause, ...)
	if withPause then
		GameTimer.timerPauseList[key] = {}
		GameTimer.timerPauseList[key].timerObj = timerObj
	else
		GameTimer.timerList[key] = {}
		GameTimer.timerList[key].timerObj = timerObj
	end

    return key
end

--每帧回调以及超时回调
--totalTime 总时长
--updateFunc 每帧回调函数
--timerOverFunc 超时回调函数
--withPause 暂停游戏是否暂停计时
function GameTimer.StartUpdateTimer(totalTime,updateFunc,timerOverFunc,withPause)
	local timerKey = GameTimer._StartUpdateTimer(nil,totalTime,updateFunc,timerOverFunc,withPause)
	return timerKey
end

--指定key key不能用数字
function GameTimer.StartUpdateTimerWithKey(key,totalTime,updateFunc,timerOverFunc,withPause)
	local timerKey = GameTimer._StartUpdateTimer(key,totalTime,updateFunc,timerOverFunc,withPause)
	return timerKey
end

function GameTimer._StartUpdateTimer(key,totalTime,updateFunc,timerOverFunc,withPause)
	GameTimer.timerKey = GameTimer.timerKey + 1
	key = key or GameTimer.timerKey
	local timerObj = ZTD.GameTimeClock:new(key)
	timerObj:StartUpdateTimer(totalTime,updateFunc,timerOverFunc,withPause)
	if withPause then
		GameTimer.timerPauseList[key] = {}
		GameTimer.timerPauseList[key].timerObj = timerObj
	else
		GameTimer.timerList[key] = {}
		GameTimer.timerList[key].timerObj = timerObj
	end
	return key
end


function GameTimer._GetTimerObj(key)
	local timerObj
	if GameTimer.timerList[key] then
		timerObj = GameTimer.timerList[key].timerObj 
	elseif GameTimer.timerPauseList[key] then
		timerObj = GameTimer.timerPauseList[key].timerObj 
	end
	return timerObj
end
--拿到剩余时间
function GameTimer.GetLeftTime(key)
	local timerObj = GameTimer._GetTimerObj(key)
	if not timerObj then
		return -1
	else
		return timerObj.leftTime
	end
end

--设置更新Func
function GameTimer.SetUpdateFunc(key, updateFunc)
	local timerObj = GameTimer._GetTimerObj(key)
	if timerObj then
		timerObj.updateFunc = updateFunc
	end
end
--设置超时Func
function GameTimer.SetTimerOverFunc(key, timerOverFunc)
	local timerObj = GameTimer._GetTimerObj(key)
	if timerObj then
		timerObj.timerOverFunc = timerOverFunc
	end
end

--暂停所有暂停游戏相关的timer
function GameTimer.PauseTimers()
	for key,v in pairs(GameTimer.timerPauseList) do
		v.timerObj:PauseTimer()
    end
end
--恢复所有暂停游戏相关的timer
function GameTimer.ResumeTimers()
	for key,v in pairs(GameTimer.timerPauseList) do
		v.timerObj:ResumeTimer()
    end
end
--暂停指定timer
function GameTimer.PauseTimer(key)
	local timerObj = GameTimer._GetTimerObj(key)
	if timerObj then
		timerObj:PauseTimer()
	end
end
--恢复指定timer
function GameTimer.ResumeTimer(key)
	local timerObj = GameTimer._GetTimerObj(key)
	if timerObj then
		timerObj:ResumeTimer()
	end
end
--重新设置interval（重新开始计时）
function GameTimer.ResetInterval(key,interval)
	local timerObj = GameTimer._GetTimerObj(key)
	if timerObj then
		timerObj:ResetInterval(interval)
	end
end
--停止指定timer
function GameTimer.StopTimer(key)
	local timerObj = GameTimer._GetTimerObj(key)
	if timerObj then
		timerObj:Stop()
		GameTimer.timerList[key] = nil
		GameTimer.timerPauseList[key] = nil
	end
end
--停止pause timer
function GameTimer.StopPauseTimers(key)
	for key,v in pairs(GameTimer.timerPauseList) do
        v.timerObj:Stop()
        GameTimer.timerPauseList[key] = nil
    end
	GameTimer.timerPauseList = {}
end

function GameTimer.Release()
	if not isDone then
		return
	end
    for key,v in pairs(GameTimer.timerList) do
        v.timerObj:Stop()
        GameTimer.timerList[key] = nil
    end
    for key,v in pairs(GameTimer.timerPauseList) do
        v.timerObj:Stop()
        GameTimer.timerPauseList[key] = nil
    end
	GameTimer.timerList = {}
	GameTimer.timerPauseList = {}

	ZTD.UpdateRemove(GameTimer.Update)
	isDone = false
end

return GameTimer