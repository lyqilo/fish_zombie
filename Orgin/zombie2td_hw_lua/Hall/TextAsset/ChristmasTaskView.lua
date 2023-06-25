local CC = require("CC")
local ChristmasTaskView = CC.uu.ClassView("ChristmasTaskView")

function ChristmasTaskView:ctor(param)
    self.param = param;
	self.language = self:GetLanguage()
	self.createTime = os.time()+math.random()
    self.musicName = nil
    self.PrefabTask = {}
	self.PrefabInfo = {}
	self.PrefabGoods = {}
	self.IconTab = {}
	self.christmasTreeLight = {}
	self.bangerList = {}
	self.roleList = {}
	self.numberRoller = nil
	self.clickNum = 0
end

function ChristmasTaskView:OnCreate()
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitUI()
end

function ChristmasTaskView:InitUI()
	--大奖名单
    self.JPAwardPanel = self:FindChild("JPAwardPanel")
    self:AddClick(self.JPAwardPanel:FindChild("BtnJP"), function ()
        self:OnAwardClick(true, true)
	end)
    self:AddClick(self.JPAwardPanel:FindChild("BtnAward"), function ()
        self:OnAwardClick(true, false)
	end)
    self:AddClick(self.JPAwardPanel:FindChild("bg"), function ()
        self:OnAwardClick(false, false)
	end)
	self.Info_Content = self.JPAwardPanel:FindChild("AwardView/Scroller/Viewport/Content")
    self.Info_Item = self.JPAwardPanel:FindChild("AwardView/Scroller/Viewport/Item")

    self.ContentTask = self:FindChild("ChristmasTask/TaskScr/Viewport/Content")
	self.ItemTask = self:FindChild("ChristmasTask/TaskScr/Viewport/Content/ItemTask")
	self.ContentGoods = self:FindChild("ChristmasTask/GoodsScr")
	self.GoodsItem = self:FindChild("ChristmasTask/GoodsScr/Goods")

	self.timeText = self:FindChild("ChristmasTask/Time")

	-- for i = 1, 14 do
	-- 	local index = i
	-- 	if i == 3 or i == 6 or i == 9 or i == 12 or i == 14 then
	-- 		self.christmasTreeLight[i] = self:FindChild(string.format("ChristmasTree/LightEffect/dj%s", index))
	-- 	else
	-- 		self.christmasTreeLight[i] = self:FindChild(string.format("ChristmasTree/%s", index))
	-- 	end
	-- end
	self.bangerList[1] = self:FindChild("SpecialSpin/Tip/Special/general")
	self.bangerList[3] = self:FindChild(string.format("SpecialSpin/Tip/Special/%s", 3))
	self.bangerList[6] = self:FindChild(string.format("SpecialSpin/Tip/Special/%s", 6))
	self.bangerList[9] = self:FindChild(string.format("SpecialSpin/Tip/Special/%s", 9))
	self.bangerList[12] = self:FindChild(string.format("SpecialSpin/Tip/Special/%s", 12))
	self.bangerList[14] = self:FindChild(string.format("SpecialSpin/Tip/Special/%s", 14))
	for i = 1, 3 do
		local index = i
		self.roleList[index] = self:FindChild(string.format("SpecialSpin/Role/%s", index))
	end

	self:AddClick(self:FindChild("ChristmasTask/BtnLighten"), function()
        self.viewCtr:ReqChristTaskReward()
	end)
	self:AddClick(self:FindChild("BtnCrystalStore"), function()
		CC.ViewManager.Open("CrystalStoreView")
	end)
	self:AddClick(self:FindChild("BtnRule"), function()
		self:FindChild("ExplainView"):SetActive(true)
    end)
	self:AddClick(self:FindChild("ExplainView/Frame/BtnClose"), function()
		self:FindChild("ExplainView"):SetActive(false)
	end)
	self:AddClick(self:FindChild("Rewards"), function()
		self:FindChild("Rewards"):SetActive(false)
	end)
	self:AddClick(self:FindChild("Rewards/BtnShare"), function()
		local param = {}
		param.isShowPlayerInfo = true
        CC.ViewManager.Open("CaptureScreenShareView", param)
	end)
	self:AddClick(self:FindChild("SpecialSpin/RoleBtn"), function()
		self:RoleBtnClick()
	end)

    self:LanguageSwitch()
	self:UpdataJp()
	self.viewCtr:ReqChristTaskInfo()
	self.viewCtr:ReqChristTaskRecord()
    -- self:DelayRun(0.1, function()
	-- 	self.musicName = CC.Sound.GetMusicName();
	-- 	CC.Sound.PlayHallBackMusic("ChristmasTaskBg");
	-- end)
