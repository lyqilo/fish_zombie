
local CC = require("CC")

local TrailStoreView = CC.uu.ClassView("TrailStoreView")

function TrailStoreView:ctor(param)

	self:InitVar(param);
end

function TrailStoreView:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
end

function TrailStoreView:CreateViewCtr(...)
	local viewCtrClass = require("View/TrailView/"..self.viewName.."Ctr");
	return viewCtrClass.new(self, ...);
end


function TrailStoreView:InitVar(param)

	self.param = param;
	--筹码对象列表
	self.chipItems = {};
	--道具对象列表
	self.propItems = {};
	--筹码渠道按钮列表
	self.chipChannelBtns = {};
	--道具按钮列表
	self.propChannelBtns = {};

	self.storeDefine = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine");

	self.callback = self.param and self.param.callback;
end

function TrailStoreView:InitContent(param)

	local headNode = self:FindChild("TopPanel/HeadNode");
	self.HeadIcon = CC.HeadManager.CreateHeadIcon({parent = headNode, clickFunc = "unClick"});

	local diamondNode = self:FindChild("TopPanel/NodeMgr/DiamondNode");
	self.diamondCounter = CC.HeadManager.CreateDiamondCounter({parent = diamondNode, hideBtnAdd = true});

	local chipNode = self:FindChild("TopPanel/NodeMgr/ChipNode");
	self.chipCounter = CC.HeadManager.CreateChipCounter({parent = chipNode, hideBtnAdd = true});


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

	self:AddClick("RightPanel/BtnTab/BtnProp", "OnClickChangeToProp", "click_tabchange");

	self:AddClick("RightPanel/BtnTab/BtnChip", "OnClickChangeToDiamond", "click_tabchange");

	if param.autoExchange then
		self:FindChild("BottomPanel/AutoExchangePanel/Node/Toggle"):GetComponent("Toggle").isOn = param.autoExchange;
	end
	--自动兑换勾选按钮
	UIEvent.AddToggleValueChange(self:FindChild("BottomPanel/AutoExchangePanel/Node/Toggle"), function(selected)
			self:SetAutoExchange(selected);
		end)

	UIEvent.AddSliderOnValueChange(self:FindChild("BottomPanel/ManualExchangePanel/ExchangeNode/Slider"), function(selected)
			self:SetExchangeSlider(selected);
		end)

	self:AddClick("BottomPanel/ManualExchangePanel/ExchangeNode/BtnAdd", "OnClickBtnAdd");

	self:AddClick("BottomPanel/ManualExchangePanel/ExchangeNode/BtnMinus", "OnClickBtnMinus");

	self:AddClick("BottomPanel/ManualExchangePanel/BtnExchange", "OnClickBtnExchange");

	-- self:AddClick("TopPanel/BtnBG/BtnBack", "Destroy");

	self:AddClick("TopPanel/BtnBG/BtnBack", function()
			self:Destroy();
		end);
	self:InitTextByLanguage();

	--获取裁剪区域左下角和右上角的世界坐标
	local viewport = self:FindChild("RightPanel/ScrollPanel/Viewport");
	local wordPos = viewport:GetComponent("RectTransform"):GetWorldCorners()
	local minX = wordPos[0].x;
	local minY = wordPos[0].y;
	local maxX = wordPos[2].x;
	local maxY = wordPos[2].y;

	--把坐标传入shader(maskParticle.shader，maskShine.shader)
	local nodePath = {"ChipItem/Board/BtnPay/Corner/SaveEffect", "Effects"}
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
end

