local CC = require("CC")
local MonopolyView = CC.uu.ClassView("MonopolyView")

function MonopolyView:ctor(param)
    self.param = param or {}
	self.createTime = os.time()+math.random()
    self.BgTab = {}
    self.ElephantTab = {}
    self.curElephantSpine = nil
    self.MapGridTab = {}
    self.maxGrid = 20
    self.GiftInfo = {}
    self.CurMapCfg = nil
    --神秘奖选择的牌
    self.plateList = {}
    self.isSelectPlate = false
    --当前地图使用道具数量
    self.curMapUseNum = 1
    self.curLocation = 1
    --当前的进度
    self.curProgressBar = 0
    self.giftList = {[30370] = true, [30371] = true, [30372] = true, [30373] = true, [30374] = true,}
    --自动
    self.AutoDoSpin = false
    self.ActionSpeed = 1
end

function MonopolyView:OnCreate()
	self.propCfg = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
    self.monopolyCfg = CC.ConfigCenter.Inst():getConfigDataByKey("MonopolyConfig")

    self:InitUI()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
end

function MonopolyView:InitUI()
    for i = 1, 3 do
		self.BgTab[i] = self:FindChild(string.format("Frame/Bg/%s", i))
	end
    for i = 1, 10 do
		self.ElephantTab[i] = self:FindChild(string.format("Frame/Elephant/%s", i))
	end
    for i = 1, self.maxGrid do
		self.MapGridTab[i] = self:FindChild(string.format("Frame/Map/%s", i))
	end
    local chipNode = self:FindChild("Frame/ChipNode")
    self.chipCounter = CC.HeadManager.CreateChipCounter({parent = chipNode, hideBtnAdd = true})
    self.WaterNum = self:FindChild("Frame/WaterNum/Text")
    self.JkNum = self:FindChild("Frame/JK/Text")
    self.Player = self:FindChild("Frame/Player")
    self.PlayerGo = self.Player:FindChild("go")
    self.PlayerSpine = self.PlayerGo:GetComponent("SkeletonGraphic")

    self.GiftItem = self:FindChild("Frame/GiftItem")
	self.Content = self:FindChild("Frame/Scroll/Viewport/Content")
    self.Progress = self:FindChild("Frame/Progress/Slider"):GetComponent("Slider")
    self.ProgressText = self:FindChild("Frame/Progress/Text")
    self.CurLevel = self:FindChild("Frame/Progress/Level")
    --神秘奖选择界面
    self.SelectReward = self:FindChild("Frame/SelectReward")
    self.hand = self.SelectReward:FindChild("Effect_shouzhi")
    for i = 1, 2 do
        local index = i
        self.plateList[index] = self.SelectReward:FindChild(string.format("RewardList/%s", index))
        self.plateList[index]:FindChild("bg").onClick = function ()
            self:PlayMysticalAnim(index)
        end
    end
    self:AddLongClick(self:FindChild("Frame/Btn/Spin"),
		{
			funcClick = function ()
				self:ClickBtnSpin()
			end,
			funcLongClick = function()
                self:ClickBtnSpin(true)
			end,
			time = 0.5,
		})
    self:FindChild("Frame/Btn/Stop").onClick = function ()
		self:SetAutoDo(false)
	end
    self:AddClick("Frame/BtnExplain", "ClickExplain")
    self:AddClick("Frame/BtnRank",function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnCollectionViewJumpToView, "MonopolyRankView")
	end)
	self:AddClick("BtnClose", "CloseView")
    self.diceIcon = self:FindChild("Frame/Btn/Dice")
    self.diceAni = self:FindChild("Frame/DiceAnimator"):GetComponent("Animator")

    self:LanguageSwitch()
    self:SetWaterNum()
end

--语言切换
function MonopolyView:LanguageSwitch()
    self.language = self:GetLanguage()
    self:FindChild("Frame/Btn/Des").text = self.language.btn_spin
    self.SelectReward:FindChild("Text").text = self.language.SelectReward
