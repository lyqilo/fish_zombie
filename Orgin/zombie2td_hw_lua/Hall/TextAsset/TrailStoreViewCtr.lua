
local CC = require("CC")

local TrailStoreViewCtr = CC.class2("TrailStoreViewCtr")

local debugShowMol = false;

-- local testData = {
-- 	MolOpenChips = 0,
-- 	MolHide = 0,
-- 	Chip = {
-- 		Other = {
-- 			{CommodityType = 31, WareIds = {'com.huoys.royalcasino.product1','com.huoys.royalcasino.product2','com.huoys.royalcasino.product3',
-- 				'com.huoys.royalcasino.product4','com.huoys.royalcasino.product5','com.huoys.royalcasino.product6','com.huoys.royalcasino.product7'}},
-- 		},
-- 		Mol = {
-- 			{CommodityType = 21, WareIds = {91001,91002,91003,91004,91005}},
-- 			{CommodityType = 22, WareIds = {92001,92002,92003,92004,92005}},
-- 			{CommodityType = 23, WareIds = {93001,93002,93003,93004,93005,93006,93007}},
-- 			{CommodityType = 24, WareIds = {95003,95004,95005,95006,95007,95008,95009,95010,95011,95012,95013,95014,95015,95016}},
-- 			{CommodityType = 25, WareIds = {96003,96004,96005,96006,96007,96008,96009,96010,96011,96012,96013,96014,96015,96016}},
-- 			{CommodityType = 26, WareIds = {97003,97004,97005,97006,97007,97008,97009,97010,97011,97012,97013,97014,97015,97016}},
-- 			{CommodityType = 27, WareIds = {94003,94004,94005,94006,94007,94008,94009,94010,94011}},
-- 		}
-- 	},
-- 	Prop = {
-- 		{CommodityType = 12, WareIds = {20001,20002,20003,20004,20005}},
-- 	}
-- }

--[[
@param
channelTab  --指定渠道页签
extraData   --支付传入的额外数据
]]
function TrailStoreViewCtr:ctor(view, param)

	CC.ViewManager.HideChatPanel();

	self:InitVar(view, param);
end

function TrailStoreViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function TrailStoreViewCtr:InitVar(view, param)

	self.param = param or {};

	self.view = view;
	--当前商店页签
	self.storeTab = nil;
	--道具商品相关数据
	self.propData = {};
	--筹码商品相关数据
	self.chipData = {};
	--后台商店配置
	self.webStoreCfg = {};

	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.storeDefine = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine");

	self.gameData = CC.DataMgrCenter.Inst():GetDataByKey("Game");

	self.language = CC.LanguageManager.GetLanguage("L_StoreView");

	self.hallCamera = GameObject.Find("HallCamera/GaussCamera"):GetComponent("Camera");

	--选择兑换的钻石数额
	self.exchangeDiamond = 0;
	--能够兑换的筹码数额
	self.exchangeChip = 0;
	--可兑换的钻石总额
	self.totalDiamond = 0;
	--自动兑换标记
	self.autoExchange = false;

	--给一份默认的计费点配置防止web配置拉取不到
	self.orgStoreCfg = {
	    MolOpenChips = 0,
	    MolHide = 1,
	    Chip = {
		    Other = {
		        {CommodityType = 31, WareIds = {'com.huoys.royalcasino.productios1','com.huoys.royalcasino.productios2','com.huoys.royalcasino.productios3','com.huoys.royalcasino.productios4',
					'com.huoys.royalcasino.productios5','com.huoys.royalcasino.productios6','com.huoys.royalcasino.productios7','com.huoys.royalcasino.productios10',
					'com.huoys.royalcasino.productios11','com.huoys.royalcasino.productios12','com.huoys.royalcasino.productios13','com.huoys.royalcasino.shopios1000',
					'com.huoys.royalcasino.shopios1500','com.huoys.royalcasino.shopios3000'},
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
	    Prop = {
	        {CommodityType = 13, WareIds = {21001,21002,21003,21004,21005,21006,21007,21008,21009,21010}},
	        -- {CommodityType = 14, WareIds = {22001,22002,22003,22004,22005}},
	        -- {CommodityType = 12, WareIds = {20001,20002,20003,20004,20005}},
	    }
	}
end

function TrailStoreViewCtr:InitData()

	self.webStoreCfg = self.orgStoreCfg;

	self.propData.curCommodityType = self.storeDefine.CommodityType.Chip;

	self.chipData.curCommodityType = self:GetOrgChannel();

	if CC.ChannelMgr.GetIOSPrivateStatus() then
		self.chipData.curCommodityType = self.storeDefine.CommodityType.Pay12Call;
	end

	self.autoExchange = Util.GetFromPlayerPrefs("autoExchange");
	if self.autoExchange == "" then
		self:OnSetAutoExchange(true);
	end

	local data = {};
	data.setOrgTab = self.storeDefine.StoreTab.Diamond;
	--判断传入的渠道页签是否为道具页签
	for _,v in ipairs(self.webStoreCfg.Prop) do
		if v.CommodityType == self.param.channelTab then
			data.setOrgTab = self.storeDefine.StoreTab.Prop;
			break;
		end
	end

	data.showBackIcon = not CC.ViewManager.IsHallScene();
	data.autoExchange = self.autoExchange == "true" and true;
	self.view:InitContent(data);

	if data.setOrgTab == self.storeDefine.StoreTab.Diamond then
		self:OnChangeToDiamond();
	else
		self:OnChangeToProp();
	end

	--切换到指定渠道页签
	if self.param.channelTab then
		self:OnChangeToPropByChannel(self.param.channelTab);
	end

	self:OnShowHallCamera(false);
end

function TrailStoreViewCtr:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);

	CC.HallNotificationCenter.inst():register(self,self.OnRefreshPropChange,CC.Notifications.changeSelfInfo);

	CC.HallNotificationCenter.inst():register(self,self.OnExchangeRsp,CC.Notifications.NW_Exchange);

	CC.HallNotificationCenter.inst():register(self,self.OnLoadCreditLineRsp,CC.Notifications.NW_ReqLoadCreditLine);

	CC.HallNotificationCenter.inst():register(self,self.OnBuyWithIdRsp,CC.Notifications.NW_ReqBuyWithId);
end

function TrailStoreViewCtr:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.changeSelfInfo);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_Exchange);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqLoadCreditLine);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqBuyWithId);
end

