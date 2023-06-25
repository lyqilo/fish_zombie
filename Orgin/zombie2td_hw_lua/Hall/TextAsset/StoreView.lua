local CC = require("CC")

local StoreView = CC.uu.ClassView("StoreView")

function StoreView:ctor(param)

	self:InitVar(param);
end

function StoreView:OnCreate()

	self:FindChild("PropBtn/Icon"):GetComponent("Text").fontSize = 26

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitUI()
end

function StoreView:InitVar(param)

	self.param = param;
	--筹码对象列表
	self.chipItems = {};
	--道具对象列表
	self.propItems = {};
	--银行渠道筹码对象列表
	self.bankItems = {};
	--筹码渠道按钮列表
	self.chipChannelBtns = {};
	--道具按钮列表
	self.propChannelBtns = {};
	--银行渠道按钮列表
	self.bankChannelBtns = {};

	self.storeDefine = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine");

	self.callback = self.param and self.param.callback;
	--是否充值标记
	self.buyInStore = false
	--是否异常玩家
	self.playerStatus = {}

	self.exceptionChannel = {24,26,31,41,51,53,54,55}

	self.hideAutoExchange = self.param and self.param.hideAutoExchange or false
end

function  StoreView:InitUI()
	self:AddClick("TopPanel/BtnBG/BtnBack", function()
		self:Destroy();
	end);
end

