local CC = require("CC")
local MarsTaskView = CC.uu.ClassView("MarsTaskView")
local M = MarsTaskView

function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param or {}
    self.language = self:GetLanguage()
	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
	self.curJp = 0
	--当前阶段（共3阶段）
	self.curStage = param.stage or 1
	--展示目标等级
	self.showLevel = 1
	self.isRankViewOpen = false
	self.isShowGuide = false
	self.myHeadIcon = nil
	self.taskItemList = {}
	self.rewardsItemList = {}
	self.recHeadIconList = {}
	self.rankHeadIconList = {}
	self.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	self.currency = CC.CurrencyDefine.CurrencyCode
	self:RefreshConfig()
end

function M:RefreshConfig()
	self.buffCfg = CC.ConfigCenter.Inst():getConfigDataByKey("MarsTaskConfig").buff
	self.marsTaskCfg = CC.ConfigCenter.Inst():getConfigDataByKey("MarsTaskConfig")
end

function M:OnCreate()
    self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
    self:InitContent()
	self:InitTextByLanguage()
	
	self:InitUI()
	self:RefreshRedPacket()
	self.viewCtr:StartRequest()
end

function M:InitContent()
	self.rankView = CC.uu.LoadHallPrefab("prefab", "MarsTaskRank", self:FindChild("Frame/RightPanel/Rank"))
	self.targetView = CC.uu.LoadHallPrefab("prefab", self.marsTaskCfg[self.curStage].targetPrefab, self:FindChild("Frame/LeftPanel/Node"))
	
	self.topPanel = self:FindChild("Frame/TopPanel")
	self.JPRoller = self.topPanel:FindChild("JP/Num"):GetComponent("NumberRoller")
	
	self.leftPanel = self:FindChild("Frame/LeftPanel")
	self.btnLock = self.leftPanel:FindChild("BtnLock")
	self.btnUnlock = self.leftPanel:FindChild("BtnUnlock")
	self.btnAtlas = self.leftPanel:FindChild("BtnAtlas")
	self.btnRedPacket = self.leftPanel:FindChild("BtnRedPacket")
	
	self.rightPanel = self:FindChild("Frame/RightPanel")
	self.taskList = self.rightPanel:FindChild("TaskList/Viewport/Content")
	self.taskItem = self.rightPanel:FindChild("TaskItem")
	self.rewardList = self.rightPanel:FindChild("Rewards/List")
	self.rewardItem = self.rightPanel:FindChild("Rewards/Item")
	self.handClick = self.rightPanel:FindChild("HandClick")
	
	self.rankViewMask = self.rankView:FindChild("Frame/Mask")
	self.rankPanel = self.rankView:FindChild("Frame/RankPanel")
	self.recordPanel = self.rankView:FindChild("Frame/RecordPanel")
	self.toggleRank = self.rankView:FindChild("Frame/ToggleGroup/ToggleRank")
	self.toggleRecord =  self.rankView:FindChild("Frame/ToggleGroup/ToggleRecord")
	self.rankScrCtrl = self.rankPanel:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.recordScrCtrl = self.recordPanel:FindChild("ScrollerController"):GetComponent("ScrollerController")
	
	self.trail = self:FindChild("Frame/Effect/Trail")
	self.explainPanel = self:FindChild("Frame/ExplainPanel")
	
	self.myRank = self.rankPanel:FindChild("Self")
	local data = {}
	data.parent = self.myRank:FindChild("Icon/HeadNode")
	self.myHeadIcon = CC.HeadManager.CreateHeadIcon(data);
	self.myRank:FindChild("Info/Name").text = CC.Player.Inst():GetSelfInfoByKey("Nick")
	local timeInfo = CC.TimeMgr.GetTimeInfo()
	self.myRank:FindChild("Info/Time").text = string.format("%02d-%02d-%d",timeInfo.day,timeInfo.month,timeInfo.year)
	
	self:AddClick(self.topPanel:FindChild("BtnExplain"),function ()
			self:ShowExplainPanel(true)
		end)
	self:AddClick(self.explainPanel:FindChild("Close"),function ()
			self:ShowExplainPanel(false)
		end)
	self:AddClick(self.topPanel:FindChild("BtnClose"),function ()
			CC.Sound.PlayHallEffect("MarsCloseView")
			self:PanelOut(true)
		end)
	self:AddClick(self.rankViewMask,"ChangeRankViewStatus")
	self:AddClick(self.btnUnlock,"OnClickBtnUnlock")
	self:AddClick(self.btnAtlas,"OnClickBtnAtlas")
	self:AddClick(self.targetView:FindChild("BtnBack"),function ()
			self:ChangeTargetLevel(self.showLevel-1)
		end)
	self:AddClick(self.targetView:FindChild("BtnNext"),function ()
			self:ChangeTargetLevel(self.showLevel+1)
		end)
	self:AddLongClick(self.btnRedPacket,{
			funcClick = function ()
				self:OnClickBtnRedPacket()
			end,
			funcLongClick = function ()
				self:ShowRedPacketTips(true)
			end,
			funcUp = function ()
				self:ShowRedPacketTips(false)
			end,
			time = 0.3,
		})
	
	self.rankScrCtrl:AddChangeItemListener(function(tran,dataIndex,cellIndex)
			self:RefreshRankItem(tran,dataIndex)
		end)
	self.rankScrCtrl:AddRycycleAction(function (tran)
			self:RycycleRankItem(tran)
		end)
	self.recordScrCtrl:AddChangeItemListener(function(tran,dataIndex,cellIndex)
			self:RefreshRecordItem(tran,dataIndex)
		end)
	self.recordScrCtrl:AddRycycleAction(function (tran)
			self:RycycleRecordItem(tran)
		end)
	
	UIEvent.AddToggleValueChange(self.toggleRank,function (selected)
			self.rankPanel:SetActive(selected)
			if selected then
				self.rankScrCtrl:InitScroller(#self.viewCtr.rankList)
				if not self.isRankViewOpen then
					self:ChangeRankViewStatus()
				end
			end
		end)
	UIEvent.AddToggleValueChange(self.toggleRecord,function (selected)
			self.recordPanel:SetActive(selected)
			if selected then
				self.recordScrCtrl:InitScroller(#self.viewCtr.recList)
				if not self.isRankViewOpen then
					self:ChangeRankViewStatus()
				end
			end
		end)
	self.musicName = self.param.orgMusic or CC.Sound.GetMusicName()
	CC.Sound.PlayHallBackMusic("MarsBg")
end

function M:InitTextByLanguage()
	self.topPanel:FindChild("JP").text = self.language.jp
	self.btnLock:FindChild("Text").text = self.language.btnLock
	self.btnUnlock:FindChild("Text").text = self.language.btnUnlock
	self.leftPanel:FindChild("ActTime").text = string.format(self.language.timeText,self.language.actTime)
	self.rightPanel:FindChild("Rewards/Text").text = self.language.rewardsText
	self.rightPanel:FindChild("TipText").text = self.language.tipTask
	self.rankView:FindChild("Frame/ToggleGroup/ToggleRank/Background/Label").text = self.language.btnRank
	self.rankView:FindChild("Frame/ToggleGroup/ToggleRank/Checkmark/Label").text = self.language.btnRank
	self.rankView:FindChild("Frame/ToggleGroup/ToggleRecord/Background/Label").text = self.language.btnRecord
	self.rankView:FindChild("Frame/ToggleGroup/ToggleRecord/Checkmark/Label").text = self.language.btnRecord
	self.recordPanel:FindChild("Top/Name").text = self.language.roleName
	self.recordPanel:FindChild("Top/Num").text = self.language.winInfo
	self.rankPanel:FindChild("Self/Info/Text").text = self.language.myRank
	self.explainPanel:FindChild("Bg1/Title").text = self.language.explainTitle
	self.explainPanel:FindChild("Scroll View/Viewport/Content/Text").text = string.format(self.language.explainText,self.language.actTime)
	self.btnRedPacket:FindChild("Tips/Text").text = self.language.redPacketTips
end

function M:InitUI()
	self.rightPanel:FindChild("TipText"):SetActive(self.curStage == 3)
	self:SetImage(self.taskItem:FindChild("Rewards"),self.marsTaskCfg[self.curStage].taskIcon)
	if self.param.curData then
		self:RefreshUI(self.param.curData)
	end
end

function M:RefreshUI(data,isLvUpAnimation)
	
	if data.taskInfo and not table.isEmpty(data.taskInfo) then
		self:RefreshTarget(data.taskInfo,isLvUpAnimation)
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
	
	if data.rankList and self.rankPanel.activeSelf then
		self.rankScrCtrl:InitScroller(#data.rankList)
	end

	if data.recList and self.recordPanel.activeSelf then
		self.recordScrCtrl:InitScroller(#data.recList)
	end

end

function M:RefreshTarget(param,isLvUpAnimation)
	self.showLevel = param.level > self.viewCtr.maxLevel and self.viewCtr.maxLevel or param.level
	local stage = math.ceil(self.showLevel/10)
	local index = self.showLevel%10~=0 and self.showLevel%10 or 10
	local img = string.format(self.marsTaskCfg[stage].targetImg,index)
	local curScore = param.score
	local totalScore = param.totalScore
	self:SetImage(self.targetView:FindChild("Main/Body/Image"),img)
	self.targetView:FindChild("Main/Body/Image"):GetComponent("Image"):SetNativeSize()
	self.targetView:FindChild("Name").text = self.language.targetName[stage][index]
	if stage == 3 then
		--阶段三
		curScore = totalScore - curScore
	end
	self.trail:FindChild("stage"):SetActive(stage ~= 3)
	self.trail:FindChild("stage3"):SetActive(stage == 3)
	self.targetView:FindChild("Progress/Text").text = string.format("%d/%d",curScore,totalScore)
	self.targetView:FindChild("Progress"):GetComponent("Slider").value = curScore/totalScore
	self.targetView:FindChild("BtnBack"):SetActive(self.showLevel%10 ~= 1 and self.showLevel > self.viewCtr.curLevel)
	self.targetView:FindChild("BtnNext"):SetActive(self.viewCtr.curLevel%10 ~= 0)
	self.btnLock:SetActive(self.showLevel > self.viewCtr.curLevel and not isLvUpAnimation)
	
	if (param.status == 2 or param.directStatus == 1) and not isLvUpAnimation then
		self.viewCtr:ReqMarsUpgrade()
	else
		if self.showLevel == self.viewCtr.curLevel then
			if self.viewCtr.unlockGift and not isLvUpAnimation then
				local buff = self.buffCfg[self.param.level]
				local isShow = buff and (not table.isEmpty(buff))
				self.btnUnlock:FindChild("Buff"):SetActive(isShow)
				self.btnUnlock:SetActive(true)
			else
				self.btnUnlock:SetActive(false)
			end
		else
			self.btnUnlock:SetActive(false)
		end
	end
end

function M:RefreshTaskList(param)
	local itemList = self.taskItemList
	
	for _,v in ipairs(itemList) do
		v.transform:SetActive(false)
	end

	self:RunAction(self.taskList,{"fadeToAll", 255, 0})
	for i,v in ipairs(param.taskList) do
		
		if v.Type == 7 and v.Status > 0 then
			self.btnUnlock:SetActive(false)
		end
		
		self:DelayRun(0.2*i,function ()
				if itemList[i] then
					itemList[i].data = v
					itemList[i].onRefreshData(v)
				else
					local item = self:CreateTaskItem(v)
					table.insert(itemList, item)
				end
		end)
	end
end

function M:CreateTaskItem(param)
	local item = {}
	item.data = param
	item.transform = CC.uu.newObject(self.taskItem, self.taskList)
	
	item.onRefreshData = function(param)

		self:RunAction(item.transform,{{"fadeToAll", 0, 0},{"fadeToAll", 255, 0.3}})
		
		item.transform:FindChild("Rewards/Num").text = param.Score
		item.transform:FindChild("Desc").text = string.format(self.language.taskType[param.Type],CC.uu.NumberFormat(param.NeeDValue))
		item.transform:FindChild("Progress/Text").text = CC.uu.NumberFormat(param.Value).."/"..CC.uu.NumberFormat(param.NeeDValue)
		item.transform:FindChild("Progress"):GetComponent("Slider").value = param.Value/param.NeeDValue
		
		item.transform:FindChild("Status/Go"):SetActive(param.Status==0)
		item.transform:FindChild("Status/Finish"):SetActive(param.Status~=0)
		item.transform:FindChild("Status/Get"):SetActive(param.Status==2)
		item.transform:FindChild("Light"):SetActive(param.Status==2)
		item.transform:FindChild("Mask"):SetActive(param.Status==1)
		item.transform:SetActive(true)
		
		if CC.LocalGameData.GetLocalDataToKey("MarsTaskGuide", self.playerId)  then
			if not self.isShowGuide and	param.Status==2 then
				CC.LocalGameData.SetLocalDataToKey("MarsTaskGuide", self.playerId)
				self.isShowGuide = true
				self:DelayRun(0.5,function ()
						self.handClick.position = item.transform.position
						self.handClick:SetActive(true)
					end)
			end
		end

		self:AddClick(item.transform:FindChild("Status/Get"),function ()
				if self.isShowGuide then
					self.handClick:SetActive(false)
				end
				self:OnClickTaskItemBtnGo(param,item.transform)
			end)
		self:AddClick(item.transform:FindChild("Status/Go"),function ()
				self:OnClickTaskItemBtnGo(param,item.transform)
			end)
	end

	item.onRefreshData(param)
	return item
end

function M:RefreshTaskRewards(param)
	local itemList = self.rewardsItemList

	if #itemList > #param then
		for i = #param+1, #itemList do
			itemList[i].transform:SetActive(false)
		end
	end

	for i,v in ipairs(param) do
		if itemList[i] then
			itemList[i].data = v
			itemList[i].onRefreshData(v)
		else
			local item = self:CreateRewardItem(v)
			table.insert(itemList, item)
		end
	end
end

function M:CreateRewardItem(param)
	local item = {}
	item.data = param
	item.transform = CC.uu.newObject(self.rewardItem, self.rewardList)

	item.onRefreshData = function(param)
		if param.isCard then
			self:SetImage(item.transform:FindChild("Icon"),"truecard5090")
			item.transform:FindChild("Bubble"):SetActive(false)
		elseif param.jpNum then
			self:SetImage(item.transform:FindChild("Icon"),"dj_jackpot")
			item.transform:FindChild("Bubble"):SetActive(true)
			item.transform:FindChild("Bubble/Image/Num").text = param.jpNum.."%"
		elseif param.redPacket then
			self:SetImage(item.transform:FindChild("Icon"),"prop_img_73")
			local str = ""
			if param.redPacket.min then
				str = str..string.format("%d%s",param.redPacket.min,self.currency)
			end
			if param.redPacket.max then
				str = str..string.format("~%d%s",param.redPacket.max,self.currency)
			end
			item.transform:FindChild("Num").text = str
			item.transform:FindChild("Bubble"):SetActive(false)
		else
			if param.ConfigId == CC.shared_enums_pb.EPC_One_Red_env then
				item.transform:SetActive(false)
				return
			else
				self:SetImage(item.transform:FindChild("Icon"),"prop_img_"..param.ConfigId)
				item.transform:FindChild("Bubble"):SetActive(false)
			end
		end
		item.transform:FindChild("Icon"):GetComponent("Image"):SetNativeSize()
		item.transform:FindChild("Num").text = param.Count
		item.transform:SetActive(true)
	end

	item.onRefreshData(param)
	return item
end

function M:RefreshJackpot(num)
	if self.curJp ~= num then
		local effect = self.topPanel:FindChild("JP/Effect")
		effect:SetActive(false)
		effect:SetActive(true)
	end
	self.curJp = num
	self.JPRoller:RollTo(num,1)
end

function M:RefreshRedPacket()
	local num = CC.Player.Inst():GetSelfInfoByKey("EPC_One_Red_env")
	self.btnRedPacket:FindChild("Text").text = string.format("%d%s",num,self.currency)
end

function M:ChangeRankViewStatus()
	self.isRankViewOpen = not self.isRankViewOpen
	self.rankViewMask:SetActive(self.isRankViewOpen)
	if self.isRankViewOpen then
		CC.Sound.PlayHallEffect("MarsOpenView")
		self:RunAction(self.rankView,{"localMoveBy", -356, 0, 0.2, ease=CC.Action.EOutSine})
	else
		CC.Sound.PlayHallEffect("MarsCloseView")
		self:RunAction(self.rankView,{"localMoveBy", 356, 0, 0.2, ease=CC.Action.EOutSine})
	end
end

function M:ChangeTargetLevel(level,isLvUpAnimation)
	local cb = function()
		self.showLevel = level > self.curStage*10 and  self.viewCtr.curLevel or level
		local param
		if self.showLevel == self.viewCtr.curLevel then
			param = self.viewCtr.curTaskData
		else
			param = self.viewCtr.allTaskData[self.showLevel] or {}
		end
		self:RefreshUI(param,isLvUpAnimation)
		if not isLvUpAnimation then
			self:PanelIn()
		end
	end
	if isLvUpAnimation then
		cb()
	else
		self:PanelOut(nil,cb)
	end
end

function M:RefreshRankItem(trans,index)
	if not self.viewCtr then return end
	local dataIdx = index + 1
	local rankList = self.viewCtr.rankList

	if not rankList or table.isEmpty(rankList) then
		return
	end

	local rankData = rankList[dataIdx]
	local rank = rankData.RankID
	local rankImg = trans:FindChild("Icon/Rank")
	local rankImgSp = trans:FindChild("Icon/RankSp")
	trans.name = dataIdx
	if rank <= 3 then
		self:SetImage(rankImgSp, string.format("hxrw_phb_mc%02d",rank))
		rankImgSp:GetComponent("Image"):SetNativeSize()
		rankImg:SetActive(false)
		rankImgSp:SetActive(true)
	else
		rankImg:FindChild("Text").text = rank
		rankImg:SetActive(true)
		rankImgSp:SetActive(false)
	end
	trans:FindChild("Info/Name").text = rankData.Name
	--trans:FindChild("Info/Time").text = ""
	trans:FindChild("Score/Text").text = string.format("%d/%d",rankData.score,self.viewCtr.maxLevel)
	local stage = math.ceil(rankData.score/10)
	local index = rankData.score%10~=0 and rankData.score%10 or 10
	self:SetImage(trans:FindChild("Score/Image"),string.format(self.marsTaskCfg[stage].rankIcon,index))
	
	local IconData = {}
	IconData.parent = trans:FindChild("Icon/HeadNode")
	IconData.playerId = rankData.PlayerId
	IconData.portrait = rankData.Portrait
	IconData.unShowVip = true
	--IconData.headFrame = rankData.Background
	--IconData.vipLevel = rankData.Level
	local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.rankHeadIconList[dataIdx] = headIcon
end

function M:RycycleRankItem(trans)
	local index = tonumber(trans.transform.name)
	if self.rankHeadIconList[index] then
		self.rankHeadIconList[index]:Destroy(true)
	end
end

function M:RefreshRecordItem(trans,index)
	if not self.viewCtr then return end
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
	local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.recHeadIconList[dataIdx] = headIcon
end

function M:RycycleRecordItem(trans)
	local index = tonumber(trans.transform.name)
	if self.recHeadIconList[index] then
		self.recHeadIconList[index]:Destroy(true)
	end
end

function M:ShowNumberRoller(num,callback)
	self:SetCanClick(false)
	if self.numberRoller then
		self.numberRoller:Destroy()
		self.numberRoller = nil
	end
	self:FindChild("Frame/RollerNode"):SetActive(true)
	local param = {
		parent = self:FindChild("Frame/RollerNode"),
		number = num,
		callback = function()
			self:SetCanClick(true)
			self:FindChild("Frame/RollerNode"):SetActive(false)
			if callback then
				callback()
			end
		end
	}
	self.numberRoller = CC.ViewCenter.NumberRoller.new();
	self.numberRoller:Create(param);
end

function M:SetMyRankScore(cur,max)
	local level = cur > max and max or cur
	local stage = math.ceil(level/10)
	local index = self.viewCtr:GetIndexByLevel(level)
	self.myRank:FindChild("Score/Text").text = level.."/"..max
	self:SetImage(self.myRank:FindChild("Score/Image"),string.format(self.marsTaskCfg[stage].rankIcon,index))
end

function M:ShowExplainPanel(isShow)
	if isShow then
		CC.Sound.PlayHallEffect("MarsOpenView")
		self:RunAction(self.explainPanel, {"spawn",
				{"fadeToAll", 0, 0, function() self.explainPanel:SetActive(true) end},
				{"fadeToAll", 255, 0.2},
				{"scaleTo",1,0,0},
				{"scaleTo",1,1,0.2}
			});
	else
		CC.Sound.PlayHallEffect("MarsCloseView")
		self:RunAction(self.explainPanel, {"spawn",
				{"fadeToAll", 0, 0.2},
				{"scaleTo",1,0,0.2, function() self.explainPanel:SetActive(false) end}
			});
	end
end

function M:OnClickBtnAtlas()
	CC.ViewManager.Open("MarsTaskAtlasView",{curLevel = self.viewCtr.curLevel, maxLevel = self.viewCtr.maxLevel})
end

function M:OnClickBtnUnlock()
	if not self.viewCtr.unlockGift then return end
	local index = self.viewCtr:GetIndexByLevel(self.viewCtr.curLevel)
	local param = {}
	param.stage = self.curStage
	param.level = index
	param.rewards = self.viewCtr.unlockGift.Prop
	param.price = self.viewCtr.unlockGift.Amount
	param.succCb = function()
		self.btnUnlock:SetActive(false)
		--三阶段直升解锁
		self.directUp = true
		self:DelayRun(1,function ()
				self.viewCtr:ReqCurTaskInfo()
			end)
	end
	param.errCb = function()
		logError("Buy UnlockGift Faile")
	end
	CC.ViewManager.Open("MarsTaskUnlockView",param)
end

function M:OnClickTaskItemBtnGo(data,item)
	--Type type类型 1在线时长 2分享 3游戏累计流水 4累计好友 5绑定手机 6.赠送一笔 7.钻石解锁 8.解锁安全码 11.任意充值
	if data.Status == 0 then
		if data.Type == 1 then
			CC.ViewManager.ShowTip(self.language.tip1)
		elseif data.Type == 2 then
			local param = {}
			param.imgName = "share_1_8"
			param.shareCallBack = function()
				self.viewCtr:ReqShareTask()
			end
			CC.ViewManager.Open("ImageShareView", param)
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
		elseif data.Type == 8 then
			if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("OTPVerify") then
				if not CC.HallUtil.CheckTelBinded() then
					CC.ViewManager.Open("BindTelView")
					return
				end
			end

			if CC.HallUtil.CheckSafePassWord() then
				CC.ViewManager.Open("SafeBoxView")
			end
		elseif data.Type == 11 then
			CC.ViewManager.Open("StoreView")
		end
	elseif data.Status == 2 then
		self.finishTaskItem = item
		self.viewCtr:ReqFinishSubTask(data.SubTaskID)
	end
end

function M:OnClickBtnRedPacket()
	local num = CC.Player.Inst():GetSelfInfoByKey("EPC_One_Red_env") or 0
	if num > 0 then
		CC.ViewManager.OpenAndReplace("TreasureView",{exchangeId = "100064"})
	else
		CC.ViewManager.ShowTip(self.language.redPacketNotEnought)
	end
end

function M:ShowSubTaskFinishEffect(callback)
	if self.finishTaskItem then
		self:RunAction(self.taskList,{"fadeToAll", 0, 0.5})
		local begin = self.finishTaskItem:FindChild("Rewards").transform.position
		local target = nil
		local stage = math.ceil(self.showLevel/10)
		if stage == 3 then
			target = self.targetView:FindChild("Main/Body/Aim").transform.position
		else
			target = self.targetView:FindChild("Progress").transform.position
		end
		local cb = function()
			self:ShowProgressEffect()
			callback()
		end
		self:ShowTrailEffect(begin,target,cb)
	else
		callback()
	end
end

function M:ShowTrailEffect(begin,target,callback)
	local duration = 0.4
	local deltaX = target.x - begin.x
	local deltaY = target.y - begin.y
	local mid = Vector3(begin.x+deltaX/2,begin.y+deltaY/3,target.z)
	local path ={begin,mid,target}
	self.trail.position = begin
	self.trail:SetActive(true)
	self.trail:DOPath(path,duration,DG.Tweening.PathType.CatmullRom)
	CC.Sound.PlayHallEffect("MarsFly")
	self:DelayRun(duration,function ()
			self.trail:SetActive(false)
			if callback then callback() end
		end)
end

function M:ShowProgressEffect()
	CC.Sound.PlayHallEffect("MarsHit")
	local stage = math.ceil(self.showLevel/10)
	local effect = nil
	if stage == 3 then
		effect = self.targetView:FindChild("Main/Body/Aim/Strike")
	else
		effect = self.targetView:FindChild("Effect/Progress")
	end
	effect:SetActive(false)
	effect:SetActive(true)
end

function M:ShowLevelUpEffect(callback)
	local curLv = self.viewCtr.curLevel
	self:ChangeTargetLevel(curLv,true)
	self:SetCanClick(false)
	self.btnAtlas:SetActive(false)
	self.rightPanel:SetActive(false)
	self.topPanel:SetActive(false)
	self.targetView:FindChild("Main/Body"):GetComponent("Animator").enabled = false
	self.targetView:FindChild("Main/Body").localPosition = Vector3(0,0,0)
	local effect = self.targetView:FindChild("Main/Body/LevelUp")
	local delayTime = math.ceil(curLv/10) == 3 and 3 or 1.5
	self:RunAction(self.leftPanel:FindChild("Node"),{
			{"localMoveTo",280,0,0.3,function ()
				--移动到中间
					self.targetView:FindChild("Main/Body").localScale = Vector3(1.35,1.35,1)
				end},
			{"delay",delayTime,function ()
				--升级特效
					effect:SetActive(false)
					effect:SetActive(true)
					CC.Sound.PlayHallEffect("MarsHit")
					self:ChangeTargetLevel(curLv+1,true)
				end},
			{"delay",1.5},
			{"localMoveTo",0,0,0.3,function ()
				--返回初始位置
					self.btnAtlas:SetActive(true)
					self.rightPanel:SetActive(true)
					self.topPanel:SetActive(true)
					self:SetCanClick(true)
					self.targetView:FindChild("Main/Body").localScale = Vector3(1,1,1)
					self.targetView:FindChild("Main/Body"):GetComponent("Animator").enabled = true
					callback()
				end},
		})
	if math.ceil(curLv/10) == 3 and self.directUp then
		--三阶段直升特效
		local aimIcon = self.targetView:FindChild("Main/Body/Aim/Image")
		aimIcon.transform.localPosition = Vector3(1200,-400,0)
		local aimEffect = self.targetView:FindChild("Main/Body/Aim/DirectUp")
		self:RunAction(aimIcon,{
			{"localMoveTo",0,0,1.5},
			{"delay", 0.5, function ()
				aimEffect:SetActive(true)
				aimIcon:SetActive(false)
			end},
			{"delay", 3, function ()
				aimIcon.transform.localPosition = Vector3.zero
				aimIcon:SetActive(true)
				aimEffect:SetActive(false)
			end},
		})
	end
end

function M:ShowRedPacketTips(isShow)
	self.btnRedPacket:FindChild("Tips"):SetActive(isShow)
end

function M:PanelIn()
	self:SetCanClick(false)
	self:RunAction(self:FindChild("Frame/LeftPanel"),{"localMoveTo", -290, 0,0.3})
	self:RunAction(self:FindChild("Frame/RightPanel"),{"localMoveBy", -635, 0,0.3})
	self:RunAction(self:FindChild("Frame/TopPanel"),{"localMoveBy", 0, -120,0.3,function () self:SetCanClick(true)	end})
end

function M:PanelOut(isClose,callback)
	if not isClose then 
		CC.Sound.PlayHallEffect("MarsSwitch")
	end
	self:SetCanClick(false)
	self:RunAction(self:FindChild("Frame/LeftPanel"),{"localMoveTo", -960, 0,0.3})
	self:RunAction(self:FindChild("Frame/RightPanel"),{"localMoveBy", 635, 0,0.3})
	self:RunAction(self:FindChild("Frame/TopPanel"),{"localMoveBy", 0, 120,0.3,
			function ()
				if isClose then
					self:ActionOut()
				else
					self:SetCanClick(true)
				end
				if callback then callback() end
			end})
end

function M:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {"spawn",
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.2},
			{"scaleTo",1,0,0},
			{"scaleTo",1,1,0.2, function() self:PanelIn() end}
		});
end

function M:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {"spawn",
			{"fadeToAll", 0, 0.2},
			{"scaleTo",1,0,0.2, function() self:Destroy() end}
		});
end

function M:OnDestroy()
	
	if self.musicName then
		CC.Sound.PlayHallBackMusic(self.musicName);
	else
		CC.Sound.StopBackMusic();
	end
	
	if self.numberRoller then
		self.numberRoller:Destroy()
		self.numberRoller = nil
	end
	
	for _,v in pairs(self.recHeadIconList) do
		--销毁中奖记录头像
		if v then
			v:Destroy(true)
			v = nil
		end
	end
	
	for _,v in pairs(self.rankHeadIconList) do
		--销毁排行榜头像
		if v then
			v:Destroy(true)
			v = nil
		end
	end
	
	if self.myHeadIcon then
		self.myHeadIcon:Destroy(true)
		self.myHeadIcon = nil
	end
	
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end

end

return MarsTaskView