local CC = require("CC")
local GameList = CC.uu.ClassView("GameList")

local TripleJackpot = {}

local ADMove = {
	[2] = {[1.5] = 2, [2.5] = 1, [3.5] = 2, [4.5] = 1},
	[3] = {[1.5] = 3, [2.5] = 1, [3.5] = 2, [4.5] = 3, [5.5] = 1, [6.5] = 2, [7.5] = 3},
	[4] = {[1.5] = 3, [2.5] = 4, [3.5] = 1, [4.5] = 2, [5.5] = 3, [6.5] = 4, [7.5] = 1, [8.5] = 2},
	[5] = {[1.5] = 3, [2.5] = 4, [3.5] = 5, [4.5] = 1, [5.5] = 2, [6.5] = 3, [7.5] = 4, [8.5] = 5, [9.5] = 1, [10.5] = 2}
}

local SPECIAL_SCALE = 2
local DESIGN_MOVE = 200 - 3 --最近游戏底框移动距离

function GameList:ctor(transform, hallview, obj)
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
	self.realJackpotMap = {}
	--奖池滚动间隔
	self.rollSecond = 3000

	--比赛Map
	self.matchMap = {}
	--比赛切换间隔
	self.matchSecond = 30
	--比赛初始化状态
	self.matchState = false

	--最近游戏展示中
	self.recentShow = false

	self.minPos = nil
	self.maxPos = nil

	self.leftPos = nil
	self.rightPos = nil

	self.adIndex = 1
	self.currentGmaeType = -1
	self.gameAction = {}

	self.boardOffsetPosX = Screen.width / Screen.height * 6 / 2 * 10 + 20 --图卡显示隐藏的边界世界坐标X
end

function GameList:Create()
	self:OnCreate()
end

function GameList:OnCreate()
	self.language = CC.LanguageManager.GetLanguage("L_HallView")

	self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")

	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")

	self.webDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")

	self.tripleJackpot = self:FindChild("Viewport/Content/SpecialNode/Jackpot")
	self.tripleJackpotText = self.tripleJackpot:FindChild("Text")

	self.gameNode = self:FindChild("Viewport/Content")
	self.aircraftNode = self:FindChild("Viewport/Content/SpecialNode/AircraftNode")
	self.fishNode = self:FindChild("Viewport/Content/SpecialNode/FishNode")
	self.rcNode = self:FindChild("Viewport/Content/Recommend")
	self.miniNode = self:FindChild("Viewport/Content/Common")

	self.recentPanel = self:FindChild("RecentGame")
	self.recentBtn = self:FindChild("RecentGame/RecentBtn")
	self.toggleGroup = self.recentPanel:FindChild("GameSort")

	self.decorate = self:FindChild("Viewport/Content/MessageBox/DecorateNode")
	self.spin = self:FindChild("Viewport/Content/MessageBox/DecorateNode/Elephant"):GetComponent("SkeletonGraphic")
	self.indexNode = self:FindChild("Viewport/Content/MessageBox/IndexGroup")
	self.index = self.indexNode:FindChild("Index")

	self.ScrollRect = self:FindChild("Viewport/Content/MessageBox/Layout/Scroller")
	self.ScrollerController =
		self:FindChild("Viewport/Content/MessageBox/Layout/ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(
		function(tran, dataIndex, cellIndex)
			self.viewCtr:ItemData(tran, dataIndex, cellIndex)
		end
	)

	self.viewCtr = require("View/HallView/GameListCtr").new(self, self.param)
	self.viewCtr:OnCreate()
	self:InitRecentGame()
	-------------------------------------------------------------------------------------------------------------------------------------
	self:StartUpdate()
end

