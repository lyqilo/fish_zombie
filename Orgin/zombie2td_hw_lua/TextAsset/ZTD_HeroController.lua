local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu



-----------------------TdHeroObj-----------------------

local ColorP = 
{
Color(1, 0.7, 0.17, 0.5),
Color(0, 0, 0, 0),
Color(0, 0, 0, 0),
Color(0, 0, 0, 0),
--Color(0, 1, 0.05, 0.35),
--Color(0, 0.3, 1, 0.5),
--Color(1, 0, 0, 0.5),
}
local AniState = {
	Idle = "Idle",
	Atk = "Atk"
}

local TdHeroObj = GC.class2("TdHeroObj")
function TdHeroObj:Init(obj, config, isSelf, playerId)
	self._obj = obj;
	self._cfg = config
	self.isSelf = isSelf
	self.playerId = playerId
	self._hero = self._obj:FindChild("sp_hero")
	self._heroSelf = self._obj:FindChild("sp_hero_self")
	self._hero:SetActive(not isSelf)
	self._heroSelf:SetActive(isSelf)
	self.posY = 0.8
	self.spHero = isSelf and self._heroSelf or self._hero
	self._animator = self.spHero:GetComponent("Animator")
	-- 朝向角度 0度朝下，逆时针0~360
	self:setDir(math.random(0,360))
	self:playAnim(AniState.Idle)

	
	self._shootEffPath = self._cfg.bulletShootEff;
	
	-- 附加特效
	self._attachNodes = {};
	--self:SetMatirial()
	self.baoqi = self._obj:FindChild("TD_Effect_L_baoqi1")
	self._obj:FindChild("Effect_HitRat"):SetActive(false)
	self.actionList = {}
	ZTD.Notification.GameRegister(self, ZTD.Define.HistoryTrend, self.SetSealEffPos)
end

--所有英雄命中率表现
function TdHeroObj:SetSealEff1(state, len, hitRatList, posY)
	-- logError("state="..tostring(state))
	self.posY = posY
	local heroSealEff = self._obj:FindChild("Effect_HitRat")
	if not heroSealEff then return end
	if state then
		-- logError("heroSealEff.activeSelf="..tostring(heroSealEff.activeSelf))
		if heroSealEff.activeSelf then
			return
		end
		heroSealEff:FindChild("num1"):GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("Prefab", "mzl_"..hitRatList[1])
		heroSealEff:FindChild("num2"):GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("Prefab", "mzl_"..hitRatList[2])
		heroSealEff:FindChild("num3"):GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("Prefab", "mzl_"..hitRatList[3])
		heroSealEff.localPosition = Vector3(0, -0.5, 0)
		heroSealEff.localScale = Vector3.one
		heroSealEff:SetActive(state)
		local showAct = ZTD.Extend.RunAction(heroSealEff,
		{
			{"scaleTo", 0, 0, 0, 0}, 
			{"delay", 0.05}, 
			{"scaleTo", 1.2, 1.2, 1.2, 0.03},
			{"delay", 0.1}, 
			{"scaleTo", 1, 1, 1, 0.03},
			{"delay", 0.1},
			{"localMoveTo", 0, posY, 0, 0.4},
			{"call", function()
				self.isActionEnd = true
				self:SetSealEffPos(not ZTD.BattleView.inst:FindChild("node_history").activeSelf)
			end}
		})
		table.insert(self.actionList, showAct)
	else
		local endAct = ZTD.Extend.RunAction(heroSealEff,
		{
			{"spawn", 
				{"scaleTo", 0, 0, 0, 0.33},
				{"localMoveTo", 0, 1.8, 0, 0.33},
			},
			{"call", function()
				heroSealEff:SetActive(state)
				heroSealEff.localPosition = Vector3(0, -0.5, 0)
				heroSealEff.localScale = Vector3.one
			end}
		})
		table.insert(self.actionList, endAct)
	end
end

function TdHeroObj:SetSealEffPos(isClose)
	if not self.isActionEnd then
		return
	end
	local heroSealEff = self._obj:FindChild("Effect_HitRat")
	if not heroSealEff then return end
	local posY = self.posY + 0.4
	if isClose then
		posY = self.posY
	end
	heroSealEff.localPosition = Vector3(heroSealEff.localPosition.x, posY, heroSealEff.localPosition.z)
