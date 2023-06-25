---------------------------------
-- region ArenaView.lua			-
-- Date: 2019.7.18				-
-- Desc: 比赛场					-
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local ArenaView = CC.uu.ClassView("ArenaView")

function ArenaView:ctor(param)
	self.param = param

	--竞技场列表
	self.arenaList = {}

	self.changeTime = 30

	self.ScaleMin = 0.65
	self.ScaleMax = 1

	self.NodePosMin = 0
	self.NodePosMax = 45

	self.LeftPos = nil
	self.RightPos = nil

	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
	self.curPage = 1
	self.totalPage = 6
	self.matchItemList = {}
end

function ArenaView:OnCreate()
	CC.ViewManager.CloseNoticeView()
	self.language = self:GetLanguage()
	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
	self.viewCtr = self:CreateViewCtr(self.param)

	self.MidPos = self:FindChild("Scroll View/Viewport/Middle").position.x
	self.LeftPos = self:FindChild("Scroll View/Viewport/Left").position.x
	self.RightPos = self:FindChild("Scroll View/Viewport/Right").position.x

	self.scaleDis = (self.ScaleMax-self.ScaleMin)/(self.MidPos-self.LeftPos)
	self.highDis = (self.NodePosMax-self.NodePosMin)/(self.MidPos-self.LeftPos)

	self.ScrollRect = self:FindChild("Scroll View")
	self.ContentNode = self:FindChild("Scroll View/Viewport/Content")

	self.ADScrollerController = self:FindChild("ADScrollerController"):GetComponent("ScrollerController")
	self.ADScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
	xpcall(function() self.viewCtr:ADItem(tran,dataIndex,cellIndex) end,function(error) logError(error) end) end)

	self.viewCtr:OnCreate()

	self:AddClickEvent()
	self:InitTopPanel()
	self:RegisterEvent()

	self:StartUpdate()
	self:InitRoolEvent()
	self:InitHelpPanel()
	CC.ResDownloadManager.CheckDownloaderState()
	self:InitDragData()
	self:CheckGuide()

	self:DelayRun(0.1, function()
		self.musicName = CC.Sound.GetMusicName();
		CC.Sound.PlayHallBackMusic("arena");
	end)
end

function ArenaView:InitDragData()
	local width = self.ContentNode:GetComponent('RectTransform').sizeDelta.x
	self.LeftPos = -(((width - 700)/2-525))
	self.RightPos = (((width - 700)/2-525))
end

function ArenaView:CheckGuide()
	if not self.gameDataMgr.GetSingleFlag(23) then
		CC.ViewManager.Open("GuideView", {singleFlag = 23})
	end
end

function ArenaView:InitRoolEvent()
	--滚动消息相关数据
	self.speed = 2
	self.ADstartPos = nil
	self.moveTime = 0
	self.moveDistance = self:FindChild("ADItem"):GetComponent('RectTransform').sizeDelta.y
	self.moveObj = self:FindChild("AdverBG/adver_bg/Scroller/Container")
end

function ArenaView:BeginRoll()
	self:StartTimer("Roll", 5, function()
		self.isMove = true
		self.ADstartPos = self.moveObj.transform.localPosition
		self.moveTime = 0
	end,-1)
end

function ArenaView:StartUpdate()
	UpdateBeat:Add(self.Update,self);
end

function ArenaView:StopUpdate()
	UpdateBeat:Remove(self.Update,self);
end