function GameList:InitRecentGame()
	local curScale = (UnityEngine.Screen.width / UnityEngine.Screen.height)
	if curScale > SPECIAL_SCALE then
		self.recentMoveWidth = DESIGN_MOVE + 60 --正常移动像素为140-3
	else
		self.recentMoveWidth = DESIGN_MOVE
	end

	local info = CC.LocalGameData.GetRecentGame()
	for i, v in ipairs(info) do
		local btn = CC.uu.UguiAddChild(self.recentPanel, self.recentBtn, tostring(v))
		local ImgName =
			self.HallDefine.GameListIcon["yxrk_" .. v] and self.HallDefine.GameListIcon["yxrk_" .. v].path or "img_yxrk_" .. v
		self:SetImage(btn, ImgName)
		self:AddClick(
			btn,
			function()
				self:OnClickCard(v, true)
			end
		)
	end
	UIEvent.AddToggleValueChange(
		self.toggleGroup:FindChild("All"),
		function(selected)
			self.toggleGroup:FindChild("All/Checkmark"):SetActive(selected)
			if selected then
				if self.currentGmaeType == 0 then
					return
				end
				self.currentGmaeType = 0
				self.viewCtr:SetGameList(0)
			end
		end
	)
	UIEvent.AddToggleValueChange(
		self.toggleGroup:FindChild("Fish"),
		function(selected)
			self.toggleGroup:FindChild("Fish/Checkmark"):SetActive(selected)
			if selected then
				if self.currentGmaeType == 1 then
					return
				end
				self.currentGmaeType = 1
				self.viewCtr:SetGameList(1)
			end
		end
	)
	UIEvent.AddToggleValueChange(
		self.toggleGroup:FindChild("Slots"),
		function(selected)
			self.toggleGroup:FindChild("Slots/Checkmark"):SetActive(selected)
			if selected then
				if self.currentGmaeType == 2 then
					return
				end
				self.currentGmaeType = 2
				self.viewCtr:SetGameList(2)
			end
		end
	)
	UIEvent.AddToggleValueChange(
		self.toggleGroup:FindChild("Poker"),
		function(selected)
			self.toggleGroup:FindChild("Poker/Checkmark"):SetActive(selected)
			if selected then
				if self.currentGmaeType == 3 then
					return
				end
				self.currentGmaeType = 3
				self.viewCtr:SetGameList(3)
			end
		end
	)

	-- unity2020,这里单单设置Toggle.isOn = true 没生效，先置为false，再置为true,就又行了...
	self.toggleGroup:FindChild("All"):GetComponent("Toggle").isOn = false
	self.toggleGroup:FindChild("All"):GetComponent("Toggle").isOn = true
end

function GameList:SetGameType(gameType)
	if not gameType then
		return
	end
	if gameType == 1 then
		self.toggleGroup:FindChild("Fish"):GetComponent("Toggle").isOn = false
		self.toggleGroup:FindChild("Fish"):GetComponent("Toggle").isOn = true
	elseif gameType == 2 then
		self.toggleGroup:FindChild("Slots"):GetComponent("Toggle").isOn = false
		self.toggleGroup:FindChild("Slots"):GetComponent("Toggle").isOn = true
	elseif gameType == 3 then
		self.toggleGroup:FindChild("Poker"):GetComponent("Toggle").isOn = false
		self.toggleGroup:FindChild("Poker"):GetComponent("Toggle").isOn = true
	else
		self.toggleGroup:FindChild("All"):GetComponent("Toggle").isOn = false
		self.toggleGroup:FindChild("All"):GetComponent("Toggle").isOn = true
	end
end

function GameList:ShowRecentGame(bState)
	if self.actioning then
		return
	end
	if bState then
		if self.recentShow then
			return
		end
		self.actioning = true
		self.recentShow = true
		self.recentPanel:SetActive(true)
		self:RunAction(self.recentPanel, {{"fadeToAll", 0, 0}, {"fadeToAll", 255, 0.4}})
		self:RunAction(
			self.recentPanel,
			{
				"localMoveTo",
				self.recentPanel.localPosition.x + self.recentMoveWidth,
				self.recentPanel.localPosition.y,
				0.2,
				function()
					self.actioning = false
				end
			}
		)
	else
		if not self.recentShow then
			return
		end
		self.actioning = true
		self.recentShow = false
		self:RunAction(self.recentPanel, {{"fadeToAll", 255, 0}, {"fadeToAll", 0, 0.4}})
		self:RunAction(
			self.recentPanel,
			{
				"localMoveTo",
				self.recentPanel.localPosition.x - self.recentMoveWidth,
				self.recentPanel.localPosition.y,
				0.2,
				function()
					self.actioning = false
					self.recentPanel:SetActive(false)
				end
			}
		)
	end
end

