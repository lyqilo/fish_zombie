local CC = require("CC")

local M = {}

M.CreateIcon = function (param)
	local icon = CC.ViewCenter.SlotCommonNoticeIcon.new()
	icon:Init("SlotCommonNoticeIcon", param.parent, param)
	return icon
end

M.DestroyIcon = function (icon)
	icon:Destroy()
end

return M