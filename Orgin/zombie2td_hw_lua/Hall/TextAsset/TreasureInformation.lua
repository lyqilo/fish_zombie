---------------------------------
-- region TreasureInformation.lua		-
-- Date: 2019.11.11				-
-- Desc:  一元夺宝               -
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local TreasureInformation = CC.uu.ClassView("TreasureInformation")

function TreasureInformation:ctor(param)
	self:InitVar(param)
end

function TreasureInformation:OnCreate()

    self.language = CC.LanguageManager.GetLanguage("L_TreasureView");
    
    local viewCtrClass = require("View/TreasureView/TreasureInformationCtr")
	
	self.viewCtr = viewCtrClass.new(self);

	self.recordPanel = self:FindChild("BG/RecordList")

	self.scrollview = self:FindChild("BG/RecordList/ScrollView")

	self.scrollBar = self:SubGet("BG/RecordList/ScrollView/Scrollbar", "Scrollbar")

	self.item = self:FindChild("RecordItem")

	self.itemParent = self:FindChild("BG/RecordList/ScrollView/Viewport/Content")
	
	self.viewCtr:OnCreate()
	
	self:AddClickEvent()
	
    self:InitTextByLanguage()

	self:RefreshTreasureInfo(self.param)

	self:ModifyQuantity(false)
end

function TreasureInformation:InitVar(param)

	self.param = param

	self.bInitShow = false
	
	--购买次数
	self.times = 1 

	--夺宝ID
	self.PrizeId = self.param.PrizeId

	--夺宝期数
	self.Issue = self.param.Issue

	--商品价格
	self.Price = self.param.Price

	--消耗货币
	self.Currency = self.param.Currency

	--VIP限制
	self.VipLimit = self.param.VipLimit

	--购买限制
	self.LimitQuota = self.param.LimitQuota   
	
	--是否支持筹码补齐
	self.IsSupplement = self.param.IsSupplement

	--已经购买多少次
	self.PurchasedQuota = 0

	self.Portrait = nil

	self.isOpenPrize = false

	self.RecordInit = true


	-- 请求锁, 用于防止频繁的向服务器发送请求
	self.queryLock = 0   -- 0 解锁 1 加锁  2 永久加锁

	self.RecordList = {}
end

function TreasureInformation:RefreshCodeNum(count)
	if count > 0 then
		self:FindChild("BG/Detail/Shadow/Underline/Text").text = string.format(self.language.myCode,count)
		self:FindChild("BG/Detail/Shadow/Underline"):SetActive(true)
	else
		self:FindChild("BG/Detail/Shadow/Underline"):SetActive(false)
	end
end

function TreasureInformation:RefreshTreasureInfo(data)
	if not data.Issue then
		--如果商品下架了，传过来的是空数据，这个时候需要关闭imfomation界面
		self:ActionOut()
		return
	end
	if self.Issue ~= data.Issue then
		self.bInitShow = false
	end
	if not self.bInitShow then
		self.PrizeId = data.PrizeId
		self.Issue = data.Issue
		self.Price = data.Price
		self.Currency = data.Currency
		self.VipLimit = data.VipLimit
		local priceIcon = self.viewCtr.realDataMgr.GetPriceIcon(data.Currency)
		local image = self:FindChild("BG/Detail/Purchasing/SubBtn/Text/Icon")
		self:SetImage(image, priceIcon)
		image:GetComponent("Image"):SetNativeSize()
		self:FindChild("BG/Detail/Purchasing/SubBtn/Text").text = data.Price
		self:SetImage(self:FindChild("BG/Detail/Shadow/Goods/Base/Down/Icon"), data.Icon)
		self:FindChild("BG/Detail/Shadow/Goods/Base/Down/Name").text = data.Name
		self:FindChild("BG/Detail/Shadow/Desc").text = self.language[data.Desc]
		self:FindChild("BG/Detail/Shadow/Name").text = data.Name
		if data.VipLimit > 0 then
			self:FindChild("BG/Detail/Shadow/Goods/Base/Down/Spike"):SetActive(false)
			self:FindChild("BG/Detail/Shadow/Goods/Base/Down/VIP"):SetActive(true)
			self:FindChild("BG/Detail/Shadow/Goods/Base/Down/VIP/Start_VIP/Text").text = data.VipLimit
		else
			self:FindChild("BG/Detail/Shadow/Goods/Base/Down/Spike"):SetActive(true)
			self:FindChild("BG/Detail/Shadow/Goods/Base/Down/VIP"):SetActive(false)
		end   
		if data.LimitQuota > 0 then
			self:FindChild("BG/Detail/Shadow/Issue/LimitQuota").text = string.format(self.language.infor_LimitQuota,data.LimitQuota)
		end
	end
	self.PurchasedQuota = data.PurchasedQuota
	self:ReFreshBtnState()
	self:FindChild("BG/Detail/Shadow/Goods/Base/Down/Issue").text = string.format(self.language.label_Issue,data.Issue)
	self:FindChild("BG/Detail/Shadow/Issue").text = string.format(self.language.label_Issue,data.Issue)
	self:SetCurState(data)