end

function MonopolyView:ClickExplain()
    CC.ViewManager.Open("MonopolyRuleView")
end
--设置自动状态
function MonopolyView:SetAutoDo(isAutodo)
    self.AutoDoSpin = isAutodo
    if self.AutoDoSpin then
        self.ActionSpeed = 1.5
    else
        self.ActionSpeed = 1
    end
    self:FindChild("Frame/Btn/Stop"):SetActive(isAutodo)
end

function MonopolyView:ClickBtnSpin(isLongClick)
    if not CC.ViewManager.IsHallScene() then
        CC.ViewManager.ShowTip(self.language.gameTip)
        return
    end
    if CC.Player.Inst():GetSelfInfoByKey("EPC_TenGift_Sign_97") >= self.curMapUseNum then
        if isLongClick then
            self:SetAutoDo(true)
        end
        self.viewCtr:ReqPlayerSpin()
    else
        self:SetAutoDo(false)
        CC.ViewManager.ShowMessageBox(self.language.spinTip)
    end
end

--设置显示地图
function MonopolyView:SetMapShow(index)
    if index > 3 or index <= 0 then return end
    for i = 1, 3 do
		self.BgTab[i]:SetActive(index == i)
	end
end
--设置大象显示
function MonopolyView:SetElephantShow(index)
    if index > 10 or index <= 0 then return end
    for i = 1, 10 do
		self.ElephantTab[i]:SetActive(index == i)
	end
    --当前的大象spine
    self.curElephantSpine = self.ElephantTab[index]:GetComponent("SkeletonGraphic")
    if self.curElephantSpine then
        if self.curElephantSpine.AnimationState then
            self.curElephantSpine.AnimationState:ClearTracks()
            self.curElephantSpine.AnimationState:SetAnimation(0, "idle", true)
        end
    end
end
--设置水滴数
function MonopolyView:SetWaterNum()
    local count = CC.Player.Inst():GetSelfInfoByKey("EPC_TenGift_Sign_97")
    self.WaterNum.text = CC.uu.DiamondFortmat(count)
end
--设置jk数
function MonopolyView:SetJackPotNum(count)
    self.JkNum.text = CC.uu.Chipformat2(count, true)
end

--设置界面信息
function MonopolyView:SetViewInfo(param)
    if param.MapId then
        local mapId = param.MapId
        if mapId > self.monopolyCfg.MaxMapNum then
            mapId = self.monopolyCfg.MaxMapNum
        end
        self.CurMapCfg = self.monopolyCfg[mapId]
        if self.CurMapCfg then
            self:SetMapShow(self.CurMapCfg.MapBg)
            self:SetElephantShow(self.CurMapCfg.ElephantIndex)
            self.curMapUseNum = self.CurMapCfg.UseNum or 1
            self:FindChild("Frame/Consume/Text").text = string.format(self.language.ConsumeText, self.curMapUseNum)
            self:FindChild("Frame/Btn/Num").text = string.format("x%s", self.curMapUseNum)
            self:InitMapInfo(self.CurMapCfg.Rewards)
            if param.ProgressBar then
                self.curProgressBar = param.ProgressBar
                self:SetProgress()
            end
        end
    end
    if param.CurrentLever then
        --当前等级
        local curLevel = param.CurrentLever
        self.CurLevel.text = "V" .. curLevel
    end
    if param.CurrentJPPool then
        self:SetJackPotNum(param.CurrentJPPool)
    end
    if param.CurrentLocation then
        self.curLocation = param.CurrentLocation
        if self.MapGridTab[self.curLocation] then
            self.Player.localPosition = self.MapGridTab[self.curLocation].localPosition
            self:SetMapGridState(self.curLocation, true)
            self.Player:SetActive(true)
        end
    end
end

