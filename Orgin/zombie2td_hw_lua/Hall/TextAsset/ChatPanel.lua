---------------------------------
-- region ChatPanel.lua			-
-- Date: 2019.9.27				-
-- Desc: 聊天					-
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local ChatPanel = CC.uu.ClassView("ChatPanel")

--发送聊天类型
local TABLETYPE = {HALL = 1, SPEAKER = 2}

--私聊玩家列表
local PrivateList = {}

--公共聊天内容列表
local PubContentList = {}

--私人聊天内容列表
local PriContentList = {}

--防诈骗提醒内容列表
local SystemWarnList = {}
--防诈骗警告关键词
local WarnKeyWordList = {}

--系统用户，发言变色列表
local SystemList = 1466700

function ChatPanel:ctor(param)
	self.param = param

	PrivateList = {}
	PubContentList = {}
	PriContentList = {}
	SystemWarnList = {}
	WarnKeyWordList = {}
	--界面是否销毁
	self.viewDestroy = false
end

function ChatPanel:OnCreate()
	self.language = CC.LanguageManager.GetLanguage("L_ChatPanel")
	self.friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend")
	self.GiftDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("GiftData")
	self.switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")
	--用来判断是否拉到顶部
	self.isConentTop = false
	--是否可以发送聊天？（每两次发送之间倒计时，这时候不能发送聊天）
	self.bCanChipChat = true
	--是否可以发送喇叭
	self.bCanHornSend = true
	--缓冲池
	self.prefabPool = self:FindChild("PrefabPool")

	self.viewCtr = self:CreateViewCtr(self.param)

	--私聊
	self.LastPriPlayer = nil

	self.PriLabel = self:FindChild("Layer_Panel/Layer_Pri/Scroller/Label")
	self.PriPanel = self:FindChild("Layer_Panel/Layer_Pri/Panel")
	self.PriScroller = self:FindChild("Layer_Panel/Layer_Pri/Scroller")
	self.PrivatePanel = self:FindChild("Layer_Panel/Layer_Pri")
	self.PriNick = self:SubGet("Layer_Panel/Layer_Pri/Panel/Text/","Text")
	self.ScrollerController = self:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self.viewCtr:InitPrivateItem(tran,dataIndex,cellIndex)
	end)
	self.ScrollerController:AddRycycleAction(function (tran)
		self:RycycleItem(tran)
	end)

	--公共聊天内容父节点
	self.PubContParent = self:FindChild("Layer_Panel/Layer_Pub/ScrollView/ScrollRect/Content")
	--私人聊天内容父节点
	self.PriContParent = self:FindChild("Layer_Panel/Layer_Pri/Panel/ScrollRect/Content")

	self.showHall = CC.LocalGameData.GetHallToggle()
	self.showPrivate = CC.LocalGameData.GetPrivateToggle()

	self:FindChild("Layer_BG/PubBottom/TogNode/Hall"):GetComponent("Toggle").isOn = self.showHall
	self:FindChild("Layer_BG/PubBottom/TogNode/Private"):GetComponent("Toggle").isOn = self.showPrivate

	--私聊,大厅,系统消息3个切换按钮
	self.TableGroup = {}
	self.TableGroup[1] = self:FindChild("Layer_BG/ToggleBG/SysChat/SysChatBtn")
	self.TableGroup[2] = self:FindChild("Layer_BG/ToggleBG/PublicChat/PublicChatBtn")
	self.TableGroup[3] = self:FindChild("Layer_BG/ToggleBG/PrivateChat/PrivateChatBtn")


	--操作面板
	self.BottomGroup = {}
	self.PriBottom = self:FindChild("Layer_BG/PriBottom")
	self.BottomGroup[1] = self:FindChild("Layer_BG/SysBottom")
	self.BottomGroup[2] = self:FindChild("Layer_BG/PubBottom")
	self.BottomGroup[3] = self.PriBottom

	--emoji按钮
	self.PubEmojiBtn = self:SubGet("Layer_BG/PubBottom/Bottom/FaceBtn","Button")
	self.PriEmojiBtn = self:SubGet("Layer_BG/PriBottom/FaceBtn","Button")

	--筹码聊天，私聊发送按钮
	self.SendChipBtn = self:SubGet("Layer_BG/PubBottom/Bottom/SendChipBtn","Button")
	self.SendPrivateBtn = self:SubGet("Layer_BG/PriBottom/PrivateBtn","Button")
	self.SendHornBtn = self:SubGet("Layer_Horn/BG/SendBtn","Button")

	--发送消息按钮上显示的字样，15秒倒计时
	self.SendChipBtnText = self:SubGet("Layer_BG/PubBottom/Bottom/SendChipBtn/Node/Text","Text")
	self.SendHornBtnText = self:SubGet("Layer_Horn/BG/SendBtn/Text","Text")

	--发送按钮Label
	self.SendChipLabel = self:FindChild("Layer_BG/PubBottom/Bottom/SendChipBtn/Node/Label")

	--发送消息输入框
	self.PublicInputFieldText = self:SubGet("Layer_BG/PubBottom/Bottom/InputField","InputField")
	self.PrivateInputFieldText = self:SubGet("Layer_BG/PriBottom/InputField","InputField")
	self.HornInputFieldText = self:SubGet("Layer_Horn/BG/InputField","InputField")

	--消息输入提示语
	self.PublicInputFieldPlaceholder = self:SubGet("Layer_BG/PubBottom/Bottom/InputField/Placeholder","Text")
	self.PrivateInputFieldPlaceholder = self:SubGet("Layer_BG/PriBottom/InputField/Placeholder","Text")
	self.HornInputFieldPlaceholder = self:SubGet("Layer_Horn/BG/InputField/Placeholder","Text")

	self.viewCtr:OnCreate()

	--动态监听输入框字符串
	local publicInput = self:FindChild("Layer_BG/PubBottom/Bottom/InputField")
	UIEvent.AddInputFieldOnValueChange(publicInput, function( str )
		self:OnInputFieldChange(str)
	end)
	local privateInput = self:FindChild("Layer_BG/PriBottom/InputField")
	UIEvent.AddInputFieldOnValueChange(privateInput, function( str )
		self:OnInputFieldChange(str)
	end)
	local hornInput = self:FindChild("Layer_Horn/BG/InputField")
	UIEvent.AddInputFieldOnValueChange(hornInput, function( str )
		self:OnHornInputFieldChange(str)
	end)
	local pubScrollRect = self:FindChild("Layer_Panel/Layer_Pub/ScrollView/ScrollRect")
	UIEvent.AddScrollRectOnValueChange(pubScrollRect,function ()
		--大于1再执行不会导致切换聊天类型的刷新
		if self:FindChild("Layer_Panel/Layer_Pub/ScrollView/ScrollRect"):GetComponent("ScrollRect").verticalNormalizedPosition > 1 then
			if not self.isConentTop then
				self.isConentTop = true
				self.viewCtr:OverFresh()
			end
		else
			self.isConentTop = false
		end
	end)
	local priScrollRect = self:FindChild("Layer_Panel/Layer_Pri/Panel/ScrollRect")
	UIEvent.AddScrollRectOnValueChange(priScrollRect,function ()
		--大于1再执行不会导致切换聊天类型的刷新
		if self:FindChild("Layer_Panel/Layer_Pri/Panel/ScrollRect"):GetComponent("ScrollRect").verticalNormalizedPosition > 1 then
			if not self.isConentTop then
				self.isConentTop = true
				self.viewCtr:OverPriChat()
			end
		else
			self.isConentTop = false
		end
	end)

	--表情输入选择面板
	self.emojiPanel = self:FindChild("Layer_Panel/emojiPanel")
	self.hornEmojiPanel = self:FindChild("Layer_Horn/emojiPanel")
	for i=0,15 do
		local item1 = self.emojiPanel:FindChild(string.format("emojiPanel/emoji%d/Text",i))
		local item2 = self.hornEmojiPanel:FindChild(string.format("emojiPanel/emoji%d/Text",i))
		item1.text = string.upper(string.format("[%x]",i))
		item2.text = string.upper(string.format("[%x]",i))
	end
	--公共聊天背景
	self.PubBackground = self:FindChild("Layer_Panel/Layer_Pub/BG")

	--喇叭输入窗口
	self.hornPanel = self:FindChild("Layer_Horn")

	--防诈骗警告
	self.systemWarnPre = self:FindChild("SystemWarn")
	WarnKeyWordList = self.language.systemWarnKeyWord

	--添加点击事件
	self:AddClickEvent()
	--初始化组件翻译
	self:SetTextByLanguage()
	--初始化玩家信息及聊天设置
	self:InitUserInfo()

	self:FindChild("Layer_Panel/Layer_Pri/AntiFraud/Phone"):SetActive(self.switchDataMgr.GetSwitchStateByKey("OTPVerify"))
