local CC = require("CC")
local AgentMyGrades = CC.uu.ClassView("AgentMyGrades")

function AgentMyGrades:ctor(param)
	self:InitVar(param);
    self:RegisterEvent()
end

function AgentMyGrades:InitVar(param)
	self.param = param or {}
    self.animDelay = 0.5
    self.showTip = false
end

function AgentMyGrades:OnCreate()
    self.language = CC.LanguageManager.GetLanguage("L_AgentView")
    self.agentConfig = CC.ConfigCenter.Inst():getConfigDataByKey("AgentConfig")
	self:InitTr()
	self:InitTextByLanguage()
end

function AgentMyGrades:InitTr()
    self.CurLevel = self:FindChild("Level/CurLevel")
    self.NextLevel = self:FindChild("Level/NextLevel")

    self:AddClick(self:FindChild("btnHelp"), function()
        self:OnBtnHelp()
    end)
    self:AddClick(self:FindChild("RulePlane/BtnClose"), function()
        self:FindChild("RulePlane"):SetActive(false)
    end)
    self:AddClick(self:FindChild("BtnGet"), function()
        CC.HallNotificationCenter.inst():post(CC.Notifications.OnChangeAgentView, "AgentShareView")
    end)
    self:AddClick(self:FindChild("Animator/Plane/Btn"), function()
        self:FindChild("Animator"):SetActive(false)
    end)
    self:AddClick(self:FindChild("SliderNum/NeedText/Image"), function()
        self.showTip = not self.showTip
        self:FindChild("SliderNum/NeedText/Image/explain"):SetActive(self.showTip)
    end)
    CC.Request("ReqAgentData")
end

function AgentMyGrades:InitTextByLanguage()
	self:FindChild("Tip").text = self.language.myGradesTip
    self:FindChild("BtnGet/Text").text = self.language.myGradesBtnGet
    self:FindChild("Reward").text = self.language.myGradesReward
    self:FindChild("CountDown").text = self.language.myGradesCountDown
    self:FindChild("Level/CurLevel/Name/Text").text = self.language.myGradesCurLevel
    self:FindChild("Level/NextLevel/Name/Text").text = self.language.myGradesNextLevel
    self:FindChild("Animator/Plane/Btn/Text").text = self.language.myGradesBtn
    local str = "<color=#33FF00FF>√</color>"
    self.CurLevel:FindChild("Send").text = string.format(self.language.myGradesSend, str)
    self.NextLevel:FindChild("Send").text = string.format(self.language.myGradesSend, str)

    self:FindChild("RulePlane/Title/Text").text = self.language.ruletitle
    self:FindChild("RulePlane/ScrollView/Viewport/Content/Text1").text = self.language.myGradesRule1
    self:FindChild("RulePlane/ScrollView/Viewport/Content/Text2").text = self.language.myGradesRule2
    self:FindChild("RulePlane/ScrollView/Viewport/Content/Text3").text = self.language.myGradesRule3
    self:FindChild("RulePlane/ScrollView/Viewport/Content/Title/1/Text").text = self.language.myGradesRuleLevel
    self:FindChild("RulePlane/ScrollView/Viewport/Content/Title/2/Text").text = self.language.myGradesRuleSend
    self:FindChild("RulePlane/ScrollView/Viewport/Content/Title/3/Text").text = self.language.myGradesRuleDivide
    self:FindChild("RulePlane/ScrollView/Viewport/Content/Title/4/Text").text = self.language.myGradesRuleTable
    self:FindChild("RulePlane/ScrollView/Viewport/Content/Title/5/Text").text = self.language.myGradesReward
    self:FindChild("SliderNum/NeedText/Image/explain/Text").text = self.language.myGradesPeopleTip
    for i = 1, 6 do
        self:FindChild(string.format("RulePlane/ScrollView/Viewport/Content/Level%s/1/Text", i)).text = self.language.myGradesList[i]
        self:FindChild(string.format("RulePlane/ScrollView/Viewport/Content/Level%s/2/Text", i)).text = "<color=#33FF00FF>√</color>"
        if self.agentConfig[i].Divide > 0 then
            str = string.format("%s%%up", self.agentConfig[i].Divide)
        end
        self:FindChild(string.format("RulePlane/ScrollView/Viewport/Content/Level%s/3/Text", i)).text = str
        if self.agentConfig[i].Table > 0 then
            str = string.format("%s%%up", self.agentConfig[i].Table)
        end
        self:FindChild(string.format("RulePlane/ScrollView/Viewport/Content/Level%s/4/Text", i)).text = str
        if i == 1 then
            self:FindChild(string.format("RulePlane/ScrollView/Viewport/Content/Level%s/5/Text", i)).text = self.language.myGradesLock
        else
            self:FindChild(string.format("RulePlane/ScrollView/Viewport/Content/Level%s/5/Text", i)).text = CC.uu.ChipFormat(self.agentConfig[i].Reward)
        end
    end
