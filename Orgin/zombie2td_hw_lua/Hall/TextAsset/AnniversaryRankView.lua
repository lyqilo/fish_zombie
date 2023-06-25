local CC = require("CC")
local AnniversaryRankView = CC.uu.ClassView("AnniversaryRankView")

function AnniversaryRankView:ctor(param)
	self:InitVar(param);
end

function AnniversaryRankView:InitVar(param)
	self.param = param
	self.language = CC.LanguageManager.GetLanguage("L_AnniversaryTurntableView");
	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
	self.rewardBox = {}
	--个人排行头像
	self.myHeadIcon = nil
	--当前车主头像
	self.carOwnerHeadIcon = nil
	--排行榜头像列表
	self.headIconList = {}
	--宝箱目标
	self.keyBoxTarget = {3,10,50,100,500,1000}
	--宝箱金币奖励
	self.keyBoxRewards = {10000,20000,100000,200000,1000000,2000000}
	--排行榜奖励
	self.rewardConfig = {
		[1] = {prop = 20100, num = ""},
		[2] = {prop = 20101, num = ""},
		[3] = {prop = 20110, num = ""},
		[4] = {prop = 20055, num = ""},-- 4-10名
		[5] = {prop = 2, num = "10M"},-- 11-30名
		[6] = {prop = 2, num = "5M"},-- 31-50名
		}
	self.headFrame = {[1] = 3057,}
end

function AnniversaryRankView:OnCreate()
	self:InitNode()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()

	self:InitContent()
	self:InitTextByLanguage()

end

function AnniversaryRankView:InitNode()
	self.bottomPanel = self:FindChild("BottomPanel")
	self.rightPanel = self:FindChild("RightPanel")
	self.tipsPanel = self:FindChild("TipsPanel")
	self.rankNode = self.rightPanel:FindChild("RankNode")
	self.rankScrCtrl = self.rankNode:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.myHeadNode = self.rankNode:FindChild("MyRank/HeadIcon")
	self.carOwnerHeadNode = self.rankNode:FindChild("CarOwner/Head")
	self.keyBoxSlider = self.bottomPanel:FindChild("Slider"):GetComponent("Slider")
	self.noRecordText = self.rankNode:FindChild("NoRecord")
	self.scrollView = self.rankNode:FindChild("Scroll View")
	for i=1,6 do
		local boxItem = self.bottomPanel:FindChild("Box/"..i)
		self.rewardBox[i] = boxItem
	end

	self.closeBtn = self:FindChild("ClostBtn")
end

function AnniversaryRankView:InitContent()

	self:AddClick(self.closeBtn,"ActionOut")
	for i=1,6 do
		local boxItem = self.rewardBox[i]
		local bubble = boxItem:FindChild("Bubble")
		self:AddClick(boxItem,function ()
			self:OnClickBoxItem(i)
		end)
		self:AddClick(bubble:FindChild("Close"),function ()
			bubble:SetActive(false)
		end)
	end
	self.rankScrCtrl:AddChangeItemListener(function(tran,dataIndex,cellIndex)
			self:RefreshRankItem(tran,dataIndex)
		end)
	self.rankScrCtrl:AddRycycleAction(function (tran)
			self:RycycleRankItem(tran)
		end)

	self:AddClick("RightPanel/RankNode/MyRank/Key/Add",function ()
		CC.ViewManager.Open("CelebrationTipView")
	end)
	self:AddClick("BottomPanel/Tip","OnClickBoxTips")
	self:AddClick("BottomPanel/Tip/Bubble/Close",function ()
		self:FindChild("BottomPanel/Tip/Bubble"):SetActive(false)
	end)
	self:AddClick("RightPanel/RankNode/Bg/Tip",function ()
		self.tipsPanel:SetActive(true)
	end)
	self:AddClick("TipsPanel/Mask",function ()
		self.tipsPanel:SetActive(false)
	end)

	self.bottomPanel:FindChild("Key/Num").text = CC.Player.Inst():GetSelfInfoByKey("EPC_Props_80")
	self.rankNode:FindChild("MyRank/Key/Num").text = CC.Player.Inst():GetSelfInfoByKey("EPC_Props_80")

	local data = {}
	data.parent = self.myHeadNode
	--data.clickFunc = "unClick";
	self.myHeadIcon = CC.HeadManager.CreateHeadIcon(data);
	self.rankNode:FindChild("MyRank/CurRank/RankNum").text = 0
	-- CC.Sound.StopEffect()
	-- CC.Sound.PlayHallEffect("car_sound")

	self.rankScrCtrl:InitScroller(50)
end

