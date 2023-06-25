local CC = require("CC")

local WorldCupMainView = CC.uu.ClassView("WorldCupMainView")
local M = WorldCupMainView

function M:ctor(param)

	self:InitVar(param)

end

function M:InitVar(param)
	self.param = param or {};

	self.adIndex = 1;

	self.adMoveTime = 0;

	self.adCount = 0;

	self.rhData = {
		{index = 1, headFrame = CC.shared_enums_pb.EPC_Avatar_Box_WorldCup1},
		{index = 2, headFrame = CC.shared_enums_pb.EPC_Avatar_Box_WorldCup2},
		{index = 3, headFrame = CC.shared_enums_pb.EPC_Avatar_Box_WorldCup3},
	}

	self.adHeadList = {};

	self.rankHeadList = {};

	self.indexList = {};

	self.scheduleBoard = nil;

	self.language = CC.LanguageManager.GetLanguage("L_WorldCupView")
end

function M:OnCreate()

	self:InitUI()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
	self:InitTextByLanguage()
	self:AddClickEvent()
end

function M:CreateViewCtr(...)
	local viewCtrClass = require("View/WorldCupView/"..self.viewName.."Ctr")
	return viewCtrClass.new(self, ...)
end

function M:InitUI()

	self.championNode = self:FindChild("RightPanel/TNode")
	self.rankNode = self:FindChild("RightPanel/BNode")
	self.adNode = self:FindChild("LeftPanel/Content")
	self.chatNode = self:FindChild("LeftPanel/BtnChat")

	local headNode = self.rankNode:FindChild("HeadNode");
	for _,v in ipairs(self.rhData) do
		local headIcon = CC.HeadManager.CreateHeadIcon({parent = headNode:FindChild(tostring(v.index)), playerId = "", headFrame = v.headFrame, isShowDefault = true, clickFunc = "unClick"})
		table.insert(self.rankHeadList, headIcon)
	end

	local switch = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("ChatPanel") and CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel")
	if switch then
		self:StartTimer("chat", 1, function()
			local chatData = CC.ChatManager.GetLastPublicChatInfo();
			if chatData then
				self.chatNode:FindChild("Frame"):SetActive(true)
				self:RefreshUI({chatData = chatData})
			end
		end, -1)
	else
		self.chatNode:SetActive(false);
	end

	self.mascot = CC.uu.CreateHallView("WorldCupMascot");
	self.mascot.transform:SetParent(self.adNode:FindChild("Mascot"), false);

	CC.HallNotificationCenter.inst():post(CC.Notifications.WorldCupJackpotChange, {type = "champion", node = self.championNode:FindChild("Jackpot/Value")});
	CC.HallNotificationCenter.inst():post(CC.Notifications.WorldCupJackpotChange, {type = "rank", node = self.rankNode:FindChild("Jackpot/Value")});
end

function M:InitTextByLanguage()
	self.rankNode:FindChild("Tittle").text = self.language.scoreRank
	self.adNode:FindChild("OrgItem/Text").text = self.language.worldCup
end

function M:AddClickEvent()

	self:AddClick(self.chatNode, function()
		if CC.ChatManager.ChatPanelToggle() then
			CC.ViewManager.ShowChatPanel()
		end
	end)

	local btnGuess = self:FindChild("RightPanel/TNode/Frame");
	self:AddClick(btnGuess, function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.WorldCupSubViewChange, "WorldCupGuessView");
	end)

	local btnRank = self:FindChild("RightPanel/BNode/Frame");
	self:AddClick(btnRank, function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.WorldCupSubViewChange, "WorldCupRankView");
	end)
end

function M:InitAdScroller(data)
	self.adData = data;
	self.adCount = #self.adData;
	if self.adCount > 0 then
		self.ScrollRect = self.adNode:FindChild("Scroller")
		self.ScrollRect:GetComponent("ScrollRect").horizontal = false;
		self.ScrollerController = self.adNode:FindChild("ScrollerController"):GetComponent("ScrollerController")
		self.ScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
			self:InitADItemData(tran,dataIndex,cellIndex)
		end)
		self.ScrollerController:AddRycycleAction(function(tran)
			self:RycycleItem(tran)
		end)
		self.ScrollerController:InitScroller(self.adCount)


		local indexNode = self.adNode:FindChild("IndexGroup")
		local index = indexNode:FindChild("Index")
		for i = 1, self.adCount do
			local index = CC.uu.UguiAddChild(indexNode,index,i)
			table.insert(self.indexList,index)
		end
		self:SetIndexLight(self.adIndex);
		self:ShowLuckerInfo(true);
		if self.adCount == 1 then
			self.ScrollerController:ToggleLoop();
		end
		if self.adCount > 1 then
			self:StartUpdate(self.Update);
		end
		return;
	end
	self.adNode:FindChild("OrgItem"):SetActive(true);
end

function M:InitScheduleBoard(data)
	local scheduleBoard = CC.uu.CreateHallView("ScheduleBoard", data)
	scheduleBoard.transform:SetParent(self:FindChild("MidPanel"), false)
	self.scheduleBoard = scheduleBoard;
end

