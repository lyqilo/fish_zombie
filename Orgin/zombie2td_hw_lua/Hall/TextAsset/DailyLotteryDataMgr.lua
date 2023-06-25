
local CC = require("CC")
local DailyLotteryDataMgr = {}

local info = {}

function DailyLotteryDataMgr.GetScrollData(data)
	return info
end

function DailyLotteryDataMgr.InsertScrollData(data)
    table.insert(info, 1, data)
    if table.length(info) > 20 then
        table.remove(info,#info)
    end
end

return DailyLotteryDataMgr
