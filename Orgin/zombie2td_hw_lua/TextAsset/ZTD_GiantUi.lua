local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

-- 巨人
local GiantUi = GC.class2("ZTD_GiantUi", ZTD.TimeMapBase)
local SUPER = ZTD.TimeMapBase

local Giant_UI_PB = "OriGiantMedal"
-- 夜王死亡时间
local DEAD_TIME_10004 = 2.2
-- ui 特效边框文件
local GHOST_FRAME_PB = "TD_Effects_JRjing_PB";

local function PlayAnimation(targetSp, value)
	local playAni = targetSp:GetComponent("Animator")
	if playAni == nil then
		return
	end
	if (targetSp.gameObject.activeSelf) then
		playAni:SetTrigger(value)
	end
	playAni.speed = 1
end

function GiantUi:ctor(_, battleView)
	self._battleView = battleView
	self._rootNode = ZTD.PoolManager.GetUiItem(Giant_UI_PB, self._battleView.transform)
	self._rootNode:SetActive(false)
	self._uiFrame = ZTD.EffectManager.PlayEffect(GHOST_FRAME_PB, self._battleView.transform, true)
	self._uiFrame:SetActive(false)
	self._txtGold = self._rootNode:SubGet("txt_gold", "Text")
    self.IsConnect = false
	self.Level = 1
	self.giantLogic = ZTD.GiantLogic:new(self)
	ZTD.Notification.NetworkRegister(self, "SCGiantUpgrade", self.OnPushGiantUpgrade)
	ZTD.Notification.NetworkRegister(self, "SCPushGiantEnd", self.OnPushGiantEnd)
	SUPER.Init(self)
end

--巨人升级
function GiantUi:OnPushGiantUpgrade(Data)
	-- log(os.date("%Y-%m-%d %H:%M:%S:").."  OnPushLevelUp data = "..GC.uu.Dump(Data))
	local enemyMgr = ZTD.Flow.GetEnemyMgr()
	local tgEnemey = enemyMgr._ctrlList[Data.PositionId]
	if not tgEnemey then
		tgEnemey = enemyMgr._readyDelCtrlList[Data.PositionId]
	end
	--5级中奖，召唤始祖巨人
	if Data.IsOver then
		self:OnGiantRelease(Data)
	elseif not Data.IsOver and tgEnemey then
		tgEnemey:SetGiantLevel(Data.Level)
		tgEnemey._enemyObj:OnRefreshLevMul(Data.Level)
		tgEnemey._enemyObj:OnRefreshScale(Data.Level)
		tgEnemey._enemyObj:OnRefreshEff(Data.Level)
		ZTD.PlayMusicEffect("levelUp")
	end
end

--始祖巨人释放
function GiantUi:OnGiantRelease(Data)
	-- logError(os.date("%Y-%m-%d %H:%M:%S:").."  OnGiantRelease Data="..GC.uu.Dump(Data))
	self._isPlayer = (Data.PlayerId == ZTD.PlayerData.GetPlayerId())
	self.attackTimes = Data.AttackTimes
	if self._isPlayer then
		-- 如果还在结算过程中，强制结束所有动作
		if self._isEndProcess then
			logError("！！！始祖巨人 强制结算")			
			-- 中断要强行刷新 父节点金币链
			if self._myComboNode then
				ZTD.ComboShowTree.ReduceComboByNode(self._myComboNode)
				self._myComboNode = nil
			end	
			self:Reset()
		end	
		self._rootNode.localPosition = Vector3(400, 130, 0)
		self._rootNode.localScale = Vector3.one * 0.5
		self._rootNode:FindChild("longmuRat"):SetActive(false)
		local avData = Data.AttackInfo
		local f_id = avData.KillID
		local n_id = avData.SelfID
		local medalUi = self
		if self._myComboNode == nil then
			local comboNode = ZTD.ComboShowTree.LinkCombo({atkType = ZTD.AttackData.TypeGiant, medalUi = medalUi, goldData = ZTD.GoldData.OriGiantGold}, f_id, n_id)
			self._myComboNode = comboNode
			self.giantLogic:SetComboNode(comboNode)
		end	
	end	
	local posID = Data.PositionId
	local enemyMgr = ZTD.Flow.GetEnemyMgr()
	self.IsConnect = enemyMgr.connectList[posID]
	self:StopSummonAct()
	self.giantLogic:SetRatio(Data.Ratio)
	if self.attackTimes <= 0 then
		return
	end
	-- 如果为0，表示刚登陆 或切后台回来还在过程中
	if posID == 0 then
		local data = {
			posID = posID,
			attackTimes = self.attackTimes,
		}
		self.giantLogic:ActiveRoad(self._isPlayer, data)
	else	
		-- 播放怪物死亡动作
		local enemyMgr = ZTD.Flow.GetEnemyMgr()
		enemyMgr:ReadyDestory(posID)
		self.delayAct = self:StartTimer(function ()
			ZTD.PlayMusicEffect("giantHowl")
		end, 1, 1)
		--等怪物动作完毕后再播放尸鬼龙入场动画
		self._releaseAct = self:StartTimer(function ()
			local data = {
				posID = posID,
				attackTimes = self.attackTimes,
			}
			self.giantLogic:ActiveRoad(self._isPlayer, data)
			self:StopSummonAct()
		end, DEAD_TIME_10004, 1)
	end
