
local CC = require("CC")
local WorldCupADPageViewCtr = CC.class2("WorldCupADPageViewCtr")

function WorldCupADPageViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function WorldCupADPageViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function WorldCupADPageViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
end

function WorldCupADPageViewCtr:InitData()

end

function WorldCupADPageViewCtr:RegisterEvent()

	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function WorldCupADPageViewCtr:UnRegisterEvent()

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

function WorldCupADPageViewCtr:Destroy()

	self:UnRegisterEvent();
end

return WorldCupADPageViewCtr;
