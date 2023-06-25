local CC = require("CC")
local DonateView = CC.uu.ClassView("DonateView")

function DonateView:ctor(param)
	self:InitVar(param)
end

function DonateView:InitVar(param)
	self.param = param
	self.language = self:GetLanguage()
	self.myHead = nil
	self.myRankHead = nil
	self.rankHeadList = {}
	self.viewJump = {
		{viewName = "AnniversaryTurntableView",param = nil},
		{viewName = "SelectGiftCollectionView",param = {currentView = "NewPayGiftView"}, switch = "NewPayGiftView"},
		{viewName = "DailyGiftCollectionView",param = {currentView="HolidayDiscountsView"}, switch = "HolidayDiscountsView"},
	}
end

function DonateView:OnCreate()
	self:InitNode()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
	self:InitContent()
	self:InitTextByLanguage()
	self:ShowDonateRed()
end

function DonateView:InitNode()
	self.donateBtn = self:FindChild("LeftPanel/SelfNode/DonateBtn")
	self.ActBubble = self:FindChild("LeftPanel/ActNode/ExplainBtn/Bubble")
	self.thanksText = self:FindChild("Bg/Thanks")
	self.serverDonate = self:FindChild("BottomPanel/ServerData"):GetComponent("NumberRoller")
	self.rankScrCtrl = self:FindChild("RightPanel/Rank/ScrollerController"):GetComponent("ScrollerController")
	self.donateAni = self:FindChild("DonateAni"):GetComponent("Animator")
end

function DonateView:InitContent()

	self:FindChild("RightPanel/SelfRank/Data/Name").text = CC.Player.Inst():GetSelfInfoByKey("Nick")
	self:FindChild("RightPanel/SelfRank/Data/Score").text = "0"
	self:FindChild("RightPanel/SelfRank/RankNum").text = "99+"
	
	self:AddClick("Bg/CloseBtn","ActionOut")
	self:AddClick("Bg/ExplainBtn","ShowDonateExplain")
	self:AddClick(self.donateBtn,"OnClickDonateBtn")
	self:AddClick("LeftPanel/ActNode/ExplainBtn",function ()
		self.ActBubble:SetActive(true)
		self:DelayRun(4,function ()
			self.ActBubble:SetActive(false)
		end)
	end)
	self:AddClick("LeftPanel/ActNode/ExplainBtn/Bubble/Close",function ()
		self.ActBubble:SetActive(false)
	end)
	for i=1,3 do
		local obj = self:FindChild("LeftPanel/ActNode/ActGroup/Act"..i.."/GoBtn")
		self:AddClick(obj,function ()
			self:OnClickGoToBtn(i)
		end)
		self:SetObjOnClickScale(obj)
	end
	self:SetObjOnClickScale(self.donateBtn)

	self.rankScrCtrl:AddChangeItemListener(function(tran,dataIndex,cellIndex)
			self:RefreshRankItem(tran,dataIndex)
		end)
	self.rankScrCtrl:AddRycycleAction(function (tran)
			self:RycycleRankItem(tran)
		end)
	self.rankScrCtrl:InitScroller(0)
	
	self.myHead = CC.HeadManager.CreateHeadIcon({parent = self:FindChild("LeftPanel/SelfNode/Head")})
	self.myRankHead = CC.HeadManager.CreateHeadIcon({parent = self:FindChild("RightPanel/SelfRank/Head")})
end

function DonateView:InitTextByLanguage()
	self:FindChild("ActTime").text = self.language.actTime
	self:FindChild("LeftPanel/Desc").text = self.language.leftDesc
	self:FindChild("LeftPanel/SelfNode/Now/Text").text = self.language.myScore
	self:FindChild("LeftPanel/SelfNode/Donated/Text").text = self.language.donatedScore
	self:FindChild("LeftPanel/ActNode/ExplainBtn/Bubble/Image/Text").text = self.language.ActExplain
	self:FindChild("BottomPanel/Desc/Text1").text = self.language.bottomDesc1
	self:FindChild("BottomPanel/Desc/Text2").text = self.language.bottomDesc2

	for i=1,3 do
		local item = self:FindChild("LeftPanel/ActNode/ActGroup/Act"..i)
		item:FindChild("Text").text = self.language["act"..i]
		item:FindChild("GoBtn/Text").text = self.language.btnGo
	end

end

function DonateView:RefreshSelfInfo(data)
	if not data then return end
	self:FindChild("LeftPanel/SelfNode/Now/Num").text = CC.uu.numberToStrWithComma(data.PlayerOwnNum)
	self:FindChild("LeftPanel/SelfNode/Donated/Num").text = CC.uu.numberToStrWithComma(data.PlayerDonateNum)
end

function DonateView:RefreshServerDonate(num,time)
	self.serverDonate:RollTo(num, time)
end

