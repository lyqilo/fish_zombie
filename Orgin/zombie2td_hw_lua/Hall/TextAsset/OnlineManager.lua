local CC = require("CC")

local OnlineManager = {}

OnlineManager.CreateIcon = function (param)
	local icon = CC.ViewCenter.OnlineIcon.new()
	icon:Create(param)
	return icon
end

OnlineManager.CreateSlotsIcon = function (param)
	local icon = CC.ViewCenter.SlotsOnlineIcon.new()
	icon:Create(param)
	return icon
end

OnlineManager.DestroyIcon = function (icon)
	icon:Destroy()
end

return OnlineManager