--设置进度
function MonopolyView:SetProgress(changeNum)
    if changeNum then
        local targetValue = (self.curProgressBar + changeNum) * 10
        local startValue = self.curProgressBar * 10
        local sound2 = true
        local sound3 = true
        CC.Sound.PlayHallEffect("progress_1")
        self:RunAction(self.Progress, {"to", startValue, targetValue, 0.5, function(value)
            if sound2 and value > startValue + 4 then
                sound2 = false
                CC.Sound.PlayHallEffect("progress_2")
            elseif sound3 and value > startValue + 8 then
                sound3 = false
                CC.Sound.PlayHallEffect("progress_3")
            end
            self.Progress.value = value / (self.CurMapCfg.ProgressNum * 10)
        end});
        self.curProgressBar = self.curProgressBar + changeNum
    end
    if self.CurMapCfg then
        self.Progress.value = self.curProgressBar / self.CurMapCfg.ProgressNum
        self.ProgressText.text = string.format("%s/%s",self.curProgressBar, self.CurMapCfg.ProgressNum)
    end
end
--设置格子显示状态，是否在格子上
function MonopolyView:SetMapGridState(index, isStay)
    if self.MapGridTab[index] then
        self.MapGridTab[index]:FindChild("Effect/step"):SetActive(isStay)
        self.MapGridTab[index]:FindChild("Effect/default"):SetActive(isStay)
        self.MapGridTab[index]:FindChild("Grid"):SetActive(not isStay)
        self.MapGridTab[index]:FindChild("Text"):SetActive(not isStay)
    end
end
--初始化地图信息
function MonopolyView:InitMapInfo(data)
    for k, v in ipairs(data) do
        if self.MapGridTab[k] and k ~= 5 and k ~= 10 and k ~= 15 and k ~= 20 then
            if v.Count <= 0 then
                self.MapGridTab[k]:FindChild("Grid/Icon"):SetActive(false)
                self.MapGridTab[k]:FindChild("Text").text = ""
            else
                local iconImage = self.propCfg.GetIcon(v.PropId)
                if not iconImage then
                    self.MapGridTab[k]:FindChild("Grid/Icon"):SetActive(false)
                else
                    self.MapGridTab[k]:FindChild("Grid/Icon"):SetActive(true)
                end
                self:SetImage(self.MapGridTab[k]:FindChild("Grid/Icon"), iconImage)
                self.MapGridTab[k]:FindChild("Grid/Icon"):GetComponent("Image"):SetNativeSize()
                local count = v.PropId == 98 and "" or v.Count
                self.MapGridTab[k]:FindChild("Text").text = CC.uu.Chipformat2(count)
            end
        end
    end
end

--骰子动画
function MonopolyView:PlayDiceAnimator(diceNum)
    if not diceNum and diceNum > 6 then return end
    self.diceAni:SetActive(false)
    self.diceAni:SetActive(true)
    self.diceIcon:SetActive(false)
    CC.Sound.PlayHallEffect("playDice")
    self.diceAni:Play(string.format("point_%s", diceNum))
    self:DelayRun(1.5, function ()
        self:PlayerMoveTo(diceNum)
    end)
    self.viewCtr.PlayAnim = true
    self:SetCanClick(false)
end
--移动计算处理
function MonopolyView:PlayerMoveTo(diceNum)
    self:DelayRun(0.1, function ()
        self:SetMapGridState(self.curLocation, false)
    end)
    local targetPos = self.curLocation + diceNum
    local index = 0
    local speed = self.ActionSpeed
    for i = self.curLocation + 1, targetPos do
        self:DelayRun(index * 0.4 / speed, function ()
            self:MoveToPos(i, i == targetPos, speed)
        end)
        index = index + 1
    end
