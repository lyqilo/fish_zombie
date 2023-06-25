local CC = require("CC")
local MonthRebateView = CC.uu.ClassView("MonthRebateView")

local MaskMode = {
    "_MASKMODE_ROUND",
    "_MASKMODE_RECTANGLE",
    "_MASKMODE_MORE",
    "_MASKMODE_NULL"
}

function MonthRebateView:ctor(param)
    self.param = param or {}
    self.LevelTab = {}
    self.curNum = 0
    --气泡
    self.bubbleList = {}
    self.bubblePlay = false
    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
    --引导
    self.guideStep = 0
    --流水任务
    self.curLevel = 1
    --有奖励可以领
    self.isBoxReward = false
end

function MonthRebateView:OnCreate()
    self.language = self:GetLanguage()
    self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate()

    self:InitUI()
    self:LanguageSwitch()
end

function MonthRebateView:InitUI()
    self.mask = self:FindChild("Guide/mask")
    for _,v in pairs(MaskMode) do
        if self.mask:GetComponent("Image").material:IsKeywordEnabled(v) then
            self.MaskMode = v
        end
    end
    self.mask:GetComponent("Image").material:DisableKeyword(self.MaskMode)
    self.mask:GetComponent("Image").material:EnableKeyword("_MASKMODE_NULL")
    self.MaskMode = "_MASKMODE_RECTANGLE"

    self.TimeText = self:FindChild("Frame1/bg/Time/TimeText")
    self.TimeText2 = self:FindChild("Frame2/bg/Time/TimeText")
    self.bubbleAnim = self:FindChild("Bubble"):GetComponent("Animator")
    self.helpPlanel = self:FindChild("HelpPlanel")
    for i = 1, 3 do
        self.bubbleList[i] = self:FindChild(string.format("Bubble/%s", i))
    end
    --流水任务
    self.TaskFrame = self:FindChild("Frame1")
    for i = 1, 5 do
        local ind = i
		self.LevelTab[i] = self.TaskFrame:FindChild(string.format("Right/Level_%s", ind))
        self:AddClick(self.LevelTab[ind]:FindChild("default"),function()
            self:FindChild("Bubble").localScale = Vector3(0,0,1)
            self:LevelBtnClick(ind)
        end)
	end
	self.Slider = self.TaskFrame:FindChild("Right/Slider")
    self.NowNum = self.TaskFrame:FindChild("Right/NowNum/Text")
    --月末返利
    self.RebateFrame = self:FindChild("Frame2")
    self.RebateBoxSpine = self.RebateFrame:FindChild("Box"):GetComponent("SkeletonGraphic")
    
    self:AddClick(self:FindChild("Button/BtnVip"), function ()
        self:OnBtnVipClick()
	end)
    self:AddClick(self:FindChild("Button/BtnNormal/Image"), function ()
        self.viewCtr:ReqAcquireReward(self.curLevel)
	end)
    self:AddClick(self:FindChild("Button/BtnHelp"), function ()
        for i = 1, 5, 1 do
            if self.viewCtr.statusList[i] == 0 then
                self:FindChild("HelpPlanel/Content/2/"..i):SetActive(true)
                self:FindChild("HelpPlanel/Content/2/"..i.."_1"):SetActive(false)
            else
                self:FindChild("HelpPlanel/Content/2/"..i):SetActive(false)
                self:FindChild("HelpPlanel/Content/2/"..i.."_1"):SetActive(true)
            end
        end
        self.helpPlanel:SetActive(true)
	end)
    self:AddClick(self:FindChild("HelpPlanel/BtnClose"), function ()
        self.helpPlanel:SetActive(false)
	end)
    self:AddClick(self:FindChild("BtnClose"), function ()
		self:CloseView()
	end)
    self:AddClick(self:FindChild("Guide/mask"), function ()
        --引导
        self:FindChild(string.format("Guide/%s", self.guideStep)):SetActive(false)
		self.guideStep = self.guideStep + 1
        if self.guideStep < 4 then
            self:FindChild(string.format("Guide/%s", self.guideStep)):SetActive(true)
            if self.guideStep == 2 then
                self.mask:GetComponent("Image").material:SetVector("_Center", Vector4(500,10,0,0))
                self.mask:GetComponent("Image").material:SetVector("_RectangleSize", Vector4(100,280,0,0))
                self.mask:GetComponent("Image").material:DisableKeyword("_MASKMODE_RECTANGLE")
                self.mask:GetComponent("Image").material:EnableKeyword("_MASKMODE_RECTANGLE")
            else
                self.mask:GetComponent("Image").material:SetVector("_Center", Vector4(10000,0,0,0))
            end
        else
            self:FindChild("Guide"):SetActive(false)
        end
	end)
    self:AddClick(self:FindChild("Box"),function ()
        CC.ViewManager.ShowTip(self.language.tip3);
    end)

    for i = 1, 3, 1 do
        self:AddClick(self:FindChild("Bubble/"..i),function ()
            self:BubbleClickEvent(self.curLevel)
        end)
    end

    self:InitView()
