local CC = require("CC")
local baseClass = CC.class2("ViewUIBase")

local create = function ( viewName , bundleName, parent )
	local transform,isCreate
	if type(viewName) == "string" then
		transform = CC.uu.LoadHallPrefab(bundleName or "prefab", viewName, parent)
		isCreate = true
	else
		transform = viewName
	end
	return transform,isCreate
end

--[[
	非界面prefab 子ui class
]]
function baseClass:ctor()
	self.bundleName = nil
	self.viewName = nil

	self._timers = {}
	self._cos = {}
	self._actions = {}
end

function baseClass:OnCreate(...)
	-- body
end

function baseClass:OnShow( ... )
	-- body
end

function baseClass:OnHide( ... )
	-- body
end

function baseClass:OnDestroy( ... )
	-- body
end

function baseClass:Init( prefabNameOrTransform, parent, ...)
	self.transform,self.isCreate = create(self.viewName or prefabNameOrTransform,self.bundleName,parent)
	self.gameObject = self.transform.gameObject
	if self.isCreate and parent then
		self.gameObject.layer = parent.gameObject.layer
	end
	self.isActive = self.gameObject.activeSelf
	self:OnCreate(...)
	if self.isActive then
		self:OnShow()
	else
		self:OnHide()
	end
end

function baseClass:SetParentAndLayer( parent, layer )
	if parent then
		self.transform:SetParent(parent,false)
	end
	if layer then
		self.gameObject.layer = layer
	end
end

function baseClass:SetActive( bActive, ... )
	if self.isActive == bActive then
		return
	end
	self.gameObject:SetActive(bActive)
	self.isActive = bActive
	if self.isActive then
		self:OnShow(...)
	else
		self:OnHide(...)
	end
end

function baseClass:Assert( obj, err )
	if not obj then
		logError(err)
	end
	return obj
end

function baseClass:FindChild( childNodeName )
	return self.transform:Find(childNodeName)
end

function baseClass:GetComponent( childNodeName,typeName )
	local tr = self.transform:Find(childNodeName)
	if CC.uu.IsNil(tr) then
		logError("!!!!!!!!!!!!! can not find "..childNodeName)
		return
	end
	return tr:GetComponent(typeName)
end

function baseClass:SubGet( childNodeName, typeName )
	local obj = self:FindChild(childNodeName)
	if obj then
		return self:Assert(obj:GetComponent(typeName), "SubGet component not find : "..childNodeName.."."..typeName)
	end
end

function baseClass:Destroy( isDestroyObj )
	self:CancelAllDelayRun()
	self:StopAllTimer()
	self:StopAllAction()
	self:OnDestroy()
	if self.isCreate and isDestroyObj then
		if self.transform then
			CC.uu.destroyObject(self.transform);
			self.transform = nil;
		end
	end
end

function baseClass:Func( funcName )
	return function( ... )
		local func = self[funcName]
		if func then
			func( self, ... )
		else
			logError("no func "..self.viewName..":"..funcName)
		end
	end
end

function baseClass:AddClick(node, func, clickSound, delayRuns, isScale)
	clickSound = clickSound or "click"
	delayRuns = tonumber(delayRuns) or false
	if CC.uu.isString(func) then
		func = self:Func(func)
	end
	if CC.uu.isString(node) then
		node = self:FindChild(node)
	end
	--在按下时就播放音效，解决音效延迟问题
	if node then
		node.onDown = function (obj, eventData)
			CC.Sound.PlayEffect(clickSound)
			if isScale then
				self:RunAction(node, {"spawn",{"fadeToAll", 255, 0.05}, { "scaleTo", 0.9, 0.9, 0.05, ease = CC.Action.EOutBack}})
			end
		end

		node.onUp = function (obj, eventData)
			if isScale then
				self:RunAction(node, {"spawn",{"fadeToAll", 255, 0.05}, { "scaleTo", 1, 1, 0.05, ease = CC.Action.EOutBack}})
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
					CC.uu.DelayRun(delayRuns,function()
						func(obj, eventData)
					end)
				else
					func(obj, eventData)
				end
			end
		end
	end