end
function MonopolyView:MoveToPos(pos, isEnd, speed)
    if pos > self.maxGrid then
        --超过地图格子
        pos = pos - self.maxGrid
    end
    if self.MapGridTab[pos] then
        self:RunAction(self.Player,
            {"localMoveTo", self.MapGridTab[pos].localPosition.x,self.MapGridTab[pos].localPosition.y, 0.3 / speed,function ()
                if isEnd then
                    self.curLocation = pos
                    self:MoveEnd()
                else
                    self.MapGridTab[pos]:FindChild("pass"):SetActive(true)
                    self:DelayRun(0.1, function ()
                        self.MapGridTab[pos]:FindChild("pass"):SetActive(false)
                    end)
                end
            end})
        --玩家跳动画
        CC.Sound.PlayHallEffect("playerJump")
        if self.PlayerSpine.AnimationState then
            self.PlayerSpine.AnimationState:ClearTracks()
            self.PlayerSpine.AnimationState:SetAnimation(0, "jump", false)
        end
        self:RunAction(self.PlayerGo,
            {{"localMoveTo", self.PlayerGo.localPosition.x, self.PlayerGo.localPosition.y + 40, 0.15 / speed},
            {"localMoveTo", self.PlayerGo.localPosition.x, self.PlayerGo.localPosition.y, 0.15 / speed, function ()
                if self.PlayerSpine.AnimationState then
                    self.PlayerSpine.AnimationState:ClearTracks()
                    self.PlayerSpine.AnimationState:SetAnimation(0, "stand", true)
                end
            end}}
        )
    end
end

function MonopolyView:MoveEnd()
    local isMystical = false
    local delayTime = 0
    if self.CurMapCfg and self.CurMapCfg.Rewards[self.curLocation] then
        local propId = self.CurMapCfg.Rewards[self.curLocation].PropId
        if propId == 99 or propId == 100 or propId == 101 or propId == 102 or propId == 103 then
            --踩中进度条
            delayTime = 1
            self:SetProgress(self.CurMapCfg.Rewards[self.curLocation].Count)
            CC.Sound.PlayHallEffect(string.format("luckyTime_%s", propId))
            self.MapGridTab[self.curLocation]:FindChild("ef_play"):SetActive(false)
            self.MapGridTab[self.curLocation]:FindChild("ef_play"):SetActive(true)
            self.Player:SetActive(false)
            self:SetMapGridState(self.curLocation, true)
        elseif propId == 98 then
            --踩中神秘奖
            isMystical = true
            self:ShowSelectReward()
        else
            if self.CurMapCfg.Rewards[self.curLocation].Count == 0 then
                CC.Sound.PlayHallEffect("playerBorn")
            else
                CC.Sound.PlayHallEffect("playerBorn_reward")
            end
        end
    end
    self:DelayRun(delayTime, function ()
        self.Player:SetActive(true)
        if self.viewCtr.IsUpgrade then
            self:UpgradePlayAnim()
        else
            self:SetMapGridState(self.curLocation, true)
            if not isMystical then
                self:ShowReward()
            end
        end
    end)
end
--升级
function MonopolyView:UpgradePlayAnim()
    self:SetAutoDo(false)
    local timeNum = 0
    --大象喷水
    if self.curElephantSpine then
        if self.curElephantSpine.AnimationState then
            self.curElephantSpine.AnimationState:ClearTracks()
            self.curElephantSpine.AnimationState:SetAnimation(0, "attack", false)
        end
        self:FindChild("Frame/Effect/elephant"):SetActive(false)
        self:FindChild("Frame/Effect/elephant"):SetActive(true)
        CC.Sound.PlayHallEffect("mapUpGrade")
        timeNum = 2
    end
    self:SetMapGridState(self.curLocation, true)
    self:DelayRun(timeNum, function ()
        local isJp = self.viewCtr.IsJPPool or false
        self:ShowReward(true, isJp)
        self.viewCtr:Req_UW_MonopolyGetUserInfo()
        self:SetMapGridState(self.curLocation, false)
    end)
end

--大富翁限时礼包计时
function MonopolyView:UpdateTime()
    self:StartTimer("CountDown"..self.createTime, 1, function()
        for _, v in pairs(self.GiftInfo) do
            if v.time > 0 then
                v.time = v.time - 1
                v.timeText.text = CC.uu.TicketFormat(v.time, true)
                if v.time <= 0 then
                    v.item:SetActive(false)
                end
            else
                v.item:SetActive(false)
            end
        end
    end, -1)