end

function TdHeroObj:RemoveAction()
	if not self.actionList then return end
	for k, v in ipairs(self.actionList) do
		if v then
			ZTD.Extend.StopAction(v)
		end
	end
	self.actionList = nil
end


--所有英雄封印表现
function TdHeroObj:SetSealEff2(isSelf, state)
	local heroSealEff = self._obj:FindChild("Effect_UI_BUFF")
	if not heroSealEff then return end
	heroSealEff:SetActive(state)
	local guangEff = heroSealEff:FindChild("GUANG")
	guangEff:SetActive(isSelf)
end

function TdHeroObj:SetSaveMode()
	if self.baoqi then
		self.baoqi.transform:SetActive(not ZTD.isSaveMode)
	end
	if --[[self.isSelf and --]]self._ef_stand then
		self._ef_stand.transform:SetActive(not ZTD.isSaveMode)
	end

end

--[[function TdHeroObj:SetMatirial()
	local mat = ResMgr.LoadAsset("prefab", "sprite_outline")
	if not mat then
		logError("SetMatirial null")
	end
	local selfRenderer = self.spHero:GetComponent(typeof(UnityEngine.Renderer))
	selfRenderer.sharedMaterial = mat
end--]]


function TdHeroObj:setDir(angle)
	self._angle = angle
	if angle > 202.5 and angle < 337.5 then
		self.flip = true
		self.spHero.localRotation = Quaternion.Euler(0, 180, 0);
	else
		self.flip = false
		self.spHero.localRotation = Quaternion.Euler(0, 0, 0);
	end	
	local idx = math.modf((angle+22.5)/45) 
	self.atkIdx = idx==0 and 8 or idx
	
	angle = angle > 180 and math.abs(angle-360) or angle
	self._animator:SetFloat("Angle", angle)
	
end

function TdHeroObj:setPos(x, y)
	self._obj.localPosition = Vector3(x, y, 0);

	local constCfg = ZTD.ConstConfig[1];

	--local limitH = constCfg.LogicHeight / 100;

	local y_total = 300;

	--local gaps = {};

	--[[for i = 1, y_total do
		gaps[i] = (limitH/y_total) * i - limitH/2;
	end


	local sortY = 1;
	for i = y_total, 1, -1 do
		if y > gaps[i] then
			sortY = y_total - i + 1;
			break;
		end
	end
	--]]

	local sortY = math.abs(y*100-constCfg.LogicHeight/2)/y_total*10000
	if self._sortY ~= sortY then
		self._sortY = sortY;

		local function _setSort(spSet, sortY)
			local myRenderer = spSet:GetComponentInChildren(typeof(UnityEngine.Renderer));
			--myRenderer.sortingLayerName = "sort" .. sortY;
			myRenderer.sortingOrder = sortY
			--logError("sortY="..tostring(sortY))
			--logError("myRenderer.sortingOrder="..tostring(myRenderer.sortingOrder))
			local buff = self._obj:FindChild("Effect_UI_BUFF")
			buff:FindChild("yuan"):GetComponent(typeof(UnityEngine.ParticleSystemRenderer)).sortingOrder = sortY+1
			buff:FindChild("GUANG"):GetComponent(typeof(UnityEngine.ParticleSystemRenderer)).sortingOrder = sortY+2
			buff:FindChild("GUANG/yuanhuan"):GetComponent(typeof(UnityEngine.ParticleSystemRenderer)).sortingOrder = sortY+2
		end

		_setSort(self.spHero, self._sortY);

		--local spSet = self._obj:FindChild("sp_hero_stand");
		--_setSort(spSet, 1);--self._sortY - 1);

		--local spSh = self._obj:FindChild("sp_shadow");
		--_setSort(spSh, self._sortY - 1);
	end

	self:UpdateEffectLayer();
end

-- 重新更新附加特效的层级
function TdHeroObj:UpdateEffectLayer()
	for _, attachNode in ipairs (self._attachNodes) do
		local children = attachNode.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer));
		for i = 0 ,children.Length - 1 do 
			children[i].sortingLayerName = "sort" .. self._sortY;
		end
	end	
