local CC = require("CC")
local AnniversaryTurntableView = CC.uu.ClassView("AnniversaryTurntableView")

function AnniversaryTurntableView:ctor(param)
	self:InitVar(param);
end

function AnniversaryTurntableView:InitVar(param)
	self.param = param or {}

	self.turntableCfg = nil

	self.awardType = nil

	self.turntableList = {}
	--存放特效节点,用于界面弹出隐藏
	self.effectList = {}

	self.language = self:GetLanguage()
	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")

	self.effectCfg = {
		{name = "defaultEffect", path = "Bg/DefaultEffect"},
		{name = "smallEffect", path = "Bg/SmallEffect"},
		{name = "bigEffect", path = "MiddlePanel/Turntable/BigEffect"},
		{name = "dragonSmallEffect", path = "MiddlePanel/Turntable/DragonSmallEffect"},
		{name = "dragonBigEffect", path = "MiddlePanel/Turntable/DragonBigEffect"},
		{name = "rewardEffect", path = "MiddlePanel/Turntable/Frame/RewardEffect"},
		{name = "rewardJPEffect", path = "MiddlePanel/Turntable/Frame/RewardJPEffect"},
		{name = "pointerSparkEffect", path = "MiddlePanel/Turntable/Pointer/Arrow/SparkEffect"},
		{name = "pointerSpreadEffect", path = "MiddlePanel/Turntable/Pointer/SpreadEffect"},
		{name = "turntableEffect", path = "MiddlePanel/Turntable/TurntableEffect"},
	}
	self.IconTab = {}
	self.curRecordPage = 1
	self.musicName = nil
	self.bigRewardHead = nil
	self.RewardHeadList = {}
	self.taskList = {}
	self.isRightViewOpen = false
end

function AnniversaryTurntableView:OnCreate()
	self:InitNode()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()

	self:InitContent()
	self:InitTextByLanguage()
	self:InitMoreSpinPanel()
	self:SetFreeCountdown()
end

function AnniversaryTurntableView:InitNode()
	--先初始化UI节点
	self.middlePanel = self:FindChild("MiddlePanel")
	self.leftPanel =  self:FindChild("LeftPanel")
	self.rightPanel =  self:FindChild("RightPanel")
	self.bottomPanel =  self:FindChild("BottomPanel")
	self.explainPanel = self:FindChild("ExplainPanel")

	self.spinMove = self.bottomPanel:FindChild("SpinMove")
	for i = 1, 3 do
		self.taskList[i] = self.leftPanel:FindChild(string.format("TaskNode/TaskItem%d", i))
		self:AddClick(self.taskList[i]:FindChild("Icon"),function()
			self:OnClickTaskItem(i)
		end)
	end
	self.pointer = self.middlePanel:FindChild("Turntable/Pointer");
	self.pointerArrow = self.pointer:FindChild("Arrow");
	self.btnOne = self.bottomPanel:FindChild("BtnOne")
	self.btnTen = self.bottomPanel:FindChild("BtnTen")
	self.btnFree = self.bottomPanel:FindChild("BtnFree")
	self.grayMat = ResMgr.LoadAsset("material", "Gray")
	self.moreSpinPanel = self:FindChild("BottomPanel/MoreSpin")

	self.recordNote = self.rightPanel:FindChild("RecordNode")
	self.btnServer = self.rightPanel:FindChild("ToggleGroup/ServerBtn")
	self.btnPerson = self.rightPanel:FindChild("ToggleGroup/PersonBtn")
	self.JbTip = self.recordNote:FindChild("ServerPanel/Tip")
	self.noRecordText = self.recordNote:FindChild("NoRecord")
	self.MainHeadNode = self.recordNote:FindChild("ServerPanel/Desc/Got/Head")
	self.rightViewMask = self.rightPanel:FindChild("RightMask")

	self.ServerScrCtrl = self.recordNote:FindChild("ServerPanel/ScrollerController"):GetComponent("ScrollerController")
	self.PersonScrCtrl = self.recordNote:FindChild("PersonPanel/ScrollerController"):GetComponent("ScrollerController")

	self.Skeleton = self.middlePanel:FindChild("Turntable/Skeleton"):GetComponent("SkeletonGraphic")
	self.Skeleton1 = self.middlePanel:FindChild("Turntable/Skeleton1"):GetComponent("SkeletonGraphic")

	self.quaternion = Quaternion();
end

