local CC = require("CC")
local Push = {}

function Push.Logout()
	local push = CC.NetworkHelper.MakeMessage("Logout")
    CC.Network.Push("Logout")
end

return Push