end

function MonthRebateView:BubbleClickEvent(index)
    if self.viewCtr.statusList[index] == 2 then

    else
        CC.ViewManager.ShowTip(self.language.tip4);
    end
end

function MonthRebateView:LanguageSwitch()
    self:FindChild("Button/BtnNormal/Text").text = self.language.btnNormal
    self:FindChild("Button/BtnNormal/Gray/Text").text = self.language.btnNormal
    self:FindChild("Button/BtnVip/Text").text = self.language.btnVip
    self:FindChild("Button/BtnVip/Gray/Text").text = self.language.btnVip
    self.TaskFrame:FindChild("Tip").text = self.language.tip1
    self.RebateFrame:FindChild("Tip").text = self.language.tip2
    self.helpPlanel:FindChild("Title").text = self.language.helpTitle
    self.helpPlanel:FindChild("Content/1").text = self.language.Content_1
    self.helpPlanel:FindChild("Content/3").text = self.language.Content_3
    self.helpPlanel:FindChild("Content/4/box/Text").text = self.language.Content_4
    self.helpPlanel:FindChild("Content/5").text = self.language.Content_5

    self:FindChild("RebateTip/Text1").text = self.language.rebateTip
    self:FindChild("RebateTip/Text2").text = self.language.autoSwitch

    self:FindChild("Guide/1/Text1").text = self.language.guide1_1
    self:FindChild("Guide/1/Text2").text = self.language.guideTip
    self:FindChild("Guide/2/Text").text = self.language.guide2_0
    self:FindChild("Guide/2/Text1").text = self.language.guide2_1
    self:FindChild("Guide/2/Text2").text = self.language.guideTip
    self:FindChild("Guide/3/Text").text = self.language.guide3_0
    self:FindChild("Guide/3/Text1").text = self.language.guide3_1
    self:FindChild("Guide/3/Text2").text = self.language.guideTip

    self.TaskFrame:FindChild("Right/NowNum/T").text = self.language.NowNum_T
end
--初始化界面
function MonthRebateView:InitView()
    if not self.gameDataMgr.GetSingleFlag(19) then
		self.guideStep = 1
        self:FindChild("Guide"):SetActive(true)
        self.mask:GetComponent("Image").material:SetVector("_Center", Vector4(10000,0,0,0))
        CC.Request("ReqSaveNewPlayerFlag",{Flag = 19, IsSingle = true})
        self.gameDataMgr.SetGuide(19, true)
	end
    if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= 10 then
        self:FindChild("Button/BtnNormal"):SetActive(false)
        -- self.bubbleList[3]:FindChild("Des").text = self.language.maxReward
    end
end
--vip按钮
function MonthRebateView:OnBtnVipClick()
    if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < 10 then
        CC.ViewManager.Open("StoreView")
    else
        self.viewCtr:ReqAcquireReward(self.curLevel)
    end
end
--刷新UI
function MonthRebateView:RefreshUI(data)
    if data.Type then
        self:FindChild("Bubble"):SetActive(true)
        --1本月流水，2本月返利,3上月返利
        if not self.viewCtr.curType or data.Type ~= self.viewCtr.curType then
            self:ShowFrame(data.Type == 1, data.Status)
        end
        if data.Type == 2 then
            --本月返利，不能领取
            self:FindChild("Button/BtnVip"):SetActive(false)
            self:FindChild("Button/BtnNormal"):SetActive(true)
            self:FindChild("Button/BtnNormal/Text").text = self.language.btnNormal_no
            self:FindChild("Button/BtnNormal/Gray/Text").text = self.language.btnNormal_no
            self:FindChild("Button/BtnNormal/Gray"):SetActive(true)
            self:FindChild("Bubble"):SetActive(false)
        elseif data.Type == 3 then
            if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < 10 then
                self:FindChild("Button/BtnVip"):SetActive(false)
            end
            self.bubbleList[3]:FindChild("Text").text = CC.uu.ChipFormat(data.BasePrize)
        end
    end
    if data.Score then
        self.curNum = data.Score
        self:NowLivenessValue()
    end
    if data.VipPrize then
        if data.VipPrize <= 0 and CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < 10 then
            self.bubbleList[1]:FindChild("Text").text = self.language.btnVip
        else
            self.bubbleList[1]:FindChild("Text").text = CC.uu.ChipFormat(data.VipPrize)
        end
    end
    if data.LoginPrize then
        if data.LoginPrize <= 0 then
            self.bubbleList[2]:FindChild("Text").text = self.language.unReward
        else
            self.bubbleList[2]:FindChild("Text").text = CC.uu.ChipFormat(data.LoginPrize)
        end
    end
    if data.StartTime and data.EndTime then
        local strTime = (data.Type and data.Type == 1 and self.language.time) or self.language.time1
         self.TimeText.text = string.format(strTime, CC.TimeMgr.GetTimeFormat5(data.StartTime), CC.TimeMgr.GetTimeFormat4(data.EndTime))
         self.TimeText2.text = string.format(strTime, CC.TimeMgr.GetTimeFormat5(data.StartTime), CC.TimeMgr.GetTimeFormat4(data.EndTime))
        end
    if data.TreasureList then
        --流水任务
        self:SetLevelStatus(data.TreasureList)
        self:SetBtnStatus()
    end
