---------------------------------
-- region ChatPanelCtr.lua	-
-- Date: 2019.09.27				-
-- Desc: 聊天				-
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local ChatPanelCtr = CC.class2("ChatPanelCtr")

local ChatItemList = {}

function ChatPanelCtr:ctor(view, param)
	self:InitVar(view, param)
end

function ChatPanelCtr:InitVar(view,param)
	self.view = view

	ChatItemList = {}
end

function ChatPanelCtr:OnCreate()
	self:RegisterEvent()
end

function ChatPanelCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.RefreshUserInfo,CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():register(self,self.RecvChat,CC.Notifications.RefreshChat)
	CC.HallNotificationCenter.inst():register(self,self.RecvPriChat,CC.Notifications.PriChat)
	CC.HallNotificationCenter.inst():register(self,self.OnResqAddFriend,CC.Notifications.NW_ReqAddFriend)
	CC.HallNotificationCenter.inst():register(self,self.ReqHisChatDataRsp,CC.Notifications.NW_LoadChatList)
	CC.HallNotificationCenter.inst():register(self,self.ReqPriHisChatDataRsp,CC.Notifications.NW_LoadPChatSummary)
end

function ChatPanelCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.RefreshChat)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.PriChat)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqAddFriend)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_LoadChatList)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_LoadPChatSummary)
end

function ChatPanelCtr:RefreshUserInfo()
	self.view:RefreshUserInfo()
end

function ChatPanelCtr:ReqHisChatData()
	if CC.ChatManager.IsLoadHisChatData() then
		self:InitPubChat()
		return
	end
	--请求历史聊天记录
	local data=CC.ChatManager.GetHisInfoNum()
	CC.Request("LoadChatList",{Count=data})
end

function ChatPanelCtr:ReqHisChatDataRsp(err, data)
	if err == 0 then
		CC.ChatManager.InitCache(data.Chats)
		self:InitPubChat()
		return
	end
	logError("ChatPanelCtr:ReqHisChatData failed");
end

--公共聊天部分
--首次点击系统聊天或世界聊天
function ChatPanelCtr:InitPubChat()
	--保存这次拉取的所有信息（后续刷新使用这部分数据）
	self.InitChatInfo = CC.ChatManager.GetChatInfo()
	self.InitIndex = 0
	local count = #self.InitChatInfo
	--刷新父节点锚点
	-- self.view:SetPivot(count)
	if count <= 10 then
		for i,v in ipairs(self.InitChatInfo) do
			self.view:DelayRun(0.016*(i-1),function ()
				self.view:CreateHisChat(self.InitChatInfo[i],false)
			end)
		end
	else
		local delay = 0
		self.InitIndex = count - 5
		for i=self.InitIndex,count do
			self.view:DelayRun(0.016*delay,function ()
				self.view:CreateHisChat(self.InitChatInfo[i],false)
			end)
			delay = delay + 1
		end
	end
end

--刷新后续消息
function ChatPanelCtr:OverFresh()
	self.InitIndex = self.InitIndex -1
	if self.InitIndex < 0 then return end
	if #self.InitChatInfo >= 10 then
		if self.InitIndex - 5 > 0 then
			local delay = 0
			for i = self.InitIndex - 5,self.InitIndex do
				self.view:DelayRun(0.016*delay,function ()
					self.view:CreateHisChat(self.InitChatInfo[i],true)
				end)
				delay = delay + 1
			end
			self.InitIndex = self.InitIndex - 5
		else
			local delay = 0
			for i=1,self.InitIndex do
				self.view:DelayRun(0.016*delay,function ()
					self.view:CreateHisChat(self.InitChatInfo[i],true)
				end)
				delay = delay + 1
			end
			self.InitIndex = 0
		end
	end
end

--接受服务器推送消息
function ChatPanelCtr:RecvChat(resp)
	self.view:OnRcvMsg(resp)
end

function ChatPanelCtr:ReqPriHisChatData()
	if CC.ChatManager.IsLoadPriHisChatData() then
		self:InitPrivateList()
		return
	end
	CC.Request("LoadPChatSummary")
end

function ChatPanelCtr:ReqPriHisChatDataRsp(err, data)

	if err == 0 then
		CC.ChatManager.InitPrivateList(data)
		self:InitPrivateList()
		return
	end
	logError("ChatPanelCtr: ReqPriHisChatData failed");
end

