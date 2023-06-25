local CC = require("CC")

local M = {}
M.sTimeStamp = nil;
M.startUpdate = nil;
M.refreshTime = 180;
M.ssec = 0;
M.reqsec = 0;
M.timeZone = 7 * 3600  --使用泰国时区(东7区)

function M.Start()
	if M.startUpdate then return end
	M.startUpdate = true;
	UpdateBeat:Add(M.Update, M);
end

function M.Update()
	if not M.sTimeStamp then return end;
	M.ssec = M.ssec + Time.deltaTime;
	M.reqsec = M.reqsec + Time.deltaTime;

	if M.reqsec > M.refreshTime then
		M.reqsec = 0;
		M.ReqSvrTimeStamp();
	end
end

function M.ReqSvrTimeStamp()
	local rt = os.time();
	CC.Request("GetServerDateTime", nil, function(err, result)
		M.sTimeStamp = result.DataTime;
		M.ssec = os.time() - rt;
	end)
end

function M.SetSvrTimeStamp(timeStamp)
	M.ssec = 0
	M.sTimeStamp = timeStamp;
end

function M.GetSvrTimeStamp()
	if not M.sTimeStamp then return 0 end;
	return (M.sTimeStamp + math.floor(M.ssec));
end

function M.GetTimeZone()
	local now = os.time();
	local zone= os.difftime(now, os.time(os.date("!*t", now)));
	return zone;
end

--转成泰国时区的时间信息
function M.GetTimeInfo()
	local svrStamp = M.GetSvrTimeStamp();
	return os.date("*t", svrStamp + M.timeZone - M.GetTimeZone());
end

function M.GetConvertTimeInfo(timeStamp)
	return os.date("*t", timeStamp + M.timeZone - M.GetTimeZone());
end

--获取当前时区的时间(单位小时)
function M.GetTimeHour(timeStamp)
	local svrStamp = timeStamp or M.GetSvrTimeStamp();
	return os.date("%H", svrStamp + M.timeZone - M.GetTimeZone());
end

--获取当前时区的时间(单位分钟)
function M.GetTimeMinute(timeStamp)
	local svrStamp = timeStamp or M.GetSvrTimeStamp();
	return os.date("%M", svrStamp + M.timeZone - M.GetTimeZone());
end

--转化当前时区(日/月 小时:分钟:秒)
function M.GetTimeFormat1(timeStamp)
	return os.date("%d/%m %H:%M:%S", timeStamp + M.timeZone - M.GetTimeZone());
end

--转化当前时区(小时:分钟)
function M.GetTimeFormat2(timeStamp)
	local svrStamp = timeStamp or M.GetSvrTimeStamp();
	return os.date("%H:%M", svrStamp + M.timeZone - M.GetTimeZone());
end

--转化当前时区(日/月)
function M.GetTimeFormat3(timeStamp)
	local svrStamp = timeStamp or M.GetSvrTimeStamp();
	return os.date("%d/%m", svrStamp + M.timeZone - M.GetTimeZone());
end

--转化当前时区(日/月/年)
function M.GetTimeFormat4(timeStamp)
	local svrStamp = timeStamp or M.GetSvrTimeStamp();
	return os.date("%d/%m/%Y", svrStamp + M.timeZone - M.GetTimeZone());
end

--转化当前时区(日)
function M.GetTimeFormat5(timeStamp)
	local svrStamp = timeStamp or M.GetSvrTimeStamp();
	return os.date("%d", svrStamp + M.timeZone - M.GetTimeZone());
end

function M.Stop()
	M.startUpdate = false;
	UpdateBeat:Remove(M.Update, M);
end

return M;
