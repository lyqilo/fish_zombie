
local CC = require("CC")

local ChatManager = {}

local lastReqTime = 0

local lastHornTime = 0

local noticeDelay = 15

local isSpeakBordShow = true
local isNoticeBordShow = true
local isLoadHisChatData = false
local isLoadPriHisChatData = false

local _CurChatType = CC.ChatConfig.TOGGLETYPE.PUBLIC

--存储聊天内容
local _CHATCACHEMSGTAB = {
	PUBLIC = {},
	SYS = {}
}

local _HISINFO = {}
local _PRIVATELIST = {}
local _PRIVATEMAP = {}
local _PlayerInfo = {}

local RankList = {}

function ChatManager.SetSpeakBordState( bState )
	isSpeakBordShow = bState
end

function ChatManager.SetNoticeBordState( bState )
	isNoticeBordShow = bState
end

function ChatManager.GetSpeakBordState()
	if CC.ViewManager.IsHallScene() then
		return isSpeakBordShow
	else
		return false
	end
end

function ChatManager.GetNoticeBordState()
	return isNoticeBordShow
end

function ChatManager.ChatPanelToggle()
	return CC.ViewManager.IsSwitchOn("ChatPanel");
end

function ChatManager.ResetLastReqTime()
	lastReqTime = os.time()
end

function ChatManager.ResetLastHornTime()
	lastHornTime = os.time()
end

function ChatManager.GetDeltaTime()
	return  CC.ChatConfig.CHATSETTING.INTERVALTIME - (os.time() - lastReqTime)
end

function ChatManager.GetHornDeltaTime()
	return CC.ChatConfig.CHATSETTING.HORNINTERVALTIME - (os.time() - lastHornTime)
end

--获取2种聊天所有内容
function ChatManager.ChatContents()
	return _CHATCACHEMSGTAB
end

--重置聊天存储的内容
function ChatManager.ResetChatCacheMsgTable()
	_CHATCACHEMSGTAB = { PUBLIC = {}, SYS ={} }
	_HISINFO = {}
	_PRIVATELIST = {}
	_PRIVATEMAP = {}
	_PlayerInfo = {}
end

--大厅发言一次需要多少金币
function ChatManager.GetChatUseGold()
	return 19999
end

--大厅消耗喇叭一次一个
function ChatManager.GetChatUseHorn()
	return 1
end

--大厅拉取历史消息条数
function ChatManager.GetHisInfoNum()
	return 50
end

function ChatManager.SetSendRanks(data)
	for i,v in ipairs(data.Ranks) do
		RankList[i] = v
	end
end

function ChatManager.ReturnRankById(id)
	for i,v in ipairs(RankList) do
		if v == id then
			return i
		end
	end
	return -1
end

function ChatManager.IsLoadHisChatData()
	return isLoadHisChatData
end

function ChatManager.InitCache(data)
	if isLoadHisChatData then return end
	isLoadHisChatData = true
	for i=1,#data do
 		if data[i].Message and #data[i].Message > 0 then
		    if data[i].MessageType == CC.ChatConfig.CHATTYPE.Gold then
		    	if #_CHATCACHEMSGTAB.PUBLIC >= CC.ChatConfig.CHATSETTING.CACHEMSGMAXLEN then
					table.remove(_CHATCACHEMSGTAB.PUBLIC,1)
				end
				table.insert(_CHATCACHEMSGTAB.PUBLIC,data[i])
			elseif data[i].MessageType == CC.ChatConfig.CHATTYPE.HORN then
				if #_CHATCACHEMSGTAB.PUBLIC >= CC.ChatConfig.CHATSETTING.CACHEMSGMAXLEN then
					table.remove(_CHATCACHEMSGTAB.PUBLIC,1)
				end
				table.insert(_CHATCACHEMSGTAB.PUBLIC,data[i])
			elseif
				data[i].MessageType == CC.ChatConfig.CHATTYPE.GAMESYSTEM then
				if #_CHATCACHEMSGTAB.SYS >= CC.ChatConfig.CHATSETTING.CACHEMSGMAXLEN then
					table.remove(_CHATCACHEMSGTAB.SYS,1)
				end
				table.insert(_CHATCACHEMSGTAB.SYS,data[i])
			end
		end
	end