end

--语言切换
function ChristmasTaskView:LanguageSwitch()
	self:FindChild("ChristmasTask/Time").text = self.language.activityTime .. "22/4/2021"
	self:FindChild("ChristmasTask/AcquireText").text = self.language.AcquireText
	self:FindChild("ChristmasTask/BtnLighten/Text").text = self.language.btnLighten
	self:FindChild("ChristmasTask/TaskScr/Viewport/Content/ItemTask/GoBtn/Text").text = self.language.btnGo
	self:FindChild("ChristmasTask/TaskScr/Viewport/Content/ItemTask/GrayBtn/Text").text = self.language.btnGo
	self:FindChild("ChristmasTask/Jackpot/Text").text = self.language.JP
	self:FindChild("ChristmasTask/Jackpot/Text1").text = self.language.chance;
	-- self:FindChild("ChristmasTree/LightenNum").text = self.language.remainLighten
	self.JPAwardPanel:FindChild("BtnJP/Text").text = self.language.btnJP;
	self.JPAwardPanel:FindChild("BtnAward/Text").text = self.language.btnAward;
	self.JPAwardPanel:FindChild("AwardView/Image/Name").text = self.language.roleName;
	self.JPAwardPanel:FindChild("AwardView/Image/Info").text = self.language.winInfo;
	--self:FindChild("SpecialSpin/HpText").text = self.language.hpText
	self:FindChild("ChristmasTask/desText").text = self.language.desText
	self:FindChild("ExplainView/Frame/Title").text = self.language.title
	self:FindChild("ExplainView/Frame/Text").text = self.language.rule
	self:FindChild("ExplainView/Frame/Text1").text = self.language.rule1
	self:FindChild("ExplainView/Frame/Text2").text = self.language.rule2
	self:FindChild("ExplainView/Frame/Text3").text = self.language.rule3
	local JPList = {"80%","50%","30%","20%","10%"}
	for i=1,5 do
		local item = self:FindChild("JPAwardPanel/JPView/Content/Item"..i)
		item:FindChild("Nick").text = self.language.JP
		item:FindChild("Num").text = JPList[i]
	end
	self:FindChild("Rewards/BtnShare/Text").text = self.language.btnShare
end

--点击人物
function ChristmasTaskView:RoleBtnClick()
	local curTask = self.viewCtr.curTaskId
	local index = self.viewCtr.roleList[curTask].role
	local animSpin = self.roleList[index]:GetComponent("SkeletonAnimation")
	animSpin.AnimationState:ClearTracks()
	animSpin.AnimationState:SetAnimation(0, "hit", false)
	animSpin.AnimationState.Complete = animSpin.AnimationState.Complete + function()
		animSpin.AnimationState:SetAnimation(0, "stand", true)
	end
	self.clickNum = self.clickNum + 1
	CC.Sound.PlayHallEffect(string.format("JPM_voice_click%s", self.clickNum % 3 + 1))
end

function ChristmasTaskView:UpdataJp()
	self.viewCtr:ReqChristTaskJP()
	local countDown = 8
	self:StartTimer("countDown"..self.createTime, 1, function ()
		countDown = countDown - 1
		if countDown < 0 then
			countDown = 8
			self.viewCtr:ReqChristTaskJP()
		end
	end,-1)
end

--初始化任务列表
function ChristmasTaskView:InitTaskInfo(data)
	local list = data.CurTasks
	for _,v in pairs(self.PrefabTask) do
		v.transform:SetActive(false)
	end
	for i = 1,#list do
		self:AddItemData(i, list[i])
	end
	self:SetGoodInfo(data.ChainProgress)
	--self:SetChristmasTreeShow(data)
	self:SetMonsterNian(data)
end

