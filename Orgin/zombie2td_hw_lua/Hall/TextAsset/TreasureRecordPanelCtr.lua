---------------------------------
-- region TreasureRecordPanelCtr.lua	-
-- Date: 2019.11.11				-
-- Desc: 一元夺宝				-
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local TreasureRecordPanelCtr = CC.class2("TreasureRecordPanelCtr")

function TreasureRecordPanelCtr:ctor(view, param)
	self:InitVar(view, param)
end

function TreasureRecordPanelCtr:InitVar(view,param)
    self.param = param

	self.view = view

	self.language = CC.LanguageManager.GetLanguage("L_TreasureView");

	self.realDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData")

	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")

	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")

	self.propDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
	--------------------------
	self.PurchaseRecordMap = {}

	self.PurchaseRecordList = {}

	self.PlayerLuckyRecordMap = {}

	self.PlayerLuckyRecordList = {}

	self.bInitLucky = true

	self.LuckyStart = 0

	self.LuckyEnd = false

	self.bInitPurchase = true

	self.PurchaseStart = 0

	self.PurchaseEnd = false
	--------------------------
end

function TreasureRecordPanelCtr:OnCreate()
	self:RegisterEvent()
	local data = {}
	data.Start = self.PurchaseStart
    data.End = self.PurchaseStart + 19
    CC.Request("Req_PurchaseRecord",data)

    local dataLucky = {}
	dataLucky.Start = self.LuckyStart
    dataLucky.End = self.LuckyStart + 19
    CC.Request("Req_PlayerLuckyRecord",dataLucky)
end

function TreasureRecordPanelCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.PurchaseRecordResp,CC.Notifications.NW_Req_PurchaseRecord)
	CC.HallNotificationCenter.inst():register(self,self.PlayerLuckyRecordResp,CC.Notifications.NW_Req_PlayerLuckyRecord)
end

function TreasureRecordPanelCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_Req_PurchaseRecord)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_Req_PlayerLuckyRecord)
end

function TreasureRecordPanelCtr:Req_PurchaseRecord()
	if self.PurchaseEnd then return end
	local data = {}
	data.Start = self.PurchaseStart
    data.End = self.PurchaseStart + 19
    CC.Request("Req_PurchaseRecord",data)
end

function TreasureRecordPanelCtr:Req_PlayerLuckyRecord()
	if self.LuckyEnd then return end
	local data = {}
	data.Start = self.LuckyStart
    data.End = self.LuckyStart + 19
    CC.Request("Req_PlayerLuckyRecord",data)
end

function TreasureRecordPanelCtr:PurchaseRecordResp(err,data)
	if err == 0 then
		self.PurchaseStart = self.PurchaseStart + 19
		if #data.PurchaseRecordList < 20 then
			self.PurchaseEnd = true
		end
		for i,v in ipairs(data.PurchaseRecordList) do
			if not self.PurchaseRecordMap[v.PrizeId] then
				self.PurchaseRecordMap[v.PrizeId] = {}
				self.PurchaseRecordMap[v.PrizeId][v.Issue] = v
				table.insert(self.PurchaseRecordList,v)
			else
				if not self.PurchaseRecordMap[v.PrizeId][v.Issue] then
					self.PurchaseRecordMap[v.PrizeId][v.Issue] = v
					table.insert(self.PurchaseRecordList,v)
				end
			end
		end
		self.view:InItPurchaseRecord(#self.PurchaseRecordList,self.bInitPurchase)
		self.bInitPurchase = false
	else
		log("PlayerLuckyRecordResp:"..err)
	end
end

function TreasureRecordPanelCtr:PlayerLuckyRecordResp(err,data)
	if err == 0 then
		self.LuckyStart = self.LuckyStart + 19
		if #data.PlayerLuckyRecord < 20 then
			self.LuckyEnd = true
		end
		for i,v in ipairs(data.PlayerLuckyRecord) do
			if not self.PlayerLuckyRecordMap[v.PrizeId] then
				self.PlayerLuckyRecordMap[v.PrizeId] = {}
				self.PlayerLuckyRecordMap[v.PrizeId][v.Issue] = v
				table.insert(self.PlayerLuckyRecordList,v)
			else
				if not self.PlayerLuckyRecordMap[v.PrizeId][v.Issue] then
					self.PlayerLuckyRecordMap[v.PrizeId][v.Issue] = v
					table.insert(self.PlayerLuckyRecordList,v)
				end
			end
		end
		self.view:InItPlayerLuckyRecord(#self.PlayerLuckyRecordList,self.bInitLucky)
		self.bInitLucky = false
	else
		logError("NW_Req_PlayerLuckyRecord:"..err)
	end
end

function TreasureRecordPanelCtr:SetPurchaseData(tran,dataIndex,cellIndex)
	local index = dataIndex + 1
	local info = self.PurchaseRecordList[index]
	local param = {}
	param.PrizeId = info.PrizeId
	if info.PropId == CC.shared_enums_pb.EPC_ChouMa then
		param.Icon = self.realDataMgr.GetChipIcon(info.PropCout)
		param.Name = self.propDataMgr.GetLanguageDesc(info.PropId,info.PropCout)
	else
		CC.uu.Log(info,"Test:",3)
		param.Icon = self.propCfg[info.PropId].Icon
		param.Name = self.propDataMgr.GetLanguageDesc(info.PropId)
	end
	param.Issue = info.Issue
	param.Time = CC.uu.TimeOut3(info.EndTime)
	param.PurchasedTimes = info.PurchasedTimes
	param.Lucky = info.Lucky
	param.Remain = info.Remain
	param.proceed = info.proceed
	param.SoldQuota = info.SoldQuota
	param.OpenNeedQuota = info.OpenNeedQuota
	param.LuckyPlayer = info.LuckyPlayer
	self.view:SetPurchaseItem(tran,param)
end

function TreasureRecordPanelCtr:SetLuckyData(tran,dataIndex,cellIndex)
	local index = dataIndex + 1
	local info = self.PlayerLuckyRecordList[index]
	CC.uu.Log(info,"Record:",3)
	local param = {}
	param.PrizeId = info.PrizeId
	if info.PropId == CC.shared_enums_pb.EPC_ChouMa then
		param.Icon = self.realDataMgr.GetChipIcon(info.PropCount)
		param.Name = self.propDataMgr.GetLanguageDesc(info.PropId,info.PropCount)
	else
		param.Icon = self.propCfg[info.PropId].Icon
		param.Name = self.propDataMgr.GetLanguageDesc(info.PropId)
	end
	param.Issue = info.Issue
	param.Time = CC.uu.TimeOut3(info.EndTime)
	param.PurchasedTimes = info.PurchasedTimes
	param.WinninerNumber = info.WinninerNumber
	self.view:SetLuckyItem(tran,param)
end

function TreasureRecordPanelCtr:Destroy()
	self:UnRegisterEvent();

	self.view = nil;
end

return TreasureRecordPanelCtr