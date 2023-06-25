
--[[
	使用前必读！所有View的Base类，封装了一些公用方法，可以被继承使用！
	Attentions！！！！注意！！！！
	子游戏如果继承了该类，下面三个方法必须重写！！！
	ViewBase:GlobalNode()
	ViewBase:GlobalCamera()
	ViewBase:GlobalLayer()
	这三个方法是获取大厅场景的公用节点：
	ViewBase:GlobalNode() 应该返回子游戏挂载UI的根节点
	ViewBase:GlobalCamera() 应该返回子游戏显示UI的相机组件
	ViewBase:GlobalLayer() 应该填写子游戏view的layer标识，可为空！（"layer31"仅作为大厅ui的tag）

	PS:
	self.viewName和self.bundleName这两个参数是在ClassView时定义的类属性
]]

local GC = require("GC")
local ZTD = require("ZTD")

local ViewBase = GC.class2("ViewBase")

function ViewBase:ctor(...)
	--构造函数，会递归执行父类的初始化，不会像其他函数一样被重写
	--self.viewName和self.bundleName这两个参数是在ClassView时定义的类属性
	self.viewName = self.viewName
	self.bundleName = self.bundleName
	self._timers = {}
	self._cos = {}
	self._actions = {}
	self._addClickNodes = {}
	self._args = {...}
	self._effList = {}
	self:RegisterBaseEvent()
end

function ViewBase:GlobalNode()
	logError("！！！注意,你必须重写该方法！"..debug.traceback())
end

function ViewBase:GlobalCamera()
	logError("！！！注意,你必须重写该方法！"..debug.traceback())
end

function ViewBase:GlobalLayer()
	logWarn("！！！注意,你可选着重写该方法！"..debug.traceback())
	return nil
end

function ViewBase:Func( funcName )
	return function( ... )
		local func = self[funcName]
		if func then
			func( self, ... )
		else
			logError("no func "..self.viewName..":"..funcName)
		end
	end
end

function ViewBase:RegisterBaseEvent()
	GC.HallNotificationCenter.inst():register(self,self.OnMenuBack,GC.Notifications.OnMenuBack)
	GC.HallNotificationCenter.inst():register(self,self.OnPause,GC.Notifications.OnPause)
	GC.HallNotificationCenter.inst():register(self,self.OnResume,GC.Notifications.OnResume)
end

function ViewBase:Create()
	self.transform = ResMgr.LoadPrefab(self.bundleName, 
		self.viewName,
		self:GlobalNode(),
		self.viewName,
		self:GlobalLayer())
	self:OnCreate()
end

--[[
	destroyOnLoad:是否让场景销毁的同时异步销毁节点
]]
function ViewBase:Destroy(destroyOnLoad)
	self:RemoveAllEff()
	self:RemoveAllClick()

	self:StopAllTimer()
	self:StopAllAction()
	GC.HallNotificationCenter.inst():unregisterAll(self)
	self:OnDestroy(destroyOnLoad)
	self:OnDestroyFinish()
	if destroyOnLoad ~= true then
		coroutine.start(function()
			GC.uu.destroyObject(self)
		end)
	end
end

function ViewBase:OnCreate()
	--待重写（创建view节点成功后干啥）
end

function ViewBase:OnDestroy(destroyOnLoad)
	--待重写（view节点被消除前应该干啥）
end

function ViewBase:OnDestroyFinish()
	--待重写
	--该重写仅仅被ViewManager使用，用来管理view
end

function ViewBaseOnMenuBack()
	--待重写（安卓返回键监听）
end

function ViewBase:OnPause()
	--待重写（应用暂停操作）
end

function ViewBase:OnResume()
	--待重写（应用重新响应操作）
end
function ViewBase:
Assert( obj, err )
	if not obj then
		logError(err)
	end
	return obj
end

function ViewBase:FindChild(childNodeName)
	return self:Assert(self.transform:FindChild(childNodeName), "child not find "..childNodeName)
end

function ViewBase:Hide(childNodeName)
	self:SetActive(childNodeName, false)
end

function ViewBase:Show(childNodeName)
	self:SetActive(childNodeName, true)
end

function ViewBase:SetActive( childNodeName, bActive )
	local obj = not childNodeName and self.transform or self:FindChild(childNodeName)
	if obj then
		obj:SetActive(bActive)
	end
end

function ViewBase:AddComponent(cstype)
	return self.transform:AddComponent(typeof(cstype))
end

function ViewBase:GetComponent(typeName)
	return self:Assert(self.transform:GetComponent(typeName), "GetComponent component not find : "..typeName)
end

function ViewBase:SubAdd( childNodeName, cstype )
	return self:FindChild(childNodeName):AddComponent(typeof(cstype))
end

function ViewBase:SubGet( childNodeName, typeName )
	local obj = self:FindChild(childNodeName)
	if obj then
		return self:Assert(obj:GetComponent(typeName), "SubGet component not find : "..childNodeName.."."..typeName)
	end
end

