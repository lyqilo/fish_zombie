local CC = require("CC")

local FreeChipsManager = {}

FreeChipsManager.CreateIcon = function (param)
	local icon = CC.ViewCenter.FreeChipsIcon.new()
	icon:Init("FreeChipsIcon", param.parent, param)
	return icon
end

FreeChipsManager.CreateSlotIcon = function (param)
	local icon = CC.ViewCenter.SlotFreeChipsIcon.new()
	icon:Init("SlotFreeChipsIcon", param.parent, param)
	return icon
end

FreeChipsManager.DestroyIcon = function (icon)
	icon:Destroy()
end

return FreeChipsManager