local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TouchChecker = GC.class2("ZTD_TouchChecker")

function TouchChecker:ctor(_, maskId, customFuncs)
	self._maskId = maskId;
	self._touchTime = 0;
	self._isPressed = false;
	self._touchRects = {};
	if customFuncs then
		self._customPresseDownCheck = customFuncs.customPresseDownCheck;
		self._customPresseUpCheck = customFuncs.customPresseUpCheck;
	end	
end

function TouchChecker:Register(bindTransform, bindData, funcs)	
	local newInx = #self._touchRects + 1;
	self._touchRects[newInx] = {};
	
	local emptyFunc = function() end
	self._touchRects[newInx].bindTransform = bindTransform;
	self._touchRects[newInx].bindData = bindData;
	self._touchRects[newInx].downFunc = funcs.downFunc or emptyFunc;
	self._touchRects[newInx].dragFunc = funcs.dragFunc or emptyFunc;
	self._touchRects[newInx].cancelFunc = funcs.cancelFunc or emptyFunc;
	self._touchRects[newInx].upFunc = funcs.upFunc or emptyFunc;
	self._touchRects[newInx].callObj = funcs.callObj;
	self._touchRects[newInx].pressTime = funcs.pressTime or -1;
	self._touchRects[newInx].isDragging = false;
end

function TouchChecker:UnRegister(bindTransform)
	for pos, v in ipairs(self._touchRects) do
		if bindTransform == v.bindTransform then
			table.remove(self._touchRects, pos);
			break;
		end
	end	
end	

function TouchChecker:Release()
	self._touchRects = {};
	self._touchTime = 0;
	self._isPressed = false;	
	self._lastRet = nil;
end	

function TouchChecker:PickTouch()
	local ray = ZTD.MainScene.CamObj:ScreenToWorldPoint(ZTD.MainScene.screenPosition);
	local hits = UnityEngine.Physics2D.RaycastAll(ray, Vector2.zero, 1000, LayerMask.GetMask(self._maskId));
	local transformMap = {};
	for i = 0, hits.Length - 1 do
		local rst = hits[i];
		if rst and rst.collider and rst.collider.gameObject.transform then
			for _, v in ipairs(self._touchRects) do
				if rst.collider.gameObject.transform == v.bindTransform then
					return v;
				end
			end
		end
	end	
end

function TouchChecker:Reset()
	self._touchTime = 0;
	self._isPressed = false;
	self._lastRet = nil
end	



TouchChecker.TYPE_BREAK = 2;
function TouchChecker:CheckLogic(dt)
	if not ZTD.MainScene.PressDown then
		self._firstPressDown = true;
		self._firstScreenPosition = ZTD.MainScene.screenPosition;
		self._isEmptyClk = false;
	end

	-- 拖动截断
	if ZTD.MainScene.PressDown and self._lastRet and self._lastRet.isDragging then	
		self._lastRet.dragFunc(self._lastRet.callObj, self._lastRet);
		ZTD.Flow.GetTouchMgr():ResetOther(self)
		return true;
	end
	
	if ZTD.MainScene.PressDown and not ZTD.MainScene.IsPressUi() then
		self._isPressed = true;
		
		-- 按下截断
		if self._customPresseDownCheck then
			return self._customPresseDownCheck(self);
		end		
		
		if self._isEmptyClk then
			return;			
		end	
						
		local ret = self:PickTouch();

		if ret and self._lastRet == ret then
			self._lastRet.isCancel = false;
			self._touchTime = self._touchTime + dt;
			if ret.pressTime > 0 and self._touchTime >= ret.pressTime then
				self._lastRet.isDragging = true;
			end
		else
			self._touchTime = 0;
			if self._lastRet then
				if self._lastRet.dragFunc then
					self._lastRet.isDragging = true;					
				else
					if not self._lastRet.isCancel then
						self._lastRet.cancelFunc(self._lastRet.callObj, self._lastRet);
					end	
					self._lastRet.isCancel = true;
					return;
				end
			end			
			
			if ret and self._firstPressDown then
				self._lastRet = ret;
				self._lastRet.isCancel = false;
				self._lastRet.downFunc(self._lastRet.callObj, self._lastRet);
				return true;
			else
				self._isEmptyClk = true;	
			end
		end
		
		self._firstPressDown = false;
	elseif self._isPressed then
		self._isPressed = false;
		local tag = false
		if self._customPresseUpCheck then
			tag = self._customPresseUpCheck(self);
		elseif self._lastRet then
			local isDragging = self._lastRet.isDragging;
			self._lastRet.isDragging = false;
			local ret = self:PickTouch();
			tag = true
			if self._lastRet == ret then
				self._lastRet.upFunc(self._lastRet.callObj, self._lastRet);
			elseif not self._lastRet.isCancel then
				self._lastRet.cancelFunc(self._lastRet.callObj, self._lastRet);
				self._lastRet.isCancel = true;
				self._lastRet = nil;
				tag =  TouchChecker.TYPE_BREAK;
			end
			--logError("_touchTime_touchTime:" .. self._touchTime)
			self._lastRet = nil;
			
		end	
		--按下按中东西，重置所有层级状态
		if tag then
			ZTD.Flow.GetTouchMgr():ResetAll()
		end
		return tag
	end
	return false;
end

return TouchChecker;