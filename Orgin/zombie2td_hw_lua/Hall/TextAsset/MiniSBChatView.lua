local CC = require("CC")
local GC = require("GC")
local MiniSBChatView = CC.uu.ClassView("MiniSBChatView")
local MiniSBNotification = require("View/MiniSBView/MiniSBNetwork/MiniSBNotification")
local Request = require("View/MiniSBView/MiniSBNetwork/Request")
local proto = require("View/MiniSBView/MiniSBNetwork/game_pb")
local MNSBConfig = require("View/MiniSBView/MiniSBConfig")

local onMsg
local query
local initView
local startChatTimer

local INPUT_LIMIT = 50 --输入文字最多50个字符
-- 发消息定时器
local SEND_TIMER = "SEND_TIMER"
local MY_MSG_COLOR = "<color=#faba30>%s</color>"
local OTHER_MSG_COLOR = "<color=#e5d6c1>%s</color>"

local PLAYER_CHAT_MSG = "PlayerChatMsg"

--公共聊天内容列表
local ContParent = {}

local chatItemList = {}

local START_X = 300

local Moving  -- 是否action in

function MiniSBChatView:ctor(param)
	self.mainView = param.mainView
	Moving = false
	ContParent = {}
	chatItemList = {}
end

function MiniSBChatView:OnCreate()
	self.sendTime = 0 --发送消息倒计时 为0才能发送消息
	initView(self)
	query(self)
	self:changeInputFieldPlaceholder()
	self:registerEvent()
end

function MiniSBChatView:registerEvent()
	MiniSBNotification.GameRegister(self, PLAYER_CHAT_MSG, onMsg)
end

function MiniSBChatView:unRegisterEvent()
	MiniSBNotification.GameUnregisterAll(self)
end

-- ************************************************************
-- ActionIn 正常打开动作
-- ************************************************************
function MiniSBChatView:ActionIn()
	-- 记录位置，要在这里记录位置，不能在OnCreate，因为涉及到缩小界面，位置会变化，OnCreate记录界面会导致缩小时，节点位置没适配
	local node = self:FindChild("Node")
	if not self.basePos then
		self.basePos = node.transform.localPosition
	end

	-- 首次打开
	if self.mainView.firstTimesOpenChatView then
		self.mainView.firstTimesOpenChatView = false
		log("firstTimesOpenChatView")
		return
	end
	-- 如果是runAction中，则不能点击关闭
	if Moving then
		log("Moving")
		return
	end
	self:setMoveing(true)

	local window = CC.MiniGameMgr.GetCurWindowMode()
	-- 窗口下空白按钮显示
	if window then
		self.blockBtn:SetActive(true)
	end

	-- 设置位置到左边
	node.localPosition = Vector3(self.basePos.x + START_X, self.basePos.y, 0)
	-- 移动回来
	self:RunAction(
		node,
		{
			"localMoveTo",
			self.basePos.x,
			self.basePos.y,
			0.15,
			ease = CC.Action.ELinear,
			function()
				self:setMoveing(false)
			end
		}
	)
end

-- ************************************************************
-- ActionOut 正常关闭动作
-- ************************************************************
function MiniSBChatView:ActionOut()
	if Moving then
		return
	end

	self:setMoveing(true)
	local node = self:FindChild("Node")
	self:RunAction(
		node,
		{
			"localMoveTo",
			self.basePos.x + START_X,
			self.basePos.y,
			0.15,
			ease = CC.Action.ELinear,
			function()
				self:setMoveing(false)
				self:Destroy()
			end
		}
	)
end

-- ************************************************************
-- setMoveing 设置状态
-- @moving : 是否移动中
-- ************************************************************
function MiniSBChatView:setMoveing(moving)
	Moving = moving
	self:SetCanClick(not moving)
end

-- ************************************************************
-- hideBlockBtn 隐藏空白按钮
-- ************************************************************
function MiniSBChatView:hideBlockBtn()
	self.blockBtn:SetActive(false)
end

function MiniSBChatView:changeInputFieldPlaceholder()
	if self.sendTime == 0 then
		local language = self.mainView.language
		self.InputField.enabled = true
		self.placeholderText.text = language.Placeholder
	else
		self.InputField.enabled = false
		self.placeholderText.text = self.sendTime .. "s..."
	end
end

function MiniSBChatView:refresh(sCLoadMsgChatRsp)
	self.InitChatInfo = sCLoadMsgChatRsp.msgs
	self.InitIndex = 0
	local count = #self.InitChatInfo

	for i = 1, #self.InitChatInfo do
		local info = self.InitChatInfo[i]
		self:createHisChat(info, false)
	end

	self:DelayRun(
		0.3,
		function()
			self:FindChild("Node/ScrollRect"):GetComponent("ScrollRect").verticalNormalizedPosition = 0
		end
	)
end

function MiniSBChatView:createHisChat(resp, isFirst)
	local item = self:getChatItem("SelfPre", self.pubContParent)

	local tPre = {}
	tPre.preName = "SelfPre"
	tPre.obj = item

	self:initItem(item, resp)

	table.insert(ContParent, tPre)
end

