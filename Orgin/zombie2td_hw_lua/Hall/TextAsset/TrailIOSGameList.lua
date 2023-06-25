
local viewCtrClass = require("View/TrailView/TrailIOSGameListCtr")

local CC = require("CC")
local TrailIOSGameList = CC.uu.ClassView("TrailIOSGameList")

local TripleJackpot = {

}

function TrailIOSGameList:ctor(transform,hallview,obj)
	self.transform = transform
	--游戏卡图对象
	self.gameList = {}
	--奖池对象
	self.jackpot = {}
	--奖池状态
	self.jackpotState = false
	--奖池特效切换间隔
	self.jackpotTime = 0
	--当前播放奖池特效下标
	self.jackpotIndex = 1
	--奖池Map
	self.jackpotMap = {}
	--奖池当前滚动数据
	self.realJackpotMap ={}
	--奖池滚动间隔
	self.rollSecond = 3000

	--比赛Map
	self.matchMap = {}
	--比赛切换间隔
	self.matchSecond = 30
	--比赛初始化状态
	self.matchState = false
end

function TrailIOSGameList:Create()
	self:OnCreate()
end

function TrailIOSGameList:OnCreate()
	self.language = CC.LanguageManager.GetLanguage("L_HallView");

	self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")

	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")

	self.webDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")

	self.tripleJackpot = self:FindChild("Viewport/Content/SpecialNode/Jackpot")
	self.tripleJackpotText = self.tripleJackpot:FindChild("Text")

	self.aircraftNode = self:FindChild("Viewport/Content/SpecialNode/AircraftNode")
	self.fishNode = self:FindChild("Viewport/Content/SpecialNode/FishNode")
	self.rcNode = self:FindChild("Viewport/Content/Recommend")
	self.miniNode = self:FindChild("Viewport/Content/Common")

	self.viewCtr = viewCtrClass.new(self,self.param);
	self.viewCtr:OnCreate()

	CC.LocalGameData.GetRecentGame()
	-- self:StartUpdate()
end

function TrailIOSGameList:InitGameList(param)
	local index = 1
	self.co_InitList = coroutine.start(function ()
		for i = 1,#param.airList do
			index = index + 1
			self:CreRCPrefab(param.airList[i],self.aircraftNode,index)
			coroutine.step(1)
		end
		for i = 1, #param.fishList do
			index = index + 1
			self:CreRCPrefab(param.fishList[i],self.fishNode,index)
			coroutine.step(1)
		end
		for i = 1, #param.rcList do
			index = index + 1
			self:CreRCPrefab(param.rcList[i],self.rcNode,index)
			coroutine.step(1)
		end
		for i = 1, #param.miniList do
			index = index + 1
			self:CreMiniPrefab(param.miniList[i],self.miniNode,index)
			coroutine.step(1)
		end
		self.jackpotState = true
		self.matchState = true
		self:InitGameJackpots(true)

		if not table.isEmpty(param.airList) and not table.isEmpty(param.fishList) then
			--可以显示捕鱼奖池
			self.tripleJackpot:SetActive(true)
		end
		-- 每次进入HallView，检查当前游戏下载进度
		CC.ResDownloadManager.CheckDownloaderState()
	end)
end

function TrailIOSGameList:CreRCPrefab(param,parent,index)
	local obj = nil
	local preName = param.name
	obj = CC.uu.LoadHallPrefab("prefab",preName,parent)
	obj.transform.localScale = Vector3(0,0,1)
	param.obj = obj
	local effect = obj.transform:FindChild("obj/icon/effect")
	if effect then
		effect:SetActive(false)
	end
	self:InitPrefab(param,index)
end

