local CC = require("CC")
local BatteryRankView = CC.uu.ClassView("BatteryRankView")

function BatteryRankView:ctor(param)
	self:InitVar(param);
end

function BatteryRankView:InitVar(param)
	self.param = param or {}
	self.language = self:GetLanguage()
	--个人排行头像
	self.myHeadIcon = nil
	--排行榜头像列表
	self.headIconList = {}
	self.RewardList = {
		-- [1] = {PropId = 3054 ,imgae ="prop_img_3054"},
		-- [2] = {PropId = 3055 ,imgae ="prop_img_3055"},
		-- [3] = {PropId = 3056 ,imgae ="prop_img_3056"},
		-- [1] = {PropId = 4020 ,imgae ="prop_img_4020"},
		-- [2] = {PropId = 4021 ,imgae ="prop_img_4021"},
		-- [3] = {PropId = 4022 ,imgae ="prop_img_4022"},
		[1] = {PropId = 3059 ,imgae ="prop_img_3059"},
		[2] = {PropId = 3060 ,imgae ="prop_img_3060"},
		[3] = {PropId = 3061 ,imgae ="prop_img_3061"},
	}
	self.entryEffectList = {}
	self.curEntryEffect = self.RewardList[1].PropId
end

function BatteryRankView:OnCreate()
	self:InitNode()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()

	self:InitContent()
	self:InitTextByLanguage()
end

function BatteryRankView:InitNode()
	self.bottomPanel = self:FindChild("BottomPanel")
	self.rightPanel = self:FindChild("RightPanel")
	self.rankScrCtrl = self.rightPanel:FindChild("ScrollerController"):GetComponent("ScrollerController")
	for i = 1, #self.RewardList do
		self.entryEffectList[i] = self:FindChild(string.format("LeftPanel/%s", self.RewardList[i].PropId))
	end
end

function BatteryRankView:InitContent()
    self:AddClick("BottomPanel/BtnBook",function ()
		CC.ViewManager.Open("BatteryBookView")
    end)
	self:AddClick("LeftPanel/Play",function ()
		CC.ViewManager.Open("BatteryEntryeffect", {propId = self.curEntryEffect})
    end)
	self:AddClick("Help",function ()
		local data = {
			title = self.language.title,
			content = self.language.explainContent,
		}
		CC.ViewManager.Open("CommonExplainView", data)
    end)
	self.rankScrCtrl:AddChangeItemListener(function(tran,dataIndex,cellIndex)
			self:RefreshRankItem(tran,dataIndex)
		end)
	self.rankScrCtrl:AddRycycleAction(function (tran)
			self:RycycleRankItem(tran)
		end)

	local data = {}
	data.parent = self.bottomPanel:FindChild("HeadNode")
	--data.clickFunc = "unClick";
	self.myHeadIcon = CC.HeadManager.CreateHeadIcon(data)

	self.rankScrCtrl:InitScroller(30)
end

function BatteryRankView:InitTextByLanguage()
	self.bottomPanel:FindChild("Ranking").text = self.language.myRank
    self:FindChild("LeftPanel/Text").text = self.language.effectTitle
	self:FindChild("Time").text = self.language.timeTitle
    self.rightPanel:FindChild("Bg/Title").text = self.language.title
end

function BatteryRankView:RefreshRankList(data)
    if data.MyRank <= 0 then
        self.bottomPanel:FindChild("Ranking/Text").text = self.language.noRank
    else
        self.bottomPanel:FindChild("Ranking/Text").text = data.MyRank
    end
    self.bottomPanel:FindChild("Score").text = CC.uu.ChipFormat(data.MyScore)

	self.rankScrCtrl:InitScroller(30)
end

function BatteryRankView:RefreshRankItem(trans,index)
	local hasData = false
    local rankList = self.viewCtr.rankData or {}
	local dataIndex = index + 1
	if rankList[dataIndex] then
        hasData = true
    end

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
	local rewaredInd = 1
	if dataIndex > 10 and dataIndex <= 20 then
		rewaredInd = 2
	elseif dataIndex > 20 then
		rewaredInd = 3
	end
	local reward = trans:FindChild("Reward")
	self:SetImage(reward, self.RewardList[rewaredInd].imgae)
	reward:GetComponent("Image"):SetNativeSize()
	reward:FindChild("Effect_3059"):SetActive(rewaredInd == 1)
	reward:FindChild("Effect_3060"):SetActive(rewaredInd == 2)
	reward:FindChild("Effect_3061"):SetActive(rewaredInd == 3)
	reward:SetActive(true)

	local IconData = {}
	IconData.parent = trans:FindChild("HeadIcon");
	IconData.playerId = hasData and rankList[dataIndex].Player.Id or "";
	IconData.portrait = hasData and rankList[dataIndex].Player.Portrait
    IconData.vipLevel = hasData and rankList[dataIndex].Level
	IconData.clickFunc = "unClick"
	local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.headIconList[dataIndex] = headIcon

	-- trans:FindChild("Name").text = hasData and rankList[dataIndex].Name or ""
	trans:FindChild("Btn/Num").text = hasData and CC.uu.ChipFormat(rankList[dataIndex].Score) or ""
	self:AddClick(trans:FindChild("Btn"),function ()
		if hasData then
			CC.ViewManager.Open("BatteryPossessView", {playerId = rankList[dataIndex].Player.Id})
		end
	end)
	self:AddClick(trans:FindChild("Reward"),function ()
		 self:UpdateEffectShow(rewaredInd)
		--CC.ViewManager.Open("BatteryEntryeffect", {propId = self.RewardList[rewaredInd].PropId})
	end)
end

function BatteryRankView:UpdateEffectShow(index)
	self.curEntryEffect =  self.RewardList[index].PropId
	for i = 1, #self.entryEffectList do
		self.entryEffectList[i]:SetActive(i == index)
	end
end

function BatteryRankView:RycycleRankItem(tran)
	local index = tonumber(tran.transform.name)
	if self.headIconList[index] then
		self.headIconList[index]:Destroy(true)
	end
end

function BatteryRankView:ActionIn()
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end},
		});
end

function BatteryRankView:ActionOut()
	self.viewCtr:UnRegisterEvent()
	self:SetCanClick(false)
	self:RunAction(self.transform, {"fadeToAll", 0, 0.5, function() self:Destroy() end});
end

function BatteryRankView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:OnDestroy();
		self.viewCtr = nil;
	end
	if self.myHeadIcon then
		--销毁个人排行头像
		self.myHeadIcon:Destroy(true)
		self.myHeadIcon = nil
	end
	for _,v in pairs(self.headIconList) do
		--销毁排行榜头像
		if v then
			v:Destroy(true)
			v = nil
		end
	end
end

return BatteryRankView