end

--动态监听输入框字符串
function ChatPanel:OnInputFieldChange(str)
    if str == nil or str == "" then
		--输入框分公开和私聊
		if CC.ChatManager.GetCurChatType() == CC.ChatConfig.TOGGLETYPE.PUBLIC then
			self.SendChipBtn:SetBtnEnable(false)
			return
		elseif CC.ChatManager.GetCurChatType() == CC.ChatConfig.TOGGLETYPE.PRIVATE then
			self.SendPrivateBtn:SetBtnEnable(false)
			return
		end
    end
    if #str > 0 then
		--输入框分公开和私聊
		if CC.ChatManager.GetCurChatType() == CC.ChatConfig.TOGGLETYPE.PUBLIC then
			self.PublicInputFieldPlaceholder.enabled = false
			if self.bCanChipChat then
				self.SendChipBtn:SetBtnEnable(true)
			end
		elseif CC.ChatManager.GetCurChatType() == CC.ChatConfig.TOGGLETYPE.PRIVATE then
			self.PrivateInputFieldPlaceholder.enabled = false
			self.SendPrivateBtn:SetBtnEnable(true)
		end
    end
end

function ChatPanel:OnHornInputFieldChange(str)
	if not self.bCanHornSend  then return end
	if str == nil or str == "" then
        self.SendHornBtn:SetBtnEnable(false)
		return
    end
    if #str > 0 then
		self.HornInputFieldPlaceholder.enabled = false
        self.SendHornBtn:SetBtnEnable(true)
    end
end

function ChatPanel:AddClickEvent()
	-- 点击空白处，隐藏ChatPanel或者隐藏表情选择面板
	self:AddClick("Layer_Mask",function()
		if self.emojiPanel.activeSelf then
			self.emojiPanel:Hide()
		else
			CC.HallNotificationCenter.inst():post(CC.Notifications.ChatFlash,false)
			self:Destroy()
		end
	end)

	--点击聊天窗口内表情面板外，隐藏表情面板
	self:AddClick("Layer_Panel/emojiPanel/mask",function()
		self.emojiPanel:Hide()
	end)
	--点击空白区域，关闭喇叭表情选择面板
	self:AddClick("Layer_Horn/emojiPanel/mask",function ()
		self.hornEmojiPanel:Hide()
	end)
	--点击打开喇叭窗口
	self:AddClick("Layer_BG/PubBottom/Bottom/HornBtn",function()
		if CC.ViewManager.IsHallScene() then
			self.hornPanel:SetActive(not self.hornPanel.activeSelf)
		else
			CC.ViewManager.ShowTip(self.language.horn_stop)
		end
	end)
	--点击关闭喇叭窗口
	self:AddClick("Layer_Horn/BG/CloseBtn",function()
		self.hornPanel:SetActive(not self.hornPanel.activeSelf)
	end)
	--点击打开表情选择面板的按钮
	self:AddClick("Layer_BG/PubBottom/Bottom/FaceBtn",function() self:OpenFaceUI()  end)
	self:AddClick("Layer_BG/PriBottom/FaceBtn",function() self:OpenFaceUI()  end)
	self:AddClick("Layer_Horn/BG/FaceBtn",function() self:OpenHornFaceUI() end)

	--发送消息按钮
	self:AddClick("Layer_BG/PubBottom/Bottom/SendChipBtn",function() self:SendChatMsg(TABLETYPE.HALL) end)
	self:AddClick("Layer_Horn/BG/SendBtn",function() self:SendChatMsg(TABLETYPE.SPEAKER) end)
	self:AddClick("Layer_BG/PriBottom/PrivateBtn",function () self:SendPrivateMsg() end)

	--大厅，私聊，系统三个按钮切换按钮
	for i = 1,3 do
		self:AddClick(self.TableGroup[i],function(obj) self:ClickTabBtn(obj) end ,"click")
	end

	--私聊界面返回
	self:AddClick("Layer_Panel/Layer_Pri/Panel/Back","ClosePriChat")

	--是否展示大厅聊天
	self:FindChild("Layer_BG/PubBottom/TogNode/Hall").onClick = function()
		self.showHall = self:FindChild("Layer_BG/PubBottom/TogNode/Hall"):GetComponent("Toggle").isOn
		self:ShowHallChat()
		CC.LocalGameData.SetHallToggle(self.showHall)
	end
	self:FindChild("Layer_BG/PubBottom/TogNode/Private").onClick = function()
		self.showPrivate = self:FindChild("Layer_BG/PubBottom/TogNode/Private"):GetComponent("Toggle").isOn
		CC.LocalGameData.SetPrivateToggle(self.showPrivate)
	end

	--防诈骗修改
	self:AddClick("Layer_BG/PubBottom/AntiFraud/Condition/Button",function()
		CC.SubGameInterface.OpenVipBestGiftView({needLevel = 3})
		self:Destroy()
	end)
	self:AddClick("Layer_Panel/Layer_Pri/AntiFraud/Chip/Button",function()
		CC.ViewManager.Open("StoreView")
		self:Destroy()
	end)
	self:AddClick("Layer_Panel/Layer_Pri/AntiFraud/VIP/Button",function()
		CC.SubGameInterface.OpenVipBestGiftView({needLevel = 3})
		self:Destroy()
	end)
	self:AddClick("Layer_Panel/Layer_Pri/AntiFraud/Phone/Button",function()
		CC.ViewManager.Open("BindTelView")
		self:Destroy()
	end)
	--添加好友
	self:AddClick("Layer_Panel/Layer_Pri/Panel/BtnAddFriend",function()
		if self.param then
			local playerId = self.param.PlayerId
			self.viewCtr:ReqAddFriend(playerId)
		end
	end)