function TrailStoreViewCtr:GetStoreCfg()
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

function TrailStoreViewCtr:GetOrgChannel()

	local data = {};

	--玩家流水超过这个配置的值就显示Mol支付
	if self:IsShowMol() then
		for _, v in ipairs(self.webStoreCfg.Chip.Mol) do
			table.insert(data, v.CommodityType);
		end
	end

	for _, v in ipairs(self.webStoreCfg.Chip.Other) do
		local index = (v.Index and v.Index > 0) and v.Index or 1;
		index = index > #data and #data+1 or index;
		table.insert(data, index, v.CommodityType);
	end

	return data[1];
end

function TrailStoreViewCtr:OnShowHallCamera(flag)
	if not CC.ViewManager.IsHallScene() then
		return;
	end
	self.hallCamera:SetActive(flag);
end

function TrailStoreViewCtr:OnChangeChannel(param)

	local dataObj;

	if param.btnType == self.storeDefine.StoreTab.Diamond then
		dataObj = self.chipData;
	elseif param.btnType == self.storeDefine.StoreTab.Prop then
		dataObj = self.propData;
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

function TrailStoreViewCtr:OnChangeToDiamond()

	self.storeTab = self.storeDefine.StoreTab.Diamond;

	local data = self:GetChangeTabData();
	data.setOrgTab = self.storeDefine.StoreTab.Diamond;

	self.view:RefreshUI(data);
end

function TrailStoreViewCtr:OnChangeToProp()

	self.storeTab = self.storeDefine.StoreTab.Prop;

	local data = self:GetChangeTabData();
	data.setOrgTab = self.storeDefine.StoreTab.Prop;

	self.view:RefreshUI(data);
end

function TrailStoreViewCtr:OnChangeToDiamondByChannel(channel)

	local data = {};
	data.btnType = self.storeDefine.StoreTab.Chip;
	data.commodityType = channel;
	data.changeChannelTab = channel;
	self:OnChangeChannel(data);
end

function TrailStoreViewCtr:OnChangeToPropByChannel(channel)

	local data = {};
	data.btnType = self.storeDefine.StoreTab.Prop;
	data.commodityType = channel;
	data.changeChannelTab = channel;
	self:OnChangeChannel(data);
end

function TrailStoreViewCtr:GetChangeTabData()

	local dataObj;
	if self.storeTab == self.storeDefine.StoreTab.Diamond then
		dataObj = self.chipData;
	elseif self.storeTab == self.storeDefine.StoreTab.Prop then
		dataObj = self.propData;
	end
	local data = {};
	if not dataObj.items then
		dataObj.items = self:GetChannelItems(dataObj.curCommodityType);
		dataObj.btns = self:GetChannelBtns();
		data.items = dataObj.items;
		data.btns = dataObj.btns;
	end

	data.showTabType = self.storeTab;
	data.curCommodityType = dataObj.curCommodityType;

	return data;
end

