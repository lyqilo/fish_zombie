local GC = require("GC")
local CC = require("CC")
local ZTD = require("ZTD")
local tools = GC.uu

local HeroPos = GC.class2("TdHeroPos")

function HeroPos:ctor(_)

end
	
function HeroPos:Init(groupInx, setupInx, setupPos, battleView)
	if self._node_summon == nil then
		self._isEff = true;
		self._groupInx = groupInx;
		self._setupInx = setupInx;
		self._posId = ZTD.MainScene.HeroGS2PosId(groupInx, setupInx);
		
		local mapObj = ZTD.MainScene.GetMapObj();
		local node_summon = ZTD.PoolManager.GetGameItem("TD_SUMMON_TIPS", mapObj);
		local wPos = Vector3(setupPos.x, setupPos.y, 0);	
		node_summon.localPosition = wPos;
		local isvip = ZTD.PlayerData.GetIsVip()
		self._cost = ZTD.MainScene.GetMapScore(1, self._posId, isvip);
		local textObj = node_summon:FindChild("txt_cost");
		textObj.text = self._cost;
		local function callBack()
			ZTD.Notification.GamePost(ZTD.Define.MsgOpenSummon, self);
		end
		ZTD.MainScene.AddTouchObj(node_summon, self, callBack);
		self._callBack = callBack;
		self._node_summon = node_summon;
		self._textObj = textObj;
		self._battleView = battleView;
		
		self:_runFadeAct();
	end
end

--获取当前地图分值
function HeroPos:GetCost()
	return tonumber(self._textObj.text)
end

--根据是否会员刷新地图分值
function HeroPos:ChangeCost(cost)
	self._cost = cost
	self._textObj.text = cost
end

function HeroPos:_runFadeAct()
	if self._loopAct == nil then
		self._loopAct = ZTD.Extend.RunAction(self._textObj, {
							{"fadeToAll", 100, 4},
							{"delay", 2},
							{"fadeToAll", 255, 0.7},
							{"delay", 1.5},		
							loop = 1073741823,
							})
	end							
end	

function HeroPos:IsCost()
	local cost = self._battleView:GetNowCost();
	if cost >= self._cost then
		return true;
	else
		return false;
	end
end	

function HeroPos:SetStatus(cost)
	-- set color
	if cost then
		if self._loopAct then
			ZTD.Extend.StopAction(self._loopAct);
			self._loopAct = nil;
			ZTD.Extend.RunAction(self._textObj, {{"fadeToAll", 255, 0},});
		end	
		if cost >= self._cost then	
			--212 42 46 200
			self._textObj.color = Color(159/255, 255/255, 168/255, 255/255);
			self._textObj:GetComponent("Outline").effectColor = Color(0/255, 107/255, 13/255, 255/255);
		else	
			--245 212 137 255
			self._textObj.color = Color(255/255, 97/255, 97/255, 255/255);	
			self._textObj:GetComponent("Outline").effectColor = Color(107/255, 0/255, 0/255, 255/255);
		end
	else
		self:_runFadeAct();
		self._textObj.color = Color(175/255, 183/255, 220/255, 225/255);
		self._textObj:GetComponent("Outline").effectColor = Color(105/255, 109/255, 146/255, 255/255);	
	end
end

function HeroPos:DoClick()
	self._callBack(1);
end	

function HeroPos:SetEff(var)
	self._isEff = var;
end
function HeroPos:ShowUpEff()
	local groupInx = self._groupInx;
	local setupInx = self._setupInx;	
	local eff_down, eff_downID = ZTD.EffectManager.PlayEffect("TD_ef_jiaodiyan", ZTD.MainScene.GetMapObj());
	local MapInfo = ZTD.MainScene.GetMapInfo();
	local pos = MapInfo.setup[groupInx][setupInx];				
	eff_down.localPosition = pos;
	eff_down:SetActive(false);
	eff_down:SetActive(true);
	ZTD.GameTimer.DelayRun(1.0, function()
		ZTD.EffectManager.RemoveEffectByID(eff_downID)
		eff_down = nil;
	end)	
