local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

-- 喷火逻辑驱动类
local GhostFireUi = GC.class2("ZTD_GhostFireUi", ZTD.TimeMapBase);
local SUPER = ZTD.TimeMapBase;
-- 进度条移动变量(x轴)
local FillAmountMove = 300;

local OGG_PRIZE_SHOW_SOUND = "Ghost_prize_start";
local OGG_PRIZE_SHOW_BURST = "Ghost_prize_end";

--夜王爆奖牌
local GHOST_UI_PB = "ZTD_ghost_show";
-- ui 特效边框文件
local GHOST_FRAME_PB = "TD_Effects_YWjing_PB";
--夜王死亡时间
local DEAD_TIME_10004 = 2.2;

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

function GhostFireUi:ctor(_, battleView)
	self._battleView = battleView;
	self._rootNode = ZTD.PoolManager.GetUiItem(GHOST_UI_PB, self._battleView.transform);
	self._rootNode:SetActive(false);
	
	self._uiFrame = ZTD.EffectManager.PlayEffect(GHOST_FRAME_PB, self._battleView.transform, true);
	self._uiFrame:SetActive(false);
	
	-- 进度条部分UI
	self._leftShow = self._battleView:FindChild("top_left2");
	self._leftShow:SetActive(false);	
	self._leftShowOrgPos = self._leftShow.localPosition;
	self._leftShow.localPosition = Vector3(self._leftShowOrgPos.x - FillAmountMove, self._leftShowOrgPos.y, self._leftShowOrgPos.z);
	
	-- 获得金币
	self._txtGold = self._rootNode:SubGet("txt_gold", "Text");	
	-- 剩余攻击次数
	self._txtAtkCount = self._rootNode:FindChild("txt_count");
	-- ui主部件
	self._ghostBg = self._rootNode:FindChild("Effect_UI_Long");
	-- 逻辑行为
	self._ghostFireLogic = ZTD.GhostFireLogic:new(self);
	
	--
	self._timeActList = {};
	
	ZTD.Notification.NetworkRegister(self, "SCPushGhostDragonRelease", self.OnPushGhostFireRelease)
	ZTD.Notification.NetworkRegister(self, "SCPushGhostDragonEnd", self.OnPushGhostFireEnd)
	ZTD.Notification.NetworkRegister(self, "SCPushSelfGhostDragonState", self.OnPushGhostFireState)	
	
	-- log("-----------------------00--GhostFireUi init")
	
	SUPER.Init(self);

	self.IsConnect = false
end

function GhostFireUi:FindChild(childNodeName)
	return self._rootNode:FindChild(childNodeName);
end

function GhostFireUi:StopSummonAct()
	if self._releaseAct then
		self:StopTimer(self._releaseAct);
		self._releaseAct = nil;
	end
end