function StoreView:InitContent(param)

	self.BtnFloat = self:FindChild("RightPanel/BtnTab/BtnFloat")
	self:AddClick(self.BtnFloat,function()
		CC.ViewManager.Open("SelectGiftCollectionView",{currentView = "NewPayGiftView"})
		self:Destroy()
	 end)

	local headNode = self:FindChild("TopPanel/HeadNode");
	self.HeadIcon = CC.HeadManager.CreateHeadIcon({parent = headNode, clickFunc = "unClick", showFrameEffect = true});

	local diamondNode = self:FindChild("TopPanel/NodeMgr/DiamondNode");
	self.diamondCounter = CC.HeadManager.CreateDiamondCounter({parent = diamondNode, hideBtnAdd = true});

	local chipNode = self:FindChild("TopPanel/NodeMgr/ChipNode");
	self.chipCounter = CC.HeadManager.CreateChipCounter({parent = chipNode, hideBtnAdd = true});

	local VipNode = self:FindChild("TopPanel/NodeMgr/VipNode");
	self.VIPCounter = CC.HeadManager.CreateVIPCounter({parent = VipNode, tipsParent = self:FindChild("TopPanel/VIPTipsNode")});

	local integralNode = self:FindChild("TopPanel/NodeMgr/IntegralBG")
	self.integralCounter = CC.HeadManager.CreateIntegralCounter({parent = integralNode,hideBtnAdd = true})

	local roomcardNode = self:FindChild("TopPanel/NodeMgr/RoomcardNode");
	self.roomcardCounter = CC.HeadManager.CreateRoomcardCounter({parent = roomcardNode, hideBtnAdd = true});
	roomcardNode:SetActive(CC.Player.Inst():IsShowRoomCard())

	if not CC.ChannelMgr.GetSwitchByKey("bHasRealStore") then
		integralNode:SetActive(false);
		VipNode:SetActive(false);
	end

	if param.setOrgTab then
		self:SetTabShow(param.setOrgTab);
	end

	--切换返回按钮上的图标
	if param.showBackIcon then
		local hallIcon = self:FindChild("TopPanel/BtnBG/BtnBack/HallIcon");
		hallIcon:SetActive(false);
		local backIcon = self:FindChild("TopPanel/BtnBG/BtnBack/GameIcon");
		backIcon:SetActive(true);
	end

	self:AddClick("RightPanel/BtnTab/BtnGroup/BtnProp", "OnClickChangeToProp","");

	self:AddClick("RightPanel/BtnTab/BtnGroup/BtnChip", "OnClickChangeToDiamond","");

	self:AddClick("RightPanel/BtnTab/BtnGroup/BtnBank", "OnClickChangeToBank","");

	if CC.LocalGameData.GetLocalDataToKey("AutoExchangeTip",CC.Player.Inst():GetSelfInfoByKey("Id")) and not CC.ChannelMgr.GetTrailStatus() then
		--如果隐藏自动兑换面板，提示也不要出来了
		if not self.hideAutoExchange then
			self:FindChild("BottomPanel/AutoExchangePanel/Tip"):SetActive(true)
			CC.LocalGameData.SetLocalDataToKey("AutoExchangeTip", CC.Player.Inst():GetSelfInfoByKey("Id"))
			self:DelayRun(5, function ()
				self:FindChild("BottomPanel/AutoExchangePanel/Tip"):SetActive(false)
			end)
		end
	end

	self.AutoExchangeBtn = self:FindChild("BottomPanel/AutoExchangePanel/Node/Toggle")
	self:AddClick(self.AutoExchangeBtn,"SetAutoExchange")
	self.AutoExchangeBtn:FindChild("Close"):SetActive(not param.autoExchange)
	self.AutoExchangeBtn:FindChild("Open"):SetActive(param.autoExchange)

	UIEvent.AddSliderOnValueChange(self:FindChild("BottomPanel/ManualExchangePanel/ExchangeNode/Slider"), function(selected)
			self:SetExchangeSlider(selected);
		end)

	self:FindChild("BottomPanel/AutoExchangePanel/Node"):SetActive(not self.hideAutoExchange)

	self:AddClick("BottomPanel/ManualExchangePanel/ExchangeNode/BtnAdd", "OnClickBtnAdd");

	self:AddClick("BottomPanel/ManualExchangePanel/ExchangeNode/BtnMinus", "OnClickBtnMinus");

	self:AddClick("BottomPanel/ManualExchangePanel/BtnExchange", "OnClickBtnExchange");

	self:InitTextByLanguage();

	--获取裁剪区域左下角和右上角的世界坐标
	local viewport = self:FindChild("RightPanel/ScrollPanel/Viewport");
	local wordPos = viewport:GetComponent("RectTransform"):GetWorldCorners()
	local minX = wordPos[0].x;
	local minY = wordPos[0].y;
	local maxX = wordPos[2].x;
	local maxY = wordPos[2].y;

	--把坐标传入shader(maskParticle.shader，maskShine.shader)
	local nodePath = {"ChipItem/Board/BtnPay/Corner/SaveEffect", "Effects","BankItem/Board/BtnPay/Corner/SaveEffect"}
	for _,path in ipairs(nodePath) do
		local particleParent = self:FindChild(path);
		local particleComps = particleParent:GetComponentsInChildren(typeof(UnityEngine.Renderer));
		if particleComps then
			for i,v in ipairs(particleComps:ToTable()) do
				v.material:SetFloat("_MinX",minX);
				v.material:SetFloat("_MinY",minY);
				v.material:SetFloat("_MaxX",maxX);
				v.material:SetFloat("_MaxY",maxY);
			end
		end
	end

	self:ShowBankTab(param.isShowBankTb)
	self.RightScrollRect = self:FindChild("RightPanel/ScrollPanel"):GetComponent("ScrollRect")
	if param.scrollPosition then
		self:DelayRun(0,function()
			self.RightScrollRect.verticalNormalizedPosition = param.scrollPosition
		end)
	end

	--月末活动雷蛇渠道CDK
	self.cursertime = CC.HallUtil.GetCurServerTime(true)
	if self.viewCtr:CheckChannel(self.storeDefine.CommodityType.Molpoints) then
		self:FindChild("RightPanel/BtnTab/BtnGroup/BtnChip/CDK"):SetActive(self.storeDefine.DisplayCDK(param,self.cursertime))
	end

	--渠道临时关闭提示
	-- local time = CC.TimeMgr.GetTimeInfo()
	-- if not time then
	-- 	time = os.date("*t", os.time())
	-- end
	-- if 630045 ~= CC.Player.Inst():GetSelfInfoByKey("Id") and time.year == 2021 and time.month == 9 and time.day == 22 then
	-- 	if time.hour >= 4 and time.hour < 10 then
	-- 		self:FindChild("BottomPanel/AutoExchangePanel/Text"):SetActive(true)
	-- 	end
	-- end
end

function StoreView:ShowBankTab(flag)
	self.openbankTab = flag --and (not CC.ChannelMgr.CheckOppoChannel()) and (not CC.ChannelMgr.CheckVivoChannel())
	self:FindChild("RightPanel/BtnTab/BtnGroup/BtnBank"):SetActive(self.openbankTab)
	local HorizontalLayoutGroup = self:FindChild("RightPanel/BtnTab/BtnGroup"):GetComponent("HorizontalLayoutGroup")
	HorizontalLayoutGroup.spacing = self.openbankTab and 25 or 125
end

