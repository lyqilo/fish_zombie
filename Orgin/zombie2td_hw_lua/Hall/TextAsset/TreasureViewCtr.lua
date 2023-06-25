---------------------------------
-- region TreasureViewCtr.lua	-
-- Date: 2019.11.11				-
-- Desc: 一元夺宝				-
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local TreasureViewCtr = CC.class2("TreasureViewCtr")

function TreasureViewCtr:ctor(view, param)
	self:InitVar(view, param)
end

function TreasureViewCtr:InitVar(view,param)
	self.param = param or {}
	self.view = view
	--新需求中，兑换也需要有刷新列表的操作
	self.chipCount = 0
	self.integralCount = 0
	self.redEnvelopeCount = 0

	self.language = self.view:GetLanguage();

	self.mailDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Mail")

	self.realDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData")

	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("PhysicalShop")

	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")

	self.propDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
end

function TreasureViewCtr:OnCreate()
	self:RegisterEvent()
	--请求夺宝列表
	CC.Request("Req_PrizeList")
	CC.Request("Req_LatelyPlayerLuckyRecord")
	self:ReqGetGoodsList()
	self:ReqRecordRecent()
	self:ReqRecordBuy()
	self:RefreshMailRedPoint()
	self:ReqTrade()
	CC.HallUtil.OnShowHallCamera(false);
end

function TreasureViewCtr:ReqGetGoodsList(data)
	-- CC.uu.Log(data,"ReqGetGoodsList,data：")
	if CC.uu.isNumber(data) then
		logError("err:"..data)
		if data == 601 then
			--实物商城预警
			CC.ViewManager.Open("WarningTipView")
			return;
		end
	end 

	local typeNum = self.view.curShopType or CC.proto.client_shop_pb.LiQuanShop
    CC.Request("ReqGetGoodsList",{Type = typeNum})
end

function TreasureViewCtr:SetReqGoodsInfoState(isOn)
	local typeNum = self.view.curShopType or CC.proto.client_shop_pb.LiQuanShop
	if isOn then
		self.view:StartTimer("ReqGoodsInfo", 5, function()
				CC.Request("ReqGetGoodsList",{Type = typeNum})
			end,-1)
	else
		self.view:StopTimer("ReqGoodsInfo")
	end

end

function TreasureViewCtr:InitIntegralGoods()
	local data = self.realDataMgr.GetIntegralList()
	local playerLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	local param = {}
	for k,v in pairs(data) do
		local goods = {}
		goods.info = self.wareCfg[v.Id]
		goods.num = v.Count > 0 and v.Count or 0
		goods.path = self.wareCfg[v.Id].Icon
		goods.consume = v.Consume
		goods.wePayChannel = v.WePayChannel
		goods.IsSupplement = v.IsSupplement
		if playerLevel >= goods.info.LimitShow then
		    if self.wareCfg[v.Id].LockSwitch == 0 then
			    table.insert(param,goods)
		    else
			    if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel") then
				    table.insert(param,goods)
			    end
		    end
	    end
	end
	self.view:InitIntegralGoods(param, true)
end

function TreasureViewCtr:InitChipGoods()
	local data = self.realDataMgr.GetChipList()
	local playerLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	local param = {}
	for k,v in pairs(data) do
		local goods = {}
		goods.info = self.wareCfg[v.Id]
		goods.num = v.Count > 0 and v.Count or 0
		goods.path = self.wareCfg[v.Id].Icon
		goods.consume = v.Consume
		goods.wePayChannel = v.WePayChannel
		goods.IsSupplement = v.IsSupplement
		if playerLevel >= goods.info.LimitShow then
		    if self.wareCfg[v.Id].LockSwitch == 0 then
			    table.insert(param,goods)
		    else
			    if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("ChipExchange") then
				    table.insert(param,goods)
			    end
		    end
	    end
	end
	self.view:InitChipGoods(param, true)
end

