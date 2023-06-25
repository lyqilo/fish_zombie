local CC = require("CC")
local NewbieTaskView = CC.uu.ClassView("NewbieTaskView")

--param.isGiftCollection礼包合集打开，callBack显示合集关闭按钮回调
function NewbieTaskView:ctor(param)
    self.param = param;
	self.language = self:GetLanguage()
	self.createTime = os.time()+math.random()
	self.PrefabTab = {}
	self.AwardProfab = {}
	self.LivenessTab = {}
	self.livenessId = {8001, 9001, 10001, 11001, 12001}
	self.debrisNum = 0
	--活跃度
	self.curLiveness = 0
	self.livenessScale = {25, 35, 45, 55, 70}
end

function NewbieTaskView:OnCreate()
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.newbieTask = CC.ConfigCenter.Inst():getConfigDataByKey("NewbieTask")
	self.noviceDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("NoviceDataMgr")
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitUI()
end

function NewbieTaskView:InitUI()
    for i = 1, 5 do
        local ind = i
		self.LivenessTab[i] = self:FindChild(string.format("LeftPanel/Liveness_%s", ind))
		self.LivenessTab[i]:FindChild("num").text = self.livenessScale[ind]
		self:LivenessBtnClick(ind)
	end
	self.LivenessSlider = self:FindChild("LeftPanel/Slider")

    self.Scroller = self:FindChild("RightPanel/TaskScr")
	self.ContentTask = self.Scroller:FindChild("Viewport/Content")
	self.ItemTask = self.Scroller:FindChild("Viewport/ItemTask")
	self.Goods = self.Scroller:FindChild("Viewport/Goods")

	self.awardScr = self:FindChild("BubbleTip/AwardScr")
	self.awardItem = self:FindChild("BubbleTip/AwardItem")
	self:AddClick(self:FindChild("BubbleTip/closeTip"),function()
        self:FindChild("BubbleTip"):SetActive(false)
    end)

	self.timeText = self:FindChild("BreakFragment/Frame/time")

	self:AddClick(self:FindChild("RightPanel/Bottom/BtnConvert"), function ()
		self:BreakView("TreasureView", 2)
	end)

	self:AddClick(self:FindChild("BtnRule"), function ()
		self:FindChild("ExplainView"):SetActive(true)
	end)
	self:AddClick(self:FindChild("ExplainView/Frame/BtnClose"), function ()
		self:FindChild("ExplainView"):SetActive(false)
    end)
	self:AddClick(self:FindChild("BtnClose"), function ()
		self:CloseView()
	end)

	self:FindChild("RightPanel/Bottom/BtnConvert"):SetActive(CC.ViewManager.IsHallScene())
	self.viewCtr:ReqTaskListInfo()
    self:LanguageSwitch()
end

--语言切换
function NewbieTaskView:LanguageSwitch()
	self:FindChild("RightPanel/Bottom/Text").text = self.language.bottomText
	self:FindChild("RightPanel/Bottom/BtnConvert/Text").text = self.language.convertBtn
	self.ItemTask:FindChild("GoBtn/Text").text = self.language.goBtn
	self.ItemTask:FindChild("GetBtn/Text").text = self.language.getBtn
	self.ItemTask:FindChild("GrayBtn/Text").text = self.language.getBtn
	self.ItemTask:FindChild("reward").text = self.language.reward
	self:FindChild("BreakFragment/Frame/Text1").text = self.language.finishText1
	self:FindChild("BreakFragment/Frame/Text2").text = self.language.finishText2
	self:FindChild("ExplainView/Frame/Tittle/Text").text = self.language.ruleTitle
	self:FindChild("ExplainView/Frame/ScrollText/Viewport/Content/Text").text = self.language.ruleText
end

function NewbieTaskView:NowLivenessValue(value)
	self.curLiveness = value
	self:FindChild("LeftPanel/NowLiveness").text = string.format(self.language.nowLiveness, value)
	local sliderValue = 0
	for i = 1, #self.livenessScale do
		if value <= self.livenessScale[i] then
			--计算当前活跃度在slider的多少
			if i > 1 then
				local gap = self.livenessScale[i] - self.livenessScale[i - 1]
				sliderValue = 14 * (i - 1) + 14 / gap * (value - self.livenessScale[i - 1])
			else
				sliderValue = 14 / 25 * value
			end
			break
		end
	end
	self.LivenessSlider:FindChild("Fill/effectSlider"):SetActive(sliderValue > 0)
	self.LivenessSlider:GetComponent("Slider").value = sliderValue / 70