end

function MonthRebateView:ShowBox()
    for i = 1, 5, 1 do
        self.TaskFrame:FindChild("Box"..i):SetActive(false)
        if i == self.curLevel then
            self.TaskFrame:FindChild("Box"..i):SetActive(true)
            self.TaskBoxSpine = self.TaskFrame:FindChild("Box"..i):GetComponent("SkeletonGraphic")
        end
    end
end

--显示界面,中间箱子动画
function MonthRebateView:ShowFrame(isTask, status)
    self.TaskFrame:SetActive(isTask)
    self.RebateFrame:SetActive(not isTask)
    self:FindChild("RebateTip"):SetActive(false)

    local isShow = self.viewCtr.statusList[self.curLevel] == 2 and true or false
    local animalIndex = isShow and "stand03" or "stand02"
    local animalTime = isShow and 0.5 or 0

    if isTask then
        self:ShowBox()
        if self.TaskBoxSpine.AnimationState then
            self.TaskBoxSpine.AnimationState:ClearTracks()
            self.TaskBoxSpine.AnimationState:SetAnimation(0, "stand01", false)
        end
        local LotteryFun = nil
        LotteryFun = function ()
            self.TaskBoxSpine.AnimationState:ClearTracks()
            self.TaskBoxSpine.AnimationState:SetAnimation(0, animalIndex, false)
            self.TaskBoxSpine.AnimationState.Complete =  self.TaskBoxSpine.AnimationState.Complete - LotteryFun
            self:DelayRun(animalTime, function ()
                self:PlayAnim()
            end)
        end
        self.TaskBoxSpine.AnimationState.Complete =  self.TaskBoxSpine.AnimationState.Complete + LotteryFun
        self:FindChild("Button/BtnNormal/Text").text = self.language.btnNormal
        self:FindChild("Button/BtnNormal/Gray/Text").text = self.language.btnNormal
    else
        if status and status == 3 then
            self:FindChild("RebateTip"):SetActive(true)
            local time = 5
            self:FindChild("RebateTip/Time/Text").text = time
            self:StartTimer("SwtichStatus", 1, function()
                time = time - 1
                self:FindChild("RebateTip/Time/Text").text = time
                if time <= 0 then
                    self.viewCtr:Req_UW_UpdateStatus()
                    self:StopTimer("SwtichStatus")
                end
            end,-1)
        else
            self:FindChild("Box"):SetActive(false)

            if self.RebateBoxSpine.AnimationState then
                self.RebateBoxSpine.AnimationState:ClearTracks()
                self.RebateBoxSpine.AnimationState:SetAnimation(0, "stand01", false)
            end
            local LotteryFun = nil
            LotteryFun = function ()
                self.RebateBoxSpine.AnimationState:ClearTracks()
                self.RebateBoxSpine.AnimationState:SetAnimation(0, animalIndex, false)
                self.RebateBoxSpine.AnimationState.Complete =  self.RebateBoxSpine.AnimationState.Complete - LotteryFun
                self.RebateFrame:FindChild("effect"):SetActive(true)
                self:DelayRun(animalTime, function ()
                    self:PlayAnim()
                end)
            end
            self.RebateBoxSpine.AnimationState.Complete =  self.RebateBoxSpine.AnimationState.Complete + LotteryFun
        end
        self:FindChild("Button/BtnNormal/Text").text = self.language.btnRebate
        self:FindChild("Button/BtnNormal/Gray/Text").text = self.language.btnRebate
    end
