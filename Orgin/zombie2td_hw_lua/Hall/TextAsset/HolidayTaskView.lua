local CC = require("CC")
local HolidayTaskView = CC.uu.ClassView("HolidayTaskView")

function HolidayTaskView:ctor(param)
	self:InitVar(param)
end

function HolidayTaskView:InitVar(param)
	self.param = param
	self.language = self:GetLanguage()
	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
	self.tower = {}
	self.taskItemList = {}
	self.headIconList = {}
	self.recPanelIsOpen = false
	self.jpNum = {3,7,15,25,50}
	self.isOnLongClick = false
end

function HolidayTaskView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param)
	self:InitContent()
	self:InitTextByLanguage()
	
	self.viewCtr:OnCreate()
end

function HolidayTaskView:InitContent()

	self.leftPanel = self:FindChild("Frame/LeftPanel")
	self.upEffect = self:FindChild("Frame/Effect/UpgradeEffect")
	self.btnAllGet = self.leftPanel:FindChild("BtnList/BtnAllGet/Normal")
	self.btnAllGetGray = self.leftPanel:FindChild("BtnList/BtnAllGet/Gray")
	self.btnUnlock = self.leftPanel:FindChild("BtnList/BtnUnlock")
	self.taskList = self.leftPanel:FindChild("TaskList/Viewport/Content")
	self.taskItem = self.leftPanel:FindChild("TaskItem")
	self.finishMask = self.leftPanel:FindChild("FinishMask")
	self.rewardItem = self.leftPanel:FindChild("Rewards/Item")
	self.rewardList = self.leftPanel:FindChild("Rewards/List")
	self.jpNumber1 = self.leftPanel:FindChild("JP/Number"):GetComponent("NumberRoller")
	
	self.rightPanel = self:FindChild("Frame/RightPanel")
	self.efYanhua = self.rightPanel:FindChild("Tower/ef_yanhua")
	
	self.nameText = self:FindChild("Frame/LongClickTip/Name")
	self.jpNumber2 = self:FindChild("RecordAndJP/JPPanel/JP/Number"):GetComponent("NumberRoller")
	self.recordScrCtrl = self:FindChild("RecordAndJP/RecordPanel/ScrollerController"):GetComponent("ScrollerController")

	self.recPanel = self:FindChild("RecordAndJP")
	self.recPanelMask = self:FindChild("RecordAndJP/Mask")
	self.jpPanel = self:FindChild("RecordAndJP/JPPanel")
	self.RecordPanel = self:FindChild("RecordAndJP/RecordPanel")

	for i=1,7 do
		self.tower[i] = self.rightPanel:FindChild("Tower/"..i)
	end
	
	self.recordScrCtrl:AddChangeItemListener(function(tran,dataIndex,cellIndex)
			self:RefreshRecordItem(tran,dataIndex)
		end)
	self.recordScrCtrl:AddRycycleAction(function (tran)
			self:RycycleRecordItem(tran)
		end)

	self:AddClick(self.btnAllGet,"OnClickBtnAllGet")
	self:AddClick(self.btnUnlock,"OnClickBtnUnlock")
	--self:AddClick(self.btnAllGetGray,function ()
			--CC.ViewManager.ShowTip("")
		--end)
	self:AddClick("Frame/LeftPanel/BtnExplain",function ()
			CC.ViewManager.Open("HolidayTaskExplainView")
		end)
	self:AddClick(self.recPanelMask,"ChangeRecPanelStatus")
	self:AddLongClick(self.rightPanel:FindChild("Tower"),{
			funcDown = function ()
			end,
			funcLongClick = function (  )
				self.isOnLongClick = true
				--self:RefreshSandTower(self.viewCtr.curLevel+1)
				self:OnTowerLongClick()
			end,
			funcUp = function ()
				if self.isOnLongClick then
					self.isOnLongClick = false
					--self:RefreshSandTower(self.viewCtr.curLevel)
					self:OnTowerLongClick()
				end
			end,
			time = 0.3,
		})


	UIEvent.AddToggleValueChange(self:FindChild("RecordAndJP/ToggleGroup/ToggleJP"),function (selected)
			self.jpPanel:SetActive(selected)
			if selected then
				if not self.recPanelIsOpen then
					self:ChangeRecPanelStatus()
				end
			end
		end)
	UIEvent.AddToggleValueChange(self:FindChild("RecordAndJP/ToggleGroup/ToggleRecord"),function (selected)
			self.RecordPanel:SetActive(selected)
			if selected then
				self.recordScrCtrl:InitScroller(#self.viewCtr.recList)
				if not self.recPanelIsOpen then
					self:ChangeRecPanelStatus()
				end
			end
		end)
end

function HolidayTaskView:InitTextByLanguage()

	self.leftPanel:FindChild("Time/Text1").text = self.language.timeText1
	self.leftPanel:FindChild("Time/Text2").text = self.language.timeText2
	self.leftPanel:FindChild("Desc").text = self.language.desc
	self.leftPanel:FindChild("TaskItem/Status/Go/Text").text = self.language.btnGo
	self.leftPanel:FindChild("TaskItem/Status/Gray/Text").text = self.language.btnGo
	self.leftPanel:FindChild("Rewards/Text").text = self.language.rewardsText
	self.leftPanel:FindChild("Rewards/Item/Bubble/Image/Text1").text = self.language.bubbleText1
	self.leftPanel:FindChild("Rewards/Item/Bubble/Image/Text2").text = self.language.bubbleText2
	self.leftPanel:FindChild("Rewards/Item/Bubble/Image/Num").text = ""
	self.leftPanel:FindChild("FinishMask/Text").text = self.language.taskAllFinish

	self.btnAllGet:FindChild("Text").text = self.language.btnAllGet
	self.btnAllGetGray:FindChild("Text").text = self.language.btnAllGet
	self.btnUnlock:FindChild("Text").text = self.language.btnUnlock

	self:FindChild("Frame/LongClickTip/Text").text = self.language.longClick
	self.recPanel:FindChild("ToggleGroup/ToggleJP/Label").text = self.language.btnJP
	self.recPanel:FindChild("ToggleGroup/ToggleRecord/Label").text = self.language.btnRec
	self.RecordPanel:FindChild("Top/Name").text = self.language.roleName
	self.RecordPanel:FindChild("Top/Num").text = self.language.winInfo

	for i = 1, 5 do
		self.jpPanel:FindChild("List/Item"..i.."/JP").text = self.language.jp
		self.jpPanel:FindChild("List/Item"..i.."/Num").text = self.jpNum[5-i+1].."%"
	end
end

function HolidayTaskView:RefreshUI(data)

	if data.taskInfo and not table.isEmpty(data.taskInfo) then
		self:RefreshTaskList(data.taskInfo)
	end

	if data.rewards then
		if table.isEmpty(data.rewards) then
			self.rewardList:SetActive(false)
		else
			self:RefreshTaskRewards(data.rewards)
			self.rewardList:SetActive(true)
		end
	end
	
	if data.jackpot then
		self:RefreshJackpot(data.jackpot)
	end
	
	if data.recList and self.RecordPanel.activeSelf then
		self.recordScrCtrl:InitScroller(#data.recList)
	end
	
	if data.marqueeList then
		self:ShowMarquee(data.marqueeList)
	end

end

function HolidayTaskView:RefreshTaskList(param)

	local itemList = self.taskItemList
	local curFinish = param.status == 2 or param.directStatus == 1
	local allFinish = param.complete == 1
	local taskStage = param.level

	if #itemList > #param.taskList then
		for i = #param.taskList+1, #itemList do
			itemList[i].transform:SetActive(false)
		end
	end
	
	if allFinish then
		self.btnAllGet:SetActive(false)
		self.btnAllGetGray:SetActive(false)
		self.btnUnlock:SetActive(false)
		self.finishMask:SetActive(true)
	else
		self.btnAllGet:SetActive(curFinish)
		self.btnAllGetGray:SetActive(not curFinish)
		self.btnUnlock:SetActive((taskStage>=3) and (not curFinish))
	end

	for i,v in ipairs(param.taskList) do
		if itemList[i] then
			itemList[i].data = v
			itemList[i].onRefreshData(v)
		else
			local item = self:CreateTaskItem(v)
			table.insert(itemList, item)
		end
	end


end

function HolidayTaskView:CreateTaskItem(param)
	local item = {}
	item.data = param
	item.transform = CC.uu.newObject(self.taskItem, self.taskList)

	item.onRefreshData = function(param)
		local status = param.Status > 0
		if param.Type == 7 and param.Status then
			self.btnUnlock:SetActive(false)
		end
		item.transform:FindChild("Desc").text = string.format(self.language.taskType[param.Type],CC.uu.NumberFormat(param.NeeDValue))
		item.transform:FindChild("Progress").text = CC.uu.NumberFormat(param.Value).."/"..CC.uu.NumberFormat(param.NeeDValue)
		if param.Type == 2 or param.Type == 7 then
			item.transform:FindChild("Status/Go"):SetActive(not status)
		else
			item.transform:FindChild("Status/Gray"):SetActive(not status)
		end
		item.transform:FindChild("Status/Finish"):SetActive(status)
		item.transform:SetActive(true)
		self:AddClick(item.transform:FindChild("Status/Gray"),function ()
				self:OnClickTaskItemBtnGo(param)
			end)
		self:AddClick(item.transform:FindChild("Status/Go"),function ()
				self:OnClickTaskItemBtnGo(param)
			end)
	end

	item.onRefreshData(param)
	return item
end

function HolidayTaskView:RefreshTaskRewards(data)
	for i = self.rewardList.childCount - 1,0,-1 do
		GameObject.Destroy(self.rewardList:GetChild(i).gameObject)
	end
	for k,v in ipairs(data) do
		local item = CC.uu.newObject(self.rewardItem, self.rewardList)
		self:SetImage(item:FindChild("Icon"),"prop_img_"..v.ConfigId)
		item:FindChild("Icon"):GetComponent("Image"):SetNativeSize()
		item:FindChild("Num").text = v.Count
		item:SetActive(true)
	end
	if self.viewCtr.curLevel >= 3 then
		local item = CC.uu.newObject(self.rewardItem, self.rewardList)
		item:FindChild("Num").text = self.jpNum[self.viewCtr.curLevel-2].."%"
		item:FindChild("Bubble/Image/Num").text = self.jpNum[self.viewCtr.curLevel-2].."%"	
		item:FindChild("Bubble"):SetActive(true)
		item:SetActive(true)
	end
end

function HolidayTaskView:RefreshJackpot(number,immediately)
	local time = immediately and 0 or 1.5
	self.jpNumber1:RollTo(number,time)
	self.jpNumber2:RollTo(number,time)
end

function HolidayTaskView:RefreshSandTower(level,showAni)
	if level > 7 then level = 7 end
	if level == 7 then
		self:FindChild("Frame/LongClickTip"):SetActive(false)
	end
	if showAni then
		self.upEffect:SetActive(true)
		self:DelayRun(3,function ()
			for i=1,7 do
				self.tower[i]:SetActive(i==level)
			end
		end)
		self:DelayRun(5,function ()
			self.upEffect:SetActive(false)
		end)
	else
		for i=1,7 do
			self.tower[i]:SetActive(i==level)
		end
	end
	self.efYanhua:SetActive(level>=5)
	self.nameText.text = self.language.sandTower[level].Name
end

function HolidayTaskView:RefreshRecordItem(trans,index)
	local dataIdx = index + 1
	local recList = self.viewCtr.recList
	
	if not recList or table.isEmpty(recList) then
		return
	end
	
	local recData = recList[dataIdx]
	trans.name = dataIdx
	trans:FindChild("Icon/Name").text = recData.Nick
	trans:FindChild("Info/JP").text = self.propLanguage[recData.PropID].."x"..CC.uu.ChipFormat(recData.PropNum,true)
	trans:FindChild("Info/Time").text = CC.TimeMgr.GetTimeFormat1(recData.Timestamp)

	local IconData = {}
	IconData.parent = trans:FindChild("Icon/HeadNode")
	IconData.playerId = recData.PlayerId
	IconData.portrait = recData.Portrait
	IconData.headFrame = recData.Background
	IconData.vipLevel = recData.Level
	--IconData.clickFunc = "unClick";
	local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.headIconList[dataIdx] = headIcon
end

function HolidayTaskView:RycycleRecordItem(trans)
	local index = tonumber(trans.transform.name)
	if self.headIconList[index] then
		self.headIconList[index]:Destroy(true)
	end
end

function HolidayTaskView:OnClickBtnAllGet()
	self.viewCtr:ReqUpgrade()
end

function HolidayTaskView:OnClickBtnUnlock()
	if not self.viewCtr.unlockGift then return end
	local param = {}
	param.level = self.viewCtr.curLevel
	param.rewards = self.viewCtr.unlockGift.Prop
	param.price = self.viewCtr.unlockGift.Amount
	param.succCb = function()
		self:DelayRun(1,function ()
			self.viewCtr:ReqActivityInfo()
		end)
	end
	param.errCb = function()
		logError("Buy UnlockGift Faile")
	end
	CC.ViewManager.Open("UnlockGiftView",param)
end

function HolidayTaskView:OnClickTaskItemBtnGo(data)
	--TODO
	--Type type类型 1在线时长，2分享，3游戏累计流水，4累计好友，5绑定手机，6.赠送一笔
	if data.Type == 1 then
		CC.ViewManager.ShowTip(self.language.tip1)
	elseif data.Type == 2 then
		local param = {}
		--param.imgName = "share_1_7"
		param.shareCallBack = function()
			self.viewCtr:ReqShareTask()
		end
		--CC.ViewManager.Open("ImageShareView", param)
		param.isShowPlayerInfo = true
		CC.ViewManager.Open("CaptureScreenShareView", param)
	elseif data.Type == 3 then
		CC.ViewManager.ShowTip(self.language.tip2)
	elseif data.Type == 4 then
		CC.ViewManager.ShowTip(self.language.tip3)
	elseif data.Type == 5 then
		CC.ViewManager.ShowTip(self.language.tip4)
	elseif data.Type == 6 then
		CC.ViewManager.ShowTip(self.language.tip5)
	elseif data.Type == 7 then
		self:OnClickBtnUnlock()
	end
end

function HolidayTaskView:OnTowerLongClick()
	if self.viewCtr.curLevel >= 7 then return end
	local curTower = self.tower[self.viewCtr.curLevel]
	local nextTower = self.tower[self.viewCtr.curLevel+1]
	if self.isOnLongClick then
		
		self:RunAction(nextTower, {
				{"fadeToAll", 0, 0, function ()
						nextTower:SetActive(true)
				end},
				{"fadeToAll", 255, 0.4, function()
						nextTower:SetActive(true)
				end}
			});
		self:RunAction(curTower, {
				{"fadeToAll", 255, 0},
				{"fadeToAll", 0, 0.4, function()
						curTower:SetActive(false)
					end},
				{"fadeToAll", 255, 0},
			});
		
	else
		
		self:RunAction(curTower, {
				{"fadeToAll", 0, 0, function ()
						curTower:SetActive(true)
				end},
				{"fadeToAll", 255, 0.4, function()
						curTower:SetActive(true)
				end}
			});
		self:RunAction(nextTower, {
				{"fadeToAll", 255, 0},
				{"fadeToAll", 0, 0.4, function()
						nextTower:SetActive(false)
					end},
				{"fadeToAll", 255, 0},
			});
		
	end
end

--显示跑马灯
function HolidayTaskView:ShowMarquee(list)
	if not self.Marquee then
		self.Marquee = CC.uu.CreateHallView("Marquee",{parent = self:FindChild("MarqueeNode")})
	end
	for _,v in ipairs(list) do
		local numStr = CC.uu.ChipFormat(v.num,true)
		local str = string.format(self.language.marquee,v.name,self.propLanguage[v.id],numStr)
		--log("Marquee:\n"..str)
		self.Marquee:Report(str)
	end

end

function HolidayTaskView:ShowNumberRoller(num,callback)
	if not self.numberRoller then
		self.numberRoller = CC.ViewCenter.NumberRoller.new();
	end
	self:FindChild("RollerNode"):SetActive(true)
	local param = {
		parent = self:FindChild("RollerNode"),
		number = num,
		callback = function()
			self:FindChild("RollerNode"):SetActive(false)
			if callback then
				callback()
			end
		end
	}
	self.numberRoller:Create(param);
end

function HolidayTaskView:ChangeRecPanelStatus()
	self.recPanelIsOpen = not self.recPanelIsOpen
	self.recPanelMask:SetActive(self.recPanelIsOpen)
	if self.recPanelIsOpen then
		self:RunAction(self.recPanel,{"localMoveBy", -324, 0, 0.5, ease=CC.Action.EOutSine})
	else
		self:RunAction(self.recPanel,{"localMoveBy", 324, 0, 0.5, ease=CC.Action.EOutSine})
	end
end

function HolidayTaskView:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.3, function()
					--self:SetCanClick(true);
				end}
		});
end

function HolidayTaskView:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.3, function() self:Destroy() end},
		});
end

function HolidayTaskView:OnDestroy()

	if self.Marquee then
		self.Marquee:Destroy()
		self.Marquee = nil
	end
	
	if self.numberRoller then
		self.numberRoller:Destroy()
		self.numberRoller = nil
	end

	for _,v in pairs(self.headIconList) do
		--销毁排行榜头像
		if v then
			v:Destroy(true)
			v = nil
		end
	end

	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end

end

return HolidayTaskView