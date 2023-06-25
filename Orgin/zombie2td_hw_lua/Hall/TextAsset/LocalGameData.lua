
local CC = require("CC")

local LocalGameData = {}

local saveNamePrefix = "Hall_LocalGameData"
local saveHeadFile = "Hall_LocalHeadData"
local saveGameActionFile = "Hall_LocalGameActionData"
local _data = {}
local _headData = {}
--每天游戏key行为的次数
local _gameActionCount = {}
--每天需要重置的记录状态
--幸运礼包,Vip礼包,生日礼包,首次打开商店,每天破产打开商店,周年庆
local RefreeDailyRecord = {"LuckyTurntable", "VipRightsGift", "BirthdayGift", "FirstOpenStore", "BrokeOpenStore","CelebrationView","StarRatingView",
							"GiftTurntableView"}

--存储
function LocalGameData.Init()
	_data = CC.UserData.Load(saveNamePrefix,{})
	_headData = CC.UserData.Load(saveHeadFile,{})
	_gameActionCount = CC.UserData.Load(saveGameActionFile,{})
	if not _data.PersonalData then
		_data.PersonalData = {}
	end
	--检测每天需要重置的状态
	LocalGameData.CheckRefreshDailyState();
end

function LocalGameData.CheckRefreshDailyState()
	local today = os.date("%d",os.time());

	if _data["LastDay"] and _data["LastDay"] == today then
		return
	end
	LocalGameData.ResetDailyState();
	LocalGameData.RefreeDailyRecordState();
	LocalGameData.ResetGameActionCount();
	_data["LastDay"] = today;
end

function LocalGameData.SetDownLoadVersion(gameId,version)
	if _data["DownLoadData"] and _data["DownLoadData"][tostring(gameId)] then
		_data["DownLoadData"][tostring(gameId)].version = version
	elseif _data["DownLoadData"] then
		_data["DownLoadData"][tostring(gameId)] = {}
		_data["DownLoadData"][tostring(gameId)].version = version
	else
		_data["DownLoadData"] = {}
		_data["DownLoadData"][tostring(gameId)] = {}
		_data["DownLoadData"][tostring(gameId)].version = version
	end
	--存储
	CC.UserData.Save(saveNamePrefix,_data)
end

function LocalGameData.GetDownLoadVersion(gameId)
	if _data["DownLoadData"] and _data["DownLoadData"][tostring(gameId)] and _data["DownLoadData"][tostring(gameId)].version then
		return _data["DownLoadData"][tostring(gameId)].version
	else
		return 0
	end
end

--读取子游戏版本号
function LocalGameData.GetGameVersion(gameId)
	if _data["gameData"] and _data["gameData"][tostring(gameId)] and _data["gameData"][tostring(gameId)].version then
		return _data["gameData"][tostring(gameId)].version
	else
		return 0
	end
end

--存储子游戏版本号
function LocalGameData.SetGameVersion(gameId,version)
	if _data["gameData"] and _data["gameData"][tostring(gameId)] then
		_data["gameData"][tostring(gameId)].version = version
	elseif _data["gameData"] then
		_data["gameData"][tostring(gameId)] = {}
		_data["gameData"][tostring(gameId)].version = version
	else
		_data["gameData"] = {}
		_data["gameData"][tostring(gameId)] = {}
		_data["gameData"][tostring(gameId)].version = version
	end
	--存储
	CC.UserData.Save(saveNamePrefix,_data)
end

function LocalGameData.SetHallToggle(toggle)
	if _data["ChatToggle"] and _data["ChatToggle"].Hall then
		_data["ChatToggle"].Hall = toggle
	elseif _data["ChatToggle"] then
		_data["ChatToggle"].Hall = toggle
	else
		_data["ChatToggle"] = {}
		_data["ChatToggle"].Hall = toggle
	end
	CC.UserData.Save(saveNamePrefix,_data)
end

function LocalGameData.SetPrivateToggle(toggle)
	if _data["ChatToggle"] and _data["ChatToggle"].Private then
		_data["ChatToggle"].Private = toggle
	elseif _data["ChatToggle"] then
		_data["ChatToggle"].Private = toggle
	else
		_data["ChatToggle"] = {}
		_data["ChatToggle"].Private = toggle
	end
	CC.UserData.Save(saveNamePrefix,_data)
end

function LocalGameData.GetHallToggle()
	if _data["ChatToggle"] and _data["ChatToggle"].Hall ~= nil then
		return _data["ChatToggle"].Hall
	else
		return false
	end