end

function ChatPanel:SetTextByLanguage()
	self.TableGroup[1]:FindChild("Label").text = self.language.system
	self.TableGroup[2]:FindChild("Label").text = self.language.public
	self.TableGroup[3]:FindChild("Label").text = self.language.private
	self:FindChild("Layer_Horn/BG/Horn_Tip/Num/").text = "x"..CC.ChatManager.GetChatUseHorn()
	self:FindChild("Layer_Horn/BG/Chip_Tip/Num/").text = "x"..CC.ChatManager.GetChatUseGold()
	self:FindChild("Layer_Horn/BG/Tip").text = self.language.horn_Tip
	self:FindChild("Layer_Horn/BG/Horn_Num").text = self.language.horn_remainder
	self:FindChild("Layer_Horn/BG/SendBtn/Text").text = self.language.privateBtn
	self:FindChild("Layer_Horn/BG/InputField/Placeholder").text = self.language.horn_Placeholder
	self:FindChild("Layer_BG/PubBottom/Bottom/InputField/Placeholder").text = self.language.horn_Placeholder
	self:FindChild("Layer_BG/PubBottom/Bottom/SendChipBtn/Node/Label/Text").text = self.language.privateBtn
	self:FindChild("Layer_BG/SysBottom/BG/Text").text = self.language.label_nochat
	self:FindChild("Layer_BG/PriBottom/PrivateBtn/Text").text = self.language.privateBtn
	self:FindChild("Layer_Panel/Layer_Pri/Scroller/Label").text = self.language.privateLabel
	self:FindChild("Layer_BG/PubBottom/TogNode/Hall/Label").text = self.language.toggle_nohall
	self:FindChild("Layer_BG/PubBottom/TogNode/Private/Label").text = self.language.toggle_noprivate

	self:FindChild("Layer_BG/PubBottom/AntiFraud/Label").text = self.language.condition_label
	self:FindChild("Layer_BG/PubBottom/AntiFraud/Condition/Text").text = self.language.condition_vip
	self:FindChild("Layer_Panel/Layer_Pri/AntiFraud/Label").text = self.language.condition_label
	self:FindChild("Layer_Panel/Layer_Pri/AntiFraud/Chip/Text").text = self.language.condition_chip
	self:FindChild("Layer_Panel/Layer_Pri/AntiFraud/VIP/Text").text = self.language.condition_vip
	self:FindChild("Layer_Panel/Layer_Pri/AntiFraud/Phone/Text").text = self.language.condition_phone
	self:FindChild("PrivateItem/Delete/Text").text = self.language.delete
	self:FindChild("Layer_Panel/Layer_Pri/Panel/BtnAddFriend/Text").text = self.language.BtnAddFriend
	self.systemWarnPre:FindChild("Name").text = self.language.systemWarnName
	self.systemWarnPre:FindChild("Box/msg").text = self.language.systemWarnMsg

end

function ChatPanel:InitUserInfo()
	--初始化玩家信息
	self:RefreshUserInfo()
	if not self.switchDataMgr.GetSwitchStateByKey("ChatFunction") then
		self:FindChild("Layer_BG/ToggleBG/PublicChat"):SetActive(false)
	end
	--初始化选中大厅按钮
	if self.param then
		if self.param.HallPriBtn then
			self:ClickTabBtn(self.TableGroup[3])
		else
			self:OpenPriChat(self.param)
		end
	else
		self:ClickTabBtn(self.TableGroup[2])
	end
	self.PublicInputFieldText.text = ""
	self.PrivateInputFieldText.text = ""
	self.PublicInputFieldPlaceholder.enabled = true
	self.PrivateInputFieldPlaceholder.enabled = true

	local time =  CC.ChatManager.GetDeltaTime()
	if time > 0 then
		self:fnResetFlag(time)
	end
	time  = CC.ChatManager.GetHornDeltaTime()
	if time > 0 then
		self:hornResetFlag(time)
	end
end

function ChatPanel:RefreshUserInfo()
	local strText = self:FindChild("Layer_Horn/BG/Horn_Num/Text"):GetComponent("Text")
	local hornTip = self:FindChild("Layer_Horn/BG/Horn_Tip")
	local chipTip = self:FindChild("Layer_Horn/BG/Chip_Tip")
	local hornNum = CC.Player.Inst():GetSelfInfoByKey("EPC_Speaker")
	strText.text = CC.uu.ChipFormat(hornNum)

	if hornNum > 0 then
		hornTip:SetActive(true)
		chipTip:SetActive(false)
	else
		hornTip:SetActive(false)
		chipTip:SetActive(true)
	end

	if not CC.ChannelMgr.GetTrailStatus() then
		self:SetChatLimit()
	end
