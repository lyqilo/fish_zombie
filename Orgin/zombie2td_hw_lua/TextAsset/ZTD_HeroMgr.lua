local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TdHeroMgr = GC.class2("TdHeroMgr", ZTD.ObjectMgr);
local SUPER = ZTD.ObjectMgr;

function TdHeroMgr:Init()
	self.heroList = {}
end

function TdHeroMgr:CreateHero(block, setup, heroId, playerId, heroPos, uuid)
	if not self._touchChecker then
		self._touchChecker = ZTD.TouchChecker:new(ZTD.Define.LayerPlayer);
		ZTD.Flow.GetTouchMgr():AddTouch(self._touchChecker, 8);
	end	
	
	local MapInfo = ZTD.MainScene.GetMapInfo();
	local pos = MapInfo.setup[block][setup];	
	
	local heroCfg = ZTD.MainScene.GetHeroCfg(heroId);
	
	self._ctrlClass = ZTD.HeroController["Hero" .. heroId];
	
	local ret = self:CreateObject({heroCfg = heroCfg, srcPos = pos, block = block, setup = setup, playerId = playerId, heroPos = heroPos, uuid = uuid});	
	local cfg = ZTD.ConstConfig[1];
	table.insert(self.heroList, ret)
	if playerId == ZTD.PlayerData.GetPlayerId() then
		local heroCtrl = self:GetCtrlById(ret);
		local funcsData = {};
		funcsData.callObj = self;
		funcsData.downFunc = self.OnClkDownHero;
		funcsData.dragFunc = self.OnClkDragHero;
		funcsData.cancelFunc = self.OnClkCancelHero;
		funcsData.upFunc = self.OnClkUpHero;
		funcsData.pressTime = cfg.HeroPressTime;		
		self._touchChecker:Register(heroCtrl._obj, heroCtrl, funcsData);
	end
	
	return ret;
end	

function TdHeroMgr:DestoryCtrl(heroCtrl)
	self._touchChecker:UnRegister(heroCtrl._obj);
	SUPER.DestoryCtrl(self, heroCtrl);
end

function TdHeroMgr:OnClkDownHero(clkData)
	local heroCtrl = clkData.bindData;
	--logError("OnClkDownHeroOnClkDownHeroOnClkDownHero:" .. heroCtrl._id);
end	

function TdHeroMgr:OnClkDragHero(clkData)
	local heroCtrl = clkData.bindData;
	local offX = -0;
	local offY = 0;
	if not self._nowDraggingObj and heroCtrl._obj then
		self._nowDraggingObj = GameObject.Instantiate(heroCtrl._obj);
		self._nowDraggingObj.gameObject.layer = 1;
		self._nowDraggingObj.transform:SetParent(ZTD.MainScene.GetMapObj());
		self._nowDraggingObj:SetActive(true);
		--local myRenderer = self._nowDraggingObj:GetComponentInChildren(typeof(UnityEngine.Renderer));
		--myRenderer.sortingOrder = 100;

		heroCtrl:Hide();
		local cfg = ZTD.ConstConfig[1];
		local s = cfg.HeroPressScale;
		self._nowDraggingObj.localScale = Vector3(s, s, s);
		
		ZTD.BattleView.inst._heroMenu:Close();
		--myRenderer.color = Color(1, 1, 1, 0.5)
		--if not self._isPickCost then
			local changeCost = heroCtrl._heroPos._cost;
			self._isPickCost = true;
			--logError("------changeCostchangeCostchangeCostchangeCostchangeCost")
			ZTD.Notification.GamePost(ZTD.Define.MsgCostChange, changeCost, true);
		--end	
	end
	
	if heroCtrl._obj then
		local screenPos = ZTD.MainScene.CamObj:ScreenToWorldPoint(ZTD.MainScene.screenPosition);
		screenPos = Vector3(screenPos.x + offX, screenPos.y + offY, heroCtrl._obj.position.z);
		self._nowDraggingObj.position = screenPos;
		if self._lastPickHP then
			self._lastPickHP:CloseHeroRange();
			self._lastPickHP = nil;
		end		
		local pickRet = ZTD.MainScene.PickTouch();
		if pickRet then
			self._lastPickHP = pickRet.bindData;
			if self._lastPickHP:IsCost() then
				self._lastPickHP:ShowHeroRange(heroCtrl._atkRange);
			end	
		else
			local pickRet2 = self._touchChecker:PickTouch();
			if pickRet2 then
				self._lastPickHP = pickRet2.bindData._heroPos;
				if self._lastPickHP:IsCost() then
					self._lastPickHP:ShowHeroRange(heroCtrl._atkRange);
				end	
			end	
		end
	else
		-- 如果因为其他原因被销毁了，则不做拖放逻辑了
		tools.destroyObject(self._nowDraggingObj);
		self._nowDraggingObj = nil;
	end