end

function AgentMyGrades:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqAgentDataResq,CC.Notifications.NW_ReqAgentData)
end

function AgentMyGrades:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function AgentMyGrades:OnBtnHelp( )
    self:FindChild("RulePlane"):SetActive(true)
end

function AgentMyGrades:ReqAgentDataResq(err, param)
    log("err = ".. err.."  "..CC.uu.Dump(param, "ReqAgentDataResq",10))
	if err == 0 then
		self:SetLevelInfo(param)
        self:SetCountDown(param.WeekCountdown)
        self:PlayAnim(param)
	end
end

--等级信息
function AgentMyGrades:SetLevelInfo(param)
    local curLevel = param.Level or 1
    if curLevel > 6 then curLevel = 6 end
    local curInfo = self.agentConfig[curLevel] or {}
    local strDivide = "<color=#33FF00FF>√</color>"
    local strTable = "<color=#33FF00FF>√</color>"
    local unlock = "<color=#FF002FFF>X</color>"
    if curInfo.Divide > 0 then
        strDivide = string.format("<color=#FFE90C>%s%%up</color>", curInfo.Divide)
    end
    if curInfo.Table > 0 then
        strTable = string.format("<color=#FFE90C>%s%%up</color>", curInfo.Table)
    end
    self.CurLevel:FindChild("Divide").text = string.format(self.language.myGradesDivide, strDivide)
    self.CurLevel:FindChild("Table").text = string.format(self.language.myGradesTable, strTable)
    self:SetImage(self.CurLevel:FindChild("Icon"), curInfo.Icon)
    self:SetImage(self.CurLevel:FindChild("IconName"), curInfo.IconName)
    self.CurLevel:FindChild("IconName"):GetComponent("Image"):SetNativeSize()

    local taskInfo = curInfo
    if curLevel < 6 and param.promoteNum >= curInfo.PeopleNum then
        --推广人数完成当前任务，显示下个等级任务
        local nextInfo = self.agentConfig[curLevel + 1] or {}
        taskInfo = nextInfo
        if nextInfo.Divide > 0 then
            strDivide = string.format("<color=#FFE90C>%s%%up</color>", nextInfo.Divide)
        end
        if nextInfo.Table > 0 then
            strTable = string.format("<color=#FFE90C>%s%%up</color>", nextInfo.Table)
        end
        self.NextLevel:FindChild("Divide").text = string.format(self.language.myGradesDivide, strDivide)
        self.NextLevel:FindChild("Table").text = string.format(self.language.myGradesTable, strTable)
        self:SetImage(self.NextLevel:FindChild("Icon"), nextInfo.Icon)
        self:SetImage(self.NextLevel:FindChild("IconName"), nextInfo.IconName)
        self.NextLevel:FindChild("IconName"):GetComponent("Image"):SetNativeSize()
        self.NextLevel:SetActive(true)
        self:FindChild("Level/Arrow"):SetActive(true)
    else
        self.NextLevel:SetActive(false)
        self:FindChild("Level/Arrow"):SetActive(false)
        if curLevel == 1 then
            --黑铁等级没有完成
            self:FindChild("Reward").text = self.language.myGradesLock
            local propIcon = self:FindChild("Reward/Prop/Icon")
            self:SetImage(propIcon, curInfo.Icon)
            propIcon:GetComponent("Image"):SetNativeSize()
            propIcon.localScale = Vector3(0.25,0.25,0.25)
            self:FindChild("Reward/Prop/Num"):SetActive(false)
            self.CurLevel:FindChild("Send").text = string.format(self.language.myGradesSend, unlock)
            self.CurLevel:FindChild("Divide").text = string.format(self.language.myGradesDivide, unlock)
            self.CurLevel:FindChild("Table").text = string.format(self.language.myGradesTable, unlock)
        end
    end
    self:FindChild("SliderNum/NeedText").text = string.format(self.language.myGradesNeedPeople, taskInfo.PeopleNum)
    self:FindChild("SliderNum/Text").text = string.format("%s/%s", param.promoteNum, taskInfo.PeopleNum)
    self:FindChild("SliderNum"):GetComponent("Slider").value = param.promoteNum / taskInfo.PeopleNum
    self:FindChild("Reward/Prop"):SetActive(true)
    self:FindChild("Reward/Prop/Num").text = CC.uu.ChipFormat(taskInfo.Reward)