function MiniSBChatView:initItem(tran, data)
	local oMsg = tran:GetComponent("Text")

	local dataStr = Json.decode(data.msg.data)
	local text = data.playerInfo.nick .. " : "
	local msg

	local taken = GC.Player.Inst():GetLoginInfo()
	if data.playerInfo.playerID == taken.PlayerId then
		msg = string.format(MY_MSG_COLOR, dataStr.msg)
	else
		msg = string.format(OTHER_MSG_COLOR, dataStr.msg)
	end

	text = text .. msg
	oMsg.text = text
end

function MiniSBChatView:OnDestroy()
	self:StopTimer(SEND_TIMER)
	self.mainView.chatView = nil
	self:unRegisterEvent()
	self:CancelAllDelayRun()
end

function MiniSBChatView:queryChatHistory()
	query(self)
end

--缓冲池相关
function MiniSBChatView:getChatItem(name, parent)
	if not chatItemList[name] then
		chatItemList[name] = {}
	end
	if #chatItemList[name] > 0 then
		local item = table.remove(chatItemList[name])
		if not item.activeSelf then
			item:SetActive(true)
		end
		item:SetParent(parent)
		return item
	else
		return CC.uu.UguiAddChild(self.pubContParent, self.item)
	end
end

function MiniSBChatView:RemoveChatItem(name, item)
	if item then
		item.localPosition = Vector3(1000, 0, 0)
		table.insert(chatItemList[name], item)
		item:SetParent(self.prefabPool)
	end
end

-- 收到信息
onMsg = function(self, msgChat)
	if #ContParent >= 20 then
		self:RemoveChatItem(ContParent[1].preName, ContParent[1].obj)
		table.remove(ContParent, 1)
	end

	local item = self:getChatItem("SelfPre", self.pubContParent)
	local tPre = {}
	tPre.preName = "SelfPre"
	tPre.obj = item
	self:initItem(item, msgChat)
	table.insert(ContParent, tPre)

	self:DelayRun(
		0.3,
		function()
			self:FindChild("Node/ScrollRect"):GetComponent("ScrollRect").verticalNormalizedPosition = 0
		end
	)
end

-- 请求
query = function(self)
	if self.mainView.firstTimesOpenChatView then
		return
	end

	local cb = function(err, sCLoadMsgChatRsp)
		if err == 0 then
			self:refresh(sCLoadMsgChatRsp)
		end
	end
	Request.LoadMsgChat(0, 10, cb)
end

-- 长度
local function utf8len(input)
	local len = string.len(input)
	local left = len
	local cnt = 0
	local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	while left ~= 0 do
		local tmp = string.byte(input, -left)

		local i = #arr
		while arr[i] do
			if tmp >= arr[i] then
				left = left - i
				break
			end
			i = i - 1
		end
		cnt = cnt + 1
	end
	return cnt
end

-- 排除都是空格
local function allSpace(input)
	local len = string.len(input)
	local allSpace = true
	for i = 1, len do
		local tmp = string.byte(input, i)
		-- 排除都是空格
		if tmp ~= 32 then
			allSpace = false
			return allSpace
		end
	end
	return allSpace
end

initView = function(self)
	self.isConentTop = false
	self.blockBtn = self:FindChild("BlockBtn")
	self.blockBtn:SetActive(false)
	self.InputField = self:FindChild("Node/InputField"):GetComponent("InputField")
	self.InputField.characterLimit = 0
	self.placeholderText = self:SubGet("Node/InputField/Placeholder", "Text")

	self.pubContParent = self:FindChild("Node/ScrollRect/Content")
	self.item = self:FindChild("Node/ChatItem")
	self.prefabPool = self:FindChild("Node/PrefabPool")

	self:AddClick(
		"Node/Close",
		function()
			self:ActionOut()
		end
	)
	self:AddClick(
		"BlockBtn",
		function()
			self:ActionOut()
		end
	)

	self:AddClick(
		"Node/Send",
		function()
			local cb = function(err)
				if err == 0 then
					self.InputField.text = ""
				end
			end
			if self.sendTime == 0 then
				local text = self.InputField.text
				if not allSpace(text) and utf8len(text) > 0 then
					if utf8len(text) <= INPUT_LIMIT then
						Request.SendMsgChat(text, cb)
						startChatTimer(self)
					else
						local errStr = MNSBConfig.LOCAL_CHAT[MNSBConfig.GameLanguage]["MessageLimit"]
						CC.ViewManager.ShowTip(errStr)
					end
				else
					local errStr = MNSBConfig.LOCAL_CHAT[MNSBConfig.GameLanguage]["EmptyMessage"]
					CC.ViewManager.ShowTip(errStr)
				end
			end
		end
	)
end

startChatTimer = function(self)
	self.sendTime = 3
	self:changeInputFieldPlaceholder()
	self:StopTimer(SEND_TIMER)
	self:StartTimer(
		SEND_TIMER,
		1,
		function()
			if self.sendTime >= 1 then
				self.sendTime = self.sendTime - 1
			else
				self:StopTimer(SEND_TIMER)
			end
			self:changeInputFieldPlaceholder()
		end,
		-1
	)
end

return MiniSBChatView
