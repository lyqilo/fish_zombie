---------------------------------
-- region SuperTreasureView.lua		-
-- Date: 2020.09.05				-
-- Desc:  超级夺宝               -
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local SuperTreasureView = CC.uu.ClassView("SuperTreasureView")

function SuperTreasureView:ctor(param)
	self:InitVar(param);
end

function SuperTreasureView:InitVar(param)
    --夺宝商品数量(用于本地与服务器数量不同时刷新本地商品)
    self.treasureCount = 0;
    --夺宝初始化状态
    self.bInitTreasure = false;
    --夺宝货架
	self.treasureShelf = {};
    --夺宝对象
    self.treasureItem = {};
	self.scrollDirUp = true
end

function SuperTreasureView:OnCreate()
    self.language = self:GetLanguage();
    --货架Item
    self.shelfItem = self:FindChild("TreasureShelfItem");
    --货架parentNode
    self.shelfNode = self:FindChild("BG/TreasurePanel/Viewport/Content");
    --拉取失败Tips
	self.shelfTips = self:FindChild("BG/TreasurePanel/Tips");
	--小奖票
	self.smallText = self:FindChild("BG/SmallFrame/Count")
	--大奖票
	self.bigText = self:FindChild("BG/BigFrame/Count")
	--跑马灯文字
	self.MarqueeText = self:FindChild("BG/Marquee/Text")
	self.BtnBottom = self:FindChild("BtnBottom")
	self.scrollRect = self:FindChild("BG/TreasurePanel")

    self.viewCtr = self:CreateViewCtr(self.param);
    self.viewCtr:OnCreate();

    self:AddClickEvent();
	self:InitTextByLanguage();
end

function SuperTreasureView:AddClickEvent()
	--打开邮箱
	self:AddClick("BG/BtnGroup/MailBtn",function ()
		CC.ViewManager.Open("MailView")
	end)
	--打开自己兑换记录
	self:AddClick("BG/BtnGroup/RecordBtn",function ()
		CC.ViewManager.Open("TreasureRecordPanel")
	end)
	--打开夺宝奖票礼包
	self:AddClick("BG/Button",function ()
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnCollectionViewJumpToView, "GiftExchangeView")
	end)
	self:AddClick(self.BtnBottom, function()
		self:SetEquitiesScroll(not self.scrollDirUp)
	end)
	UIEvent.AddScrollRectOnValueChange(self.scrollRect,function (v)
		if v.y < 0.9 then
			self.scrollDirUp = false
			self.BtnBottom.localScale = Vector3(1, -1, 1)
		else
			self.scrollDirUp = true
			self.BtnBottom.localScale = Vector3(1, 1, 1)
		end
	end)
end

function SuperTreasureView:InitTextByLanguage()
	self:FindChild("BG/Time").text = self.language.actTime
	self:FindChild("BG/Tips").text = self.language.tips
	self:FindChild("BG/Button/Text").text = self.language.btnText
	self:FindChild("BG/TreasurePanel/Tips").text = self.language.reqFail
	for i = 1, 3 do
		self.shelfItem:FindChild("Board/"..i.."/Base/Top/CountDown/Remaining").text = self.language.top_Remaining
		self.shelfItem:FindChild("Board/"..i.."/Base/Top/CountDown/L_Hour").text = self.language.top_Hour
		self.shelfItem:FindChild("Board/"..i.."/Base/Top/CountDown/L_Minute").text = self.language.top_Minute
		self.shelfItem:FindChild("Board/"..i.."/Base/Top/CountDown/L_Second").text = self.language.top_Second
		self.shelfItem:FindChild("Board/"..i.."/Base/Top/LuckCode/Label").text = self.language.top_code
		self.shelfItem:FindChild("Board/"..i.."/Base/Down/WinningInfo/Text").text = self.language.down_winLabel
	end
end

function SuperTreasureView:SetEquitiesScroll(isUp)
	--滑动
	local value = isUp and 1 or 0
	local scaleY = isUp and 1 or -1
	self.scrollDirUp = isUp
	self.BtnBottom.localScale = Vector3(1, scaleY, 1)
	self.scrollRect:GetComponent("ScrollRect").verticalNormalizedPosition = value
end

function SuperTreasureView:RefrshProp()
	self.smallText.text = CC.Player.Inst():GetSelfInfoByKey("EPC_MidMonth_Treasure_Small") or 0
	self.bigText.text = CC.Player.Inst():GetSelfInfoByKey("EPC_MidMonth_Treasure_Big") or 0
end