end

function ChatPanel:SetChatLimit()
	--公共聊天限制
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < CC.ChatConfig.CHATSETTING.VIPLIMIT then
		self.PublicInputFieldText.enabled = false
		self.PubEmojiBtn:SetBtnEnable(false)
		self.PublicInputFieldPlaceholder.text = self.language.limit_tips
		self:FindChild("Layer_BG/PubBottom/AntiFraud"):SetActive(true)
	else
		self:FindChild("Layer_BG/PubBottom/AntiFraud"):SetActive(false)
	end

	--私聊限制
	self:OnPriChatLimit(self.param)
end

function ChatPanel:ClickTabBtn(obj)
	local _btnName = obj.gameObject.name
	if not self.switchDataMgr.GetSwitchStateByKey("ChatFunction") and _btnName == "PublicChatBtn" then
		_btnName = "SysChatBtn"
	end
	if _btnName == self.hisTabClick then return end
	if _btnName == "SysChatBtn" then
		--系统聊天
		self.TableGroup[1]:GetComponent("Toggle").isOn = true
		self.viewCtr:SetCurChatType(CC.ChatConfig.TOGGLETYPE.SYSTEM)
		self.PubBackground:SetActive(true)
		self.PrivatePanel:SetActive(false)
		self:SetBottomState(1)
		self:ClearPubContent()
		self.viewCtr:ReqHisChatData()
	elseif _btnName == "PublicChatBtn" then
		--大厅聊天
		self.TableGroup[2]:GetComponent("Toggle").isOn = true
		self.viewCtr:SetCurChatType(CC.ChatConfig.TOGGLETYPE.PUBLIC)
		self.PubBackground:SetActive(true)
		self.PrivatePanel:SetActive(false)
		self:SetBottomState(2)
		self:ClearPubContent()
		self.viewCtr:ReqHisChatData()
	else
		--私人聊天
		self.TableGroup[3]:GetComponent("Toggle").isOn = true
		self.viewCtr:SetCurChatType(CC.ChatConfig.TOGGLETYPE.PRIVATE)
		self.PubBackground:SetActive(false)
		self.PrivatePanel:SetActive(true)
		self:ClearPubContent()
		self.viewCtr:ReqPriHisChatData()
		if self.LastPriPlayer then
			self:SetBottomState(3)
		else
			self:SetBottomState(0)
		end
		CC.HallNotificationCenter.inst():post(CC.Notifications.PriChatPush, false)
	end
	--上次点击tabBtn
	self.hisTabClick = _btnName
end

function ChatPanel:SetBottomState(num)
	for i=1,#self.BottomGroup do
		if i == num then
			self.BottomGroup[i]:SetActive(true)
		else
			self.BottomGroup[i]:SetActive(false)
		end
	end
end

--设置头像
function ChatPanel:SetHeadIcon(node,id,portrait,level,headFrame,fun)
	local param = {}
	param.parent = node
	param.playerId = id
	param.portrait = portrait
	param.vipLevel = level
	param.headFrame = headFrame
	param.clickFunc = fun
	return CC.HeadManager.CreateHeadIcon(param)
end

function ChatPanel:OpenFaceUI()
	self.emojiPanel:SetActive(not self.emojiPanel.activeSelf)
	if not self.nInit then
		self.nInit = true
		for i = 1, self.emojiPanel:FindChild("emojiPanel").childCount do
			local _childFace = self.emojiPanel:FindChild("emojiPanel"):GetChild(i - 1)
			self:AddClick(_childFace, function(obj)
				local _text = obj:FindChild("Text")
				local _emoji = _text:GetComponent("Text").text
				local _curText = nil
				--输入框分公开和私聊
				if CC.ChatManager.GetCurChatType() == CC.ChatConfig.TOGGLETYPE.PUBLIC then
					_curText = self.PublicInputFieldText.text
				elseif CC.ChatManager.GetCurChatType() == CC.ChatConfig.TOGGLETYPE.PRIVATE then
					_curText = self.PrivateInputFieldText.text
				end
				local _strLen = CC.uu.StringLen(_emoji, 0)
				local _curLen = CC.uu.StringLen(_curText, 0)
				if _curLen + _strLen > CC.ChatConfig.CHATSETTING.EMOJIMAXLENGTH then
					return
				end
				--输入框分公开和私聊
				if CC.ChatManager.GetCurChatType() == CC.ChatConfig.TOGGLETYPE.PUBLIC then
					self.PublicInputFieldText.text = string.format("%s%s", _curText, _emoji)
					self.PublicInputFieldPlaceholder.enabled = false
				elseif CC.ChatManager.GetCurChatType() == CC.ChatConfig.TOGGLETYPE.PRIVATE then
					self.PrivateInputFieldText.text = string.format("%s%s", _curText, _emoji)
					self.PrivateInputFieldPlaceholder.enabled = false
				end
			end)
		end
	end
end

--喇叭表情
function ChatPanel:OpenHornFaceUI()
	self.hornEmojiPanel:SetActive(not self.hornEmojiPanel.activeSelf)
	if not self.hornInit then
		self.hornInit = true
		for i = 1, self.hornEmojiPanel:FindChild("emojiPanel").childCount do
			local _childFace = self.hornEmojiPanel:FindChild("emojiPanel"):GetChild(i - 1)
			self:AddClick(_childFace, function(obj)
				local _text = obj:FindChild("Text")
				local _emoji = _text:GetComponent("Text").text
				local _curText = nil
				_curText = self.HornInputFieldText.text
				local _strLen = CC.uu.StringLen(_emoji, 0)
				local _curLen = CC.uu.StringLen(_curText, 0)
				if _curLen + _strLen > CC.ChatConfig.CHATSETTING.EMOJIMAXLENGTH then
					return
				end
				self.HornInputFieldText.text = string.format("%s%s", _curText, _emoji)
				self.HornInputFieldPlaceholder.enabled = false
			end)
		end
	end
end

function ChatPanel:SetPivot(count)
	if count >= 6 then
		self.PubContParent.pivot = Vector2(0.5,0)
	else
		self.PubContParent.pivot = Vector2(0.5,1)
	end
end