function TrailIOSGameList:CreMiniPrefab(param,parent,index)
	local obj = nil
	local preName = param.name
	if self.HallDefine.GameListIcon[preName] and self.HallDefine.GameListIcon[preName].prefab then
		obj = CC.uu.LoadHallPrefab("prefab",preName,parent)
	else
		obj = CC.uu.LoadHallPrefab("prefab","MiniCard",parent)
		local sprite = self.HallDefine.GameListIcon[preName] and self.HallDefine.GameListIcon[preName].path or "img_yxrk_1002"
		self:SetImage(obj:FindChild("obj/icon"), sprite);
		self:SetImage(obj:FindChild("obj/state/icon"), sprite);
		self:SetImage(obj:FindChild("obj/state/mask"), sprite);
	end
	param.obj = obj
	obj.transform.localScale = Vector3(0,0,1)
	local effect = obj.transform:FindChild("obj/icon/effect")
	if preName ~= "MiniCard" and effect then
		effect:SetActive(false)
	end
	self:InitPrefab(param,index)
end

function TrailIOSGameList:InitPrefab(param,index)
	local id = param.id
	local data = param.data
	local obj = param.obj
	local action = {
		{"delay", (index-1) * 0.03},
		{"scaleTo", 1, 1, 0.3, ease = CC.Action.EOutBack},
	}

	action.onEnd = function()
		if obj:FindChild("obj/icon/effect") then
			obj:FindChild("obj/icon/effect"):SetActive(true)
		end
		obj:FindChild("obj/icon/hot"):SetActive(false)
		obj:FindChild("obj/icon/new"):SetActive(false)
		obj:FindChild("obj/icon/vip"):SetActive(false)
		obj:FindChild("obj/icon/match"):SetActive(false)
	end


	--设置下载状态
	obj:FindChild("obj/undownload"):SetActive(false)
	--设置解锁状态
	local lock = CC.HallUtil.CheckEnterLimit(id)
	if not lock then
		obj:FindChild("obj/lock"):SetActive(false)
		obj:FindChild("obj/undownload"):SetActive(false)
	end
	--设置点击状态
	if data.IsCommingSoon == 1 then
		obj:FindChild("obj/icon"):SetActive(false)
		obj:FindChild("obj/state"):SetActive(true)
		obj:FindChild("obj/state/soon"):SetActive(true)
		obj:FindChild("obj/undownload"):SetActive(false)
		obj:GetComponent("Button"):SetBtnEnable(false)
	end
	self:RunAction(obj, action)
	--------------------------------初始化奖池状态，比赛状态-------------------------------------
	-- if data.IsGoldPoolShow == 1 then
	-- 	local jackpot = nil
	-- 	if self:JudgeJackpotState(id) then
	-- 		jackpot = obj:FindChild("jackpot")
	-- 	else
	-- 		jackpot = obj:FindChild("jackpot")
	-- 		jackpot:SetActive(false)
	-- 	end
	-- 	if jackpot then
	-- 		table.insert(self.jackpot,jackpot:FindChild("jackpot"))
	-- 		table.insert(self.jackpotMap,id)
	-- 	end
	-- end

	local match = obj:FindChild("obj/match")
	if match then
		match:SetActive(false)
	end
	-- if match then
	-- 	self.matchMap[id] = {}
	-- 	self.matchMap[id].curType = 1
	-- 	self.matchMap[id].count = match.childCount
	-- 	self.matchMap[id].obj = match
	-- 	self.matchMap[id].time = self.matchSecond
	-- 	--设置奖池标记，用于比赛奖池切换
	-- 	if data.IsGoldPoolShow == 1 then
	-- 		self.matchMap[id].jackpot = obj:FindChild("jackpot")
	-- 	else
	-- 		self.matchMap[id].jackpot = nil
	-- 	end
	-- 	self:InitMatchInfo(id)
	-- end
	-------------------------------------------------------------------------------------------
	self.gameList[id] = {}
	self.gameList[id].obj = obj
	self.gameList[id].isClick = false
	self.gameList[id].vipLimit = data.VipUnlock

	self:AddClick(obj,function ()
		self:OnClickCard(id)
	end)

	--------------------------------点击缩放-------------------------------------
	obj.onDown = function ()
		if self.gameList[id].isClick == false then
			self:RunAction(obj, { "scaleTo", 0.98, 0.98, 0.05, ease = CC.Action.EOutBack})
		end
	end

	obj.onUp = function ()
		if self.gameList[id].isClick == false then
			self:RunAction(obj, { "scaleTo", 1, 1, 0.05, ease = CC.Action.EOutBack})
		end
	end
	-----------------------------------------------------------------------------------------
