-- region TaskManager.lua
-- Date: 2017.10.27
-- Desc: 任务管理类
-- Author: Chaoe

local CC = require("CC")

local TaskManager = CC.class2("TaskManager")

local taskMgr = nil
function TaskManager.Inst()
	if not taskMgr then
		taskMgr = TaskManager.new()
	end
	return taskMgr
end

function TaskManager:ctor()
	self.LoginAwardData = nil	--登陆奖励数据
end

function TaskManager:PushLoginAwardData(data)
	taskMgr.LoginAwardData = data
end

function TaskManager:GetLoginAwardData()
	return taskMgr.LoginAwardData
end

function TaskManager:SetOpenState()
	taskMgr.LoginAwardData = nil
end

return TaskManager