end
--气泡动画
function MonthRebateView:PlayAnim()
    self.bubblePlay = true
    self.bubbleAnim.speed = 1
    self.bubbleAnim:Play("Bubble_Open",0,1)
    self:StopTimer("CheckAniState")
    self:StartTimer("CheckAniState", 0, function()
        local stateInfo = self.bubbleAnim:GetCurrentAnimatorStateInfo(0)
            if stateInfo.normalizedTime >= 1.0 then
                self.bubbleAnim:SetBool("loop",true)
                self:StopTimer("CheckAniState")
                self.bubblePlay = false
                self:FindChild("Bubble").localScale = Vector3(1,1,1)
            end
    end,-1)
end
--计算任务进度
function MonthRebateView:NowLivenessValue()

	self.NowNum.text = self.curNum > 99999999 and CC.uu.NumberFormat(self.curNum) or self.curNum
	local sliderValue = 0
	for i = 1, #self.viewCtr.TaskScale do
		if self.curNum <= self.viewCtr.TaskScale[i] then
			--计算当前活跃度在slider的多少
			if i > 1 then
				local gap = self.viewCtr.TaskScale[i] - self.viewCtr.TaskScale[i - 1]
				sliderValue = 19 * (i - 1) + 19 / gap * (self.curNum - self.viewCtr.TaskScale[i - 1])
			else
				sliderValue = 19 / 10 * math.floor(self.curNum / 10000000)
			end
			break
        else
            if i == 5 then
				sliderValue = 97
            end
		end
	end
	self.Slider:FindChild("Fill/effect"):SetActive(sliderValue > 0)
	self.Slider:GetComponent("Slider").value = sliderValue / 100
end
--设置任务状态
function MonthRebateView:SetLevelStatus(TreasureList)
    self.isBoxReward = false
    for i, v in ipairs(TreasureList) do
        local idx = i
        if self.LevelTab[idx] then
            self.LevelTab[idx]:FindChild("default"):SetActive(v.status ~= 1)
            self.LevelTab[idx]:FindChild("open"):SetActive(v.status == 1)
            self.LevelTab[idx]:FindChild("effect"):SetActive(v.status == 2)
            -- math.floor(v.Score / 10000000)
            self.LevelTab[idx]:FindChild("num").text = CC.uu.NumberFormat(v.Score)
            if v.status == 2 then
                self.isBoxReward = true
                self.curLevel = v.level
            end
        end
    end
	if not self.isBoxReward then
        self.curLevel = #self.viewCtr.TaskScale
    end
end

function MonthRebateView:SetBtnStatus()
    if not self.viewCtr.TaskScale[self.curLevel] then return end
    if self.curNum < self.viewCtr.TaskScale[self.curLevel] then
        self:FindChild("Button/BtnNormal/Gray"):SetActive(true)
        if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= 10 then
            self:FindChild("Button/BtnVip/Gray"):SetActive(true)
        end
    else
        self:FindChild("Button/BtnNormal/Gray"):SetActive(false)
        self:FindChild("Button/BtnVip/Gray"):SetActive(false)
    end
    if self.viewCtr.ShowPrizeList[self.curLevel] then
        self.bubbleList[3]:FindChild("Text").text = self.viewCtr.ShowPrizeList[self.curLevel]
    end

    local isShow = self.viewCtr.statusList[self.curLevel] == 2 and true or false
    for i = 1, 3, 1 do
        self:FindChild("Bubble/"..i.."/Lock"):SetActive(not isShow)
    end
end

function MonthRebateView:LevelBtnClick(index)
    self.curLevel = index
    self:ShowFrame(true,self.viewCtr.statusList[self.curLevel])

    --切换奖励展示
    -- if not self.bubblePlay then
    --     self.bubblePlay = true
    --     self.bubbleAnim:StartPlayback()
    --     self.bubbleAnim.speed = -1
    --     self.bubbleAnim:Play("Bubble_Open",0,1)
    --     self:DelayRun(0.2, function ()
            self:SetBtnStatus()
    --         self:PlayAnim()
    --     end)
    -- end
end

--关闭界面
function MonthRebateView:CloseView()
	self:ActionOut()
end
function MonthRebateView:ActionIn()
end
function MonthRebateView:ActionOut()
    self:Destroy()
end

function MonthRebateView:OnDestroy()
	self:CancelAllDelayRun()
    self:StopTimer("CheckAniState")
    self:StopTimer("SwtichStatus")
	if self.param and self.param.callBack then
		self.param.callBack()
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
end

return MonthRebateView