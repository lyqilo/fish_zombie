local CC = require("CC")
local CrystalStoreViewCtr = CC.class2("CrystalStoreViewCtr")

function CrystalStoreViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function CrystalStoreViewCtr:InitVar(view, param)
	self.param = param;
    self.view = view;
    self.MessageList = {}
	CC.Request("ReqGetGoodsList",{Type = CC.proto.client_shop_pb.CrystalShop})
end

function CrystalStoreViewCtr:OnCreate()
    self:RegisterEvent()
end

function CrystalStoreViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.ReqGetGoodsList,CC.Notifications.NW_ReqGetGoodsList)
    CC.HallNotificationCenter.inst():register(self,self.ReqGoodsBuyResp,CC.Notifications.NW_ReqGoodsBuy)
end

function CrystalStoreViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetGoodsList)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGoodsBuy)
end

function CrystalStoreViewCtr:ReqGetGoodsList(err,data)
	log(CC.uu.Dump(data, "ReqGetGoodsList"))
	if err == 0 and data.GoodList and #data.GoodList > 0 then
		local wareList = {}
		for i,v in ipairs(data.GoodList) do
			if self.view.physicalShopCfg[tostring(v.ID)] and v.Currency == CC.shared_enums_pb.EPC_Crystal then
                table.insert(wareList,v)
            else
                log("当前水晶商城配置中暂无该商品配置或该商品不可用水晶兑换 wareID:"..v.ID)
			end
		end
		self.view:InitStore(wareList)
	end
end

function CrystalStoreViewCtr:ReqGoodsBuyResp(err,data)
	self.view:RefreshCrystal()
end

function CrystalStoreViewCtr:Destroy()
	self:UnRegisterEvent()
end

return CrystalStoreViewCtr
