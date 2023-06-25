
local CC = require("CC")
local WorldCupTipsViewCtr = CC.class2("WorldCupTipsViewCtr")

function WorldCupTipsViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function WorldCupTipsViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function WorldCupTipsViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
end

function WorldCupTipsViewCtr:InitData()

end

function WorldCupTipsViewCtr:RegisterEvent()

	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function WorldCupTipsViewCtr:UnRegisterEvent()

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

function WorldCupTipsViewCtr:Destroy()

	self:UnRegisterEvent();
end

return WorldCupTipsViewCtr;
