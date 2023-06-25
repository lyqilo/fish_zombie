
local CC = require("CC")

local BlessSearchView = CC.uu.ClassView("BlessSearchView")

function BlessSearchView:ctor(param)

	self:InitVar(param);
end

function BlessSearchView:OnCreate()

	self:InitData();

	self:InitContent();
end

function BlessSearchView:InitVar(param)
	--在线好友数据
	self.onlineFriendData = {};
	--头像对象列表
	self.headObjList = {};
	--需要显示的好友对象
	self.matchFriendList = {};

	self.language = CC.LanguageManager.GetLanguage("L_BlessLotteryView");

	self.friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend");
end

function BlessSearchView:InitData()

	for _,v in pairs(self.friendDataMgr.GetFriendListData()) do
		if v.Online then
			table.insert(self.onlineFriendData, v);
		end
	end

	self.matchFriendList = self.onlineFriendData;

	self:InitLanguage();
end

function BlessSearchView:InitLanguage()

	self:FindChild("Frame/Tab/Title"):SetText(self.language.blessTitle);
	self:FindChild("Frame/Bottom/Text"):SetText(self.language.blessBoardTip);
	self:FindChild("Frame/Bottom/BtnSend/Text"):SetText(self.language.btnSendSelf);
	self:FindChild("Frame/SearchInputField/Placeholder").text = self.language.inputTips;
	
end

function BlessSearchView:GetMatchFriendData(id)
	
	local list = {};
	for _,v in ipairs(self.onlineFriendData) do
		if string.match(tostring(v.PlayerId), id) then
			table.insert(list, v);
		end
	end
	return list;
end

function BlessSearchView:InitContent()

	local scrollController = self:FindChild("Frame/ScrollerController"):GetComponent("ScrollerController");
	scrollController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		xpcall(function() self:InitItemData(tran,dataIndex,cellIndex) end, function(error) logError(error) end);
	end)
	scrollController:InitScroller(#self.matchFriendList); 

	local inputField = self:FindChild("Frame/SearchInputField")
	local placeholder = self:FindChild("Frame/SearchInputField/Placeholder")
	UIEvent.AddInputFieldOnValueChange(inputField, function(str)
			if str == "" then
				return
			end
			self.matchFriendList = self:GetMatchFriendData(str);
			scrollController:RefreshScroller(#self.matchFriendList, 0);
		end);

	self:AddClick("Frame/BtnSearch", "ClickBtnSearch");
	self:AddClick("Frame/Bottom/BtnSend", "ClickBtnSend");
end

function BlessSearchView:InitItemData(trans, dataIndex, cellIndex)
	-- logError("dataIndex:"..tostring(dataIndex));
	local index = dataIndex + 1;
	local friendData = 	self.matchFriendList[index];

	--清理HeadNode节点下挂载的头像节点
	local headNode = trans:FindChild("HeadNode");
	CC.uu.DestroyAllChilds(headNode);
	if self.headObjList[index] then
		self.headObjList[index]:Destroy();
		self.headObjList[index] = nil;
	end

	--创建并挂载头像节点到HeadNode
	local headData = {};
	headData.parent = headNode;
	headData.playerId = friendData.PlayerId;
	headData.vipLevel = friendData.Level;
	headData.portrait = friendData.Portrait;
	headData.clickFunc = "unClick";
	self.headObjList[index] = CC.HeadManager.CreateHeadIcon(headData);

	trans:FindChild("Name"):SetText(friendData.Nick);
	trans:FindChild("Id"):SetText(friendData.PlayerId);

	self:AddClick(trans:FindChild("BtnSend"), function()
			self:RequestSendBless(friendData.PlayerId);
		end);
end

function BlessSearchView:ClickBtnSearch()

	if #self.matchFriendList == 0 then
		CC.ViewManager.ShowTip(self.language.NoSearchResult);
	end
end

function BlessSearchView:ClickBtnSend()

	local toPlayerId = CC.Player.Inst():GetSelfInfoByKey("Id");
	self:RequestSendBless(toPlayerId);
end

function BlessSearchView:RequestSendBless(toPlayerId)
	local data = {};
	data.PlayerId = CC.Player.Inst():GetSelfInfoByKey("Id");
	data.ToPlayerId = toPlayerId;
	CC.Request("SendFarewell",data)
	self:ActionOut();
end

function BlessSearchView:OnDestroy()

	for i,headObj in pairs(self.headObjList) do
		headObj:Destroy();
	end
end

return BlessSearchView;