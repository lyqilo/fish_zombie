
local CC = require("CC")

local OverlappingManager = CC.class2("OverlappingManager")
local _instance = nil

function OverlappingManager:ctor()
	self._queue = CC.Queue.new()
	self._isOpen = false
	self._currView = nil
end

function OverlappingManager.GetInstance()
	if not _instance then
		_instance = OverlappingManager.new()
	end
	return _instance
end

local function OpenView(self)
	if self._queue:size() <= 0 then return end
	local p = self._queue:peek()
	self._currView = CC.ViewManager.Open(p.clazz, unpack(p.data))
	if self._currView == nil then return end

	self._queue:pop()
	self._isOpen = true
	local handle = self._currView.OnDestroyFinish
	self._currView.OnDestroyFinish = function(s)
		handle(s)
		self._currView = nil
		self._isOpen = false
		OpenView(self)
	end
	return self._currView
end

function OverlappingManager:Open(clazz, ...)
	if not CC.ViewManager.IsSwitchOn(clazz) then
		return
	end
	local param = {}
	param.data = {...}
	param.clazz = clazz
	self._queue:push(param)
	if not self._isOpen then
		return OpenView(self)
	end
end

function OverlappingManager:DestroyInance()
	if _instance then
		_instance:clear()
		_instance = nil
	end
end

function OverlappingManager:clear()
	self._queue:clear()
	self._isOpen = false

	if self._currView then
		self._currView:Destroy()
	end
end

return OverlappingManager