function TreasureViewCtr:InitRedEnvelopeGoods()
	local subPage = self.view.redEnvelopePage or 1--红包商城子页签1为捕获，2为棋牌
	local data = self.realDataMgr.GetRedEnvelopeList()
	local playerLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	local param = {}
	for k,v in pairs(data) do
		--商品类型：红包商城（0为通用，1为捕获，2为棋牌）
		if v.GoodsType == 0 or v.GoodsType == subPage then
			local goods = {}
			goods.info = self.wareCfg[v.Id]
			goods.num = v.Count > 0 and v.Count or 0
			goods.path = self.wareCfg[v.Id].Icon
			goods.consume = v.Consume
			goods.wePayChannel = v.WePayChannel
			goods.IsSupplement = v.IsSupplement
			if playerLevel >= goods.info.LimitShow then
				if self.wareCfg[v.Id].LockSwitch == 0 then
					table.insert(param,goods)
				else
					if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel") then
						table.insert(param,goods)
					end
				end
			end
		end
	end
	self.view:InitRedEnvelopeGoods(param, true)
end

function TreasureViewCtr:ReqRecordRecent()
	CC.Request("ReqRecordRecent")
end

function TreasureViewCtr:InfoItem(tran,dataIndex,cellIndex)
	local index = dataIndex + 1
	local param = {}
	if self.view.curShopType == 0 then
		local info = self.realDataMgr.GetTreasureRollInfoByIndex(index)
		param.Time = CC.uu.TimeOut3(info.OpenTime)
		if info.PropId == CC.shared_enums_pb.EPC_ChouMa then
			param.Goods = self.propDataMgr.GetLanguageDesc(info.PropId,info.PropCount)
		else
			param.Goods = self.propDataMgr.GetLanguageDesc(info.PropId)
		end
		param.Name = info.NickName
	else
		local info = self.realDataMgr.GetAllBuyInfoByIndex(index)
		param.Time = CC.uu.TimeOut3(info.TimeStamp)
		param.Name = info.Name
		param.Goods = CC.ConfigCenter.Inst():getDescByKey("ware_"..info.GoodsID)
	end
	self.view:CreateInfoItem(tran,param)
end

function TreasureViewCtr:InitRollPanel()
	local count = 0
	if self.view.curShopType == 0 then
		count = self.realDataMgr.GetTreasureRollInfoCount()
	else
		count = self.realDataMgr.GetAllBuyInfoCount()
	end
	self.view:InitRollPanel(count)
end

function TreasureViewCtr:ReqRecordBuy()
	CC.Request("ReqRecordBuy")
end

function TreasureViewCtr:SetGoodsInfo(err,data)
	if err == 0 then
		if self.view.curShopType == CC.proto.client_shop_pb.ChouMaShop then
			self.realDataMgr.SetChipList(data)
		elseif self.view.curShopType == CC.proto.client_shop_pb.RedEnvelopeShop then
			self.realDataMgr.SetRedEnvelopeList(data)
		else
			self.realDataMgr.SetIntegralList(data)
		end
		self:RefreshGoodsInfo()
	else
		if self.chipCount == 0 and self.integralCount == 0 and self.redEnvelopeCount == 0 then
			self.view:InitGoodsFail()
		end
	end
end

function TreasureViewCtr:RefreshGoodsInfo()
	local IntegralList = self.realDataMgr.GetIntegralList()
	if self.integralCount ~= #IntegralList then
		self.integralCount = #IntegralList
		self:InitIntegralGoods()
	else
		self.view:RefreshCount(IntegralList)
	end

	local ChipList = self.realDataMgr.GetChipList()
	if self.chipCount ~= #ChipList then
		self.chipCount = #ChipList
		self:InitChipGoods()
	else
		self.view:RefreshCount(ChipList)
	end
	
	local RedEnvelopeList = self.realDataMgr.GetRedEnvelopeList()
	if self.redEnvelopeCount ~= #RedEnvelopeList or self.view.refreshGoods then
		self.view.refreshGoods = false
		self.redEnvelopeCount = #RedEnvelopeList
		self:InitRedEnvelopeGoods()
	else
		self.view:RefreshCount(RedEnvelopeList)
	end
end

function TreasureViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.PrizeListResp,CC.Notifications.NW_Req_PrizeList)
	CC.HallNotificationCenter.inst():register(self,self.RefreshTreasureList,CC.Notifications.SetTreasureInfoFinish)
	CC.HallNotificationCenter.inst():register(self,self.InitBuyGoodsInfo,CC.Notifications.NW_ReqRecordRecent)
	CC.HallNotificationCenter.inst():register(self,self.InitSelfBuyGoodsInfo,CC.Notifications.NW_ReqRecordBuy)
	CC.HallNotificationCenter.inst():register(self,self.SetGoodsInfo,CC.Notifications.NW_ReqGetGoodsList)
	-- CC.HallNotificationCenter.inst():register(self,self.RefreshGoodsInfo,CC.Notifications.RefreshPhysicalGoodsInfo)
	CC.HallNotificationCenter.inst():register(self,self.OpenPrizeResp,CC.Notifications.OnPushTreasureOpenPrize)
	CC.HallNotificationCenter.inst():register(self,self.LatelyPlayerLuckyRecordResp,CC.Notifications.NW_Req_LatelyPlayerLuckyRecord)
	CC.HallNotificationCenter.inst():register(self,self.OnNoviceReward,CC.Notifications.NoviceReward)
	CC.HallNotificationCenter.inst():register(self,self.RefreshSwitchState, CC.Notifications.HallFunctionUpdate)
	CC.HallNotificationCenter.inst():register(self,self.RefreshMailRedPoint,CC.Notifications.MailAdd)
	CC.HallNotificationCenter.inst():register(self,self.RefreshMailRedPoint,CC.Notifications.MailOpen)
	CC.HallNotificationCenter.inst():register(self,self.InitRollPanel,CC.Notifications.RefreshRecordRecent)
	CC.HallNotificationCenter.inst():register(self,self.RefreshTrade,CC.Notifications.NW_ReqTradeInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnPurchaseNotify,CC.Notifications.OnPurchaseNotify)
	CC.HallNotificationCenter.inst():register(self,self.ReqGetGoodsList,CC.Notifications.NW_ReqGoodsBuy)
	CC.HallNotificationCenter.inst():register(self,self.OnPropChange,CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnSwitchTableGroup,CC.Notifications.OnTreasureSwitch)
end

function TreasureViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function TreasureViewCtr:OnPurchaseNotify()
	self:ReqTrade()
end

function TreasureViewCtr:RefreshMailRedPoint()
	if self.mailDataMgr.GetUnOpenMailCount() > 0 then
		self.view:RefreshMailRedPoint(true)
	else
		self.view:RefreshMailRedPoint(false)
	end
end

function TreasureViewCtr:RefreshSwitchState()
	self.view:RefreshSwitchState()
end

function TreasureViewCtr:OnNoviceReward()
	self.view:HideVIPBtn()
end

function TreasureViewCtr:InitBuyGoodsInfo(err,data)
	if err == 0 then
		self.realDataMgr.SetAllBuyGoodsInfo(data)
	end
end

function TreasureViewCtr:InitSelfBuyGoodsInfo(err,data)
	if err == 0 then
		self.realDataMgr.SetSelfBuyInfo(data)
	end
end

function TreasureViewCtr:SelfInfoItem(tran,dataIndex,cellIndex)
	local index = dataIndex + 1
	local info = self.realDataMgr.GetSelfBuyInfoByIndex(index)
	local param = {}
	param.Time = CC.uu.TimeOut3(info.TimeStamp)
	param.Name = CC.ConfigCenter.Inst():getDescByKey("ware_"..info.GoodsID)
	for k,v in pairs(self.wareCfg) do
		if v.ProductId == info.GoodsID then
			param.Icon = v.Icon
			break
		end
	end
	self.view:CreateSelfInfoItem(tran,param)
end

function TreasureViewCtr:PrizeListResp(err,data)
	if err == 0 then
		self.realDataMgr.SetTreasureInfo(data)
	else
		self.view:InitTreasureFail()
	end
end

function TreasureViewCtr:LatelyPlayerLuckyRecordResp(err,data)
	if err == 0 then
		self.realDataMgr.SetTreasureRollInfo(data)
		self:InitRollPanel()
	else
		log("拉取历史夺宝信息失败")
	end
end

