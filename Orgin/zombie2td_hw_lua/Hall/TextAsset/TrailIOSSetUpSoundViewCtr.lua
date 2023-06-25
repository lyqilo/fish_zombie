
local CC = require("CC")
local TrailIOSSetUpSoundViewCtr = CC.class2("TrailIOSSetUpSoundViewCtr")

function TrailIOSSetUpSoundViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function TrailIOSSetUpSoundViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function TrailIOSSetUpSoundViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
end

function TrailIOSSetUpSoundViewCtr:InitData()

end

function TrailIOSSetUpSoundViewCtr:RegisterEvent()

	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function TrailIOSSetUpSoundViewCtr:UnRegisterEvent()

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

function TrailIOSSetUpSoundViewCtr:Destroy()

	self:UnRegisterEvent();
end

return TrailIOSSetUpSoundViewCtr;
