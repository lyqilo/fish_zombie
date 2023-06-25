--魅魔转盘管理
--data.view：转盘预制
--data.info:转盘信息

local GC = require("GC")
local ZTD = require("ZTD")

local TurnTableMgr = GC.class2("PrizeMedal")

function TurnTableMgr:ctor()
    self:InitData()
    self:StartUpdate()
    self:RegisterEvent()
end

function TurnTableMgr:InitData()
    TurnTableMgr.list = {}
    --是否正在运行转盘
    TurnTableMgr.isRunning = false
end

function TurnTableMgr:StartUpdate()
    ZTD.UpdateAdd(TurnTableMgr.Update, TurnTableMgr)
end

function TurnTableMgr:RegisterEvent()
    
end

--添加一个转盘
function TurnTableMgr:AddTurnTable(PlayerId, data)
    if not TurnTableMgr.list[PlayerId] then
        TurnTableMgr.list[PlayerId] = {}
    end
    local view = ZTD.TurnTableUi:new()
    data.view = view
    view:Init(data)
    table.insert(TurnTableMgr.list[PlayerId], data)
    self:StartTurnTable(PlayerId)
    self:RefreshTableNum(PlayerId)
end

--移除一个转盘
function TurnTableMgr:RemoveTurnTable(PlayerId)
    if not TurnTableMgr.list[PlayerId] then
        return
    end
    table.remove(TurnTableMgr.list[PlayerId], 1)
    TurnTableMgr.isRunning = false
    self:StartTurnTable(PlayerId)
    self:RefreshTableNum(PlayerId)
end

--移除所有转盘
function TurnTableMgr:RemoveAll()
    for _, v in pairs(TurnTableMgr.list) do
        if v and #v > 0 then
            for _, data in ipairs(v) do
                if data and data.view then
                    data.view:Release()
                end
            end
        end
    end
    TurnTableMgr.list = {}
end

--启动一个转盘
function TurnTableMgr:StartTurnTable(PlayerId)
    --正在运行转盘中
    -- log("TurnTableMgr.isRunning="..tostring(TurnTableMgr.isRunning))
    if TurnTableMgr.isRunning then
        return
    end
    -- log("TurnTableMgr.list="..GC.uu.Dump(TurnTableMgr.list))
    if not TurnTableMgr.list[PlayerId] then
        return
    end
    local data = TurnTableMgr.list[PlayerId][1]
    if data then
        TurnTableMgr.isRunning = true
        data.view:StartTurnTable()
    end
end

--获取转盘数量
function TurnTableMgr:GetTurnTableCount(PlayerId)
    if not TurnTableMgr.list[PlayerId] then
        return 0
    end
    return #TurnTableMgr.list[PlayerId]
end

--刷新转盘数量
function TurnTableMgr:RefreshTableNum(PlayerId)
    local num = self:GetTurnTableCount(PlayerId)
    if num <= 0 then
        return
    end
    for k, v in ipairs(TurnTableMgr.list[PlayerId]) do
        if k == num then
            v.view:RefreshTableNum(num)
        else
            v.view:RefreshTableNum(-1)
        end
    end
end

function TurnTableMgr:Update()
    if not TurnTableMgr.list then
        return
    end
    for _, v in pairs(TurnTableMgr.list) do
        if v and #v > 0 then 
            if v[1].view then
                v[1].view:Update()
            end
        end
    end
end

function TurnTableMgr:StopUpdate()
    ZTD.UpdateRemove(TurnTableMgr.Update, TurnTableMgr)
end

function TurnTableMgr:UnRegisterEvent()
    
end

function TurnTableMgr:Release()
    self:RemoveAll()
    self:StopUpdate()
    self:UnRegisterEvent()
end

return TurnTableMgr