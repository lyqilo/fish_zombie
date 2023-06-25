
local CC = require("CC")

local StoreViewCtr = CC.class2("StoreViewCtr")

local debugShowMol = false;

--[[
@param
channelTab  --指定渠道页签
extraData   --支付传入的额外数据
]]
function StoreViewCtr:ctor(view, param)

	CC.ViewManager.HideChatPanel();

	self:InitVar(view, param);
end

function StoreViewCtr:OnCreate()

	self:ReqPlayerStatus()

	self:RegisterEvent();
end

function StoreViewCtr:InitVar(view, param)

	self.param = param or {};

	self.view = view;
	--当前商店页签
	self.storeTab = nil;
	--道具商品相关数据
	self.propData = {};
	--筹码商品相关数据
	self.chipOpenChannel = {}
	self.chipData = {};
	--银行渠道商品相关数据
	self.bankOpenChannel = {}
	self.bankData = {};
	--后台商店配置
	self.webStoreCfg = {};
	--充值额度限制
	self.CreditLineList = nil

	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.storeDefine = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine");
	self.gameData = CC.DataMgrCenter.Inst():GetDataByKey("Game");

	self.language = self.view:GetLanguage();

	--选择兑换的钻石数额
	self.exchangeDiamond = 0;
	--能够兑换的筹码数额
	self.exchangeChip = 0;
	--可兑换的钻石总额
	self.totalDiamond = 0;
	--自动兑换标记
	self.autoExchange = false;
	--刷新数据
	self.forceRefresh = false
	--刷新数据
	self.isGetPlayerStatus = false

	self.hideAutoExchange = self.param and self.param.hideAutoExchange or false

	--给一份默认的计费点配置防止web配置拉取不到
	self.orgStoreCfg = {
	    MolOpenChips = 0,
	    MolHide = 1,
	    Chip = {
		    Other = {
		        {CommodityType = 31, WareIds = {'com.huoys.royalcasino.product1','com.huoys.royalcasino.product2','com.huoys.royalcasino.product3',
		        'com.huoys.royalcasino.product4','com.huoys.royalcasino.product5','com.huoys.royalcasino.product6','com.huoys.royalcasino.product7'},
		    	Index = 1}
		    },
			Mol = {
				-- {CommodityType = 21, WareIds = {91001,91002,91003,91004,91005}},
				-- {CommodityType = 22, WareIds = {92001,92002,92003,92004,92005}},
				-- {CommodityType = 23, WareIds = {93001,93002,93003,93004,93005,93006,93007}},
				-- {CommodityType = 24, WareIds = {95003,95004,95005,95006,95007,95008,95009,95010,95011,95012,95013,95014,95015,95016}},
				-- {CommodityType = 25, WareIds = {96003,96004,96005,96006,96007,96008,96009,96010,96011,96012,96013,96014,96015,96016}},
				-- {CommodityType = 26, WareIds = {97003,97004,97005,97006,97007,97008,97009,97010,97011,97012,97013,97014,97015,97016}},
				-- {CommodityType = 27, WareIds = {94003,94004,94005,94006,94007,94008,94009,94010,94011}},
			}

		},
		Bank = {},
	    Prop = {
	        {CommodityType = 13, WareIds = {21001,21002,21003,21004,21005,21006,21007,21008,21009,21010}},
	        {CommodityType = 14, WareIds = {22001,22002,22003,22004,22005}},
	        {CommodityType = 16, WareIds = {22101,22102,22103}},
			{CommodityType = 17, WareIds = {22201,22202,22203,22204}},
	    }
	}

	self.batteryList = {}
end