function ArenaView:Update()
	self.changeTime = self.changeTime + Time.deltaTime
	if self.changeTime >= 5 then
		self.changeTime = 0
		local currentTimestamp = os.time()
		for k,v in pairs(self.arenaList) do
			if v.IsOpen then
				local des = v.obj.transform:FindChild("Tips/Des")
				local time = v.obj.transform:FindChild("Tips/Time")
				for i,t in ipairs(v.Tips) do
					if i == #v.Tips and currentTimestamp > t.endTime then
					    --所有比赛结束，该游戏比赛场刷新时间戳
						self:RefreshTimestamp(k)
					end
					if i >= v.TimeIndex and currentTimestamp < t.startTime then
						des.text = t.des
						time.text = t.showTime
						v.TimeIndex = v.TimeIndex + 1
						if v.TimeIndex > #v.Tips then
							v.TimeIndex = 1
						end
						break
					elseif currentTimestamp >= t.startTime and currentTimestamp <= t.endTime then
						des.text = t.des
						time.text = self.language.matching
						break
					end
				end
			end
		end
	end

	if self.isMove then
		self.moveTime = self.moveTime + (Time.deltaTime * self.speed)
		if self.moveTime >= 1 then
			self.moveTime = 1
			self.isMove = false
		end
		local curPos = Mathf.Lerp(self.ADstartPos.y,self.ADstartPos.y+self.moveDistance,self.moveTime)
		self.moveObj.localPosition = Vector3(self.moveObj.localPosition.x,curPos,self.moveObj.localPosition.z)
	end


	------滑动效果
	for i = 1, self.ContentNode.childCount do
		local obj = self.ContentNode:GetChild(i-1)
		local dis = math.abs(obj.position.x - self.MidPos)
		obj.localScale = Vector3(1-dis*self.scaleDis,1-dis*self.scaleDis,1-dis*self.scaleDis)
		obj:FindChild("Node").localPosition = Vector3(0,dis*self.highDis,0)
	end
end

function ArenaView:DragEndEvent()
	local moveDis = 0
	if self.startPos.x > self.ContentNode.localPosition.x then
		self.moveLeft = false
		moveDis = self.startPos.x - self.ContentNode.localPosition.x
	else
		self.moveLeft = true
		moveDis = self.ContentNode.localPosition.x - self.startPos.x
	end
	local MoveNum = math.floor((moveDis) / 350 + 0.5)
	if not self.moveLeft then
		MoveNum = -MoveNum
	end
	local targetPos = self.startPos.x + MoveNum * 350
	if targetPos > self.RightPos then
		targetPos = self.RightPos
	elseif targetPos < self.LeftPos then
		targetPos = self.LeftPos
	end
	self:RunAction(self.ContentNode, {"localMoveTo",targetPos,self.ContentNode.localPosition.y, 0.2});
end

function ArenaView:AddClickEvent()
	self.ScrollRect.onBeginDrag = function ()
		self.startPos = self.ContentNode.localPosition
	end
	self.ScrollRect.onEndDrag = function ()
		self:DragEndEvent()
	end
	--关闭界面
	self:AddClick("TopPanel/BtnBG/BtnBack",function ()
		if self.musicName then
			CC.Sound.PlayHallBackMusic(self.musicName);
		else
			CC.Sound.StopBackMusic();
		end
		if self.param and self.param.closeFunc then
			self.param.closeFunc()
		end
		self:Destroy()
	end)
	self:AddClick("BtnHelp",function ()
		self:FindChild("HelpPlane"):SetActive(true)
	end)
	self:FindChild("BtnHelp"):SetActive(false)
	self:AddClick("HelpPlane/BtnClose",function ()
		self:FindChild("HelpPlane"):SetActive(false)
	end)
	self:AddClick("HelpPlane/leftBtn", function()
        self:OnNextPage(false)
    end)
	self:AddClick("HelpPlane/rightBtn", function()
        self:OnNextPage(true)
    end)
end

