local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local MarsTaskIcon = CC.class2("MarsTaskIcon",ViewUIBase)
local M = MarsTaskIcon

--[[
param
parent:Icon父节点
listParent:列表父节点
]]
function M:OnCreate(param)

	self.param = param
	self.curStage = 1
	self.language = CC.LanguageManager.GetLanguage("L_MarsTaskView")
	self.isCanClick = false
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self:RegisterEvent()
	self:InitContent()

	self:DelayRun(2,function ()
		self:ReqCurTaskInfo()
	end)
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnCurTaskInfoRsp, CC.Notifications.NW_Req_UW_MarsGetTask)
	CC.HallNotificationCenter.inst():register(self, self.IsShowIcon, CC.Notifications.OnRefreshActivityBtnsState)
	CC.HallNotificationCenter.inst():register(self,self.OnClickIcon,CC.Notifications.JumpToMarsTask)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function M:InitContent()
	self.param.listParent.transform.position = self.param.parent.transform.position
	
	self.taskList = self:FindChild("Task")
	self.taskList.parent = self.param.listParent
	
	self:AddClick("Btn","OnClickIcon")
end

function M:OnClickIcon()
	if not self.isCanClick then return end
	CC.Sound.PlayHallEffect("MarsOpenView")
	local id = CC.Player.Inst():GetSelfInfoByKey("Id")
	if CC.LocalGameData.GetLocalDataToKey("MarsTaskStoryBegin"..self.curStage, id) then
		CC.LocalGameData.SetLocalDataToKey("MarsTaskStoryBegin"..self.curStage, id)
		local param = {}
		param.storyIdx = self.curStage
		param.content = "Begin"
		param.callBack = function(param)
			self:OpenView(param)
		end
		CC.ViewManager.OpenAndReplace("MarsTaskStoryView",param)
	else
		local param = {}
		self:OpenView(param)
	end
end

function M:OpenView(param)
	if self.allFinish then
		if self.getStageReward then
			self:IsShowIcon()
		else
			CC.ViewManager.Open("MarsTaskAtlasView",{curLevel = self.curLevel, maxLevel = self.maxLevel})
		end
	else
		CC.ViewManager.OpenAndReplace("MarsTaskView",{stage = self.curStage, orgMusic = param.orgMusic})
	end
end

function M:RefreshTask(list)
	local param = list[1]
	if not param then return end
	self.taskList:FindChild("Item/Rewards/Num").text = param.Score
	self.taskList:FindChild("Item/Desc").text = string.format(self.language.taskType[param.Type],CC.uu.NumberFormat(param.NeeDValue))
	self.taskList:FindChild("Item/Progress/Text").text = CC.uu.NumberFormat(param.Value).."/"..CC.uu.NumberFormat(param.NeeDValue)
	self.taskList:FindChild("Item/Progress"):GetComponent("Slider").value = param.Value/param.NeeDValue
	self:ShowTaskItem()
	self:SetRedDot(param.Status == 2)
end

function M:ShowTaskItem()
	local curView = CC.ViewManager.GetCurrentView()
	if curView.viewName ~= "HallView" then return end
	
	CC.Sound.PlayHallEffect("MarsOpenView")
	self.taskList:SetActive(true)
	self:RunAction(self.taskList,{
			{"to",0,390,0.3,function(value)	self.taskList.transform.width = value end},
			{"delay",3,function() CC.Sound.PlayHallEffect("MarsCloseView") end},
			{"to",390,0,0.3,function(value)	self.taskList.transform.width = value end},
		})
end

function M:HideTaskItem()
	self.taskList:SetActive(false)
end

function M:SetRedDot(isShow)
	self:FindChild("Red"):SetActive(isShow)
end

function M:IsShowIcon(key,switchOn)
	if key and key ~= "MarsTaskView" then return end
	--活动开关
	local switchOn = self.activityDataMgr.GetActivityInfoByKey("MarsTaskView").switchOn
	local isShow = switchOn and not (self.allFinish and self.getStageReward)
	self.isCanClick = isShow
	self.param.parent:SetActive(isShow)
	self.param.listParent:SetActive(isShow)
	CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetActivityInfoByKey("MarsTaskEntryView", {switchOn = isShow})
end

function M:ReqCurTaskInfo()
	if not self.activityDataMgr.GetActivityInfoByKey("MarsTaskView").switchOn then return end
	CC.Request("Req_UW_MarsGetTask")
end

function M:OnCurTaskInfoRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_MarsGetTask err:"..err)
		return
	end
	--CC.uu.Log(data,"Req_UW_MarsGetTask Rsp:",2)
	
	self.curStage = data.Level > data.MaxLevel and math.ceil(data.MaxLevel/10) or math.ceil(data.Level/10)
	self.allFinish = data.Complete == 1
	self.curLevel = data.Level
	self.maxLevel = data.MaxLevel
	
	self.getStageReward = data.LastLevelAwardStatus == 1
	self:IsShowIcon()
	
	local t = {}
	for k,v in ipairs(data.SubTask) do
		table.insert(t,v)
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
	table.sort(t,_sort)
	self:RefreshTask(t)
end

function M:OnDestroy()
	self:UnRegisterEvent()
end

return MarsTaskIcon