end

function TrailIOSGameList:InitMatchInfo(id)
	local Info = self.gameDataMgr.GetArenaInfoByID(id)
	if not Info then return end
	if Info.IsOpen then
		self.matchMap[id].IsOpen = Info.IsOpen
		local CompetitionInfo = self.gameDataMgr.GetArenaInfoByID(id).CompetitionInfo
		for i,v in ipairs(CompetitionInfo) do
			local weekday = CompetitionInfo[i].WeekDay
			local showTime = CompetitionInfo[i].ShowTime
			local startTime = CompetitionInfo[i].StartTime
			local endTime = CompetitionInfo[i].EndTime
			local type = CompetitionInfo[i].Type
			local physical = CompetitionInfo[i].Physical
			local param = {}
			param.weekday = weekday
			param.showTime = self:GetTimestamp(showTime)
			-- param.startTime = self:GetTimestamp(startTime)
			param.endTime = self:GetTimestamp(endTime)
			param.show =self.language.match_start_time..startTime
			param.physical = physical
			if not type then return end
			if not self.matchMap[id][type] then
				self.matchMap[id][type] = {}
				table.insert(self.matchMap[id][type],param)
			else
				table.insert(self.matchMap[id][type],param)
			end
		end
	else
		self.matchMap[id].IsOpen = Info.IsOpen
	end
end

function TrailIOSGameList:GetTimestamp(Time)
	local currentTime = os.time()
	local currentDay = os.date("%d",currentTime)
	local currentYear = os.date("%Y",currentTime)
	local currentMon = os.date("%m",currentTime)
	local matchHour = string.sub(Time,1,string.find(Time,':')-1)
	local MinyteSceond = string.sub(Time,string.find(Time,':')+1,-1)
	local matchMinute = string.sub(MinyteSceond,1,string.find(MinyteSceond,':')-1)
	local matchSceond = string.sub(MinyteSceond,string.find(MinyteSceond,':')+1,-1)
	local timestamp = os.time({day=currentDay, month=currentMon, year=currentYear, hour=tonumber(matchHour), min=tonumber(matchMinute), sec=tonumber(matchSceond)})
	return timestamp
end

function TrailIOSGameList:OnClickCard(id)
	if id == 4001 then
		self:EnterLot()
		return
	elseif id == 4002 then
		CC.ViewManager.Open("ArenaView")
		return
	end

	if self.gameList[id].isClick == false then
		self.gameList[id].isClick = true
		CC.HallUtil.CheckAndEnter(id)
	end
end

function TrailIOSGameList:EnterLot()
	if self.webDataMgr.GetLotAddress() then
		CC.ViewManager.Open("LotteryView",{serverIp = self.webDataMgr.GetLotAddress()})
	else
        local data = {}
        data.GameId = 4001
        data.GroupId = 1
        CC.Request("ReqAllocServer",data,function (err,data)
			CC.ViewManager.Open("LotteryView",{serverIp = data.Address})
		end,
		function (err,data)
			logError("EnterLot Fail")
		end)

	end
end

function TrailIOSGameList:GameUnlockGift(id)
	if self.gameList[id] == nil then return end
	local obj = self.gameList[id].obj
	obj:FindChild("obj/lock"):SetActive(false)
	obj:FindChild("obj/undownload"):SetActive(CC.LocalGameData.GetGameVersion(id) == 0)
end

function TrailIOSGameList:VipChanged(level)
	for k, v in pairs(self.gameList) do
		if level >= v.vipLimit then
			v.obj:FindChild("obj/lock"):SetActive(false)
			v.obj:FindChild("obj/undownload"):SetActive(CC.LocalGameData.GetGameVersion(k) == 0)
		end
	end
end

