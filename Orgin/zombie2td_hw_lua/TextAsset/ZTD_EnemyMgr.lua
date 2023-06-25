local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TdEnemyMgr = GC.class2("TdEnemyMgr", ZTD.ObjectMgr);
local SUPER = ZTD.ObjectMgr;

function TdEnemyMgr:ctorCustom()
	-- unity实体映射
	self._enemyTransformMap = {};
	-- 准备创建的敌人数据
	self._buildStandByData = {};
	-- 准备同步的敌人数据
	self._buildSyncData = {};
	-- 即将被删除的敌人
	self._readyDelCtrlList = {};
	-- 用于记录删除敌人的缓存
	self._dieRecord = {};
	local constCfg = ZTD.ConstConfig[1];
	self._monsterTime = constCfg.MonsterCd;
	--用于记录产出的怪物是否为连接怪
	self.connectList = {}
end

function TdEnemyMgr:ChangeId(srcId, newId)
	local buildCtrl = self:GetCtrlById(srcId);
	if buildCtrl then
		buildCtrl._id = newId;
		self._ctrlList[srcId] = nil;
		self._ctrlList[newId] = buildCtrl;
	end	
end	
	
function TdEnemyMgr:createEnemy(routeId, enemyId, serverId, buffList, IsConnect, Level)
	--logWarn("-------------createEnemycreateEnemycreateEnemy:" .. serverId);
	local cfg = ZTD.ConstConfig[1];
	local enemyCfg = ZTD.MainScene.GetEnemyCfg(enemyId);
	if enemyCfg == nil then
		logError("-------------invail enemyId when createEnemy:" .. enemyId);
		enemyCfg = ZTD.MainScene.GetEnemyCfg(4000);
	end
	if not IsConnect then
		IsConnect = false
	end
	self.connectList[serverId] = IsConnect
	local buildId = self:CreateObject({objPath = cfg.ResPath, enemyCfg = enemyCfg, routeId = routeId, forceId = serverId, IsConnect = IsConnect, Level = Level});
	
	local buildCtrl = self:GetCtrlById(buildId);
	if buffList then 
		-- logError("buffList="..GC.uu.Dump(buffList))
		if buffList[2] == 0 then
			buildCtrl:UpdateBuffer(buffList[1])
		end
	end
	
	
	local transform = buildCtrl:getEnemyObj();
	self._enemyTransformMap[transform] = buildId;
	
	--
	--[[
	local v1 = math.floor(buildId % 1000 / 100);
	local v2 = math.floor(buildId % 100 / 10);
	local v3 = buildId % 10;
	buildCtrl:setDebug(v1, v2, v3);
	--]]
	if not self._touchChecker then
		local customData = {};
		customData.customPresseDownCheck = function()
			return false;
		end
		customData.customPresseUpCheck = self.OnEnemyClkUp;
		self._touchChecker = ZTD.TouchChecker:new(ZTD.Define.LayerZombie, customData);
		ZTD.Flow.GetTouchMgr():AddTouch(self._touchChecker, 10);
	end
	self._touchChecker:Register(transform, buildCtrl, {});	
	
	return buildCtrl;
end

function TdEnemyMgr:getCtrlByTransForm(transform)
	local buildId = self._enemyTransformMap[transform];
	if buildId then
		return self:GetCtrlById(buildId);
	end
end	

function TdEnemyMgr:DestoryCtrl(delCtrl)
	local transform = delCtrl:getEnemyObj();
	if transform then
		self._enemyTransformMap[transform] = nil;
		self._touchChecker:UnRegister(transform);
	end	
	SUPER.DestoryCtrl(self, delCtrl);
end


function TdEnemyMgr:DestoryCtrlById(delId)
	local ctrl = self:GetCtrlById(delId);
	local transform;
	if ctrl then
		transform = ctrl:getEnemyObj();
	end
	if transform then
		self._enemyTransformMap[transform] = nil;
		self._touchChecker:UnRegister(transform);
	end
	SUPER.DestoryCtrlById(self, delId);
