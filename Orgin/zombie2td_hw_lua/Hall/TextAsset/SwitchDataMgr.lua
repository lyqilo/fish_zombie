local CC = require("CC")
local SwitchDataMgr = {}

local SwitchData = {}
local SetPing = nil --降级PING
local PlayerPing = nil --玩家登录PING
local PhoneLogin = nil --手机登录开关
local loginQueue = {}

function SwitchDataMgr.SetPingSwitch(ping)
    SetPing = ping
end

function SwitchDataMgr.SetPlayerPing(ping)
    if ping then
        PlayerPing = ping
    end
end

function SwitchDataMgr.GetLoginQueueSwitch()
    return loginQueue
end

function SwitchDataMgr.SetLoginQueueSwitch(queue)
    if queue then
        loginQueue = queue
    end
end

function SwitchDataMgr.SetPhoneLoginSwitch(state)
    PhoneLogin = state
end

function SwitchDataMgr.GetPhoneLoginSwitch()
    return PhoneLogin
end

function SwitchDataMgr.GetPingSwitch()
    if not PlayerPing then
        return true
    end
    --配置中有设置PING，玩家Ping大于设置Ping，则请求降级,否则不降级,Ping小于0则默认不降级
    if CC.DebugDefine.GetLowHttpDebugState() then
        return false
    end
    if SetPing then
        if SetPing < 0 then
            return true
        elseif PlayerPing > SetPing then
            return false
        end
    end
    return true
end

function SwitchDataMgr.SetSwitchData(data)
    SwitchData = {}
    for _, v in pairs(data.data) do
        SwitchData[v.Key] = v
    end
    log(CC.uu.Dump(SwitchData, "SwitchData:"))
    CC.HallNotificationCenter.inst():post(CC.Notifications.HallFunctionUpdate)
end

function SwitchDataMgr.GetSwitchStateByKey(key, bState)
    --提审状态处理
    if CC.ChannelMgr.GetTrailStatus() then
        local hideList = {"EPC_LockLevel", "BSGuide", "TreasureEffect", "TreasureGoods", "PhysicalLock"}
        for _, v in ipairs(hideList) do
            if key == v then
                return false
            end
        end
    end
    -- 道具实物锁不配置在web配置中
    if key == "EPC_LockLevel" then
        if CC.ChannelMgr.CheckOppoChannel() or CC.DebugDefine.GetLockDebugState() then
            return true
        end
        --一级锁去掉，都使用实物锁替换(PhysicalLock)
        -- local lockLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_LockLevel") or 0
        -- if lockLevel > 0 then
        --     return true
        -- end
        --一级锁未开，老玩家用TreasureGoods去判断开关条件
        local greenhand = CC.Player.Inst():GetSelfInfoByKey("EPC_GreenHand") or 0
        if greenhand == 0 then
            key = "TreasureGoods"
        else
            key = "PhysicalLock"
        end
        --实物锁，防止switchdata没有，默认返回false
        bState = false
    end

    if SwitchData[key] then
        local isOpen = SwitchData[key].IsOpen
        if isOpen then
            if key == "SetDot" or key == "SetUpServiceView" or key == "WebService" then
                return isOpen
            end
            local Condition = SwitchData[key].Condition
            local PlayerInfo = {}
            PlayerInfo.VIPLimit = CC.Player.Inst():GetSelfInfoByKey("EPC_Level") or 0
            PlayerInfo.OnlineTime = CC.Player.Inst():GetSelfInfoByKey("EPC_OnlineTime") or 0
            PlayerInfo.Turnover = CC.Player.Inst():GetSelfInfoByKey("EPC_TotalLose") or 0
            PlayerInfo.Chip = CC.Player.Inst():GetSelfInfoByKey("EPC_LastMaxChm") or 0
            PlayerInfo.LastPurchaseTime = CC.Player.Inst():GetSelfInfoByKey("EPC_TotalRecharge") or 0
            if key == "ShowMol" then
                return SwitchDataMgr.ReturnMolSwitch(Condition, PlayerInfo)
            else
                return SwitchDataMgr.ReturnUniversalSwitch(Condition, PlayerInfo)
            end
        else
            return false
        end
    end
    --如果没有拉到Switch数据，默认返回true,如果有传状态则返回传的状态
    if bState == nil then
        return true
    else
        return bState
    end
end

--通用开关控制
function SwitchDataMgr.ReturnUniversalSwitch(Condition, PlayerInfo)
    if
        PlayerInfo.VIPLimit >= Condition.VIPLimit and PlayerInfo.Turnover >= Condition.Turnover and
            PlayerInfo.OnlineTime >= Condition.OnlineTime and
            PlayerInfo.Chip >= Condition.Chip
     then
        if Condition.LastPurchaseTime and Condition.LastPurchaseTime == 1 then
            if PlayerInfo.LastPurchaseTime <= 0 then
                return false
            else
                return true
            end
        else
            return true
        end
    end
    return false
end

--赠送咨询开关
function SwitchDataMgr.ReturnBSGuideSwitch(Condition, PlayerInfo)
    --判断首充状态，没有首充直接返回false
    local lastPurchaseTime = CC.Player.Inst():GetSelfInfoByKey("EPC_TotalRecharge")
    if lastPurchaseTime <= 0 then
        return false
    end

    --新老玩家判断一级锁，一级锁开则返回true
    local lockLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_LockLevel")
    if lockLevel > 0 then
        return true
    end
    --判断是否是老玩家，是老玩家需要额外判断开关状态
    local greenhand = CC.Player.Inst():GetSelfInfoByKey("EPC_GreenHand") or 0
    if greenhand == 0 then
        local limit = SwitchDataMgr.GetSwitchStateByKey("TreasureGoods")
        if limit then
            return true
        else
            return false
        end
    else
        return false
    end
end

--mol
function SwitchDataMgr.ReturnMolSwitch(Condition, PlayerInfo)
    --游戏开发服开启三方
    if CC.DebugDefine.GetEnvState() == CC.DebugDefine.EnvState.StableDev then
        return true
    end
    --判断首充状态或流水
    if CC.HallUtil.IsFromADSource() or PlayerInfo.Turnover >= Condition.Turnover then
        return true
    else
        return false
    end
end

return SwitchDataMgr