function StoreView:InitTextByLanguage()

	local language = self:GetLanguage();
	self.language = language

	local tips = self:FindChild("Tips/Title");
	tips.text = language.googleTips;

	local desTips = self:FindChild("DesTips/Text");
	desTips.text = language.roomcardTips;

	local autoExchange = self:FindChild("BottomPanel/AutoExchangePanel/Node/Text");
	autoExchange.text = language.autoExchange;
	self:FindChild("BottomPanel/AutoExchangePanel/Node"):GetComponent("HorizontalLayoutGroup").spacing = 9

	self:FindChild("BottomPanel/AutoExchangePanel/Tip/Text").text = language.autoExchangeTip

	local btnExchange = self:FindChild("BottomPanel/ManualExchangePanel/BtnExchange/Text");
	btnExchange.text = language.btnExchange;

	local diamondDes = self:FindChild("BottomPanel/ManualExchangePanel/Diamond/Des");
	diamondDes.text = language.diamondDes;

	local chipDes = self:FindChild("BottomPanel/ManualExchangePanel/Chip/Des");
	chipDes.text = language.chipDes;

	self:FindChild("ChipItem/Board/PriceFrame/Equal").text = "=";
	self:FindChild("BottomPanel/AutoExchangePanel/Node/Toggle/Close/Text").text = self.language.toggleOff
	self:FindChild("BottomPanel/AutoExchangePanel/Node/Toggle/Open/Text").text = self.language.toggleOn
	self:FindChild("BottomPanel/AutoExchangePanel/Text").text = self.language.timeTip
	self:FindChild("DiamondTips").text = self.language.diamondTips
end


--创建左边渠道和道具按钮对象
function StoreView:CreateChannelItem(param)
	local item = {};
	item.data = param;
	--根据按钮类型创建对应object
	local parent = self:FindChild("LeftPanel/Viewport/Content");
	local itemName = (param.btnType == self.storeDefine.StoreTab.Diamond or param.btnType == self.storeDefine.StoreTab.Bank) and "ChannelBtn" or "PropBtn";
	item.transform = CC.uu.newObject(self:FindChild(itemName),parent);
	item.transform:SetActive(true);
	--设置渠道按钮图标
	if param.icon then
		self:SetImage(item.transform:FindChild("Icon"), param.icon);
	end
	--设置渠道按钮折扣显示
	if param.chlDiscount then
		item.transform:FindChild("Corner"):SetActive(true);
		item.transform:FindChild("Corner/Text"):SetText(param.chlDiscount.."%");
	end
	--设置道具按钮文本
	if param.iconText then
		item.transform:FindChild("Icon"):SetText(param.iconText);
	end
	--google和ios渠道特殊处理
	if param.showExtraTips then
		item.tips = self:FindChild("Tips");
		item.tips:SetParent(item.transform, false);
		self:AddClick(item.tips, "OnClickTips");
	end

	--道具描述提示,目前用于房卡道具
	if param.showRoomCardTips then
		local tips = self:FindChild("DesTips");
		item.desTips = CC.uu.newObject(tips,item.transform)
		-- item.desTips = self:FindChild("DesTips");
		-- item.desTips:SetParent(item.transform, false);
	end

	if param.showFragmentTips then
		local tips = self:FindChild("DesTips");
		item.desTips = CC.uu.newObject(tips,item.transform)
		self.FragmentText = item.desTips:FindChild("Text")
		self.FragmentText.text = string.format(self.language.CurHaveNum,CC.Player.Inst():GetSelfInfoByKey("EPC_PointCard_Fragment"))
	end

	if param.showGiftVoucherTips then
		local tips = self:FindChild("DesTips");
		item.desTips = CC.uu.newObject(tips,item.transform)
		self.GiftVoucherText = item.desTips:FindChild("Text")
		self.GiftVoucherText.text = string.format(self.language.CurHaveNum,CC.Player.Inst():GetSelfInfoByKey("EPC_GiftVoucher"))
	end

	if param.commodityType == self.storeDefine.CommodityType.Battery then
		local tipSp = self:FindChild("DesTipsSp")
		local tipTrans = CC.uu.newObject(tipSp,item.transform)
		tipTrans:SetActive(true)
	end

	--月末活动雷蛇渠道CDK
	if param.btnType == self.storeDefine.StoreTab.Diamond then
		item.transform:FindChild("CDK"):SetActive(self.storeDefine.DisplayCDK(param,self.cursertime))
	end

	item.onSelect = function()
		CC.Sound.PlayEffect("click")
		self.viewCtr:OnChangeChannel(item.data);
		self:SetBtnFloat(item.data.commodityType,item.data.btnType)
	end

	UIEvent.AddToggleValueChange(item.transform, function(selected)
			if selected then
				item.onSelect();
			end
			if item.tips and not CC.ChannelMgr.GetTrailStatus() then
				item.tips:SetActive(selected);
			end
			if item.desTips then
				item.desTips:SetActive(selected);
			end
		end)

	return item;
end

function StoreView:SetBtnFloat(Type,btnType)
	local Types = self.storeDefine.CommodityType
	local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("NewPayGiftView").switchOn
	if CC.ChannelMgr.CheckOppoChannel() then
		switchOn = switchOn and Type == Types.OppoPay
	else
		switchOn = switchOn and not (Type == Types.GooglePay or Type == Types.ApplePay or Type == Types.VivoPayBank or Type == Types.VivoPaySms) and
		           not (btnType == self.storeDefine.StoreTab.Prop)
	end
	self.BtnFloat:SetActive(switchOn)
