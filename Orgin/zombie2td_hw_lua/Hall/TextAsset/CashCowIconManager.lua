local CC = require("CC")

local M = {}

M.CreateIcon = function (param)
	local icon = CC.ViewCenter.CashCowIcon.new()
	icon:Create(param)
	return icon
end

M.DestroyIcon = function (icon)
    if icon then
        icon:Destroy()
    end
end

return M