function TrailIOSGameList:DownloadProcess(data)
	local id = data.gameID
	local process = data.process
	if self.gameList[id] == nil then return end
	local obj = self.gameList[id].obj
	if process < 1 then
		if process == 0 then
			obj:FindChild("obj/icon"):SetActive(false)
			obj:FindChild("obj/undownload"):SetActive(false)
			obj:FindChild("obj/state"):SetActive(true)
			obj:FindChild("obj/state/slider"):SetActive(true)
			obj:FindChild("obj/state/slider/Text").text = self.language.download_tip
			obj:FindChild("obj/state/slider/Slider"):GetComponent("Slider").value = process
		else
			obj:FindChild("obj/icon"):SetActive(false)
			obj:FindChild("obj/undownload"):SetActive(false)
			obj:FindChild("obj/state"):SetActive(true)
			obj:FindChild("obj/state/slider"):SetActive(true)
			obj:FindChild("obj/state/slider/Text").text = string.format("%.1f",process * 100) .. "%"
			obj:FindChild("obj/state/slider/Slider"):GetComponent("Slider").value = process
		end
	else
		obj:FindChild("obj/icon"):SetActive(true)
		obj:FindChild("obj/undownload"):SetActive(false)
		obj:FindChild("obj/state"):SetActive(false)
		self.gameList[id].isClick = false
	end
end

function TrailIOSGameList:DownloadFail(id)
	if self.gameList[id] == nil then return end
	local obj = self.gameList[id].obj
	obj:FindChild("obj/icon"):SetActive(true)
	obj:FindChild("obj/undownload"):SetActive(true)
	obj:FindChild("obj/state"):SetActive(false)
	self.gameList[id].isClick = false
end

function TrailIOSGameList:StartUpdate()
	UpdateBeat:Add(self.Update,self);
end

function TrailIOSGameList:StopUpdate()
	UpdateBeat:Remove(self.Update,self);
end

function TrailIOSGameList:Update()
	if self.jackpotState then
		self.jackpotTime = self.jackpotTime + Time.deltaTime
		self.jackpot[self.jackpotIndex]:SetActive(true)
		if self.jackpotTime > 2.5 then
			self.jackpot[self.jackpotIndex]:SetActive(false)
			self.jackpotIndex = self.jackpotIndex + 1
			self.jackpotTime = 0
			if self.jackpotIndex > #self.jackpot then
				self.jackpotIndex = 1
			end
		end
	end
	if self.matchState then
		local currentDay = os.date("%w", os.time());
		for k,v in pairs(self.matchMap) do
			v.time = v.time + Time.deltaTime
			if v.time >= self.matchSecond then
				v.time = 0
				if v.IsOpen then
					local typeParam = v[v.curType]
					if not typeParam then
						v.curType = v.curType + 1
						if v.curType > v.count then
							v.curType = 1
						end
						v.time = self.matchSecond
						return
					end
					for i = 1, #typeParam do
						if typeParam[i].weekday == -1 or typeParam[i].weekday == tonumber(currentDay) then
							-- self:RefreshMatch(v,typeParam)
							v.curType = v.curType + 1
							if v.curType > v.count then
								v.curType = 1
							end
							break
						else
							v.curType = v.curType + 1
							if v.curType > v.count then
								v.curType = 1
							end
							v.time = self.matchSecond
							break
						end
					end
				end
			end
		end
	end
end

function TrailIOSGameList:RefreshMatch(value,param)
	local obj = value.obj
	local jackpot = value.jackpot
	local index = value.curType
	local count = obj.childCount
	local showText,bMatch,physical = self:GetCurrentShowTime(param,jackpot)
	for i = 1, count do
		if jackpot then
			if bMatch then
				if i == index then
					local Image = obj:FindChild(tostring(i).."/Title")
					if Image then
						if physical and CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("TreasureGoods") then
							obj:FindChild(tostring(i).."/Title/Reward"):SetActive(true)
							obj:FindChild(tostring(i).."/Title/Common"):SetActive(false)
						else
							obj:FindChild(tostring(i).."/Title/Reward"):SetActive(false)
							obj:FindChild(tostring(i).."/Title/Common"):SetActive(true)
						end
					end
					obj:FindChild(tostring(i).."/Text").text = showText
					obj:FindChild(tostring(i)):SetActive(true)
				else
					obj:FindChild(tostring(i)):SetActive(false)
				end
				obj:SetActive(true)
				jackpot:SetActive(false)
			else
				obj:SetActive(false)
				jackpot:SetActive(true)
			end
		else
			if i == index then
				local Image = obj:FindChild(tostring(i).."/Title")
					if Image then
						if physical and CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("TreasureGoods") then
							obj:FindChild(tostring(i).."/Title/Reward"):SetActive(true)
							obj:FindChild(tostring(i).."/Title/Common"):SetActive(false)
						else
							obj:FindChild(tostring(i).."/Title/Reward"):SetActive(false)
							obj:FindChild(tostring(i).."/Title/Common"):SetActive(true)
						end
					end
				obj:FindChild(tostring(i).."/Text").text = showText
				obj:FindChild(tostring(i)):SetActive(true)
			else
				obj:FindChild(tostring(i)):SetActive(false)
			end
		end
	end