function GhostFireUi:OnPushGhostFireRelease(Data)
	-- log(os.date("%Y-%m-%d %H:%M:%S:") .. ("!!!!!!!!!!!!!OnPushGhostFireReleaseOnPushGhostFireRelease PositionId:" .. Data.PositionId));
	self._isPlayer = (Data.PlayerId == ZTD.PlayerData.GetPlayerId());
	-- 0.普通攻击杀死1.毒爆2.巨龙
	self._isShowBg = self._isPlayer;-- and (Data.KillType == 0) 
	
	if self._isPlayer then
		self._battleView.isGhostSkipGroup = false
		-- 如果还在结算过程中，强制结束所有动作
		if self._isEndProcess then
			-- logError("GhostFire EndProcessEndProcess break!!!")	
			-- 中断要强行刷新 父节点金币链
			if self._myComboNode then
				ZTD.ComboShowTree.ReduceComboByNode(self._myComboNode);
				self._myComboNode = nil;
			end	
			self:Reset();		
		end	
		
		self._rootNode.localPosition = Vector3.zero;
		self._rootNode.localScale = Vector3.one;
		self._rootNode:FindChild("img_r"):SetActive(false);
		self._rootNode:FindChild("img_s"):SetActive(false);
		self._rootNode:FindChild("img_ss"):SetActive(false);
		self._rootNode:FindChild("node_zd"):SetActive(false);	
		
		local avData = Data.AttackInfo;
		local f_id = avData.KillID;
		local n_id = avData.SelfID;
		local medalUi = self;
		if self._myComboNode == nil then
			local comboNode = ZTD.ComboShowTree.LinkCombo({atkType = ZTD.AttackData.TypeGhost, medalUi = medalUi, goldData = ZTD.GoldData.GhostGold}, f_id, n_id);
			self._myComboNode = comboNode;
			self._ghostFireLogic:SetComboNode(comboNode);
		end	
	end	
	

	local callGhost = function ()		
		self._ghostFireLogic:ActiveRoad(self._isPlayer);

		if self._isPlayer then
			--self._leftShow:SetActive(true);
			self._dstFillAmount = 1;
			self._leftShow.localPosition = Vector3(self._leftShowOrgPos.x - FillAmountMove, self._leftShowOrgPos.y, self._leftShowOrgPos.z);
			self:StartAction(self._leftShow,
								{"localMoveBy", FillAmountMove, 0, 0, 0.5});
			
			local prog_img = self._leftShow:FindChild("skill_prog"):GetComponent("Image");
			self._AttackCount = Data.AttackCount;
			prog_img.fillAmount = (self._AttackCount - Data.UseCount) / self._AttackCount;
		end
	end
	
	
	local posID = Data.PositionId;

	local enemyMgr = ZTD.Flow.GetEnemyMgr()
	self.IsConnect = enemyMgr.connectList[posID]

	self:StopSummonAct();
	self._ghostFireLogic:SetRatio(Data.Ratio);
	
	-- 如果为0，表示刚登陆 或切后台回来还在过程中
	if posID == 0 then
		callGhost();
	else	
		-- 播放怪物死亡动作
		local enemyMgr = ZTD.Flow.GetEnemyMgr();
		enemyMgr:ReadyDestory(posID);

		--等怪物动作完毕后再播放尸鬼龙入场动画
		self._releaseAct = self:StartTimer(function ()
			callGhost();
			self:StopSummonAct();
		end, DEAD_TIME_10004, 1);	
	end
end

function GhostFireUi:StartUiFrame()
	if self._uiFrameEndFunc then
		self:StopTimer(self._uiFrameEndFunc)
		self._uiFrameEndFunc = nil;
	end
	
	if self._uiFrameStartFunc == nil then		
		self._uiFrameStartFunc = self:StartTimer(function ()
			self._uiFrame:SetActive(true);
			PlayAnimation(self._uiFrame, "READY");
			self:StopTimer(self._uiFrameStartFunc)
			self._uiFrameStartFunc = nil;
		end, 0.2, 1);	
	end	
end

function GhostFireUi:StopUiFrame()
	if self._uiFrameStartFunc then
		self:StopTimer(self._uiFrameStartFunc)
		self._uiFrameStartFunc = nil;
	end
	
	if self._uiFrameEndFunc == nil then
		PlayAnimation(self._uiFrame, "LEAVE");
		self._uiFrameEndFunc = self:StartTimer(function ()
			self._uiFrame:SetActive(false);
			self:StopTimer(self._uiFrameEndFunc)
			self._uiFrameEndFunc = nil;
		end, 1.0, 1);	
	end
end
	
-- fly gold 回调使用
function GhostFireUi:GetGoldPos()
	return self:FindChild("node_gold_target").position;
end

function GhostFireUi:RefreshGold()
	local goldData = ZTD.GoldData.GhostGold;
	self:UpdateGold(goldData.Show)
end