end

function StoreView:SetTabShow(tab)
	local path = "BtnBank"
	if tab == self.storeDefine.StoreTab.Diamond then
		path = "BtnChip"
	elseif tab == self.storeDefine.StoreTab.Prop then
		path = "BtnProp"
	end
	local btnTab = self:FindChild("RightPanel/BtnTab/BtnGroup/"..path);
	btnTab:GetComponent("Toggle").isOn = true;
end

function StoreView:RefreshUI(param)

	--切换页签刷新数据
	if param.showTabType then
		self:OnShowTab(param);
	end
	--切换渠道刷新商品
	if param.refreshItems then
		self:OnRefreshItems(param);
	end

	--刷新google和ios信用额度
	if param.extraCapcity then
		self:OnRefreshCapcity(param);
	end

	if param.setOrgTab then
		self:SetTabShow(param.setOrgTab);
	end

	--切换渠道按钮显示
	if param.changeChannelTab then
		self:OnSetChannelTab(param);
	end

	if param.refreshManualExchange then
		self:OnRefreshManualExchange(param);
	end

	self:RefreshBatteryBubbleState()
end

--炮台返场气泡
function StoreView:RefreshBatteryBubbleState()
	local isShow = false
	for _,v in ipairs(self.viewCtr.webStoreCfg.Prop) do
		if v.CommodityType == self.storeDefine.CommodityType.Battery then
			isShow = true
		end
	end
	local isHide = not self.viewCtr:CheckAnyBatteryHasNot()
	self:FindChild("RightPanel/BtnTab/BtnGroup/BtnProp/Bubble"):SetActive(isShow and not isHide)
end

function StoreView:OnRefreshManualExchange(param)

	if param.diamondCount then
		self:FindChild("BottomPanel/ManualExchangePanel/Diamond/Number"):SetText(param.diamondCount);
	end

	if param.chipCount then
		self:FindChild("BottomPanel/ManualExchangePanel/Chip/Number"):SetText(param.chipCount);
	end

	local slider = self:FindChild("BottomPanel/ManualExchangePanel/ExchangeNode/Slider"):GetComponent("Slider");
	if param.sliderValue then
		slider.value = param.sliderValue;
	end

	if param.maxValue then
		slider.maxValue = param.maxValue;
	end
end

function StoreView:OnSetChannelTab(param)
	local ChannelBtns = self.chipChannelBtns
	if param.storeTab == self.storeDefine.StoreTab.Prop then
		ChannelBtns = self.propChannelBtns
	elseif param.storeTab == self.storeDefine.StoreTab.Bank then
		ChannelBtns = self.bankChannelBtns
	end
	for _,v in ipairs(ChannelBtns) do
		if v.data.commodityType == param.changeChannelTab then
			v.transform:GetComponent("Toggle").isOn = true;
			break
		end
	end
end

function StoreView:OnRefreshCapcity(param)
	for _,v in ipairs(self.chipChannelBtns) do
		if v.data.showExtraTips then
			local capcity = v.tips:FindChild("Text");
			capcity.text = string.format("%s฿/%s฿", param.extraRemain, param.extraCapcity);
			break;
		end
	end
end

function StoreView:OnRefreshItems(param)

	local itemList;
	if param.storeTab == self.storeDefine.StoreTab.Diamond then
		itemList = self.chipItems;
	elseif param.storeTab == self.storeDefine.StoreTab.Prop then
		itemList = self.propItems;
	elseif param.storeTab == self.storeDefine.StoreTab.Bank then
		itemList = self.bankItems;
	end

	--需要刷新的对象数据少于对象表内个数，则隐藏多余对象

	if #itemList > #param.refreshItems then
		for i = #param.refreshItems+1, #itemList do
			itemList[i].transform:SetActive(false);
		end
	end
	--刷新数据显示时如果对象个数不够就创建新的对象
	for i,v in ipairs(param.refreshItems) do
		if itemList[i] then

			itemList[i].data = v;
			itemList[i].onRefreshData(v);
		else
			local item;
			if param.storeTab == self.storeDefine.StoreTab.Diamond then
				item = self:CreateChipItem(v);
			elseif param.storeTab == self.storeDefine.StoreTab.Prop then
				item = self:CreatePropItem(v);
			elseif param.storeTab == self.storeDefine.StoreTab.Bank then
				item = self:CreateBankItem(v);
			end
			table.insert(itemList, item);
		end
	end
	if param.storeTab == self.storeDefine.StoreTab.Diamond then
		if self.diamondTips then
			CC.uu.destroyObject(self.diamondTips)
			self.diamondTips = nil
		end
		local parent = self:FindChild("RightPanel/ScrollPanel/Viewport/Content");
		self.diamondTips = CC.uu.newObject(self:FindChild("DiamondTips"), parent);
		self.diamondTips:SetActive(true)
	else
		if self.diamondTips then
			self.diamondTips:SetActive(false)
		end
	end

	--筹码兑换渠道需要显示手动兑换功能
	if param.showManualExchange ~= nil then
		local exchangeObj = self:FindChild("BottomPanel/ManualExchangePanel");
		exchangeObj:SetActive(param.showManualExchange);
	end
