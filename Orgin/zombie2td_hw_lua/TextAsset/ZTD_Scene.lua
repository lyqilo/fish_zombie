local GC = require("GC")
local CC = require("CC")
local ZTD = require("ZTD")
local tools = GC.uu

local TdScene = {};
local MASK_BG;
function TdScene.Init()
	if not MASK_BG then
		MASK_BG = GameObject.Find("BG_ZTD");
	end	
	MASK_BG:SetActive(false);
	
	local cfg = ZTD.ConstConfig[1];
	-- 目前地图只有一个ID
	local mapCfg = ZTD.MapConfig[1];
	
	local BattleField = GameObject.Find("BattleField");
	TdScene.SceneObj = ResMgr.LoadPrefab(cfg.ResPath, "ZTD_Scene", BattleField.transform, "ZTD_Scene");
	TdScene.MapObj = TdScene.SceneObj:FindChild("sp_map");
	TdScene.SpecialEnemyObj = TdScene.SceneObj:FindChild("sp_SpecialEnemy");
	TdScene.CamTrans = TdScene.SceneObj:FindChild("Camera").transform
	TdScene.CamObj = TdScene.SceneObj:FindChild("Camera"):GetComponent("Camera");
	TdScene.UICamObj = GameObject.Find("Main/UICamera"):GetComponent("Camera");
	TdScene.canvas = GameObject.Find("Main/Canvas");
	
	local fitWidth = cfg.LogicWidth;
	local screenRadio = (Screen.height / Screen.width);
	if screenRadio < 0.5625 then
		fitWidth = cfg.LogicWidthBig;
	end
	
	TdScene.MapWidth = fitWidth;
	TdScene.MapHeight = fitWidth * screenRadio;
	
	TdScene.CamObj.orthographicSize = (fitWidth * screenRadio) / 100 / 2; --3.8
	
	TdScene.LockObj = TdScene.SceneObj:FindChild("TD_LOCKING");
	
	TdScene.MapInfo = {};
		
	TdScene.isPressUI = false
	TdScene.MapInfo.gates = {};
	TdScene.MapInfo.MaxX = 0;
	TdScene.MapInfo.MinX = 99999;
	TdScene.MapInfo.MaxY = 0;
	TdScene.MapInfo.MinY = 99999;	
	for i = 1, mapCfg.TotalGate do
		TdScene.MapInfo.gates[i] = {};
		local gate = TdScene.MapInfo.gates[i];
		local tfGate = TdScene.MapObj:FindChild("point_gate" .. i).transform;
		gate.x = tfGate.x;
		gate.y = tfGate.y;

		if TdScene.MapInfo.MaxX < gate.x then
			TdScene.MapInfo.MaxX = gate.x
		end
		
		if TdScene.MapInfo.MinX > gate.x then
			TdScene.MapInfo.MinX = gate.x
		end

		if TdScene.MapInfo.MaxY < gate.y then
			TdScene.MapInfo.MaxY = gate.y
		end
		
		if TdScene.MapInfo.MinY > gate.y then
			TdScene.MapInfo.MinY = gate.y
		end		
	end	
	
	TdScene.MapInfo.cross = {};
	for i = 1, mapCfg.TotalCross do
		TdScene.MapInfo.cross[i] = {};
		local cross = TdScene.MapInfo.cross[i];
		local tfCross = TdScene.MapObj:FindChild("point_cross" .. i).transform;
		cross.x = tfCross.x;
		cross.y = tfCross.y;		
	end
	
	
	TdScene.MapInfo.setup = {};
	local childCount = TdScene.MapObj.transform.childCount;
	if childCount > 0 then
		for i = 0,childCount - 1 do
			local tfSetup = TdScene.MapObj.transform:GetChild(i);
			local pointName = tfSetup.gameObject.name;
			local findKey = "point_setup_";
			local findInx = string.find(pointName, findKey);
			if findInx then
				local findPos = findInx + string.len(findKey);
				local pick_str = string.sub(pointName, findPos, string.len(pointName));
				local str_arr = string.split(pick_str, "_");
				local groupInx = tonumber(str_arr[1]);
				local setupInx = tonumber(str_arr[2]);
				
				if not TdScene.MapInfo.setup[groupInx] then
					TdScene.MapInfo.setup[groupInx] = {};
				end
				TdScene.MapInfo.setup[groupInx][setupInx] = {};
				local setup = TdScene.MapInfo.setup[groupInx][setupInx];
				setup.x = tfSetup.x;
				setup.y = tfSetup.y;
			end			
		end
	end
	
	TdScene.PanGirdData = ZTD.GirdData:new();	
	local mapInfo = ZTD.MainScene.GetMapInfo();
	local width = mapInfo.MaxX - mapInfo.MinX;
	local high = mapInfo.MaxY - mapInfo.MinY;
	TdScene.PanGirdData:Init(width, high, cfg.GirdXNums, cfg.GirdYNums, 0.5, 0.5);	
	
	TdScene.NowTargets = {};
	TdScene.ReadNowTargets();
	TdScene.IsReqLockOk = true;
	
	ZTD.Notification.NetworkRegister(TdScene, "SCSyncGetTowerMonster", TdScene.OnSyncMonster)
	ZTD.Notification.NetworkRegister(TdScene, "SCTowerMonster", TdScene.OnBuildMonster)
	ZTD.Notification.NetworkRegister(TdScene, "SCTowerPlayerLockTarget", TdScene.OnPlayerLockEnemy)	