function StoreViewCtr:InitData()

	self.webStoreCfg = self:GetStoreCfg();
	self:InitBattleList()
	self.propData.curCommodityType = self.storeDefine.CommodityType.Chip;
	self.propData.btns = self:GetPropChannelData()

	self.chipOpenChannel = self:GetChipChannel()
	self.chipData.curCommodityType = self.chipOpenChannel[1] and self.chipOpenChannel[1].CommodityType or 31
	self.chipData.btns = self:GetChipChannelData()

	self.bankOpenChannel = self:GetBankChannel()
	self.bankData.curCommodityType = self.bankOpenChannel[1] and self.bankOpenChannel[1].CommodityType or 0
	self.bankData.btns = self:GetBankChannelData()

	if CC.ChannelMgr.GetIOSPrivateStatus() then
		self.chipData.curCommodityType = self.storeDefine.CommodityType.Pay12Call;
	end

	self.autoExchange = CC.LocalGameData.GetDataByKey("IsAutoExchangeChip",CC.Player.Inst():GetSelfInfoByKey("Id"))
	if self.autoExchange == nil then
		self:OnSetAutoExchange(false);
	end

	local data = {};
	local isShowMol = self:IsShowMol()
	if self.param.channelTab then
		--判断传入的渠道页签是否为砖石页签
		for _,v in ipairs(self.chipOpenChannel) do
			if v.CommodityType == self.param.channelTab then
				data.setOrgTab = self.storeDefine.StoreTab.Diamond;
				break;
			end
		end

		--判断传入的渠道页签是否为道具页签
		if not data.setOrgTab and not self.view:IsPortraitView() then
			for _,v in ipairs(self.webStoreCfg.Prop) do
				if v.CommodityType == self.param.channelTab then
					data.setOrgTab = self.storeDefine.StoreTab.Prop;
					break;
				end
			end
		end

		--判断传入的渠道页签是否为银行页签
		if not data.setOrgTab and isShowMol and self:IsBankChanell(self.param.channelTab) then
			data.setOrgTab = self.storeDefine.StoreTab.Bank
		end
	end

	if not data.setOrgTab then
		data.setOrgTab = self.storeDefine.StoreTab.Diamond
		if isShowMol and CC.LocalGameData.GetLocalDataToKey("FirstOpenStore", CC.Player.Inst():GetSelfInfoByKey("Id")) then
			CC.LocalGameData.SetLocalDataToKey("FirstOpenStore", CC.Player.Inst():GetSelfInfoByKey("Id"))
			data.setOrgTab = self.storeDefine.StoreTab.Bank
		end
	elseif data.setOrgTab == self.storeDefine.StoreTab.Bank then
		CC.LocalGameData.SetLocalDataToKey("FirstOpenStore", CC.Player.Inst():GetSelfInfoByKey("Id"))
	end

	data.showBackIcon = not CC.ViewManager.IsHallScene();
	data.autoExchange = self.autoExchange == "true" and true;
	data.isShowBankTb = isShowMol
	data.scrollPosition = self.param.scrollPosition
	self.view:InitContent(data);

	if data.setOrgTab == self.storeDefine.StoreTab.Diamond then
		self:OnChangeToDiamond();
	elseif data.setOrgTab == self.storeDefine.StoreTab.Prop then
		self:OnChangeToProp();
	else
		self:OnChangeToBank();
	end

	CC.HallUtil.OnShowHallCamera(false);

	--切换到指定渠道页签
	if self.param.channelTab then
		local temptable = self.chipData
		if data.setOrgTab == self.storeDefine.StoreTab.Prop then
			temptable = self.propData
		elseif data.setOrgTab == self.storeDefine.StoreTab.Bank then
			temptable = self.bankData
		end
		for i,v in ipairs(temptable.btns) do
			if v.commodityType == self.param.channelTab then
				self:OnChangeByChannel(self.param.channelTab,data.setOrgTab)
				return
			end
		end
		log("无法切换到指定渠道页签，自动切换到默认页签")
	end

end

function StoreViewCtr:InitBattleList()
	--任意一个没有
	self.batteryList = {}
	for _, v in ipairs(self.webStoreCfg.Prop) do
		if v.CommodityType == self.storeDefine.CommodityType.Battery then
			for _,wareId in ipairs(v.WareIds) do
				local batteryId = self.wareCfg[tostring(wareId)].Rewards[1].ConfigId
				table.insert(self.batteryList,batteryId)
			end
		end
	end
end

function StoreViewCtr:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);

	CC.HallNotificationCenter.inst():register(self,self.OnRefreshPropChange,CC.Notifications.changeSelfInfo);

	CC.HallNotificationCenter.inst():register(self,self.OnExchangeRsp,CC.Notifications.NW_Exchange);

	CC.HallNotificationCenter.inst():register(self,self.OnLoadCreditLineRsp,CC.Notifications.NW_ReqLoadCreditLine);

	CC.HallNotificationCenter.inst():register(self,self.OnGetPlayerStatus,CC.Notifications.NW_ReqGetPlayerType);

	CC.HallNotificationCenter.inst():register(self,self.OnBuyWithIdRsp,CC.Notifications.NW_ReqBuyWithId);
end

function StoreViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self);
end

