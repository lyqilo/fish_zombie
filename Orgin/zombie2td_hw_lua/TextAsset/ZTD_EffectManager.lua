local GC = require("GC")
local ZTD = require("ZTD")

local M = {}

local effectParent = nil
local effectID = nil
local effectList = nil

function M.Init()
    effectParent = GameObject.Find("effectContainer").transform
    effectID = 0
    effectList = {}
end

--创建特效
function M.PlayEffect(PrefabName, parent, isUI)
    local effect = ZTD.PoolManager.GetUiItem(PrefabName, parent or effectParent)

    effect.localPosition = Vector3.zero
    effect.localScale = Vector3.one
    effect.localRotation = Quaternion.Euler(0, 0, 0)
    
    effectID = effectID + 1
    effectList[effectID] = {}
    effectList[effectID].effectObj = effect
    effectList[effectID].effectID = effectID
    effectList[effectID].PrefabName = PrefabName
    effectList[effectID].isUI = isUI and true or false

	return effect, effectID
end

--初始化特效参数
function M.InitParam(effect, pos, scale, rotation)
    if not effect then return end
    if pos then
        effect.localPosition = pos
    end
    if scale then
        effect.localScale = scale
    end
    if rotation then
        effect.localRotation = rotation
    end
end

--根据ID获取effect
function M.GetEffectByID(effectID)
    if effectID and effectList and effectList[effectID] then
        return effectList[effectID]
    end
end

--根据ID移除特效
function M.RemoveEffectByID(effectID)
    if effectID and effectList and effectList[effectID] then
        if effectList[effectID].isUI == true then
            ZTD.PoolManager.RemoveUiItem(effectList[effectID].PrefabName, effectList[effectID].effectObj)
        elseif effectList[effectID].isUI == false then
            ZTD.PoolManager.RemoveGameItem(effectList[effectID].PrefabName, effectList[effectID].effectObj)
        end
        effectList[effectID] = nil
    end
end

function M.Release()
    if effectList ~= nil then
        for _,v in pairs(effectList) do
            if v.isUI == true then
                ZTD.PoolManager.RemoveUiItem(v.PrefabName, v.effectObj)
            elseif v.isUI == false then
                ZTD.PoolManager.RemoveGameItem(v.PrefabName, v.effectObj)
            end
        end
    end
    effectID = 0
    effectList = {}
end

return M