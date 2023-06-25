local CC = require("CC")

local WalletViewCtr = CC.class2("WalletViewCtr")

function WalletViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function WalletViewCtr:InitVar(view,param)
	self.param = param or {}
	self.view = view
	self.buyGiftWareId = nil
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    self.gameData = CC.DataMgrCenter.Inst():GetDataByKey("Game")
    self.storeDefine = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine")

	--需要屏蔽的支付方式
    self.hideChannel = {self.storeDefine.CommodityType.Bay, self.storeDefine.CommodityType.Bbl, self.storeDefine.CommodityType.Ktb,
				self.storeDefine.CommodityType.Scb, self.storeDefine.CommodityType.Kbank,self.storeDefine.CommodityType.tiki_truemoney,
				self.storeDefine.CommodityType.tiki_airpay,self.storeDefine.CommodityType.tiki_promptpay,self.storeDefine.CommodityType.Linepay}

	-- 20010屏蔽google支付方式			
	if CC.ChannelMgr.CheckOfficialWebChannel() then
		table.insert(self.hideChannel,self.storeDefine.CommodityType.GooglePay)
	end
    self.payWayData = {}
    --后台商店配置
    self.webStoreCfg = {}
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
		},
	}
	self.timeHideChannel = {self.storeDefine.CommodityType.Truewallet, self.storeDefine.CommodityType.Truemoney,
							self.storeDefine.CommodityType.Molpoints, self.storeDefine.CommodityType.Pay12call}
end

function WalletViewCtr:OnCreate()
	self:InitData()
	self:RegisterEvent()
end

function WalletViewCtr:InitData()
    self.webStoreCfg = self:GetStoreCfg()
    --log(CC.uu.Dump(self.webStoreCfg,"self.webStoreCfg",10))
end

function WalletViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnChangeSelfInfo, CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():register(self, self.PurchaseNotify, CC.Notifications.OnPurchaseNotify)
end

function WalletViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnPurchaseNotify)
end

function WalletViewCtr:OnHideChannel(commodityType)
    for _,v in ipairs(self.hideChannel) do
		if v == commodityType then
			return true
		end
	end
	--渠道维护期间屏蔽
	-- local time = CC.TimeMgr.GetTimeInfo()
	-- if not time then
	-- 	time = os.date("*t", os.time())
	-- end
	-- if 630045 ~= CC.Player.Inst():GetSelfInfoByKey("Id") and time.year == 2021 and time.month == 9 and time.day == 22 then
	-- 	if time.hour >= 4 and time.hour < 10 then
	-- 		for _,v in ipairs(self.timeHideChannel) do
	-- 			if v == commodityType then
	-- 				return true
	-- 			end
	-- 		end
	-- 	end
	-- end
	return false
end

function WalletViewCtr:ChangeExchangeWareId(wareId)
    if self.param and self.param.exchangeWareId then
        self.param.exchangeWareId = wareId
    end
end

function WalletViewCtr:SetBuyExchangeWareId(wareId)
	self.buyGiftWareId = tostring(wareId)
end

function WalletViewCtr:PurchaseNotify(param)
	if param.WareId then
		if param.WareId ~= self.param.exchangeWareId then
			local itemCfg = self.wareCfg[tostring(param.WareId)];
			local commodityType = itemCfg.CommodityType
			if self.view.curSelectCommodityType and self.view.curSelectCommodityType == commodityType then
				CC.LocalGameData.SetLocalStateToKey("CommodityType", commodityType)
				self.view.localCommodityType = commodityType
			end
			self.view:HideBottomPanel()
		elseif self.param.succCb then
			self.param.succCb()
		end
	end
end
--支付方式渠道
function WalletViewCtr:PayWayChannelData(isRight)
    if not self.payWayData.Data then
        self.payWayData.Data = self:GetPayChannelData()
    end
	local data
    if isRight and not self.payWayData.RightSet then
        --未设置过修改支付渠道按钮
        self.payWayData.RightSet = true
        data = self.payWayData.Data
    elseif not isRight and not self.payWayData.BottomSet then
        self.payWayData.BottomSet = true
        data = self.payWayData.Data
    end
    self.view:PayWayChannel(isRight, data)
end

