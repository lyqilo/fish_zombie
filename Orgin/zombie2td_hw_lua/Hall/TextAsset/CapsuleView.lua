local CC = require("CC")

local CapsuleView = CC.uu.ClassView("CapsuleView")

local isHalloween = false --CapsuleView_万圣节版本.unitypackage

function CapsuleView:ctor(param)
    self.param = param
    self.propfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
	self.CostType = {
		Chips = 1,
		GiftVoucher = 2,
		Free = 3,
		Key = 4,
		Snow = 5,
		Star = 6,
	}
	self.isRecViewOpen = false
	self.recType = 1
	self.headList = {}
	self.mainScrollList = {}
	self.previewScrollList = {}
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self.CapsuleCfg = CC.ConfigCenter.Inst():getConfigDataByKey("CapsuleConfig")
end

function CapsuleView:OnCreate()
    self.language = self:GetLanguage()
    self.viewCtr = self:CreateViewCtr(self.param)

    self.Record = nil

    self:InitUI()

    self.viewCtr:OnCreate()
	self:InitTextByLanguage()
    self:AddClickEvent()

    self:RefreshSelfInfo()
	if isHalloween then
		--万圣节UI气泡形式奖励展示
		self:InitBubbleList()
	else
		--通用UI滚动列表形式奖励展示
		self:InitRewardsList()
	end
	self:InitPreviewPanel()
    -- self:DelayRun(0.3,function ()
    --     if not CC.LocalGameData.GetDailyStateByKey("Capsule") then
    --         CC.LocalGameData.SetDailyStateByKey("Capsule", true)
    --         self.TipsPanel:SetActive(true)
    --         self:SetCanClick(false);
    --         self.TipsPanel.localScale = Vector3(0.5,0.5,1)
    --         self:RunAction(self.TipsPanel, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    --             self:SetCanClick(true);
    --         end})
    --     end
    -- end)
end

function CapsuleView:InitUI()
	self.marquee = self:FindChild("SpeakerBord")
	self.marqueeText = self:FindChild("SpeakerBord/SpeakerImg/TextTip")
	self.marqueeWidth = (self:FindChild("SpeakerBord/SpeakerImg"):GetComponent('RectTransform').rect.width - 15)/2

    self.ChipNum = self:FindChild("Layer_UI/ChipCounter/Icon/Text")
    self.TicketNum = self:FindChild("Layer_UI/IntegralCounter/Icon/Text")
    self:FindChild("Layer_UI/ChipCounter"):SetActive(false)
    self:FindChild("Layer_UI/IntegralCounter"):SetActive(false)

    self.SnowNum = self:FindChild("Layer_UI/SnowCounter/Icon/Text")
    self:FindChild("Layer_UI/SnowCounter"):SetActive(true)

    self.Bubble = self:FindChild("Layer_UI/QP"):GetComponent("Animator")
	-- self.Bubble.transform:FindChild("01/Text").text = "599999"
	-- self.Bubble.transform:FindChild("02/Text").text = "999999"
	-- self.Bubble.transform:FindChild("03/Text").text = "199999"
	-- self.Bubble.transform:FindChild("04/Text").text = "x5"
	-- self.Bubble.transform:FindChild("05/Text").text = "x1"
    self.CapsuleSpin = self:FindChild("Layer_UI/CapsuleAnim"):GetComponent("SkeletonGraphic")

    self.Reward = self:FindChild("Layer_UI/OnceAnim")
    self.RewardSpin = self:FindChild("Layer_UI/OnceAnim"):GetComponent("SkeletonGraphic")
    self.RewardEffext = self:FindChild("Layer_UI/OnceAnim/BoneFollower/RewardEffect")

    self.MoreReward = self:FindChild("Layer_UI/MoreAnim")
    self.parent = self:FindChild("Layer_UI")

    self.ShowOBJ = nil

    --万圣节修改
    self.TipsPanel = self:FindChild("Layer_Tips")

    self.FreeBtn = self:FindChild("Layer_UI/FreeBtn")
    self.FreeNum = self:FindChild("Layer_UI/FreeBtn/Price"):GetComponent("Text")

    self.ShareBtn = self:FindChild("Layer_UI/ShareBtn")
    --self.ShareBtn:SetActive(false)

    self.OnlineTime = self:FindChild("Layer_UI/OnlineTime")
    self.OnlineTimeText = self:FindChild("Layer_UI/OnlineTime/Time"):GetComponent("Text")
	
	self.rewardsList = self:FindChild("Layer_UI/RewardsList")
	self.jumpPanel = self:FindChild("Layer_UI/JumpPanel")
	self.previewPanel = self:FindChild("Layer_UI/PreviewPanel")
	self.recordPanel = self:FindChild("Layer_UI/Record")
	self.recordMask =  self.recordPanel:FindChild("Frame/Mask")
	self.recordScrCtrl = self.recordPanel:FindChild("Frame/Panel/ScrollerController"):GetComponent("ScrollerController")
	
	if isHalloween then
		self.bubblePrefab = self:FindChild("Layer_UI/BubbleList/ShowRange/Item")
		self.bubbleParent = self:FindChild("Layer_UI/BubbleList/ShowRange/Parent")
	end

	--周年庆期间不显示2、4
	local jumpPanelShow = {[1] = true, [2] = true, [3] = true, [4] = true}
	for i=1,4 do
		self.jumpPanel:FindChild("Content/Card"..i):SetActive(jumpPanelShow[i])
	end
	self:FindChild("Layer_UI/ChipBtn/Price").text = "10000"
	self:FindChild("Layer_UI/ChipExBtn/Price").text = "100000"
	self:FindChild("Layer_UI/TicketBtn/Price").text = "200"
	self:FindChild("Layer_UI/TicketExBtn/Price").text = "2000"
    self:FindChild("Layer_UI/ChipBtn"):SetActive(false)
	self:FindChild("Layer_UI/ChipExBtn"):SetActive(false)
	self:FindChild("Layer_UI/TicketBtn"):SetActive(false)
	self:FindChild("Layer_UI/TicketExBtn"):SetActive(false)

    self:FindChild("Layer_UI/SnowBtn/Price").text = 1
    self:FindChild("Layer_UI/SnowExBtn/Price").text = 10
    self:FindChild("Layer_UI/SnowBtn"):SetActive(true)
    self:FindChild("Layer_UI/SnowExBtn"):SetActive(true)

    self:SpinAnim()
    self:RefrshMoreReward()
