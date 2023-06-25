local CC = require("CC")

local TreasureBoxGiftView = CC.uu.ClassView("TreasureBoxGiftView")

function TreasureBoxGiftView:ctor(param)
    self.param = param;
	self.language = self:GetLanguage()
	self.createTime = os.time()+math.random()
	self.boxItem = {}
	self.propAward = {}
	self.propAnim = {}
	self.maxRebate = {}
	self.PrefabTab = {}
	self.remianTime = 0
    --当前在滚动信息索引
	self.curMoveInfoIndex = {}
	--移动中
	self.moving = false
	self.rankNum = 0
end

function TreasureBoxGiftView:OnCreate()
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.activityDataMgr.SetActivityInfoByKey("TreasureBoxGiftView", {redDot = false})
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitUI()
end

function TreasureBoxGiftView:InitUI()
	self.boxName = {self.language.bronzeBox,self.language.silverBox,self.language.goldenBox,self.language.angleBox}
	--奖励描述窗口
	self.rewardItemTip = nil;
	for i = 1, 4 do
		self.boxItem[i] = self:FindChild(string.format("BoxPanel/Scroller/%s", i))
		self.propAward[i] = self:FindChild(string.format("BoxPanel/Award/Prop%s", i))
		self.propAnim[i] = self.propAward[i]:GetComponent("Animator")
		self.maxRebate[i] = self:FindChild(string.format("BoxPanel/MaxRebate/Rebate%s", i))
	end
	--self:SetPropRewardBtn()
	self:AddClick(self:FindChild("BoxPanel/Right"), function ()
		if not self.moving then
			self.viewCtr:BoxSwitch(true)
		end
    end)
	self:AddClick(self:FindChild("BoxPanel/Left"), function ()
		if not self.moving then
			self.viewCtr:BoxSwitch(false)
		end
    end)

    self.Scroller = self:FindChild("RollRecord/Scroller")
	self.Content = self.Scroller:FindChild("Content")
	self.Item = self.Scroller:FindChild("Item")
	self:AddClick(self:FindChild("BoxPanel/Receive/ReceiveBtn"), function ()
		self:OnReceiveBtnClick()
    end)
    self:AddClick(self:FindChild("BoxPanel/BtnRule"), function ()
		self:FindChild("ExplainView"):SetActive(true)
	end)
	self:AddClick(self:FindChild("ExplainView/Frame/BtnClose"), function ()
		self:FindChild("ExplainView"):SetActive(false)
	end)
	self.viewCtr:ReqTreasureEnable()
	self:SetCanClick(false)
	self:LanguageSwitch()
	self:InitData()
end

--语言切换
function TreasureBoxGiftView:LanguageSwitch()
	--self:FindChild("BoxPanel/BoxName/Text").text = self.language.bronzeBox
	self:FindChild("BoxPanel/Activity").text = self.language.activityTime
	self:FindChild("ExplainView/Frame/ScrollText/Viewport/Content/Text").text = self.language.ruleExplain
	self:FindChild("ExplainView/Frame/Tittle/Text").text = self.language.ruleTittle
end

function TreasureBoxGiftView:SetPropRewardBtn()
	local thunderData = {{name = self.language.bronzeThunder, num = 5}, {name = self.language.silverThunder, num = 5},
	{name = self.language.goldenThunder, num = 5}, {name = self.language.angleThunder, num = 1}}
	local wareIds = {CC.shared_enums_pb.EPC_Torpedo_1016, CC.shared_enums_pb.EPC_GiftFishV2,
	CC.shared_enums_pb.EPC_GiftFishV3, CC.shared_enums_pb.EPC_Torpedo_1017}
	for k, v in ipairs(self.propAward) do
		v:FindChild("02/Text").text = string.format("%s*%s", thunderData[k].name, thunderData[k].num)
		self:SetItemLongClick(v:FindChild("01/QP001"), v:FindChild("01/DesNode"), CC.shared_enums_pb.EPC_ChouMa)
		self:SetItemLongClick(v:FindChild("02/QP002"), v:FindChild("02/DesNode"), wareIds[k])
		self:SetItemLongClick(v:FindChild("03/QP003"), v:FindChild("03/DesNode"), CC.shared_enums_pb.EPC_Experience)
	end
end

function TreasureBoxGiftView:SetItemLongClick(itemBtn, rewardNode, wareId)
	local btnData = {};
	btnData.funcLongClick = function()
		local data = {};
		data.node = rewardNode
		data.propId = wareId
		self:ShowRewardItemTip(true,data)
	end
	btnData.funcUp = function()
		self:ShowRewardItemTip(false)
	end
	btnData.funcClick = function()
	end
	btnData.time = 0.1
	self:AddLongClick(itemBtn, btnData)
end

