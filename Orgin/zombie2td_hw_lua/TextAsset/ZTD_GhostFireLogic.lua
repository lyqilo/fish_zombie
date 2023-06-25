local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local GhostFireLogic = GC.class2("ZTD_GhostFireLogic");

-- 配置数据

local SpitFirePrefab = "ZTD_ICE_SL";

local SpitFirePrefabDX0 = -5.91;
local SpitFirePrefabDX = -3.24;
local SpitFirePrefabDY = 4.25;
local SpitFirePrefabDZ = -43;

local SpitFireSkillX = -2.63;
local SpitFireSkillY = -0.13;
local SpitFireSkillZ = 0;

local SpitFireSkillId = 10015;

-- 尸鬼龙入场时间
local SpitFireStartTime = 0.5;
-- 喷火逻辑间隔
local SpitFireRate = 1;
-- 进入攻击状态后的喷火开始时间
local SpitFireActiveTime = 0.25;

local OGG_GHOST_FIRE = "Ghost_fire";

local function PlayAnimation(targetSp, value)
	local playAni = targetSp:GetComponent("Animator");
	if playAni == nil then
		return;
	end
	if (targetSp.gameObject.activeSelf)then
		playAni:SetTrigger(value);
	end
	playAni.speed = 1;
end

function GhostFireLogic:ctor(_, fireUi)
	self._modeFunc = {};
	
	self._modeFunc["Enter"] = self.ModeEnter;
	self._modeFunc["Atk"] = self.ModeAtk;
	self._modeFunc["Leave"] = self.ModeLeave;
	
	self._rootUi = fireUi;
	
	-- 记录喷火的起点终点坐标
	self._srcPos = Vector3(SpitFirePrefabDX0, SpitFirePrefabDY, SpitFirePrefabDZ);	
	self._goSpd = Vector3(SpitFirePrefabDX - SpitFirePrefabDX0, 0, 0) / SpitFireStartTime;	
	
	self._nodeGhost = ZTD.PoolManager.GetGameItem (SpitFirePrefab, ZTD.MainScene.SceneObj:FindChild("node_3d"));
	self._nodeSpit = self._nodeGhost:FindChild("huo_1");
	self._nodeModel = self._nodeGhost:FindChild("Shigui/spine/SL_02_01");
	self._nodeGhost:SetActive(false);
end

function GhostFireLogic:SetComboNode(comboNode)
	--logError("GhostFireLogic setsetSetsetsetSetsetset comboNode:" .. tostring(comboNode) .. "!!!!!:" .. debug.traceback());
	-- 为nil则清空
	if comboNode == nil then
		self._comboNode = nil;
		-- 在免费结算时，同步金币时使用
		ZTD.GhostFireLogic.ComboNode = nil;
		return;
	end

	-- 只赋值一次
	if self._comboNode == nil then
		self._comboNode = comboNode;
		ZTD.GhostFireLogic.ComboNode = comboNode;
	end	
end

function GhostFireLogic:ActiveRoad(isSelf)
	self:Release(true);
	
	-- 正在离开，还没被删除
	self._isLeaving = false;
	-- 已经离开完毕，被删除
	self._isActive = true;
	-- 初始化喷火的起点状态
	self._nodeGhost.localPosition = self._srcPos;
	self._nodeGhost:SetActive(true);	
	self._nodeSpit:SetActive(false);
	PlayAnimation(self._nodeModel, "READY");
	
	
	
	self._skillPos = Vector3(SpitFireSkillX, SpitFireSkillY, SpitFireSkillZ);
	
	-- 各种状态下的活动时间
	self._actTime = 0;
	-- 喷火时间计
	self._spitTime = 0;
	
	self._ratio = self._ratio or 1;
	
	self._isSelf = isSelf;
	
	self._actMode = "Enter";
	
	ZTD.Flow.AddUpdateList(self);
	
end


function GhostFireLogic:Release(isHoldCombo)
	if self._isActive then
		ZTD.StopMusicEffect(OGG_GHOST_FIRE);
		if self._nodeGhost then
			self._nodeGhost:SetActive(false);
		end	
		--ZTD.PoolManager.RemoveGameItem(SpitFirePrefab, self._nodeGhost);
		--self._nodeGhost = nil;
		if not isHoldCombo then
			self:SetComboNode(nil);
		end	
		self._isActive = false;
		ZTD.Flow.RemoveUpdateList(self);
	end
end

-- 状态机动作 入场 - 攻击 - 退场
function GhostFireLogic:ModeEnter(dt)
	if self._actTime > SpitFireStartTime then
		--self._nodeSpit:SetActive(true);
		self._nodeGhost.localPosition = Vector3(SpitFirePrefabDX, SpitFirePrefabDY, SpitFirePrefabDZ);
		self._actMode = "Atk";
		self._actTime = 0;
	else
		self._nodeGhost.localPosition = self._nodeGhost.localPosition + self._goSpd * dt;
	end
end

function GhostFireLogic:ModeAtk(dt)
	self._spitTime = self._spitTime + dt;
	if self._spitTime > SpitFireActiveTime then
		if not self._nodeSpit.activeSelf then
			self._nodeSpit:SetActive(true);
			if self._isSelf then
				self._rootUi:StartUiFrame();
			end	
			ZTD.PlayMusicEffect(OGG_GHOST_FIRE, nil, true, true);
		end	
	end	
	
	if self._isSelf and self._actTime > SpitFireRate then
		local skillMgr = ZTD.Flow.GetSkillMgr();
		skillMgr:AddSkill(SpitFireSkillId,
		{isSelf = self._isSelf,
		pos = self._skillPos,
		ratio = self._ratio,
		SpitFireMode = 1});
		
		self._actTime = 0;
	end	

end

function GhostFireLogic:ModeLeave(dt)
	self._nodeGhost.localPosition = self._nodeGhost.localPosition - self._goSpd * dt;
	if self._actTime > 1 then
		self._actMode = "";
		self:Release();
	end
end

function GhostFireLogic:PushLeave()
	if not self._isLeaving then
		self._isLeaving = true;
		self._actMode = "Leave";
		self._actTime = 0;
		if self._nodeGhost and self._nodeModel then
			PlayAnimation(self._nodeModel, "LEAVE");
		end	
		self._nodeSpit:SetActive(false);
		if self._isSelf then
			self._rootUi:StopUiFrame();
		end	
		ZTD.StopMusicEffect(OGG_GHOST_FIRE);
	end
end

function GhostFireLogic:GetRatio()
	return self._ratio or 1;
end	

function GhostFireLogic:SetRatio(ratio)
	self._ratio = ratio;
end	

function GhostFireLogic:FixedUpdate(dt)
	self._actTime = self._actTime + dt;
	if self._modeFunc[self._actMode] then
		self._modeFunc[self._actMode](self, dt);
	end
end

return GhostFireLogic;