local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu
local TimeMapBase = GC.class2("TimeMapBase")


-- 针对需要大量使用startTime runAction 封装的管理类

TimeMapBase.timeCount = 0;

-- 继承使用时 一定要调用一次该方法
function TimeMapBase:Init()
	self.timerKeyToken = self.className .. "_";
	self.timeMap = {};
	self.actionMap = {};
end

function TimeMapBase:StartTimer(func,interval,times)
    TimeMapBase.timeCount  = TimeMapBase.timeCount + 1
    local timerKey = self.timerKeyToken..tostring(TimeMapBase.timeCount)
    ZTD.GameTimer.StartTimerWithKey(timerKey,func,interval or 0,times or -1,false)
    self.timeMap[timerKey] = timerKey
    return timerKey
end

function TimeMapBase:StopTimer(key)
    if not key or not self.timeMap[key] then  return  end 
    ZTD.GameTimer.StopTimer(key)
    self.timeMap[key] = nil
end

function TimeMapBase:StartAction(target, action)
    local actKey = ZTD.Extend.RunAction(target, action);
	self.actionMap[actKey] = actKey;
	return actKey;
end

function TimeMapBase:StartBezier(targetPos, oriPos, runObj, checkFunc, endFunc, duration, ctrlPos)
	local actKey = ZTD.Extend.RunBezier(targetPos, oriPos, runObj, checkFunc, endFunc, duration, ctrlPos)
	-- logError("StartBezier actKeyactKeyactKey:" .. actKey);
	self.actionMap[actKey] = actKey;
	return actKey;	
end	

function TimeMapBase:StopAction(key)
    if not key or not self.actionMap[key] then  return  end 
    ZTD.Extend.StopAction(key)
    self.actionMap[key] = nil
end

function TimeMapBase:StopAllAction()
    if self.actionMap == nil then return end
    for __, v in pairs(self.actionMap) do
        ZTD.Extend.StopAction(v)
    end
    self.actionMap = {}
end	

function TimeMapBase:StopAllTimer()
    if self.timeMap == nil then return end
    for __,v in pairs(self.timeMap) do
        ZTD.GameTimer.StopTimer(v)
    end
    self.timeMap = {}
end

function TimeMapBase:StopAll()
	self:StopAllTimer();
	self:StopAllAction();
end

return TimeMapBase