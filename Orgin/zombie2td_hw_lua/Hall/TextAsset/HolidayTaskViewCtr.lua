local CC = require("CC")
local HolidayTaskViewCtr = CC.class2("HolidayTaskViewCtr")

function HolidayTaskViewCtr:ctor(view,param)
	self:InitVar(view,param)
end

function HolidayTaskViewCtr:InitVar(view,param)
    self.view = view
	self.param = param
	self.recList = {}
	self.curLevel = nil
	self.unlockGift = nil
end

function HolidayTaskViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnActivityInfoRsp,CC.Notifications.NW_Req_UW_GetTask)
	CC.HallNotificationCenter.inst():register(self,self.OnGetWinPrizeListRsp,CC.Notifications.NW_Req_UW_GetWinPrizeList)
	CC.HallNotificationCenter.inst():register(self,self.OnShareTaskRsp,CC.Notifications.NW_Req_UW_ShareTask)
	CC.HallNotificationCenter.inst():register(self,self.OnUpgradeRsp,CC.Notifications.NW_Req_UW_Upgrade)
	CC.HallNotificationCenter.inst():register(self,self.OnPropChange,CC.Notifications.changeSelfInfo)
end

function HolidayTaskViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function HolidayTaskViewCtr:OnCreate()
	self:RegisterEvent()
	self:ReqActivityInfo()
	self:ReqGetWinPrizeList()
	self.view:StartTimer("Timer", 30, function ()
		self:ReqGetWinPrizeList()
	end, -1)
end

function HolidayTaskViewCtr:ReqActivityInfo()
	CC.Request("Req_UW_GetTask")
end

function HolidayTaskViewCtr:OnActivityInfoRsp(err,data)
	if err ~= 0 then
		self.view:SetCanClick(true)
		logError("Req_UW_GetTask err:"..err)
		return
	end
	CC.uu.Log(data,"Req_UW_GetTask Rsp:",1)
	local actInfo = {}
	actInfo.jackpot = data.JP
	
	actInfo.taskInfo = {}
	actInfo.taskInfo.status = data.Status
	actInfo.taskInfo.level = data.Level
	actInfo.taskInfo.complete = data.Complete
	actInfo.taskInfo.directStatus = data.DirectStatus
	actInfo.taskInfo.taskList = {}
	for k,v in ipairs(data.SubTask) do
		actInfo.taskInfo.taskList[k] = v
	end
	
	actInfo.rewards = {}
	for k,v in ipairs(data.RewardsList) do
		actInfo.rewards[k] = {}
		actInfo.rewards[k].ConfigId = v.PropID
		actInfo.rewards[k].Count = v.PropNum
	end
	
	--if not self.curLevel then
		self.curLevel = data.Level
		self.view:RefreshSandTower(data.Level)
	--elseif self.curLevel ~= data.Level then
		--self.curLevel = data.Level
		--self.view:RefreshSandTower(data.Level,true)
	--end
	
	self.unlockGift = data.UWUnlockGift
	
	self.view:RefreshUI(actInfo)
	self.view:SetCanClick(true)
end

function HolidayTaskViewCtr:ReqGetWinPrizeList()
	CC.Request("Req_UW_GetWinPrizeList")
end

function HolidayTaskViewCtr:OnGetWinPrizeListRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_GetWinPrizeList err:"..err)
		return
	end
	CC.uu.Log(data,"Req_UW_GetWinPrizeList Rsp:",1)
	local param = {}
	param.jackpot = data.Jp
	param.recList = {}
	param.marqueeList = {}
	for k,v in ipairs(data.List) do
		if k <= 20 then
			param.marqueeList[k] = {name = v.Nick, id = v.PropID, num = v.PropNum}
		end
		param.recList[k] = v
	end
	self.recList = param.recList
	
	self.view:RefreshUI(param)
end

function HolidayTaskViewCtr:ReqUpgrade()
	CC.Request("Req_UW_Upgrade")
end

function HolidayTaskViewCtr:OnUpgradeRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_Upgrade err:"..err)
		return
	end
	local rewards = {}
	if data.Prop then
		for _,v in ipairs(data.Prop) do
			table.insert(rewards,{ConfigId = v.PropID, Count = v.PropNum})
		end
	end
	
	local param = {}
	param.items = rewards
	param.splitState = true
	
	if data.Jp and data.Jp > 0 then	
		table.insert(rewards,{ConfigId = 2, Count = data.Jp})
		self.view:ShowNumberRoller(data.Jp,function ()
			--CC.ViewManager.Open("SpecialRewardsView", {items = rewards,towerLv = self.curLevel+1})
			CC.ViewManager.OpenRewardsView(param)
			self:ReqActivityInfo()
		end)
	else
		--CC.ViewManager.Open("SpecialRewardsView", {items = rewards,towerLv = self.curLevel+1})
		CC.ViewManager.OpenRewardsView(param)
		self:ReqActivityInfo()
	end

end

function HolidayTaskViewCtr:ReqShareTask()
	CC.Request("Req_UW_ShareTask")
end

function HolidayTaskViewCtr:OnShareTaskRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_ShareTask err:"..err)
		return
	end
	self:ReqActivityInfo()
end

function HolidayTaskViewCtr:OnPropChange(props,source)

	if source == CC.shared_transfer_source_pb.TS_Splash_Unlock_1 or
		source == CC.shared_transfer_source_pb.TS_Splash_Unlock_2 or
		source == CC.shared_transfer_source_pb.TS_Splash_Unlock_3 or
		source == CC.shared_transfer_source_pb.TS_Splash_Unlock_4 or
		source == CC.shared_transfer_source_pb.TS_Splash_Unlock_5 then

		CC.ViewManager.OpenRewardsView({items = props});
	end
end

function HolidayTaskViewCtr:Destroy()
	self.view:StopTimer("Timer")
	self:UnRegisterEvent()
end

return HolidayTaskViewCtr