function TrailStoreViewCtr:GetChannelBtns()

	if self.storeTab == self.storeDefine.StoreTab.Diamond then
		return self:GetChipChannelData();
	elseif self.storeTab == self.storeDefine.StoreTab.Prop then
		return self:GetPropChannelData();
	end
end

function TrailStoreViewCtr:GetChipChannelData()

	local data = {};

	--玩家流水超过这个配置的值就显示Mol支付
	if self:IsShowMol() then
		for _, v in ipairs(self.webStoreCfg.Chip.Mol) do
			local tb = {};
			tb.commodityType = v.CommodityType;
			tb.icon = self:GetChipChannelIcon(v.CommodityType);
			tb.btnType = self.storeDefine.StoreTab.Diamond;
			table.insert(data, tb);
		end
	end

	for _, v in ipairs(self.webStoreCfg.Chip.Other) do
		local tb = {};
		tb.commodityType = v.CommodityType;
		tb.icon = self:GetChipChannelIcon(v.CommodityType);
		tb.btnType = self.storeDefine.StoreTab.Diamond;
		--google渠道需要显示提示
		if tb.commodityType == self.storeDefine.CommodityType.GooglePay or tb.commodityType == self.storeDefine.CommodityType.ApplePay then
			tb.showExtraTips = true;
			--请求google和ios额度
			self:ReqExtraCapcity();
		end
		local index = (v.Index and v.Index > 0) and v.Index or 1;
		index = index > #data and #data+1 or index;
		table.insert(data, index, tb);
	end

	return data;
end

function TrailStoreViewCtr:GetPropChannelData()

	local data = {};
	for _, v in ipairs(self.webStoreCfg.Prop) do
		local tb = {};
		tb.commodityType = v.CommodityType;
		tb.iconText = self:GetPropChannelText(v.CommodityType);
		tb.btnType = self.storeDefine.StoreTab.Prop;
		if v.CommodityType == self.storeDefine.CommodityType.RoomCard then
			tb.showRoomCardTips = true;
		end
		table.insert(data, tb);
	end
	return data;
end

function TrailStoreViewCtr:GetChipChannelIcon(commodityType)
	for key,v in pairs(self.storeDefine.CommodityType) do
		if commodityType == v then
			return self.storeDefine.ChipChannelIcon[key];
		end
	end
	logError("TrailStoreViewCtr:has no match chipChannelIcon");
end

function TrailStoreViewCtr:GetPropChannelText(commodityType)
	local key = string.format("store_%s_Name", commodityType);
	return CC.ConfigCenter.Inst():getDescByKey(key) or "";
end

function TrailStoreViewCtr:GetChannelItems(commodityType)

	--找到后台对应的渠道配置
	local channelData;
	if self.storeTab == self.storeDefine.StoreTab.Diamond then
		for _,v in ipairs(self.webStoreCfg.Chip.Other) do
			if v.CommodityType == commodityType then
				channelData = v;
			end
		end
		if self:IsShowMol() then
			for _,v in ipairs(self.webStoreCfg.Chip.Mol) do
				if v.CommodityType == commodityType then
					channelData = v;
				end
			end
		end
	elseif self.storeTab == self.storeDefine.StoreTab.Prop then
		for _,v in ipairs(self.webStoreCfg.Prop) do
			if v.CommodityType == commodityType then
				channelData = v;
			end
		end
	end

	if not channelData then
		logError("TrailStoreViewCtr: not find channel Data");
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
		end
		table.insert(data, itemData);
	end
	return data;
end

function TrailStoreViewCtr:GetPropData(param)
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
	return data;
end

function TrailStoreViewCtr:GetChipData(param)
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

function TrailStoreViewCtr:GetPropPriceIcon(commodityType)
	for key,v in pairs(self.storeDefine.CommodityType) do
		if commodityType == v then
			return self.storeDefine.PropPirceIcon[key];
		end
	end
	logError("TrailStoreViewCtr:has no match PropPirceIcon");
end

function TrailStoreViewCtr:GetAttachmentsData(attachments)
	if type(attachments) ~= "table" or table.length(attachments) == 0 then
		return;
	end
	local data = {};
	for _,v in ipairs(attachments) do
		local t = {};
		t.count = v.Count;
		t.icon = self.propCfg[v.ConfigId].Icon
		table.insert(data, t);
	end
	return data;
end

function TrailStoreViewCtr:GetDataByCommodity(commodityType)
	local data = {};
	for _,v in pairs(self.wareCfg) do
		if commodityType == v.CommodityType then
			table.insert(data, v);
		end
	end

	return data;
end