end

function LocalGameData.GetPrivateToggle()
	if _data["ChatToggle"] and _data["ChatToggle"].Private ~= nil then
		return _data["ChatToggle"].Private
	else
		return false
	end
end

function LocalGameData.SetDailyStateByKey(key, flag)

	if _data["dailyStates"] then
		_data["dailyStates"][key] = flag;
	else
		_data["dailyStates"] = {};
		_data["dailyStates"][key] = flag;
	end
	CC.UserData.Save(saveNamePrefix,_data);
end

function LocalGameData.GetDailyStateByKey(key)

	return _data["dailyStates"][key] or false;
end

function LocalGameData.ResetDailyState()
	--重置的变量
	local dailyVar = {"Popup", "Notice", "Sign", "RealStore","Capsule", "FiveMinTip","TenSecTip","TodayEnterGame","SafetyFactor", "FlowWaterTask"};

	for _,key in pairs(dailyVar) do

		if key == "Popup" then
			LocalGameData.SetDailyStateByKey(key, "");
		else
			LocalGameData.SetDailyStateByKey(key, false);
		end
	end
end

function LocalGameData.SetPopupState(state)

	LocalGameData.SetDailyStateByKey("Popup", state);
end

function LocalGameData.GetPopupState()
	if LocalGameData.GetDailyStateByKey("Popup") == true or LocalGameData.GetDailyStateByKey("Popup") == false then
		return ""
	else
		return tostring(LocalGameData.GetDailyStateByKey("Popup"))
	end
end

function LocalGameData.SetNoticeState(state)
	LocalGameData.SetDailyStateByKey("Notice", state);
end

function LocalGameData.GetNoticeState()
	return LocalGameData.GetDailyStateByKey("Notice");
end

function LocalGameData.SetWorldCupChampionData(id)
	if not _data["WorldCupChampion"] then
		_data["WorldCupChampion"] = {}
	end
	_data["WorldCupChampion"]["CountryId"] = id
	CC.UserData.Save(saveNamePrefix,_data);
end

function LocalGameData.GetWorldCupChampionData()
	if not _data["WorldCupChampion"] then
		return nil
	end
	return _data["WorldCupChampion"]["CountryId"]
end


function LocalGameData.SetSignState(state)
	LocalGameData.SetDailyStateByKey("Sign", state);
end

function LocalGameData.GetSignState()
	return LocalGameData.GetDailyStateByKey("Sign");
end

--重置每天本地状态
function LocalGameData.RefreeDailyRecordState()
	for _, v in pairs(RefreeDailyRecord) do
		if not _data[v] then
			_data[v] = {}
		end
		for i, _ in pairs(_data[v]) do
			_data[v][i] = false
		end
		CC.UserData.Save(saveNamePrefix,_data);
	end
end

--重置每天游戏行为次数
function LocalGameData.ResetGameActionCount()
	_gameActionCount = {}
	CC.UserData.Save(saveGameActionFile, _gameActionCount)
end

function LocalGameData.SetGameActionCount(gameId, aciton, count)
	if not _gameActionCount[tostring(gameId)] then
		_gameActionCount[tostring(gameId)] = {}
	end
	count = count or 1
	_gameActionCount[tostring(gameId)][aciton] = _gameActionCount[tostring(gameId)][aciton] and _gameActionCount[tostring(gameId)][aciton] + count or count
	CC.UserData.Save(saveGameActionFile, _gameActionCount)
end

function LocalGameData.GetGameActionCount(gameId, aciton)
	if not _gameActionCount[tostring(gameId)] then
		_gameActionCount[tostring(gameId)] = {}
	end
	return _gameActionCount[tostring(gameId)][aciton] or 0
end

function LocalGameData.SaveIMEICode(code)

	if _data["IMEI"] then
		if _data["IMEI"] ~= code then
			_data["IMEI"] = code;
			LocalGameData.ResetDailyState();
			LocalGameData.RefreeDailyRecordState();
			LocalGameData.ResetGameActionCount()
		end
	else
		_data["IMEI"] = code;
	end
	CC.UserData.Save(saveNamePrefix,_data);
end

function LocalGameData.SetFrames()
	if _data["ExFrames"] then
		Application.targetFrameRate = _data["ExFrames"]
	else
		_data["ExFrames"] = 30
		CC.UserData.Save(saveNamePrefix,_data);
		Application.targetFrameRate = _data["ExFrames"]
	end