end

function NewbieTaskView:SetLivenessStatus(data)
	local idx = math.floor(data.ID / 1000) - 7
	if self.LivenessTab[idx] then
		self.LivenessTab[idx]:FindChild("default"):SetActive(not data.IsFinish)
		self.LivenessTab[idx]:FindChild("open"):SetActive(data.IsReward)
		self.LivenessTab[idx]:FindChild("effect"):SetActive(data.IsFinish and not data.IsReward)
	end
	if data.ID == 12001 then
		self:NowLivenessValue(data.Process)
	end
end

function NewbieTaskView:LivenessBtnClick(index)
	self:AddClick(self.LivenessTab[index]:FindChild("default"),function()
		self:SetBubbleAward(index)
        self:FindChild("BubbleTip"):SetActive(true)
    end)
	self:AddClick(self.LivenessTab[index]:FindChild("effect/Baoxiang"),function()
		if self.curLiveness >= self.livenessScale[index] then
			self.viewCtr:ReqAcquireReward(self.livenessId[index])
		else
			logError("活跃度不足")
		end
    end)
end

--活跃度宝箱奖励
function NewbieTaskView:SetBubbleAward(index)
	self:FindChild("BubbleTip").transform.localPosition = Vector3(80,  -292 + index * 84, 0)
	if index < 5 then
		self:FindChild("BubbleTip/Acquire").text = string.format(self.language.livenessBox, index * 10 + 15)
	else
		self:FindChild("BubbleTip/Acquire").text = self.language.realBox
	end
	for _,v in pairs(self.AwardProfab) do
		v.transform:SetActive(false)
	end
	local param = self.newbieTask[self.livenessId[index]].Items
	for i=1, #param do
		self:AddAwardItem(i, param[i])
	end
end

function NewbieTaskView:AddAwardItem(index, param)
	local rewardType = param.ConfigId
	local rewardAmount = param.Count or 0
	local quality = self:InitQuality(rewardType,rewardAmount)

	local obj = nil
	if not self.AwardProfab[index] then
		obj = CC.uu.newObject(self.awardItem)
		self.AwardProfab[index] = obj
	else
		obj = self.AwardProfab[index]
	end
	obj.transform:SetParent(self.awardScr, false)
	obj:SetActive(true)

	local bg = obj.transform:FindChild("bg")
	self:SetImage(bg, "award_" .. quality)
	if rewardType == CC.shared_enums_pb.EPC_New_GiftVoucher then
		--新礼劵
		bg:FindChild("num").text = string.format("%s—%s", param.Min, param.Max)
	else
		bg:FindChild("num").text = CC.uu.DiamondFortmat(rewardAmount)
	end
    local node = obj.transform:FindChild("bg/Sprite")
    self:SetImage(node, self.propCfg[rewardType].Icon);
end

function NewbieTaskView:InitQuality(propID,count)
	if propID == CC.shared_enums_pb.EPC_ChouMa then
		if count < 10000 then
			return 1
		elseif count < 999999 then
			return 2
		else
			return 3
		end
	else
		return self.propCfg[propID].Quality
	end
end

function NewbieTaskView:ShowRewardItemTip(isShow, param)
	if isShow then
		if not self.rewardItemTip then
			self.rewardItemTip = CC.ViewCenter.CommonItemDes.new();
			self.rewardItemTip:Create({parent = param.node});
		end
		local data = {
			parent = param.node,
			propId = param.propId,
		}
		self.rewardItemTip:Show(data);
	else
		if not self.rewardItemTip then return end;
		self.rewardItemTip:Hide();
		self.rewardItemTip.transform:SetParent(self:FindChild("ViewBtn"))
		self.rewardItemTip.transform.localPosition = Vector3.zero
	end
	self:FindChild("ViewBtn"):SetActive(isShow)
end

--初始化任务列表
function  NewbieTaskView:InitTaskInfo(data)
	local list = data
	for _,v in pairs(self.PrefabTab) do
		v.transform:SetActive(false)
	end
	for i = 1,#list do
		self:AddItemData(i,list[i])
	end
end

