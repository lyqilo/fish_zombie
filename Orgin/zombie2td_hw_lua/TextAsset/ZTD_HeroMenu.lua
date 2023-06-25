local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local HeroMenu = GC.class2("TdHeroMenu")

function HeroMenu:ctor(_)

end

function HeroMenu:Init(menuNode, battleView)
	self._menuNode = menuNode;
	
	self._menuNode:SetActive(false);
	
	self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_NodeMenu");

	self._menuNode:FindChild("node/btn_cancel/text").text = self.language.btn_cancel
	self._menuNode:FindChild("node/btn_begin/text (1)").text = self.language.btn_begin
	self._menuNode:FindChild("node/btn_pause/text (2)").text = self.language.btn_pause
	self._menuNode:FindChild("node/btn_change/text (1)").text = self.language.btn_change

	self._btnCancel = self._menuNode:FindChild("node/btn_cancel");
	self._btnPause = self._menuNode:FindChild("node/btn_pause");
	self._btnBegin = self._menuNode:FindChild("node/btn_begin");
	self._btnChange = self._menuNode:FindChild("node/btn_change");
		
	local btnPauseCb = function()
		battleView._nowSelHp:PauseCb();
		-- self._btnPause:SetActive(true);
		-- self._btnBegin:SetActive(false);
		-- self:Close();		
		ZTD.TableData.SetLockTarget(battleView._nowSelHp._posId, nil);
		ZTD.TableData.SetReadyLockTarget(battleView._nowSelHp.posId, ZTD.TableData.NullTarget);
		
		--只要有一个停止攻击就关闭全体攻击的UI提示
		battleView:SetAutoBattleUi(false);
		
		-- 如果所有英雄关闭了自动攻击，则检查结束挂机
		local isAllAtkStop = true;
		for nm, _ in pairs(battleView._nowHeroHps) do
			if nm:IsAutoAtk() then
				isAllAtkStop = false;
				break;
			end
		end
		if isAllAtkStop then
			battleView:_doEndTrusteeshipReq();
		end
	end
	
	battleView:AddClick(self._btnPause, function()
		battleView:_reqAtk(battleView._nowSelHp._posId, false, btnPauseCb);
		-- self:Close();		
	end);
	
	
	local btnBeginCb = function(stdt)
		battleView._nowSelHp:BeginCb(stdt);
		-- self._btnPause:SetActive(false);
		-- self._btnBegin:SetActive(true);		
		-- self:Close();		
		local isAllAtk = true;
		for nm, _ in pairs(battleView._nowHeroHps) do
			if not nm:IsAutoAtk() then
				isAllAtk = false;
				break;
			end
		end
		if isAllAtk then
			battleView:SetAutoBattleUi(true);
		end

		ZTD.Request.CSButtonRecordsReq({ID = 4003, Mode = 4});
	end
	
	battleView:AddClick(self._btnBegin, function()
		battleView:_reqAtk(battleView._nowSelHp._posId, true, btnBeginCb);
	end);
	
	local btnCancelCb = function()
		local selHp = battleView._nowSelHp;
		battleView:_downHero(selHp);
		battleView:OnCostChange(selHp._cost);
		-- 如果场上没有了英雄，又开启了挂机，则关闭挂机
		if next(battleView._nowHeroHps) == nil then
			battleView:_doEndTrusteeshipReq();
			battleView:SetAutoBattleUi(false);
		end
	end

	battleView:AddClick(self._btnCancel, function()
		battleView:_reqHero(battleView._nowSelHp._posId, battleView._nowSelHp._nowHeroId, true, btnCancelCb);
		ZTD.Request.CSButtonRecordsReq({ID = 4004, Mode = 4});
	end);
	
	battleView:AddClick(self._btnChange, function()
		local selHp = battleView._nowSelHp;
		battleView:OnOpenSummon(selHp, true);
	end);	
	self._battleView = battleView;
end

function HeroMenu:Close()
	local battleView = self._battleView;
	self._menuNode:SetActive(false);
	--if self._openHeroMark then
		ZTD.Notification.GameUnregister(self, ZTD.Define.MsgClkMap);
		--self._openHeroMark = nil;
	--end
	if battleView._nowSelHp then
		battleView._nowSelHp:CloseHeroRange();
	end	
end

function HeroMenu:SetAtkUi(isAtk)
	if isAtk then
		self._btnPause:SetActive(true);
		self._btnBegin:SetActive(false);
	else
		self._btnPause:SetActive(false);
		self._btnBegin:SetActive(true);
	end	
end	

function HeroMenu:closeMenu()
	--if self._openHeroMark == 1 then
		self:Close();
		--self._openHeroMark = nil;
	--elseif self._openHeroMark == 0 then
	--	self._openHeroMark = self._openHeroMark + 1;
	--end
end

function HeroMenu:Open(heroPos)
	local battleView = self._battleView;
	self:Close();
	
	self._menuNode:SetActive(true);
	heroPos:ShowHeroRange();
	-- Init hero menu
	self._menuNode:FindChild("node").position = ZTD.MainScene.SetupPos2UiPos(heroPos._node_summon.position);
		
	self:SetAtkUi(heroPos:IsAutoAtk())
	
	--self._openHeroMark = 0;
	
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgClkMap, self.closeMenu);	
end

function HeroMenu:IsActive()
	return self._menuNode.activeSelf;
end

function HeroMenu:Release()
	ZTD.Notification.GameUnregisterAll(self);
end

return HeroMenu;