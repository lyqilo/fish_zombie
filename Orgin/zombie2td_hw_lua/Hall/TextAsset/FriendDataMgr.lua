local CC = require("CC")
local FriendDataMgr = {}

local FriendsMsg = {}	--好友列表
local ApplyFriendsMsg = {}	--好友申请列表
local ListMsg = {}
local RecommandedGuy = {}
local FriendIndex = 1
local ApplyFriendIndex = 1
local FriendTotal  = 0
local ApplyFriendsTotal  = 0

local InitFriendsList = false
local InitApplyList = false

--在线好友排序
function FriendDataMgr.SortFriendList()
	local OnLineTab = {}
	local OffLineTab = {}
	local Temptab = {}

	if not RecommandedGuy.Guies then return end

	for i,v in ipairs(RecommandedGuy.Guies) do
		if i <= 2 then
			if FriendDataMgr.IsFriend(v.Player.PlayerId) then
				--在线的币商好友
				table.insert(OnLineTab,v.Player.PlayerId)
			else
				--不在线的币商好友
				table.insert(OffLineTab,v.Player.PlayerId)
			end
		end		
	end

	for i,v in ipairs(ListMsg) do
		if v.Online then
			--在线好友
			table.insert(Temptab,1,v)
		else
			--不在线好友
			table.insert(Temptab,table.length(Temptab)+ 1,v)
		end
	end

	ListMsg = {}
	local ISAddId = 0
	--在线的
	for i,v in ipairs(Temptab) do
		for key,value in ipairs(OnLineTab) do
			if OnLineTab[key] == v.PlayerId and v.Online == true then
				--在线好友
				table.insert(ListMsg,1,v)
				ISAddId = v.PlayerId
			end			
		end

		if v.Online == true and ISAddId ~= v.PlayerId then
			table.insert(ListMsg,table.length(ListMsg)+ 1,v)
		end
	end
	--不在线的
	for i,v in ipairs(Temptab) do
		if v.Online == false then
			table.insert(ListMsg,table.length(ListMsg)+ 1,v)
		end		
	end
end

--推荐好友数据
function FriendDataMgr.SetReCommandGuy(data)
	RecommandedGuy = data
end

--获取推荐好友
function FriendDataMgr.GetReCommandGuy()
	local tab = {}
	local i  = 0
	local SelfID = CC.Player.Inst():GetSelfInfoByKey("Id")
	if not RecommandedGuy.Guies then return tab end
	for k,v in ipairs(RecommandedGuy.Guies) do
		if SelfID ~= v.Player.PlayerId then
			i =  i + 1
			tab[i] = v
		end
	end
	return tab
end

--设置下一次需要拉取好友列表的页签
function FriendDataMgr.SetCurrentIndexPage(rankId)
	local num = math.ceil(rankId / 50)
	if num < 1 then
		num = 0
	end
	FriendIndex = num + 1
end

--获取下一次需要拉取好友列表的页签
function FriendDataMgr.GetCurrentIndexPage()
	return FriendIndex
end

--设置下一次需要拉取好友申请列表的页签
function FriendDataMgr.SetCurrentApplyIndexPage(rankId)
	local num = math.floor(rankId / 50)
	if num < 1 then
		num = 0
	end
	ApplyFriendIndex = num +1
end

--获取下一次需要拉取好友申请列表的页签
function FriendDataMgr.GetCurrentApplyIndexPage()
	return ApplyFriendIndex
end

--获取好友总数
function FriendDataMgr.GetFriendTotal()
	return FriendTotal
end

--设置好友总数
function FriendDataMgr.SetFriendTotal(num)
	if not num or num == 0 then
		return
	end
	FriendTotal = num
end

--获取当前拉取的好友列表数据
function FriendDataMgr.GetFriendListData()
	return ListMsg
end

--根据id下标获取好友列表数据
function FriendDataMgr.GetFriendListDataByKey(id)
	if not ListMsg then return end
	for i=1,table.length(ListMsg) do
		if i == id then
			return ListMsg[i]
		end		
	end
end

--修改好友在线状态
function FriendDataMgr.SetFriendsList_IsOnline(id,b)
	if not ListMsg then return end
	for i=1,table.length(ListMsg) do
		if ListMsg[i].PlayerId == id then
			ListMsg[i].Online = b
		end		
	end
end

--获取当前拉取到的好友长度
function FriendDataMgr.GetFriendListLen()
	return table.length(ListMsg) or 0
end

