local CC = require("CC")

local BrokeGiftView = CC.uu.ClassView("BrokeGiftView")

function BrokeGiftView:ctor(param)
    self.param = param or {}
	self.language = self:GetLanguage()
	self.createTime = os.time()+math.random()
    self.PrefabInfo = {}
    self.IconTab = {}
	self.ruleWareId = nil
	self.numberRoller = nil
	self.WareIds = {"23001", "23002", "23003"}
	self.buyInBroke = false
	self.firstOpenRank = true
end

function BrokeGiftView:OnCreate()
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitUI()
end

function BrokeGiftView:InitUI()
	--大奖名单
	self.BigAwardPanel = self:FindChild("BigAwardPanel")
    self:AddClick(self.BigAwardPanel:FindChild("BigAwardBtn"), function ()
		if self.firstOpenRank then
			self:FindChild("BigAwardPanel/InfoView/GradeBtn/Tog_3"):GetComponent("Toggle").isOn = true
			self.firstOpenRank = false
		end
        self:OnBigAwardClick()
	end)
	self.Info_Content = self.BigAwardPanel:FindChild("InfoView/Scroller/Viewport/Content")
    self.Info_Item = self.BigAwardPanel:FindChild("InfoView/Scroller/Viewport/Item")
    for i = 1, 3 do
        local grade = i
        local toggle = self:FindChild(string.format("BigAwardPanel/InfoView/GradeBtn/Tog_%s", grade))
		local wareId = self.WareIds[grade]
		toggle:FindChild("Text").text = self.viewCtr.giftInfo[wareId].price
		toggle:FindChild("select/Text").text = self.viewCtr.giftInfo[wareId].price
        UIEvent.AddToggleValueChange(toggle, function(selected)
			if selected then
				-- if self.viewCtr.rankData[grade] then
				-- 	self:SetAwardInfo(self.viewCtr.rankData[grade])
				-- else
				-- 	self.viewCtr:ReqBrokeRankRecord(grade)
				-- end
				self.viewCtr:ReqBrokeRankRecord(grade)
            end
        end)
    end
	self.timeText = self:FindChild("Timer/timeText")

	for i = 1, 3 do
		local idx = i
		local wareId = self.WareIds[idx]
		self:FindChild(string.format("Grade%s/MaxNum", idx)).text =  CC.uu.ChipFormat(self.viewCtr.giftInfo[wareId].max, true)
		self:FindChild(string.format("Grade%s/BuyBtn/Text", idx)).text =  self.viewCtr.giftInfo[wareId].price

		self:AddClick(self:FindChild(string.format("Grade%s/BtnRule", idx)), function()
			self:SetRulePanel(self.WareIds[idx])
			self:FindChild("RulePanel"):SetActive(true)
		end)
		self:AddClick(self:FindChild(string.format("Grade%s/BuyBtn", idx)), function ()
			self:OnBuyGift(self.WareIds[idx])
		end)
	end
	self:AddClick(self:FindChild("RulePanel/CloseRule"), function()
		self:FindChild("RulePanel"):SetActive(false)
	end)
	self:AddClick(self:FindChild("RulePanel/BuyBtn"), function ()
		if self.ruleWareId and self.wareCfg[self.ruleWareId] then
			self:OnBuyGift(self.ruleWareId)
		end
	end)

	self:AddClick(self:FindChild("Rewards"), function()
		self:FindChild("Rewards"):SetActive(false)
	end)
    self:AddClick(self:FindChild("BtnClose"), function ()
		self:CloseView()
	end)
    self:LanguageSwitch()
	self:InitUIData()
	self.viewCtr:ReqBrokeGiftStatus()

	local portraitView = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine").PortraitSupport[self.viewName]
	self.BigAwardPanel:SetActive(not portraitView)
end

--语言切换
function BrokeGiftView:LanguageSwitch()
	for i = 1, 3 do
		local idx = i
		self:FindChild(string.format("Grade%s/Max", idx)).text = self.language.Height;
	end
	self:FindChild("RulePanel/Max").text = self.language.Height;
	self:FindChild("RulePanel/MinFrame/Min").text = self.language.low;
	self.BigAwardPanel:FindChild("InfoView/Image/Name").text = self.language.roleName;
	self.BigAwardPanel:FindChild("InfoView/Image/Info").text = self.language.winInfo;