end

function CapsuleView:InitTextByLanguage()
    self:FindChild("Layer_UI/FreeBtn/Text").text = self.language.FreeBtn
    self:FindChild("Layer_UI/ChipBtn/Text").text = self.language.OnceBtn
    self:FindChild("Layer_UI/ChipExBtn/Text").text = self.language.MoreBtn
    self:FindChild("Layer_UI/TicketBtn/Text").text = self.language.OnceBtn
    self:FindChild("Layer_UI/TicketExBtn/Text").text = self.language.MoreBtn
    self:FindChild("Layer_UI/TicketExBtn/Tips/Text").text = self.language.MoreTips
    self:FindChild("Layer_UI/ActiveTime").text = self.language.Time
    self:FindChild("Layer_UI/OnlineTime/Text").text = self.language.OnlineText

    self:FindChild("Layer_UI/SnowBtn/Text").text = self.language.OnceBtn
    self:FindChild("Layer_UI/SnowExBtn/Text").text = self.language.MoreBtn
	
	self:FindChild("Layer_UI/RewardsList/BtnPreview/Text").text = self.language.btnPreview
	self.jumpPanel:FindChild("Content/Text1").text = self.language.coinNotEnough
	self.jumpPanel:FindChild("Content/Text2").text = self.language.closeTip
	for i=1,4 do
		self.jumpPanel:FindChild("Content/Card"..i.."/Tag/Text").text = self.language["activity"..i].tag
		self.jumpPanel:FindChild("Content/Card"..i.."/Text").text = self.language["activity"..i].name
	end
	self.previewPanel:FindChild("Content/Real/Egg/Text").text = self.language.egg3
	self.previewPanel:FindChild("Content/Normal/Egg/Text").text = self.language.egg2
	self.previewPanel:FindChild("Content/Chip/Egg/Text").text = self.language.egg1
	self.recordPanel:FindChild("Frame/ToggleGroup/BigRecord/Background/Label").text = self.language.toggleBig
	self.recordPanel:FindChild("Frame/ToggleGroup/BigRecord/Checkmark/Label").text = self.language.toggleBig
	self.recordPanel:FindChild("Frame/ToggleGroup/MyRecord/Background/Label").text = self.language.toggleMy
	self.recordPanel:FindChild("Frame/ToggleGroup/MyRecord/Checkmark/Label").text = self.language.toggleMy

	self.recordPanel:FindChild("Frame/ToggleGroup/CountRecord/Background/Label").text = self.language.toggleCount
	self.recordPanel:FindChild("Frame/ToggleGroup/CountRecord/Checkmark/Label").text = self.language.toggleCount

	self:FindChild("Layer_UI/Record/Frame/Panel/Item/RankCount/Count/Text").text = self.language.countText
end