end	

function TdHeroObj:AttachEffect(effFilePath)
	-- 重复处理
	if self._attachNodes[effFilePath] then
		return;
	end
	
	local constCfg = ZTD.ConstConfig[1];
	
	local attachNode = ZTD.Extend.LoadPrefab(effFilePath, self._obj);
	
	attachNode.localPosition = Vector3.zero;
	
	local myRenderer = self.spHero:GetComponentInChildren(typeof(UnityEngine.Renderer));

    local children = attachNode.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer));
    for i = 0 ,children.Length - 1 do 
        children[i].sortingLayerName = "sort" .. self._sortY;
        children[i].sortingOrder = children[i].sortingOrder - constCfg.HeroFakerOrder + myRenderer.sortingOrder;
    end
	
	self._attachNodes[effFilePath] = attachNode;
end

function TdHeroObj:RemoveEffect(effFilePath)
	if self._attachNodes[effFilePath] then
		ZTD.Extend.Destroy(self._attachNodes[effFilePath]);
		self._attachNodes[effFilePath] = nil;
	end
end

function TdHeroObj:RemoveAllEffect()
	for _, v in pairs (self._attachNodes) do
		ZTD.Extend.Destroy(v.gameObject);
	end
	self._attachNodes = {};
end

function TdHeroObj:getPos()
	return Vector2(self._obj.localPosition.x, self._obj.localPosition.y);
end

function TdHeroObj:playAnim(value)
	if value == AniState.Idle and not self.baoqi then
		return
	end
	self._animator:SetTrigger(value)
end 

function TdHeroObj:PlayShootEff()
	if not self._shootEffPath then
		return
	end
	self:RemoveShootEff()
	self._shootEff = ZTD.PoolManager.GetGameItem(self._shootEffPath, self.spHero)
	local qua = Quaternion.AngleAxis(self._angle-180, self.flip and Vector3.back or Vector3.forward)
	self._shootEff.localRotation = qua;
	self._shootEff.localPosition = self._cfg.shootEffPos[self.atkIdx]
	self.shootRemoveTimer = ZTD.GameTimer.DelayRun(0.5,function ()
		self:RemoveShootEff()
		self.shootRemoveTimer = nil
	end)
	return self._shootEff.position
end

function TdHeroObj:RemoveShootEff()
	if self.shootRemoveTimer then
		ZTD.GameTimer.StopTimer(self.shootRemoveTimer)
		self.shootRemoveTimer = nil
	end
	if self._shootEff then
		ZTD.PoolManager.RemoveGameItem(self._shootEffPath, self._shootEff);
		self._shootEff = nil;
	end
end

function TdHeroObj:SetStand(standInx, isPlayer)
	self.chairId = standInx
	
	local spStand = self._obj:FindChild("sp_hero_stand");
	spStand:GetComponent("SpriteRenderer").sprite = ResMgr.LoadAssetSprite("Prefab", "hero_stand" .. standInx);
	
	--local selfRenderer = self.spHero:GetComponent(typeof(UnityEngine.Renderer))
	
		--selfRenderer.material:SetColor("_OutlineColor", ColorP[standInx])

	
	--selfRenderer.material:SetInt("_ShowOutline", isPlayer and 0 or 0);	

	local eff_root = self._obj:FindChild("TD_Effect_PAOTAI");
	
	if self._ef_stand then
		ZTD.PoolManager.RemoveGameItem(self._ef_stand.gameObject.name, self._ef_stand)
	end

--	ZTD.GameTimer.DelayRun(0.1, function ()
--	if isPlayer then	
		local ef_stand = ZTD.PoolManager.GetGameItem("TD_Effect_PAOTAI" .. standInx, eff_root);
		ef_stand.localPosition = Vector3.zero;
		ef_stand:SetActive(false)
		ef_stand:SetActive(true)
		local ef1 = ef_stand:FindChild("Effect_tazuo");
		local ef2 = ef_stand:FindChild("Effect_tazuo/Effect_tazuo");
		
		local ef1Renderer = ef1:GetComponent(typeof(UnityEngine.Renderer));
		ef1Renderer.sortingLayerName = "sort1";--"sort" .. self._sortY;	
		ef1Renderer.sortingOrder = 2;

		local ef2Renderer = ef2:GetComponent(typeof(UnityEngine.Renderer));
		ef2Renderer.sortingLayerName = "sort1";--"sort" .. self._sortY;
		ef2Renderer.sortingOrder = 2;
		
		self._ef_stand = ef_stand;
--	end
--	end)
end

