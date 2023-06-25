local CC = require("CC")

local LuckyTurntableView = CC.uu.ClassView("LuckyTurntableView")

--param.isGiftCollection礼包合集打开，callBack显示合集关闭按钮回调
function LuckyTurntableView:ctor(param)
    self.param = param;
	self.language = self:GetLanguage()
	self.createTime = os.time()+math.random()
    self.PrefabTab = {}
    self.PrefabInfo = {}
    self.IconTab = {}
	self.RankNum = 0
	self.PrefabCoin = {}
	--当前在滚动信息索引
	self.curMoveInfoIndex = {}
	--self.FirstClose = true
	--转盘个区域倍数
	self.turntableMul = {100, 1, 1.2, 1.4, 1.1, 1.3, 100, 1, 1.2, 1.4, 1.1, 1.3}
	--已经购买
	self.bought = false
	self.remianTime = 0
	self.playAnim = false
end

function LuckyTurntableView:OnCreate()
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.viewCtr = self:CreateViewCtr(self.param);
	self.giftPrice = self.wareCfg["22006"].Price or 270
	self.viewCtr:OnCreate();
	self:InitUI()
end

function LuckyTurntableView:InitUI()
	self.ChipNode = self:FindChild("ResultPanel/ChipNode")
	self:AddClick(self.ChipNode:FindChild("Add"), function()
        CC.ViewManager.Open("StoreView")
	end)
	self:ShowChipAddBtn()
	self.RewardsChip = self:FindChild("ResultPanel/RewardsChip")
	self.remainTime = self:FindChild("ResultPanel/Timer/timeText")
	self.RewardsBase = self.RewardsChip:FindChild("BaseText")
	self.RewardsDouble = self.RewardsChip:FindChild("DoubleText")
	self.Receive = self:FindChild("ResultPanel/Receive")
    self:AddClick(self.Receive:FindChild("ReceiveBtn"), function ()
        self:OnReceiveClick()
	end)

    self.Scroller = self:FindChild("RollRecord/Scroller")
	self.Content = self.Scroller:FindChild("Content")
    self.Item = self.Scroller:FindChild("Item")

	--大奖名单
	self.BigAwardPanel = self:FindChild("BigAwardPanel")
    self:AddClick(self.BigAwardPanel:FindChild("BigAwardBtn"), function ()
        self:OnBigAwardClick()
	end)
	self.Info_Content = self.BigAwardPanel:FindChild("InfoView/Scroller/Viewport/Content")
	self.Info_Item = self.BigAwardPanel:FindChild("InfoView/Scroller/Viewport/Item")
	self:OptimizeAlter()

	self.tableNode = self:FindChild("Turntable/TurnNode")
	self.pointerArrow = self:FindChild("Turntable/Pointer/Arrow")
	self:AddClick(self:FindChild("Turntable/Spin/Spin"), "OnSpinClick")
	self:AddClick(self:FindChild("BtnClose"), function ()
		-- if self.FirstClose then
		-- 	self:FindChild("AgainSure"):SetActive(true)
		-- else
		-- 	self:CloseView()
		-- end
		-- self.FirstClose = false
		self:CloseView()
	end)
	-- self:AddClick(self:FindChild("AgainSure/SureBg/SureBtn"), "OnSpinClick")
	-- self:AddClick(self:FindChild("AgainSure/SureBg/CloseSure"), function()
	-- 	self:FindChild("AgainSure"):SetActive(false)
	-- end)
	self.flyCoint = self:FindChild("Coin")

	self.viewCtr:ReqLuckyInfo()

    self:LanguageSwitch()
	self:InitUIData()
	self.quaternion = Quaternion();
end

--语言切换
function LuckyTurntableView:LanguageSwitch()
	self.RewardsChip:FindChild("Base").text = self.language.base;
	self.RewardsChip:FindChild("Double").text = self.language.double;
	self.Receive:FindChild("ReceiveBtn").text = self.language.receive;
	self.BigAwardPanel:FindChild("InfoView/Image/Name").text = self.language.roleName;
	self.BigAwardPanel:FindChild("InfoView/Image/Info").text = self.language.winInfo;
end