end

--始祖巨人结束
function GiantUi:OnPushGiantEnd(Data)
	-- logError(os.date("%Y-%m-%d %H:%M:%S:").."  OnPushGiantEnd Data=:" .. GC.uu.Dump(Data))
	self:StopSummonAct()
	local isPlayer = (Data.PlayerId == ZTD.PlayerData.GetPlayerId())
	if isPlayer then
		-- 是否进入结算过程
		self._isEndProcess = true
	end
	local targetPos = nil
	if isPlayer then
		if self._myComboNode == nil then
			logError("！！！self._myComboNode is nil")
			return
		end
		targetPos = ZTD.ComboShowTree.GetParentUIGoldPos(self._myComboNode)
		self.giantLogic:SetComboNode()
	end
	local OriGiantGold = ZTD.GoldData.OriGiantGold
	self._checkEndFunc = function (dt)
		-- logError("OriGiantGold="..GC.uu.Dump(OriGiantGold))
		-- logError("OriGiantGold.Recorder="..tostring(OriGiantGold.Recorder))
		if OriGiantGold.Recorder <= 0 then
			self._checkEndTime = self._checkEndTime + dt
			if self._checkEndTime > 2.5 then
				ZTD.Flow.RemoveUpdateList(self._checkEndFunc)
				self._checkEndFunc = nil
				self._txtGold.text = tools.numberToStrWithComma(OriGiantGold.Sync)
				if self.addRatio and self.addRatio > 1 then
					self._txtGold.text = tools.numberToStrWithComma(math.floor(OriGiantGold.Sync/self.addRatio))
				end			
				local function onEndFunc()
					local effect = self._rootNode
					self._rootNode:FindChild("giantGoldEff"):SetActive(true)
					self.timer3 = ZTD.GameTimer.DelayRun(0.2, function()
						ZTD.PlayMusicEffect("giantPrize")
					end)
					self.timer1 = self:StartTimer(function()
						self._rootNode:SetActive(false)
						self._rootNode:FindChild("giantGoldEff"):SetActive(false)
						-- 金币柱表现
						if OriGiantGold.Sync > 0 then
							ZTD.Notification.GamePost(ZTD.Define.MsgGoldPillar, OriGiantGold.Sync / self.giantLogic:GetRatio(), OriGiantGold.Sync)
						end
						-- 刷新底部+-金币					
						ZTD.ComboShowTree.ReduceComboByNode(self._myComboNode)
						self._myComboNode = nil
						self._isEndProcess = false
						if self.timer1 then
							self:StopTimer(self.timer1)
							self.timer1 = nil
						end
					end, 2.5, 1)
					self.timer2 = self:StartTimer(function()
						local effect = self._rootNode
						self:StartBezier(targetPos, effect.position, effect, nil, nil, 0.5)
						self:StartAction(effect, {"scaleTo", 0.1, 0.1, 0.1, 0.35})
						if self.timer2 then
							self:StopTimer(self.timer2)
							self.timer2 = nil
						end
					end, 2.0, 1)
				end	
				-- self._rootNode.localPosition = Vector3.zero
				-- self._rootNode.localScale = Vector3.one
				local effect = self._rootNode
				local mapPos = ZTD.MainScene.GetMapObj().position
				local pos = ZTD.MainScene.SetupPos2UiPos(mapPos)
				self:StartBezier(pos, effect.position, effect, nil, onEndFunc, 0.5)
				self:StartAction(effect, {{"delay", 0.3},{"scaleTo", 1, 1, 1, 0.1}})
			end
		end	
	end
	if isPlayer then
		self._checkEndTime = 0
		ZTD.Flow.AddUpdateList(self._checkEndFunc)
	end
	self.giantLogic:PushLeave()
