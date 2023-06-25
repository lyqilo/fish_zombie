local CC = require("CC")

local OnlineAwardCtr = CC.class2("OnlineAwardCtr")

function OnlineAwardCtr:ctor(view)
	self:InitVar(view);
end

function OnlineAwardCtr:InitVar(view)
	self.view = view

	self:RegisterEvent()
end

function OnlineAwardCtr:OnCreate()
	self:RefreshAwardInfo()
end

function OnlineAwardCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnlineRewardInfo, CC.Notifications.NW_GetOnlineRewardInfo)
	CC.HallNotificationCenter.inst():register(self, self.TakeOnlineReward, CC.Notifications.NW_TakeOnlineReward)
	--充值成功推送
	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function OnlineAwardCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetOnlineRewardInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_TakeOnlineReward)
	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

function OnlineAwardCtr:OnPurchaseSuccess()
	self:RefreshAwardInfo()
end

function OnlineAwardCtr:OnlineRewardInfo(err,data)
	if err == 0 then
		self.view:RefresState(data)
	else
		self.view:RefresState({err = 318})
		logError("GetOnlineRewardInfo err:"..err)
	end
end

function OnlineAwardCtr:TakeOnlineReward(err,data)
	if err == 0 then
		self.view:OpenReward(data)
	else
		self:RefreshAwardInfo()
		logError("TakeOnlineReward err:"..err)
	end
end

function OnlineAwardCtr:RefreshAwardInfo()
	local playerId=CC.Player.Inst():GetSelfInfoByKey("Id") 
    CC.Request("GetOnlineRewardInfo",{PlayerId=playerId})
end

function OnlineAwardCtr:TakeOnlineAward(num)
	local data = {}
	data.PlayerId=CC.Player.Inst():GetSelfInfoByKey("Id")
	data.RewardId=num
	CC.Request("TakeOnlineReward",data)
end

function OnlineAwardCtr:Destroy()
	self:unRegisterEvent()
end

return OnlineAwardCtr