function AnniversaryTurntableView:InitContent()
	self.turntableCfg = self.viewCtr.turntableCfg;
	self.awardType = self.viewCtr.awardType;
	for _,v in ipairs(self.effectCfg) do
		self.effectList[v.name] = self:FindChild(v.path);
	end
	for i,v in ipairs(self.turntableCfg) do
		local tb = self:InitTurntable(i)
		table.insert(self.turntableList,tb)
		self:RefreshTableAngle(i, v.orgDeltaAngle)--360 / #v.blockItems / 2)
	end
	self:SetBigRewards()

	self:AddClick("BottomPanel/SpinMove/ExplainBtn",function() self.explainPanel:SetActive(true) end)
	self:AddClick("ExplainPanel/CloseBtn",function() self.explainPanel:SetActive(false) end)
	self:AddClick("ExplainPanel/GoBtn",function() self.explainPanel:SetActive(false) end)
	self:AddClick("RightPanel/RecordNode/ServerPanel/Desc",function()
		self.JbTip:SetActive(true)
		self:DelayRun(4,function ()
			self.JbTip:SetActive(false)
		end)
	end)
	self:AddClick(self.JbTip:FindChild("Close"),function()
		self.JbTip:SetActive(false)
	end)

	self:AddClick("CloseBtn","ActionOut")
	self:AddClick(self.leftPanel:FindChild("Tickets/Add"), function()
		CC.ViewManager.Open("CelebrationTipView", {Stone = true})
	end)
	--抽一次
	self:AddClick(self.btnOne:FindChild("Btn"), "OnClickBtnOne")
	--onClick不受SetCanClick影响
	self.btnOne:FindChild("Skip").onClick = function ()
		self.viewCtr:ShowFinishImmediately()
	end
	self:AddClick("MiddlePanel/Turntable/Frame/Jackpot", "OnClickTurntable")

	self:AddLongClick(self.btnTen:FindChild("Btn"),
		{
			--抽多次
			funcClick = function ()
				self:OnClickBtnTen()
			end,
			--长按选择次数
			funcLongClick = function()
				self:OnLongClickBtnTen()
			end,
			time = 0.3,
		})
	self.btnTen:FindChild("Skip").onClick = function ()
		self.viewCtr:ShowFinishImmediately()
	end
	--免费抽奖
	self:AddClick(self.btnFree:FindChild("Btn"), "OnClickBtnFree")
	self.btnFree:FindChild("Skip").onClick = function ()
		self.viewCtr:ShowFinishImmediately()
	end
	--抽奖券加号
	self:AddClick("LeftPanel/Tickets","OnClickTicketsAdd")
	--分享
	self:AddClick("LeftPanel/TaskNode/TaskItem3/ShareBtn","OnClickBtnShare")
	--金牌得主
	self:AddClick("RightPanel/RecordNode/ServerPanel/GoldRecord/GoldOwnerBtn","OnClickGoldOwnerBtn")
	self:AddClick(self.rightViewMask,"ChangeRightViewStatus")
	------------------
	--抽奖记录
	UIEvent.AddToggleValueChange(self.btnServer, function(selected)
			if selected then
				self:OnChangeRecordPage(1)
				if not self.isRightViewOpen then
					self:ChangeRightViewStatus()
				end
			end
		end)
	UIEvent.AddToggleValueChange(self.btnPerson, function(selected)
			if selected then
				self:OnChangeRecordPage(2)
				if not self.isRightViewOpen then
					self:ChangeRightViewStatus()
				end
			end
		end)
	self.ServerScrCtrl:AddChangeItemListener(function(tran,dataIndex,cellIndex)
			self:RefreshServerRecordItem(tran,dataIndex)
		end)
	self.ServerScrCtrl:AddRycycleAction(function (tran)
		end)
	self.PersonScrCtrl:AddChangeItemListener(function(tran,dataIndex,cellIndex)
			self:RefreshPersonRecordItem(tran,dataIndex)
		end)
	self.PersonScrCtrl:AddRycycleAction(function (tran)
		end)
	self.btnServer:GetComponent("Toggle").isOn = true

	self:UpdateRaffleTickets(CC.Player.Inst():GetSelfInfoByKey("EPC_Props_81"))
	self:UpdateChip(CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa"))
	self:UpdateGiftVoucher(CC.Player.Inst():GetSelfInfoByKey("EPC_New_GiftVoucher"))
	self:DelayRun(0.1, function()
		self.musicName = CC.Sound.GetMusicName();
		CC.Sound.PlayHallBackMusic("turntableBg")
	end)
end

function AnniversaryTurntableView:InitTextByLanguage()
	self.btnOne:FindChild("Skip").text = self.language.btnSkip
	self.btnOne:FindChild("Draw/Num").text = "x1"
	self.btnTen:FindChild("Skip").text = self.language.btnSkip
	self.btnTen:FindChild("Draw/Num").text = "x"..self.viewCtr.totalSpinTimes
	self.btnTen:FindChild("Tips").text = self.language.longClickTips
	self.btnFree:FindChild("Draw/Text").text = self.language.btnFree
	self.btnFree:FindChild("Skip").text = self.language.btnSkip
	self.btnPerson:FindChild("Text").text = self.language.btnPerson
	self.btnPerson:FindChild("Selected/Text").text = self.language.btnPerson
	self.btnServer:FindChild("Text").text = self.language.btnServer
	self.btnServer:FindChild("Selected/Text").text = self.language.btnServer
	self.explainPanel:FindChild("GoBtn/Text").text = self.language.btnGo
	self.recordNote:FindChild("ServerPanel/Desc/None/Text1").text = self.language.serverRecordDesc1
	self.recordNote:FindChild("ServerPanel/Desc/None/Text2").text = self.language.serverRecordDesc2
	self.recordNote:FindChild("ServerPanel/Tip/Text").text = self.language.goldMedalBubble
	self.noRecordText.text = self.language.noRecord
	self:FindChild("MiddlePanel/Turntable/Frame/Jackpot/Text").text = self.language["jpStage"..self.viewCtr.nowStage]
	self.explainPanel:FindChild("Tips").text = self.language.cleanUpTip
	self.bottomPanel:FindChild("SpinMove/ExplainBtn/Text").text = self.language.explainTips
end

function AnniversaryTurntableView:InitTurntable(index)
	local tb = {}
	tb.tableNode = self:FindChild("MiddlePanel/Turntable/Frame/Tb"..index);
	tb.rollEffect = tb.tableNode:FindChild("RollEffect");
	tb.blockEffect = tb.tableNode:FindChild("BlockEffect");
	tb.arrows = {};
	tb.blocks = {};

	local tbCfg = self.turntableCfg[index]

	for i,v in ipairs(tbCfg.blockItems) do
		local awardItem = tb.tableNode:FindChild(string.format("AwardItemNode/AwardItem%s",i))

		if v.iconImg then
			local icon = awardItem:FindChild("Image")
			icon:SetActive(true)
			self:SetImage(icon,v.iconImg)
		end

		self:SetText(awardItem:FindChild("Text"),v.desc)

		if v.type == self.awardType.ARROW then
			awardItem:SetActive(false)
			local arrow = tb.tableNode:FindChild(string.format("Area%s/Arrow",i))
			arrow.interactable = false
			arrow:SetActive(true)
			table.insert(tb.arrows, arrow)
		end

		local image = tb.tableNode:FindChild(string.format("Area%s/Image", i))
		table.insert(tb.blocks, image)
	end
	return tb
end

function AnniversaryTurntableView:SetBigRewards()
	local cfg = self.viewCtr.turntableBlockCfg[13]
	local img = self.viewCtr.propCfg[cfg.PropConfigId].Icon
	local obj = self:FindChild("MiddlePanel/Turntable/Frame/Jackpot/Image")
	self:SetImage(obj,img)
	self:SetImage(obj:FindChild("sg"),img)
	self:SetImage(self.recordNote:FindChild("ServerPanel/Desc"),img)
	self:SetImage(self.recordNote:FindChild("ServerPanel/Desc/sg"),img)
	obj:GetComponent("Image"):SetNativeSize()
	obj:FindChild("sg"):GetComponent("Image"):SetNativeSize()
	self.recordNote:FindChild("ServerPanel/Desc"):GetComponent("Image"):SetNativeSize()
	self.recordNote:FindChild("ServerPanel/Desc/sg"):GetComponent("Image"):SetNativeSize()
	self:FindChild("MiddlePanel/Turntable/Frame/Jackpot/Text").text = self.propLanguage[cfg.PropConfigId]
end

function AnniversaryTurntableView:InitMoreSpinPanel()
	local selection = {100,50,30,10}
	local parent = self.moreSpinPanel
	local prefab = self.moreSpinPanel:FindChild("Item")
	for _,v in ipairs(selection) do
		local item = CC.uu.newObject(prefab,parent)
		item:FindChild("Text").text = v
		self:AddClick(item,function ()
				self:OnClickSelectTimes(v)
				self.moreSpinPanel:SetActive(false)
			end)
		item:SetActive(true)
	end
end

function AnniversaryTurntableView:GetTableAngle(tableIndex)
	local tb = self.turntableList[tableIndex]
	return tb.tableNode.transform.localEulerAngles.z
end

function AnniversaryTurntableView:RefreshTableAngle(tableIndex, zAngle)
	local tb = self.turntableList[tableIndex]
	tb.tableNode.transform.localRotation = self.quaternion:SetEuler(0, 0, zAngle);
end

function AnniversaryTurntableView:RefreshPointerArrowAngle(zAngle)
	self.pointerArrow.transform.localRotation =self.quaternion:SetEuler(0, 0, zAngle);
end

function AnniversaryTurntableView:RefreshPointerPos(layerIndex)
	local posNode = self:FindChild("MiddlePanel/Turntable/Frame/PointerPos/"..layerIndex);
	self.pointer.x, self.pointer.y = posNode.x, posNode.y;
end

function AnniversaryTurntableView:ResetBtnClick(clickType)
	if clickType == 1 then
		--点击抽1次，抽1次按钮变skip，抽10次按钮置灰
		self.btnOne:FindChild("Draw"):SetActive(false)
		self.btnOne:FindChild("Skip"):SetActive(true)
		self.btnTen:FindChild("Btn").material = self.grayMat
		self.btnTen:FindChild("Draw/Icon").material = self.grayMat
	elseif clickType == 2 then
		--点击抽10次，抽10次按钮变skip，抽1次按钮置灰
		self.btnTen:FindChild("Draw"):SetActive(false)
		self.btnTen:FindChild("Skip"):SetActive(true)
		self:SetBtnTenSkipText()
		self.btnOne:FindChild("Btn").material = self.grayMat
		self.btnOne:FindChild("Draw/Icon").material = self.grayMat
		self.btnFree:FindChild("Btn").material = self.grayMat
	elseif clickType == 3 then
		--点击免费抽奖，按钮变skip，抽10次按钮置灰
		self.btnFree:FindChild("Draw"):SetActive(false)
		self.btnFree:FindChild("Skip"):SetActive(true)
		self.btnTen:FindChild("Btn").material = self.grayMat
		self.btnTen:FindChild("Draw/Icon").material = self.grayMat
	else
		--按钮恢复（隐藏免费抽奖，显示1次和10次按钮）
		self.btnOne:FindChild("Draw"):SetActive(true)
		self.btnOne:FindChild("Skip"):SetActive(false)
		self.btnTen:FindChild("Draw"):SetActive(self.viewCtr.totalSpinTimes > 1)
		self.btnTen:FindChild("Skip"):SetActive(false)
		self.btnFree:FindChild("Draw"):SetActive(true)
		self.btnFree:FindChild("Skip"):SetActive(false)
		self.btnOne:FindChild("Btn").material = nil
		self.btnOne:FindChild("Draw/Icon").material = nil
		self.btnTen:FindChild("Btn").material = nil
		self.btnTen:FindChild("Draw/Icon").material = nil
		self.btnFree:FindChild("Btn").material = nil
		self:SetBtnFreeState()
	end
end

function AnniversaryTurntableView:SetBtnFreeState()
	self.btnFree:SetActive(self.viewCtr.freeCount > 0)
	self.btnOne:SetActive(self.viewCtr.freeCount <= 0)
end

function AnniversaryTurntableView:SetFreeCountdown()
	local serverDate = CC.TimeMgr.GetTimeInfo()
	local countdown = 86400
	if serverDate then
		countdown = 86400 - serverDate.hour*3600 - serverDate.min*60 - serverDate.sec
	end
	self.btnOne:FindChild("FreeCountdown").text = string.format(self.language.freeCountdown,CC.uu.TicketFormat(countdown))
	self:StartTimer("FreeCountdown",1,function ()
		countdown = countdown - 1
		if countdown < 0 then
			self:StopTimer("FreeCountdown")
			--三秒后再请求，防止误差
			self:DelayRun(3,function ()
				self.viewCtr:OnReqTaskList()
				self:SetFreeCountdown()
			end)
		else
			self.btnOne:FindChild("FreeCountdown").text = string.format(self.language.freeCountdown,CC.uu.TicketFormat(countdown))
		end
	end,-1)
end

function AnniversaryTurntableView:SetBtnTenSkipText()
	self.btnTen:FindChild("Skip").text = self.language.btnSkip..string.format(" %d/%d",self.viewCtr.curSpinTimes,self.viewCtr.totalSpinTimes)
end

function AnniversaryTurntableView:MovePointer(layerIndex, callback, delay)
	local delay = delay or 0;
	local posNode = self:FindChild("MiddlePanel/Turntable/Frame/PointerPos/"..layerIndex);

	self:RunAction(self.pointer,
		{
			{"delay", delay, function() CC.Sound.PlayHallEffect("turntable_pointermove"); end},
			{"localMoveTo", posNode.x, posNode.y, 0.2, ease = CC.Action.EOutBack},
			{"delay", 0, function() self:ShowPointerSpreadEffect() end},
			{"delay", 0.8, callback}
		})
end

function AnniversaryTurntableView:ShowPointerSpreadEffect()
	self.effectList["pointerSpreadEffect"]:SetActive(true);
	self:DelayRun(1, function()
			self.effectList["pointerSpreadEffect"]:SetActive(false);
		end);
end

function AnniversaryTurntableView:ShowPointerSparkEffect(flag)
	self.effectList["pointerSparkEffect"]:SetActive(flag);
end

function AnniversaryTurntableView:ShowRollEffect(tableIndex)
	local effect = self.turntableList[tableIndex].rollEffect;
	effect:SetActive(true);
	self:DelayRun(1, function()
			effect:SetActive(false);
		end);
end

function AnniversaryTurntableView:ShowRewardEffect(flag)
	local effect = self.effectList["rewardEffect"];
	effect:SetActive(true);
	self:DelayRun(1, function()
			effect:SetActive(false);
		end);
	CC.Sound.PlayHallEffect("turntableEnd");
end

function AnniversaryTurntableView:ShowJackpotRewardEffect(flag)
	self.effectList["rewardJPEffect"]:SetActive(flag);
end

function AnniversaryTurntableView:ShowBlockEffect(flag, tableIndex, blockIndex, immediately)

	local turntable = self.turntableList[tableIndex];

	turntable.blockEffect:SetActive(flag);

	if not flag then return end;

	turntable.blockEffect:SetParent(turntable.blocks[blockIndex], false);

	if not immediately then return end;

end

--显示跑马灯
function AnniversaryTurntableView:ShowMarquee(data)
	if not self.Marquee then
		self.Marquee = CC.uu.CreateHallView("Marquee",{parent = self:FindChild("MarqueeNode")})
	end
	local str = string.format(self.language["Marquee"..data.BigReward],data.Nickname,self.propLanguage[data.RewardId],data.RewardNum)
	--log("AnniversaryTurntableView Marquee:\n"..str)
	self.Marquee:Report(str)
end

--更新筹码
function AnniversaryTurntableView:UpdateChip(num)
	self:FindChild("LeftPanel/PropInfo/Chips/Num").text = CC.uu.ChipFormat(num)
end

--更新礼券
function AnniversaryTurntableView:UpdateGiftVoucher(num)
	self:FindChild("LeftPanel/PropInfo/GiftVoucher/Num").text = CC.uu.DiamondFortmat(num);
end

--更新龙鳞石
function AnniversaryTurntableView:UpdateRaffleTickets(num)
	self:FindChild("LeftPanel/Tickets/Num").text = num
end

--刷新任务列表
function AnniversaryTurntableView:RefreshTaskList(data)
	for _,v in ipairs(data) do
		local taskType = v.TaskType
		if not taskType or not self.taskList[taskType] then
			break
		end
		local obj = self.taskList[taskType]
		if taskType == 1 then
			obj:FindChild("Text").text = string.format(self.language.task1Des,CC.uu.NumberFormat(v.CompleteAmount),CC.uu.NumberFormat(v.TaskAmount))
		elseif taskType == 2 then
			obj:FindChild("Text").text = string.format(self.language.task2Des,math.floor(v.CompleteAmount/60),math.ceil(v.TaskAmount/60))
		elseif taskType == 3 then
			obj:FindChild("Text").text = self.language.task3Des
		end
		if not obj then break end
		-- self:SetImage(obj:FindChild("Icon"),"prop_img_81")
		for _,item in ipairs(v.Rewards) do
			if item.ConfigId == CC.shared_enums_pb.EPC_Props_81 then
				obj:FindChild("Num").text = "x"..item.Count
			end
		end
		if v.Status == 2 then
			obj:FindChild("Text").text = self.language.taskTomorrow
		end
		self:RefreshTaskState(obj,v.Status)
	end
end

--state:0--未完成 1--可领取（显示红点） 2--已完成（显示对勾）
function AnniversaryTurntableView:RefreshTaskState(itemObj,state)
	if not itemObj then return end
	itemObj:FindChild("Red"):SetActive(state==1)
	itemObj:FindChild("Finish"):SetActive(state==2)
	itemObj:FindChild("Num"):SetActive(state~=2)
	itemObj:FindChild("Icon"):SetActive(state~=2)
end

--刷新中奖记录
function AnniversaryTurntableView:RefreshRewardRecord(page,data)
	if self.curRecordPage ~= page then return end
	if data:HasField("TodayBigReward") then
		self.recordNote:FindChild("ServerPanel/Desc/None"):SetActive(false)
		self.recordNote:FindChild("ServerPanel/Desc/Got"):SetActive(true)
		local time = CC.uu.date2time(data.TodayBigReward.Date)
		self.recordNote:FindChild("ServerPanel/Desc/Got/Time").text = CC.uu.TimeOut4(time)
		self.recordNote:FindChild("ServerPanel/Desc/Got/Name").text = data.TodayBigReward.Nickname
		self.recordNote:FindChild("ServerPanel/Desc/Got/Text").text = self.language.goldMedalGet
		local IconData = {}
		IconData.playerId = data.TodayBigReward.PlayerId
		IconData.portrait = data.TodayBigReward.Portrait
		IconData.headFrame = data.TodayBigReward.Background
		IconData.vipLevel = data.TodayBigReward.Level
		IconData.parent = self.MainHeadNode
		self.bigRewardHead = CC.HeadManager.CreateHeadIcon(IconData);
	else
		self.recordNote:FindChild("ServerPanel/Desc/None"):SetActive(true)
		self.recordNote:FindChild("ServerPanel/Desc/Got"):SetActive(false)
		local date = CC.TimeMgr.GetTimeInfo()
		if date and date.hour and date.hour >= 20 then
			self.recordNote:FindChild("ServerPanel/Desc/None/Text2").text = self.language.probabilityUp
			self.recordNote:FindChild("ServerPanel/Desc/None/Up"):SetActive(true)
		else
			self.recordNote:FindChild("ServerPanel/Desc/None/Up"):SetActive(false)
		end
	end

	if #data.RecordList <= 0 then
		self.noRecordText:SetActive(true)
		return
	end

	local rankNum = #data.RecordList
	if page == 1 and self.recordNote:FindChild("ServerPanel").activeSelf then
		self.ServerScrCtrl:InitScroller(rankNum)
	elseif page == 2 and self.recordNote:FindChild("PersonPanel").activeSelf then
		self.PersonScrCtrl:InitScroller(rankNum)
	end
end

function AnniversaryTurntableView:RefreshServerRecordItem(trans,index)
	local dataIndex = index + 1
	local data = self.viewCtr.recordInfo[1] or {}
	if table.isEmpty(data) then return end
	local info = data.RecordList[dataIndex]
	if not info or not info:HasField("RewardId") then
		return
	end
	trans.name = dataIndex
	trans:FindChild("Text").text = string.format(self.language["serverText0"],info.Nickname,self.propLanguage[info.RewardId],info.RewardNum)
end

function AnniversaryTurntableView:RefreshPersonRecordItem(trans,index)
	local dataIndex = index + 1
	local data = self.viewCtr.recordInfo[2] or {}
	if table.isEmpty(data) then return end
	local info = data.RecordList[dataIndex]
	if not info or not info:HasField("RewardId") then
		return
	end
	trans.name = dataIndex
	local time = CC.uu.date2time(info.Date)
	trans:FindChild("Time").text = CC.uu.TimeOut3(time)
	trans:FindChild("Text").text = string.format(self.language.personalText,self.propLanguage[info.RewardId],info.RewardNum)
end

function AnniversaryTurntableView:RefreshGoldOwnerList(data)
	for _,v in ipairs(self.RewardHeadList) do
		if v then
			v:Destroy(true)
			v = nil
		end
	end
	for i,v in ipairs(data.PlayerBaseList) do
		local IconData = {}
		IconData.parent = self.recordNote:FindChild("ServerPanel/GoldRecord/GridGroup")
		IconData.playerId = v.PlayerId
		IconData.portrait = v.Portrait
		IconData.headFrame = v.Background
		IconData.vipLevel = v.Level
		local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
		table.insert(self.RewardHeadList,headIcon)
		if i >= 4 then break end
	end
end

function AnniversaryTurntableView:OnClickTaskItem(i)
	if self.viewCtr.taskInfo and self.viewCtr.taskInfo[i] and self.viewCtr.taskInfo[i].Status == 1 then
		self.viewCtr:OnReqTaskReward(i)
	else
		if i == 3 and self.viewCtr.taskInfo and self.viewCtr.taskInfo[i] and self.viewCtr.taskInfo[i].Status == 0 then
			--分享任务未完成时不显示气泡，直接分享
			self:OnClickBtnShare()
		end
	end
end

function AnniversaryTurntableView:OnClickTurntable()
	if self.viewCtr.freeCount > 0 then
		self:OnClickBtnFree()
	else
		self:OnClickBtnOne()
	end
end

function AnniversaryTurntableView:OnClickBtnOne()
	self.viewCtr:OnReqTurntableSpin(1)
	-- 测试代码
	-- local result = {Results = {{Index = 1, Level = 1, RewardId = 2, RewardNum = 2000}}}
	-- self.viewCtr:OnSpinRsp(0, result)
	-- self:SpinHideOther(true)
end

function AnniversaryTurntableView:OnClickBtnTen()
	if self.viewCtr.totalSpinTimes < 1 then
		self:OnLongClickBtnTen()
	else
		self.viewCtr:OnReqTurntableSpin(self.viewCtr.totalSpinTimes)
	end
end

function AnniversaryTurntableView:OnLongClickBtnTen()
	self.moreSpinPanel:SetActive(true)
end

function AnniversaryTurntableView:OnClickBtnFree()
	self.viewCtr:OnReqTurntableSpin(0)
end

function AnniversaryTurntableView:OnClickBtnShare()
	local param = {}
	param.shareType = CC.shared_enums_pb.ClientShareLuckyRoulette
	param.defaultUrl = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetAnniversaryShareUrl()
	param.shareCallBack = function()
		self.viewCtr:OnReqTaskList()
	end
	param.isHideImg = true
	CC.ViewManager.Open("CaptureScreenShareView",param)
end

function AnniversaryTurntableView:OnClickTicketsAdd()
	--打开引导页
	CC.ViewManager.OpenAndReplace("CelebrationView")
end

function AnniversaryTurntableView:OnClickGoldOwnerBtn()
	if not self.viewCtr.goldOwnerList then return end
	local param = {}
	param.PlayerList = self.viewCtr.goldOwnerList
	param.title = self.language.goldOwner
	CC.ViewManager.Open("GoldOwnerView",param)
end

--选择X连
function AnniversaryTurntableView:OnClickSelectTimes(times)
	if self.viewCtr.totalSpinTimes < 1 then
		self.btnTen:FindChild("Tips").localPosition = Vector2(0,-54)
		self.btnTen:FindChild("Draw"):SetActive(true)
	end
	self.viewCtr.totalSpinTimes = times
	self.btnTen:FindChild("Draw/Num").text = "x"..self.viewCtr.totalSpinTimes
end

function AnniversaryTurntableView:OnChangeRecordPage(page)
	--切换 1.全服记录 2.个人记录
	self.curRecordPage = page
	self.recordNote:FindChild("ServerPanel"):SetActive(page==1)
	self.recordNote:FindChild("PersonPanel"):SetActive(page==2)
	self.noRecordText:SetActive(false)
	if self.reqRecordTime and os.time() - self.reqRecordTime < 2 then
		self:DelayRun(2,function ()
			self.reqRecordTime = os.time()
			self.viewCtr:OnReqRewardRecord(page)
		end)
	else
		self.reqRecordTime = os.time()
		self.viewCtr:OnReqRewardRecord(page)
	end
end

function AnniversaryTurntableView:ChangeRightViewStatus()
	self.isRightViewOpen = not self.isRightViewOpen
	self.rightViewMask:SetActive(self.isRightViewOpen)
	if self.isRightViewOpen then
		self:RunAction(self.rightPanel,{"localMoveBy", -340, 0, 0.2, ease=CC.Action.EOutSine})
	else
		self:RunAction(self.rightPanel,{"localMoveBy", 340, 0, 0.2, ease=CC.Action.EOutSine})
	end
end

function AnniversaryTurntableView:ShowGotoGameView()
	if not CC.LocalGameData.GetDailyStateByKey("TodayEnterGame") then
		CC.ViewManager.Open("GameTipView", {tipType = 2})
	else
		local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("HolidayDiscountsView").switchOn
		if switchOn then
			CC.ViewManager.OpenAndReplace("DailyGiftCollectionView",{currentView="HolidayDiscountsView"})
		end
	end
end

---------------------------------
--param.items	奖励数组
--param.title	奖励弹窗标题
--param.callback	回调
--param.splitState	是否拆分
---------------------------------
function AnniversaryTurntableView:OpenRewardsView(param)
	local items = param.items
	local propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	local data = {};
	for i,v in ipairs(items) do
		if v.Delta and propCfg[v.ConfigId].IsReward and propCfg[v.ConfigId] then
			if v.Delta > 0 then
				data[i] = {}
				data[i].Crit = v.Crit;
				data[i].ConfigId = v.ConfigId;
				data[i].Count = v.Delta;
			end
		elseif v.Count and propCfg[v.ConfigId].IsReward and propCfg[v.ConfigId] then
			if v.Count > 0 then
				data[i] = {}
				data[i].Crit = v.Crit;
				data[i].ConfigId = v.ConfigId;
				data[i].Count = v.Count;
			end
		end
	end
	param.data = data
	if not table.isEmpty(data) then
		return CC.ViewManager.OpenOtherEx("AnniversaryRewardsView", param);
	end
end

function AnniversaryTurntableView:HideAllEffects()
	for _,v in pairs(self.effectList) do
		v:SetActive(false);
	end

	for _,v in pairs(self.turntableList) do
		v.rollEffect:SetActive(false);
		v.blockEffect:SetActive(false);
	end
end

function AnniversaryTurntableView:SpinHideOther(isHide)
	if isHide then
		self:RunAction(self.leftPanel, {"localMoveTo", -1000, 0, 0.3, ease = CC.Action.EOutSine});
		self:RunAction(self.rightPanel, {"localMoveBy", 100, 0, 0.3, ease = CC.Action.EOutSine});
		self:RunAction(self.spinMove, {"localMoveTo", 0, -300, 0.3, ease = CC.Action.EOutSine});
		self.Skeleton.AnimationState:ClearTracks()
		self.Skeleton.AnimationState:SetAnimation(0, "stand02", false)
		self.Skeleton1.AnimationState:ClearTracks()
		self.Skeleton1.AnimationState:SetAnimation(0, "stand02", false)

		local DragonFun = nil
		DragonFun = function ()
			self.Skeleton1.AnimationState:ClearTracks()
			self.Skeleton1.AnimationState:SetAnimation(0, "stand01", true)
			self.Skeleton.AnimationState:ClearTracks()
			self.Skeleton.AnimationState:SetAnimation(0, "stand01", true)
			self.Skeleton1.AnimationState.Complete =  self.Skeleton1.AnimationState.Complete - DragonFun
		end
		self.Skeleton1.AnimationState.Complete =  self.Skeleton1.AnimationState.Complete + DragonFun
		CC.Sound.PlayHallEffect("dragon")
	else
		self:RunAction(self.leftPanel, {"localMoveTo", -500, 0, 0.3, ease = CC.Action.EOutSine});
		self:RunAction(self.rightPanel, {"localMoveBy", -100, 0, 0.3, ease = CC.Action.EOutSine});
		self:RunAction(self.spinMove, {"localMoveTo", 0, 0, 0.3, ease = CC.Action.EOutSine});
	end
	self.effectList["smallEffect"]:SetActive(isHide)
	if self.viewCtr.spinType == 2 then
		self.effectList["bigEffect"]:SetActive(isHide)
		self.effectList["dragonBigEffect"]:SetActive(false)
		self.effectList["dragonBigEffect"]:SetActive(isHide)
	else
		self.effectList["dragonSmallEffect"]:SetActive(false)
		self.effectList["dragonSmallEffect"]:SetActive(isHide)
	end
end


function AnniversaryTurntableView:ActionIn()
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true);self.middlePanel:SetActive(true); end},
		});
	self:RunAction(self.leftPanel, {"localMoveTo", -500, 0, 0.5, ease = CC.Action.EOutSine});
	self:RunAction(self.rightPanel, {"localMoveBy", -100, 0, 0.5, ease = CC.Action.EOutSine});
	self:RunAction(self.bottomPanel, {"localMoveTo", 0, 0, 0.5, ease = CC.Action.EOutSine});
