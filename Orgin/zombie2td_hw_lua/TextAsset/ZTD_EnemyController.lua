local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TdEnemyController = GC.class2("TdEnemyController", ZTD.ObjectController)

-------移动方式
local LINER = 0; -- xy直线
	
function TdEnemyController:MyCtor()
	-- 入口点
	self._posEnter = nil; 
	-- 出口点
	self._posExit = nil;
	-- 路径点
	self._paths = {};
	-- 正在前往的路径点目标
	self._nowTarget = 1;
	-- 实体
	self._enemyObj = nil;	
	-- 是否已判断死亡
	self._isDoDie = false;
	-- 是否已经走出屏幕
	self._isDoExit = false;
	-- 是否被锁定
	self._isLock = false;	
	
	-------属性
	-- 移动速度
	self._moveSpd = 0;
	self._hp = 0;	

	-------移动方式
	self._moveWay = LINER;
	self._dirX = 0;
	self._dirY = 0;
	
	-- 总行进时间
	self._walkTime = 0;
	
	-- 是否被释放
	self._isRelease = false;
	
	-- 击杀后获得的金币和倍率，如果不为0则是本地玩家所杀
	self._moneyEarn = 0;
	self._ratio = 0;

	self.balloonRatio = 0
	
	-- 记录受击子弹
	self._dmgBullets = {};
		
	--击杀失败时需要强制死亡时使用
	self._forceDieCd = 0;
	self._isPlayingDie = false;
	-- 毒爆怪是否不可被锁定，用于死亡动作演示
	self._isUnSelect = false;
	--气球怪不可被锁定
	self._isUnSelectBalloon = false
	-- buffer列表
	self._buffList = {};
	--是否为连接怪
	self.IsConnect = false
	--巨人怪等级
	self.Level = 1
end

function TdEnemyController:createBlood()

end

function TdEnemyController:getEffApp(effName)
	
	local myId = self._cfg.id;
	local offset = Vector3.zero;
	local scale = Vector3.one;
	local doActFunc = nil
	local doMoveBy = nil;
	local etCfg = ZTD.MainScene.GetEffTransformConfig(effName);
	if etCfg then
		if etCfg.on_enemy[myId] then
			offset = etCfg.on_enemy[myId].offset;
			scale = etCfg.on_enemy[myId].scale;
			doActFunc = etCfg.on_enemy[myId].doActFunc;
		else
			offset = etCfg.offset;
			scale = etCfg.scale;	
			doActFunc = etCfg.doActFunc;
		end	
	end
	return offset, scale, doActFunc;
end

-- 播放退场效果
function TdEnemyController:playDeadEff(selfListName, cfgListName, isInMap)
	if self._effectId == nil or self[selfListName] ~= nil then
		return;
	end
	
	local eeCfg = ZTD.MainScene.GetEnemyEffCfg(self._effectId)
	if eeCfg[cfgListName] then
		self[selfListName] = {}
		for k, v in ipairs(eeCfg[cfgListName]) do			
			local eff
			if isInMap then
				eff = ZTD.PoolManager.GetGameItem(v, ZTD.MainScene.GetMapObj())
			else	
				eff = ZTD.PoolManager.GetGameItem(v, self:getEnemyObj())
			end	
			eff:SetActive(false);
			local offset, scale, doActFunc = self:getEffApp(v)
			
			if isInMap then
				eff.localPosition = self:getEnemyObj().localPosition + offset
			else	
				eff.localPosition = offset
			end	
			eff.localScale = scale
			eff:SetActive(true)
			local ed = {}
			ed.obj = eff
			ed.name = v
			
			if doActFunc then
				doActFunc(eff, self)
			end
			
			table.insert(self[selfListName], ed)
		end		
	end
end

function TdEnemyController:SetUnSelectBalloon()
	self._isUnSelectBalloon = true
end
	