function TdHeroObj:Release()
	if self._shootEff then
		ZTD.PoolManager.RemoveGameItem(self._shootEffPath, self._shootEff);
		self._shootEff = nil;
	end

	if self._ef_stand then
		ZTD.PoolManager.RemoveGameItem(self._ef_stand.gameObject.name, self._ef_stand)
	end
	self:RemoveShootEff()
	self:RemoveAllEffect();
	self:RemoveAction()
end


-----------------------TdHeroController----------------------------

local TdHeroController = GC.class2("TdHeroController", ZTD.ObjectController)
local SUPER = ZTD.ObjectController;

function TdHeroController:Release()
	self:HideScoreUi();
	self._heroObj:Release();
	SUPER.Release(self);
end	
	
function TdHeroController:Init(buildId, buildInfo)
	local cfg = ZTD.ConstConfig[1];   
	local mapObj = ZTD.MainScene.GetMapObj();
	
	self._cfg = buildInfo.heroCfg;
	self._uuid = buildInfo.uuid
	self._heroPos = buildInfo.heroPos;
	self._shootCd = 0;
	self._shootLimit = self._cfg.shootCd; 
	self._atk = self._cfg.atk;	
	self._atkRange = self._cfg.atkRange;	
	self._isPlayAtk = false;
	self._block = buildInfo.block;
	self._setup = buildInfo.setup;
	self._isShootContinue = false;
	self._fakerShootTimes = 1;

	buildInfo.objPath = cfg.ResPath;
	buildInfo.objFile = self._cfg.modelPath;
	buildInfo.objParent = mapObj;
	SUPER.Init(self, buildId, buildInfo);
	
	self._heroObj = TdHeroObj:new();
	self._obj:SetActive(true);
	self._heroObj:Init(self._obj, self._cfg, buildInfo.playerId== ZTD.PlayerData.GetPlayerId(), buildInfo.playerId);
	self._heroObj:setPos(buildInfo.srcPos.x, buildInfo.srcPos.y);
	
	self._playerId = buildInfo.playerId;
	
	self.chairId = ZTD.TableData.GetData(self._playerId, "ChairId") or 1
	self.isSelf = self._playerId == ZTD.PlayerData.GetPlayerId()
	self._heroObj:SetStand(self.chairId, self.isSelf);
	--self:beginAtk();
	
	self:ShowScoreUi();
	self:SetSaveMode()
end

function TdHeroController:SetSaveMode()
	self._heroObj:SetSaveMode()
end

function TdHeroController:Hide()
	self._obj:SetActive(false);
	self._heroPos._node_summon:SetActive(true);
	self._isHide = true;
	self:HideScoreUi();
end

function TdHeroController:Show()
	self._obj:SetActive(true);
	self._heroPos._node_summon:SetActive(false);
	self._isHide = false;
	self:ShowScoreUi();
end

function TdHeroController:pauseAtk()
	self._isPlayAtk = false;
	self._heroObj:playAnim(AniState.Idle);
end	

function TdHeroController:beginAtk(stdt)
	if stdt then
		self._shootCd = stdt - math.floor(stdt/self._shootLimit);
	end	
	
	self._isPlayAtk = true;
end	

function TdHeroController:isAutoPlayAtk()
	return self._isPlayAtk;
end	