function TrailStoreViewCtr:OnPay(param)

	if param.itemType == self.storeDefine.StoreTab.Prop then

		if param.commodityType == self.storeDefine.CommodityType.Horn then
			local curDiamond = CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi");
			if curDiamond >= param.price then
				--筹码兑换道具
				local data={}
                data.WareId=tostring(param.id)
                CC.Request("ReqBuyWithId",data)

			else
				--筹码不足,提示是否跳转兑换筹码的页签
				local okFunc = function()
					self:OnChangeToDiamond();
				end
				CC.ViewManager.ShowMessageBox(self.language.diamondNotEnough, okFunc)
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
	elseif param.itemType == self.storeDefine.StoreTab.Diamond then
		--购买筹码
		local data = {};
		data.wareId = tostring(param.id);
		data.subChannel = param.subChannel;
		data.price = param.price;
		data.playerId = CC.Player.Inst():GetSelfInfoByKey("Id");
		data.autoExchange = self.autoExchange == "true" and true;
		data.extraData = self.param.extraData;
		CC.PaymentManager.RequestPay(data);
	end
end

function TrailStoreViewCtr:OnBuyWithIdRsp(err, result)

	if err == 0 then
		CC.ViewManager.ShowTip(self.language.paySuccess);
	else
		CC.ViewManager.ShowTip(self.language.payFailed);
	end
end

function TrailStoreViewCtr:OnOpenExplainView()
	CC.ViewManager.Open("StoreExplainView");
end

function TrailStoreViewCtr:IsShowMol()

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

function TrailStoreViewCtr:ReqExtraCapcity()
    CC.Request("ReqLoadCreditLine");
end

function TrailStoreViewCtr:OnLoadCreditLineRsp(err, result)

	if err == 0 then
		local data = {};
		data.extraCapcity = CC.uu.ChipFormat(result.Capacity/100);
		data.extraRemain = CC.uu.ChipFormat(result.Remain/100);
		self.view:RefreshUI(data);
	else
		CC.uu.Log("TrailStoreViewCtr: Request.ReqLoadCreditLine failed");
	end
end

function TrailStoreViewCtr:OnPurchaseSuccess(param)
	--支付成功后刷新信用额度
	self:ReqExtraCapcity();
end

function TrailStoreViewCtr:OnRefreshPropChange(props, source)

	if source ~= CC.shared_transfer_source_pb.TS_PropExchange and source ~= CC.shared_transfer_source_pb.TS_Shop then
		return;
	end

	local isChangedDiamond = false;
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_ZuanShi then
			isChangedDiamond = true;
		end
	end
	if not isChangedDiamond then return end;

	self:InitManualExchange();
end

function TrailStoreViewCtr:OnOpenRwardsViewByWareId(wareId)
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
		CC.ViewManager.OpenEx("RewardsView", rewards, "CommonGet");
	end
end

function TrailStoreViewCtr:InitManualExchange()
	self.exchangeDiamond = 0;
	self.exchangeChip = 0;
	self.totalDiamond = CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi");

	self:OnRefreshManualExchange();
end

function TrailStoreViewCtr:OnAddExchangeCount()

	if self.exchangeDiamond >= self.totalDiamond then
		return;
	end

	self.exchangeDiamond = self.exchangeDiamond + 1;
	self.exchangeChip = self.exchangeChip + 1000;

	self:OnRefreshManualExchange();
end

function TrailStoreViewCtr:OnMinusExchangeCount()

	if self.exchangeDiamond <= 0 then
		return;
	end

	self.exchangeDiamond = self.exchangeDiamond - 1;
	self.exchangeChip = self.exchangeChip - 1000;

	self:OnRefreshManualExchange();
end

function TrailStoreViewCtr:OnSetExchangeSlider(value)

	self.exchangeDiamond = math.floor(value);
	self.exchangeChip = math.floor(value) * 1000;

	self:OnRefreshManualExchange();
end

function TrailStoreViewCtr:OnRefreshManualExchange()

	local data = {};
	data.refreshManualExchange = true;
	data.diamondCount = self.exchangeDiamond;
	data.chipCount = self.exchangeChip;
	data.sliderValue = self.exchangeDiamond;
	data.maxValue = self.totalDiamond;
	self.view:RefreshUI(data);
end

function TrailStoreViewCtr:OnSetAutoExchange(flag)
	self.autoExchange = tostring(flag);
	Util.SaveToPlayerPrefs("autoExchange", self.autoExchange);
end

function TrailStoreViewCtr:OnExchangeChips()
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

function TrailStoreViewCtr:OnExchangeRsp(err, result)

	if err == 0 then
		--兑换成功
		CC.ViewManager.ShowTip(self.language.paySuccess);
	else
		CC.ViewManager.ShowTip(self.language.payFailed);
	end
end

function TrailStoreViewCtr:Destroy()

	self:UnRegisterEvent();

	self:OnShowHallCamera(true);

	self.view = nil;
end

return TrailStoreViewCtr;