-- 预爆准备
function TdEnemyController:SetUnSelect(killPlayerId, fid, nid)
	self._isUnSelect = true;
	self._UnSelectKillId = killPlayerId or 0;
	if self._enemyObj and self._deadStartEffect == nil then		
		self._enemyObj:playAnim("Dead");		
		-- 设置死亡特效
		if self._effectId == nil then
			self._effectId = 2;
			self._enemyObj:PoxFreeze();
		end	
		self:playDeadEff("_deadStartEffect", "deadStartEffect");
		-- 死亡音效
		self._deadSound = "ZTD_dead_10001";
		
		--[[
		if killPlayerId and ZTD.PlayerData.GetPlayerId() ~= killPlayerId then
			local function removeCall()
				self._mgr:ReadyDestory(self._id, killPlayerId);
			end
			ZTD.TableData.AddPoxData(killPlayerId, self._id, removeCall);		
		end	
		--]]
		
		
		--[[
		-- 调试代码
		local spDebugF1 = self._enemyObj._obj:FindChild("sp_debug1_f");
		if fid and spDebugF1 then
			
			local dbinx = math.floor(fid % 1000 / 100);
			local dbinx2 = math.floor(fid % 100 / 10);
			local dbinx3 = fid % 10;
			
			spDebugF1:SetActive(true);
			spDebugF1:GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("TowerDefMode", "jb_" .. dbinx);
			
			spDebugF1 = self._enemyObj._obj:FindChild("sp_debug2_f");
			spDebugF1:SetActive(true);
			spDebugF1:GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("TowerDefMode", "jb_" .. dbinx2);
			
			spDebugF1 = self._enemyObj._obj:FindChild("sp_debug3_f");
			spDebugF1:SetActive(true);
			spDebugF1:GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("TowerDefMode", "jb_" .. dbinx3);	
		end
		
		local spDebugN1 = self._enemyObj._obj:FindChild("sp_debug1_n");
		if nid and spDebugN1 then
			
			local dbinx = math.floor(nid % 1000 / 100);
			local dbinx2 = math.floor(nid % 100 / 10);
			local dbinx3 = nid % 10;
			
			spDebugN1:SetActive(true);
			spDebugN1:GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("TowerDefMode", "jb_" .. dbinx);
			
			spDebugN1 = self._enemyObj._obj:FindChild("sp_debug2_n");
			spDebugN1:SetActive(true);
			spDebugN1:GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("TowerDefMode", "jb_" .. dbinx2);
			
			spDebugN1 = self._enemyObj._obj:FindChild("sp_debug3_n");
			spDebugN1:SetActive(true);
			spDebugN1:GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("TowerDefMode", "jb_" .. dbinx3);	
		end
		--]]		
	end	
end

function TdEnemyController:GetLastHitHeroPos()
	--按顺序找出最后一个打在该怪身上的子弹，通过子弹找到对应的英雄
	local heroPos;
	local dmgLenth = #self._dmgBullets;
	for i = dmgLenth, 1, -1 do
		local dmgData = self._dmgBullets[i];
		if dmgData.isHit then
		--	logError("id:" .. self._id .. ",use hit:" .. dmgData.id);
			heroPos = dmgData.heroPos;
			break;
		end
	end
	return heroPos;
end

function TdEnemyController:GetObjPos()
	-- log("self._enemyObj="..tostring(self._enemyObj))
	if self._enemyObj then
		local epos = self._enemyObj._obj.position;
		local objPos = Vector3(epos.x, epos.y, epos.z);
		return objPos;
	end	
end

function TdEnemyController:IsPlayDie()
	return self._isPlayingDie
end

function TdEnemyController:_dieShowWork(heroPos)
	if self._enemyObj then	
		-- logError("_dieShowWork")
		-- logError("_dieShowWork"..GC.uu.Dump(self._enemyObj))
		--[[
		if heroPos == nil then
			heroPos = self:GetLastHitHeroPos();			
			-- 如果是其他玩家的，又没有找到，寻找本ID下最近的一个英雄pos
			if heroPos == nil and not self._isPlayerKill then
				local myPos = self._enemyObj._obj.position;
				local hi = ZTD.TableData.GetData(self._killPlayerId, "heroInfo");
				local minLenth = 99999;
				
				local heroMgr = ZTD.Flow.GetHeroMgr();
				local heroList = heroMgr:GetCtrlList();
				local heroPosRecord = {};
				for _, v in pairs(heroList) do
					local posId = ZTD.MainScene.HeroGS2PosId(v._block, v._setup);
					heroPosRecord[posId] = v._obj.position;
				end
				-- hi = nil?
				for posId, v in pairs(hi or {}) do
					local hPos = heroPosRecord[posId];
					local lenth = Vector3.Distance(hPos, myPos);
					if lenth < minLenth then
						minLenth = lenth;
						heroPos = ZTD.MainScene.SetupPos2UiPos(hPos);
					end
				end
			end
		end
		--]]
		heroPos = nil;
		self._enemyObj:playAnim("Dead")
		
		--被气球怪击杀的夜王不播放夜王头和蓄力特效
		local isPlayEff = true
		if self.__monId == 10004 then
			if self.balloonRatio > 0 then
				isPlayEff = false
			end
			-- if self.balloonRatio > 0 or self.giantRatio > 0 then
			-- 	isPlayEff = false
			-- end
		end
		if isPlayEff then
			self:playDeadEff("_deadStartEffect", "deadStartEffect");
		end
		
		self._isPlayingDie = true;
		
		if self._deadSound then
			ZTD.PlayMusicEffect(self._deadSound, nil, nil, true);
		end	
	end
	if not self.IsConnect or (self.IsConnect and self.__monId == 10001) or (self.IsConnect and self.__monId == 10005) then
		self:CheckPlayCoin();
	end