end

--剩余周任务时间
function  AgentMyGrades:SetCountDown(countDown)
    countDown = countDown < 0 and 0 or countDown
	local day = math.floor(countDown / 86400)
    local hours = math.ceil((countDown - day * 86400) / 3600)
    self:FindChild("CountDown/Text").text = string.format(self.language.myGradesTime, day, hours)
end

function  AgentMyGrades:PlayAnim(param)
    self:DelayRun(self.animDelay, function ()
        local before = param.BeforeLevel
        local curLevel = param.Level
        local beforeGrade = self.language.myGradesList[curLevel]
        local curGrade = self.language.myGradesList[curLevel]
        if param.LevelStatus == 1 then
            --升级
            self:FindChild("Animator/Plane/animTip").text = string.format(self.language.myGradesAnimUpgrade, curGrade, curGrade, curGrade)
            self:PlayUpgradeAnim(curLevel)
        elseif param.LevelStatus == 2 then
            --降级
            self:FindChild("Animator/Plane/animTip").text = string.format(self.language.myGradesAnimDegrade, beforeGrade, curGrade)
            self:PlayDegradeAnim(before, curLevel)
        elseif param.LevelStatus == 3 then
            --初始级
            self:FindChild("Animator/Plane/animTip").text = string.format(self.language.myGradesAnimTip, curGrade)
            self:PlayUpgradeAnim(curLevel)
        end
    end)
end

--等级提升动画
function  AgentMyGrades:PlayUpgradeAnim(curLevel)
    self:SetImage(self:FindChild("Animator/Plane/Icon"), self.agentConfig[curLevel].Icon)
    self:SetImage(self:FindChild("Animator/Plane/IconName"), self.agentConfig[curLevel].IconName)
    self:FindChild("Animator/Plane/IconName"):GetComponent("Image"):SetNativeSize()
    CC.Request("ReqHomeStatus", {StatusType = 1})
    self:FindChild("Animator"):SetActive(true)
    local plane = self:FindChild("Animator/Plane")
    local effect = self:FindChild("Animator/Effect")
    plane.localScale = Vector3(0, 0, 1)
    effect:SetActive(false)

    CC.Sound.StopEffect()
    CC.Sound.PlayHallEffect("upgrade_win.ogg")
	self:RunAction(plane, {
        {"fadeToAll", 0, 0},
        {"fadeToAll", 255, 0.5, function()
            effect:SetActive(true)
            self:FindChild("Animator/Plane/Btn"):SetActive(true)
            self:FindChild("Animator/Plane/animTip"):SetActive(true)
        end},
	});
    self:RunAction(plane, {
        {"scaleTo", 1, 1, 0.5, ease = CC.Action.EOutSine},
    });
end

--降级动画
function  AgentMyGrades:PlayDegradeAnim(before, curLevel)
    self:SetImage(self:FindChild("Animator/Plane/Icon"), self.agentConfig[before].Icon)
    self:SetImage(self:FindChild("Animator/Plane/IconName"), self.agentConfig[before].IconName)
    self:FindChild("Animator/Plane/IconName"):GetComponent("Image"):SetNativeSize()
    self:FindChild("Animator"):SetActive(true)
    local plane = self:FindChild("Animator/Plane")
    local effect = self:FindChild("Animator/Effect")
    plane.localScale = Vector3(1, 1, 1)
    effect:SetActive(false)
    self:FindChild("Animator/Plane/Btn"):SetActive(false)
    self:FindChild("Animator/Plane/animTip"):SetActive(false)
    CC.Sound.StopEffect()
    CC.Sound.PlayHallEffect("degrade_fail.ogg")
	self:RunAction(plane, {
			{"fadeToAll", 255, 0},
            {"fadeToAll", 0, 0.5, function()
                self:DelayRun(0.2, function ()
                    self:PlayUpgradeAnim(curLevel)
                end)
            end},
		});
    self:RunAction(plane, {
		{"scaleTo", 0, 0, 0.5, ease = CC.Action.EOutSine},
	});
end

function AgentMyGrades:ActionIn()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
		{"fadeToAll", 0, 0},
		{"fadeToAll", 255, 0.5, function()
            self:SetCanClick(true)
            self.animDelay = 0
        end}
	});
end

function AgentMyGrades:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function AgentMyGrades:OnDestroy()
    self:UnRegisterEvent()
    self:CancelAllDelayRun()
end

return AgentMyGrades;