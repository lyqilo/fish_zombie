local CC = require("CC")
local FragmentTaskView = CC.uu.ClassView("FragmentTaskView")

--param.isGiftCollection礼包合集打开，callBack显示合集关闭按钮回调
function FragmentTaskView:ctor(param)
    self.param = param;
	self.language = self:GetLanguage()
	self.PrefabTab = {}
	self.AwardProfab = {}
	self.LivenessTab = {}
	self.livenessId = {8001, 9001, 10001, 11001, 12001}
	self.debrisNum = 0
	--活跃度
	self.curLiveness = 0
	self.livenessScale = {25, 35, 45, 55, 70}
end

function FragmentTaskView:OnCreate()
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.newbieTask = CC.ConfigCenter.Inst():getConfigDataByKey("NewbieTask")
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitUI()
end

function FragmentTaskView:InitUI()
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

	self.awardScr = self:FindChild("BubbleTip/AwardScr")
	self.awardItem = self:FindChild("BubbleTip/AwardItem")
	self:AddClick(self:FindChild("BubbleTip/closeTip"),function()
        self:FindChild("BubbleTip"):SetActive(false)
    end)

	self:AddClick(self:FindChild("RightPanel/Bottom/BtnConvert"), function ()
		CC.ViewManager.Open("TreasureView", {closeFunc = fun, OpenViewId = 2})
	end)
	self:AddClick(self:FindChild("BtnClose"), function ()
		self:CloseView()
	end)

	self.viewCtr:ReqTaskListInfo()
    self:LanguageSwitch()
	self:InitTaskInfo()
	self:SetDebrisConvert()
end

--语言切换
function FragmentTaskView:LanguageSwitch()
	self:FindChild("RightPanel/Bottom/Text").text = self.language.rule
	self:FindChild("RightPanel/Bottom/BtnConvert/Text").text = self.language.convertBtn
	self.ItemTask:FindChild("GoBtn/Text").text = self.language.goBtn
	self.ItemTask:FindChild("des").text = self.language.des
end

function FragmentTaskView:NowLivenessValue(value)
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
	self:SetDebrisConvert()
end

function FragmentTaskView:SetLivenessStatus(data)
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

function FragmentTaskView:LivenessBtnClick(index)
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
function FragmentTaskView:SetBubbleAward(index)
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

function FragmentTaskView:AddAwardItem(index, param)
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
	if rewardType == CC.shared_enums_pb.EPC_PointCard_Fragment then
		--点卡碎片
		bg:FindChild("num").text = param.Min .. "—" .. param.Max
	else
		bg:FindChild("num").text = CC.uu.DiamondFortmat(rewardAmount)
	end
    local node = obj.transform:FindChild("bg/Sprite")
    self:SetImage(node, self.propCfg[rewardType].Icon);
end

function FragmentTaskView:InitQuality(propID,count)
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

--设置碎片兑换
function FragmentTaskView:SetDebrisConvert()
	self.debrisNum = CC.Player.Inst():GetSelfInfoByKey("EPC_PointCard_Fragment")
	self:FindChild("RightPanel/Bottom/debris/num").text = self.debrisNum .. "/" .. 70
end

--初始化任务列表
function  FragmentTaskView:InitTaskInfo()
	self:FindChild("RightPanel/Bottom/BtnConvert"):SetActive(CC.ViewManager.IsHallScene())
	for _,v in pairs(self.PrefabTab) do
		v.transform:SetActive(false)
	end
	for i = 1, 9 do
		self:AddItemData(i)
	end
end

function FragmentTaskView:AddItemData(index)
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
		local taskName = "taskName" .. index
		item:FindChild("name").text = self.language[taskName]
		if not CC.ViewManager.IsHallScene() then return end
		item:FindChild("GoBtn"):SetActive(true)
		self:AddClick(item:FindChild("GoBtn"), function( )
			CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, false)
			local fun = function()
				CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, true)
			end
			CC.ViewManager.Open("ArenaView", {closeFunc = fun})
		end)
	end
end

function FragmentTaskView:ActionIn()
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

function FragmentTaskView:ActionOut()
	self:SetCanClick(false);
	CC.HallUtil.HideByTagName("Effect", false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

--关闭界面
function FragmentTaskView:CloseView()
	if self.param and self.param.callBack then
		self.param.callBack(true)
	end
	self:ActionOut()
end

function FragmentTaskView:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true);
	if self.viewCtr then
		self.viewCtr:ReqTaskListInfo()
	end
end

function FragmentTaskView:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function FragmentTaskView:OnDestroy()
	--CC.Sound.StopEffect()
	self:CancelAllDelayRun()
	if self.param and self.param.callBack then
		self.param.callBack(true)
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
end

return FragmentTaskView;