function AnniversaryRankView:InitTextByLanguage()
	self:FindChild("Bg/Title/Time").text = self.language.timeTitle
	self.rankNode:FindChild("Bg/Tip/Text").text = self.language.endTip
	if not self:GetActStage() then
		--活动结束时间
		self.rankNode:FindChild("Bg/Time/Title").text = self.language.endTime
		self.rankNode:FindChild("Bg/Time/TimeText").text = "17-10-2022 00:00:00"
	else
		--当前活动已结束
		self.rankNode:FindChild("Bg/Time/Title").text = self.language.timeOut
	end

	self.rankNode:FindChild("MyRank/CurRank/Text").text = self.language.myRank
	self.noRecordText.text = self.language.noRankData
	for i=1,6 do
		self.rewardBox[i]:FindChild("Bubble/TipsGroup/Line1/Text1").text = self.language.boxBubbleText2
		self.rewardBox[i]:FindChild("Bubble/TipsGroup/Line1/Text2").text = string.format(self.language.boxBubbleText1,self.keyBoxTarget[i])
		self.rewardBox[i]:FindChild("Bubble/TipsGroup/Line2/Num").text = "จะได้รับฟรี x"..self.keyBoxRewards[i]
	end
	self:FindChild("BottomPanel/Tip/Bubble/TipsGroup/Text").text = self.language.keyBoxTip

	self.tipsPanel:FindChild("BG/Title/Text").text = self.language.rankTips1_Title
	local scrollContent = self.tipsPanel:FindChild("Content/Scroll View/Viewport/Content")
	scrollContent:FindChild("RankTips/Text").text = self.language.rankTips1_Title
	scrollContent:FindChild("Physical/Text").text = self.language.rankTips2_Title
	scrollContent:FindChild("Virtual/Text").text = self.language.rankTips3_Title
	scrollContent:FindChild("RankTipsList/ListDesc").text = self.language.rankTips1_Content
	scrollContent:FindChild("PhysicalList/ListDesc").text = self.language.rankTips2_Content
	scrollContent:FindChild("VirtualList/ListDesc").text = self.language.rankTips3_Content
end

function AnniversaryRankView:RefreshRankList(data)
	local myRankInfo = data.MyRank
	local rankList = data.RankList
	if myRankInfo and myRankInfo.PlayerId == CC.Player.Inst():GetSelfInfoByKey("Id") then
		self.rankNode:FindChild("MyRank/CurRank/RankNum").text = myRankInfo.Ranking
	end

	if rankList and #rankList < 1 then
		self.carOwnerHeadNode:SetActive(false)
		return
	end
	self.noRecordText:SetActive(false)

	local IconData = {}
	IconData.parent = self.carOwnerHeadNode:FindChild("Node")
	--IconData.clickFunc = "unClick";
	IconData.playerId = rankList[1].PlayerId
	IconData.portrait = rankList[1].Portrait
	IconData.headFrame = self.headFrame[1]
	IconData.vipLevel = rankList[1].Level
	IconData.showFrameEffect = true
	self.carOwnerHeadIcon = CC.HeadManager.CreateHeadIcon(IconData);

	self.carOwnerHeadNode:FindChild("Name/Text").text = rankList[1].Nickname
	self.carOwnerHeadNode:SetActive(true)

	self.rankScrCtrl:InitScroller(50)
end

function AnniversaryRankView:RefreshRankItem(trans,index)
	local hasData = false
	if table.isEmpty(self.viewCtr.rankData) then

	elseif not self.viewCtr.rankData.RankList or #self.viewCtr.rankData.RankList < 1 then

	else
		if self.viewCtr.rankData.RankList[index + 1] then
			hasData = true
		end
	end

	local rankList = self.viewCtr.rankData.RankList

	local dataIndex = index + 1
	trans.name = dataIndex
	local rankImgSp = trans:FindChild("RankSp")
	local rankImg = trans:FindChild("Rank")
	local reward = {}
	if dataIndex < 4 then
		reward = self.rewardConfig[dataIndex]
		rankImgSp:SetActive(true)
		rankImg:SetActive(false)
		self:SetImage(rankImgSp,"cp_phbicon_" .. dataIndex);
		trans:FindChild("Reward/Num").text = reward.num
	else
		if dataIndex < 11 then
			reward = self.rewardConfig[4]
			trans:FindChild("Reward/Num").text = reward.num
		elseif dataIndex < 31 then
			reward = self.rewardConfig[5]
			trans:FindChild("Reward/Num").text = reward.num
		else
			reward = self.rewardConfig[6]
			trans:FindChild("Reward/Num").text = reward.num
		end
		rankImgSp:SetActive(false)
		rankImg:SetActive(true)
		rankImg:FindChild("Text").text = dataIndex
	end

	--1-10 固定头像框
	local headFrame = nil
	if dataIndex == 1 then
		headFrame = self.headFrame[dataIndex]
	end

	local IconData = {}
	IconData.parent = trans:FindChild("HeadIcon");
	IconData.playerId = hasData and rankList[dataIndex].PlayerId or "创建默认头像";
	IconData.portrait = hasData and rankList[dataIndex].Portrait
	IconData.headFrame = headFrame
	IconData.vipLevel = hasData and rankList[dataIndex].Level
	IconData.showFrameEffect = true
	--IconData.clickFunc = "unClick";
	local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.headIconList[dataIndex] = headIcon

	local wordPos = self.scrollView:GetComponent("RectTransform"):GetWorldCorners()
	local minX = wordPos[0].x;
	local minY = wordPos[0].y;
	local maxX = wordPos[2].x;
	local maxY = wordPos[2].y;
	if headFrame then
		local testobj = headIcon.transform:FindChild("Frame")
		if headIcon.transform:FindChild("Frame/HeadFrame"..headFrame) then
			local trans = headIcon.transform:FindChild("Frame/HeadFrame"..headFrame)
			local particleComps = trans:GetComponentsInChildren(typeof(UnityEngine.Renderer));
			if particleComps then
				for _,v in ipairs(particleComps:ToTable()) do
					v.material:SetFloat("_MinX",minX);
					v.material:SetFloat("_MinY",minY);
					v.material:SetFloat("_MaxX",maxX);
					v.material:SetFloat("_MaxY",maxY);
				end
			end
		end
	end

	-- trans:FindChild("Desc/Name").text = hasData and rankList[dataIndex].Nickname or ""
	trans:FindChild("Desc/Key/Num").text = hasData and rankList[dataIndex].Score or "0"

	self:SetImage(trans:FindChild("Reward/Image"),"prop_img_"..reward.prop)
	trans:FindChild("Reward/Image"):GetComponent("Image"):SetNativeSize()
