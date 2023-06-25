local CC = require("CC")
local ChristmasTaskViewCtr = CC.class2("ChristmasTaskViewCtr")

function ChristmasTaskViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function ChristmasTaskViewCtr:InitVar(view,param)
	self.param = param
	self.view = view
	--当前任务奖励id
    self.curTaskId = nil
	self.rewardTab = {[1] = {{ConfigId = 2, Count = 500}, {ConfigId = 26, Count = 1},},
		[2] = {{ConfigId = 2, Count = 700}, {ConfigId = 26, Count = 1},},
		[3] = {{ConfigId = 2, Count = 1000}, {ConfigId = 3025, Count = 1},{ConfigId = 36, Count = 1},{ConfigId = 2, Count = -1},},
		[4] = {{ConfigId = 2, Count = 1200}, {ConfigId = 26, Count = 1},},
		[5] = {{ConfigId = 2, Count = 1500}, {ConfigId = 26, Count = 1},},
		[6] = {{ConfigId = 2, Count = 1800}, {ConfigId = 3026, Count = 1},{ConfigId = 36, Count = 1},{ConfigId = 2, Count = -1},},
		[7] = {{ConfigId = 2, Count = 2000}, {ConfigId = 26, Count = 1},},
		[8] = {{ConfigId = 2, Count = 2500}, {ConfigId = 26, Count = 1},},
		[9] = {{ConfigId = 2, Count = 3000}, {ConfigId = 3027, Count = 1},{ConfigId = 36, Count = 1},{ConfigId = 2, Count = -1},},
		[10] = {{ConfigId = 2, Count = 3500}, {ConfigId = 26, Count = 1},},
		[11] = {{ConfigId = 2, Count = 4000}, {ConfigId = 26, Count = 1},},
		[12] = {{ConfigId = 2, Count = 4500}, {ConfigId = 3028, Count = 1},{ConfigId = 36, Count = 1},{ConfigId = 2, Count = -1},},
		[13] = {{ConfigId = 2, Count = 5000}, {ConfigId = 26, Count = 1},},
		[14] = {{ConfigId = 2, Count = 5500}, {ConfigId = 3029, Count = 1},{ConfigId = 36, Count = 1},{ConfigId = 2, Count = -1},},
	}
	self.JpRatio = {[3] = "10%", [6] = "20%", [9] = "30%", [12] = "50%", [14] = "80%",}
	self.roleList = {[1] = {hp = 2000, jpNum = 3, role = 1}, [2] = {hp = 75, jpNum = 2, role = 1},
				[3] = {hp = 1000, jpNum = 1, role = 1}, [4] = {hp = 75, jpNum = 3, role = 2},
				[5] = {hp = 75, jpNum = 2, role = 2}, [6] = {hp = 200, jpNum = 1, role = 2},
				[7] = {hp = 75, jpNum = 3, role = 2}, [8] = {hp = 75, jpNum = 2, role = 2},
				[9] = {hp = 100, jpNum = 1, role = 2}, [10] = {hp = 75, jpNum = 3, role = 3},
				[11] = {hp = 75, jpNum = 2, role = 3}, [12] = {hp = 90, jpNum = 1, role = 3},
				[13] = {hp = 75, jpNum = 2, role = 3}, [14] = {hp = 75, jpNum = 1, role = 3},}
	self.taskIsFinish = false
	--点亮
	self.taskIsDone = false
end

function ChristmasTaskViewCtr:OnCreate()
	self:RegisterEvent()
end

function ChristmasTaskViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ChristTaskInfoResp,CC.Notifications.NW_ReqChristTaskInfo)
	CC.HallNotificationCenter.inst():register(self,self.ChristTaskJPResp,CC.Notifications.NW_ReqChristTaskJP)
	CC.HallNotificationCenter.inst():register(self,self.ChristTaskRecordResp,CC.Notifications.NW_ReqChristTaskRecord)
	CC.HallNotificationCenter.inst():register(self,self.ChristTaskRewardResq,CC.Notifications.NW_ReqChristTaskReward)
	--分享成功
	CC.HallNotificationCenter.inst():register(self,self.ReqChristTaskInfo,CC.Notifications.NW_ReqOnClientShare)
end

function ChristmasTaskViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqChristTaskInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqChristTaskJP)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqChristTaskRecord)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqChristTaskReward)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqOnClientShare)
end

--任务列表信息
function ChristmasTaskViewCtr:ReqChristTaskInfo()
	CC.Request("ReqChristTaskInfo")
end

function ChristmasTaskViewCtr:ChristTaskInfoResp(err, param)
	log(CC.uu.Dump(param, "ReqChristTaskInfo", 10))
	if err == 0 then
        if param:HasField("task") then
			self.view:InitTaskInfo(param.task)
			self.curTaskId = param.task.ChainProgress
			self.taskIsFinish = param.task.IsFinish
			self.taskIsDone = param.task.IsDone
		end
	end
end

--Jp数
function ChristmasTaskViewCtr:ReqChristTaskJP()
	CC.Request("ReqChristTaskJP")
end

function ChristmasTaskViewCtr:ChristTaskJPResp(err,param)
	log("err = ".. err.."  "..CC.uu.Dump(param, "ReqChristTaskJP",10))
	if err == 0 then
		self.view:SetJpNum(param.JackPot)
	end
end

--记录
function ChristmasTaskViewCtr:ReqChristTaskRecord()
	CC.Request("ReqChristTaskRecord")
end

function ChristmasTaskViewCtr:ChristTaskRecordResp(err,param)
	log("err = ".. err.."  "..CC.uu.Dump(param, "ReqChristTaskRecord",10))
	if err == 0 then
		self.view:SetAwardInfo(param.List)
	end
end

--点亮奖励
function ChristmasTaskViewCtr:ReqChristTaskReward()
	if self.taskIsDone then return end
	if not self.curTaskId or not self.taskIsFinish then
		CC.ViewManager.ShowTip(self.view.language.unFinish)
		return
	end
	CC.Request("ReqChristTaskReward", {ChainProgressIndex = self.curTaskId})
end

function ChristmasTaskViewCtr:ChristTaskRewardResq(err, param)
	log(CC.uu.Dump(param, "ReqChristTaskReward", 10))
	if err == 0 then
		local jpChouMa = 0
		for _,v in ipairs(param.jp_rewards) do
			if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
				jpChouMa = jpChouMa + v.Count
			end
		end
		local data = {};
		for k, v in ipairs(param.rewards) do
			data[k] = {}
			data[k].ConfigId = v.ConfigId
			data[k].Count = v.Count
		end
		local Cb = nil
		Cb = function()
			if jpChouMa > 0 then
				self.view:RewardGold(jpChouMa)
			end
		end
		CC.ViewManager.OpenOtherEx("SpecialRewardsView", {items = data, callback = Cb, curTaskId = self.curTaskId})
		self.view:InitTaskInfo(param.task)
		self.curTaskId = param.task.ChainProgress
		self.taskIsFinish = param.task.IsFinish
		self.taskIsDone = param.task.IsDone
	end
end

function ChristmasTaskViewCtr:Destroy()
	self:unRegisterEvent()
end

return ChristmasTaskViewCtr