local CC = require("CC")

local GoldenElephant = CC.uu.ClassView("GoldenElephant")

function GoldenElephant:ctor(param)
	self.param = param;
	self.language = self:GetLanguage()
	self.PrefabTab = {}
	self.numberRoller = nil
	self.PrefabCoin = {}
	self.BaseCoinFly = false
	self.MysteryCoinFly = false
end

function GoldenElephant:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();

	self:InitContent();
end

function GoldenElephant:InitContent()

	self.Scroller = self:FindChild("Record/Scroller")
	self.Content = self.Scroller:FindChild("Content")
	self.Item = self.Scroller:FindChild("Item")
	self:AddClick(self:FindChild("BtnBuy"), function ()
		self.viewCtr:OnPay()
	end)

	self.GoldSpine = self:FindChild("Animation/GoldAnim"):GetComponent("SkeletonGraphic")
	self.MysterySpine = self:FindChild("Animation/MysteryAnim"):GetComponent("SkeletonGraphic")

	self.moveGold = self:FindChild("MoveGold")
	self.moveMystery = self:FindChild("MoveMystery")
	self.flyCoint = self:FindChild("Coin")

	self:AddClick("Animation/Mask", function ()
		if self.viewCtr.animEnd then
			self:HideAnimation()
		end
	end);
	self:AddClick("BtnRule", function ()
		CC.ViewManager.Open("ElephantExplainView")
	end)
	self:AddClick("BtnClose", "ActionOut");

	self:SetHead()
	self.viewCtr:ReqElephantRecord()
	self.viewCtr:ReqElephant()
	self:LanguageSwitch()
end

function GoldenElephant:LanguageSwitch()
	self:FindChild("BtnBuy/Text"):GetComponent("Text").text = self.language.Buy
end

--金象动画
function GoldenElephant:PlayGoldAnim(data)
	self:FindChild("LeftElephant/Image"):SetActive(false)
	self.moveGold.localPosition = Vector3(-111, -78, 0)
	self.moveGold.localScale = Vector3.one
	self.moveGold:SetActive(true)
	self:SetCanClick(false)
	self:RunAction(self.moveGold,  {"localMoveTo", -40, -13, 1, function ()
		self.moveGold:SetActive(false)
		self:FindChild("Animation"):SetActive(true)
		self:SetCanClick(true)
		self.GoldSpine:SetActive(true)
		CC.Sound.PlayHallEffect("Hit")
		--砸金象动画结束
		local goldFun
		goldFun = function ()
			self.GoldSpine.AnimationState:ClearTracks()
			self:FindChild("Animation/GoldAnim/Gold"):SetActive(true)
			CC.Sound.PlayHallEffect("GoldPopup")
			if self.viewCtr.Mystery and self.viewCtr.baseCount > 0 then
				--有神秘奖
				data = self.viewCtr.baseCount
			end
			self:ReceiveGold(data)
			self.viewCtr:MarkAnimState(true)
			self.BaseCoinFly = true
			self.GoldSpine.AnimationState.Complete =  self.GoldSpine.AnimationState.Complete - goldFun
		end
		self.GoldSpine.AnimationState.Complete =  self.GoldSpine.AnimationState.Complete + goldFun
	end})
	self:RunAction(self.moveGold, {"scaleTo", 1.7, 1.7, 1})
end

--神秘象动画
function GoldenElephant:PlayMysteryAnim()
	self:FindChild("RightElephant/Image"):SetActive(false)
	self.moveMystery.localPosition = Vector3(210, -166, 0)
	self.moveMystery.localScale = Vector3.one
	self.moveMystery:SetActive(true)
	self:SetCanClick(false)
	self:RunAction(self.moveMystery,  {"localMoveTo", -34, -6, 1, function ()
		self.moveMystery:SetActive(false)
		self:FindChild("Animation"):SetActive(true)
		self:SetCanClick(true)
		self.MysterySpine:SetActive(true)
		CC.Sound.PlayHallEffect("Hit")
		--砸神秘象结束
		local mysteryFun
		mysteryFun = function ()
			self.MysterySpine.AnimationState:ClearTracks()
			self:FindChild("Animation/MysteryAnim/Gold"):SetActive(true)
			CC.Sound.PlayHallEffect("GoldPopup")
			self:ReceiveGold(self.viewCtr.mysteryCount)
			self.viewCtr:MarkAnimState(true)
			self.MysteryCoinFly = true
			self.MysterySpine.AnimationState.Complete =  self.MysterySpine.AnimationState.Complete - mysteryFun
		end
		self.MysterySpine.AnimationState.Complete =  self.MysterySpine.AnimationState.Complete + mysteryFun
	end})
	self:RunAction(self.moveMystery, {"scaleTo", 4.5, 4.5, 1})
	self.viewCtr.Mystery = false
end

