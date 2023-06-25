local CC = require("CC")
local AgentTaskView = CC.uu.ClassView("AgentTaskView")

function AgentTaskView:ctor()
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView");

	self.curSortType = CC.proto.client_agent_pb.SortByLastActivityTime
end

function AgentTaskView:OnCreate()
	self.itemlist = {}
	self:RegisterEvent()
	self:InitContent()
	self:InitTextLanguage()
	self:InitItem()
	self:LoadPromoteTask()
end

function AgentTaskView:InitContent()
	self:AddClick(self:FindChild("Panel/closeBtn"),slot(self.ActionOut, self))

	self.itemPrefab = self:FindChild("Panel/content/item")
    self.itemParent = self:FindChild("Panel/content/mid")

	self:AddClick(self:FindChild("mask"), function()
        self:FindChild("Panel/tipFrame"):SetActive(false)
    end)
    self:AddClick(self:FindChild("Panel/tipBtn"), function()
        self:FindChild("Panel/tipFrame"):SetActive(true)
    end)
	self:AddClick(self:FindChild("Panel/shareBtn"), function()
		self:ActionOut()
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnChangeAgentView, "AgentShareView")
    end)
	self:AddClick(self:FindChild("Panel/BtnAll"), function()
        CC.Request("PromoteTaskReceive", {taskType = CC.proto.client_agent_pb.CollectAllType})
    end)
end

function AgentTaskView:InitTextLanguage()
    self:FindChild("Panel/title").text = self.language.taskTitle
	self:FindChild("Panel/TipText").text = self.language.taskTipText
    self:FindChild("Panel/shareBtn/Text").text = self.language.taskShare
    self:FindChild("Panel/content/top/nameText").text = self.language.taskName
	self:FindChild("Panel/content/top/rewardText").text = self.language.taskReward
    self:FindChild("Panel/content/top/completionText").text = self.language.taskCompletion
    self:FindChild("Panel/content/top/earnText").text = self.language.taskEarn
    self:FindChild("Panel/tipFrame/Text").text = self.language.taskTip
	self:FindChild("Panel/totalEarn/Text").text = self.language.totalEarn
	self:FindChild("Panel/BtnAll/Text").text = self.language.btnAll

    self.itemPrefab:FindChild("completionText"):GetComponent("RichText").text = self.language.taskUndone
    self.itemPrefab:FindChild("lookBtn"):GetComponent("RichText").text = self.language.taskLook
    self.itemPrefab:FindChild("getBtn/Text").text = self.language.taskGet
	self:FindChild("Panel/content/Lock/Text").text = self.language.auditPeriod
end

function AgentTaskView:InitItem()
	local rewardTab = {2000, 2000, 10000}
	for i = 1, 3 do
		local index = i
		local obj = CC.uu.newObject(self.itemPrefab, self.itemParent)
		obj:SetActive(true)
        obj:FindChild("bg"):SetActive(index % 2 ~= 0)
		obj:FindChild("nameText").text = self.language.agentTask[index]
		obj:FindChild("rewardText").text = rewardTab[index]
		self.itemlist[i] = obj
	end

	if self.agentDataMgr.GetAgentLockStatus() then
        self:FindChild("Panel/BtnAll"):SetActive(false)
        self:FindChild("Panel/content/Lock"):SetActive(true)
        local time = os.date("%d-%m-%Y %H:%M",self.agentDataMgr.GetAgentLockTime())
        self:FindChild("Panel/content/Lock/Time").text = string.format(self.language.auditTime, time)
    end
end

function AgentTaskView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.PromoteTaskResp, CC.Notifications.NW_PromoteTask)
	CC.HallNotificationCenter.inst():register(self,self.PromoteTaskReceiveResp, CC.Notifications.NW_PromoteTaskReceive)
end

function AgentTaskView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_PromoteTask)
	CC.HallNotificationCenter.inst():register(self, CC.Notifications.NW_PromoteTaskReceive)
end

function AgentTaskView:LoadPromoteTask()
	CC.Request("PromoteTask")
end

function AgentTaskView:PromoteTaskResp(err, data)
	log("err = ".. err.."  "..CC.uu.Dump(data, "PromoteTask",10))
	local list = data.promoteTask
	if not list then return end

	local totalEarn = 0
	for _,v in ipairs(list) do
		self:UpdateItem(v)
		totalEarn = totalEarn + v.earn
	end
	self:FindChild("Panel/totalEarn").text = CC.uu.ChipFormat(totalEarn)
end

function AgentTaskView:UpdateItem(param)
	local taskType = param.taskType
	local index = taskType - 4
	if index > #self.itemlist then return end
	local obj = self.itemlist[index]
    if obj then
		if param.earn then
			obj:FindChild("earnText").text = CC.uu.ChipFormat(param.earn)
			-- obj:FindChild("getBtn"):SetActive(param.earn > 0)
			-- self:AddClick(obj:FindChild("getBtn"), function()
			-- 	CC.Request("PromoteTaskReceive", {taskType = taskType})
			-- end)
		end
		if param.accomplishCount then
			obj:FindChild("numText"):GetComponent("RichText").text = param.accomplishCount
			obj:FindChild("numText"):SetActive(param.accomplishCount > 0)
			obj:FindChild("completionText"):SetActive(param.accomplishCount <= 0)
		end
		self:AddClick(obj:FindChild("lookBtn"), function()
			CC.ViewManager.Open("AgentUnderlingView", {lookType = taskType})
		end)
    end
end

function AgentTaskView:PromoteTaskReceiveResp(err, param)
	log("err = ".. err.."  "..CC.uu.Dump(param, "PromoteTaskReceive",10))
	if err == 0 then
		local earn = param.earn
		local configId = param.propID
		local data = {{ConfigId = configId, Count = earn}}
		CC.ViewManager.OpenRewardsView({items = data})
		self:LoadPromoteTask()
	end
end

function AgentTaskView:OnDestroy()
	self:unRegisterEvent()
end

return AgentTaskView