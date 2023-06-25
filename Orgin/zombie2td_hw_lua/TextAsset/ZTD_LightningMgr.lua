--连接怪闪电管理
local GC = require("GC")
local ZTD = require("ZTD")

local ballPrefab = "TD_Effect_Sandian01"

local LightningMgr = GC.class2("ZTD_LightningMgr")

function LightningMgr:ctor()
    self:InitData()
end

function LightningMgr:InitData()
    --存储所有连接怪闪电
    LightningMgr.lightning = {}
    --存储所有连接怪闪电球
    LightningMgr.ball = {}
end

--创建对应连接怪的闪电
function LightningMgr:AddLightning(ID, data)
    if not LightningMgr.lightning[ID] then
        LightningMgr.lightning[ID] = {}
    end
    local lightning = ZTD.Lightning:new()
    data.lightning = lightning
    lightning:Init(data)
    table.insert(LightningMgr.lightning[ID], data)
    -- log("AddLightning LightningMgr.lightning[ID]="..tostring(ID))
end

--创建闪电球
function LightningMgr:AddLightningBall(ID, data)
    -- log("AddLightningBall ID="..tostring(ID))
    if not LightningMgr.ball[ID] then
        LightningMgr.ball[ID] = {}
    end
    local lightningBall = ZTD.PoolManager.GetGameItem(ballPrefab, ZTD.MainScene.GetMapObj())
	lightningBall.position = data.position
    lightningBall.localScale = data.scale or Vector3.one
    data.lightningBall = lightningBall
    table.insert(LightningMgr.ball[ID], data)
    -- log("AddLightningBall LightningMgr.ball[ID]="..tostring(ID))
end

--移除对应连接怪的所有闪电和闪电球
function LightningMgr:RemoveLightning(ID)
    -- log("RemoveLightning ID="..tostring(ID))
    if LightningMgr.lightning[ID] then
        for k, v in ipairs(LightningMgr.lightning[ID]) do
            if v.lightning then
                v.lightning:Release()
            end
        end
        LightningMgr.lightning[ID] = {}
        -- log("RemoveLightning LightningMgr.lightning[ID]="..tostring(ID))
    end

    if LightningMgr.ball[ID] then
        for k, v in ipairs(LightningMgr.ball[ID]) do
            if v.lightningBall then
                ZTD.PoolManager.RemoveGameItem(ballPrefab, v.lightningBall)
            end
        end
        LightningMgr.ball[ID] = {}
        -- log("RemoveLightning LightningMgr.ball[ID]="..tostring(ID))
    end
end

--移除所有连接怪的闪电和闪电球
function LightningMgr:RemoveAll()
    -- logError("RemoveAll LightningMgr.lightning[ID]="..GC.uu.Dump(LightningMgr.lightning))
    for _, v in pairs(LightningMgr.lightning) do
        if v and #v > 0 then
            for _, data in ipairs(v) do
                if data and data.lightning then
                    data.lightning:Release()
                end
            end
        end
    end
    LightningMgr.lightning = {}
    -- logError("RemoveAll LightningMgr.lightning[ID]="..GC.uu.Dump(LightningMgr.lightning))

    -- logError("RemoveAll LightningMgr.ball[ID]="..GC.uu.Dump(LightningMgr.ball))
    for _, v in pairs(LightningMgr.ball) do
        if v and #v > 0 then
            for _, data in ipairs(v) do
                if data and data.lightningBall then
                    ZTD.PoolManager.RemoveGameItem(ballPrefab, v.lightningBall)
                end
            end
        end
    end
    LightningMgr.ball = {}
    -- logError("RemoveAll LightningMgr.ball[ID]="..GC.uu.Dump(LightningMgr.ball))
end

function LightningMgr:Release()
    self:RemoveAll()
end

return LightningMgr