function GhostFireUi:UpdateGold(dmoney, comboNode, addRatio, GiantHitPower, balloonRatio)
	self.GiantHitPower = GiantHitPower or 0
	self.balloonRatio = balloonRatio or 0
	--if comboNode and comboNode ~= self._myComboNode then
	--	return;
	--end	
	
	--if dmoney ~= 0 and ZTD.GoldData.GhostGold.Sync ~= 0 then
		self._txtGold.text = tools.numberToStrWithComma(dmoney);
	--end	
	local cfg = ZTD.ConstConfig[1];
	
	if self._isShowBg and self._rootNode.activeSelf == false then			
		self._rootNode.localPosition = Vector3.zero;
		self._ghostBg.localScale = Vector3.one * 0.5;				
		--self._txtGold.fontSize = 32;	
		self._rootNode:FindChild("txt_gold").localScale = Vector3(0.3, 0.3, 1);
		self._rootNode:FindChild("txt_gold").localPosition = Vector3(0, -13, 0);				
		--self._txtAtkCount.text = "剩余子弹:" .. Data.UseCount;
		--self._txtGold.text = 0;
		
		PlayAnimation(self._ghostBg, "READY");
		self._rootNode:SetActive(true);	
		
		ZTD.PlayMusicEffect(OGG_PRIZE_SHOW_SOUND);
		local pos = Vector3(-200, -10, 0);	
		local pos1 = Vector3(150, -10, 0);
		local pos2 =  Vector3(190, 0, 0)
		local pos3 = Vector3(270, 0, 0)
		
		local off = 190
		if addRatio and addRatio > 1 then
			off = 270
			self._rootNode:FindChild("img_r"):SetActive(true);
			self._rootNode:FindChild("img_s"):SetActive(true);
			
			self._rootNode:FindChild("img_r").localScale = Vector3(0.5, 0.5, 1);
			self._rootNode:FindChild("img_r").localPosition = pos1
			self._rootNode:FindChild("img_s").localScale = Vector3(0.5, 0.5, 1);
			self._rootNode:FindChild("img_s").localPosition = pos			
			if GiantHitPower and GiantHitPower > 1 then
				self._rootNode:FindChild("img_ss"):SetActive(true);
				self._rootNode:FindChild("img_ss").localPosition = pos
				self._rootNode:FindChild("img_ss").localScale = Vector3(0.5, 0.5, 1);
				self._rootNode:FindChild("img_giant").localPosition = pos2
				self._rootNode:FindChild("node_zd").localPosition = pos3
			else
				self._rootNode:FindChild("node_zd").localPosition = pos2
			end
			
			if addRatio > 1 and addRatio < 5 then
				self._rootNode:FindChild("img_r"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. addRatio);
			else
				self._rootNode:FindChild("img_r"):SetActive(false);
			end
			self.addRatio = addRatio;
		else
			self.addRatio = nil;
			if GiantHitPower and GiantHitPower > 1 then
				self._rootNode:FindChild("img_giant").localPosition = pos1
				self._rootNode:FindChild("node_zd").localPosition = pos2
			else
				self._rootNode:FindChild("node_zd").localPosition = pos1
			end
		end
		if GiantHitPower and GiantHitPower > 1 then
			self._rootNode:FindChild("img_giant"):SetActive(true);
			self._rootNode:FindChild("img_giant"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. GiantHitPower);
			self.GiantHitPower = GiantHitPower
		else
			self.GiantHitPower = nil
			self._rootNode:FindChild("img_giant"):SetActive(false);
		end
		if balloonRatio and balloonRatio > 1 then
			self._rootNode:FindChild("node_zd"):SetActive(true);
			
			self._rootNode:FindChild("node_zd").localScale = Vector3(0.5, 0.5, 1);

			if balloonRatio > 1 and balloonRatio < 4 then
				self._rootNode:FindChild("node_zd/img_rzd"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. balloonRatio);
				self._rootNode:FindChild("node_zd/img_zd"):SetActive(true)
			else
				self._rootNode:FindChild("node_zd"):SetActive(false);
			end
		else
			self.balloonRatio = nil
		end
		self._rootNode:FindChild("Effect_UI_Long/linkImg"):SetActive(self.IsConnect)
	end
	
	if self.addRatio then
		self._txtGold.text = tools.numberToStrWithComma(math.floor(dmoney / self.addRatio));
	end