function LuckyTurntableView:InitUIData()
	for i=1,12 do
		self.tableNode:FindChild(i).text = "X"..self.turntableMul[i]
	end
	self.RewardsBase.text = "300000"
	self:SetTimer("00:00:00")
	if self.param and self.param.isGiftCollection then
		self:FindChild("Bg"):SetActive(false)
		self:FindChild("BtnClose"):SetActive(false)
	else
		self:FindChild("Bg"):SetActive(true)
		self:FindChild("BtnClose"):SetActive(true)
	end
	self.walletView = CC.uu.CreateHallView("WalletView", {parent = self.transform, exchangeWareId = "22006"})
	--self.walletView.transform:SetParent(self.transform, false);
	self:SetChouMa(CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa"))
	self:SetReceiveDouble(100, false)
	self.Receive:FindChild("ReceiveBtn"):SetActive(false)
	self.Receive:FindChild("Award/Icon"):SetActive(true)
	self.Receive:FindChild("Award").localPosition = Vector3(0, -2,0)
	self.Receive:FindChild("default"):SetActive(true)
	self.Receive:FindChild("icon"):SetActive(false)
	self.Receive:FindChild("Award/Num"):GetComponent("Text").text = 30000000
	local animator = self.Receive:GetComponent("Animator")
	animator:Play("Effect_jsj_jlsz_an",0,0)
    animator:Update(0)
	animator.enabled = false

	local data = self.activityDataMgr.GetLuckyRollData()
	self:InitRollInfo(data)
	CC.Request("GetOrderStatus",{"22006"})

end

function LuckyTurntableView:ShowChipAddBtn()
	if not CC.LocalGameData.GetLocalStateToKey("CommodityType") or CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= self.giftPrice then
		self.ChipNode:FindChild("Add"):SetActive(false)
	else
		self.ChipNode:FindChild("Add"):SetActive(true)
	end
end

function LuckyTurntableView:OnSpinClick()
	if self.bought or self.remianTime <= 0 then
		return
	end
	--self:OnSpinNowTurn(1.3)
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= self.giftPrice then
		--self.viewCtr:ReqLuckySpin()
		local data={}
        data.WareId="22006"
        data.ExchangeWareId= "22006"
        CC.Request("ReqBuyWithId",data)

	else
		if self.walletView then
			self.walletView:PayRecharge()
		end
	end
end

function LuckyTurntableView:OnSpinNowTurn(multi)
	--购买礼包成功
	self.walletView:PayGiftSucceed(false)
	self.ChipNode:FindChild("Add"):SetActive(false)
	if self.param and self.param.callBack then
		self.param.callBack(false)
	end
	--self.FirstClose = false
	self.bought = true
	self.playAnim = true
	--self:FindChild("AgainSure"):SetActive(false)
	CC.Sound.PlayHallEffect("Turntable")
	-- 让动画停在第一帧
	local spinAnimator = self:FindChild("Turntable/Spin"):GetComponent("Animator")
	spinAnimator:Play("Spin",0,0)
    spinAnimator:Update(0)
	spinAnimator.enabled = false
	self:SetReceiveDouble("", false)
	self.RewardsBase:SetActive(false)
	self.RewardsBase:GetComponent("Text").text = ""
	self.Receive:FindChild("default"):SetActive(false)
	self.Receive:FindChild("icon"):SetActive(true)
	self.Receive:FindChild("Award/Icon"):SetActive(false)
	self.Receive:FindChild("Award/Num"):GetComponent("Text").text = ""
	self:FindChild("Turntable/Effect_Frame"):SetActive(true)
	self:DelayRun(1, function()
		self:FindChild("Turntable/Effect_Frame"):SetActive(false)
	end);
	self:FindChild("Turntable/Sale"):SetActive(false)
	self.pointerArrow.transform.localPosition = Vector3(0,-100,0)
	self:SetCanClick(false)
	self:SetGiftCollectionClick(false)
	CC.uu.DelayRun(1.1, function ()
		self.viewCtr:StartRoll(multi)
	end)
end

--设置时间
function LuckyTurntableView:SetTimer(remainTime)
    self.remainTime:GetComponent("Text").text = remainTime
end

--设置玩家金币
function LuckyTurntableView:SetChouMa(ChouMaNum)
	self.ChipNode:FindChild("Text"):GetComponent("Text").text = ChouMaNum
end

--设置中奖倍数
function LuckyTurntableView:SetReceiveDouble(Double, isEffect)
	self.RewardsDouble:GetComponent("Text").text = Double
	self.RewardsDouble:FindChild("Effect").transform:SetActive(isEffect)
end

--设置中奖结果
function LuckyTurntableView:SetReceiveResult(area)
	local finalNum = area
	self.tableNode:FindChild(string.format("%s/Effect_Shan",finalNum)):SetActive(true)
	self:FindChild("Turntable/Frame/Effect_circle"):SetActive(true)
	self:DelayRun(1.5,function()
		CC.Sound.PlayHallEffect("Award")
		self.RewardsBase:SetActive(true)
		self.tableNode:FindChild(string.format("%s/Effect_Shan",finalNum)):SetActive(false)
		self:FindChild("Turntable/Frame/Effect_circle"):SetActive(false)
		self.tableNode:FindChild(string.format("%s/Effect_Liu",finalNum)):SetActive(true)

		self.RewardsBase:GetComponent("NumberRoller"):RollTo(300000, 1)
		self:RunAction(self.RewardsBase,  {"scaleTo", 1.5, 1.5, 0.5 , function ()
			self.RewardsBase:FindChild("Effect").transform:SetActive(true)
			self:RunAction(self.RewardsBase, {"scaleTo", 1, 1, 0.5})
		end})
		self:DelayRun(1.5, function ()
			self:SetReceiveDouble(self.turntableMul[finalNum], true)
		end)
		self:DelayRun(2.5, function ()
			self.Receive:FindChild("ReceiveBtn"):SetActive(true)
			self.Receive:FindChild("Award/Icon"):SetActive(true)
			self.Receive:FindChild("Award").localPosition = Vector3(0, -15,0)
			self.Receive:FindChild("Award/Num"):GetComponent("NumberRoller"):RollTo(self.turntableMul[finalNum] * 300000, 1);
			self:RunAction(self.Receive:FindChild("Award"),  {"scaleTo", 1.5, 1.5, 0.5 , function ()
				self.Receive:FindChild("Effect").transform:SetActive(true)
				self:RunAction(self.Receive:FindChild("Award"), {"scaleTo", 1, 1, 0.5})
				self.Receive:GetComponent("Animator").enabled = true
			end})
			self:SetCanClick(true);
			self.playAnim = false
		end)
	end)
end

--转盘转动，礼包合集按钮不可点击
function LuckyTurntableView:SetGiftCollectionClick(flag)
	CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, flag);