function ChristmasTaskView:AddItemData(index, data)
	local item = nil
	if self.PrefabTask[index] == nil then
		item = CC.uu.newObject(self.ItemTask)
		item.transform.name = tostring(index)
		self.PrefabTask[index] = item.transform
	else
		item = self.PrefabTask[index]
	end
	item:SetActive(true)
	if item then
		item.transform:SetParent(self.ContentTask, false)
        --log(CC.uu.Dump(data, "data",10))
        if data.TaskItemType then
            local progress = data.ItemProgress
            local itemTarget = data.ItemTarget
            if data.TaskItemType == CC.shared_enums_pb.TaskITE_OnlineTime then
                --在线时长任务
                -- progress = math.floor(data.ItemProgress / 3600)
				-- itemTarget = math.floor(data.ItemTarget / 3600)
				item:FindChild("name").text = string.format(self.language.task1, math.floor(itemTarget / 60))
                progress = (progress >= itemTarget and 1) or 0
				itemTarget = 1
			else
				item:FindChild("name").text = self.language[string.format("task%s", data.TaskItemType)]
			end
			progress = (progress >= itemTarget and itemTarget) or progress
            if progress >= itemTarget then
                item:FindChild("GoBtn"):SetActive(false)
                item:FindChild("GrayBtn"):SetActive(false)
                item:FindChild("fulfill"):SetActive(true)
            else
                item:FindChild("fulfill"):SetActive(false)
                local isJump = false
                if data.TaskItemType == CC.shared_enums_pb.TaskITE_Match and CC.ViewManager.IsHallScene() then
                    --比赛
                    isJump = true
                end
                if data.TaskItemType == CC.shared_enums_pb.TaskITE_ShareChrist or data.TaskItemType == CC.shared_enums_pb.TaskITE_SeckillGift then
                    --分享和秒杀礼包
                    isJump = true
                end
                item:FindChild("GoBtn"):SetActive(isJump)
                item:FindChild("GrayBtn"):SetActive(not isJump)
                self:AddClick(item:FindChild("GoBtn"), function( )
                    self:ByTaskIdJump(data.TaskItemType)
                end)
			end
			if data.TaskItemType == CC.shared_enums_pb.TaskITE_SumWin then
				if progress > 1000 then
					progress = math.floor(progress / 1000) .. "K"
				end
				if itemTarget > 1000 then
					itemTarget = math.floor(itemTarget / 1000) .. "K"
				end
			end
			item:FindChild("num").text = progress .."/".. itemTarget
        end
	end
end

--跳转
function ChristmasTaskView:ByTaskIdJump(taskType)
	if taskType == CC.shared_enums_pb.TaskITE_ShareChrist then
		local param = {}
		param.isShowPlayerInfo = true
		param.shareType = CC.shared_enums_pb.ClientShareChrist
		--param.webText = self.language.share_content
		CC.ViewManager.Open("CaptureScreenShareView", param)
		--方便测试分享
		-- CC.Request("ReqOnClientShare", {ShareType = CC.shared_enums_pb.ClientShareChrist})
	elseif taskType == CC.shared_enums_pb.TaskITE_Match then
		--比赛
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, false)
		local fun = function()
			CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, true)
		end
		CC.ViewManager.Open("ArenaView", {closeFunc = fun})
	elseif taskType == CC.shared_enums_pb.TaskITE_SeckillGift then
		CC.ViewManager.OpenAndReplace("SelectGiftCollectionView",{currentView = "ElkLimitGiftView"})
	end
	--self:CloseView()
end

function ChristmasTaskView:SetGoodInfo(TaskIndex)
	self.roleList[1]:SetActive(TaskIndex < 4)
	self.roleList[2]:SetActive(TaskIndex > 3 and TaskIndex < 10)
	self.roleList[3]:SetActive(TaskIndex > 9)
	local list = self.viewCtr.rewardTab[TaskIndex]
	if not list then return end
	for _,v in pairs(self.PrefabGoods) do
		v.transform:SetActive(false)
	end
	for i = 1,#list do
		self:AddGoodItem(i, list[i])
	end
	if self.viewCtr.JpRatio[TaskIndex] then
		self:FindChild("ChristmasTask/Jackpot"):SetActive(true)
		self:FindChild("ChristmasTask/Jackpot/Num").text = self.viewCtr.JpRatio[TaskIndex]
		-- self:FindChild("ChristmasTask/BtnLighten/Image"):SetActive(false)
		-- self:FindChild("ChristmasTask/BtnLighten/Special"):SetActive(true)
		-- for k, _ in pairs(self.viewCtr.JpRatio) do
		-- 	self:FindChild(string.format("ChristmasTask/BtnLighten/Special/%s", k)):SetActive(TaskIndex == k)
		-- end
	else
		self:FindChild("ChristmasTask/Jackpot"):SetActive(false)
		-- self:FindChild("ChristmasTask/BtnLighten/Image"):SetActive(true)
		-- self:FindChild("ChristmasTask/BtnLighten/Special"):SetActive(false)
	end
