local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local Skill = GC.class2("ZTD_Skill");

function Skill:Init(skillId, skillData, skillMgr)
	self._liveTime = 0;
	self._effTime = 0;
	self._rectTime = 0;
	self._cfg = ZTD.MainScene.GetSkillCfg(skillId);
	self._skillData = skillData;
	
	self._hitEnemys = {};
	self._blocks = {};
	self._rects = {};	
	
	self._isLogicOver = false;
	self._isSkillRectEnd = false;
	
	self._skillMgr = skillMgr;

	self:CreateSkillWay();
end

function Skill:CreateSkillWay()
	if self._cfg.sType == 1 then
		self:CreateSkillRect(self._cfg.collWidth, self._cfg.collHigh, 0)
		self:CreateSkillEff(0, 0, 0, 1)
		self:PlayBalloonAction(0, 0, 0, 1)
	elseif self._cfg.sType == 2 then
		local isCross = false;
		local pos = self._skillData.pos;
		local crossInfo = ZTD.MainScene.GetMapInfo().cross;
		for _, v in pairs(crossInfo) do
			local len = math.sqrt(math.pow(v.x - pos.x, 2) + math.pow(v.y - pos.y, 2));
			-- 算出和十字路口位置的距离，以判断是否落在十字口
			if len <= 0.35 then
				isCross = true;
				break;
			end
		end
		
		local dirPi = self._skillData.dir;		
		local gap = self._cfg.gap;
		local blocks = self._skillData.blocks;
		for i = 1, blocks do
			self:CreateSkillEff(gap * i, dirPi, self._cfg.gapTime * (i - 1), 1);
		end
		
		for i = 1, blocks do
			self:CreateSkillEff(gap * i, dirPi + math.pi, self._cfg.gapTime * (i - 1), 2);
		end
		self:CreateSkillRect(self._cfg.collWidth * (blocks * 2 + 1), self._cfg.collHigh, dirPi)
		
		if isCross then
			for i = 1, blocks do
				self:CreateSkillEff(gap * i, dirPi + math.pi/2, self._cfg.gapTime * (i - 1), 3);
			end
		
			for i = 1, blocks do
				self:CreateSkillEff(gap * i, dirPi + math.pi * 1.5, self._cfg.gapTime * (i - 1), 4);
			end
			
			self:CreateSkillRect(self._cfg.collWidth * (blocks * 2 + 1), self._cfg.collHigh, dirPi + math.pi/2)
		end
	end
end

--播放气球怪炸弹飞行动画
function Skill:PlayBalloonAction(gap, rotPi, gapTime, group)
	if not self._cfg.balloonHitEff then
		return;
	end
	if self._skillData.enemyCtrl then
		--logError("self._skillData.bombPos="..GC.uu.Dump(self._skillData.bombPos))
		self._skillData.enemyCtrl:SetAttack(self._skillData.bombPos)
	end
	-- logError("self._skillData.bombPos="..GC.uu.Dump(self._skillData.bombPos))
	local eff = ZTD.PoolManager.GetGameItem(self._cfg.balloonHitEff, ZTD.MainScene.GetMapObj())
	eff.localPosition = self._skillData.pos
	eff.localScale = Vector3.one
	eff:FindChild("tuowei").gameObject:SetActive(false)
	eff:FindChild("tuowei").gameObject:GetComponent("TrailRenderer").enabled = false
	-- 针对怪物的特殊运动函数
	local doActFunc = function(eff)
		eff:SetActive(false)
		ZTD.Extend.RunAction(eff, {
			{"delay", 0.3, onEnd = function() 
				eff:SetActive(true) 
			end},
			{"spawn",
				{
					{"delay", 0, onEnd = function()
						local function endFunc()
							eff:FindChild("tuowei"):SetActive(false)
							eff:SetActive(false)
							ZTD.PoolManager.RemoveGameItem(self._cfg.balloonHitEff, eff)
						end
						local targetPos = self._skillData.bombPos.bombWorldPos
						local p1 = eff.position + (targetPos - eff.position) * 0.5 + Vector3(0, 1, 0)
						local bezUpHeroAct = ZTD.Extend.RunBezier(targetPos, eff.position, eff, nil, endFunc, 0.7, p1)		
					end},
				},
				{
					{"delay", 0.45, onEnd = function() 
						eff:FindChild("tuowei"):SetActive(true)
						eff:FindChild("tuowei").gameObject:GetComponent("TrailRenderer").enabled = true
					end},
				},
		    }
		})
	end	
	doActFunc(eff)			
