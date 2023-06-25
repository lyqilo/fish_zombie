local CC = require("CC")

local RankIconManager = {}

RankIconManager.CreateIcon = function (param)
	local icon = CC.ViewCenter.RankIcon.new()
	icon:Create(param)
	return icon
end

RankIconManager.CreateDiffRankIcon = function (param)
	local icon = CC.ViewCenter.DiffRankIcon.new()
	icon:Create(param)
	return icon
end

RankIconManager.DestroyIcon = function (icon)
	icon:Destroy()
end

return RankIconManager