end

function StoreView:OnShowTab(param)

	local items,channelBtns,createFunc;
	if param.showTabType == self.storeDefine.StoreTab.Prop then
		items,channelBtns,createFunc = self.propItems,self.propChannelBtns,self.CreatePropItem;
	elseif param.showTabType == self.storeDefine.StoreTab.Diamond then
		items,channelBtns,createFunc = self.chipItems,self.chipChannelBtns,self.CreateChipItem;
	elseif param.showTabType == self.storeDefine.StoreTab.Bank then
		items,channelBtns,createFunc = self.bankItems,self.bankChannelBtns,self.CreateBankItem;
	end

	--创建商品
	if param.items then
		for _,v in ipairs(param.items) do
			if self.playerStatus.Type == 3 then
				for _, payChannel in ipairs(self.exceptionChannel) do
					if v.commodityType == payChannel then
						local item = createFunc(self, v);
						table.insert(items, item);
					end
				end
			end
		end
	end
	--创建渠道按钮
	if param.btns then
		for _,v in ipairs(param.btns) do
			if self.playerStatus.Type == 3 then
			--异常玩家判定，限定支付渠道
				for _, payChannel in ipairs(self.exceptionChannel) do
					if v.commodityType == payChannel then
						local btn = self:CreateChannelItem(v);
						table.insert(channelBtns, btn);
					end
				end
			else
				local btn = self:CreateChannelItem(v);
				table.insert(channelBtns, btn);
			end
		end
	end

	--切换页签设置商品和渠道按钮显示
	--local active = param.showTabType == self.storeDefine.StoreTab.Prop and true or false;
	self:SetItemsActive(self.propItems, param.showTabType == self.storeDefine.StoreTab.Prop);
	self:SetItemsActive(self.propChannelBtns, param.showTabType == self.storeDefine.StoreTab.Prop);
	self:SetItemsActive(self.chipItems, param.showTabType == self.storeDefine.StoreTab.Diamond);
	self:SetItemsActive(self.chipChannelBtns, param.showTabType == self.storeDefine.StoreTab.Diamond);
	self:SetItemsActive(self.bankItems, param.showTabType == self.storeDefine.StoreTab.Bank);
	self:SetItemsActive(self.bankChannelBtns, param.showTabType == self.storeDefine.StoreTab.Bank);

	--钻石购买页签需要显示自动兑换功能
	local showAutoExchange = param.showTabType == self.storeDefine.StoreTab.Diamond;
	local exchangeObj = self:FindChild("BottomPanel/AutoExchangePanel");
	exchangeObj:SetActive(showAutoExchange);

	--动态设置裁剪区域高度，防止粒子特效穿透
	local height = showAutoExchange and -160 or -112;
	if self:IsPortraitView() then
		height = -339
	end
	local obj = self:FindChild("RightPanel/ScrollPanel"):GetComponent("RectTransform");
	obj.sizeDelta = Vector2(obj.sizeDelta.x, height);

	--切换页签设置渠道按钮选中
	for _,v in ipairs(channelBtns) do
		if param.curCommodityType == v.data.commodityType then
			--每次先关再开,触发toggleValueChange监听
			v.transform:GetComponent("Toggle").isOn = false;
			v.transform:GetComponent("Toggle").isOn = true;
		end
	end
	if param.items and table.isEmpty(param.items) or self.playerStatus.Type == 3 then
		--货架为空时默认跳转第一个页签
		channelBtns[1].transform:GetComponent("Toggle").isOn = false;
		channelBtns[1].transform:GetComponent("Toggle").isOn = true;
	end
end

function StoreView:SetItemsActive(tb, flag)
	for _,v in ipairs(tb) do
		v.transform:SetActive(flag);
	end
end