function TrailStoreView:InitTextByLanguage()

	local language = CC.LanguageManager.GetLanguage("L_StoreView");

	local tips = self:FindChild("Tips/Title");
	tips.text = language.googleTips;

	local desTips = self:FindChild("DesTips/Text");
	desTips.text = language.roomcardTips;

	local autoExchange = self:FindChild("BottomPanel/AutoExchangePanel/Node/Text");
	autoExchange.text = language.autoExchange;

	local btnExchange = self:FindChild("BottomPanel/ManualExchangePanel/BtnExchange/Text");
	btnExchange.text = language.btnExchange;

	local diamondDes = self:FindChild("BottomPanel/ManualExchangePanel/Diamond/Des");
	diamondDes.text = language.diamondDes;

	local chipDes = self:FindChild("BottomPanel/ManualExchangePanel/Chip/Des");
	chipDes.text = language.chipDes;

	self:FindChild("ChipItem/Board/PriceFrame/Equal").text = "=";
end


--创建左边渠道和道具按钮对象
function TrailStoreView:CreateChannelItem(param)
	local item = {};
	item.data = param;
	--根据按钮类型创建对应object
	local parent = self:FindChild("LeftPanel/Viewport/Content");
	local itemName = param.btnType == self.storeDefine.StoreTab.Diamond and "ChannelBtn" or "PropBtn";
	item.transform = CC.uu.newObject(self:FindChild(itemName),parent);
	item.transform:SetActive(true);
	--设置渠道按钮图标
	if param.icon then
		self:SetImage(item.transform:FindChild("Icon"), param.icon);
	end
	--设置道具按钮文本
	if param.iconText then
		item.transform:FindChild("Icon"):SetText(param.iconText);
	end
	--google和ios渠道特殊处理
	if param.showExtraTips then
		item.tips = self:FindChild("Tips");
		item.tips:SetParent(item.transform, false);
		-- item.tips:SetActive(true);
		self:AddClick(item.tips, "OnClickTips");
	end

	--道具描述提示,目前用于房卡道具
	if param.showRoomCardTips then
		item.desTips = self:FindChild("DesTips");
		item.desTips:SetParent(item.transform, false);
	end

	item.onSelect = function()
		self.viewCtr:OnChangeChannel(item.data);
	end

	UIEvent.AddToggleValueChange(item.transform, function(selected)
			if selected then
				item.onSelect();
			end
			if item.tips then
				item.tips:SetActive(selected);
			end
			if item.desTips then
				item.desTips:SetActive(selected);
			end
		end)

	return item;
end

function TrailStoreView:SetTabShow(tab)
	local path = tab == self.storeDefine.StoreTab.Diamond and "BtnChip" or "BtnProp";
	local btnTab = self:FindChild("RightPanel/BtnTab/"..path);
	btnTab:GetComponent("Toggle").isOn = true;
end

function TrailStoreView:RefreshUI(param)

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
		self:OnSetChannelTab(param.changeChannelTab);
	end

	if param.refreshManualExchange then
		self:OnRefreshManualExchange(param);
	end
end

function TrailStoreView:OnRefreshManualExchange(param)

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

function TrailStoreView:OnSetChannelTab(changeTab)
	for _,v in ipairs(self.propChannelBtns) do
		if v.data.commodityType == changeTab then
			v.transform:GetComponent("Toggle").isOn = true;
		end
	end
end 

function TrailStoreView:OnRefreshCapcity(param)
	for _,v in ipairs(self.chipChannelBtns) do
		if v.data.showExtraTips then
			local capcity = v.tips:FindChild("Text");
			capcity.text = string.format("%s฿/%s฿", param.extraRemain, param.extraCapcity);
			break;
		end
	end
end

function TrailStoreView:OnRefreshItems(param)

	local itemList;
	if param.storeTab == self.storeDefine.StoreTab.Diamond then
		itemList = self.chipItems;
	elseif param.storeTab == self.storeDefine.StoreTab.Prop then
		itemList = self.propItems;
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
			end
			table.insert(itemList, item);
		end
	end

	--筹码兑换渠道需要显示手动兑换功能
	if param.showManualExchange ~= nil then
		local exchangeObj = self:FindChild("BottomPanel/ManualExchangePanel");
		exchangeObj:SetActive(param.showManualExchange);
	end
end