function M:InitADItemData(tran,dataIndex,cellIndex)
	if not self.adHeadList then return end
	local index = dataIndex + 1;
	local data = self.adData[index];
	tran.name = index;
	local node = tran:FindChild(data.type);
	node:SetActive(true);
	if data.type == "Lucker" then
		local headNode = node:FindChild("HeadNode");
		local headIcon = CC.HeadManager.CreateHeadIcon({parent = headNode, playerId = data.playerId, portrait = data.portrait,headFrame = data.headFrame, clickFunc = "unClick"})
		self.adHeadList[index] = headIcon;
		headNode:FindChild("Tips/Text").text = self.language.gameLucker;
		headNode:FindChild("ChipCount").text = CC.uu.ChipFormat(data.bonus);
	elseif data.type == "Match" then
		for i,v in ipairs(data.country) do
			local index = i == 1 and "L" or "R";
			local stationNode = node:FindChild("Frame/"..index.."Station");
			self:SetImage(stationNode, "circle_"..v.id);
			local stationName = stationNode:FindChild("Text");
			stationName.text = self.language.countryName[v.id];
			local score = stationNode:FindChild("Score");
			score.text = v.score;
		end
		node:FindChild("Tips/Text").text = self.language.matchReview;
	end
end

function M:RycycleItem(tran)
	if not self.adHeadList then return end
	local index = tonumber(tran.name);
	local data = self.adData[index];
	local node = tran:FindChild(data.type);
	node:SetActive(false);
	local headIcon = self.adHeadList[index]
	if headIcon then
		headIcon:Destroy(true);
		self.adHeadList[index] = nil;
	end
end

function M:SetIndexLight(index)
	self.adIndex = index
	for i,v in ipairs(self.indexList) do
		if i == index then
			v:FindChild("On"):SetActive(true)
		else
			v:FindChild("On"):SetActive(false)
		end
	end
end

function M:RefreshUI(param)
	if param.chatData then
		self:RefreshChat(param.chatData);
	end
end

function M:RefreshChat(chatData)
	self.chatNode:FindChild("Frame/Mask/Text").text = chatData.Message;
end

function M:RefreshRankHeadIcon(data)
	for i,v in ipairs(data.RankInfo.Rank) do
		local headIcon = self.rankHeadList[i];
		if headIcon then
			headIcon:SetHeadImage(v.Player.Portrait);
		end
	end
end

function M:Update()
	self.adMoveTime = self.adMoveTime + Time.deltaTime
	if self.adMoveTime >= 5 then
		local curPos = self.ScrollRect:FindChild("Container").localPosition
		self.adMoveTime = 0
		self:ShowLuckerInfo(false);
		self:RunAction(self.ScrollRect:FindChild("Container"), {"localMoveTo",curPos.x - 400,curPos.y, 1,function ()
			self.adIndex = self.adIndex + 1 > self.adCount and 1 or self.adIndex + 1
			self:SetIndexLight(self.adIndex)
			self:ShowLuckerInfo(true);
		end});
	end
end

function M:ShowLuckerInfo(flag)
	local data = self.adData[self.adIndex];
	if data.type ~= "Lucker" then return end
	local nick = self.adNode:FindChild("Bottom/Nick");
	local playerId = self.adNode:FindChild("Bottom/ID");
	if flag then
		nick.text = data.nick;
		playerId.text = data.playerId;
		return;
	end
	nick.text = "";
	playerId.text = "";
end

function M:ActionIn()
	local node = self:FindChild("RightPanel");
	local x,y = node.x,node.y;
	node.x = -900;
	self:RunAction(node, {"localMoveTo", x, y, 0.3, ease = CC.Action.EOutSine, function() end})

	local node = self:FindChild("MidPanel");
	local x,y = node.x,node.y;
	node.x = -1100;
	self:RunAction(node, {"localMoveTo", x, y, 0.3, delay = 0.1, ease = CC.Action.EOutSine, function() end})

	local node = self:FindChild("LeftPanel");
	local x,y = node.x,node.y;
	node.x = -1300;
	self:RunAction(node, {"localMoveTo", x, y, 0.3, delay = 0.2, ease = CC.Action.EOutSine, function() end})
end

function M:ActionOut(cb)

	local node = self:FindChild("LeftPanel");
	self:RunAction(node, {"localMoveTo", -1300, node.y, 0.3, ease = CC.Action.EOutSine, function() end})

	local node = self:FindChild("MidPanel");
	self:RunAction(node, {"localMoveTo", -1100, node.y, 0.3, delay = 0.1, ease = CC.Action.EOutSine, function() end})

	local node = self:FindChild("RightPanel");
	self:RunAction(node, {"localMoveTo", -900, node.y, 0.3, delay = 0.2, ease = CC.Action.EOutSine, function() 
		self:Destroy();
		if cb then cb() end
	end})
end

function M:SetCanClick(flag)
	self._canClick = flag;
	if self.scheduleBoard then
		self.scheduleBoard:SetCanClick(flag);
	end
end

function M:OnDestroy()

	if self.viewCtr then
		self.viewCtr:Destroy()
	end

	if self.mascot then
		self.mascot:Destroy()
	end

	if not table.isEmpty(self.rankHeadList) then
		for _,v in pairs(self.rankHeadList) do
			v:Destroy();
		end
		self.rankHeadList = nil;
	end

	if not table.isEmpty(self.adHeadList) then
		for _,v in pairs(self.adHeadList) do
			v:Destroy();
		end
		self.adHeadList = nil
	end

	self.ScrollRect = nil;
	self.ScrollerController = nil;
end

return M