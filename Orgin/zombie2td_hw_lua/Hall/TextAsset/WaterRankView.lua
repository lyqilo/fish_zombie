local CC = require("CC")
local WaterRankView = CC.uu.ClassView("WaterRankView")

function WaterRankView:ctor(param)
	self:InitVar(param);
end

function WaterRankView:InitVar(param)
	self.param = param or {}
	self.language = self:GetLanguage()
	self.rewardBox = {}
	--个人排行头像
	self.myHeadIcon = nil
	--当前第一名头像
	self.firstHeadIcon = nil
	--钥匙宝箱目标
	self.boxTarget = {"15M", "40M", "150M", "300M", "900M", "2.5B", "9B", "20B", "50B", "90B"}
    self.gameType = 1
    if self.param.gameType then
        if self.param.gameType == "waterCaptureBtn" then
            self.gameType = 1
        elseif self.param.gameType == "waterOtherBtn" then
            self.gameType = 2
			self.boxTarget = {"3.5M", "9M", "30M", "100M", "200M", "1B", "2.5B", "6B", "15B", "27B"}
        end
    end
	--排行榜头像列表
	self.headIconList = {}
	--宝箱奖励
	self.boxRewards = {1, 2, 4, 10, 20, 50, 150, 400, 900, 1500}

end

function WaterRankView:OnCreate()

	self:InitNode()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
	self.viewName = self.param.viewName or "WaterRankView"

	self:InitContent()
	self:InitTextByLanguage()
    self:UpdataMarquee()
end

function WaterRankView:InitNode()
	self.bottomPanel = self:FindChild("BottomPanel")
	self.rightPanel = self:FindChild("RightPanel")
	self.rankNode = self.rightPanel:FindChild("RankNode")
	self.rankScrCtrl = self.rankNode:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.myHeadNode = self.rankNode:FindChild("MyRank/HeadIcon")
	self.firstRankHeadNode = self.rankNode:FindChild("FirstRank/Head")
	self.BoxSlider = self.bottomPanel:FindChild("Slider"):GetComponent("Slider")
	for i = 1, 10 do
		self.rewardBox[i] = self.bottomPanel:FindChild(string.format("Box/%s", i))
	end
end

function WaterRankView:InitContent()
	for i = 1, 10 do
		local boxItem = self.rewardBox[i]
		self:AddClick(boxItem,function ()
			self:OnClickBoxItem(i)
		end)
	end
    self:AddClick("BottomPanel/CloseBubble",function ()
        self:FindChild("BottomPanel/CloseBubble"):SetActive(false)
        self:ShowBoxBubble()
    end)
	self.rankScrCtrl:AddChangeItemListener(function(tran,dataIndex,cellIndex)
			self:RefreshRankItem(tran,dataIndex)
		end)
	self.rankScrCtrl:AddRycycleAction(function (tran)
			self:RycycleRankItem(tran)
		end)

	self:AddClick("RightPanel/RankNode/MyRank/Rule",function ()
		 CC.ViewManager.Open("WaterRankHelpView", {gameType = self.gameType})
	end)

	self:AddClick("BottomPanel/Tip", function ()
		self:FindChild("BottomPanel/Tip/Bubble"):SetActive(true)
	end)
	self:AddClick("BottomPanel/Tip/Bubble/Close",function ()
		self:FindChild("BottomPanel/Tip/Bubble"):SetActive(false)
	end)

	local data = {}
	data.parent = self.myHeadNode
	--data.clickFunc = "unClick";
	self.myHeadIcon = CC.HeadManager.CreateHeadIcon(data)

	self.rankScrCtrl:InitScroller(50)
end

function WaterRankView:InitTextByLanguage()
	self.rankNode:FindChild("MyRank/Rank").text = self.language.myRank
    self.rankNode:FindChild("FirstRank/Text").text = self.language.firstRank
	self.rankNode:FindChild("Bg/Text").text = self.language.Marquee0
	self.rankNode:FindChild("Bg/TimeText").text = self.language.activityTime
	for i = 1, 10 do
		self.rewardBox[i]:FindChild("Bubble/TipsGroup/Line1/Text").text = " x"..self.boxRewards[i]
        self.rewardBox[i]:FindChild("Bubble/TipsGroup/Line2/Text").text = self.language.dateWater
		self.rewardBox[i]:FindChild("Bubble/TipsGroup/Line2/Num").text = self.boxTarget[i]
	end
	self:FindChild("BottomPanel/Tip/Bubble/TipsGroup/Text").text = self.language.boxTip
end

function WaterRankView:RefreshRankList(data)
	local rankList = data.GameRank or {}
    self.rankNode:FindChild("MyRank/RankNum").text = data.PlayerRankID > 0 and data.PlayerRankID or "——"
    self.rankNode:FindChild("MyRank/ChipNum").text = CC.uu.ChipFormat(data.PlayerRankScore)
	--self:FindChild("Halloween/JP/Text").text = data.Jp
     self:FindChild("Jackpot/Text").text = CC.uu.ChipFormat(data.Jp,true)
	if #rankList < 1 then
		self.firstRankHeadNode:SetActive(false)
		return
	end

	local IconData = {}
	IconData.parent = self.firstRankHeadNode:FindChild("Node")
	--IconData.clickFunc = "unClick";
	IconData.playerId = rankList[1].PlayerId
	IconData.portrait = rankList[1].Portrait
	self.firstHeadIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.firstRankHeadNode:FindChild("Name/Text").text = rankList[1].Name
	self.firstRankHeadNode:SetActive(true)

	self.rankScrCtrl:InitScroller(50)