function ViewBase:SetText( childNodeName, text )
	local obj = childNodeName;
	if GC.uu.isString(childNodeName) then
		obj = self:FindChild(childNodeName)
	end
	if obj then
		obj.text = text
	end
end

function ViewBase:SetNodeText(trans, childNodeName, text )
	local obj = childNodeName;
	if GC.uu.isString(childNodeName) then
		obj = trans:FindChild(childNodeName)
	end
	if obj then
		obj.text = text
	end
end

function ViewBase:GetText( childNodeName )
	local obj = self:FindChild(childNodeName)
	return obj and obj.text or ""
end

function ViewBase:SetImage( childNodeName, nameOrTexture )
	local obj = self:FindChild(childNodeName)
	if obj then
		obj:SetImage(nameOrTexture)
	end
end

function ViewBase:AddClick(node, func, clickSound, delayRuns, isScale)
	clickSound = clickSound or "click"
	delayRuns = tonumber(delayRuns) or false
	if GC.uu.isString(func) then 
		func = self:Func(func) 
	end
	if GC.uu.isString(node) then
		node = self:FindChild(node)
	end
	--在按下时就播放音效，解决音效延迟问题
	if node then
		node.onDown = function (obj, eventData)
			GC.Sound.PlayEffect(clickSound)
			if isScale then
				self:RunAction(node, {"spawn",{"fadeToAll", 255, 0.05}, { "scaleTo", 0.9, 0.9, 0.05, ease = GC.Action.EOutBack}})
			end
		end

		node.onUp = function (obj, eventData)
			if isScale then
				self:RunAction(node, {"spawn",{"fadeToAll", 255, 0.05}, { "scaleTo", 1, 1, 0.05, ease = GC.Action.EOutBack}})
			end
		end

		node.onClick = function(obj, eventData)
			local enable = true
			if node == self.transform then
				if eventData.rawPointerPress ~= eventData.pointerPress then
					enable = false
				end
			end
			if enable then
				if delayRuns then
					GC.uu.DelayRun(delayRuns,function()
						func(obj, eventData)
					end)
				else
					func(obj, eventData)
				end
			end
		end

		table.insert(self._addClickNodes,node)
	end
end

function ViewBase:RemoveAllClick()
	for _,node in ipairs(self._addClickNodes) do
		if tostring(node) ~= "null" then
			node.onDown = nil
			node.onUp = nil
			node.onClick = nil
		end
	end
	self._addClickNodes = {}
end

function ViewBase:AddPrefab( prefab, parent, name, pos )
	local obj = GC.uu.newObject( prefab ).transform
	if name then obj.name = tostring(name) end
	obj:SetParent(parent.transform)
	obj.localScale = Vector3.one
	obj.localPosition = pos or Vector3.zero
	return obj
end

function ViewBase:SetTransform(trans, parent, name, pos)
	if name then trans.name = tostring(name) end
	trans:SetParent(parent.transform)
	trans.localPosition = pos or Vector3.zero
end

function ViewBase:DelayRun( second, func)
	local key = ZTD.GameTimer.DelayRun(second, func)
	self._timers[key] = key
	return key
end

function ViewBase:StartTimer( key, interval, func, times )
	ZTD.GameTimer.StopTimer(key)
	ZTD.GameTimer.StartTimerWithKey(key, func, interval or 0,times or -1,false)
    self._timers[key] = key
    return key
end

function ViewBase:StopTimer(key)
	if not key or not self._timers[key] then  return  end 
    ZTD.GameTimer.StopTimer(key)
    self._timers[key] = nil
end

function ViewBase:StopAllTimer()
	for _, key in pairs(self._timers) do
		ZTD.GameTimer.StopTimer(key)
	end
	self._timers = {}
end

function ViewBase:RunAction(target, action)
	if GC.uu.isString(target) then
		target = self:FindChild(target)
	end
	local tween = GC.Action.RunAction(target, action)
	table.insert(self._actions,tween)
	return tween
end

function ViewBase:StopAction(tween, beComplete)
	for key, action in pairs(self._actions) do
		if tween == action then
			action:Kill(beComplete or false)
			action:Destroy()
			self._actions[key] = nil
			break
		end
	end
end

function ViewBase:StopAllAction(beComplete)
	for _, action in pairs(self._actions) do
        action:Kill(beComplete or false)
        action:Destroy()
        action = nil
    end
    self._actions = {}
end


--播放特效
--name 特效名字, parent, duration持续时间
function ViewBase:PlayEff(name, parent, duration)
	local eff, effID = ZTD.EffectManager.PlayEffect(name, parent, true)
	if duration and duration > 0 then
		self:DelayRun(duration, function ()
			self:RemoveEff(effID)
		end)
	end
	
	self._effList[effID] = eff
	return eff, effID
end
--播放特效
function ViewBase:RemoveEff(effID)
	ZTD.EffectManager.RemoveEffectByID(effID)
	self._effList[effID] = nil
end


function ViewBase:RemoveAllEff()
	for id,v in ipairs(self._effList) do
		ZTD.EffectManager.RemoveEffectByID(id)
	end
	self._effList = {}
end


return ViewBase