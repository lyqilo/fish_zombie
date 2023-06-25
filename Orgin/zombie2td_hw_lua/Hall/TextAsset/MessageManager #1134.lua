-- MessageName 消息名称
-- MessageType 消息种类：1自动 2点击 3自动&点击 4竞技场广告 5大厅广告
-- MessageUseType 消息类型：1购买验证 2新游跳转 3功能跳转 4无跳转
-- IsShow 是否位于消息框：1是 0否
-- ShowTimeOut 消息框内驻留时间（小时）：-1永久 0关闭消失 其余数字小时数
-- IconAddress 贴图路径
-- State 消息状态：1开启 0关闭

local CC = require("CC")
local MessageManager = {}

local _messageDataMap = {} --消息信息汇总
local _iconCache = {} --缓存的图片
local _adverFinish = {} --缓存完成的广告
local _popFinish = {} --自动弹出广告
local _arenaFinish = {} --竞技场广告
local _hallFinish = {} --大厅广告
local _downloadImageList = {}

local _cdnUrl = nil

function MessageManager.ReqInfo()
	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetADUrl()
	local doReq = nil
	doReq = function()
		local www =
			CC.HttpMgr.Get(
			url,
			function(www)
				local json = Json.decode(www.downloadHandler.text)
				log(CC.uu.Dump(json, "MessageInfo:", 10))

				--先给所有广告按 MessageType 和 LID 排序
				if #json.data > 1 then
					table.sort(
						json.data,
						function(a, b)
							if tonumber(a.MessageContent.MessageType) == tonumber(b.MessageContent.MessageType) then
								return tonumber(a.LID) < tonumber(b.LID)
							else
								return tonumber(a.MessageContent.MessageType) < tonumber(b.MessageContent.MessageType)
							end
						end
					)
				end

				for i = 1, #json.data do
					local content = json.data[i].MessageContent
					local LID = json.data[i].LID
					local MessageType = content.MessageType
					local index = MessageType .. LID
					if not _messageDataMap[index] then
						_messageDataMap[index] = {}
						_messageDataMap[index].MessageType = content.MessageType
						_messageDataMap[index].MessageUseType = content.MessageUseType
						_messageDataMap[index].ExtensionID = content.ExtensionID
						_messageDataMap[index].CurrentView = content.CurrentView
						_messageDataMap[index].IconAddress = json.data[i].Icon
						_messageDataMap[index].VIPLevel = json.data[i].VIPLeve
						_messageDataMap[index].MessageName = json.data[i].MessageName
						if content.MessageType == "4" then
							MessageManager.DownloadIcon(index, _messageDataMap[index].IconAddress, "Arena")
						else
							MessageManager.DownloadIcon(index, _messageDataMap[index].IconAddress)
						end
					end
				end
				MessageManager.DeleteInvalidImage("MessageImages")
			end,
			function()
			end
		)
	end
	doReq()
end

function MessageManager.DownloadIcon(index, icon, mesType)
	--没有新字段直接return
	if not icon then
		return
	end
	local weburl = icon
	local _start, _end = string.find(weburl, "Res")
	_cdnUrl = _cdnUrl or string.sub(weburl, 1, _end + 1)
	local LocalPath = string.sub(weburl, _start)
	local imgName = LocalPath:split("/")[3]
	table.insert(_downloadImageList, imgName)
	if Util.HasFile(Util.userPath .. LocalPath) then
		MessageManager.IconDownloadComplete(index)
	else
		local time = os.clock()
		CC.HttpMgr.Get(
			weburl,
			function(www)
				-- if mesType == "Arena" then
				-- 	--logError("文件路径："..weburl.."  耗时："..math.floor((os.clock()-time)*1000).."ms")
				-- 	CC.FirebasePlugin.TrackHttpReqTime("RES", math.floor((os.clock()-time)*1000))
				-- end
				CC.UserData.WriteBytes(LocalPath, www.downloadHandler.data)
				MessageManager.IconDownloadComplete(index)
			end
		)
	end
end