end

--喇叭
function ChatManager.OnRcvSpeakMsg(resp)
	local tip = nil
	if resp.Who.Nick == "" then
		tip = string.format("%s",CC.uu.ReplaceFace(resp.Message,nil,true))
	else
    	tip = string.format("<color=DarkOrange>%s:</color>%s", resp.Who.Nick, CC.uu.ReplaceFace(resp.Message,nil,true))
    end
	CC.ViewManager.UpdateSpeakBoard(tip)

	if #_CHATCACHEMSGTAB.PUBLIC >= CC.ChatConfig.CHATSETTING.CACHEMSGMAXLEN then
		table.remove(_CHATCACHEMSGTAB.PUBLIC,1)
	end
	table.insert(_CHATCACHEMSGTAB.PUBLIC,resp)

	if _CurChatType == CC.ChatConfig.TOGGLETYPE.PUBLIC then
		CC.HallNotificationCenter.inst():post(CC.Notifications.RefreshChat,resp)
	end
end

--世界聊天
function ChatManager.OnRcvWordMsg(resp)
	if #_CHATCACHEMSGTAB.PUBLIC >= CC.ChatConfig.CHATSETTING.CACHEMSGMAXLEN then
		table.remove(_CHATCACHEMSGTAB.PUBLIC,1)
	end
	table.insert(_CHATCACHEMSGTAB.PUBLIC,resp)

	if _CurChatType == CC.ChatConfig.TOGGLETYPE.PUBLIC then
		CC.HallNotificationCenter.inst():post(CC.Notifications.RefreshChat,resp)
	end
end

--系统消息
function ChatManager.OnRcvSystemMsg(resp)
	CC.ViewManager.UpdateNoticeBord(resp)
	CC.HallNotificationCenter.inst():post(CC.Notifications.SubRcvSystemMsg,resp)

	if #_CHATCACHEMSGTAB.SYS >= CC.ChatConfig.CHATSETTING.CACHEMSGMAXLEN then
		table.remove(_CHATCACHEMSGTAB.SYS,1)
	end
	table.insert(_CHATCACHEMSGTAB.SYS,resp)

	if _CurChatType == CC.ChatConfig.TOGGLETYPE.SYSTEM then
		CC.HallNotificationCenter.inst():post(CC.Notifications.RefreshChat,resp)
	end
end

--大奖消息（目前是客户端直接调用，不是服务器返回）
function ChatManager.OnRcvRewardMsg(resp)
	if #_CHATCACHEMSGTAB.SYS >= CC.ChatConfig.CHATSETTING.CACHEMSGMAXLEN then
		table.remove(_CHATCACHEMSGTAB.SYS,1)
	end
	table.insert(_CHATCACHEMSGTAB.SYS,resp)

	if _CurChatType == CC.ChatConfig.TOGGLETYPE.SYSTEM then
		CC.HallNotificationCenter.inst():post(CC.Notifications.RefreshChat,resp)
	end
end

--游戏消息
function ChatManager.OnGameSystemMsg(resp)
	CC.uu.DelayRun(noticeDelay,function()
		CC.ViewManager.UpdateNoticeBord(resp)
		CC.HallNotificationCenter.inst():post(CC.Notifications.SubRcvSystemMsg,resp)

		if #_CHATCACHEMSGTAB.SYS >= CC.ChatConfig.CHATSETTING.CACHEMSGMAXLEN then
			table.remove(_CHATCACHEMSGTAB.SYS,1)
		end
		table.insert(_CHATCACHEMSGTAB.SYS,resp)

		if _CurChatType == CC.ChatConfig.TOGGLETYPE.SYSTEM then
			CC.HallNotificationCenter.inst():post(CC.Notifications.RefreshChat,resp)
		end
	end)
end