--奖励
function GoldenElephant:ReceiveGold(count)
	self:FindChild("Animation/Receive"):SetActive(true)
	local param = {
		parent = self:FindChild("Animation/Receive/Count"),
		number = count,
		-- callback = function()
		-- 	CC.uu.DelayRun(1,function()
		-- 		self:FindChild("Animation/GoldAnim/Gold"):SetActive(false)
		-- 		self:FindChild("Animation/MysteryAnim/Gold"):SetActive(false)
		-- 	end)
		-- end
	}
	self.numberRoller = CC.ViewCenter.NumberRoller.new();
	self.numberRoller:Create(param);
end

function GoldenElephant:HideAnimation()
	--动画设置初始状态
	if self.GoldSpine.AnimationState then
		self.GoldSpine.AnimationState:ClearTracks()
		self.GoldSpine.AnimationState:SetAnimation(0, "stand", false)
	end
	if self.MysterySpine.AnimationState then
		self.MysterySpine.AnimationState:ClearTracks()
		self.MysterySpine.AnimationState:SetAnimation(0, "stand", false)
	end
	CC.uu.DelayRun(0,function()
		self:FindChild("Animation"):SetActive(false)
		self:FindChild("Animation/GoldAnim"):SetActive(false)
		self:FindChild("Animation/MysteryAnim"):SetActive(false)
	end)
	if self.numberRoller then
		self.numberRoller:Destroy()
		self.numberRoller = nil
	end
	self:FindChild("Animation/GoldAnim/Gold"):SetActive(false)
	self:FindChild("Animation/MysteryAnim/Gold"):SetActive(false)
	self:FindChild("Animation/Receive"):SetActive(false)
	self.moveGold:SetActive(false)
	self.moveMystery:SetActive(false)
	self.viewCtr:MarkAnimState(false)
	self:GoldFly()
end

--砸象结束
function GoldenElephant:HitElephantEnd()
	self.BaseCoinFly = false
	self.MysteryCoinFly = false
	if self.viewCtr.Mystery then
		--显示中神秘象
		self:FindChild("TipSp"):SetActive(true)
		CC.uu.DelayRun(2,function()
			self:FindChild("TipSp"):SetActive(false)
			self:PlayMysteryAnim()
		end)
	else
		self:InitPanelShow()
	end
end

--初始界面显示
function GoldenElephant:InitPanelShow()
	self:FindChild("LeftElephant/Image"):SetActive(true)
	self:FindChild("LeftElephant/Broken"):SetActive(false)
	self:FindChild("RightElephant/Image"):SetActive(true)
	self:FindChild("RightElephant/Broken"):SetActive(false)
	self.viewCtr.Mystery = false
	self.viewCtr.baseCount = 0
	self.viewCtr.mysteryCount = 0
	self:BtnShow(true)
	self.viewCtr:ReqElephant()
end

function GoldenElephant:BtnShow(isShow)
	self:FindChild("BtnBuy"):SetActive(isShow)
	self:FindChild("Tips"):SetActive(isShow)
	self:FindChild("BtnClose"):SetActive(isShow)
end

--金币飞动画
function GoldenElephant:GoldFly()
	self:BtnShow(false)
	local num = 20
	local coinScale = 3
	local isBase = true
	if self.BaseCoinFly then
		self:FindChild("LeftElephant/Image"):SetActive(false)
		self:FindChild("LeftElephant/Broken"):SetActive(true)
	elseif self.MysteryCoinFly then
		self:FindChild("RightElephant/Image"):SetActive(false)
		self:FindChild("RightElephant/Broken"):SetActive(true)
		num = 30
		coinScale = 3
		isBase = false
	end
	CC.Sound.PlayHallEffect("CoinFly")
	for i = 1, num do
		local idx = i
		CC.uu.DelayRun(idx * 0.05,function ()
			self:FlyCoin(idx, coinScale, isBase, idx == num)
		end)
	end
end

function GoldenElephant:FlyCoin(index, coinScale, isBase, endFly)
	local tran = nil
	local item = nil
	if self.PrefabCoin[index] == nil then
		tran = self.flyCoint
		item = CC.uu.newObject(tran)
		item.transform.name = tostring(index)
		self.PrefabCoin[index] = item.transform
	else
		item = self.PrefabCoin[index]
	end
	item.transform:SetParent(self:FindChild("ChipNode"), false)
	item.localScale = Vector3(coinScale,coinScale,coinScale)
	local rndx = isBase and math.random(-140,40) or math.random(200, 260)
	local rndy = isBase and math.random(-100,-180) or math.random(-150, -200)
	item.localPosition = Vector3(rndx,rndy,0)
	item:SetActive(true)
	local target = self:FindChild("ChipNode/Text").localPosition
	self:RunAction(item,  {"localMoveTo", target.x,target.y, 1 , function ()
		item:SetActive(false)
		if endFly then
			if self.viewCtr.baseCount > 0 and self.viewCtr.mysteryCount > 0 then
				local playCoin = tonumber(self:FindChild("ChipNode/Text"):GetComponent("Text").text)
				if isBase then
					playCoin = playCoin + self.viewCtr.baseCount
				else
					playCoin = playCoin + self.viewCtr.mysteryCount
				end
				self:FindChild("ChipNode/Text"):GetComponent("Text").text = playCoin
			else
				self:FindChild("ChipNode/Text"):GetComponent("Text").text = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
			end
			CC.uu.DelayRun(0.5, function ()
				self:HitElephantEnd()
			end)
		end
	end})