function ArenaView:InitHelpPanel()
	self:FindChild("HelpPlane/Title/Text").text = self.language.helpTitle
	self.matchPrefab = self:FindChild("HelpPlane/matchItem")
	self.content = self:FindChild("HelpPlane/ScrollView/Viewport/Content")
	self.content:FindChild("Title/1/Text").text = self.language.gameName
	self.content:FindChild("Title/2/Text").text = self.language.gameTime
	self.content:FindChild("Title/3/Text").text = self.language.gameType
	self.content:FindChild("Title/4/Text").text = self.language.gameAward
	local time = CC.TimeMgr.GetTimeInfo()
	if time.month == 1 then
		--1月份
		self.curPage = 1
	elseif time.month == 2 then
		--2月份
		if time.day < 7 then
			self.curPage = 2
		elseif time.day < 14 then
			self.curPage = 3
		else
			self.curPage = self.totalPage
		end
	end
	--比赛类型
	self.gameTypeList = {3,3,1,3,2,3,1,3,3,3}
	for i = 1, 10 do
		local matchItem = CC.uu.newObject(self.matchPrefab, self.content)
		self.matchItemList[i] = matchItem
		matchItem:SetActive(true)
	end
	self:OnReflashTime()
end

function ArenaView:OnReflashTime()
	local rewardNum = 1
	local matchType = self.language.gameMatchMonth
	if self.curPage ~= 1 then
		rewardNum = 3
		matchType = self.language.gameMatchWeek
	end
	for i = 1, 10 do
		local index = i
		self.matchItemList[i]:FindChild("1/Text").text = self.language.gameNameList[index]
		self.matchItemList[i]:FindChild("2/Text").text = self.language.gameTimeList[self.curPage][index]
		self.matchItemList[i]:FindChild("3/Text").text = string.format("%s\n%s", matchType, self.language.gameMatchType[self.gameTypeList[index]])
		for j = 1, 3 do
			self.matchItemList[i]:FindChild(string.format("4/PropList/Prop%s", j)):SetActive(false)
		end
		for k = 1, rewardNum do
			local propId = self.language.RewardConfig[self.curPage][index][k]
			local sprite = self.PropDataMgr.GetIcon(propId)
			self:SetImage(self.matchItemList[i]:FindChild(string.format("4/PropList/Prop%s", k)), sprite,true)
			self.matchItemList[i]:FindChild(string.format("4/PropList/Prop%s/Text", k)).text = self.propLanguage[propId]
			--self.matchItemList[i]:FindChild(string.format("4/PropList/Prop%s", k)):GetComponent("Image"):SetNativeSize()
			self.matchItemList[i]:FindChild(string.format("4/PropList/Prop%s", k)):SetActive(true)
		end
	end
	self:FindChild("HelpPlane/pageText").text = string.format("%s/%s", self.curPage,self.totalPage)
end

--下一页
function ArenaView:OnNextPage(isNext)
	if isNext then
		self.curPage = self.curPage + 1 > self.totalPage and 1 or self.curPage + 1
	else
		self.curPage = self.curPage - 1 < 1 and self.totalPage or self.curPage - 1
	end
	self:OnReflashTime()
end

function ArenaView:InitTopPanel()
	local headNode = self:FindChild("TopPanel/HeadNode");
	self.HeadIcon = CC.HeadManager.CreateHeadIcon({parent = headNode});

	local diamondNode = self:FindChild("TopPanel/NodeMgr/DiamondNode");
	self.diamondCounter = CC.HeadManager.CreateDiamondCounter({parent = diamondNode, hideBtnAdd = false});

	local chipNode = self:FindChild("TopPanel/NodeMgr/ChipNode");
	self.chipCounter = CC.HeadManager.CreateChipCounter({parent = chipNode, hideBtnAdd = false});

	local VipNode = self:FindChild("TopPanel/NodeMgr/VipNode");
	self.VIPCounter = CC.HeadManager.CreateVIPCounter({parent = VipNode, tipsParent = self:FindChild("TopPanel/VIPTipsNode")});

	local integralNode = self:FindChild("TopPanel/NodeMgr/IntegralBG")
	self.integralCounter = CC.HeadManager.CreateIntegralCounter({parent = integralNode,hideBtnAdd = false})
end

