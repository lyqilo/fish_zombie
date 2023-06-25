-- ************************************************************
-- @File: SoundInterface.lua
-- @Summary: 对子游戏暴露操作音效相关的接口
-- @Version: 1.0
-- @Author: luo qiu zhang
-- @Date: 2023-03-28 10:24:49
-- ************************************************************
local CC = require("CC")

local SoundInterface = {}
local M = {}
M.__index = function(t, key)
    if M[key] then
        return M[key]
    else
        return function()
            logError("无法访问 SoundInterface.lua 里 函数为 " .. key .. "() 的接口, 请确认接口名字")
        end
    end
end

setmetatable(SoundInterface, M)

function M.SetMusicVolumeTransition(data)
    local to = data.to
    local from = data.from
    local sound = CC.Sound
    local duration = data.duration
    if not duration then
        sound.SetMusicVolume(sound.GetMusicVolume(), to)
        return
    end

    local curTime = 0
    local timer = nil
    timer =
        CC.uu.StartTimer(
        0,
        function()
            curTime = curTime + Time.deltaTime
            sound.SetMusicVolume(sound.GetMusicVolume(), Mathf.Lerp(from, to, curTime / duration))
            if curTime >= duration then
                CC.uu.StopTimer(timer)
                sound.SetMusicVolume(sound.GetMusicVolume(), to)
            end
        end,
        -1
    )
end

function M.GetMusicVolume()
    return CC.Sound.GetMusicVolume()
end

function M.GetSoundVolume()
    return CC.Sound.GetEffectVolume()
end

function M.SetMusicVolume(value)
    CC.Sound.SetMusicVolume(value)
end

function M.SetEffectVolume(value)
    CC.Sound.SetEffectVolume(value)
end

function M.PlayBackgroundMusic(name, abName)
    CC.Sound.PlayBackMusic(name, nil, nil, abName)
end

function M.StopBackgroundMusic()
    CC.Sound.StopBackMusic()
end

function M.PlayEffect(name, abName)
    CC.Sound.PlayEffect(name, nil, nil, abName)
end

--循环播放音效
function M.PlayLoopEffect(audioName, abName)
    CC.Sound.PlayLoopEffect(audioName, abName)
end

--删除扩展的音效组件
function M.StopExtendEffect(audioName)
    CC.Sound.StopExtendEffect(audioName)
end

function M.Save()
    return CC.Sound.Save()
end

return M