function GameList:InitGameList(param)
	if self.co_InitList then
		coroutine.stop(self.co_InitList)
		self.co_InitList = nil
	end

	for _, v in pairs(self.gameList) do
		v.obj:SetActive(false)
	end
	self:StopGameAction()
	local index = 1
	self.co_InitList =
		coroutine.start(
		function()
			self:FindChild("Viewport/Content/SpecialNode"):SetActive(self.viewCtr.showFish)
			self.rcNode:SetActive(self.viewCtr.showRecommend)
			self.miniNode:SetActive(self.viewCtr.showCommon)
			for i = 1, #param.airList do
				index = index + 1
				if not self.gameList[param.airList[i].id] then
					self:CreRCPrefab(param.airList[i], self.aircraftNode, index)
				else
					self.gameList[param.airList[i].id].obj:SetActive(true)
					self:RunGameAction(self.gameList[param.airList[i].id].obj, index)
				end
				coroutine.step(1)
			end
			for i = 1, #param.fishList do
				index = index + 1
				if not self.gameList[param.fishList[i].id] then
					self:CreRCPrefab(param.fishList[i], self.fishNode, index)
				else
					self.gameList[param.fishList[i].id].obj:SetActive(true)
					self:RunGameAction(self.gameList[param.fishList[i].id].obj, index)
				end
				coroutine.step(1)
			end
			for i = 1, #param.rcList do
				index = index + 1
				if not self.gameList[param.rcList[i].id] then
					self:CreRCPrefab(param.rcList[i], self.rcNode, index)
				else
					self.gameList[param.rcList[i].id].obj:SetActive(true)
					self:RunGameAction(self.gameList[param.rcList[i].id].obj, index)
				end
				coroutine.step(1)
			end
			for i = 1, #param.miniList do
				index = index + 1
				if not self.gameList[param.miniList[i].id] then
					self:CreMiniPrefab(param.miniList[i], self.miniNode, index)
				else
					self.gameList[param.miniList[i].id].obj:SetActive(true)
					self:RunGameAction(self.gameList[param.miniList[i].id].obj, index)
				end
				coroutine.step(1)
			end
			self.leftPos = -self:FindChild("Viewport"):GetComponent("RectTransform").rect.width / 2
			self.rightPos = -self.gameNode:GetComponent("RectTransform").rect.width - self.leftPos
			self.transform:GetComponent("ScrollRect").enabled = true
			self.jackpotState = true
			self.matchState = true
			self:InitGameJackpots(true)

			for k, v in pairs(self.gameList) do
				v.pos = v.obj.position.x
				if not self.minPos and not self.maxPos then
					self.minPos, self.maxPos = v.pos, v.pos
				else
					if v.pos < self.minPos then
						self.minPos = v.pos
					end
					if v.pos > self.maxPos then
						self.maxPos = v.pos
					end
				end
			end

			if not table.isEmpty(param.airList) and not table.isEmpty(param.fishList) and #TripleJackpot > 0 then
				--可以显示捕鱼奖池
				self.tripleJackpot:SetActive(true)
			end
			-- 每次进入HallView，检查当前游戏下载进度
			CC.ResDownloadManager.CheckDownloaderState()
			self:AddDragEvent()
		end
	)
end

function GameList:AddDragEvent()
	self.transform.onBeginDrag = function()
		self.startPos = self.gameNode.localPosition
	end

	self.transform.onDrag = function()
		if not self.startPos then
			self.startPos = self.gameNode.localPosition
		end
		local curPos = self.gameNode.localPosition
		-- if curPos.x >= self.leftPos or curPos.x <= self.rightPos then return end
		if curPos.x - self.startPos.x > 0 then
			self.startPos = self.gameNode.localPosition
			self:ShowRecentGame(false)
		elseif curPos.x - self.startPos.x < 0 then
			self.startPos = self.gameNode.localPosition
			self:ShowRecentGame(true)
		end
	end
end

function GameList:CreRCPrefab(param, parent, index)
	local obj = nil
	local preName = param.name
	obj = CC.uu.LoadHallPrefab("prefab", preName, parent)
	if param.id == 3002 or param.id == 3005 or param.id == 3007 then
		--暂时只三个捕鱼游戏这样设置
		obj:GetComponent("Image").alphaHitTestMinimumThreshold = 0.1
	end
	obj.transform.localScale = Vector3(0, 0, 1)
	param.obj = obj
	local effect = obj.transform:FindChild("obj/icon/effect")
	if effect then
		effect:SetActive(false)
	end
	self:InitPrefab(param, index)
end

function GameList:CreMiniPrefab(param, parent, index)
	local obj = nil
	local preName = param.name
	if self.HallDefine.GameListIcon[preName] and self.HallDefine.GameListIcon[preName].prefab then
		obj = CC.uu.LoadHallPrefab("prefab", preName, parent)
	else
		obj = CC.uu.LoadHallPrefab("prefab", "MiniCard", parent)
		local sprite = self.HallDefine.GameListIcon[preName] and self.HallDefine.GameListIcon[preName].path or "img_yxrk_1002"
		self:SetImage(obj:FindChild("obj/icon"), sprite)
		self:SetImage(obj:FindChild("obj/state/icon"), sprite)
		self:SetImage(obj:FindChild("obj/state/mask"), sprite)
		if CC.DebugDefine.GetDebugMode() then
			if not self.HallDefine.GameListIcon[preName] then
				local name = GameObject.New("GameName", typeof(UnityEngine.UI.Text)).transform
				name:SetParent(obj, false)
				name.width = 500
				local text = name:GetComponent("Text")
				text.font = UnityEngine.Resources.GetBuiltinResource(typeof(UnityEngine.Font), "Arial.ttf")
				text.fontSize = 30
				text.alignment = UnityEngine.TextAnchor.MiddleCenter
				text.text = param.data.GameName
				text.raycastTarget = false

				obj:FindChild("obj/icon").color = Color(1, 1, 1, 0.2)
			end
		end
	end
	param.obj = obj
	obj.transform.localScale = Vector3(0, 0, 1)
	local effect = obj.transform:FindChild("obj/icon/effect")
	if preName ~= "MiniCard" and effect then
		effect:SetActive(false)
	end
	self:InitPrefab(param, index)
