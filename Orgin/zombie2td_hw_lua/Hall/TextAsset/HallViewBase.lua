
local CC = require("CC")

local HallViewBase = CC.class2("HallViewBase",CC.ViewBase)

function HallViewBase:ctor()
	self._canClick = true
	self.__longClickCount = 0
	self._addToDontDestroyNode = false;
	self._updates = {};
	self._isPortraitView = false
end

function HallViewBase:GlobalNode()
	if self:IsPortraitView() then
		return GameObject.Find("GNode/GPortraitCanvas/GMain").transform
	else
		return GameObject.Find("GNode/GCanvas/GMain").transform
	end
end

function HallViewBase:GlobalExtend()
	if self:IsPortraitView() then
		return GameObject.Find("GNode/GPortraitCanvas/GExtend").transform
	else
		return GameObject.Find("GNode/GCanvas/GExtend").transform
	end
end

function HallViewBase:GlobalCamera()
	return GameObject.Find("HallCamera/GUICamera"):GetComponent("Camera")
end

function HallViewBase:GlobalLayer()
	return "layer31"
end

function HallViewBase:Create()
	local prefabName = self.viewName
	if self:IsPortraitScreen() then
		local portraitView = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine").PortraitSupport[self.viewName]
		if portraitView then
			self._isPortraitView = true
			prefabName = portraitView
		end
	end
	self.transform = CC.uu.LoadHallPrefab(self.bundleName, 
		prefabName,
		self:GlobalNode(),
		self.viewName,
		self:GlobalLayer())
	self:OnCreate()
end

function HallViewBase:AddToDontDestroyNode()
	self._addToDontDestroyNode = true;
end

--重写AddClick，加了self._canClick判断
function HallViewBase:AddClick(node, func, clickSound, isScale)
	clickSound = clickSound or "click"
	
	if CC.uu.isString(func) then 
		func = self:Func(func) 
	end
	if CC.uu.isString(node) then
		node = self:FindChild(node)
	end

	if not node then
		logError("按钮节点不存在")
		return
	end
	--在按下时就播放音效，解决音效延迟问题
	node.onDown = function (obj, eventData)
		if not self._canClick then return end;
		CC.Sound.PlayHallEffect(clickSound)
		if isScale then
			self:RunAction(node, {"spawn",{"fadeToAll", 255, 0.05}, { "scaleTo", 0.9, 0.9, 0.05, ease = CC.Action.EOutBack}})
		end
	end

	node.onUp = function (obj, eventData)
		if not self._canClick then return end;
		if isScale then
			self:RunAction(node, {"spawn",{"fadeToAll", 255, 0.05}, { "scaleTo", 1, 1, 0.05, ease = CC.Action.EOutBack}})
		end
	end

	if node == self.transform then
		node.onClick = function(obj, eventData)
			if not self._canClick then return end;
			if eventData.rawPointerPress == eventData.pointerPress then
				func(obj, eventData)
			end
		end
	else
		node.onClick = function(obj, eventData)
			if not self._canClick then return end;
			func(obj, eventData)
		end
	end

	table.insert(self._addClickNodes,node)
end

function HallViewBase:AddLongClick(node, param)
	local funcClick = param.funcClick;
	local funcLongClick = param.funcLongClick;
	local funcDown = param.funcDown;
	local funcUp = param.funcUp;
	local time = param.time or 1;
	local clickSound = param.clickSound or "click";
	local longClickSound = param.longClickSound;

	self.__longClickCount = self.__longClickCount and self.__longClickCount + 1 or 0;
	local curCount = self.__longClickCount

	node.onDown = function(obj, eventData)
		if not self._canClick then return end
		CC.Sound.PlayHallEffect(clickSound)
		self.__longClickFlag = false;
		self:StartTimer("CheckLongClick"..curCount,time,function()
			if eventData.pointerCurrentRaycast.gameObject == node.gameObject then 
				self.__longClickFlag = true;
				funcLongClick(obj, eventData);
				CC.Sound.StopExtendEffect(longClickSound);
			end
		end)
		if funcDown then 
			funcDown(obj,eventData);
		end
		CC.Sound.PlayHallLoopEffect(longClickSound);
	end

	node.onUp = function(obj,eventData)
		if not self._canClick then return end
		if funcUp then 
			funcUp(obj,eventData);
		end
		self:StopTimer("CheckLongClick"..curCount);
		CC.Sound.StopExtendEffect(longClickSound);
	end

	node.onClick = function(obj, eventData)
		if not self._canClick then return end
		if not self.__longClickFlag then
			if funcClick then
				funcClick(obj, eventData);
			end
		end
	end

	table.insert(self._addClickNodes,node)
end

function HallViewBase:StartTimer( name, delay, func, times )
	self:StopTimer(name)
	self._timers[name] = Timer.New(func, delay, times);
	self._timers[name]:Start();
