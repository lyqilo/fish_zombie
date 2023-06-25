---------------------------------
-- region TreasureInformationCtr.lua	-
-- Date: 2019.11.11				-
-- Desc: 一元夺宝				-
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local TreasureInformationCtr = CC.class2("TreasureInformationCtr")

function TreasureInformationCtr:ctor(view, param)
	self:InitVar(view, param)
end

function TreasureInformationCtr:InitVar(view,param)
	self.param = param or {}

	self.view = view

	self.language = CC.LanguageManager.GetLanguage("L_TreasureView");

	self.realDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData")

	-- self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")

	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")

	self.propDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")

	self.LuckRecordMap = {}
	self.nStartIndex = 0
	self.nCapacity = 10
	self.nEndIndex = (self.nStartIndex + self.nCapacity) - 1
	self.nMaxLimit = 100
end

function TreasureInformationCtr:OnCreate()
	self:RegisterEvent()

	if self.realDataMgr.GetTradeInfo() and self.realDataMgr.GetTradeInfo().Locked then
		self.LockedChip = self.realDataMgr.GetTradeInfo().Locked
	else
		self.LockedChip = 0
	end
end

function TreasureInformationCtr:Req_PrizeLuckyRecord()
	local param = {
		PrizeId = self.view.PrizeId,
		Start = self.nStartIndex,
		End = self.nEndIndex
	}
	CC.Request("Req_PrizeLuckyRecord", param)
end

function TreasureInformationCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.RefreshTreasure,CC.Notifications.SetTreasureInfoFinish)
	CC.HallNotificationCenter.inst():register(self,self.RefreshTreasure,CC.Notifications.SetSuperTreasureInfoFinish)
	CC.HallNotificationCenter.inst():register(self,self.PrizePuarchaseResp,CC.Notifications.NW_Req_PrizePuarchase)
	CC.HallNotificationCenter.inst():register(self,self.PrizePuarchaseResp,CC.Notifications.NW_Req_Super_PrizePurchase)
	CC.HallNotificationCenter.inst():register(self,self.PrizeLuckyRecordResp,CC.Notifications.NW_Req_PrizeLuckyRecord)
	CC.HallNotificationCenter.inst():register(self,self.OpenPrizeResp,CC.Notifications.OnPushTreasureOpenPrize)
	CC.HallNotificationCenter.inst():register(self,self.OpenPrizeFinish,CC.Notifications.OnOpenPrizeFinish)
end

function TreasureInformationCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.SetTreasureInfoFinish)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.SetSuperTreasureInfoFinish)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_Req_PrizePuarchase)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_Req_Super_PrizePurchase)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_Req_PrizeLuckyRecord)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPushTreasureOpenPrize)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnOpenPrizeFinish)
end

function TreasureInformationCtr:RefreshTreasure(data)
	local goods = {}
	for k,v in pairs(data) do
		if v.PrizeId  == self.view.PrizeId then
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
			goods.Desc = self.realDataMgr.GetDescType(v.PropId,self.propCfg[v.PropId].Type)
			goods.WaitOpen = v.WaitOpen;
			if v.PropId == CC.shared_enums_pb.EPC_ChouMa then
				goods.Icon = self.realDataMgr.GetChipIcon(v.PropCount)
				goods.Name = self.propDataMgr.GetLanguageDesc(v.PropId,v.PropCount)
			else
				goods.Icon = self.propCfg[v.PropId].Icon
				goods.Name = self.propDataMgr.GetLanguageDesc(v.PropId)
			end
		end
	end
	self.view:RefreshTreasureInfo(goods)
end