function TreasureViewCtr:RefreshTreasureList(data)
	local param = {}
	for k,v in pairs(data) do
		local goods = {}
		goods.PrizeId = v.PrizeId				--夺宝ID
		goods.Issue = v.Issue					--夺宝期数
		goods.VipLimit = v.VipLimit				--VIP限制
		goods.Currency = v.Currency				--夺宝货币
		goods.Price = v.Price					--夺宝价格
		goods.LimitType = v.LimitType			--存在类型
		goods.OpenType = v.OpenType				--夺宝类型
		goods.CountDown = v.CountDown			--开奖倒计时
		goods.PurchasedQuota = v.PurchasedQuota	--自己购买次数
		goods.LimitQuota = v.LimitQuota			--购买限制
		goods.SoldQuota = v.SoldQuota			--当前购买
		goods.TotalQuota = v.TotalQuota			--夺宝次数上限
		goods.Status = v.Status					--开奖状态
		goods.SellStartTime = v.SellStartTime	--预售开始时间
		goods.LuckyPlayer = v.LuckyPlayer		--中奖玩家信息
		goods.IsSupplement = v.IsSupplement		--是否支持用筹码补齐礼票
		goods.Desc = self.realDataMgr.GetDescType(v.PropId,self.propCfg[v.PropId].Type)
		goods.WaitOpen = v.WaitOpen;
		if v.PropId == CC.shared_enums_pb.EPC_ChouMa then
			goods.Icon = self.realDataMgr.GetChipIcon(v.PropCount)
			goods.Name = self.propDataMgr.GetLanguageDesc(v.PropId,v.PropCount)
		else
			goods.Icon = self.propCfg[v.PropId].Icon
			goods.Name = self.propDataMgr.GetLanguageDesc(v.PropId)
		end
		if v.Lock == 0 or not v.Lock then
			table.insert(param,goods)
		else
			if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel") then
				table.insert(param,goods)
			end
		end
	end
	self.view:RefreshTreasureList(param)
end

