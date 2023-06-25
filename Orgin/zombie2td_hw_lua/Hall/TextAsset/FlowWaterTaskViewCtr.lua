local CC = require("CC")
local FlowWaterTaskViewCtr = CC.class2("FlowWaterTaskViewCtr")

function FlowWaterTaskViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function FlowWaterTaskViewCtr:InitVar(view,param)
	self.param = param
	self.view = view
	self.curTaskId = nil
end

function FlowWaterTaskViewCtr:OnCreate()
	self:RegisterEvent()
	self:ReqFlowTaskList()
end

function FlowWaterTaskViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.TaskListResp,CC.Notifications.NW_ReqFlowTaskList)
    CC.HallNotificationCenter.inst():register(self,self.OnShareTaskRsp,CC.Notifications.NW_ReqFlowTaskShare)
    CC.HallNotificationCenter.inst():register(self, self.OnChangeProp, CC.Notifications.changeSelfInfo)
end

function FlowWaterTaskViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function FlowWaterTaskViewCtr:SortTaskList(tab)
	table.sort(tab, function(a,b) return a.ID < b.ID end )
	local finishTab = {}
	local activeTab = {}
	local overTab = {}
	local sortTab = {}
	local taskTab = {}
	for i = 1, #tab do
		if tab[i].Status == 0 then
            activeTab[#activeTab + 1] = tab[i]
        elseif tab[i].Status == 1 then
            overTab[#overTab + 1] = tab[i]
        elseif tab[i].Status == 2 then
            finishTab[#finishTab + 1] = tab[i]
		else
			taskTab[#taskTab + 1] = tab[i]
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
	return sortTab, taskTab
end

function FlowWaterTaskViewCtr:ReqFlowTaskList()
	CC.Request("ReqFlowTaskList")
end

function FlowWaterTaskViewCtr:TaskListResp(err, param)
	log(CC.uu.Dump(param, "TaskListResp", 10))
	if err == 0 then
		if param.FlowTaskList then
            local taskInfoList = self:SortTaskList(param.FlowTaskList)
            CC.uu.Log(taskInfoList,"taskInfoList:")
            if #taskInfoList > 0 then
                self.view:InitTaskInfo(taskInfoList)
            end
        end
	end
end

function FlowWaterTaskViewCtr:OnShareTaskRsp(err,data)
	if err ~= 0 then
		logError("ReqFlowTaskShare err:"..err)
		return
	end
	self:ReqFlowTaskList()
end

--领取流水任务奖励
function FlowWaterTaskViewCtr:ReqFlowTaskReceive(taskId, level)
	--同时只能有一个奖励领取
	if self.curTaskId then return end
	self.curTaskId = taskId
	CC.Request("ReqFlowTaskReceive", {TaskID = taskId, Level = level})
end

function FlowWaterTaskViewCtr:OnChangeProp(props,source)
    if source == CC.shared_transfer_source_pb.TS_WorldCup_Share_Task or source == CC.shared_transfer_source_pb.TS_WorldCup_Capture_Task
        or source == CC.shared_transfer_source_pb.TS_WorldCup_Comprehensive_Task then
        local cb = function()
			self:ReqFlowTaskList()
			self.curTaskId = nil
		end
		CC.ViewManager.OpenRewardsView({items = props, callback = cb});
	end
end

function FlowWaterTaskViewCtr:Destroy()
	self:unRegisterEvent()
end

return FlowWaterTaskViewCtr