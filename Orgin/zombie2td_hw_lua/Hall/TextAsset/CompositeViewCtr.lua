local CC = require("CC")
local LoginAwardView = require "view.otherview.loginawardview"
local CompositeViewCtr = CC.class2("CompositeViewCtr")
local compositeCachePath = "Composite_key_2"

local table = table
local string = string

function CompositeViewCtr:ctor(view, param)
	self:InitVar(view, param)
end

function CompositeViewCtr:InitVar(view, param)
	self.view = view
end

function CompositeViewCtr:OnCreate()
	self:InitData()
	self:RegisterEvent()
end

function CompositeViewCtr:RefreshData()
	self.svrData = {
		[501] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Common1),
		[502] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Common2),
		[503] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Common3),
		[504] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Common4),
		[505] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Rare1),
		[506] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Rare2),
		[507] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Rare3),
		[508] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Rare4),
		[509] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Mythical1),
		[510] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Mythical2),
		[511] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Mythical3),
		[512] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Legendary1),
		[513] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Legendary2),
		[514] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Legendary3),
		[515] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Immortal1),
		[516] = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_Immortal2),
	}
end

function CompositeViewCtr:InitData()
	self:GetCahceData()
	self:RefreshData()
	self.cfgBase = table.copy(CC.ConfigCenter.Inst():getConfigDataByKey("CompositeBase"))
	self.cfgAssembly = CC.ConfigCenter.Inst():getConfigDataByKey("CompositeAssembly")
	self.cfgRankJP = CC.ConfigCenter.Inst():getConfigDataByKey("CompositeJPConfig")

	--这里的CompositeAssembly的配置方式是为了和服务器接近方便配置人员配置的
	--再处理一下方便客户端使用,吧CompositeAssembly里的数据变成附属于CompositeBase里ID的结构
	for k,item in pairs(self.cfgBase) do
		--这里增加的是谁能合成当前物品
		item.assembly = {}
		for _k,assembly in pairs(self.cfgAssembly) do
			for __k,v in pairs(assembly.outcomes) do
				if v.propID == item.ID then
					table.insert(item.assembly,{
						materials = assembly.materials,
						outcome = v,
						assemblyID = assembly.ID,
					})
				end
			end
		end
		table.sort(item.assembly,function(a,b)
			return a.outcome.probability > b.outcome.probability
		end)
	end

	self.cfgBaseArray = {}
	for k,item in pairs(self.cfgBase) do
		table.insert(self.cfgBaseArray,item)
	end
	table.sort(self.cfgBaseArray,function(a,b)
		return a.ID < b.ID
	end)

	self:BroadcastReq()
end

function CompositeViewCtr:OnRefreshPropChange(props, source)
	self.view:RefreshSelfInfo()

	for _,v in ipairs(props) do
		local id = v.ConfigId
		if id == CC.shared_enums_pb.EPC_Common1
		or id == CC.shared_enums_pb.EPC_Common2
		or id == CC.shared_enums_pb.EPC_Common3
		or id == CC.shared_enums_pb.EPC_Common4
		or id == CC.shared_enums_pb.EPC_Rare1
		or id == CC.shared_enums_pb.EPC_Rare2
		or id == CC.shared_enums_pb.EPC_Rare3
		or id == CC.shared_enums_pb.EPC_Rare4
		or id == CC.shared_enums_pb.EPC_Mythical1
		or id == CC.shared_enums_pb.EPC_Mythical2
		or id == CC.shared_enums_pb.EPC_Mythical3
		or id == CC.shared_enums_pb.EPC_Legendary1
		or id == CC.shared_enums_pb.EPC_Legendary2
		or id == CC.shared_enums_pb.EPC_Legendary3
		or id == CC.shared_enums_pb.EPC_Immortal1
		or id == CC.shared_enums_pb.EPC_Immortal2
		then
			self:RefreshData()
			if self.view then
				self.view:RefreshItemNum()
				self.view:OnChoseItem()
			end
		end

		if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
			if source == CC.shared_transfer_source_pb.TS_Compose_Exchange then
				if self.view then
					self.view:ShowExchangeResp(v.Delta)
				end
			end
		end
    end
end

function CompositeViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.JPResp,CC.Notifications.NW_ReqCompositeJPPool)
	CC.HallNotificationCenter.inst():register(self,self.HasJPResp,CC.Notifications.NW_ReqCompositeHasJP)
	CC.HallNotificationCenter.inst():register(self,self.GetJPResp,CC.Notifications.NW_ReqCompositeGetJP)
	CC.HallNotificationCenter.inst():register(self,self.CompositeResp,CC.Notifications.NW_ReqCompositeDo)
	CC.HallNotificationCenter.inst():register(self,self.OnPushActivity,CC.Notifications.OnPushActivityMsg)
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshPropChange,CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():register(self,self.MulRankResp,CC.Notifications.NW_ReqCompositeMulRank)
    CC.HallNotificationCenter.inst():register(self,self.ExchangeResp,CC.Notifications.NW_ReqCompositeExchange)
	CC.HallNotificationCenter.inst():register(self,self.BroadcastResp,CC.Notifications.NW_ReqCompositeBroadcast)