function NewbieTaskView:AddItemData(index, data)
	local taskInfo = self.newbieTask[data.ID]
	if not taskInfo then
		return
	end
	local item = nil
	if self.PrefabTab[index] == nil then
		item = CC.uu.newObject(self.ItemTask)
		item.transform.name = tostring(index)
		self.PrefabTab[index] = item.transform
	else
		item = self.PrefabTab[index]
	end
	item:SetActive(true)

	if item then
		item.transform:SetParent(self.ContentTask, false)
		--log(CC.uu.Dump(data, "data",10))
		if not taskInfo.IsRewards then
			--任务没有大奖
			item:FindChild("des"):SetActive(false)
			item:FindChild("name").localPosition = Vector3(-145, 45, 0)
			item:FindChild("reward").localPosition = Vector3(-200, -14, 0)
			item:FindChild("GoodsScr").localPosition = Vector3(-200, -16, 0)
		else
			item:FindChild("des"):SetActive(true)
			item:FindChild("name").localPosition = Vector3(15, 45, 0)
			item:FindChild("reward").localPosition = Vector3(-48, -14, 0)
			item:FindChild("GoodsScr").localPosition = Vector3(-65, -16, 0)
			local curCount = data.ID % 1000
			if curCount <= taskInfo.TotalCount then
				if not data.IsFinish then
					curCount = curCount - 1
				end
				item:FindChild("des/count").text = curCount .."/".. taskInfo.TotalCount
				item:FindChild("des/Slider"):GetComponent("Slider").value = curCount / taskInfo.TotalCount
				item:FindChild("des/Text").text = self.viewCtr:GetTaskReward(data.ID)
			end
		end
		local target = data.Target
		local process = (data.Process > target and target) or data.Process
		if math.floor(data.ID / 1000) == 3 then
			--在线时长任务
			target = math.floor(target / 3600)
			process = math.floor(process / 3600)
		end
		process = process + taskInfo.SingleCount - target
		item:FindChild("num").text = process .."/".. taskInfo.SingleCount
		if math.floor(data.ID / 1000) == 2 then
			item:FindChild("num"):SetActive(false)
		end
		item:FindChild("name").text = self.viewCtr:GetTaskName(data.ID)
		self:SetItemBtn(item, data)

		local content = item:FindChild("GoodsScr")
		self:SetGoodScr(content, taskInfo)
	end
end

function NewbieTaskView:SetItemBtn(item, data)
	item:FindChild("GrayBtn"):SetActive(false)
	item:FindChild("GoBtn"):SetActive(not data.IsFinish)
	item:FindChild("fulfill"):SetActive(data.IsFinish and data.IsReward or false)
	item:FindChild("GetBtn"):SetActive(data.IsFinish and not data.IsReward or false)
	local index = math.floor(data.ID / 1000)
	if index == 1 then
		--新手签到是否结束
		if not self.noviceDataMgr.GetNoviceDataByKey("NoviceSignInView").open then
			item:FindChild("GoBtn"):SetActive(false)
		end
		if not self.activityDataMgr.GetActivityInfoByKey("NoviceSignInView").switchOn then
			item:SetActive(false)
		end
	end
	if index == 7 and not CC.Player.Inst():GetFirstGiftState() then
		--首冲礼包
		item:FindChild("GoBtn"):SetActive(false)
	end
	if data.IsFinish then
		--任务完成
		if not data.IsReward then
			--奖励没领取
			self:AddClick(item:FindChild("GetBtn"), function( )
				self.viewCtr:ReqAcquireReward(data.ID)
			end)
		end
	else
		if index == 6 and not CC.ViewManager.IsHallScene() then
			item:FindChild("GoBtn"):SetActive(false)
		end
		self:AddClick(item:FindChild("GoBtn"), function( )
			self:ByTaskIdJump(data.ID)
		end)
		if index == 2 or index == 3 or index == 16 or index == 20 or (index == 1 and self.viewCtr.isSign) then
			item:FindChild("GoBtn"):SetActive(false)
			item:FindChild("GrayBtn"):SetActive(true)
		end
	end
end