end

--领取奖励
function LuckyTurntableView:OnReceiveClick()
	self.Receive:FindChild("ReceiveBtn"):GetComponent("Text").raycastTarget = false
	self:GoldFly()
end

--金币飞动画
function LuckyTurntableView:GoldFly()
	local num = 20
	CC.Sound.PlayHallEffect("CoinFly")
	for i = 1, num do
		local idx = i
		self:DelayRun(idx * 0.05,function ()
			self:FlyCoin(idx, idx == num)
		end)
	end
end

function LuckyTurntableView:FlyCoin(index, endFly)
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
	item.transform:SetParent(self.ChipNode, false)
	local rndx = math.random(680, 770)
	local rndy = math.random(-500, -460)
	item.localPosition = Vector3(rndx,rndy,0)
	item:SetActive(true)
	local target = self.ChipNode:FindChild("Text").localPosition
	self:RunAction(item,  {"localMoveTo", target.x,target.y, 1 , function ()
		item:SetActive(false)
		if endFly then
			if self.viewCtr.awardNum > 0 then
				local playCoin = tonumber(self.ChipNode:FindChild("Text"):GetComponent("Text").text)
				playCoin = playCoin + self.viewCtr.awardNum
				self.ChipNode:FindChild("Text"):GetComponent("Text").text = playCoin
			else
				self.ChipNode:FindChild("Text"):GetComponent("Text").text = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
			end
			self:DelayRun(0.5,function()
				--奖励界面
				local data = {};
				data.ConfigId = 2
				data.Count = self.viewCtr.awardNum
				self:SetGiftCollectionClick(true)
				CC.ViewManager.OpenRewardsView({items = {data},title = "LuckyTurntable",callback = function ()
					if not CC.uu.IsNil(self.transform) then
						self:CloseView()
					end
				end})
			end)
		end
	end})