function ArenaView:InitCards(param)
	if #param > 0 then
		for i = 1, #param do
			self:CreateCardItem(param[i])
		end
	end
	if self.ContentNode.childCount % 2 == 0 then
		self.ContentNode.localPosition = Vector3(-175,0,0)
	else
		self.ContentNode.localPosition.x = Vector3.zero
	end
end

function ArenaView:InitAD(count)
	if count == 0 then
		count = 1
	end
	self.ADScrollerController:InitScroller(count)
	if count > 1 then
		self:BeginRoll()
	end
end

function ArenaView:CreateCardItem(id)
	--竞技场相关信息
	local info = self.viewCtr.gameDataMgr.GetArenaInfoByID(id)

	if not info then return end

	local name = "Arena_"..id

	local tran = CC.uu.LoadHallPrefab("prefab", name, self.ContentNode);

	self.arenaList[id] = {}
	self.arenaList[id].obj = tran
	self.arenaList[id].IsOpen = info.IsOpen
	self.arenaList[id].TimeIndex = 1
	self.arenaList[id].IsClick = false

	if info.IsOpen then
		self:SetCardState(self.arenaList[id].obj,id,info)
	else
		tran.transform:FindChild("Node/icon"):SetActive(false)
		tran.transform:FindChild("Tips"):SetActive(false)
		tran.transform:FindChild("Node/state"):SetActive(true)
		tran.transform:FindChild("Node/state/soon"):SetActive(true)
	end
end

function ArenaView:CreateADItem(tran,param)
	if param.texture then
		tran:GetComponent("RawImage").texture = param.texture
	end
	tran.transform.onClick = function ()
		self:InitClickEvent(param.info)
	end
end

function ArenaView:InitClickEvent(param)
	local language = CC.LanguageManager.GetLanguage("L_PopupView");
	if param.MessageUseType == "1" then
	    --购买验证
		local wareCfg = self.viewCtr.wareCfg[param.ExtensionID];
		local data = {}
		data.wareId = wareCfg.Id
		data.subChannel = wareCfg.SubChannel
		data.price = wareCfg.Price
		data.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
		if param.ExtensionID == CC.PaymentManager.GetActiveWareIdByKey("buyu") then
			data.errCallback = function (err)
				if err == CC.shared_en_pb.WareAlreadyPurchased then
					CC.ViewManager.ShowTip(language.WareAlreadyPurchased)
				end
			end
		end
		CC.PaymentManager.RequestPay(data)
	elseif param.MessageUseType == "2" then
	--新游跳转
		local id = tonumber(param.ExtensionID)
		CC.HallUtil.CheckAndEnter(id)
	elseif param.MessageUseType == "3" then
	    --功能跳转
		CC.ViewManager.Open(param.ExtensionID)
	elseif param.MessageUseType == "5" then
	    --打开facebook外链
		Client.OpenURL(param.ExtensionID)
	elseif param.MessageUseType == "7" then
		CC.ViewManager.Open(param.ExtensionID, {currentView = param.CurrentView})
	else
	--无处理
	end
end

function ArenaView:SetCardState(tran,id,param)
	local tipsInfo = param.CompetitionInfo

	self.arenaList[id].Tips = {}
	for i,v in ipairs(tipsInfo) do
		local CompetitionInfo = {}
		local weekday = self.language[tipsInfo[i].WeekDay]
		-- local showTime = tipsInfo[i].StartTime
		local startTime = tipsInfo[i].StartTime
		local endTime = tipsInfo[i].EndTime
		CompetitionInfo.startTime = self:GetTimestamp(startTime)
		CompetitionInfo.endTime = self:GetTimestamp(endTime)
		CompetitionInfo.des = tipsInfo[i].Des
		CompetitionInfo.showTime = weekday.." "..startTime.." - "..endTime
		table.insert(self.arenaList[id].Tips,CompetitionInfo)
	end

	self:AddClick(tran.transform,function ()
		self:OnClickCard(id)
	end)
