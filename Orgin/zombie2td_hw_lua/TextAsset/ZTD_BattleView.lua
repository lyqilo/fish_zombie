local CC = require("CC")
local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local BattleView = ZTD.ClassView("ZTD_BattleView")

local DefaultHeroId = 1001;
-----
function BattleView:ctor(_)
	self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_BattleView");
	-- 当前场上本地客户端的英雄位置
	self._nowHeroHps = {};
	-- 该房间的所有玩家UI
	self._playerItems = {};
	-- 当前被选择的本地英雄位置
	self._nowSelHp = nil;
	-- 英雄控制页
	self._heroMenu = nil;
	-- 英雄召唤页
	self._nodeSummon = nil;
	-- 英雄召唤页所选择的id,默认1001
	self._nodeSummonheroId = DefaultHeroId;
	
	-- 换房间的回调队列
	self._RoomChangeCb = {};

	self.isOneKeyActive = true
	--nft卡
	self.cardList = {}
end

function BattleView:setFps(fps)
	self:FindChild("debug/txt_fps").text = math.floor(fps);
end

function BattleView:ResetGoldEff(gold)
	self.preGold = gold;
    local goldText = self:FindChild("top/txt_gold")
    goldText.localScale = Vector3.one
    if self.goldAc then
        ZTD.Extend.StopAction(self.goldAc)
        self.goldAc = nil
    end	
end

-- fly gold 回调使用
function BattleView:_goldAppeal(goldVar)
	self:TargetCoinScaleAction();
	self:OnRefreshGold(goldVar);
	self:OnRefreshGoldEarn();	
end	

function BattleView:UpdateGold(goldVar)
	self:_goldAppeal(goldVar);
end
	
function BattleView:RefreshGold()
	self:_goldAppeal();
end

function BattleView:GetGoldPos()
	return self.TopGoldNode.position;
end
-- fly gold end

function BattleView:OnRefreshGoldEarn(forceVar)
	-- 显示的金币要减去其他特殊途径获得的金币
	local totalMoneyEarnShow = forceVar or 
									(self._moneyEarnSc - ZTD.GoldData.GetHoldTotalGold());
	self._maxMoneyEarn = totalMoneyEarnShow;
end	

--开启VIP和金币检测倒计时
function BattleView:StartskipGroupTimer()
	if not ZTD.Flow.isOpenGroupTimer then
		ZTD.Flow.isStartGroupTimer = false
	end
	if not ZTD.Flow.isStartGroupTimer then return end
	--log("!!! StartskipGroupTimer")
	-- log("self.skipGroupLimit.time="..tostring(self.skipGroupLimit.time))
	self:StartTimer("SkipGroupCountDown", self.skipGroupLimit.time, function()
		-- log("倒计时中  "..tostring(self.skipGroupLimit.time))
		-- log("isDragonSkipGroup="..tostring(self.isDragonSkipGroup))
		-- log("isGhostSkipGroup="..tostring(self.isGhostSkipGroup))
		-- log("isExitGamePop="..tostring(ZTD.Flow.isExitGamePop))
		if not self.isDragonSkipGroup then return end
		if not self.isGhostSkipGroup then return end
		if ZTD.Flow.isExitGamePop then return end
		local viplevel = ZTD.PlayerData.GetVipLevel()
		local playerId = ZTD.PlayerData.GetPlayerId()
		local money = ZTD.TableData.GetData(playerId, "Money")
		-- log("viplevel="..tostring(viplevel))
		-- log("money="..tostring(money))
		-- log("self.skipGroupLimit.vip = "..tostring(self.skipGroupLimit.vip).."  self.skipGroupLimit.gold ="..tostring(self.skipGroupLimit.gold))
		if viplevel >= self.skipGroupLimit.vip and money >= self.skipGroupLimit.gold then
			ZTD.Flow.isOpenGroupTimer = false
			local confirmFunc = function()
				local groupId = ZTD.Flow.groupId + 1
				local data = Json.decode(ZTD.MJGame.gameData[groupId].UnlockCondition)
				local chouma = ZTD.TableData.GetData(playerId, "Money")
				-- log("chouma="..tostring(chouma).."  count="..tostring(data.Min[1].Count))
				if chouma < data.Min[1].Count then
					local confirmFunc = function()
					end
					ZTD.ViewManager.OpenExtenPopView(self.language.txt_skipGroupLimit, confirmFunc)
					return
				end
				-- log("ZTD.Flow.IsTrusteeship="..tostring(ZTD.Flow.IsTrusteeship))
				local goNewRoom = function()
					self:_dealExit()
					--发送退场消息
					ZTD.Notification.GamePost(ZTD.Define.MsgDoExit, {isSkipArena = true})
				end
				if ZTD.Flow.IsTrusteeship then
					self._trustCb = goNewRoom;
					self:_doEndTrusteeshipReq()
				else	
					goNewRoom()
				end
			end
			local cancelFunc = function()
			end
			ZTD.ViewManager.OpenExtenPopView(self.language.txt_skipGroup, confirmFunc, cancelFunc)
			-- log("关闭倒计时")
			self:StopTimer("SkipGroupCountDown")
		end
	end, -1)
end

function BattleView:OnRefreshGold(gold)
	--log("OnRefreshGold gold = "..tostring(gold))
	--log("preGold="..tostring(self.preGold))
	if gold == nil then
		local totalGold = ZTD.GoldData.Gold;
		gold = totalGold.Show;
	end
	if gold == nil then 
		gold = 0 
	end
    if gold <= 0 then
        gold = 0
	end
    self.preGold = self.preGold or 0
	if self.preGold == gold then
        return
    end
    local goldText = self:FindChild("top/txt_gold")
    goldText.localScale = Vector3.one
    if self.goldAc then
        ZTD.Extend.StopAction(self.goldAc)
        self.goldAc = nil
    end
    if gold - self.preGold > 0 then
        self.goldAc = ZTD.Extend.RunAction(goldText,{{"scaleTo",1.2,1.2,1,0.05},{"scaleTo",1,1,1,0.05}})
    end
    
    self.preGold = gold
	if self.nftView then
		self.nftView:RefreshGold(gold)
	end
	local _gold = tools.numberToStrWithComma(gold)
	-- logError("_gold="..tostring(_gold))
    goldText.text = _gold
	
	local totalMoneyEarnShow = gold - (self._roomGold or 0);	
	--logError("totalMoneyEarnShow="..tostring(totalMoneyEarnShow).."  gold="..tostring(gold).."  self._roomGold="..tostring(self._roomGold))
	
	if self._ui_myWin == nil then
		logError("---------invail OnRefreshGold!!!:" .. debug.traceback());		
		return;
	end
	
	self._ui_myWin:SetActive(totalMoneyEarnShow > 0);
	self._ui_myLose:SetActive(totalMoneyEarnShow < 0);	
	if totalMoneyEarnShow > 0 or totalMoneyEarnShow < 0 then
		if self.canSkipTimer and ZTD.Flow.groupId < 4 then
			self:StartskipGroupTimer()
			self.canSkipTimer = false
		end
	end
	self._ui_myWin.text = "+" .. tools.numberToStrWithComma(totalMoneyEarnShow);
	self._ui_myLose.text = "-" .. tools.numberToStrWithComma(math.abs(totalMoneyEarnShow));
	local playerId = ZTD.PlayerData.GetPlayerId()
	self:_updatePlayerItemMoney(playerId, totalMoneyEarnShow, gold);
	self.isOpen = GC.UserData.Load(ZTD.gamePath.."CheckBrokeOrRelief/"..playerId,  {isOpenBroke = false}).isOpenBroke
	--检查破产和救济金
	if not self.isOpen then
		local param = {}
		param.curMoney = gold
		param.brokeMoney = 3000
		param.againBroke = true
		--isOpen用于检测救济金和破产，check用于检测是否打开商城
		param.closeFunc = function()
			self.check = false
		end
		self.isOpen = GC.SubGameInterface.CheckBrokeOrRelief(param)
		self.check = self.isOpen
		GC.UserData.Save(ZTD.gamePath.."CheckBrokeOrRelief/"..playerId, {isOpenBroke = self.isOpen})
	end
	
	--logError("OnRefreshGold traceback:" .. debug.traceback());
end	