function ChatPanel:SetPriPivot(count)
	if count >= 6 then
		self.PriContParent.pivot = Vector2(0.5,0)
	else
		self.PriContParent.pivot = Vector2(0.5,1)
	end
end

function ChatPanel:CreateHisChat(resp,isFirst)
	if not resp then return end
	local tData = {}
	tData.Msg = resp.Message
	tData.Who = resp.Who
	tData.MessageType = resp.MessageType
	local tPre = self:CreatePrefab(tData)
	tPre.obj:SetActive(not self.showHall)
	if isFirst then
		tPre.obj:SetAsFirstSibling()
		table.insert(PubContentList,1,tPre)
	else
		table.insert(PubContentList,tPre)
	end
end

function ChatPanel:OnRcvMsg(resp)
	if #PubContentList >= CC.ChatConfig.CHATSETTING.CACHEMSGMAXLEN then
		PubContentList[1].portrait:Destroy(true)
		self.viewCtr:RemoveChatItem(PubContentList[1].preName,PubContentList[1].obj)
		table.remove(PubContentList,1)
	end
	local tData = {}
	tData.Msg = resp.Message
	tData.Who = resp.Who
	tData.MessageType = resp.MessageType
	local tPre = self:CreatePrefab(tData)
	tPre.obj:SetActive(not self.showHall)
	table.insert(PubContentList,tPre)
end

function ChatPanel:CreatePrefab(param)
	local curPrefab = nil
	local parent = self.PubContParent

	local id = param.Who.PlayerId
	local rank = CC.ChatManager.ReturnRankById(id)

	if CC.ChatManager.GetCurChatType() == CC.ChatConfig.TOGGLETYPE.SYSTEM then
		if param.MessageType == CC.ChatConfig.CHATTYPE.REWARDS then
			curPrefab = "RewardMsgPre"
		else
			curPrefab = "OtherPre"
		end
	else
		if id == CC.Player.Inst():GetSelfInfoByKey("Id") then
			if rank > 0 then
				curPrefab = "RankSelfPre"
			else
				curPrefab = "SelfPre"
			end
		else
			if rank > 0 then
				curPrefab = "RankOtherPre"
			else
				curPrefab = "OtherPre"
			end
		end
	end
	if CC.ChatManager.GetCurChatType() == CC.ChatConfig.TOGGLETYPE.PRIVATE then
		parent = self.PriContParent
	end

	local item = self.viewCtr:GetChatItem(curPrefab,parent)
	local tPre = {}
	tPre.preName = curPrefab
	tPre.obj = item
	self:FillPrefab(item,param,tPre)
	return tPre
end

function ChatPanel:FillPrefab(item,param,tPre)
	local oMsg = CC.uu.SubGetObject(item, "Layout/Box/msg","Text")
	local oName = CC.uu.SubGetObject(item, "Layout/Name","Text")
	local portrait = nil
	if CC.ChatManager.GetCurChatType() == CC.ChatConfig.TOGGLETYPE.SYSTEM then
		oMsg.text = param.Msg
		oName.text = self.language.system_name
		portrait = self:SetHeadIcon(item.transform:FindChild("Layout/HeadNode"),0,"999",0,nil,"unClick")

		if param.MessageType == CC.ChatConfig.CHATTYPE.REWARDS then
			local JumpBtn = item.transform:FindChild("Layout/Box/JumpBtn")
			item.transform:FindChild("Layout/Box/Text").text = self.language.goldMedal
			self:AddClick(JumpBtn,function ()
				-- CC.ViewManager.Open("AnniversaryTurntableView")
				self:Destroy()
			end)
		end

	else
		if param.Who.PlayerId == SystemList then
			oMsg.text = "<color=#FFF900>"..CC.uu.ReplaceFace(param.Msg, 55,true).."</color>"
			oName.text = "<color=#FFF900>"..param.Who.Nick.."</color>"
			portrait = self:SetHeadIcon(item.transform:FindChild("Layout/HeadNode"),param.Who.PlayerId,param.Who.Portrait,param.Who.Level,param.Who.Background,"unClick")
		else
			oMsg.text = CC.uu.ReplaceFace(param.Msg,55,true)
			oName.text = param.Who.Nick
			portrait = self:SetHeadIcon(item.transform:FindChild("Layout/HeadNode"),param.Who.PlayerId,param.Who.Portrait,param.Who.Level,param.Who.Background)
		end
		local oHorn = item:FindChild("Layout/Box/horn")
		if param.MessageType == CC.ChatConfig.CHATTYPE.HORN then
			oHorn:SetActive(true)
		else
			oHorn:SetActive(false)
		end
		local longClick = {}
		longClick.funcLongClick = function ()
			local msg = oMsg.text
			self:CopyToClipboard(msg)
		end
		longClick.funcClick = function ()
		end
		self:AddLongClick(oMsg,longClick)
	end
	tPre.portrait = portrait
end

function ChatPanel:ClearPubContent()
	local count = #PubContentList
	for i=1,count do
		PubContentList[i].portrait:Destroy(true)
		self.viewCtr:RemoveChatItem(PubContentList[i].preName,PubContentList[i].obj)
	end
	PubContentList = {}
end

function ChatPanel:ShowHallChat()
	for i,v in ipairs(PubContentList) do
		v.obj:SetActive(not self.showHall)
	end
end

