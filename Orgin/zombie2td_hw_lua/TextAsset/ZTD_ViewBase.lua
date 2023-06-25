local CC = require("CC")
local GC = require("GC")
local tools = GC.uu
local ZTD = require("ZTD")

local ZTD_ViewBase = GC.class2("ZTD_ViewBase", ZTD.HallViewBase)
function ZTD_ViewBase:GlobalNode()
	return GameObject.Find("Main/Canvas/Panel").transform
end

function ZTD_ViewBase:GlobalCamera()
	logError("！！！注意,你必须重写该方法！"..debug.traceback())
end

function ZTD_ViewBase:GlobalLayer()
	return "UI"
end

function ZTD_ViewBase:ctor(...)
	ZTD.HallViewBase.ctor(self, ...);
	self._pressDownMark = {};
	self._pressEventMark = {};	
end	

function ZTD_ViewBase:OnCreate()
	--待重写（创建view节点成功后干啥）
end

function ZTD_ViewBase:OnDestroy()
	--待重写（view节点被消除前应该干啥）
end

function ZTD_ViewBase:PlayAnimAndEnter()
	local animator = self.transform:GetComponent("Animator");
	if animator then
		animator:Update(0);
	end
end

function ZTD_ViewBase:PlayAnimAndExit(func)
	local playAni;
	local function _saveGetAnimator()
		playAni = self.transform:GetComponent("Animator");
	end
	pcall(_saveGetAnimator);
	
	if playAni == nil then
		if func and type(func) == "function" then
			func()
		end
		self:Destroy() 
		return;
	end
	local maskObj = ResMgr.LoadPrefab("prefab", "ScreenMask", self.transform);
	playAni:SetTrigger("onExit")
	
	local counting = function()		
		local stateinfo;
		local function _saveGetAnimState()
			local playAni = self.transform:GetComponent("Animator");
			stateinfo = playAni:GetCurrentAnimatorStateInfo(0);
		end
		local ret, err = pcall(_saveGetAnimState);
		if not ret then
			-- log("_saveGetAnimState _setStateInfo:" .. err)
			ZTD.GlobalTimer.StopTimer(self.co_count);
			self.co_count = nil;
			return;
		end
		
		if stateinfo:IsName("onExit") then
			if (stateinfo.normalizedTime >= 1.0) then

				if GC.uu.isString(func) then 
					func = self:Func(func) 
				elseif not GC.uu.isFunction(func) then 
					func = nil; 					
				end

				
				if func == nil then
					local function defaultCb() 
						self:Destroy() 
					end;
					func = defaultCb;
				end
				--tools.destroyObject(maskObj.gameObject)	
				func();
				
				ZTD.GlobalTimer.StopTimer(self.co_count);
			end
		end
	end

    self.co_count = ZTD.GlobalTimer.StartTimer(function()
        counting();
    end, 0, -1);
end

function ZTD_ViewBase:AddClick(node, func, clickSound, delayRuns, isScale)
	if clickSound == false then
		clickSound = nil
	elseif clickSound == nil then
		clickSound = "ZTD_btn_click"
	end	
	
	if GC.uu.isString(node) then
		node = self:FindChild(node)
	end
	if GC.uu.isString(func) then 
		func = self:Func(func) 
	end	
	if not self._nodeClickMap then
		self._nodeClickMap = {};
	end
	self._nodeClickMap[node] = {};
	self._nodeClickMap[node].clickSound = clickSound;
	self._nodeClickMap[node].func = func;
	
	GC.ViewBase.AddClick(self, node, func, clickSound, delayRuns, isScale)
end

function ZTD_ViewBase:AddUIMaskClick(node)
	node.onDown = function(obj, eventData)
		ZTD.MainScene.isPressUI = true
		node.gameObject:GetComponent("Image").raycastTarget = false
	end

	node.onUp = function(obj, eventData)
		ZTD.MainScene.isPressUI = false
		node.gameObject:GetComponent("Image").raycastTarget = true
	end
end
--按下回调
function ZTD_ViewBase:AddOnDown(node, func)
	if GC.uu.isString(node) then
		node = self:FindChild(node)
	end
	if node then
		node.onDown = function(obj, eventData)
			func(eventData)
		end
	end
end
--松手回调
function ZTD_ViewBase:AddOnUp(node, func)
	if GC.uu.isString(node) then
		node = self:FindChild(node)
	end
	if node then
		node.onUp = function(obj, eventData)
			func(eventData)
		end
	end
end
--拖拽回调
function ZTD_ViewBase:AddOnDrag(node, func)
	if GC.uu.isString(node) then
		node = self:FindChild(node)
	end
	if node then
		node.onDrag = function(obj, eventData)
			func(eventData)
		end
	end
end

function ZTD_ViewBase:AddLongPressClick(node, func, longFunc, clickSound)
	clickSound = clickSound or "ZTD_btn_click"
	
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
			self._pressDownMark[node] = true;
			self._pressEventMark[node] = nil;
			local function longPressFunc()
				if longFunc and self._pressDownMark[node] then
					self._pressEventMark[node] = true;
					longFunc();
				end
			end
			self:DelayRun(0.5, longPressFunc);
		end

		node.onUp = function (obj, eventData)
			self._pressDownMark[node] = nil;
		end

		node.onClick = function(obj, eventData)
			local enable = true
			if node == self.transform then
				if eventData.rawPointerPress ~= eventData.pointerPress then
					enable = false
				end
			end
			if enable and not self._pressEventMark[node] then
				func(obj, eventData)
			end
		end
	end
end

function ZTD_ViewBase:DoClickByNode(node)
	if GC.uu.isString(node) then
		node = self:FindChild(node)
	end
	
	if node then
		self._nodeClickMap[node].func();
		GC.Sound.PlayEffect(self._nodeClickMap[node].clickSound);
	end
end

function ZTD_ViewBase:GetLanguage()
	return ZTD.LanguageManager.GetLanguage("L_"..self.viewName);
end


--获取组件
function ZTD_ViewBase:GetCmp(nodeName, cmp)
	local child = self.transform
	if nodeName then
		child = self:FindChild(nodeName)
	end
	if not child then
		logError("GetCmp Error: can not find node " .. nodeName )
		return
	end
	local nodeCmp = child:GetComponent(cmp)
	return nodeCmp
end


local function starstwith(str, chars)
	return string.match(str, '^' .. chars)
end
function ZTD_ViewBase:InitLan()
	self.lan = self:GetLanguage()

	local textList = self.transform:GetComponentsInChildren(typeof(UnityEngine.UI.Text), true)
	for i = 0, textList.Length - 1, 1 do
        local str = textList[i].text
		if starstwith(str, "#") then
			local lan = self.lan[string.sub(str, 2)]
			if lan then
				textList[i].text = lan
			end
		end
    end
end

return ZTD_ViewBase