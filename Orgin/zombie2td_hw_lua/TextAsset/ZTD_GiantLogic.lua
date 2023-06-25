local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

--始祖巨人
local GiantLogic = GC.class2("ZTD_GiantLogic")

local SpitFirePrefab = "SL_04_01_forShow"
local OGG_GHOST_FIRE = "Ghost_fire"

local SpitFirePrefabDX = 0
local SpitFirePrefabDY0 = 5
local SpitFirePrefabDY = 2
local SpitFirePrefabDZ = 0

-- 尸鬼龙入场时间
local SpitFireStartTime = 0.5
-- 喷火逻辑间隔
local SpitFireRate = 1
--二次攻击时间
local SpitFireRate2 = 4
--三次攻击时间
local SpitFireRate3 = 7
--动画间隔
local rate = 3

local effList = {}
local timerList = {}
local effectParent = GameObject.Find("effectContainer").transform

local function PlayAnimation(targetSp, value)
	local playAni = targetSp:GetComponent("Animator")
	if playAni == nil then
		return
	end
	if (targetSp.gameObject.activeSelf)then
		playAni:SetTrigger(value)
	end
	playAni.speed = 1
end

function GiantLogic:ctor(_, fireUi)
	self._modeFunc = {}
	self._modeFunc["Enter"] = self.ModeEnter
	self._modeFunc["Atk1"] = self.ModeAtk1
	self._modeFunc["Atk2"] = self.ModeAtk2
	self._modeFunc["Atk3"] = self.ModeAtk3
	self._modeFunc["Hide"] = self.ModeHide
	self._modeFunc["Leave"] = self.ModeLeave
	
	self._rootUi = fireUi
	-- 记录喷火的起点终点坐标
	self._srcPos = Vector3(SpitFirePrefabDX, SpitFirePrefabDY0, SpitFirePrefabDZ)
	self._goSpd = Vector3(SpitFirePrefabDX, SpitFirePrefabDY0 - SpitFirePrefabDY, 0) / SpitFireStartTime
	
	self._nodeGhost = ZTD.PoolManager.GetGameItem (SpitFirePrefab, ZTD.MainScene.SceneObj:FindChild("node_3d"))
	self._nodeModel = self._nodeGhost:FindChild("Shigui/spine/SL_04_01")
	self._nodeGhost:SetActive(false)
end

function GiantLogic:FixedUpdate(dt)
	self._actTime = self._actTime + dt
	if self._modeFunc[self._actMode] then
		self._modeFunc[self._actMode](self, dt)
	end
end

function GiantLogic:SetComboNode(comboNode)
	--logError("GiantLogic setsetSetsetsetSetsetset comboNode:" .. tostring(comboNode) .. "!!!!!:" .. debug.traceback())
	-- 为nil则清空
	if comboNode == nil then
		self._comboNode = nil
		-- 在免费结算时，同步金币时使用
		ZTD.GiantLogic.ComboNode = nil
		return
	end
	-- 只赋值一次
	if self._comboNode == nil then
		self._comboNode = comboNode
		ZTD.GiantLogic.ComboNode = comboNode
	end	
end

function GiantLogic:ActiveRoad(isSelf, data)
	--logError("data="..GC.uu.Dump(data))
	self:Release(true)
	-- 正在离开，还没被删除
	self._isLeaving = false
	-- 已经离开完毕，被删除
	self._isActive = true
	-- 初始化喷火的起点状态
	self._nodeGhost.localPosition = self._srcPos
	self._nodeGhost:SetActive(true)
	PlayAnimation(self._nodeModel, "walk")
	-- 各种状态下的活动时间
	self._actTime = 0
	self._ratio = self._ratio or 1
	self._isSelf = isSelf
	self.attackTimes = data.attackTimes
	--logError("attackTimes="..tostring(self.attackTimes))
	self.times = 1
	self.posID = data.posID
	self._actMode = "Enter"
	ZTD.Flow.AddUpdateList(self)
end

