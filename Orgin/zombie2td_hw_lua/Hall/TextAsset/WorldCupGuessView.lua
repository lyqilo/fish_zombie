local CC = require("CC")

local WorldCupGuessView = CC.uu.ClassView("WorldCupGuessView")
local M = WorldCupGuessView

function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param or {};
	self.language = CC.LanguageManager.GetLanguage("L_WorldCupView")
    self.worldCup = CC.ConfigCenter.Inst():getConfigDataByKey("WorldCup")
    self.PrefabTab = {}
    --当前选择的洲
    self.curOption = 0
    --最低下注
    self.minBet = 1
    self.curBetNum = self.minBet
    --保底金币
    self.guaranteedCoins = 0
    --单注倍率
    self.baseBet = 20000
    --竞猜卡价值
    self.baseCard = 1000
    --是否使用竞猜卡
    self.useCard = false
    --最高下注
    self.maxBet = 0
    --当前选择下注的国家id
    self.curSelectNation = 0
    --剩余投注时间
    self.remainTime = 0
end

function M:OnCreate()
	self:InitUI()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
	self:InitTextByLanguage()
	self:AddClickEvent()
end

function M:CreateViewCtr(...)
	local viewCtrClass = require("View/WorldCupView/"..self.viewName.."Ctr")
	return viewCtrClass.new(self, ...)
end

function M:InitUI()
    self.leftPanel = self:FindChild("LeftPanel")
	self.rightPanel = self:FindChild("RightPanel")

    self.Champion = self.leftPanel:FindChild("Effect/Champion")
    self.date = self.leftPanel:FindChild("Date/Text")
    self.GirlSpine = self.leftPanel:FindChild("Girl"):GetComponent("SkeletonGraphic")

    self.Parent = self.rightPanel:FindChild("MNode/ScrollView/Content")
    self.item = self.rightPanel:FindChild("MNode/ScrollView/Content/Item")
    self.dropdown = self.rightPanel:FindChild("TNode/Dropdown"):GetComponent("Dropdown")
    self.betTimeText = self.rightPanel:FindChild("TNode/Time/Text")
    self.betNum = self.rightPanel:FindChild("BNode/BetNum")
    self.minusBtn = self.rightPanel:FindChild("BNode/Minus")
    self.addBtn = self.rightPanel:FindChild("BNode/Add")
    self.maxBtn = self.rightPanel:FindChild("BNode/Max")
    self.betBtn = self.rightPanel:FindChild("BNode/BetBtn")
    self.betGrayBtn = self.rightPanel:FindChild("BNode/BetGrayBtn")
    self.timeBtn = self.rightPanel:FindChild("BNode/TimeBtn")
    self.refreshTime = self.rightPanel:FindChild("BNode/TimeBtn/Text")
    self.maxSlider = self.rightPanel:FindChild("BNode/MaxSlider"):GetComponent("Slider")

    for _, v in pairs(self.worldCup) do
        if v.Id > 0 then
            local btnItem = self:CreateItem(v)
            self.PrefabTab[v.Id] = btnItem
        end
    end
    --冠军结果日期 12/18 10:00
    self.date.text = "22:00"
    self.leftPanel:FindChild("ChampionDate").text = "18/12"
    CC.HallNotificationCenter.inst():post(CC.Notifications.WorldCupJackpotChange, {type = "champion", node = self.rightPanel:FindChild("TNode/Jackpot/Num")});
    self:SetBetState()

    --每4秒小女孩跳一次舞
    local countDown = 4
    self:StartTimer("GirlLoopTimer", 1, function ()
        countDown = countDown - 1
        if countDown < 0 then
            countDown = 4
            self:GirlStateChange()
        end
    end, -1)
end

--创建国家item
function M:CreateItem(data)
    local t = {}
    t.item = CC.uu.newObject(self.item, self.Parent)
	t.item.name = tostring(data.Id)
    t.Id = data.Id
    t.toggle = t.item:FindChild("Toggle"):GetComponent("Toggle")
    t.effect = t.item:FindChild("effect")
    t.item:FindChild("Name").text = self.language.countryName[t.Id]
    local icon = "square_" .. t.Id
    self:SetImage(t.item:FindChild("Icon"), icon)
    UIEvent.AddToggleValueChange(t.item:FindChild("Toggle"), function(selected)
        if selected then
            if CC.DataMgrCenter.Inst():GetDataByKey("WorldCupData").IsShowWorldCupGift(self.curBetNum * self.baseBet, self.useCard) then
                --不能下注
                t.toggle.isOn = false
            else
                t.effect:SetActive(false)
                t.effect:SetActive(true)
                self:UpdateState(t.Id)
            end
        else
            if t.Id == self.curSelectNation then
                self:UpdateState(0)
            end
        end
    end)
    return t