function TreasureBoxGiftView:ShowRewardItemTip(isShow, param)
	if isShow then
		if not self.rewardItemTip then
			self.rewardItemTip = CC.ViewCenter.CommonItemDes.new();
			self.rewardItemTip:Create({parent = param.node});
		end
		local data = {
			parent = param.node,
			propId = param.propId,
		}
		self.rewardItemTip:Show(data);
	else
		if not self.rewardItemTip then return end;
		self.rewardItemTip:Hide();
	end
end

function TreasureBoxGiftView:InitData()
	self.walletView = CC.uu.CreateHallView("WalletView", {parent = self.transform, exchangeWareId = "22007"})
	self.walletView.transform:SetParent(self.transform, false)
	self:SetReceiveBuyBtn()
end

function TreasureBoxGiftView:OnReceiveBtnClick()
	if self.moving then return end
	self.viewCtr:ReqBuyTreasure()
end

--刷新界面显示
function TreasureBoxGiftView:RefreshTreasure(curIndex)
	self:TreasureBaseInfo(curIndex)
	for i = 1, 4 do
		local ind = i
		local scale = ind == curIndex and 2 or 1
		local pos = self.viewCtr:GetMovePos(ind)
		self.boxItem[ind].localPosition = Vector3(pos.x, pos.y, 0)
		self.boxItem[ind].localScale = Vector3(scale, scale, 1)
		self.boxItem[ind]:FindChild("default"):SetActive(ind ~= curIndex)
		self.boxItem[ind]:FindChild("select"):SetActive(ind == curIndex)
		self.propAward[ind]:SetActive(ind == curIndex)
		self.maxRebate[ind]:SetActive(ind == curIndex)
		if ind == curIndex then
			self:PlayBubbleAnim(ind)
		end
	end
	self:SetCanClick(true)
end

function TreasureBoxGiftView:BoxSwitchChange(curIndex, lastIndex, callBack)
	self.moving = true
	if lastIndex then
		self:PlayBubbleAnim(lastIndex, true)
	end
	self:DelayRun(0.3, function()
		for i = 1, 4 do
			local ind = i
			local scale = ind == curIndex and 2 or 1
			local pos = self.viewCtr:GetMovePos(ind)
			self:RunAction(self.boxItem[ind],  {"localMoveTo", pos.x, pos.y, 0.4})
			self:RunAction(self.boxItem[ind],  {"scaleTo", scale, scale, 0.4, function ()
				self.boxItem[ind]:FindChild("default"):SetActive(ind ~= curIndex)
				self.boxItem[ind]:FindChild("select"):SetActive(ind == curIndex)
				self.propAward[ind]:SetActive(ind == curIndex)
				self.maxRebate[ind]:SetActive(ind == curIndex)
				if ind == curIndex then
					self:PlayBubbleAnim(ind)
				end
			end})
		end
		self:DelayRun(0.8, function ()
			self.moving = false
			if callBack then
				callBack()
			end
		end)
		self:TreasureBaseInfo(curIndex)
	end)
end

function TreasureBoxGiftView:TreasureBaseInfo(curBoxId)
	self.boxItem[curBoxId].transform:SetSiblingIndex(3)
	--self:FindChild("BoxPanel/BoxName/Text").text = self.boxName[curBoxId]
	self:SetReceiveBuyBtn()
	local info = self.viewCtr:GetTreasureInfo(curBoxId)
	if info then
		self:ShowCountdownOrReceive(info.Enabled)
		self.propAward[curBoxId]:FindChild("01/Chip"):SetActive(info.Enabled)
	end
end

--显示倒计时和按钮
function TreasureBoxGiftView:ShowCountdownOrReceive(canBuy)
	self:FindChild("BoxPanel/Receive"):SetActive(canBuy)
	self:FindChild("BoxPanel/Timer"):SetActive(not canBuy)
end

--气泡动画
function TreasureBoxGiftView:PlayBubbleAnim(index, isClose)
	if index < 0 or index > #self.propAnim then return end
	if isClose then
		self.propAnim[index]:Play("Effect_MeiRiXunBao_QiPao_Close")
	else
		self.propAnim[index]:Play("Effect_MeiRiXunBao_QiPao_Open")
	end
end

function TreasureBoxGiftView:SetBubbleValue(index, count)
	if index and count > 0 then
		self.propAward[index]:FindChild("01/Chip/Text").text = count
	end
end

--购买价格
function TreasureBoxGiftView:SetReceiveBuyBtn()
	local price = self.viewCtr:GetCurBoxPrice()
	self:FindChild("BoxPanel/Receive/Award/Num").text = string.format("%s%s",price, self.language.open)
end

