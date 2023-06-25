local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local DragonLogic = GC.class2("ZTD_DragonLogic");

local DragonPrefab = "ZTD_SL_02_02";

function DragonLogic:ctor(_, dgUi)
	self._dragonUi = dgUi;
	local cfg = ZTD.DragonConfig[1];
	
	local mapInfo = ZTD.MainScene.GetMapInfo();
	local width = mapInfo.MaxX - mapInfo.MinX;
	
	local cx = width/2;
	
	local gapWidth = width / cfg.lineEffNums;
	
	self._lineData = {};
	for i = 1, cfg.lineEffNums do
		local modifyX = gapWidth * (i - 1) + gapWidth/2;
		self._lineData[i] = {};
		self._lineData[i].x = modifyX - cx;
		self._lineData[i].minX = gapWidth * (i - 1) - cx;
		self._lineData[i].maxX = gapWidth * (i) - cx;
	end
end

function DragonLogic:SetComboNode(comboNode)
	self._comboNode = comboNode;
	-- 在免费结算时，同步金币时使用
	ZTD.DragonLogic.ComboNode = comboNode;
	--logError("SetComboNodeSetComboNode:" .. tostring(comboNode));
end

function DragonLogic:GetRatio()
	return self._ratio or 1;
end

function DragonLogic:Release()
	if self._isActive then
		self._nodeDragon:SetActive(false);
		ZTD.PoolManager.RemoveGameItem(DragonPrefab, self._nodeDragon);
		self._nodeDragon = nil;
		self._isActive = false;
		ZTD.Flow.RemoveUpdateList(self);
	end
end

function DragonLogic:ActiveRoad(isSelf, attackInfo)
	self:Release();

	self._isSelf = isSelf;
	
	self._isEndReq = false;
	
	self._isEnd1 = false;
	self._isEnd2 = false;
	
	local cfg = ZTD.DragonConfig[1];
	
	-- 初始化龙的起点状态
	self._nodeDragon = ZTD.PoolManager.GetGameItem (DragonPrefab, ZTD.MainScene.SceneObj:FindChild("node_3d"));
	
	local mapInfo = ZTD.MainScene.GetMapInfo();
	-- 设置龙模型初始状态
	local gates = mapInfo.gates;	
	local src_pz = -43;--self._nodeDragon.localPosition.z;
	-- 根据出口和入口计算出路程的点
	self._p1 = Vector3(gates[3].x + cfg.gapX, gates[3].y + cfg.gapY, src_pz);
	self._p2 = Vector3(gates[4].x - cfg.gapX, gates[4].y + cfg.gapY, src_pz);
	self._p3 = Vector3(gates[1].x - cfg.gapX, gates[1].y + cfg.gapY, src_pz);
	self._p4 = Vector3(gates[2].x + cfg.gapX, gates[2].y + cfg.gapY, src_pz);

	self._srcPos = self._p3;
	
	-- 开启上路火特效，关掉下路火
	self._nodeDragon:FindChild("huo_1"):SetActive(true);
--	self._nodeDragon:FindChild("huo_2"):SetActive(false);
	self._nodeDragon.localRotation = Quaternion.Euler(cfg.srcX, cfg.srcY, cfg.srcZ);
	-- 上路技能释放点
	self._skillPoint = self._nodeDragon:FindChild("skill_p1");
	self._nodeDragon.localPosition = self._srcPos;
	self._nodeDragon:SetActive(true);
	
	self._nowSpd = (self._p2.x - self._p1.x) / cfg.runTime;
	
	-- 记录时间运动
	self._timeGroup = {};
	self._timeInx = 1;

	-- 整体运动时间
	self._runTime = 0;

	-- 是否激活动作
	self._isActive = true;
	
	-- 记录地面爆火格子
	self._count = 0;
	self._girdMark = {};
	self._girdMark[1] = {};
	self._girdMark[2] = {};
	self._girdYInx = 1;	
	
	local function moveFunc(dt)
		local localPos = self._nodeDragon.localPosition;
		self._nodeDragon.localPosition = Vector3(localPos.x + self._nowSpd * dt, localPos.y, localPos.z);
		self:CheckFireActive();
	end
	
	local function turnBackFunc()
		self._nodeDragon.localPosition = self._p3;
		self._nodeDragon.localRotation = Quaternion.Euler(cfg.srcX, -cfg.srcY, -cfg.srcZ);
		self._nodeDragon:FindChild("huo_1"):SetActive(true);
		--self._nodeDragon:FindChild("huo_2"):SetActive(true);		
		self._skillPoint = self._nodeDragon:FindChild("skill_p2");
		self._girdYInx = 2;	
		self._nowSpd = (self._p4.x - self._p3.x) / cfg.runTime;
	end
	
	local function endFunc()
		self:Release();
		
		if not self._isEndReq then
			local lastHitPos = Vector3(0, 0, 0);
			local lastHitId = cfg.fireEndSkillId_Empty;		
			self:_reqEnd(lastHitId, lastHitPos, lastHitPos)
		end	
	end
	