--私聊
function ChatManager.OnRcvPriChat(resp)
	if not _PRIVATEMAP then return end
	local id = resp.From
	local index = tostring(resp.From)
	if ChatManager.ReturnPrivatePos(id) then
		if not _PRIVATEMAP[index] then
			_HISINFO[index].UnreadCount = _HISINFO[index].UnreadCount + 1
			_HISINFO[index].NewestChat.Content = resp.Content
			table.remove(_PRIVATELIST,ChatManager.ReturnPrivatePos(id))
			table.insert(_PRIVATELIST,1,id)
		else
			table.remove(_PRIVATELIST,ChatManager.ReturnPrivatePos(id))
			table.insert(_PRIVATELIST,1,id)
			table.insert(_PRIVATEMAP[index],resp)
			_PRIVATEMAP[index].unRead = _PRIVATEMAP[index].unRead + 1
			if #_PRIVATEMAP[index] >= 50 then
				table.remove(_PRIVATEMAP[index],1)
			end
		end
	else
		if not _PRIVATEMAP[index] then
			table.insert(_PRIVATELIST,1,id)
			_PlayerInfo[index] = resp.SourcePlayerInfo
			_PRIVATEMAP[index] = {}
			table.insert(_PRIVATEMAP[index],resp)
			_PRIVATEMAP[index].unRead = 1
		else
			table.remove(_PRIVATELIST,ChatManager.ReturnPrivatePos(id))
			table.insert(_PRIVATELIST,1,id)
			table.insert(_PRIVATEMAP[index],resp)
			_PRIVATEMAP[index].unRead = _PRIVATEMAP[index].unRead + 1
		end
		if #_PRIVATEMAP[index] >= 50 then
			table.remove(_PRIVATEMAP[index],1)
		end
	end

	local chatPanel = CC.ViewManager.GetChatPanel()
	if chatPanel and chatPanel.LastPriPlayer and chatPanel.LastPriPlayer.PlayerId == id then
		ChatManager.SetUnReadNum(id)
	end

	CC.HallNotificationCenter.inst():post(CC.Notifications.PriChat,resp)
end

function ChatManager.ReturnPrivatePos(id)
	for i=1,#_PRIVATELIST do
		if _PRIVATELIST[i] == id then
			return i
		end
	end
	return nil
end

function ChatManager.DealHisMsg(id,data)
	local index = tostring(id)
	for i=1,#data do
		if not _PRIVATEMAP[index] then
			_PRIVATEMAP[index] = {}
			_PRIVATEMAP[index].unRead = 0
			table.insert(_PRIVATEMAP[index],data[i])
		else
			table.insert(_PRIVATEMAP[index],data[i])
		end
		if #_PRIVATEMAP[index] >= 50 then
			table.remove(_PRIVATEMAP[index],1)
		end
	end
end

function ChatManager.InsertMsg(resp)
	local id = resp.Who.PlayerId
	local index = tostring(resp.Who.PlayerId)
	if not ChatManager.ReturnPrivatePos(id) then
		table.insert(_PRIVATELIST,1,id)
		_PlayerInfo[index] = resp.Who
		_PRIVATEMAP[index] = {}
		_PRIVATEMAP[index].unRead = 0
		table.insert(_PRIVATEMAP[index],resp)
	else
		table.remove(_PRIVATELIST,ChatManager.ReturnPrivatePos(id))
		table.insert(_PRIVATELIST,1,id)
		table.insert(_PRIVATEMAP[index],resp)
		if #_PRIVATEMAP[index] >= 50 then
			table.remove(_PRIVATEMAP[index],1)
		end
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.PriChat,resp)
end

---拉取最后一条信息
function ChatManager.GetLastContentByID(id)
	local index = tostring(id)
	if _PRIVATEMAP[index] then
		local lastIndex = #_PRIVATEMAP[index]
		return _PRIVATEMAP[index][lastIndex].Content
	elseif _HISINFO[index] then
		return _HISINFO[index].NewestChat.Content
	else
		return ""
	end
end
--拉取玩家姓名
function ChatManager.GetNameByID(id)
	local index = tostring(id)
	if _PlayerInfo[index] ~= nil then
		return _PlayerInfo[index].Nick
	end