end

function GameList:InitPrefab(param, index)
	local id = param.id
	local data = param.data
	local obj = param.obj
	local action = {
		{"delay", (index - 1) * 0.03},
		{"scaleTo", 1, 1, 0.3, ease = CC.Action.EOutBack}
	}

	action.onEnd = function()
		if obj:FindChild("obj/icon/effect") then
			obj:FindChild("obj/icon/effect"):SetActive(true)
		end
		obj:FindChild("obj/icon/hot"):SetActive(data.Tag == 1)
		obj:FindChild("obj/icon/new"):SetActive(data.Tag == 2)
		obj:FindChild("obj/icon/vip"):SetActive(data.Tag == 3)
		obj:FindChild("obj/icon/match"):SetActive(data.Tag == 4)
	end

	--设置下载状态
	obj:FindChild("obj/undownload"):SetActive(CC.LocalGameData.GetGameVersion(id) == 0)
	--设置解锁状态
	local lock = CC.HallUtil.CheckEnterLimit(id)
	if not lock then
		obj:FindChild("obj/lock"):SetActive(true)
		obj:FindChild("obj/undownload"):SetActive(false)
	end
	--设置点击状态
	if data.IsCommingSoon == 1 or CC.HallUtil.CheckShow(id) then
		obj:FindChild("obj/icon"):SetActive(false)
		obj:FindChild("obj/state"):SetActive(true)
		obj:FindChild("obj/state/soon"):SetActive(true)
		obj:FindChild("obj/undownload"):SetActive(false)
		obj:GetComponent("Button"):SetBtnEnable(false)
	end
	self.gameAction[index] = self:RunAction(obj, action)
	--------------------------------初始化奖池状态，比赛状态-------------------------------------
	if data.IsGoldPoolShow == 1 then
		local jackpot = nil
		if self:JudgeJackpotState(id) then
			--jackpot = obj:FindChild("jackpot")
		else
			jackpot = obj:FindChild("obj/jackpot")
			jackpot:SetActive(true)
		end
		if jackpot then
			table.insert(self.jackpot, jackpot:FindChild("jackpot"))
		end
		table.insert(self.jackpotMap, id)
	end

	local match = obj:FindChild("obj/match")
	if match then
		self.matchMap[id] = {}
		self.matchMap[id].curType = 1
		self.matchMap[id].count = match.childCount
		self.matchMap[id].obj = match
		self.matchMap[id].time = self.matchSecond
		--设置奖池标记，用于比赛奖池切换
		if data.IsGoldPoolShow == 1 and not self:JudgeJackpotState(id) then
			self.matchMap[id].jackpot = obj:FindChild("obj/jackpot")
		else
			self.matchMap[id].jackpot = nil
		end
		self:InitMatchInfo(id)
	end
	-------------------------------------------------------------------------------------------
	self.gameList[id] = {}
	self.gameList[id].obj = obj
	self.gameList[id].isClick = false
	self.gameList[id].vipLimit = data.VipUnlock
	self.gameList[id].node = obj:FindChild("obj")

	self:AddClick(
		obj,
		function()
			self:OnClickCard(id)
		end
	)

	self:SetGameTagState(param.id)
	--------------------------------点击缩放-------------------------------------
	obj.onDown = function()
		if self.gameList[id].isClick == false then
			self:RunAction(obj, {"scaleTo", 0.98, 0.98, 0.05, ease = CC.Action.EOutBack})
		end
	end

	obj.onUp = function()
		if self.gameList[id].isClick == false then
			self:RunAction(obj, {"scaleTo", 1, 1, 0.05, ease = CC.Action.EOutBack})
		end
	end
	-----------------------------------------------------------------------------------------
end

function GameList:RunGameAction(obj, index)
	obj.transform.localScale = Vector3(0, 0, 1)
	local action = {
		{"delay", (index - 1) * 0.03},
		{"scaleTo", 1, 1, 0.3, ease = CC.Action.EOutBack}
	}
	self.gameAction[index] = self:RunAction(obj, action)
end