function TrailStoreView:OnShowTab(param)

	local items,channelBtns,createFunc;
	if param.showTabType == self.storeDefine.StoreTab.Prop then
		items,channelBtns,createFunc = self.propItems,self.propChannelBtns,self.CreatePropItem;
	elseif param.showTabType == self.storeDefine.StoreTab.Diamond then
		items,channelBtns,createFunc = self.chipItems,self.chipChannelBtns,self.CreateChipItem;
	end

	--创建商品
	if param.items then
		for _,v in ipairs(param.items) do
			local item = createFunc(self, v);
			table.insert(items, item);
		end
	end
	--创建渠道按钮
	if param.btns then
		for _,v in ipairs(param.btns) do
			local btn = self:CreateChannelItem(v);
			table.insert(channelBtns, btn);
		end
	end

	--切换页签设置商品和渠道按钮显示
	local active = param.showTabType == self.storeDefine.StoreTab.Prop and true or false;
	self:SetItemsActive(self.propItems, active);
	self:SetItemsActive(self.propChannelBtns, active);
	self:SetItemsActive(self.chipItems, not active);
	self:SetItemsActive(self.chipChannelBtns, not active);

	--钻石购买页签需要显示自动兑换功能
	local showAutoExchange = param.showTabType == self.storeDefine.StoreTab.Diamond;
	local exchangeObj = self:FindChild("BottomPanel/AutoExchangePanel");
	exchangeObj:SetActive(showAutoExchange);

	--动态设置裁剪区域高度，防止粒子特效穿透
	local height = showAutoExchange and -160 or -112;
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
end

function TrailStoreView:SetItemsActive(tb, flag)
	for _,v in ipairs(tb) do
		v.transform:SetActive(flag);
	end
end

function TrailStoreView:CreatePropItem(param)

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

		item.transform:SetActive(true);
	end;

	item.onRefreshData(param);

	return item;
end

function TrailStoreView:CreateChipItem(param)

	local item = {};
	item.data = param;
	local parent = self:FindChild("RightPanel/ScrollPanel/Viewport/Content");
	item.transform = CC.uu.newObject(self:FindChild("ChipItem"), parent);
	
	local btn = item.transform:FindChild("Board/BtnPay");
	self:AddClick(btn, function()
			self.viewCtr:OnPay(item.data);
		end)

	item.onRefreshData = function(param)
		if param.icon then
			local icon = item.transform:FindChild("Board/Icon");
			self:SetImage(icon, param.icon);
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
		end
		item.transform:SetActive(true);
	end

	item.onRefreshData(param);

	return item;
end

function TrailStoreView:RefreshAttachments(item)

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

function TrailStoreView:CreateAttachItem(param, parent)
	local item = {};
	item.transform = CC.uu.newObject(self:FindChild("AttachmentItem"), parent);
	

	item.onRefreshData = function(param)
		local icon = item.transform:FindChild("Icon");
		self:SetImage(icon, param.icon);

		local count = item.transform:FindChild("Bottom/Count");
		count.text = param.count;

		item.transform:SetActive(true);
	end

	item.onRefreshData(param);

	return item;
end

function TrailStoreView:OnClickChangeToProp()
	self.viewCtr:OnChangeToProp();
end

function TrailStoreView:OnClickChangeToDiamond()
	self.viewCtr:OnChangeToDiamond();
end

function TrailStoreView:OnClickTips()
	self.viewCtr:OnOpenExplainView();
end

function TrailStoreView:OnClickBtnAdd()
	self.viewCtr:OnAddExchangeCount();
end

function TrailStoreView:OnClickBtnMinus()
	self.viewCtr:OnMinusExchangeCount();
end

function TrailStoreView:SetExchangeSlider(value)
	self.viewCtr:OnSetExchangeSlider(value);
end

function TrailStoreView:SetAutoExchange(value)
	self.viewCtr:OnSetAutoExchange(value);
end

function TrailStoreView:OnClickBtnExchange()
	self.viewCtr:OnExchangeChips();
end

function TrailStoreView:OnDestroy()
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
		self.callback();
		self.callback = nil;
	end
end

function TrailStoreView:ActionIn()

end

return TrailStoreView;