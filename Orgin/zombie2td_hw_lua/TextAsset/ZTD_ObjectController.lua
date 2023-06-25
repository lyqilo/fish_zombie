local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TdObjectController = GC.class2("TdObjectController")

function TdObjectController:ctor(_, mgr)
	self._obj = nil;
	self._id = -1;
	self._mgr = mgr;
end
	
function TdObjectController:Init(buildId, buildInfo)
	self._id = buildId;
	self._objName = buildInfo.objFile;
	self._obj = ZTD.PoolManager.GetGameItem(buildInfo.objFile, buildInfo.objParent);
	self._obj:SetActive(false);
	self._obj:SetActive(true);
end

function TdObjectController:GetId()
	return self._id;
end	
function TdObjectController:SetSaveMode()
	
end


function TdObjectController:FixedUpdate(dt)
end

function TdObjectController:Release()
	if self._obj then
		ZTD.PoolManager.RemoveGameItem(self._objName, self._obj)
		self._obj = nil;
	end	
end

return TdObjectController