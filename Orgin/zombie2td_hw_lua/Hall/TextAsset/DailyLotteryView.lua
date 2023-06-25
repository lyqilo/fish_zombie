---------------------------------
-- region DailyLotteryView.lua
-- Date: 2020-06-17 14:21
-- Desc: 每日抽奖活动弹窗
-- Author: GuoChaoWen
---------------------------------
local CC = require("CC")
local DailyLotteryView = CC.uu.ClassView("DailyLotteryView")

function DailyLotteryView:ctor(param)
	self:InitVar(param)
end

function DailyLotteryView:InitVar(param)
	self.param = param or {}
	self.base = 1001						-- 基础奖励配置
	self.isInitReward = true				-- 初始化奖励
	self.bCanLottery = true					-- 是否可以抽奖
	self.nCurLightIndex = 1					-- 当前跑灯的下标
	self.nTotalRoundAmount = 8				-- 一圈总个数
	self.nPlayRound = 3						-- 播放的圈数
	self.runIntervalTime = 0.3				-- 跑马灯间隔时间
	self.scrollItems = {}					-- 滚动列表item
	self.contentMoveStatus = {}				-- 当前滚动文字标识
	self.curMoveIndex = 0					-- 当前滚动文字标识
	self.RewardInfo = {}					-- 大奖排行榜信息
	self.lotteryTime = 0 					-- 摇奖次数
	self.bShareFinish = false				-- 分享任务是否完成
	self.bOnlineFinish = false				-- 在线任务是否完成
	self.rewardData = {}					-- 奖励弹窗中的奖品信息
	self.nAwardId = 0						-- 中奖id
	self.iconTab = {}						-- 排行榜头像信息
	self.rankNum = 0						-- 排行榜排名
	self.coroutine = nil
	self.rollInfoData = {}
	self.showCfg = {}
	self.toggleList= {}
	self.curPage = 1
	self.maxPage = 1
	self.DailyLotteryDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("DailyLotteryDataMgr")
	self.language = self:GetLanguage()
end

function DailyLotteryView:OnCreate()
	self:InitContent()
	self:RefreshLotteryTime(self.lotteryTime)
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()

	self.lotteryConfig = CC.ConfigCenter.Inst():getConfigDataByKey("DailyLotteryConfig")
	self:InitShowList()
	self:InitLotteryInfo(1)
end

function DailyLotteryView:InitShowList()
	local vip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	for _,v in ipairs(self.lotteryConfig.showCfg) do
		if vip <= v.vipMax then
			table.insert(self.showCfg,v)
		end
	end
	self.maxPage = #self.showCfg
	if self.maxPage > 1 then
		self.backBtn:SetActive(true)
		self.nextBtn:SetActive(true)
	end
	local togglePre = self:FindChild("UILayout/Page/Toggle")
	local parent = self:FindChild("UILayout/Page/Group")
	for i=1,self.maxPage do
		local toggle = CC.uu.newObject(togglePre,parent)
		toggle:GetComponent("Toggle").isOn = false
		self.toggleList[i] = toggle
	end
end