function StoreView:CreatePropItem(param)

	local item = {};
	item.data = param;
	local parent = self:FindChild("RightPanel/ScrollPanel/Viewport/Content");
	item.transform = CC.uu.newObject(self:FindChild("PropItem"), parent);

	local btn = item.transform:FindChild("Board/BtnPay");
	self:AddClick(btn, function()
			self.viewCtr:OnPay(item.data);
		end)

	item.onRefreshData = function(param)
		if param.icon then
			local icon = item.transform:FindChild("Board/Icon");
			self:SetImage(icon, param.icon);
			icon:GetComponent("Image"):SetNativeSize()
		end
		local corner = item.transform:FindChild("Board/Icon/Corner");
		corner:SetActive(param.iconCorner and true or false);
		if param.iconCorner then
			if param.iconCorner == "best" then
				CC.uu.newObject(self:FindChild("Effects/BestEffect"), corner);
			elseif param.iconCorner == "most" then
				CC.uu.newObject(self:FindChild("Effects/MostEffect"), corner);
			end
		end
		if param.count then
			local count = item.transform:FindChild("Board/Bottom/CurCount");
			count.text = param.count;
		end
		if param.price then
			local price = btn:FindChild("Price/Text");
			price.text = CC.uu.ChipFormat(param.price);
		end
		if param.propPriceIcon then
			local priceIcon = btn:FindChild("Price/Icon");
			self:SetImage(priceIcon, param.propPriceIcon);
		end

		if param.commodityType == self.storeDefine.CommodityType.Battery then
			item.transform:FindChild("Board/Bottom"):SetActive(false)
		else
			item.transform:FindChild("Board/Bottom"):SetActive(true)
		end
		local priceCorner = btn:FindChild("Corner");
		priceCorner:SetActive(param.priceDisDes and true or false);
		if param.priceDisDes then
			local priceDisDes = btn:FindChild("Corner/Text");
			priceDisDes.text = param.priceDisDes;
		end
		item.transform:SetActive(true);
	end;

	item.onRefreshData(param);

	return item;
end

function StoreView:IsPayLimit()
	if (self.playerStatus.Type == 3 or self.playerStatus.Type == 1) and self.playerStatus.AchieveDailyRechargeLimit then
		return true
	end
	return false
end

function StoreView:CreateChipItem(param)
	if self.playerStatus.Type == 3 and param.price >= 100000 then
		return
	end
	local item = {};
	item.data = param;
	local parent = self:FindChild("RightPanel/ScrollPanel/Viewport/Content");
	item.transform = CC.uu.newObject(self:FindChild("ChipItem"), parent);

	local btn = item.transform:FindChild("Board/BtnPay");
	self:AddClick(btn, function()
		if self:IsPayLimit() then
			--新手玩家当日充值上限
			CC.ViewManager.ShowMessageBox(self.language.payLimit)
		else
			self:CheckOnPay(item.data)
		end
	end)

	item.onRefreshData = function(param)
		if param.icon then
			local icon = item.transform:FindChild("Board/Icon");
			self:SetImage(icon, param.icon);
			icon:GetComponent("Image"):SetNativeSize()
		end

		--商品角标特效
		local corner = item.transform:FindChild("Board/Icon/Corner");
		corner:SetActive(param.iconCorner and true or false);
		if param.iconCorner then
			if param.iconCorner == "best" then
				if not item.bestEffect then
					item.bestEffect = CC.uu.newObject(self:FindChild("Effects/BestEffect"), corner);
				end
				item.bestEffect:SetActive(true);
				if item.mostEffect then
					item.mostEffect:SetActive(false);
				end
			end
			if param.iconCorner == "most" then
				if not item.mostEffect then
					item.mostEffect = CC.uu.newObject(self:FindChild("Effects/MostEffect"), corner);
				end
				item.mostEffect:SetActive(true);
				if item.bestEffect then
					item.bestEffect:SetActive(false);
				end
			end
		end
		if param.chipCount then
			local count = item.transform:FindChild("Board/PriceFrame/Chip/Text");
			count.text = CC.uu.ChipFormat(param.chipCount);
		end
		if param.diamondCount then
			local count = item.transform:FindChild("Board/PriceFrame/Diamond/Text");
			count.text =CC.uu.ChipFormat(param.diamondCount);
		end
		if param.price then
			local price = btn:FindChild("PriceFrame/Price");
			price.text = string.format("%s฿",CC.uu.ChipFormat(param.price/100));
		end
		local priceDisCount = btn:FindChild("PriceFrame/DisCount");
		priceDisCount:SetActive(param.priceDisCount and true or false);
		if param.priceDisCount then
			priceDisCount.text = string.format("%s฿",CC.uu.ChipFormat(param.priceDisCount/100));
		end
		local priceCorner = btn:FindChild("Corner");
		priceCorner:SetActive(param.priceDisDes and true or false);
		if param.priceDisDes then
			local priceDisDes = btn:FindChild("Corner/Text");
			priceDisDes.text = param.priceDisDes;
		end
		if param.attachments then
			self:RefreshAttachments(item);
		else
			if item.attachments then
				for k,v in ipairs(item.attachments) do
					if v.transform then
						v.transform:SetActive(false)
					end
				end
			end
		end

        --月末活动雷蛇渠道CDK
		item.transform:FindChild("Board/CDK"):SetActive(self.storeDefine.DisplayCDK(param,self.cursertime))
		item.transform:FindChild("Board/CDK/Text").text = self.language.CDKText

		item.transform:SetActive(true);
	end

	item.onRefreshData(param);

	return item;
