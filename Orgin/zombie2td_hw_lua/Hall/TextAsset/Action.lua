
--[[
	动作工具类
]]
local CC = require("CC")

local Action = {}

Action.ELinear = 1--默认EaseType
Action.EInSine = 2
Action.EOutSine = 3
Action.EInOutSine = 4
Action.EInQuad = 5
Action.EOutQuad = 6
Action.EInOutQuad = 7
Action.EInCubic = 8
Action.EOutCubic = 9
Action.EInOutCubic = 10
Action.EInQuart = 11
Action.EOutQuart = 12
Action.EInOutQuart = 13
Action.EInQuint = 14
Action.EOutQuint = 15
Action.EInOutQuint = 16
Action.EInExpo = 17
Action.EOutExpo = 18
Action.EInOutExpo = 19
Action.EInCirc = 20
Action.EOutCirc = 21
Action.EInOutCirc = 22
Action.EInElastic = 23
Action.EOutElastic = 24
Action.EInOutElastic = 25
Action.EInBack = 26
Action.EOutBack = 27
Action.EInOutBack = 28
Action.EInBounce = 29
Action.EOutBounce = 30
Action.EInOutBounce = 31
Action.EFlash = 32
Action.EInFlash = 33
Action.EOutFlash = 34
Action.EInOutFlash = 35

Action.LTRestart = 0 -- 默认LoopType
Action.LTYoyo = 1
Action.LTIncremental = 2

local Param = {
	ease = function( tween, aEaseType )
		return tween:Ease(aEaseType)
	end,
	loop = function( tween, aTimes, aLoopType )
		return tween:Loop(aTimes, aLoopType or Action.LTRestart)
	end,
	delay = function( tween, aSecend )
		return tween:Delay(aSecend)
	end,
	from = function( tween )
		return tween:From()
	end,
	onStart = function( tween, ... )
		return Action.SetCallBack(tween, 'OnStart', ...)
	end,
	onLoop = function( tween, ... )
		return Action.SetCallBack(tween, 'OnStepComplete', ...)
	end,
	onEnd = function( tween, ... )
		return Action.SetOnComplete(tween, ...)
	end
}

local Function = {
	localMoveBy = function( target, x, y, duration, ... )
		return Action.SetOnComplete(DoTween.LocalMoveBy(target, Vector3(x,y,0), duration), ...)
	end,
	localMoveTo = function( target, x, y, duration, ... )
		return Action.SetOnComplete(DoTween.LocalMoveTo(target, Vector3(x,y,0), duration), ...)
	end,
	localMoveBy3D = function( target, x, y, z, duration, ... )
		return Action.SetOnComplete(DoTween.LocalMoveBy(target, Vector3(x,y,z), duration), ...)
	end,
	localMoveTo3D = function( target, x, y, z, duration, ... )
		return Action.SetOnComplete(DoTween.LocalMoveTo(target, Vector3(x,y,z), duration), ...)
	end,
	moveBy = function( target, x, y, duration,camera, ... )
		return Action.SetOnComplete(DoTween.MoveBy(target, Vector3(x,y,0), duration,camera), ...)
	end,
	moveTo = function( target, x, y, duration,camera, ... )
		return Action.SetOnComplete(DoTween.MoveTo(target, Vector3(x,y,0), duration,camera), ...)
	end,
	rotateBy = function( target, angle, duration, ... )
		return Action.SetOnComplete(DoTween.RotateBy(target, Vector3(0,0,-angle), duration), ...)
	end,
	rotateTo = function( target, angle, duration, ... )
		return Action.SetOnComplete(DoTween.RotateTo(target, Vector3(0,0,-angle), duration), ...)
	end,
	rotateBy3D = function( target, x, y, z, duration, ... )
		return Action.SetOnComplete(DoTween.RotateBy(target, Vector3(x,y,z), duration), ...)
	end,
	rotateTo3D = function( target, x, y, z, duration, ... )
		return Action.SetOnComplete(DoTween.RotateTo(target, Vector3(x,y,z), duration), ...)
	end,
	scaleBy = function( target, x, y, duration, ... )
		return Action.SetOnComplete(DoTween.ScaleBy(target, Vector3(x,y,1), duration), ...)
	end,
	scaleTo = function( target, x, y, duration, ... )
		return Action.SetOnComplete(DoTween.ScaleTo(target, Vector3(x,y,1), duration), ...)
	end,
	scaleToEx = function( target, x, y, z, duration, ... )
		return Action.SetOnComplete(DoTween.ScaleTo(target, Vector3(x,y,z), duration), ...)
	end,
	fadeTo = function( target, opacity, duration, ... )
		return Action.SetOnComplete(DoTween.FadeTo(target, opacity, duration), ...)
	end,
	fadeToAll = function( target, opacity, duration, ... )
		return Action.SetOnComplete(DoTween.FadeToAll(target, opacity, duration), ...)
	end,
	colorTo = function( target, r, g, b, a, duration, ... )
		return Action.SetOnComplete(DoTween.ColorTo(target, Color(r, g, b, a), duration), ...)
	end,
	colorToAll = function( target, r, g, b, a, duration, ... )
		return Action.SetOnComplete(DoTween.ColorToAll(target, Color(r, g, b, a), duration), ...)
	end,
	delay = function( target, delay, ... )
		return Action.SetOnComplete(Action.NoneTo(target, delay), ...)
	end,
	call = function( target, ... )
		return Action.SetOnComplete(Action.NoneTo(target), ...)
	end,
	update = function( target, duration, ... )
		return Action.SetCallBack(Action.NoneTo(target, duration), 'OnUpdate', ...)
	end,
	to = function( target, startValue, endValue, duration, setter, ... )
		return Action.SetOnComplete(DoTween.To(target, startValue, endValue, duration, setter), ...)
	end,
	spawn = function( target, ... )
		return Action.SequenceAction( target, {...}, "Insert" )
	end,
	FadeParticleColor = function( target, r, g, b, a, duration, ... )
		return Action.SetOnComplete(DoTween.FadeParticleColor(target, Color(r, g, b, a), duration), ...)
	end,
	shakePosition = function( target, duration, strength, vibrato, randomness, snapping, ... )
		return Action.SetOnComplete(DoTween.ShakePosition(target, duration, strength, vibrato, randomness, snapping), ...)
	end
}