end

function MonopolyView:InitGiftInfo(data)
	local list = data or {}
	for _,v in pairs(self.GiftInfo) do
		v.item.transform:SetActive(false)
	end
    if table.isEmpty(list) then return end
	for _,v in pairs(list) do
		local item = self:CreateGiftItem(v)
        table.insert(self.GiftInfo, item)
	end
    if not table.isEmpty(self.GiftInfo) then
        self:UpdateTime()
    end
end

--添加礼包
function MonopolyView:CreateGiftItem(info)
    local t = {}
    t.item = CC.uu.newObject(self.GiftItem, self.Content)
    t.item:SetActive(true)
	t.item.name = info.GiftId
    t.wareId = tostring(info.GiftId)
    local image = string.format("cgxb_icon_%s", info.GiftId)
    self:SetImage(t.item:FindChild("Icon"), image)
    t.item:FindChild("Icon"):GetComponent("Image"):SetNativeSize()
    t.time = info.IdExpireTime - CC.TimeMgr.GetSvrTimeStamp()
    t.timeText = t.item:FindChild("Text")
    if t.time > 0 then
        t.timeText.text = CC.uu.TicketFormat(t.time, true)
    end
    self:AddClick(t.item, function ()
        if self.AutoDoSpin then return end
        self:OpenMonopolyGift(t.wareId)
	end)
    return t
end
--打开内嵌礼包
function MonopolyView:OpenMonopolyGift(wareId)
    local cb = function (isBuyGift)
        self:SetCanClick(true)
        if not self.viewCtr then return end
        self.viewCtr.PlayAnim = false
        if isBuyGift then
            self:SetAutoDo(false)
        elseif self.AutoDoSpin then
            self:ClickBtnSpin()
        end
        self.viewCtr:ReqGfitList()
    end
    local autoClose = self.AutoDoSpin and true or false
    CC.ViewManager.Open("MonopolyGiftView", {wareId = tostring(wareId), callback = cb, AutoClose = autoClose})
end

--神秘奖
function MonopolyView:ShowSelectReward()
    self.SelectReward:SetActive(true)
    self.hand:SetActive(true)
    self.hand.localPosition = Vector3(116, -100, 0)
    CC.Sound.PlayHallEffect("mysticalJump")
    for i, _ in ipairs(self.plateList) do
        self.plateList[i]:SetActive(true)
        self.plateList[i]:FindChild("bg"):SetActive(true)
        self.plateList[i]:FindChild("effect"):SetActive(false)
        self.plateList[i]:FindChild("reward"):SetActive(false)
        self.plateList[i]:GetComponent("CanvasGroup").alpha = 1
    end
    local time = 5
    self.SelectReward:FindChild("Tip").text = string.format(self.language.SelectRewardTip, time)
    self:StopTimer("AutoSelectPlate")
    self:StartTimer("AutoSelectPlate", 1, function()
        time = time - 1
        self.SelectReward:FindChild("Tip").text = string.format(self.language.SelectRewardTip, time)
        if time == 0 then
            local rnd = math.random(1, 2)
            self:PlayMysticalAnim(rnd)
        end
    end, time)
end
--神秘奖励动画
function MonopolyView:PlayMysticalAnim(index)
    self:StopTimer("AutoSelectPlate")
    if self.isSelectPlate then return end
    self.isSelectPlate = true
    --移动手到选择的牌
    self:RunAction(self.hand, {"localMoveTo",
            self.plateList[index].localPosition.x - 70,self.plateList[index].localPosition.y, 0.2, function()
                CC.Sound.PlayHallEffect("mysticalPlate")
                self.plateList[index]:FindChild("effect"):SetActive(true)
            end})
    self:DelayRun(0.6, function ()
        --隐藏除选择牌的其他东西
        self.hand:SetActive(false)
        for i, _ in ipairs(self.plateList) do
            self.plateList[i]:SetActive(i == index)
        end
        --播放选择牌的动画
        self:RunAction(self.plateList[index],{
            {"scaleTo", 1.2,1.2, 0.1,},
            {"scaleTo", 0,0, 0.2,function () self:ShowAllMystical(index) end}})
    end)