end

function TrailIOSGameList:GetCurrentShowTime(param,jackpot)
	local showText = nil
	local bMatch = false
	local physical = nil
	local currentTime = os.time()
	if param[1].showTime then
		showText = param[1].show
	end
	for i = 1, #param do
		if jackpot then
			if currentTime >= param[i].showTime and currentTime <= param[i].endTime then
				showText = param[i].show
				bMatch = true
				physical = param[i].physical
				break
			end
		else
			if currentTime <= param[i].endTime then
				showText = param[i].show
				bMatch = true
				physical = param[i].physical
				break
			end
		end
	end
	return showText,bMatch,physical
end

function TrailIOSGameList:InitGameJackpots(bState)
	for i = 1, #self.jackpotMap do
		local id = self.jackpotMap[i]
		local obj = self.gameList[id].obj
		local param = {}
		if self:JudgeJackpotState(id) then
			param.obj = self.tripleJackpotText
		else
			param.obj = obj:FindChild("obj/jackpot/01/Text")
		end
		self:UpdateGoldPool(param,id)
		if bState then
			self:RollGoldPool(param,id)
		end
	end
end

function TrailIOSGameList:UpdateGoldPool(param,id)
	local jackpotNum = 0
	if self:JudgeJackpotState(id) then
		jackpotNum = self:GetTripleJackpot()
	else
		jackpotNum = CC.Player.Inst():GetJackpotsNumByKey(id)
	end
	if jackpotNum == 0 then
		param.obj.text = self.language.jackpotLoading
		param.loadingOver = false
	else
		if self.realJackpotMap[id] == nil then
			self.realJackpotMap[id] = {}
			self.realJackpotMap[id].cur = jackpotNum
		end
		param.loadingOver = true
		param.hallGoldValue =  math.ceil(self.realJackpotMap[id].cur)
		param._dstGoldValue =  math.ceil(jackpotNum)
		param._delayGoldvalue = math.ceil((param._dstGoldValue -  param.hallGoldValue)/self.rollSecond)
	end
end

function TrailIOSGameList:RollGoldPool(param,id)
	self:StartTimer("RunCircle" .. id,0.1,function ()
		if param.loadingOver then
			self.realJackpotMap[id].cur = self.realJackpotMap[id].cur + param._delayGoldvalue
			if self.realJackpotMap[id].cur > param._dstGoldValue then
				self.realJackpotMap[id].cur = param._dstGoldValue
			end
			param.obj.text = CC.uu.numberToStrWithComma(self.realJackpotMap[id].cur)
		end
	end,self.rollSecond)
end


--合并奖池
function TrailIOSGameList:JudgeJackpotState(id)
	local state = false
	for i = 1, #TripleJackpot do
		if TripleJackpot[i] == id then
			state = true
		end
	end
	return state
end

--获取合并奖池
function TrailIOSGameList:GetTripleJackpot()
	local count = 0
	for i = 1, #TripleJackpot do
		count = count + CC.Player.Inst():GetJackpotsNumByKey(TripleJackpot[i])
	end
	return count
end

function TrailIOSGameList:SetCanClick(flag)
	self._canClick = flag
end

function TrailIOSGameList:OnDestroy()
	if self.co_InitList then
		coroutine.stop(self.co_InitList)
		self.co_InitList = nil
	end
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
	self:StopUpdate()
	self:StopAllTimer()
end

return TrailIOSGameList