end

--获取气球怪爆炸点
function TdScene.GetBalloonPoint(pos)
	local cfg = ZTD.BalloonConfig.BombPointCfg
	-- logError("cfg="..GC.uu.Dump(cfg))
	local tab = {}
	local disTab = {}
	local ballTab = {}
	for k, v in pairs(cfg) do
		local ballpos = Vector3(v.x, v.y, 0)
		local dis = Vector3.Distance(Vector3(pos.x, pos.y, 0), ballpos)
		tab[k] = {}
		tab[k].dis = dis
		tab[k].pos = ballpos
		table.insert(disTab, dis)
	end
	-- logError("tab="..GC.uu.Dump(tab))
	table.sort(disTab)
	-- logError("disTab="..GC.uu.Dump(disTab))
	for i = 1, 3, 1 do
		for k, v in pairs(tab) do
			if disTab[i] == v.dis then
				table.insert(ballTab, v.pos)
				break
			end
		end
	end
	-- logError("ballTab="..GC.uu.Dump(ballTab))
	return ballTab
end

--从屏幕坐标点发射射线
--screenPos 屏幕坐标点
function TdScene.ScreenRayToWorld(screenPos,specicalLayer)
	local layerMask = specicalLayer
	local ray = TdScene.UICamObj:ScreenPointToRay(screenPos)
	local isHit, hitInfo = UnityEngine.Physics.Raycast(
						   ray,
	 					   nil,
	 					   1000,
	 					   layerMask)
	if isHit then
		return hitInfo
	end
end

--屏幕坐标转换为ui本地坐标
function TdScene.ScreenToUILocalPos(pos)
	local out
	local _, localPos = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(
		TdScene.canvas:GetComponent("RectTransform"), 
		pos, 
		TdScene.UICamObj, out)
		
	return localPos
end

-- groupInx 代表行 setup代表列，不会超过10个
function TdScene.HeroPosId2GS(positionId)
	local setup = positionId % 10;
	local groupInx = math.floor(positionId / 10);
	return groupInx, setup;
end

function TdScene.HeroGS2PosId(groupInx, setup)
	return (groupInx * 10) + setup;
end	

function TdScene.OnPlayerLockEnemy(_, data)
	for _, v in ipairs(data.LockInfo) do
		ZTD.TableData.SetLockTarget(v.PositionId, v.TargetPositionId);
	end
end

function TdScene.OnBuildMonster(_, monstersData)	
	local tableId = ZTD.TableData.GetTable();
	
	local function dealFunc(tId)
		if monstersData.TableID == tId then
			local monstersInfo = monstersData.Info;
			local enemyMgr = ZTD.Flow.GetEnemyMgr();
			enemyMgr:PushNewBuild(monstersInfo);
		end
	end
	
	if tableId == -1 then
		ZTD.TableData.AddTFunc(dealFunc);
	else	
		dealFunc(tableId);	
	end	
end

function TdScene.OnSyncMonster(_, monstersData)
	
	--[[
	-- 关闭等待房间转菊花
	if ZTD.MainScene.WaitTipRoomInx then
		ZTD.Utils.CloseWaitTip(ZTD.MainScene.WaitTipRoomInx);
		ZTD.MainScene.WaitTipRoomInx = nil;
	end
	--]]
	
	local tableId = ZTD.TableData.GetTable();
	
	local function dealFunc(tId)
		if monstersData.TableID == tId then
			local monstersInfo = monstersData.Info;
			local enemyMgr = ZTD.Flow.GetEnemyMgr();
			enemyMgr:PushSync(monstersInfo);
		end
	end
	
	if tableId == -1 then
		ZTD.TableData.AddTFunc(dealFunc);
	else	
		dealFunc(tableId);	
	end		
