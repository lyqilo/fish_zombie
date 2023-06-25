---------------------------------
-- region TreasureView.lua		-
-- Date: 2019.11.11				-
-- Desc:  一元夺宝               -
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local TreasureView = CC.uu.ClassView("TreasureView")

function TreasureView:ctor(param)
	self:InitVar(param)
end

function TreasureView:OnCreate()
	self:SetCanClick(false)

	self.scroller = self:FindChild("BottomPanel/InfoPanel/Scroller")

	self.language = self:GetLanguage()

	--左侧切换按钮
	self.TableGroup = {}
	self.TableGroup[1] = self:FindChild("ToggleGroup/Treasure")
	self.TableGroup[2] = self:FindChild("ToggleGroup/Integral")
	self.TableGroup[3] = self:FindChild("ToggleGroup/Chip")
	self.TableGroup[4] = self:FindChild("ToggleGroup/RedEnvelope")

	self.viewCtr = self:CreateViewCtr(self.param)

	self.ScrollerController = self:FindChild("AllScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
	xpcall(function() self.viewCtr:InfoItem(tran,dataIndex,cellIndex) end,function(error) logError(error) end) end)

	self.SelfScrollerController = self:FindChild("SelfScrollerController"):GetComponent("ScrollerController")
	self.SelfScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
	xpcall(function() self.viewCtr:SelfInfoItem(tran,dataIndex,cellIndex) end,function(error) logError(error) end) end)
	self.BottomContainer = self:FindChild("BottomPanel/InfoPanel/Scroller/Container")
    self.BottomContainer:SetActive(false)
	--兑换提示
	self.exchangeLimitBox = self:FindChild("ExchangeLimitBox")
	

	self.viewCtr:OnCreate()

	if CC.ChannelMgr.CheckOppoChannel() then
		self:FindChild("BtnGroup/VipBtn"):SetActive(false)
	elseif CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
		self:FindChild("BtnGroup/VipBtn"):SetActive(true)
	else
		--if CC.ChannelMgr.GetSwitchByKey("bHasGift") then
			--local GiftNode = self:FindChild("BtnGroup/Node");
			--GiftNode:SetActive(true);
			--self.GiftBtn = CC.SelectGiftManager.CreateIcon({parent = GiftNode});
		--end
	end

	self.marquee = self:FindChild("SpeakerBord")
	self.marqueeText = self:FindChild("SpeakerBord/SpeakerImg/TextTip")
	self.marqueeWidth = (self:FindChild("SpeakerBord/SpeakerImg"):GetComponent('RectTransform').rect.width - 15)/2

	self:AddClickEvent()
	self:InitTextByLanguage()
	self:RefreshSwitchState()
	self:InitTopPanel()
	self:InitRoolEvent()

	self:FindChild("BottomPanel/iosTips"):SetActive(CC.Platform.isIOS)

	self:StartTimer("RefreshTreasure",3,function ()
		CC.Request("Req_PrizeList")
	end,-1)

	-- if self.switchDataMgr.GetSwitchStateByKey("TreasureEffect") then
	--     self:ClickTabBtn(self.TableGroup[1])
	-- elseif self.switchDataMgr.GetSwitchStateByKey("ChipExchange") then
	--     self:ClickTabBtn(self.TableGroup[3])
	-- else
	--     self:ClickTabBtn(self.TableGroup[2])
	-- end

	if self.param and self.param.OpenViewId then
		self:ClickTabBtn(self.TableGroup[self.param.OpenViewId])
	elseif self:IsShowRedEnvelope() then
		self:ClickTabBtn(self.TableGroup[4])
	else
		self:ClickTabBtn(self.TableGroup[2])
	end

	CC.uu.DelayRun(0.2,function ()
			self:SetCanClick(true)
			if self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") then
				CC.LocalGameData.SetLocalDataToKey("TreasureTips", CC.Player.Inst():GetSelfInfoByKey("Id"))
			end
			if self.switchDataMgr.GetSwitchStateByKey("ChipExchange") then
				CC.LocalGameData.SetLocalDataToKey("TreasureTips1", CC.Player.Inst():GetSelfInfoByKey("Id"))
			end
			if self.curShopType == CC.proto.client_shop_pb.RedEnvelopeShop then
				self:ExMarquee(false)
			elseif not CC.LocalGameData.GetDailyStateByKey("RealStore") and self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") then
				CC.LocalGameData.SetDailyStateByKey("RealStore", true)
				self:PlayMarquee(true)
			else
				self:ExMarquee(false)
			end
		end)

	if CC.ChannelMgr.GetTrailStatus() then
		self:FindChild("BtnGroup/TipsBtn"):SetActive(false);
	end
	
	self:RefreshRedEnvelope()
	self:CheckGuide()
end

function TreasureView:InitVar(param)
	self.param = param

	self.bInitIntegralGoods,self.bInitChipGoods,self.bInitTreasure = false,false,false

	--夺宝物品数量
	self.treasureCount = 0
	--夺宝货架
	self.treasureShelf = {}
	--商品对象
	self.goodsItem = {}
	--夺宝对象
	self.treasureItem = {}
    --点卡碎片兑换信息
	self.PointCardInfo = nil
	--引导状态
	self.guideState = true
	self.guideGoodId = 0
	--协同程序
	self.co_InitUI = {}
	--商品列表
	self.goodsList = {}
	--红包商城子标签页
	self.redEnvelopePage = 1
	self.switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")
end

function TreasureView:CheckGuide()
	if self.param and self.param.guideFlag then
		self:DelayRun(0.2, function ( )
			CC.ViewManager.Open("GuideView", {singleFlag = 13})
		end)
	end
end