--[[
	self._timeGroup[1] = 
	{
		time = cfg.runTime;
		doFunc = moveFunc;
	}
	
	self._timeGroup[2] = 
	{
		time = cfg.runTime + cfg.delayTime;
		startFunc = turnBackFunc;
	}
--]]
	turnBackFunc();
	self._timeGroup[1] = 
	{
		startFunc = turnBackFunc;
		time = cfg.runTime;--cfg.runTime + cfg.delayTime + cfg.runTime;
		doFunc = moveFunc;
		endFunc = endFunc;
	}
	
	ZTD.Flow.AddUpdateList(self);
end
	
function DragonLogic:ReqRoad(PropsID, pSussCb)
	local cfg = ZTD.DragonConfig[1];
	
	if self._isActive then
		local language = ZTD.LanguageManager.GetLanguage("L_ZTD_DragonConfig");
		ZTD.ViewManager.ShowTip(language.cdTip);
		return;
	end
	
	self._ratio = ZTD.PlayerData.GetMultiple() or 1;

	local function sucCb(err, Data)

		-- 巨龙之怒一定是root触发者
		local medalUi = self._dragonUi;
		local avData = Data.AttackInfo;
		local f_id = avData.KillID;
		local n_id = avData.SelfID;		
		local comboNode = ZTD.ComboShowTree.LinkCombo({atkType = ZTD.AttackData.TypeDragon, medalUi = medalUi, goldData = ZTD.GoldData.DragonGold}, f_id, n_id);
		self:SetComboNode(comboNode);
		self:ActiveRoad(true);
		
		if pSussCb then
			pSussCb();
		end
	end
	local function errCb(err, data)
		-- ZTD.Utils.CloseWaitTip(winx);
		logError("----CSDragonReleaseReqCSDragonReleaseReq:" .. err)
	end
	ZTD.Request.CSDragonReleaseReq({Ratio = self._ratio, PropsID = PropsID}, sucCb, errCb)
	
end

-- 跳到指定时间
function DragonLogic:Skip2Pos(st)
	-- ZTD.Flow.RemoveUpdateList(self);	
	-- 把坐标和时间重置
	self._nodeDragon.localPosition = self._srcPos;
	self._timeInx = 1;
	self._runTime = 0;
	
	local oldGirdInx = self._girdYInx;
	self:UpdatePos(st)

	-- ZTD.Flow.AddUpdateList(self);
end