function DonateView:RefreshRankList(data)
	self:RefreshServerDonate(data.TotalDonateNum,2)
	self:RefreshSelfRank(data.playerRecord)
	if #data.RecordList > 0 then
		self:FindChild("RightPanel/Rank/Empty"):SetActive(false)
	end
	self.rankScrCtrl:InitScroller(#data.RecordList)
end

function DonateView:RefreshSelfRank(data)
	local rank = (data.RankIndex == 0 or data.RankIndex > 99) and "99+" or data.RankIndex
	self:FindChild("RightPanel/SelfRank/Data/Score").text = data.PropNum
	self:FindChild("RightPanel/SelfRank/RankNum").text = rank
end

function DonateView:RefreshRankItem(tran,index)
	if table.isEmpty(self.viewCtr.rankData) then return end
	local dataIndex = index + 1
	local rankData = self.viewCtr.rankData[dataIndex]
	if not rankData then return end

	tran.name = dataIndex
	local rankNum = tran:FindChild("RankNum")
	local rankNumSp = tran:FindChild("RankSp")
	if dataIndex <= 3 then
		rankNum:SetActive(false)
		rankNumSp:SetActive(true)
		self:SetImage(rankNumSp,"cp_phbicon_" .. dataIndex)
		rankNumSp:GetComponent("Image"):SetNativeSize()
	else
		rankNum:SetActive(true)
		rankNumSp:SetActive(false)
		rankNum:FindChild("Text").text = dataIndex
	end

	local IconData = {}
	IconData.parent = tran:FindChild("Head")
	IconData.playerId = rankData.PlayerID
	IconData.portrait = rankData.Portrait
	IconData.vipLevel = rankData.VipLevel
	local headIcon = CC.HeadManager.CreateHeadIcon(IconData)
	self.rankHeadList[dataIndex] = headIcon

	tran:FindChild("Data/Name").text = rankData.PlayerName
	tran:FindChild("Data/Score").text = rankData.PropNum
end

function DonateView:RycycleRankItem(tran)
	local index = tonumber(tran.transform.name)
	if self.rankHeadList[index] then
		self.rankHeadList[index]:Destroy(true)
	end
end

function DonateView:OnClickDonateBtn()
	self.viewCtr:ReqDonate()
end

function DonateView:OnClickGoToBtn(index)
	local data = self.viewJump[index]
	if data.switch then
		local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey(data.switch).switchOn
		if not switchOn then
			CC.ViewManager.ShowTip(self.language.actNotOpen)
			return
		end
	end
	CC.ViewManager.OpenAndReplace(data.viewName,data.param)
end

function DonateView:ShowDonateRed()
	local isShow = CC.Player.Inst():GetSelfInfoByKey("EPC_Merits") >= 10
	self.donateBtn:FindChild("Red"):SetActive(isShow)
end

function DonateView:ShowThanksText()
	self.thanksText:SetActive(true)
end

function DonateView:ShowMarquee(name,num)
	if not self.Marquee then
		self.Marquee = CC.uu.CreateHallView("Marquee",{parent = self:FindChild("MarqueeNode")})
	end
	local str = string.format(self.language.Marquee,name,num)
	--log("DonateView Marquee:\n"..str)
	self.Marquee:Report(str)
end

function DonateView:ShowDonateAnimation()
	local actionTable = {
		{"delay",0,function()
				self.donateAni.transform:SetActive(true)
				self.donateAni:Play("DonateAni",0,0)
			end},
		{"delay",2.5,function()
				self.viewCtr:ReqDonateNum()
				self.viewCtr:ReqDonateRank()
				self:ShowThanksText()
				self:SetCanClick(true)
			end},
	}
	if self.viewCtr.donateNum >= 100 then
		local extAction = {"delay",2.4,function() self.donateAni:Play("DonateAni",0,0) end}
		table.insert(actionTable,2,extAction)
		if self.viewCtr.donateNum >= 1000 then
			table.insert(actionTable,2,extAction)
		end
	end
	self:RunAction(self.transform,actionTable)
end

function DonateView:ShowDonateExplain()
	CC.ViewManager.Open("CommonExplainView",{title = self.language.title, content = self.language.DonateExplain})
end

function DonateView:SetObjOnClickScale(obj)
	obj.onDown = function ()
		self:RunAction(obj, { "scaleTo", 0.96, 0.96, 0.05, ease = CC.Action.EOutBack})
	end

	obj.onUp = function ()
		self:RunAction(obj, { "scaleTo", 1, 1, 0.05, ease = CC.Action.EOutBack})
	end
end

function DonateView:OnDestroy()

	--销毁自身头像
	if self.myHead then
		self.myHead:Destroy(true)
		self.myHead = nil
	end

	--销毁排行榜头像
	if self.myRankHead then
		self.myRankHead:Destroy(true)
		self.myRankHead = nil
	end
	for _,v in pairs(self.rankHeadList) do
		if v then
			v:Destroy(true)
			v = nil
		end
	end

	if self.Marquee then
		self.Marquee:Destroy()
		self.Marquee = nil
	end

	if self.viewCtr then
		self.viewCtr:OnDestroy()
		self.viewCtr = nil
	end
end

return DonateView