--获取在线好友数量
function FriendDataMgr.GetFriendOnLine()
	if not ListMsg then
		return
	end
	local OnLineNum = 0
	for i,v in ipairs(ListMsg) do
		if v.Online then
			 OnLineNum = OnLineNum + 1
		end		
	end
	return OnLineNum
end

--好友列表插入好友数据
function FriendDataMgr.SetNewFriendListData(data)	
	if not FriendDataMgr.IsFriend(data.FriendInfo.PlayerId) then
		if data.FriendInfo.Online then
			table.insert(ListMsg,1,data.FriendInfo)
		else
			table.insert(ListMsg,data.FriendInfo)
		end
		FriendsMsg[data.FriendInfo.PlayerId] = data.FriendInfo

		FriendDataMgr.SetFriendTotal(FriendDataMgr.GetFriendTotal() + 1)
		--logError(string.format("ListMsg: %s    FriendTotal: %s",#ListMsg,FriendDataMgr.GetFriendTotal()))
	end
end

--是否好友
function FriendDataMgr.IsFriend(PlayerId)
	if FriendsMsg[PlayerId] ~= nil then
		return true
	else
		return false
	end
end

--添加好友列表数据 到列表
function FriendDataMgr.AddFriendListData(data)
	InitFriendsList = true
	for i,v in ipairs(data.FriendInfo) do
		if not FriendDataMgr.IsFriend(v.PlayerId) then
			if v.Online then
				table.insert(ListMsg,1,v)
			else
				table.insert(ListMsg,v)
			end
			FriendsMsg[v.PlayerId] = v
		end
	end
	FriendDataMgr.SetFriendTotal(data.Total)
	--logError(string.format("ListMsg: %s  Total: %s  FriendTotal: %s",#ListMsg,data.Total,FriendDataMgr.GetFriendTotal()))
end

--设置好友列表数据
function FriendDataMgr.SetFriendListData(data)
	InitFriendsList = true
	ListMsg = {}
	FriendsMsg = {}
	for key,value in ipairs(data.FriendInfo) do
		if value.Online then
			table.insert(ListMsg,1,value)
		else
			table.insert(ListMsg,value)
		end
		FriendsMsg[value.PlayerId] = value
	end		
	FriendDataMgr.SetFriendTotal(data.Total)
	--logError(string.format("ListMsg: %s  Total: %s  FriendTotal: %s",#ListMsg,data.Total,FriendDataMgr.GetFriendTotal()))
end

--根据玩家id删除好友
function FriendDataMgr.SetDeletePersonData(PlayerId)
	for key,value in pairs(FriendsMsg) do
		if key == PlayerId then
			FriendsMsg[key] = nil
		end
	end

	for i=1,table.length(ListMsg) do
		if tonumber(ListMsg[i].PlayerId) == tonumber(PlayerId) then
			table.remove(ListMsg,i)
			--FriendDataMgr.SetFriendTotal(FriendDataMgr.GetFriendTotal() - 1)
			--直接设置,不走 SetFriendTotal ，因为当为 0 时会 return 掉，设置不成功，后续会引发 FriendView 循环请求好友列表，导致界面卡死
			FriendTotal = FriendDataMgr.GetFriendTotal() - 1 <= 0 and 0 or FriendDataMgr.GetFriendTotal() - 1
			--logError(string.format("ListMsg: %s    FriendTotal: %s",#ListMsg,FriendDataMgr.GetFriendTotal()))
			CC.HallNotificationCenter.inst():post(CC.Notifications.SetDeleteFriend)
			break
		end		
	end

end

--获取好友申请列表总数
function FriendDataMgr.GetApplyFriendsTotal()
	return ApplyFriendsTotal
end

--写入好友列表总数据
function FriendDataMgr.SetApplyFriendsTotal(num)
	ApplyFriendsTotal = num
end

--设置好友申请列表
function FriendDataMgr.SetApplyFriendsData(data)
	InitApplyList = true
	ApplyFriendsMsg = {}
	local Repetition = 0
	for key,value in ipairs(data.FriendInfo) do		
		if not FriendDataMgr.IsFriend(value.PlayerId) and FriendDataMgr.CheckSaveID(value.PlayerId) then
			table.insert(ApplyFriendsMsg,value)
		else
			Repetition = Repetition +1
		end
	end		
	--服务器这里给过来Total的值不准确，这里客户端做处理，减去已经是好友或者已经在好友申请列表中的
	FriendDataMgr.SetApplyFriendsTotal(data.Total - Repetition) 
	--logError(string.format("ApplyFriendsMsg: %s   Total: %s   ApplyFriendsTotal: %s   FriendInfo: %s",#ApplyFriendsMsg,data.Total,FriendDataMgr.GetApplyFriendsTotal(),#(data.FriendInfo)))
end

--添加好友申请列表
function FriendDataMgr.AddApplyFriendsData(data)
	InitApplyList = true
	local Repetition = 0
	for key,value in ipairs(data.FriendInfo) do
		local id = value.PlayerId
		if not FriendDataMgr.IsFriend(id) and FriendDataMgr.CheckSaveID(id) then
			table.insert(ApplyFriendsMsg,value)
		else
			Repetition = Repetition +1
		end
	end		
	FriendDataMgr.SetApplyFriendsTotal(data.Total - Repetition)
	--logError(string.format("ApplyFriendsMsg: %s    Total: %s     ApplyFriendsTotal: %s   FriendInfo: %s",#ApplyFriendsMsg,data.Total,FriendDataMgr.GetApplyFriendsTotal(),#(data.FriendInfo)))
end

--增加一个好友请求的数据
function FriendDataMgr.SetNewApplyFriendsData(data)
	for i,v in ipairs(ApplyFriendsMsg) do
		if v.PlayerId == data.FriendInfo.PlayerId then
			table.remove(ApplyFriendsMsg,i)
			FriendDataMgr.SetApplyFriendsTotal(FriendDataMgr.GetApplyFriendsTotal()- 1)
			--logError(string.format("ApplyFriendsMsg: %s    ApplyFriendsTotal: %s",#ApplyFriendsMsg,FriendDataMgr.GetApplyFriendsTotal()))
			break
		end
	end
	table.insert(ApplyFriendsMsg,1,data.FriendInfo)
	FriendDataMgr.SetApplyFriendsTotal(FriendDataMgr.GetApplyFriendsTotal()+ 1)
	--logError(string.format("ApplyFriendsMsg: %s    ApplyFriendsTotal: %s",#ApplyFriendsMsg,FriendDataMgr.GetApplyFriendsTotal()))
end

--获取当前拉取的好友申请数量
function FriendDataMgr.GetApplyFriendsLen()
	return table.length(ApplyFriendsMsg) or 0
end

--查重,存在返回false，不存在返回true
function FriendDataMgr.CheckSaveID(id)
	for i, v in ipairs(ApplyFriendsMsg) do
		if id == v.PlayerId then
			return false
		end
	end
	return true
end


--获取好友
function FriendDataMgr.GetApplyFriendsDataByKey(id)
	for key,value in ipairs(ApplyFriendsMsg) do
		if key == id then
			return ApplyFriendsMsg[key]
		end		
	end	
	return nil
end

--删除所有好友申请数据
function FriendDataMgr.DeleteAllApplyFriendsMsg()
	ApplyFriendsMsg = {}
	ApplyFriendsTotal = 0
end

--根据好友申请下标删除好友申请数据
function FriendDataMgr.DeleteApplyFriendsById(id)
	for i=1,table.length(ApplyFriendsMsg) do
		if i == id then
			table.remove(ApplyFriendsMsg,i)
			FriendDataMgr.SetApplyFriendsTotal(FriendDataMgr.GetApplyFriendsTotal() - 1)
			--logError(string.format("ApplyFriendsMsg: %s    ApplyFriendsTotal: %s",#ApplyFriendsMsg,FriendDataMgr.GetApplyFriendsTotal()))
			break
		end
	end
end

--根据playerid删除好友申请数据
function FriendDataMgr.DeleteApplyFriendsByPlayerId(PlayerId)
	for i=1,table.length(ApplyFriendsMsg) do
		if ApplyFriendsMsg[i].PlayerId == PlayerId then
			table.remove(ApplyFriendsMsg,i)
			FriendDataMgr.SetApplyFriendsTotal(FriendDataMgr.GetApplyFriendsTotal() - 1)
			--logError(string.format("ApplyFriendsMsg: %s    ApplyFriendsTotal: %s",#ApplyFriendsMsg,FriendDataMgr.GetApplyFriendsTotal()))
			break
		end
	end
end

function FriendDataMgr.GetInitFriendsListState()
	return InitFriendsList
end

function FriendDataMgr.GetInitApplyListState()
	return InitApplyList
end

function FriendDataMgr.ResetInitState()
	ListMsg = {}
	FriendsMsg = {}
	ApplyFriendsMsg = {}
	InitFriendsList = false
	InitApplyList = false
end

return FriendDataMgr