--发送聊天内容
function ChatPanel:SendChatMsg(sendType)
	local _inputValue = nil
	local bCanSend = false
	--VIP校验
	if sendType == TABLETYPE.SPEAKER and CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < CC.ChatConfig.CHATSETTING.HORNVIPLIMIT then
		CC.ViewManager.ShowTip(self.language.send_tip_VIPLimitErr)
		return
	end
	--输入框分公开和私聊
	if sendType == TABLETYPE.HALL then
		_inputValue = self.PublicInputFieldText.text
	elseif sendType == TABLETYPE.SPEAKER then
		_inputValue = self.HornInputFieldText.text
	end

	if sendType == TABLETYPE.HALL then
		if not self.bCanChipChat then
			return
		end
	end
	--如果可以发送
	if _inputValue then
		local _inputStrLen =  string.len(_inputValue)

		--输入内容是否符合格式
		if _inputStrLen <= 0 or _inputStrLen > CC.ChatConfig.CHATSETTING.MSGMAXLENGTH then
			CC.ViewManager.ShowTip(self.language.send_tip_lenErr)
			return
		end

		if sendType == TABLETYPE.HALL then
			bCanSend = true
		else
			if CC.Player.Inst():GetSelfInfoByKey("EPC_Speaker") >=  CC.ChatManager.GetChatUseHorn() then
				bCanSend = true
			elseif CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") >=  CC.ChatManager.GetChatUseGold() then
				bCanSend = true
			else
				bCanSend = false
			end
		end

		local doChat = function ()
			local _chatType = CC.ChatConfig.CHATTYPE.Gold
			if sendType == TABLETYPE.SPEAKER then _chatType = CC.ChatConfig.CHATTYPE.HORN end

			--发送聊天
			local data={}
			data.MessageType=_chatType
			data.Message=_inputValue
			CC.Request("Chat",data,function (err,data)
				--客户端处理界面销毁异常
				if self.viewDestroy then return end
				if sendType == TABLETYPE.HALL then
					self:fnResetFlag()
					CC.ChatManager.ResetLastReqTime()
				else
					self:hornResetFlag()
					CC.ChatManager.ResetLastHornTime()
				end
			end,
			function (err,data)
				if self.viewDestroy then return end
				if sendType == TABLETYPE.HALL then
					self.SendChipBtn:SetBtnEnable(true)
				else
					self.SendHornBtn:SetBtnEnable(true)
				end
			end)
		end
		if sendType == TABLETYPE.HALL and bCanSend then
			self.SendChipBtn:SetBtnEnable(false)
			doChat()
		elseif sendType == TABLETYPE.SPEAKER and bCanSend then
			self.SendHornBtn:SetBtnEnable(false)
			doChat()
		else
			local tips = CC.ViewManager.ShowMessageBox(self.language.send_tip_front ..  CC.ChatManager.GetChatUseGold() .. self.language.send_tip_noCoin,
				function ()
					self.hornPanel:SetActive(not self.hornPanel.activeSelf)
					CC.ViewManager.OpenAndReplace("StoreView")
					self:Destroy()
				end,
				function ()
					self.hornPanel:SetActive(not self.hornPanel.activeSelf)
				end)
			tips:SetOkText(self.language.send_btn_shop)
		end
	else
		CC.ViewManager.ShowTip(self.language.send_tip_fast)
	end
end

--刷新发送消息相关UI，30s倒计时之类
function ChatPanel:fnResetFlag(time)
	local deltaTime = time or CC.ChatConfig.CHATSETTING.INTERVALTIME

	self.emojiPanel:Hide()
	self.bCanChipChat = false
	self.PublicInputFieldText.text = ""
	self.PublicInputFieldPlaceholder.enabled = true
	self.SendChipBtn:SetBtnEnable(false)
	--隐藏花费
	self.SendChipLabel:SetActive(false)
	--显示倒计时
	self.SendChipBtnText:SetActive(true)
	-- 暂停
	self.sendChatTime = deltaTime
	self.SendChipBtnText.text = string.format(self.language.chat_second, self.sendChatTime)

	self:StartTimer("_SendChat", 1, function ()
		self.sendChatTime = self.sendChatTime - 1
		if self.sendChatTime <= 0 then
			self.bCanChipChat = true
			self.SendChipLabel:SetActive(true)
			self.SendChipBtnText:SetActive(false)
			if #self.PublicInputFieldText.text > 0 then
				self.SendChipBtn:SetBtnEnable(true)
			end
		else
			self.SendChipBtnText.text = string.format(self.language.chat_second, self.sendChatTime)
		end
	end, deltaTime)
end

function ChatPanel:hornResetFlag(time)
	local deltaTime = time or CC.ChatConfig.CHATSETTING.HORNINTERVALTIME
	local countDwonTime = deltaTime

	self.bCanHornSend = false
	self.hornPanel:SetActive(false)
	self.SendHornBtn:SetBtnEnable(false)
	self.HornInputFieldText.text = ""

	self:StartTimer("_HornChat",1,function ()
		countDwonTime = countDwonTime -1
		if countDwonTime <= 0 then
			self.bCanHornSend = true
			if #self.HornInputFieldText.text > 0 then
				self.SendHornBtn:SetBtnEnable(true)
			end
			self.SendHornBtnText.text = self.language.privateBtn
		else
			self.SendHornBtnText.text = CC.uu.TicketFormat3(countDwonTime)
		end
	end,deltaTime)
end

--私聊部分
function ChatPanel:InitPrivatePrefab(tran,id)
	--id为私聊对象id
	if PrivateList[id] == nil then
		PrivateList[id] = {}
		PrivateList[id].obj = tran
	else
		PrivateList[id].obj = tran
	end
	tran.name = id
	local oHeadNode = tran:FindChild("DragBG/HeadNode")
	local tMsg = CC.uu.SubGetObject(tran, "DragBG/Text","Text")
	local tName = CC.uu.SubGetObject(tran, "DragBG/MZK","Text")
	local tUnRead = CC.uu.SubGetObject(tran,"DragBG/Tip/Text","Text")
	local oUnRead = tran:FindChild("DragBG/Tip")
	local unReadNum = CC.ChatManager.GetUnReadNum(id)
	local portrait = CC.ChatManager.GetPortrait(id)
	local vip = CC.ChatManager.GetVipLevel(id)
	local headFrame = CC.ChatManager.GetHeadFrame(id)
	tMsg.text = CC.uu.ReplaceFace(CC.ChatManager.GetLastContentByID(id))
	tName.text = CC.uu.ReplaceFace(CC.ChatManager.GetNameByID(id))
	tUnRead.text = unReadNum > 9 and "9+" or unReadNum
	if unReadNum > 0 then
		oUnRead:SetActive(true)
	else
		oUnRead:SetActive(false)
	end
	PrivateList[id].portrait = self:SetHeadIcon(oHeadNode,id,portrait,vip,headFrame)

	local data = {}
	data.PlayerId = id
	data.Nick = CC.ChatManager.GetNameByID(id)
	data.Level = CC.ChatManager.GetVipLevel(id)
	data.Portrait = CC.ChatManager.GetPortrait(id)
	tran.onClick = function ()
		self:OpenPriChat(data)
	end

	tran:FindChild("Delete").onClick = function ()
		self:DeletePriChat(id)
	end

	local drag = tran:FindChild("DragBG")
	local delete = tran:FindChild("Delete")
	local script = tran:GetComponent("DragEx")

	script.func1 = function ()
		self.clickPos = Input.mousePosition.x
		self.itemPos = drag.transform.localPosition
	end

	script.func2 = function ()
		local dragDist = Input.mousePosition.x - self.clickPos
		self.clickPos = Input.mousePosition.x


		local dragPos = drag.transform.localPosition
		local ndragPos = drag.transform.localPosition
		local deletePos = delete.transform.localPosition
		local ndeletePos = delete.transform.localPosition
		ndragPos.x = dragPos.x + dragDist;
		if ndragPos.x <= -143 then
			ndragPos.x = -143
		elseif ndragPos.x >= 0 then
			ndragPos.x = 0
		end

		dragDist = ndragPos.x - dragPos.x
		ndeletePos.x = deletePos.x + dragDist

		drag.transform.localPosition = ndragPos;
		delete.transform.localPosition = ndeletePos
	end

	script.func3 = function ()
		local distance = drag.transform.localPosition.x - self.itemPos.x
		if distance > -55 then
			local pos = drag.transform.localPosition
			local delePos = delete.transform.localPosition
			local action = self:RunAction(drag,{"to", drag.transform.localPosition.x, 0, 0.2,
			function(val)
				pos.x = val
				local temp = drag.transform.localPosition.x - val
				delePos.x = delePos.x - temp
			    drag.transform.localPosition = pos;
			    delete.transform.localPosition = delePos
			end})
		elseif distance <= -55 then
			local pos = drag.transform.localPosition
			local delePos = delete.transform.localPosition
			local action = self:RunAction(drag,{"to", drag.transform.localPosition.x, -143, 0.5,
			function(val)
				pos.x = val
				local temp =  val - drag.transform.localPosition.x
				delePos.x = delePos.x + temp
			    drag.transform.localPosition = pos;
			    delete.transform.localPosition = delePos
			end,ease = CC.Action.EOutBack})
		end
	end
