
local CC = require("CC")
local TemplateViewCtr = CC.class2("TemplateViewCtr")

function TemplateViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function TemplateViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function TemplateViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
end

function TemplateViewCtr:InitData()

end

function TemplateViewCtr:RegisterEvent()

	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function TemplateViewCtr:UnRegisterEvent()

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

function TemplateViewCtr:Destroy()

	self:UnRegisterEvent();
end

return TemplateViewCtr;