end
-- fly gold end

function GhostFireUi:Release()
	self:Reset();
	ZTD.Notification.NetworkUnregisterAll(self);
	self._ghostFireLogic:Release();
	
	-- log("-----------------------00--GhostFireUi Release")
end

function GhostFireUi:Reset()
	--
	if self._checkEndFunc then
		ZTD.Flow.RemoveUpdateList(self._checkEndFunc)
		self._checkEndFunc = nil;
	end	
	
	if self._checkFillAmountFunc then
		ZTD.Flow.RemoveUpdateList(self._checkFillAmountFunc)
		self._checkFillAmountFunc = nil;	
	end			
	
	self:StopAll();
	self._releaseAct = nil;
	
	self._rootNode:SetActive(false);
	self._leftShow:SetActive(false);
	self._uiFrame:SetActive(false);
	
	self._myComboNode = nil;
	self._ghostFireLogic:Release();
	
	-- 重置金币表现数据
	local ghostGold = ZTD.GoldData.GhostGold;
	ghostGold:Set(0);
	ghostGold.Recorder = 0;
	
	self._rootNode.localPosition = Vector3.zero;
	
	self._isEndProcess = false;
end	

function GhostFireUi:OnPushGhostFireEnd(Data)
	--logError("!!!!!!!!!!!!!!!!!!table:" .. tostring(ZTD.TableData.GetTable()) .. "," .. Data.TableID);
	--if Data.TableID ~= ZTD.TableData.GetTable() then
	--	return;
	--end	
	-- 是否进入结算过程
	self._isEndProcess = true;
	
	self:StopSummonAct();
	local isPlayer = (Data.PlayerId == ZTD.PlayerData.GetPlayerId());
	--local moneyEarn = Data.Money;
	-- log(os.date("%Y-%m-%d %H:%M:%S:") .. "!!!!!!!!!!!!!!!!!!OnPushGhostFireEnd");

	local targetPos = nil;
	if isPlayer then
		if self._myComboNode == nil then
			logError("invail PushGhostFireEnd push!!!!!")
			return;
		end
		targetPos = ZTD.ComboShowTree.GetParentUIGoldPos(self._myComboNode);
		self._ghostFireLogic:SetComboNode();
	end
	
	local ghostGold = ZTD.GoldData.GhostGold;
	self._checkEndFunc = function (dt)
		if ghostGold.Recorder <= 0 then
			self._checkEndTime = self._checkEndTime + dt;
			if self._checkEndTime > 0.5 then
				ZTD.Flow.RemoveUpdateList(self._checkEndFunc)
				self._checkEndFunc = nil;
				
				self._txtGold.text = tools.numberToStrWithComma(ghostGold.Sync);
				if self.addRatio then
					self._txtGold.text = tools.numberToStrWithComma(math.floor(ghostGold.Sync/self.addRatio));
				end				
				PlayAnimation(self._ghostBg, "LEAVE");
				ZTD.PlayMusicEffect(OGG_PRIZE_SHOW_BURST);
				
				self._ghostBg.localScale = Vector3.one;

				--self._txtGold.fontSize = 60;	
				self._rootNode:FindChild("txt_gold").localScale = Vector3(0.5, 0.5, 1);
				self._rootNode:FindChild("txt_gold").localPosition = Vector3(0, -20, 0);	
				local pos = Vector3(-380, -20, 0)
				local pos1 = Vector3(300, -20, 0)
				local pos2 = Vector3(370, -10, 0)
				local pos3 = Vector3(440, -10, 0)
				if self.addRatio and self.addRatio > 1 then
					--local baseSizeX = 50
					--local singleX = 40
					--local bWidth = #tostring(self._txtGold.text) * singleX + baseSizeX
					self._rootNode:FindChild("img_s").localScale = Vector3(1, 1, 1);
					self._rootNode:FindChild("img_s").localPosition = pos
					self._rootNode:FindChild("img_r").localScale = Vector3(0.7, 0.7, 1);
					self._rootNode:FindChild("img_r").localPosition = pos1
					if self.GiantHitPower and self.GiantHitPower > 1 then
						self._rootNode:FindChild("img_ss").localScale = Vector3(1, 1, 1);
						self._rootNode:FindChild("img_ss").localPosition = pos
						self._rootNode:FindChild("img_giant").localPosition = pos2
						self._rootNode:FindChild("node_zd").localPosition = pos3
					else
						self._rootNode:FindChild("node_zd").localPosition = pos2
					end
				else
					if self.GiantHitPower and self.GiantHitPower > 1 then
						self._rootNode:FindChild("img_giant").localPosition = pos1
						self._rootNode:FindChild("node_zd").localPosition = pos2
					else
						self._rootNode:FindChild("node_zd").localPosition = pos1
					end
				end	
				if self.balloonRatio and self.balloonRatio > 1 then
					self._rootNode:FindChild("node_zd").localScale = Vector3(1, 1, 1);
				end
				
				self:StartTimer(function()
					if isPlayer then
						self._battleView.isGhostSkipGroup = true
					end
					self._rootNode:SetActive(false);
					--self._leftShow:SetActive(false);
					
					-- 金币柱表现
					if ghostGold.Sync > 0 then
						ZTD.Notification.GamePost(ZTD.Define.MsgGoldPillar, ghostGold.Sync / self._ghostFireLogic:GetRatio(), ghostGold.Sync);
					end	
					
					-- 刷新底部+-金币					
					ZTD.ComboShowTree.ReduceComboByNode(self._myComboNode);
					self._myComboNode = nil;
					self._isEndProcess = false;
					
					-- log(os.date("%Y-%m-%d %H:%M:%S:") .. "!!!!!!!!!!!!!!!!!!OnPushGhostFireEnd EndProcess");
				end, 2.5, 1);
				
				self:StartTimer(function()
					local effect = self._rootNode;
					self:StartBezier(targetPos, effect.position, effect, nil, nil, 0.5);	
					self:StartAction(effect, {"scaleTo", 0.1, 0.1, 0.1, 0.35});
				end, 2.0, 1);
			end
		end	
	end
	
	if isPlayer then
		self._checkEndTime = 0;
		ZTD.Flow.AddUpdateList(self._checkEndFunc)
	end
	
	--if isPlayer and self._dstFillAmount ~= 0 then
	--	self:StartAction(self._leftShow, {"localMoveBy", -FillAmountMove, 0, 0, 0.5});
	--end	
	
	self._ghostFireLogic:PushLeave();

