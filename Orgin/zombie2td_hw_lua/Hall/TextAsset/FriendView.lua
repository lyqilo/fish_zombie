
local CC = require("CC")

local FriendView = CC.uu.ClassView("FriendView")

function FriendView:ctor(param)
	self.param = param or {}
	self.language = self:GetLanguage()
	self.listFriendItems = {}
	self.friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend")
	self.friendData = self.friendDataMgr.GetFriendListData()
	self.curTab = 1
	self.PrefabTab = {}
	self.IconTab = {}
	self.headIndex = 0
end

function FriendView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitUI()
end

function FriendView:GiftRankClose()
	self.Right:SetActive(true)
end

function FriendView:InitUI()
	self.material = ResMgr.LoadAsset("material", "MaskDefaultGray")
	self.Layer_UI =self:FindChild("Layer_UI")
	self.xian1 = self.Layer_UI:FindChild("Center/xian1")
	self.xian2 = self.Layer_UI:FindChild("Center/xian2")
	self.BtnChat = self.Layer_UI:FindChild("Left/BtnChat")

------------------ListFriendView-------------------------------
    self.ListFriendView = self.Layer_UI:FindChild("Center/ListFriendView")
	self.listScroRect = self.ListFriendView:FindChild("ListFriendScroll"):GetComponent("ScrollRect")
	self.listScroController = self.ListFriendView:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.listScroController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:ListFriend_ItemData(tran,dataIndex)
	end)
	self.listScroController:AddRycycleAction(function(tran)
		self:RycycleItem(tran)
	end)
	self.listSearchInput = self.ListFriendView:FindChild("SeachInputField")
	UIEvent.AddInputFieldOnValueChange(self.listSearchInput, function(str) -- 输入id 搜索相应id的玩家
		self:ListSeachOnValueChange(str)
	end)
	self:AddClick(self.ListFriendView:FindChild("BtnSearch"),function() self:OnListSearchBtn() end,nil,true)
	
-----------------------AddFriendView--------------------------------------------
    self.AddFriendView = self.Layer_UI:FindChild("Center/AddFriendView")
	self.addSearchInput = self.AddFriendView:FindChild("SeachInputField")
	self.addSearchBtn = self.AddFriendView:FindChild("BtnSearch")
	self.Scroll_Init = self.AddFriendView:FindChild("Scroll_Init")
	self.Scroll_Result = self.AddFriendView:FindChild("Scroll_Result")
	self.ResultContent = self.Scroll_Result:FindChild("Viewport/Content")
	self.InitContent = self.Scroll_Init:FindChild("Viewport/Content")
	UIEvent.AddInputFieldOnValueChange(self.addSearchInput, function(str)
		self:AddSearchOnValueChange(str)
	end)
	self:AddClick(self.addSearchBtn,"SearchPersonData",nil,true)

-----------------------FriendRequestView--------------------------------------------
    self.Hongdian = self.Layer_UI:FindChild("Center/Hongdian")
    self.FriendRequestView = self.Layer_UI:FindChild("Center/FriendRequestView")
	self.requestScroRect = self.FriendRequestView:FindChild("VerticalScroll"):GetComponent("ScrollRect")
	self.BtnRejectall = self.FriendRequestView:FindChild("BtnRejectall")
	self.BtnFullAcceptance = self.FriendRequestView:FindChild("BtnFullAcceptance")
	self.requestScroController = self.FriendRequestView:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.requestScroController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:FriendRequest_ItemData(tran,dataIndex)
	end)
	self.requestScroController:AddRycycleAction(function(tran)
		self:RycycleItem(tran)
	end)
	self:AddClick(self.BtnRejectall,function() self.viewCtr:ReqFriendsRefuseAll() end,nil,true)
	self:AddClick(self.BtnFullAcceptance,function() self.viewCtr:ReqFriendsAgreeAll() end,nil,true)

	self:TopHeadInput()

	self.toggle = {}
	self.toggle[1] = self:FindChild("Layer_UI/Center/FriendList")
	self.toggle[2] = self:FindChild("Layer_UI/Center/AddFriednd")
	self.toggle[3] = self:FindChild("Layer_UI/Center/FriendRequest")
	for i,v in ipairs(self.toggle) do
		local index = i
		UIEvent.AddToggleValueChange(v,function(value)
			if value then
				self:OnToggleValueChange(index)
			else
				if index == 2 then
					self.addSearchInput:GetComponent("InputField").text = ""
				elseif index == 1 then
				    self.listSearchInput:GetComponent("InputField").text = ""
				end
			end
		end)
	end
	-- --默认选择第一个页签
	self.toggle[1 or self.param.tab]:GetComponent("Toggle").isOn = false
	self.toggle[1 or self.param.tab]:GetComponent("Toggle").isOn = true

	self:AddClick(self.BtnChat,"GiftToChat",nil,true)
	self:AddClick(self.Layer_UI:FindChild("TopBG/Back/BtnBack"),"CloseView",nil,true)

	self:SetLanguage()

	if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("ChatPanel") then
		self.BtnChat:SetActive(false)
	end