function DailyLotteryView:InitContent()
	self.turntableItems = {}
	self.lampLights = {}		-- 追尾灯的颜色值
	for i = 1, 8 do
		self.turntableItems[i] = self:FindChild("UILayout/Turntable/Item"..i)
		self.lampLights[i] = self.turntableItems[i]:FindChild("Light"):GetComponent("Image")
		self.lampLights[i].color = Color(1, 1, 1, 0)
	end
	-- 摇奖剩余次数
	self.times = self:FindChild("UILayout/Topbar/Panel/LotteryTime")
	-- 文字报幕
	self.scroller = self:FindChild("UILayout/RollRecord/Scroller")
	self.scrollContent = self.scroller:FindChild("Content")
	-- 大奖排行榜
	self.bigAwardPanel = self:FindChild("BigAwardPanel")
	self.bigAwardContent = self.bigAwardPanel:FindChild("InfoView/Scroller/Viewport/Content")
	self.scrollItem = self.bigAwardPanel:FindChild("InfoView/Scroller/Viewport/Item")

	--抽奖按钮
	self.lotteryBtn = self:FindChild("UILayout/BtnObj")
	self.tipBtn = self:FindChild("UILayout/BtnTips")
	self.grayBtn = self:FindChild("UILayout/BtnObj/BtnLottery/Gray")
	self.backBtn = self:FindChild("UILayout/Page/BtnBack")
	self.nextBtn = self:FindChild("UILayout/Page/BtnNext")

	self:FindChild("UILayout/Label3/BtnShare/Text").text = self.language.share
	self:AddClick("UILayout/BtnObj/BtnLottery", "RequestLottery")
	self:AddClick("UILayout/BtnTips/BtnLottery",function () self.viewCtr:OnOpenStoreView()	end)
	self:AddClick("UILayout/Label3/BtnShare", "OnClickShare")
	self:AddClick("UILayout/Topbar/Panel/BtnHelp", "OnClickRule")
	self:AddClick("BigAwardPanel/BigAwardBtn","OnBigAwardClick")
	self:AddClick(self.backBtn,function ()
			self:OnChangePage(self.curPage-1)
	end)
	self:AddClick(self.nextBtn,function ()
			self:OnChangePage(self.curPage+1)
		end)

	self.noRankInfoTips = self.bigAwardPanel:FindChild("InfoView/Scroller/Viewport/NoRankInfoTips")
	self.noRankInfoTips:GetComponent("Text").text = self.language.noRankInfo
	self.bigAwardPanel:FindChild("InfoView/Image/Name"):GetComponent("Text").text = self.language.roleName
	self.bigAwardPanel:FindChild("InfoView/Image/Info"):GetComponent("Text").text = self.language.winInfo

	self:FindChild("UILayout/ShowBtn/Tips/Text").text = self.language.lookAt

	for i=1,3 do
		self:FindChild("UILayout/Label"..i).text = self.language.task..i..":"
		self:FindChild("UILayout/Label"..i.."/Text").text = self.language["task"..i]
	end
	--local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	--if vipLevel >= 20 then
		--self.base = 1008
		--self:FindChild("UILayout/ShowBtn"):SetActive(false)
	--end
end

-- 点击分享
function DailyLotteryView:OnClickShare()
	-- local data = {}
	-- data.imgName = "share_1_2_20201124"
	-- data.content = CC.LanguageManager.GetLanguage("L_CaptureScreenShareView").shareContent1
	-- data.shareCallBack = function()
	-- 	if not self.bShareFinish then
	-- 		self.viewCtr:OnReqAddLotteryTimes()
	-- 	end
	-- end
	-- CC.ViewManager.Open("ImageShareView",data)
	local param = {}
	param.isShowPlayerInfo = true
	param.shareCallBack = function()
		if not self.bShareFinish then
			self.viewCtr:OnReqAddLotteryTimes()
		end
	end
	param.webText = ""--CC.LanguageManager.GetLanguage("L_CaptureScreenShareView").shareContent1
	CC.ViewManager.Open("CaptureScreenShareView", param)
	--方便测试分享
	-- CC.Request("ReqOnClientShare", {ShareType = CC.shared_enums_pb.ClientShareCommon})
end

-- 点击规则界面
function DailyLotteryView:OnClickRule()
	self.viewCtr:OnOpenRuleView()
end

function DailyLotteryView:OnBigAwardClick()
	if self.bigAwardPanel:FindChild("BigAwardBtn/Dir").localScale.x >= 1 then
		self.bigAwardPanel:FindChild("bg"):SetActive(true)
		self.bigAwardPanel:FindChild("BigAwardBtn").localPosition = Vector3(234,10,0)
		self.bigAwardPanel:FindChild("BigAwardBtn/Dir").localScale = Vector3(-1,1,1)
		self.bigAwardPanel:FindChild("InfoView").localPosition = Vector3(452,0,0)
	else
		self.bigAwardPanel:FindChild("bg"):SetActive(false)
		self.bigAwardPanel:FindChild("BigAwardBtn").localPosition = Vector3(608,10,0)
		self.bigAwardPanel:FindChild("BigAwardBtn/Dir").localScale = Vector3(1,1,1)
		self.bigAwardPanel:FindChild("InfoView").localPosition = Vector3(826,0,0)
	end
end

function DailyLotteryView:OnChangePage(page)
	if page > self.maxPage then
		self.curPage = 1
	elseif page < 1 then
		self.curPage = self.maxPage
	else
		self.curPage = page
	end
	self:InitLotteryInfo(self.curPage)
end