end

-- 爆金币函数，在进退后台被销毁前，也要调用一次
function TdEnemyController:CheckPlayCoin(objPos)
	if self._moneyEarn > 0 and not self._isPlayCoin then
		-- logError("objPos="..GC.uu.Dump(objPos))
		local coinDropPos = objPos and objPos or self:GetObjPos();
		-- logError("coinDropPos="..GC.uu.Dump(coinDropPos))
		ZTD.GoldFlyFactor.PlayCoinWork(self._dieData, self._isPlayerKill, self._moneyEarn, coinDropPos, self._cfg, self._isUnSelect);
		self._isPlayCoin = true;
	end
end

function TdEnemyController:AddDmgBullet(dmgBulletId, heroPos, isChange)
	local dmgData = {};
	dmgData.id = dmgBulletId;
	if heroPos then
		if isChange then
			dmgData.heroPos = heroPos;
		else	
			dmgData.heroPos = ZTD.MainScene.SetupPos2UiPos(heroPos);
		end
		dmgData.heroPos = Vector3(dmgData.heroPos.x, dmgData.heroPos.y + 1.5, dmgData.heroPos.z);
	end
	dmgData.isHit = false;
	self._dmgBullets[#self._dmgBullets + 1] = dmgData;	
end	

function TdEnemyController:DoHit(bulletId, hitEff, hitSound, isGoldEff)
	if self._enemyObj then
		if hitEff then
			self._enemyObj:PlayHitEffect(hitEff);
		end
		
		if isGoldEff then
			--ZTD.GoldPlay.PlayGoldEffect(ZTD.GoldPlay.TYPE_DROP_ONLY, self:GetObjPos(), math.random(1, 3));
			--self._enemyObj:PlayHitEffect("TD_Effect_JinBi001");
		end
		
		if hitSound then
			ZTD.PlayMusicEffect(hitSound);
		end
	end
	
	local dmgData;
	for _, v in ipairs(self._dmgBullets) do
		if bulletId == v.id then
			dmgData = v;
			dmgData.isHit = true;
			break;
		end
	end	
	-- logError("_isDoDie="..tostring(self._isDoDie))
	if self._isDoDie and dmgData ~= nil then
		local heroPos = dmgData.heroPos;
		-- logError("id:"  .. self._id .. ",hit bulletId:" .. bulletId)
		self:_dieShowWork(heroPos);
		self._dmgBullets = {};
		return;
	end
end

function TdEnemyController:SetDie(playerId, pMoneyEarn, pDieData)
	-- logError(os.date("%Y-%m-%d %H:%M:%S:") .. "-----------SetDie.SetDie.SetDie:" .. self._id)
	-- logWarn("------------SetDieSetDieSetDie:" .. self._id);
	local isPlayer = (playerId == ZTD.PlayerData.GetPlayerId());
	self._isPlayerKill = isPlayer;
	self._killPlayerId = playerId;
	self._moneyEarn = pMoneyEarn or 0;
	self._ratio = 0;
	self.balloonRatio = 0
	self._isDoDie = true;
	if pDieData then
		self._dieData = pDieData;
		self._ratio = pDieData.Ratio;
		self.balloonRatio = pDieData.BalloonRatio
	end
	if self._isUnSelect then
		self:_dieShowWork();
	end
	if self._isUnSelectBalloon then
		self._isDoDie = false
		self:CheckPlayCoin();
	end
end	

--气球怪攻击动作
function TdEnemyController:SetAttack(bombPos)
	--logError("_enemyObj="..tostring(self._enemyObj))
	if not self._enemyObj then return end
	self:SetAttackDir(Vector2(bombPos.bombWorldPos.x, bombPos.bombWorldPos.y))
	-- self:_setMoveDir(Vector3(bombPos.bombWorldPos.x, bombPos.bombWorldPos.y, 0))
	self._enemyObj:playAnim("Atk")
	self.atkIdx = self.atkIdx or 0
	self.atkIdx = self.atkIdx + 1
	if self.atkIdx == 1 then
		local pos = self._enemyObj.spEnemy.localPosition
		--logError("pos="..GC.uu.Dump(pos))
		self._enemyObj.spEnemy.localPosition = pos + Vector3(0, 0.8, 0)
	end
	-- logError("atkIdx="..tostring(self.atkIdx))
	if self.atkIdx >= 3 then
		ZTD.GameTimer.DelayRun(1.3, function()
			self:_dieShowWork()
		end)
	end
end

function TdEnemyController:isLost()
	local ret =  (self._isDoExit or self._isDoDie or self._isUnSelect or self._isUnSelectBalloon);
	return ret;
end	

function TdEnemyController:getCfgId()
	return self._cfg.id;
end

function TdEnemyController:SignedAngel(from, to)
	local delta = to-from
	local tmp = math.atan2(delta.y, delta.x)* 57.29578 + 451
	
	return tmp % 360
end

function TdEnemyController:SetAttackDir(bombPos)
	local angle = self:SignedAngel(self._enemyObj:getWorldPos(), bombPos)
	-- 1下 2右 3上 4左
	local dir = 1
	if angle > 45 and angle <= 135 then
		dir = 2
	elseif angle > 135 and angle <= 225 then
		dir = 3
	elseif angle > 225 and angle <= 315 then
		dir = 4
	end
	self._enemyObj:setDir(dir)
end

function TdEnemyController:_setMoveDir()
	local tgPath = self._paths[self._nowTarget];
	local v2_dir = Vector2.Normalize(Vector2(tgPath.x - self._x, tgPath.y - self._y));
	self._dirX = self._moveSpd * v2_dir.x;
	self._dirY = self._moveSpd * v2_dir.y;
	
	local a_rot_pi = math.atan2(v2_dir.y, v2_dir.x) + math.pi;
	-- 角度从逆时针开始计算,生成射击角度区间,根据落在哪个区间来旋转英雄的方向
	if not TdEnemyController.DirGap then
		local totalInx = 4;
		local gaps = {}
		for i = 1, totalInx do
			local len = (math.pi) / totalInx;
			gaps[i] = len + len * 2 * (i - 1);
		end	
		TdEnemyController.DirGap = gaps;
	end
	
	local gaps = TdEnemyController.DirGap;
	
	local dir = #gaps;
	for i = 1, #gaps - 1 do
		if a_rot_pi >= gaps[i] and a_rot_pi <= gaps[i + 1] then
			dir = i;
			break;
		end
	end	
	self._dir = dir;
	self._enemyObj:setDir(dir)
end	

-- 设置关键路径点	
function TdEnemyController:_setRouteCfg(routeCfg)
	local function _calcTime(pathInx, pathData)
		local lastPos;
		local lastTime = 0;
		if pathInx == 1 then
			lastPos = self._posEnter;
		else
			lastPos = self._paths[pathInx - 1];
			lastTime = self._paths[pathInx - 1].time;
		end

		local path_len = math.sqrt(math.pow(lastPos.x - pathData.x, 2) + math.pow(lastPos.y - pathData.y, 2));
		local pathTime = path_len / self._cfg.walkSpd;
		return pathTime + lastTime;
	end
	
	local MapInfo = ZTD.MainScene.GetMapInfo();	
	local enterPos = MapInfo.gates[routeCfg.enter]
	self._posEnter = enterPos;
	self._x = enterPos.x;
	self._y = enterPos.y;
	self._enemyObj:setPos(self._x, self._y);
	
	local exitPos = MapInfo.gates[routeCfg.exit];
	self._posExit = {x = exitPos.x, y = exitPos.y};

	local paths = string.split(routeCfg.path, "_");
	
	local function _setPathData(pathData)
		local pathInx = #self._paths + 1;
		local time = _calcTime(pathInx, pathData);
		pathData.time = time;
		self._paths[pathInx] = pathData;		
	end
	
	for _, v in ipairs(paths) do
		local inx = tonumber(v);
		local cross = MapInfo.cross[inx];
		local pathData = {x = cross.x, y = cross.y}; 
		_setPathData(pathData);		
	end
	
	local pathData = {x = self._posExit.x, y = self._posExit.y}; 
	_setPathData(pathData);
	
	self:_setMoveDir();
end
	
function TdEnemyController:Init(buildId, buildInfo)	
	self:MyCtor();
	local mapObj = ZTD.MainScene.GetMapObj();
	if self.monsterId == 10008 then
		mapObj = ZTD.MainScene.GetSpecialMapObj();
	end
	self._id = buildId;
	self._cfg = buildInfo.enemyCfg;	
	self._effectId = self._cfg.effectId;
	self._moveSpd = self._cfg.walkSpd;
	self.monsterId = self._cfg.id
	self._hp = self._cfg.hp;
	self._routeId = buildInfo.routeId;
	self.IsConnect = buildInfo.IsConnect;
	self.Level = buildInfo.Level
	self.giantCfg = ZTD.GiantConfig
	
	self._enemyObj = ZTD.EnemyObj:new(self._id);
	self._enemyObj:Init(buildInfo.objPath, self._cfg.modelPath, mapObj, 
		buildInfo.IsConnect, self.Level, self.monsterId, self._cfg.sortOrder or 0);
	self._enemyObj:playAnim("Walk");
	-- for temp
	local routeCfg = ZTD.RouteConfig[buildInfo.routeId];
	
	self:_setRouteCfg(routeCfg);	
	
	self:createBlood();
end

--------------------
--巨人
function TdEnemyController:SetGiantLevel(Level)
	self.Level = Level
	--logError("self.Level="..tostring(self.Level))
end

function TdEnemyController:GetGiantLevel()
	return self.Level
end
--------------------

function TdEnemyController:GetNowDir()
	return math.atan2(self._dirY, self._dirX);
end	

function TdEnemyController:getEnemyObj()
	if self._enemyObj then
		return self._enemyObj._obj;
	end	
end

function TdEnemyController:Update(dt)
end
function TdEnemyController:DealTouchLogic()
	ZTD.TableData.SetReadyLockTarget(nil, self._id) 
	ZTD.MainScene.SetPlayerLockTarget(self);
end	

function TdEnemyController:setLock(isLock)
	if self._enemyObj and isLock and (not self._isLock) then
		--logError("self.__monId="..tostring(self.__monId))
		ZTD.BattleView.inst:SetLockIcon(self.__monId, self.IsConnect)
		self._enemyObj:addLockMark();
	elseif self._enemyObj and not isLock and self._isLock then
		ZTD.BattleView.inst:SetLockIcon()
		self._enemyObj:RemoveLockMark();
	end
	self._isLock = isLock;
end

function TdEnemyController:setDebug(dbinx, dbinx2, dbinx3)
	if true then
		return;
	end
	local spDebug
	local myRenderer
	
	spDebug = self._enemyObj._obj:FindChild("sp_debug1");
	if spDebug then
		spDebug:SetActive(true);
		spDebug:GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("TowerDefMode", "jb_" .. dbinx);
		
		spDebug = self._enemyObj._obj:FindChild("sp_debug2");
		spDebug:SetActive(true);
		spDebug:GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("TowerDefMode", "jb_" .. dbinx2);
		
		spDebug = self._enemyObj._obj:FindChild("sp_debug3");
		spDebug:SetActive(true);
		spDebug:GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("TowerDefMode", "jb_" .. dbinx3);	
	end
end	


function TdEnemyController:UpdateBuffer(id, isDel)
	if self:isLost() then
		return
	end
	
	if isDel then
		local tgCfg = self._buffList[id];
		self._buffList[id] = nil;
		if tgCfg and tgCfg.Type == 1 then
			self._enemyObj:SpeedDown(false);
		end		
	else
		local tgCfg = ZTD.BufferConfig[id];
		self._buffList[id] = ZTD.BufferConfig[id];
		if tgCfg.Type == 1 then
			self._enemyObj:SpeedDown(true);
		end		
	end	

end	
	
function TdEnemyController:checkBufferExist(id)
	if self._buffList[id] then
		return true;
	else
		return false;
	end
end	
	
function TdEnemyController:makeWalkProcesss(dt, isInit)

	local function checkGoOver()	
		local tgPath = self._paths[self._nowTarget];

		local moveDt = dt;
		
		local buffList = self._buffList;
		if next(buffList) and not isInit then
			for _, v in pairs(buffList) do
				local buffCfg = ZTD.BufferConfig[v.Id];
				if buffCfg.Type == 1 then
					moveDt = moveDt * buffCfg.Rate;
				end
			end	
		end	
		if self.monsterId == 10008 and not isInit then
			-- logError("Level="..tostring(self.Level))
			-- logError("self.giantCfg.spdCfg[self.Level]="..tostring(self.giantCfg.spdCfg[self.Level]))
			moveDt = moveDt * self.giantCfg.spdCfg[self.Level]/self.giantCfg.spdCfg[1]
		end
		
		self._walkTime = self._walkTime + moveDt;
		self._x = self._x + self._dirX * moveDt;
		self._y = self._y + self._dirY * moveDt;	
		if self._walkTime > tgPath.time then
			return true;
		else
			return false;
		end
	end
	
	local checkRet = checkGoOver();
	-- 计算溢出时间,再算出溢出的路程
	if checkRet then
		local beginT = self._nowTarget + 1;
		local isMoveOver = true;
		for i = beginT, #self._paths do
			local lastPath = self._paths[i - 1];
			local nowPath = self._paths[i];
			if self._walkTime <= nowPath.time then
				self._x = lastPath.x;
				self._y = lastPath.y;
				self._nowTarget = i;
				self:_setMoveDir();
				local pathDt = self._walkTime - lastPath.time;
				self._x = lastPath.x + pathDt * self._dirX;
				self._y = lastPath.y + pathDt * self._dirY;
				isMoveOver = false;
				break;
			end
		end		
	
		if isMoveOver then
			--log("---------------!!!isMoveOverisMoveOverisMoveOver:" .. self._id)
			self._nowTarget = #self._paths + 1;
			self._isDoExit = true;
		end	
	end		
end

-- 用步行经过的时间设置当前的位置
function TdEnemyController:SkipPosToTime(st)
	--log("--------------------SkipPosToTime:" .. math.floor(st) .. "," .. self._id);
	--重置入口点和时间
	self._x = self._posEnter.x;
	self._y = self._posEnter.y;
	self._walkTime = 0;
	self._nowTarget = 1;
	self:makeWalkProcesss(st, true);
	--log("---------------!!!self._nowTargetself._nowTargetself._nowTarget:" .. self._nowTarget)
	self._enemyObj:setPos(self._x, self._y);	
end

-- 数组请求，目前只使用于毒爆怪
function TdEnemyController.ReqMulDoDamage(pickEnemys, shotCb, UsePositionId, poxCtrl, forceRatio)
	local constCfg = ZTD.ConstConfig[1];
	local SpecialInfo = {};

	--logError(string.format("---------------!!!mul poxCtrl id:%s time:%s", poxCtrl._id, poxCtrl._walkTime));
	for _, hitEnemy in ipairs(pickEnemys) do
		table.insert(SpecialInfo, 
						{MonsterId = hitEnemy.__monId, 
						PositionId = hitEnemy._id,
						ChannelId = hitEnemy._routeId;
						ProcessTime = math.floor(hitEnemy._walkTime * constCfg.SecondRate);						
						})
	end
	if next(SpecialInfo) then
		local cfg = ZTD.ConstConfig[1];
		local data = { }
		-- 服务器需要缺省ID
		data.MonsterId = 10001;
		data.PositionId = 0;
		data.Mode = cfg.ParamMode;
		data.UsePositionId = UsePositionId or 0;
		data.UsePositionTimes = poxCtrl._id or 1;
		data.SpecialInfo = SpecialInfo;
		--特殊怪物攻击类型 1.巨龙2.毒爆3.尸鬼龙 5.气球怪
		data.SpecialType = 2;
		if forceRatio then
			data.Ratio = forceRatio;
		else	
			data.Ratio = ZTD.PlayerData.GetMultiple() or 1;
		end

		local succCb = function(err, data)
			for _, hitEnemy in ipairs(pickEnemys) do
				shotCb(hitEnemy);
			end
		end
		
		local errCb = function(err, data)	
			logError("[ZTD_NET_ERROR]MulAttackReqEnemy NetError:" .. tostring(err));
		end
		-- logError("毒爆怪 AttackReq data = "..GC.uu.Dump(data))
		ZTD.Request.AttackReq(data, succCb, errCb);	
	else

	end
end

-- 数组请求，只使用于巨龙之怒
function TdEnemyController.ReqMulDoDamage2(pickEnemys, shotCb, DragonEnd, forceRatio, reqCb)
	TdEnemyController._ReqMulDoDamageSpec(nil, pickEnemys, shotCb, forceRatio, reqCb, 3, 1, DragonEnd);
end

-- 数组请求，只使用于尸鬼龙喷火
function TdEnemyController.ReqMulDoDamage3(pickEnemys, shotCb, forceRatio)	
	TdEnemyController._ReqMulDoDamageSpec(nil, pickEnemys, shotCb, forceRatio, nil, 3, 3);
end

-- 数组请求，只使用于气球怪
function TdEnemyController.ReqMulDoDamage4(pickEnemys, shotCb, DragonEnd, forceRatio, UsePositionId, reqCb)	
	TdEnemyController._ReqMulDoDamageSpec(UsePositionId, pickEnemys, shotCb, forceRatio, reqCb, 10, 5, DragonEnd);
end

-- 数组请求，只使用于巨人
function TdEnemyController.ReqMulDoDamage5(pickEnemys, shotCb, DragonEnd, forceRatio, UsePositionId, reqCb)	
	TdEnemyController._ReqMulDoDamageSpec(UsePositionId, pickEnemys, shotCb, forceRatio, reqCb, 1000, 7, DragonEnd);
end

-- 群攻通用接口
function TdEnemyController._ReqMulDoDamageSpec(UsePositionId, pickEnemys, shotCb, forceRatio, reqCb, limitCount, SpecialType, DragonEnd)
	local cfg = ZTD.ConstConfig[1];
	local SpecialInfo = {};	
	-- 服务器要求一次不能发太多怪，故而分批
	local limitCount = limitCount;
	local specInx = 1;
	local helpCount = 1;
	-- logError("pickEnemys="..GC.uu.Dump(pickEnemys))
	for _, hitEnemy in ipairs(pickEnemys) do
		if not SpecialInfo[specInx] then
			SpecialInfo[specInx] = {};
			SpecialInfo[specInx].spInfo = {};
			SpecialInfo[specInx].pickEnemys = {};
		end
	
		--logError(string.format("---------------!!!mul dragon hitEnemy id:%s ", hitEnemy._id));
		table.insert(SpecialInfo[specInx].spInfo, 
						{MonsterId = hitEnemy.__monId, 
						PositionId = hitEnemy._id,						
						});
						
		table.insert(SpecialInfo[specInx].pickEnemys, hitEnemy);
		
		helpCount = helpCount + 1;
		if helpCount >= limitCount then
			helpCount = 0;
			specInx = specInx + 1;
		end
	end
	if next (SpecialInfo) or DragonEnd then
		local enemyCount = 1;
		-- log("SpecialInfo="..GC.uu.Dump(SpecialInfo))
		--特殊处理气球怪免费子弹没有击中任何怪的情况
		if next (SpecialInfo) == nil and DragonEnd and SpecialType == 5 then
			local data = { }
			-- 服务器需要缺省ID
			data.MonsterId = 10001;
			data.PositionId = 0;
			data.Mode = cfg.ParamMode;
			data.UsePositionId = UsePositionId or 0
			-- data.SpecialInfo = v.spInfo;
			--特殊怪物攻击类型 1.巨龙2.毒爆3.尸鬼龙 5.气球怪 7.巨人
			data.SpecialType = SpecialType;
			data.DragonEnd = DragonEnd
			-- if k == #SpecialInfo then
			-- 	data.DragonEnd = DragonEnd;
			-- 	v.IsLastReq = true;
			-- else
			-- 	data.DragonEnd = false;
			-- end	
			if forceRatio then
				data.Ratio = forceRatio;
			else	
				data.Ratio = ZTD.PlayerData.GetMultiple() or 1;
			end
			local succCb = function(err, data)
				-- logError("succCb")
				-- for _, hitEnemy in ipairs(v.pickEnemys) do
				-- 	shotCb(hitEnemy);
				-- end
				if reqCb then
					reqCb();
				end
			end
			
			local errCb = function(err, data)
				logError("errCb"..GC.uu.Dump(err))
				if reqCb then
					reqCb();
				end			
			end
			--log("UsePositionId="..tostring(data.UsePositionId))
			--logError("AttackReq data="..GC.uu.Dump(data))
			ZTD.Request.AttackReq(data, succCb, errCb);	
			return
		end
		for k, v in ipairs(SpecialInfo) do
			local data = { }
			-- 服务器需要缺省ID
			data.MonsterId = 10001;
			data.PositionId = 0;
			data.Mode = cfg.ParamMode;
			data.UsePositionId = UsePositionId or 0
			data.SpecialInfo = v.spInfo;
			--特殊怪物攻击类型 1.巨龙2.毒爆3.尸鬼龙 5.气球怪 7.巨人
			data.SpecialType = SpecialType;
			
			if k == #SpecialInfo then
				data.DragonEnd = DragonEnd;
				v.IsLastReq = true;
			else
				data.DragonEnd = false;
			end	
			if forceRatio then
				data.Ratio = forceRatio;
			else	
				data.Ratio = ZTD.PlayerData.GetMultiple() or 1;
			end
			
			local succCb = function(err, data)
				for _, hitEnemy in ipairs(v.pickEnemys) do
					shotCb(hitEnemy);
				end
				if reqCb and v.IsLastReq then
					reqCb();
				end
			end
			
			local errCb = function(err, data)
				if reqCb and v.IsLastReq then
					reqCb();
				end			
			end
			--log("UsePositionId="..tostring(data.UsePositionId))
			--logError("AttackReq data="..GC.uu.Dump(data))
			ZTD.Request.AttackReq(data, succCb, errCb);	
		end
	end
end
	
function TdEnemyController:ReqDoDamage(shotCb, isDmg, UsePositionId, UsePositionTimes, forceRatio, uuid)
	if self._isUnSelect then
		return;
	end

	if self._isUnSelectBalloon then
		return
	end
		
	local cfg = ZTD.ConstConfig[1];
	local data = { }
	data.MonsterId = self.__monId;
	data.PositionId = self._id;
	data.Mode = cfg.ParamMode;
	data.UsePositionId = UsePositionId or 0;
	data.UsePositionTimes = UsePositionTimes or 1;
	data.HeroUniqueId = uuid;
	
	if forceRatio then
		data.Ratio = forceRatio;
	else	
		data.Ratio = ZTD.PlayerData.GetMultiple() or 1;
	end
	
	-- 如果显示金币不够，弹去充值界面
	if ZTD.GoldData.Gold.Show - data.Ratio < 0 and isDmg then
		--logError("Gold.Show - data.RatioGold.Show - data.RatioGold.Show - data.Ratio")
		ZTD.Notification.GamePost(ZTD.Define.MsgLackMoney);
		return;
	end	

	local succCb = function(err, data)
		local dmgBulletId, heroPos = shotCb(self);
		if dmgBulletId then
			--logError("id:" .. self._id .. ",save bulletId:" .. dmgBulletId)			
			self:AddDmgBullet(dmgBulletId, heroPos);
		end

		--ZTD.PlayerData.UpdateRadioReq();
	end
	local errCb = function(err, data)	
		-- 10007金币不足
		if err == 10007 then
            ZTD.Notification.GamePost(ZTD.Define.MsgLackMoney);
		-- 同步机制导致这两个错误总是会有，所以特殊处理
		-- 10044怪物已经被击杀，请勿连续击杀多
		-- 10065场上不存在该怪物	
		elseif (err == 10044 or err == 10065) then
			return;
		
			--self._mgr:ReadyDestory(self._id);
			--self:_dieShowWork();
		else
			logError("[ZTD_NET_ERROR]AttackReqEnemy:" .. self._id .. ",NetError:" .. tostring(err) .. ",UsePositionId:" .. tostring(UsePositionId));
		end
	end
	
	if isDmg then
		ZTD.Request.AttackReq(data, succCb, errCb)
	else
		succCb();
	end
end

function TdEnemyController:IsRelease()
	return self._isRelease;
end
	
function TdEnemyController:FixedUpdate(dt)	
	if self._isRelease then
		return;
	end
		
	if self._isDoExit then
		-- 通知服务器，怪物离场
		ZTD.Request.CSTowerMonsterExitReq({PositionId = self._id});
		self._mgr:DestoryCtrl(self);		
		return;
	end
	
	self._enemyObj:FixedUpdate(dt)
		
	local function removeEff()
		if self._deadEndEffect then
			for k, v in ipairs(self._deadEndEffect) do
				v.obj:SetActive(false);
				ZTD.PoolManager.RemoveGameItem(v.name, v.obj);
			end
			self._deadEndEffect = nil;
		end		
	end		
			
	-- logError("_isPlayingDie="..tostring(self._isPlayingDie))
	if self._isPlayingDie then		
		if self._enemyObj:checkAnimEnd("Dead") or self._isUnSelect then
			-- 播放死亡特效
			if self._deadEndEffect == nil and self._effectId then
				self:playDeadEff("_deadEndEffect", "deadEndEffect", true);
				ZTD.GameTimer.DelayRun(2, function()
					removeEff();
				end)
			end
			self._mgr:DestoryCtrl(self);
		end
		return;
	end	
	
	if self._isDoDie then
		self._forceDieCd = self._forceDieCd + dt;
		-- logError("_forceDieCd="..tostring(self._forceDieCd))
		if self._forceDieCd > 0.5 then
			self:_dieShowWork();
			return;
		end
	end	
	
	if not self._isUnSelect and not self._isUnSelectBalloon then
		self:makeWalkProcesss(dt);	
		self._enemyObj:setPos(self._x, self._y);
	elseif self._isUnSelect or self._isUnSelectBalloon then
		self._forceDieCd = self._forceDieCd + dt;
		-- 从敌人无法被选（SetUnSelect 之后）开始，如果超过180秒没有被销毁，则强制销毁
		if self._forceDieCd > 180 then
			self:_dieShowWork();
			
			local playerId = self._UnSelectKillId or 0;
			local posId = self._id;
			local unSelectRootId = self._unSelectRootId or 0;
			
			local debug_log = "force_kill:" .. playerId .. ",p:" .. posId .. ",f:" .. unSelectRootId;
			-- logError(os.date("%Y-%m-%d %H:%M:%S:") .. " force_kill," .. debug_log);
			
			--ZTD.Utils.ShowWaitTip();
			local succCb = function(err,data)
				--ZTD.Utils.CloseWaitTip();
			end				
			ZTD.Request.CSDebugDataReq({DebugData = debug_log}, succCb, succCb);
			
			return;
		end		
	end	
	
	if (self._isDoExit) then			
		-- 通知服务器，怪物离场
		if not self._isRelease then
			ZTD.Request.CSTowerMonsterExitReq({PositionId = self._id});
		end	
--			logWarn("-------------exit and buildId:" .. self._id);
		self._mgr:DestoryCtrl(self);
	end
end

function TdEnemyController:Release()
	if self._isRelease then
		return;
	end
	if self._isLock then
		ZTD.MainScene.SetPlayerLockTarget();
	end
	
	if self._deadStartEffect then
		for k, v in ipairs(self._deadStartEffect) do
			v.obj:SetActive(false);
			ZTD.PoolManager.RemoveGameItem(v.name, v.obj);
		end
		self._deadStartEffect = nil;
	end
	
	-- 释放之前再一次检查金币流程
	if not self.IsConnect or (self.IsConnect and self.__monId == 10001) or (self.IsConnect and self.__monId == 10005) then
		self:CheckPlayCoin();
	end
	if self._enemyObj then
		self._enemyObj:Release();
		self._enemyObj = nil;
	end
	
	self._isRelease = true;
end





return TdEnemyController;