function GameList:StopGameAction()
	for _, action in pairs(self.gameAction) do
		self:StopAction(action)
		action = nil
	end
	self.gameAction = {}
end

--统一处理提前体验/比赛/jackpot标签 优先级：提前体验>比赛>jackpot
function GameList:SetGameTagState(id, isShowMatch)
	if not self.gameList[id] then
		return
	end
	local QueueList = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetQueueList()
	local isShowEarlyAccess = false
	for _, v in ipairs(QueueList) do
		if id == tonumber(v) then
			isShowEarlyAccess = true
		end
	end
	if isShowEarlyAccess then
		local earlyObj = self.gameList[id].obj:FindChild("obj/early")
		if earlyObj then
			earlyObj:SetActive(true)
			earlyObj:FindChild("Text").text = string.format(self.language.earlyAccess, self.gameList[id].vipLimit)
			if self.matchMap[id] then
				if self.matchMap[id].obj then
					self.matchMap[id].obj:SetActive(false)
				end
				if self.matchMap[id].jackpot then
					self.matchMap[id].jackpot:SetActive(false)
				end
			end
		else
			logError("当前排队游戏没有添加EarlyAccess图标，id:" .. id)
		end
		return
	end
	if self.matchMap[id] then
		if self.matchMap[id].obj then
			self.matchMap[id].obj:SetActive(isShowMatch)
		end
		if self.matchMap[id].jackpot then
			self.matchMap[id].jackpot:SetActive(not isShowMatch)
		end
	end
end

function GameList:InitMatchInfo(id)
	local Info = self.gameDataMgr.GetArenaInfoByID(id)
	if not Info then
		return
	end
	if Info.IsOpen then
		self.matchMap[id].IsOpen = Info.IsOpen
		local CompetitionInfo = self.gameDataMgr.GetArenaInfoByID(id).CompetitionInfo
		for i, v in ipairs(CompetitionInfo) do
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
			param.show =
				id == 3007 and string.format("%s<color=#0CFF00FF>%s</color>", self.language.match_start_time, startTime) or
				self.language.match_start_time .. startTime
			param.physical = physical
			if not type then
				return
			end
			if not self.matchMap[id][type] then
				self.matchMap[id][type] = {}
				table.insert(self.matchMap[id][type], param)
			else
				table.insert(self.matchMap[id][type], param)
			end
		end
	else
		self.matchMap[id].IsOpen = Info.IsOpen
	end
end

function GameList:GetTimestamp(Time)
	local currentTime = os.time()
	local currentDay = os.date("%d", currentTime)
	local currentYear = os.date("%Y", currentTime)
	local currentMon = os.date("%m", currentTime)
	local matchHour = string.sub(Time, 1, string.find(Time, ":") - 1)
	local MinyteSceond = string.sub(Time, string.find(Time, ":") + 1, -1)
	local matchMinute = string.sub(MinyteSceond, 1, string.find(MinyteSceond, ":") - 1)
	local matchSceond = string.sub(MinyteSceond, string.find(MinyteSceond, ":") + 1, -1)
	local timestamp =
		os.time(
		{
			day = currentDay,
			month = currentMon,
			year = currentYear,
			hour = tonumber(matchHour),
			min = tonumber(matchMinute),
			sec = tonumber(matchSceond)
		}
	)
	return timestamp
end

function GameList:OnClickCard(id, jump, flag)
	if jump and self.gameList[id] then
		local temp = self.gameList[id].pos - self.minPos
		local tol = self.maxPos - self.minPos
		self.transform:GetComponent("ScrollRect").horizontalNormalizedPosition = temp / tol
		self:ShowRecentGame(false)
	end
	CC.ReportManager.SetDot("CLICKGAME" .. id)
	local OpenURL = self.gameDataMgr.GetOpenURLByID(id)
	if OpenURL then
		local param = {}
		param.str = self.language["jump_" .. id]
		param.okFunc = function()
			Client.OpenURL(OpenURL)
		end
		param.width = 600
		param.height = 250
		CC.ViewManager.MessageBoxExtend(param)
		return
	end

	if id == 4001 then
		self:EnterLot()
		return
	elseif id == 4002 then
		CC.ViewManager.Open("ArenaView")
		return
	elseif id == 5007 then
		CC.ViewManager.Open("ThirdPartyView", {}, self.language)
		return
	elseif id == 5007003 and not flag then
		local nextCb = function()
			self:OnClickCard(1015, jump, true)
		end
		local conCb = function()
			self:OnClickCard(id, jump, true)
		end
		CC.ViewManager.Open("ThirdGameTipView", {nextCallback = nextCb, conCallback = conCb})
		return
	end

	if self.gameList[id] and self.gameList[id].isClick == false then
		self.gameList[id].isClick = true
		if id == 5007003 or math.floor(id / 1000) == 5002 then
			local chip = id == 5007003 and 18000 or 50000
			if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") < chip then
				CC.ViewManager.ShowTip(string.format(self.language.thirdGameTip, chip))
				self.gameList[id].isClick = false
				return
			end
			CC.HallUtil.CheckAndEnter(id, {GameId = id})
		else
			CC.HallUtil.CheckAndEnter(id)
		end
	end
