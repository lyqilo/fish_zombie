---------------------------------
-- region SuperTreasureViewCtr.lua		-
-- Date: 2020.09.05				-
-- Desc:  超级夺宝               -
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local SuperTreasureViewCtr = CC.class2("SuperTreasureViewCtr")

function SuperTreasureViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function SuperTreasureViewCtr:InitVar(view, param)
    self.param = param or {};
	self.view = view;

	self.isInit = true;

	self.language = self.view:GetLanguage();

	self.mailDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Mail");

	self.realDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData");

	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");

	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop");

	self.propDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr");

	self.recordList = nil

	--跑马灯下标
	self.MarqueeIndex = 1

	--跑马灯初始化状态
	self.MarqueeInit = false

	--开奖推送标记(用于礼票结束时请求最新道具状况，推送会多次，请求一次即可)
	self.PushFlag = true
end

function SuperTreasureViewCtr:OnCreate()
	self:RegisterEvent();
	self:ReqLoadPlayerWithPropIds()
	CC.Request("Req_Super_PrizeList")
	CC.Request("Req_Super_LatelyPlayerLuckyRecord")
end

function SuperTreasureViewCtr:ReqLoadPlayerWithPropIds()
	local data = {
		propIds = {
			CC.shared_enums_pb.EPC_MidMonth_Treasure_Small,
			CC.shared_enums_pb.EPC_MidMonth_Treasure_Big
		} 
	}
	CC.HallUtil.ReqPlayerPropByIds(data)
end

function SuperTreasureViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.PrizeListResp,CC.Notifications.NW_Req_Super_PrizeList)
	CC.HallNotificationCenter.inst():register(self,self.RefreshTreasureList,CC.Notifications.SetSuperTreasureInfoFinish)
	CC.HallNotificationCenter.inst():register(self,self.OpenPrizeResp,CC.Notifications.OnPushSuperTreasureOpenPrize)
	CC.HallNotificationCenter.inst():register(self,self.LatelyPlayerLuckyRecordResp,CC.Notifications.NW_Req_Super_LatelyPlayerLuckyRecord)
	CC.HallNotificationCenter.inst():register(self,self.RefreshProp,CC.Notifications.changeSelfInfo)
end

function SuperTreasureViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function SuperTreasureViewCtr:RefreshTreasureList(data)
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

function SuperTreasureViewCtr:PrizeListResp(err,data)
	if err == 0 then
		self.realDataMgr.SetSuperTreasureInfo(data)
		self.view:StartTimer("RefreshTreasure",3,function ()
			CC.Request("Req_Super_PrizeList")
		end,-1)
	else
		self.view:StopTimer("RefreshTreasure")
		self.view:InitTreasureFail()
	end
end

function SuperTreasureViewCtr:OpenPrizeResp(data)
	if CC.Player.Inst():GetSelfInfoByKey("EPC_MidMonth_Treasure_Small") > 0 or CC.Player.Inst():GetSelfInfoByKey("EPC_MidMonth_Treasure_Big") > 0 and self.PushFlag then
		self.PushFlag = false
		local rd = math.random(1,5)
		self.view:DelayRun(rd,function ()
			self:ReqLoadPlayerWithPropIds()
		end)
	end
	CC.Request("Req_Super_LatelyPlayerLuckyRecord")
	self.view:OpenPrize(data)
end

function SuperTreasureViewCtr:LatelyPlayerLuckyRecordResp(err,data)
	if err == 0 then
		self.recordList = {}
		self.recordList = data.LatelyLuckys
		self.MarqueeIndex = 1
		if not self.MarqueeInit and #self.recordList > 0 then
			self.MarqueeInit = true
			self.view:StartMarquee()
		end
	else
		log("拉取历史夺宝信息失败")
	end
end

function SuperTreasureViewCtr:RefreshProp()
	self.view:RefrshProp()
end

function SuperTreasureViewCtr:GetMarqueeText()
    if self.recordList[self.MarqueeIndex] then
        local info = self.recordList[self.MarqueeIndex]
		local nick = info.NickName
		local reward = self.propDataMgr.GetLanguageDesc(info.PropId,info.PropCount)
        self.MarqueeIndex = self.MarqueeIndex + 1
        if self.MarqueeIndex == 5 or self.MarqueeIndex > #self.recordList then self.MarqueeIndex = 1 end
        return nick,reward
    end
end

function SuperTreasureViewCtr:Destroy()
	self:UnRegisterEvent();

	self.view = nil;
end

return SuperTreasureViewCtr