end

function ChristmasTaskView:AddGoodItem(index, info)
	local item = nil
	if self.PrefabGoods[index] == nil then
		item = CC.uu.newObject(self.GoodsItem)
		item.transform.name = tostring(index)
		self.PrefabGoods[index] = item.transform
	else
		item = self.PrefabGoods[index]
	end
	if item then
		item:SetActive(true)
		item.transform:SetParent(self.ContentGoods, false)
		self:SetImage(item:FindChild("icon"), self.propCfg[info.ConfigId].Icon)
		if info.ConfigId == CC.shared_enums_pb.EPC_Crystal then
			item:FindChild("num").text = self.language.chance
		elseif info.Count < 0 then
			item:FindChild("num").text = ""
		else
			item:FindChild("num").text = info.Count
		end
	end
end

--设置圣诞树展示
function ChristmasTaskView:SetChristmasTreeShow(data)
	local taskIndex = data.ChainProgress
	self:FindChild("ChristmasTree/LightenNum/Num").text = data.IsDone and data.ChainTarget - taskIndex or data.ChainTarget - taskIndex + 1
	if taskIndex > #self.christmasTreeLight then return end
	for i = 1, #self.christmasTreeLight do
		local index = i
		if index == taskIndex then
			self.christmasTreeLight[i]:FindChild("Light"):SetActive(data.IsDone)
			self.christmasTreeLight[i]:FindChild("Dark"):SetActive(not data.IsDone)
		else
			self.christmasTreeLight[i]:FindChild("Light"):SetActive(index < taskIndex)
			self.christmasTreeLight[i]:FindChild("Dark"):SetActive(index > taskIndex)
		end
	end
	if taskIndex == data.ChainTarget and data.IsDone then
		self:FindChild("ChristmasTask/BtnLighten/Text").text = self.language.btnFinish
		self:FindChild("ChristmasTask/BtnLighten/Image"):SetActive(false)
		self:FindChild("ChristmasTask/BtnLighten/Special"):SetActive(false)
	end
end

--设置展示
function ChristmasTaskView:SetMonsterNian(data)
	local taskIndex = data.ChainProgress
	local num = data.IsDone and data.ChainTarget - taskIndex or data.ChainTarget - taskIndex + 1
	self:FindChild("SpecialSpin/Num").text = string.format(self.language.remainNum, num)
	if taskIndex == data.ChainTarget and data.IsDone then
		self:FindChild("ChristmasTask/BtnLighten/Text").text = self.language.btnFinish
		self:FindChild("SpecialSpin/Tip/Text").text = self.language.finishText
	else
		if self.viewCtr.roleList[taskIndex].jpNum then
			self:FindChild("SpecialSpin/Tip/Text").text = string.format(self.language.TipText, self.viewCtr.roleList[taskIndex].jpNum)
		end
	end
	for _, v in pairs(self.bangerList) do
		v:SetActive(false)
	end
	if self.bangerList[taskIndex] then
		self.bangerList[taskIndex]:SetActive(true)
	else
		self.bangerList[1]:SetActive(true)
	end

	local totalHp = 0
	local loseHp = 0
	for i = 1, #self.viewCtr.roleList do
		totalHp = totalHp + self.viewCtr.roleList[i].hp
		if taskIndex > i or (taskIndex == i and data.IsDone) then
			loseHp = loseHp + self.viewCtr.roleList[i].hp
		end
	end
	self:FindChild("SpecialSpin/Slider"):GetComponent("Slider").value = (totalHp - loseHp) / totalHp
	if num <= 0 then
		self:FindChild("SpecialSpin/Num"):SetActive(false)
		self:FindChild("SpecialSpin/Slider"):SetActive(false)
	end
end

--设置JP数
function ChristmasTaskView:SetJpNum(num)
	self:FindChild("SpecialSpin/JPSum").text = num
	self:FindChild("JPAwardPanel/JPView/Image/JPSum").text = num
end