end

--私聊限制
function ChatPanel:OnPriChatLimit(param)
	local bChip = false
	local bVIP = false
	local bPhone = false
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") >= CC.ChatConfig.CHATSETTING.PRIVATELIMIT then
		bChip = true
	end
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= CC.ChatConfig.CHATSETTING.VIPLIMIT then
		bVIP = true
	end
	if CC.Player.Inst():GetSelfInfoByKey("Telephone") and CC.Player.Inst():GetSelfInfoByKey("Telephone") ~= "" then
		bPhone = true
	end
	
	if not self.switchDataMgr.GetSwitchStateByKey("OTPVerify") then
		bPhone = true
	end

	self:FindChild("Layer_Panel/Layer_Pri/AntiFraud/Chip/Image"):SetActive(bChip)
	self:FindChild("Layer_Panel/Layer_Pri/AntiFraud/VIP/Image"):SetActive(bVIP)
	self:FindChild("Layer_Panel/Layer_Pri/AntiFraud/Phone/Image"):SetActive(bPhone)
	self:FindChild("Layer_Panel/Layer_Pri/AntiFraud/Chip/Button"):SetActive(not bChip)
	self:FindChild("Layer_Panel/Layer_Pri/AntiFraud/VIP/Button"):SetActive(not bVIP)
	self:FindChild("Layer_Panel/Layer_Pri/AntiFraud/Phone/Button"):SetActive(not bPhone)

	if param then
		local targetWhiteAccount = self.GiftDataMgr:GetSuperWhiteAccount(param.PlayerId)
		if self.GiftDataMgr:GetSuperWhiteAccount(CC.Player.Inst():GetSelfInfoByKey("Id")) then
			targetWhiteAccount = true
		end
		if targetWhiteAccount then
			bChip, bVIP, bPhone = true, true, true
			if not self.friendDataMgr.IsFriend(param.PlayerId) then
				self:FindChild("Layer_Panel/Layer_Pri/Panel/BtnAddFriend"):SetActive(true)
			end
		else
			self:FindChild("Layer_Panel/Layer_Pri/Panel/BtnAddFriend"):SetActive(false)
		end
	end
	if bChip and bVIP and bPhone then
		self.PrivateInputFieldText.enabled = true
		self.PriEmojiBtn:SetBtnEnable(true)
		self.PrivateInputFieldPlaceholder.text = ""
		self:FindChild("Layer_Panel/Layer_Pri/AntiFraud"):SetActive(false)
	else
		self.PrivateInputFieldText.enabled = false
		self.PriEmojiBtn:SetBtnEnable(false)
		self.PrivateInputFieldPlaceholder.text = self.language.limit_tips
		self:FindChild("Layer_Panel/Layer_Pri/AntiFraud"):SetActive(true)
	end
end

function ChatPanel:OpenPriChat(param)
	self:ClickTabBtn(self.TableGroup[3])
	for i = 1,3 do
		self.TableGroup[i].transform.enabled = false
	end
	self:OnPriChatLimit(param)

	local id = param.PlayerId
	if self.LastPriPlayer then
		self:ClosePriChat()
	end
	self.PrivateInputFieldText.text = ""
	self.SendPrivateBtn:SetBtnEnable(false)
	if PrivateList[id] then
		PrivateList[id].obj:FindChild("DragBG/Tip"):SetActive(false)

		CC.Request("MarkPChatAsReaded",{Target=id},function (err,data)
			if err == 0 then
				logError("标记已读,ID:"..id)
			end
		end)

		CC.ChatManager.SetUnReadNum(id)
	end
	self.LastPriPlayer = CC.ChatManager.GetPlayerInfoByID(id) or param
	self.PriNick.text = CC.ChatManager.GetNameByID(id) or param.Nick
	self.PriBottom:SetActive(true)
	self.PriPanel:SetActive(true)
	self.PriScroller:SetActive(false)
	self.viewCtr:OpenPriChat(id)
end

function ChatPanel:LoadPChatListSuccess()
	self:DelayRun(0.16,function ()
		for i = 1,3 do
			self.TableGroup[i].transform.enabled = true
		end
	end)
end

function ChatPanel:ClosePriChat()
	CC.ChatManager.SetUnReadNum(self.LastPriPlayer.PlayerId)
	self.viewCtr:RefreshPriList()
	self.PriBottom:SetActive(false)
	self.PriPanel:SetActive(false)
	self.PriScroller:SetActive(true)
	self:ClearPriContent()
	self.LastPriPlayer = nil
