
local CC = require("CC")
local ThirdGameTipViewCtr = CC.class2("ThirdGameTipViewCtr")

function ThirdGameTipViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function ThirdGameTipViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function ThirdGameTipViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
end

function ThirdGameTipViewCtr:InitData()

end

function ThirdGameTipViewCtr:RegisterEvent()

	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function ThirdGameTipViewCtr:UnRegisterEvent()

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

function ThirdGameTipViewCtr:Destroy()

	self:UnRegisterEvent();
end

return ThirdGameTipViewCtr;