end

function M:InitTextByLanguage()
	self.rightPanel:FindChild("TNode/Time").text = self.language.remainBetTime
    self.rightPanel:FindChild("MNode/Title").text = self.language.selectNation
    self.maxBtn:FindChild("Btn/Text").text = "MAX"
    self.maxBtn:FindChild("Gray/Text").text = "MAX"
    self.rightPanel:FindChild("BNode/MaxSlider/Text").text = "MAX"
    self.rightPanel:FindChild("BetStop/Node/Text").text = self.language.betNotStart
end

function M:AddClickEvent()
    self:AddClick(self.rightPanel:FindChild("MNode/LeftBtn"), function()
		self:LookMoreNation(false)
	end)
    self:AddClick(self.rightPanel:FindChild("MNode/RightBtn"), function()
		self:LookMoreNation(true)
	end)
    self:AddClick(self.minusBtn:FindChild("Btn"), function()
		self:OnBetNumClick(false)
	end)
    self:AddClick(self.addBtn:FindChild("Btn"), function()
		self:OnBetNumClick(true)
	end)
    self:AddClick(self.betBtn, function()
        if CC.DataMgrCenter.Inst():GetDataByKey("WorldCupData").IsShowWorldCupGift(self.curBetNum * self.baseBet, self.useCard) or not self.viewCtr.countryList[self.curSelectNation] then return end
        local info = self.viewCtr.countryList[self.curSelectNation]
        local param = {}
        param.Index = 2
        param.SpriteName = "square_" .. info.CountryId
        param.CountryID = self.curSelectNation
        param.Amount = self.curBetNum * self.baseBet
        param.Odds = info.Odds
        param.SureBtnCb = function()
            self.viewCtr:ReqPlayerBet(self.curSelectNation,self.curBetNum, info.Odds)
        end
        CC.ViewManager.OpenEx("WorldCupTipsView",param)
	end)
    self:AddClick(self.maxBtn:FindChild("Btn"), function()
        local isActive = self.maxSlider.transform.activeSelf
		self.maxSlider.transform:SetActive(not isActive)
	end)
    UIEvent.AddSliderOnValueChange(self.maxSlider.transform, function (value)
		self:OnSliderValueChange(value)
	end)
    self:InitDropDown()
end

--查看更多国家
function M:LookMoreNation(isRight)
    local dir = isRight and -1 or 1
    self:SetCanClick(false)
    self:RunAction(self.Parent,{"localMoveBy", dir * 752, 0, 0.2, ease=CC.Action.EOutSine,function()
        self:SetLeftOrRightState()
        self:SetCanClick(true)
    end})
end

--设置中间国家左右切换按钮的状态
function M:SetLeftOrRightState()
    if math.abs(self.Parent.localPosition.x + 376) < 1  then
        --aciton有时会有一些误差，绝对值在1区间
        self.rightPanel:FindChild("MNode/LeftBtn"):SetActive(false)
    else
        self.rightPanel:FindChild("MNode/LeftBtn"):SetActive(true)
    end
    if math.abs(self.Parent.localPosition.x - 752) > self.Parent.width then
        --是否还可以向右移动
        self.rightPanel:FindChild("MNode/RightBtn"):SetActive(false)
    else
        self.rightPanel:FindChild("MNode/RightBtn"):SetActive(true)
    end
end

--得到可以下注的筹码(竞猜卡换成筹码价值计算)
function M:GetCanBetCoins()
    local canCoins = self:GetCanBetCard() * self.baseCard
    if canCoins >= self.baseBet then
        --竞猜卡足够下注,优先使用竞猜卡
        self.useCard = true
    else
        self.useCard = false
        canCoins = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") - self.guaranteedCoins
    end
    self.betBtn:FindChild("Icon"):SetActive(not self.useCard)
    self.betBtn:FindChild("Coin"):SetActive(self.useCard)
    self.betGrayBtn:FindChild("Icon"):SetActive(not self.useCard)
    self.betGrayBtn:FindChild("Coin"):SetActive(self.useCard)
    return canCoins
end

--得到可以下注的竞猜卡
function M:GetCanBetCard()
    return CC.Player.Inst():GetSelfInfoByKey("EPC_WorldCup_QuizCard") or 0
end

function M:OnSliderValueChange(value)
	self.curBetNum = value
    self:SetBetState()
end

--设置国家数量
function M:SetNationNum(nationNum)
    self.rightPanel:FindChild("TNode/NationNum/Text").text = string.format("<color=#03DD2C>%s</color>/32", nationNum)
end

