local CC = require("CC")

local ElephantManager = {}

ElephantManager.CreateIcon = function (param)
	local icon = CC.ViewCenter.ElephantIcon.new()
	icon:Create(param)
	return icon
end

ElephantManager.DestroyIcon = function (icon)
	icon:Destroy()
end

return ElephantManager