function TdHeroController:_shoot(customLock, playerLock)
	
	local isPlayer = (self._playerId == ZTD.PlayerData.GetPlayerId());
	local checkRange = self._atkRange;
	local myPos = self._obj.localPosition;
	-- 如果是我的英雄，设置优先目标
	local posId = ZTD.MainScene.HeroGS2PosId(self._block, self._setup);
	
	if playerLock and ZTD.MainScene.IsEnemyInRange(playerLock, myPos, checkRange) then
		customLock = playerLock;
	end	
	
	-- 玩家锁定的，优先判断是否可以攻击
	local lockTarget = customLock;
	if lockTarget and not ZTD.MainScene.IsEnemyInRange(lockTarget, myPos, checkRange) then
		lockTarget = nil;
	elseif lockTarget and self._targetEnemy ~= lockTarget and isPlayer then
		-- 如果更换了锁定目标，更新readylock告诉其他玩家，以同步
		ZTD.TableData.SetReadyLockTarget(posId, lockTarget._id);
	end
	
	-- 如果是没开攻击，又选了敌人，就是强制锁定，则强制赋值
	if (customLock and self._isPlayAtk == false) then
		self._targetEnemy = lockTarget;
	end
	
	if self._targetEnemy ~= lockTarget then
		self._targetEnemy = lockTarget;
	-- 不符合条件则依然瞄准上一个目标，判断是否在范围
	elseif self._targetEnemy then
		if not ZTD.MainScene.IsEnemyInRange(self._targetEnemy, myPos, checkRange) then
			self._targetEnemy = nil;
		end
	end	
	
	-- 只有开启了自动攻击后，才有了选择目标之后的判断
	if self._isPlayAtk and isPlayer and self._targetEnemy == nil then		
		-- 没有锁定目标，则重新搜索目标
		local readyTargetEnemy = ZTD.MainScene.CheckEnemyInRange(myPos, checkRange);
		if readyTargetEnemy then
			ZTD.TableData.SetReadyLockTarget(posId, readyTargetEnemy._id);
		end
	end
	
	if self._targetEnemy then
		local isDmg = false;
		self._fakerShootTimes = self._fakerShootTimes - 1;
		if self._fakerShootTimes == 0 then
			self._fakerShootTimes = self._cfg.fakerShootTimes or 1;
			isDmg = isPlayer;
		end	
		self:ForceShotTarget(self._targetEnemy, isDmg);
		return true;
	else
		--ZTD.TableData.SetLockTarget(posId, nil);
		--ZTD.TableData.SetReadyLockTarget(posId, ZTD.TableData.NullTarget);	
		self._heroObj:playAnim(AniState.Idle);
		return false;
	end
end

function TdHeroController:SignedAngel(from, to)
	local delta = to-from
	local tmp = math.atan2(delta.y, delta.x)* 57.29578 + 451
	
	return tmp % 360
end
function TdHeroController:ForceShotTarget(pTarget, isDmg, isNoAnim)
	if self._isHide then
		return;
	end	
	
	-- 播放音效
	if not self._cfg.isIgnoreShootSound then
		if self._cfg.isShootContinueSound and self._isShootContinue then
			ZTD.PlayMusicEffect("ZTD_shoot_continue_" .. self._cfg.id);
		else
			ZTD.PlayMusicEffect("ZTD_shoot_" .. self._cfg.id);
		end	
	end	
	local angle = self:SignedAngel(self._heroObj:getPos(), pTarget._enemyObj:getPos())

	-- angel 0朝下，逆时针 0~360
	self._heroObj:setDir(angle);

	self._heroObj:playAnim(AniState.Atk);
	local posShoot = self._heroObj:PlayShootEff()

	-- 子弹创造瞬间就发送请求,仅自己上阵英雄有实际发送请求
	local function shootCb()
		if pTarget._isDoExit or pTarget._isUnSelect or pTarget._isUnSelectBalloon or pTarget:getEnemyObj() == nil then
		--if pTarget:isLost() or pTarget:getEnemyObj() == nil then
			return nil;
		end
		
		if self._obj then
			local heroPos = self._heroObj._obj.position;
			local myPos = heroPos;
			if posShoot then
				myPos = posShoot;
			end
			if self._cfg.id == 1005 then
				myPos = Vector3(myPos.x, myPos.y + 0.5, myPos.z)
			end
			-- 记录子弹ID
			local hitEff = self._cfg.bulletHitEff;
			local hitSound;
			if not self._cfg.isIgnoreHitSound then
				hitSound = "ZTD_hit_" .. self._cfg.id;
			end	
						
			local bulletId = ZTD.Flow.GetBulletMgr():createBullet(
																	{
																		objFile = self._cfg.bulletPath, 
																		target = pTarget, 
																		srcPos = myPos, 
																		heroPos = heroPos,
																		hitEff = hitEff,
																		hitSound = hitSound,
																		bulletId = self._cfg.id,
																		playerId = self._playerId
																	}
																);
			return bulletId, heroPos;
		end;	
	end
	
	pTarget:ReqDoDamage(shootCb, isDmg, nil, nil, nil, self._uuid);