end

function CompositeViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.changeSelfInfo)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPushActivityMsg)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqCompositeDo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqCompositeHasJP)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqCompositeGetJP)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqCompositeJPPool)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqCompositeMulRank)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqCompositeExchange)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqCompositeBroadcast)
end

function CompositeViewCtr:OnPushActivity(data)
	if data.ActivityId == CC.shared_enums_pb.AE_Compose then
		if self.view then
			self.view:InsertBroadCastResp(0,Json.decode(data.Msg))
		end
	end
end

function CompositeViewCtr:ExchangeReq(materialID,materialNum)
	-- log("ExchangeReq MaterialID:"..tostring(materialID).." MaterialNum:"..tostring(materialNum))
	CC.Request("ReqCompositeExchange",{
		MaterialID = materialID,
		MaterialNum = materialNum,
	})
end

function CompositeViewCtr:ExchangeResp(code,data)
	-- log("***兑换道具数据***code:"..tostring(code).." data:"..tostring(data))
	if self.view then
		self.view:ExchangeResp(code,data)
	end
end

function CompositeViewCtr:CompositeReq(assemblyID,useDiamond,times)
	-- log("CompositeReq ComposeID:"..tostring(assemblyID).." IsRaise:"..tostring(useDiamond).." ComposeTimes:"..times)
	CC.Request("ReqCompositeDo",{
		ComposeID = assemblyID,
		IsRaise = useDiamond,
		ComposeTimes = times,
	})
end

function CompositeViewCtr:CompositeResp(code,data)
	-- log("***合成结果数据***code:"..tostring(code).." data:"..tostring(data))
	--522代表还有未领取的JP
	if code == 522 then
		self:HasJPReq()
		return
	end
	if self.view then
		self.view:CompositeResp(code,data)
	end
end

function CompositeViewCtr:GetJPReq()
	CC.Request("ReqCompositeGetJP")
end

function CompositeViewCtr:GetJPResp(code,data)
	-- log("***领取JP数据***code:"..tostring(code).." data:"..tostring(data))
	if self.view then
		self.view:GetJPResp(code,data)
	end
end

function CompositeViewCtr:HasJPReq()
	CC.Request("ReqCompositeHasJP")
end

function CompositeViewCtr:HasJPResp(code,data)
	-- log("***是否命中JP数据***code:"..tostring(code).." data:"..tostring(data))
	if self.view then
		self.view:HasJPResp(code,data)
	end
end

function CompositeViewCtr:BroadcastReq()
	CC.Request("ReqCompositeBroadcast")
end

function CompositeViewCtr:BroadcastResp(code,data)
	-- log("***广播数据***code:"..tostring(code).." data:"..tostring(data))
	if self.view then
		self.view:InitBroadCastResp(code,data)
	end
end

function CompositeViewCtr:JPReq()
	CC.Request("ReqCompositeJPPool")
end

function CompositeViewCtr:JPResp(code,data)
	-- log("***JP池子数据***code:"..tostring(code).." data:"..tostring(data))
	if self.view then
		self.view:JPResp(code,data)
	end
end

function CompositeViewCtr:MulRankReq(typeVal)
	CC.Request("ReqCompositeMulRank",{type = typeVal})
end

function CompositeViewCtr:MulRankResp(code,data)
	-- log("***排行榜数据***code:"..tostring(code).." data:"..tostring(data))
	if self.view then
		self.view:RankResp(code,data)
	end
end

function CompositeViewCtr:GetCahceData()
	local tab = CC.UserData.Load(compositeCachePath, {
		isNew = true,
		cacheVersion = 0,
		cancelExchangeTip = false,
		canShowIconTip = true,
		canShowChangeTip = true,
	})
	self.isNew = tab.isNew
	self.cacheVersion = tab.cacheVersion
	self.cancelExchangeTip = tab.cancelExchangeTip
	self.canShowIconTip = tab.canShowIconTip
	self.canShowChangeTip = tab.canShowChangeTip
end

function CompositeViewCtr:SaveCacheData()
	CC.UserData.Save(compositeCachePath, {
		isNew = self.isNew,
		cacheVersion = self.cacheVersion,
		cancelExchangeTip = self.cancelExchangeTip,
	})
end

function CompositeViewCtr:OnFocusIn()

end

function CompositeViewCtr:OnDestroy()
	self:SaveCacheData()
	self:UnRegisterEvent()
end

return CompositeViewCtr