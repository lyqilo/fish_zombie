
local CC = require("CC")

local FriendViewCtr = CC.uu.ClassView("FriendViewCtr")

function FriendViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function FriendViewCtr:OnCreate()
	self:RegisterEvent()
end

function FriendViewCtr:Destroy()
	self:unRegisterEvent()
	CC.HallUtil.OnShowHallCamera(true);
end

function FriendViewCtr:InitVar(view, param)
	self.param = param;
	--UI对象
	self.view = view;

	self.friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend");

	--拉取好友列表
	if not self.friendDataMgr.GetInitFriendsListState() then
		CC.Request("ReqLoadFriendsList",{Index = 1})
	end

	--拉取好友申请列表
	if not self.friendDataMgr.GetInitApplyListState() then
		CC.Request("ReqLoadApplyFriendsList",{Index = 1})
	end

	--每次点开推荐列表能够获取最新的推荐列表数据
	self:ReqLoadRecommandedFriends()

	CC.HallUtil.OnShowHallCamera(false);
end

function FriendViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.RefreshChatState,CC.Notifications.ChatFlash)
	CC.HallNotificationCenter.inst():register(self, self.ResRecommandedFriends, CC.Notifications.NW_ReqLoadRecommandedFriends)
	CC.HallNotificationCenter.inst():register(self, self.ResFriendsRefuseAll, CC.Notifications.NW_ReqFriendsRefuseAll)
	CC.HallNotificationCenter.inst():register(self, self.ResFriendsAgreeAll, CC.Notifications.NW_ReqFriendsAgreeAll)
	CC.HallNotificationCenter.inst():register(self, self.ResLoadFriendsList, CC.Notifications.NW_ReqLoadFriendsList)
	CC.HallNotificationCenter.inst():register(self, self.ResLoadApplyFriendsData, CC.Notifications.NW_ReqLoadApplyFriendsList)

	CC.HallNotificationCenter.inst():register(self, self.OnSearchFriend, CC.Notifications.OnSearchFriend)
	CC.HallNotificationCenter.inst():register(self, self.OnGetPushFriendRequest, CC.Notifications.OnPushFriendRequest)
	CC.HallNotificationCenter.inst():register(self, self.OnGetPushFriendAdded, CC.Notifications.OnPushFriendAdded)
   	CC.HallNotificationCenter.inst():register(self, self.OnSetDeleteFriend, CC.Notifications.SetDeleteFriend)
	CC.HallNotificationCenter.inst():register(self, self.OnPriChat, CC.Notifications.PriChatRead)
	CC.HallNotificationCenter.inst():register(self, self.OnPriChat, CC.Notifications.PriChat)
end

function FriendViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

--获取好友列表的数据
function FriendViewCtr:GetFriendListDataByKey(id)
	for i,v in ipairs(self.view.friendData) do
		if i == id then
			return self.view.friendData[i]
		end		
	end
end

--设置长度
function FriendViewCtr:SetNewLen(VerticalScroll,VerticalLayoutGroup,len)
	VerticalLayoutGroup.enabled = false
	if len <= 0 then return	end
	VerticalScroll:InitScroller(len <= 4 and len or 5)
end

--动画
function FriendViewCtr:DoTweenTranMove(VerticalScroll,VerticalLayoutGroup,tran,len,index,ScrollRect)	
	if VerticalLayoutGroup.enabled == false then
		tran.transform.localPosition = Vector3(1105,-53 + (index * -107),0)
		self.view:RunAction(tran, {"localMoveTo", 0, -53 + (index * -107),0.15*(index + 1), function()
			local count = len <= 4 and len or 4
			if index + 1 == count then
	  			VerticalLayoutGroup.enabled = true
	  			self:ScorllCount(VerticalScroll,len,ScrollRect)
	  		end
		end})
	end	
end

--设置循环列表的长度
function FriendViewCtr:ScorllCount(looptran,sumCount,ScrollRect)
	if sumCount <= 0 then
		looptran:ClearAll()
		return
	end
	looptran:RefreshScroller(sumCount,1-ScrollRect.verticalNormalizedPosition)
end

function FriendViewCtr:RefreshChatState(state)
	self.view:RefreshChat(state)
end