end	

function TdHeroController:DealTouchLogic()		
	ZTD.Notification.GamePost(ZTD.Define.MsgOpenHeroMenu, self._block, self._setup);
end

function TdHeroController:DoSkill()
	local mapObj = ZTD.MainScene.GetMapObj();
    local Bomb = ZTD.PoolManager.GetGameItem("ZTD_missileBomb", mapObj)
    Bomb.localPosition = Vector3(-2, -1, 0);	
end	

function TdHeroController:FixedUpdate(dt)

	local isPlayer = (self._playerId == ZTD.PlayerData.GetPlayerId());
	local playerLock;
	if isPlayer then
		playerLock = ZTD.MainScene.GetPlayerLockTarget();
	end

	local posId = ZTD.MainScene.HeroGS2PosId(self._block, self._setup);
	local customLock = ZTD.MainScene.GetLockCtrl(posId);
	
	if self._isPlayAtk or customLock ~= nil or playerLock ~= nil then	
		if self._shootCd <= 0 then
			if self:_shoot(customLock, playerLock) then
				self._shootCd = self._shootLimit;
				self._isShootContinue = true;
			else
				self._isShootContinue = false;
			end	
		else
			self._shootCd = self._shootCd - dt;
		end
	else
		self._heroObj:playAnim(AniState.Idle)
	end
	
end

function TdHeroController:OpenScoreUi()
	self._showScore = true;
	self:ShowScoreUi();
end

function TdHeroController:CloseScoreUi()
	self._showScore = false;
	self:HideScoreUi();
end
	
function TdHeroController:ShowScoreUi()
	if ZTD.TrendDraw.IsOpen then
		self._showScore = true;
	end
	
	if self._showScore and self._scoreUi == nil then
		ZTD.TableData.BindHeroUuidUi(self._uuid, self);
		self._scoreUi = ZTD.PoolManager.GetUiItem("ZTD_HeroScoreTag", ZTD.GoldPlay.topNode);
		local uiPos = ZTD.MainScene.SetupPos2UiPos(self._heroObj._obj.position);
		if self._cfg.id == 1005 then
			self._scoreUi.position = Vector3(uiPos.x, uiPos.y + 4, uiPos.z);
		else
			self._scoreUi.position = Vector3(uiPos.x, uiPos.y + 2.5, uiPos.z);
		end
		local isPlayer = (self._playerId == ZTD.PlayerData.GetPlayerId());
		self._scoreUi:FindChild("img_player"):SetActive(isPlayer);
		self._scoreUi:FindChild("img_other"):SetActive(not isPlayer);

		self:UpdateScoreUi();
		-- if self._cfg.id == 1005 then
		-- 	self._scoreUi:SetActive(false)
		-- end
	end
end

function TdHeroController:UpdateScoreUi()
	if self._scoreUi then
		if self._cfg.id == 1005 then
			self._scoreUi:FindChild("node_win"):SetActive(false);
			self._scoreUi:FindChild("node_lose"):SetActive(false);
			self._scoreUi:FindChild("img_player"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "ZTD_skill0004")
			self._scoreUi:FindChild("img_other"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "ZTD_skill0004")
			self._scoreUi:FindChild("node_skillTimes"):SetActive(true);
			local score1 = ZTD.TableData.GetMaSkillTimes(self._uuid) or 0;
			self._scoreUi:FindChild("node_skillTimes/txt_score").text = "X" .. tostring(score1)
			return
		end
		local score = ZTD.TableData.GetHeroUuidMoeny(self._uuid) or 0;
		local tgNode;
		local signed = "";
		if score >= 0 then
			self._scoreUi:FindChild("node_win"):SetActive(true);
			self._scoreUi:FindChild("node_lose"):SetActive(false);
			tgNode = self._scoreUi:FindChild("node_win");
		else
			self._scoreUi:FindChild("node_win"):SetActive(false);
			self._scoreUi:FindChild("node_lose"):SetActive(true);
			tgNode = self._scoreUi:FindChild("node_lose");
			signed = "-";
		end

		tgNode:FindChild("txt_score").text = signed .. GC.uu.NumberFormat(math.abs(score));
	end