end

--创建技能特效
function Skill:CreateSkillEff(gap, rotPi, gapTime, group)
	if not self._cfg.file then
		return;
	end
	local block = {};
	
	local oneX = math.cos(rotPi);
	local oneY = math.sin(rotPi);
	local offsetX = gap * oneX;
	local offsetY = gap * oneY;
	local skillObj = ZTD.PoolManager.GetGameItem(self._cfg.file, ZTD.MainScene.GetMapObj());
	skillObj:SetActive(false);
	block.skillObj = skillObj;
	block.gapTime = gapTime;

	local pos = self._skillData.pos;
	-- logError("pos="..GC.uu.Dump(pos))
	block.pos = Vector3(pos.x + offsetX, pos.y + offsetY, pos.z);
	local mapPos = ZTD.MainScene.GetMapObj().localPosition
	if self._skillData.bombPos then
		local targetPos = self._skillData.bombPos.bombSelfPos
		block.skillObj.localPosition = targetPos
	else
		block.skillObj.localPosition = block.pos;
	end
	
	local rotation = Quaternion.Euler(0, 0, rotPi / math.pi * 180);
	block.skillObj.localRotation = rotation;	
	
	block.group = group;
	block.rotPi = rotPi;
	
	table.insert(self._blocks, block);
	return block;
end	

--创建技能框
function Skill:CreateSkillRect(width, high, dirPi)
	if not self._skillData.isSelf then
		return;
	end
	
	local skillRect = ZTD.PoolManager.GetGameItem(self._cfg.rect, ZTD.MainScene.GetMapObj());
	skillRect:SetActive(false);
	skillRect.localRotation = Quaternion.Euler(0, 0, dirPi / math.pi * 180);
	local pos = self._skillData.pos;
	local mapPos = ZTD.MainScene.GetMapObj().localPosition
	if self._skillData.bombPos then
		local targetPos = self._skillData.bombPos.bombSelfPos
		skillRect.localPosition = targetPos
	else
		skillRect.localPosition = Vector3(pos.x, pos.y, pos.z)
	end
	local skillRectSize = Vector2(width, high);
	skillRect:GetComponent("BoxCollider2D").size = skillRectSize;

	local function checkRectHit()
		local enemyMgr = ZTD.Flow.GetEnemyMgr();
		for _, hitEnemy in pairs (enemyMgr._ctrlList) do
			local hitObj = hitEnemy:getEnemyObj();
			if hitObj and not hitEnemy:isLost() and hitEnemy.__monId ~= self._cfg.InvalidId 
				and (self._max_target == nil or self._max_target > 0) then
					
					local subX = math.abs(hitObj.localPosition.x - skillRect.localPosition.x);
					local subY = math.abs(hitObj.localPosition.y - skillRect.localPosition.y);
					
					local checkSize = hitObj:GetComponent("BoxCollider2D").size or Vector2(0, 0);
					
					if subX < (skillRectSize.x /2 + checkSize.x/2) and subY < (skillRectSize.y /2 + checkSize.y/2) then				
						table.insert(self._hitEnemys, hitEnemy);
					end	
			end		
		end
	end	
	
	--[[
	local utility = skillRect:GetComponent("CollisionTriggerUtility")
	if utility then
		local function onTriggerEnter2D(_, triggerGameObj)
			local hitEnemy = ZTD.Flow.GetEnemyMgr():getCtrlByTransForm(triggerGameObj.transform);
			if hitEnemy and not hitEnemy:isLost() and hitEnemy.__monId ~= self._cfg.InvalidId 
				and (self._max_target == nil or self._max_target > 0) then
				table.insert(self._hitEnemys, hitEnemy);
			end				
		end		
		utility.onTriggerEnter2D = onTriggerEnter2D
	end
	--]]
	local rectData = {};
	rectData.skillRect = skillRect;
	rectData.checkRectHitFunc = checkRectHit;
	table.insert(self._rects, rectData);