end

function TreasureInformation:SetCurState(data)
	if self.isOpenPrize then return end
	
	if data.WaitOpen then
		self:IssuePurchaseState(data,true)
		self:IssueOpenState(true)
		self:IssueEndState(data,false)
		self:IssueRemainState(false)
		self:IssuePrepareState(data,false)
		self:IssueWaitOpenState(true)
	elseif data.Status == CC.proto.client_treasure_pb.IssuePurchase then
		--购买中
		self:IssuePurchaseState(data,true)
		self:IssueOpenState(false)
		self:IssueEndState(data,false)
		self:IssueRemainState(false)
		self:IssuePrepareState(data,false)
		self:IssueWaitOpenState(false)
	elseif data.Status == CC.proto.client_treasure_pb.IssueOpen then
		--开奖中
		self:IssuePurchaseState(data,false)
		self:IssueOpenState(true)
		self:IssueEndState(data,false)
		self:IssueRemainState(false)
		self:IssuePrepareState(data,false)
		self:IssueWaitOpenState(false)
	elseif data.Status == CC.proto.client_treasure_pb.IssueEnd then
		--开奖
		self:IssuePurchaseState(data,false)
		self:IssueOpenState(false)
		self:IssueEndState(data,true)
		self:IssueRemainState(false)
		self:IssuePrepareState(data,false)
		self:IssueWaitOpenState(false)
	elseif data.Status == CC.proto.client_treasure_pb.IssueRemain then
		--流拍
		self:IssuePurchaseState(data,false)
		self:IssueOpenState(false)
		self:IssueEndState(data,false)
		self:IssueRemainState(true)
		self:IssuePrepareState(data,false)
		self:IssueWaitOpenState(false)
	elseif data.Status == CC.proto.client_treasure_pb.IssuePrepare then
		--预售
		self:IssuePurchaseState(data,false)
		self:IssueOpenState(false)
		self:IssueEndState(data,false)
		self:IssueRemainState(false)
		self:IssuePrepareState(data,true)
		self:IssueWaitOpenState(false)
	-- elseif data.Status == CC.proto.client_treasure_pb.IssueWaitOpen then
		-- --等待开奖
		-- self:IssuePurchaseState(data,true)
		-- self:IssueOpenState(true)
		-- self:IssueEndState(data,false)
		-- self:IssueRemainState(false)
		-- self:IssuePrepareState(data,false)
		-- self:IssueWaitOpenState(true)
	end
end

