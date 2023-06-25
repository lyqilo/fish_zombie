--[[
    签到活动相关数据管理类
]]

local CC = require("CC")
local SignActivityDataMgr = {}
local Mgr = SignActivityDataMgr

local NoviceSignState = nil
function Mgr.SetNoviceSignState(data)

end

function Mgr.GetNoviceSignState()
    return NoviceSignState
end

local NoviceSignAwardInfo = nil
function Mgr.SetNoviceSignAwardInfo(data)
    NoviceSignAwardInfo = {}
    for i,v in ipairs(data.List) do
        table.insert(NoviceSignAwardInfo, v)
    end
end

function Mgr.AddNoviceSignAwardInfo(data)
    if not NoviceSignAwardInfo then
        NoviceSignAwardInfo ={}
    end
    table.insert(NoviceSignAwardInfo, 1, data)
    CC.HallNotificationCenter.inst():post(CC.Notifications.AddNoviceSignAwardInfo)
end

function Mgr.GetNoviceSignAwardInfo()
    return NoviceSignAwardInfo
end

return Mgr
