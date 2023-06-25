local CC = require("CC")

local WorldCupView = CC.uu.ClassView("WorldCupView")
local M = WorldCupView

function M:ctor(param)
	self.param = param or {};
	self.language = self:GetLanguage();
	self.currentView = nil;
	self.showViewList = {};
end

function M:OnCreate()

	self:InitUI()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
	self:InitTextByLanguage()
	self:AddClickEvent()
end

function M:InitUI()

	self.topPanel = self:FindChild("TopPanel")
	self.rightPanel = self:FindChild("RightPanel")

	local headNode = self:FindChild("TopPanel/HeadNode")
	self.headIcon = CC.HeadManager.CreateHeadIcon({parent = headNode, showFrameEffect = true})

	self:RefreshInfo();

	self:InitJackpotRoller();
end

function M:InitTextByLanguage()
	
	self.topPanel:FindChild("NodeMgr/ScoreNode/Frame/BtnTip/Frame/Tip").text = self.language.scoreTip;
	self.topPanel:FindChild("NodeMgr/CardNode/Frame/BtnTip/Frame/Tip").text = self.language.cardTip;
end

function M:AddClickEvent()

	local rNode = self.rightPanel:FindChild("RBtnNodeMgr");
	local btnBack = rNode:FindChild("BtnBack");
	self:AddClick(btnBack, function()
		self:BackSubView();
	end, nil, true)

	local btnRule = rNode:FindChild("BtnRule");
	self:AddClick(btnRule, function()
		CC.ViewManager.Open("CommonExplainView", {title = self.language.ruleTittle, content = self.language.ruleContent, prefab = "WorldCupRuleView"})
	end, nil, true)

	local btnSchedule = rNode:FindChild("BtnSchedule");
	self:AddClick(btnSchedule, function()
		self:ShowSubView("WorldCupMatchView");
	end, nil, true)

	local btnRecord = rNode:FindChild("BtnRecord");
	self:AddClick(btnRecord, function()
		btnRecord:FindChild("Red"):SetActive(false)
		self:ShowSubView("WorldCupRecordView");
	end, nil, true)

	self.btnGift = rNode:FindChild("BtnGift");

	self:DelayRun(0.3,function()
		local btnGiftPos = UnityEngine.RectTransformUtility.WorldToScreenPoint(self:GlobalCamera(),self.btnGift.transform.position)
		CC.DataMgrCenter.Inst():GetDataByKey("WorldCupData").SetGiftBtnV2(btnGiftPos)
	end)
	self:AddClick(self.btnGift, function()
		CC.ViewManager.Open("WorldCupGiftView");
	end, nil, true)

	local taskState = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("FlowWaterTaskView").switchOn
	rNode:FindChild("BtnTask"):SetActive(taskState)
	self:AddClick(rNode:FindChild("BtnTask"), function()
		CC.ViewManager.Open("FlowWaterTaskView")
	end, nil, true)

	for _,v in ipairs({"ScoreNode", "CardNode"}) do
		local btnTip = self.topPanel:FindChild("NodeMgr/"..v.."/Frame/BtnTip");
		local tip = btnTip:FindChild("Frame");
		self:AddClick(btnTip, function()
			if tip.activeSelf then return end
			tip:SetActive(true);
			self:RunAction(tip, {
				{"fadeToAll", 0, 0},
				{"fadeToAll", 255, 0.2},
				{"delay", 2},
				{"fadeToAll", 0, 0.2, function()
					tip:SetActive(false) 
				end}
			})
		end);
	end
end

function M:RefreshUI(param)

	if param.nick then
		self:RefreshNick(param.nick);
	end

	if param.chip then
		self:RefreshChip(param.chip);
	end

	if param.diamond then
		self:RefreshDiamond(param.diamond);
	end

	if param.card then
		self:RefreshCard(param.card);
	end

	if param.score then
		self:RefreshScore(param.score);
	end
end

function M:RefreshNick(value)
	local node = self.topPanel:FindChild("Nick");
	node.text = value;
end

function M:RefreshChip(value)
	local node = self.topPanel:FindChild("NodeMgr/ChipNode/Frame/Text");
	node.text = CC.uu.ChipFormat(value);
end

function M:RefreshDiamond(value)
	local node = self.topPanel:FindChild("NodeMgr/DiamondNode/Frame/Text");
	node.text = CC.uu.DiamondFortmat(value);
end

function M:RefreshCard(value)
	local node = self.topPanel:FindChild("NodeMgr/CardNode/Frame/Text");
	node.text = CC.uu.DiamondFortmat(value);
end

function M:RefreshScore(value)
	local node = self.topPanel:FindChild("NodeMgr/ScoreNode/Frame/Text");
	node.text = CC.uu.ChipFormat(value);
end