function TreasureInformation:IssuePurchaseState(data,bState)
	if bState then
		if data.OpenType == CC.proto.client_treasure_pb.Time then
			if data.CountDown then
				self:StartCountdown(data)
				self:FindChild("BG/Detail/Shadow/CountDown"):SetActive(true)
			end
			if data.TotalQuota > 0 then
				self:FindChild("BG/Detail/Shadow/Times").text = string.format(self.language.infor_purchasedQuota,data.SoldQuota,data.TotalQuota)
			else
				self:FindChild("BG/Detail/Shadow/Times").text = string.format(self.language.infor_purchasedQuota3,data.SoldQuota)
			end
			self:FindChild("BG/Detail/Shadow/Times"):SetActive(true)
			self:FindChild("BG/Detail/Purchasing"):SetActive(true)
		else
			local bDayLimit = data.DayLimit
			if bDayLimit then
				self:FindChild("BG/Detail/Shadow/Slider"):SetActive(false)
				self:FindChild("BG/Detail/Shadow/Times"):SetActive(false)
				self:FindChild("BG/Detail/Shadow/DayLimit"):SetActive(true)
			else
				self:RefreshSlider(data)
				self:FindChild("BG/Detail/Shadow/Slider"):SetActive(true)
				self:FindChild("BG/Detail/Shadow/Times").text = string.format(self.language.infor_purchasedQuota2,data.SoldQuota,data.TotalQuota)
				self:FindChild("BG/Detail/Shadow/Times"):SetActive(true)
				self:FindChild("BG/Detail/Shadow/DayLimit"):SetActive(false)
				self:FindChild("BG/Detail/Purchasing"):SetActive(true)
			end
		end
		self:FindChild("BG/Detail/Shadow/Goods/Base/Down/Issue"):SetActive(true)
		if data.PurchasedQuota > 0 then
			self:FindChild("BG/Detail/Shadow/Underline/Text").text = string.format(self.language.myCode,data.PurchasedQuota)
			self:FindChild("BG/Detail/Shadow/Underline"):SetActive(true)
			if self.LimitQuota ~= 0 and data.PurchasedQuota >= self.LimitQuota then
				self:FindChild("BG/Detail/Purchasing/SubBtn"):GetComponent("Button"):SetBtnEnable(false)
			else
				self:FindChild("BG/Detail/Purchasing/SubBtn"):GetComponent("Button"):SetBtnEnable(true)
			end
		else
			self:FindChild("BG/Detail/Shadow/Underline"):SetActive(false)
		end
	else
		self:FindChild("BG/Detail/Shadow/CountDown"):SetActive(false)
		self:FindChild("BG/Detail/Shadow/Slider"):SetActive(false)
		self:FindChild("BG/Detail/Shadow/Times"):SetActive(false)
		self:FindChild("BG/Detail/Purchasing"):SetActive(false)
	end
end

function TreasureInformation:StartCountdown(data)
    local hourText = self:FindChild("BG/Detail/Shadow/CountDown/Hour/Text")
	local minuteText = self:FindChild("BG/Detail/Shadow/CountDown/Minute/Text")
	local secondText = self:FindChild("BG/Detail/Shadow/CountDown/Second/Text")
	hourText.text,minuteText.text,secondText.text = CC.uu.TicketReturnText(data.CountDown)
	self:StartTimer(data.PrizeId,1,function ()
		if data.CountDown > 1 then
			data.CountDown = data.CountDown - 1
			hourText.text,minuteText.text,secondText.text = CC.uu.TicketReturnText(data.CountDown)
		else
			self:StopTimer(data.PrizeId)
		end
	end,-1)
end

function TreasureInformation:RefreshSlider(data)
	local slider = self:FindChild("BG/Detail/Shadow/Slider"):GetComponent("Slider")
	slider.maxValue = data.TotalQuota
	slider.value = data.SoldQuota
end

function TreasureInformation:IssueOpenState(bState)
	if bState then
		self:FindChild("BG/Detail/Wait"):SetActive(true)
	else
		self:FindChild("BG/Detail/Wait"):SetActive(false)
	end
end

function TreasureInformation:IssueEndState(data,bState)
	if bState then
		local PlayerId = data.LuckyPlayer.PlayerId
		local NickName = data.LuckyPlayer.NickName
		local Vip = data.LuckyPlayer.Vip
		local Portrait = data.LuckyPlayer.Portrait
		local WinninerNumber = data.LuckyPlayer.WinninerNumber
		local PurchaseTimes = data.LuckyPlayer.PurchaseTimes

		if self.Portrait then
			self.Portrait:Destroy(true)
		end

		self:FindChild("BG/Detail/LuckShow/Nick").text = NickName
		self:FindChild("BG/Detail/LuckShow/Frequency").text = string.format(self.language.label_NumberPurchased,PurchaseTimes)
		self:SetWinNum(self:FindChild("BG/Detail/LuckShow/Num"),WinninerNumber)
		self.Portrait = self:SetHeadIcon(self:FindChild("BG/Detail/LuckShow/Node"),PlayerId,Portrait,Vip)
		self:FindChild("BG/Detail/LuckShow"):SetActive(true)
	else
		self:FindChild("BG/Detail/LuckShow"):SetActive(false)
	end