function FriendViewCtr:ReqIsFriend(id)
	CC.Request("ReqIsFriend",{FriendId = tonumber(id)},function(err,data)
		if err == 0 then 
			if data.Ret then
				return true
			end			
		elseif err == 52 then 
			return false
		end		
	end)
end

function FriendViewCtr:OnSearchFriend(err, data)
	if err == 0 then
		local chouma = self:GetPropValueByKey("EPC_ChouMa",data)
		local FriendData = data.Data.Player
		self.view:ItemData(1,FriendData,self.view.ResultContent,FriendData.Id,chouma)
		self.view.Scroll_Init:SetActive(false)
		self.view.Scroll_Result:SetActive(true)
		return 
	end
	if err ~= CC.shared_en_pb.OpsLocked then
		CC.ViewManager.ShowTip(self.view.language.NoSearchResult)
	end
end

function FriendViewCtr:RequestSearchView(str)
	local param = {
		playerId = str,
		propTypes = {CC.shared_enums_pb.EPT_Wealth}
	}
	CC.Request("ReqLoadPlayerWithPropType",param, function(err,data)
		--logError("err = ".. err.."  "..CC.uu.Dump(data,"ReqLoadPlayerWithPropType",10))	
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnSearchFriend,err,data)
	end, function(err, data)
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnSearchFriend,err)
	end)
end

function FriendViewCtr:GetPropValueByKey(key,data)
	local propId = CC.shared_enums_pb[key];
	if not propId then
		logError("PersonalInfoViewCtr:shared_enums_pb has no enum value of "..tostring(key))
		return
	end
	local propsData = data.Data.Props
	for _,v in ipairs(propsData) do
		if v.ConfigId == propId then
			return v.Count
		end
	end
	logError("PersonalInfoViewCtr:has no this propId-"..tostring(propId))
end

function FriendViewCtr:ReqAddFriend(id,func)
	if not self.view.friendDataMgr.CheckSaveID(id) then
		CC.ViewManager.ShowTip(self.view.language.tip1)
		return
	end
	if self.view.friendDataMgr.IsFriend(id) then
		CC.ViewManager.ShowTip(self.view.language.connectfriendReturn4)
		return
	end
	CC.Request("ReqAddFriend",{FriendId = id},function(err,data)
		if err == 0 then
			func()
			CC.ViewManager.ShowTip(self.view.language.connectfriendReturn3)
		end
	end)
end

function FriendViewCtr:ReqAgreeFriend(ids,rankId)
	CC.Request("ReqAgreeFriend",{ids = ids})
end

function FriendViewCtr:ReqRefuseFriend(ids,flags,rankId)
	CC.Request("ReqRefuseFriend",{ids = ids,flags = flags},function(err,data)
		if err == 0 then 
			--logError("拒绝好友申请成功！")
			self:RebuildScrll(rankId)
		elseif err == 52 then 
			--logError("该请求已被撤销!")
		end		
	end)
end

--拒绝的时候删除单个申请
function FriendViewCtr:RebuildScrll(rankId)
	self.view.friendDataMgr.DeleteApplyFriendsById(rankId)
	if self.view.curTab == 3 and not CC.uu.IsNil(self.view.transform) then
		self.view.requestScroController:RefreshScroller(self.view.friendDataMgr.GetApplyFriendsLen(),1-self.view.requestScroRect.verticalNormalizedPosition)
	    self.view:BtnInteractable()
	end
end

--同意所有好友
function FriendViewCtr:ReqFriendsAgreeAll()
	CC.Request("ReqFriendsAgreeAll")
end

--同意所有好友回调
function FriendViewCtr:ResFriendsAgreeAll(err,data)
	if err == 0 then 
			--logError("同意所有好友申请成功！")
			self:FullDataFunc()
		elseif err == 52 then 
			--logError("该请求已被撤销!")
		end		
end

--拒绝所有好友
function FriendViewCtr:ReqFriendsRefuseAll()
	CC.Request("ReqFriendsRefuseAll")
end

--全部拒绝回调
function FriendViewCtr:ResFriendsRefuseAll(err,data)
	if err == 0 then 
		--logError("拒绝所有好友申请成功！")
		self:FullDataFunc()
	elseif err == 52 then 
		--logError("该请求已被撤销!")
	end		
end