--初始化下拉框
function M:InitDropDown()
    local OptionData = UnityEngine.UI.Dropdown.OptionData
	self.dropdown:ClearOptions()
    for _,v in ipairs(self.viewCtr.dropDownList) do
        local option = self.language.areaName[v]
        local data = OptionData.New(option)
        self.dropdown.options:Add(data)
    end
    UIEvent.AddDropdownValueChange(self.dropdown.transform, function (value)
		self:OnDropdownValueChange(value)
	end)
	self.dropdown.value = self.curOption
	self.dropdown:RefreshShownValue()
end

--选择所属洲变化
function M:OnDropdownValueChange(index)
    self.curOption = index
    self:UpdateData()
    self:InitGuessState()
end

--初始化竞猜状态
function M:InitGuessState()
    if self.PrefabTab[self.curSelectNation] then
        self.PrefabTab[self.curSelectNation].toggle.isOn = false
    end
    self:UpdateState(0)
end

--更新选择状态
function M:UpdateState(nation)
    self.curSelectNation = nation
    self.maxBet = self.viewCtr.countryList[self.curSelectNation] and self.viewCtr.countryList[self.curSelectNation].BetMax or 0
    if self.curSelectNation == 0 then
        --没有选择
        self.maxBet = 0
    end
    local maxValue = math.floor(self.maxBet / self.baseBet)
    local canCoins = self:GetCanBetCoins()
    if canCoins < self.maxBet then
        --可以用来下注等价筹码的数量
        local chouMa = canCoins
        maxValue = math.floor(chouMa / self.baseBet)
    end
    self.maxSlider.maxValue = maxValue
    self.maxBtn:FindChild("Gray"):SetActive(maxValue <= 0)
    self.maxSlider.transform:SetActive(false)
    self.curBetNum = self.minBet
    self:SetBetState()
end

--改变下注金额
function M:OnBetNumClick(isAdd)
    --每日加注或减注都是最小下注额
    if isAdd then
        self.curBetNum = self.curBetNum + self.minBet
    else
        self.curBetNum = self.curBetNum - self.minBet
    end
    self.maxSlider.value = self.curBetNum
    self:SetBetState()
end

--下注按钮状态变化
function M:SetBetState()
    local isShowBet = false
    local canCoins = self:GetCanBetCoins()
    if self.worldCup[self.curSelectNation] and self.curSelectNation > 0 and canCoins >= self.curBetNum * self.baseBet then
        isShowBet = true
    end
    self.betNum.text = self.curBetNum
    self.betBtn:SetActive(isShowBet)
    self.betGrayBtn:SetActive(not isShowBet)
    --下注数换算成筹码数量
    local coins = self.curBetNum * self.baseBet
    if self.useCard then
        --使用竞猜卡，换算卡数量
        coins = coins / self.baseCard
    end
    self.betBtn:FindChild("Text").text = CC.uu.Chipformat2(coins)
    self.betGrayBtn:FindChild("Text").text = CC.uu.Chipformat2(coins)

    local mayAdd = self.curBetNum + self.minBet
    if canCoins >= mayAdd * self.baseBet and self.maxBet >= mayAdd * self.baseBet then
        --可以加注
        self.addBtn:FindChild("Gray"):SetActive(false)
    else
        self.addBtn:FindChild("Gray"):SetActive(true)
    end
    local mayMin = self.curBetNum - self.minBet
    if mayMin >= self.minBet then
        --可以减注
        self.minusBtn:FindChild("Gray"):SetActive(false)
    else
        self.minusBtn:FindChild("Gray"):SetActive(true)
    end
end

--投注剩余时间
function M:SetBetTime()
    self.betTimeText.text = CC.uu.TicketFormat2(self.remainTime)
    self:StartTimer("GuessBetTimer", 1, function ()
        self.remainTime = self.remainTime - 1
        if self.remainTime < 0 then
            self:StopTimer("GuessBetTimer")
            self.rightPanel:FindChild("BetStop"):SetActive(true)
        else
            self.betTimeText.text = CC.uu.TicketFormat2(self.remainTime)
        end
    end, -1)
end

function M:UpdateData()
    local param = {}
    for _, v in pairs(self.viewCtr.countryList) do
        if v.CountryId > 0 then
            if self.curOption == 0 then
                table.insert(param, v)
            elseif v.RegionId == self.curOption then
                table.insert(param, v)
            end
        end
    end
    -- self.rightPanel:FindChild("MNode/LeftBtn"):SetActive(false)
    for _,v in pairs(self.PrefabTab) do
        v.item:SetActive(false)
    end
    if not next(param) then return end
    for _,v in pairs(param) do
        if self.PrefabTab[v.CountryId] then
            self.PrefabTab[v.CountryId].item:SetActive(true)
        end
    end
    self:DelayRun(0.2, function ()
        self.Parent.localPosition = Vector3(-376, 0, 0)
        self:SetLeftOrRightState()
    end)
