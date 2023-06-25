
local CC = require("CC")
local RealStoreIconManager = {}

RealStoreIconManager.CreateIcon = function (param)
	local icon = CC.ViewCenter.RealStoreIcon.new()
	icon:Init("RealStoreIcon", param.parent, param)
	return icon
end

RealStoreIconManager.DestroyIcon = function (icon)
	icon:Destroy()
end


return RealStoreIconManager;