end

--设置顶部头像钻石
function FriendView:TopHeadInput()
	local vipNode = self.Layer_UI:FindChild("TopBG/NodeMgr/VipNode")
	local param = {}
	param.parent = self.Layer_UI:FindChild("TopBG/HeadNode")
	param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id");
	param.portrait = 0;
	param.showFrameEffect = true;
	self:SetHeadIcon(param,true)
	self.VIPCounter = CC.HeadManager.CreateVIPCounter({parent = vipNode, tipsParent = self.Layer_UI:FindChild("TopBG/VIPTipsNode")})
	self.ChipCounter = CC.HeadManager.CreateChipCounter({parent = self.Layer_UI:FindChild("TopBG/NodeMgr/ChipNode")})

	if not CC.ChannelMgr.GetSwitchByKey("bHasVip") then
		vipNode:SetActive(false);
	end
end

--语言设置
function FriendView:SetLanguage()
	self.toggle[1]:FindChild("Text").text = self.language.ListOfFriend
	self.toggle[1]:FindChild("OnSelectText").text = self.language.ListOfFriend
	self.toggle[2]:FindChild("Text").text = self.language.AddFriend
	self.toggle[2]:FindChild("OnSelectText").text = self.language.AddFriend
	self.toggle[3]:FindChild("Text").text = self.language.FriendRequest
	self.toggle[3]:FindChild("OnSelectText").text = self.language.FriendRequest
	self.ListFriendView:FindChild("SeachInputField/Placeholder"):GetComponent("Text").text = self.language.InputID
	self.ListFriendView:FindChild("BtnSearch/Text"):GetComponent("Text").text = self.language.Search
	self.FriendRequestView:FindChild("BtnFullAcceptance/Text"):GetComponent("Text").text = self.language.AllAccpt
	self.FriendRequestView:FindChild("BtnRejectall/Text"):GetComponent("Text").text = self.language.AllRefuse
	self.AddFriendView:FindChild("SeachInputField/Placeholder"):GetComponent("Text").text = self.language.InputID
	self.AddFriendView:FindChild("BtnSearch/Text"):GetComponent("Text").text = self.language.Search
	self.AddFriendView:FindChild("Scroll_Init/TipsBG/TipsText").text = self.language.RecommendPlayer
end

