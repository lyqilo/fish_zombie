
local CC = require("CC")
local NewPayGiftView = CC.uu.ClassView("NewPayGiftView")

--宝箱领奖spine索引
local spineIndex = {1,1,2,2,3,3,4,5}

function NewPayGiftView:ctor(viewParam,language,btnName,collection)

	self:InitVar(viewParam,language,btnName,collection);
end

function NewPayGiftView:InitVar(viewParam,language,btnName,collection)
    self.param = viewParam or {}
    self.collection = collection
	self.language = self:GetLanguage()
	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
    self.propfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.newPayCfg = CC.ConfigCenter.Inst():getConfigDataByKey("NewPayGiftConfig")
    self.RechargeTotal = 0
    --排行榜排名梯度
    self.RankGrads = {{1,1},{2,2},{3,3},{4,10},{11,20}}
    --中jp窗口展示的图片
    self.JpImageCfg = {"dj_jp10","dj_jp30","dj_jp40","dj_jp50"}

    self.isOppo = CC.ChannelMgr.CheckOppoChannel()
    self.award = self.newPayCfg.boxRewards
    self.PayRankPrize = self.newPayCfg.rankRewards
    self.CurBoxId = 1
	self.isRankViewOpen = false
	self.IconTab = {}
    self.headIndex = 0
end

function NewPayGiftView:OnCreate()
    self:InitNode()
    self:InitView()
    self:InitClickEvent()
    self.viewCtr = self:CreateViewCtr(self.param);
    self.viewCtr:OnCreate()
	self:RefreshBoxAward(0)
end

function NewPayGiftView:InitNode()
    self.PayTotal = self:FindChild("UI/PayTotal")
    self.TimeTxt = self:FindChild("UI/RightPanel/Time")
    self.PayRankPanel = self:FindChild("RankNode/PayRankPanel")
    self.PayRankParent = self.PayRankPanel:FindChild("Panel/Bg/Scroll View/Viewport/Content")
    --self.PayItem = self.isOppo and self.PayRankParent:FindChild("Item_oppo") or self.PayRankParent:FindChild("Item_nomal")
    self.PayItem = self.PayRankParent:FindChild("Item_nomal")
    self.LotteryBtn = self:FindChild("Btn/LotteryBtn")
    self.NormalBtn = self:FindChild("Btn/LotteryBtn/Normal")
    self.LotteryFlag = self.NormalBtn:FindChild("Lottery")
    self.GrayBtn = self:FindChild("Btn/LotteryBtn/Gray")
    self.WinRankPanel = self:FindChild("RankNode/WinRankPanel")
    self.WinRankParent = self.WinRankPanel:FindChild("Bg/Scroll View/Viewport/Content")
    self.WinItem = self.WinRankParent:FindChild("Item")
	self.MeritsIcon = self.NormalBtn:FindChild("Merits")
	self.CapsuleCoin = self.NormalBtn:FindChild("CoinTip")
	self.rankNode = self:FindChild("RankNode")
	self.rankMask = self:FindChild("RankNode/Mask")
	
	self.startNode = self:FindChild("UI/LeftPanel/ShowRange/StartNode")
	self.bubblePrefab = self:FindChild("UI/LeftPanel/ShowRange/Item")
	self.bubbleParent = self:FindChild("UI/LeftPanel/ShowRange/Parent")

    self.BoxNode = {}
    self.BoxCfg = {}
    local rechargeCfg = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine").Recharge[self.isOppo and 2 or 1]
    for i = 1,8 do
        table.insert(self.BoxNode,self:FindChild("Btn/Box/Box"..i))
        table.insert(self.BoxCfg,{RechargeTarget = rechargeCfg[i]})
        self.BoxNode[i]:FindChild("Image/Text").text = rechargeCfg[i].."฿"
    end

end