end

function TdEnemyMgr.OnEnemyClkUp()
	local self = ZTD.Flow.GetEnemyMgr();
	local ret = self._touchChecker:PickTouch();
	if ret then
		ret.bindData:DealTouchLogic();
	end
	return ret
end

function TdEnemyMgr:FixedUpdate(dt)
	local constCfg = ZTD.ConstConfig[1];
	local tableId = ZTD.TableData.GetTable(); 
	local doubleCheck = self._dieRecord[tableId] or {};
	-- 同步数据的敌人列表:_buildSyncData，用完就删除
	for channelId, monsterBuildDatas in pairs(self._buildSyncData) do
		for monsterID, monsterdata in pairs(monsterBuildDatas) do
			
			if not doubleCheck[monsterdata.ServerId] then
				--如果没有这个monsterId，则创建后同步
				local buildCtrl = self:GetCtrlById(monsterdata.ServerId);
				if buildCtrl == nil then
					buildCtrl = self:createEnemy(channelId, monsterdata.MonsterID, monsterdata.ServerId, monsterdata.BuffList, monsterdata.IsConnect, monsterdata.Level);
				end
				buildCtrl.__monId = monsterdata.MonsterID;
				
				buildCtrl:SkipPosToTime(monsterdata.ProcessTime / constCfg.SecondRate);
			end
		end		
	end
	self._buildSyncData	= {};
	
	for channelId, monsterBuildDatas in pairs(self._buildStandByData) do
		-- 冷却时间到达后就创建怪，然后从队头中移除
		for monsterID, monsterdata in pairs(monsterBuildDatas) do
			if not doubleCheck[monsterdata.ServerId] then
				local buildCtrl = self:GetCtrlById(monsterdata.ServerId);
				if not buildCtrl then
					buildCtrl = self:createEnemy(channelId, monsterdata.MonsterID, monsterdata.ServerId, monsterdata.BuffList, monsterdata.IsConnect, monsterdata.Level)
					buildCtrl.__monId = monsterdata.MonsterID;
					buildCtrl:SkipPosToTime(monsterdata.ProcessTime / constCfg.SecondRate);					
				end	
			end
		end
	end	
	self._buildStandByData = {};
	
	for id, v in pairs(self._readyDelCtrlList) do
		v:FixedUpdate(dt);
		if v:IsRelease() then
			self._readyDelCtrlList[id] = nil;
		end
	end
	
	SUPER.FixedUpdate(self, dt);
end

function TdEnemyMgr:PushSync(buildData)
	-- logError("buildData="..GC.uu.Dump(buildData))
	local count = 0;
	
	local tableId = ZTD.TableData.GetTable();
	local doubleCheck = self._dieRecord[tableId] or {};	
	
	for _, vvv in ipairs(buildData) do
		local channelId = vvv.ChannelId;
		if not self._buildStandByData[channelId] then
			self._buildStandByData[channelId] = {};
		end
		if not self._buildSyncData[channelId] then
			self._buildSyncData[channelId] = {};
		end
		
		--
		local constCfg = ZTD.ConstConfig[1];
	
		
		for _, v in ipairs(vvv.ChannelInfo) do
			if not doubleCheck[v.Position] then			
				--log(string.format("---------------PushSync ZTD_OnPush.channelId: %s ServerId:%s MonsterID:%s ProcessTime: %s ReadyTime:%s Timestamp:%s", tostring(channelId), tostring(v.Position), tostring(v.MonsterID), tostring(v.ProcessTime), tostring(v.ReadyTime), tostring(v.Timestamp)));
				--logError(os.date("%Y-%m-%d %H:%M:%S:") .. string.format("---------------PushSync ZTD_OnPush.channelId: %s PositionId:%s MonsterID:%s ProcessTime: %s", tostring(channelId), tostring(v.Position), tostring(v.MonsterID), tostring(v.ProcessTime)));
				local buildEnemyData = {};
				buildEnemyData.ProcessTime = v.ProcessTime;
				buildEnemyData.MonsterID = v.MonsterID;
				buildEnemyData.ServerId = v.Position;
				buildEnemyData.BuffList = v.Buff;
				buildEnemyData.IsConnect = v.IsConnect;
				buildEnemyData.Level = v.Level
					
				self._buildSyncData[channelId][buildEnemyData.ServerId] = buildEnemyData;
				count = count + 1;
			else
				logError("---------!!!PushSync _doubleCheck:" .. v.Position);
			end
		end
	end
	--log("-----------------PushSync end count:" .. count .. "," .. os.date("%Y-%m-%d %H:%M:%S:"));