-- 同步其他玩家的英雄
function BattleView:_syncOtherHero()
	local syncAtkFuncs = {};
	-- 避免同步问题，先同步英雄，再在回调里同步射击时间
	local function warpFunc(info)
		-- 同步其他玩家的英雄信息，自己的不处理
		if info.PlayerId == ZTD.PlayerData.GetPlayerId() then
			return;
		end
		for pos, v in pairs(info.heroInfo) do
			local groupInx, setupInx = ZTD.MainScene.HeroPosId2GS(v.PositionId);
			local heroPos = self._hero_pos[groupInx][setupInx];
			
			if heroPos._nowHeroId == v.HeroId and heroPos._playerId == info.PlayerId then
				return;
			elseif heroPos._nowHeroId ~= nil then
				self:SetHeroOnScene(groupInx, setupInx, 0);
			end

			self:SetHeroOnScene(groupInx, setupInx, v.HeroId, info.PlayerId, true, v.Uuid)
			
			if v.IsAtk then
				local funcAtkBegin = function(Data, oldHeroInx)
					if heroPos._heroInx and heroPos._heroInx == oldHeroInx then
						local stdt1 = v.Timestamp;
						local stdt2 = Data.Timestamp;
						local stdt = stdt2 - stdt1;
						--logError(string.format("-------------Timestamp stdt:%s %s %s", stdt2, stdt1, stdt));
						heroPos:BeginCb(stdt/1000);
						ZTD.TableData.SetLockTarget(v.PositionId, v.TargetPositionId)
					end
				end
				syncAtkFuncs[#syncAtkFuncs + 1] = {func = funcAtkBegin, oldInx = heroPos._heroInx};
			end
			
			heroPos:PauseCb();
		end
	end
	ZTD.TableData.WarpInfo(warpFunc);
	
	local function succCb(err, Data)
		for _, funcData in pairs(syncAtkFuncs) do
			funcData.func(Data, funcData.oldInx);
		end
	end
	ZTD.Request.CSGetCurrentTimeReq({}, succCb)
end

function BattleView:OnSummonHeroIcon(heroCfg, isSummon)
	local btnSummon = self._btnSummons[heroCfg.id];
	if btnSummon == nil then
		return;
	end
	
	local cfg = ZTD.ConstConfig[1];
	self._nodeSummonheroId = heroCfg.id;
	self._nodeSummon:FindChild("icon_select").position = btnSummon.position;
	self._nodeSummon:FindChild("sp_skill"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, heroCfg.icon_skill);

	local function _setRange(pNode, pValue)
		for i = 1, 3 do 
			pNode:FindChild("degree" .. i):SetActive(false);
		end
		
		if pValue < 1 or pValue > 3 then
			logError("[ZTD_GAME_ERROR]:hero range over stack!!!");
			pValue = 1;
		end

		for i = 1, 3 do 
			pNode:FindChild("degree" .. i):SetActive(false);
			pNode:FindChild("sp_degree" .. i):SetActive(false);
		end
		
		for i = 1, pValue do 
			pNode:FindChild("degree" .. i):SetActive(true);
		end
		pNode:FindChild("sp_degree" .. pValue):SetActive(true);
	end
	
	local node_range = self._nodeSummon:FindChild("node_range");
	local node_atkspd = self._nodeSummon:FindChild("node_atkspd");
	_setRange(node_range, heroCfg.desc_atk_ranged);
	_setRange(node_atkspd, heroCfg.desc_atk_spd);

	local summonLanguage = ZTD.LanguageManager.GetLanguage("L_ZTD_NodeSummon");
	node_range:FindChild("text (1)").text = summonLanguage.node_range_txt
	node_atkspd:FindChild("text").text = summonLanguage.node_atkspd_txt
	
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_HeroConfig");
	self._nodeSummon:FindChild("txt_skill_name").text = language[heroCfg.id].name_skill;
	self._nodeSummon:FindChild("txt_skill_desc").text = language[heroCfg.id].desc_skill;
	self._nodeSummon:FindChild("txt_heroName").text = language[heroCfg.id].name_hero;

	if not isSummon then
		if heroCfg.id == self._nowSelHp._nowHeroId then
			self._nodeSummon:FindChild("btn_summon_change"):SetActive(false);
		else
			self._nodeSummon:FindChild("btn_summon_change"):SetActive(true);
		end
	end
end

function BattleView:InitLimitXY()
    local x_left = self:FindChild("UIScreen/X_Left").position.x
    local x_right = self:FindChild("UIScreen/X_Right").position.x
    local y_up = self:FindChild("UIScreen/Y_Up").position.y
    local y_down = self:FindChild("UIScreen/Y_Down").position.y
    local y_fall = self:FindChild("UIScreen/Y_Fall").position.y
    ZTD.Utils.InitLimitUI_XY(x_left,x_right,y_up,y_down,y_fall)
end

-- 检查地图摆放的分值
function BattleView:CheckCostStatus()
	local nowCost = tonumber(self._ui_cost.text);
	local isOverPut = true;
	for _, v in pairs(self._hero_pos) do
		for __, heroPos in pairs(v) do
			if heroPos._heroInx == nil and heroPos._cost <= nowCost then
				isOverPut = false;
			end
		end
	end
	
	-- set color
	if isOverPut then
		--212 42 46 200
		self._ui_cost.color = Color(255/255, 97/255, 97/255, 255/255);
		self._ui_cost:GetComponent("Outline").effectColor = Color(107/255, 0/255, 0/255, 255/255);
	else	
		--245 212 137 255
		self._ui_cost.color = Color(159/255, 255/255, 168/255, 255/255);
		self._ui_cost:GetComponent("Outline").effectColor = Color(0/255, 107/255, 13/255, 255/255);
	end
end

function BattleView:GetNowCost()
	return tonumber(self._ui_cost.text);
end
	
function BattleView:CheckHeroPosStatus(isDrag)
	local nowCost = tonumber(self._ui_cost.text);
	for _, v in pairs(self._hero_pos) do
		for __, heroPos in pairs(v) do
			if isDrag then
				heroPos:SetStatus(nowCost);
			else
				heroPos:SetStatus();
			end	
		end
	end
end	

function BattleView:_showUiCostTips(score)

	if self._ui_cost_tips_run_key then
		ZTD.Extend.StopAction(self._ui_cost_tips_run_key);
	end
	
	local r, g, b, a;
	local outLine = self._ui_cost_tips:GetComponent("Outline");
	if score > 0 then
		score = "+" .. score;
		r = 159/255;
		g = 255/255;
		b = 168/255;
		a = 255/255;
		self._ui_cost_tips.color = Color(r, g, b, a);
		
		outLine.effectColor = Color(0/255, 107/255, 13/255, 255/255);
	else
		r = 255/255;
		g = 97/255;
		b = 97/255;
		a = 255/255;
		self._ui_cost_tips.color = Color(r, g, b, a);
		outLine.effectColor = Color(0/255, 0/255, 0/255, 255/255);
	end
	self._ui_cost_tips.text = score;
	local tp = self._ui_cost.localPosition;
	self._ui_cost_tips.localPosition = Vector3(tp.x, tp.y + 30, tp.z);
	
	ZTD.Extend.RunAction(outLine, {"fadeToAll", 0, 1});
	self._ui_cost_tips_run_key = ZTD.Extend.RunAction(self._ui_cost_tips, 
														{
															{"fadeToAll", 255, 0}, 
															{"localMoveBy", 0, 25, 0, 0.5},
															{"delay", 0.5, onEnd = function() outLine.effectColor = Color(r, g, b, a); end}, 
															{"fadeToAll", 0, 1}
														}
													);

	self._ui_cost_up:SetActive(false);
	self._ui_cost_up:SetActive(true);	
	GC.Sound.PlayEffect("ZTD_cost_go");
end	

function BattleView:OnCostChange(score, isDrag)
	self._ui_cost.text = tonumber(self._ui_cost.text) + score;
	self:CheckCostStatus();
	self:_showUiCostTips(score);
	self:CheckHeroPosStatus(isDrag);
end	

function BattleView:_downHero(heroPos, isIgnoreReset)
	local ctrl = heroPos:GetHeroCtrl();
	heroPos:CancelCb(isIgnoreReset);
	self._heroMenu:Close();
	self._nowHeroHps[heroPos] = nil;	
end

function BattleView:_upHero(heroPos, isAtk, playerId, summonHeroId, uuid)
	local playerId = playerId or ZTD.PlayerData.GetPlayerId();
	self:SetHeroOnScene(heroPos._groupInx, heroPos._setupInx, summonHeroId or self._nodeSummonheroId, playerId, nil, uuid);	
	if isAtk then
		heroPos:GetHeroCtrl():beginAtk();
	end
	local sealState = self.SealUi:GetSealState(playerId)
	-- logError("sealState"..tostring(sealState))
	self.SealUi:RefreshEffAll(sealState, playerId)
end

function BattleView:TargetCoinScaleAction()
    self:ResetAnim()
    self:CreateTishiEff(self.TopGoldNode)
	self.__TargetCoinScaleAction_Anim = ZTD.Extend.RunAction(self.TopGoldNode,{{"scaleTo",1.3,1.3,1,0.1},{"scaleTo",1,1,1,0.1}})
end

function BattleView:CreateTishiEff(parent)
    local tishiEff, tishiEffID = ZTD.EffectManager.PlayEffect("TD_Effect_UI_JB_TiShi", parent);
	tishiEff:SetActive(false);
	tishiEff:SetActive(true);
    tishiEff.localScale = Vector3.one
    tishiEff.localPosition = Vector3.zero

    ZTD.GameTimer.DelayRun(0.5,function()
		tishiEff:SetActive(false);
        ZTD.EffectManager.RemoveEffectByID(tishiEffID)
		tishiEff = nil;
    end)
end

function BattleView:ResetAnim()
    if self.__TargetCoinScaleAction_Anim then
        ZTD.Extend.StopAction(self.__TargetCoinScaleAction_Anim)
    end

    self.TopGoldNode.localScale = Vector3.one
end

--设置选场ID
function BattleView:SetCurGroupId()
	-- log("ZTD.Flow.groupId="..ZTD.Flow.groupId)
	GC.SubGameInterface.SetCurGroupId(ZTD.Flow.groupId)
end

--请求获取礼包数据
function BattleView:RequestGift()
	local dailyGiftList = {
		{id = "30113", enabled = true}, 
		{id = "30114", enabled = true}, 
		{id = "30115", enabled = true}, 
		{id = "30116", enabled = true}, 
		{id = "30117", enabled = true}}
	for k, v in ipairs(dailyGiftList) do
		-- logError("v="..tostring(v.id))
		-- isDaily = GC.SubGameInterface.ByWareIdGetState(tostring(i))
		local param = {}
		param.wareId = {v.id}
		param.succCb = function(err, data)
			if data.Items then
				for _, item in ipairs(data.Items) do
					if tonumber(item.WareId) == tonumber(v.id) then
						v.enabled = item.Enabled
					end
				end
			end
			-- logError("dailyGiftList="..tostring(#dailyGiftList))
			if k == #dailyGiftList then
				  self:OpenGift(dailyGiftList)
			end
		end
		param.errCb = function(err, data)
			logError("errCb"..err)
		end
		-- logError("param="..GC.uu.Dump(param))
		GC.SubGameInterface.ByWareIdOrderState(param)
	end
end

--礼包弹出(每日礼包/周卡礼包), 入场特效播放
function BattleView:OpenGift(dailyGiftList)
	-- logError("dailyGiftList="..GC.uu.Dump(dailyGiftList))
	local isDaily = true
	if dailyGiftList then
		for k, v in pairs(dailyGiftList) do
			if not v.enabled then
				isDaily = v.enabled
				break
			end
		end
	end
	local effect = ZTD.PlayerData.GetEntryEffect()
	-- logError("isDaily="..tostring(isDaily).."  isOpenDaily="..tostring(ZTD.Flow.isOpenDaily))
	if isDaily and ZTD.Flow.isOpenDaily then
		ZTD.Flow.isOpenDaily = false
		local function closeFunc()
			--logError("ZTD.BattleView.inst="..tostring(ZTD.BattleView.inst))
			--if ZTD.BattleView.inst then
				self:PlayEntryEffect(effect)
			--end
		end
		GC.SubGameInterface.OpenDailyGiftView({currentView = "DailyGiftZombie", closeFunc = closeFunc})
	else
		self:PlayEntryEffect(effect)
	end
	if ZTD.Flow.isOpenGameGift then
		ZTD.ViewManager.OpenMessageBox("ZTD_GiftCollectionView")
		ZTD.Flow.isOpenGameGift = false
	end
end

--播放圣诞入场特效
function BattleView:PlayEntryEffect(effect)
	local effect = effect
	-- log("effect="..tostring(effect))
	if tostring(self:FindChild("entryEffectNode")) == "null" or self:FindChild("entryEffectNode") == nil then
		return
	end
	local parent = self:FindChild("entryEffectNode")
	if not parent then
		return
	end
	if type(GC.SubGameInterface.CreateEntryEffect) ~= "function" then return end
	self.entryEffect = GC.SubGameInterface.CreateEntryEffect(effect, parent)
end

--刷新红点
function BattleView:RefreshRedPoint()
	local chipData = ZTD.PlayerData.GetChipData()
	-- log("chipData="..GC.uu.Dump(chipData))
	local state = false
	for k, v in ipairs(chipData) do
		local id = v.PropsID % 10 - 1
		-- log("TotalNum="..tostring(v.TotalNum).."  ChipNum="..tostring(self.boxInfoCfg[id].ChipNum))
		if v.TotalNum >= self.boxInfoCfg[id].ChipNum then
			state = true
			break
		end
	end
	-- log("state="..tostring(state))
	self:FindChild("leftGridNode/gameGiftNode/redPoint"):SetActive(state)
end

function BattleView:OnPushConnectMonster(data)
	--击杀怪位置为起始闪电位置
	local originPos = nil
	--击杀怪大小
	local originScale = nil
	--击杀怪
	local originEnemy = nil
	--存储该批次的所有怪物位置和大小除击杀怪外
	local lightningPosList = {}
	--存储该批次的所有怪物和位置除击杀怪外
	local enemyList = {}
	local enemyMgr = ZTD.Flow.GetEnemyMgr()
	for k, v in ipairs(data.Connect) do 
		local tgEnemey = enemyMgr._ctrlList[v.PositionID]
		if not tgEnemey then
			tgEnemey = enemyMgr._readyDelCtrlList[v.PositionID]
		end
		if tgEnemey then
			local eobj = tgEnemey:getEnemyObj()
			local position = eobj.transform.position
			local scale = Vector3.one
			if v.MonsterID == 10005 then
				position = eobj.transform.position + Vector3(0, 1.5, 0)
			elseif v.MonsterID == 10004 then
				scale = Vector3(2, 2, 2)
			elseif v.MonsterID == 10003 then
				scale = Vector3(1.8, 1.8, 1.8)
			elseif v.MonsterID == 10002 then
				scale = Vector3(1.5, 1.5, 1.5)
			end
			if v.PositionID == data.AttackPositionID then
				originPos = position
				originScale = scale
				originEnemy = tgEnemey
			else
				table.insert(lightningPosList, {position = position, scale = scale, enemy = tgEnemey})
			end
			table.insert(enemyList, {enemy = tgEnemey, position = position})
		else
			logError("！！！ can not find enemy"..tostring(v.PositionID))
		end
	end

	--击杀怪闪电球创建
	if originPos and originScale then
		ZTD.LightningMgr:AddLightningBall(data.ConnectID, {
			position = originPos,
			scale = originScale,
		})
	end

	--如果该批次存在2个或2个以上连接怪，则出现闪电连接
	-- log("lightningPosList="..GC.uu.Dump(lightningPosList))
	if #lightningPosList > 0 then
		ZTD.PlayMusicEffect("shandian2")
		for key, value in ipairs(lightningPosList) do
			ZTD.LightningMgr:AddLightningBall(data.ConnectID, {
				position = value.position,
				scale = value.scale,
			})
			ZTD.LightningMgr:AddLightning(data.ConnectID, 
			{
				curCount = key,
				connectCount = #lightningPosList,
				ConnectID = data.ConnectID,
				startPoint = originPos or ZTD.MainScene.GetMapObj().position,
				endPoint = value.position,
				enemyList = enemyList,
			})
		end
	else
		ZTD.GameTimer.DelayRun(2,function()
			--log("222 ConnectID="..tostring(data.ConnectID))
			ZTD.LightningMgr:RemoveLightning(data.ConnectID)
		end)
		if originEnemy and originPos then
			ZTD.GameTimer.DelayRun(1,function()
				originEnemy:CheckPlayCoin(originPos)
			end)
		end
	end
end

--碎片掉落推送
function BattleView:OnPushDropMaterials(data)
	for k, v in ipairs(data.Info) do
		for i = 1, v.Num, 1 do
			self:OnChipFly(v.PositionId, v.PropsID, i)
		end
	end
end

--碎片ID转换
function BattleView:GetIndex(ID)
    if ID == 1112 then
		return "01"
	elseif ID == 1113 then
		return "02"
	elseif ID == 1114 then
		return "03"
	elseif ID == 1115 then
		return "04"
	end
end

--创建碎片回收特效
function BattleView:CreateChipEff(parent)
    local chipEff, chipEffID = ZTD.EffectManager.PlayEffect("Effects_suipianhuishou", parent)
	chipEff:SetActive(false)
	chipEff:SetActive(true)
    chipEff.localScale = Vector3.one
    chipEff.localPosition = Vector3.zero

    ZTD.GameTimer.DelayRun(0.5,function()
		chipEff:SetActive(false)
        ZTD.EffectManager.RemoveEffectByID(chipEffID)
		chipEff = nil
    end)
end

--碎片掉落
function BattleView:OnChipFly(positionId, ID, Num)
	local enemyMgr = ZTD.Flow.GetEnemyMgr()
	local tgEnemey = enemyMgr._ctrlList[positionId]
	if not tgEnemey then
		logError("！！！ can not find enemy")
		return
	end
	local eobj = tgEnemey:getEnemyObj()
	local orgPos = eobj.transform.position
	orgPos = ZTD.MainScene.SetupPos2UiPos(orgPos)
	local targetPos = self:FindChild("leftGridNode/gameGiftNode").position + Vector3(0, -2, 0)
	local item, itemID = ZTD.EffectManager.PlayEffect("TD_Effect_baoshi", self.coinEffect, true)
	local index = self:GetIndex(ID)
	item:FindChild("baoshi/"..index):SetActive(true)	
	item:FindChild("jinbi"..index):SetActive(true)
	item.position = orgPos
	item:FindChild("jinbi"..index.."/Trail").gameObject:SetActive(false)
	item:FindChild("jinbi"..index.."/Trail").gameObject:GetComponent(typeof(UnityEngine.Renderer)).enabled = false
	item:SetActive(false) 
    local dis_y = 100 --金币开始出现时 y值，最高与最低的距离差
    local highX = 75 --金币开始出现时 x的最大偏幅
    local moveSpeed = {x = 100,y = 150} --金币出现时移动的速度
    local bounceY = 100 * 0.5 --落地时第一次反弹的高度
    local durationTo = 1 --金币去到目标点的总时间
    local moveUpDown = function(item)
        local ctrlPos = (orgPos+targetPos)*0.5 + Vector3(math.random(15,-15),math.random(5,-5),0)
		local isActive = 0
        local localMoveBy = {"localMoveBy",0,bounceY,0,bounceY/moveSpeed.y,loop={2,ZTD.Action.LTYoyo},ease=ZTD.Action.EOutQuad}
		local to = {"to",1,100,durationTo,function(value)
			 --延缓一帧打开拖尾
			 isActive = isActive + 1
			 if isActive == 8 then
				item:FindChild("jinbi"..index.."/Trail"):SetActive(true)
				item:FindChild("jinbi"..index.."/Trail").gameObject:GetComponent("TrailRenderer").enabled = true
			 end
            -- 这里是二阶贝塞尔曲线的实现
            local t = value*0.01
            local u = 1-t
            local tt = t*t
            local uu = u*u
            local p = Vector3(uu*orgPos.x,uu*orgPos.y,uu*orgPos.z)
            p = p + Vector3(2*u*t*ctrlPos.x,2*u*t*ctrlPos.y,2*u*t*ctrlPos.z)
            p = p + Vector3(tt*targetPos.x,tt*targetPos.y,tt*targetPos.z)
            item.transform.position = p
        end,ease=ZTD.Action.EInQuad
        }
		
        local tweenAction = {
	    {"delay", 0},
            to,
			onEnd = function()
				ZTD.PlayMusicEffect("ZTD_Suipianhuishou",0.4, nil, true)
				local parent = self:FindChild("leftGridNode/gameGiftNode/effectNode")
				self:CreateChipEff(parent)
				item:FindChild("jinbi"..index.."/Trail").gameObject:SetActive(false)
				item:FindChild("baoshi/"..index):SetActive(false)	
				item:FindChild("jinbi"..index):SetActive(false)
				item:SetActive(false)
				ZTD.EffectManager.RemoveEffectByID(itemID)
				local TotalNum = ZTD.PlayerData.GetChipNumByID(ID) + Num
				ZTD.PlayerData.SetChipNumByID(ID, TotalNum)
				self:RefreshRedPoint()
			end
        }
		ZTD.Extend.RunAction(item,tweenAction)
       
		local randomX = 0;--math.random(-30,30)
		local randomY = math.random(-100,100)
		ZTD.Extend.RunAction(item,{
			{"localMoveBy",randomX,0,0,bounceY/moveSpeed.y},
			{"localMoveBy",randomX*0.5,0,0,bounceY/moveSpeed.y*0.5},
		})
	end
	item:SetActive(true)
	moveUpDown(item)
	-- ZTD.Extend.RunAction(item,{
	-- 	{"localMoveBy",0,dis_y*0.678,0,dis_y*0.678/moveSpeed.y*0.5,ease=ZTD.Action.EOutQuad},
	-- 	{"localMoveBy",0,-dis_y,0,dis_y/moveSpeed.y*0.5,ease=ZTD.Action.EInQuad},
	-- })

end

--刷新大厅按钮
function BattleView:OnRefreshHallBtn(type, value, gameId)
	local Id = ZTD.ConstConfig[1].GameId
	if type == "Task" and tonumber(gameId) == Id then
		self:FindChild("leftGridNode/hallTaskNode"):SetActive(value)
	end
end

--刷新大厅红点
function BattleView:OnRefreshHallPoint(type, value, gameId)
	local Id = ZTD.ConstConfig[1].GameId
	if type == "Task" and tonumber(gameId) == Id then
		self:FindChild("leftGridNode/hallTaskNode/redPoint"):SetActive(value)
	end
end

--活动开关推送
function BattleView:OnDragonboxSwitchState(data)
	-- logError("OnDragonboxSwitchState data = "..GC.uu.Dump(data))
	local state = false
	if data.state == 1 then
		state = true
	end
	if data.actID == 1001 then
		self:FindChild("leftGridNode/giftNode"):SetActive(state)
		if state == false then
			ZTD.Notification.GamePost(ZTD.Define.OnCloseGiftView)
		end
	elseif data.actID == 1002 then
		self:FindChild("leftGridNode/dragonBoatNode"):SetActive(state)
		if state == false then
			ZTD.Notification.GamePost(ZTD.Define.OnCloseHolidayView)
		end
	end
end

--获取道具名称
function BattleView:GetNameByPropsID(ID)
	if not ID then return end
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_HolidayView")
	local cfg = language.dragonBoat
	for k, v in ipairs(cfg) do
		if v.PropsID == ID then
			return v.Name
		end
	end
	return ""
end

--材料转换推送
function BattleView:OnMapMaterialConvertInfo(data)
	-- logError("OnMapMaterialConvertInfo data = "..GC.uu.Dump(data))
	local str = ""
	local coin = 0
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_HolidayView")
	for k, v in ipairs(data.info) do
		local name = self:GetNameByPropsID(v.ID)
		local num = v.Num
		str = str .. string.format(language.txt_convertProps, name, num)
		coin = coin + v.coins
	end
	local tip = string.format(language.txt_convertCoin, str, coin)
	local sortingOrder = self.transform:GetComponent("Canvas").sortingOrder + 13
	ZTD.ViewManager.Open("ZTD_ExtendPopViewEx", tip, nil, nil, sortingOrder)
end

-- 自动兑换宝箱信息
function BattleView:OnExchangeBox(data)
	-- log("OnExchangeBox data = "..GC.uu.Dump(data))
	if data.ExchangeCount then
		ZTD.PlayerData.SetExchangeCount(data.ExchangeCount)
	end
	ZTD.ViewManager.Open("ZTD_DragonTreasureRetView", data)
end

function BattleView:OnCreate()
	self:InitLan()
	self:AddUIMaskClick(GameObject.Find("UIMask").transform)
	self:SetCurGroupId()
	self:RequestGift()

	self.skipGroupLimit = ZTD.ArenaConfig.SkipGroupLimit[ZTD.Flow.groupId]

	BattleView.inst = self;

	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");

	--是否开启跳场倒计时
	self.canSkipTimer = true
	
	-- 地图ID，目前只有1
	self._mapId = 1;
	self.mapCfg = {}
	-- 巨龙之怒控制类
	self._dragonUi = ZTD.DragonUi:new(self:FindChild("top_right2"), self);
	self.isDragonSkipGroup = true
	
	self._ghostUi = ZTD.GhostFireUi:new(self);
	self.isGhostSkipGroup = true

	self.gaintUi = ZTD.GiantUi:new(self)
	--五行封印
	self.SealUi = ZTD.SealUi:new(self)

	self._moneyEarnSc = 0;
	
	local cfg = ZTD.ConstConfig[1];
	
	ZTD.Utils.Init();
	self:InitLimitXY();

	self._goldPillar = ZTD.GoldPillar:new();
	
	self.coinEffect = self:FindChild("top/effectContainer");
	self.topNode = self:FindChild("top");
	self.tempPosNode = self:FindChild("tempPos");
	
	self.TopGoldNode = self:FindChild("top/img_gold");
	
	ZTD.GoldPlay.Init()

	self.tbContainer = self:FindChild("top/tbContainer")
	self.TurnTableMgr = ZTD.TurnTableMgr:new()
	self.LightningMgr = ZTD.LightningMgr:new()

	self._isShowPlayerList = false;

	self._nodeSummon = ZTD.PoolManager.GetUiItem("ZTD_NodeSummon", self.transform);--self:FindChild("node_summon");
	self._nodeSummon:SetActive(false);
	self._btnSummons = {};
	
	local heroCfgs = ZTD.HeroConfig;
	local uiSummonListParent = self._nodeSummon:FindChild("itemList_Hero/Viewport/Content");	

	for _, v in ipairs(heroCfgs) do
		local btnSummon = ZTD.Extend.LoadPrefab("ZTD_SummonIcon", uiSummonListParent);
		btnSummon:GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, v.icon_head);
		btnSummon:FindChild("onlyone"):GetComponent("Text").text = self.language.txt_onlyOne;
		self._btnSummons[v.id] = btnSummon;
		self:AddClick(btnSummon, function()
			local viplevel = ZTD.PlayerData.GetVipLevel()
			local isvip = ZTD.PlayerData.GetIsVip()
			-- if viplevel < 3 and v.id == 1003 then
				-- self._nodeSummon:FindChild("btn_summon_confirm"):GetComponent("Button"):SetBtnEnable(false)
				-- self._nodeSummon:FindChild("btn_summon_change"):GetComponent("Button"):SetBtnEnable(false)
			-- elseif not isvip and v.id == 1004 then
				-- self._nodeSummon:FindChild("btn_summon_confirm"):GetComponent("Button"):SetBtnEnable(false)
				-- self._nodeSummon:FindChild("btn_summon_change"):GetComponent("Button"):SetBtnEnable(false)
			-- else
				-- self._nodeSummon:FindChild("btn_summon_confirm"):GetComponent("Button"):SetBtnEnable(true)
				-- self._nodeSummon:FindChild("btn_summon_change"):GetComponent("Button"):SetBtnEnable(true)
			-- end
			-- 召唤按钮的显示与否，来区分当前正在召唤还是换阵
			local isSummon = self._nodeSummon:FindChild("btn_summon_confirm").activeSelf
			self:OnSummonHeroIcon(v, isSummon);
		end)	
	end
	
	local summonLanguage = ZTD.LanguageManager.GetLanguage("L_ZTD_NodeSummon");
	self._nodeSummon:FindChild("btn_summon_confirm").text = summonLanguage.btn_summon_confirm
	self._nodeSummon:FindChild("btn_summon_change").text = summonLanguage.btn_summon_change

	self:AddClick(self._nodeSummon:FindChild("btn_summon_confirm"), "OnClkSummon");
	
	self:AddClick(self._nodeSummon:FindChild("btn_summon_change"), "OnClkChange");

	self:AddClick(self:FindChild("leftGridNode/gameGiftNode"), "OnClkGameGift");

	self:AddClick("btn_onepunch/lock", function()
		-- ZTD.LockPop.OpenLockPopView(language.txt_privilegePop, function()
			ZTD.ViewManager.OpenMessageBox("ZTD_GiftCollectionView", "weeksCard", 2)
		-- end)
	end)
	
	local btnBg = self._nodeSummon:FindChild("btn_bg");
	self:AddClick(btnBg, function()
		self._nodeSummon:SetActive(false);
	end);
	
	self._heroMenu = ZTD.HeroMenu:new();
	local nodeMenu = ZTD.PoolManager.GetUiItem("ZTD_NodeMenu", self.transform);
	self._heroMenu:Init(nodeMenu, self);
	local menuBtnBg = nodeMenu:FindChild("btn_bg");
	self:AddClick(menuBtnBg, function()
		self._heroMenu:closeMenu()
	end);
	
	self:_initTowers();
	
	-- 一键部署相关---
	-- 长摁事件	
	local playerId = ZTD.PlayerData.GetPlayerId()
	self._oneKeyHeros = GC.UserData.Load(ZTD.gamePath.."OneKeyHeros/"..playerId);
	if self._oneKeyHeros then
		for heroId, _ in pairs(self._oneKeyHeros) do
			self._oneKeyHeros[tostring(heroId)] = nil;
			self._oneKeyHeros[tonumber(heroId)] = true;
		end		
	else
		self._oneKeyHeros = {[1001] = true};
	end
	
	local oneKeySetUi = self:FindChild("ZTD_nodeOneKey");
	local isvip = ZTD.PlayerData.GetIsVip()
	self:RefreshOneKeyStatus(isvip)
	self:AddLongPressClick("btn_onepunch",
		function()
			if not self.isOneKeyActive then
				return
			end
			self.isOneKeyActive = false
			self:FindChild("btn_onepunch"):GetComponent("Button"):SetBtnEnable(false)
			self:StartTimer("CoolCountDown", 1, function()
				self.isOneKeyActive = true
				self:FindChild("btn_onepunch"):GetComponent("Button"):SetBtnEnable(true)
				self:StopTimer("CoolCountDown")
			end, -1)
			self:AutoUpHero();
			ZTD.Request.CSButtonRecordsReq({ID = 5001, Mode = 5});
			-- self._heroMenu:closeMenu()
		end,
		
		function()
			--ZTD.ViewManager.Open("ZTD_PackageView");
			oneKeySetUi:SetActive(true);
			-- 刷新
			local viplevel = ZTD.PlayerData.GetVipLevel()
			local isvip = ZTD.PlayerData.GetIsVip()
			self:RefreshOneKeyHero(viplevel, isvip)
			-- self._heroMenu:closeMenu()
		end	
	)
	do
		oneKeySetUi:FindChild("frame/text1").text = language.nodeOneKeyTxt1
		oneKeySetUi:FindChild("frame/text2").text = language.nodeOneKeyTxt2
		local heroCfgs = ZTD.HeroConfig;
		local uiSummonListParent = oneKeySetUi:FindChild("frame/itemList_Hero/Viewport/Content");	
		local arenaId = ZTD.PlayerData.GetRoomArenaID()

		for _, v in ipairs(heroCfgs) do
			local btnSummon = ZTD.Extend.LoadPrefab("ZTD_OneKeyIcon", uiSummonListParent);
			btnSummon.name = v.id
			local viplevel = ZTD.PlayerData.GetVipLevel()
			local isvip = ZTD.PlayerData.GetIsVip()
			--初始化
			if v.id == 1003 and viplevel < 3 then
				btnSummon:FindChild("mask"):SetActive(true)
				btnSummon:FindChild("img_select"):SetActive(false);
				self._oneKeyHeros[tonumber(v.id)] = nil
				self:SaveOneKey()
			elseif v.id == 1004 and not isvip then
				btnSummon:FindChild("mask"):SetActive(true)
				btnSummon:FindChild("img_select"):SetActive(false);
				self._oneKeyHeros[tonumber(v.id)] = nil
				self:SaveOneKey()
			elseif v.id == 1005 then
				btnSummon:FindChild("new"):SetActive(true)
				btnSummon:FindChild("onlyone"):SetActive(true)
				if arenaId <= 1 then
					btnSummon:FindChild("mask"):SetActive(true)
					btnSummon:FindChild("img_select"):SetActive(false);
					self._oneKeyHeros[tostring(v.id)] = nil
				else
					btnSummon:FindChild("mask"):SetActive(false)
				end
			else
				btnSummon:FindChild("mask"):SetActive(false)
			end
			self:AddClick(btnSummon:FindChild("mask"), function()
				if v.id == 1003 and viplevel < 3 then
					ZTD.LockPop.OpenLockPopView(language.txt_v3Pop, function()
						local param = {}
						param.currentView = "VipThreeCardView"
						GC.SubGameInterface.OpenGiftSelectionView(param)
					end)
				elseif v.id == 1004 and not isvip then
					-- ZTD.LockPop.OpenLockPopView(language.txt_privilegePop, function()
						ZTD.ViewManager.OpenMessageBox("ZTD_GiftCollectionView", "weeksCard", 1)
					-- end)
				elseif v.id == 1005 and arenaId <= 1 then
					ZTD.ViewManager.ShowTip(self.language.txt_lockHero)
				end
			end)

			btnSummon:GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, v.icon_head);
			if self._oneKeyHeros[v.id] then
				btnSummon:FindChild("img_select"):SetActive(true);
			else
				btnSummon:FindChild("img_select"):SetActive(false);
			end
			self:AddClick(btnSummon, function()
				if self._oneKeyHeros[v.id] then
					self._oneKeyHeros[tonumber(v.id)] = nil;
					if next(self._oneKeyHeros) then
						btnSummon:FindChild("img_select"):SetActive(false);
					else
						self._oneKeyHeros[tonumber(v.id)] = true;
						ZTD.ViewManager.ShowTip(language.one_key_tip1);
					end
				else
					self._oneKeyHeros[tonumber(v.id)] = true;
					btnSummon:FindChild("img_select"):SetActive(true);
				end	
				self:SaveOneKey()
				-- logError("v.id="..tostring(v.id))
				-- logError("_oneKeyHeros="..GC.uu.Dump(self._oneKeyHeros))
			end)		
		end
	end
	--翻转动画部分---
	local loopFunc;
	local loopMark = true;
	loopFunc = function()
		local rrrTxt = self:FindChild("btn_onepunch/txt");
		local goRo = 180;
		if loopMark then
			goRo = -180;
		else
			goRo = 180;
		end
		rrrTxt.transform.localScale = Vector3.one;
		rrrTxt.transform.localRotation = Vector3.zero;
		ZTD.Extend.RunAction(rrrTxt, {{"rotateTo", 0, goRo, 0, 1} ,
											onEnd = function()										
												ZTD.GameTimer.DelayRun(1, loopFunc);
											end,})
											
		ZTD.GameTimer.DelayRun(0.5, function()
			if loopMark then
				rrrTxt.text = language.txt_btn_onekey1;
				goRo = -180;
			else
				rrrTxt.text = language.txt_btn_onekey2;
				goRo = 180;
			end
			rrrTxt.transform.localScale = Vector3(-1, 1, 1);
			loopMark = not loopMark;				
		end)									
	end	
	loopFunc();
	------------------------

	
	self:_initUi();
	
	---debug---
	self._isBack = false;
	self:AddClick("debug/btn_pause",function()
		self._isBack = not self._isBack;
		if self._isBack then
			self:FindChild("debug/btn_pause/txt_pause").text = "后台中";
			ZTD.Flow.OnPause();
			self:OnPause();
		else	
			self:FindChild("debug/btn_pause/txt_pause").text = "前台中";
			ZTD.Flow.OnResume();
			self:OnResume();
		end	
	end);
	
	self:AddClick("debug/btn_dragon",function()	
		ZTD.ViewManager.Open("ZTD_PackageView");
		if true then
			return;
		end	
	
		local enemyMgr = ZTD.Flow.GetEnemyMgr();
		for _, hitEnemy in pairs (enemyMgr._ctrlList) do
			if hitEnemy._isUnSelect then
				
				
				local playerId = hitEnemy._UnSelectKillId or 0;
				local roomId = self._var_roomId;
				local posId = hitEnemy._id;
				local unSelectRootId = hitEnemy._unSelectRootId or 0;
				
				local debug_log = "" .. playerId .. ",r:" .. roomId .. ",p:" .. posId .. ",f:" .. unSelectRootId;
				-- logError(os.date("%Y-%m-%d %H:%M:%S:") .. "," .. debug_log);
				
				
				local succCb = function(err,data)
				end				
				ZTD.Request.CSDebugDataReq({DebugData = debug_log}, succCb, succCb);
			end
		end		
	end);	
	----------
	--大厅道具变更推送
	--ZTD.Notification.GameRegister(self, ZTD.Define.OnPushPropsInfo, self.OnPushPropsInfo)
	
	ZTD.Notification.GameRegister(self, ZTD.Define.OnPushChipRedPoint, self.RefreshRedPoint)
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgPlayerJoin, self.OnPlayerJoin)
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgPlayerLeave, self.OnPlayerLeave)	
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgScMoneyChange, self.OnPlayerMoneyChange)	
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgOpenSummon, self.OnOpenSummon)
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgOpenHeroMenu, self.OnOpenHeroMenu)
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgTrustOn, self.OnTrustOn)
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgCleanHeroLock, self.CleanMyHeroLock)
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgLackMoney, self.OnLackMoney)
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgRelease, self.Destroy);
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgRefreshRadio, self.InitMultiple);
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgHeroChange, self.ChangeHeroPos);
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgCostChange, self.OnCostChange)
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgGameResume, self.OnGameResume)
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgRefreshGold, self.OnRefreshGold)
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgRefreshGoldEarn, self.OnRefreshGoldEarn)
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgClkMap, self.OnClkMap);
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgGoldPillar, self.OnGoldPillar);
	
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgNetClose, self.OnNetClose);
	
	-- ZTD.Notification.GameRegister(self, ZTD.Define.OnpushShake, self.OnpushShake);
	-- ZTD.Notification.GameRegister(self, ZTD.Define.OnpushShakeClose, self.OnpushShakeClose);

	ZTD.Notification.GameRegister(self, ZTD.Define.OnPushDropMaterials, self.OnPushDropMaterials);
	ZTD.Notification.GameRegister(self, ZTD.Define.OnPushConnectMonster, self.OnPushConnectMonster)
	
	-- 重连等同于换房间	
	-- 游戏服重连
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgReconnect, self.OnChangeRoom);

	--玩家vip等级
	ZTD.Notification.NetworkRegister(self, "SCPlayerVipLevel", self.OnPlayerVipLevel)	
	--推送巨龙令信息
	ZTD.Notification.NetworkRegister(self, "SCPushDragonProps", self.OnDragonProps)	
	
	ZTD.Notification.NetworkRegister(self, "SCPushTowerUpdateHero", self.OnSummonTowerHero)
	ZTD.Notification.NetworkRegister(self, "SCTowerHeroAtkInfo", self.OnTowerHeroAtk)
	ZTD.Notification.NetworkRegister(self, "SCEndTrusteeship", self.OnEndTrusteeship)
    ZTD.Notification.NetworkRegister(self, "SCTowerExchangeHero", self.OnExchangeHero)	
	ZTD.Notification.NetworkRegister(self, "SCLeaveTowerTableCountdown", self.OnLeaveTowerTableCountdown)
	ZTD.Notification.NetworkRegister(self, "SCOneKeyUpdateHero", self.OnOneKeyUpdateHero)
	ZTD.Notification.NetworkRegister(self, "SCPushSyncHeroMoney", self.OnPushSyncHeroMoney)
	ZTD.Notification.NetworkRegister(self, "SCDropCard", self.OnPushDropCard)
	
	-- 刚进页面时，拉取新手数据
	local function succCb(err, gData)
		ZTD.GuideData.Init(gData);
		ZTD.Notification.GamePost(ZTD.Define.MsgGuideBattleView, self);
	end
	local function errcb(err, data)
		succCb(nil, nil);
	end					

	--succCb(nil, nil);
	ZTD.Request.CSGetTowerStepReq(succCb, errcb);	

	--宝箱信息
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_GiftCollectionView")
	self.boxInfoCfg = language.dragonTreasure
	--玩家材料信息
	local succCb = function(err, data)
		-- log("CSGetMaterialsInfoReq data="..GC.uu.Dump(data.Info))
		ZTD.PlayerData.SetChipData(data.Info)
		self:RefreshRedPoint()
    end
    local errCb = function(err, data)
        logError("CSGetMaterialsInfoReq err="..GC.uu.Dump(err))
    end
    ZTD.Request.CSGetMaterialsInfoReq(succCb, errCb)
	
	
