local CC = require("CC")
local ArenaDataMgr = {}
local this = ArenaDataMgr

function this.Init()
	CC.HallNotificationCenter.inst():register(this,this.OnGetGameArenaRsp,CC.Notifications.NW_ReqGetGameArena)
end

function this.GetGameArena()
	CC.Request("ReqGetGameArena")
end

function this.OnGetGameArenaRsp( code , data)
	log(CC.uu.Dump(data,"OnGetGameArenaRsp =",10))
	this.HandleArenaData(data)
end

function this.HandleArenaData( data )
	if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("SidePopup") then
		return
	end
	local GameArenas = data.Arenas
	local TimeStamp = data.TimeStamp
	for i,Arena in ipairs(GameArenas or {}) do
		local GameId = Arena.GameId
		local GroupId = Arena.GroupId
		local ArenaInfo = Arena.ArenaInfo
		local ExtraData = Arena.ExtraData
		local MatchId = Arena.MatchId
		local AData
		if ArenaInfo and CC.uu.SafeCallFunc(function() AData = Json.decode(ArenaInfo) end) then
			if AData == nil then
				return
			end
			local Props = {}
			if AData.Material and type(AData.Material)=="table" and #AData.Material>1 and AData.Material[1]~=0 and AData.Material[2]~=0 then
				table.insert(Props,{ConfigId = AData.Material[1],Count = AData.Material[2]})
			end
			if AData.Prop and type(AData.Prop)=="table" and #AData.Prop>1 and AData.Prop[1]~=0 and AData.Prop[2]~=0 then
				table.insert(Props,{ConfigId = AData.Prop[1],Count = AData.Prop[2]})
			end
			if AData.Money and AData.Money~=0 then
				table.insert(Props,{ConfigId = CC.shared_enums_pb.EPC_ChouMa,Count = AData.Money})
			end
			if #Props == 0 then
				CC.uu.Log(data,"OnPushGameArena:",3)
				return
			end

			-- 拉取的，使用时间戳重新计算倒计时时间
			if TimeStamp and type(TimeStamp) == "number" and TimeStamp ~= 0 and
				AData.StartTime and type(AData.StartTime) == "number" and
				AData.RemainTime and type(AData.RemainTime) == "number" then
				AData.RemainTime = AData.StartTime - TimeStamp
				if AData.RemainTime < 0 then
					AData.RemainTime = 0
				end
			end

			if AData.IsAward then
				this.HandleArenaAward(Arena,AData,Props,GameId)
			else
				this.HandleArenaTips(Arena,AData,Props,GameId)
			end
		else
			CC.uu.Log(data,"OnPushGameArena:",3)
		end
	end
end

function this.HandleArenaTips(Arena,AData,Props,GameId)
	local showTime = 8 -- 显示时间
	if not CC.ViewManager.IsHallScene() then
		showTime = AData.ShowTime
	end
	local time = AData.RemainTime -- 倒计时
	local isShowAwardPool
	if GameId and (GameId == 2002 or GameId == 2004) or AData.IsShowAwardPool then
		isShowAwardPool = true
	end
	local timeStr = CC.uu.TimeFormat(AData.BeginHour,AData.BeginMin,AData.EndHour,AData.EndMin)
	local name = AData.Name
	local callback = function ()
		if CC.ViewManager.IsHallScene() then
			local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game");
			local param = {}
			param.isMatch = true
			param.gameData = gameDataMgr.GetInfoByID(GameId)
			CC.HallUtil.CheckAndEnter(GameId,param)
		else
			CC.HallNotificationCenter.inst():post(CC.Notifications.OnPlayerToArenaClick,Arena)
		end
	end
	CC.ViewManager.ShowArenaNoticeView(
		{type=3,name=name,showTime=showTime,Props=Props,time=time,timeStr=timeStr,isShowAwardPool=isShowAwardPool,callback=callback}, 
		true,
		GameId)
end

function this.HandleArenaAward(Arena,AData,Props,GameId)
	local title = AData.Name or ""
	local playerName = AData.PlayerName or ""
	local showTime = AData.ShowTime or 8

	CC.ViewManager.ShowArenaNoticeView(
		{type=4,name=title,showTime=showTime,Props=Props,playerName=playerName}, 
		true,
		GameId)
end

this.Init()

return ArenaDataMgr