end

function AnniversaryTurntableView:ActionOut()
	self:SetCanClick(false)
	self.middlePanel:SetActive(false)
	self:RunAction(self.transform, {"fadeToAll", 0, 0.5, function() self:Destroy() end});
	self:RunAction(self.leftPanel, {"localMoveTo", -800, 0, 0.5, ease = CC.Action.EOutSine});
	self:RunAction(self.rightPanel, {"localMoveBy", 100, 0, 0.5, ease = CC.Action.EOutSine});
	self:RunAction(self.bottomPanel, {"localMoveTo", 0, -300, 0.5, ease = CC.Action.EOutSine});
end

function AnniversaryTurntableView:OnDestroy()
	self:CancelAllDelayRun()
	self:StopAllTimer()
	self:StopAllAction()

	self.Skeleton = nil
	self.Skeleton1 = nil
	if self.Marquee then
		self.Marquee:Destroy()
		self.Marquee = nil
	end

	if self.bigRewardHead then
		self.bigRewardHead:Destroy(true)
		self.bigRewardHead = nil
	end

	for _,v in ipairs(self.RewardHeadList) do
		if v then
			v:Destroy(true)
			v = nil
		end
	end

	if self.viewCtr then
		self.viewCtr:OnDestroy();
		self.viewCtr = nil;
	end

	if self.musicName then
		CC.Sound.PlayHallBackMusic(self.musicName);
	else
		CC.Sound.StopBackMusic();
	end

	if self.param.closeFunc then
		self.param.closeFunc()
	end
end


return AnniversaryTurntableView