function MessageManager.IconDownloadComplete(index)
	if _messageDataMap[index].MessageType == "2" then
		table.insert(_adverFinish, index)
	elseif _messageDataMap[index].MessageType == "3" then
		table.insert(_adverFinish, index)
		table.insert(_popFinish, index)
	elseif _messageDataMap[index].MessageType == "4" then
		table.insert(_arenaFinish, index)
	elseif _messageDataMap[index].MessageType == "5" then
		table.insert(_hallFinish, index)
	end
end

function MessageManager.DeleteInvalidImage(path)
	local localAllFile = Util.GetAllFileNameWithExtension(Util.userPath .. "Res/" .. path, "*png")
	if not localAllFile then
		return
	end
	for i, localName in ipairs(localAllFile:ToTable()) do
		local delete = true
		for j, v in ipairs(_downloadImageList) do
			if localName == v then
				delete = false
				break
			end
		end
		if delete then
			Util.RemoveFile(Util.userPath .. "Res/" .. path .. "/" .. localName)
		end
	end
end

function MessageManager.GetADInfoWithID(index)
	return _messageDataMap[index]
end

function MessageManager.GetList(MessageType)
	local list = {}
	if MessageType == 2 then
		list = _adverFinish
	elseif MessageType == 3 then
		list = _popFinish
	elseif MessageType == 4 then
		list = _arenaFinish
	elseif MessageType == 5 then
		list = _hallFinish
	end
	local tmpTab = {}
	for _, v in pairs(list) do
		local VIPLevel = MessageManager.GetADInfoWithID(v).VIPLevel or 0
		local MessageUseType = MessageManager.GetADInfoWithID(v).MessageUseType or "0"
		if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= VIPLevel then
			if MessageUseType == "9" then
				if CC.Player.Inst():GetSelfInfoByKey("EPC_Anni_Avator_Box") <= 0 then
					table.insert(tmpTab, v)
				end
			else
				table.insert(tmpTab, v)
			end
		end
	end
	return tmpTab
end

function MessageManager.GetAdvertiseList()
	return MessageManager.GetPopupList()
end

function MessageManager.GetPopupList()
	return MessageManager.GetList(3)
end

function MessageManager.GetUnreadPouupIndex()
	local len = #(MessageManager.GetPopupList())
	local readIndex = CC.LocalGameData.GetPopupState():split(":") or {}
	for i = 1, len do
		local b = false
		for j = 1, #readIndex do
			if readIndex[j] == tostring(i) then
				b = true
			end
		end

		if not b then
			return i
		end
	end
	return false
end

function MessageManager.IsReadByIndex(index)
	local readIndex = CC.LocalGameData.GetPopupState():split(":") or {}

	for i = 1, #readIndex do
		if readIndex[i] == tostring(index) then
			return true
		end
	end
	return false
end

function MessageManager.GetArenaADList()
	return MessageManager.GetList(4)
end

function MessageManager.GetHallADList()
	if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel") then
		return MessageManager.GetList(5)
	else
		return {}
	end
end

function MessageManager.GetIconWithID(index)
	return _iconCache[index]
end

function MessageManager.ReadLocalAsset(param)
	local id = param.id
	local cb = param.callback
	local isHall = param.isHall
	local LocalPath = MessageManager.GetADInfoWithID(id).IconAddress
	if string.find(LocalPath, "http") then
		local _index = string.find(LocalPath, "Res")
		LocalPath = string.sub(LocalPath, _index)
	else
		LocalPath = MessageManager.GetADInfoWithID(id).IconAddress:ltrim("/")
	end
	local bytes = Util.ReadBytes(Util.userPath .. LocalPath)
	local texture2D =
		isHall and Texture2D(272, 412, UnityEngine.TextureFormat.RGBA32, false) or
		Texture2D(940, 544, UnityEngine.TextureFormat.RGBA32, false)
	UnityEngine.ImageConversion.LoadImage(texture2D, bytes)
	_iconCache[id] = texture2D
	if cb then
		cb()
	end
end

function MessageManager.GetCDNUrlPrefix()
	return _cdnUrl
end

function MessageManager.ClearCache()
	for k, v in pairs(_iconCache) do
		GameObject.Destroy(v)
		_iconCache[k] = nil
	end
end

return MessageManager