--私聊部分
--初始化私聊列表
function ChatPanelCtr:InitPrivateList()
	if not self.isInitPriChat then
		self.isInitPriChat =true
		self.PivateList = CC.ChatManager.GetPrivateList()
		if #self.PivateList > 0 then
			self.view.PriLabel:SetActive(false)
		else
			self.view.PriLabel:SetActive(true)
		end
		self.view.ScrollerController:InitScroller(#self.PivateList)
	end
end

--刷新私聊列表
function ChatPanelCtr:RefreshPriList()
	self.PivateList = CC.ChatManager.GetPrivateList()
	if #self.PivateList > 0 then
		self.view.PriLabel:SetActive(false)
	else
		self.view.PriLabel:SetActive(true)
	end
	self.view.ScrollerController:RefreshScroller(#self.PivateList,1-self.view.PriScroller:GetComponent("ScrollRect").verticalNormalizedPosition)
end

--私聊列表对象修改
function ChatPanelCtr:InitPrivateItem(tran,dataIndex,cellIndex)
	local id = self.PivateList[dataIndex + 1]
	self.view:InitPrivatePrefab(tran,id)
end

--接收服务器推送私聊信息
function ChatPanelCtr:RecvPriChat(resp)
	self:RefreshPriList()
	self.view:FillPriPrefab(resp,false)
end

function ChatPanelCtr:SetCurChatType(type)
	CC.ChatManager.SetCurChatType(type)
end

function ChatPanelCtr:OpenPriChat(id)
	--获取私人聊天详细信息
	self.HisPriChat = CC.ChatManager.GetDetailDataByID(id)
	if self.HisPriChat then
		self:CreatePri(self.HisPriChat)
		self.view:LoadPChatListSuccess()

		CC.HallNotificationCenter.inst():post(CC.Notifications.PriChatRead,{From = id})
	else
		CC.Request("LoadPChatList",{Target=id},function (err,param)
			if self.view.viewDestroy then return end
			if err == 0 then
				CC.ChatManager.DealHisMsg(id,param.Items)
				self.HisPriChat = CC.ChatManager.GetDetailDataByID(id)
				self:CreatePri(param.Items)
				self.view:LoadPChatListSuccess()

				CC.HallNotificationCenter.inst():post(CC.Notifications.PriChatRead,{From = id})
			else
				self.view:LoadPChatListSuccess()
			end
		end)

	end
end

function ChatPanelCtr:CreatePri(param)
	self.view:SetPriPivot(#param)
	if #param <= 10 then
		self.PriIndex = 0
		for i,v in ipairs(param) do
			self.view:DelayRun(0.016*(i-1),function ()
				self.view:FillPriPrefab(v,false)
			end)
		end
	else
		local delay = 0
		self.PriIndex = #param - 5
		for i=self.PriIndex,#param do
			self.view:DelayRun(0.016*delay,function ()
				self.view:FillPriPrefab(param[i],false)
			end)
		end
		delay = delay + 1
	end
end

function ChatPanelCtr:OverPriChat()
	self.PriIndex = self.PriIndex -1
	if self.PriIndex < 0 then return end
	if #self.HisPriChat >= 10 then
		if self.PriIndex - 5 > 0 then
			local delay = 0
			for i = self.PriIndex - 5,self.PriIndex do
				self.view:DelayRun(0.016*delay,function ()
					self.view:FillPriPrefab(self.HisPriChat[i],true)
				end)
				delay = delay + 1
			end
			self.PriIndex = self.PriIndex - 5
		else
			local delay = 0
			for i=1,self.PriIndex do
				self.view:DelayRun(0.016*delay,function ()
					self.view:FillPriPrefab(self.HisPriChat[i],true)
				end)
				delay = delay + 1
			end
			self.PriIndex = 0
		end
	end
end

--缓冲池相关
function ChatPanelCtr:GetChatItem(name,parent)
	if not ChatItemList[name] then
        ChatItemList[name] = {}
    end
    if #ChatItemList[name] > 0 then
		local item = table.remove(ChatItemList[name])
        if not item.activeSelf then
            item:SetActive(true)
        end
		item:SetParent(parent)
		return item
    else
		return CC.uu.LoadHallPrefab("prefab",name,parent)
    end
end

function ChatPanelCtr:RemoveChatItem(name,item)
	item:SetParent(self.view.prefabPool)
	item.localPosition = Vector3(1000,0,0)
	table.insert(ChatItemList[name],item)
end

function ChatPanelCtr:ReqAddFriend(id)
	CC.Request("ReqAddFriend", {FriendId = id})
end

function ChatPanelCtr:OnResqAddFriend(err, data)
	if err == 0 then
		CC.ViewManager.ShowTip(self.view.language.connectfriendReturn)
	end
end

function ChatPanelCtr:Destroy()
	self:UnRegisterEvent();
	self.view = nil;
end

return ChatPanelCtr