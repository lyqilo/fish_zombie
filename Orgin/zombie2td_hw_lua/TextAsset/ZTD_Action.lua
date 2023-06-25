
--[[
	动作工具类
]]
local GC = require("GC")
local tools = GC.uu

local ZTD_Action = {}

ZTD_Action.ELinear = 1--默认EaseType
ZTD_Action.EInSine = 2
ZTD_Action.EOutSine = 3
ZTD_Action.EInOutSine = 4
ZTD_Action.EInQuad = 5
ZTD_Action.EOutQuad = 6
ZTD_Action.EInOutQuad = 7
ZTD_Action.EInCubic = 8
ZTD_Action.EOutCubic = 9
ZTD_Action.EInOutCubic = 10
ZTD_Action.EInQuart = 11
ZTD_Action.EOutQuart = 12
ZTD_Action.EInOutQuart = 13
ZTD_Action.EInQuint = 14
ZTD_Action.EOutQuint = 15
ZTD_Action.EInOutQuint = 16
ZTD_Action.EInExpo = 17
ZTD_Action.EOutExpo = 18
ZTD_Action.EInOutExpo = 19
ZTD_Action.EInCirc = 20
ZTD_Action.EOutCirc = 21
ZTD_Action.EInOutCirc = 22
ZTD_Action.EInElastic = 23
ZTD_Action.EOutElastic = 24
ZTD_Action.EInOutElastic = 25
ZTD_Action.EInBack = 26
ZTD_Action.EOutBack = 27
ZTD_Action.EInOutBack = 28
ZTD_Action.EInBounce = 29
ZTD_Action.EOutBounce = 30
ZTD_Action.EInOutBounce = 31
ZTD_Action.EFlash = 32
ZTD_Action.EInFlash = 33
ZTD_Action.EOutFlash = 34
ZTD_Action.EInOutFlash = 35

ZTD_Action.LTRestart = 0 -- 默认LoopType
ZTD_Action.LTYoyo = 1
ZTD_Action.LTIncremental = 2

local Param = {
	ease = function( tween, aEaseType )
		return tween:Ease(aEaseType)
	end,
	loop = function( tween, aTimes, aLoopType )
		return tween:Loop(aTimes, aLoopType or ZTD_Action.LTRestart)
	end,
	delay = function( tween, aSecend )
		return tween:Delay(aSecend)
	end,
	from = function( tween )
		return tween:From()
	end,
	onStart = function( tween, ... )
		return ZTD_Action.SetCallBack(tween, 'OnStart', ...)
	end,
	onLoop = function( tween, ... )
		return ZTD_Action.SetCallBack(tween, 'OnStepComplete', ...)
	end,
	onEnd = function( tween, ... )
		return ZTD_Action.SetOnComplete(tween, ...)
	end
}

local Function = {
	localMoveBy = function( target, x, y, z, duration, ... )
		return ZTD_Action.SetOnComplete(DoTween.LocalMoveBy(target, Vector3(x,y,z), duration), ...)
	end,
	localMoveTo = function( target, x, y, z, duration, ... )
		return ZTD_Action.SetOnComplete(DoTween.LocalMoveTo(target, Vector3(x,y,z), duration), ...)
	end,
	moveBy = function( target, x, y, z, duration, camera, ... )
		return ZTD_Action.SetOnComplete(DoTween.MoveBy(target, Vector3(x,y,z), duration, camera), ...)
	end,
	moveTo = function( target, x, y, z, duration, camera, ... )
		return ZTD_Action.SetOnComplete(DoTween.MoveTo(target, Vector3(x,y,z), duration, camera), ...)
	end,
	rotateBy = function( target, x, y, z, duration, ... )
		return ZTD_Action.SetOnComplete(DoTween.RotateBy(target, Vector3(x, y, z), duration), ...)
	end,
	rotateTo = function( target, x, y, z, duration, ... )
		return ZTD_Action.SetOnComplete(DoTween.RotateTo(target, Vector3(x, y, z), duration), ...)
	end,
	scaleBy = function( target, x, y, duration, ... )
		return ZTD_Action.SetOnComplete(DoTween.ScaleBy(target, Vector3(x,y,1), duration), ...)
	end,
	scaleTo = function( target, x, y, z, duration, ... )
		return ZTD_Action.SetOnComplete(DoTween.ScaleTo(target, Vector3(x,y,z), duration), ...)
	end,
	fadeTo = function( target, opacity, duration, ... )
		return ZTD_Action.SetOnComplete(DoTween.FadeTo(target, opacity, duration), ...)
	end,
	fadeToAll = function( target, opacity, duration, ... )
		return ZTD_Action.SetOnComplete(DoTween.FadeToAll(target, opacity, duration), ...)
	end,
	colorTo = function( target, r, g, b, a, duration, ... )
		return ZTD_Action.SetOnComplete(DoTween.ColorTo(target, Color(r, g, b, a), duration), ...)
	end,
	colorToAll = function( target, r, g, b, a, duration, ... )
		return ZTD_Action.SetOnComplete(DoTween.ColorToAll(target, Color(r, g, b, a), duration), ...)
	end,
	delay = function( target, delay, ... )
		return ZTD_Action.SetOnComplete(ZTD_Action.NoneTo(target, delay), ...)
	end,
	call = function( target, ... )
		return ZTD_Action.SetOnComplete(ZTD_Action.NoneTo(target), ...)
	end,
	update = function( target, duration, ... )
		return ZTD_Action.SetCallBack(ZTD_Action.NoneTo(target, duration), 'OnUpdate', ...)
	end,
	to = function( target, startValue, endValue, duration, setter, ... )
		return ZTD_Action.SetOnComplete(DoTween.To(target, startValue, endValue, duration, setter), ...)
	end,
	spawn = function( target, ... )
		return ZTD_Action.SequenceAction( target, {...}, "Insert" )
	end,
	FadeParticleColor = function( target, r, g, b, a, duration, ... )
		return ZTD_Action.SetOnComplete(DoTween.FadeParticleColor(target, Color(r, g, b, a), duration), ...)
	end,
	shakePosition = function( target, duration, strength, vibrato, randomness, snapping, ... )
		return ZTD_Action.SetOnComplete(DoTween.ShakePosition(target, duration, strength, vibrato, randomness, snapping), ...)
	end
}