-- 初始化奖品图片
function DailyLotteryView:InitLotteryInfo(page)
	local data = self.showCfg[page] or {}
	self.awardsIndex = {}
	self.toggleList[page]:GetComponent("Toggle").isOn = true
	if data.vipMax ~= 0 then
		if data.vipMax >= 30 then
			self:FindChild("UILayout/Page/Vip").text = string.format("VIP %d+", data.vipMin)
		else
			self:FindChild("UILayout/Page/Vip").text = string.format("VIP %d-%d", data.vipMin, data.vipMax)
		end
	else
		self:FindChild("UILayout/Page/Vip").text = ""
	end
	
	local vip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	self.grayBtn:SetActive(vip < data.vipMin)
	
	for index, item in ipairs(self.turntableItems) do
		item:FindChild("EffectChange"):SetActive(false)
		local awardId = data.showList[index]
		self.awardsIndex[awardId] = index

		item:FindChild("Amount"):GetComponent("RichText").text = "x"..self.lotteryConfig.award[awardId].PropNum
		self:SetImage(item:FindChild("Award"),self.lotteryConfig.award[awardId].PropIcon,true)
		item:FindChild("Award").y = 5
		if not self.isInitReward and self.base == 1008 then
			item:FindChild("EffectChange"):SetActive(true)
		end
		item:FindChild("EffectAward"):SetActive(self.lotteryConfig.award[awardId].Entity)
	end
	if not self.isInitReward and self.base == 1008 then
		CC.Sound.StopEffect()
		CC.Sound.PlayHallEffect("qhjl.ogg")
	end
	self.isInitReward = false
	local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	if self.base == 1008 and vipLevel < 20 then
		self.lotteryBtn:SetActive(false)
		self.tipBtn:SetActive(true)
	else
		self.lotteryBtn:SetActive(true)
		self.tipBtn:SetActive(false)
	end
end

-- 刷新奖励配置
function DailyLotteryView:RefreshLotteryInfo(data)
	if data.Times then
		self:RefreshLotteryTime(data.Times)
	else
		self:RefreshLotteryTime(0)
	end

	if data and table.length(data) > 1 then
		self:RefreshTaskStatus(data)
	end

	--local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	--if vipLevel >= 20 then
		--self.base = 1008
		--self:FindChild("UILayout/ShowBtn"):SetActive(false)
		--self:InitLotteryInfo()
	--end
end

-- 刷新摇奖次数
function DailyLotteryView:RefreshLotteryTime(times)
	self.lotteryTime = tonumber(times)
	local str = self.language.lotteryTime.."："..self.lotteryTime.." "
	self.times:GetComponent("Text").text = str
end

-- 刷新任务状态
function DailyLotteryView:RefreshTaskStatus(data)
	self.bOnlineFinish = data.OnlineTask or false
	self.bNextFinish = data.NextDayLoginTask or false
	self.bShareFinish = data.ShareTask or false

	if data.RemainTime <= 0 then
		self:FindChild("UILayout/Label1/Time"):SetActive(false)
		self:FindChild("UILayout/Label1/Complete"):SetActive(true)
	else
		self:FindChild("UILayout/Label1/Time"):SetActive(not data.bOnlineFinish)
		self:FindChild("UILayout/Label1/Complete"):SetActive(data.bOnlineFinish)
		self:StartOnlineTimer(data.RemainTime)
	end

	self:FindChild("UILayout/Label2/Next"):SetActive(not data.NextDayLoginTask)
	self:FindChild("UILayout/Label2/Complete"):SetActive(data.NextDayLoginTask)

	self:FindChild("UILayout/Label3/BtnShare"):SetActive(not data.ShareTask)
	self:FindChild("UILayout/Label3/Complete"):SetActive(data.ShareTask)
end

function DailyLotteryView:StartOnlineTimer(cd)
	local deltaTime = cd
	self:FindChild("UILayout/Label1/Time/Text").text = string.format(CC.uu.TicketFormat(deltaTime),"00:00:00")
	self:StartTimer("OnlineCountDown", 1, function()
		deltaTime = deltaTime - 1
        local timeStr = CC.uu.TicketFormat(deltaTime)
        if deltaTime <= 0 then
			self:FindChild("UILayout/Label1/Time/Text").text = "00:00:00"
			self.viewCtr:OnRefreshOnlineTime()
			self.viewCtr:OnReqGetDailyLotteryInfo()
			self:StopTimer("OnlineCountDown")
		else
			self:FindChild("UILayout/Label1/Time/Text").text = string.format(timeStr,"00:00:00")
		end
    end, -1)