function TreasureView:AddClickEvent()
	--切换按钮
	for i = 1,4 do
		self:AddClick(self.TableGroup[i],function(obj) self:ClickTabBtn(obj) end ,"click")
	end
	--关闭界面
	self:AddClick("TopPanel/BtnBG/BtnBack",function () self:Destroy() end)
	--打开邮箱
	self:AddClick("BtnGroup/MailBtn",function ()
		CC.ViewManager.Open("MailView")
	end)
	--打开自己兑换记录
	self:AddClick("BtnGroup/RecordBtn",function ()
		if self.curShopType == 0 then
			CC.ViewManager.Open("TreasureRecordPanel")
		else
			self.viewCtr.ReqRecordBuy()
			self:OpenRecordPanel()
		end
	end)
	--关闭自己兑换记录
	self:AddClick("RecordPanel/Mask",function ()
		self:CloseRecordPanel()
	end)
	--打开Tips
	self:AddClick("BtnGroup/TipsBtn",function ()
		CC.ViewManager.Open("RealStoreExplainView",{shopType = self.curShopType})
	end)
	--VIP礼包
	self:AddClick("BtnGroup/VipBtn",function ()
		local param = {}
		param.SelectGiftTab = {"NoviceGiftView"}
		CC.ViewManager.Open("SelectGiftCollectionView",param)
	end)
	--兑换说明
	self:AddClick("BottomPanel/ExchangeTipBtn",function ()
		CC.ViewManager.Open("TreasureExchangeTips")
	end)
	self:AddClick("ExchangeLimitBox/Mask",function ()
		self.exchangeLimitBox:SetActive(false)
	end)
	self:AddClick("ExchangeLimitBox/Frame/BtnFitter/BtnNo",function ()
		self.exchangeLimitBox:SetActive(false)
	end)
	self:AddClick("ExchangeLimitBox/Frame/BtnTips",function ()
		self.exchangeLimitBox:SetActive(false)
		CC.ViewManager.Open("TreasureExchangeTips")
	end)

	UIEvent.AddToggleValueChange(self:FindChild("RedEnvelopePanel/BtnTab/BtnGroup/BtnCatch"), function(selected)
			if selected then
				--捕获类
				if self.redEnvelopePage and self.redEnvelopePage == 1 then return end
				self.redEnvelopePage = 1
				self.refreshGoods = true
				self.viewCtr:ReqGetGoodsList()
			end
		end)
	UIEvent.AddToggleValueChange(self:FindChild("RedEnvelopePanel/BtnTab/BtnGroup/BtnChess"), function(selected)
			if selected then
				--棋牌类
				if self.redEnvelopePage and self.redEnvelopePage == 2 then return end
				self.redEnvelopePage = 2
				self.refreshGoods = true
				self.viewCtr:ReqGetGoodsList()
			end
		end)
end

function TreasureView:InitTextByLanguage()
	self:FindChild("ToggleGroup/Treasure/Label").text = self.language.tab_Treasure
	self:FindChild("ToggleGroup/Integral/Label").text = self.language.tab_Exchange
	self:FindChild("ToggleGroup/Chip/Label").text = self.language.tab_Exchange
	self:FindChild("ToggleGroup/RedEnvelope/Label").text = self.language.tab_RedEnvelope
	self:FindChild("BottomPanel/iosTips/Text").text = self.language.iosTips
	self:FindChild("RecordPanel/BG/Label/Label_award").text = self.language.record_award
	self:FindChild("RecordPanel/BG/Label/Label_time").text = self.language.record_time
	self:FindChild("RecordPanel/BG/Title/Text").text = self.language.record_title
	self:FindChild("BottomPanel/ExchangeTipBtn/Text").text = self.language.tipsButton
	self.exchangeLimitBox:FindChild("Frame/BtnTips"):GetComponent("RichText").text = "<u>"..self.language.tipsButton.."</u>"
	self.exchangeLimitBox:FindChild("Frame/BtnFitter/BtnOk/Text").text = self.language.btnOk
	self.exchangeLimitBox:FindChild("Frame/BtnFitter/BtnNo/Text").text = self.language.btnCancel
	self.exchangeLimitBox:FindChild("Frame/DailyLimit/Text").text = self.language.dailyLimit
	--
	for i = 1, 3 do
		self:FindChild("TreasureShelfItem/Board/"..i.."/Base/Top/CountDown/Remaining").text = self.language.top_Remaining
		self:FindChild("TreasureShelfItem/Board/"..i.."/Base/Top/CountDown/L_Hour").text = self.language.top_Hour
		self:FindChild("TreasureShelfItem/Board/"..i.."/Base/Top/CountDown/L_Minute").text = self.language.top_Minute
		self:FindChild("TreasureShelfItem/Board/"..i.."/Base/Top/CountDown/L_Second").text = self.language.top_Second
		self:FindChild("TreasureShelfItem/Board/"..i.."/Base/Top/LuckCode/Label").text = self.language.top_code
		self:FindChild("TreasureShelfItem/Board/"..i.."/Base/Down/WinningInfo/Text").text = self.language.down_winLabel
	end
	self:FindChild("IntegralPanel/Tips").text = self.language.reqFail
	self:FindChild("ChipPanel/Tips").text = self.language.reqFail
	self:FindChild("RedEnvelopePanel/Tips").text = self.language.reqFail
	self:FindChild("TreasurePanel/Tips").text = self.language.treasure_ReqFail
end

