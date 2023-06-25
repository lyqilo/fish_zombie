local CC = require("CC")
local FlowWaterTaskView = CC.uu.ClassView("FlowWaterTaskView")

function FlowWaterTaskView:ctor(param)
    self.param = param
	self.PrefabTaskTab = {}
end

function FlowWaterTaskView:OnCreate()
	self:InitUI()
    self:LanguageSwitch()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
end

function FlowWaterTaskView:InitUI()
	self.taskParent = self:FindChild("RightPlane/TaskScroll/Content")
	self.taskItem = self:FindChild("RightPlane/TaskScroll/Item")
    self.rulePanel = self:FindChild("RulePanel")

    self:AddClick("RightPlane/BtnGift", function ()
		CC.ViewManager.Open("WorldCupGiftView")
        self:CloseView()
	end)
    self:AddClick("RightPlane/BtnHelp", function ()
		self.rulePanel:SetActive(true)
	end)
    self:AddClick("RulePanel/Frame/BtnClose", function ()
		self.rulePanel:SetActive(false)
	end)
	self:AddClick("BtnClose", function ()
		self:CloseView()
	end)
end

--语言切换
function FlowWaterTaskView:LanguageSwitch()
    self.language = self:GetLanguage()
    self:FindChild("RightPlane/Title").text = self.language.Title
	self:FindChild("RightPlane/Time").text = self.language.TimeTitle
    self:FindChild("RightPlane/Time/Text").text = self.language.time
    self:FindChild("RightPlane/Tip").text = self.language.taskTip
	self.taskItem:FindChild("GoBtn/Text").text = self.language.GoBtn
	self.taskItem:FindChild("GetBtn/Text").text = self.language.GetBtn
	self.taskItem:FindChild("GrayBtn/Text").text = self.language.GetBtn
	self.taskItem:FindChild("stage").text = self.language.taskStage

    self:FindChild("RulePanel/Frame/Tittle/Text").text = self.language.ruleTitle
    self:FindChild("RulePanel/Frame/ScrollText/Viewport/Content/Text").text = self.language.explain
end

--任务列表
function  FlowWaterTaskView:InitTaskInfo(data)
	local list = data
    for _,v in pairs(self.PrefabTaskTab) do
		v.transform:SetActive(false)
	end
	for i = 1,#list do
		self:AddTaskItemData(i,list[i])
	end
end

function FlowWaterTaskView:AddTaskItemData(index, data)
    local item = nil
    if self.PrefabTaskTab[index] == nil then
        item = CC.uu.newObject(self.taskItem)
        if item then
            item.transform.name = tostring(index)
            item.transform:SetParent(self.taskParent, false)
            self.PrefabTaskTab[index] = item.transform
        end
    else
        item = self.PrefabTaskTab[index]
    end
	if item then
		item:SetActive(true)
		item:FindChild("name").text = self.language.taskName[data.ID]
        local curNum = data.Value > data.NeeDValue and data.NeeDValue or data.Value
		item:FindChild("num").text = string.format("%s/%s", CC.uu.ChipFormat(curNum),CC.uu.ChipFormat(data.NeeDValue))
		if data.Status == 1 then
			item:FindChild("stage/Text").text = string.format("%s/%s", data.Level, data.TaskCount)
		else
			item:FindChild("stage/Text").text = string.format("%s/%s", data.Level - 1, data.TaskCount)
		end
		local goodNum = "<color=#FFF7A3>x%s</color>"
		if data.IsBuyWare == 1 then
			goodNum = "<color=#FF062B>x%s</color>"
		end
		item:FindChild("Goods/num").text = string.format(goodNum, data.RewardsList[1].PropNum)
		item:FindChild("GoBtn"):SetActive(data.Status == 0)
		item:FindChild("GetBtn"):SetActive(data.Status == 2)
		item:FindChild("fulfill"):SetActive(data.Level == data.TaskCount and data.Status == 1)
        item:FindChild("GrayBtn"):SetActive(data.Level ~= data.TaskCount and data.Status == 1)
		self:AddClick(item:FindChild("GoBtn"), function()
            self:ByTaskIdJump(data.ID)
		end)
		self:AddClick(item:FindChild("GetBtn"), function( )
            if data.IsBuyWare ~= 1 and not CC.LocalGameData.GetDailyStateByKey("FlowWaterTask") then
                local param = {}
				param.str = self.language.receiveTip
				param.btnOkText = self.language.buyBtn
				param.okFunc = function()
					CC.ViewManager.Open("WorldCupGiftView")
					self:CloseView()
				end
				param.noFunc = function()
					self.viewCtr:ReqFlowTaskReceive(data.ID, data.Level)
				end
				param.btnNoText = self.language.receiveBtn
                CC.ViewManager.MessageBoxExtend(param)
				CC.LocalGameData.SetDailyStateByKey("FlowWaterTask", true)
            else
                self.viewCtr:ReqFlowTaskReceive(data.ID, data.Level)
            end
		end)
	end
end


--跳转
function FlowWaterTaskView:ByTaskIdJump(taskId)
	if taskId == 1 or taskId == 2 then
        local gameType = taskId == 1 and 1 or 0
        local rNum = math.random(1000)
        if taskId == 2 then
            --随机弹出Slots或Poker
            gameType = rNum > 500 and 2 or 3
        end
        CC.HallNotificationCenter.inst():post(CC.Notifications.RefreshGameList, gameType)
        CC.ViewManager.CloseAllOpenView()
	elseif taskId == 3 then
        local param = {}
        param.isShowPlayerInfo = true
        param.shareCallBack = function()
            CC.Request("ReqFlowTaskShare")
        end
		CC.ViewManager.Open("CaptureScreenShareView", param)
	end
end

function FlowWaterTaskView:ActionIn() end

function FlowWaterTaskView:ActionOut() end

--关闭界面
function FlowWaterTaskView:CloseView()
	self:Destroy()
end

function FlowWaterTaskView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
end

return FlowWaterTaskView;