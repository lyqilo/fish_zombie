
--大厅的消息分发中心，子游戏禁止公用

local CC = require("CC")

local HallNotificationCenter = {}

--静态方法
local _inst = nil
function HallNotificationCenter.inst()
	if not _inst then
		_inst = CC.NotificationCenter.new()
	end
	return _inst
end

return HallNotificationCenter