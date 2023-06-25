local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TdObjectMgr = GC.class2("TdObjectMgr");

function TdObjectMgr:ctor(_, ctrlClass)
	self._createInx = 0;
	self._ctrlList = {};
	self._ctrlClass = ctrlClass;
end

function TdObjectMgr:Init()

end

function TdObjectMgr:Update(dt)

end

function TdObjectMgr:FixedUpdate(dt)
	for _, v in pairs(self._ctrlList) do
		v:FixedUpdate(dt);
	end
end

function TdObjectMgr:SetSaveMode()
	for _, v in pairs(self._ctrlList) do
		v:SetSaveMode();
	end
end

function TdObjectMgr:IncreaseId()
	self._createInx = self._createInx + 1;
	if self._createInx > 9999 then
		self._createInx = 1;
	end
	return self._createInx;
end

-- params:
--objPath
--objFile
--objParent
--forceId
--
function TdObjectMgr:CreateObject(objInfo)
	local buildId = objInfo.forceId;
	
	if buildId == nil then
		buildId = self:IncreaseId();
	end
	
	if self._ctrlList[buildId] ~= nil then
		logError("--------" .. self.className .. " over stack!!!:" .. buildId ..",replace monId:" .. tostring(self._ctrlList[buildId].__monId));
		logError("traceback:" .. debug.traceback());
		self:DestoryCtrl(self._ctrlList[buildId]);
	end

	local ctrl = self._ctrlClass:new(self);
	ctrl:Init(buildId, objInfo);
	self._ctrlList[buildId] = ctrl;
	return buildId;
end

function TdObjectMgr:GetCtrlList()
	return self._ctrlList;
end	

function TdObjectMgr:DestoryCtrl(delCtrl)
	delCtrl:Release();
	self._ctrlList[delCtrl._id] = nil;
end


function TdObjectMgr:DestoryCtrlById(delId)
	local delCtrl = self._ctrlList[delId];
	if delCtrl then
		delCtrl:Release();
	end
	self._ctrlList[delId] = nil;
end

function TdObjectMgr:GetCtrlById(id)
	return self._ctrlList[id];
end

function TdObjectMgr:Release()
	for _, v in pairs(self._ctrlList) do
		v:Release();
	end
	self._ctrlList = {};
end 

return TdObjectMgr;