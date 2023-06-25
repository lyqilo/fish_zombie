local CC = require("CC")
local MarsTaskViewCtr = CC.class2("MarsTaskViewCtr")
local M = MarsTaskViewCtr

function M:ctor(view,param)
	self:InitVar(view,param)
end

function M:InitVar(view,param)
    self.view = view
	self.param = param
	--中奖记录列表
	self.recList = {}
	--排行榜列表
	self.rankList = {}
	--当前等级
	self.curLevel = nil
	--最大等级
	self.maxLevel = 10
	--当前解锁礼包数据
	self.unlockGift = nil
	--当前等级任务数据
	self.curTaskData = self.param.curData or {}
	--所有等级任务列表
	self.allTaskData = {}
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnCurTaskInfoRsp,CC.Notifications.NW_Req_UW_MarsGetTask)
	CC.HallNotificationCenter.inst():register(self,self.OnAllTaskInfoRsp,CC.Notifications.NW_Req_UW_MarsGetList)
	CC.HallNotificationCenter.inst():register(self,self.OnMarsUpgradeRsp,CC.Notifications.NW_Req_UW_MarsUpgrade)
	CC.HallNotificationCenter.inst():register(self,self.OnMarsGetWinPrizeListRsp,CC.Notifications.NW_Req_UW_MarsGetWinPrizeList)
	CC.HallNotificationCenter.inst():register(self,self.OnShareTaskRsp,CC.Notifications.NW_Req_UW_MarsShareTask)
	CC.HallNotificationCenter.inst():register(self,self.OnFinishSubTaskRsp,CC.Notifications.NW_Req_UW_MarsReceiveSubTaskAward)
	CC.HallNotificationCenter.inst():register(self,self.OnGetMTaskRankRsp,CC.Notifications.NW_Req_UW_MarsGetMTaskRank)
	CC.HallNotificationCenter.inst():register(self,self.OnPropChange,CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnPurchaseNotify,CC.Notifications.OnPurchaseNotify)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function M:OnCreate()
	self:RegisterEvent()
end

function M:StartRequest()
	self:ReqCurTaskInfo()
	local taskList = CC.Player.Inst():GetMarsTaskList()
	if taskList then
		self.allTaskData = taskList
	else
		self:ReqAllTaskInfo()
	end
	self.view:DelayRun(0.5,function ()
			self:ReqMarsGetMTaskRank()
			self:ReqMarsGetWinPrizeList()
			self.view:StartTimer("Timer", 60, function ()
					self:ReqMarsGetWinPrizeList()
				end, -1)
		end)

end

--请求任务信息
function M:ReqCurTaskInfo()
	CC.Request("Req_UW_MarsGetTask")
end

function M:OnCurTaskInfoRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_MarsGetTask err:"..err)
		return
	end
	--CC.uu.Log(data,"Req_UW_MarsGetTask Rsp:",2)
	local lastLevel = self.curLevel
	self.curLevel = data.Level
	self.maxLevel = data.MaxLevel
	self.view:SetMyRankScore(data.Level,data.MaxLevel)
	
	if lastLevel and (math.ceil(self.curLevel/10) > math.ceil(lastLevel/10)) then
		local id = CC.Player.Inst():GetSelfInfoByKey("Id")
		local openAtlas = function()
			CC.ViewManager.Open("MarsTaskAtlasView",{curLevel = self.curLevel, maxLevel = self.maxLevel, OpenBox = self.view.curStage})
		end
		if CC.LocalGameData.GetLocalDataToKey("MarsTaskStoryFinish"..self.view.curStage, id) then
			CC.LocalGameData.SetLocalDataToKey("MarsTaskStoryFinish"..self.view.curStage, id)
			local param = {}
			param.storyIdx = self.view.curStage
			param.content = "Finish"
			param.callBack = function()
				openAtlas()
			end
			CC.ViewManager.OpenAndReplace("MarsTaskStoryView",param)
		else
			openAtlas()
		end
		return
	end
	
	local t = {}
	t.taskInfo = {}
	t.taskInfo.status = data.Status
	t.taskInfo.level = data.Level
	t.taskInfo.maxLevel = data.MaxLevel
	t.taskInfo.complete = data.Complete
	t.taskInfo.directStatus = data.DirectStatus
	t.taskInfo.score = data.Score
	t.taskInfo.totalScore = data.TotalScore
	
	--子任务排序
	local temp = {}
	for k,v in ipairs(data.SubTask) do
		table.insert(temp,v)
	end
	local _sort = function (a,b)
		if a.Status == 2 then
			if a.Status == b.Status then
				return false
			else
				return true
			end
		end
		if b.Status == 2 then
			return false
		end
		if a.Status == 1 then
			return false
		end
		if b.Status == 1 then
			return true
		end
		local apercent = a.Value/a.NeeDValue
		local bpercent = b.Value/b.NeeDValue
		return apercent > bpercent
	end
	table.sort(temp,_sort)
	t.taskInfo.taskList = temp
	t.rewards = self:GetRewardsList(data)
	
	self.unlockGift = data:HasField("UWUnlockGift") and data.UWUnlockGift or nil
	
	self.curTaskData = t
	self.view:RefreshUI(t)
end

--请求所有任务列表信息
function M:ReqAllTaskInfo()
	CC.Request("Req_UW_MarsGetList")
end