function TreasureView:ClickTabBtn(obj)
	local _btnName = obj.gameObject.name
	if _btnName == self.hisTabClick then return end
	if _btnName == "Treasure" then
		--一元夺宝
		self.TableGroup[1]:GetComponent("Toggle").isOn = true
		self.curShopType = 0
		self:RefreshShowPanel(self.curShopType)
		self.viewCtr:SetReqGoodsInfoState(false)
		--self:SetTreasureLocation(true)
		if not self.viewCtr.gameDataMgr.GetSingleFlag(22) then
			CC.ViewManager.Open("GuideView", {singleFlag = 22})
		end
	elseif _btnName == "Integral" then
		--礼券兑换
		self.TableGroup[2]:GetComponent("Toggle").isOn = true
		self.curShopType = CC.proto.client_shop_pb.LiQuanShop
		self:RefreshShowPanel(self.curShopType)
		self.viewCtr:ReqGetGoodsList()
		self.viewCtr:SetReqGoodsInfoState(true)
		--self.viewCtr:InitIntegralGoods()
		--self:SetTreasureLocation(false)
	elseif _btnName == "RedEnvelope" then
		--红包兑换
		self.TableGroup[4]:GetComponent("Toggle").isOn = true
		self.curShopType = CC.proto.client_shop_pb.RedEnvelopeShop
		self:RefreshShowPanel(self.curShopType)
		self.viewCtr:ReqGetGoodsList()
		self.viewCtr:SetReqGoodsInfoState(true)
		self:FindChild("RedEnvelopePanel/BtnTab/BtnGroup/BtnCatch"):GetComponent("Toggle").isOn = true
	else
		--筹码兑换
		self.TableGroup[3]:GetComponent("Toggle").isOn = true
		self.curShopType = CC.proto.client_shop_pb.ChouMaShop
		self:RefreshShowPanel(self.curShopType)
		self.viewCtr:ReqGetGoodsList()
		self.viewCtr:SetReqGoodsInfoState(true)
		--self.viewCtr:InitChipGoods()
		--self:SetTreasureLocation(false)
	end
	self.viewCtr:InitRollPanel()
	if not self.showMarquee then
		self.marqueeText:GetComponent('Text').text = self:GetMarqueeText()
	end
	self:ShowExchangeTipBtn(self.curShopType ~= CC.proto.client_shop_pb.RedEnvelopeShop)
	self.hisTabClick = _btnName
end

function TreasureView:InitTopPanel()
	local headNode = self:FindChild("TopPanel/HeadNode");
	self.HeadIcon = CC.HeadManager.CreateHeadIcon({parent = headNode, clickFunc = "unClick", showFrameEffect = true});

	--local diamondNode = self:FindChild("TopPanel/NodeMgr/DiamondNode");
	--self.diamondCounter = CC.HeadManager.CreateDiamondCounter({parent = diamondNode, hideBtnAdd = false});

	local chipNode = self:FindChild("TopPanel/NodeMgr/ChipNode");
	self.chipCounter = CC.HeadManager.CreateChipCounter({parent = chipNode, hideBtnAdd = false});

	--local VipNode = self:FindChild("TopPanel/NodeMgr/VipNode");
	--self.VIPCounter = CC.HeadManager.CreateVIPCounter({parent = VipNode, tipsParent = self:FindChild("TopPanel/VIPTipsNode")});

	local integralNode = self:FindChild("TopPanel/NodeMgr/IntegralBG")
	self.integralCounter = CC.HeadManager.CreateIntegralCounter({parent = integralNode,hideBtnAdd = true})

	--local roomcardNode = self:FindChild("TopPanel/NodeMgr/RoomcardNode");
	--self.roomcardCounter = CC.HeadManager.CreateRoomcardCounter({parent = roomcardNode, hideBtnAdd = false});
	--roomcardNode:SetActive(CC.Player.Inst():IsShowRoomCard())
end

function TreasureView:RefreshSwitchState()
	--夺宝页签
	self:FindChild("ToggleGroup/Treasure"):SetActive(self.switchDataMgr.GetSwitchStateByKey("TreasureEffect"))
	--礼票页签
	self:FindChild("ToggleGroup/Integral"):SetActive(self.switchDataMgr.GetSwitchStateByKey("IntegralExchange"))
	--筹码兑换屏蔽
	-- self:FindChild("ToggleGroup/Chip"):SetActive(self.switchDataMgr.GetSwitchStateByKey("ChipExchange"))
	self:FindChild("ToggleGroup/Chip"):SetActive(false)
	--红包商城页签
	local isShowRedEnvelope = self:IsShowRedEnvelope()
	self:FindChild("ToggleGroup/RedEnvelope"):SetActive(isShowRedEnvelope)
	self:FindChild("TopPanel/NodeMgr/Prop82"):SetActive(isShowRedEnvelope)
	--self:FindChild("TopPanel/NodeMgr/Prop83"):SetActive(isShowRedEnvelope)
end

function TreasureView:IsShowRedEnvelope()
	return self.switchDataMgr.GetSwitchStateByKey("RedEnvelopeStore") and self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel")
end

function TreasureView:InitRoolEvent()
	--滚动消息相关数据
	self.startPos = nil
	self.moveTime = 0
	self.moveDistance = self:FindChild("BottomPanel/infoItem"):GetComponent('RectTransform').sizeDelta.y
	self.moveObj = self:FindChild("BottomPanel/InfoPanel/Scroller/Container")

	self:StartUpdate()

	self:BeginRoll()
end

function TreasureView:StartUpdate()
	UpdateBeat:Add(self.Update,self);
end

function TreasureView:StopUpdate()
	UpdateBeat:Remove(self.Update,self);
end

function TreasureView:Update()
	if self.isMove then
		self.moveTime = self.moveTime + Time.deltaTime
		if self.moveTime >= 1 then
			self.moveTime = 1
			self.isMove = false
		end
		local curPos = Mathf.Lerp(self.startPos.y,self.startPos.y+self.moveDistance,self.moveTime)
		self.moveObj.localPosition = Vector3(self.moveObj.localPosition.x,curPos,self.moveObj.localPosition.z)
	end
end

function TreasureView:BeginRoll()
	self:StartTimer("Roll", 3, function()
		self.isMove = true
		self.startPos = self.moveObj.transform.localPosition
		self.moveTime = 0
	end,-1)
end

function TreasureView:InitGoodsFail()
	self:FindChild("IntegralPanel/Tips"):SetActive(true)
	self:FindChild("ChipPanel/Tips"):SetActive(true)
	self:FindChild("RedEnvelopePanel/Tips"):SetActive(true)
end

