local CC = require("CC")
local NewbieTaskViewCtr = CC.class2("NewbieTaskViewCtr")

function NewbieTaskViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function NewbieTaskViewCtr:InitVar(view,param)
	self.param = param
	self.view = view
	self.languageName = {}
	self.languageReward = {}
	self.taskInfoList = {}
	--当前任务奖励id
	self.curTaskId = nil
	--今天是否签到过
	self.isSign = false
	self.taskId = {1, 2, 3, 4, 7, 13, 14, 16, 17, 20}
end

function NewbieTaskViewCtr:OnCreate()
	self:InitData()
	self:RegisterEvent()
end

function NewbieTaskViewCtr:InitData()
	for _, v in pairs(self.taskId) do
		local taskName = "taskName" .. v
		self.languageName[v] = self.view.language[taskName]
		local taskReward = "taskReward" .. v
		if self.view.language[taskReward] then
			self.languageReward[v] = self.view.language[taskReward]
		end
	end
end

function NewbieTaskViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.TaskListResp,CC.Notifications.NW_ReqTaskListInfo)
	CC.HallNotificationCenter.inst():register(self,self.ReqAcquireRewardResq,CC.Notifications.NW_ReqGetReward)
	CC.HallNotificationCenter.inst():register(self,self.ReqAcquireRewardResq,CC.Notifications.NW_ReqGetBoxReward)
	--分享成功
	CC.HallNotificationCenter.inst():register(self,self.ReqTaskListInfo,CC.Notifications.NW_ReqOnClientShare)
end

function NewbieTaskViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqTaskListInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetReward)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetBoxReward)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqOnClientShare)
end

--任务名称
function NewbieTaskViewCtr:GetTaskName(taskId)
	local num = math.floor(taskId / 1000)
	local count = taskId % 1000
	local taskName = self.languageName[num]
	if num == 2 and count then
		--登陆任务
		if count == 2 then
			taskName = self.view.language["taskName2_3"]
		elseif count == 3 then
			taskName = self.view.language["taskName2_7"]
		end
	end
	return taskName
end

--任务大奖励名称
function NewbieTaskViewCtr:GetTaskReward(taskId)
	local num = math.floor(taskId / 1000)
	return self.languageReward[num] or ""
end

--任务列表排序
function NewbieTaskViewCtr:SortTaskList(tab)
	table.sort(tab, function(a,b) return a.ID < b.ID end )
	local finishTab = {}
	local activeTab = {}
	local overTab = {}
	local sortTab = {}
	for i = 1, #tab do
		if tab[i].IsFinish then
			if tab[i].IsReward then
				overTab[#overTab + 1] = tab[i]
			else
				finishTab[#finishTab + 1] = tab[i]
			end
		else
			local num = math.floor(tab[i].ID / 1000)
			if (num == 1 and self.isSign) or num == 2 or num == 3 or num == 16 then
				--第二天登陆和在线时长，进行中任务，但不能领取
				table.insert(overTab, 1, tab[i])
			else
				activeTab[#activeTab + 1] = tab[i]
			end
		end
	end
	--已完成任务，没领奖励
	for i = 1, #finishTab do
		sortTab[#sortTab + 1] = finishTab[i]
	end
	--进行中任务
	for i = 1, #activeTab do
		sortTab[#sortTab + 1] = activeTab[i]
	end
	--已结束任务
	for i = 1, #overTab do
		sortTab[#sortTab + 1] = overTab[i]
	end
	return sortTab
end

--任务列表信息
function NewbieTaskViewCtr:ReqTaskListInfo()
	CC.Request("ReqTaskListInfo")
end

function NewbieTaskViewCtr:TaskListResp(err, param)
	log(CC.uu.Dump(param, "TaskListResp", 10))
	if err == 0 then
		if param.IsNewTaskAllAward and param.IsBoxTaskAllAward then
			-- if CC.uu.isTable(param.NewTaskList) and #param.NewTaskList <= 0 then
				self.view:SwitchView()
			-- else
			-- 	self.view:NewbieTaskFinish()
			-- end
			-- self.view:NewbieTaskFinish()
			return
		end
		self.isSign = param.IsSign
		if param.BoxTaskList then
			--活跃度任务
			for _, v in ipairs(param.BoxTaskList) do
				self.view:SetLivenessStatus(v)
			end
		end
		if param.NewTaskList then
			--新手任务
			self.taskInfoList = self:SortTaskList(param.NewTaskList)
			local taskList = {}
			local ind = 1
			for i = 1, #self.taskInfoList do
				--任务信息
				taskList[ind] = self.taskInfoList[i]
				ind = ind + 1
			end
			if #taskList > 0 then
				self.view:InitTaskInfo(taskList)
			end
		end
	end
end

function NewbieTaskViewCtr:ReqAcquireReward(taskId)
	--同时只能有一个奖励领取
	if self.curTaskId then return end
	logError("领取".. taskId)
	self.curTaskId = taskId
	for _, v in pairs(self.view.livenessId) do
		if taskId == v then
			--活跃度任务奖励
			CC.Request("ReqGetBoxReward", {TaskID = taskId})
			return
		end
	end
	CC.Request("ReqGetReward", {TaskID = taskId})
end

function NewbieTaskViewCtr:ReqAcquireRewardResq(err, param)
	log(CC.uu.Dump(param, "ReqAcquireRewardResq", 10))
	if err == 0 then
		--local taskInfo = self.view.newbieTask[self.curTaskId]
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
		log(CC.uu.Dump(data))
		CC.ViewManager.OpenRewardsView({items = data, callback = Cb})
	else
		self.curTaskId = nil
	end
end

function NewbieTaskViewCtr:Destroy()
	self:unRegisterEvent()
end

return NewbieTaskViewCtr