end

function BrokeGiftView:OnBuyGift(giftWareId)
	local price = self.wareCfg[giftWareId].Price
	if CC.Player:Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
		local data={}
        data.WareId=giftWareId
        data.ExchangeWareId=giftWareId
        CC.Request("ReqBuyWithId",data)
	else
		if self.walletView then
			self.walletView:SetBuyExchangeWareId(giftWareId)
			self.walletView:PayRecharge()
		end
	end
end

--奖励
function BrokeGiftView:RewardGold(count)
	self:FindChild("Rewards"):SetActive(true)
	local param = {
		parent = self:FindChild("Rewards/Count"),
		number = count,
	}
	if self.numberRoller then
		self.numberRoller:Destroy()
		self.numberRoller = nil
	end
	self.numberRoller = CC.ViewCenter.NumberRoller.new();
	self.numberRoller:Create(param);
end

function BrokeGiftView:InitUIData()
	if self.param.isGiftCollection then
		self:FindChild("mask"):SetActive(false)
		self:FindChild("BtnClose"):SetActive(false)
	else
		self:FindChild("mask"):SetActive(true)
		self:FindChild("BtnClose"):SetActive(true)
    end
    self.walletView = CC.uu.CreateHallView("WalletView", {parent = self.transform})
	self.walletView.transform:SetParent(self.transform, false);
end

function BrokeGiftView:SetGiftInfo(param)
	self:SetCountDown(param.lLeftTimeSec)
	for _, v in ipairs(param.arrBrokenGift) do
		self:SetBuyBtnState(v.nGiftID, v.bStatus)
		if not self.viewCtr.giftInfo[v.nGiftID] then
			self.viewCtr.giftInfo[v.nGiftID] = {}
		end
		self.viewCtr.giftInfo[v.nGiftID].status = v.bStatus
		self.viewCtr.giftInfo[v.nGiftID].max = v.lMaxReward
		self.viewCtr.giftInfo[v.nGiftID].min = v.lMinReward
		self.viewCtr.giftInfo[v.nGiftID].price = v.nPrice
	end
end

function BrokeGiftView:SetBuyBtnState(wareId, canBuy)
	local idx = nil
	for i,v in pairs(self.WareIds) do
		if wareId == v then
			idx = i
			break
		end
	end
	if idx then
		self:FindChild(string.format("Grade%s/BuyBtn", idx)):SetActive(canBuy)
		self:FindChild(string.format("Grade%s/BtnRule", idx)):SetActive(canBuy)
		self:FindChild(string.format("Grade%s/UnableBtn", idx)):SetActive(not canBuy)
	end
end

function BrokeGiftView:SetRulePanel(wareId)
    if self.viewCtr.giftInfo[wareId] then
        self:FindChild("RulePanel/MaxNum").text = CC.uu.ChipFormat(self.viewCtr.giftInfo[wareId].max, true)
        self:FindChild("RulePanel/MinFrame/MinNum").text = CC.uu.ChipFormat(self.viewCtr.giftInfo[wareId].min)
        self:FindChild("RulePanel/BuyBtn/Text").text = self.viewCtr.giftInfo[wareId].price
	end
	self.ruleWareId = wareId
	self:FindChild("RulePanel/BuyBtn"):SetActive(self.viewCtr.giftInfo[wareId].status)
	self:FindChild("RulePanel/UnableBtn"):SetActive(not self.viewCtr.giftInfo[wareId].status)
end