end

function TdHeroController:HideScoreUi()
	if self._scoreUi then
		ZTD.TableData.BindHeroUuidUi(self._uuid, nil);
		ZTD.PoolManager.RemoveUiItem("ZTD_HeroScoreTag", self._scoreUi);
		self._scoreUi = nil;
	end	
end

--------------------------------------------------------------------------
local SUPER = TdHeroController;
local Hero1001 = GC.class2("Hero1001", TdHeroController);
function Hero1001:Init(buildId, buildInfo)
	SUPER.Init(self, buildId, buildInfo)
end

local Hero1002 = GC.class2("Hero1002", TdHeroController);
function Hero1002:ForceShotTarget(pTarget, isDmg)
	if self._isHide then
		return;
	end
	
	local myPos = self._obj.localPosition;
	
	local rets = {};
	local list = ZTD.Flow.GetEnemyMgr():GetCtrlList();
	local spreadRange = 1;
	local spreadNums = 2;	
	local retMaxDistance;
	
	for _, v in pairs(list) do
		local isCheck = not v._isPlayingDie and not v:isLost() and v._enemyObj ~= nil and pTarget ~= v and ZTD.MainScene.NowTargets[v:getCfgId()];
		-- 如果不是自己，则不用筛选
		if not isDmg then
			isCheck = not v._isPlayingDie and not v:isLost() and v._enemyObj ~= nil and pTarget ~= v
		end
		if v.IsConnect and not ZTD.MainScene.NowTargets[10007] then
			isCheck = false
		end
		if isCheck then	
			local epos = v:getEnemyObj().localPosition;
			local distance = Vector3.Distance(myPos, epos);
			if distance <= self._atkRange then
				local distance2 = Vector3.Distance(pTarget:getEnemyObj().localPosition, epos);
				if distance2 <= spreadRange then
					if #rets == 0 then
						table.insert(rets, v);
						retMaxDistance = distance2;
					else
						if #rets == spreadNums then
							table.remove(rets, 1);
						end						
						if distance2 < retMaxDistance then
							table.insert(rets, v);
						else
							table.insert(rets, 1, v);
							retMaxDistance = distance2;
						end
					end
				end
			end
		end
	end	
	table.insert(rets, pTarget);
	for _, vTarget in ipairs (rets) do
		SUPER.ForceShotTarget(self, vTarget, isDmg, false);
	end
end

local Hero1003 = GC.class2("Hero1003", TdHeroController);
function Hero1003:ForceShotTarget(pTarget, isDmg)
	SUPER.ForceShotTarget(self, pTarget, isDmg);
	
	-- 如果buffer 1存在(冻结状态)，则做二段攻击
	if pTarget:checkBufferExist(1) then
		ZTD.GameTimer.DelayRun(0.2, function ()
			if not pTarget:isLost() and pTarget._enemyObj ~= nil and self._obj ~= nil and ZTD.Flow.IsTrusteeship then
				SUPER.ForceShotTarget(self, pTarget, isDmg, true);
			end	
		end)	
	end
end

local Hero1004 = GC.class2("Hero1004", TdHeroController);

local Hero1005 = GC.class2("Hero1005", TdHeroController);
function Hero1005:Init(buildId, buildInfo)
	SUPER.Init(self, buildId, buildInfo)
end

TdHeroController.Hero1001 = Hero1001;
TdHeroController.Hero1002 = Hero1002;
TdHeroController.Hero1003 = Hero1003;
TdHeroController.Hero1004 = Hero1004;
TdHeroController.Hero1005 = Hero1005;

return TdHeroController