end

-- 金币柱显示
function BattleView:OnGoldPillar(high, moneyEarn)
	self._goldPillar:AddPillar(high, moneyEarn);
end	

-- 断网工作
function BattleView:OnNetClose()
	ZTD.MainScene.SetPlayerLockTarget(nil);
	self:SetAutoBattle(false, nil, true);
end

--暗补
-- function BattleView:OnpushShake()
-- 	local gameData = ZTD.MJGame.gameData
-- 	GC.SubGameInterface.OpenShake(gameData.GameID)
-- end

-- function BattleView:OnpushShakeClose()
-- 	GC.SubGameInterface.DestryShake(self.shakeIcon)
-- end

-- 点击地图空白处的回调
function BattleView:OnClkMap()
	self._isShowHistoryTrend = false;
	ZTD.TrendDraw.Close(self:FindChild("node_history"));
	
	self._isShowMore = false;
	self:FindChild("top_right/bg_menu"):SetActive(self._isShowMore);	
	
	--self._heroMenu:Close();
	
	local oneKeySetUi = self:FindChild("ZTD_nodeOneKey");
	oneKeySetUi:SetActive(false); 

	self._dragonUi.dragonPop:SetActive(false)
	self._dragonUi.isOpenPop = false
	self:SaveOneKey()