function Action.RunAction( target, action )
	--这个方法的存在只是为了确保Action.Run使用的target是transform
	return Action.Run(target.transform or target, action)
end

function Action.SetCallBack(tween, callback, aFunc, ...)
	if aFunc and CC.uu.isFunction(aFunc) then
		local args = {...}
		return tween[callback](tween, #args == 0 and aFunc or function()
			aFunc(unpack(args))
		end)
	end
	return tween
end

function Action.SetOnComplete(tween, aFunc, ...)
	return Action.SetCallBack(tween, 'OnComplete', aFunc, ...)
end

function Action.NoneTo( target, duration )
	return DoTween.NoneTo(target, duration or 0.0001)
end

function Action.SetParam( tween, action ,funcName)
	if tween then
		for name, param in pairs(action) do
			if CC.uu.isString(name) then
				if CC.uu.isTable(param) then
					CC.uu.SafeCallFunc(Param[name], tween, unpack(param))
				else
					CC.uu.SafeCallFunc(Param[name], tween, param)
				end
			end
		end
	else
		if CC.uu.isString(funcName) then
			log("Action.SetParam action not find : "..funcName)
		elseif CC.uu.isTable(funcName) then
			logError("Action.SetParam table")
			CC.uu.Log(funcName)
		else
			logError("Action.SetParam other")
		end
	end
	return tween
end

function Action.SequenceAction( target, action, opt )
	--opt: "Append" 动作数组按顺序执行
	--opt: "Insert" 动作数组同时执行
	local sequence = DoTween.Sequence()
	for _, act in ipairs(action) do
		if CC.uu.isTable(act) then
			if opt == "Append" then
				sequence:Append(Action.Run(target, act))
			elseif opt == "Insert" then
				sequence:Insert(Action.Run(target, act))
			end
		end
	end
	return Action.SetParam(sequence, action)
end

function Action.Run( target, action )
	--执行Action
	return Action.CreateAction( target, action, unpack(action) )
end

function Action.CreateAction( target, action, funcName, ... )
	if CC.uu.isString(funcName) then
		--unpack(action)得到的第一个参数funName是一个字符串，代表一个动作
		local actFunc = Function[funcName]
		local tween = CC.uu.SafeDoFunc(actFunc, target, ...)
		tween = Action.SetParam(tween, action, funcName )
		return tween
	elseif CC.uu.isTable(funcName) then
		--unpack(action)得到的第一个参数funName是一个table，表示action是一个动作数组，需要拆分其动作并组合成数组动作
		return Action.SequenceAction( target, action, "Append" )
	elseif CC.uu.isFunction(funcName) then
		--unpack(action)得到的第一个参数funName是一个function,表示这个动作只是执行这个function
		return Function.call(target, funcName, ...)
	end
end

--延迟
function Action.DelayTime(target,duration)
	return DoTween.NoneTo(target, duration or 0.0001)
end

--调用方法
function Action.CallFunc(target,func)
	local tween = DoTween.NoneTo(target, 0.0001)
	return tween.OnComplete(tween,func)
end

--延迟调用
function Action.DelayCallFunc(target,duration,func)
	local tween = DoTween.NoneTo(target, duration)
	return tween.OnComplete(tween,func)
end

--队列
function Action.Sequence(acts)
	local sequence = DoTween.Sequence()
	for _, act in ipairs(acts) do
		sequence:Append(act)
	end
	return sequence
end

--用于按钮点击缩放
function Action.ScaleInOut(target,ScaleInOutTime)
	ScaleInOutTime = ScaleInOutTime or 0.15
	local tween1 = DoTween.ScaleTo(target, Vector3(0.9,0.9,1), ScaleInOutTime/2)
	local tween2 = DoTween.ScaleTo(target, Vector3(1,1,1), ScaleInOutTime/2)
	return Sequence({tween1,tween2})
end


--同时播放多个动作
function Action.Spawn(acts)
	local sequence = DoTween.Sequence()
	for _, act in ipairs(acts) do
		sequence:Insert(act)
	end
	return sequence
end

return Action