function M:ShowTopPanel(viewName, flag)
	local y = 361;
	if flag then
		if viewName == "WorldCupMatchView" or viewName == "WorldCupRecordView" then return end
		if self.isShowTopPanel then return end;
		self.isShowTopPanel = true;
		self:RunAction(self.topPanel,{"localMoveTo", self.topPanel.x, y, 0.3, ease = CC.Action.EOutSine});
	else
		if (viewName ~= "WorldCupMatchView" and viewName ~= "WorldCupRecordView") then return end
		if not self.isShowTopPanel then return end;
		self.isShowTopPanel = false;
		self:RunAction(self.topPanel,{"localMoveTo", self.topPanel.x, y + 200, 0.3, ease = CC.Action.EOutSine});
	end
end

function M:SetRecordRed()
	self.rightPanel:FindChild("RBtnNodeMgr/BtnRecord/Red"):SetActive(true)
end

function M:SetTaskBtn(switchOn)
	self.rightPanel:FindChild("RBtnNodeMgr/BtnTask"):SetActive(switchOn)
end

function M:SetTaskEffect(value)
	self.rightPanel:FindChild("RBtnNodeMgr/BtnTask/effect"):SetActive(value)
end

function M:RefreshInfo()
	self:RefreshUI({
		nick = CC.Player.Inst():GetSelfInfoByKey("Nick"),
		chip = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa"),
		diamond = CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi"),
		card = CC.Player.Inst():GetSelfInfoByKey("EPC_WorldCup_QuizCard"),
		score = CC.DataMgrCenter.Inst():GetDataByKey("WorldCupData").GetScore();
	});
end

function M:InitJackpotRoller()
	self.championJPRoller = CC.ViewCenter.JackpotRoller.new()
	self.championJPRoller:Create({state = false})

	self.rankJPRoller = CC.ViewCenter.JackpotRoller.new()
	self.rankJPRoller:Create({state = false})
end

function M:RefreshJackpotRoller(data)
	self.championJPRoller:UpdateGoldPool(data.JackPotChampion)
	self.rankJPRoller:UpdateGoldPool(data.JackpotRank)
end

function M:ShowSubView(viewName)
	local showView = function ()
		local viewParam = {};
		self.currentView = CC.uu.CreateHallView(viewName, viewParam,self.language);
		self.currentView.transform:SetParent(self:FindChild("SubView"), false);
		self.currentView:ActionIn();
		self:SetCanClick(true);
		self:ShowTopPanel(viewName, true);
		self:SwitchBackBtn(viewName);
		for i = #self.showViewList, 1, -1 do
			if self.showViewList[i] == viewName then
				table.remove(self.showViewList, i);
				break;
			end
		end
		table.insert(self.showViewList, viewName);
	end
	
	if self.currentView then
		if self.currentView.viewName == viewName then return end;
		self:SetCanClick(false);
		self.currentView:SetCanClick(false);
		self.currentView:ActionOut(showView);
		self:ShowTopPanel(viewName, false);
		self.currentView = nil;
		return;
	end
	showView();
end

function M:BackSubView()
	if self.currentView and self.currentView.viewName ~= "WorldCupMainView" then
		table.remove(self.showViewList, #self.showViewList);
		local viewName = self.showViewList[#self.showViewList];
		if not viewName then
			self.viewCtr:ReqHomePageInfo();
		else
			self:ShowSubView(viewName);
		end
		return;
	end
	self:ActionOut();
end

function M:SwitchBackBtn(viewName)
	local main = self.rightPanel:FindChild("RBtnNodeMgr/BtnBack/Main");
	local sub = self.rightPanel:FindChild("RBtnNodeMgr/BtnBack/Sub");
	local showMain = viewName == "WorldCupMainView";
	main:SetActive(showMain);
	sub:SetActive(not showMain);
end

function M:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
		{"fadeToAll", 0, 0},
		{"fadeToAll", 255, 0.5, function() 
			self:SetCanClick(true); 
			CC.HallUtil.OnShowHallCamera(false);
		end}
	});
end

function M:ActionOut()
	CC.HallUtil.OnShowHallCamera(true);
	if not self.currentView then
		self:Destroy(); 
		return;
	end
	
	self:SetCanClick(false);
	self:RunAction(self.transform,{"fadeToAll", 0, 0.5});
	self.currentView:ActionOut(function() 
		self.currentView = nil;
		self:Destroy(); 
	end)
end

function M:OnFocusIn()
	CC.HallUtil.OnShowHallCamera(false);
end

function M:OnDestroy()
	
	--断线/被顶号时会从CloseAllOpenView直接调destroy，不会执行ActionOut
	CC.HallUtil.OnShowHallCamera(true)
	if self.currentView then
		self.currentView:Destroy()
	end
	
	if self.viewCtr then
		self.viewCtr:Destroy();
	end
	if self.headIcon then
		self.headIcon:Destroy();
		self.headIcon = nil
	end
	if self.championJPRoller then
		self.championJPRoller:Destroy();
	end
	if self.rankJPRoller then
		self.rankJPRoller:Destroy();
	end
end

return M