function NewPayGiftView:InitView()
    self.TimeTxt.text = string.format(self.language.ActTime,self.newPayCfg.time)
    self.NormalBtn:FindChild("Text").text = self.language.Lottery
    self.GrayBtn:FindChild("Text").text = self.language.YetLottery
    self.PayTotal:FindChild("Text").text = self.language.PayTotal
	self.PayTotal:FindChild("ScoreText").text = self.language.PayScore
    self.BoxNode[1]:FindChild("Tip/Text").text = self.language.RandomPay
    self.WinRankPanel:FindChild("Bg/Title/Image/Text").text = self.language.PrizeList
    self.WinRankPanel:FindChild("Bg/Top/Nick").text = self.language.Nick
    self.WinRankPanel:FindChild("Bg/Top/ID").text = "ID"
    self.WinRankPanel:FindChild("Bg/Top/Prize").text = self.language.Award
    self.WinRankPanel:FindChild("Bg/Top/Time").text = self.language.PrizeTime
	self.MeritsIcon:FindChild("Bubble/Image/Text").text = self.language.meritsTip
	self:FindChild("RankNode/ToggleGroup/PayRank/Background/Label").text = self.language.btnRank
	self:FindChild("RankNode/ToggleGroup/PayRank/Checkmark/Label").text = self.language.btnRank
	self:FindChild("RankNode/ToggleGroup/WinRank/Background/Label").text = self.language.PrizeList
	self:FindChild("RankNode/ToggleGroup/WinRank/Checkmark/Label").text = self.language.PrizeList
	self.PayRankPanel:FindChild("Panel/MyRank/noRank").text = self.language.noRank

    self.lanuageType = CC.LanguageManager.GetType()
end

function NewPayGiftView:InitClickEvent()
    self:AddClick(self:FindChild("Btn/ExplainBtn") , function() self:OpenExplainView() end,nil,true)
    self:AddClick(self.NormalBtn, function() self:OnNormalClick() end,nil,true)
    self:AddClick(self:FindChild("Btn/WinBtn") , function()  self:OpenRecord() end,nil,true)
    self:AddClick(self.WinRankPanel:FindChild("Bg/BackBtn") , function() self:CloseRecord() end,nil,true)
	self:AddClick("Btn/PreviewBtn",function ()
			local param = {}
			param.rechargeCfg = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine").Recharge[self.isOppo and 2 or 1]
			param.boxCfg = self.award
			CC.ViewManager.Open("NewPayGiftPreviewView",param)
		end)

    for i,v in ipairs(self.BoxNode) do
        local index = i
        UIEvent.AddToggleValueChange(v,function(selected) if selected then self:OnClickBox(index)end end)
    end
	self.BoxNode[1]:GetComponent("Toggle").isOn = true

	self:AddClick(self.MeritsIcon,function ()
			local bubble = self.MeritsIcon:FindChild("Bubble")
			bubble:SetActive(true)
			self:DelayRun(3,function ()
					bubble:SetActive(false)
				end)
		end)
	self:AddClick(self.MeritsIcon:FindChild("Bubble/Close"),function ()
			self.MeritsIcon:FindChild("Bubble"):SetActive(false)
		end)
	self:AddClick(self.rankMask,"ChangeRankViewStatus")
	
	UIEvent.AddToggleValueChange(self:FindChild("RankNode/ToggleGroup/PayRank"),function (selected)
			if selected then
				self:ShowRankPanel(1)
				if not self.isRankViewOpen then
					self:ChangeRankViewStatus()
				end
			end
		end)
	UIEvent.AddToggleValueChange(self:FindChild("RankNode/ToggleGroup/WinRank"),function (selected)
			if selected then
				self:ShowRankPanel(2)
				if not self.isRankViewOpen then
					self:ChangeRankViewStatus()
				end
			end
		end)
end

function NewPayGiftView:OpenRecord()
    self:SetCanClick(false)
    self.WinRankPanel:SetActive(true)
    local node = self.WinRankPanel:FindChild("Bg")
    node.transform.localScale = Vector3(0.5,0.5,1)
    self:RunAction(node, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
            self:SetCanClick(true);
    end})
end

function NewPayGiftView:CloseRecord()
    self:SetCanClick(false);
    self:RunAction(self.WinRankPanel:FindChild("Bg"), {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
            self:SetCanClick(true);
            self.WinRankPanel:SetActive(false)
    end})
end