end

function BattleView:SaveOneKey()
	local heroTable = {};
	for heroId, _ in pairs(self._oneKeyHeros) do
		heroTable[tostring(heroId)] = true;
	end
	local playerId = ZTD.PlayerData.GetPlayerId()
	GC.UserData.Save(ZTD.gamePath.."OneKeyHeros/"..playerId, heroTable);	
end

--点击游戏礼包合集
function BattleView:OnClkGameGift()
	ZTD.ViewManager.OpenMessageBox("ZTD_GiftCollectionView")
end

function BattleView:OnClkChange()
	local arenaId = ZTD.PlayerData.GetRoomArenaID()
	if self._nodeSummonheroId == 1005 and arenaId <= 1 then
		ZTD.ViewManager.ShowTip(self.language.txt_lockHero)
		return
	end
	local viplevel = ZTD.PlayerData.GetVipLevel()
	local isvip = ZTD.PlayerData.GetIsVip()
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	-- logError("viplevel="..viplevel.."  isvip="..tostring(isvip).." self._nodeSummonheroId="..self._nodeSummonheroId)
	if viplevel < 3 and self._nodeSummonheroId == 1003 then
		ZTD.LockPop.OpenLockPopView(language.txt_v3Pop, function()
			local param = {}
			param.currentView = "VipThreeCardView"
			GC.SubGameInterface.OpenGiftSelectionView(param)
		end)
		return
	elseif not isvip and self._nodeSummonheroId == 1004 then
		-- ZTD.LockPop.OpenLockPopView(language.txt_privilegePop, function()
			ZTD.ViewManager.OpenMessageBox("ZTD_GiftCollectionView", "weeksCard", 1)
		-- end)
		return
	end
	
	if self._nowSelHp._nowHeroId then
		local heroPos = self._nowSummonHp;
		local function buildCb(heroId, playerId, uuid)
			self:_downHero(self._nowSelHp);
			self:_upHero(heroPos, nil, nil, nil, uuid);
			-- 如果正在自动攻击，还要请求一下攻击状态
			if self._isAutoBattle then
				self:DelayRun(0.1, function()
					local btnBeginCb = function(stdt)
						heroPos:BeginCb(stdt);
					end
					self:_reqAtk(heroPos._posId, true, btnBeginCb);
				end)
			end
		end
		self:_reqHero(heroPos._posId, self._nodeSummonheroId, false, buildCb);			
	end	
end	

function BattleView:OnClkSummon()
	local arenaId = ZTD.PlayerData.GetRoomArenaID()
	if self._nodeSummonheroId == 1005 and arenaId <= 1 then
		ZTD.ViewManager.ShowTip(self.language.txt_lockHero)
		return
	end
	local viplevel = ZTD.PlayerData.GetVipLevel()
	local isvip = ZTD.PlayerData.GetIsVip()
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	-- logError("viplevel="..viplevel.."  isvip="..tostring(isvip).." self._nodeSummonheroId="..self._nodeSummonheroId)
	if viplevel < 3 and self._nodeSummonheroId == 1003 then
		ZTD.LockPop.OpenLockPopView(language.txt_v3Pop, function()
			local param = {}
			param.currentView = "VipThreeCardView"
			GC.SubGameInterface.OpenGiftSelectionView(param)
		end)
		return
	elseif not isvip and self._nodeSummonheroId == 1004 then
		-- ZTD.LockPop.OpenLockPopView(language.txt_privilegePop, function()
			ZTD.ViewManager.OpenMessageBox("ZTD_GiftCollectionView", "weeksCard", 1)
		-- end)
		return
	end
	
	local heroPos = self._nowSummonHp;
	local function buildCb(heroId, playerId, uuid)
		self:_upHero(heroPos, nil, nil, nil, uuid);
		self:OnCostChange(-heroPos._cost);
		-- 如果正在自动攻击，还要请求一下攻击状态
		if self._isAutoBattle then
			self:DelayRun(0.1, function()
				local btnBeginCb = function(stdt)
					heroPos:BeginCb(stdt);
				end
				self:_reqAtk(heroPos._posId, true, btnBeginCb);
			end)
		end
	end
	self:_reqHero(heroPos._posId, self._nodeSummonheroId, false, buildCb);		
end

function BattleView:OnOneKeyUpdateHero(Data)	
	if ZTD.TableData.GetTable() ~= Data.TableId then
		return;
	end
	-- logError("leaveInfo="..GC.uu.Dump(Data.leaveInfo))
	-- logError("updateInfo="..GC.uu.Dump(Data.updateInfo))
	-- 先做下阵工作
	for _, v in ipairs(Data.leaveInfo) do
		local leaveData = {};
		leaveData.Leave = true;
		leaveData.ReqPlayerId = Data.PlayerId;
		leaveData.Info = {};
		leaveData.Info.HeroId = v.HeroId;
		leaveData.Info.PositionId = v.PositionId;
		self:OnSummonTowerHero(leaveData);
	end	
	
	
	local isPlayer = (Data.PlayerId == ZTD.PlayerData.GetPlayerId());
	local upData = {};
	for _, v in ipairs(Data.updateInfo) do
		local heroId = v.HeroId;
		local posId = v.PositionId;
		local uuid = v.UniqueId;
		table.insert(upData, {heroId = heroId, posId = posId, uuid = uuid})
	end
	
	local node_bo = self:FindChild("btn_onepunch");

	local checkCost = 0;

	
	for _, v in ipairs(upData) do
		
		local gi, si = ZTD.MainScene.HeroPosId2GS(v.posId);
		local heroPos = self._hero_pos[gi][si];
		checkCost = checkCost - heroPos._cost;
		local targetPos = heroPos._node_summon.position;
		

		
		if isPlayer then
			heroPos:SetEff(false);
			self:_upHero(heroPos, false, Data.PlayerId, v.heroId, v.uuid)
			local heroCtrl = heroPos:GetHeroCtrl();
			heroCtrl:Hide();
			heroPos:SetEff(true);
		end			
		
		if isPlayer then
			local trail, trailID = ZTD.EffectManager.PlayEffect("TD_Effect_fangzhi_1", ZTD.MainScene.GetMapObj());	
			trail:SetActive(true);
			trail.position = ZTD.MainScene.UiPos2SetupPos(node_bo.transform.position);
			local autoUpData = {};
			local tuowei = trail:FindChild("touwei/toulaing");
			tuowei:SetActive(false);
			local function checkFunc(value)
				if value > 10 then
					tuowei:SetActive(true);
				end			
			end
			
			local function endFunc()
				ZTD.EffectManager.RemoveEffectByID(trailID)
				trail:SetActive(false);
				local put_show, put_showID = ZTD.EffectManager.PlayEffect("TD_Effect_fangzhi_2", ZTD.MainScene.GetMapObj());
				put_show:SetActive(true);
				put_show.position = targetPos;			
				autoUpData.put_show = put_show;
				autoUpData.put_showID = put_showID;
				
				ZTD.GameTimer.DelayRun(1.5, function()
					ZTD.EffectManager.RemoveEffectByID(put_showID)
					put_show:SetActive(false);
				end)
				
				local heroCtrl = heroPos:GetHeroCtrl();
				if heroCtrl then
					heroCtrl:Show();
					heroPos:ShowUpEff();
				end	
				-- 如果正在自动攻击，还要请求一下攻击状态
				if self._isAutoBattle then
					self:DelayRun(0.1, function()
						local btnBeginCb = function(stdt)
							heroPos:BeginCb(stdt);
						end
						self:_reqAtk(heroPos._posId, true, btnBeginCb);
					end)
				end			
				
				if self._autoUpTable then
					self._autoUpTable = nil;
				end			
			end

			local bezUpHeroAct = ZTD.Extend.RunBezier(targetPos, trail.position, trail, checkFunc, endFunc)
			
			autoUpData.act = bezUpHeroAct;
			autoUpData.trail = trail;
			autoUpData.trailID = trailID;
			if not self._autoUpTable then
				self._autoUpTable = {};
			end
			table.insert(self._autoUpTable, autoUpData);
		else
			self:_upHero(heroPos, false, Data.PlayerId, v.heroId, v.uuid)
		end
	end
	
	if isPlayer then
		self:OnCostChange(checkCost);
	end	
end

function BattleView:OnPushSyncHeroMoney(Data)
	ZTD.TableData.ResetHeroUuidMoeny();
	ZTD.TableData.ResetMaSkillTimes();
	for _, v in ipairs(Data.HeroMoney) do
		ZTD.TableData.SetMaSkillTimes(v.UniqueId, v.Money);
		ZTD.TableData.WriteHeroUuidMoeny(v.UniqueId, v.Money);
	end
end	

function BattleView:OnLeaveTowerTableCountdown(Data)
	--logError("ppppppppppppppppppppppppp:" .. Data.TableID)
	local vRoomId = self._var_roomId;
	if vRoomId == Data.TableID then
		self:ShowCountDown(10)
	end	
end

--会员到期，上阵龙母替换为维克多
function BattleView:ChangeHero(oldIsVip, newIsVip)
	if oldIsVip ~= newIsVip and not newIsVip then
		for nm, _ in pairs(self._nowHeroHps) do
			local heroCtrl = nm:GetHeroCtrl()
			local id = heroCtrl._cfg.id
			local isAtk = heroCtrl:isAutoPlayAtk()
			if id == 1004 then
				--logError("替换龙母")
				local function buildCb(heroId, playerId, uuid)
					self:_downHero(nm, true);
					self:_upHero(nm, isAtk, playerId, heroId, uuid)
					-- 如果正在自动攻击，还要请求一下攻击状态
					if self._isAutoBattle then
						self:DelayRun(0.1, function()
							local btnBeginCb = function(stdt)
								nm:BeginCb(stdt);
							end
							self:_reqAtk(nm._posId, true, btnBeginCb)
						end)
					end
				end
				self:_reqHero(nm._posId, 1001, false, buildCb, showInx)
			end
		end
	end
end

function BattleView:OnSummonTowerHero(data)
	-- log("OnSummonTowerHero data = "..GC.uu.Dump(data))
	local heroId = data.Info.HeroId;
	local positionId = data.Info.PositionId;
	local groupInx, setupInx = ZTD.MainScene.HeroPosId2GS(positionId);
	
	local isPlayerChange = false;
	local heroPos = self._hero_pos[groupInx][setupInx];
	if heroPos._playerId == ZTD.PlayerData.GetPlayerId() then
		isPlayerChange = true;
	end
	
	-- log("OnSummonTowerHero:" .. positionId .. ":" .. tostring(data.Leave))
	if not data.Leave then
		local chairId = ZTD.TableData.GetData(data.ReqPlayerId, "ChairId");
		-- 获取不到玩家信息则无视这个操作
		if chairId then
			self:SetHeroOnScene(groupInx, setupInx, heroId, data.ReqPlayerId, nil, data.Info.UniqueId);
		end	
	else
		self:SetHeroOnScene(groupInx, setupInx, 0);
	end
	
	if isPlayerChange then
		local isvip = ZTD.PlayerData.GetIsVip()
		local checkCost = ZTD.MainScene.GetMapScore(1, positionId, isvip);
		if not data.Leave then
			checkCost = -checkCost;
		end
		checkCost = isvip and checkCost or checkCost + 1
		--logError("checkCost="..checkCost)
		--logError("333 tonumber(self._ui_cost.text)="..tonumber(self._ui_cost.text))
		self:OnCostChange(checkCost);
		--logError("444 tonumber(self._ui_cost.text)="..tonumber(self._ui_cost.text))
	end
end	

function BattleView:OnTowerHeroAtk(data)
	for _, v in pairs(data.Info) do
		local positionId = v.HeroPositionId;
		if positionId then
			local groupInx, setupInx = ZTD.MainScene.HeroPosId2GS(positionId);
			local heroPos = self._hero_pos[groupInx][setupInx];
			if v.IsAtk then
				heroPos:BeginCb();
			else
				heroPos:PauseCb();
			end
		end
	end
end

function BattleView:OnEndTrusteeship(data)
    self:SetAutoBattle(false, nil, true)
	--if not ZTD.Flow.IsOpenTrusteeshipRetView then
		ZTD.Flow.IsOpenTrusteeshipRetView = true;
		ZTD.ViewManager.Open("ZTD_TrusteeshipRetView", data, self._trustCb);
		self._trustCb = nil;
	--end	
end

function BattleView:OnExchangeHero(data)
	local srcPos = data.OldPositionId;
	local newPos = data.NewPositionId;
	
	local srcGs = {};
	local dstGs = {};
	srcGs.gi, srcGs.si = ZTD.MainScene.HeroPosId2GS(srcPos);
	dstGs.gi, dstGs.si = ZTD.MainScene.HeroPosId2GS(newPos);
	
	self:ChangeHeroPos(srcGs, dstGs, data.ReqPlayerId);
end	

function BattleView:OnPlayerJoin(ptData)
	local isPlayerIdMark = false;
	for _, v in ipairs(ptData.Info) do
		if v.PlayerId == ZTD.PlayerData.GetPlayerId() then
			isPlayerIdMark = true;			
			
			-- 从后台回来时，清场工作
			if self._pauseMark then
				self:ResetGoldDisplay();
				self._pauseMark = nil;
			end
			--self:ReqNFTConfig()
			break;
		else
			self:PlayEntryEffect(v.Effect)
		end
	end
	
	if isPlayerIdMark then
		local uiRoomId = self._var_roomId;
		-- 当收到包含自己的推送时，确认房间的初始化
		if #self._RoomChangeCb > 0 then
			logError("-----errerrerr _RoomChangeCb_RoomChangeCb:" .. ZTD.TableData.GetTable());
			self._RoomChangeCb[1]();
			table.remove(self._RoomChangeCb, 1);
		elseif uiRoomId ~= ptData.TableID then
			self:OnChangeRoom();
		end
	end
		
	local function warpFunc(info)
		if self._playerItems[info.PlayerId] == nil then
			self:_createPlayerItem(info);
			--logError("!!!!!!!!_createPlayerItem:" .. info.PlayerId)
		end
	end
	ZTD.TableData.WarpInfo(warpFunc);	
	
	self:_syncOtherHero();
end

function BattleView:ShowCountDown(cd)
	self:ReleaseCountDown();
	self._countDown = ZTD.CountDown:new();
	self._countDown:Init(cd);
end	

function BattleView:ReleaseCountDown()
	if self._countDown then
		self._countDown:Release();
		self._countDown = nil;
	end	
end	

function BattleView:OnPlayerLeave(Data)
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	local playerId = Data.PlayerId;
	local function leaveFunc(heroInfo)
		local groupInx, setupInx = ZTD.MainScene.HeroPosId2GS(heroInfo.PositionId);
		self:SetHeroOnScene(groupInx, setupInx, 0);	
	end
	ZTD.TableData.DealLeave(playerId, leaveFunc);
	
	if self._playerItems[playerId] then
		--logError("!!!!!!!!_removePlayerItem:" .. playerId)
		ZTD.PoolManager.RemoveUiItem("ZTD_NodeTablePlayer", self._playerItems[playerId]);
		self._playerItems[playerId] = nil;
	end
	
	if playerId == ZTD.PlayerData.GetPlayerId() then
		--logWarn("----------------------kick!!!!!!!!");
		--self:OnExit();
		local IsAgainEnter = Data.IsAgainEnter;
		
		if IsAgainEnter then
			self:OnChangeRoom();	
		else	
			local str = language.kick_out_tips;
			local confirmFunc = function ()
				self:OnChangeRoom();
			end
			local cancelFunc = function ()
				self:OnExit();
			end

			ZTD.ViewManager.OpenExitGameBox(0, str, confirmFunc, cancelFunc, language.BtnConnect, language.BtnLeave)
			self:ReleaseCountDown();
		end
				
		return;
	end		