function TreasureInformationCtr:Req_PrizePuarchase(data)
	local GiftVoucher = nil
	local Chip = nil

	local prizeId = data.PrizeId
	local issue = data.Issue
	local times = data.Times
	local Price = data.Price
	local Currency = data.Currency
	local VipLimit = data.VipLimit
	local IsSupplement = data.IsSupplement
	local PriceCount = Price*times
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < VipLimit then
		self:GuideToRecharge(self.language.VIPNotEnough)
		return
	end
	if Currency == CC.shared_enums_pb.EPC_ChouMa then
		if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") < PriceCount then
			self:GuideToRecharge(self.language.ChipNotEnough)
			return
		elseif CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") - self.LockedChip < PriceCount then
			CC.ViewManager.ShowTip(self.language.infor_LockedChip)
			return
		end
	elseif Currency == CC.shared_enums_pb.EPC_New_GiftVoucher then
		if CC.Player.Inst():GetSelfInfoByKey("EPC_New_GiftVoucher") < PriceCount then
			if IsSupplement then
				local lack = PriceCount - CC.Player.Inst():GetSelfInfoByKey("EPC_New_GiftVoucher")
				local cost = lack * 50
				if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") >= cost then
					if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") - self.LockedChip >= cost then
						GiftVoucher = lack
						Chip = cost
					else
						CC.ViewManager.ShowTip(self.language.infor_LockedChip)
						return
					end
				else
					self:GuideToRecharge(self.language.ChipNotEnough)
					return
				end
			else
				CC.ViewManager.ShowTip(self.language.GiftVoucherNotEnough)
				return
			end
		end
	elseif Currency == CC.shared_enums_pb.EPC_MidMonth_Treasure_Small  then
		if CC.Player.Inst():GetSelfInfoByKey("EPC_MidMonth_Treasure_Small") < PriceCount then
			CC.ViewManager.ShowTip(self.language.xjqNotEnough)
			return
		end
	elseif Currency == CC.shared_enums_pb.EPC_MidMonth_Treasure_Big then
		if CC.Player.Inst():GetSelfInfoByKey("EPC_MidMonth_Treasure_Big") < PriceCount then
			CC.ViewManager.ShowTip(self.language.djqNotEnough)
			return
		end
	-- elseif Currency == CC.shared_enums_pb.EPC_PointCard_Fragment then
	-- 	if CC.Player.Inst():GetSelfInfoByKey("EPC_PointCard_Fragment") < PriceCount then
	-- 		self.view:Destroy()
    --         CC.ViewManager.ShowTip(self.language.PointCard_FragmentNotEnough)
    --         CC.ViewManager.Open("DebrisGiftView")
	-- 		return
	-- 	end
	end

	--检查是否绑定手机和是否设置安全码
	if not self:CheckIsCanPurchase() then
		return
	end

	local nextFun = function(err,result)
		--验证安全码错误
		if err ~= 0 then return end
		--验证成功之后下次 兑换、夺宝、超级夺宝 都不用再验证
		CC.Player.Inst():GetSafeCodeData().SafeService[1].Status = true
		CC.Player.Inst():GetSafeCodeData().SafeService[2].Status = true
		CC.Player.Inst():GetSafeCodeData().SafeService[3].Status = true

		local Req = function ()
			if self.view.Currency >= CC.shared_enums_pb.EPC_MidMonth_Treasure_Small then
				CC.Request("Req_Super_PrizePurchase",{PrizeId = prizeId,Issue = issue,Times = times})
			else
				CC.Request("Req_PrizePuarchase",{PrizeId = prizeId,Issue = issue,Times = times})
			end
		end
	
		if GiftVoucher and Chip then
			-- local box = CC.ViewManager.ShowMessageBox(string.format(self.language.treasureLack,GiftVoucher,Chip),
			-- function ()
			-- 	Req()
			-- end)
			CC.ViewManager.ShowTip(self.language.exNotEnought)
		else
			Req()
		end
	end

	--验证安全码
	local isSuper_Prize = self.view.Currency >= CC.shared_enums_pb.EPC_MidMonth_Treasure_Small
	local needVerify = CC.Player.Inst():GetSafeCodeData().SafeService[isSuper_Prize and 3 or 2].Status
	
	if not needVerify then
		CC.ViewManager.Open("VerSafePassWordView",{serviceType = isSuper_Prize and 3 or 2,verifySuccFun = nextFun})
	else
		nextFun(0,{Token = ""})
	end
end

function TreasureInformationCtr:PrizePuarchaseResp(err,data)
	if err == 0 then
		-- CC.uu.Log(data,"返回的夺宝码：",3)
		local purchaseTimes = data.RequestTimes
		local successTimes = data.SuccessTimes
		if purchaseTimes == successTimes then
			self.view:OpenTreasureCodePanel(data)
			self.view:RefreshCodeNum(#data.Numbers)
			self:RefreshReq()
		elseif successTimes < purchaseTimes and successTimes ~=0 then
			self.view:OpenTreasureTips(data)
			self.view:OpenTreasureCodePanel(data)
			self.view:RefreshCodeNum(#data.Numbers)
			self:RefreshReq()
		elseif successTimes == 0 then
			self.view:OpenTreasureTips(data)
			self:RefreshReq()
		end
		self.view:ResetTimes()
	else
		if CC.uu.isNumber(err) then
			if err == 601 then
				--夺宝预警
				CC.ViewManager.Open("WarningTipView")
				return;
			end
		end
		log("PrizePuarchaseResp 购买失败")
	end
end

function TreasureInformationCtr:RefreshReq()
	if self.view.Currency >= CC.shared_enums_pb.EPC_MidMonth_Treasure_Small then
		CC.Request("Req_Super_PrizeList")
	else
		CC.Request("Req_PrizeList")
	end
end

function TreasureInformationCtr:PrizeLuckyRecordResp(err,data)
	if err == 0 then
		local count = #data.LuckyRecordList
		if count < self.nCapacity then
			--数据拉到底 设置拉取锁
			self.view.queryLock = 2
		end
		--刷新拉取下标
		self.nStartIndex = self.nEndIndex + 1
		self.nEndIndex = (self.nStartIndex + self.nCapacity) - 1
		if self.nStartIndex >= self.nMaxLimit then
			self.view.queryLock = 2
		end
		if self.view.queryLock ~= 2 then
			self.view.queryLock = 0
		end
		if count > 0 then
			for i,v in ipairs(data.LuckyRecordList) do
				if not self.LuckRecordMap[v.Issue] then
					self.LuckRecordMap[v.Issue] = v
					self.view:FillRecordItem(v)
				end
			end
		else
			self.view:RecordReqFail()
		end
	else
		self.view:RecordReqFail()
	end
end

function TreasureInformationCtr:OpenPrizeResp(data)
	if data.PrizeId == self.view.PrizeId and data.Issue == self.view.Issue then
		self.view:OpenPrize(data)
	end
end

function TreasureInformationCtr:OpenPrizeFinish()
	self.view:OpenPrizeFinish()
end

function TreasureInformationCtr:GuideToRecharge(message)
	local box = CC.ViewManager.ShowMessageBox(message,
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

function TreasureInformationCtr:CheckIsCanPurchase()
	if not CC.HallUtil.CheckTelBinded() then
		if CC.HallUtil.CheckSafetyFactor() then
			return false
		end
	end
	
	if not CC.HallUtil.CheckSafePassWord() then
		return false
	end

	return true
end

function TreasureInformationCtr:Destroy()
	self:UnRegisterEvent();
	self.view = nil;
end

return TreasureInformationCtr