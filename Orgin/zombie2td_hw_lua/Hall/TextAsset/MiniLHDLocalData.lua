local CC = require("CC")

local MiniLHDLocalData = {}

local saveNamePrefix = "MiniLHD_LocalData"
local _data = {}

function MiniLHDLocalData.Init()
    _data = CC.UserData.Load(saveNamePrefix, {})
end

function MiniLHDLocalData.SetSelectChip(chipIndex)
    local key = "SELECT_CHIP"
    _data[key] = chipIndex
    CC.UserData.Save(saveNamePrefix, _data)
end

function MiniLHDLocalData.GetSelectChip()
    local key = "SELECT_CHIP"
    return _data[key] or 1
end

return MiniLHDLocalData