-- 状态机动作 入场 - 攻击 - 退场
function GiantLogic:ModeEnter(dt)
	if self._actTime > SpitFireStartTime then
		if self._isSelf then
			self._rootUi:StartUiFrame()
		end	
		self._nodeGhost.localPosition = Vector3(SpitFirePrefabDX, SpitFirePrefabDY, SpitFirePrefabDZ)
		self._actMode = "Atk1"
		self._actTime = 0
		ZTD.PlayMusicEffect("giantEnter")
	else
		self._nodeGhost.localPosition = self._nodeGhost.localPosition - self._goSpd * dt
	end
end

function GiantLogic:ModeAtk1(dt)
	if self.attackTimes > 0 and self._actTime > 1 then
		self:StartAttack()
		self._actMode = "Atk2"
		self._actTime = 0
	end
end

function GiantLogic:ModeAtk2(dt)
	if self.attackTimes > 0 and self._actTime > 3.3 then
		self:StartAttack()
		self._actMode = "Atk3"
		self._actTime = 0
	end
end

function GiantLogic:ModeAtk3(dt)
	if self.attackTimes > 0 and self._actTime > 3.3 then
		--如果攻击波次是2，则只进行两次动画
		if self.attackTimes < self.times then
			self._actMode = "Hide"
			self._actTime = 0
			return
		end
		self:StartAttack()
		self._actMode = "Atk3"
		self._actTime = 0
	end
end

function GiantLogic:ModeHide()
	if self._actTime > 2 and self._nodeGhost then
		self._nodeGhost:SetActive(false)
		self._actMode = ""
		self._actTime = 0
	end
end

function GiantLogic:StartAttack()
	PlayAnimation(self._nodeModel, "attack3")
	local eff, effID = ZTD.EffectManager.PlayEffect("Effect_UI_SSjurenbao", effectParent, true)
	table.insert(effList, {eff = eff, effID = effID})
	local time = ZTD.GameTimer.DelayRun(2, function()
		ZTD.PlayMusicEffect("suiping")
		ZTD.PlayMusicEffect("giantAttack")
	end)
	local time1 = ZTD.GameTimer.DelayRun(2.4, function()
		if eff then 
			eff:SetActive(false)
		end
	end)
	table.insert(timerList, time)
	table.insert(timerList, time1)
	ZTD.Utils.ShakeCameraPosition(Vector3(0.4, 0.4, 0), 0.2, 2, 30)
	local tag = self.times == self.attackTimes and true or false
	local idx = self.times
	local skillId = 10018 + self.times
	-- logError("  tag="..tostring(tag).."  skillId="..tostring(skillId))
	local skillMgr = ZTD.Flow.GetSkillMgr()
	skillMgr:AddSkill(
		skillId, 
		{isSelf = self._isSelf, 
		ratio = self._ratio, 
		GiantMode = idx,
		UsePositionId = self.posID,
		DragonEnd = tag,
		pos = Vector3.zero,
		callBack = function ()
		end})
	self.times = self.times + 1
end

function GiantLogic:ModeLeave(dt)
	if self._actTime > 1 then
		self:Release()
		self._actTime = 0
		self._actMode = ""
	end
end

function GiantLogic:PushLeave()
	if not self._isLeaving then
		self._isLeaving = true
		self._actMode = "Leave"
		self._actTime = 0
		if self._isSelf then
			self._rootUi:StopUiFrame()
		end	
	end
end

function GiantLogic:GetRatio()
	return self._ratio or 1
end	

function GiantLogic:SetRatio(ratio)
	self._ratio = ratio
end	

function GiantLogic:Release(isHoldCombo)
	-- logError("self._isActive="..tostring(self._isActive))
	if self._isActive then
		if effList then
			-- logError("effList="..GC.uu.Dump(effList))
			for k, v in ipairs(effList) do
				if v then 
					ZTD.EffectManager.RemoveEffectByID(v.effID)
				end
			end
			effList = {}
		end
		if timerList then
			-- logError("timerList="..GC.uu.Dump(timerList))
			for k, v in ipairs(timerList) do
				if v then
					ZTD.GameTimer.StopTimer(v)
				end
			end
			timerList = {}
		end
		if self._nodeGhost then
			self._nodeGhost:SetActive(false)
		end	
		if not isHoldCombo then
			self:SetComboNode()
		end	
		self._isActive = false
		ZTD.Flow.RemoveUpdateList(self)
	end
end

return GiantLogic