end

-- 请求抽奖
function DailyLotteryView:RequestLottery()
	if self.lotteryTime > 0  then
		if self.bCanLottery then
			self.viewCtr:OnReqLottery()
		end
	else
		if self.bShareFinish and self.bOnlineFinish then
			local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
			-- 如果是vivo或者oppo渠道则，vip3以下跳vip3直升卡
			local bLimit = CC.ChannelMgr.CheckOppoChannel() or CC.ChannelMgr.CheckVivoChannel() or CC.ChannelMgr.CheckOfficialWebChannel()
			if bLimit then
				if vipLevel < 3 then
					CC.ViewManager.Open("VipThreeCardView")
				else
					CC.ViewManager.ShowTip(self.language.noTimeTips)
				end
			else
				if vipLevel == 0 then
					self.viewCtr:OnOpenStoreView()
				elseif vipLevel < 3 then
					CC.ViewManager.Open("VipThreeCardView")
				else
					CC.ViewManager.ShowTip(self.language.noTimeTips)
				end
			end
		else
			self.viewCtr:OnOpenTaskGuideView(self.bOnlineFinish,self.bShareFinish)
		end
	end
	-- -- 测试代码
	-- local award = self.nCurLightIndex + 2 > 8 and 2 or self.nCurLightIndex + 2
	-- self:ReadyLottery({AwardID=1008})
	-- local data = {}
	-- data.Items = {{ConfigId = 2004, Count = 1}}
	-- self:SetRewardData(data)
end

-- 准备播奖
function DailyLotteryView:ReadyLottery(data)
	if self.bCanLottery then
		self.lotteryTime = self.lotteryTime - 1
		if self.lotteryTime < 0 then
			self.lotteryTime = 0
		end
		self.nAwardId = data.AwardID
		local index = self.awardsIndex[self.nAwardId]
		if not index then
			logError("客户端展示配置与服务器不一致，跳过动画")
			self:ShowRewardsView()
			return 
		end
		self:RefreshLotteryTime(self.lotteryTime)
		self:PlayLotteryAnim(index)
		self.bCanLottery = false
	end
end

-- 设置奖励配置
function DailyLotteryView:SetRewardData(data)
	-- self.rewardData = data
end

-- 关灯
function DailyLotteryView:CloseAllLight()
	for _, item in pairs(self.lampLights) do
		item.color = Color(1, 1, 1, 0)
	end
end

-- 播放抽奖动画
function DailyLotteryView:PlayLotteryAnim(index)
	-- 动画播放过程中，禁止点击
	self.viewCtr:SetCanClick(false)
	local diff = index >= self.nCurLightIndex and index - self.nCurLightIndex or 8 + index - self.nCurLightIndex
	local total = self.nPlayRound * self.nTotalRoundAmount + diff + 3
	self:RunLightUpdate(1,total,self.nCurLightIndex)
end

-- 跑马灯透明度设置
local Color1 = Color(1, 1, 1, 1)
local Color2 = Color(1, 1, 1, 0.8)
local Color3 = Color(1, 1, 1, 0.6)

--[[
	Desc: 			跑马灯定时器
	param:
	@playIndex		已经运行的次数
	@total			需要运行总次数
	@index			第一个灯停靠的下标
]]
function DailyLotteryView:RunLightUpdate(playIndex,total,index)
	self:StartTimer("RunLightUpdate", self.runIntervalTime, function()
		self:CloseAllLight()
		if playIndex == total then
			self:StopTimer("RunLightUpdate")
			self.lampLights[index].color = Color1
			playIndex = 1
			self.nCurLightIndex = index
			CC.Sound.StopEffect()
			CC.Sound.PlayHallEffect("lotteryAward.ogg")
			if tonumber(self.nAwardId) > 0 then
				local awardIndex = self.awardsIndex[self.nAwardId]
				self:ShowAwardView(self.lampLights[awardIndex])
			end
		else
			CC.Sound.StopEffect()
			CC.Sound.PlayHallEffect("lotteryDaily.ogg")
			local firstIndex = index
			local secondIndex = index-1 < 1 and self.nTotalRoundAmount or index-1
			local thirdIndex = index-2 < 1 and self.nTotalRoundAmount-2+index or index-2
			if playIndex == 1 then
				self.lampLights[firstIndex].color = Color1
			elseif playIndex == 2 then
				self.lampLights[firstIndex].color = Color1
				self.lampLights[secondIndex].color = Color2
			elseif playIndex > total - 1 then
				self.lampLights[firstIndex].color = Color1
				self.lampLights[secondIndex].color = Color3
			else
				self.lampLights[firstIndex].color = Color1
				self.lampLights[secondIndex].color = Color2
				self.lampLights[thirdIndex].color = Color3
			end
			playIndex = playIndex + 1
			if playIndex < total-1 then
				index = index + 1 > self.nTotalRoundAmount and 1 or index+1
			end
			-- 变速设置
			if playIndex > self.nTotalRoundAmount - 2  and playIndex <= self.nTotalRoundAmount then
				self.runIntervalTime = 0.15
			elseif playIndex > self.nTotalRoundAmount  and playIndex <= total-self.nTotalRoundAmount then
				self.runIntervalTime = 0.1
			elseif playIndex >= total - self.nTotalRoundAmount+3 then
				self.runIntervalTime = 0.25
			elseif playIndex > total-self.nTotalRoundAmount then
				self.runIntervalTime = 0.15
			end
			self:RunLightUpdate(playIndex,total,index)
		end
	end)