function NewPayGiftView:OpenExplainView()
	if self.lanuageType == "Chinese" then
		self.ExplainContent = self.newPayCfg.ChineseExplain
	else
		self.ExplainContent = self.newPayCfg.ThaiExplain
	end
	local content = self.ExplainContent.Content
	local rewardName = {}
	for _,v in ipairs(self.newPayCfg.rankRewards) do
		local name = self.propLanguage[v.id]
		table.insert(rewardName,name)
	end
	local data = {
		title = self.ExplainContent.Title,
		content = string.format(content,self.newPayCfg.time,rewardName[1],rewardName[2],rewardName[3],rewardName[4],rewardName[5]),
	}
	data.tableData = {}
	for _, v in ipairs(self.ExplainContent.ChannelTitle) do
		table.insert(data.tableData, v)
	end
	CC.ViewManager.Open("CommonExplainView", data)
end

function NewPayGiftView:OnNormalClick()
	if self.LotteryFlag.activeSelf then
        CC.Request("ReqRechargeOpenBox",{BoxID = self.BoxCfg[self.CurBoxId].BoxID})
    else
        CC.ViewManager.Open("StoreView")
        if self.collection then self.collection:ActionOut() end
    end
end

function NewPayGiftView:StartLottery(Reward,JPType)
    CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, false)
    self:SetCanClick(false)
    self.isLottery = true

	local Icon = JPType ~= 0 and self.JpImageCfg[JPType] or self.propfg[Reward[1].ConfigId].Icon
	local fun = function()
		self.isLottery = false
		CC.ViewManager.OpenRewardsView({items = Reward,callback = function ()
					if CC.uu.IsNil(self.transform) then return end
					self:ShowGiftSpine(false)
					--存储下这个宝箱抽奖的结果
					CC.LocalGameData.SetDataByKey("NewPayGiftView_V1",CC.Player.Inst():GetSelfInfoByKey("Id")..self.CurBoxId,Icon)
					--刷新宝箱打开状态
					self:RefreshBox(self.CurBoxId,true,false)
					self.BoxCfg[self.CurBoxId].IsOpen = true
					--检查下个宝箱是否可以抽奖
					self:CheckNextBox()
					--如果中实物奖励，打开邮箱
					if self.propfg[Reward[1].ConfigId].Physical then
						CC.ViewManager.Open("MailView")
					end
				end})
		CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, true)
		self:SetCanClick(true)
	end
	--self:ShowGiftSpine(true)
	--self:RunAction(self.transform,
		--{"delay",2.2,function ()
				fun()
		--end})
end

function NewPayGiftView:ShowGiftSpine(isShow)
	self:FindChild("GiftSpine"):SetActive(isShow)
	local index = spineIndex[self.CurBoxId]
	for i=1,5 do
		self:FindChild("GiftSpine/Spine"..i):SetActive(false)
	end
	if isShow then
		local spine = self:FindChild("GiftSpine/Spine"..index)
		spine:SetActive(true)
		spine:GetComponent("SkeletonGraphic").AnimationState:SetAnimation(0, "stand01", false)
	end
end

function NewPayGiftView:CheckNextBox()
   for i,v in ipairs(self.BoxCfg) do
       if not v.IsOpen and self.RechargeTotal >= v.RechargeTarget then
           self.BoxNode[i]:GetComponent("Toggle").isOn = true
           return
       end
   end
   self.NormalBtn:SetActive(false)
   self.GrayBtn:SetActive(true)
end

function NewPayGiftView:RefreshView(data)
    self.PayTotal:FindChild("Num").text = string.format("%s%s",CC.uu.DiamondFortmat(data.ActualRechargeNum)," ฿")
	self.PayTotal:FindChild("Score").text = CC.uu.DiamondFortmat(data.RechargeNum)
    self.RechargeTotal = data.ActualRechargeNum
    --local index = nil
    for i,v in ipairs(data.InfoList) do
        self.BoxCfg[i].IsOpen = v.IsOpen
        self.BoxCfg[i].BoxID = v.BoxID
        local value = not v.IsOpen and data.ActualRechargeNum >= self.BoxCfg[i].RechargeTarget
        self:RefreshBox(i, v.IsOpen,value)
        --if index == nil and value then index = i end
    end

    --index = index or 1
    --if index == self.CurBoxId then self.BoxNode[self.CurBoxId]:GetComponent("Toggle").isOn = false end
    --self.BoxNode[index]:GetComponent("Toggle").isOn = true
end