end

function StoreView:CreateBankItem(param)
	if self.playerStatus.Type == 3 and param.price >= 100000 then
		return
	end
	local item = {};
	item.data = param;
	local parent = self:FindChild("RightPanel/ScrollPanel/Viewport/Content");
	item.transform = CC.uu.newObject(self:FindChild("BankItem"), parent);

	local btn = item.transform:FindChild("Board/BtnPay");
	self:AddClick(btn, function()
		if self:IsPayLimit() then
			--新手玩家当日充值上限
			CC.ViewManager.ShowMessageBox(self.language.payLimit)
		else
			self:CheckOnPay(item.data)
		end
	end)
	--self:AddClick(btn:FindChild("Gray"),function() CC.ViewManager.ShowTip(self:GetLanguage().viplacking) end)
	item.onRefreshData = function(param)
		if param.icon then
			local icon = item.transform:FindChild("Board/Icon");
			self:SetImage(icon, param.icon);
			icon:GetComponent("Image"):SetNativeSize()
		end

		--商品角标特效
		local corner = item.transform:FindChild("Board/Icon/Corner");
		corner:SetActive(param.iconCorner and true or false);
		if param.iconCorner then
			if param.iconCorner == "best" then
				if not item.bestEffect then
					item.bestEffect = CC.uu.newObject(self:FindChild("Effects/BestEffect"), corner);
				end
				item.bestEffect:SetActive(true);
				if item.mostEffect then
					item.mostEffect:SetActive(false);
				end
			end
			if param.iconCorner == "most" then
				if not item.mostEffect then
					item.mostEffect = CC.uu.newObject(self:FindChild("Effects/MostEffect"), corner);
				end
				item.mostEffect:SetActive(true);
				if item.bestEffect then
					item.bestEffect:SetActive(false);
				end
			end
		end
		if param.price then
			local price = btn:FindChild("PriceFrame/Price");
			price.text = string.format("%s฿",CC.uu.ChipFormat(param.price/100));
		    -- price = btn:FindChild("Gray/PriceFrame/Price");
			-- price.text = string.format("%s฿",CC.uu.ChipFormat(param.price/100));
		end
		local priceDisCount = btn:FindChild("PriceFrame/DisCount");
		priceDisCount:SetActive(param.priceDisCount and true or false);
		if param.priceDisCount then
			priceDisCount.text = string.format("%s฿",CC.uu.ChipFormat(param.priceDisCount/100));
		end
		-- priceDisCount = btn:FindChild("Gray/PriceFrame/DisCount");
		-- priceDisCount:SetActive(param.priceDisCount and true or false);
		-- if param.priceDisCount then
		-- 	priceDisCount.text = string.format("%s฿",CC.uu.ChipFormat(param.priceDisCount/100));
		-- end
		local priceCorner = btn:FindChild("Corner");
		priceCorner:SetActive(param.priceDisDes and true or false);
		if param.priceDisDes then
			local priceDisDes = btn:FindChild("Corner/Text");
			priceDisDes.text = param.priceDisDes;
		end
		 if param.attachments then
		 	self:RefreshAttachments(item);
		else
			if item.attachments then
				for k,v in ipairs(item.attachments) do
					if v.transform then
						v.transform:SetActive(false)
					end
				end
			end
		 end
		local chip = item.transform:FindChild("Board/Chip");
		chip:SetActive(param.chipCount and true or false)
		if param.chipCount then
			chip:FindChild("Text").text = CC.uu.ChipFormat(param.chipCount)
		end
		local language = self:GetLanguage()
		chip:FindChild("Left/Text").text = language.OriginalPrice
		chip:FindChild("Left/Num").text = param.bankWareCfg.OriginalPrice
		chip:FindChild("Right/Text1").text = language.SendText1
		chip:FindChild("Right/Num").text = param.bankWareCfg.Send
		chip:FindChild("Right/Text2").text = language.SendText2
		--btn:FindChild("Gray"):SetActive(CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < param.VipLimitMin)
		item.transform:SetActive(true);
	end

	item.onRefreshData(param);

	return item;
end