function SuperTreasureView:RefreshTreasureList(param)
	self.shelfTips:SetActive(false);
	if self.treasureCount ~= #param then
		self:ClearShelf();
		self.treasureCount = #param;
		self.bInitTreasure = false;
		self.treasureShelf = {};
		self.treasureItem = {};
	end

	--货架数
	local shelfNum = math.ceil(#param/3);
	local goodsNum = #param + 1;
	local curNum = 0;
	self.BtnBottom:SetActive(shelfNum > 1)

	self.co_InitUI = coroutine.start(function()
		for s=1,shelfNum do
			local Shelf = nil
			if not self.bInitTreasure then
				self.treasureShelf[s] = {}
				Shelf = CC.uu.newObject(self.shelfItem, self.shelfNode)
				self.treasureShelf[s].transform = Shelf
			else
				Shelf = self.treasureShelf[s].transform
			end
			for i=1,3 do
				curNum = curNum + 1
				if curNum < goodsNum then
					local data = param[curNum]
					local PrizeId = data.PrizeId
					if not self.treasureItem[PrizeId] then
						self.treasureItem[PrizeId] = {}
						self.treasureItem[PrizeId].Issue = 0	--初始化时开奖期数设为0，需要初始化item
						self.treasureItem[PrizeId].OpenPrize = false
						self.treasureItem[PrizeId].transform = Shelf.transform:FindChild("Board/"..i.."/Base")
					end
					self:RefreshTreasureGoods(self.treasureItem[PrizeId],data)
					self:RefreshTreasureGoodsState(self.treasureItem[PrizeId],data)
					Shelf.transform:FindChild("Board/"..i.."/Base"):SetActive(true)
					Shelf.transform:FindChild("Board/"..i.."/Null"):SetActive(false)
				elseif curNum == goodsNum then
					Shelf.transform:FindChild("Board/"..i.."/Base"):SetActive(false)
					Shelf.transform:FindChild("Board/"..i.."/Null"):SetActive(true)
				else
					Shelf.transform:FindChild("Board/"..i.."/Base"):SetActive(false)
					Shelf.transform:FindChild("Board/"..i.."/Null"):SetActive(false)
				end
			end
			Shelf.transform:SetActive(true)
			if s == shelfNum then
				self.bInitTreasure = true
			end
			coroutine.step(1)
		end
	end)
end

function SuperTreasureView:ClearShelf()
	for k, v in pairs(self.treasureItem) do
		if v.Portrait then
			v.Portrait:Destroy(true)
		end
		self:StopTimer(k)
	end
	Util.ClearChild(self:FindChild("BG/TreasurePanel/Viewport/Content"))
end

function SuperTreasureView:RefreshTreasureGoods(param,data)
	local tran = param.transform
	if param.Issue ~= data.Issue then
		param.Issue = data.Issue

		local priceIcon = self.viewCtr.realDataMgr.GetPriceIcon(data.Currency)
		local node = tran:FindChild("Down/Icon")
		self:SetImage(node, data.Icon)
		node:GetComponent("Image"):SetNativeSize()
		tran:FindChild("Down/Icon").material = nil
		tran:FindChild("Down/Name").text = data.Name
		if data.VipLimit > 0 then
			tran:FindChild("Down/Spike"):SetActive(false)
			tran:FindChild("Down/VIP"):SetActive(true)
			tran:FindChild("Down/VIP/Start_VIP/Text").text = data.VipLimit
		else
			tran:FindChild("Down/Spike"):SetActive(true)
			tran:FindChild("Down/VIP"):SetActive(false)
		end
		local image = tran:FindChild("Down/Price/Text/Icon")
		self:SetImage(image, priceIcon)
		image:GetComponent("Image"):SetNativeSize()
		tran:FindChild("Down/Price/Text").text = data.Price
	end
	tran:FindChild("Top/Times/Text").text = string.format(self.language.purchasedQuota,data.SoldQuota)
	self:AddClick(tran, function()
		CC.ViewManager.Open("TreasureInformation",data)
	end)
end

function SuperTreasureView:RefreshTreasureGoodsState(param,data)
	if self.treasureItem[data.PrizeId].OpenPrize then return end
	local tran = param.transform
	if data.WaitOpen then
		self:IssuePurchaseState(tran,data,true)
		self:IssueEndState(tran,data,false)
		self:IssueRemainState(tran,data,false)
		self:IssuePrepareState(tran,data,false)
	elseif data.Status == CC.proto.client_treasure_pb.IssuePurchase then
		--购买中
		self:IssuePurchaseState(tran,data,true)
		self:IssueEndState(tran,data,false)
		self:IssueRemainState(tran,data,false)
		self:IssuePrepareState(tran,data,false)
	elseif data.Status == CC.proto.client_treasure_pb.IssueOpen then
		--开奖中
	elseif data.Status == CC.proto.client_treasure_pb.IssueEnd then
		--开奖
		self:IssuePurchaseState(tran,data,false)
		self:IssueEndState(tran,data,true)
		self:IssueRemainState(tran,data,false)
		self:IssuePrepareState(tran,data,false)
	elseif data.Status == CC.proto.client_treasure_pb.IssueRemain then
		--流拍
		self:IssuePurchaseState(tran,data,false)
		self:IssueEndState(tran,data,false)
		self:IssueRemainState(tran,data,true)
		self:IssuePrepareState(tran,data,false)
	elseif data.Status == CC.proto.client_treasure_pb.IssuePrepare then
		--预售
		self:IssuePurchaseState(tran,data,false)
		self:IssueEndState(tran,data,false)
		self:IssueRemainState(tran,data,false)
		self:IssuePrepareState(tran,data,true)
	end
end
function SuperTreasureView:IssuePurchaseState(tran,data,bState)
	if bState then
		tran:FindChild("Down/Icon").material = nil
		tran:FindChild("Down/Price"):SetActive(true)
		tran:FindChild("Top/Times"):SetActive(true)
		if data.OpenType == CC.proto.client_treasure_pb.Time then
			tran:FindChild("Top/CountDown"):SetActive(true)
			if data.CountDown then
				self:StartCountdown(tran,data)
			end
		end
	else
		tran:FindChild("Top/CountDown"):SetActive(false)
		tran:FindChild("Down/Price"):SetActive(false)
		tran:FindChild("Top/Times"):SetActive(false)
	end
end

function SuperTreasureView:StartCountdown(tran,data)
	local hourText = tran:FindChild("Top/CountDown/Hour/Text")
	local minuteText = tran:FindChild("Top/CountDown/Minute/Text")
	local secondText = tran:FindChild("Top/CountDown/Second/Text")
	hourText.text,minuteText.text,secondText.text = CC.uu.TicketReturnText(data.CountDown)
	self:StartTimer(data.PrizeId,1,function ()
		if data.CountDown > 1 then
			data.CountDown = data.CountDown - 1
			hourText.text,minuteText.text,secondText.text = CC.uu.TicketReturnText(data.CountDown)
		else
			self:IssueOpenState(tran)
			self:StopTimer(data.PrizeId)
		end
	end,-1)
end

function SuperTreasureView:IssueOpenState(tran,bState)
end

function SuperTreasureView:IssueEndState(tran,data,bState)
	if bState then
		local PlayerId = data.LuckyPlayer.PlayerId
		local NickName = data.LuckyPlayer.NickName
		local Portrait = data.LuckyPlayer.Portrait
		local WinninerNumber = data.LuckyPlayer.WinninerNumber
		local vip = data.LuckyPlayer.Vip

		if self.treasureItem[data.PrizeId].Portrait then
			self.treasureItem[data.PrizeId].Portrait:Destroy(true)
		end
		self:SetWinNum(tran:FindChild("Top/LuckCode/Num"),WinninerNumber)
		tran:FindChild("Down/WinningInfo/Name").text = NickName
		self.treasureItem[data.PrizeId].Portrait = self:SetHeadIcon(tran:FindChild("Down/WinningInfo/Node"),PlayerId,Portrait,vip,"unClick")
		tran:FindChild("Top/LuckCode"):SetActive(true)
		tran:FindChild("Down/WinningInfo"):SetActive(true)
	else
		tran:FindChild("Top/LuckCode"):SetActive(false)
		tran:FindChild("Down/WinningInfo"):SetActive(false)
	end
end

function SuperTreasureView:IssueRemainState(tran,data,bState)
	if bState then
		tran:FindChild("Down/Icon").material = ResMgr.LoadAsset("material", "Gray");
		tran:FindChild("Down/AuctionFail"):SetActive(true)
	else
		tran:FindChild("Down/Icon").material = nil
		tran:FindChild("Down/AuctionFail"):SetActive(false)
	end
end

function SuperTreasureView:IssuePrepareState(tran,data,bState)
	if bState then
		tran:FindChild("Down/Presale"):SetActive(true)
		tran:FindChild("Down/Presale/Time").text = os.date("%d-%m-%Y %H:%M:%S",data.SellStartTime)
	else
		tran:FindChild("Down/Presale"):SetActive(false)
	end
end

function SuperTreasureView:InitTreasureFail()
	self:FindChild("BG/TreasurePanel/Viewport/Content"):SetActive(false)
	self:FindChild("BG/TreasurePanel/Tips"):SetActive(true)
end

--设置头像
function SuperTreasureView:SetHeadIcon(node,id,portrait,level,fun)
	local param = {}
	param.parent = node
	param.playerId = id
	param.portrait = portrait
	param.vipLevel = level
	param.clickFunc = fun
	return CC.HeadManager.CreateHeadIcon(param)
end

function SuperTreasureView:OpenPrize(data)
	--流拍不需要展示动画
	if data.Remain then
		return
	end
	local PrizeId = data.PrizeId
	--推送延迟或推送数据和当期不符丢弃信息
	if self.treasureItem[PrizeId].Issue ~= data.Issue then
		return
	end
	local WinninerNumber = data.LuckyPlayer.WinninerNumber
	self.treasureItem[PrizeId].OpenPrize = true
	local tran = self.treasureItem[PrizeId].transform
	local anitor = tran:FindChild("Top/LuckCode/Num"):GetComponent("Animator")
	self:IssuePurchaseState(tran,nil,false)
	tran:FindChild("Top/LuckCode"):SetActive(true)

	for i = 1, 8 do
		tran:FindChild("Top/LuckCode/Num/"..i.."/Text"):GetComponent("Text").material = ResMgr.LoadAsset("material", "TreasureBlur");
		tran:FindChild("Top/LuckCode/Num/"..i.."/Text1"):GetComponent("Text").material = ResMgr.LoadAsset("material", "TreasureBlur");
	end
	anitor:Play("TreasureAni",-1,0)
	self:StartTimer("rand"..PrizeId, 0.05, function()
		local num = math.random(10000000,99999999)
		self:SetNum(tran:FindChild("Top/LuckCode/Num"),num)
	end, -1)
	local component = tran:FindChild("Top/LuckCode/Num"):GetComponent("Elf_AnimatorEventHandle")
    component:SetHandleEventFun(function(eventName)
		if eventName == "shownumber" then
			for i = 1, 8 do
				tran:FindChild("Top/LuckCode/Num/"..i.."/Text"):GetComponent("Text").material = nil
				tran:FindChild("Top/LuckCode/Num/"..i.."/Text1"):GetComponent("Text").material = nil
			end
			self:StopTimer("rand"..PrizeId)
			self:SetWinNum(tran:FindChild("Top/LuckCode/Num"),WinninerNumber)
			anitor:SetTrigger("stop")
			self:DelayRun(1,function ()
				self.treasureItem[PrizeId].OpenPrize = false
				CC.HallNotificationCenter.inst():post(CC.Notifications.OnOpenPrizeFinish)
			end)
        end
	end)
end

function SuperTreasureView:SetWinNum(tran,num)
	local sWin = tostring(string.format("1%07d",num))
	local sLen = #sWin - 1
	local index = 1
	for i = 8-sLen, 8 do
		tran:FindChild(i.."/Text1").text = string.sub(sWin,index,index)
		index = index + 1
	end
end

function SuperTreasureView:SetNum(tran,num)
	local sWin = tostring(num)
	local sLen = #sWin - 1
	local index = 1
	for i = 8-sLen, 8 do
		tran:FindChild(i.."/Text").text = string.sub(sWin,index,index)
		tran:FindChild(i.."/Text1").text = math.floor((tonumber(string.sub(sWin,index,index))+1)/2)
		index = index + 1
	end
end

function SuperTreasureView:StartMarquee()
	self:StartTimer("Marquee",1,function ()
		if self.isMarqueeMoving then
			return
		else
			self.isMarqueeMoving = true
			self.MarqueeText.text = self:DealWithString(string.format(self.language.treasureText,self.viewCtr:GetMarqueeText()))
			self.MarqueeText.localPosition = Vector3(2000,2000,0)
			self:DelayRun(0.1,function()
				local textW = self.MarqueeText:GetComponent('RectTransform').rect.width
				local half = textW/2
				self.MarqueeText.localPosition = Vector3(half + 220, -10, 0)
				self.action = self:RunAction(self.MarqueeText, {"localMoveTo", -half - 220, -10, 0.65 * math.max(16,textW/40), function()
					self.action = nil
					self.isMarqueeMoving = false
				end})
			end)
		end
	end,-1)
end

function SuperTreasureView:DealWithString(text)
	local str = string.gsub(CC.uu.ReplaceFace(text,23,true),'%s+',' ')
	return str
end

function SuperTreasureView:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function SuperTreasureView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function SuperTreasureView:OnDestroy()
	for k, v in pairs(self.treasureItem) do
		if v.Portrait then
			v.Portrait:Destroy(true)
		end
	end
	if self.co_InitUI then
		coroutine.stop(self.co_InitUI)
		self.co_InitUI = nil
	end
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
	self:StopAllTimer()
	self:StopUpdate()
end

return SuperTreasureView