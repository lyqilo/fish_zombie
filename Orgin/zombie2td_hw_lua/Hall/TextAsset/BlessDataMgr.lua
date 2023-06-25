
local CC = require("CC")
local BlessDataMgr = {}

local blessData;

function BlessDataMgr.SetBlessData(data)
	blessData = {};
	for i,v in ipairs(data) do
		blessData[#blessData+1] = v;
	end
end

function BlessDataMgr.InsertBlessData(data)
	if not blessData then return end
	table.remove(blessData, #blessData);
	table.insert(blessData, 1, data[1]);
end

function BlessDataMgr.GetBlessData()

	return blessData;
end

function BlessDataMgr.GetDataLength()
	if not blessData then return 0 end
	return #blessData;
end

return BlessDataMgr