end

function ArenaView:OnClickCard(id)
	if not self.arenaList[id].IsClick then
		self.arenaList[id].IsClick = false
		local param = {}
		param.isMatch = true
		param.gameData = self.gameDataMgr.GetInfoByID(id)
		CC.HallUtil.CheckAndEnter(id,param)
	end
end

function ArenaView:GetTimestamp(Time)
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

function ArenaView:RefreshTimestamp(id)
	if self.arenaList[id].IsOpen then
		for i,t in ipairs(self.arenaList[id].Tips) do
			t.startTime = t.startTime + 86400
			t.endTime = t.endTime + 86400
		end
	end
end

function ArenaView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.DownloadProcess,CC.Notifications.DownloadGame)
	CC.HallNotificationCenter.inst():register(self,self.DownloadFail,CC.Notifications.DownloadFail)
	CC.HallNotificationCenter.inst():register(self,self.SetClickState,CC.Notifications.GameClickState)
end

function ArenaView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadGame)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadFail)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.GameClickState)
end

function ArenaView:DownloadProcess(data)
	local id = data.gameID
	local process = data.process
	if self.arenaList[id] == nil or not self.arenaList[id].IsOpen then return end
	if process < 1 then
		if process == 0 then
			self.arenaList[id].IsClick = true
			self.arenaList[id].obj.transform:FindChild("Node/icon"):SetActive(false)
			self.arenaList[id].obj.transform:FindChild("Node/state"):SetActive(true)
			self.arenaList[id].obj.transform:FindChild("Node/state/down"):SetActive(true)
			self.arenaList[id].obj.transform:FindChild("Node/state/down/Text").text = self.language.download_tip
			self.arenaList[id].obj.transform:FindChild("Node/state/down/Slider"):GetComponent("Slider").value = process
		else
			self.arenaList[id].IsClick = true
			self.arenaList[id].obj.transform:FindChild("Node/icon"):SetActive(false)
			self.arenaList[id].obj.transform:FindChild("Node/state"):SetActive(true)
			self.arenaList[id].obj.transform:FindChild("Node/state/down"):SetActive(true)
			self.arenaList[id].obj.transform:FindChild("Node/state/down/Text").text = string.format("%.1f",process * 100) .. "%"
			self.arenaList[id].obj.transform:FindChild("Node/state/down/Slider"):GetComponent("Slider").value = process
		end
	else
		self.arenaList[id].obj.transform:FindChild("Node/icon"):SetActive(true)
		self.arenaList[id].obj.transform:FindChild("Node/state"):SetActive(false)
		self.arenaList[id].IsClick = false
	end
end

function ArenaView:DownloadFail(id)
	if self.arenaList[id] == nil or not self.arenaList[id].IsOpen then return end
	self.arenaList[id].obj.transform:FindChild("Node/icon"):SetActive(true)
	self.arenaList[id].obj.transform:FindChild("Node/state"):SetActive(false)
	self.arenaList[id].IsClick = false
end

function ArenaView:SetClickState(param)
	local id = param.id
	local state = param.state
	if self.arenaList[id] then
		self.arenaList[id].IsClick = state
	end
end

function ArenaView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end

	if self.HeadIcon then
		self.HeadIcon:Destroy();
		self.HeadIcon = nil;
	end

	if self.chipCounter then
		self.chipCounter:Destroy();
		self.chipCounter = nil;
	end

	if self.diamondCounter then
		self.diamondCounter:Destroy();
		self.diamondCounter = nil;
	end

	if self.VIPCounter then
		self.VIPCounter:Destroy();
		self.VIPCounter = nil;
	end

	if self.integralCounter then
		self.integralCounter:Destroy()
		self.integralCounter = nil
	end
	self:StopAllTimer()
	self:StopUpdate()
	self:unRegisterEvent()
end

function ArenaView:ActionIn()
end

return ArenaView