end

function GiantUi:GetGoldPos()
	return self:FindChild("node_gold_target").position
end

function GiantUi:RefreshGold()
	-- logError("RefreshGold")
	local goldData = ZTD.GoldData.OriGiantGold
	-- logError("goldData="..GC.uu.Dump(goldData))
	self:UpdateGold(goldData.Show)
end

function GiantUi:UpdateGold(dmoney, comboNode, addRatio)
	-- logError("UpdateGold"..tostring(dmoney))
	self.addRatio = addRatio
	self._txtGold.text = tools.numberToStrWithComma(dmoney)	
	-- logError("_isPlayer="..tostring(self._isPlayer))
	-- logError("self._rootNode.activeSelf="..tostring(self._rootNode.activeSelf))
	if self._isPlayer and self._rootNode.activeSelf == false then			
		self._rootNode.localPosition = Vector3(400, 130, 0)
		self._rootNode.localScale = Vector3.one * 0.5
		self._rootNode:SetActive(true)
		local cfg = ZTD.ConstConfig[1]
		if self.addRatio and self.addRatio > 1 then
			self._rootNode:FindChild("longmuRat"):SetActive(true)
			self._rootNode:FindChild("longmuRat/img_r"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. self.addRatio)
		else
			self._rootNode:FindChild("longmuRat"):SetActive(false)
		end
	end
	if self.addRatio and self.addRatio > 1 then
		self._txtGold.text = tools.numberToStrWithComma(math.floor(dmoney / self.addRatio))
	end
end

function GiantUi:FindChild(childNodeName)
	return self._rootNode:FindChild(childNodeName)
end

function GiantUi:StopSummonAct()
	if self._releaseAct then
		self:StopTimer(self._releaseAct)
		self._releaseAct = nil
	end
	if self.delayAct then
		self:StopTimer(self.delayAct)
		self.delayAct = nil
	end
end

function GiantUi:StartUiFrame()
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

function GiantUi:StopUiFrame()
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

function GiantUi:Reset()
	if self._checkEndFunc then
		ZTD.Flow.RemoveUpdateList(self._checkEndFunc)
		self._checkEndFunc = nil
	end		
	if self.timer1 then
		self:StopTimer(self.timer1)
		self.timer1 = nil
	end
	if self.timer2 then
		self:StopTimer(self.timer2)
		self.timer2 = nil
	end
	if self.timer3 then
		self:StopTimer(self.timer3)
		self.timer3 = nil
	end
	self:StopAll()
	self._releaseAct = nil
	self.delayAct = nil
	self._rootNode:SetActive(false)
	self._uiFrame:SetActive(false);
	self._myComboNode = nil
	self.giantLogic:Release()
	-- 重置金币表现数据
	local OriGiantGold = ZTD.GoldData.OriGiantGold
	OriGiantGold:Set(0)
	OriGiantGold.Recorder = 0
	self._isEndProcess = false
end

function GiantUi:Release()
	self:Reset()
	ZTD.Notification.NetworkUnregisterAll(self)
	self.giantLogic:Release()
end

return GiantUi