end

function GameList:EnterLot()
	if self.webDataMgr.GetLotAddress() then
		CC.ViewManager.Open("LotteryView", {serverIp = self.webDataMgr.GetLotAddress()})
	else
		local data = {}
		data.GameId = 4001
		data.GroupId = 1
		CC.Request(
			"ReqAllocServer",
			data,
			function(err, data)
				CC.ViewManager.Open("LotteryView", {serverIp = data.Address})
			end,
			function(err, data)
				logError("EnterLot Fail")
			end
		)
	end
end

function GameList:GameUnlockGift(id)
	if self.gameList[id] == nil then
		return
	end
	local obj = self.gameList[id].obj
	obj:FindChild("obj/lock"):SetActive(false)
	obj:FindChild("obj/undownload"):SetActive(CC.LocalGameData.GetGameVersion(id) == 0)
end

function GameList:VipChanged(level)
	for k, v in pairs(self.gameList) do
		if level >= v.vipLimit then
			v.obj:FindChild("obj/lock"):SetActive(false)
			v.obj:FindChild("obj/undownload"):SetActive(CC.LocalGameData.GetGameVersion(k) == 0)
		end
	end
end

function GameList:DownloadProcess(data)
	local id = data.gameID
	local process = data.process
	if self.gameList[id] == nil then
		return
	end
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
			obj:FindChild("obj/state/slider/Text").text = string.format("%.1f", process * 100) .. "%"
			obj:FindChild("obj/state/slider/Slider"):GetComponent("Slider").value = process
		end
	else
		obj:FindChild("obj/icon"):SetActive(true)
		obj:FindChild("obj/undownload"):SetActive(false)
		obj:FindChild("obj/state"):SetActive(false)
		self.gameList[id].isClick = false
	end
end

function GameList:DownloadFail(id)
	if self.gameList[id] == nil then
		return
	end
	local obj = self.gameList[id].obj
	obj:FindChild("obj/icon"):SetActive(true)
	obj:FindChild("obj/undownload"):SetActive(true)
	obj:FindChild("obj/state"):SetActive(false)
	self.gameList[id].isClick = false
end

function GameList:StartUpdate()
	UpdateBeat:Add(self.Update, self)
end

function GameList:StopUpdate()
	UpdateBeat:Remove(self.Update, self)
end

function GameList:Update()
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
		for k, v in pairs(self.matchMap) do
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
						local skip, skipMatch = self:RefreshMatch(v, typeParam, k)
						if skipMatch then
							--有奖池比赛类型，当前有比赛，不需要检查后续类型比赛状态，当前比赛结束后才切换比赛类型
						else
							--无需跳过，切换下一场类型数据，供检查转态使用
							if skip then
								--当前无符合要求比赛类型，直接切换下一场
								v.curType = v.curType + 1
								if v.curType > v.count then
									v.curType = 1
								end
								v.time = self.matchSecond
								break
							else
								--有符合要求比赛类型，等待显示时间后切换
								v.curType = v.curType + 1
								if v.curType > v.count then
									v.curType = 1
								end
								break
							end
						end
					end
				end
			end
		end
	end
	--咨询自动滚动
	if self.isMove then
		self.moveTime = self.moveTime + Time.deltaTime
		if self.moveTime >= 5 then
			local curPos = self.ScrollRect:FindChild("Container").localPosition
			self.moveTime = 0
			self:RunAction(
				self.ScrollRect:FindChild("Container"),
				{
					"localMoveTo",
					curPos.x - 248,
					curPos.y,
					1,
					function()
						self.adIndex = self.adIndex + 1 > self.viewCtr.adCount and 1 or self.adIndex + 1
						self:SetIndexLight(self.adIndex)
					end
				}
			)
		end
	end

	for _, v in pairs(self.gameList) do
		if v.obj.position.x < (10000 - self.boardOffsetPosX) or v.obj.position.x > (10000 + self.boardOffsetPosX) then
			if v.node.activeSelf then
				v.node:SetActive(false)
			end
		else
			if not v.node.activeSelf then
				v.node:SetActive(true)
			end
		end
	end
end