end	
	
function HeroPos:SummonCb(heroId, playerId, uuid)	
	if self._heroInx then
		logError("HeroPos:SummonCb duplicate!!!!:" .. debug.traceback());
		return;
	end
		
	self._node_summon:SetActive(false);
	self._nowHeroId = heroId;
	self._playerId = playerId;	
	local groupInx = self._groupInx;
	local setupInx = self._setupInx;	
	local heroInx = ZTD.Flow.GetHeroMgr():CreateHero(groupInx, setupInx, heroId, playerId, self, uuid);
	
	if self._isEff then
		self:ShowUpEff();
	end
	
	self._heroInx = heroInx;
end

function HeroPos:CancelCb(isIgnoreReset)
	if self._heroInx then
		-- 下阵前先停止攻击
		self:PauseCb();
		ZTD.TableData.UpdateHeroInfo(self._playerId, self._posId, nil);
		local heroCtrl = self:GetHeroCtrl();
		if heroCtrl then
			if not isIgnoreReset then
				ZTD.TableData.ResetHeroUuidMoeny(heroCtrl._uuid);
				ZTD.TableData.ResetMaSkillTimes(heroCtrl._uuid);
			end	
			local heroMgr = ZTD.Flow.GetHeroMgr();
			heroMgr:DestoryCtrl(heroCtrl);
		end
		self._node_summon:SetActive(true);

		self._heroInx = nil;
		self._nowHeroId = nil;
		self._playerId = nil;				
	end	
end

function HeroPos:BeginCb(stdt)		
	local heroCtrl = self:GetHeroCtrl();
	if heroCtrl then
		if not heroCtrl:isAutoPlayAtk() then
			heroCtrl:beginAtk(stdt);
		end
		ZTD.TableData.UpdateHeroInfo(self._playerId, self._posId, {IsAtk = true});
	end	
end

function HeroPos:PauseCb()
	local heroInx = self._heroInx;
	local heroCtrl = self:GetHeroCtrl();
	if heroCtrl and heroCtrl:isAutoPlayAtk() then
		heroCtrl:pauseAtk();
	end
	ZTD.TableData.UpdateHeroInfo(self._playerId, self._posId, {IsAtk = false});
end

function HeroPos:IsAutoAtk()
	local heroCtrl = self:GetHeroCtrl();
	if heroCtrl then
		return heroCtrl:isAutoPlayAtk();
	end	
end	

function HeroPos:GetHeroCtrl()	
	local heroInx = self._heroInx;
	local heroMgr = ZTD.Flow.GetHeroMgr();
	return heroMgr:GetCtrlById(heroInx);
end

function HeroPos:CleanLock()
	if self._heroInx then
		local heroCtrl = self:GetHeroCtrl();
		heroCtrl._targetEnemy = nil;
	end
end

function HeroPos:ShowHeroRange(forceRange)
	if not self._sp_hero_range then
		local mapObj = ZTD.MainScene.GetMapObj();
		local sp_hero_range, sp_hero_rangeID = ZTD.EffectManager.PlayEffect("TD_HERO_RANGE", mapObj);
		sp_hero_range.localPosition = self._node_summon.localPosition;
		
		local ar = forceRange;
		if ar == nil then
			local heroCtrl = self:GetHeroCtrl();
			ar = heroCtrl._atkRange;
		end
		sp_hero_range.localScale = Vector3.one * ar / 1.28; -- 光圈图是256x256
		self._sp_hero_range = sp_hero_range;
		self._sp_hero_rangeID = sp_hero_rangeID
	end
	
	self._sp_hero_range:SetActive(true);
end

function HeroPos:CloseHeroRange()
	if self._sp_hero_range and self._sp_hero_rangeID then
		self._sp_hero_range:SetActive(false);
		ZTD.EffectManager.RemoveEffectByID(self._sp_hero_rangeID)
		self._sp_hero_range = nil;
		self._sp_hero_rangeID = nil
	end	
end

return HeroPos