end

function AnniversaryRankView:RycycleRankItem(tran)
	local index = tonumber(tran.transform.name)
	if self.headIconList[index] then
		self.headIconList[index]:Destroy(true)
	end
end

function AnniversaryRankView:RefreshKeyGiftProgress(data)
	local keyNum = CC.Player.Inst():GetSelfInfoByKey("EPC_Props_80")
	local progress = 0
	for _,v in ipairs(data) do
		local boxItem = self.rewardBox[v.BoxId]
		local flag = v.Status
		boxItem:FindChild("Bubble/TipsGroup/Line1/Text1").text = self.language.boxBubbleText2
		boxItem:FindChild("Close"):SetActive(v.Status == 0)
		boxItem:FindChild("Red"):SetActive(v.Status == 0 and keyNum >= v.KeyAmount)
		boxItem:FindChild("Open"):SetActive(v.Status == 1)
		progress = (keyNum >= v.KeyAmount and v.BoxId > progress) and v.BoxId or progress
	end
	self.keyBoxSlider.value = tonumber(progress)/6
end

function AnniversaryRankView:OnClickBoxItem(index)
	local boxItem = self.rewardBox[index]
	local keyNum = CC.Player.Inst():GetSelfInfoByKey("EPC_Props_80")
	local boxData
	for _,v in ipairs(self.viewCtr.boxData) do
		if v.BoxId == index then
			boxData = v
		end
	end
	if not boxData then return end
	if boxData.Status == 0 and keyNum >= boxData.KeyAmount then
		self.viewCtr:OnReqGetGiftReward(index)
	else
		self:ShowBoxBubble(index)
	end
end

function AnniversaryRankView:ShowBoxBubble(index)
	for i,v in ipairs(self.rewardBox) do
		local bubble = v:FindChild("Bubble")
		if i == index then
			bubble:SetActive(true)
			self:DelayRun(4,function ()
				bubble:SetActive(false)
			end)
		else
			bubble:SetActive(false)
		end
	end

end

function AnniversaryRankView:OnClickBoxTips()
	local bubble = self:FindChild("BottomPanel/Tip/Bubble")
	bubble:SetActive(true)
	self:DelayRun(3,function ()
		bubble:SetActive(false)
	end)
end

function AnniversaryRankView:GetActStage()
	if self:CheckIsOver() then
		self.bottomPanel:SetActive(false)
		return true
	else
		self:StartTimer("stageTimer",1,function ()
			if self:CheckIsOver() then
				self:StopTimer("stageTimer")
				self.rankNode:FindChild("Bg/Time/Title").text = self.language.timeOut
				self.rankNode:FindChild("Bg/Time/TimeText").text = ""
				self.bottomPanel:SetActive(false)
			end
		end,-1)
	end
	return false
end

function AnniversaryRankView:CheckIsOver()
	local date = CC.TimeMgr.GetTimeInfo()
	if date then
		if (date.month >= 10 and date.day >= 17) or date.month >= 11 then
			return true
		end
	end
	return false
end

function AnniversaryRankView:ActionIn()
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.3, function() self:SetCanClick(true); end},
		});
end

function AnniversaryRankView:ActionOut()
	self:SetCanClick(false)
	self:RunAction(self.transform, {"fadeToAll", 0, 0.3, function() self:Destroy() end});
end

function AnniversaryRankView:OnDestroy()
	self:StopTimer("stageTimer")
	if self.viewCtr then
		self.viewCtr:OnDestroy();
		self.viewCtr = nil;
	end
	if self.myHeadIcon then
		--销毁个人排行头像
		self.myHeadIcon:Destroy(true)
		self.myHeadIcon = nil
	end
	if self.carOwnerHeadIcon then
		--销毁车主头像
		self.carOwnerHeadIcon:Destroy(true)
		self.carOwnerHeadIcon = nil
	end
	for _,v in pairs(self.headIconList) do
		--销毁排行榜头像
		if v then
			v:Destroy(true)
			v = nil
		end
	end
end

return AnniversaryRankView