function GameList:RefreshMatch(value, param, id)
	local obj = value.obj
	local jackpot = value.jackpot
	local index = value.curType
	local count = obj.childCount
	local showText, bMatch, physical, skip, skipMatch = self:GetCurrentShowTime(param, jackpot)
	if skip then
		return skip, skipMatch
	end
	for i = 1, count do
		if jackpot then
			if bMatch then
				if i == index then
					local Image = obj:FindChild(tostring(i) .. "/Title")
					if Image then
						if physical and CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("GameMatch") then
							obj:FindChild(tostring(i) .. "/Title/Reward"):SetActive(true)
							obj:FindChild(tostring(i) .. "/Title/Common"):SetActive(false)
						else
							obj:FindChild(tostring(i) .. "/Title/Reward"):SetActive(false)
							obj:FindChild(tostring(i) .. "/Title/Common"):SetActive(true)
						end
					end
					obj:FindChild(tostring(i) .. "/Title/Text").text = showText
					obj:FindChild(tostring(i)):SetActive(true)
				else
					obj:FindChild(tostring(i)):SetActive(false)
				end
				--obj:SetActive(true)
				--jackpot:SetActive(false)
				self:SetGameTagState(id, true)
			else
				--obj:SetActive(false)
				--jackpot:SetActive(true)
				self:SetGameTagState(id, false)
			end
		else
			self:SetGameTagState(id, true)
			if i == index then
				local Image = obj:FindChild(tostring(i) .. "/Title")
				if Image then
					if physical and CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("GameMatch") then
						obj:FindChild(tostring(i) .. "/Title/Reward"):SetActive(true)
						obj:FindChild(tostring(i) .. "/Title/Common"):SetActive(false)
					else
						obj:FindChild(tostring(i) .. "/Title/Reward"):SetActive(false)
						obj:FindChild(tostring(i) .. "/Title/Common"):SetActive(true)
					end
				end
				obj:FindChild(tostring(i) .. "/Title/Text").text = showText
				obj:FindChild(tostring(i)):SetActive(true)
			else
				obj:FindChild(tostring(i)):SetActive(false)
			end
		end
	end
	return skip, skipMatch
end

function GameList:GetCurrentShowTime(param, jackpot)
	local showText = nil
	local bMatch = false
	local physical = nil
	local skip = true
	local skipMatch = false
	local currentTime = os.time()
	local currentDay = os.date("%w", currentTime)
	if param[1].showTime then
		showText = param[1].show
	end
	for i = 1, #param do
		if param[i].weekday == -1 or param[i].weekday == tonumber(currentDay) then
			skip = false
			if jackpot then
				if currentTime >= param[i].showTime and currentTime <= param[i].endTime then
					showText = param[i].show
					bMatch = true
					skipMatch = true
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
	end
	return showText, bMatch, physical, skip, skipMatch
end

function GameList:InitGameJackpots(bState)
	for i = 1, #self.jackpotMap do
		local id = self.jackpotMap[i]
		local obj = self.gameList[id].obj
		local param = {}
		if self:JudgeJackpotState(id) then
			param.obj = self.tripleJackpotText
		else
			param.obj = obj:FindChild("obj/jackpot/01/Text")
		end
		self:UpdateGoldPool(param, id)
		if bState then
			self:RollGoldPool(param, id)
		end
	end
end

function GameList:UpdateGoldPool(param, id)
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
		param.hallGoldValue = math.ceil(self.realJackpotMap[id].cur)
		param._dstGoldValue = math.ceil(jackpotNum)
		param._delayGoldvalue = math.ceil((param._dstGoldValue - param.hallGoldValue) / self.rollSecond)
	end
end

function GameList:RollGoldPool(param, id)
	self:StartTimer(
		"RunCircle" .. id,
		0.1,
		function()
			if param.loadingOver then
				self.realJackpotMap[id].cur = self.realJackpotMap[id].cur + param._delayGoldvalue
				if self.realJackpotMap[id].cur > param._dstGoldValue then
					self.realJackpotMap[id].cur = param._dstGoldValue
				end
				param.obj.text = CC.uu.numberToStrWithComma(self.realJackpotMap[id].cur)
			end
		end,
		self.rollSecond
	)
end

--合并奖池
function GameList:JudgeJackpotState(id)
	local state = false
	for i = 1, #TripleJackpot do
		if TripleJackpot[i] == id then
			state = true
		end
	end
	return state
end

--获取合并奖池
function GameList:GetTripleJackpot()
	local count = 0
	for i = 1, #TripleJackpot do
		count = count + CC.Player.Inst():GetJackpotsNumByKey(TripleJackpot[i])
	end
	return count
end

function GameList:SetCanClick(flag)
	self._canClick = flag
end