end

function ChatPanel:DeletePriChat(id)
	CC.ChatManager.DeleteMsg(id)
	self.viewCtr:RefreshPriList()
end

function ChatPanel:FillPriPrefab(resp,isFirst)
	if not self.LastPriPlayer then return end
	local selfId = CC.Player.Inst():GetSelfInfoByKey("Id")
	if resp.From == selfId or resp.From == self.LastPriPlayer.PlayerId then
		local tData = {}
		tData.Msg = resp.Content
		tData.Who = resp.SourcePlayerInfo
		local tPre = self:CreatePrefab(tData)
		if isFirst then
			tPre.obj:SetAsFirstSibling()
			table.insert(PriContentList,1,tPre)
		else
			table.insert(PriContentList,tPre)
		end
		--防诈骗警告
		if resp.From ~= selfId then
			if not self.GiftDataMgr:GetSuperWhiteAccount(resp.From) and not self.GiftDataMgr:GetSuperWhiteAccount(selfId) then
				local find = self:HasWarnKeyWord(resp.Content)
				if find then
					local sysPre = CC.uu.UguiAddChild(self.PriContParent,self.systemWarnPre)
					table.insert(SystemWarnList,sysPre)
				end
			end
		end

		self:SetPriPivot(#PriContentList + #SystemWarnList)

	end
end

function ChatPanel:HasWarnKeyWord(msg)
	for _,v in ipairs(WarnKeyWordList) do
		if string.find(string.lower(msg),string.lower(v)) then
			return true
		end
	end
	return false
end

function ChatPanel:SendPrivateMsg()
	local _inputValue = self.PrivateInputFieldText.text
	local _inputStrLen =  string.len(_inputValue)

	local RecvPlayerData = self.LastPriPlayer
	local RecvPlayerId = RecvPlayerData.PlayerId
	if not (self.GiftDataMgr:GetSuperWhiteAccount(RecvPlayerId)) and CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") < CC.ChatConfig.CHATSETTING.PRIVATELIMIT then
		CC.ViewManager.ShowTip(self.language.send_tip_PriLimitErr)
		return
	end

	if _inputStrLen <= 0 or _inputStrLen > CC.ChatConfig.CHATSETTING.MSGMAXLENGTH then
		CC.ViewManager.ShowTip(self.language.send_tip_lenErr)
		return
	end

    local data={}
    data.Target=RecvPlayerId
    data.Content = _inputValue
    CC.Request("SendPChat",data,function (err,data)
		if self.viewDestroy then return end
		self.emojiPanel:Hide()
		self.PrivateInputFieldText.text = ""
		self.PrivateInputFieldPlaceholder.enabled = true
		local param = {}
		---Who对方玩家信息
		param.Who = {}
		param.Who.PlayerId = RecvPlayerData.PlayerId
		param.Who.Portrait = RecvPlayerData.Portrait
		param.Who.Background = RecvPlayerData.HeadFrame
		param.Who.Nick = RecvPlayerData.Nick
		param.Who.Level = RecvPlayerData.Level
		---NewestChat聊天相关数据
		param.Content = _inputValue
		param.SourcePlayerInfo = {}
		param.SourcePlayerInfo.PlayerId = CC.Player.Inst():GetSelfInfoByKey("Id")
		param.SourcePlayerInfo.Portrait = CC.Player.Inst():GetSelfInfoByKey("Portrait")
		param.SourcePlayerInfo.Nick = CC.Player.Inst():GetSelfInfoByKey("Nick")
		param.SourcePlayerInfo.Level = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
		param.SourcePlayerInfo.Background = CC.Player.Inst():GetSelfInfoByKey("Background")

		param.From = CC.Player.Inst():GetSelfInfoByKey("Id")

		CC.ChatManager.InsertMsg(param)
	end )

end

function ChatPanel:ClearPriContent()
	local count = #PriContentList
	for i=1,count do
		PriContentList[i].portrait:Destroy(true)
		self.viewCtr:RemoveChatItem(PriContentList[i].preName,PriContentList[i].obj)
	end
	for _,v in ipairs(SystemWarnList) do
		if v then
			CC.uu.destroyObject(v)
			v = nil
		end
	end
	PriContentList = {}
	SystemWarnList = {}
end

function ChatPanel:RycycleItem(tran)
	local id = tonumber(tran.name)
	if PrivateList[id].portrait then
		PrivateList[id].portrait:Destroy(true)
	end
end

function ChatPanel:AddLongClick(node, param)
	local funcClick = param.funcClick;
	local funcLongClick = param.funcLongClick;
	local funcDown = param.funcDown;
	local funcUp = param.funcUp;
	local time = param.time or 1;

	self.__longClickCount = self.__longClickCount and self.__longClickCount + 1 or 0;
	local curCount = self.__longClickCount

	node.onDown = function(obj, eventData)
		self.__longClickFlag = false;
		self:StartTimer("CheckLongClick"..curCount,time,function()
			if eventData.pointerCurrentRaycast.gameObject == node.gameObject then
				self.__longClickFlag = true;
				funcLongClick(obj, eventData);
			end
		end)
		if funcDown then
			funcDown(obj,eventData);
		end
	end

	node.onUp = function(obj,eventData)
		if funcUp then
			funcUp(obj,eventData);
		end
		self:StopTimer("CheckLongClick"..curCount);
	end

	node.onClick = function(obj, eventData)

		if not self.__longClickFlag then
			funcClick(obj, eventData);
		end
	end
end

function ChatPanel:CopyToClipboard(msg)
	Util.CopyToClipboard(msg)
	CC.ViewManager.ShowTip(self.language.copy_succ)
  end

function ChatPanel:OnDestroy()
	self.viewDestroy = true
	self:ClearPubContent()
	self:ClearPriContent()
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end

	self.PublicInputFieldText = nil
	self.PrivateInputFieldText = nil
	self.HornInputFieldText = nil
	self.SendChipBtn = nil
	self.SendPrivateBtn = nil
	self.SendHornBtn = nil
	self.PriNick = nil
	self.SendChipBtnText = nil
	self.PublicInputFieldPlaceholder = nil
	self.PrivateInputFieldPlaceholder = nil
	self.HornInputFieldPlaceholder = nil
	self.ScrollerController = nil
end

return ChatPanel