end

-- 推送新怪物
function TdEnemyMgr:PushNewBuild(buildData)
	local count = 0;
	
	local tableId = ZTD.TableData.GetTable();
	local doubleCheck = self._dieRecord[tableId] or {};
	
	for _, vvv in ipairs(buildData) do
		local channelId = vvv.ChannelId;
		if not self._buildStandByData[channelId] then
			self._buildStandByData[channelId] = {};
		end
		--
		local constCfg = ZTD.ConstConfig[1];
		
		for _, v in ipairs(vvv.ChannelInfo) do
			if not doubleCheck[v.Position] then
				--log(string.format("---------------PushNewBuild ZTD_OnPush.channelId: %s ServerId:%s MonsterID:%s ProcessTime: %s ReadyTime:%s Timestamp:%s", tostring(channelId), tostring(v.Position), tostring(v.MonsterID), tostring(v.ProcessTime), tostring(v.ReadyTime), tostring(v.Timestamp)));
				-- logError(os.date("%Y-%m-%d %H:%M:%S:") .. string.format("---------------PushNewBuild ZTD_OnPush.channelId: %s PositionId:%s MonsterID:%s ProcessTime: %s", tostring(channelId), tostring(v.Position), tostring(v.MonsterID), tostring(v.ProcessTime)));
				local buildEnemyData = {};
				-- DEBUG 让服务器发毫秒 过来,
				buildEnemyData.ProcessTime = v.ProcessTime;
				buildEnemyData.MonsterID = v.MonsterID;
				buildEnemyData.ServerId = v.Position;
				buildEnemyData.BuffList = v.Buff;
				buildEnemyData.IsConnect = v.IsConnect;
				buildEnemyData.Level = v.Level
				
				local bslist = self._buildStandByData[channelId];
				bslist[#bslist + 1] = buildEnemyData;
				count = count + 1;
			else
				logError("---------!!!PushNewBuild _doubleCheck:" .. v.Position);
			end
		end
	end
	--log("-----------------PushNewBuild end count:" .. count .. "," .. os.date("%Y-%m-%d %H:%M:%S:"));
end

function TdEnemyMgr:PushSingleBuildData(channelId, enemyData)
	local bslist = self._buildStandByData[channelId];
	bslist[#bslist + 1] = enemyData;	
end

-- 毒爆怪预爆动作推送
function TdEnemyMgr:SCPoisonBomTimes(data)
	-- logError("SCPoisonBomTimes="..GC.uu.Dump(data))
	
	local PositionId = data.PositionId;  --转发前端传的怪物位置id,是哪个毒爆怪
	
	local tgEnemey = self._ctrlList[PositionId];
	if not tgEnemey then
		tgEnemey = self._readyDelCtrlList[PositionId];
	end
	
	local avData = data.AttackInfo;
	local f_id = avData.KillID;
	local n_id = avData.SelfID;	
	
	local skillPosition;
	local heroPos;
	if tgEnemey then
		tgEnemey:SetUnSelect(data.KillPlayerId, f_id, n_id);
		local eobj = tgEnemey:getEnemyObj();
		skillPosition = eobj.localPosition;
		heroPos = tgEnemey:GetLastHitHeroPos();
	else
		skillPosition = ZTD.MainScene.GetMapObj().position;
		heroPos = ZTD.MainScene.GetMapObj().position;	
	end
	

	
	

	local Times = data.Times; 		     --次数
	local Ratio = data.Ratio;		     --倍率
	local AddTimes = data.AddTimes; 	 --连爆次数 如果为-1或者0则表示没有获取连爆次数

	local IsSelf = (ZTD.PlayerData.GetPlayerId() == data.KillPlayerId);
	
	-- log(os.date("%Y-%m-%d %H:%M:%S:") .. "-----------SCPoisonBomTimes:" .. PositionId .. ",IsSelf:" .. tostring(IsSelf) .. "," .. data.KillPlayerId);

	if IsSelf == false then			
		for i = 1, #AddTimes do
			local tgId = AddTimes[i];
			local function removeCall()
				self:ReadyDestory(tgId, data.KillPlayerId);
			end
			ZTD.TableData.AddPoxData(data.KillPlayerId, tgId, removeCall);
		end			
	end	

	--for i = 1, #AddTimes do
	--	logError("--------------------AddTimes:" .. AddTimes[i])
	--end
	-- 毒爆怪技能ID:10001
	--logError("---------------pppppppppppppppppID:10001:" .. PositionId .. ",T:" .. Times)
	if Times > 0 then
		local skillMgr = ZTD.Flow.GetSkillMgr();

		if IsSelf then
			local avData = data.AttackInfo;
			local f_id = avData.KillID;
			local n_id = avData.SelfID;
			
			-- 毒爆怪转盘向屏幕中央靠拢(0,0)
			local function __hardFixMedal(lpos, wpos)
				local offsetX;
				local offsetY;
				local offVar = 1;
				
				if lpos.x > 0 then
					offsetX = -offVar;
				elseif lpos.x < 0 then	
					offsetX = offVar;
				end	
				if lpos.y > 0 then
					offsetY = -offVar;
				elseif lpos.y < 0 then	
					offsetY = offVar;
				end			
				
				local fixPos = Vector3(wpos.x + offsetX, wpos.y + offsetY, wpos.z);	
				return fixPos;
			end
			--
			local coinPos = __hardFixMedal(skillPosition, ZTD.MainScene.GetMapObj().position + skillPosition);
			local medalUi = ZTD.PoisonMedalMgr.CreateMedal(PositionId, coinPos, 10001, Ratio, f_id, n_id);
		end

		local max_range = 3;
		local pox_rate = (5 + 0.1) / max_range;
		local times = math.floor(Times / pox_rate);
		skillMgr:AddSkill(10001, 
						{isSelf = IsSelf, 
						addTimes = AddTimes, 
						enemyCtrl = tgEnemey,
						dir = 0,--tgEnemey:GetNowDir(), 
						pos = skillPosition, 
						killPlayerId = data.KillPlayerId,
						blocks = times,
						ratio = Ratio, 
						max_target = Times, 
						poisonId = PositionId,
						newPoisonId = PositionId,
						heroPos = heroPos,
						});		 
	end
end

function TdEnemyMgr:SCPoisonbombTypes(data)
	local constCfg = ZTD.ConstConfig[1];
	for _, v in ipairs(data.Info) do
		local cfgId = v.MonsterId;--怪物id
		local masterId = v.MasterPoisonBombId;--母体id
		local posId = v.PoisonBombId;--毒爆id
		local killPlayerId = v.KillPlayerId;--击杀玩家
		local ChannelId = v.ChannelId
		local ProcessTime = v.ProcessTime
		--logError(string.format("SCPoisonbombTypesSCPoisonbombTypes MonsterId:%s masterId:%s posId:%s ChannelId:%s ProcessTime:%s", cfgId, masterId, posId, ChannelId, ProcessTime / constCfg.SecondRate))
		
		local eCfg = ZTD.MainScene.GetEnemyCfg(cfgId);
		local buildId = self:CreateObject({objPath = eCfg.ResPath, enemyCfg = eCfg, routeId = ChannelId, forceId = posId});	
		local buildCtrl = self:GetCtrlById(buildId);
		buildCtrl.__monId = cfgId;
		buildCtrl:SkipPosToTime(ProcessTime / constCfg.SecondRate);
		buildCtrl:SetUnSelect(killPlayerId);
		
		local isPlayerKill = false;
		if killPlayerId == ZTD.PlayerData.GetPlayerId() then
			isPlayerKill = true;
		end
	end
	
	-- 游戏恢复暂停的时机？
	ZTD.Flow.IsPause = false;
end

--创建气球怪爆炸点
function TdEnemyMgr:CreateBombPoint(balloonPos, skillId)
	--获取爆炸点
	local points = ZTD.MainScene.GetBalloonPoint(balloonPos)
	local bombPosList = {}
	--设置爆炸点
	for i = 1, 3, 1 do
		-- logError("skillId="..tostring(skillId))
		local cfg = ZTD.MainScene.GetSkillCfg(skillId)
		local bombObj = ZTD.PoolManager.GetGameItem(cfg.balloonPrefab, ZTD.MainScene.GetMapObj())
		bombObj.localPosition = points[i]
		local bombWorldPos = bombObj.position
		local bombSelfPos = bombObj.localPosition
		skillId = skillId + 1
		table.insert(bombPosList, {bombWorldPos = bombWorldPos, bombSelfPos = bombSelfPos})
		ZTD.GameTimer.DelayRun(2, function()
			if bombObj and tostring(bombObj) ~= "null" then
				ZTD.PoolManager.RemoveGameItem(cfg.balloonPrefab, bombObj)
			end
		end)
	end
	-- logError("bombPosList="..GC.uu.Dump(bombPosList))
	return bombPosList
end

--气球怪免费次数
function TdEnemyMgr:SCPushBalloonTimes(data)
	-- logError("!!! SCPushBalloonTimes"..GC.uu.Dump(data))
	local PositionId = data.PositionId

	local tgEnemey = self._ctrlList[PositionId]
	if not tgEnemey then
		tgEnemey = self._readyDelCtrlList[PositionId]
	end

	local avData = data.AttackInfo
	local f_id = avData.KillID
	local n_id = avData.SelfID
	
	local skillPosition
	local heroPos
	local balloonPos
	if tgEnemey then
		tgEnemey:SetUnSelectBalloon()
		local eobj = tgEnemey:getEnemyObj()
		balloonPos = eobj.localPosition
		skillPosition = eobj.localPosition
		heroPos = tgEnemey:GetLastHitHeroPos()
	else
		skillPosition = ZTD.MainScene.GetMapObj().position
		balloonPos = ZTD.MainScene.GetMapObj().position
		heroPos = ZTD.MainScene.GetMapObj().position
	end
	local bombPosList = self:CreateBombPoint(balloonPos, 10016)

	local IsSelf = (ZTD.PlayerData.GetPlayerId() == data.PlayerId)

	if IsSelf == false then
		self:ReadyDestory(PositionId, data.PlayerId)
	end	
	local skillMgr = ZTD.Flow.GetSkillMgr()
	if data.FreeTimes > 0 then
		--释放技能
		local time = 0
		if data.AttackCount > 0 then
			for i = 1, data.AttackCount, 1 do
				local tag = i == 3 and true or false
				local idx = i
				--设置爆炸点
				local skillId = 10015 + i
				--logError("skillId="..tostring(skillId))
				ZTD.GameTimer.DelayRun(time, function () 
					--logError("bombPosList="..GC.uu.Dump(bombPosList[idx]))
					--logError("tag="..tostring(tag))
					-- ZTD.PoolManager.RemoveGameItem(cfg.balloonPrefab, bombObj)
					skillMgr:AddSkill(
						skillId, 
						{isSelf = IsSelf, 
						enemyCtrl = tgEnemey,
						pos = skillPosition,
						ratio = data.Ratio, 
						heroPos = heroPos,
						BalloonMode = idx,
						UsePositionId = PositionId,
						AttackCount = data.AttackCount,
						DragonEnd = tag,
						bombPos = {bombWorldPos = bombPosList[idx].bombWorldPos, bombSelfPos = bombPosList[idx].bombSelfPos},
						callBack = function ()
						end})
				end)

				time = time + 1.4
			end	
		end
		if IsSelf then
			local avData = data.AttackInfo
			local f_id = avData.KillID
			local n_id = avData.SelfID
			
			-- 向屏幕中央靠拢(0,0)
			local function __hardFixMedal(lpos, wpos)
				local offsetX
				local offsetY
				local offVar = 1
				
				if lpos.x > 0 then
					offsetX = -offVar
				elseif lpos.x < 0 then	
					offsetX = offVar
				end	
				if lpos.y > 0 then
					offsetY = -offVar
				elseif lpos.y < 0 then	
					offsetY = offVar
				end			
				
				local fixPos = Vector3(wpos.x + offsetX, wpos.y + offsetY, wpos.z)
				return fixPos;
			end
			local coinPos = __hardFixMedal(skillPosition, ZTD.MainScene.GetMapObj().position + skillPosition)
			local medalUi = ZTD.BalloonMgr.CreateMedal(PositionId, coinPos, 10005, data.Ratio, f_id, n_id)
		end
	end
end

function TdEnemyMgr:SCPushMonsterBuff(pData)
	--logError("SCPushMonsterBuff State:" .. pData.State .. ",PositionID:" .. pData.PositionID)
	local buildCtrl = self:GetCtrlById(pData.PositionID);
	-- 0.开始1.结束
	if buildCtrl then
		if pData.State == 0 then
			buildCtrl:UpdateBuffer(pData.BuffType);
		elseif pData.State == 1 then
			buildCtrl:UpdateBuffer(pData.BuffType, true);
		end
	end	
end

function TdEnemyMgr:SCPushMonsterDead(pData)
	local tableId = pData.TableID;
	local dieId = pData.PositionID;
	
	if not self._dieRecord[tableId] then
		self._dieRecord[tableId] = {};
	end
	self._dieRecord[tableId][dieId] = true;	
	--logError("-----------------SCPushMonsterDed OnPushDieRecord:" .. tableId .. "," .. dieId);
end	

function TdEnemyMgr:CheckPoxEnd(data, MoneyEarn)	
	if data.Bom ~= nil and data.Bom.UsePositionId ~= 0 and data.Bom.AllOver then
		local masterId = data.Bom.UsePositionId
		if data.Type == 4 then
			local f_id = data.AttackInfo.KillID
			local n_id = data.AttackInfo.SelfID
			-- logError("---------!!!ScMoneyChange data.Type:" .. data.Type .. ",playerId:" .. data.PlayerId .. ",PositionId:" .. data.PositionId .. ",KillID:" .. f_id .. ",SelfID:".. n_id .. ",MoneyEarn:" .. MoneyEarn .. ",Eared:" .. tostring(data.Eared));
			ZTD.PoisonMedalMgr.FinshMedal(masterId)
		elseif data.Type == 20 then
			ZTD.BalloonMgr.FinshMedal(masterId)
		end
	end
end	

function TdEnemyMgr:ScMoneyChange(data)
	--for k, data in ipairs(pData.Info) do
		local scMoney = data.Money;
		local playerId = data.PlayerId
		local isSelf = (playerId == ZTD.PlayerData.GetPlayerId());
		local preScMoney = ZTD.TableData.GetData(playerId, "Money");
		if not preScMoney then
			preScMoney = scMoney;
		end
		local MoneyEarn = scMoney - preScMoney;

		-- 立即设置同步金币
		if scMoney > 0 and not isSelf then
			-- logError("scMoney="..tostring(scMoney))
		end
		ZTD.TableData.SetData(playerId, "Money", scMoney);

		--logError("ScMoneyChangeScMoneyChange v.UniqueId:" .. data.HeroUniqueId .. ",v.Money:" .. MoneyEarn);
		if isSelf then
			-- 同步自己的总金币
			ZTD.GoldData.Gold.Sync = scMoney;
			-- 检查毒爆怪或气球怪结束情况
			self:CheckPoxEnd(data, MoneyEarn);
			-- 设置个别炮台金币
			ZTD.TableData.WriteHeroUuidMoeny(data.HeroUniqueId, MoneyEarn);
			-- -- 魅魔转盘
			if data.MonsterId > 0 then
				-- log("ScMoneyChange="..GC.uu.Dump(data))
			end	
			if data.MonsterId == 10005 then
				--logError("ScMoneyChange="..GC.uu.Dump(data))
			end
		end
		--if MoneyEarn > 0 then
			-- logError("ScMoneyChange="..GC.uu.Dump(data))
		--end
		-- 更新各种金币增量
		ZTD.Notification.GamePost(ZTD.Define.MsgScMoneyChange, data, MoneyEarn);
		if data.MxlSealMoney then
			ZTD.Notification.GamePost(ZTD.Define.RefreshSealMoney, data)
		end
		--logWarn("---------!!!playerIdplayerIdplayerIdplayerId:" .. playerId .. ",scMoney:" .. scMoney);
		if data.Type == 18 then
			return
		end
		-- --巨人5级以下中奖
		if data.Type == 22 and MoneyEarn > 0 then
			-- logError("ScMoneyChange="..GC.uu.Dump(data))
			-- logError("MoneyEarn="..tostring(MoneyEarn))
			local cfg = ZTD.MainScene.GetEnemyCfg(10008)
			local tgEnemey = self._ctrlList[data.PositionId]
			if tgEnemey then
				local coinDropPos = tgEnemey:GetObjPos()
				ZTD.GoldFlyFactor.PlayCoinWork(data, isSelf, MoneyEarn, coinDropPos, cfg)
			end
			return
		end
		local f_id = data.AttackInfo.KillID;
		local n_id = data.AttackInfo.SelfID;
		if MoneyEarn > 0 and data.Ratio > 0 then
			-- logError("ScMoneyChange="..GC.uu.Dump(data))
			-- logError("---------!!!ScMoneyChange data.Type:" .. data.Type .. ",playerId:" .. data.PlayerId .. ",PositionId:" .. data.PositionId .. ",KillID:" .. f_id .. ",SelfID:".. n_id .. ",MoneyEarn:" .. MoneyEarn .. ",Eared:" .. tostring(data.Eared));
			self:ReadyDestory(data.PositionId, playerId, MoneyEarn, data);
		elseif data.Bom.AllOver and data.Type == 17 then
			self:ReadyDestory(data.PositionId, playerId, MoneyEarn, data);
		elseif data.Eared >= 0 and isSelf == false then
			self:ReadyDestory(data.PositionId, playerId, data.Eared, data);
		elseif MoneyEarn < 0 and isSelf then
			local totalGold = ZTD.GoldData.Gold;
			totalGold:Add(MoneyEarn);
			ZTD.Notification.GamePost(ZTD.Define.MsgRefreshGold, totalGold.Show);
		end
	--end
end

-- 先从表中移除，然后等待动画播放完毕后再实际释放资源

function TdEnemyMgr:ReadyDestory(delId, playerId, pMoneyEarn, pDieData)
	--logError("delId="..tostring(delId))
	local delCtrl = self._ctrlList[delId];
	-- logError("_ctrlList="..GC.uu.Dump(self._ctrlList))
	-- logError("delCtrl="..GC.uu.Dump(delCtrl))
	if delCtrl then
		self._ctrlList[delId] = nil;
		-- logError("delId="..tostring(delId))
		self._readyDelCtrlList[delId] = delCtrl;
		delCtrl:SetDie(playerId, pMoneyEarn, pDieData);
	else
		if playerId == ZTD.PlayerData.GetPlayerId() then
			
			if not self.__DCStack then
				self.__DCStack = {};
			end
			
			if #self.__DCStack > 0 then
				local rInx = #self.__DCStack;
				if rInx % 2 == 0 then
					rInx = -(rInx / 2);
				end
				local r3v = Vector3(0.3 * rInx, 0.3 * rInx, 0);
				ZTD.GoldFlyFactor.PlayCoinWork(pDieData, true, pMoneyEarn, ZTD.MainScene.GetMapObj().position + r3v, nil);
			else
				ZTD.GoldFlyFactor.PlayCoinWork(pDieData, true, pMoneyEarn, ZTD.MainScene.GetMapObj().position, nil);				
			end
			
			table.insert(self.__DCStack, #self.__DCStack + 1, true);
			ZTD.GameTimer.DelayRun(0.5, function () table.remove(self.__DCStack, 1) end)			
		end
	--else
	--	logError("---------!!!ReadyDestory FailFailFailFailFailFailFailFailFail");
	end
end

function TdEnemyMgr:Init()
	SUPER.Init(self);
	self:ctorCustom();
	
	--金币结算关联角色死亡的确定，故注册监听
	ZTD.Notification.NetworkRegister(self, "SCSyncMoney", self.ScMoneyChange);
	--毒爆僵尸获得的毒爆次数
	ZTD.Notification.NetworkRegister(self, "SCPoisonBomTimes", self.SCPoisonBomTimes);
	--毒爆状态暂存列表
	ZTD.Notification.NetworkRegister(self, "SCPoisonbombTypes", self.SCPoisonbombTypes);
	--气球怪获得的免费次数
	ZTD.Notification.NetworkRegister(self, "SCPushBalloonTimes", self.SCPushBalloonTimes);
	
	ZTD.Notification.NetworkRegister(self, "SCPushMonsterDead", self.SCPushMonsterDead)
	
	ZTD.Notification.NetworkRegister(self, "SCPushMonsterBuff", self.SCPushMonsterBuff)
	--
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgGameResume, self.OnGameResume)
end

function TdEnemyMgr:_releaseList(isResume)
	self._buildStandByData = {};
	self._buildSyncData = {};
	for id, v in pairs(self._readyDelCtrlList) do
		if isResume then
			v:CheckPlayCoin();
		end	
		v:Release();
	end
	self._readyDelCtrlList = {};
	self._enemyTransformMap = {};
	if self._touchChecker then
		ZTD.Flow.GetTouchMgr():RemoveTouch(self._touchChecker);
		self._touchChecker = nil;
	end	
	SUPER.Release(self);
end

function TdEnemyMgr:Release()
	self:_releaseList();	
	ZTD.Notification.NetworkUnregisterAll(self);
	ZTD.Notification.GameUnregisterAll(self);
end

-- 后台处理
function TdEnemyMgr:OnPause()
	self:CleanDieRecord();
end

function TdEnemyMgr:CleanDieRecord()
	self._dieRecord = {};
end

function TdEnemyMgr:OnResume()
	self:_releaseList(true);
	
	-- 在游戏中才有请求
	--[[
	if ZTD.BattleView.inst ~= nil then	
		if ZTD.MainScene.WaitTipRoomInx then
			ZTD.Utils.CloseWaitTip(ZTD.MainScene.WaitTipRoomInx);
			ZTD.MainScene.WaitTipRoomInx = nil;
		end
		ZTD.MainScene.WaitTipRoomInx = ZTD.Utils.ShowWaitTipEx();
	end
	--]]
end

function TdEnemyMgr:OnGameResume(isCallSuss)
	if isCallSuss then
		
	end
end

return TdEnemyMgr;