function NewPayGiftView:RefreshBox(index,IsOpen,isMove)
    local Box = self.BoxNode[index]
    Box:FindChild("Baoxiang"):GetComponent("Animator").enabled = isMove
    Box:FindChild("Baoxiang"):SetActive(not IsOpen)
    Box:FindChild("BaoxiangOpen"):SetActive(IsOpen)
end

function NewPayGiftView:OnClickBox(index)
    --抽奖时不做操作
    if self.isLottery then return end 
    for i=1,8 do 
		self.BoxNode[i]:FindChild("glow"):SetActive(i == index)
	end
    self.CurBoxId = index
    local boxCfg = self.BoxCfg[index]
    local state = boxCfg.IsOpen
    self.NormalBtn:SetActive(not state)
    self.GrayBtn:SetActive(state)
	
	if not state then
		self:CheckMeritsIcon()
		--self:CheckCapsuleCoin(self:GetBoxRewards(self.CurBoxId))
	end
	
    if self.RechargeTotal < boxCfg.RechargeTarget then
        local Str = index == 1 and self.language.ToPay or string.format(self.language.PayTip,boxCfg.RechargeTarget - self.RechargeTotal)
        self.NormalBtn:FindChild("Text").text = Str
        self.LotteryFlag:SetActive(state)
    else
        self.NormalBtn:FindChild("Text").text = self.language.Lottery
        self.LotteryFlag:SetActive(not state)
    end
	self:RefreshBoxAward(self.CurBoxId)
 end

function NewPayGiftView:RefreshBoxAward(index)
	
	local awards = self:GetBoxRewards(index)

	if index == 0 then
		self.NormalBtn:SetActive(false)
		self.GrayBtn:SetActive(false)
	end

	self:StopTimer("Bubble")
	Util.ClearChild(self.bubbleParent)
	local loopIdx = 1
	local func = function()
		for i=1,3 do
			if loopIdx > #awards then
				loopIdx = 1
			end
			local data = awards[loopIdx]
			local endNode = self:FindChild("UI/LeftPanel/ShowRange/EndNode"..i)
			self:CreateBubbleItem(data, endNode.position)
			loopIdx = loopIdx + 1
		end
	end
	func()
	self:StartTimer("Bubble", 2, func, -1)
end

function NewPayGiftView:CreateBubbleItem(data,endPos)
	local item = CC.uu.newObject(self.bubblePrefab,self.bubbleParent)
	item.position = self.startNode.position
	local action = nil
	local actionParam = {}
	local duration = 20
	local startX = item.position.x
	local startY = item.position.y
	local endX = endPos.x
	local endY = endPos.y
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

function NewPayGiftView:CheckMeritsIcon()
	local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("DonateView").switchOn
	self.MeritsIcon:SetActive(switchOn)
end

function NewPayGiftView:CheckCapsuleCoin(data)
	local num = 0
	for _,v in ipairs(data) do
		if v.id == CC.shared_enums_pb.EPC_TwistEgg_Coin then
			num = tonumber(string.match(v.text,"%d"))
		end
	end
	self.CapsuleCoin:FindChild("Bubble/Text").text = num
	self.CapsuleCoin:SetActive(num > 0)
end

