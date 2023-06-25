local CC = require("CC")

local ReportManager = {}

local ReportDefine = {
	STARTAPP = 1,
	GETVERSION = 2,
	UPDATEPAGE = 3,
	UPDATESUCC = 4,
	UPDATEFAIL = 5,
	LOGINVIEW = 6,
	CLICKFBBTN = 7,
	FBLOGINSUCC = 8,
	FBLOGINFAIL = 9,
	FBCHECKSUCC = 10,
	FBCHECKFAIL = 11,
	FBENTERHALL = 12,
	CLICKLINEBTN = 13,
	LINELOGINSUCC = 14,
	LINELOGINFAIL = 15,
	LINECHECKSUCC = 16,
	LINECHECKFAIL = 17,
	LINEENTERHALL = 18,
	CLICKGUESTBTN = 19,
	GUESTREGISUCC = 20,
	GUESTREGIFAIL = 21,
	GUESTENTERHALL = 22,
	GUESTLOGINSUCC = 23,
	GUESTLOGINFAIL = 24,
	CLICKAPPLEBTN = 25,
	APPLELOGINSUCC = 26,
	APPLELOGINFAIL = 27,
	APPLEENTERHALL = 28,
	ONRECONNECT = 29,
	RECONNECTSUCC = 30,
	RECONNECTFAIL = 31,
	RECONNECTTOLOGIN = 32,
	GUIDESTEP1 = 33,
	GUIDESTEP2JUMP = 34,
	GUIDESTEP2NEXT = 35,
	GUIDESTEP3JUMP = 36,
	GUIDESTEP3NEXT = 37,
	GUIDESTEP4JUMP = 38,
	GUIDESTEP4NEXT = 39,
	CLICKGAME3002 = 40,
	CLICKGAME3005 = 41,
	CLICKGAME2003 = 42,
	CLICKGAME4002 = 43,
	CLICKGAME2002 = 44,
	CLICKGAME1007 = 45,
	CLICKGAME3004 = 46,
	CLICKGAME2005 = 47,
	CLICKGAME1003 = 48,
	CLICKGAME2001 = 49,
	CLICKGAME3009 = 50,
	CLICKGAME1001 = 51,
	CLICKGAME3001 = 52,
	CLICKGAME3010 = 53,
	CLICKGAME1005 = 54,
	CLICKGAME1004 = 55,
	CLICKGAME3008 = 56,
	CLICKGAME3003 = 57,
	CLICKGAME1006 = 58,
	CLICKGAME4001 = 59,
	CLICKGAME3007 = 60,
	CLICKGAME1008 = 61,
	CLICKLOGOUT = 296,
	CLICKGAME7001 = 315,
}


function ReportManager.SetDot(Step)

	if CC.DebugDefine.GetDotDebugState() then
		--log("Debug模式关闭打点")
		return;
	end

	--这两个点还没拉取到开关状态，默认不打这两个点
	if Step~="STARTAPP" and Step~="GETVERSION" then
		--web打点开关
		if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("SetDot",false) then
			return
		end
	else
		return
	end
	
	local OperateType = ReportDefine[Step] or Step
	if not CC.uu.isNumber(OperateType) then
		--logError("OperateType is not a number:"..OperateType)
		return
	end
	
	local hasPlayerInfo = CC.Player.Inst():CheckSelfInfo()
	if hasPlayerInfo then
		local createTime = CC.uu.date4time(CC.Player.Inst():GetSelfInfoByKey("CreateTime"))
		local curTime = os.time()
		if curTime - createTime > 86400 then
			--logError("仅新用户24小时内打点")
			return
		end
	end

	local param = {}
	param.IP = Util.GetIPAddress()
	param.IMEI = CC.Platform.GetDeviceId()
	param.PlayerID = hasPlayerInfo and CC.Player.Inst():GetSelfInfoByKey("Id") or 0
	param.OperateType = OperateType
	param.PhoneDev = ReportManager.GetDeviceModel()
	param.ClientVersion = string.format("%s.%s",AppInfo.version,tonumber(Util.GetFromPlayerPrefs("LocalAssetsVersion")));
	param.OS = CC.Platform.GetOSEnum()
	param.Network = Util.IsWifi and 2 or 1
	param.PING = -2
	param.CreateTimeStamp = os.time()

	if CC.Network.isInGame() then--连接服务器后再上传打点记录
		local func = function (value)
			param.PING = value
			local js = Json.encode(param)
			CC.uu.Log(js,"Log:",3)
			CC.Request("Req_ClientRecord",js)
		end
		CC.Network.GetHallPing(func)
	else
		local js = Json.encode(param)
		CC.uu.Log(js,"Log:",3)
		CC.Request("Req_ClientRecord",js)
	end
end

function ReportManager.GetDeviceModel()

	local info = CC.HallUtil.GetDeviceInfo()
	if table.isEmpty(info) then
		return "Unknown"
	end
	return info.BRAND.. " " .. info.MODEL
end

return ReportManager