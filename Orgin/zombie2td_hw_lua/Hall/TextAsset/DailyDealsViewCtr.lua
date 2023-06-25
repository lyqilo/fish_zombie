
local CC = require("CC")
local DailyDealsViewCtr = CC.class2("DailyDealsViewCtr")

function DailyDealsViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function DailyDealsViewCtr:OnCreate()
	self:InitData();
	self:RegisterEvent();
end

function DailyDealsViewCtr:InitVar(view, param)

	self.param = param;
	self.view = view;
end

function DailyDealsViewCtr:InitData()
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");
	self.WareId = "com.huoys.royalcasino.FJ10"
end

function DailyDealsViewCtr:BuyAirDeals()
	
	local wareCfg = self.wareCfg[self.WareId]
	local param = {}
	param.wareId = wareCfg.Id
	param.subChannel = wareCfg.SubChannel
	param.price = wareCfg.Price
	param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	param.errCallback = function (err)
		if err == CC.shared_en_pb.WareAlreadyPurchased or err == CC.shared_en_pb.WareLocked then
			CC.ViewManager.ShowTip(self.view.language.tips_fishGift)
		end
	end
	CC.PaymentManager.RequestPay(param)
end

function DailyDealsViewCtr:RegisterEvent()
	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end



function DailyDealsViewCtr:UnRegisterEvent()

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

function DailyDealsViewCtr:Destroy()

	self:UnRegisterEvent();
end

return DailyDealsViewCtr;