end
--拉取玩家头像ID
function ChatManager.GetPortrait(id)
	local index = tostring(id)
	if _PlayerInfo[index] ~= nil then
		return _PlayerInfo[index].Portrait
	end
end
--拉取玩家VIP等级
function ChatManager.GetVipLevel(id)
	local index = tostring(id)
	if _PlayerInfo[index] ~= nil then
		return _PlayerInfo[index].Level
	end
end
--拉取玩家头像框
function ChatManager.GetHeadFrame(id)
	local index = tostring(id)
	if _PlayerInfo[index] ~= nil then
		return _PlayerInfo[index].Background
	end
end

function ChatManager.GetPlayerInfoByID(id)
	local index = tostring(id)
	if _PlayerInfo[index] ~= nil then
		return _PlayerInfo[index]
	end
end

--拉取未读消息条数
function ChatManager.GetUnReadNum(id)
	local index = tostring(id)
	if _PRIVATEMAP[index]then
		return _PRIVATEMAP[index].unRead
	elseif _HISINFO[index] then
		return _HISINFO[index].UnreadCount
	else
		return 0
	end
end

--设置未读消息条数
function ChatManager.SetUnReadNum(id)
	local index = tostring(id)
	if _PRIVATEMAP[index]then
		_PRIVATEMAP[index].unRead = 0
	end
end

--拉取ID玩家所有消息
function ChatManager.GetDetailDataByID(id)
	local index = tostring(id)
	if _PRIVATEMAP[index] then
		return _PRIVATEMAP[index]
	else
		return nil
	end
end

function ChatManager.GetPrivateList()
	return _PRIVATELIST
end

function ChatManager.DeleteMsg(id)
	local index = tostring(id)
	for i=1,#_PRIVATELIST do
		if id == _PRIVATELIST[i] then
			table.remove(_PRIVATELIST,i)
			CC.Request("DelPChat",{Target=id},function (err,data)end)
			break
		end
	end
	_PRIVATEMAP[index] = nil
end

function ChatManager.IsLoadPriHisChatData()
	return isLoadPriHisChatData
end

function ChatManager.ResetPrivateState()
	isLoadPriHisChatData = false
end

function ChatManager.InitPrivateList(data)
	if isLoadPriHisChatData then return end
	isLoadPriHisChatData = true
	if #data.Items == 0 then
		-- CC.ViewManager.InitHisMsgFinish()
	else
		for i=1,#data.Items do
			if _HISINFO[tostring(data.Items[i].Who.PlayerId)] == nil then
				table.insert(_PRIVATELIST,1,data.Items[i].Who.PlayerId)
				_PlayerInfo[tostring(data.Items[i].Who.PlayerId)] = data.Items[i].Who
				_HISINFO[tostring(data.Items[i].Who.PlayerId)] = {}
				_HISINFO[tostring(data.Items[i].Who.PlayerId)].NewestChat = data.Items[i].NewestChat
				_HISINFO[tostring(data.Items[i].Who.PlayerId)].UnreadCount = data.Items[i].UnreadCount
			end
			if i == #data.Items then
				-- CC.ViewManager.InitHisMsgFinish()
			end
		end
	end
end

function ChatManager.SetCurChatType(type)
	_CurChatType = type
end

function ChatManager.GetCurChatType()
	return _CurChatType
end

function ChatManager.GetChatInfo()
	if _CurChatType == CC.ChatConfig.TOGGLETYPE.PUBLIC then
		return _CHATCACHEMSGTAB.PUBLIC
	elseif _CurChatType == CC.ChatConfig.TOGGLETYPE.SYSTEM then
		return _CHATCACHEMSGTAB.SYS
	else
	end
end

function ChatManager.GetLastPublicChatInfo()
	if #_CHATCACHEMSGTAB.PUBLIC > 0 then
		return _CHATCACHEMSGTAB.PUBLIC[#_CHATCACHEMSGTAB.PUBLIC];
	end
end

return ChatManager