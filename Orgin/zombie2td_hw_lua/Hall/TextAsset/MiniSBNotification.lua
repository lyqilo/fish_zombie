local Notification = {}
local M = {}
M.__index = M
setmetatable(Notification, M)

----------------游戏内部消息传递---------------
local GameList = {}

function M.GameRegister(obj, name, func)
	local lExist = false
	for _, v in ipairs(GameList) do
		if v.name == name and v.obj == obj then
			lExist = true
			break
		end
	end

	if not lExist then
		local data = {}
		data.obj = obj
		data.func = func
		data.name = name
		table.insert(GameList, data)
	end
end

function M.GameUnregister(obj, name)
	local i = 1
	local data
	while i <= #GameList do
		data = GameList[i]
		if data.name == name and data.obj == obj then
			table.remove(GameList, i)
			break
		else
			i = i + 1
		end
	end
end

function M.GameUnregisterAll(obj)
	local i = 1
	while i <= #GameList do
		if GameList[i].obj == obj then
			table.remove(GameList, i)
		else
			i = i + 1
		end
	end
end

function M.GamePost(name, ...)
	for i, v in ipairs(GameList) do
		if (v.name == name) then
			v.func(v.obj, ...)
		end
	end
end
----------------游戏内部消息传递---------------

----------------网络回包消息分发---------------
local NetworkList = {}
--name填写请求的名字
function M.NetworkRegister(obj, name, func)
	local lExist = false
	for _, v in ipairs(NetworkList) do
		if v.name == name and v.obj == obj then
			lExist = true
			break
		end
	end

	if not lExist then
		local data = {}
		data.obj = obj
		data.func = func
		data.name = name
		table.insert(NetworkList, data)
	end
end

function M.NetworkUnregister(obj, name)
	local i = 1
	local data
	while i <= #NetworkList do
		data = NetworkList[i]
		if data.name == name and data.obj == obj then
			table.remove(NetworkList, i)
			break
		else
			i = i + 1
		end
	end
end

function M.NetworkUnregisterAll(obj)
	local i = 1
	while i <= #NetworkList do
		if NetworkList[i].obj == obj then
			table.remove(NetworkList, i)
		else
			i = i + 1
		end
	end
end

function M.NetworkPost(name, ...)
	for i, v in ipairs(NetworkList) do
		if (v.name == name) then
			v.func(v.obj, ...)
		end
	end
end
----------------网络回包消息分发---------------

function M.UnregisterAll(obj)
	local i = 1
	while i <= #GameList do
		if GameList[i].obj == obj then
			table.remove(GameList, i)
		else
			i = i + 1
		end
	end

	i = 1
	while i <= #NetworkList do
		if NetworkList[i].obj == obj then
			table.remove(NetworkList, i)
		else
			i = i + 1
		end
	end
end

function M.ResetTable()
	GameList = {}
	NetworkList = {}
end

return Notification
