local CC = require("CC")

local FlyCoinManager = {}

FlyCoinManager.Create = function(param)
	local FlyCoin = CC.ViewCenter.FlyCoin.new();
	FlyCoin:Create(param)
	return FlyCoin
end

FlyCoinManager.Destroy = function(FlyCoin)
	FlyCoin:Destroy();
end 

return FlyCoinManager