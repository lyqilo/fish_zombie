local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TdEnemyObj = GC.class2("TdEnemyObj")

local FlashTime = 0.1;
local AniState = 
{
	Walk = "Walk",
	Dead = "Dead",
	Atk = "Atk",
}

function TdEnemyObj:ctor(_, id)
	self._id = id;
	self._flashTime = 0;
end

function TdEnemyObj:Init(objPath, objFile, parentNode, IsConnect, Level, monsterId, sortOrder)
	self._objName = objFile;
	self._obj = ZTD.PoolManager.GetGameItem(objFile, ZTD.MainScene.GetMapObj());
	self._obj:SetActive(true);
	self._effStack = {};

	self.giantCfg = ZTD.GiantConfig
	self.monsterId = monsterId
	self.spEnemy = self._obj:FindChild("sp_enemy")
	self.spRender = self.spEnemy:GetComponent(typeof(UnityEngine.Renderer))
	self.spRender.sortingOrder = sortOrder
	self.sortOrder = sortOrder
	self._animator = self.spEnemy:GetComponent("Animator")
	self.connectEffect = self._obj:FindChild("Effect_Jygfz_Jin_1")
	self.connectEffect:SetActive(IsConnect)
	if self.monsterId == 10008 then
		self:OnRefreshLevMul(Level)
		self:OnRefreshScale(Level)
	end
	-- 方向给个默认值
	self:setDir(1);
end

--刷新巨人升级特效
function TdEnemyObj:OnRefreshEff(Level)
	if not Level then
		return
	end
	self.eff = self._obj:FindChild("TD_Effect_JRshengji")
	self.eff:SetActive(false)
	self.eff:SetActive(true)
	self.eff.localScale = Vector3(self.giantCfg.effScaleCfg[Level], self.giantCfg.effScaleCfg[Level], self.giantCfg.effScaleCfg[Level])
end

--刷新巨人头顶倍数
function TdEnemyObj:OnRefreshLevMul(Level)
	if not Level then
		return
	end
	self.spLevMul = self._obj:FindChild("sp_ratio")
	self.spLevMul:GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("Prefab", self.giantCfg.mulCfg[Level])
end

--刷新巨人缩放大小
function TdEnemyObj:OnRefreshScale(Level)
	if not Level then
		return
	end
	local scale = self.giantCfg.scaleCfg[Level]
	self.spEnemy.localScale = Vector3(scale, scale, scale)
	local pos = self.spEnemy.localPosition
	pos.y = (scale-0.5)*0.6
	--self:setPos(pos.x, pos.y)
	self.spEnemy.localPosition = pos
	self.baseSortOrder = self.baseSortOrder or self.sortOrder
	self.sortOrder =  math.floor(self.baseSortOrder*scale)
end

-- 1下 2右 3上 4左
function TdEnemyObj:setDir(dir_inx)
	if(self._nowDir == dir_inx) then
		return;
	end

	self.spEnemy.localRotation = Quaternion.Euler(0, 0, 0);
	if(dir_inx == 4) then
		self.spEnemy.localRotation = Quaternion.Euler(0, 180, 0);
	end
	self._animator:SetFloat("DirIdx", dir_inx)
	self._nowDir = dir_inx;
end

function TdEnemyObj:setPos(x, y)
	self._obj.localPosition = Vector3(x, y, 0);
	
	local constCfg = ZTD.ConstConfig[1];
	
	--local limitH = constCfg.LogicHeight / 100;
	
	local y_total = 300;
	
	local gaps = {};
	
	-- for i = 1, y_total do
	-- 	gaps[i] = (limitH/y_total) * i - limitH/2;
	-- end
	
	-- local sortY = 1;
	-- for i = y_total, 1, -1 do
	-- 	if y > gaps[i] then
	-- 		sortY = y_total - i + 1;
	-- 		break;
	-- 	end
	-- end
	local sortY = math.abs(y*100-constCfg.LogicHeight/2)/y_total*100
	sortY = sortY*100 + self.sortOrder
	if self._sortY ~= sortY then
		--self.spRender.sortingLayerName = "sort" .. sortY
		self.spRender.sortingOrder = sortY
		self._sortY = sortY;
	end
end

function TdEnemyObj:getPos()
	return Vector2(self._obj.localPosition.x, self._obj.localPosition.y);
end

function TdEnemyObj:getWorldPos()
	return Vector2(self._obj.position.x, self._obj.position.y);
end

function TdEnemyObj:playAnim(value)
	if self._state == AniState.Dead then
		return
	end
	if value == AniState.Dead then
		self.isDead = true
	end
	self._state = value
	self._animator:SetTrigger(value)
	self:ChangeAniSpeed(1)
end


function TdEnemyObj:checkAnimEnd(value)
	local  stateinfo = self._animator:GetCurrentAnimatorStateInfo(0);
	if stateinfo:IsName(value) then
		if (stateinfo.normalizedTime >= 1.0) then
			return true;
		end
	end
	return false;