function StoreViewCtr:GetStoreCfg()
	local storeCfg = self.gameData.GetStoreCfg();

	if table.isEmpty(storeCfg) then

		storeCfg = self.orgStoreCfg;
		--ios平台需要切换苹果计费点
		if CC.Platform.isIOS then
			storeCfg.Chip.Other = {
				CommodityType = 41,
				WareIds = {'com.huoys.royalcasino.productios1','com.huoys.royalcasino.productios2','com.huoys.royalcasino.productios3','com.huoys.royalcasino.productios4',
					'com.huoys.royalcasino.productios5','com.huoys.royalcasino.productios6','com.huoys.royalcasino.productios7'
		        },
		        Index = 1
		    }
		elseif CC.ChannelMgr.CheckOppoChannel() then
			storeCfg.Chip.Other = {
				CommodityType = 1001,
				WareIds = {'oppo10001','oppo10002','oppo10003','oppo10004','oppo10005','oppo10006','oppo10007','oppo10008','oppo10009','oppo10010',
				'oppo10011','oppo10012','oppo10013','oppo10014','oppo10015','oppo10016','oppo10017','oppo10018','oppo10019','oppo10020',
		        },
		        Index = 1
		    }
		end
	end
	--道具没有配置就用默认的
	if table.isEmpty(storeCfg.Prop) then
		storeCfg.Prop = self.orgStoreCfg.Prop;
	end

	return storeCfg;
end

function StoreViewCtr:GetChipChannel()
	local data = {};
	--玩家流水超过这个配置的值就显示Mol支付
	if self:IsShowMol() then
		for _, v in ipairs(self.webStoreCfg.Chip.Mol) do
			if v.IsOpen then
				table.insert(data, v)
			end
		end
	end
	for _, v in ipairs(self.webStoreCfg.Chip.Other) do
		if v.IsOpen then
			if CC.ChannelMgr.CheckOfficialWebChannel() and v.CommodityType == self.storeDefine.CommodityType.GooglePay then
				log("官网包屏蔽google渠道")
			else
				table.insert(data, v);
			end
		end
	end
	table.sort(data, function(a,b) return a.Index < b.Index end )
	return data;
end

function StoreViewCtr:GetBankChannel()
	local data = {};
	--玩家流水超过这个配置的值就显示Mol支付
	if self:IsShowMol() then
		for _, v in ipairs(self.webStoreCfg.Bank) do
			if v.IsOpen then
				table.insert(data, v)
			end
		end
	end
	table.sort(data, function(a,b) return a.Index < b.Index end )
	return data;
end

function StoreViewCtr:IsBankChanell(CommodityType)
	if CommodityType then
		for _,v in pairs(self.bankOpenChannel) do
			if CommodityType == v.CommodityType then
				return true
			end
		end
	end
	return false
end

function StoreViewCtr:OnChangeChannel(param)

	local dataObj;

	if param.btnType == self.storeDefine.StoreTab.Diamond then
		dataObj = self.chipData;
	elseif param.btnType == self.storeDefine.StoreTab.Prop then
		dataObj = self.propData;
	elseif param.btnType == self.storeDefine.StoreTab.Bank then
		dataObj = self.bankData;
	end
	dataObj.curCommodityType = param.commodityType;

	dataObj.items = self:GetChannelItems(dataObj.curCommodityType);

	local data = {};
	data.refreshItems = dataObj.items;
	data.storeTab = self.storeTab;
	data.changeChannelTab = param.changeChannelTab;
	data.showManualExchange = false;
	if dataObj.curCommodityType == self.storeDefine.CommodityType.Chip then
		data.showManualExchange = true;
		self:InitManualExchange();
	end

	self.view:RefreshUI(data);
end

function StoreViewCtr:OnChangeToDiamond()

	if self.storeTab == self.storeDefine.StoreTab.Diamond then return end

	self.view:SetRightPanelContentPadding(-40)
	
	self.storeTab = self.storeDefine.StoreTab.Diamond;

	local data = self:GetChangeTabData();
	data.setOrgTab = self.storeDefine.StoreTab.Diamond;

	self.view:RefreshUI(data);
end

function StoreViewCtr:OnChangeToProp()

	if self.storeTab == self.storeDefine.StoreTab.Prop and self.forceRefresh == false then return end
	
	self.view:SetRightPanelContentPadding(80)
	
	self.storeTab = self.storeDefine.StoreTab.Prop;

	local data = self:GetChangeTabData();
	data.setOrgTab = self.storeDefine.StoreTab.Prop;

	self.view:RefreshUI(data);
end

