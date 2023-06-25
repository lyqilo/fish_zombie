
local CC = require("CC")
local WarningTipViewCtr = CC.class2("WarningTipViewCtr")

function WarningTipViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function WarningTipViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function WarningTipViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
end

function WarningTipViewCtr:InitData()

end

function WarningTipViewCtr:RegisterEvent()

	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function WarningTipViewCtr:UnRegisterEvent()

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

function WarningTipViewCtr:Destroy()

	self:UnRegisterEvent();
end

return WarningTipViewCtr;
