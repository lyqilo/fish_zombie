-- ************************************************************
-- @File: EventInterface.lua
-- @Summary: 子游戏操作一些事件,记录等接口
-- @Version: 1.0
-- @Author: luo qiu zhang
-- @Date: 2023-04-06 15:29:18
-- ************************************************************
local CC = require("CC")
local EventInterface = {}
local M = {}
M.__index = function(t, key)
    if M[key] then
        return M[key]
    else
        return function()
            logError("无法访问 EventInterface.lua 里 函数为 " .. key .. "() 的接口, 请确认接口名字")
        end
    end
end
setmetatable(EventInterface, M)

--[[
游戏行为计数（每天重置）
gameId：游戏id
action:行为的key，游戏自行定义
count:自定义计数基数，不传默认1
*********gameId和action不能为nil********
列：进入游戏次数,param = {gameId = 1001, action = "EnterGameCount", count = 1}
]]
function M.SetGameActionCount(param)
    CC.LocalGameData.SetGameActionCount(param.gameId, param.action, param.count)
end

--获得游戏行为计数
function M.GetGameActionCount(param)
    log(
        string.format(
            "%s游戏的 %s行为次数: %s",
            param.gameId,
            param.action,
            CC.LocalGameData.GetGameActionCount(param.gameId, param.action)
        )
    )
    return CC.LocalGameData.GetGameActionCount(param.gameId, param.action)
end

function M.TrackLogGameEvent(key, data)
    CC.FirebasePlugin.TrackLogGameEvent(key, data)
end

function M.TrackEnterMatchGame(gameId)
    CC.FirebasePlugin.TrackEnterMatchGame(gameId)
end

return M
