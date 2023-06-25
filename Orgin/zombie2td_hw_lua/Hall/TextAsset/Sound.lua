
--[[
	为什么不在这个文件内保存上一次的bgm名字呢？
	因为大厅和子游戏都用这个声音管理，避免互相影响，bgm开关之后，需要自己去开关bgm
]]

local CC = require("CC")

local Sound = {}

--音乐音量百分比(0~1)
local _musicVolum = 0.5
--音乐音量系数(0~1)
local _musicVolumMul = 1
--音效音量百分比
local _effectVolum = 1
--音效音量系数
local _effectVolumMul = 1

local _musicName = nil
local _musicAbName = nil

local _effectAudio = nil

--声音配置本地保存路径
local _savePath = "voiceCfg"

--声音配置初始化
function Sound.Init()
    local voiceCfg = CC.UserData.Load(_savePath,{_musicVolum = 0.5, _effectVolum = 1})
    _musicVolum = tonumber(voiceCfg._musicVolum) or 0.5
    _effectVolum = tonumber(voiceCfg._effectVolum) or 1
end

--播放背景音乐
function Sound.PlayBackMusic(name, volum, volumMul, abName)
	local volum = volum or _musicVolum
	local volumMul = volumMul or 1;
	if name and name ~= "" then
		LuaFramework.SoundManager.SetBackMusicVolume(volum * volumMul)
		LuaFramework.SoundManager.PlayBacksound(name, true, abName or "sound")
		_musicName = name
		_musicAbName = abName
	end
end

function Sound.PlayHallBackMusic(name, volum, volumMul)
	if name == _musicName then return end
	local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Sound[name];
	Sound.PlayBackMusic(name, volum, volumMul, abName);
end

--停止播放背景音乐
--只，针对需要主动关闭背景音乐的情况,例如有些情况不需要播放背景音乐
function Sound.StopBackMusic()
	LuaFramework.SoundManager.PlayBacksound("",false)
	_musicName = nil
end

function Sound.GetMusicName()
	return _musicName
end

function Sound.SetMusicVolume(volum, volumMul)
	_musicVolum = volum or 0.5
	_musicVolumMul = volumMul or 1
	LuaFramework.SoundManager.SetBackMusicVolume(_musicVolum * _musicVolumMul)
end

function Sound.GetMusicVolume()
	return _musicVolum
end

--播放音效
function Sound.PlayEffect(name, volum, volumMul, abName)
	local volum = volum or _effectVolum
	local volumMul = volumMul or 1
    if volum ~= 0 and name and name ~= "" then
	    LuaFramework.SoundManager.PlaySound(name, volum * volumMul, abName or "sound")
    end
end

function Sound.PlayHallEffect(name, volum, volumMul)

	local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Sound[name];
	Sound.PlayEffect(name, volum, volumMul, abName);
end

function Sound.StopEffect()
	if not _effectAudio then
		local effectAudio = GameObject.Find("effectAudio")
		if not effectAudio then return end
		_effectAudio = effectAudio:GetComponent("AudioSource")
	end
	_effectAudio:Stop();
end

function Sound.SetEffectVolume(volum, volumMul)
	_effectVolum = volum or 1
	_effectVolumMul = volumMul or 1
	LuaFramework.SoundManager.SetSoundVolume(_effectVolum * _effectVolumMul)
end

function Sound.GetEffectVolume()
	return _effectVolum
end

--设置完声音，需要调用一句这个代码
function Sound.Save()
	local content = {_musicVolum = _musicVolum, _effectVolum = _effectVolum}
	CC.UserData.Save(_savePath,content)
end

----------------功能扩展------------------

local _audioComponents = {};

--循环播放音效
function Sound.PlayLoopEffect(audioName, abName)
	if not audioName or audioName == "" then return end
    Sound.StopExtendEffect(audioName);
    local audio = LuaFramework.SoundManager.PlayExtendSound(audioName, _effectVolum, abName or "sound");
    if not audio then return end
    audio.loop = true;
    audio:Play();
    _audioComponents[audioName] = audio;
end

function Sound.PlayHallLoopEffect(name)
	if not name or name == "" then return end
	local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Sound[name];
	Sound.PlayLoopEffect(name, abName);
end

--删除扩展的音效组件
function Sound.StopExtendEffect(audioName)
	if not audioName or audioName == "" then return end
    if _audioComponents[audioName] then
        LuaFramework.SoundManager.StopExtendSound(_audioComponents[audioName]);
        _audioComponents[audioName] = nil;
    end
end

--释放所有扩展的音效组件
function Sound.ExtendAudioRelease()
    for name,audio in pairs(_audioComponents) do
        if audio then
            Sound.StopExtendEffect(name);
        end
    end
    _audioComponents = {};
end

--Attentions!!!下面API弃用
--设置背景音乐开关
function Sound.SetBackMusicToggle(tog)
	logError("！！！该API已废弃！\n" .. debug.traceback())
end
--获取音乐开关
function Sound.GetBackMusicToggle()
	logError("！！！该API已废弃！\n" .. debug.traceback())
end
--设置音效开关
function Sound.SetEffectToggle(tog)
	logError("！！！该API已废弃！\n" .. debug.traceback())
end
--获取音效开关
function Sound.GetEffectToggle()
	logError("！！！该API已废弃！\n" .. debug.traceback())
end
function Sound.Play()
	logError("！！！该API已废弃！请使用Sound.PlayEffect\n" .. debug.traceback())
end
function Sound.SetToggle()
	logError("！！！该API已废弃，请使用Sound.SetBackMusicToggle/Sound.SetEffectToggle\n" .. debug.traceback())
end
function Sound.GetToggle()
	logError("！！！该API已废弃，请使用Sound.GetBackMusicToggle/Sound.GetEffectToggle\n" .. debug.traceback())
	return false
end
function Sound.GetCombinToggle()
	logError("！！！该API已废弃,请使用Sound.SetBackMusicToggle/Sound.SetEffectToggle\n" .. debug.traceback())
end

return Sound