end

function TdEnemyObj:ChangeAniSpeed(speed)
	self._animator.speed = speed
end

-- 毒爆状态冻结（变绿静止）
function TdEnemyObj:PoxFreeze()
	self:ChangeAniSpeed(0)
	--self.spRender.material:SetColor("_Color", Color(0,1,0,1));
	self.spRender.color = Color(0,1,0,0.5)
	self._isFreeze = true;
end

-- 减速
function TdEnemyObj:SpeedDown(isSpeedDown)
	if self._isFreeze then
		return;
	end
	self._spdDown = isSpeedDown
	if isSpeedDown then
		self.spRender.color = Color(0.5, 0.5, 1, 1)
	else
		self.spRender.color = Color(1, 1, 1, 1)
	end
end
 

function TdEnemyObj:addLockMark()
	if ZTD.MainScene.LockObj then
		local spShadow = self._obj:FindChild("sp_shadow");
		ZTD.MainScene.LockObj:SetActive(false)
		ZTD.MainScene.LockObj:SetActive(true)
		ZTD.MainScene.LockObj.transform:SetParent(self._obj);
		ZTD.MainScene.LockObj.transform.localPosition = spShadow.transform.localPosition;	
		
		local scaleS = spShadow.transform.localScale.x;
		if scaleS >= 1.5 then
			scaleS = 1.5;
		end
		ZTD.MainScene.LockObj.transform.localScale = Vector3(scaleS, scaleS, scaleS);
	end
end

function TdEnemyObj:RemoveLockMark()
	if ZTD.MainScene.LockObj then
		ZTD.MainScene.LockObj.transform:SetParent(ZTD.MainScene.GetMapObj());
		ZTD.MainScene.LockObj:SetActive(false);
	end	
end

function TdEnemyObj:Release()
	--self.spRender.material:SetFloat("_FillAlpha", 0);
	self.spRender.color = Color(1,1,1,1)
	--self.spRender.material:SetColor("_Color", Color(1,1,1,1));
	for vname, vobj in pairs (self._effStack) do
		ZTD.PoolManager.RemoveGameItem(vname, vobj);
	end
	
	if ZTD.MainScene.LockObj == self._obj.parent then
		self:RemoveLockMark();
	end
	
	self._effStack = {};

	self._obj:SetActive(false);
	ZTD.PoolManager.RemoveGameItem(self._objName, self._obj);
	self._obj = nil;
end

function TdEnemyObj:RemoveEff()
	if self.removeEffTimer then
		ZTD.GameTimer.StopTimer(self.removeEffTimer)
		self.removeEffTimer = nil
	end
	for vname, vobj in pairs (self._effStack) do
		ZTD.PoolManager.RemoveGameItem(vname, vobj);
	end
	self._effStack = {};	
end

function TdEnemyObj:PlayHitEffect(effPath)
	if not effPath then
		return;
	end
	self:RemoveEff()
	local effObj = ZTD.PoolManager.GetGameItem(effPath, self._obj);
	effObj.localPosition = Vector3(0, 0, 0);
	self._effStack[effPath] = effObj;
	
	self.removeEffTimer = ZTD.GameTimer.DelayRun(0.5,function ()
		self.removeEffTimer = nil
		self:RemoveEff()
	end)
	self._isFlash = true;
	self._flashTime = 0;
	
	--self.spRender.material:SetFloat("_FillAlpha", 0);
	--self.spRender.color = Color(0.5,0,0,0.5)
end

function TdEnemyObj:UpdateFlash(dt)
	if self._isFlash and not self._spdDown then
		local fillV = 0.5;
		self._flashTime = self._flashTime + dt;
		local dstT = FlashTime/2;
		if self._flashTime <= dstT then
			fillV = self._flashTime/dstT;
		elseif self._flashTime >= FlashTime then
			fillV = 1;
			self._isFlash = false;
		else
			fillV = 1 - (self._flashTime - dstT)/dstT;
		end
		fillV = fillV<0.7 and 0.7 or fillV
		--self.spRender.material:SetFloat("_FillAlpha", fillV * 0.5);			
		self.spRender.color = Color(fillV,fillV,fillV,1)
	end	
end

function TdEnemyObj:UpdateFreeze(dt)
	if self._isFreeze then
		local fillV = 0;
		self._flashTime = self._flashTime + dt;
		local dstT = FlashTime/2;
		if self._flashTime <= dstT then
			fillV = self._flashTime/dstT;
		elseif self._flashTime >= FlashTime then
			fillV = 0;
			self._flashTime = 0;
		else
			fillV = 1 - (self._flashTime - dstT)/dstT;
		end
		--self.spRender.material:SetFloat("_FillAlpha", fillV * 0.5);
		self.spRender.color = Color(0,1,0,0.5*fillV)
	
	end
end

function TdEnemyObj:FixedUpdate(dt)
	self:UpdateFlash(dt);
	self:UpdateFreeze(dt);
end

return TdEnemyObj;