function NewPayGiftView:GetRewardIcon(rank)
    for i,v in ipairs(self.RankGrads) do
        if rank >= v[1] and rank <= v[2] then
            return self.propfg[self.PayRankPrize[i].id].Icon,self.PayRankPrize[i].text
        end
    end
    return self.propfg[self.PayRankPrize[#(self.RankGrads)].id].Icon,self.PayRankPrize[#(self.RankGrads)].text
end

function NewPayGiftView:RefreshJackPot(value)
	self:FindChild("UI/RightPanel/Jp").text = CC.uu.ChipFormat(value,true)
end

function NewPayGiftView:ShowRankPanel(index)
	self.PayRankPanel:SetActive(index==1)
	self.WinRankPanel:SetActive(index==2)
end

function NewPayGiftView:ChangeRankViewStatus()
	self.isRankViewOpen = not self.isRankViewOpen
	self.rankMask:SetActive(self.isRankViewOpen)
	if self.isRankViewOpen then
		self:RunAction(self.rankNode,{"localMoveBy", -706, 0, 0.2, ease=CC.Action.EOutSine})
	else
		self:RunAction(self.rankNode,{"localMoveBy", 706, 0, 0.2, ease=CC.Action.EOutSine})
	end
end

function NewPayGiftView:GetBoxRewards(boxId)
	return self.award["box"..boxId].list or {}
end

function NewPayGiftView:ShowWinnerItem(Item,value)
    Item:FindChild("Nick").text = value.PlayerName
    Item:FindChild("Id").text = value.PlayerID
    local str = self.propLanguage[value.PropID]
    if value.PropID == CC.shared_enums_pb.EPC_ChouMa then
        str = CC.uu.ChipFormat(value.PropNum,true)
    end
	local thai = string.match(str,"[^%w^%s^%p]")
	if not thai then
		str = string.len(str) < 15 and str or string.sub(str, 1, 15) .. "..."
	end
    Item:FindChild("Prize").text = str
    Item:FindChild("Time").text = os.date("%d/%m %H:%M",value.TimeStamp)
    local param = {}
    param.parent =  Item:FindChild("HeadNode")
    param.playerId = value.PlayerID
    param.vipLevel = value.VipLevel
    param.portrait = value.Portrait
    param.headFrame = value.Background
    self:SetHeadIcon(param)
    Item:SetActive(true)
end

function NewPayGiftView:ShowPayRank(data)
    self.initRank = coroutine.start(function()
        for i = 1,self.RankGrads[#(self.RankGrads)][2] do
            local obj = CC.uu.newObject(self.PayItem,self.PayRankParent)
            obj.name = i
            obj:FindChild("rank").text = i
			obj:FindChild("Bg"):SetActive(i%2==0)
            local image,des = self:GetRewardIcon(i)
            self:SetImage(obj:FindChild("reward"),image)
            obj:FindChild("reward"):GetComponent("Image"):SetNativeSize()
            if des then 
                obj:FindChild("reward/Text").text = des
                obj:FindChild("reward/Text").y = -15
            end
            if data.RechargeRank and data.RechargeRank[i] then
                local v = data.RechargeRank[i]
                obj:FindChild("info/name").text = v.PlayerName
                obj:FindChild("info/bg/ls").text = v.RechargeNum
                self:SetHeadIcon({parent = obj:FindChild("txnode"),playerId = v.PlayerID,vipLevel = v.VipLevel,portrait = v.Portrait,headFrame = v.Background})
				if CC.Player.Inst():GetSelfInfoByKey("Id") == v.PlayerID then
					self.PayRankPanel:FindChild("Panel/MyRank/noRank"):SetActive(false)
				end
            else
                self:SetHeadIcon({parent = obj:FindChild("txnode"),playerId = i,clickFunc = "unClick"})
            end
            obj:SetActive(true)
            coroutine.step(1)
        end
    end)
	self:SetHeadIcon({parent = self.PayRankPanel:FindChild("Panel/MyRank/txnode"),clickFunc = "unClick"})
	self.PayRankPanel:FindChild("Panel/MyRank/name").text = CC.Player.Inst():GetSelfInfoByKey("Nick")
	if data.RankID and data.RankID > 0 then
		self.PayRankPanel:FindChild("Panel/MyRank/rank").text = data.RankID
	else
		self.PayRankPanel:FindChild("Panel/MyRank/rank").text = "No Rank"
	end
	self.PayRankPanel:FindChild("Panel/MyRank/score").text = data.Score
end

function NewPayGiftView:SetHeadIcon(param)
    self.headIndex = self.headIndex +1
    local HeadIcon = CC.HeadManager.CreateHeadIcon(param)
    self.IconTab[self.headIndex] = HeadIcon
end


function NewPayGiftView:ActionIn()
    self:SetCanClick(false);
    self.transform.size = Vector2(125, 0)
	self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function NewPayGiftView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
        });
    self:Destroy()
end

function NewPayGiftView:OnDestroy()
    if self.param.closeFunc then
        local state = false
        for i,v in ipairs(self.BoxCfg) do
            if not v.IsOpen and self.RechargeTotal >= v.RechargeTarget then
                state = true
                break
            end
        end
        self.param.closeFunc(state)
    end
	for i,v in pairs(self.IconTab) do
        if v then
          v:Destroy()
          v = nil
        end
    end
	if self.initRank then
		coroutine.stop(self.initRank)
		self.initRank = nil
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil;
    end

    CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, true)
end

return NewPayGiftView