--奖励
function ChristmasTaskView:RewardGold(count)
	self:FindChild("Rewards"):SetActive(true)
	local param = {
		parent = self:FindChild("Rewards/Count"),
		number = count,
		callback = function()
			self:FindChild("Rewards/BtnShare"):SetActive(true)
		end
	}
	if self.numberRoller then
		self.numberRoller:Destroy()
		self.numberRoller = nil
	end
	CC.Sound.PlayHallEffect("gs_reward")
	self.numberRoller = CC.ViewCenter.NumberRoller.new();
	self.numberRoller:Create(param);
end

--jp或中奖名单显示
function ChristmasTaskView:OnAwardClick(Show, IsShowJP)
    self.JPAwardPanel:FindChild("bg"):SetActive(Show)
	self.JPAwardPanel:FindChild("JPView/Image/bg"):SetActive(Show)
	self.JPAwardPanel:FindChild("AwardView/Image/bg"):SetActive(Show)
    self.JPAwardPanel:FindChild("JPView"):SetActive(IsShowJP)
    self.JPAwardPanel:FindChild("AwardView"):SetActive(not IsShowJP)
    local movePosX = Show and -326 or 0
    self.JPAwardPanel:FindChild("BtnJP").localPosition = Vector3(610 + movePosX, 108, 0)
    self.JPAwardPanel:FindChild("BtnAward").localPosition = Vector3(610 + movePosX, -84, 0)
    self.JPAwardPanel:FindChild("JPView").localPosition = Vector3(806 + movePosX, 0, 0)
    self.JPAwardPanel:FindChild("AwardView").localPosition = Vector3(806 + movePosX, 0, 0)
end

--初始化大奖列表
function  ChristmasTaskView:SetAwardInfo(data)
	local list = data
	for _,v in pairs(self.PrefabInfo) do
		v.transform:SetActive(false)
	end
	for i = 1,#list do
		self:InfoItemData(i, list[i])
	end
end

--大奖玩家信息
function ChristmasTaskView:InfoItemData(index, InfoData)
	local tran = nil
	local item = nil
	if self.PrefabInfo[index] == nil then
        tran = self.Info_Item
        item = CC.uu.newObject(tran)
        item.transform.name = tostring(index)
		self.PrefabInfo[index] = item.transform
    else
        item = self.PrefabInfo[index]
    end
	item:SetActive(true)
	local headNode = item.transform:FindChild("ItemHead")
	self:DeleteHeadIconByKey(headNode)
	Util.ClearChild(headNode,false)
	local param = {}
	param.parent = headNode
	param.portrait = InfoData.Portrait
	param.playerId = InfoData.PlayerId
	param.vipLevel = InfoData.Vip
	param.headFrame = InfoData.Background
	param.clickFunc = "unClick"
	self:SetHeadIcon(param,index)
	if item then
		item.transform:SetParent(self.Info_Content, false)
		item.transform:FindChild("Nick"):GetComponent("Text").text = InfoData.Name
        item.transform:FindChild("Num"):GetComponent("Text").text = InfoData.Rewards[1].Count
        item.transform:FindChild("Time"):GetComponent("Text").text = os.date("%H:%M:%S %d/%m",InfoData.TimeStamp)
	end
end

--删除头像对象
function ChristmasTaskView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.IconTab[tonumber(headtran.transform.name)] ~= nil then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end
end

--设置头像
function  ChristmasTaskView:SetHeadIcon(param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

function ChristmasTaskView:ActionIn()
	self:SetCanClick(false);
	self.transform.size = Vector2(125, 0)
	self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:RunAction(self.transform, {
		{"fadeToAll", 0, 0},
		{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
	})
end

function ChristmasTaskView:ActionOut()
	self:SetCanClick(false);
	CC.HallUtil.HideByTagName("Effect", false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

--关闭界面
function ChristmasTaskView:CloseView()
	self:ActionOut()
end

function ChristmasTaskView:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true)
end

function ChristmasTaskView:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function ChristmasTaskView:OnDestroy()
	--CC.Sound.StopEffect()
	self:StopTimer("countDown"..self.createTime)
	if self.musicName then
		CC.Sound.PlayHallBackMusic(self.musicName);
	end
	for _,v in pairs(self.IconTab) do
		if v then
			v:Destroy()
			v = nil
		end
    end
	if self.numberRoller then
		self.numberRoller:Destroy()
		self.numberRoller = nil
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
end

return ChristmasTaskView;