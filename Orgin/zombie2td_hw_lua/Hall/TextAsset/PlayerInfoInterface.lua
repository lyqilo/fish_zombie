-- ************************************************************
-- @File: PlayerInfoInterface.lua
-- @Summary: 暴露一些 get/set 用户信息的接口给子游戏
-- @Version: 1.0
-- @Author: luo qiu zhang
-- @Date: 2023-03-27 17:31:16
-- ************************************************************
local CC = require("CC")
local PlayerInfoInterface = {}
local M = {}
M.__index = function(t, key)
    if M[key] then
        return M[key]
    else
        return function()
            logError("无法访问 PlayerInfoInterface.lua 里 函数为 " .. key .. "() 的接口, 请确认接口名字")
        end
    end
end
setmetatable(PlayerInfoInterface, M)

function M.GetVipLevel()
    return CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
end

function M.GetNickName()
    return CC.Player.Inst():GetSelfInfoByKey("Nick")
end

function M.GetPlayerId()
    return CC.Player.Inst():GetSelfInfoByKey("Id")
end

function M.GetHallMoney()
    return CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
end

function M.GetHallDiamond()
    return CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi")
end

function M.GetHallIntegral()
    return CC.Player.Inst():GetSelfInfoByKey("EPC_New_GiftVoucher")
end

function M.GetHallRoomCard()
    return CC.Player.Inst():GetSelfInfoByKey("EPC_RoomCard")
end

function M.GetPortrait()
    return CC.Player.Inst():GetSelfInfoByKey("Portrait")
end

function M.GetHeadFrame()
    return CC.Player.Inst():GetSelfInfoByKey("Background")
end

function M.GetEntryEffect()
    return CC.Player.Inst():GetSelfInfoByKey("Effect")
end

function M.GetTelephone()
    return CC.Player.Inst():GetSelfInfoByKey("Telephone")
end

function M.GetPropNumByPropId(PropId)
    return CC.Player.Inst():GetSelfInfoByKey(PropId)
end

function M.GetThreshold()
    return CC.Player.Inst():GetThreshold()
end

function M.GetReliefLeftTimes()
    return CC.Player.Inst():GetLeftTimes()
end

function M.GetPlayerLoginData()
    return CC.Player.Inst():GetLoginInfo()
end

function M.GetJackpotsByID(GameId)
    return CC.Player.Inst():GetJackpotsByID(GameId)
end

function M.GetAgentLevel()
    return CC.Player.Inst():GetSelfInfoByKey("EPC_AgentLevel")
end

function M.IsShowRoomCard()
    return CC.Player.Inst():IsShowRoomCard()
end

function M.GetDailyGiftState()
    return CC.ChannelMgr.GetSwitchByKey("bHasGift") and CC.Player.Inst():GetDailyGiftState() or false
end

function M.ChangeHallUserProp(PropId, Count, Delta)
    local data = {
        Items = {
            {
                ConfigId = PropId,
                Count = Count,
                Delta = Delta
            }
        }
    }
    -- logError("改变大厅道具:"..id.. " 数量为:"..count);
    CC.Player.Inst():ChangeProp(data)
end

--[[
-- 传游戏ID检查解锁道具状态
--  true：购买过当前游戏解锁礼包
--  false：没购买或当前游戏无解锁礼包
]]
function M.CheckUnlockPropState(gameId)
    local gameId = gameId or CC.ViewManager.GetCurGameId()
    local HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
    if HallDefine.UnlockCondition[gameId] then
        local prop = HallDefine.UnlockCondition[gameId].Prop
        local propNum = CC.Player.Inst():GetSelfInfoByKey(prop) or 0
        if propNum > 0 then
            return true
        else
            return false
        end
    else
        return false
    end
end

-- 是否有新手引导
function M.IsHasGuide()
    local guideData = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetGuide()
    return (guideData.state and guideData.Flag < 1)
end

--[[
判断id玩家是否是当前玩家好友
]]
function M.IsFriendByID(id)
    return id and CC.DataMgrCenter.Inst():GetDataByKey("Friend").IsFriend(id) or false
end

return M