end

function baseClass:AddLongClick(node, param)
	local funcClick = param.funcClick;
	local funcLongClick = param.funcLongClick;
	local funcDown = param.funcDown;
	local funcUp = param.funcUp;
	local time = param.time or 0.5;
	local clickSound = param.clickSound or "click";
	local longClickSound = param.longClickSound or "click";

	self.__longClickCount = self.__longClickCount and self.__longClickCount + 1 or 0;
	local curCount = self.__longClickCount

	if CC.uu.isString(node) then
		node = self:FindChild(node)
	end

	local DelayCo = nil

	node.onDown = function(obj, eventData)
		local minTime = time/32
		local delayTime = time
		local LongClickFunc
		LongClickFunc = function()
			if eventData.pointerCurrentRaycast.gameObject == node.gameObject then
				self.__longClickFlag = true;
				funcLongClick(obj, eventData)
				CC.Sound.StopExtendEffect(longClickSound)
			end
			if DelayCo then
				self:CancelDelayRun(DelayCo)
			end
			DelayCo = self:DelayRun(delayTime,function ()
				LongClickFunc()
			end)
			if delayTime >= minTime then
				delayTime = delayTime/2
			end
		end

		CC.Sound.PlayHallEffect(clickSound)
		self.__longClickFlag = false;
		self:StartTimer("CheckLongClick"..curCount,time,LongClickFunc)

		if funcDown then
			funcDown(obj,eventData);
		end
		CC.Sound.PlayHallLoopEffect(longClickSound);
	end

	node.onUp = function(obj,eventData)
		if funcUp then
			funcUp(obj,eventData);
		end
		self:StopTimer("CheckLongClick"..curCount);
		if DelayCo then
			self:CancelDelayRun(DelayCo)
		end
		CC.Sound.StopExtendEffect(longClickSound);
	end

	node.onClick = function(obj, eventData)

		if not self.__longClickFlag then
			funcClick(obj, eventData);
		end
	end
end

function baseClass:DelayRun( second, func, ... )
	local co = CC.uu.DelayRun(second, func, ...)
	self._cos[co] = co
	return co
end

function baseClass:CancelDelayRun( co )
	if co then
		self._cos[co] = nil
		CC.uu.CancelDelayRun(co)
	end
end

function baseClass:CancelAllDelayRun()
	for _, co in pairs(self._cos) do
		CC.uu.CancelDelayRun(co)
	end
	self._cos = {}
end

function baseClass:StartTimer( name, delay, func, times )
	self:StopTimer(name)
	self._timers[name] = Timer.New(func, delay, times);
	self._timers[name]:Start();
end

function baseClass:StopTimer(name)
	local timer = self._timers[name]
	if timer then
		timer:Stop();
		self._timers[name] = nil
	end
end

function baseClass:StopAllTimer()
	for _, timer in pairs(self._timers) do
		timer:Stop();
	end
	self._timers = {}
end

function baseClass:RunAction(target, action)
	if CC.uu.isString(target) then
		target = self:FindChild(target)
	end
	local tween = CC.Action.RunAction(target, action)
	table.insert(self._actions,tween)
	return tween
end

function baseClass:StopAction(tween, beComplete)
	for key, action in pairs(self._actions) do
		if tween == action then
			action:Kill(beComplete or false)
			self._actions[key] = nil
			break
		end
	end
end

function baseClass:StopAllAction(beComplete)
	for _, action in pairs(self._actions) do
        action:Kill(beComplete or false)
    end
    self._actions = {}
end

function baseClass:SetImage(childNode, path)
	if CC.uu.isString(childNode) then
		childNode = self:FindChild(childNode);
	end
	CC.uu.SetHallImage(childNode, path);
end

return baseClass