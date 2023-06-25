
local CC = require("CC")
local TotalTipsViewCtr = CC.class2("TotalTipsViewCtr")

function TotalTipsViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function TotalTipsViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function TotalTipsViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;

	self.RewardConfig = {{rank = "1",rew1 = {id = 20118,count = 1},rew2 = {id = 20118,count = 1}},
                         {rank = "2",rew1 = {id = 20109,count = 1},rew2 = {id = 20109,count = 1}},
                         {rank = "3",rew1 = {id = 20116,count = 1},rew2 = {id = 20116,count = 1}},
                         {rank = "4",rew1 = {id = 2,count = "20M"},rew2 = {id = 2,count = "20M"}},
                         {rank = "5",rew1 = {id = 2,count = "15M"},rew2 = {id = 2,count = "15M"}},
                         {rank = "6-10",rew1 = {id = 2,count = "10M"},rew2 = {id = 2,count = "10M"}},
                         {rank = "11-20",rew1 = {id = 2,count = "5M"},rew2 = {id = 2,count = "5M"}},
                         {rank = "21-30",rew1 = {id = 2,count = "3M"},rew2 = {id = 2,count = "3M"}},
                         {rank = "31-60",rew1 = {id = 2,count = "2M"},rew2 = {id = 2,count = "2M"}},
                         {rank = "61-100",rew1 = {id = 2,count = "1M"},rew2 = {id = 2,count = "1M"}},
                        }
end

function TotalTipsViewCtr:InitData()

end

function TotalTipsViewCtr:RegisterEvent()

	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function TotalTipsViewCtr:UnRegisterEvent()

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

function TotalTipsViewCtr:Destroy()

	self:UnRegisterEvent();
end

return TotalTipsViewCtr;