----------------------------------------------------------------------

end

function GhostFireUi:OnPushGhostFireState(Data)
	-- 屏蔽子弹进度条显示
	if true then
		return;
	end	
	
	local leftCount = Data.Count;
	--logError("!!!!!!!!!!!!!!!!!!leftCount:" .. leftCount);
	
	self._txtAtkCount.text = "剩余子弹:" .. leftCount;
	
	local prog_img = self._leftShow:FindChild("skill_prog"):GetComponent("Image");
	self._dstFillAmount = leftCount/ self._AttackCount;	
	self._dstSpd = (prog_img.fillAmount - self._dstFillAmount) / 0.25;
	
	if self._dstFillAmount == 0 then
		self._dstSpd = self._dstSpd * 5;
	end	
	
	if self._checkFillAmountFunc == nil then
		self._checkFillAmountFunc = function(dt)
			
			local setFillAmount = prog_img.fillAmount - self._dstSpd * dt;
			if setFillAmount <= self._dstFillAmount then
				setFillAmount = self._dstFillAmount;
				ZTD.Flow.RemoveUpdateList(self._checkFillAmountFunc)
				self._checkFillAmountFunc = nil;
				
				if self._dstFillAmount == 0 then
					self:StartAction(self._leftShow, {"localMoveBy", -FillAmountMove, 0, 0, 0.5});
				end
			end
			prog_img.fillAmount = setFillAmount;
		end
		ZTD.Flow.AddUpdateList(self._checkFillAmountFunc)
	end
end


return GhostFireUi;