end	

function TdHeroMgr:OnClkCancelHero(clkData)
	--logError("------OnClkCancelHeroOnClkCancelHero")
	
	local function _pickCost()
		--if self._isPickCost then
			--logError("------OnClkCancelHeroOnClkCancelHero")
			local heroCtrl = clkData.bindData;
			local changeCost = heroCtrl._heroPos._cost;
			ZTD.Notification.GamePost(ZTD.Define.MsgCostChange, -changeCost);
			self._isPickCost = false;
		--end	
	end	
	
	-- 拖动时才有该逻辑
	if self._nowDraggingObj then
		local heroCtrl = clkData.bindData;
		--heroCtrl:Show();
		local pickRet = ZTD.MainScene.PickTouch();
		-- 被更换的目标英雄
		local dstHeroCtrl;
		
		local srcGS, dstGS;
		if pickRet then
			local dstGi, dstSi = ZTD.MainScene.HeroPosId2GS(pickRet.bindData._posId);
			srcGS = {gi = heroCtrl._block, si = heroCtrl._setup};
			dstGS = {gi = dstGi, si = dstSi};
		else
			local pickRet2 = self._touchChecker:PickTouch();
			if pickRet2 then
				dstHeroCtrl = pickRet2.bindData;
				srcGS = {gi = heroCtrl._block, si = heroCtrl._setup};
				dstGS = {gi = dstHeroCtrl._block, si = dstHeroCtrl._setup};
			end							
		end
		
		local function _releaseDragging()
			tools.destroyObject(self._nowDraggingObj);
			self._nowDraggingObj = nil;
			if self._lastPickHP then
				self._lastPickHP:CloseHeroRange();
				self._lastPickHP = nil;
			end			
		end	
		
		if srcGS and dstGS then
			local param = {};
			param.NewPositionId = ZTD.MainScene.HeroGS2PosId(dstGS.gi, dstGS.si);
			param.OldPositionId = ZTD.MainScene.HeroGS2PosId(srcGS.gi, srcGS.si);

			local function sussCb()
				_releaseDragging();
				ZTD.Notification.GamePost(ZTD.Define.MsgHeroChange, srcGS, dstGS, ZTD.PlayerData.GetPlayerId());
			end
			local function errCb(err, data)
				_releaseDragging();
				heroCtrl:Show();
				_pickCost()			
				if err == 10067 then
					local dstHeroPos = clkData.bindData._heroPos._battleView._hero_pos[dstGS.gi][dstGS.si]
					-- logError("dstHeroPos="..GC.uu.Dump(dstHeroPos))
					ZTD.ViewManager.ShowBubble(dstHeroPos._node_summon.position)
				end
				log("[ZTD_NET_ERROR]TowerExchangeHeroReq:,NetError:" .. tostring(err));
			end			
			ZTD.Request.CSTowerExchangeHeroReq(param, sussCb, errCb);
		else
			_releaseDragging();
			heroCtrl:Show();
			_pickCost()	
		end
	--else
	--	_pickCost()	
	end
end

function TdHeroMgr:OnClkUpHero(clkData)
	--logError("------OnClkUpHeroOnClkUpHeroOnClkUpHero")
	local heroCtrl = clkData.bindData;
	if self._nowDraggingObj then
		tools.destroyObject(self._nowDraggingObj);
		self._nowDraggingObj = nil;
		heroCtrl:Show();
	end
	
	heroCtrl:DealTouchLogic();
end	

function TdHeroMgr:FixedUpdate(dt)
	SUPER.FixedUpdate(self, dt);
end

function TdHeroMgr:Release()
	if self._nowDraggingObj then
		tools.destroyObject(self._nowDraggingObj);
		self._nowDraggingObj = nil;
	end	
	if self._touchChecker then
		ZTD.Flow.GetTouchMgr():RemoveTouch(self._touchChecker);
		self._touchChecker = nil;		
	end	
	SUPER.Release(self);
end
	
return TdHeroMgr;