function CapsuleView:AddClickEvent()
    self:AddClick("Layer_UI/FreeBtn",function ()
        self.viewCtr:ReqLottery(self.CostType.Free,1)
    end)
    self:AddClick("Layer_UI/ChipBtn",function ()
        self.viewCtr:ReqLottery(self.CostType.Chips,1)
    end)
    self:AddClick("Layer_UI/ChipExBtn",function ()
        self.viewCtr:ReqLottery(self.CostType.Chips,10)
    end)
    self:AddClick("Layer_UI/TicketBtn",function ()
        self.viewCtr:ReqLottery(self.CostType.GiftVoucher,1)
    end)
    self:AddClick("Layer_UI/TicketExBtn",function ()
        self.viewCtr:ReqLottery(self.CostType.GiftVoucher,10)
        self:FindChild("Layer_UI/TicketExBtn/Tips"):SetActive(false)
    end)
    self:AddClick("Layer_UI/SnowBtn",function ()
        self.viewCtr:ReqLottery(self.CostType.Snow,1)
    end)
    self:AddClick("Layer_UI/SnowExBtn",function ()
        self.viewCtr:ReqLottery(self.CostType.Snow,10)
    end)
    self:AddClick("Layer_UI/ChipCounter",function ()
        if CC.ViewManager.IsHallScene() then
            CC.ViewManager.Open("StoreView")
        end
    end)
    self:AddClick("Layer_UI/Title/Button",function ()
        -- self.TipsPanel:SetActive(true)
        -- self:SetCanClick(false);
        -- self.TipsPanel.localScale = Vector3(0.5,0.5,1)
        -- self:RunAction(self.TipsPanel, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    	-- 	self:SetCanClick(true);
    	-- end})
      
        CC.ViewManager.Open("CommonExplainView", {title = self.language.explainTitle,content = self.language.explainContent})
    end)
    self:AddClick("Layer_Tips/Panel/Charge",function ()
        self:ToCharge()
    end)
    self:AddClick("Layer_Tips/Panel/CloseBtn",function ()
        self:RunAction(self.TipsPanel, {"scaleTo", 0, 0, 0.2, ease=CC.Action.EOutQuad, function()
    		self.TipsPanel:SetActive(false)
    	end})
    end)
    self:AddClick("Layer_UI/ShareBtn",function ()
        if not self.viewCtr.shareState then
            self.shareState = true
        end
        local param = {}
        param.isShowPlayerInfo = true
        --param.webText = self.language.ShareContent
        CC.ViewManager.Open("CaptureScreenShareView", param)
    end)
    self:AddClick("Layer_Tips/Panel/ShareBtn",function ()
        if not self.viewCtr.shareState then
            self.shareState = true
        end
        local param = {}
        param.isShowPlayerInfo = true
        param.webText = self.language.ShareContent
        CC.ViewManager.Open("CaptureScreenShareView", param)
    end)
	self:AddClick(self.jumpPanel:FindChild("Mask"),function ()
			self.jumpPanel:SetActive(false)
		end)
	self:AddClick("Layer_UI/RewardsList/BtnPreview",function ()
			for _,v in ipairs(self.previewScrollList) do
				if v then
					v:SetTrundleState(true)
				end
			end
			self.previewPanel:SetActive(true)
		end)
	self:AddClick(self.previewPanel:FindChild("Close"),function ()
			for _,v in ipairs(self.previewScrollList) do
				if v then
					v:SetTrundleState(false)
				end
			end
			self.previewPanel:SetActive(false)
		end)
	self:AddClick(self.recordMask,"ChangeRecordViewStatus")
	for i=1,4 do
		self:AddClick(self.jumpPanel:FindChild("Content/Card"..i),function ()
				self:OnClickJumpActivity(i)
			end)
	end
	
    self:FindChild("Layer_Tips/Panel/ShareBtn"):SetActive(false)
	
	self.recordScrCtrl:AddChangeItemListener(function(tran,dataIndex,cellIndex)
			self:RefreshRecordItem(tran,dataIndex)
		end)
	self.recordScrCtrl:AddRycycleAction(function (tran)
			self:RycycleRecordItem(tran)
		end)

	UIEvent.AddToggleValueChange(self.recordPanel:FindChild("Frame/ToggleGroup/BigRecord"),function (selected)
			if selected then
				self.recType = 2
				self.recordScrCtrl:InitScroller(#self.viewCtr.bigRecord)
				if not self.isRecViewOpen then
					self:ChangeRecordViewStatus()
				end
			end
		end)
	UIEvent.AddToggleValueChange(self.recordPanel:FindChild("Frame/ToggleGroup/MyRecord"),function (selected)
			if selected then
				self.recType = 3
				self.recordScrCtrl:InitScroller(#self.viewCtr.myRecord)
				if not self.isRecViewOpen then
					self:ChangeRecordViewStatus()
				end
			end
		end)
	UIEvent.AddToggleValueChange(self.recordPanel:FindChild("Frame/ToggleGroup/CountRecord"),function (selected)
			if selected then
				self.recType = 1
				self.recordScrCtrl:InitScroller(#self.viewCtr.countRecord)
				if not self.isRecViewOpen then
					self:ChangeRecordViewStatus()
				end
			end
		end)
end

function CapsuleView:RefreshUI(param)
    if param.IsShare then
        self.ShareBtn:FindChild("Text").text = string.format(self.language.ShareText,"")
    else
        self.ShareBtn:FindChild("Text").text = string.format(self.language.ShareText,"+1")
    end

    --2021圣诞节没有免费抽奖，这里先注释
    -- if param.Free then
    --     self.FreeNum.text = param.Free
    --     self.FreeBtn:SetActive(param.Free > 0)
    -- end

    --2021圣诞节没有在线任务，这里先注释
    -- if param.CD then
    --     self:SetOnlineTime(param.CD)
    -- end
end

function CapsuleView:InitBubbleList()
	local cfg = self.CapsuleCfg.mainShow
	local awards = {}
	for _,v in ipairs(cfg.special) do
		table.insert(awards,v)
	end
	for _,v in ipairs(cfg.big) do
		table.insert(awards,v)
	end
	for _,v in ipairs(cfg.normal) do
		table.insert(awards,v)
	end
	if table.isEmpty(awards) then return end
	
	local startNode = {
		[1] = self:FindChild("Layer_UI/BubbleList/ShowRange/StartNode1"),
		[2] = self:FindChild("Layer_UI/BubbleList/ShowRange/StartNode2"),
	}
	local endNode = {
		[1] = self:FindChild("Layer_UI/BubbleList/ShowRange/EndNode1"),
		[2] = self:FindChild("Layer_UI/BubbleList/ShowRange/EndNode2"),
	}

	self:StopTimer("Bubble")
	self.co_Bubble =  coroutine.start(function()
			coroutine.step(1)
			Util.ClearChild(self.bubbleParent)
			local loopIdx = 1
			local func = function()
				for i=1,2 do
					if loopIdx > #awards then
						loopIdx = 1
					end
					local data = awards[loopIdx]
					self:CreateBubbleItem(data, startNode[i], endNode[i])
					loopIdx = loopIdx + 1
				end
			end
			func()
			self:StartTimer("Bubble", 2, func, -1)
		end)
end

function CapsuleView:CreateBubbleItem(data,startNode,endNode)
	local item = CC.uu.newObject(self.bubblePrefab,self.bubbleParent)
	item.position = startNode.position
	local action = nil
	local actionParam = {}
	local duration = 20
	local startX = startNode.position.x
	local startY = startNode.position.y
	local endX = endNode.position.x
	local endY = endNode.position.y
	local deltaX = endX - startX
	local deltaY = endY - startY
	local hasHide = false
	local awardImage = data.icon~="" and data.icon or self.propfg[data.id].Icon

	self:SetImage(item:FindChild("Node/Icon"),awardImage)
	item:FindChild("Node/Icon"):GetComponent("Image"):SetNativeSize()
	item:FindChild("Node/Num").text = data.text or ""
	item:SetActive(true)

	--table.insert(actionParam,"spawn")
	table.insert(actionParam,{"to", 0, 1000, duration,function (value)
				local percent = value/1000
				item.position = Vector3(startX + deltaX*percent, startY + deltaY*percent)
				if value >= 680 and (not hasHide) then
					hasHide = true
					self:RunAction(item, {"fadeToAll", 0, 0.5, function ()
								if action ~= nil then
									self:StopAction(action)
								end
								if not CC.uu.IsNil(item) then
									CC.uu.destroyObject(item)
								end
							end})
				end
			end})
	actionParam.ease = CC.Action.EOutQuart
	action = self:RunAction(item, actionParam)
end

function CapsuleView:InitRewardsList()
	local cfg = self.CapsuleCfg.mainShow
	
	local parent = self.rewardsList:FindChild("Big/UpList")
	local autoScroll = CC.ViewCenter.AutoScroll.new()
	table.insert(self.mainScrollList,autoScroll)
	local param = {}
	param.parent = parent
	param.list = cfg.special
	param.type = 2
	autoScroll:Create(param)
	autoScroll:SetTrundleState(true)
	
	parent = self.rewardsList:FindChild("Big/List")
	local autoScroll = CC.ViewCenter.AutoScroll.new()
	table.insert(self.mainScrollList,autoScroll)
	local param = {}
	param.parent = parent
	param.list = cfg.big
	param.type = 1
	autoScroll:Create(param)
	autoScroll:SetTrundleState(true)
	
	parent = self.rewardsList:FindChild("Chip/List")
	local autoScroll = CC.ViewCenter.AutoScroll.new()
	table.insert(self.mainScrollList,autoScroll)
	local param = {}
	param.parent = parent
	param.list = cfg.normal
	param.type = 1
	autoScroll:Create(param)
	autoScroll:SetTrundleState(true)
end

function CapsuleView:InitPreviewPanel()
	local cfg = self.CapsuleCfg.rewardsList
	local prefab = self.previewPanel:FindChild("Item")
	local realParent = self.previewPanel:FindChild("Content/Real/List")
	local normalParent = self.previewPanel:FindChild("Content/Normal/List")
	local chipParent = self.previewPanel:FindChild("Content/Chip/List")
	
	local autoScroll = CC.ViewCenter.AutoScroll.new()
	table.insert(self.previewScrollList,autoScroll)
	local param = {}
	param.parent = realParent
	param.list = cfg[1].list
	param.type = 1
	autoScroll:Create(param)
	
	local autoScroll = CC.ViewCenter.AutoScroll.new()
	table.insert(self.previewScrollList,autoScroll)
	local param = {}
	param.parent = normalParent
	param.list = cfg[2].list
	param.type = 1
	autoScroll:Create(param)
	
	local autoScroll = CC.ViewCenter.AutoScroll.new()
	table.insert(self.previewScrollList,autoScroll)
	local param = {}
	param.parent = chipParent
	param.list = cfg[3].list
	param.type = 1
	autoScroll:Create(param)

end

function CapsuleView:SetOnlineTime(time)
    if time > 0 then
        self.OnlineTime:SetActive(true)
        self.TotalTime = time
        self.NextTime = self.TotalTime % 1200
        self:StartTimer("TotalTime",1,function ()
            self.TotalTime = self.TotalTime - 1
            if self.TotalTime > 0 then
                self.OnlineTimeText.text = CC.uu.TicketFormat(self.TotalTime)
            else
                self.OnlineTime:SetActive(false)
                self:StopTimer("TotalTime")
            end
        end,-1)
        self:StartTimer("NextReq",1,function ()
            self.NextTime = self.NextTime - 1
            if self.NextTime == 0 then
                self.viewCtr:RefreshOnlineTime()
                self:StopTimer("NextReq")
            end
        end,-1)
    else
        self.OnlineTime:SetActive(false)
    end
end

function CapsuleView:SpinAnim()
    self.Reward:SetActive(true)
    if self.RewardSpin.AnimationState then
        self.RewardSpin.AnimationState:ClearTracks()
        self.RewardSpin.AnimationState:SetAnimation(0, "stand", false)
    end
    local RewardFun = nil
    RewardFun = function ()
        if self.RewardSpin.AnimationState then
            self.RewardSpin.AnimationState:ClearTracks()
            self.RewardSpin.AnimationState:SetAnimation(0, "stand", false)
        end
        self:DelayRun(0.016,function ()
            if not CC.uu.IsNil(self.RewardSpin) then
                self.RewardSpin:SetActive(false)
				if isHalloween then
					self.RewardSpin.transform.localPosition = Vector3(6,-180,0)
				else
					self.RewardSpin.transform.localPosition = Vector3(-173,-188,0)
				end
            end
        end)
        self.RewardSpin.AnimationState.Complete = self.RewardSpin.AnimationState.Complete - RewardFun
    end
    self.RewardSpin.AnimationState.Complete = self.RewardSpin.AnimationState.Complete + RewardFun
end

function CapsuleView:PlayLotteryAnim(bstate)
    CC.HallNotificationCenter.inst():post(CC.Notifications.FreeChipsCollectionClickState, false);
    CC.Sound.PlayHallEffect("niudanjis")
    self.Bubble:StartPlayback()
    self.Bubble.speed = -1
    self.Bubble:Play("Effect_NiuDan_QiPao_Open",0,1)
    if self.CapsuleSpin.AnimationState then
		local animation = bstate and "stand2_2" or "stand2_1"
		-- local animation = "stand2"
        self.CapsuleSpin.AnimationState:ClearTracks()
        self.CapsuleSpin.AnimationState:SetAnimation(0, animation, false)
    end
    local LotteryFun = nil
    LotteryFun = function ()
        if bstate then
            self:PlayMoreAnim()
            CC.Sound.PlayHallEffect("10lianchou")
        else
            self:PlayOnceAnim()
            CC.Sound.PlayHallEffect("1lianchou")
        end
        self.CapsuleSpin.AnimationState:ClearTracks()
        self.CapsuleSpin.AnimationState:SetAnimation(0, "stand1", true)
        self.CapsuleSpin.AnimationState.Complete =  self.CapsuleSpin.AnimationState.Complete - LotteryFun
    end
    self.CapsuleSpin.AnimationState.Complete =  self.CapsuleSpin.AnimationState.Complete + LotteryFun
end

function CapsuleView:PlayMoreAnim()
    self.ShowOBJ:SetActive(true)
    for i = 1, 10 do
		local reward = self.viewCtr.reward.Rewards[i]
        local random = self:GetAnimIndex(reward)
        local ani = nil
        if random == 1 then
            ani = "stand"
        else
            ani = "stand"..random
        end
        self.MoreRewardRandom[i] = random
        if self.MoreRewardSpin[i].AnimationState then
            self.MoreRewardSpin[i].AnimationState:ClearTracks()
            self.MoreRewardSpin[i].AnimationState:SetAnimation(0, ani, false)
        end
        local ShowRewardFun = nil
        local OpenRewardFun = nil
        OpenRewardFun = function ()
            if i == 10 then
                self.MoreRewardSpin[i].AnimationState.Complete =  self.MoreRewardSpin[i].AnimationState.Complete - ShowRewardFun
                self:StopMoreAnim()
            end
        end
        ShowRewardFun = function ()
            local state = self.MoreRewardRandom[i]
            local openAni = "stand"..(state + 3)
            if self.MoreRewardSpin[i].AnimationState then
                self.MoreRewardSpin[i].AnimationState:ClearTracks()
                self.MoreRewardSpin[i].AnimationState:SetAnimation(0, openAni, false)
                self.MoreRewardSpin[i].AnimationState.Complete =  self.MoreRewardSpin[i].AnimationState.Complete - ShowRewardFun
                self.MoreRewardSpin[i].AnimationState.Complete = self.MoreRewardSpin[i].AnimationState.Complete + OpenRewardFun
            end
        end
        self.MoreRewardSpin[i].AnimationState.Complete = self.MoreRewardSpin[i].AnimationState.Complete + ShowRewardFun
    end
end

function CapsuleView:GetAnimIndex(reward,isOnce)
	local index = math.random(1,3)
	for _,table in ipairs(self.CapsuleCfg.rewardsList) do
		for _,v in ipairs(table.list) do
			if reward.ConfigId == v.id and reward.Count == v.num then
				if isOnce then
					index = table.onceAnimIndex
				else
					index = table.animIndex
				end
			end
		end
	end
	return index
end

function CapsuleView:StopMoreAnim()
    self:RefrshMoreReward()
    self.viewCtr:OpenRewardPanel()
    self.Bubble:StartPlayback()
    self.Bubble.speed = 1
    self.Bubble:Play("Effect_NiuDan_QiPao_Open",0,0)
    self:StartTimer("CheckAniState", 0, function()
    local stateInfo = self.Bubble:GetCurrentAnimatorStateInfo(0)
        if stateInfo.normalizedTime >= 1.0 then
            self.Bubble:SetBool("loop",true)
            self:StopTimer("CheckAniState")
        end
    end,-1)
end

function CapsuleView:RefrshMoreReward()
    if self.ShowOBJ then
        CC.uu.destroyObject(self.ShowOBJ)
    end
    self.ShowOBJ = CC.uu.newObject(self.MoreReward, self.parent)
    self.MoreRewardSpin = {}
    for i = 1, 10 do
        table.insert(self.MoreRewardSpin,self.ShowOBJ:FindChild(i):GetComponent("SkeletonGraphic"))
    end
    self.MoreRewardRandom = {}
end

function CapsuleView:PlayOnceAnim()
	local reward = self.viewCtr.reward.Rewards[1]
	local index = self:GetAnimIndex(reward,true)
    local ani = nil
    if index == 1 then
        ani = "stand"
    else
        ani = "stand"..index
    end
    self.Reward:SetActive(true)
    if self.RewardSpin.AnimationState then
        self.RewardSpin.AnimationState:ClearTracks()
        self.RewardSpin.AnimationState:SetAnimation(0, ani, false)
    end
    local RewardFun = nil
    RewardFun = function ()
        self.RewardEffext:SetActive(true)
        self:StopOnceAnim()
        self.RewardSpin.AnimationState.Complete = self.RewardSpin.AnimationState.Complete - RewardFun
    end
    self.RewardSpin.AnimationState.Complete = self.RewardSpin.AnimationState.Complete + RewardFun
end

function CapsuleView:StopOnceAnim()
    if self.RewardSpin.AnimationState then
        self.RewardSpin.AnimationState:ClearTracks()
        self.RewardSpin.AnimationState:SetAnimation(0, "stand", false)
    end
    self:DelayRun(0.016,function ()
        self.RewardSpin:SetActive(false)
        self.RewardEffext:SetActive(false)
        self.viewCtr:OpenRewardPanel()
    end)
    self.Bubble:StartPlayback()
    self.Bubble.speed = 1
    self.Bubble:Play("Effect_NiuDan_QiPao_Open",0,0)
    self:StartTimer("CheckAniState", 0, function()
        local stateInfo = self.Bubble:GetCurrentAnimatorStateInfo(0)
        if stateInfo.normalizedTime >= 1.0 then
            self.Bubble:SetBool("loop",true)
            self:StopTimer("CheckAniState")
        end
    end,-1)
end

function CapsuleView:RefreshSelfInfo()
    -- self.ChipNum.text = CC.uu.ChipFormat(CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa"))
    -- self.TicketNum.text = CC.uu.ChipFormat(CC.Player.Inst():GetSelfInfoByKey("EPC_New_GiftVoucher"))
	local propNum = CC.Player.Inst():GetSelfInfoByKey("EPC_TwistEgg_Coin")
    self.SnowNum.text = CC.uu.ChipFormat(propNum)
	-- self:FindChild("Layer_UI/Num").text = math.floor(propNum/1)
end

function CapsuleView:ShowRewardRecord()
	do return end
    self.Record = self.viewCtr.realDataMgr.GetEggRecord()
    if #self.Record > 0 then
        self.recordIndex = 1;
        self.marquee:SetActive(true)
        self:PlayMarquee()
    end
end

function CapsuleView:RefrshEggRecord(param)
    if self.Record then
        table.insert(self.Record,1,param)
        if #self.Record > 20 then
            table.remove(self.Record,#self.Record)
        end
        self.recordIndex = 1
    end
end

function CapsuleView:PlayMarquee()
    self:StartTimer("Record",1,function()
        if self.isMoving then
            return
        else
            self.isMoving = true
            local text =  self:InitRecord(self.Record[self.recordIndex])
            self.recordIndex = self.recordIndex + 1
            if self.recordIndex > #self.Record then self.recordIndex = 1 end
			self.marqueeText:GetComponent('Text').text = text
			self:DelayRun(0.1,function()
				local textW = self.marqueeText:GetComponent('RectTransform').rect.width
				local half = textW/2
                self.marqueeText.localPosition = Vector3(half + self.marqueeWidth, 0, 0)
                self:RunAction(self.marqueeText, {"localMoveTo", -half - self.marqueeWidth, 0, 0.65 * math.max(16,textW/40), function()
					self.isMoving = false
                end})
			end)
        end
    end,-1)
end

function CapsuleView:InitRecord(param)
    local data = param.Reward
    local propDes = self.viewCtr.propDataMgr.GetLanguageDesc(data.ConfigId,data.Count)
    local nick = param.Name
    local msg = string.format(self.language.RewardRecord,nick,propDes)
    return msg
end

function CapsuleView:OnResume()
	if self.shareState then
		self.shareState = false
		self.viewCtr:ShareComplete()
	end
end

function CapsuleView:ToCharge()
    local level = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
    if level < 3 then
        if CC.Player.Inst():GetFirstGiftState() then
            --首冲礼包
			CC.ViewManager.OpenAndReplace("FirstBuyGiftView")
        elseif CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
            CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, false);
            CC.ViewManager.Open("SelectGiftCollectionView", {currentView = "NoviceGiftView", closeFunc = function() CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, true); end});
        else
            CC.ViewManager.OpenAndReplace("VipThreeCardView")
        end
    else
        CC.ViewManager.OpenAndReplace("StoreView")
    end
end

function CapsuleView:ChangeRecordViewStatus()
	self.isRecViewOpen = not self.isRecViewOpen
	self.recordMask:SetActive(self.isRecViewOpen)
	if self.isRecViewOpen then
		self:RunAction(self.recordPanel,{"localMoveBy", -418, 0, 0.2, ease=CC.Action.EOutSine})
	else
		self:RunAction(self.recordPanel,{"localMoveBy", 418, 0, 0.2, ease=CC.Action.EOutSine})
	end
end

function CapsuleView:RefreshRecordItem(trans,index)
	if not self.viewCtr then return end
	local dataIdx = index + 1
	local recList
	if self.recType == 2 then
		recList = self.viewCtr.bigRecord
	elseif self.recType == 3 then
		recList =  self.viewCtr.myRecord
	elseif self.recType == 1 then
		recList =  self.viewCtr.countRecord
	end

	if not recList or table.isEmpty(recList) then
		return
	end

	local recData = recList[dataIdx]
	if self.recType == 2 then
		self:RefreshBigRecordItem(trans,dataIdx,recData)
	elseif self.recType == 3 then
		self:RefreshMyRecordItem(trans,dataIdx,recData)
	elseif self.recType == 1 then
		self:RefreshCountRecordItem(trans,dataIdx,recData)
	end
end

function CapsuleView:RefreshBigRecordItem(trans,dataIdx,recData)
	--CC.uu.Log(recData,"recData",3)
	trans.name = dataIdx
	-- trans:FindChild("Bg"):SetActive(dataIdx%2==0)
	trans:FindChild("Icon"):SetActive(true)
	trans:FindChild("Info"):SetActive(true)
	trans:FindChild("RankCount"):SetActive(false)
	trans:FindChild("Info/Name").text = recData.Name
	trans:FindChild("Info/Time").text = CC.TimeMgr.GetTimeFormat1(recData.TimeStamp)
	self:SetImage(trans:FindChild("Prop/Icon"),self.propfg[recData.Reward.ConfigId].Icon)
	trans:FindChild("Prop/Icon"):GetComponent("Image"):SetNativeSize()
	if recData.Reward.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
		trans:FindChild("Prop/Num").text = CC.uu.ChipFormat(recData.Reward.Count)
	else
		trans:FindChild("Prop/Num").text = ""
	end

	local IconData = {}
	IconData.parent = trans:FindChild("Icon/HeadNode")
	IconData.playerId = recData.PlayerId
	IconData.portrait = recData.Portrait
	IconData.headFrame = recData.Background
	IconData.vipLevel = recData.Vip
	local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.headList[dataIdx] = headIcon
end

function CapsuleView:RefreshMyRecordItem(trans,dataIdx,recData)
	--CC.uu.Log(recData,"recData",3)
	trans.name = dataIdx
	-- trans:FindChild("Bg"):SetActive(dataIdx%2==0)
	trans:FindChild("Icon"):SetActive(true)
	trans:FindChild("Info"):SetActive(true)
	trans:FindChild("RankCount"):SetActive(false)
	trans:FindChild("Info/Name").text = CC.Player.Inst():GetSelfInfoByKey("Nick");--recData.Name
	trans:FindChild("Info/Time").text = CC.TimeMgr.GetTimeFormat1(recData.TimeStamp)
	self:SetImage(trans:FindChild("Prop/Icon"),self.propfg[recData.Reward.ConfigId].Icon)
	trans:FindChild("Prop/Icon"):GetComponent("Image"):SetNativeSize()
	if recData.Reward.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
		trans:FindChild("Prop/Num").text = CC.uu.ChipFormat(recData.Reward.Count)
	else
		trans:FindChild("Prop/Num").text = ""
	end

	local IconData = {}
	IconData.parent = trans:FindChild("Icon/HeadNode")
	IconData.playerId = recData.PlayerId

	local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.headList[dataIdx] = headIcon
end

function CapsuleView:RefreshCountRecordItem(trans,dataIdx,recData)
	trans.name = dataIdx
	trans:FindChild("Icon"):SetActive(false)
	trans:FindChild("Info"):SetActive(false)
	trans:FindChild("RankCount"):SetActive(true)
	self:SpriteInfo(dataIdx, trans)
	trans:FindChild("RankCount/Count/Num").text = recData.Score
	local ConfigId = self.CapsuleCfg.rankRewards[dataIdx].rew1.id
	if ConfigId then
		self:SetImage(trans:FindChild("Prop/Icon"),self.propfg[ConfigId].Icon)
		trans:FindChild("Prop/Icon"):GetComponent("Image"):SetNativeSize()
		if self.CapsuleCfg.rankRewards[dataIdx].rew1.count > 1 then
			trans:FindChild("Prop/Num").text = CC.uu.NumberFormat(self.CapsuleCfg.rankRewards[dataIdx].rew1.count) 
		else
			trans:FindChild("Prop/Num").text = ""
		end
	end

	local IconData = {}
	IconData.parent = trans:FindChild("RankCount/HeadNode")
	IconData.portrait = recData.Portrait
	IconData.headFrame = recData.Background
	IconData.vipLevel = recData.Vip
	IconData.playerId = recData.PlayerId

	local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.headList[dataIdx] = headIcon
end

--皇冠图片切换
function CapsuleView:SpriteInfo(key,value)
	if key <= 3 then
		value:FindChild("RankCount/Effect"):SetActive(true)
		value:FindChild("RankCount/Effect/1"):SetActive(key == 1)
		value:FindChild("RankCount/Effect/2"):SetActive(key == 2)
		value:FindChild("RankCount/Effect/3"):SetActive(key == 3)
		value:FindChild("RankCount/Rank"):SetActive(false)
	else
		value:FindChild("RankCount/Effect"):SetActive(false)
		value:FindChild("RankCount/Rank"):SetActive(true)
		value:FindChild("RankCount/Rank/Text").text = key
	end
end

function CapsuleView:RycycleRecordItem(trans)
	local index = tonumber(trans.transform.name)
	if self.headList[index] then
		self.headList[index]:Destroy(true)
	end
end

function CapsuleView:OnClickJumpActivity(index)
	local viewList = {"SelectGiftCollectionView","FreeChipsCollectionView","DailyGiftCollectionView","FreeChipsCollectionView"}
	local subViewList = {"NewPayGiftView","HalloweenLoginGiftView","HolidayDiscountsView","DailyLotteryView"}
	
	local viewKey = subViewList[index]
	local switchOn = self.activityDataMgr.GetActivityInfoByKey(viewKey).switchOn
	if viewKey == "HalloweenLoginGiftView" then
		switchOn = switchOn and CC.HallUtil.ShowHalloweenLoginGift()
	end
	if not switchOn then
        CC.ViewManager.ShowTip(self.language.activityTip)
        return
    end;
	if viewList[index] == "FreeChipsCollectionView" then
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnChangeFreeChipsView, viewKey)
	else
		CC.ViewManager.OpenAndReplace(viewList[index],{currentView = viewKey});
	end
end

function CapsuleView:ActionIn()
	--self:SetCanClick(false);
	--self:RunAction(self.transform, {
			--{"fadeToAll", 0, 0},
			--{"fadeToAll", 255, 0.5, function()
					--self:SetCanClick(true);
				--end}
		--});
end

function CapsuleView:ActionOut()
	self:Destroy()
	--self:SetCanClick(false);
	--self:RunAction(self.transform, {
			--{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		--});
end

function CapsuleView:OnDestroy()
    CC.HallNotificationCenter.inst():post(CC.Notifications.FreeChipsCollectionClickState, true)

	for _,v in pairs(self.headList) do
		if v then
			v:Destroy(true)
			v = nil
		end
	end

	for _,v in ipairs(self.mainScrollList) do
		if v then
			v:Destroy()
			v = nil
		end
	end	
	for _,v in ipairs(self.previewScrollList) do
		if v then
			v:Destroy()
			v = nil
		end
	end
	
	if self.co_Bubble then
		coroutine.stop(self.co_Bubble)
		self.co_Bubble = nil
	end
	
    if self.viewCtr then
        self.viewCtr:Destroy()
        self.viewCtr = nil
    end

    self.Bubble = nil
end


return CapsuleView