end

function TreasureInformation:IssueRemainState(bState)
	if bState then
		self:FindChild("BG/Detail/Shadow/Goods/Base/Down/Icon").material = ResMgr.LoadAsset("material", "Gray");
		self:FindChild("BG/Detail/Shadow/Goods/Base/Down/AuctionFail"):SetActive(true)
	else
		self:FindChild("BG/Detail/Shadow/Goods/Base/Down/Icon").material = nil
		self:FindChild("BG/Detail/Shadow/Goods/Base/Down/AuctionFail"):SetActive(false)
	end
end

function TreasureInformation:IssuePrepareState(data,bState)
	if bState then
		self:FindChild("BG/Detail/Shadow/Goods/Base/Down/Issue"):SetActive(false)
		self:FindChild("BG/Detail/Shadow/Goods/Base/Down/Presale"):SetActive(true)
		self:FindChild("BG/Detail/Shadow/Goods/Base/Down/Presale/Time").text = os.date("%d-%m-%Y %H:%M:%S",data.SellStartTime)
	else
		self:FindChild("BG/Detail/Shadow/Goods/Base/Down/Presale"):SetActive(false)
	end
end

function TreasureInformation:IssueWaitOpenState(bState)

	if bState then
		self:FindChild("BG/Detail/Purchasing"):SetActive(false)
	end
end

function TreasureInformation:AddClickEvent()
	--关闭界面
	self:AddClick("BG/CloseBtn",function () self:ActionOut() end)
	--打开锁定Tips
	self:AddClick("BG/Detail/Purchasing/BtnTips",function ()
		CC.ViewManager.Open("TreasureTipsView",self.Currency)
	end)
	self:FindChild("BG/Detail/Purchasing/BtnTips"):SetActive(false)
	--修改购买数量
	self:AddClick("BG/Detail/Purchasing/AddBtn",function ()
		self:ModifyQuantity(true)
	end)
	self:AddClick("BG/Detail/Purchasing/LessBtn",function ()
		self:ModifyQuantity(false)
	end)
	--大额修改数量
	self:AddClick("BG/Detail/Purchasing/AddMore",function ()
		self:ModifyMoreQuantity(true)
	end)
	self:AddClick("BG/Detail/Purchasing/LessMore",function ()
		self:ModifyMoreQuantity(false)
	end)
	--参与夺宝
	self:AddClick("BG/Detail/Purchasing/SubBtn",function ()
		local data = {}
		data.PrizeId = self.PrizeId
		data.Issue = self.Issue
		data.Times = self.times
		data.Price = self.Price
		data.Currency = self.Currency
		data.VipLimit = self.VipLimit
		data.IsSupplement = self.IsSupplement
		self.viewCtr:Req_PrizePuarchase(data)
	end)
	--打开我的夺宝码
	self:AddClick("BG/Detail/Shadow/Underline",function ()
		local param = {}
		param.CodeList = nil
		param.PrizeId = self.PrizeId
		param.Issue = self.Issue
		CC.ViewManager.Open("TreasureCodePanel",param)
	end)
	--商品详情
	self:AddClick("BG/Title/Detail",function ()
		self:FindChild("BG/Detail"):SetActive(true)
		self.recordPanel.localPosition = Vector3(5000,0,0)
	end)
	--幸运儿列表
	self:AddClick("BG/Title/Record",function ()
		if self.RecordInit then
			self.RecordInit = false
			self.viewCtr:Req_PrizeLuckyRecord()
		end
		self:FindChild("BG/Detail"):SetActive(false)
		self.recordPanel.localPosition = Vector3(0,0,0)
	end)

	-- 通过下拉来获取新的记录
	self.scrollview.onEndDrag = function ( obj,eventData )
		if eventData.rawPointerPress == eventData.pointerPress then
			-- 下拉处理 -- 注意:需要防止用户疯狂的进行下拉操作导致重复取或多取数据
			local fnQuery = function(  )

				if self.scrollBar.value == 0 then
					self:StopTimer("timer_bar")

					self.queryLock = 1
					self.viewCtr:Req_PrizeLuckyRecord()
				end
			end
		
			-- 做个流畅性处理 1s内检测
			local totalTime = 10
			self:StartTimer("timer_bar", 0.1,
			function (  )
				totalTime = totalTime - 1
				if totalTime < 0 then
					self:StopTimer("timer_bar")
				else
					if self.queryLock == 0 then
						fnQuery()
					end
				end
			end,totalTime)
		end
	end