end

function HallViewBase:StopTimer(name)
	local timer = self._timers[name]
	if timer then
		timer:Stop();
		self._timers[name] = nil
	end
end

function HallViewBase:StopAllTimer()
	for _, timer in pairs(self._timers) do
		timer:Stop();
	end
	self._timers = {}
end

function HallViewBase:StartUpdate(func)
	self:StopUpdate(func);
	self._updates[func] = func;
	UpdateBeat:Add(func,self);
end

function HallViewBase:StopUpdate(func)
	if self._updates[func] then 
		self._updates[func] = nil;
		UpdateBeat:Remove(func,self);
	end
end

function HallViewBase:StopAllUpdate()
	for i,v in pairs(self._updates) do 
		UpdateBeat:Remove(i,self);
	end
	self._updates = {};
end


function HallViewBase:GetLanguage()
	return CC.LanguageManager.GetLanguage("L_"..self.viewName);
end

function HallViewBase:CreateViewCtr(...)
	local viewCtrClass = require("View/"..self.viewName.."/"..self.viewName.."Ctr");
	return viewCtrClass.new(self, ...);
end

function HallViewBase:SetCanClick(flag)
	self._canClick = flag;
end

function HallViewBase:ActionIn()
	self:SetCanClick(false);
    self.transform.size = Vector2(3000, 3000)
    self.transform.localScale = Vector3(0.5,0.5,1)
    self:RunAction(self, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    		self:SetCanClick(true);
    	end})
    CC.Sound.PlayHallEffect("click_boardopen");
end

function HallViewBase:ActionOut()
	self:SetCanClick(false);
    self:RunAction(self, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    		self:Destroy();
    	end})
end

function HallViewBase:ShowPanel(panel)
	self:SetCanClick(false);
	panel:SetActive(true)
    panel:FindChild("Frame").localScale = Vector3(0.5,0.5,1)
    self:RunAction(panel:FindChild("Frame"), {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    		self:SetCanClick(true);
    	end})
	CC.Sound.PlayHallEffect("click_boardopen");
end

function HallViewBase:HidePanel(panel)
	self:SetCanClick(false);
    self:RunAction(panel:FindChild("Frame"), {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
		     panel:SetActive(false)
		     self:SetCanClick(true);
    	end})
end

function HallViewBase:SetImage(childNode, path,setnativesize)
	if CC.uu.isString(childNode) then
		childNode = self:FindChild(childNode);
	end
	CC.uu.SetHallImage(childNode, path,setnativesize);
end

function HallViewBase:SetImageFromAb(childNode, path, abName)
	local abName = abName or "image"
	local image = childNode:GetComponent("Image");
	local sprite = CC.uu.LoadImgSpriteFromAb(abName, path);
	if sprite then
		image.sprite = sprite;
	end
end

function HallViewBase:SetRawImageFromAb(childNode,path,abName)
	local abName = abName or "image"
	abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[path] or abName;
	local rawImage = childNode:GetComponent("RawImage")
	local texture = ResourceManager.LoadAsset(abName, path)
	if rawImage then
		rawImage.texture = texture
	end
end

--判断屏幕竖屏
function HallViewBase:IsPortraitScreen()
	if Application.isEditor then
		return Screen.width < Screen.height
	end
	--logError("orientation:"..tostring(Screen.orientation))
	if Screen.orientation == UnityEngine.ScreenOrientation.Portrait or Screen.orientation == UnityEngine.ScreenOrientation.PortraitUpsideDown then
		return true
	end
	return false
end

--判断界面竖屏
function HallViewBase:IsPortraitView()
	return self._isPortraitView
end

function HallViewBase:OnFocusIn()

end

function HallViewBase:OnFocusOut()

end

--[[
	destroyOnLoad:是否让场景销毁的同时异步销毁节点
]]
function HallViewBase:Destroy(destroyOnLoad)
	self:RemoveAllClick()
	self:CancelAllDelayRun()
	self:StopAllTimer()
	self:StopAllAction()
	self:StopAllUpdate()
	CC.HallNotificationCenter.inst():unregisterAll(self)
	self:OnDestroy(destroyOnLoad)
	self:OnDestroyFinish()
	--只要添加到dontDestroyNode每次销毁都直接做destroyObject处理(否则异步加载场景时脚本对象释放了,但viewObject没自动释放)
	if self._addToDontDestroyNode then
		coroutine.start(function()
			CC.uu.destroyObject(self)
		end)
		return;
	end
	if destroyOnLoad ~= true then
		--解决异步切换场景过程中创建的viewObject被场景切换后销毁，导致脚本对象执行到该处找不到viewObject报错
		if not CC.uu.IsNil(self.transform) then
			coroutine.start(function()
				CC.uu.destroyObject(self)
			end)
		end
	end
end

return HallViewBase