function TreasureViewCtr:ExchangeGoods(goodsInfo)

	--游戏里不允许兑换
	if not CC.ViewManager.IsHallScene() then
		CC.ViewManager.ShowTip(self.language.gobackToHall)
		return
	end
	
	--商品数据
	local id = goodsInfo.info.Id
	local productId = goodsInfo.info.ProductId
	local count = goodsInfo.num
	local price = goodsInfo.info.Price
	local currency = goodsInfo.info.Currency
	--商品配置信息
	local wareInfo = goodsInfo.info
	--获得物品信息
	local propinfo = self.propCfg[wareInfo.Rewards[1].ConfigId]
	local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")

	local Chip = nil
	local GiftVoucher = nil
	local count = tonumber(count)
	if count <= 0 then
		CC.ViewManager.ShowTip(self.language.stockNotEnough)
		return
	end
	
	if vipLevel < wareInfo.VipLimitMin then
		CC.ViewManager.ShowTip(self.language.vipLimit)
		return
	end
	
	if self.realDataMgr.GetTradeInfo() and self.realDataMgr.GetTradeInfo().Locked then
		self.LockedChip = self.realDataMgr.GetTradeInfo().Locked
	else
		self.LockedChip = 0
	end
	if currency == CC.shared_enums_pb.PCT_Chouma then
		if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") < price then
			self:GuideToRecharge()
			return
		elseif CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") - self.LockedChip < price then
			CC.ViewManager.ShowTip(self.language.infor_LockedChipShop)
			return
		end
	-- elseif currency == CC.shared_enums_pb.PCT_Card_Pieces then
	-- 	if CC.Player.Inst():GetSelfInfoByKey("EPC_PointCard_Fragment") < price then
	-- 		CC.ViewManager.ShowTip(self.language.PointCard_FragmentNotEnough)
	-- 		CC.ViewManager.Open("DebrisGiftView")
	-- 		return
	-- 	else
	-- 		if CC.Player.Inst():GetSelfInfoByKey("EPC_Card_Pieces_Exchange_Count") == 0 then
	-- 			CC.ViewManager.Open("CardFragExchangeView",{goodsID = id})
	-- 			return
	-- 		end
	-- 	end
	elseif currency == CC.shared_enums_pb.PCT_GiftVoucher then
		if CC.Player.Inst():GetSelfInfoByKey("EPC_New_GiftVoucher") < price then
			--兑换商品是筹码时，不能使用筹码兑换
			if wareInfo.Rewards[1].ConfigId == CC.shared_enums_pb.EPC_ChouMa or not goodsInfo.IsSupplement then
				CC.ViewManager.ShowTip(self.language.GiftVoucherExchangeNotEnough)
				return
			end

			--一张礼票=50筹码
			local lack = price - CC.Player.Inst():GetSelfInfoByKey("EPC_New_GiftVoucher")
			local cost = lack * 50
			if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") >= cost then
				if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") - self.LockedChip >= cost then
					GiftVoucher = lack
					Chip = cost
				else
					CC.ViewManager.ShowTip(self.language.infor_LockedChipShop)
					return
				end
			else
				self:GuideToRecharge()
				return
			end
		end
	elseif currency == CC.shared_enums_pb.EPC_True_Money_Card then
		if CC.Player.Inst():GetSelfInfoByKey("EPC_True_Money_Card") < price then
			CC.ViewManager.ShowTip(self.language.exNotEnought)
			return
		end
	elseif currency == CC.shared_enums_pb.EPC_One_Red_env or currency == CC.shared_enums_pb.EPC_Truemoney_20093 then
		if CC.Player.Inst():GetSelfInfoByKey(currency) < price then
			CC.ViewManager.Open("TreasureNotEnoughTips",{wareInfo = wareInfo,tips = self.view.language.RedPacketNotEnought})
			return
		end
	else
		--消耗道具
		if goodsInfo.consume then
			local hasNum = CC.Player.Inst():GetSelfInfoByKey(goodsInfo.consume) or 0
			if hasNum < price then
				CC.ViewManager.ShowTip(self.language.exNotEnought)
				return
			end
		end
	end

	--检查是否绑定手机和是否设置安全码
	if not self:CheckIsCanExchange() then
		return
	end
	-- 当前商城类型
	local shopType = self.view.curShopType
	
	--红包商城兑换非金币类商品，对V0/1/2需要保留一定的金币
	if shopType == CC.proto.client_shop_pb.RedEnvelopeShop and propinfo.Id ~= CC.shared_enums_pb.EPC_ChouMa then
		local hasNum = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
		local needKeep = self.realDataMgr.GetKeepMinChip()
		if hasNum < needKeep then
			CC.ViewManager.Open("ChipNotEnoughTips",{tips = self.language.keepChipTips, needValue = needKeep})
			return
		end
	end
	
	local nextFun = function(err,result)
		--验证安全码错误
		if err ~= 0 then return end
		---验证成功之后下次 兑换、夺宝、超级夺宝 都不用再验证
		CC.Player.Inst():GetSafeCodeData().SafeService[1].Status = true
		CC.Player.Inst():GetSafeCodeData().SafeService[2].Status = true
		CC.Player.Inst():GetSafeCodeData().SafeService[3].Status = true



		if id == "100059" then
			CC.ViewManager.Open("AgentShareView", {value = 20,closeBtn = true, tipsType = 2})
			return
		elseif id == "100064" or id == "100065" or id == "100066" 
			or (shopType == CC.proto.client_shop_pb.RedEnvelopeShop and goodsInfo.wePayChannel > 0) 
			or propinfo.Type == CC.shared_enums_pb.EPT_EWallet then
			--兑换电子钱包
			local param = {}
			param.goodsId = id
			param.type = shopType
			param.icon = self.wareCfg[id].Icon
			CC.ViewManager.Open("AgentExView", param)
			return
		end

		local param = {}
		param.Canclose = true
		param.IdendityInfo = propinfo.IdendityInfo
		param.PersonInfo = propinfo.PersonInfo
		param.Desc = CC.ConfigCenter.Inst():getDescByKey("ware_"..productId)
		param.Type = propinfo.Type
		param.Icon = self.wareCfg[id].Icon
		param.ActiveName = wareInfo.SubChannel
		param.callback = function ()
			local data = {}
			data.GoodsID = tonumber(id)
			data.Type = shopType
			CC.Request("ReqGoodsBuy",data)
		end

		local ReqGoodsBuy = function ()
			local req = function ()
				local data = {}
				data.GoodsID = tonumber(id)
				data.Type = shopType
				CC.Request("ReqGoodsBuy",data)
			end
			if wareInfo.Rewards[1].ConfigId == CC.shared_enums_pb.EPC_ChouMa or propinfo.Physical and propinfo.Delivery == 0 then
				req()
			else
				CC.ViewManager.Open("InformationView",param)
			end
		end

		local OnReqExchange = function()
			if Chip and GiftVoucher then
				local box = CC.ViewManager.ShowMessageBox(string.format(self.language.exchangeLack,GiftVoucher,Chip),
					function ()
						ReqGoodsBuy()
					end,
					function ()
						-- body
					end)
			else
				ReqGoodsBuy()
			end
		end
		self:OnReqExchangeTimes(shopType,tonumber(id),OnReqExchange)
	end

	--验证安全码
	if not CC.Player.Inst():GetSafeCodeData().SafeService[1].Status then
		CC.ViewManager.Open("VerSafePassWordView",{serviceType = 1,verifySuccFun = nextFun})
	else
		nextFun(0,{Token = ""})
	end