end

function LuckyTurntableView:SetVipUpChouMa(count)
	local playCoin = tonumber(self.ChipNode:FindChild("Text"):GetComponent("Text").text)
	if count and count > 0 then
		playCoin = playCoin + count
	end
	self:SetChouMa(playCoin)
end

--初始化滚动列表
function  LuckyTurntableView:InitRollInfo(data)
	local list = data
	for _,v in pairs(self.PrefabTab) do
		v.transform:SetActive(false)
	end
	for i = 1,#list do
		self:AddItemData(i,list[i])
	end
end

function LuckyTurntableView:AddItemData(index, data)
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
	item.localPosition = Vector3(1000, -6, 0)
	item:SetActive(true)

	if item then
		item.transform:SetParent(self.Content, false)
        --log(CC.uu.Dump(data, "data",10))
		local str = string.format(self.language.rollInfo, data.Name, data.Reward)
		item:GetComponent("Text").text = str
	end
end

function LuckyTurntableView:MoveRoll(index)
	if self.Content.childCount <= 0 or index > self.Content.childCount then
		return
	end
	if index == self.Content.childCount then
		self.viewCtr.curMoveIndex = 0
	end
	if self.curMoveInfoIndex[index] then
		return
	else
		self.curMoveInfoIndex[index] = true
	end
	local obj = self.Content:GetChild(index - 1)
	if obj then
		self:RunAction(obj,  {"localMoveTo", -1000, -6, 12, function ()
			if obj.localPosition.x <= -1000 then
				obj.localPosition = Vector3(1000, -6, 0);
				if self.curMoveInfoIndex[tonumber(obj.name)] then
					self.curMoveInfoIndex[tonumber(obj.name)] = nil
				end
			end
		end})
	end
end

--中大奖名单
function LuckyTurntableView:OnBigAwardClick()
	--没有打开
	if self.BigAwardPanel:FindChild("BigAwardBtn/Dir").localScale.x >= 1 then
		self.viewCtr:ReqLuckyRecord()
		self.BigAwardPanel:FindChild("bg"):SetActive(true)
		self.BigAwardPanel:FindChild("BigAwardBtn").localPosition = Vector3(234,10,0)
		self.BigAwardPanel:FindChild("BigAwardBtn/Dir").localScale = Vector3(-1,1,1)
		self.BigAwardPanel:FindChild("InfoView").localPosition = Vector3(452,0,0)
	else
		self.BigAwardPanel:FindChild("bg"):SetActive(false)
		self.BigAwardPanel:FindChild("BigAwardBtn").localPosition = Vector3(608,10,0)
		self.BigAwardPanel:FindChild("BigAwardBtn/Dir").localScale = Vector3(1,1,1)
		self.BigAwardPanel:FindChild("InfoView").localPosition = Vector3(826,0,0)
	end
end

--初始化大奖列表
function  LuckyTurntableView:InitInfo(data)
	local list = data
	for _,v in pairs(self.PrefabInfo) do
		v.transform:SetActive(false)
	end
	local isShow = true
	self.rankCoroutine = coroutine.start(function()
		for i = 1,#list do
			isShow = not isShow
			self:InfoItemData(i,list[i], isShow)
			coroutine.step(1)
		end
	end)
end

--大奖玩家信息
function LuckyTurntableView:InfoItemData(index,InfoData,bgShow)
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
	self.RankNum = self.RankNum + 1
	local param = {}
	param.parent = headNode
	param.portrait = InfoData.Portrait
	param.playerId = InfoData.PlayerId
	param.vipLevel = InfoData.Level
	param.clickFunc = "unClick"
	self:SetHeadIcon(param,self.RankNum)

	if item then
		item.transform:SetParent(self.Info_Content, false)
		item.transform:FindChild("Nick"):GetComponent("Text").text = InfoData.Name
        item.transform:FindChild("Num"):GetComponent("Text").text = InfoData.Reward
        item.transform:FindChild("Time"):GetComponent("Text").text = os.date("%H:%M:%S %d/%m",InfoData.TimeSTamp)
        item.transform:FindChild("bg"):SetActive(bgShow)
	end
