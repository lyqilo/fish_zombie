local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TouchManager = GC.class2("ZTD_TouchManager")

function TouchManager:ctor(_)

end

function TouchManager:Init()
	-- 顺序触摸
	self._touchList = {};
	-- 穿透触摸,总是会被检测到
	self._extraTouchList = {};	
end	

function TouchManager:Release()
	self:Init();
end	

function TouchManager:AddTouch(touch, order)
	local touchData = {};
	touchData.touch = touch;
	touchData.order = order or 0;
	
	if order == -1 then
		table.insert(self._extraTouchList, touchData);
	else	
		table.insert(self._touchList, touchData);
		local function comp(a, b)
			return a.order > b.order;
		end
		table.sort(self._touchList, comp);
	end
end

function TouchManager:RemoveTouch(touch)
	for i, v in ipairs(self._extraTouchList) do
		if v == touch then
			table.remove(self._extraTouchList, i);
			return;
		end
	end
	
	for i, v in ipairs(self._touchList) do
		if v == touch then
			table.remove(self._touchList, i);
			return;
		end
	end	
end	

function TouchManager:ResetAll()
	for _, v in ipairs(self._touchList) do
		v.touch:Reset()
	end
	for _, v in ipairs(self._extraTouchList) do
		v.touch:Reset()
	end
end

function TouchManager:ResetOther(selfChecker)
	for _, v in ipairs(self._touchList) do
		if v.touch ~= selfChecker then
			v.touch:Reset()
		end
	end
	for _, v in ipairs(self._extraTouchList) do
		if v.touch ~= selfChecker then
			v.touch:Reset()
		end
	end
end

function TouchManager:FixedUpdate(dt)
	local checkType;
	for _, v in ipairs(self._touchList) do
		checkType = v.touch:CheckLogic(dt);
		if checkType then
			break;
		end
	end
	
	-- 触碰过程中不让其他层级干扰
	if checkType == ZTD.TouchChecker.TYPE_BREAK then
		for _, v in ipairs(self._extraTouchList) do
			v.touch:Reset(dt);
		end			
		return;
	end	
	
	for _, v in ipairs(self._extraTouchList) do
		v.touch:CheckLogic(dt);
	end	
end

return TouchManager;