end

function TreasureViewCtr:OnReqExchangeTimes(type,goodsId,callback)
	local data = {}
	data.Type = type
	data.GoodsID = goodsId
	local succCb = function(code,result)
		self.view:ShowExchangeLimitBox(result,callback)
	end
	local errCb = function(code,result)
		CC.ViewManager.ShowTip(CC.LanguageManager.GetLanguage("L_Common").tip2)
	end
	CC.Request("ReqExchangeTimes",data,succCb,errCb)
end

function TreasureViewCtr:OnPropChange(data)
	for _,v in ipairs(data) do
        if v.ConfigId == CC.shared_enums_pb.EPC_PointCard_Fragment then
			self.view:RefreshPCFNum()
		elseif v.ConfigId == CC.shared_enums_pb.EPC_Props_82 or
			v.ConfigId == CC.shared_enums_pb.EPC_Props_83 then
			self.view:RefreshRedEnvelope()
		end
	end
end

function TreasureViewCtr:OnSwitchTableGroup(OpenViewId)
	self.view:OnSwitchTableGroup(OpenViewId)
end

function TreasureViewCtr:Req_PrizePuarchase(PrizeId,Issue,Times)
	local data = {}
	data.PrizeId = PrizeId
    data.Issue = Issue
    data.Times = Times
	CC.Request("Req_PrizePuarchase",data)
end

function TreasureViewCtr:OpenPrizeResp(data)
	CC.Request("Req_LatelyPlayerLuckyRecord")
	self.view:OpenPrize(data)
end

function TreasureViewCtr:ReqTrade()
	CC.Request("ReqTradeInfo")

end

function TreasureViewCtr:RefreshTrade(err,data)
	if err == 0 then
		self.realDataMgr.SetTradeInfo(data)
	else
		log("拉取锁定筹码失败")
	end
end

function TreasureViewCtr:GuideToRecharge()
	local box = CC.ViewManager.ShowMessageBox(self.language.ChipExchangeNotEnough,
	function ()
		if CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
			local param = {}
			param.SelectGiftTab = {"NoviceGiftView"}
			CC.ViewManager.Open("SelectGiftCollectionView",param)
		else
			CC.ViewManager.Open("StoreView")
		end
	end,
	function ()
		--取消不作任何处理
	end)
	box:SetCloseBtn()
end

function TreasureViewCtr:CheckIsCanExchange()
	if not CC.HallUtil.CheckTelBinded() then
		if CC.HallUtil.CheckSafetyFactor({str = "safetyTip3"}) then
			return false
		end
	end
	
	if not CC.HallUtil.CheckSafePassWord() then
		return false
	end

	return true
end

function TreasureViewCtr:Destroy()
	self:UnRegisterEvent();

	self.view = nil;

	CC.HallUtil.OnShowHallCamera(true);
end

return TreasureViewCtr