function WalletViewCtr:OnChangeSelfInfo(props)
	local isNeedRefresh = false;
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_ZuanShi then
			isNeedRefresh = true;
		end
	end
	if not isNeedRefresh then return end;
	self.view:SetDiamond(CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi"))
end

function WalletViewCtr:GetStoreCfg()
	local storeCfg = self.gameData.GetStoreCfg();

	if table.isEmpty(storeCfg) then
		storeCfg = self.orgStoreCfg;
		--ios平台需要切换苹果计费点
		if CC.Platform.isIOS then
			storeCfg.Chip.Other = {
				CommodityType = 41,
				WareIds = {'com.huoys.royalcasino.productios1','com.huoys.royalcasino.productios2','com.huoys.royalcasino.productios3','com.huoys.royalcasino.productios4',
					'com.huoys.royalcasino.productios5','com.huoys.royalcasino.productios6','com.huoys.royalcasino.productios7'},
                Index = 1
            }
		elseif CC.ChannelMgr.CheckOppoChannel() then
			storeCfg.Chip.Other = {
				CommodityType = 1001,
				WareIds = {'oppo10001','oppo10002','oppo10003','oppo10004','oppo10005','oppo10006','oppo10007','oppo10008','oppo10009','oppo10010',
				'oppo10011','oppo10012','oppo10013','oppo10014','oppo10015','oppo10016','oppo10017','oppo10018','oppo10019','oppo10020',},
                Index = 1
            }
		end
	end

	return storeCfg;
end

function WalletViewCtr:GetChannelItems(commodityType)
    --找到后台对应的渠道配置
	local channelData;
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
    if not channelData then
        return
	end
	--组装需要使用的商品数据
	local data = {};
	for _,id in ipairs(channelData.WareIds) do
		local itemCfg = self.wareCfg[tostring(id)];
		local itemData = self:GetCommodityData(itemCfg)
		table.insert(data, itemData);
	end
	return data;
end

function WalletViewCtr:GetCommodityData(param)
	local data = {};
	data.id = param.Id;
	data.icon = param.Icon;
	data.diamondCount = param.Rewards[1].Count;
	data.chipCount = param.Chips;
	data.commodityType = param.CommodityType;
    data.subChannel = param.SubChannel;
    data.itemType = self.storeDefine.StoreTab.Prop;
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

--支付方式渠道数据
function WalletViewCtr:GetPayChannelData()
	local data = {};
	if self:IsShowMol() then
		for _, v in ipairs(self.webStoreCfg.Chip.Mol) do
			if v.IsOpen then
				local tb = {};
				tb.commodityType = v.CommodityType;
				tb.icon = self:GetPayChannelIcon(v.CommodityType);
				tb.btnType = self.storeDefine.StoreTab.Diamond;
				tb.Index = v.Index or 0
				table.insert(data, tb);
			end
		end
	end

	for _, v in ipairs(self.webStoreCfg.Chip.Other) do
		if v.IsOpen then
			local tb = {};
			tb.commodityType = v.CommodityType;
			tb.icon = self:GetPayChannelIcon(v.CommodityType);
			tb.btnType = self.storeDefine.StoreTab.Diamond;
			--google渠道需要显示提示
			if tb.commodityType == self.storeDefine.CommodityType.GooglePay or tb.commodityType == self.storeDefine.CommodityType.ApplePay then
				tb.showExtraTips = true;
				--请求google和ios额度
				self:ReqExtraCapcity();
			end
			tb.Index = v.Index or 0
			table.insert(data, tb);
		end
	end
	table.sort(data, function(a,b) return a.Index < b.Index end )
	return data;
end

--得到渠道icon
function WalletViewCtr:GetPayChannelIcon(commodityType)
	for key,v in pairs(self.storeDefine.CommodityType) do
		if commodityType == v then
			return self.storeDefine.ChipChannelIcon[key]
		end
	end
end

function WalletViewCtr:ReqExtraCapcity()
	 CC.Request("ReqLoadCreditLine");
end

--得到礼包数据
function WalletViewCtr:GetGiftToWareId()
	if self.param and self.param.exchangeWareId then
		return self.wareCfg[tostring(self.param.exchangeWareId)]
	end
	if self.buyGiftWareId then
		return self.wareCfg[tostring(self.buyGiftWareId)]
	end
end

function WalletViewCtr:IsShowMol()
	if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("ShowMol",false) then
		if not CC.ChannelMgr.GetSwitchByKey("bShowMol") then
			return false;
		end
		return true
	else
		return false
	end
end

function WalletViewCtr:OnPay(param)
	if self.param and self.param.exchangeWareId then
		self.buyGiftWareId = tostring(self.param.exchangeWareId)
	end
	if not self.buyGiftWareId then return end
	
	CC.HallUtil.GetRealAuthStates(param,function ()
			local data = {};
			data.wareId = tostring(param.id);
			data.subChannel = param.subChannel;
			data.price = param.price;
			data.playerId = CC.Player.Inst():GetSelfInfoByKey("Id");
			data.extraData = param.extraData;
			data.ExchangeWareId = self.buyGiftWareId
			if self.param and self.param.notBuyGift then
				data.ExchangeWareId = nil
			end
			if param.callback then
				data.callback = param.callback
			end
			CC.PaymentManager.RequestPay(data);
			log(CC.uu.Dump(data,"data",10))
		end)
end

function WalletViewCtr:Destroy()
	self:unRegisterEvent()
end

return WalletViewCtr