function GameList:InitContent(count)
	if count > 1 then
		self.ScrollRect.onBeginDrag = function()
			self.isMove = false
		end
		self.ScrollRect.onEndDrag = function()
			local endPos = self.ScrollRect:FindChild("Container").localPosition
			local tolDis = endPos.x / -248
			local part = math.floor(tolDis / 0.5)
			if part % 2 == 0 then
				part = part - 1
			end
			local min = part * 0.5
			local max = min + 1
			local targetPos = nil
			local actionFun = nil
			if tolDis - min > max - tolDis then
				targetPos = -248 * max
				actionFun = function()
					self:SetIndexLight(ADMove[count][max])
				end
			else
				targetPos = -248 * min
				actionFun = function()
					self:SetIndexLight(ADMove[count][min])
				end
			end

			self:RunAction(
				self.ScrollRect:FindChild("Container"),
				{
					"localMoveTo",
					targetPos,
					endPos.y,
					0.3,
					function()
						self.moveTime = 0
						self.isMove = true
						actionFun()
					end
				}
			)
		end

		self.moveTime = 0
		self.isMove = true
		self.indexList = {}
		for i = 1, count do
			local index = CC.uu.UguiAddChild(self.indexNode, self.index, i)
			table.insert(self.indexList, index)
		end
		self:SetIndexLight(self.adIndex)
	else
		count = 1
	end
	if (self.viewCtr.HallADLoop and count <= 1) or (not self.viewCtr.HallADLoop and count > 1) then
		self.ScrollerController:ToggleLoop()
		self.viewCtr.HallADLoop = not self.viewCtr.HallADLoop
	end

	self.ScrollerController:InitScroller(count)
	self.decorate:SetActive(true)
	self:AddClick(
		"Viewport/Content/MessageBox/DecorateNode/Elephant/Button",
		function()
			self:PlayAnim()
		end
	)
	self:FindChild("Viewport/Content/MessageBox").localScale = Vector3(0, 0, 1)
	self:RunAction(self:FindChild("Viewport/Content/MessageBox"), {"scaleTo", 1, 1, 0.3, ease = CC.Action.EOutBack})
end

function GameList:PlayAnim()
	if self.ElephantPlay then
		return
	end
	self.ElephantPlay = true
	if self.spin.AnimationState then
		self.spin.AnimationState:ClearTracks()
		self.spin.AnimationState:SetAnimation(0, "stand02", false)
	end
	local AnimFun = nil
	AnimFun = function()
		self.spin.AnimationState:ClearTracks()
		self.spin.AnimationState:SetAnimation(0, "stand01", true)
		self.spin.AnimationState.Complete = self.spin.AnimationState.Complete - AnimFun
		self.ElephantPlay = false
	end
	self.spin.AnimationState.Complete = self.spin.AnimationState.Complete + AnimFun
end

function GameList:SetIndexLight(index)
	self.adIndex = index
	for i, v in ipairs(self.indexList) do
		if i == index then
			v:FindChild("On"):SetActive(true)
		else
			v:FindChild("On"):SetActive(false)
		end
	end
end

function GameList:CreateItem(tran, param)
	if param.texture then
		tran.transform:GetComponent("RawImage").texture = param.texture
		tran.transform:SetActive(true)
	else
		tran.transform:SetActive(true)
	end
	self:AddClick(
		tran,
		function()
			CC.HallUtil.ClickADEvent(param.info)
		end
	)
end

function GameList:RefreshSubscribeList()
	local NeedSubscribeList = self.gameDataMgr.GetNeedSubscribeList() --需要预约游戏
	for i, v in ipairs(NeedSubscribeList) do
		local id = tonumber(v)
		if self.gameList[id] then
			local obj = self.gameList[id].obj
			local state = CC.HallUtil.CheckShow(id)
			if state then
				obj:FindChild("obj/icon"):SetActive(false)
				obj:FindChild("obj/state"):SetActive(true)
				obj:FindChild("obj/state/soon"):SetActive(true)
				obj:FindChild("obj/undownload"):SetActive(false)
				obj:GetComponent("Button"):SetBtnEnable(false)
			else
				obj:FindChild("obj/icon"):SetActive(true)
				obj:FindChild("obj/state"):SetActive(false)
				obj:FindChild("obj/state/soon"):SetActive(false)
				obj:FindChild("obj/undownload"):SetActive(true)
				obj:GetComponent("Button"):SetBtnEnable(true)
			end
		end
	end
end

function GameList:OnDestroy()
	if self.co_InitList then
		coroutine.stop(self.co_InitList)
		self.co_InitList = nil
	end
	self:StopGameAction()
	self:StopAllAction()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
	self.ScrollerController = nil
	self:StopUpdate()
	self:StopAllTimer()
end

return GameList
