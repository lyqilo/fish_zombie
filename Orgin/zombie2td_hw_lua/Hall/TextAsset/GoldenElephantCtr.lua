
---------------------------------
-- region GoldenElephantCtr.lua    -
-- Date: 2019.11.22        -
-- Desc: 金象礼包  -
-- Author: Bin        -
---------------------------------
local CC = require("CC")

local GoldenElephantCtr = CC.uu.ClassView("GoldenElephantCtr")

function GoldenElephantCtr:ctor(view, param)

	self:InitVar(view, param);
end

function GoldenElephantCtr:InitVar(view, param)

	self.view = view;
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	--等待时间
	self.dalayTime = 0;
	--砸金象动画是否结束
	self.animEnd = false
	self.Mystery = false
	self.baseCount = 0
	self.mysteryCount = 0
end

function GoldenElephantCtr:OnCreate()
	self:RegisterEvent();
end

function GoldenElephantCtr:ReqElephant()
	CC.Request("ReqElephantPiggy")
end

function GoldenElephantCtr:ReqElephantRecord()
	CC.Request("ReqElephantPiggyRecord")
end

function GoldenElephantCtr:OnElephantPiggyRecordRsp(err, result)
	log("err = ".. err.."  "..CC.uu.Dump(result,"ReqElephantPiggyRecord",10))
	if err == 0 then
		self.view:InitListData(result.Records)
	end
end

function GoldenElephantCtr:ReqElephantPiggyRsp(err, result)
	log("err = ".. err.."  "..CC.uu.Dump(result,"ReqElephantPiggy",10))
	if err == 0 then
		self.view:BaseData(result.Info)
	end
end

function GoldenElephantCtr:MarkAnimState(state)
	self.animEnd = state
end

function GoldenElephantCtr:OnPay()
    local wareId = CC.PaymentManager.GetActiveWareIdByKey("elephant")
    local ware = self.wareCfg[wareId]
    local data = {}
    data.wareId = ware.Id
	data.subChannel = ware.SubChannel
	data.price = ware.Price
	data.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	log(CC.uu.Dump(data,"datapay",10))
    CC.PaymentManager.RequestPay(data);
end

function GoldenElephantCtr:OnRefreshPropChange(props, source)
	log(CC.uu.Dump(props,"props",10))
	log(CC.uu.Dump(source,"source",10))
	local ChouMa = 0
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
			ChouMa = v.Delta
		end
	end
	if source == CC.shared_transfer_source_pb.TS_ElephantPiggy then
		self.view:PlayGoldAnim(ChouMa)
	elseif source == CC.shared_transfer_source_pb.TS_LevelUp then
		self.view:SetVipUpChouMa(ChouMa)
	end
end

--是否有神秘象
function GoldenElephantCtr:OnMysteryElephantPiggy(data)
	log(CC.uu.Dump(data,"神秘奖data",10))
	self.Mystery = true
	self.baseCount = data.Base
	self.mysteryCount = data.Mystery
end

function GoldenElephantCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshPropChange,CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnMysteryElephantPiggy,CC.Notifications.MysteryElephantPiggy)
	CC.HallNotificationCenter.inst():register(self,self.OnElephantPiggyRecordRsp,CC.Notifications.NW_ReqElephantPiggyRecord)
	CC.HallNotificationCenter.inst():register(self,self.ReqElephantPiggyRsp,CC.Notifications.NW_ReqElephantPiggy)
end

function GoldenElephantCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.MysteryElephantPiggy)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqElephantPiggyRecord)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqElephantPiggy)
end

function GoldenElephantCtr:StartUpdate()
	UpdateBeat:Add(self.Update,self);
end

function GoldenElephantCtr:StopUpdate()
	UpdateBeat:Remove(self.Update,self);
end

function GoldenElephantCtr:Update()
	self.dalayTime = self.dalayTime + Time.deltaTime
	if self.dalayTime >= 4  then
		self.dalayTime = 0
		self.view:AutoRoll()
	end
end

function GoldenElephantCtr:OnDestroy()
	self:StopUpdate()
	self:UnRegisterEvent()
end

return GoldenElephantCtr;