function TreasureBoxGiftView:PlaySpineAnim(index, animName, data)
	local spineAnim = self.boxItem[index]:FindChild("box"):GetComponent("SkeletonGraphic")
	spineAnim.AnimationState:SetAnimation(0, animName, false)
	if animName == "stand02" then
		self.moving = true
		self:SetGiftCollectionClick(false)
		self:PlayBubbleAnim(index, true)
		self:DelayRun(0.6,function ()
			self.boxItem[index]:FindChild("open"):SetActive(false)
			self.boxItem[index]:FindChild("open"):SetActive(true)
			-- for k,v in ipairs(data.Rewards) do
			-- 	if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
			-- 		self:SetBubbleValue(index, v.Count)
			-- 	end
			-- end
			self:PlayBubbleAnim(index)
		end)
		CC.Sound.PlayHallEffect("open")
		if data then
			self:DelayRun(2, function()
				self:SetGiftCollectionClick(true)
				self:PropShow(data)
			end)
		end
	end
end

--道具显示
function TreasureBoxGiftView:PropShow(rewardData)
	--奖励界面
	local data = {};
	for k,v in ipairs(rewardData.Rewards) do
		data[k] = {}
		data[k].ConfigId = v.ConfigId
		data[k].Count = v.Count
	end
	CC.ViewManager.OpenRewardsView({items = data,title = "TreasureGift",callback = function ()
		self.moving = false
		self.viewCtr:BoxAutoSwitch()
	end})
end

function TreasureBoxGiftView:SetTimer(countDown)
	self:FindChild("BoxPanel/Timer/timeText").text = countDown
end

function TreasureBoxGiftView:BoxCountDown(countDown)
	if countDown < 0 or self.remianTime > 0  then return end
	self.remianTime = countDown
	self:StartTimer("BoxCountDown"..self.createTime, 1, function()
		self.remianTime = self.remianTime - 1
        local timeStr = CC.uu.TicketFormat(self.remianTime)
        if self.remianTime <= 0 then
			self:SetTimer("00:00:00")
			self:StopTimer("BoxCountDown"..self.createTime)
			self.viewCtr:ReqTreasureEnable()
		else
			self:SetTimer(timeStr)
		end
    end, -1)
end

function TreasureBoxGiftView:ConstituteRollInfo(data)
	local chouMa = 0
	local thunder = 0
	local boxStr = nil
	for k,v in ipairs(data.Rewards) do
		if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
			chouMa = v.Count
		end
		if v.ConfigId == CC.shared_enums_pb.EPC_Torpedo_1016 then
			boxStr = self.language.rollInfo_bronze
			thunder = v.Count
		end
		if v.ConfigId == CC.shared_enums_pb.EPC_GiftFishV2 then
			boxStr = self.language.rollInfo_silver
			thunder = v.Count
		end
		if v.ConfigId == CC.shared_enums_pb.EPC_GiftFishV3 then
			boxStr = self.language.rollInfo_golden
			thunder = v.Count
		end
		if v.ConfigId == CC.shared_enums_pb.EPC_Torpedo_1017 then
			boxStr = self.language.rollInfo_angle
			thunder = v.Count
		end
	end
	if boxStr then
		local str = string.format(boxStr, data.Name, chouMa, thunder)
		self.rankNum = self.rankNum + 1
		self:AddItemData(self.rankNum, str)
	end
end

function TreasureBoxGiftView:AddItemData(index, data)
	self:FindChild("RollRecord"):SetActive(true)
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
	item.localPosition = Vector3(550, -2, 0)
	item:SetActive(true)

	if item then
		item.transform:SetParent(self.Content, false)
		item.text = data
	end
end

function TreasureBoxGiftView:MoveRoll(index)
	if self.Content.childCount <= 0 or index > self.Content.childCount then
		self.viewCtr.curMoveIndex = 0
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
		self:RunAction(obj,  {"localMoveTo", -1500, -2, 12, function ()
			if obj.localPosition.x <= -800 then
				obj.localPosition = Vector3(550, -2, 0);
				if self.curMoveInfoIndex[tonumber(obj.name)] then
					self.curMoveInfoIndex[tonumber(obj.name)] = nil
				end
			end
		end})
	end
end

function TreasureBoxGiftView:ActionIn()
	self:SetCanClick(false);
	self.transform.size = Vector2(125, 0)
	self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:FindChild("bg/deng"):SetActive(false)
	self:RunAction(self.transform, {
		{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
				self:SetCanClick(true)
				self:FindChild("bg/deng"):SetActive(true)
			end}
		});
end

function TreasureBoxGiftView:ActionOut()
	self:SetCanClick(false)
	self:FindChild("BoxPanel"):SetActive(false)
	CC.HallUtil.HideByTagName("Effect", false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

--礼包合集按钮不可点击
function TreasureBoxGiftView:SetGiftCollectionClick(flag)
	CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, flag);
end

--关闭界面
function TreasureBoxGiftView:CloseView()
	self:Destroy()
end

function TreasureBoxGiftView:OnDestroy()
	self:StopTimer("BoxCountDown"..self.createTime)
	self:SetGiftCollectionClick(true)
	self:CancelAllDelayRun()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
	if self.walletView then
		self.walletView:Destroy()
		self.walletView = nil
	end
	if self.rewardItemTip then
		self.rewardItemTip:Destroy();
		self.rewardItemTip = nil;
	end
end

return TreasureBoxGiftView;