end

function LocalGameData.ChangeFrames(isHigh)
	if isHigh then
		LocalGameData.SetLocalStateToKey("ExFrames", 60)
	else
		LocalGameData.SetLocalStateToKey("ExFrames", 30)
	end
	Application.targetFrameRate = _data["ExFrames"]
end

function LocalGameData.GetFrames()
	return LocalGameData.GetLocalStateToKey("ExFrames") or 0
end

function LocalGameData.SetNoticeVersion(version)
	_data["Notice"] = version
	CC.UserData.Save(saveNamePrefix,_data);
end

function LocalGameData.GetNoticeVersion()
	return _data["Notice"]
end

function LocalGameData.GetEventLogByKey(key)
	if not _data["LogEvent"] then
		_data["LogEvent"] = {};
	end
	return _data["LogEvent"][tostring(key)];
end

function LocalGameData.SetEventLogByKey(key)
	if not _data["LogEvent"] then
		_data["LogEvent"] = {};
	end
	_data["LogEvent"][tostring(key)] = true;
	CC.UserData.Save(saveNamePrefix, _data);
end

--[[
	设置本地记录状态  key————记录标志，value————值
	GiftSignIn:每日礼包签到首次打开,CheckFirstInstall:首次动态链接, VipThreeCard:vip3直升卡记录
	firstActiveEntry:首次关闭活动, autoExchangeTip:商城自动转换筹码记录, AddTip:跳转商城更多提示记录
	CommodityType:默认支付方式, isRegister:登录走注册流程, deviceActive:设备激活状态, FCMDebugMode：FCM上报DebugMode
	Topic_AllPlayer:Firebase主题(所有玩家)
]]
function LocalGameData.SetLocalStateToKey(key, value)
	_data[key] = value
	CC.UserData.Save(saveNamePrefix,_data);
end

function LocalGameData.GetLocalStateToKey(key)
	return _data[key] or false
end

--[[
	设置本地记录数据  key————记录标志，bindingId————绑定的id
	TreasureTips:实物商城锁tip，TreasureTips1:实物商城筹码兑换tip，GiveNews:资讯引导,DailyGift:每日礼包的首次购买,
]]
function LocalGameData.SetLocalDataToKey(key, bindingId)
	if not _data[key] then
		_data[key] = {}
	end
	_data[key][tostring(bindingId)] = true
	CC.UserData.Save(saveNamePrefix,_data);
end

function LocalGameData.GetLocalDataToKey(key, bindingId)
	if not _data[key] then
		return true
	end
	if _data[key][tostring(bindingId)] then
		return false
	else
		return true
	end
end

function LocalGameData.SetDataByKey(key, bindingId,value)
	if not _data[key] then
		_data[key] = {}
	end
	_data[key][tostring(bindingId)] = value
	CC.UserData.Save(saveNamePrefix,_data);
end

function LocalGameData.GetDataByKey(key, bindingId)
	if not _data[key] then
		return nil
	end
	return _data[key][tostring(bindingId)]
end

--最近游戏
--默认是捕鱼，dummy，新财神
function LocalGameData.GetRecentGame()
	local PlayerId = tostring(CC.Player.Inst():GetSelfInfoByKey("Id"))
	local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	if not _data["RecentGame"] then
		_data["RecentGame"] = {}
		_data["RecentGame"][PlayerId] = {3002,2003,1007}
	end
	if not _data["RecentGame"][PlayerId] then
		_data["RecentGame"][PlayerId] = {3002,2003,1007}
	end
	CC.UserData.Save(saveNamePrefix,_data);
	for i=3,1,-1 do
		if not gameDataMgr.GetInfoByID(_data["RecentGame"][PlayerId][i]) then
			table.remove(_data["RecentGame"][PlayerId],i)
		end
	end
	return _data["RecentGame"][PlayerId]
end

function LocalGameData.SetRecentGame(id)
	local PlayerId = tostring(CC.Player.Inst():GetSelfInfoByKey("Id"))
	if not _data["RecentGame"] then
		_data["RecentGame"] = {}
		_data["RecentGame"][PlayerId] = {3002,2003,1007}
	end
	local index = nil
	for i,v in ipairs(_data["RecentGame"][PlayerId]) do
		if v == id then
			index = i
			break
		end
	end
	if index then
		table.remove(_data["RecentGame"][PlayerId],index)
	end
	table.insert(_data["RecentGame"][PlayerId],1,id)
	if #_data["RecentGame"][PlayerId] > 3 then
		table.remove( _data["RecentGame"][PlayerId])
	end
	CC.UserData.Save(saveNamePrefix,_data);