end

function BattleView:OnPlayerMoneyChange(data, moneyEarn)	
	local playerId = data.PlayerId
	local totalMoneyEarn = data.MoneyVariation;
	if playerId ~= ZTD.PlayerData.GetPlayerId() then
		self:_updatePlayerItemMoney(playerId, totalMoneyEarn);
	end
	if playerId == ZTD.PlayerData.GetPlayerId() then
		-- 一旦有了金币变化就释放踢人倒计时
		if moneyEarn ~= 0 then
			self:ReleaseCountDown();
		end	
		self._moneyEarnSc = totalMoneyEarn;
		self:OnRefreshGoldEarn();

		-- 如果是充值，立即更新
		if data.Type == 1 then
			self._roomGold = self._roomGold + moneyEarn;
			local totalGold = ZTD.GoldData.Gold;
			totalGold:Set(data.Money);
			self:OnRefreshGold(data.Money);
			
		end
		if data.Type == 18 then
			local totalGold = ZTD.GoldData.Gold;
			totalGold:Set(data.Money);
			self:OnRefreshGold(data.Money)
		end
	end	
end



function BattleView:RefreshHeroLock()
	local heroCfgs = ZTD.HeroConfig
	local viplevel = ZTD.PlayerData.GetVipLevel()
	local isvip = ZTD.PlayerData.GetIsVip()	
	local arenaId = ZTD.PlayerData.GetRoomArenaID()
	--logError("viplevel="..tostring(viplevel).."  isvip="..tostring(isvip))
	for _, v in ipairs(heroCfgs) do
		if viplevel < 3 and v.id == 1003 then
			self._btnSummons[v.id]:FindChild("mask"):SetActive(true)
		elseif not isvip and v.id == 1004 then
			self._btnSummons[v.id]:FindChild("mask"):SetActive(true)
		elseif v.id == 1005 then
			self._btnSummons[v.id]:FindChild("new"):SetActive(true)
			self._btnSummons[v.id]:FindChild("onlyone"):SetActive(true)
			if arenaId <= 1 then
				self._btnSummons[v.id]:FindChild("mask"):SetActive(true)
			else
				self._btnSummons[v.id]:FindChild("mask"):SetActive(false)
			end
		else
			self._btnSummons[v.id]:FindChild("mask"):SetActive(false)
		end
	end
end

function BattleView:OnOpenSummon(tgHeroPos, isFromChange)
	--logError("OnOpenSummon")
	isFromChange = isFromChange or false
	if self._heroMenu:IsActive() and not isFromChange then
		return
	end
	self:RefreshHeroLock()
	if self._nodeSummon.activeSelf == false and tgHeroPos._heroInx == nil then
		
		local nowCost = tonumber(self._ui_cost.text)
		if nowCost < tgHeroPos._cost then
			ZTD.ViewManager.ShowBubble(tgHeroPos._node_summon.position)
			self._ui_cost_down:SetActive(false)
			self._ui_cost_down:SetActive(true)
			GC.Sound.PlayEffect("ZTD_cost_less")
			return
		end	
		
		self._nodeSummon:SetActive(true)
		self._nodeSummon.localPosition = Vector3(0, 0, 0)
		self._nowSummonHp = tgHeroPos
		
		-- 第一次打开，需要等待layout refresh后才能有正确坐标，故放在下一帧执行逻辑
		if self._isEverOpenSummon == nil then
			self:DelayRun(0.1, function()
				self:OnSummonHeroIcon(ZTD.MainScene.GetHeroCfg(DefaultHeroId), not isFromChange)
			end)
			self._isEverOpenSummon = true
		else
			self:OnSummonHeroIcon(ZTD.MainScene.GetHeroCfg(DefaultHeroId), not isFromChange)
		end

		self._nodeSummon:FindChild("btn_summon_change"):SetActive(false)
		self._nodeSummon:FindChild("icon_on"):SetActive(false)
		self._nodeSummon:FindChild("btn_summon_confirm"):SetActive(true)
		-- self._nodeSummon:FindChild("btn_summon_confirm"):GetComponent("Button"):SetBtnEnable(true)

		ZTD.Notification.GamePost(ZTD.Define.MsgGuideOpenSummonHero, self, self._nodeSummon)
	elseif isFromChange then
		self._nodeSummon:SetActive(true)
		--self._nodeSummon.localPosition = Vector3(0, 0, 0)
		self._nowSummonHp = tgHeroPos
		
		self._nodeSummon:FindChild("btn_summon_change"):SetActive(true)
		self._nodeSummon:FindChild("icon_on"):SetActive(true)
		self._nodeSummon:FindChild("btn_summon_confirm"):SetActive(false)


		
		-- 第一次打开，需要等待layout refresh后才能有正确坐标，故放在下一帧执行逻辑
		if self._isEverOpenSummon == nil then
			self:DelayRun(0.001, function()
				local btnSummon = self._btnSummons[tgHeroPos._nowHeroId];
				self._nodeSummon:FindChild("icon_on").position = btnSummon.position + Vector3(1, 0.75, 0);
				self:OnSummonHeroIcon(ZTD.MainScene.GetHeroCfg(tgHeroPos._nowHeroId), not isFromChange);
			end);	
			self._isEverOpenSummon = true;
		else
			local btnSummon = self._btnSummons[tgHeroPos._nowHeroId];
			self._nodeSummon:FindChild("icon_on").position = btnSummon.position + Vector3(1, 0.75, 0);
			self:OnSummonHeroIcon(ZTD.MainScene.GetHeroCfg(tgHeroPos._nowHeroId), not isFromChange);
		end		
	end		
end

function BattleView:FindFreeHeroPos()	
	local freeMap = {};
	for yy, v in pairs(self._hero_pos) do
		for xx, heroPos in pairs(v) do
			if heroPos._heroInx == nil  then
				freeMap[yy * 10 + xx] = heroPos;
			end
		end
	end
	
	-- 检查最佳位置是否存在,有顺序
	local bestMatch = {22, 23, 32, 33, 12, 13, 14, 52, 53, 54}
	
	for _, v in ipairs(bestMatch) do
		if freeMap[v] then
			return freeMap[v];
		end	
	end	
	
	-- 没有位置就随便找个空位返回 
	for _, v in pairs(freeMap) do
		return v;
	end
end	

function BattleView:OnOpenHeroMenu(groupInx, setupInx)
	local heroPos = self._hero_pos[groupInx][setupInx];
	self._heroMenu:Open(heroPos);
	self._nowSelHp = heroPos;
	ZTD.Request.CSButtonRecordsReq({ID = 4002, Mode = 4});
end

function BattleView:_cleanNow(isPlayerSave)
	-- 清空锁定
	ZTD.MainScene.SetPlayerLockTarget();
	
	-- 清屏敌人
	local enemyMgr = ZTD.Flow.GetEnemyMgr();
	if not isPlayerSave then
		enemyMgr:Release();
		enemyMgr:Init();
	end

	-- 清屏玩家和英雄数据
	--logError("remove start _cleanNow!!!!!");
	for playerId, v in pairs(self._playerItems) do
		--logError("!!!!!!_cleanNow remove playerId:" .. playerId);
		ZTD.PoolManager.RemoveUiItem("ZTD_NodeTablePlayer", v);
		local function leaveFunc(heroInfo)
			local groupInx, setupInx = ZTD.MainScene.HeroPosId2GS(heroInfo.PositionId);
			self:SetHeroOnScene(groupInx, setupInx, 0);	
		end
		
		if not(playerId == ZTD.PlayerData.GetPlayerId() and isPlayerSave) then
			ZTD.TableData.DealLeave(playerId, leaveFunc);		
		end	
	end	
	ZTD.TableData.Init(isPlayerSave);
	self._playerItems = {};
	if not isPlayerSave then
		-- 如果进退后台发生了断线，可能会收不到新的_playerItems的推送，从而导致英雄还在阵上，所以这里要手动多检查多一次，保证英雄重连后是下阵的
		if next(self._nowHeroHps) ~= nil then
			for nm, _ in pairs(self._nowHeroHps) do
				self:SetHeroOnScene(nm._groupInx, nm._setupInx, 0);	
			end
		end
		self._nowHeroHps = {};
	end
	
	-- 确定换房时候，再强制清理所有在场英雄，防止网络波动
	if not isPlayerSave then
		for _, v in pairs(self._hero_pos) do
			for __, heroPos in pairs(v) do
				heroPos:CloseHeroRange();
				self._heroMenu:Close();	
				heroPos:CancelCb();
			end
		end
	end	
	
	-- 清空锁定信息
	ZTD.TableData.CleanLockInfo()
end	

function BattleView:OnLackMoney()
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	
	local function cb()
		local groupId = ZTD.Flow.groupId
		self.MultipleInfo = ZTD.MultipleConfig[groupId]
		self.multipleStep = 1;
		self.multiple = self.MultipleInfo[1];
		self:SetMultiple(0)
		
		local function succCb0()
			
			if not self.tip then
				self.tip = ZTD.ViewManager.ShowTip(language.less_money)
				local playerId = ZTD.PlayerData.GetPlayerId()
				ZTD.GameTimer.DelayRun(1, function()
					if not self.check then
						local param = {
							ChouMa = ZTD.TableData.GetData(playerId, "Money"),
							Integral = GC.SubGameInterface.GetHallIntegral(),
						}
						GC.SubGameInterface.ExOpenShop(param)
					end
				end)
				self.tip = nil
			end
		end
		local function errCb0()
			succCb0();
		end
		ZTD.MainScene.SetPlayerLockTarget();
		ZTD.PlayerData.RadioReq(succCb0, errCb0)		
	end	
	
	self:SetAutoBattle(false, cb);
end	