end

--优化更新
function LuckyTurntableView:OptimizeAlter()
	self.Info_Item.sizeDelta = Vector2(374, 80)
	self.Info_Item:FindChild("Num").sizeDelta = Vector2(170, 50)
	self.Info_Item:FindChild("ItemHead").localScale = Vector3(0.7,0.7,0.7)
	self.Info_Item:FindChild("Nick").localPosition = Vector3(-46,-4,0)
end

-- 设置定时器
function LuckyTurntableView:LuckyCountDown(Seconds)
	if Seconds and Seconds <= 0 then
		if not self.playAnim then
			self.bought = true
			self:ShowTip()
		end
		return
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.LuckyCountDown, Seconds)
	self.remianTime = Seconds
	local time = 0
	self:StartTimer("LuckyCountDown"..self.createTime, 1, function()
        self.remianTime = self.remianTime - math.floor(time)
        local timeStr = CC.uu.TicketFormat(self.remianTime)
        if self.remianTime <= 0 then
			self:SetTimer("00:00:00")
			self:StopTimer("LuckyCountDown"..self.createTime)
			if self.playAnim then
				self:DelayRun(12, function ( )
					self:CloseView()
				end)
			end
		else
			self:SetTimer(timeStr)
		end
		self.remianTime = self.remianTime - 1
    end, -1)
end

function LuckyTurntableView:ShowTip()
	CC.ViewManager.ShowTip(self.language.overTimeTip);
	self:DelayRun(10, function ( )
		self:CloseView()
	end)
end

function LuckyTurntableView:GetTableAngle()
	return self.tableNode.transform.localEulerAngles.z;
end

--设置转盘角度
function LuckyTurntableView:RefreshTableAngle(zAngle)
	self.tableNode.transform.localRotation = self.quaternion:SetEuler(0, 0, zAngle);
end

--设置指针
function LuckyTurntableView:RefreshPointerArrowAngle(zAngle)
	self.pointerArrow.transform.localRotation = self.quaternion:SetEuler(0, 0, zAngle);
end

--删除头像对象
function LuckyTurntableView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.IconTab[tonumber(headtran.transform.name)] ~= nil then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end
end

--设置头像
function  LuckyTurntableView:SetHeadIcon(param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

--切后台回来
function LuckyTurntableView:OnResume()
	self.viewCtr:ReqLuckyInfo()
end

function LuckyTurntableView:ActionIn()
	if self.param and self.param.isGiftCollection then
		self:SetCanClick(false);
		self.transform.size = Vector2(125, 0)
		self.transform.localPosition = Vector3(-125 / 2, 0, 0)
		self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
	end
end

function LuckyTurntableView:ActionOut()
	self:SetCanClick(false);
	CC.HallUtil.HideByTagName("Effect", false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

--关闭界面
function LuckyTurntableView:CloseView()
	if self.bought then
		CC.HallNotificationCenter.inst():post(CC.Notifications.LuckyCountDown, 0)
	end
	if self.param and self.param.callBack then
		self.param.callBack(true)
	end
	self:ActionOut()
end

function LuckyTurntableView:OnDestroy()
	--CC.Sound.StopEffect()
	self:SetGiftCollectionClick(true)
	self:StopTimer("LuckyCountDown"..self.createTime)
	self:CancelAllDelayRun()
	if self.param and self.param.callBack then
		self.param.callBack(true)
	end

	if self.rankCoroutine then
		coroutine.stop(self.rankCoroutine)
		self.rankCoroutine = nil
	end

    for i,v in pairs(self.IconTab) do
		if v then
			v:Destroy()
			v = nil
		end
    end
	if self.walletView then
		self.walletView:Destroy()
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
    end
end

return LuckyTurntableView;