--中大奖名单
function BrokeGiftView:OnBigAwardClick()
	--没有打开
	if self.BigAwardPanel:FindChild("BigAwardBtn/Dir").localScale.x >= 1 then
		self.BigAwardPanel:FindChild("bg"):SetActive(true)
		self.BigAwardPanel:FindChild("BigAwardBtn").localPosition = Vector3(136,10,0)
		self.BigAwardPanel:FindChild("BigAwardBtn/Dir").localScale = Vector3(-1,1,1)
		self.BigAwardPanel:FindChild("InfoView").localPosition = Vector3(404,0,0)
	else
		self.BigAwardPanel:FindChild("bg"):SetActive(false)
		self.BigAwardPanel:FindChild("BigAwardBtn").localPosition = Vector3(608,10,0)
		self.BigAwardPanel:FindChild("BigAwardBtn/Dir").localScale = Vector3(1,1,1)
		self.BigAwardPanel:FindChild("InfoView").localPosition = Vector3(876,0,0)
	end
end

--初始化大奖列表
function  BrokeGiftView:SetAwardInfo(data)
	local list = data
	for _,v in pairs(self.PrefabInfo) do
		v.transform:SetActive(false)
	end
	local isShow = true
	for i = 1,#list do
		isShow = not isShow
		self:InfoItemData(i,list[i], isShow)
	end
end

--大奖玩家信息
function BrokeGiftView:InfoItemData(index,InfoData,bgShow)
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
	param.vipLevel = InfoData.VIP
	param.clickFunc = "unClick"
	self:SetHeadIcon(param,index)
	if item then
		item.transform:SetParent(self.Info_Content, false)
		item.transform:FindChild("Nick"):GetComponent("Text").text = InfoData.Name
        item.transform:FindChild("Num"):GetComponent("Text").text = InfoData.Reward
        item.transform:FindChild("Time"):GetComponent("Text").text = os.date("%H:%M:%S %d/%m",InfoData.TimeSTamp)
        item.transform:FindChild("bg"):SetActive(bgShow)
	end
end

--删除头像对象
function BrokeGiftView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.IconTab[tonumber(headtran.transform.name)] ~= nil then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end
end

--设置头像
function  BrokeGiftView:SetHeadIcon(param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

function BrokeGiftView:SetCountDown(timer)
	local countDown = timer
	self:StartTimer("CountDown"..self.createTime, 1, function()
        local timeStr = CC.uu.TicketFormat(countDown)
        if countDown <= 0 then
			self.timeText.text = "00:00:00"
			self:StopTimer("CountDown"..self.createTime)
			self:DelayRun(1, function ( )
				self.activityDataMgr.SetActivityInfoByKey("BrokeGiftView", {switchOn = false})
				self:CloseView()
			end)
		else
			self.timeText.text = timeStr
		end
		countDown = countDown - 1
    end, -1)
end

--礼包状态
function BrokeGiftView:BrokeGiftStatus()
	local brokeGiftData = self.activityDataMgr.GetBrokeGiftData()
	if brokeGiftData.nStatus == 1 then
		if brokeGiftData.arrBrokenGift then
			for _, v in ipairs(brokeGiftData.arrBrokenGift) do
				if v.bStatus then
					--有档位没有购买
					return
				end
			end
			--档位都购买了
			self.activityDataMgr.SetActivityInfoByKey("BrokeGiftView", {switchOn = false})
		end
	end
end

function BrokeGiftView:ActionIn()
	if self.param.isGiftCollection then
		self:SetCanClick(false);
		self:FindChild("mask"):SetActive(false)
		self:FindChild("BtnClose"):SetActive(false)
		--self.transform.size = Vector2(125, 0)
		--self.transform.localPosition = Vector3(-125 / 2, 0, 0)
		self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
	end
end

function BrokeGiftView:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

--关闭界面
function BrokeGiftView:CloseView()
	self:ActionOut()
end

function BrokeGiftView:OnDestroy()
	self:CancelAllDelayRun()
	self:StopTimer("CountDown"..self.createTime)
    for i,v in pairs(self.IconTab) do
		if v then
			v:Destroy()
			v = nil
		end
    end
	if self.numberRoller then
		self.numberRoller:Destroy()
		self.numberRoller = nil
	end
	if self.walletView then
		self.walletView:Destroy()
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
	self:BrokeGiftStatus()
	if self.param.callback then
		self.param.callback(self.buyInBroke)
	end
end

return BrokeGiftView;