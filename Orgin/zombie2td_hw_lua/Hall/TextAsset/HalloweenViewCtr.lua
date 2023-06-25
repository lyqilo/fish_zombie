local CC = require("CC")
local HalloweenViewCtr = CC.class2("HalloweenViewCtr")

function HalloweenViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function HalloweenViewCtr:InitVar(view,param)
	self.param = param
	self.view = view
	self.curTaskId = nil
	self.BroadCastList = {}
	self.signRewardList = {1, 3, 1, 1, 5, 2, 7}
	self.taskRewardList = {[8] = {1, 1, 2, 3, 10, 15, 100, 150, 250, 800}, [9] = {1, 1, 2, 3, 10, 15, 100, 150, 250, 800}}
end

function HalloweenViewCtr:OnCreate()
	self:RegisterEvent()
	self:ReqHalloweenInfo()
	self:ReqHalloweenShopList()
	self:ReqHalloweenShopBroad()
	-- self:ReqWaterLightAllTask()
end

function HalloweenViewCtr:RegisterEvent()
	--水灯节
	-- CC.HallNotificationCenter.inst():register(self,self.TaskListResp,CC.Notifications.NW_ReqWaterLightInfo)
	-- CC.HallNotificationCenter.inst():register(self,self.ReqAcquireRewardResq,CC.Notifications.NW_ReqWaterLightReward)
	-- CC.HallNotificationCenter.inst():register(self,self.ReqAcquireRewardResq,CC.Notifications.NW_ReqWaterLightSignAward)
	-- CC.HallNotificationCenter.inst():register(self,self.ReqShopListResq,CC.Notifications.NW_ReqWaterLightShopList)
	-- CC.HallNotificationCenter.inst():register(self,self.ReqHalloweenShopBuyResq,CC.Notifications.NW_ReqWaterLightShopBuy)
	-- CC.HallNotificationCenter.inst():register(self,self.ReqShopBroadResq,CC.Notifications.NW_ReqWaterLightShopBroad)
	-- CC.HallNotificationCenter.inst():register(self,self.ReqWaterLightAllTaskListResq,CC.Notifications.NW_ReqWaterLightAllTaskList)

	--万圣节
	CC.HallNotificationCenter.inst():register(self,self.TaskListResp,CC.Notifications.NW_ReqHalloweenInfo)
	CC.HallNotificationCenter.inst():register(self,self.ReqAcquireRewardResq,CC.Notifications.NW_ReqHalloweenReward)
	CC.HallNotificationCenter.inst():register(self,self.ReqShopListResq,CC.Notifications.NW_ReqHalloweenShopList)
	CC.HallNotificationCenter.inst():register(self,self.ReqHalloweenShopBuyResq,CC.Notifications.NW_ReqHalloweenShopBuy)
	CC.HallNotificationCenter.inst():register(self,self.ReqShopBroadResq,CC.Notifications.NW_ReqHalloweenShopBroad)

	CC.HallNotificationCenter.inst():register(self,self.OnRefreshSwitchOn,CC.Notifications.OnRefreshActivityBtnsState)
end

function HalloweenViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function HalloweenViewCtr:SortTaskList(tab)
	table.sort(tab, function(a,b) return a.ID < b.ID end )
	local finishTab = {}
	local activeTab = {}
	local overTab = {}
	local sortTab = {}
	local taskTab = {}
	for i = 1, #tab do
		if tab[i].NewTaskTabType == 1 then
			if tab[i].IsFinish then
				if tab[i].IsReward then
					overTab[#overTab + 1] = tab[i]
				else
					finishTab[#finishTab + 1] = tab[i]
				end
			else
				activeTab[#activeTab + 1] = tab[i]
			end
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

function HalloweenViewCtr:HalloweenTaskDeal(param)
	if param.NewTaskList then
		--签到任务
		local signInfoList, taskInfoList = self:SortTaskList(param.NewTaskList)
		CC.uu.Log(signInfoList,"HalloweenTaskDeal-->>signInfoList:")
		CC.uu.Log(taskInfoList,"HalloweenTaskDeal-->>taskInfoList:")
		if #signInfoList > 0 then
			self.view:InitSignInfo(signInfoList)
		end
		if #taskInfoList > 0 then
			self.view:InitTaskInfo(taskInfoList)
		end
	end
end

function HalloweenViewCtr:WaterLigheTaskDeal(param)
	--签到任务
	if param.BoxTaskList and #param.BoxTaskList > 0 then
		local tab = param.BoxTaskList
		table.sort(tab, function(a,b) return a.ID < b.ID end )
		-- finishTab: 已完成任务，没领奖励       activeTab: 进行中任务       overTab: 已结束任务
		local finishTab,activeTab,overTab = {},{},{}
		for i = 1, #tab do
			if tab[i].IsFinish then
				if tab[i].IsReward then
					overTab[#overTab + 1] = tab[i]
				else
					finishTab[#finishTab + 1] = tab[i]
				end
			else
				activeTab[#activeTab + 1] = tab[i]
			end
		end

		local sortTab,total = {finishTab,activeTab,overTab},{}
		for i,v in ipairs(sortTab) do
			for j,k in ipairs(v) do
				table.insert(total,k)
			end
		end

		self.view:InitSignInfo(total)
	end

	--流水任务
	if param.NewTaskList and #param.NewTaskList > 0 then
		table.sort(param.NewTaskList, function(a,b) return a.ID < b.ID end )
		self.view:InitTaskInfo(param.NewTaskList)
	end
end

function HalloweenViewCtr:ReqHalloweenInfo()
	CC.Request("ReqHalloweenInfo") --万圣节
	-- CC.Request("ReqWaterLightInfo") --水灯节
end

function HalloweenViewCtr:TaskListResp(err, param)
	log(CC.uu.Dump(param, "TaskListResp", 10))
	if err == 0 then
		self:HalloweenTaskDeal(param) --万圣节
		-- self:WaterLigheTaskDeal(param) --水灯节
	end
end

--领取流水任务奖励
function HalloweenViewCtr:ReqAcquireReward(taskId)
	--同时只能有一个奖励领取
	if self.curTaskId then return end
	self.curTaskId = taskId
	CC.Request("ReqHalloweenReward", {TaskID = taskId})
	
end

--领取签到奖励
function HalloweenViewCtr:ReqSignReward(taskId)
	--同时只能有一个奖励领取
	if self.curTaskId then return end
	self.curTaskId = taskId
	
	CC.Request("ReqHalloweenReward", {TaskID = taskId})
	-- CC.Request("ReqWaterLightSignAward", {TaskID = taskId})
end

--领取签到和流水任务的奖励返回都是一样的
function HalloweenViewCtr:ReqAcquireRewardResq(err, param)
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
			self:ReqHalloweenInfo()
			self:ReqHalloweenShopList()
			self.curTaskId = nil
		end
		CC.ViewManager.OpenRewardsView({items = data, callback = Cb})
	else
		self.curTaskId = nil
	end
end

function HalloweenViewCtr:ReqHalloweenShopList()
	CC.Request("ReqHalloweenShopList") --万圣节
	-- CC.Request("ReqWaterLightShopList") --水灯节
end

function HalloweenViewCtr:ReqShopListResq(err, param)
	log(CC.uu.Dump(param, "ReqWaterLightShopList", 10))
	if err == 0 then
		self.view:InitShopInfo(param.GoodsList)
	end
end

function HalloweenViewCtr:ReqHalloweenShopBuy(goodId)
	CC.Request("ReqHalloweenShopBuy", {GoodsID = goodId}) --万圣节
	-- CC.Request("ReqWaterLightShopBuy", {GoodsID = goodId}) --水灯节
end

function HalloweenViewCtr:ReqHalloweenShopBuyResq(err, param)
	log(CC.uu.Dump(param, "ReqHalloweenShopBuyResq", 10))
	if err == 0 then
		if not param.RewardList then
			return
		end
		local data = {};
		local isreal = false
		for k, v in ipairs(param.RewardList) do
			data[k] = {}
			data[k].ConfigId = v.PropID
            data[k].Count = v.PropNum

			--实物大奖
			if not isreal and v.IsReal then isreal = true end
		end
		local Cb = function ()
			self:ReqHalloweenShopList()

			if isreal then
				local para = {}
				para.imgName = "share_1_6_20221025"
				para.shareCallBack = function(view) view:Destroy() end
				--隐藏关闭按钮强制玩家分享，要不然就退游戏，等切后台回到活动自动关闭分享界面（产品要求）
				CC.ViewManager.Open("ImageShareView",para):DisplayClose(false)
			end
		end
		CC.ViewManager.OpenRewardsView({items = data, callback = Cb})
	end
end

function HalloweenViewCtr:ReqHalloweenShopBroad()
	CC.Request("ReqHalloweenShopBroad") --万圣节
	-- CC.Request("ReqWaterLightShopBroad") --水灯节
end

function HalloweenViewCtr:ReqShopBroadResq(err, param)
	log(CC.uu.Dump(param, "ReqShopBroadResq", 10))
	if err == 0 then
		self.BroadCastList = param.BroadCastList
		self.view:UpdataMarquee()
	end
end

function HalloweenViewCtr:ReqWaterLightAllTask()
	CC.Request("ReqWaterLightAllTaskList")
end

function HalloweenViewCtr:ReqWaterLightAllTaskListResq(err, param)
	log(CC.uu.Dump(param, "ReqWaterLightAllTaskList", 10))
	if err == 0 and #param.TaskListInfos > 0 then
		for i,v in ipairs(param.TaskListInfos) do
			self.view:TaskDes(v.NotifyID,v.TaskInfos)
		end
	end
end

function HalloweenViewCtr:OnRefreshSwitchOn(key,switchOn)
	if key == "HalloweenView" and not switchOn then
		self.view:CloseView()
	end
end

function HalloweenViewCtr:Destroy()
	self:unRegisterEvent()
end

return HalloweenViewCtr