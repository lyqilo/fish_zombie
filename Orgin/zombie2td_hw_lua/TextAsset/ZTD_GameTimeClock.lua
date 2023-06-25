local GC = require("GC")
local ZTD = require("ZTD")

local GameTimeClock = GC.class2()
function GameTimeClock:ctor(_,Key)
    -- log("____Key:"..Key)
    self.Key = Key
    self.withPause = false
    self.startUpdate = false
	self.curTime = 0
	self.leftTime = 0
	self.startTime = 0
	self.resumeTime = 0
	self.interval = 0
	--回调函数的可变参数
	self.funcArgs = {}
	--当前执行次数
	self.curTimes = 0
	--总次数
	self.timeCounts = 0
	--当前次数
	self.curCounts = 0
end

function GameTimeClock:Update()
    if self.startUpdate then
        self:CheckUpdateTimer()
    end
	if self.normalTimer then
		self:CheckNormalTimer()
	end
end

function GameTimeClock:CheckNormalTimer()
	if self.isPauseTimer or (self.withPause and ZTD.Flow.isPause) then
		return
	end

    self.curTime = self.curTime + Time.deltaTime
	self.leftTime = self.interval-self.curTime
	if self.leftTime < 0 then
		self.leftTime = 0
	end
    if self.curTime >= self.interval then
		self.curTime = self.curTime - self.interval
		self.curCounts = self.curCounts + 1
		if self.updateFunc then
			self.updateFunc(unpack(self.funcArgs))
		end
    end
	--次数完毕，关闭timer
	if self.timeCounts > 0 and self.curCounts >= self.timeCounts then
		self.normalTimer = false
		ZTD.GameTimer.StopTimer(self.Key)
	end

end

function GameTimeClock:CheckUpdateTimer()
	if not self.startUpdate or self.isPauseTimer or 
		(self.withPause and ZTD.Flow.isPause) then
		return
	end

    self.curTime = self.curTime + Time.realtimeSinceStartup - self.startTime
	self.leftTime = self.totalTime-self.curTime
	self.startTime = Time.realtimeSinceStartup
    if self.updateFunc then
        self.updateFunc(self.Key,self.leftTime,self.totalTime)
    end
	
    if self.leftTime <= 0 then
		self.startUpdate = false
		ZTD.GameTimer.StopTimer(self.Key)
        if self.timerOverFunc then
            self.timerOverFunc(self.Key)
        end
    end
end

function GameTimeClock:PauseTimer()
	self.isPauseTimer = true
end

function GameTimeClock:ResumeTimer()
	self.isPauseTimer = false
	self.startTime = Time.realtimeSinceStartup
end

--重新设置interval（重新开始计时）
function GameTimeClock:ResetInterval(interval)
	self.startTime = Time.realtimeSinceStartup
	self.interval = interval or 0
	self.curTime = 0
end

function GameTimeClock:StartNormalTimer(func, interval, times, withPause, ...)
    self.updateFunc = func
	self.timeCounts = times or -1
    self.interval = interval or 0
	self.withPause = withPause or false
    self.startTime = Time.realtimeSinceStartup
	self.funcArgs = {...}
    self.normalTimer = true
end

function GameTimeClock:StartUpdateTimer(totalTime,updateFunc,timerOverFunc,withPause)
    self.updateFunc = updateFunc
    self.timerOverFunc = timerOverFunc
    self.totalTime = totalTime or 99999999
    self.leftTime = self.totalTime
	self.withPause = withPause or false
    self.startTime = Time.realtimeSinceStartup
    self.startUpdate = true
end

function GameTimeClock:StartTimerWithTimes(callBack,interval,times)
    self.updateFunc = callBack
	self.timeCounts = times
    self.timerOverFunc = timerOverFunc
    self.totalTime = totalTime or 99999999
    self.leftTime = self.totalTime
    self.interval = interval
    self.startTime = Time.realtimeSinceStartup
    self.startUpdate = true
end

function GameTimeClock:Stop()
    self.startUpdate = false
end

return GameTimeClock