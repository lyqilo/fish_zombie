local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TdBulletController = GC.class2("TdBulletController", ZTD.ObjectController)
local SUPER = ZTD.ObjectController;

function TdBulletController:Init(buildId, buildInfo)
	local mapObj = ZTD.MainScene.GetMapObj();
	local cfg = ZTD.ConstConfig[1];


	buildInfo.objPath = cfg.ResPath;
	buildInfo.objParent = mapObj;
	
	--SUPER.Init(self, buildId, buildInfo);	
	
	self._id = buildId;
	self.bulletId = buildInfo.bulletId
	self.playerId = buildInfo.playerId
	--logError("InitInitInitInitInit:" .. self._id)
	self._objName = buildInfo.objFile;
	self._obj = ZTD.PoolManager.GetGameItem(buildInfo.objFile, buildInfo.objParent);
	self._obj:SetActive(false);
	self._obj:SetActive(true);
	self.totalDt = 0
	if self.bulletId == 1005 then
		self._obj:SetActive(false)
		self._obj:FindChild("fu/tuowei").gameObject:SetActive(false)
		self._obj:FindChild("fu/tuowei").gameObject:GetComponent(typeof(UnityEngine.Renderer)).enabled = false
	end
	

	local myRenderer = self._obj:GetComponentInChildren(typeof(UnityEngine.Renderer));
	myRenderer.sortingOrder = 1000;
	
	self._spd = 10;
	self._atk = 1;
	
	self._obj.position = buildInfo.srcPos;
	local sealState = ZTD.SealUi:GetSealState(self.playerId)
	--logError("sealState="..tostring(sealState))
	self._obj.localScale = sealState and Vector3(3,3,3) or Vector3.one
	self._target = buildInfo.target;
	self._hitEff = buildInfo.hitEff;
	self._sound = buildInfo.hitSound;
	self._heroPos = buildInfo.heroPos;
	
	--if self._target:isLost() or self._target:getEnemyObj() == nil then
	if self._target._isDoExit or self._target._isUnSelect or self._target._isUnSelectBalloon or self._target:getEnemyObj() == nil then	
		self._mgr:DestoryCtrl(self);
		return;
	end
	local tgPos = self._target:getEnemyObj().localPosition;
	local dir = Vector3.Normalize(tgPos - self._obj.localPosition);
	
	--local oldZ = self._obj.localRotation.z;
	self._obj.localRotation = Quaternion.FromToRotation(Vector3.up, dir)
	--self._obj.localRotation.z = self._obj.localRotation.z + oldZ;
end

function TdBulletController:FixedUpdate(dt)
	if self._obj == nil then
		logError("--------_obj == nil invaild Bullet !!!:" .. self._id);
		self._mgr:DestoryCtrl(self);
		return;
	end
	self.totalDt = dt + self.totalDt
	if self.totalDt >= 0.25 then
		if self.bulletId == 1005 then
			self._obj:FindChild("fu/tuowei").gameObject:SetActive(true)
			self._obj:FindChild("fu/tuowei").gameObject:GetComponent(typeof(UnityEngine.Renderer)).enabled = true
		end
	end
    local step = self._spd *  dt;
	
	local tgObj = self._target:getEnemyObj();
	local tgPos;
	if tgObj ~= nil then
		tgPos = tgObj.localPosition;
		
		local dir = Vector3.Normalize(tgPos - self._obj.localPosition);
		self._obj.localRotation = Quaternion.FromToRotation(Vector3.up, dir)		
	end

	tgPos = tgPos or self._lastTgPos;
	self._lastTgPos = tgPos;
	
	-- 如果杀怪请求完的时候怪就被杀死了，可能会进入这种情况
	if self._lastTgPos == nil then
		log("--------lastTgPos == nil invaild Bullet !!!:" .. self._id);
		self._obj:SetActive(false);
		self._mgr:DestoryCtrl(self);
		return;
	end	
	
	self._obj.localPosition = Vector3.MoveTowards(self._obj.localPosition, tgPos, step);
	
	local distance = Vector3.Distance(self._obj.localPosition, tgPos);
	if(distance < 0.1) then
		self._obj:SetActive(false);
		self._target:DoHit(self._id, self._hitEff, self._sound);
		self._mgr:DestoryCtrl(self);
	end
end

function TdBulletController:Release()
	if self._obj then
		--logError("ReleaseReleaseReleaseRelease:" .. self._id)
		ZTD.PoolManager.RemoveGameItem(self._objName, self._obj)
		self._obj = nil;
	end		
end

return TdBulletController