function NewbieTaskView:SetGoodScr(content, taskInfo)
	--奖励物品信息
	for i = content.childCount, 1 , -1 do
		local tran = content.transform:GetChild(i - 1)
		if tran then
			tran.gameObject:Destroy()
		end
	end
	for _, v in pairs(taskInfo.Items) do
		local obj = CC.uu.newObject(self.Goods)
		self:SetImage(obj:FindChild("icon"), self.propCfg[v.ConfigId].Icon)
		if v.ConfigId == CC.shared_enums_pb.EPC_New_GiftVoucher then
			--新礼劵
			if v.Min == v.Max then
				obj:FindChild("num").text = v.Max
			else
				obj:FindChild("num").text = v.Min .. "—" .. v.Max
			end
			-- obj.onClick = function ()
			-- 	local data = {};
			-- 	data.node = obj
			-- 	data.propId = v.ConfigId
			-- 	self:ShowRewardItemTip(true,data)
			-- end
		else
			obj:FindChild("num").text = CC.uu.DiamondFortmat(v.Count)
		end
		obj.transform:SetParent(content, false)
		obj:SetActive(true)
	end
end

--跳转
function NewbieTaskView:ByTaskIdJump(taskId)
	local num = math.floor(taskId / 1000)
	if num == 1 then
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnChangeFreeChipsView, "NoviceSignInView")
	--elseif num == 3 then
		--在线时长，返回大厅
	elseif num == 4 then
		--CC.ViewManager.Open("CaptureScreenShareView",{})
		local param = {}
		param.imgName = "share_1_5_20201022"
		param.content = self.language.share_content
		param.shareType = CC.shared_enums_pb.ClientShareCommon
		CC.ViewManager.Open("ImageShareView",param)
	elseif num == 5 then
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnChangeFreeChipsView, "DailyTurntableView")
	elseif num == 6 then
		--比赛
		self:BreakView("ArenaView")
	elseif num == 7 then
		self:BreakView("FirstBuyGiftView")
	elseif num == 13 then
		CC.ViewManager.Open("PersonalInfoView")
	elseif num == 14 then
		self:BreakView("FriendView")
	elseif num == 17 then
		CC.ViewManager.Open("BindTelView")
	end
	--self:CloseView()
end

function NewbieTaskView:BreakView(openView, OpenViewId)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, false)
	local param = {}
	local fun = function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, true)
	end
	param.closeFunc = fun
	if OpenViewId then
		param.OpenViewId = OpenViewId
	end
	CC.ViewManager.Open(openView, param)
end

--新手任务都完成或结束
function NewbieTaskView:NewbieTaskFinish()
	self:FindChild("BreakFragment"):SetActive(true)
	local countDown = 3
	self.timeText.text = countDown
	self:StartTimer("CountDown"..self.createTime, 1, function()
		countDown = countDown - 1
        if countDown <= 0 then
			self.timeText.text = countDown
			self:StopTimer("CountDown"..self.createTime)
			self:DelayRun(1, function ( )
				self:SwitchView()
			end)
		else
			self.timeText.text = countDown
		end
    end, -1)
end

function NewbieTaskView:SwitchView()
	self.noviceDataMgr.SetNoviceDataByKey("NewbieTaskView", false)
	-- self.noviceDataMgr.SetNoviceDataByKey("FragmentTaskView", true)
	-- CC.HallNotificationCenter.inst():post(CC.Notifications.OnChangeFreeChipsView, "FragmentTaskView");
	--新手任务和碎片任务请求相同，注销新手界面监听
	self.viewCtr:unRegisterEvent()
end

function NewbieTaskView:ActionIn()
	if self.param and self.param.isGiftCollection then
		self:SetCanClick(false);
		self.transform.size = Vector2(125, 0)
		self.transform.localPosition = Vector3(-125 / 2, 0, 0)
		self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
	end
end

function NewbieTaskView:ActionOut()
	self:SetCanClick(false);
	CC.HallUtil.HideByTagName("Effect", false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

--关闭界面
function NewbieTaskView:CloseView()
	if self.param and self.param.callBack then
		self.param.callBack(true)
	end
	self:ActionOut()
end

function NewbieTaskView:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true);
	if self.viewCtr then
		self.viewCtr:ReqTaskListInfo()
	end
end

function NewbieTaskView:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function NewbieTaskView:OnDestroy()
	--CC.Sound.StopEffect()
	self:StopTimer("CountDown"..self.createTime)
	self:CancelAllDelayRun()
	if self.param and self.param.callBack then
		self.param.callBack(true)
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
	if self.rewardItemTip then
		self.rewardItemTip:Destroy()
		self.rewardItemTip = nil
	end
end

return NewbieTaskView;