function StoreView:RefreshAttachments(item)

	local parent = item.transform:FindChild("Board/Attachments");
	local attachments = item.data.attachments;
	--创建附件增送物品
	if not item.attachments then
		item.attachments = {};
		for _,v in ipairs(attachments) do
			local attachItem = self:CreateAttachItem(v, parent);
			table.insert(item.attachments, attachItem);
		end
		return;
	end
	--需要刷新的对象数据少于对象表内个数，则隐藏多余对象
	if #item.attachments > #attachments then
		for i = #attachments+1, #item.attachments do
			item.attachments[i].transform:SetActive(false);
		end
	end
	--刷新数据显示时如果对象个数不够就创建新的对象
	for i,v in ipairs(attachments) do
		if item.attachments[i] then
			item.attachments[i].onRefreshData(v);
		else
			local attachItem = self:CreateAttachItem(v, parent);
			table.insert(item.attachments, attachItem);
		end
	end
end

function StoreView:CreateAttachItem(param, parent)
	local item = {};
	item.transform = CC.uu.newObject(self:FindChild("AttachmentItem"), parent);


	item.onRefreshData = function(param)
		local icon = item.transform:FindChild("Icon");
		self:SetImage(icon, param.icon);

		local count = item.transform:FindChild("Bottom/Count");
		count.text = param.count;

		--周年庆抽奖券
		local isTicket = param.configId == CC.shared_enums_pb.EPC_Props_81
		icon:SetActive(not isTicket)
		item.transform:FindChild("Bottom/Bg1"):SetActive(not isTicket)
		item.transform:FindChild("Bottom/Bg2"):SetActive(isTicket)

		item.transform:SetActive(true);
	end

	item.onRefreshData(param);

	return item;
end

function StoreView:CheckOnPay(data)
	local config = self.viewCtr:CheckTips(data.commodityType)
	
	--后续
	local nextFunc = function()
		CC.HallUtil.GetRealAuthStates(data,function ()
				self.viewCtr:OnPay(data);
			end)
	end
	
	--3秒强制跳转提示
	local showForceTips = function(tips)
		CC.ViewManager.ShowConfirmBox(tips,nextFunc,nil,nil,3)
	end
	
	--提示1 确认
	local confirmFunc = function()
		if config.Tips2 and config.Tips2 ~= "" then
			showForceTips(config.Tips2)
		else
			nextFunc()
		end
	end
	
	if config then
		if config.Tips and config.Tips ~= "" then
			--确认提示
			CC.ViewManager.ShowMessageBox(config.Tips,confirmFunc)
		elseif config.Tips2 and config.Tips2 ~= "" then
			showForceTips(config.Tips2)
		else
			nextFunc()
		end
	else
		nextFunc()
	end
end

function StoreView:RefreshTips()
	self.FragmentText.text = string.format(self.language.CurHaveNum,CC.Player.Inst():GetSelfInfoByKey("EPC_PointCard_Fragment"))
	self.GiftVoucherText.text = string.format(self.language.CurHaveNum,CC.Player.Inst():GetSelfInfoByKey("EPC_GiftVoucher"))
end

function StoreView:OnClickChangeToProp()
	self.viewCtr:OnChangeToProp();
end

function StoreView:OnClickChangeToDiamond()
	self.viewCtr:OnChangeToDiamond();
end

function StoreView:OnClickChangeToBank()
	self.viewCtr:OnChangeToBank();
end

function StoreView:SetRightPanelContentPadding(size)
	self:FindChild("RightPanel/ScrollPanel/Viewport/Content"):GetComponent("VerticalLayoutGroup").padding.bottom = size
end

function StoreView:OnClickTips()
	self.viewCtr:OnOpenExplainView();
end

function StoreView:OnClickBtnAdd()
	self.viewCtr:OnAddExchangeCount();
end

function StoreView:OnClickBtnMinus()
	self.viewCtr:OnMinusExchangeCount();
end

function StoreView:SetExchangeSlider(value)
	self.viewCtr:OnSetExchangeSlider(value);
end

function StoreView:SetAutoExchange()
	local autoExchange = self.viewCtr.autoExchange == "true"
	local Language = self:GetLanguage()
	local box = CC.ViewManager.ShowMessageBox(autoExchange and Language.AutoExchangeFalse or Language.AutoExchangeTrue,function()
		self.AutoExchangeBtn:FindChild("Close"):SetActive(autoExchange)
	    self.AutoExchangeBtn:FindChild("Open"):SetActive(not autoExchange)
		self.viewCtr:OnSetAutoExchange(autoExchange and "false" or "true");
	end)
	box:SetOkText(Language.Affirm)
	box:SetNoText(Language.Cancel)
end

function StoreView:OnClickBtnExchange()
	self.viewCtr:OnExchangeChips();
end

function StoreView:OnDestroy()
	self:CancelAllDelayRun()
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

	if self.callback then
		self.callback(self.buyInStore);
		self.callback = nil;
	end
end

function StoreView:ActionIn()

end

return StoreView;