end

function TreasureInformation:ModifyQuantity(bAdd)
	if bAdd then
		if self.times + 1 <= self.LimitQuota or self.LimitQuota == 0 then
			self.times = self.times + 1
		else
			CC.ViewManager.ShowTip(self.language.infor_PurchaseLimit)
		end
	elseif self.times - 1 > 0 then
		self.times = self.times - 1
	end
	self:ReFreshBtnState()
end

function TreasureInformation:ModifyMoreQuantity(bAdd)
	if bAdd then
		if self.times + 10 <= self.LimitQuota or self.LimitQuota == 0 then
			self.times = self.times + 10
		else
			self.times = self.LimitQuota - self.PurchasedQuota
		end
	else
		if self.times - 10 > 0 then
			self.times = self.times - 10
		else
			self.times = 1
		end
	end
	self:ReFreshBtnState()
end

function TreasureInformation:ReFreshBtnState()
	if self.PurchasedQuota + self.times >= self.LimitQuota and self.LimitQuota ~= 0 then
		self:FindChild("BG/Detail/Purchasing/AddBtn"):GetComponent("Button"):SetBtnEnable(false)
		self:FindChild("BG/Detail/Purchasing/AddMore"):GetComponent("Button"):SetBtnEnable(false)
	else
		self:FindChild("BG/Detail/Purchasing/AddBtn"):GetComponent("Button"):SetBtnEnable(true)
		self:FindChild("BG/Detail/Purchasing/AddMore"):GetComponent("Button"):SetBtnEnable(true)
	end
	if self.times == 1 then
		self:FindChild("BG/Detail/Purchasing/LessBtn"):GetComponent("Button"):SetBtnEnable(false)
		self:FindChild("BG/Detail/Purchasing/LessMore"):GetComponent("Button"):SetBtnEnable(false)
	else
		self:FindChild("BG/Detail/Purchasing/LessBtn"):GetComponent("Button"):SetBtnEnable(true)
		self:FindChild("BG/Detail/Purchasing/LessMore"):GetComponent("Button"):SetBtnEnable(true)
	end
	if self.times < 0 then
		self.times = 1
	end
	self:FindChild("BG/Detail/Purchasing/SubBtn/Text").text = CC.uu.ChipFormat(self.times * self.Price)
	self:FindChild("BG/Detail/Purchasing/TextBG/Text").text = self.times
end

function TreasureInformation:ResetTimes()
	self.times = 1
end

function TreasureInformation:OpenTreasureCodePanel(data)
	local param = {}
	param.CodeList = data
	param.PrizeId = self.PrizeId
	param.Issue = self.Issue
	CC.ViewManager.Open("TreasureCodePanel",param)
end

function TreasureInformation:OpenTreasureTips(data)
	local param = {}
	param.RequestTimes = data.RequestTimes
	param.SuccessTimes = data.SuccessTimes
	CC.ViewManager.Open("TreasureTips",param)
end

