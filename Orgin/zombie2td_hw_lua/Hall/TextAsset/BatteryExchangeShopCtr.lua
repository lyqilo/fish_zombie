local CC = require("CC")
local BatteryExchangeShopCtr = CC.class2("BatteryExchangeShopCtr")

function BatteryExchangeShopCtr:ctor(view, param)
	self:InitVar(view, param);
end

function BatteryExchangeShopCtr:InitVar(view, param)
	self.param = param
	self.view = view
end

function BatteryExchangeShopCtr:OnCreate()
    self:RegisterEvent()
    self:ReqInfo()
end

function BatteryExchangeShopCtr:ReqInfo()
    CC.Request("ReqGetExchangeList", {ActivitId = CC.shared_enums_pb.AE_CommonBattery, From = 1, To = 50})
end

function BatteryExchangeShopCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqGetExchangeListResp,CC.Notifications.NW_ReqGetExchangeList)
    CC.HallNotificationCenter.inst():register(self,self.OnPropChange,CC.Notifications.changeSelfInfo)
end

function BatteryExchangeShopCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function BatteryExchangeShopCtr:ReqGetExchangeListResp(err,data)
	log(CC.uu.Dump(data, "ReqGetExchangeList:"))
	if err == 0 then
        self.view:UpdateShop(data.ExchangeList)
	end
end

function BatteryExchangeShopCtr:OnPropChange(props, source)
    local BatteryId = nil
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_TaiJi_Totem then
            self:ReqInfo()
		end
        if self.view.batteryList[v.ConfigId] then
            BatteryId = v.ConfigId
        end
	end
    if source == CC.shared_transfer_source_pb.TS_Fourbeasts_Shop then
        if BatteryId then
            CC.ViewManager.Open("CompoundPanel", {batteryType = BatteryId})
        else
            CC.ViewManager.OpenRewardsView({items = props})
        end
    end
end

function BatteryExchangeShopCtr:Destroy()
	self:UnRegisterEvent()
end

return BatteryExchangeShopCtr;