function M:OnAllTaskInfoRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_MarsGetList err:"..err)
		return
	end
	--CC.uu.Log(data,"Req_UW_MarsGetList Rsp:",2)
	
	local t = {}
	
	for _,v in ipairs(data.TaskList) do
		local temp = {}
		temp.level = v.Level
		temp.score = 0
		temp.totalScore = v.TotalScore
		temp.taskList = {}
		for i,task in ipairs(v.SubTask) do
			temp.taskList[i] = task
		end
		t[v.Level] = {}
		t[v.Level].taskInfo = temp
		t[v.Level].rewards = self:GetRewardsList(v)
	end
	
	self.allTaskData = t
	CC.Player.Inst():SetMarsTaskList(t)
end

--请求完成子任务
function M:ReqFinishSubTask(id)
	CC.Request("Req_UW_MarsReceiveSubTaskAward",{SubTaskID = id})
end

function M:OnFinishSubTaskRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_MarsReceiveSubTaskAward err:"..err)
		return
	end
	--CC.uu.Log(data,"Req_UW_MarsReceiveSubTaskAward Rsp:",1)
	self.view:SetCanClick(false)
	self.view:ShowSubTaskFinishEffect(function ()
			self.view:SetCanClick(true)
			self:ReqCurTaskInfo()
		end)
end

--请求升级
function M:ReqMarsUpgrade()
	CC.Request("Req_UW_MarsUpgrade")
end

function M:OnMarsUpgradeRsp(err,data)
	if err ~= 0 then
		logError("UWUpgradeTaskResp err:"..err)
		return
	end
	--CC.uu.Log(data,"UWUpgradeTaskResp Rsp:",1)
	local cb = function()
		local rewards = {}
		if data.Prop then
			for _,v in ipairs(data.Prop) do
				table.insert(rewards,{ConfigId = v.PropID, Count = v.PropNum})
			end
		end
		if data.Jp and data.Jp > 0 then
			table.insert(rewards,{ConfigId = 2, Count = data.Jp})
			self.view:ShowNumberRoller(data.Jp,function ()
					CC.ViewManager.OpenMarsTaskRewardsView({items = rewards, splitState = true, callback = function()
								self:ReqCurTaskInfo()
								self:ReqMarsGetWinPrizeList()
							end})
				end)
		else
			CC.ViewManager.OpenMarsTaskRewardsView({items = rewards, splitState = true, callback = function()
						self:ReqCurTaskInfo()
					end})
		end
	end
	
	self.view:ShowLevelUpEffect(cb)
end

--请求分享任务
function M:ReqShareTask()
	CC.Request("Req_UW_MarsShareTask")
end

function M:OnShareTaskRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_MarsShareTask err:"..err)
		return
	end
	self:ReqCurTaskInfo()
end

--请求排行榜
function M:ReqMarsGetMTaskRank()
	CC.Request("Req_UW_MarsGetMTaskRank")
end

function M:OnGetMTaskRankRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_MarsGetMTaskRank err:"..err)
		return
	end
	--CC.uu.Log(data,"Req_UW_MarsGetMTaskRank Rsp:",2)
	local param = {}
	param.rankList = {}
	for k,v in ipairs(data.RankList) do
		param.rankList[k] = v
	end
	self.rankList = param.rankList
	self.view:RefreshUI(param)
end

--请求获奖记录
function M:ReqMarsGetWinPrizeList()
	CC.Request("Req_UW_MarsGetWinPrizeList")
end

function M:OnMarsGetWinPrizeListRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_MarsGetWinPrizeList err:"..err)
		return
	end
	--CC.uu.Log(data,"Req_UW_MarsGetWinPrizeList Rsp:",2)
	local param = {}
	param.jackpot = data.Jp
	param.recList = {}
	for k,v in ipairs(data.List) do
		param.recList[k] = v
	end
	self.recList = param.recList
	self.view:RefreshUI(param)
end

function M:GetRewardsList(data)
	local t = {}
	for _,v in ipairs(data.RewardsList) do
		local temp = {}
		temp.ConfigId = v.PropID
		temp.Count = v.PropNum
		table.insert(t,temp)
	end
	local hadCard = false
	for _,v in ipairs(data.SpecialPropList) do
		if v.PropID >= CC.shared_enums_pb.EPC_50Card and v.PropID <= CC.shared_enums_pb.EPC_500Card_zgold and hadCard then
			--true 50/90点卡合并图标展示
		else
			local temp = {}
			temp.ConfigId = v.PropID
			temp.Count = v.PropNum
			if v.PropID > 10000 then
				hadCard = true
				temp.isCard = true
			end
			table.insert(t,temp)
		end
	end
	local index = self:GetIndexByLevel(data.Level)
	local buff = self.view.buffCfg[index]
	if buff and (not table.isEmpty(buff)) then
		local temp = {}
		temp.redPacket = buff
		table.insert(t,temp)
	end
	if data:HasField("JpInputPercent") and data.JpInputPercent ~= 0 then
		local temp = {}
		temp.jpNum = data.JpInputPercent
		temp.Count = ""
		table.insert(t,temp)
	end
	return t
end

function M:OnPropChange(props, source)
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_One_Red_env then
			self.view:RefreshRedPacket()
		end
	end
end

function M:OnPurchaseNotify()
	self:ReqCurTaskInfo()
end

function M:GetIndexByLevel(level)
	return level%10~= 0 and level%10 or 10
end

function M:Destroy()
	self.view:StopTimer("Timer")
	self:UnRegisterEvent()
end

return MarsTaskViewCtr