end

-- 播放奖励动画
function DailyLotteryView:ShowAwardView(obj)
	local act1 = {"fadeToAll", 0, 0}
	local act2 = {"fadeToAll", 255, 0.3}
	local act3 = {"fadeToAll",255,0.3,function()
			self:ShowRewardsView()
	end}
	self:RunAction(obj.transform, {act1,act2,act1,act2,act1,act3})
end

function DailyLotteryView:ShowRewardsView()
	if self.nAwardId > 0 then
		local propId = self.lotteryConfig.award[self.nAwardId].PropId
		local count =self.lotteryConfig.award[self.nAwardId].PropNum
		if self.lotteryConfig.award[self.nAwardId].Entity then
			CC.ViewManager.OpenRewardsView({items = {{ConfigId = propId, Count = count}},source = CC.shared_transfer_source_pb.TS_Daily_Lottery})
		else
			if propId == 18 then
				self.viewCtr:OnBlessSearchView()
			else
				CC.ViewManager.OpenRewardsView({items = {{ConfigId = propId, Count = count}}})
			end
		end
	end
	self.viewCtr:SetCanClick(true)
	self.bCanLottery = true
end

-- 刷新大奖排行榜
function DailyLotteryView:RefreshLotteryRankInfo(data)
	local list = data
	self.noRankInfoTips:SetActive(#list==0)
	for _,v in pairs(self.RewardInfo) do
		v.transform:SetActive(false)
	end
	local isShow = true
	-- 避免一次性添加太多，分帧去创建
	self.coroutine = coroutine.start(function()
		for i = 1,#list do
			isShow = not isShow
			self:SetRewardItemData(i,list[i], isShow)
			coroutine.step(1)
		end
	end)

	for i = 1, #list do
		table.insert(self.rollInfoData,list[i])
		if #self.rollInfoData == 20 then
			-- 最多播最新20条
			break
		end
	end
	self:InitRollInfo(0)
end

--[[
	Desc: 		初始化滚动列表
	param:
	@index		下标
	@InfoData	数据信息
		PlayerID
		Portrait
		VipLevel
		AwardID
	@bgShow		是否显示背景
]]
function DailyLotteryView:SetRewardItemData(index,InfoData,bgShow)
	local tran = nil
	local item = nil
	if self.RewardInfo[index] == nil then
        tran = self.scrollItem
        item = CC.uu.newObject(tran)
        item.transform.name = tostring(index)
        self.RewardInfo[index] = item.transform
    else
        item = self.RewardInfo[index]
    end
	item:SetActive(true)
	local headNode = item.transform:FindChild("ItemHead")
	self:DeleteHeadIconByKey(headNode)
	Util.ClearChild(headNode,false)
	self.rankNum = self.rankNum + 1
	local param = {}
	param.parent = headNode
	param.portrait = InfoData.Portrait
	param.playerId = InfoData.PlayerID
	param.vipLevel = InfoData.VipLevel
	param.clickFunc = "unClick"
	self:SetHeadIcon(param,self.rankNum)

	if item then
		item.transform:SetParent(self.bigAwardContent, false)
		item.transform:FindChild("Nick"):GetComponent("Text").text = InfoData.Nick
        item.transform:FindChild("Num"):GetComponent("Text").text = self.lotteryConfig.award[InfoData.AwardID].Message
        item.transform:FindChild("Time"):GetComponent("Text").text = InfoData.Date
        item.transform:FindChild("bg"):SetActive(bgShow)
	end
end

--删除头像对象
function DailyLotteryView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.iconTab[tonumber(headtran.transform.name)] ~= nil then
			self.iconTab[tonumber(headtran.transform.name)]:Destroy()
			self.iconTab[tonumber(headtran.transform.name)] = nil
		end
	end
end

--设置头像
function DailyLotteryView:SetHeadIcon(param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.iconTab[i] = self.HeadIcon
end

-- 初始化滚动列表
function DailyLotteryView:InitRollInfo(time)
	-- local list = self.DailyLotteryDataMgr.GetScrollData()
	-- 需求改动：读取来源改成排行榜内容
	local list = self.rollInfoData
	if #list == 0 then
		return
	end

	for _,v in pairs(self.scrollItems) do
		v.transform:SetActive(false)
	end

	for i = 1,#list do
		self:AddItemData(i,list[i])
	end
	self.curMoveIndex = 0
	self:TextScrollUpdate(time or 6)
end

-- 添加文字滚动内容
function DailyLotteryView:AddItemData(index, data)
	local tran = nil
	local item = nil
	if self.scrollItems[index] == nil then
		tran = self.scroller:FindChild("Item")
		item = CC.uu.newObject(tran)
		item.transform.name = tostring(index)
		self.scrollItems[index] = item.transform
	else
		item = self.scrollItems[index]
	end
	item.localPosition = Vector3(700, -4, 0)
	item:SetActive(true)

	if item then
		item.transform:SetParent(self.scrollContent, false)
		local award = self.lotteryConfig.award[data.AwardID].Message
		item:GetComponent("Text").text = string.format(self.language.awardInfo,data.Nick,award)
	end
end

-- 文字滚动定时器
function DailyLotteryView:TextScrollUpdate(time)
	--每隔6秒移动下一个
	self:StartTimer("TextScrollUpdate", time, function()
		self.curMoveIndex = self.curMoveIndex + 1
		self:MoveRoll(self.curMoveIndex)
		local list = self.rollInfoData
		if self.curMoveIndex >= #list then
			self:InitRollInfo()
		else
			self:TextScrollUpdate(6)
		end
	end)
end

-- 文字滚动
function DailyLotteryView:MoveRoll(index)
	if self.scrollContent.childCount <= 0 or index > self.scrollContent.childCount then return end

	if index == self.scrollContent.childCount then
		self.viewCtr.curMoveIndex = 0
	end

	if self.contentMoveStatus[index] then
		return
	else
		self.contentMoveStatus[index] = true
	end

	local obj = self.scrollContent:GetChild(index - 1)
	if obj then
		self:RunAction(obj,  {"localMoveTo", -1000, -4, 12, function ()
			if obj.localPosition.x <= -1000 then
				obj.localPosition = Vector3(700, -4, 0)
				if self.contentMoveStatus[tonumber(obj.name)] then
					self.contentMoveStatus[tonumber(obj.name)] = nil
				end
			end
		end})
	end
end

function DailyLotteryView:ActionIn()
	self:SetCanClick(false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					CC.HallUtil.HideByTagName("Effect", true)
					self:SetCanClick(true)
				end}
		})
end

function DailyLotteryView:ActionOut()
	self:SetCanClick(false)
	CC.HallUtil.HideByTagName("Effect", false)
	self:OnDestroy()
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		})
end

function DailyLotteryView:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true) end)
	self.transform:SetActive(true)
end

function DailyLotteryView:ActionHide()
	self:SetCanClick(false)
	self.transform:SetActive(false)
end

function DailyLotteryView:OnDestroy()
	self:StopTimer("RunLightUpdate")
	self:StopTimer("TextScrollUpdate")
	self:StopTimer("OnlineCountDown")
	for i,v in pairs(self.iconTab) do
		if v then
			v:Destroy()
			v = nil
		end
	end

	if self.coroutine then
		coroutine.stop(self.coroutine)
		self.coroutine = nil
	end

	if self.viewCtr then
		self.viewCtr:OnDestroy()
		self.viewCtr = nil
	end
end

return DailyLotteryView