function BattleView:OnChangeRoom()
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig")
	local str = language.txt_changeroomLimit
	if ZTD.Utils.IsNotMatchArenaLimit(str) then return end
	local function goNewRoom()
		self:_dealExit();
		--发送退场消息
		ZTD.Notification.GamePost(ZTD.Define.MsgDoExit, {isChangeRoom = true});
	end	
	
	if ZTD.Flow.IsTrusteeship then
		self._trustCb = goNewRoom;
		self:_doEndTrusteeshipReq();
	else	
		goNewRoom();
	end
	--[[
	-- 关闭自动攻击
	self:SetAutoBattle(false);
	--logError("-----OnChangeRoom:" .. debug.traceback());
	local function goNewRoom()
		local enemyMgr = ZTD.Flow.GetEnemyMgr();
		enemyMgr:CleanDieRecord();
		
		local waitInx = ZTD.Utils.ShowWaitTip();
		self:_cleanNow();
		
		self._RoomChangeCb[#self._RoomChangeCb + 1] = function()
			ZTD.Utils.CloseWaitTip(waitInx);
			self:_initUi();
		end	
		
		local succCb = function(err,data)	
			--ZTD.PlayerData.SetMultiple(data.UseRatio);
			self:InitMultiple();
		end
		
		local errCb = function(err,data)			
			ZTD.Utils.CloseWaitTip(waitInx);
			--logError("-----errerrerr errCb OnChangeRoom:" .. debug.traceback());
			table.remove(self._RoomChangeCb, 1);
			-- 进入模式失败
			-- 10074房间不够，被挤出去，回到僵尸2
			if err == 10074 then
				local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
				local str = language.over_capacity;
				local confirmFunc = function ()
					self:OnExit();
				end

				ZTD.ViewManager.OpenExitGameBox(0,str,confirmFunc);		
			else
				logError("OnTowerDefModeClick______errCb:" .. tostring(err))
			end	
		end
		local cfg = ZTD.ConstConfig[1];
		local param = {}
		param.enter = true
		param.Mode = cfg.ParamMode;
		ZTD.Request.CSEnterStageReq(param,succCb,errCb);
	end

	self:_doEndTrusteeshipReq(goNewRoom);
	--]]
end

--获取上阵英雄数量
function BattleView:GetUpHeroNum()
	local heroNum = 0
	for k, v in pairs(self._nowHeroHps) do
		if v then
			heroNum = heroNum + 1
		end
	end
	return heroNum
end

--更新当前英雄放置分值
function BattleView:RefreshTotalCost(oldVipLevel, newVipLevel, oldIsVip, newIsVip)
	-- logError("oldVipLevel="..tostring(oldVipLevel).."  newVipLevel="..tostring(newVipLevel))
	if oldVipLevel < newVipLevel then
		local totalscore = self:GetTotalScore()
		-- logError("totalscore="..tostring(totalscore))
		-- logError("self.curtotalscore="..tostring(self.curtotalscore))
		-- logError("self:GetNowCost()="..tostring(self:GetNowCost()))
		local offScore =  totalscore - self.curtotalscore
		self.curtotalscore = totalscore
		self._ui_cost.text = self:GetNowCost() + offScore
	end
	
	local score = self:GetUpHeroNum()
	-- logError("oldIsVip="..tostring(oldIsVip))
	-- logError("newIsVip="..tostring(newIsVip))
	if oldIsVip ~= newIsVip then
		score = newIsVip and score or -score
		if score ~= 0 then
			-- logError("111 tonumber(self._ui_cost.text)="..tonumber(self._ui_cost.text))
			self:OnCostChange(score)
			-- logError("222 tonumber(self._ui_cost.text)="..tonumber(self._ui_cost.text))
			
		end
	end
end

--刷新玩家列表vip等级
function BattleView:RefreshPlayerItemVip(PlayerId, Level)
	if self._playerItems[PlayerId] then
		local item = self._playerItems[PlayerId];
		if Level > 9 and Level < 100 then
			item:FindChild("vipNode/img2"):SetActive(true)
			item:FindChild("vipNode/img3"):SetActive(true)
			item:FindChild("vipNode/vip1"):SetActive(true)
			item:FindChild("vipNode/vip2"):SetActive(true)
			item:FindChild("vipNode/vip1"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "V_"..Level/10);
			item:FindChild("vipNode/vip2"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "V_"..Level%10);
		elseif Level < 10 and Level > 0 then
			item:FindChild("vipNode/img2"):SetActive(true)
			item:FindChild("vipNode/img3"):SetActive(true)
			item:FindChild("vipNode/vip1"):SetActive(true)
			item:FindChild("vipNode/vip2"):SetActive(false)
			item:FindChild("vipNode/vip1"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "V_"..Level);
		else
			item:FindChild("vipNode/img2"):SetActive(false)
			item:FindChild("vipNode/img3"):SetActive(false)
			item:FindChild("vipNode/vip1"):SetActive(false)
			item:FindChild("vipNode/vip2"):SetActive(false)
		end
	end	
end

--刷新一键部署
function BattleView:RefreshOneKeyStatus(isvip)
	if isvip then
		self:FindChild("btn_onepunch/lock"):SetActive(false)
	else
		self:FindChild("btn_onepunch/lock"):SetActive(true)
	end
end

--刷新onekey英雄选择
function BattleView:RefreshOneKeyHero(viplevel, isvip)
	local oneKeySetUi = self:FindChild("ZTD_nodeOneKey");
	local parent = oneKeySetUi:FindChild("frame/itemList_Hero/Viewport/Content")
	local arenaId = ZTD.PlayerData.GetRoomArenaID()
	local heroCfgs = ZTD.HeroConfig
	for k, v in pairs(heroCfgs) do
		local obj = parent:FindChild(v.id)
		local maskObj = obj:FindChild("mask")
		local newObj = obj:FindChild("new")
		local onlyoneObj = obj:FindChild("onlyone")
		if v.id == 1003 and viplevel < 3 then
			maskObj:SetActive(true)
			obj:FindChild("img_select"):SetActive(false);
			self._oneKeyHeros[tonumber(v.id)] = nil
			self:SaveOneKey()
		elseif v.id == 1004 and not isvip then
			maskObj:SetActive(true)
			obj:FindChild("img_select"):SetActive(false);
			self._oneKeyHeros[tonumber(v.id)] = nil
			self:SaveOneKey()
		elseif v.id == 1005 then
			newObj:SetActive(true)
			onlyoneObj:SetActive(true)
			if arenaId <= 1 then
				maskObj:SetActive(true)
				obj:FindChild("img_select"):SetActive(false)
				self._oneKeyHeros[v.id] = nil
			else
				maskObj:SetActive(false)
			end
		else
			maskObj:SetActive(false)
		end
	end
end

--更新地图分值
function BattleView:RefreshHeroPosCost(oldIsVip, newIsVip)
	-- log("RefreshHeroPosCost oldIsVip="..tostring(oldIsVip).."  newIsVip="..tostring(newIsVip))
	for yy, v in pairs(self._hero_pos) do
		for xx, heroPos in pairs(v) do
			local curCost = heroPos:GetCost()
			if oldIsVip ~= newIsVip then
				curCost = newIsVip and curCost - 1 or curCost + 1
				heroPos:ChangeCost(curCost)
			end
		end
	end
	ZTD.MainScene.RefreshMapCfgDatas(newIsVip)
end

--刷新VIP分级分值介绍选中状态
function BattleView:RefreshTotalCostSelect(viplevel)
	local tempVip = viplevel >= 4 and 3 or viplevel
	tempVip = viplevel == 3 and 2 or tempVip
	for i = 1, 3 do
		if i == tempVip then
			self._ui_cost_itemNode:FindChild(i.."/select"):SetActive(true)
		else
			self._ui_cost_itemNode:FindChild(i.."/select"):SetActive(false)
		end
	end 
end

--玩家等级和会员刷新
function BattleView:OnPlayerVipLevel(data)
	--log("OnPlayerVipLevel data="..GC.uu.Dump(data))
	if data.PlayerId == ZTD.PlayerData.GetPlayerId() then
		local oldVipLevel = ZTD.PlayerData.GetVipLevel()
		local oldIsVip = ZTD.PlayerData.GetIsVip()
		if data.IsVip and oldIsVip ~= data.IsVip then
			self:ReleaseCountDown()
		end
		ZTD.PlayerData.SetVipLevel(data.Level)
		ZTD.PlayerData.SetIsVip(data.IsVip)
		self:RefreshTotalCost(oldVipLevel, data.Level, oldIsVip, data.IsVip)
		self:RefreshOneKeyStatus(data.IsVip)
		self:RefreshOneKeyHero(data.Level, data.IsVip)
		self:RefreshHeroPosCost(oldIsVip, data.IsVip)
		self:RefreshTotalCostSelect(data.Level)
		self:ChangeHero(oldIsVip, data.IsVip)
		self:RefreshHeroLock()
		ZTD.Notification.GamePost(ZTD.Define.OnPushTrusteeshipBtn, data.Level)
	end
	self:RefreshPlayerItemVip(data.PlayerId, data.Level)
end

--推送巨龙令信息
function BattleView:OnDragonProps(data)
	-- log("OnDragonProps data = "..GC.uu.Dump(data))
	self:ReleaseCountDown()
	self._dragonUi:OnDragonProps(data)
end

function BattleView:_doEndTrusteeshipReq(cb)
	if ZTD.Flow.IsTrusteeship then
		local succCb = function(err, data)
			-- todo
			ZTD.Flow.IsTrusteeship = false;
			if cb then
				cb();
			end
		end

		local errCb = function(err, data)
			succCb();		
			logError("_______EndTrusteeship Error:" .. err)
		end

		ZTD.Request.CSEndTrusteeshipReq({Notify = true}, succCb, errCb);	
	else
		if cb then
			cb();
		end		
	end
end	

function BattleView:OnMore()
	self._isShowMore = not self._isShowMore;
	self:FindChild("top_right/bg_menu"):SetActive(self._isShowMore);
	ZTD.Notification.GamePost(ZTD.Define.MsgGuideOpenMenu, self, self:FindChild("top_right/bg_menu"));
	-- self._heroMenu:closeMenu()
end	

function BattleView:OnPlayerList(isShow)
	self:FindChild("top_left/sp_back"):SetActive(isShow);
	self:FindChild("top_left/ItemList_Player"):SetActive(isShow);	
	
	self:FindChild("top_left/btn_playerList/sp_playerList_on"):SetActive(not isShow);
	self:FindChild("top_left/btn_playerList/sp_playerList_off"):SetActive(isShow);
	
	if not self._posOldPlayerListsX then
		self._posOldPlayerListsX = self:FindChild("top_left/btn_playerList").localPosition.x;
	end	
	
	if isShow then
		local oldPos = self:FindChild("top_left/btn_playerList").localPosition;
		local newX = self:FindChild("top_left/sp_back").localPosition.x;
		self:FindChild("top_left/btn_playerList").localPosition = Vector3(newX, oldPos.y, oldPos.z);
		
		local oldPos2 = self:FindChild("top_left/txt_title").localPosition;
		self:FindChild("top_left/txt_title").localPosition = Vector3(oldPos2.x + 60, oldPos2.y, oldPos2.z);

		ZTD.Request.CSButtonRecordsReq({ID = 4001, Mode = 4});
	else
		local oldPos = self:FindChild("top_left/btn_playerList").localPosition;
		self:FindChild("top_left/btn_playerList").localPosition = Vector3(self._posOldPlayerListsX, oldPos.y, oldPos.z);		
		
		local oldPos2 = self:FindChild("top_left/txt_title").localPosition;
		self:FindChild("top_left/txt_title").localPosition = Vector3(oldPos2.x - 60, oldPos2.y, oldPos2.z);	

		ZTD.Request.CSButtonRecordsReq({ID = 4015, Mode = 4});
	end
end

function BattleView:InitMultiple()
	local groupId = ZTD.Flow.groupId
	self.MultipleInfo = ZTD.MultipleConfig[groupId]

    self.multipleStep = 1;

	for i,v in ipairs(self.MultipleInfo) do
		if ZTD.PlayerData.GetMultiple() == v then
			self.multipleStep = i;
			break;
		end
	end
	
    self.multiple = self.MultipleInfo[self.multipleStep]

    self.multiple1 = self:SubGet("multiple/multipleText", "Text")
    self.multipEffParent = self:FindChild("multiple/effParent")
    self:SetMultiple(0)

	self:AddClick("multiple/add", function()
        self:SetMultiple(1,true)		
		ZTD.Request.CSButtonRecordsReq({ID = 4005, Mode = 4});
		-- self._heroMenu:closeMenu()
    end, false)

	self:AddClick("multiple/dec", function()
        self:SetMultiple(-1,true)		
		ZTD.Request.CSButtonRecordsReq({ID = 4005, Mode = 4});
		-- self._heroMenu:closeMenu()
    end, false)
end

function BattleView:SetMultiple(add, playEff)
	local step = self.multipleStep + add
    local multipLength = #self.MultipleInfo
    if step > multipLength or step < 1 then
        if playEff then
            self:PlayMultipleChangeEff("TD_Effect_UI_BSZJSX")
        end

        return
    end

    local multi = self.MultipleInfo[step]
    self.multipleStep = step
    self.multiple = multi

	self.multiple1.text = self.multiple
    ZTD.PlayerData.SetMultiple(self.multiple)
	
    if playEff then
        self:PlayMultipleChangeEff("TD_Effect_UI_Beishuzengjia")
		-- 如果播放了特效，说明是玩家手动摁的，发送倍率保存请求
		ZTD.PlayerData.RadioReq();
        if add >= 0 then
            ZTD.PlayMusicEffect("ZTD_add_radio")
        else
            ZTD.PlayMusicEffect("ZTD_sub_radio")
        end		
    end	
end

function BattleView:PlayMultipleChangeEff(effPrefab)
    local effect, effectID = ZTD.EffectManager.PlayEffect(effPrefab, self.multipEffParent, true);
    effect.localPosition = Vector3.zero
    effect.localScale = Vector3.one
	effect:SetActive(false);
	effect:SetActive(true);
    self:DelayRun(1.5,function()
         ZTD.EffectManager.RemoveEffectByID(effectID)
    end)
end

function BattleView:ResetGoldDisplay()
	--[[
	
	ZTD.GoldPlay.Release()
	--ZTD.BombCoinManager.Release()
	--local skillMgr = ZTD.Flow.GetSkillMgr();
	--skillMgr:Release(true);	
	-- 重置圆盘重复格记录
	ZTD.MainScene.PanGirdData:Reset();
	
	ZTD.GoldData.SyncHoldGoldDatas();

	local playerId = ZTD.PlayerData.GetPlayerId();
	local nowGold = ZTD.TableData.GetData(playerId, "Money");
	local totalGold = ZTD.GoldData.Gold;
	totalGold:Set(nowGold);
	self:OnRefreshGold(nowGold);
	--]]
end	

function BattleView:_initUi()
	ZTD.GoldPlay.Release()
	--ZTD.BombCoinManager.Release()
	local skillMgr = ZTD.Flow.GetSkillMgr();
	skillMgr:Release(true);
	
	--[[
	--
	if ZTD.MainScene.WaitTipRoomInx then
		ZTD.Utils.CloseWaitTip(ZTD.MainScene.WaitTipRoomInx);
		ZTD.MainScene.WaitTipRoomInx = nil;
	end
	ZTD.MainScene.WaitTipRoomInx = ZTD.Utils.ShowWaitTipEx();
	--]]
	
	if self._autoUpTable then
		for _, v in ipairs(self._autoUpTable) do
			ZTD.Extend.StopAction(v.act);
			ZTD.EffectManager.RemoveEffectByID(v.trailID)
			v.trail:SetActive(false);
			if v.put_show and v.put_showID then
				ZTD.EffectManager.RemoveEffectByID(v.put_showID)
				v.put_show:SetActive(false);
			end	
		end
		self._autoUpTable = nil;
	end	
	
	local cfg = ZTD.ConstConfig[1];
	self:InitMultiple();
	-- 重置圆盘重复格记录
	ZTD.MainScene.PanGirdData:Reset();
	-- 重置龙进度条和数据
	self._dragonUi:Reset();
	-- 重置夜王相关
	self._ghostUi:Reset();
	--重置巨人相关
	self.gaintUi:Reset()	
	--重置封印相关
	self.SealUi:Reset()
	-- 进房间 重置攻击链树状记录
	ZTD.ComboShowTree.Reset();
	-- 重置毒爆怪奖牌
	ZTD.PoisonMedalMgr.ReleaseAll();

	-- 底部分值提示
	local btn_cost_tip = self:FindChild("bottom2/btn_cost_tip");
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	self:AddClick(btn_cost_tip, function()
		self._ui_cost_dialog_txt.text = language.cost_tip;
		if self._ui_cost_dialog_act then
			ZTD.Extend.StopAction(self._ui_cost_dialog_act);
			self._ui_cost_dialog_act = nil;
		end
		if self._ui_cost_itemNode_act then
			ZTD.Extend.StopAction(self._ui_cost_itemNode_act);
			self._ui_cost_itemNode_act = nil;
		end
		self._ui_cost_dialog:SetActive(true);
		self._ui_cost_itemNode:SetActive(true)
		self._ui_cost_dialog_act = ZTD.Extend.RunAction(self._ui_cost_dialog, 
						{{"fadeToAll", 255, 0},
						{"delay", 1},
						{"fadeToAll", 0, 1},
						onEnd = function()
							self._ui_cost_dialog:SetActive(false);
							self._ui_cost_dialog_act = nil;
						end})	
		self._ui_cost_itemNode_act = ZTD.Extend.RunAction(self._ui_cost_itemNode, 
						{{"fadeToAll", 255, 0},
						{"delay", 1},
						{"fadeToAll", 0, 1},
						onEnd = function()
							self._ui_cost_itemNode:SetActive(false)
							self._ui_cost_itemNode_act = nil;
						end})	
		-- self._heroMenu:closeMenu()
	end);
	
	--左上角玩家列表
	local btn_playerList = self:FindChild("top_left/btn_playerList");
	
	-- 玩家列表
	local function warpFunc(info)
		self:_createPlayerItem(info);
	end
	ZTD.TableData.WarpInfo(warpFunc);
	

	self:AddClick(btn_playerList, function()
		self._isShowPlayerList = not self._isShowPlayerList;
		self:OnPlayerList(self._isShowPlayerList);	
		-- self._heroMenu:closeMenu()
	end);
	
	self:AddClick("top/btn_add", function()
		local playerId = ZTD.PlayerData.GetPlayerId();
		local param = {
			ChouMa = ZTD.TableData.GetData(playerId, "Money"),
			Integral = GC.SubGameInterface.GetHallIntegral(),
		}
		GC.SubGameInterface.ExOpenShop(param)
		ZTD.Request.CSButtonRecordsReq({ID = 4014, Mode = 4});
		-- self._heroMenu:closeMenu()
	end);

	--左下角大厅活动
	self.giftNode = self:FindChild("leftGridNode/selectGiftNode")
	self.freeChipsNode = self:FindChild("leftGridNode/FreeChipsNode")
	self.monthRankNode = self:FindChild("leftGridNode/RankNode")
	-- self.shakeNode = self:FindChild("leftGridNode/ShakeNode")

	local gameData = ZTD.MJGame.gameData
	--创建礼包
	self.giftIcon = GC.SubGameInterface.CreateSelectGiftCollectionIcon(
		{
			parent = self.giftNode, 
			SelectGiftTab = 
				{"BrokeGiftView",
				"AchievementGiftMainView",
				"LuckyTurntableView",
				"TreasureBoxGiftView", 
				"NoviceGiftView", 
				"FundView", 
				"VipThreeCardView"},
			currentView = "DailyGiftZombie",
		})
	--创建免费筹码
	self.freeChipsIcon = GC.SubGameInterface.CreateFreeChipsCollectionIcon({parent = self.freeChipsNode})
	--创建排行榜
	self.monthRankIcon = GC.SubGameInterface.CreateMonthRankIcon({parent = self.monthRankNode, id = gameData.GameID})
	if not self.monthRankIcon then
		self.monthRankNode:SetActive(false)
	end
	--创建暗补
	-- self.shakeIcon = GC.SubGameInterface.CreateShake(self.shakeNode,5,gameData.GameID)
	--调整暗补特效
	-- local ps = self.shakeIcon:FindChild("cs_hd_rktb/Particle System")
	-- for i = 0, 2 do
	-- 	ps:GetChild(i).localScale = Vector3(0.2, 0.2, 0.2)
	-- end

	-- 右上角下拉滑条
	local btnMore = self:FindChild("top_right/btn_more");
	local btn_room = self:FindChild("top_right/bg_menu/btn_room");
	local btn_help = self:FindChild("top_right/bg_menu/btn_help");
	local btn_set = self:FindChild("top_right/bg_menu/btn_set");
	local btn_exit = self:FindChild("top_right/bg_menu/btn_exit");
	
	self._isShowMore = false;
	self:AddClick(btnMore, "OnMore", "ZTD_menu_open");
	self._isShowMore = false;
	self:FindChild("top_right/bg_menu"):SetActive(self._isShowMore);
	self:AddClick(btn_set, function() self:OnSet();  ZTD.Request.CSButtonRecordsReq({ID = 4011, Mode = 4}); end);
	self:AddClick(btn_help, function() self:OnHelp();  ZTD.Request.CSButtonRecordsReq({ID = 4012, Mode = 4}); end);
	self:AddClick(btn_exit, function() 
		
		local succCb = function(err, data)
			
			log("succ data="..GC.uu.Dump(data))
			local sealValue = data.Seal
			local sealMoney = data.Money
			local isSelf = (data.PlayerId == ZTD.PlayerData.GetPlayerId())
			if sealValue > 0 then
				local callFunc = function()
					self:OnExit();  
					ZTD.Request.CSButtonRecordsReq({ID = 4010, Mode = 4});
				end
				ZTD.Notification.GamePost(ZTD.Define.OnPushSealConvertMoney, isSelf, sealValue, sealMoney, callFunc)
			else
				self:OnExit();  
				ZTD.Request.CSButtonRecordsReq({ID = 4010, Mode = 4});
			end
		end
		local errCb = function(err, data)
			logError("err="..tostring(err))
		end
		ZTD.Request.CSSealConvertMoneyReq(succCb, errCb)
	 end);
	--self:AddClick(btn_room, function() self:OnChangeRoom();  ZTD.Request.CSButtonRecordsReq({ID = 4013, Mode = 4}); end);
	self:AddClick(btn_room, function() 
		
		local succCb = function(err, data)
			
			log("succ data="..GC.uu.Dump(data))
			local sealValue = data.Seal
			local sealMoney = data.Money
			local isSelf = (data.PlayerId == ZTD.PlayerData.GetPlayerId())
			if sealValue > 0 then
				local callFunc = function()
					self:OnChangeRoom()
					ZTD.Request.CSButtonRecordsReq({ID = 4013, Mode = 4})
				end
				ZTD.Notification.GamePost(ZTD.Define.OnPushSealConvertMoney, isSelf, sealValue, sealMoney, callFunc)
			else
				self:OnChangeRoom()
				ZTD.Request.CSButtonRecordsReq({ID = 4013, Mode = 4})
			end
		end
		local errCb = function(err, data)
			logError("err="..tostring(err))
		end
		ZTD.Request.CSSealConvertMoneyReq(succCb, errCb)
	end);
	-- 右下角按钮区
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	local btn_select = self:FindChild("btn_select");
	self:FindChild("btn_select/txt_ (1)").text = language.txt_btn_select;
	local btn_trusteeship = self:FindChild("btn_trusteeship");
	local btn_autoBattle = self:FindChild("btn_autoBattle");
	self.lockIcon = self:FindChild("btn_autoBattle/lockNode")
	self.lockIcon:SetActive(false)
	local btn_history = self:FindChild("btn_history");

	self:FindChild("btn_history/txt_").text = self.language.btn_history
	self:FindChild("btn_trusteeship/txt_tips_on").text = self.language.btn_trusteeship
	self:FindChild("btn_trusteeship/txt_tips_off").text = self.language.btn_trusteeship
	self:FindChild("btn_autoBattle/text").text = self.language.btn_autoBattle
	self:FindChild("top_left/txt_title").text = self.language.txt_title

	-- 选择怪物
    self:AddClick(btn_select, function()
		self:OnSelectView();
		-- self._heroMenu:closeMenu()
    end )   
    
    --NFT系统
    -- self:AddClick(self:FindChild("btn_nft"), function()
    --     self:OpenNFT()
	-- 	--ZTD.Request.CSButtonRecordsReq({ID = 4007, Mode = 4});
    -- end ) 
    -- 挂机
    self:AddClick(btn_trusteeship, function()
        self:OnTrusteeship();
		ZTD.Request.CSButtonRecordsReq({ID = 4007, Mode = 4});
		-- self._heroMenu:closeMenu()
    end )   
    -- 
    local effect_tt = self:FindChild("btn_trusteeship/Effect_UI_Gjzs_rktb");
    effect_tt:SetActive(false);
    local txt_trusteeship_count = self:FindChild("btn_trusteeship/txt_tips_on");
    txt_trusteeship_count:SetActive(false);    
    self:FindChild("btn_trusteeship/txt_tips_off"):SetActive(true);	
	
	-- 自动攻击
	self._isAutoBattle = false;
	self:AddClick(btn_autoBattle, function ()
		-- 如果自己点击时候没有上阵英雄，提示
		if next(self._nowHeroHps) == nil then
			ZTD.ViewManager.ShowTip(language.trusteeProtectTip2);
			return;
		end	
		
		self:SetAutoBattle(not self._isAutoBattle);
		
		-- 如果是自己关闭掉自动攻击的，结束挂机
		if self._isAutoBattle == false then
			self:_doEndTrusteeshipReq();
		end	
		-- self._heroMenu:closeMenu()
	end);
	
	if self._historyCoName then
		self:StopTimer(self._historyCoName);
		self._historyCoName = nil;
	end
	self:ResetHistoryTrend();

	-- 趋势图
	self._isShowHistoryTrend = false;
	self._maxMoneyEarn = nil;
	self._maxMoneyList = {};
	self._maxMoneyList[1] = 0;
	self:AddClick(btn_history, "OnHistoryTrend");
	self._historyCoName = "historyCount";
	self:StartTimer(self._historyCoName, cfg.TrendCd, function() self:DoHistoryRecord() end, -1);

	-- 金币柱
	self._goldPillar:Init(self:FindChild("node_gold_pilar"), self);
	
	-- 其他text控件
	self._ui_roomId = self:FindChild("top_right/txt_room");
	self._ui_myGold = self:FindChild("top/txt_gold");
	self._ui_myWin = self:FindChild("top/txt_gold_change_win");
	self._ui_myLose = self:FindChild("top/txt_gold_change_lose");
	self._ui_myWin:SetActive(false);
	self._ui_myLose:SetActive(false);
	
	self._ui_cost = self:FindChild("bottom2/txt_cost");
	self._ui_cost_tips = self:FindChild("bottom2/txt_cost_tips");
	self._ui_cost_dialog = self:FindChild("bottom2/dialog_tips");
	self._ui_cost_itemNode = self:FindChild("bottom2/itemNode");
	self._ui_cost_dialog_txt = self:FindChild("bottom2/dialog_tips/Text");
	
	self._ui_cost_up = self:FindChild("bottom2/Effect_L_UIliang_1");
	self._ui_cost_down = self:FindChild("bottom2/Effect_L_UIliang_2");
	
	local tableId = ZTD.TableData.GetTable();
	local playerId = ZTD.PlayerData.GetPlayerId();
	self._ui_roomId.text = tableId;
	self._var_roomId = tableId;
	local nowGold = ZTD.TableData.GetData(playerId, "Money");
	local totalGold = ZTD.GoldData.Gold;
	totalGold:Set(nowGold);
	self._roomGold = nowGold;	
	self:OnRefreshGold(nowGold);
	self:OnRefreshGoldEarn(0);
	self.curtotalscore = self:GetTotalScore()
	self._ui_cost.text = self.curtotalscore
	self:RefreshTotalCostSelect(ZTD.PlayerData.GetVipLevel())
	self:CheckCostStatus();
	
	self._heroMenu:Close();
	self:ReleaseCountDown();
	
	for yy, v in pairs(self._hero_pos) do
		for xx, heroPos in pairs(v) do
			heroPos:CloseHeroRange();
		end
	end
end

--获取总分值
function BattleView:GetTotalScore()
	local mapCfg = ZTD.MapConfig[self._mapId]
	local viplevel = ZTD.PlayerData.GetVipLevel()
	local totalscore = nil
	if viplevel > 4 then 
		totalscore = 20
	elseif viplevel < 0 then
		totalscore = 0
	elseif viplevel == 0 then --根据策划需求，增加一个条件供测试使用，正式服不存在该情况
		totalscore = 10
	else
		totalscore = mapCfg.TotalScore[viplevel].score
	end
	return totalscore
end

--设置手动锁怪开启怪物图标显示
function BattleView:SetLockIcon(enemyId, IsConnect)
	if not enemyId then
		self.lockIcon:SetActive(false)
	else
		local info = ZTD.MainScene.GetEnemyCfg(enemyId)
		-- logError("info="..GC.uu.Dump(info))
		local icon = IsConnect and "ZTD_monster_10007" or info.icon
		self.lockIcon:FindChild("mask/lockIcon"):GetComponent("Image").sprite = ResMgr.LoadAssetSprite("prefab", icon)
		self.lockIcon:SetActive(true)
	end
	
end

-- 开启挂机的事件回调
function BattleView:OnTrustOn()
	self:SetAutoBattle(true);
	
    local effect_tt = self:FindChild("btn_trusteeship/Effect_UI_Gjzs_rktb");
    local txt_trusteeship_count = self:FindChild("btn_trusteeship/txt_tips_on");
    local txt_tips_off = self:FindChild("btn_trusteeship/txt_tips_off");
    txt_trusteeship_count:SetActive(true);
    effect_tt:SetActive(true);
    txt_tips_off:SetActive(false);
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
    local counting = function()
        if ZTD.Flow.IsTrusteeship then
            if ZTD.Flow.TrusteeLeftTime and ZTD.Flow.TrusteeLeftTime >= 0 then
                ZTD.Flow.TrusteeLeftTime = ZTD.Flow.TrusteeLeftTime - 1;
                local timeStr = tools.TicketFormat(ZTD.Flow.TrusteeLeftTime);
                txt_trusteeship_count.text = timeStr;
            else
                local tStr = language.place_play;
                if not self.__ttConutDownHelper then
                    self.__ttConutDownHelper = 4;
                end

                self.__ttConutDownHelper = self.__ttConutDownHelper - 1;
                if self.__ttConutDownHelper == 0 then
                    self.__ttConutDownHelper = 3;
                end
                if self.__ttConutDownHelper == 3 then
                    tStr = tStr .. "...";
                elseif self.__ttConutDownHelper == 2 then
                    tStr = tStr .. "..";
                elseif self.__ttConutDownHelper == 1 then
                    tStr = tStr .. ".";
                end
                txt_trusteeship_count.text = tStr;
            end
        else
            txt_trusteeship_count:SetActive(false);
            effect_tt:SetActive(false);
            txt_tips_off:SetActive(true);
            ZTD.GameTimer.StopTimer(self.co_countDownTrusteeLeftTime);
            self.co_countDownTrusteeLeftTime = nil;
        end
    end

    if (self.co_countDownTrusteeLeftTime) then
        ZTD.GameTimer.StopTimer(self.co_countDownTrusteeLeftTime);
    end

    counting();
    self.co_countDownTrusteeLeftTime = ZTD.GameTimer.StartTimer( function()
        counting();
    end , 1, -1)
end 

function BattleView:ResetHistoryTrend()
	ZTD.TrendDraw.Reset(self:FindChild("node_history"));
end

function BattleView:DoHistoryRecord()
	self._maxMoneyList[#self._maxMoneyList + 1] = self._maxMoneyEarn;
	self._maxMoneyEarn = nil;
	ZTD.TrendDraw.DealRecordOver(self._maxMoneyList);
	ZTD.TrendDraw.Draw(self:FindChild("node_history"), self._maxMoneyList);
end

function BattleView:OnHistoryTrend()
	self._isShowHistoryTrend = not self._isShowHistoryTrend;
	if self._isShowHistoryTrend then
		ZTD.TrendDraw.Open(self:FindChild("node_history"), self);
		ZTD.TrendDraw.Draw(self:FindChild("node_history"), self._maxMoneyList);		
		ZTD.Notification.GamePost(ZTD.Define.HistoryTrend, false)
		ZTD.Request.CSButtonRecordsReq({ID = 4009, Mode = 4});
	else	
		ZTD.Notification.GamePost(ZTD.Define.HistoryTrend, true)
		ZTD.TrendDraw.Close(self:FindChild("node_history"));
	end
	-- self._heroMenu:closeMenu()
end

function BattleView:OnSelectView()	
	ZTD.ViewManager.OpenMessageBox("ZTD_EnemySelectView")
	ZTD.Request.CSButtonRecordsReq({ID = 4017, Mode = 4});
end

function BattleView:CreateNFTCard(id,parent)	
	self.cardList = self.cardList or {}
	local data = ZTD.NFTData.GetCard(id)
	local card = ZTD.NFTCard:new(data, parent)
	self.cardList[card.id] = card
	return card
end
function BattleView:RemoveNFTCard(id)	
	if self.cardList[id] then
		self.cardList[id]:Release()
		self.cardList[id] = nil
	end
end
function BattleView:RemoveAllNFTCard()	
	for _,v in pairs(self.cardList) do
		v:Release()
	end
	self.cardList = {}
end

--nft卡片掉落
function BattleView:OnPushDropCard(data)
	--log("OnPushDropCard:"..GC.uu.Dump(data))
	if self.nftView then
		return
	end
	--GC.Sound.PlayEffect("ZTD_card_drop")
	ZTD.NFTData.NewCard(data)
	ZTD.Flow.hasNewCard = true
	self:FindChild("btn_nft/ImageRed"):SetActive(true)
	local enemyMgr = ZTD.Flow.GetEnemyMgr()
	local tgEnemey = enemyMgr._ctrlList[data.PositionID]
	if not tgEnemey then
		logError("！！！ can not find enemy")
		return
	end
	local eobj = tgEnemey:getEnemyObj()
	local orgPos = eobj.transform.position
	orgPos = ZTD.MainScene.SetupPos2UiPos(orgPos)

	local eff,id = self:PlayEff("TD_DropCard",self.transform)
	eff.position = orgPos
	local vecOne = Vector3.one
	eff.localScale = Vector3(0.01,0.01,0.01)
	
	GC.Sound.PlayEffect("ZTD_card_drop2")
	local scale = {"scaleTo", 1.5, 1.5, 1.5, 0.2, ease = ZTD.Action.EOutQuad}
	local scale2 = {"scaleTo", 1, 1, 1, 0.05, ease = ZTD.Action.EOutQuad}
	local delay = {"delay",0.1, onEnd=function ()
		GC.Sound.PlayEffect("ZTD_card_drop2")
		--eff:FindChild("TD_Effect_qkl02"):Show()
		local card = self:CreateNFTCard(data.ID, eff:FindChild("Card"))
		--card:SetCameraSize(3)
	end}
	local delay2 = {"delay",0.1, onEnd=function ()
		local eff3 = eff:FindChild("TD_Effect_qkl03")
		ZTD.Extend.TrailRendererClear(eff3)
		eff3:Show()
	end}
	
	local delay3 = {"delay",2.5, onEnd=function ()
		local targetPos = self:FindChild("btn_nft").localPosition
		local dis = Vector3.Distance(orgPos, targetPos)
		--logError("dis:".. dis)
		local durationTo = dis/1000 --金币去到目标点的总时间
		local move = {"localMoveTo", targetPos.x, targetPos.y, targetPos.z,
			durationTo, --ease = ZTD.Action.EOutQuad,
			onEnd = function ()
				self:RemoveNFTCard(data.ID)
				self:RemoveEff(id)
				GC.Sound.PlayEffect("ZTD_card_drop")
			end}
		local scale = {"scaleTo", 0.4, 0.4, 0.4, durationTo, ease = ZTD.Action.EOutQuad}
		
		ZTD.Extend.RunAction(eff, move)
		ZTD.Extend.RunAction(eff, scale)
	end}
	ZTD.Extend.RunAction(eff, {scale,scale2,delay,delay2,delay3})
end

--请求一次nft配置
function BattleView:SetNFTCD(time)	
	self:FindChild("btn_nft/ImageCD"):Show()
	local str = GC.uu.TicketFormat2(time)
	self.nftCDText = self:GetCmp("btn_nft/ImageCD/Text", "Text")
	self.nftCDText.text = str
	self:StopTimer("NFTCountDown")
	self:StartTimer("NFTCountDown", 1, function ()
		time = time - 1
		if time <= 0  then
			self:StopTimer("NFTCountDown")
			return
		end
		local str = GC.uu.TicketFormat2(time)
		self.nftCDText.text = str
	end, 999999999)
end
--请求一次nft配置
function BattleView:ReqNFTConfig()	
	ZTD.Request.HttpRequest("ReqNFTConfig", {
	
	}, function (data)
		local stamp = Util.GetTimeStamp(true)
		local time = data.season_pool_start_stamp - stamp
		if time > 0 then--下个赛季还没开放
			self:SetNFTCD(time)	
		else
			self:FindChild("btn_nft/ImageCD"):Hide()
			return
		end
		
		
	end, function ()
		
	end, false)
end
--NFT系统界面
function BattleView:OpenNFT()	
	
	ZTD.Request.HttpRequest("ReqNFTConfig", {
	
	}, function (data)
		local stamp = Util.GetTimeStamp(true)
		
		if data.season_pool_start_stamp < stamp and data.season_pool_end_stamp > stamp then
			self:FindChild("btn_nft/ImageCD"):Hide()
			self:FindChild("btn_nft/ImageRed"):SetActive(false)
			self:SetAutoBattle(false)
			ZTD.NFTData.Init()
			-- log("===== ReqNFTConfig === "..GC.uu.Dump(data)) 
			-- log("===== day_pool_end_stamp === "..CC.uu.TimeOut5(data.day_pool_end_stamp))
			-- log("===== season_pool_end_stamp === "..CC.uu.TimeOut5(data.season_pool_end_stamp))
			if data.cards and #data.cards then
				ZTD.NFTConfig.setGradeConfig(data.cards)
			else
				log("===== ReqNFTConfig cards === null "..GC.uu.Dump(data)) 
			end
			self.nftView = ZTD.ViewManager.Open("ZTD_NFTView", data, function ()
				self.nftView = nil
			end)
		elseif data.season_pool_start_stamp > stamp then
			self:SetNFTCD(data.season_pool_start_stamp - stamp)	
			ZTD.ViewManager.ShowTip(self.lan.seasonNotOpen)
		else
			ZTD.ViewManager.ShowTip(self.lan.seasonNotOpen)
		end
	end, function ()
		ZTD.ViewManager.ShowTip(self.lan.getNFTConfigErr)
	end, true)
	
	ZTD.Request.CSButtonRecordsReq({ID = 4017, Mode = 4});
end

function BattleView:OnSet()	
	ZTD.ViewManager.OpenMessageBox("ZTD_PauseView")
end

function BattleView:OnHelp()	
	ZTD.ViewManager.OpenMessageBox("ZTD_HelpView")
end

function BattleView:CleanMyHeroLock()
	-- 清空当前锁定
	for nm, _ in pairs(self._nowHeroHps) do
		nm:CleanLock();
		ZTD.TableData.SetLockTarget(nm._posId, nil);
	end
end

function BattleView:OnTrusteeship()
	local succCb = function(err,data)
		ZTD.ViewManager.OpenMessageBox("ZTD_TrusteeshipView", data)
	end

	local errCb = function(err,data)
		logError("_______OnTrusteeship Error:"..err)
	end
	
	ZTD.Request.CSGetTrusteeshipReq(succCb, errCb)
end	

function BattleView:SetAutoBattleUi(isAuto)
	self._isAutoBattle = isAuto;
	local eff_auto = self:FindChild("btn_autoBattle/gou");
	eff_auto:SetActive(isAuto);
	
	if isAuto == true then
		ZTD.Notification.GamePost(ZTD.Define.MsgGuideBattleView, self);
	end	
end
	
function BattleView:SetAutoBattle(isAuto, waitCb, forceSet)
	self:SetAutoBattleUi(isAuto);
	local posIds = {}
	for nm, _ in pairs(self._nowHeroHps) do
		posIds[#posIds + 1] = nm._posId;
	end
	
	local function _setAuto()
		if isAuto and self.endTrusteeship then return end
		for nm, _ in pairs(self._nowHeroHps) do
			if isAuto then
				nm:BeginCb();
			else	
				nm:PauseCb();
				ZTD.TableData.SetLockTarget(nm._posId, nil);
				ZTD.TableData.SetReadyLockTarget(nm.posId, ZTD.TableData.NullTarget);					
			end
		end		
	end
	
	-- 如果强制设置，不等回调就立刻执行
	if forceSet then
		_setAuto();
	end	
	
	if next(posIds) then
		local function reqCb()
			ZTD.Request.CSButtonRecordsReq({ID = 4006, Mode = 4});
			if waitCb then
				waitCb();
			end
			
			if not forceSet then
				_setAuto();
			end	
		end
		self:_reqAtk(posIds, isAuto, reqCb);
	else
		if waitCb then
			waitCb();
		end
	end
end

function BattleView:_createPlayerItem(info)
	if self._playerItems[info.PlayerId] then
		return;
	end
	local playerListParent = self:FindChild("top_left/ItemList_Player/Viewport/Content");	
	local item = ZTD.PoolManager.GetUiItem("ZTD_NodeTablePlayer", playerListParent);
	local pMoney = info.Money;
	local pName  = info.Name;
	local winMoney = info.MoneyVariation;
	local preMoney = item:FindChild("node_win/txt_gold_change").text
	local nowMoney = ZTD.Extend.FormatNumber(math.abs(winMoney))
	local preTotalMoney = item:FindChild("txt_total").text
	local nowTotalMoney = tools.numberToStrWithComma(pMoney)
	if preMoney ~= winMoney then
		nowMoney = preMoney
	end
	if preTotalMoney ~= nowTotalMoney then
		nowTotalMoney = preTotalMoney
	end
	if self:FindChild("top/txt_gold_change_win").activeSelf then
		item:FindChild("node_win"):SetActive(true)
		item:FindChild("node_lose"):SetActive(false)
	else
		item:FindChild("node_win"):SetActive(false)
		item:FindChild("node_lose"):SetActive(true)
	end
	if info.PlayerId == ZTD.PlayerData.GetPlayerId() then
		--用于修复自己玩家切后台列表金币显示错误问题
		item:FindChild("txt_name").text = pName;
		item:FindChild("node_win/txt_gold_change").text = "+"..ZTD.Extend.FormatNumber(ZTD.Extend.StrToNum(self:FindChild("top/txt_gold_change_win").text))
		item:FindChild("node_lose/txt_gold_change").text =  "-"..ZTD.Extend.FormatNumber(ZTD.Extend.StrToNum(self:FindChild("top/txt_gold_change_lose").text))
		item:FindChild("txt_total").text = tools.numberToStrWithComma(pMoney)
	else
		item:FindChild("txt_name").text = pName;
		item:FindChild("node_win/txt_gold_change").text = nowMoney
		item:FindChild("node_lose/txt_gold_change").text = nowMoney
		item:FindChild("txt_total").text = nowTotalMoney
	end
	if info.VipLevel > 9 and info.VipLevel < 100 then
		item:FindChild("vipNode/img2"):SetActive(true)
		item:FindChild("vipNode/img3"):SetActive(true)
		item:FindChild("vipNode/vip1"):SetActive(true)
		item:FindChild("vipNode/vip2"):SetActive(true)
		item:FindChild("vipNode/vip1"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "V_"..info.VipLevel/10);
		item:FindChild("vipNode/vip2"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "V_"..info.VipLevel%10);
	elseif info.VipLevel < 10 and info.VipLevel > 0 then
		item:FindChild("vipNode/img2"):SetActive(true)
		item:FindChild("vipNode/img3"):SetActive(true)
		item:FindChild("vipNode/vip1"):SetActive(true)
		item:FindChild("vipNode/vip2"):SetActive(false)
		item:FindChild("vipNode/vip1"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "V_"..info.VipLevel);
	else
		item:FindChild("vipNode/img2"):SetActive(false)
		item:FindChild("vipNode/img3"):SetActive(false)
		item:FindChild("vipNode/vip1"):SetActive(false)
		item:FindChild("vipNode/vip2"):SetActive(false)
	end
	
	local iconHead = item:FindChild("mask/icon_head")
	GC.SubGameInterface.SetHeadIcon(info.Head, iconHead, info.PlayerId)
	if info.PlayerId == ZTD.PlayerData.GetPlayerId() then
		ZTD.PlayerData.SetVipLevel(info.VipLevel)
		ZTD.PlayerData.SetIsVip(info.IsVip)
	end
	
	self._playerItems[info.PlayerId] = item;	
end

function BattleView:_updatePlayerItemMoney(playerId, moneyChange, totalMoney)
	if self._playerItems[playerId] then
		local item = self._playerItems[playerId];
		
		item:FindChild("node_win"):SetActive(moneyChange > 0);
		item:FindChild("node_lose"):SetActive(moneyChange <= 0);

		item:FindChild("node_win/txt_gold_change").text = "+" .. GC.uu.NumberFormat(moneyChange);
		item:FindChild("node_lose/txt_gold_change").text = "-" .. GC.uu.NumberFormat(math.abs(moneyChange));	
		item:FindChild("txt_total").text = totalMoney and tools.numberToStrWithComma(totalMoney) or tools.numberToStrWithComma(ZTD.TableData.GetData(playerId, "Money"));
	end	
end

function BattleView:_initTowers()	
	local cfg = ZTD.ConstConfig[1];	
	local mapInfo = ZTD.MainScene.GetMapInfo();
	self._hero_pos = {};
	for groupInx, pointList in ipairs(mapInfo.setup) do		
		self._hero_pos[groupInx] = {};
		for setupInx, setupPos in ipairs(pointList) do
			local heroPos = ZTD.HeroPos:new();
			heroPos:Init(groupInx, setupInx, setupPos, self);
			self._hero_pos[groupInx][setupInx] = heroPos;
		end
	end
end

function BattleView:ChangeHeroPos(srcPosGS, dstPosGS, reqPlayerId)
	
	local srcHeroPos = self._hero_pos[srcPosGS.gi][srcPosGS.si];
	local dstHeroPos = self._hero_pos[dstPosGS.gi][dstPosGS.si];

	
	-- 记录原来的英雄id
	local srcHero = srcHeroPos:GetHeroCtrl();
	local srcHeroId = srcHero._cfg.id;
	local srcPlayerId = srcHero._playerId;
	local srcUuid = srcHero._uuid;
	local isSrcAtk = srcHero:isAutoPlayAtk();
	
	-- 下阵原来的	
	self:_downHero(srcHeroPos, true);
	
	-- 上阵到目标点
	local dstHeroCtrl = dstHeroPos:GetHeroCtrl();
	local dstHeroId;
	local dstUuid;
	local isDstAtk = false;
	local dstPlayerId;
	if dstHeroCtrl then
		isDstAtk = dstHeroCtrl:isAutoPlayAtk();
		dstPlayerId = dstHeroCtrl._playerId;
		dstHeroId = dstHeroCtrl._cfg.id;
		dstUuid = dstHeroCtrl._uuid;
	end
	
	local changeCost = 0;
	-- 如果目标点有英雄，也要进行下阵
	if dstHeroId then
		self:_downHero(dstHeroPos, true);
		changeCost = changeCost + dstHeroPos._cost;
		self:_upHero(srcHeroPos, isDstAtk, dstPlayerId, dstHeroId, dstUuid);
		changeCost = changeCost - srcHeroPos._cost;
	end
	
	self:_upHero(dstHeroPos, isSrcAtk, srcPlayerId, srcHeroId, srcUuid);
	
	if reqPlayerId == ZTD.PlayerData.GetPlayerId() then
		changeCost = changeCost - dstHeroPos._cost;
		if changeCost ~= 0 then
			self:OnCostChange(changeCost);
		end
	end
end	

function BattleView:_reqHero(positionId, heroId, isLeave, cbFunc, showInx)
	
    local succCb = function(err,data)
		self._nodeSummon:SetActive(false);
		ZTD.Notification.GamePost(ZTD.Define.MsgGuideDoneSummonHero, self);
		if cbFunc then
			-- logError("--------------------------HeroId:" .. data.UniqueId);
			cbFunc(heroId, ZTD.PlayerData.GetPlayerId(), data.UniqueId);
		end		
    end

    local errCb = function(err,data)
		-- logError("------------------------------CSTowerUpdateHeroReq error:" .. tostring(err))
		local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig")
		ZTD.ViewManager.ShowTip(language[err])
    end
	
	local param = {};
	param.Info = {};
	param.Info.HeroId = heroId;
	param.Info.PositionId = positionId;
	param.Leave = isLeave;
	--log("param="..GC.uu.Dump(param))
	
	ZTD.Request.CSTowerUpdateHeroReq(param, succCb, errCb);	
end

function BattleView:_reqAtk(positionId, isAtk, cbFunc)

    local succCb = function(err,data)
		self._heroMenu:SetAtkUi(isAtk);
		if cbFunc then
			cbFunc();
		end
    end

    local errCb = function(err,data)
        logError("------------------------------_reqAtk_reqAtk_reqAtk error:" .. tostring(err))
    end
	
	local param = {};
	param.Info = {};
	
	if type(positionId) ~= "table" then
		local atkInfo = {};
		atkInfo.HeroPositionId = positionId;
		atkInfo.IsAtk = isAtk;	
		param.Info[1] = atkInfo;
	else
		for _, v in pairs(positionId) do
			local atkInfo = {};
			atkInfo.HeroPositionId = v;
			atkInfo.IsAtk = isAtk;	
			param.Info[#param.Info + 1] = atkInfo;
		end
	end
	
	ZTD.Request.CSTowerHeroAtkInfoReq(param, succCb, errCb);		
end	

-- 英雄上场回调
-- groupInx竖排坐标
-- setupInx横排坐标
-- heroId英雄配置id，为0则代表下场
-- playerId玩家id
-- isDefaultHeroData是否使用默认构造的英雄数据
-- uuid
function BattleView:SetHeroOnScene(groupInx, setupInx, heroId, playerId, isDefaultHeroData, uuid)
	local heroPos = self._hero_pos[groupInx][setupInx];
	
	if heroId ~= 0 then
		heroPos:SummonCb(heroId, playerId, uuid);
		if heroPos._playerId == ZTD.PlayerData.GetPlayerId() then
			self._nowHeroHps[heroPos] = true;
		end	
		
		if not isDefaultHeroData then
			-- 构造player table的heroinfo结构
			local hd = {};
			hd.IsAtk = false; --默认false
			hd.HeroId = heroId;
			hd.PositionId = ZTD.MainScene.HeroGS2PosId(groupInx, setupInx);
			
			ZTD.TableData.UpdateHeroInfo(playerId, hd.PositionId, hd);
		end
	else
		if heroPos._playerId == ZTD.PlayerData.GetPlayerId() then
			self._nowHeroHps[heroPos] = nil;
			heroPos:CloseHeroRange();
			self._heroMenu:Close();
		end			
		heroPos:CancelCb();
	end
end

function BattleView:_dealExit()
	-- 清空锁定
	ZTD.MainScene.SetPlayerLockTarget();

	-- 退出时先停止攻击
	for nm, _ in pairs(self._nowHeroHps) do
		nm:PauseCb();
	end

	self:CleanMyHeroLock();

	self:_doEndTrusteeshipReq();
end

function BattleView:OnExit()
	local goNewRoom = function()
		self:_dealExit();
		--发送退场消息
		ZTD.Notification.GamePost(ZTD.Define.MsgDoExit, {isChangeArena = true});
	end
	if ZTD.Flow.IsTrusteeship then
		self._trustCb = goNewRoom;
		self:_doEndTrusteeshipReq()
	else	
		goNewRoom()
	end
end

function BattleView:OnDestroy()	
	self:RemoveAllNFTCard()
	self:StopTimer("SkipGroupCountDown")

	self:StopTimer("CoolCountDown")

	-- GC.SubGameInterface.DestryShake(self.shakeIcon)
	GC.SubGameInterface.DestroyFreeChipsCollectionIcon(self.freeChipsIcon)
	GC.SubGameInterface.DestroySelectGiftCollectionIcon(self.giftIcon)
	GC.SubGameInterface.DestroyMonthRankIcon(self.monthRankIcon)
	if self.entryEffect then
		GC.uu.destroyObject(self.entryEffect)
	end

	ZTD.Extend.StopAllAction();	
	
	if self._historyCoName then
		self:StopTimer(self._historyCoName);
		self._historyCoName = nil;
		ZTD.TrendDraw.Clean();
	end	
	
	self._dragonUi:Release();		
	self._ghostUi:Release();	
	self.gaintUi:Release()
	self.SealUi:Release()
	self._goldPillar:Release();
	self._heroMenu:Release();
	ZTD.Notification.NetworkUnregisterAll(self);		
	ZTD.GoldPlay.Release();		
	self.TurnTableMgr:Release()	
	self.LightningMgr:Release()

	self:ReleaseCountDown();
	ZTD.Notification.GameUnregisterAll(self);
	ZTD.BattleView.inst = nil;
end

function BattleView:OnPause()
	local posIds = {}
	for nm, _ in pairs(self._nowHeroHps) do
		-- 记录自动攻击
		if not nm._oldAtk then
			nm._oldAtk = nm:IsAutoAtk();
			posIds[#posIds + 1] = nm._posId;
		end	
		nm:PauseCb();
	end
	if next(posIds) then
		self:_reqAtk(posIds, false);
	end	

	self:_cleanNow(true);
	
	self._dragonUi:OnPause();
	
	self._pauseMark = true;
end

function BattleView:GetNowHeroPos()
	local ret = {};
	for nm, _ in pairs(self._nowHeroHps) do
		ret[#ret + 1] = nm._posId;
	end
	return ret;
end

function BattleView:OnResume()
	
end

function BattleView:OnGameResume(isCallSuss)
	-- 回到前台，恢复英雄的自动攻击
	local function sussCb()
		local posIds = {}
		local tgNms = {};
		for nm, _ in pairs(self._nowHeroHps) do
			if nm._oldAtk then
				posIds[#posIds + 1] = nm._posId;
				tgNms[#tgNms + 1] = nm;
				nm._oldAtk = nil;
			end
		end
		
		for _, heroPos in pairs(tgNms) do
			heroPos:BeginCb();
		end	
		self:_reqAtk(posIds, true);		
	end
	
	--[[local function errCb()
		ZTD.Utils.ForceCloseWaitTip();
		self._RoomChangeCb = {};
		self:OnChangeRoom();
	end--]]
	
	--if isCallSuss then
		sussCb();
		self._dragonUi:OnResume();
	--[[else
		errCb();
	end--]]
end

function BattleView:AutoUpHero()

	local function sussCb()
		ZTD.TableData.SetMaSkillTimes(ZTD.PlayerData.GetPlayerId(), 0)
	end
	local function errCb(err,data)
		logError("ZTD.Request.CSOneKeyUpdateHeroReq:" .. tostring(err));
	end
	
	local heroList = {};
	for heroId, v in pairs(self._oneKeyHeros) do
		table.insert(heroList, heroId)
	end
	--logError("heroList="..GC.uu.Dump(heroList))
	ZTD.Request.CSOneKeyUpdateHeroReq({heroId = heroList}, sussCb, errCb)
end

return BattleView