end

--更新赔率
function M:RefreshOdds(nationId, odds)
    if self.PrefabTab[nationId] then
        self.PrefabTab[nationId].item:FindChild("Odds").text = odds
    end
end

function M:RefreshInfo(info)
    if info.Country then
        self:SetNationNum(#info.Country)
        self:UpdateData()
    end
    if info.StartBetTime then
        local curTime = CC.TimeMgr.GetSvrTimeStamp()
        if curTime < info.StartBetTime then
            self.rightPanel:FindChild("TNode/Time"):SetActive(false)
            self.rightPanel:FindChild("BetStop"):SetActive(true)
        end
    end
    if info.EndBetTime then
        local curTime = CC.TimeMgr.GetSvrTimeStamp()
        self.remainTime = info.EndBetTime - curTime
        if self.remainTime > 0 then
            self:SetBetTime()
        else
            self.rightPanel:FindChild("TNode/Time"):SetActive(false)
            self.rightPanel:FindChild("BetStop/Node/Text").text = self.language.betNotEnd
            self.rightPanel:FindChild("BetStop"):SetActive(true)
        end
    end
    if info.BaseBet then
        self.baseBet = info.BaseBet
    end
    if info.GuaranteedCoins then
        self.guaranteedCoins = info.GuaranteedCoins
    end
    if info.NextRefreshTime and info.NextRefreshTime > 0 then
        self.timeBtn:SetActive(true)
        self:RefreshBetTime(info.NextRefreshTime)
    end
    if info.ChampionCountryId and info.ChampionCountryId > 0 and self.worldCup[info.ChampionCountryId] then
        self.leftPanel:FindChild("Effect/WenHao"):SetActive(false)
        self.Champion:SetActive(true)
        self:SetImage(self.Champion,"circle_" .. info.ChampionCountryId)
    end
    if info.QuizCardValue then
        self.baseCard = info.QuizCardValue
    end
end

--刷新下注时间
function M:RefreshBetTime(time)
    self:StopTimer("RefreshBetTimer")
    self:InitGuessState()
    local countDown = time - CC.TimeMgr.GetSvrTimeStamp()
    self.refreshTime.text = CC.uu.TicketFormat(countDown, true)
    if countDown < 0 then
        self.timeBtn:SetActive(false)
        return
    end
    self:StartTimer("RefreshBetTimer", 1, function ()
        countDown = countDown - 1
        if countDown < 0 then
            self:StopTimer("RefreshBetTimer")
            self.viewCtr:ReqGetWorldCupBetInfo()
            CC.HallNotificationCenter.inst():post(CC.Notifications.WorldCupTipsViewNotify)
        else
            self.refreshTime.text = CC.uu.TicketFormat(countDown, true)
        end
    end, -1)
end

function M:GirlStateChange()
	if self.GirlSpine.AnimationState then
        self.GirlSpine.AnimationState:ClearTracks()
        self.GirlSpine.AnimationState:SetAnimation(0, "stand02", false)
	end
	local fun
	fun = function ()
        self.GirlSpine.AnimationState:ClearTracks()
        self.GirlSpine.AnimationState:SetAnimation(0, "stand", true)
        self.GirlSpine.AnimationState.Complete =  self.GirlSpine.AnimationState.Complete - fun
    end
    self.GirlSpine.AnimationState.Complete =  self.GirlSpine.AnimationState.Complete + fun
end

function M:ActionIn()
    local rightNode = self:FindChild("RightPanel");
	local x,y = rightNode.x,rightNode.y;
	rightNode.x = -900;
	self:RunAction(rightNode, {"localMoveTo", x, y, 0.3, ease = CC.Action.EOutSine, function() end})

	local leftNode = self:FindChild("LeftPanel");
	local x,y = leftNode.x,leftNode.y;
	leftNode.x = -1300;
	self:RunAction(leftNode, {"localMoveTo", x, y, 0.3, delay = 0.2, ease = CC.Action.EOutSine, function() end})
end

function M:ActionOut(cb)
    local leftNode = self:FindChild("LeftPanel");
	self:RunAction(leftNode, {"localMoveTo", -1300, leftNode.y, 0.3, ease = CC.Action.EOutSine, function() end})

	local rightNode = self:FindChild("RightPanel");
	self:RunAction(rightNode, {"localMoveTo", -900, rightNode.y, 0.3, delay = 0.2, ease = CC.Action.EOutSine, function()
		self:Destroy();
		if cb then cb() end
	end})
end

function M:OnDestroy()
    self:StopAllTimer()
	if self.viewCtr then
		self.viewCtr:Destroy()
	end
    for _,v in ipairs(self.PrefabTab) do
		v.toggle = nil
	end
    self.GirlSpine = nil
end

return M