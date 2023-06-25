local CC = require("CC")

local MiniSBLocalData = {}

local saveNamePrefix = "MiniSB_LocalData"
local _data = {}

--存储
function MiniSBLocalData.Init()
    _data = CC.UserData.Load(saveNamePrefix, {})
end
------------------------------------------------
-- Mini 骰宝
------------------------------------------------
function MiniSBLocalData.SetResultEffect(open)
    _data["MINISB_RESULT_EFFECT"] = open
    CC.UserData.Save(saveNamePrefix, _data)
end

function MiniSBLocalData.GetResultEffect()
    return _data["MINISB_RESULT_EFFECT"] or false
end

------------------------------------------------
-- Mini 骰宝
------------------------------------------------
function MiniSBLocalData.SetBetPanelPosition(pos)
    _data["MINISB_BET_PANEL_POS"] = pos
    CC.UserData.Save(saveNamePrefix, _data)
end

function MiniSBLocalData.GetBetPanelPosition()
    return _data["MINISB_BET_PANEL_POS"] or nil
end

return MiniSBLocalData
