
local CC = require("CC")
 

local NotificationCenter = CC.class2("NotificationCenter")

function NotificationCenter:ctor()
	self._center = {}
end
	
function NotificationCenter:register(obj, func, name)
	local lExist = false

	if obj == nil or func == nil or name == nil then return end

	for _,v in pairs(self._center) do
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
		table.insert(self._center, data)
	end
end

function NotificationCenter:unregister(obj, name)
	local i = 1
	while i <= #self._center do
		if self._center[i].name == name and self._center[i].obj == obj then 
			table.remove(self._center, i)
			break
		else
			i = i + 1
		end
	end
end

function NotificationCenter:unregisterAll(obj)
	if(obj ~= nil) then
		local i = 1
		while i <= #self._center do
			if self._center[i].obj == obj then 
				table.remove(self._center, i)
			else
				i = i + 1
			end
		end
	end
end

function NotificationCenter:reset()
	--谨慎调用！所有的事件监听都会失效
	self._center = {}
end

function NotificationCenter:post(name, ...)
	for i,v in ipairs(self._center) do
		if(v.name == name) then
			--判断对象是不是类对象
			if v.obj and v.obj.isClassObject then
				v.func(v.obj, ...)
			else
				v.func(...)
			end
		end
	end
end

--静态方法
local _inst = nil
function NotificationCenter.inst()
	logError([[！！！该API已废弃,游戏内使用消息管理中心，请使用NotificationCenter创建一个对象去分发消息！
		不要公用一个管理中心，因为彼此间不知道你有哪些事件，也无法管理你的事件\n]] .. debug.traceback())
	if not _inst then
		_inst = NotificationCenter.new()
	end
	return _inst
end

return NotificationCenter
