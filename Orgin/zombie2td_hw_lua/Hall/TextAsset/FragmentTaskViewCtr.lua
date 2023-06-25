local CC = require("CC")
local FragmentTaskViewCtr = CC.class2("FragmentTaskViewCtr")

function FragmentTaskViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function FragmentTaskViewCtr:InitVar(view,param)
	self.param = param
	self.view = view
	--当前任务奖励id
	self.curTaskId = nil
end

function FragmentTaskViewCtr:OnCreate()
	self:RegisterEvent()
end

function FragmentTaskViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.TaskListResp,CC.Notifications.NW_ReqTaskListInfo)
	CC.HallNotificationCenter.inst():register(self,self.ReqAcquireRewardResq,CC.Notifications.NW_ReqGetBoxReward)
	--碎片礼包购买
	CC.HallNotificationCenter.inst():register(self,self.DailyGiftFragment,CC.Notifications.OnDailyGiftGameReward)
end

function FragmentTaskViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqTaskListInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetBoxReward)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
end

function FragmentTaskViewCtr:DailyGiftFragment(data)
	if data.Source == CC.shared_transfer_source_pb.TS_CardFragment_Treasure_143 or data.Source == CC.shared_transfer_source_pb.TS_CardFragment_Treasure_49 then
		self:ReqTaskListInfo()
	end
end

--任务列表信息
function FragmentTaskViewCtr:ReqTaskListInfo()
	CC.Request("ReqTaskListInfo")
end

function FragmentTaskViewCtr:TaskListResp(err, param)
	log(CC.uu.Dump(param, "TaskListResp", 10))
	if err == 0 then
		if param.BoxTaskList then
			--活跃度任务
			for _, v in ipairs(param.BoxTaskList) do
				self.view:SetLivenessStatus(v)
			end
		end
	end
end

function FragmentTaskViewCtr:ReqAcquireReward(taskId)
	--同时只能有一个奖励领取
	if self.curTaskId then return end
	logError("领取".. taskId)
	self.curTaskId = taskId
	CC.Request("ReqGetBoxReward", {TaskID = taskId})
end

function FragmentTaskViewCtr:ReqAcquireRewardResq(err, param)
	log(CC.uu.Dump(param, "ReqAcquireRewardResq", 10))
	if err == 0 and self.curTaskId then
		if not param.AwardList then
			return
		end
		local data = {};
		for k, v in ipairs(param.AwardList) do
			data[k] = {}
			data[k].ConfigId = v.PropID
            data[k].Count = v.PropNum
		end
		local Cb = function ()
			self:ReqTaskListInfo()
			self.curTaskId = nil
		end
		CC.ViewManager.OpenRewardsView({items = data, callback = Cb})
	else
		self.curTaskId = nil
	end
end

function FragmentTaskViewCtr:Destroy()
	self:unRegisterEvent()
end

return FragmentTaskViewCtr