end

function TdScene.SetFps(fps)
	if ZTD.BattleView.inst then
		local bv = ZTD.BattleView.inst;
		bv:setFps(fps);
	end
end	

function TdScene.GetCamera()
	return TdScene.CamObj;
end

function TdScene.HideCamera()
	if not TdScene.CamObj then return end
	TdScene.CamObj.enabled = false
end

function TdScene.ShowCamera()
	if not TdScene.CamObj then return end
	TdScene.CamObj.enabled = true
end

function TdScene.GetCameraTrans()
	return TdScene.CamTrans
end

-- 设置玩家选中的敌人
function TdScene.SetPlayerLockTarget(emyCtrl)
	if TdScene.nowLockEnemy then
		if TdScene.nowLockEnemy == emyCtrl then
			return;
		end
		TdScene.nowLockEnemy:setLock(false);
	end
	TdScene.nowLockEnemy = emyCtrl;
	if emyCtrl == nil then
		return;
	end
	TdScene.nowLockEnemy:setLock(true);
end

function TdScene.GetPlayerLockTarget()
	return TdScene.nowLockEnemy;
end	

-- 通过英雄的posId获取正在锁定的enemyctrl
function TdScene.GetLockCtrl(posId)
	local enemyId = ZTD.TableData.GetLockTarget(posId);
	if enemyId then
		return ZTD.Flow.GetEnemyMgr():GetCtrlById(enemyId);
	end
end

-----------取配置相关
function TdScene.GetHeroCfg(heroId)
	if not TdScene.HeroCfgDatas then
		TdScene.HeroCfgDatas = {};
		local heroCfgs = ZTD.HeroConfig;
		for _, v in ipairs(heroCfgs) do
			TdScene.HeroCfgDatas[v.id] = v;
		end
	end
	return TdScene.HeroCfgDatas[heroId];
end

function TdScene.GetEnemyTypeCfg(eType)
	if not TdScene.EnemyTypeCfgDatas then
		TdScene.EnemyTypeCfgDatas = {};
		local EnemyTypeConfig = ZTD.EnemyTypeConfig;
		for _, v in ipairs(EnemyTypeConfig) do
			TdScene.EnemyTypeCfgDatas[v.TypeEnemy] = v;
		end
	end
	return TdScene.EnemyTypeCfgDatas[eType];
end

function TdScene.GetEnemyCfg(enemyId)
	if not TdScene.EnemyCfgDatas then
		TdScene.EnemyCfgDatas = {};
		local enemyCfgs = ZTD.EnemyConfig;
		for _, v in ipairs(enemyCfgs) do
			TdScene.EnemyCfgDatas[v.id] = v;
		end
	end
	return TdScene.EnemyCfgDatas[enemyId];
end

function TdScene.GetSkillCfg(skillId)
	if not TdScene.SkillCfgDatas then
		TdScene.SkillCfgDatas = {};
		local skillCfgs = ZTD.SkillConfig;
		for _, v in ipairs(skillCfgs) do
			TdScene.SkillCfgDatas[v.id] = v;
		end
	end
	return TdScene.SkillCfgDatas[skillId];
end

function TdScene.GetEnemyEffCfg(id)
	if not TdScene.EnemyEffCfgDatas then
		TdScene.EnemyEffCfgDatas = {};
		local EffConfigs = ZTD.EnemyEffConfig;
		for _, v in ipairs(EffConfigs) do
			TdScene.EnemyEffCfgDatas[v.id] = v;
		end
	end
	return TdScene.EnemyEffCfgDatas[id];
end

function TdScene.GetEffTransformConfig(name)
	if not TdScene.EffTransformCfgDatas then
		TdScene.EffTransformCfgDatas = {};
		local EffConfigs = ZTD.EffTransformConfig;
		for _, v in ipairs(EffConfigs) do
			TdScene.EffTransformCfgDatas[v.name] = v;
		end
	end
	return TdScene.EffTransformCfgDatas[name];
end

