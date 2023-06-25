
local CC = require("CC")
local SilentDataMgr = {}

local silentData = {}

function SilentDataMgr.SetSilentIds(data)

	for _,playerId in ipairs(data.PlayerList) do
		silentData[playerId] = true;
	end
end

function SilentDataMgr.AddSilentById(playerId)

	silentData[playerId] = true;
end

function SilentDataMgr.RemoveSilentById(playerId)

	silentData[playerId] = nil;
end

function SilentDataMgr.CheckSilentById(playerId)

	return silentData[playerId];
end

function SilentDataMgr.GetSilentIds()

	return silentData;
end

function SilentDataMgr.GetSilentCount()

	return table.length(silentData);
end

return SilentDataMgr