function ZTD_Action.RunAction( target, Action )
	--这个方法的存在只是为了确保Zombie_Action.Run使用的target是transform
	return ZTD_Action.Run(target.transform or target, Action)
end

function ZTD_Action.SetCallBack(tween, callback, aFunc, ...)
	if aFunc and tools.isFunction(aFunc) then
		local args = {...}
		return tween[callback](tween, #args == 0 and aFunc or function()
			aFunc(unpack(args))
		end)
	end
	return tween
end

function ZTD_Action.SetOnComplete(tween, aFunc, ...)
	return ZTD_Action.SetCallBack(tween, 'OnComplete', aFunc, ...)
end

function ZTD_Action.NoneTo( target, duration )
	return DoTween.NoneTo(target, duration or 0.0001)
end

function ZTD_Action.SetParam( tween, Action ,funcName)
	if tween then
		for name, param in pairs(Action) do
			if tools.isString(name) then
				if tools.isTable(param) then
					tools.SafeCallFunc(Param[name], tween, unpack(param))
				else
					tools.SafeCallFunc(Param[name], tween, param)
				end
			end
		end
	else
		log("ZTD_Action not find : "..funcName)
	end
	return tween
end

function ZTD_Action.SequenceAction( target, Action, opt )
	--opt: "Append" 动作数组按顺序执行
	--opt: "Insert" 动作数组同时执行
	local sequence = DoTween.Sequence()
	for _, act in ipairs(Action) do
		if tools.isTable(act) then
			if opt == "Append" then
				sequence:Append(ZTD_Action.Run(target, act))
			elseif opt == "Insert" then
				sequence:Insert(ZTD_Action.Run(target, act))
			end
		end
	end
	return ZTD_Action.SetParam(sequence, Action)
end

function ZTD_Action.Run( target, Action )
	--执行Zombie_Action
	return ZTD_Action.CreateAction( target, Action, unpack(Action) )
end

function ZTD_Action.CreateAction( target, Action, funcName, ... )
	if tools.isString(funcName) then
		--unpack(Action)得到的第一个参数funName是一个字符串，代表一个动作
		local actFunc = Function[funcName]
		local tween = tools.SafeDoFunc(actFunc, target, ...)
		tween = ZTD_Action.SetParam(tween, Action, funcName )
		return tween
	elseif tools.isTable(funcName) then
		--unpack(Action)得到的第一个参数funName是一个table，表示Zombie_Action是一个动作数组，需要拆分其动作并组合成数组动作
		return ZTD_Action.SequenceAction( target, Action, "Append" )
	elseif tools.isFunction(funcName) then
		--unpack(Action)得到的第一个参数funName是一个function,表示这个动作只是执行这个function
		return Function.call(target, funcName, ...)
	end
end

--延迟
function ZTD_Action.DelayTime(target,duration)
	return DoTween.NoneTo(target, duration or 0.0001)
end

--调用方法
function ZTD_Action.CallFunc(target,func)
	local tween = DoTween.NoneTo(target, 0.0001)
	return tween.OnComplete(tween,func)
end

--延迟调用
function ZTD_Action.DelayCallFunc(target,duration,func)
	local tween = DoTween.NoneTo(target, duration)
	return tween.OnComplete(tween,func)
end

--队列
function ZTD_Action.Sequence(acts)
	local sequence = DoTween.Sequence()
	for _, act in ipairs(acts) do
		sequence:Append(act)
	end
	return sequence
end

--用于按钮点击缩放
function ZTD_Action.ScaleInOut(target,ScaleInOutTime)
	ScaleInOutTime = ScaleInOutTime or 0.15
	local tween1 = DoTween.ScaleTo(target, Vector3(0.9,0.9,1), ScaleInOutTime/2)
	local tween2 = DoTween.ScaleTo(target, Vector3(1,1,1), ScaleInOutTime/2)
	return ZTD_Action.Sequence({tween1,tween2})
end


--同时播放多个动作
function ZTD_Action.Spawn(acts)
	local sequence = DoTween.Sequence()
	for _, act in ipairs(acts) do
		sequence:Insert(act)
	end
	return sequence
end

return ZTD_Action