function DragonLogic:IsTimeOut()
	-- 如果进入到这个函数，已经收到了服务器的推送，则act为false时，已经强制结算了，此时应该要弹出结算框
	if not self._isActive then
		return true;
	elseif not self._isSelf then
		return true;	
	elseif next(self._timeGroup) == nil then
		return true;
	end
	
	return (self._runTime >= self._timeGroup[#self._timeGroup].time);
end
	
function DragonLogic:UpdatePos(dt)
	if self._isActive then
		local pt = dt;
		self._runTime = self._runTime + pt;
		while self._runTime >= self._timeGroup[self._timeInx].time do
			local oldG = self._timeGroup[self._timeInx];

			if oldG.endFunc then
				oldG.endFunc();
			end
		
			self._timeInx = self._timeInx + 1;
			if self._timeInx > #self._timeGroup then
				break;
			else
				if self._timeGroup[self._timeInx].startFunc then
					self._timeGroup[self._timeInx].startFunc();
				end	
			end
			
			pt = self._runTime - oldG.time;
		end
		
		if self._timeGroup[self._timeInx] and self._timeGroup[self._timeInx].doFunc then
			self._timeGroup[self._timeInx].doFunc(pt);
		end
	end
end

function DragonLogic:_reqEnd(lastHitId, lastHitPos1, lastHitPos2)	
	local skillMgr = ZTD.Flow.GetSkillMgr();
	skillMgr:AddSkill(lastHitId, 
			{isSelf = self._isSelf,
			dir = 0,
			pos = lastHitPos1,
			ratio = self._ratio,						
			DragonMode = 1,
			DragonEnd = false,
			callBack = function ()
				skillMgr:AddSkill(lastHitId, 
						{isSelf = self._isSelf,
						dir = 0,
						pos = lastHitPos2,
						ratio = self._ratio,						
						DragonMode = 2,
						DragonEnd = true,
						callBack = function ()
							-- log(os.date("%Y-%m-%d %H:%M:%S:") .. "DragonLogic end222222222222222222222222")
						end});
			end
			});	
	self._isEndReq = true;
end	

function DragonLogic:CheckFireActive()
	local cfg = ZTD.DragonConfig[1];
	local skillMgr = ZTD.Flow.GetSkillMgr();		
	-- 获取喷火点在地图上的坐标
	self._skillPoint.transform.parent = ZTD.MainScene.GetMapObj();
	local mapX = self._skillPoint.localPosition.x;
	self._skillPoint.transform.parent = self._nodeDragon;

	local modfX;
	local markInx
	for i, v in ipairs(self._lineData) do
		if mapX > v.minX and mapX < v.maxX then
			modfX = v.x;
			markInx = i;
			break;
		end
	end
	


	local lastHitId;
	if modfX and self._girdMark[self._girdYInx][markInx] == nil then
		local localPos;
		--if self._girdYInx == 1 then
			local localPos1 = Vector3(modfX, cfg.fireFloorY1, 0);
		--else
			local localPos2 = Vector3(modfX, cfg.fireFloorY2, 0);
		--end
		
		self._count = self._count + 1;
		
		local skillId = cfg.fireSkillId1;
		--[[if self._count % 2 == 0 then
			skillId = cfg.fireSkillId2;
		end--]]
		
		--logError("----DragonModeDragonModeDragonModeDragonModes:" .. self._girdYInx);
			
		
		-- 第一格处理
		if markInx == 1 then
			ZTD.PlayMusicEffect("ZTD_dragon_way", nil, nil, true);
		end	
		--[[
		if self._girdYInx == 2 and markInx == 1 then
			ZTD.PlayMusicEffect("ZTD_dragon_way", nil, nil, true);
		elseif self._girdYInx == 1 and markInx == #self._lineData then
			ZTD.PlayMusicEffect("ZTD_dragon_way", nil, nil, true);
		end
		--]]
		-- 最终格处理		
		if markInx == #self._lineData then
			--lastHitPos = Vector3(modfX, cfg.fireFloorY2, 0);
			--lastHitId = cfg.fireEndSkillId;
			self._isEnd2 = true;
			self._isEnd1 = true;
		end
		
		-- 每格火请求,如果是结束，结束请求放在最后一格火的请求回调后面
		skillMgr:AddSkill(skillId, 
					{isSelf = self._isSelf,
					dir = 0,
					pos = localPos1,
					ratio = self._ratio,
					DragonMode = 1,--self._girdYInx,
					DragonEnd = false});
		self._girdMark[1][markInx] = true;	
				
		skillMgr:AddSkill(skillId, 
					{isSelf = self._isSelf,
					dir = 0,
					pos = localPos2,
					ratio = self._ratio,
					DragonMode = 2,--self._girdYInx,
					DragonEnd = false});
		self._girdMark[2][markInx] = true;
		

		if self._isEnd2 then
			self:_reqEnd(cfg.fireEndSkillId, 
					Vector3(0, cfg.fireFloorY1, 0),
					Vector3(0, cfg.fireFloorY2, 0));
		end
	-- 如果不在地图格上，走出去后依然没有发结束，也要发送一次结束请求（切后台处理）
	elseif markInx == nil then
		local mapInfo = ZTD.MainScene.GetMapInfo();		
		if mapX > mapInfo.MaxX and not self._isEnd2 then
			lastHitPos = Vector3(0, 0, 0);
			lastHitId = cfg.fireEndSkillId_Empty;
			self._isEnd2 = true;
			self._isEnd1 = true;
		end			
	end
	
	if self._isSelf and lastHitId then
		--logError("----End skill skillskillskillskillskillskills:" .. self._girdYInx);
		self:_reqEnd(lastHitId, lastHitPos, lastHitPos)
	end	
end

function DragonLogic:FixedUpdate(dt)
	self:UpdatePos(dt);
end

function DragonLogic:OnPause()
	self:Release();
	
	--[[
	if self._isActive then
		self._backSave = {};
		self._backSave._girdYInx = self._girdYInx;
		self._backSave._isEnd2 = self._isEnd2;
		self._backSave._isEnd1 = self._isEnd1;
	end	
	--]]
end

function DragonLogic:OnResume()
	
end

return DragonLogic;