-------
function TdScene.GetMapScore(mapId, posId, isVip)
	if not TdScene.MapCfgDatas then
		TdScene.MapCfgDatas = {};
		local mapCfg = ZTD.MapConfig;
		for _, v in ipairs(mapCfg) do
			TdScene.MapCfgDatas[v.ID] = {};
			TdScene.MapCfgDatas[v.ID].PositionInfo = {};
			TdScene.MapCfgDatas[v.ID].TotalScore = nil;
			local info = isVip and v.VipPositionInfo or v.PositionInfo
			for __, vv in ipairs(info) do
				TdScene.MapCfgDatas[v.ID].PositionInfo[vv.ID] = vv.Score;
			end
		end
	end
	return TdScene.MapCfgDatas[mapId].PositionInfo[posId];
end

function TdScene.RefreshMapCfgDatas(isVip)
	local mapCfg = ZTD.MapConfig;
	for _, v in ipairs(mapCfg) do
		local info = isVip and v.VipPositionInfo or v.PositionInfo
		-- logError("info="..GC.uu.Dump(info))
		for __, vv in ipairs(info) do
			TdScene.MapCfgDatas[v.ID].PositionInfo[vv.ID] = vv.Score;
		end
	end
end

--暂时只用于开启自动时的处理，特殊处理了连接怪的情况
function TdScene.CheckEnemyInRange(checkPos, checkRange)
	local ret;
	local list = ZTD.Flow.GetEnemyMgr():GetCtrlList();
	local minDistance = checkRange;
	for _, v in pairs(list) do
		--如果该怪是连接怪且玩家筛选了自动攻击连接怪
		if TdScene.NowTargets[10007] and v.IsConnect then
			local distance = Vector3.Distance(checkPos, v:getEnemyObj().localPosition);
			if minDistance >= distance then
				minDistance = distance;
				ret = v;
			end
		elseif not v._isPlayingDie and not v:isLost() and TdScene.NowTargets[v:getCfgId()] and not v.IsConnect then
			local distance = Vector3.Distance(checkPos, v:getEnemyObj().localPosition);
			if minDistance >= distance then
				minDistance = distance;
				ret = v;
			end
		end
	end
	
	return ret;
end

function TdScene.IsEnemyInRange(emyCtrl, checkPos, checkRange)
	if emyCtrl:isLost() then
		return false;
	end
	
	local distance = Vector3.Distance(checkPos, emyCtrl:getEnemyObj().localPosition);
	if checkRange >= distance then
		return true;
	else
		return false;
	end
end

function TdScene.GetSpecialMapObj()
	return TdScene.SpecialEnemyObj;
end

function TdScene.GetMapObj()
	return TdScene.MapObj;
end

function TdScene.GetMapInfo()
	return TdScene.MapInfo;
end

function TdScene.ShowMaskBg()
	MASK_BG:SetActive(true);
	if TdScene.SceneObj then 
		TdScene.SceneObj:SetActive(false);
	end
end

function TdScene.HideMaskBg()
	MASK_BG:SetActive(false);
	TdScene.SceneObj:SetActive(true);
end	

function TdScene.Release()
	tools.destroyObject(TdScene.SceneObj.gameObject)	
	ZTD.Notification.NetworkUnregisterAll(TdScene);
	
	ZTD.Flow.GetTouchMgr():RemoveTouch(TdScene.ObjTouchChecker);
	TdScene.ObjTouchChecker = nil;
	
	ZTD.Flow.GetTouchMgr():RemoveTouch(TdScene.MapTouchChecker);
	TdScene.MapTouchChecker = nil;	
	
	TdScene.OldReqLocks = nil;
	TdScene.IsReqLockOk = true;
	TdScene.SceneObj = nil
	TdScene.MapObj = nil
	TdScene.CamTrans = nil
	TdScene.CamObj = nil
end


function TdScene.AddTouchObj(touchObj, touchData, cb)
	if not TdScene.ObjTouchChecker then
		-- map obj
		local customData = {};
		customData.customPresseDownCheck = function()
			return true;
		end
		customData.customPresseUpCheck = function()
			ZTD.Notification.GamePost(ZTD.Define.MsgClkMap);
			return true;
		end
		TdScene.MapTouchChecker = ZTD.TouchChecker:new(ZTD.Define.LayerZombie, customData);
		ZTD.Flow.GetTouchMgr():AddTouch(TdScene.MapTouchChecker, -1);
		TdScene.MapTouchChecker:Register(TdScene.MapObj, TdScene.MapObj, {});
		
		--
		TdScene.ObjTouchChecker = ZTD.TouchChecker:new(ZTD.Define.LayerTouchObj);
		ZTD.Flow.GetTouchMgr():AddTouch(TdScene.ObjTouchChecker, 7);
	end	
	
	
	local funcsData = {};
	funcsData.upFunc = cb;
	TdScene.ObjTouchChecker:Register(touchObj, touchData, funcsData);	