end

function WaterRankView:RefreshRankItem(trans,index)
	local hasData = false
    local rankList = self.viewCtr.rankData.GameRank or {}
	if rankList[index + 1] then
        hasData = true
    end

	local dataIndex = index + 1
	trans.name = dataIndex
	local rankImgSp = trans:FindChild("RankSp")
	local rankImg = trans:FindChild("Rank")
	if dataIndex < 4 then
		rankImgSp:SetActive(true)
		rankImg:SetActive(false)
		self:SetImage(rankImgSp,"cp_phbicon_" .. dataIndex);
	else
		rankImgSp:SetActive(false)
		rankImg:SetActive(true)
		rankImg:FindChild("Text").text = dataIndex
	end
    trans:FindChild("Reward/Num").text = hasData and rankList[dataIndex].propNum or ""

	local IconData = {}
	IconData.parent = trans:FindChild("HeadIcon");
	IconData.playerId = hasData and rankList[dataIndex].PlayerId or "";
	IconData.portrait = hasData and rankList[dataIndex].Portrait
    IconData.vipLevel = hasData and rankList[dataIndex].Vip
    if not hasData then
        IconData.clickFunc = "unClick"
    end
	local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.headIconList[dataIndex] = headIcon

	trans:FindChild("Desc/Name").text = hasData and rankList[dataIndex].Name or ""
	trans:FindChild("Desc/Num").text = hasData and CC.uu.ChipFormat(rankList[dataIndex].Score) or ""
end

function WaterRankView:RycycleRankItem(tran)
	local index = tonumber(tran.transform.name)
	if self.headIconList[index] then
		self.headIconList[index]:Destroy(true)
	end
end

function WaterRankView:RefreshKeyGiftProgress(data)
	local progress = 0
	for _,v in ipairs(data) do
		local boxItem = self.rewardBox[v.ID]
		boxItem:FindChild("Close"):SetActive(v.Status == 0 or v.Status == 2)
		boxItem:FindChild("Red"):SetActive(v.Status == 2)
		boxItem:FindChild("Open"):SetActive(v.Status == 1)
		progress = v.Status > 0 and v.ID or progress
	end
	self.BoxSlider.value = tonumber(progress) / 10
end

function WaterRankView:OnClickBoxItem(index)
	local boxData = nil
	for _,v in ipairs(self.viewCtr.boxData) do
		if v.ID == index then
			boxData = v
		end
	end
	if boxData and boxData.Status == 2 then
		self.viewCtr:ReqOpenPrize(index)
	else
		self:ShowBoxBubble(index)
	end
end

function WaterRankView:ShowBoxBubble(index)
	for i,v in ipairs(self.rewardBox) do
		local bubble = v:FindChild("Bubble")
		if i == index then
            self:FindChild("BottomPanel/CloseBubble"):SetActive(true)
			bubble:SetActive(true)
		else
			bubble:SetActive(false)
		end
	end
end

function WaterRankView:UpdataMarquee()
	if not self.Marquee then
		local ReportEnd = function()
			self:UpdataMarquee()
		end
		self.Marquee = CC.uu.CreateHallView("Marquee",{parent = self:FindChild("BroadCast"), ReportEnd = ReportEnd})
	end
    local str = self.language.Marquee0
    self.Marquee:Report(str)
    str = self.language.Marquee1
    self.Marquee:Report(str)
	str = self.language.Marquee2
    self.Marquee:Report(str)
end

function WaterRankView:ActionIn()
	self:SetCanClick(false);
	if self.param.isOffset then
		self.transform.size = Vector2(125, 0)
		self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	end
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end},
		});
end

function WaterRankView:ActionOut()
	self.viewCtr:UnRegisterEvent()
	self:SetCanClick(false)
	self:RunAction(self.transform, {"fadeToAll", 0, 0.5, function() self:Destroy() end});
end

function WaterRankView:OnDestroy()
    if self.Marquee then
        self.Marquee:Destroy()
        self.Marquee = nil
    end
	if self.viewCtr then
		self.viewCtr:OnDestroy();
		self.viewCtr = nil;
	end
	if self.myHeadIcon then
		--销毁个人排行头像
		self.myHeadIcon:Destroy(true)
		self.myHeadIcon = nil
	end
	if self.firstHeadIcon then
		self.firstHeadIcon:Destroy(true)
		self.firstHeadIcon = nil
	end
	for _,v in pairs(self.headIconList) do
		--销毁排行榜头像
		if v then
			v:Destroy(true)
			v = nil
		end
	end
end

return WaterRankView