function TreasureInformation:InitTextByLanguage()
    self:FindChild("BG/Title/Detail/Label").text = self.language.infor_title_Detail
	self:FindChild("BG/Title/Record/Label").text = self.language.infor_title_Record
	
	self:FindChild("BG/Detail/Shadow/DayLimit").text = self.language.infor_dayLimit
	self:FindChild("BG/Detail/Shadow/CountDown/Remaining").text = self.language.top_Remaining
	self:FindChild("BG/Detail/Shadow/CountDown/L_Hour").text = self.language.top_Hour
	self:FindChild("BG/Detail/Shadow/CountDown/L_Minute").text = self.language.top_Minute
	self:FindChild("BG/Detail/Shadow/CountDown/L_Second").text = self.language.top_Second
	self:FindChild("BG/Detail/LuckShow/Label").text = self.language.infor_Lucky
	if self.Currency == CC.shared_enums_pb.EPC_PointCard_Fragment then
	    self:FindChild("BG/Detail/Purchasing/BtnTips/Tips").text = self.language.infor_CardFragmentTips
    else
        self:FindChild("BG/Detail/Purchasing/BtnTips/Tips").text = self.language.infor_chipTips
    end
	self:FindChild("BG/RecordList/Tips").text = self.language.noTreasureRollInfo
end

function TreasureInformation:FillRecordItem(data)
	local Issue = data.Issue
	local itemName = "item" .. Issue
	local itemPrefab = self:AddPrefab(self.item, self.itemParent,itemName)
	itemPrefab:FindChild("Issue").text = string.format(self.language.label_Issue,Issue)
	itemPrefab:FindChild("Time").text = CC.uu.TimeOut3(data.EndTime)
	if data.Remain then
		itemPrefab:FindChild("Remain"):SetActive(true)
		itemPrefab:FindChild("NotRemain"):SetActive(false)
	else
		local PlayerId = data.LuckyPlayer.PlayerId
		local NickName = data.LuckyPlayer.NickName
		local Vip = data.LuckyPlayer.Vip
		local Portrait = data.LuckyPlayer.Portrait
		local WinninerNumber = data.LuckyPlayer.WinninerNumber
		local PurchaseTimes = data.LuckyPlayer.PurchaseTimes
		itemPrefab:FindChild("Remain"):SetActive(false)
		itemPrefab:FindChild("NotRemain"):SetActive(true)
		itemPrefab:FindChild("NotRemain/Nick").text = NickName
		itemPrefab:FindChild("NotRemain/Frequency").text = string.format(self.language.label_NumberPurchased,PurchaseTimes)
		self:SetWinNum(itemPrefab:FindChild("NotRemain/Num"),WinninerNumber)
		self.RecordList[Issue] = self:SetHeadIcon(itemPrefab:FindChild("NotRemain/Node"),PlayerId,Portrait,Vip)
	end
	itemPrefab:SetActive(true)
end

function TreasureInformation:RecordReqFail()
	self:FindChild("BG/RecordList/ScrollView"):SetActive(false)
	self:FindChild("BG/RecordList/Tips"):SetActive(true)
end

function TreasureInformation:OpenPrize(data)
	if data.Remain then return end
	self.isOpenPrize = true
	self:IssuePurchaseState(nil,false)
	self:IssueOpenState(true)
end

function TreasureInformation:OpenPrizeFinish()
	self.isOpenPrize = false
end

function TreasureInformation:SetWinNum(tran,num)
	local sWin = tostring(string.format("1%07d",num))
	local sLen = #sWin - 1
	local index = 1
	for i = 8-sLen, 8 do
		tran:FindChild(i.."/Text").text = string.sub(sWin,index,index)
		index = index + 1
	end
end

--设置头像
function TreasureInformation:SetHeadIcon(node,id,portrait,level,fun)
	local param = {}
	param.parent = node
	param.playerId = id
	param.portrait = portrait
	param.vipLevel = level
	param.clickFunc = fun
	return CC.HeadManager.CreateHeadIcon(param)
end

function TreasureInformation:OnDestroy()
	if self.Portrait then
		self.Portrait:Destroy(true)
	end
	for k, v in pairs(self.RecordList) do
		if v then
			v:Destroy(true)
		end
	end
	self:StopAllTimer()
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return TreasureInformation