function TreasureView:InitTreasureFail()
	if not self.bInitTreasure then
		self:FindChild("TreasurePanel/Tips"):SetActive(true)
	end
end

function TreasureView:InitIntegralGoods(param, forceInit)
	if table.isEmpty(param) then return end
	if forceInit then self.bInitIntegralGoods = false end
	if self.bInitIntegralGoods then return end
	self.bInitIntegralGoods = true
	--货架数
	local shelfNum = math.ceil(#param/3)
	local goodsNum = #param + 1
	local curNum = 0
	local parent = self:FindChild("IntegralPanel/Viewport/Content")
	local guideItem = nil
	Util.ClearChild(parent)
	if self.co_InitUI[1] then
		coroutine.stop(self.co_InitUI[1])
		self.co_InitUI[1] = nil
	end
	self.co_InitUI[1] = coroutine.start(function()
		for j=1,shelfNum do
			local Shelf = {}
			Shelf.transform = CC.uu.newObject(self:FindChild("ShelfItem"), parent)
			for i=1,3 do
				curNum = curNum + 1
				if curNum < goodsNum then
					local index = curNum
					local goodsInfo = param[index].info
					local goodsID = goodsInfo.Id
					local productId = goodsInfo.ProductId
					self.goodsItem[goodsID] = param[index]
					self.goodsItem[goodsID].obj = Shelf.transform:FindChild("Board/"..i.."/Base")
					if goodsID == tostring(120029) or goodsID == tostring(100059) then
						local goodItem = Shelf.transform:FindChild("Board/"..i)
						if not guideItem and (goodsID ~= tostring(100059) or param[index].num > 0) then
							guideItem = goodItem
							self.guideGoodId = goodsID
						end
						self:SpecialGoods(goodsID, param[index], goodItem)
					elseif goodsID == tostring(100064) or goodsID == tostring(100065) or goodsID == tostring(100066) then
						local goodItem = Shelf.transform:FindChild("Board/"..i)
						self:SpecialGoods(goodsID, param[index], goodItem)
					else
						Shelf.transform:FindChild("Board/"..i.."/Base"):SetActive(true)
						Shelf.transform:FindChild("Board/"..i.."/Null"):SetActive(false)
						local node = Shelf.transform:FindChild("Board/"..i.."/Base/icon")
						self:SetImage(node, param[index].path)
						node:GetComponent("Image"):SetNativeSize()
						Shelf.transform:FindChild("Board/"..i.."/Base/tips/label").text = self.language.reserve
						Shelf.transform:FindChild("Board/"..i.."/Base/tips/num").text = param[index].num
						Shelf.transform:FindChild("Board/"..i.."/Base/des").text = CC.ConfigCenter.Inst():getDescByKey("ware_"..productId)

						if goodsInfo.Currency == CC.shared_enums_pb.PCT_Card_Pieces then
							local pcfNum = CC.Player.Inst():GetSelfInfoByKey("EPC_PointCard_Fragment")
							Shelf.transform:FindChild("Board/"..i.."/Base/price").text = pcfNum..'/'..goodsInfo.Price
							self.PointCardInfo = {tran=Shelf.transform:FindChild("Board/"..i.."/Base/price"),price=goodsInfo.Price}
							local cfgIcon = Shelf.transform:FindChild("Board/"..i.."/Base/price/Image")
							self:SetImage(cfgIcon, self.viewCtr.realDataMgr.GetPriceIcon(goodsInfo.Currency))
						else
							Shelf.transform:FindChild("Board/"..i.."/Base/price").text = goodsInfo.Price
						end
					end
						local exchangeFunc = function()
							self.viewCtr:ExchangeGoods(self.goodsItem[goodsID])
						end
						self.goodsList[goodsID] = {}
						self.goodsList[goodsID].exchangeFunc = exchangeFunc
						self:AddClick(Shelf.transform:FindChild("Board/"..i), exchangeFunc)
				elseif curNum == goodsNum then
					Shelf.transform:FindChild("Board/"..i.."/Base"):SetActive(false)
					Shelf.transform:FindChild("Board/"..i.."/Null"):SetActive(true)
				else
					Shelf.transform:FindChild("Board/"..i.."/Base"):SetActive(false)
					Shelf.transform:FindChild("Board/"..i.."/Null"):SetActive(false)
				end
			end
			Shelf.transform:SetActive(true)
			coroutine.step(1)
		end
		if guideItem then
			if self.guideState and self.guideGoodId == tostring(120029) and not self.viewCtr.gameDataMgr.GetSingleFlag(21) then
				self.guideState = false
				CC.ViewManager.Open("GuideView", {singleFlag = 21, btn = guideItem})
			elseif self.guideState and self.guideGoodId == tostring(100059) and not self.viewCtr.gameDataMgr.GetSingleFlag(20) then
				self.guideState = false
				CC.ViewManager.Open("GuideView", {singleFlag = 20, btn = guideItem})
			else
				self:CheckCallExchange()
			end
		else
			self:CheckCallExchange()
		end
	end)
end

function TreasureView:InitChipGoods(param, forceInit)
	if table.isEmpty(param) then return end
	if forceInit then self.bInitChipGoods = false end
	if self.bInitChipGoods then return end
	self.bInitChipGoods = true
	--货架数
	local shelfNum = math.ceil(#param/3)
	local goodsNum = #param + 1
	local curNum = 0
	local parent = self:FindChild("ChipPanel/Viewport/Content")
	Util.ClearChild(parent)
	if self.co_InitUI[2] then
		coroutine.stop(self.co_InitUI[2])
		self.co_InitUI[2] = nil
	end
	self.co_InitUI[2] = coroutine.start(function()
		for j=1,shelfNum do
				local Shelf = {}
				Shelf.transform = CC.uu.newObject(self:FindChild("ChipShelfItem"), parent)
			for i=1,3 do
				curNum = curNum + 1
				if curNum < goodsNum then
					local index = curNum
					local goodsInfo = param[index].info
					local goodsID = goodsInfo.Id
					local productId = goodsInfo.ProductId
					self.goodsItem[goodsID] = param[index]
					self.goodsItem[goodsID].obj = Shelf.transform:FindChild("Board/"..i.."/Base")
					Shelf.transform:FindChild("Board/"..i.."/Base"):SetActive(true)
					Shelf.transform:FindChild("Board/"..i.."/Null"):SetActive(false)
					local node = Shelf.transform:FindChild("Board/"..i.."/Base/icon")
					self:SetImage(node, param[index].path)
					node:GetComponent("Image"):SetNativeSize()
					Shelf.transform:FindChild("Board/"..i.."/Base/tips/label").text = self.language.reserve
					Shelf.transform:FindChild("Board/"..i.."/Base/tips/num").text = param[index].num
					Shelf.transform:FindChild("Board/"..i.."/Base/des").text = CC.ConfigCenter.Inst():getDescByKey("ware_"..productId)
					Shelf.transform:FindChild("Board/"..i.."/Base/price").text = goodsInfo.Price
					self:AddClick(Shelf.transform:FindChild("Board/"..i), function()
						self.viewCtr:ExchangeGoods(self.goodsItem[goodsID])
					end)
				elseif curNum == goodsNum then
					Shelf.transform:FindChild("Board/"..i.."/Base"):SetActive(false)
					Shelf.transform:FindChild("Board/"..i.."/Null"):SetActive(true)
				else
					Shelf.transform:FindChild("Board/"..i.."/Base"):SetActive(false)
					Shelf.transform:FindChild("Board/"..i.."/Null"):SetActive(false)
				end
			end
			Shelf.transform:SetActive(true)
			coroutine.step(1)
		end
	end)
end

function TreasureView:InitRedEnvelopeGoods(param, forceInit)
	-- 刷新红包商城货架
	if table.isEmpty(param) then return end
	if forceInit then self.bInitRedEnvelopeGoods = false end
	if self.bInitRedEnvelopeGoods then return end
	self.bInitRedEnvelopeGoods = true
	--货架数
	local shelfNum = math.ceil(#param/3)
	local goodsNum = #param + 1
	local curNum = 0
	local parent = self:FindChild("RedEnvelopePanel/Viewport/Content")
	Util.ClearChild(parent)
	if self.co_InitUI[4] then
		coroutine.stop(self.co_InitUI[4])
		self.co_InitUI[4] = nil
	end
	self.co_InitUI[4] = coroutine.start(function()
			for j=1,shelfNum do
				local Shelf = {}
				Shelf.transform = CC.uu.newObject(self:FindChild("RedEnvelopeShelfItem"), parent)
				for i=1,3 do
					curNum = curNum + 1
					if curNum < goodsNum then
						local index = curNum
						local goodsInfo = param[index].info
						local goodsID = goodsInfo.Id
						local productId = goodsInfo.ProductId
						local consume = param[index].consume
						self.goodsItem[goodsID] = param[index]
						self.goodsItem[goodsID].obj = Shelf.transform:FindChild("Board/"..i.."/Base")
						Shelf.transform:FindChild("Board/"..i.."/Base"):SetActive(true)
						Shelf.transform:FindChild("Board/"..i.."/Null"):SetActive(false)
						local node = Shelf.transform:FindChild("Board/"..i.."/Base/icon")
						self:SetImage(node, param[index].path)
						node:GetComponent("Image"):SetNativeSize()
						Shelf.transform:FindChild("Board/"..i.."/Base/tips/label").text = self.language.reserve
						Shelf.transform:FindChild("Board/"..i.."/Base/tips/num").text = param[index].num
						Shelf.transform:FindChild("Board/"..i.."/Base/des").text = CC.ConfigCenter.Inst():getDescByKey("ware_"..productId)
						local showPrice = self.viewCtr.realDataMgr.GetShowNumById(consume,goodsInfo.Price)
						Shelf.transform:FindChild("Board/"..i.."/Base/price").text = CC.uu.ChipFormat(showPrice,true)
						local priceIcon = self.viewCtr.realDataMgr.GetPriceIcon(consume)
						self:SetImage(Shelf.transform:FindChild("Board/"..i.."/Base/price/Image"),priceIcon)
						if goodsInfo.IconCorner ~= '' then
							Shelf.transform:FindChild("Board/"..i.."/Base/Vip/Discount").text = goodsInfo.IconCorner.."%"
							Shelf.transform:FindChild("Board/"..i.."/Base/Vip"):SetActive(true)
						end
						self:AddClick(Shelf.transform:FindChild("Board/"..i), function()
								self.viewCtr:ExchangeGoods(self.goodsItem[goodsID])
							end)
					elseif curNum == goodsNum then
						Shelf.transform:FindChild("Board/"..i.."/Base"):SetActive(false)
						Shelf.transform:FindChild("Board/"..i.."/Null"):SetActive(true)
					else
						Shelf.transform:FindChild("Board/"..i.."/Base"):SetActive(false)
						Shelf.transform:FindChild("Board/"..i.."/Null"):SetActive(false)
					end
				end
				Shelf.transform:SetActive(true)
				coroutine.step(1)
			end
		end)
end

function TreasureView:SpecialGoods(id,param, goodItem)
	--新手兑换一次商品
	local shelf = goodItem
	shelf:FindChild("Base"):SetActive(true)
	shelf:FindChild("Null"):SetActive(false)
	local node = shelf:FindChild("Base/icon")
	self:SetImage(node, param.path)
	node:GetComponent("Image"):SetNativeSize()
	shelf:FindChild("Base/tips/label").text = self.language.reserve
	shelf:FindChild("Base/des").text = CC.ConfigCenter.Inst():getDescByKey("ware_"..param.info.ProductId)
	shelf:FindChild("Base/price").text = param.info.Price
	if id == "120029" then
		shelf:FindChild("Base/tips/num").text = 1
	elseif id == "100059" then
		local priceIcon = shelf:FindChild("Base/price/Image")
		self:SetImage(priceIcon,"icon_dhk.png")
		shelf:FindChild("Base/tips/num").text = param.num
	elseif id == "100064" or id == "100065" or id == "100066" then
		local priceIcon = shelf:FindChild("Base/price/Image")
		self:SetImage(priceIcon,self.viewCtr.realDataMgr.GetPriceIcon(param.info.Currency))
		shelf:FindChild("Base/tips/num").text = param.num
	end
end

--刷新点卡碎片数量显示
function TreasureView:RefreshPCFNum()
	if self.PointCardInfo then
        local pcfNum = CC.Player.Inst():GetSelfInfoByKey("EPC_PointCard_Fragment")
		self.PointCardInfo.tran.text = pcfNum..'/'..self.PointCardInfo.price
    end
end

function TreasureView:OnSwitchTableGroup(OpenViewId)
	if self.TableGroup[OpenViewId] then
		self:ClickTabBtn(self.TableGroup[OpenViewId])
	end
end

function TreasureView:RefreshCount(param)
	self:FindChild("IntegralPanel/Tips"):SetActive(false)
	self:FindChild("ChipPanel/Tips"):SetActive(false)
	self:FindChild("RedEnvelopePanel/Tips"):SetActive(false)
	for k,v in pairs(param) do
		if self.goodsItem[v.Id] then
			if v.Id == "120029"then
				if not CC.uu.IsNil(self.goodsItem[v.Id].obj) then
					self.goodsItem[v.Id].obj:FindChild("tips/num").text = 1
				end
				self.goodsItem[v.Id].num = 1
			else
				if not CC.uu.IsNil(self.goodsItem[v.Id].obj) then
				self.goodsItem[v.Id].obj:FindChild("tips/num").text = v.Count > 0 and v.Count or 0
				end
				self.goodsItem[v.Id].num = v.Count > 0 and v.Count or 0
			end
		else
			-- logError("商品不存在,ID:"..v.Id)
		end
	end
end

function TreasureView:RefreshTreasureList(param)
	self:FindChild("TreasurePanel/Tips"):SetActive(false)
	if self.treasureCount ~= #param then
		self:ClearShelf()
		self.treasureCount = #param
		self.bInitTreasure = false
		self.treasureShelf = {}
		self.treasureItem = {}
	end

	--货架数
	local shelfNum = math.ceil(#param/3)
	local goodsNum = #param + 1
	local curNum = 0
	local parent = self:FindChild("TreasurePanel/Viewport/Content")

	if self.co_InitUI[3] then
		coroutine.stop(self.co_InitUI[3])
		self.co_InitUI[3] = nil
	end
	self.co_InitUI[3] = coroutine.start(function()
		for s=1,shelfNum do
			local Shelf = nil
			if not self.bInitTreasure then
				self.treasureShelf[s] = {}
				Shelf = CC.uu.newObject(self:FindChild("TreasureShelfItem"), parent)
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

function TreasureView:RefreshTreasureGoods(param,data)
	local tran = param.transform
	if param.Issue ~= data.Issue then
		param.Issue = data.IssuePurchase
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
		--游戏里不允许夺宝
		if not CC.ViewManager.IsHallScene() then
			CC.ViewManager.ShowTip(self.language.gobackToHall)
			return
		end

		CC.ViewManager.Open("TreasureInformation",data)
	end)
end

function TreasureView:RefreshTreasureGoodsState(param,data)
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
	-- elseif data.Status == CC.proto.client_treasure_pb.IssueWaitOpen then
		-- --等待开奖
		-- self:IssuePurchaseState(tran,data,true)
		-- self:IssueEndState(tran,data,false)
		-- self:IssueRemainState(tran,data,false)
		-- self:IssuePrepareState(tran,data,false)
	end
end

function TreasureView:IssuePurchaseState(tran,data,bState)
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

function TreasureView:StartCountdown(tran,data)
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

function TreasureView:IssueOpenState(tran,bState)
end

function TreasureView:IssueEndState(tran,data,bState)
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

function TreasureView:IssueRemainState(tran,data,bState)
	if bState then
		tran:FindChild("Down/Icon").material = ResMgr.LoadAsset("material", "Gray");
		tran:FindChild("Down/AuctionFail"):SetActive(true)
	else
		tran:FindChild("Down/Icon").material = nil
		tran:FindChild("Down/AuctionFail"):SetActive(false)
	end
end

function TreasureView:IssuePrepareState(tran,data,bState)
	if bState then
		tran:FindChild("Down/Presale"):SetActive(true)
		tran:FindChild("Down/Presale/Time").text = os.date("%d-%m-%Y %H:%M:%S",data.SellStartTime)
	else
		tran:FindChild("Down/Presale"):SetActive(false)
	end
end

function TreasureView:HideVIPBtn()
	self:FindChild("BtnGroup/VipBtn"):SetActive(false)
	--if CC.ChannelMgr.GetSwitchByKey("bHasGift") and not self.GiftBtn then
		--local GiftNode = self:FindChild("BtnGroup/Node");
		--GiftNode:SetActive(true);
		--self.GiftBtn = CC.SelectGiftManager.CreateIcon({parent = GiftNode});
	--end
end

--设置头像
function TreasureView:SetHeadIcon(node,id,portrait,level,fun)
	local param = {}
	param.parent = node
	param.playerId = id
	param.portrait = portrait
	param.vipLevel = level
	param.clickFunc = fun
	return CC.HeadManager.CreateHeadIcon(param)
end

function TreasureView:InitRollPanel(count)
	if not self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") then
		self:FindChild("BottomPanel/InfoPanel/Text"):SetActive(false)
		return
	end
	if count > 0 then
		self:FindChild("BottomPanel/InfoPanel/Scroller"):SetActive(true)
		self:FindChild("BottomPanel/InfoPanel/Text"):SetActive(false)
		self.ScrollerController:InitScroller(count)
		--延迟显示记录板
		CC.uu.DelayRun(1.5,function()
            if self.BottomContainer ~= nil then
			    self.BottomContainer:SetActive(true)
            end
		end)
	else
		if self.curShopType == 0 then
			self:FindChild("BottomPanel/InfoPanel/Text").text = self.language.noTreasureRollInfo
		else
			self:FindChild("BottomPanel/InfoPanel/Text").text = self.language.noAllBuyInfo
		end
		self:FindChild("BottomPanel/InfoPanel/Scroller"):SetActive(false)
		self:FindChild("BottomPanel/InfoPanel/Text"):SetActive(true)
	end
end

function TreasureView:CreateInfoItem(tran,param)
	local text = nil
	if self.curShopType == 0 then
		text = string.format(self.language.treasureText,param.Name,param.Time,param.Goods)
	else
		text = string.format(self.language.exchangeText,param.Time,param.Name,param.Goods)
	end
	tran:FindChild("Text").text = text
end

function TreasureView:CreateSelfInfoItem(tran,param)
	self:SetImage(tran:FindChild("Icon"),param.Icon)
	tran:FindChild("Name").text = param.Name
	tran:FindChild("Time").text = param.Time
end

function TreasureView:OpenRecordPanel()
	local count = self.viewCtr.realDataMgr.GetSelfBuyInfoCount()
	if count == -1 then
		self:FindChild("RecordPanel/BG/Tips").text = self.language.reqSelfBuyInfoFails
		self:FindChild("RecordPanel/BG/Tips"):SetActive(true)
	elseif count == 0 then
		self:FindChild("RecordPanel/BG/Tips").text = self.language.noSelfBuyInfo
		self:FindChild("RecordPanel/BG/Tips"):SetActive(true)
	else
		self:FindChild("RecordPanel/BG/Tips"):SetActive(false)
		self:FindChild("RecordPanel/BG/Label"):SetActive(true)
	end
	self:FindChild("RecordPanel"):SetActive(true)
	if count >= 0 then
		self.SelfScrollerController:InitScroller(count)
	end
	self:SetCanClick(false)
    self:FindChild("RecordPanel").transform.size = Vector2(3000, 3000)
    self:FindChild("RecordPanel").transform.localScale = Vector3(0.5,0.5,1)
    self:RunAction(self:FindChild("RecordPanel"), {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    	self:SetCanClick(true)
    end})
end

function TreasureView:CloseRecordPanel()
	self:SetCanClick(false);
    self:RunAction(self:FindChild("RecordPanel"), {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
		self:FindChild("RecordPanel"):SetActive(false)
		self:SetCanClick(true);
    end})
end

function TreasureView:OpenPrize(data)
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

function TreasureView:SetWinNum(tran,num)
	local sWin = tostring(string.format("1%07d",num))
	local sLen = #sWin - 1
	local index = 1
	for i = 8-sLen, 8 do
		tran:FindChild(i.."/Text1").text = string.sub(sWin,index,index)
		index = index + 1
	end
end

function TreasureView:SetNum(tran,num)
	local sWin = tostring(num)
	local sLen = #sWin - 1
	local index = 1
	for i = 8-sLen, 8 do
		tran:FindChild(i.."/Text").text = string.sub(sWin,index,index)
		tran:FindChild(i.."/Text1").text = math.floor((tonumber(string.sub(sWin,index,index))+1)/2)
		index = index + 1
	end
end

function TreasureView:ClearShelf()
	for k, v in pairs(self.treasureItem) do
		if v.Portrait then
			v.Portrait:Destroy(true)
		end
		self:StopTimer(k)
	end
	Util.ClearChild(self:FindChild("TreasurePanel/Viewport/Content"))
end

function TreasureView:SetTreasureLocation(bState)
	if bState then
		self:FindChild("TreasurePanel").localPosition = Vector3(3.739,0,0)
	else
		self:FindChild("TreasurePanel").localPosition = Vector3(5000,5000,0)
	end
end

function TreasureView:RefreshMailRedPoint(bState)
	self:FindChild("BtnGroup/MailBtn/RedDot"):SetActive(bState)
end

function TreasureView:PlayMarquee(bState)
	self.marquee:SetActive(true)
	self.showMarquee = true
	self.marqueeText.localPosition = Vector3(10000,10000,10000)
	if bState then
		self.marqueeText:GetComponent('Text').text = self.language.treasure_marquee_1
	else
		self.marqueeText:GetComponent('Text').text = self.language.treasure_marquee_2
	end
	self:DelayRun(0.1,function()
		local textW = self.marqueeText:GetComponent('RectTransform').rect.width
		local half = textW/2
		self.marqueeText.localPosition = Vector3(half + self.marqueeWidth, 0, 0)
		self.action = self:RunAction(self.marqueeText, {"localMoveTo", -half - self.marqueeWidth, 0, 0.65 * math.max(16,textW/40), function()
			if bState then
				self:PlayMarquee(false)
			else
				self:ExMarquee()
			end
		end})
	end)
end

--每天第一次登录的跑马灯展示完后再展示新跑马灯
--bState控制展示内容
function TreasureView:ExMarquee(bState)
	self.marquee:SetActive(true)
	self.showMarquee = false
	self.marqueeText.localPosition = Vector3(10000,10000,10000)
	self.marqueeText:GetComponent('Text').text = self:GetMarqueeText(bState)

	self:DelayRun(0.1,function()
		local textW = self.marqueeText:GetComponent('RectTransform').rect.width
		local half = textW/2
		self.marqueeText.localPosition = Vector3(half + self.marqueeWidth, 0, 0)
		self.action = self:RunAction(self.marqueeText, {"localMoveTo", -half - self.marqueeWidth, 0, 0.65 * math.max(16,textW/40), function()
			self:ExMarquee(not bState)
		end})
	end)
end

function TreasureView:GetMarqueeText(bState)
	local showText = ""
	self.marquee:SetActive(true)
	if self.curShopType == 0 then
		-- showText = self.language.treasureLackTips
		self.marquee:SetActive(false)
	elseif self.curShopType ==  CC.proto.client_shop_pb.RedEnvelopeShop then
		showText = self.language.redEnvelope_marquee
	else
		--if bState then
			--showText = self.language.exchangeLackTips
		--else
			showText = self.language.newMarquee
		--end
	end
	return showText
end

function TreasureView:ShowExchangeLimitBox(data,callback)
	local nowTimes = data.DayTimes
	local dailyLimit = data.DayLimitTimes
	if nowTimes == -1 or dailyLimit == -1 then
		CC.ViewManager.ShowMessageBox(self.language.makeSure,callback,nil)
		return
	end
	self.exchangeLimitBox:SetActive(true)
	if nowTimes > 0 then
		self.exchangeLimitBox:FindChild("Frame/Title").text = string.format(self.language.todayTimes,nowTimes)
		self.exchangeLimitBox:FindChild("Frame/Message").text = self.language.exchangeSure
		self.exchangeLimitBox:FindChild("Frame/BtnTips"):SetActive(false)
		self.exchangeLimitBox:FindChild("Frame/BtnFitter/BtnNo"):SetActive(true)
		self.exchangeLimitBox:FindChild("Frame/BtnFitter/BtnOk/Text").text = self.language.btnOk
		self:AddClick("ExchangeLimitBox/Frame/BtnFitter/BtnOk",function ()
			self.exchangeLimitBox:SetActive(false)
			callback()
		end)
	else
		self.exchangeLimitBox:FindChild("Frame/Title").text = self.language.reachedLimit
		self.exchangeLimitBox:FindChild("Frame/Message").text = self.language.plsLevelUp
		self.exchangeLimitBox:FindChild("Frame/BtnTips"):SetActive(true)
		self.exchangeLimitBox:FindChild("Frame/BtnFitter/BtnNo"):SetActive(false)
		self.exchangeLimitBox:FindChild("Frame/BtnFitter/BtnOk/Text").text = self.language.btnLevelUp
		self:AddClick("ExchangeLimitBox/Frame/BtnFitter/BtnOk",function ()
			self.exchangeLimitBox:SetActive(false)
			--跳转至VIP权益界面
			CC.ViewManager.OpenAndReplace("PersonalInfoView",{Upgrade = 1})
		end)
	end
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") <= 0 and data.GoodsID == 100003 then
		--vip0兑换50点卡终生限制
		self.exchangeLimitBox:FindChild("Frame/DailyLimit/Text").text = self.language.lifeLimit
	else
		self.exchangeLimitBox:FindChild("Frame/DailyLimit/Text").text = self.language.dailyLimit
	end
	self.exchangeLimitBox:FindChild("Frame/DailyLimit/Num").text = dailyLimit
end

function TreasureView:CheckCallExchange()
	if self.param and self.param.exchangeId then
		if self.goodsList[self.param.exchangeId] then
			self.goodsList[self.param.exchangeId].exchangeFunc()
		end
	end
end

function TreasureView:RefreshShowPanel(type)
	self:FindChild("TreasurePanel"):SetActive(type == 0)
	self:FindChild("ChipPanel"):SetActive(type == CC.proto.client_shop_pb.ChouMaShop)
	self:FindChild("IntegralPanel"):SetActive(type == CC.proto.client_shop_pb.LiQuanShop)
	self:FindChild("RedEnvelopePanel"):SetActive(type == CC.proto.client_shop_pb.RedEnvelopeShop)
end

function TreasureView:RefreshRedEnvelope()
	--捕获类
	local num82 = self.viewCtr.realDataMgr.GetShowNumById(CC.shared_enums_pb.EPC_Props_82)
	--棋牌类
	local num83 = self.viewCtr.realDataMgr.GetShowNumById(CC.shared_enums_pb.EPC_Props_83)
	self:FindChild("TopPanel/NodeMgr/Prop82/Text").text = CC.uu.ChipFormat(num82,true)
	self:FindChild("TopPanel/NodeMgr/Prop83/Text").text = CC.uu.ChipFormat(num83,true)
end

function TreasureView:ShowExchangeTipBtn(isShow)
	local show = isShow and self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel")
	self:FindChild("BottomPanel/ExchangeTipBtn"):SetActive(show)
end

function TreasureView:OnDestroy()
	for k, v in pairs(self.treasureItem) do
		if v.Portrait then
			v.Portrait:Destroy(true)
		end
	end
	for	_, v in pairs(self.co_InitUI) do
		coroutine.stop(v)
		v = nil
	end
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end

	if self.HeadIcon then
		self.HeadIcon:Destroy();
		self.HeadIcon = nil;
	end

	if self.chipCounter then
		self.chipCounter:Destroy();
		self.chipCounter = nil;
	end

	if self.diamondCounter then
		self.diamondCounter:Destroy();
		self.diamondCounter = nil;
	end

	if self.VIPCounter then
		self.VIPCounter:Destroy();
		self.VIPCounter = nil;
	end

	if self.integralCounter then
		self.integralCounter:Destroy()
		self.integralCounter = nil
	end

	if self.roomcardCounter then
		self.roomcardCounter:Destroy()
		self.roomcardCounter = nil
	end
	if self.GiftBtn then
		self.GiftBtn:Destroy()
		self.GiftBtn = nil
	end
	self:StopAllTimer()
	self:StopUpdate()
	if self.param and self.param.callback then
		self.param.callback()
	end
	if self.param and self.param.closeFunc then
		self.param.closeFunc()
	end

	self.ScrollerController = nil
	self.SelfScrollerController = nil
	self.BottomContainer = nil
end

function TreasureView:ActionIn()

end

return TreasureView