--一键同意或者拒绝之后的操作
function FriendViewCtr:FullDataFunc()
	self.view.friendDataMgr.DeleteAllApplyFriendsMsg()
	if self.view.curTab == 3 then
		self.view.requestScroController:RefreshScroller(self.view.friendDataMgr.GetApplyFriendsLen(),1-self.view.requestScroRect.verticalNormalizedPosition)
	    self.view:BtnInteractable()
	end
end

function FriendViewCtr:ReqLoadRecommandedFriends()
	CC.Request("ReqLoadRecommandedFriends")
end

function FriendViewCtr:ResRecommandedFriends(err,data)
	if err == 0 then 
		CC.DataMgrCenter.Inst():GetDataByKey("Friend").SetReCommandGuy(data)
	end		
end

--分页拉取好友列表
function FriendViewCtr:LoadFriendPage(rankId)
	if self.view.friendDataMgr.GetFriendListLen() == rankId and rankId < self.view.friendDataMgr.GetFriendTotal() then  
	--判断长度是否与当前item的下标相等并且当前item的下标是否小于总长度
		local from = 50 * self.view.friendDataMgr.GetCurrentIndexPage()
		self.view.friendDataMgr.SetCurrentIndexPage(rankId)
		local to = (50 * self.view.friendDataMgr.GetCurrentIndexPage()) - 1
		self:LoadFriendData(from,to,self.view.friendDataMgr.GetCurrentIndexPage())
		--logError(string.format("%s  %s",rankId,self.view.friendDataMgr.GetFriendTotal()))
	end
end

function FriendViewCtr:LoadFriendData(From,to,Pageindex)
	--拉取好友列表
	local data = {
		From = From,
		To = to,
		Index = Pageindex
	}
	CC.Request("ReqLoadFriendsList",data)
end

function FriendViewCtr:ResLoadFriendsList(err,data)
 	--logError(CC.uu.Dump(data,"ResLoadFriendsList =",11))
 	if err == 0 then
		CC.DataMgrCenter.Inst():GetDataByKey("Friend").AddFriendListData(data)
		if self.view.curTab == 1 then
			self.view.listScroController:RefreshScroller(self.view.friendDataMgr.GetFriendListLen(),1-self.view.listScroRect.verticalNormalizedPosition)
		end
	end
end

function FriendViewCtr:LoadFriendRequestPage(rankId)
	--判断长度是否与当前item的下标相等并且当前item的下标是否小于总长度
	if self.view.friendDataMgr.GetApplyFriendsLen() == rankId and rankId < self.view.friendDataMgr.GetApplyFriendsTotal() then
		self.view.friendDataMgr.SetCurrentApplyIndexPage(rankId)
		self:LoadApplyFriendsData(self.view.friendDataMgr.GetCurrentApplyIndexPage())
		--logError(string.format("%s  %s",rankId,self.view.friendDataMgr.GetApplyFriendsTotal()))
	end
end

function FriendViewCtr:LoadApplyFriendsData(Pageindex)
	--拉取好友申请列表
	CC.Request("ReqLoadApplyFriendsList",{Index = Pageindex})
end

function FriendViewCtr:ResLoadApplyFriendsData(err,data)
	if err == 0 then
		CC.DataMgrCenter.Inst():GetDataByKey("Friend").AddApplyFriendsData(data)
		if self.view.curTab == 3 then
			self.view.requestScroController:RefreshScroller(self.view.friendDataMgr.GetApplyFriendsLen(),1-self.view.requestScroRect.verticalNormalizedPosition)
		end
	end
end

function FriendViewCtr:OnGetPushFriendRequest()
	self.view:OnGetPushFriendRequest()
end

function FriendViewCtr:OnGetPushFriendAdded()
	self.view:OnGetPushFriendAdded()
end

function FriendViewCtr:OnSetDeleteFriend()
	self.view:OnSetDeleteFriend()
end

function FriendViewCtr:OnPriChat(resp)
	if resp.From == CC.Player.Inst():GetSelfInfoByKey("Id") then
		return
	end
	for k,v in pairs(self.view.listFriendItems) do
		if resp.From == v.playerId then
			self.view:RefreshChatRed(v.chatRed,v.playerId)
			break
		end
	end
end

return FriendViewCtr