---------------------------------------ListFriend --------------------------------
function FriendView:ListFriend_ItemData(tran,index)
	local rankId = index + 1
	tran.name = tostring(rankId)
	local palyer = self.viewCtr:GetFriendListDataByKey(rankId)
	tran:FindChild("ItemName"):GetComponent("Text").text = palyer.Nick
	tran:FindChild("ID"):GetComponent("Text").text = "ID:"..palyer.PlayerId
	tran:FindChild("xian"):SetActive(rankId == #self.friendData)

	local BtnGift = tran:FindChild("BtnGift")
	if not CC.ChannelMgr.GetSwitchByKey("bShowSendChip") then
		self:DelayRun(0,function ()
			BtnGift:SetActive(false);
		end)
	end
	self:AddClick(BtnGift,function() self:OpenSendChipsView(palyer) end,nil,true)

	local BtnChat = tran:FindChild("BtnChat")
	if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("ChatPanel") or CC.ChannelMgr.GetTrailStatus() then
		self:DelayRun(0,function ()
			BtnChat:SetActive(false)
		end)
	end
    self:RefreshChatRed(BtnChat:FindChild("Red"),palyer.PlayerId)
	self:AddClick(BtnChat,function() self:OpenChat(palyer) end,nil,true)

	local param = {parent = tran:FindChild("Node"),playerId = palyer.PlayerId,portrait = palyer.Portrait,vipLevel = palyer.Level,headFrame = palyer.Background}
	local headIconIndex = self:SetHeadIcon(param,palyer.Online)

	self.listFriendItems[tostring(headIconIndex)] = {chatRed = tran:FindChild("BtnChat/Red"),playerId = palyer.PlayerId}

	self.viewCtr:LoadFriendPage(rankId)
end

function FriendView:RefreshChatRed(chatRed,playerId)
	local unRead = CC.ChatManager.GetUnReadNum(playerId)
	chatRed:SetActive(unRead > 0)
	chatRed:FindChild("Text").text = unRead > 9 and "9+" or unRead
end

function FriendView:OpenSendChipsView(palyer)
	if self:HasBindPhone() then
		local param = {playerId = palyer.PlayerId,playerName = palyer.Nick,portrait = palyer.Portrait,vipLevel = palyer.Level}
		
		CC.ViewManager.Open("SendChipsView",param)
	else
		CC.ViewManager.Open("BeforeSendTipsView",{HasBindPhone = CC.HallUtil.CheckTelBinded()})
	end
end

function FriendView:OpenChat(palyer)
	local data = {PlayerId = palyer.PlayerId,Portrait =palyer.Portrait,Nick = palyer.Nick,Level = palyer.Level,HeadFrame = palyer.Background}
	
	CC.ViewManager.ShowChatPanel(data)
end

function FriendView:HasBindPhone()
	if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("OTPVerify") then
		return true
	else
		return CC.HallUtil.CheckTelBinded()
	end
end

function FriendView:ListSeachOnValueChange(str)
	self.MatchingTab = {}
	self.friendData = self.friendDataMgr.GetFriendListData()
	if str ~= "" then 
		for i = 1,self.friendDataMgr.GetFriendListLen() do
			local friend = self.friendDataMgr.GetFriendListDataByKey(i)
			if string.match(tostring(friend.PlayerId),str) ~= nil then
				table.insert(self.MatchingTab,friend)  --将匹配的id加入到临时tab里面
			end
		end
		self.friendData = self.MatchingTab
	end
	self.listScroController:RefreshScroller(#self.friendData,1-self.listScroRect.verticalNormalizedPosition)
end

function FriendView:OnListSearchBtn()
	local str = self.listSearchInput:GetComponent("InputField").text
	if str == "" then 
		CC.ViewManager.ShowTip(self.language.InputID)
	else
		CC.ViewManager.ShowTip(#self.friendData <= 0 and self.language.NoSearchResult or self.language.SearchFllowPlayers)
	end
end

---------------------------------------AddFriend --------------------------------
--搜索玩家
function FriendView:SearchPersonData()
	local str = self.addSearchInput:GetComponent("InputField").text
	if str == "" then 
		CC.ViewManager.ShowTip(self.language.InputID)
	elseif tostring(CC.Player.Inst():GetSelfInfoByKey("Id")) == str then
		CC.ViewManager.ShowTip(self.language.connectfriendReturn1)
	elseif self.friendDataMgr.IsFriend(tonumber(str)) then
		CC.ViewManager.ShowTip(self.language.connectfriendReturn4)
	elseif self.viewCtr:ReqIsFriend(tonumber(str)) then
		CC.ViewManager.ShowTip(self.language.connectfriendReturn2)
	else
	    self.viewCtr:RequestSearchView(str)
	end
end

function FriendView:AddSearchOnValueChange(str)
	if str == "" then
		self.Scroll_Init:SetActive(true)
		self.Scroll_Result:SetActive(false)
		self:InitReCommandedLsit(self.friendDataMgr.GetReCommandGuy())
	end
end

--初始化推荐列表
function  FriendView:InitReCommandedLsit(data)
 	local list = data
 	if not list then return end
	for i = 1,#list do
		self:ItemData(i,list[i].Player,self.InitContent,list[i].Player.PlayerId,list[i].ChouMa)
	end
end

function FriendView:ItemData(index,friendData,Content,id,chouma)
	local tran = nil
	local item = self.PrefabTab[index]
	if not item then
		item = CC.uu.LoadHallPrefab("prefab", "AddItem")
		item.transform.name = tostring(index)
		self.PrefabTab[index] = item.transform
	end
	if not item.activeSelf then item:SetActive(true) end
	
	local headNode = item.transform:FindChild("Node")
	self:DeleteHeadIconByKey(headNode)
	Util.ClearChild(headNode,false)

	local param = {parent = headNode,playerId = id,portrait = friendData.Portrait,vipLevel = friendData.Level,headFrame = friendData.Background}
	self:SetHeadIcon(param,true)

	local BtnAdd = item.transform:FindChild("BtnAdd")
	self:IsFriendDeal(BtnAdd,self.friendDataMgr.IsFriend(id))

	item.transform:SetParent(Content, false)
	item.transform:FindChild("ItemName").text = friendData.Nick
	item.transform:FindChild("ItemMoneyImg/ItemMoneyText").text = CC.uu.ChipFormat(chouma)
	self:AddClick(BtnAdd,function()
		self.viewCtr:ReqAddFriend(id,function() self:IsFriendDeal(BtnAdd,true) end)
	end,nil,true)
end

function FriendView:IsFriendDeal(obj,isFriend)
	if CC.uu.IsNil(self.transform) then return end

	self:SetImage(obj, isFriend and "gou" or "tianjia");
	obj.sizeDelta = isFriend and Vector2(70, 52) or Vector2(67, 57)
	obj.interactable = not isFriend;
end

---------------------------------------FriendRequestView --------------------------------
function FriendView:FriendRequest_ItemData(tran,index)
	local rankId = index + 1
	tran.name = tostring(rankId)
	local applyPlayer = self.friendDataMgr.GetApplyFriendsDataByKey(rankId)
	tran:FindChild("ItemName"):GetComponent("Text").text = applyPlayer.Nick
	tran:FindChild("ID"):GetComponent("Text").text = "ID:"..applyPlayer.PlayerId

	local BtnRefuse = tran:FindChild("BtnRefuse")
	local BtnAccpt = tran:FindChild("BtnAccpt")
	BtnRefuse:FindChild("Text"):GetComponent("Text").text = self.language.Refuse
	BtnAccpt:FindChild("Text (1)"):GetComponent("Text").text = self.language.Accpt
	tran:FindChild("xian"):SetActive(rankId == self.friendDataMgr.GetApplyFriendsLen())

	self:AddClick(BtnRefuse,function() self.viewCtr:ReqRefuseFriend({applyPlayer.PlayerId},{0},rankId) end,nil,true)
	self:AddClick(BtnAccpt,function() self.viewCtr:ReqAgreeFriend({applyPlayer.PlayerId},rankId) end,nil,true)

	local headNode = tran:FindChild("Node")
	local param = {parent = headNode,playerId = applyPlayer.PlayerId,portrait = applyPlayer.Portrait,vipLevel = applyPlayer.Level,headFrame = applyPlayer.Background}
	self:SetHeadIcon(param,true)
	
	--self.viewCtr:DoTweenTranMove(self.requestScroController,self.requestLayoutGroup,tran,self.friendDataMgr.GetApplyFriendsLen(),index,self.requestScroRect)
	self.viewCtr:LoadFriendRequestPage(rankId)
end

function FriendView:OnToggleValueChange(index)
	self.curTab = index
	CC.Sound.PlayHallEffect("click_tabchange")
	self:SetRedObj({self.curTab ~= 1,self.curTab ~= 2,self.curTab ~= 3})
	self:SetXian(self.curTab == 3,self.curTab == 1)
	self:RedPoint()

	if self.curTab == 1 then
		if not self.initList then
			self.initList = true
			self.listScroController:InitScroller(self.friendDataMgr.GetFriendListLen())
		else
			self.listScroController:RefreshScroller(self.friendDataMgr.GetFriendListLen(),1-self.listScroRect.verticalNormalizedPosition)
		end
		-- if not self.listLayoutGroup then
		-- 	self.listLayoutGroup = self.listScroController.myScroller.ScrollRect.content:GetComponent("VerticalLayoutGroup")
		-- end
		-- self.viewCtr:SetNewLen(self.listScroController,self.listLayoutGroup,self.friendDataMgr.GetFriendListLen())
	elseif self.curTab == 2 then
		self:InitReCommandedLsit(self.friendDataMgr.GetReCommandGuy())
	else
		self.Hongdian:SetActive(false)
		if not self.initRequest then
			self.initRequest = true
			self.requestScroController:InitScroller(self.friendDataMgr.GetApplyFriendsLen())
		else
			self.requestScroController:RefreshScroller(self.friendDataMgr.GetApplyFriendsLen(),1-self.requestScroRect.verticalNormalizedPosition)
		end
		-- if not self.requestLayoutGroup then
		-- 	self.requestLayoutGroup = self.requestScroController.myScroller.ScrollRect.content:GetComponent("VerticalLayoutGroup")
		-- end
		-- self.viewCtr:SetNewLen(self.requestScroController,self.requestLayoutGroup,self.friendDataMgr.GetApplyFriendsLen())
		self:BtnInteractable()
	end
end

function FriendView:SetRedObj(data)
	for i,v in ipairs(self.toggle) do
		v:FindChild("Red"):SetActive(data[i])
	end
end

function FriendView:SetXian(b1,b2)
	self.xian1:SetActive(b1)
	self.xian2:SetActive(b2)
end

--好友申请红点提示
function FriendView:RedPoint()
	local len =  self.friendDataMgr.GetApplyFriendsLen()
	self.Hongdian:SetActive(len > 0)
	self.Hongdian:FindChild("Len").text = len > 99 and "99+" or len
end

function FriendView:RycycleItem(tran)
	local headNode = tran.transform:FindChild("Node")
	self:DeleteHeadIconByKey(headNode)
	Util.ClearChild(headNode,false)
	
	if headNode.childCount > 0 then
		local index = headNode.transform:GetChild(0).transform.name
		if self.listFriendItems[index] then
			self.listFriendItems[index] = nil
		end
	end
end

function FriendView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.IconTab[tonumber(headtran.transform.name)] ~= nil then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end
end

function FriendView:SetHeadIcon(param,iconBright)
	self.headIndex = self.headIndex + 1
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	if not iconBright then
		self.HeadIcon:SetMaterial(self.material)
	end
	self.HeadIcon.transform.name = tostring(self.headIndex)
	self.IconTab[self.headIndex] = self.HeadIcon
	return self.headIndex
end

--切换到聊天
function FriendView:GiftToChat()
	CC.ViewManager.ShowChatPanel()
end

--有私聊的时候，聊天按钮抖动
function FriendView:RefreshChat(state)
	self.BtnChat:FindChild("xinxi"):SetActive(state)
end

--收到好友申请推送
function FriendView:OnGetPushFriendRequest()
	if self.curTab ~= 3 then 
		self:RedPoint()
	else
		self.requestScroController:RefreshScroller(self.friendDataMgr.GetApplyFriendsLen(),1-self.requestScroRect.verticalNormalizedPosition)
	end
end

--同意好友申请
function FriendView:OnGetPushFriendAdded()
	if self.curTab == 3 then
		self.requestScroController:RefreshScroller(self.friendDataMgr.GetApplyFriendsLen(),1-self.requestScroRect.verticalNormalizedPosition)
	    self:BtnInteractable()
	elseif self.curTab == 1 then
		self.listScroController:RefreshScroller(self.friendDataMgr.GetFriendListLen(),1-self.listScroRect.verticalNormalizedPosition)
	end
end

--删除好友
function FriendView:OnSetDeleteFriend()
	if self.curTab == 1 then
		self.listScroController:RefreshScroller(self.friendDataMgr.GetFriendListLen(),1-self.listScroRect.verticalNormalizedPosition)
	end
end

function FriendView:BtnInteractable()
	local total = self.friendDataMgr.GetApplyFriendsTotal()
	self.BtnFullAcceptance:SetActive(total > 1)
	self.BtnRejectall:SetActive(total > 1)
end

function  FriendView:CloseView()
	if self.param and self.param.closeFunc then
        self.param.closeFunc()
    end
	self:Destroy()
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnPushFriendRequest) --好友通知大厅清空红点
end

function FriendView:OnDestroy()
	for i,v in pairs(self.IconTab) do
		if v then
			v:Destroy()
			v = nil
		end
	end

	if self.ChipCounter then
		self.ChipCounter:Destroy()
		self.ChipCounter = nil
	end

	if self.VIPCounter then
		self.VIPCounter:Destroy()
		self.VIPCounter = nil
	end

	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end

	self.listScroController = nil
	self.listScroRect = nil
	self.requestScroController = nil
	self.requestScroRect = nil
end

function FriendView:ActionIn()
end

return FriendView