end

function LocalGameData.GetAppUpdateRewardVersion()
	local PlayerId = tostring(CC.Player.Inst():GetSelfInfoByKey("Id"))
	if not _data["UpdateRewardVersion"] then
		_data["UpdateRewardVersion"] = {}
	end
	return _data["UpdateRewardVersion"][PlayerId] or "0";
end

function LocalGameData.SetAppUpdateRewardVersion(version)
	local PlayerId = tostring(CC.Player.Inst():GetSelfInfoByKey("Id"))
	if not _data["UpdateRewardVersion"] then
		_data["UpdateRewardVersion"] = {}
	end
	_data["UpdateRewardVersion"][PlayerId] = version;
	CC.UserData.Save(saveNamePrefix,_data);
end

--玩家数据根据Id新建一张数据表，和玩家相关的数据存这里
function LocalGameData.GetPersonalData(key)

	local Id = tostring(CC.Player.Inst():GetSelfInfoByKey("Id"))
	if not _data.PersonalData[Id] then
		_data.PersonalData[Id] = {}
	end
	return _data.PersonalData[Id][key]
end

function LocalGameData.SetPersonalData(key, value)

	local Id = tostring(CC.Player.Inst():GetSelfInfoByKey("Id"))
	if not _data.PersonalData[Id] then
		_data.PersonalData[Id] = {}
	end
	_data.PersonalData[Id][key] = value
	CC.UserData.Save(saveNamePrefix,_data);
end

function LocalGameData.GetReportQData()

	return _data.ReportQData or {}
end

function LocalGameData.SetReportQData(data)

	_data.ReportQData = data;
	CC.UserData.Save(saveNamePrefix,_data);
end

function LocalGameData.CheckLoadImge(daynum)
	local today = os.date("%d",os.time());
	if _headData["HeadTexturetoday"] and _headData["HeadTexturetoday"]==today then
	   return
	end
    if today%daynum==0 then
	    if _headData["HeadTexture"] then
			for i=1,tonumber(_headData["HeadTexture"]),1 do
			    if _headData["HeadTextureday"..i]~="" then
					local needday=0
					if today-tonumber(_headData["HeadTextureday"..i])>0 then
						needday=today-tonumber(_headData["HeadTextureday"..i])
					else
						needday=32-tonumber(_headData["HeadTextureday"..i])+today
					end
					if needday>=daynum then
						_headData["HeadTextureday"..i]=""
					   Util.DeleteFile(_headData["HeadTexturepath"..i])--DeleteFile  DeleteDirectory
					   _headData["HeadTexturepath"..i]=""
					end
				end
			end
		end
	end
	_headData["HeadTexturetoday"]=today
	CC.UserData.Save(saveHeadFile,_headData)
end

function LocalGameData.SaveHeadTexture(textturepath)
	if _headData["HeadTexture"] then
        local needday=0
	    for i=1,tonumber(_headData["HeadTexture"]),1 do
			if _headData["HeadTexturepath"..i]=="" then
                _headData["HeadTexturepath"..i]=textturepath
		        _headData["HeadTextureday"..i]=tostring(os.date("%d",os.time()))
				needday=i
				break
			end
		end
		if needday==0 then
			local HeadTexturenum=tonumber(_headData["HeadTexture"])+1
			_headData["HeadTexture"]=tostring(HeadTexturenum)
			_headData["HeadTexturepath"..tostring(HeadTexturenum)]=textturepath
			_headData["HeadTextureday"..tostring(HeadTexturenum)]=tostring(os.date("%d",os.time()))
		end

	else
	    _headData["HeadTexture"]="1"
		_headData["HeadTexturepath1"]=textturepath
		_headData["HeadTextureday1"]=tostring(os.date("%d",os.time()))
	end
	CC.UserData.Save(saveHeadFile,_headData)
end

function LocalGameData.SaveHeadTextureday(textturepath)
	if _headData["HeadTexture"] then
		for i=1,tonumber(_headData["HeadTexture"]),1 do
			if _headData["HeadTexturepath"..i]==textturepath then
				_headData["HeadTextureday"..i]=tostring(os.date("%d",os.time()))
			   break
			end
		end
	end
	CC.UserData.Save(saveHeadFile,_headData)
end

return LocalGameData