end
--显示神秘奖所有奖励
function MonopolyView:ShowAllMystical(index)
    for i, _ in ipairs(self.plateList) do
        self.plateList[i].localScale = Vector3.one
        self.plateList[i]:SetActive(true)
        self.plateList[i]:FindChild("bg"):SetActive(false)
        self.plateList[i]:FindChild("reward"):SetActive(true)
        local info = self.viewCtr:GetRewardInfo(i == index)
        if info then
            local image = self.propCfg.GetIcon(info.ConfigId)
            local count = info.Count
            if info.Type == 5 then
                --礼包
                image = string.format("cgxb_icon_%s", info.ConfigId)
                count = ""
            end
            self:SetImage(self.plateList[i]:FindChild("reward/Sprite"), image)
            self.plateList[i]:FindChild("reward/Sprite"):GetComponent("Image"):SetNativeSize()
            self.plateList[i]:FindChild("reward/Text").text= count
        end
        if i ~= index then
            self.plateList[i]:GetComponent("CanvasGroup").alpha = 0.5
        end
    end
    self:DelayRun(1, function ()
        if self.viewCtr.ChooseRewardProp[1] and self.giftList[self.viewCtr.ChooseRewardProp[1].ConfigId] then
            self:OpenMonopolyGift(self.viewCtr.ChooseRewardProp[1].ConfigId)
        else
            self:ShowReward()
        end
        self.SelectReward:SetActive(false)
        self.isSelectPlate = false
    end)
end

function MonopolyView:ShowReward(upgrade, isJp)
    local cb = function ()
        self:SetCanClick(true)
        if not self.viewCtr then return end
        self.viewCtr.PlayAnim = false
        if self.AutoDoSpin then
            self:ClickBtnSpin()
        end
        if upgrade then
            self:FindChild("Frame/Effect/elephantUp"):SetActive(false)
            self:FindChild("Frame/Effect/elephantUp"):SetActive(true)
        end
    end
    local autoTime = self.AutoDoSpin and 3 or nil
    local isUpgrade = upgrade
    local isOpen = nil
    if isUpgrade and isJp and self.viewCtr.ChooseRewardProp[1] and
     self.viewCtr.ChooseRewardProp[1].ConfigId == CC.shared_enums_pb.EPC_ChouMa and self.viewCtr.ChooseRewardProp[1].Count > 0 then
        --升级且中jp
        local param = {};
        param.rewardInfo = {{ConfigId = 2, Count = self.viewCtr.ChooseRewardProp[1].Count}}
        param.rewardType = 2
        param.callback = cb
        isOpen = CC.ViewManager.Open("TurntableRewardView", param);
    else
        isOpen = CC.ViewManager.OpenRewardsView({items = self.viewCtr.ChooseRewardProp, callback = cb, AutoTime = autoTime, isSpecial = isUpgrade})
    end
    if not isOpen then
        cb()
    end
end

function MonopolyView:ActionIn()
	self:SetCanClick(false);
    self.transform.size = Vector2(125, 0)
    self.transform.localPosition = Vector3(-125 / 2, 0, 0)
    self:RunAction(self.transform, {
        {"fadeToAll", 0, 0},
        {"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
    });
end

function MonopolyView:ActionOut()
	self:SetCanClick(false);
	CC.HallUtil.HideByTagName("Effect", false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function MonopolyView:CloseView()
	self:ActionOut()
end

function MonopolyView:OnDestroy()
    self:CancelAllDelayRun()
	self:StopTimer("CountDown"..self.createTime)
    self:StopTimer("AutoSelectPlate")
    self.PlayerSpine = nil
    if self.chipCounter then
		self.chipCounter:Destroy()
		self.chipCounter = nil
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
end

return MonopolyView;