function StoreViewCtr:OnChangeToBank()

	if self.storeTab == self.storeDefine.StoreTab.Bank then return end

	self.view:SetRightPanelContentPadding(0)
	
	self.storeTab = self.storeDefine.StoreTab.Bank;

	local data = self:GetChangeTabData();
	data.setOrgTab = self.storeDefine.StoreTab.Bank;

	self.view:RefreshUI(data);

	--Vip10 以上玩家进入银行渠道时，直接切换到下一页(从100开始）
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") > 10 then
		self.view:DelayRun(0.05,function()
			if self.param.scrollPosition and self:IsBankChanell(self.param.channelTab) then
				return
			end
			self.view.RightScrollRect.verticalNormalizedPosition = 0.7
		end)
	end
end

function StoreViewCtr:OnChangeToDiamondByChannel(channel)

	local data = {};
	data.btnType = self.storeDefine.StoreTab.Chip;
	data.commodityType = channel;
	data.changeChannelTab = channel;
	self.storeTab = self.storeDefine.StoreTab.Chip
	self:OnChangeChannel(data);
end

function StoreViewCtr:OnChangeByChannel(channel,tab)

	local data = {};
	data.btnType = tab;
	data.commodityType = channel;
	data.changeChannelTab = channel;
	self.storeTab = tab
	self:OnChangeChannel(data);
end

function StoreViewCtr:GetChangeTabData()

	local dataObj;
	if self.storeTab == self.storeDefine.StoreTab.Diamond then
		dataObj = self.chipData;
	elseif self.storeTab == self.storeDefine.StoreTab.Prop then
		dataObj = self.propData;
	elseif self.storeTab == self.storeDefine.StoreTab.Bank then
		dataObj = self.bankData;
	end
	local data = {};
	if not dataObj.items or self.forceRefresh then
		dataObj.items = self:GetChannelItems(dataObj.curCommodityType);
		data.items = dataObj.items;
		data.btns = dataObj.btns;
	end

	data.showTabType = self.storeTab;
	data.curCommodityType = dataObj.curCommodityType;

	return data;
end

function StoreViewCtr:GetChipChannelData()
	local data = {};
	for _, v in ipairs(self.chipOpenChannel) do
		local tb = {};
		tb.commodityType = v.CommodityType;
		tb.icon = self:GetChipChannelIcon(v.CommodityType);
		tb.btnType = self.storeDefine.StoreTab.Diamond;
		tb.chlDiscount = v.Discount;
		if tb.commodityType == self.storeDefine.CommodityType.GooglePay or tb.commodityType == self.storeDefine.CommodityType.ApplePay then
			tb.showExtraTips = true;
			--请求google和ios额度
			self:ReqExtraCapcity();
		end
		table.insert(data, tb);
	end

	return data;
end

function StoreViewCtr:GetPropChannelData()

	local data = {};
	for _, v in ipairs(self.webStoreCfg.Prop) do
		local tb = {};
		local isHide = false
		tb.commodityType = v.CommodityType;
		tb.iconText = self:GetPropChannelText(v.CommodityType);
		tb.btnType = self.storeDefine.StoreTab.Prop;
		if v.CommodityType == self.storeDefine.CommodityType.RoomCard then
			tb.showRoomCardTips = true;
		elseif v.CommodityType == self.storeDefine.CommodityType.Fragment then
			tb.showFragmentTips = true;
		elseif v.CommodityType == self.storeDefine.CommodityType.GiftVoucher then
			tb.showGiftVoucherTips = true;
		elseif v.CommodityType == self.storeDefine.CommodityType.Battery then
			--招财猫炮台、朱雀炮台、龙击炮都拥有则隐藏标签
			isHide = not self:CheckAnyBatteryHasNot()
			tb.showBatteryTips = isHide
		end
		if not isHide then
			table.insert(data, tb);
		end
	end
	return data;
end

function StoreViewCtr:CheckAnyBatteryHasNot()
	--任意一个没有
	local anyHasNot = false
	for _, v in ipairs(self.batteryList) do
		anyHasNot = anyHasNot or CC.Player.Inst():GetSelfInfoByKey(v) <= 0
	end
	return anyHasNot
end

function StoreViewCtr:GetBankChannelData()
	local data = {};

	--玩家流水超过这个配置的值就显示Mol支付
	if self:IsShowMol() then
		for _, v in ipairs(self.bankOpenChannel) do
			local tb = {};
			tb.commodityType = v.CommodityType;
			tb.icon = self:GetChipChannelIcon(v.CommodityType);
			tb.btnType = self.storeDefine.StoreTab.Bank;
			tb.chlDiscount = v.Discount;
			table.insert(data, tb);
		end
	end
	return data
end

function StoreViewCtr:GetChipChannelIcon(commodityType)
	for key,v in pairs(self.storeDefine.CommodityType) do
		if commodityType == v then
			return self.storeDefine.ChipChannelIcon[key];
		end
	end
	logError("StoreViewCtr:has no match chipChannelIcon");
end

function StoreViewCtr:GetPropChannelText(commodityType)
	local key = string.format("store_%s_Name", commodityType);
	return CC.ConfigCenter.Inst():getDescByKey(key) or "";
end

function StoreViewCtr:GetChannelItems(commodityType)
	if not commodityType then return end
	--找到后台对应的渠道配置
	local channelData;
	if self.storeTab == self.storeDefine.StoreTab.Diamond then
		for _,v in ipairs(self.chipOpenChannel) do
			if v.CommodityType == commodityType then
				channelData = v;
			end
		end
	elseif self.storeTab == self.storeDefine.StoreTab.Prop then
		for _,v in ipairs(self.webStoreCfg.Prop) do
			if v.CommodityType == commodityType then
				channelData = v;
			end
		end
	elseif self.storeTab == self.storeDefine.StoreTab.Bank then
		for _,v in ipairs(self.bankOpenChannel) do
			if v.CommodityType == commodityType then
				channelData = v;
			end
		end
	end

	if not channelData then
		logError("StoreViewCtr: not find channel Data");
		return
	end
	--组装需要使用的商品数据
	local data = {};
	for _,id in ipairs(channelData.WareIds) do
		local itemCfg = self.wareCfg[tostring(id)];
		local itemData;
		if self.storeTab == self.storeDefine.StoreTab.Diamond then
			itemData = self:GetChipData(itemCfg);
		elseif self.storeTab == self.storeDefine.StoreTab.Prop then
			itemData = self:GetPropData(itemCfg);
		elseif self.storeTab == self.storeDefine.StoreTab.Bank then
			itemData = self:GetBankData(itemCfg);
		end
		if commodityType == self.storeDefine.CommodityType.Battery then
			--炮台返场仅显示未拥有的
			local rewardId = itemCfg.Rewards[1].ConfigId
			if CC.Player.Inst():GetSelfInfoByKey(rewardId) <= 0 then
				table.insert(data,itemData)
			end
		else
			table.insert(data, itemData);
		end
	end
	return data;
end

function StoreViewCtr:GetPropData(param)
	local data = {};
	data.id = param.Id;
	data.icon = param.Icon;
	data.price = param.Price;
	data.count = param.Rewards[1].Count;
	data.commodityType = param.CommodityType;
	data.subChannel = param.SubChannel;
	data.itemType = self.storeDefine.StoreTab.Prop;
	data.propPriceIcon = self:GetPropPriceIcon(param.CommodityType);
	if param.IconCorner ~= "" then
		data.iconCorner = param.IconCorner;
	end
	if type(param.Condition) == "table" then
		data.priceDisDes = param.Condition[1].Des;
	end
	return data;
end

function StoreViewCtr:GetChipData(param)
	local data = {};
	data.id = param.Id;
	data.icon = param.Icon;
	data.diamondCount = param.Rewards[1].Count;
	data.chipCount = param.Chips;
	data.commodityType = param.CommodityType;
	data.subChannel = param.SubChannel;
	data.attachments = self:GetAttachmentsData(param.Additional);
	data.itemType = self.storeDefine.StoreTab.Diamond;
	if param.IconCorner ~= "" then
		data.iconCorner = param.IconCorner;
	end
	data.price = param.Price;
	if type(param.Condition) == "table" then
		data.priceDisDes = param.Condition[1].Des;
		data.priceDisCount = param.Condition[1].Price;
	end
	return data;
end

function StoreViewCtr:GetBankData(param)
	local data = {};
	data.id = param.Id;
	data.VipLimitMin = param.VipLimitMin;
	data.icon = param.Icon;
	-- data.diamondCount = param.Rewards[1].Count;
    data.chipCount = param.Chips;
	data.commodityType = param.CommodityType;
	data.subChannel = param.SubChannel;
	data.attachments = self:GetAttachmentsData(param.Additional);
	data.itemType = self.storeDefine.StoreTab.Bank;
	if param.IconCorner ~= "" then
		data.iconCorner = param.IconCorner;
	end
	data.price = param.Price;
	if type(param.Condition) == "table" then
		data.priceDisDes = param.Condition[1].Des;
		data.priceDisCount = param.Condition[1].Price;
	end
	local bankWareCfg = self.storeDefine.BankWareCfg[tostring(param.Chips)]
	data.bankWareCfg = bankWareCfg
	return data;
end

function StoreViewCtr:GetPropPriceIcon(commodityType)
	for key,v in pairs(self.storeDefine.CommodityType) do
		if commodityType == v then
			return self.storeDefine.PropPirceIcon[key];
		end
	end
	logError("StoreViewCtr:has no match PropPirceIcon");
end

function StoreViewCtr:GetAttachmentsData(attachments)
	if type(attachments) ~= "table" or table.length(attachments) == 0 then
		return;
	end
	local data = {};
	for _,v in ipairs(attachments) do
		local t = {};
		t.configId = v.ConfigId
		t.count = v.Count;
		t.icon = self.propCfg[v.ConfigId].Icon
		table.insert(data, t);
	end
	return data;
end

function StoreViewCtr:GetDataByCommodity(commodityType)
	local data = {};
	for _,v in pairs(self.wareCfg) do
		if commodityType == v.CommodityType then
			table.insert(data, v);
		end
	end

	return data;
end

function StoreViewCtr:OnPay(param)
	if param.itemType == self.storeDefine.StoreTab.Prop then

		if param.commodityType == self.storeDefine.CommodityType.Horn or
			param.commodityType == self.storeDefine.CommodityType.PropShop or
			param.commodityType == self.storeDefine.CommodityType.Battery then

			local curDiamond = CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi");
			if curDiamond >= param.price then
				--钻石兑换道具
				local data={}
                data.WareId=tostring(param.id)
                CC.Request("ReqBuyWithId",data)

			else
				--钻石不足,提示是否跳转购买钻石的页签
				local okFunc = function()
					self:OnChangeToDiamond();
				end
				CC.ViewManager.ShowMessageBox(self.language.diamondNotEnough, okFunc)
			end
		elseif param.commodityType == self.storeDefine.CommodityType.Fragment then
			local Fragment = CC.Player.Inst():GetSelfInfoByKey("EPC_PointCard_Fragment")
			if Fragment >= param.price then
				--碎片兑换筹码
				local data = {};
				data.ID = 17;
				data.Amount = param.price;
				data.GameId = CC.ViewManager.GetCurGameId() or 1
				data.GroupId = CC.ViewManager.GetCurGroupId() or 0
				CC.Request("ReqExchange",data);
			else
				CC.ViewManager.ShowTip(self.language.PropNotEnough)
			end
		elseif param.commodityType == self.storeDefine.CommodityType.GiftVoucher then
			local GiftVoucher = CC.Player.Inst():GetSelfInfoByKey("EPC_GiftVoucher")
			if GiftVoucher >= param.price then
				--礼票兑换筹码
				local data = {};
				data.ID = 16;
				data.Amount = param.price;
				data.GameId = CC.ViewManager.GetCurGameId() or 1
				data.GroupId = CC.ViewManager.GetCurGroupId() or 0
				CC.Request("ReqExchange",data);
			else
				CC.ViewManager.ShowTip(self.language.PropNotEnough)
			end
		else
		-- elseif param.commodityType == self.storeDefine.CommodityType.Chip or param.commodityType == self.storeDefine.CommodityType.RoomCard then
			local exchangeDefine = {
				[self.storeDefine.CommodityType.Chip] = CC.shared_enums_pb.EP_Diamond_Chip,
				[self.storeDefine.CommodityType.RoomCard] = CC.shared_enums_pb.EP_Diamond_RoomCard
			}
			local curDiamond = CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi");
			if curDiamond >= param.price then
				local data = {};
				data.Id = exchangeDefine[param.commodityType];
				data.Amount = param.price;
				data.GameId = CC.ViewManager.GetCurGameId() or 1
				data.GroupId = CC.ViewManager.GetCurGroupId() or 0
				CC.Request("Exchange",data)

			else
			    --首充礼包状态钻石不足,跳转购买钻石页签
				local okFunc = function()
					self:OnChangeToDiamond();
				end
				CC.ViewManager.ShowMessageBox(self.language.diamondNotEnough, okFunc)
			end
		end
	elseif param.itemType == self.storeDefine.StoreTab.Diamond or param.itemType == self.storeDefine.StoreTab.Bank then
		--购买筹码或砖石
		local data = {};
		data.wareId = tostring(param.id);
		data.subChannel = param.subChannel;
		data.price = param.price;
		data.playerId = CC.Player.Inst():GetSelfInfoByKey("Id");
		data.autoExchange = self:CheckAutoExchange();
		data.extraData = self.param.extraData;
		CC.PaymentManager.RequestPay(data);
		-- CC.ReportQManager.ActionEvent("$item_click",{item_id = data.wareId});
	end
end

--检查渠道充值是否需要二次提示
function StoreViewCtr:CheckTips(commodityType)
	for _,v in ipairs(self.bankOpenChannel) do
		if v.CommodityType == commodityType then
			return v
		end
	end
	for _,v in ipairs(self.chipOpenChannel) do
		if v.CommodityType == commodityType then
			return v
		end
	end
end

function StoreViewCtr:CheckAutoExchange()
	--直接给金币的不用自动兑换，否则客户端展示会有问题
	if self.storeTab == self.storeDefine.StoreTab.Bank then
		return false
	end
	if self.hideAutoExchange then
		return false;
	else
		return self.autoExchange == "true" and true;
	end
end

function StoreViewCtr:OnBuyWithIdRsp(err, result)

	if err == 0 then
		CC.ViewManager.ShowTip(self.language.paySuccess);
	else
		CC.ViewManager.ShowTip(self.language.payFailed);
	end
end

function StoreViewCtr:OnOpenExplainView()
	CC.ViewManager.Open("StoreExplainView", self.CreditLineList);
end

function StoreViewCtr:ReqPlayerStatus()
	CC.Request("ReqGetPlayerType")
	--超过5秒没有收到请求结果，弹窗提示
	self.view:DelayRun(5, function()
		if not self.isGetPlayerStatus then
			CC.ViewManager.ShowMessageBox(self.language.payReqLimit,function ()
				self:ReqPlayerStatus()
			end,function ()
				self.view:Destroy()
			end)
		end
	end)
end

function StoreViewCtr:OnGetPlayerStatus(err, data)
	CC.uu.Log(data,"OnGetPlayerStatus:")
	self.isGetPlayerStatus = true
	if err == 0 then
		self.view.playerStatus = data
		self:InitData();
	else
		CC.ViewManager.ShowMessageBox(self.language.payReqLimit,function ()
			self.view:Destroy()
		end,function ()
			self.view:Destroy()
		end)
	end
end

function StoreViewCtr:IsShowMol()
	if debugShowMol then return true end

	if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("ShowMol",false) then
		if not CC.ChannelMgr.GetSwitchByKey("bShowMol") then
			return false;
		end
		return true
	else
		return false
	end
end

function StoreViewCtr:ReqExtraCapcity()
	CC.Request("ReqLoadCreditLine")
end

function StoreViewCtr:OnLoadCreditLineRsp(err, result)

	if err == 0 then
		local data = {};
		data.extraCapcity = CC.uu.ChipFormat(result.Capacity/100);
		data.extraRemain = CC.uu.ChipFormat(result.Remain/100);
		self.CreditLineList = data
		self.view:RefreshUI(data);
	else
		CC.uu.Log("StoreViewCtr: Request.ReqLoadCreditLine failed");
	end
end

function StoreViewCtr:OnPurchaseSuccess()
	--支付成功后刷新信用额度
	self:ReqExtraCapcity();
	self.view.buyInStore = true

    --支付成功后流水达到要求开启第三方支付，并且有银行渠道的相关配置，并且页签未显示就打开银行页签
	if self:IsShowMol() and self:IsBankChanell() and not self.view.openbankTab then
		self.view:ShowBankTab(true)
	end
end

function StoreViewCtr:OnRefreshPropChange(props, source)

	if source ~= CC.shared_transfer_source_pb.TS_PropExchange and source ~= CC.shared_transfer_source_pb.TS_Shop and source ~= CC.shared_transfer_source_pb.TS_Prop_Exchange then
		return;
	end

	if source == CC.shared_transfer_source_pb.TS_Prop_Exchange then
		self.view:RefreshTips()
	end

	local tip = nil
	if props[1].ConfigId == CC.shared_enums_pb.EPC_Cat_Battery_1110 then

		tip = self.view.language.catBatteryTips

	elseif props[1].ConfigId == CC.shared_enums_pb.EPC_Common_Battery_1123 or
		props[1].ConfigId == CC.shared_enums_pb.EPC_ZhuQue_Battery or
		props[1].ConfigId == CC.shared_enums_pb.EPC_WhiteTiger_Battery or
		props[1].ConfigId == CC.shared_enums_pb.EPC_Cake_Battery then

		tip = self.view.language.commonBatteryTips
	end

	--CC.ViewManager.OpenRewardsView({items = props,tips = tip});
	--购买炮台后刷新数据
	self:RefreshOnPropChange(source,props)

	local isChangedDiamond = false;
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_ZuanShi then
			isChangedDiamond = true;
		end
	end
	if not isChangedDiamond then return end;

	self:InitManualExchange();
end

function StoreViewCtr:RefreshOnPropChange(source,props)
	if source == CC.shared_transfer_source_pb.TS_Shop then
		if self.storeTab == self.storeDefine.StoreTab.Prop then
			local isBattle = false
			for _,v in ipairs(self.batteryList) do
				if props[1].ConfigId == v then
					isBattle = true
					break
				end
			end
			if isBattle then
				self.forceRefresh = true
				for _,v in ipairs(self.view.propItems) do
					if v.transform then
						CC.uu.destroyObject(v.transform)
						v = nil
					end
				end
				for _,v in ipairs(self.view.propChannelBtns) do
					if v.transform then
						CC.uu.destroyObject(v.transform)
						v = nil
					end
				end
				self.view.propItems = {}
				self.view.propChannelBtns = {}
				self:OnChangeToProp()
				self.forceRefresh = false
			end
		end
	end
end

function StoreViewCtr:OnOpenRwardsViewByWareId(wareId)
	local wareData = self.wareCfg[wareId];
	if not wareData then return end;
	local rewards = {};
	if wareData.Rewards then
		for _,v in ipairs( wareData.Rewards) do
			table.insert(rewards, v);
		end
	end
	if type(wareData.Additional) == "table" then
		for _,v in ipairs( wareData.Additional) do
			table.insert(rewards, v);
		end
	end
	if not table.isEmpty(rewards) then
		CC.ViewManager.OpenRewardsView({items = rewards})
	end
end

function StoreViewCtr:InitManualExchange()
	self.exchangeDiamond = 0;
	self.exchangeChip = 0;
	self.totalDiamond = CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi");

	self:OnRefreshManualExchange();
end

function StoreViewCtr:OnAddExchangeCount()

	if self.exchangeDiamond >= self.totalDiamond then
		return;
	end

	self.exchangeDiamond = self.exchangeDiamond + 1;
	self.exchangeChip = self.exchangeChip + 1000;

	self:OnRefreshManualExchange();
end

function StoreViewCtr:OnMinusExchangeCount()

	if self.exchangeDiamond <= 0 then
		return;
	end

	self.exchangeDiamond = self.exchangeDiamond - 1;
	self.exchangeChip = self.exchangeChip - 1000;

	self:OnRefreshManualExchange();
end

function StoreViewCtr:OnSetExchangeSlider(value)

	self.exchangeDiamond = math.floor(value);
	self.exchangeChip = math.floor(value) * 1000;

	self:OnRefreshManualExchange();
end

function StoreViewCtr:OnRefreshManualExchange()

	local data = {};
	data.refreshManualExchange = true;
	data.diamondCount = self.exchangeDiamond;
	data.chipCount = self.exchangeChip;
	data.sliderValue = self.exchangeDiamond;
	data.maxValue = self.totalDiamond;
	self.view:RefreshUI(data);
end

function StoreViewCtr:OnSetAutoExchange(flag)
	self.autoExchange = tostring(flag);
	CC.LocalGameData.SetDataByKey("IsAutoExchangeChip",CC.Player.Inst():GetSelfInfoByKey("Id"),self.autoExchange)
end

function StoreViewCtr:OnExchangeChips()
	if self.exchangeDiamond <= 0 then
		return;
	end

	local okFunc = function()
		local data = {};
		data.Id = CC.shared_enums_pb.EP_Diamond_Chip;
		data.Amount = self.exchangeDiamond;
		data.GameId = CC.ViewManager.GetCurGameId() or 1
		data.GroupId = CC.ViewManager.GetCurGroupId() or 0
		CC.Request("Exchange",data)
	end

	local tips = string.format(self.language.exchangeTip, self.exchangeDiamond, self.exchangeChip);
	CC.ViewManager.ShowMessageBox(tips, okFunc);
end

function StoreViewCtr:OnExchangeRsp(err, result)

	if err == 0 then
		--兑换成功
		CC.ViewManager.ShowTip(self.language.paySuccess);
	else
		CC.ViewManager.ShowTip(self.language.payFailed);
	end
end

--检查是否有该渠道的配置
function StoreViewCtr:CheckChannel(channel)
	local allchannel = {self.chipOpenChannel,self.bankOpenChannel,self.webStoreCfg.Prop}
	for _,v in ipairs(allchannel) do
		for _,cfg in ipairs(v) do
			if cfg.CommodityType == channel then
				return true
			end
		end
	end

	return false
end

function StoreViewCtr:Destroy()

	self:UnRegisterEvent();

	CC.HallUtil.OnShowHallCamera(true);

	self.view = nil;
end

return StoreViewCtr;