end

function TdScene.PickTouch()
	return TdScene.ObjTouchChecker:PickTouch();
end	

function TdScene.IsPressUi()
	-- local evsys = GameObject.Find("EventSystem"):GetComponent("EventSystem");
	-- if GC.Platform.isWin32 then
	-- 	if(evsys:IsPointerOverGameObject()) then
	-- 		return true;
	-- 	end
	-- else	
	-- 	for i = 0, Input.touchCount - 1 do
	-- 		local touch = Input.touches[i];
	-- 		if(evsys:IsPointerOverGameObject(touch.fingerId)) then
	-- 			return true;
	-- 		end
	-- 	end
	-- end
	-- return false;
	-- log(TdScene.isPressUI)
	return not TdScene.isPressUI
end	
	
function TdScene.FixedUpdate(dt)
	TdScene.DealReadyLock();
end

-- 锁定处理
function TdScene.DealReadyLock()
	local readyLocks, customLockId = ZTD.TableData.GetReadyLockTarget();
	
	local reqLocks = {};
	
	if not TdScene.OldReqLocks then
		reqLocks = readyLocks;
	else
		for pos, tgId in pairs(readyLocks) do
			if TdScene.OldReqLocks[pos] ~= tgId then
				reqLocks[pos] = tgId;
			end
		end		
	end
	
	TdScene.OldReqLocks = {};
	if TdScene.IsReqLockOk then
		for pos, tgId in pairs(readyLocks) do
			TdScene.OldReqLocks[pos] = tgId;
		end
	end	
	
	if next(reqLocks) and TdScene.IsReqLockOk then
		TdScene.IsReqLockOk = false;
		local succCb = function(err, data)
			TdScene.IsReqLockOk = true;
			for _, li in ipairs(data.LockInfo) do
				local pos = li.PositionId;
				local tgId = li.TargetPositionId;

				ZTD.TableData.SetLockTarget(pos, tgId);
			end
			
			-- clean
			--logError("---!!!!cleancleanclean SetReadyLockTarget clean:");
			--ZTD.TableData.SetReadyLockTarget();
		end
		local errCb = function(err, data)
			TdScene.IsReqLockOk = true;
			if err == 10065 then
				--目标已被杀死，忽略
			else			
				logError("---!!!!CSTowerPlayerLockTargetReq:" .. tostring(err));
			end	
			-- clean
			ZTD.MainScene.SetPlayerLockTarget();
			ZTD.TableData.SetReadyLockTarget();
		end
		local data = {};
		data.LockInfo = {};
		
		for pos, tgId in pairs(reqLocks) do
			local li = {};
			li.PositionId = pos;
			li.TargetPositionId = tgId;
			data.LockInfo[#data.LockInfo + 1] = li;
			
			-- log("!!!!CSTowerPlayerLockTargetReq pppid:" .. pos .. ",tgId:" .. tostring(tgId))
		end

		ZTD.Request.CSTowerPlayerLockTargetReq(data, succCb, errCb)
		ZTD.TableData.SetReadyLockTarget();
	end
end

function TdScene.SetupPos2UiPos(worldPos)
	local currentCamera = TdScene.GetCamera();

	local UICamera = TdScene.UICamObj;

	local wPos = Vector3(worldPos.x, worldPos.y, 0);			
	local tpos = currentCamera:WorldToScreenPoint(wPos)
	local pos = UICamera:ScreenToWorldPoint(tpos)			
	
	return pos;
end

function TdScene.UiPos2SetupPos(uiPos)
	local currentCamera = TdScene.GetCamera();

	local UICamera = TdScene.UICamObj;

	local u_uiPos = Vector3(uiPos.x, uiPos.y, 0);			
	local tpos = UICamera:WorldToScreenPoint(u_uiPos)
	local pos = currentCamera:ScreenToWorldPoint(tpos)
	return pos;
end

function TdScene.ReadNowTargets()
	TdScene.NowTargets = {};
	
	local selectTable = GC.UserData.Load(ZTD.gamePath.."EnemySelect");
	local enemyCfgs = ZTD.EnemyConfig;
	for _, v in ipairs(enemyCfgs) do
		local strId = tostring(v.id);
		if selectTable[strId] == nil or selectTable[strId] == true then
			TdScene.NowTargets[v.id] = true;
		end
	end
end

function TdScene.GetNowTargets()
	return TdScene.NowTargets;
end

return TdScene;