end

function GoldenElephant:SetHead()
	local headNode = self:FindChild("ItemHead")
	local param = {}
	param.parent = headNode
	param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	param.portrait = CC.Player.Inst():GetSelfInfoByKey("Portrait")
	param.vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	param.clickFunc = "unClick"
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)

	local chipNode = self:FindChild("ChipNode")
	chipNode:FindChild("Text"):GetComponent("Text").text = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
	chipNode:SetActive(true)
end

function GoldenElephant:SetVipUpChouMa(count)
	local playCoin = tonumber(self:FindChild("ChipNode/Text"):GetComponent("Text").text)
	if count and count > 0 then
		playCoin = playCoin + count
	end
	self:FindChild("ChipNode/Text"):GetComponent("Text").text = playCoin
end

function GoldenElephant:BaseData(data)
	if not data then
		return
	end
	self:FindChild("LeftElephant/MoneyTips/BaseText"):GetComponent("Text").text = self.language.BaseReward
	self:FindChild("LeftElephant/MoneyTips/BaseCount"):GetComponent("Text").text = data.Base
	self:FindChild("LeftElephant/MoneyTips/SPText"):GetComponent("Text").text = self.language.Rebate
	self:FindChild("LeftElephant/MoneyTips/SPCount"):GetComponent("Text").text = data.Extra and data.Extra or 0
	if data.IsFirstBuy then
		self:FindChild("Tips"):GetComponent("Text").text = self.language.Tip
	else
		self:FindChild("Tips"):GetComponent("Text").text = self.language.Trigger
	end
	LayoutRebuilder.ForceRebuildLayoutImmediate(self:FindChild("LeftElephant/MoneyTips"))
end

--中奖记录
function  GoldenElephant:InitListData(data)
	local list = {}
	if not data then return end
	local idx = 0
	--data = {[1] = {Name = "Royal_1022328", Reward = {ConfigId = 2,Count=8374313}, Time = "01/08/2020 17:31:49"},}
	for _,v in pairs(data) do
		if v.PlayerId then
			idx =  idx + 1
			list[idx] = v
		end
	end
	for i = 1,#list do
		self:AddItemData(i, list[i])
	end
	if #list > 3 then
		self.viewCtr:StartUpdate()
	end
end

function GoldenElephant:AddItemData(index, data)
	local tran = nil
	local item = nil
	if self.PrefabTab[index] == nil then
		tran = self.Item
		item = CC.uu.newObject(tran)
		item.transform.name = tostring(index)
		self.PrefabTab[index] = item.transform
	else
		item = self.PrefabTab[index]
	end
	item.localPosition = Vector3(0, (2 - index) * 36, 0)
	item:SetActive(true)

	if item then
		item.transform:SetParent(self.Content, false)
		item.transform:FindChild("Nick"):GetComponent("Text").text = data.Name
		item.transform:FindChild("Money"):GetComponent("Text").text = data.Reward.Count
		local timeText = string.sub(data.Time,1,5) .. string.sub(data.Time,11,16)
		if data.TimeSTamp and data.TimeSTamp > 0 then
			timeText = os.date("%m/%d %H:%M",data.TimeSTamp)
		end
		item.transform:FindChild("Date"):GetComponent("Text").text = timeText
	end
end

function GoldenElephant:AutoRoll()
    for i = 1, self.Content.childCount do
		local obj = self.Content:GetChild(i - 1)
		self:RunAction(obj,  {"localMoveTo", 0, obj.localPosition.y + 36, 2 , function ()
			if obj.localPosition.y >= 72 then
				obj.localPosition = Vector3(0, (2 - self.Content.childCount) * 36, 0);
			end
		end})
	end
end

function GoldenElephant:OnDestroy()
	self:CancelAllDelayRun()
	if self.HeadIcon then
		self.HeadIcon:Destroy()
		self.HeadIcon = nil
	end
	if self.chipCounter then
		self.chipCounter:Destroy()
		self.chipCounter = nil
	end
	if self.numberRoller then
		self.numberRoller:Destroy()
		self.numberRoller = nil
	end
	if self.viewCtr then
		self.viewCtr:OnDestroy();
		self.viewCtr = nil;
	end

	self.GoldSpine = nil;
	self.MysterySpine = nil;
	self.Item = nil;
	self.flyCoint = nil;
	self.Content = nil;
	self.PrefabTab = nil;
	self.PrefabCoin = nil;
	self.moveGold = nil;
	self.moveMystery = nil;
	self.Scroller = nil;
end

return GoldenElephant;