end	

-- 播放技能特效
function Skill:ActiveEffect(dt)
	if #self._blocks == 0 then
		return self._effTime;
	end	

	local removeMark = {};
	for k, v in ipairs(self._blocks) do
		
		if self._effTime >= v.gapTime then
			local skillObj = v.skillObj
			local pos = self._skillData.pos;
			v.skillObj:SetActive(true);
			if self._cfg.balloonHitEff then
				ZTD.PlayMusicEffect("ZTD_balloonBomb", 0.4, nil, true)
			end
			local effFunc;
			effFunc = ZTD.Flow.AddTimeFunc(self._cfg.playTime, function()
				v.skillObj:SetActive(false);
				ZTD.PoolManager.RemoveGameItem(self._cfg.file, v.skillObj);
				v.skillObj = nil;
				self._skillMgr._timeFuncs[effFunc] = nil;
			end)
			self._skillMgr._timeFuncs[effFunc] = true;
			table.insert(removeMark, k - #removeMark);
		end
	end

	for k, removeKey in ipairs(removeMark) do
		table.remove(self._blocks, removeKey);
	end
	
	self._effTime = self._effTime + dt;
end

-- 实行技能逻辑
function Skill:ActiveLogic()
	for k, v in ipairs(self._rects) do		
		v.skillRect:SetActive(true);
		
		if v.checkRectHitFunc then
			v.checkRectHitFunc();
		end	
		
		--local actFunc;
		--actFunc = ZTD.Flow.AddTimeFunc(self._cfg.RectStayTime, function()
			--local utility = v.skillRect:GetComponent("CollisionTriggerUtility");
			--utility.onTriggerEnter2D = nil;
			v.skillRect:SetActive(false);
			ZTD.PoolManager.RemoveGameItem(self._cfg.rect, v.skillRect);
			self._isSkillRectEnd = true;
			--self._skillMgr._timeFuncs[actFunc] = nil;
		--end)
		--self._skillMgr._timeFuncs[actFunc] = true;
	end
	
	self._rects = {};
end

function Skill:UpdateEffect(dt)
	if not self._cfg.file then
		return true;
	end
	
	local isUpdateEffect = false;
	local isEffectOver = false;	
	-- 依赖字段(特效播放时机)
	-- 0 无
	-- 1 字段enemyCtrl死亡时播放
	if self._cfg.Depend_Effect == nil or self._cfg.Depend_Effect == 0 then
		isUpdateEffect = (self._liveTime >= self._cfg.startTime);
	elseif self._cfg.Depend_Effect == 1 then
		if (self._skillData.enemyCtrl == nil) or 
			(not self.__DependTime and self._skillData.enemyCtrl:IsPlayDie()) then
			self.__DependTime = 0;
		end
		
		if self.__DependTime then
			self.__DependTime = self.__DependTime + dt;
			isUpdateEffect = self.__DependTime >= self._cfg.startTime
		end	
	end	
	return (isUpdateEffect and self:ActiveEffect(dt));
end

function Skill:Update(dt)
	self._liveTime = self._liveTime + dt;
	
	-- 判断技能表现是否结束
	local isEffectOver = self:UpdateEffect(dt)
	
	-- 如果不是自己的技能，纯展示用，不做逻辑
	if not self._skillData.isSelf then
		return isEffectOver;
	end
	
	-- 技能碰撞框时间
	if self._liveTime >= self._cfg.RectStartTime then
		self:ActiveLogic();
	end	
	
	if self._isSkillRectEnd and not self._isLogicOver then
		local removeMark = {};
		local pickEnemys = {};
		
		for k, hitEnemy in ipairs(self._hitEnemys) do
			if self._max_target == nil then
				table.insert(pickEnemys, hitEnemy);
				table.insert(removeMark, k - #removeMark);				
			elseif self._max_target > 0 and hitEnemy.__poiId ~= self._skillData.poisonId then
				hitEnemy.__poiId = self._skillData.poisonId;
				self._max_target = self._max_target - 1;
				table.insert(pickEnemys, hitEnemy);
				table.insert(removeMark, k - #removeMark);
				--logWarn("self._max_target:" .. os.date("%Y-%m-%d %H:%M:%S:") .. self._max_target .. ",enmy id:" .. hitEnemy._id .. ",posId:" .. self._skillData.poisonId);
			end
		end
		for k, removeKey in ipairs(removeMark) do
			table.remove(self._hitEnemys, removeKey);
		end
		
		self:ActiveSkill(pickEnemys);		
		self._isLogicOver = true;	
	end
	
	-- 返回true删除这个skill
	if isEffectOver and self._isLogicOver then
		return true;
	else
		return false;
	end
end

function Skill:Release()

end


local SUPER = Skill;

--------------------------各种派生技能-------------------------------
-- 毒爆技能
local SkillPoison = GC.class2("SkillPoison", Skill);
function SkillPoison:Init(skillId, skillData, skillMgr)
	SUPER.Init(self, skillId, skillData, skillMgr);
	-- 如果是母体毒爆怪技能，最大捕捉数为:免费子弹+子毒爆怪的数量
	if skillId == 10001 then
		self._max_target = skillData.max_target + #self._skillData.addTimes;
	else
		self._max_target = self._skillData.max_target;
	end	
end	

-- 毒爆逻辑处理
function SkillPoison:ActiveSkill(pickEnemys)
	if self._skillData.poisonId == nil then
		return;
	end
	
	if next(pickEnemys) then
		local skillBulletId = ZTD.Flow.GetBulletMgr():IncreaseId();
		-- 攻击回调必定在金币同步推送之后发生
		local shotCb = function(hitEnemy)
			hitEnemy:AddDmgBullet(skillBulletId, self._skillData.heroPos, true);
			hitEnemy:DoHit(skillBulletId);
		end
		
		local enemyMgr = ZTD.Flow.GetEnemyMgr();
		local poxCtrl = enemyMgr:GetCtrlById(self._skillData.newPoisonId);
		if poxCtrl then
			--logError(os.date("%Y-%m-%d %H:%M:%S:") .. "___________ReqMulDoDamageReqMulDoDamageReqMulDoDamage:" .. self._skillData.poisonId .. "," .. poxCtrl._id)
			
			ZTD.SkillMgr.SetDatas(self._cfg.id, self._skillData.poisonId, self._skillData);
			
			ZTD.EnemyController.ReqMulDoDamage(pickEnemys, shotCb, self._skillData.poisonId, poxCtrl, self._skillData.ratio)
		end	
		
	else
	--[-[
		local param = {};
		param.PositionId = self._skillData.poisonId;
		param.UsePositionTimes = self._skillData.newPoisonId;
		param.NewPositionId = 0--self._skillData.newPoisonId;
		--logWarn("CSChangePoisonBomTimes:" .. os.date("%Y-%m-%d %H:%M:%S:") .. param.PositionId);
		local function sucCb()
			
		end
		
		local function errCb(err, data)
			-- logError("___________CSChangePoisonBomTimes Error:"..err)
		end					
		ZTD.Request.CSChangePoisonBomTimes(param, sucCb, errCb);		
		--logError("___________CSChangePoisonBomTimes REQ:"..param.UsePositionTimes or 0)
		
		if param.PositionId == param.UsePositionTimes then
			if self._skillData.addTimes == nil then
				-- logError("___________param.PositionId == param.UsePositionTimes Error:".. tostring(param.PositionId));
				return;
			end	
			for i = 1, #self._skillData.addTimes do
				local newId = self._skillData.addTimes[i];
				if newId ~= self._skillData.poisonId then
					--logError("mastermastermastermastermastermastermastermaster:" .. newId);
					local param = {};
					param.PositionId = self._skillData.poisonId;
					param.UsePositionTimes = newId;
					param.NewPositionId = 0--self._skillData.newPoisonId;
					ZTD.Request.CSChangePoisonBomTimes(param, sucCb, errCb);
				end
			end
		end
	--]]
	end	
end

--------------------------------------------------------------------------------
-- 巨龙之怒技能
local SkillDragon = GC.class2("SkillDragon", Skill);
function SkillDragon:ActiveSkill(pickEnemys)
	if self._skillData.DragonMode == nil then
		return;
	end
	-- logError("pickEnemys="..GC.uu.Dump(pickEnemys))
	-- logError("self._skillData.DragonEnd="..tostring(self._skillData.DragonEnd))
	if next(pickEnemys) then
		local skillBulletId = ZTD.Flow.GetBulletMgr():IncreaseId();
		-- 攻击回调必定在金币同步推送之后发生
		local shotCb = function(hitEnemy)
			hitEnemy:AddDmgBullet(skillBulletId, self._skillData.heroPos, true);
			local effName = self._cfg.hitEff
			if ZTD.isSaveMode then effName = nil end
			hitEnemy:DoHit(skillBulletId, effName, nil, true);
		end
		-- logError(os.date("%Y-%m-%d %H:%M:%S:") .. "___________ActiveDragonActiveDragonActiveDragon")
		ZTD.EnemyController.ReqMulDoDamage2(pickEnemys, shotCb, self._skillData.DragonEnd, self._skillData.ratio, self._skillData.callBack)
	elseif self._skillData.DragonEnd then
		ZTD.EnemyController.ReqMulDoDamage2(pickEnemys, function() end, self._skillData.DragonEnd, self._skillData.ratio, self._skillData.callBack)
	end
end	


--------------------------------------------------------------------------------
-- 尸鬼龙技能
local SkillSpit = GC.class2("SkillSpit", Skill);
function SkillSpit:ActiveSkill(pickEnemys)
	if self._skillData.SpitFireMode == nil then
		return;
	end
	--为了避免场上击杀两只夜王强制结算出问题，硬性规定夜王每轮只能圈中一只魅魔怪
	local num = 0
	local tb = {}
	for k, v in pairs(pickEnemys) do
		if v.__monId == 10006 then
			num = num + 1
			if num == 1 then
				table.insert(tb, v)
			end
		else
			table.insert(tb, v)
		end
	end
	pickEnemys = tb
	if next(pickEnemys) then
		
		-- 攻击回调必定在金币同步推送之后发生
		local shotCb = function(hitEnemy)
			local skillBulletId = ZTD.Flow.GetBulletMgr():IncreaseId();
			hitEnemy:AddDmgBullet(skillBulletId, self._skillData.heroPos, true);
			local effName = self._cfg.hitEff
			if ZTD.isSaveMode then effName = nil end
			hitEnemy:DoHit(skillBulletId, effName, nil, true);
		end

		--logError(os.date("%Y-%m-%d %H:%M:%S:") .. "___________ActiveDragonActiveDragonActiveDragon")
		ZTD.EnemyController.ReqMulDoDamage3(pickEnemys, shotCb, self._skillData.ratio);
	end
end	
	
----------------------------------------------------
-- 气球怪技能
local SkillBalloon = GC.class2("SkillBalloon", Skill);
function SkillBalloon:ActiveSkill(pickEnemys)
	if self._skillData.BalloonMode == nil then
		return;
	end
	-- logError("pickEnemys="..tostring(#pickEnemys))
	if next(pickEnemys) then
		--每次最多筛选5只怪
		local num = #pickEnemys
		local pickEnemysNew = {}
		if num > 5 then
			for i = 1, 5, 1 do
				table.insert(pickEnemysNew, pickEnemys[i])
			end
		else
			pickEnemysNew = pickEnemys
		end
		-- logError("pickEnemysNew="..#pickEnemysNew)
		-- 攻击回调必定在金币同步推送之后发生
		local shotCb = function(hitEnemy)
			local skillBulletId = ZTD.Flow.GetBulletMgr():IncreaseId();
			hitEnemy:AddDmgBullet(skillBulletId, self._skillData.heroPos, true);
			local effName = self._cfg.hitEff
			if ZTD.isSaveMode then effName = nil end
			hitEnemy:DoHit(skillBulletId, effName, nil, true);
		end
		--log("num="..#pickEnemysNew)
		--log(os.date("%Y-%m-%d %H:%M:%S:") .. "pickEnemysNew = "..GC.uu.Dump(pickEnemysNew))
		ZTD.EnemyController.ReqMulDoDamage4(pickEnemysNew, shotCb, self._skillData.DragonEnd, self._skillData.ratio, self._skillData.UsePositionId, self._skillData.callBack)
	elseif self._skillData.DragonEnd then
		ZTD.EnemyController.ReqMulDoDamage4(pickEnemys, function() end, self._skillData.DragonEnd, self._skillData.ratio, self._skillData.UsePositionId, self._skillData.callBack)
	end
end	

-- 巨人技能
local SkillGiant = GC.class2("SkillGiant", Skill)
function SkillGiant:ActiveSkill(pickEnemys)
	if self._skillData.GiantMode == nil then
		return
	end
	-- log("SkillGiant pickEnemys="..GC.uu.Dump(pickEnemys))
	if next(pickEnemys) then
		--log(os.date("%Y-%m-%d %H:%M:%S:") .. "pickEnemys = "..GC.uu.Dump(pickEnemys))
		-- 攻击回调必定在金币同步推送之后发生
		local shotCb = function(hitEnemy)
			local skillBulletId = ZTD.Flow.GetBulletMgr():IncreaseId();
			hitEnemy:AddDmgBullet(skillBulletId, self._skillData.heroPos, true);
			local effName = self._cfg.hitEff
			if ZTD.isSaveMode then effName = nil end
			hitEnemy:DoHit(skillBulletId, effName, nil, true);
		end
		ZTD.EnemyController.ReqMulDoDamage5(pickEnemys, shotCb, self._skillData.DragonEnd, self._skillData.ratio, self._skillData.UsePositionId, self._skillData.callBack)
	elseif self._skillData.DragonEnd then
		ZTD.EnemyController.ReqMulDoDamage5(pickEnemys, function() end, self._skillData.DragonEnd, self._skillData.ratio, self._skillData.UsePositionId, self._skillData.callBack)
	end
end

local SkillMgr = GC.class2("ZTD_SkillManager");
SkillMgr.Datas = {};
function SkillMgr.SetDatas(id, key, val)
	if not SkillMgr.Datas[id] then
		SkillMgr.Datas[id] = {};
	end
	SkillMgr.Datas[id][key] = val;
end

function SkillMgr.GetDatas(id, key, val)
	if SkillMgr.Datas[id] then
		return SkillMgr.Datas[id][key];
	end
end	

function SkillMgr:Init()
	self._skillList = {};
	
	self._timeFuncs = {};
	
	-- 毒爆怪转换通知
	ZTD.Notification.NetworkRegister(self, "SCPoisonBombConvert", self.OnPoisonBombConvert);
end

function SkillMgr:AddSkill(skillId, skillData)
--	logError(os.date("%Y-%m-%d %H:%M:%S:") .. "-----------AddSkillAddSkill:" .. skillData.poisonId)
	
	-- 根据技能数据选择对应使用的Skill类
	local SkillClass = Skill;
	if skillData.poisonId ~= nil then
		SkillClass = SkillPoison;
	elseif skillData.DragonMode ~= nil then
		SkillClass = SkillDragon;
	elseif skillData.SpitFireMode ~= nil then
		SkillClass = SkillSpit;
	elseif skillData.BalloonMode ~= nil then
		SkillClass = SkillBalloon;
	elseif skillData.GiantMode ~= nil then
		SkillClass = SkillGiant;
	end	
		
	local skill = SkillClass:new();
	skill:Init(skillId, skillData, self);
	self._skillList[skill] = true;
end

function SkillMgr:FixedUpdate(dt)
	for skill, _ in pairs(self._skillList) do
		if skill:Update(dt) then
			self._skillList[skill] = nil;
		end
	end
end

function SkillMgr:Release(isInGame)	
	for callFunc, _ in pairs(self._timeFuncs) do
		ZTD.Flow.ForceTimeFunc(callFunc)
	end	
	self._timeFuncs = {};
	
	for skill, _ in pairs(self._skillList) do
		skill:Release();
	end
	self._skillList = {};
	
	SkillMgr.Datas = {};
	
	if not isInGame then
		ZTD.Notification.NetworkUnregisterAll(self);
	end	
end

-- 创建被毒爆怪感染的怪物
function SkillMgr:OnPoisonBombConvert(Data)
	-- log(os.date("%Y-%m-%d %H:%M:%S:") .. "-----------OnPoisonBombConvert:" .. Data.KillPlayerID ..",Data.PoisonBombId:" .. Data.PoisonBombId);
	-- 毒爆怪技能ID 10001
	-- 子毒爆怪技能ID 10003
	-- 毒爆怪ID 10001
	-- 不写死ID的方法？
	local mainSkillId = 10001;
	local childSkillId = 10003;
	local poxEnemeyId = 10001;
	
	local isSelf = (Data.KillPlayerID == ZTD.PlayerData.GetPlayerId());
	
	local skillData = SkillMgr.GetDatas(mainSkillId, Data.PoisonBombId);
	SkillMgr.SetDatas(mainSkillId, Data.PoisonBombId, nil);
		
	local enemyMgr = ZTD.Flow.GetEnemyMgr();
	for _, v in ipairs(Data.Info) do
		local rd = {};
		rd.rotPi = 0;		
--		logError("OnPoisonBombCbuildCtrlbuildCtrlbuildCtrl kill and build:" .. v.PositionId .. "," .. v.poisonBombId);
		local buildCtrl = enemyMgr:GetCtrlById(v.PositionId);
		-- 当感染目标不在场上时...
		if buildCtrl == nil then
			-- 如果不是本地玩家自己的技能，不作处理
			if not isSelf then
				return;
			else
				rd.pos = Vector3.zero;
			end
		else	
			enemyMgr:ChangeId(v.PositionId, v.poisonBombId);
			buildCtrl.__monId = poxEnemeyId;
			
			local killId = Data.KillPlayerID;
			buildCtrl:SetUnSelect(killId);
			buildCtrl._unSelectRootId = Data.PoisonBombId;
			local heroPos = buildCtrl:GetLastHitHeroPos();


			if buildCtrl:getEnemyObj() then
				rd.pos = buildCtrl:getEnemyObj().localPosition;
			else
				rd.pos = Vector3.zero;
			end
		end
		
		if not skillData then
			skillData = {};
			skillData.isSelf = isSelf;
			skillData.blocks = 0;
			skillData.ratio = 1;
			skillData.max_target = 0;
			skillData.poisonId = Data.PoisonBombId;
			skillData.atkData = 0;
		end
		
		self:AddSkill(childSkillId, 
						{pos = rd.pos, 
						dir = rd.rotPi, 
						isSelf = isSelf,
						blocks = skillData.blocks, 
						enemyCtrl = buildCtrl, 
						ratio = skillData.ratio, 
						max_target = skillData.max_target, 
						poisonId = skillData.poisonId,
						newPoisonId = v.poisonBombId, 
						heroPos = nil,
						atkData = skillData.atkData});
	end	
end

function SkillMgr:CreateSkillMonster(cfgId, skillId, logicId, x, y, rotPi)
	local channelId = 1;
	local monsterID = cfgId;

	local enemyMgr = ZTD.Flow.GetEnemyMgr();
	local buildCtrl = enemyMgr:createEnemy(channelId, monsterID, logicId);
	local buildObj = buildCtrl:getEnemyObj();
	buildObj.localPosition = Vector3(x, y, 0);
	buildCtrl:SetUnSelect();
	
	local skillMgr = ZTD.Flow.GetSkillMgr();
	local heroPos = buildCtrl:GetLastHitHeroPos();
	skillMgr:AddSkill(skillId, 
					{pos = Vector3(x, y, 0),
					dir = rotPi, 
					isSelf = false,
					blocks = 0,
					ratio = 0, 
					max_target = 0, 
					poisonId = 0,
					newPoisonId = 0, 
					});
end

return SkillMgr;