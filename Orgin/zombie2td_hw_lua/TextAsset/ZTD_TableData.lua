local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local M = {};
M.DealFuns = {};

function M.Init(isSaveInfo)
	if not M.PoxData then
		M.PoxData = {};
	end	
	if isSaveInfo then
		local saveInfo = M.Data.Info;
		M.Data = {};
		M.Data.Info = saveInfo;
	else
		M.Data = {};
		M.Data.Info = {};
	end	
	M.Data.TableID = -1;	
	M.Data.ReadyLock = {};
	M.Data.CustomLockId = nil;	
	-- 记录其他人的桌子号，以便后续操作更换自己到1号桌子
	M.Data.ChairIdMap = {};
	-- 玩家原本的桌子号
	M.Data.SrcPlayerChairId = nil;
		
end

function M.Update(ptData)
	for _, v in ipairs(ptData.Info) do
		-- 当收到包含自己的推送时，重设当前房间号,并清空数据表
		if v.PlayerId == ZTD.PlayerData.GetPlayerId() then
			ZTD.PlayerData.SetHeadID(v.Head)
			ZTD.PlayerData.SetEntryEffect(v.Effect)
			ZTD.PlayerData.SetBackground(v.Background)
			--logError("!!!!!!!!Join start:" .. ptData.TableID .. "....." .. debug.traceback())
			M.Data.TableID = ptData.TableID
			M.Data.Info = {};
			break;
		end
	end	
	
	-- 如果不是自己房间号的数据，抛弃
	if M.Data.TableID ~= ptData.TableID then
		return false;
	end	

	for _, v in ipairs(ptData.Info) do
		local infos = M.Data.Info;
		if not infos[v.PlayerId] then
			infos[v.PlayerId] = {};
		end
		
		local pd = infos[v.PlayerId];
		--logError("!!!!!!!!Join PlayerId:" .. v.PlayerId)
		pd.PlayerId = v.PlayerId;
		pd.ChairId = v.ChairId;
		pd.Money = v.Money;		
		pd.MoneyVariation = v.MoneyVariation;
		pd.Sex = v.Sex;
		pd.Name = v.Name;
		pd.Head = v.Head;
		pd.VipLevel = v.VipLevel;
		pd.IsVip = v.IsVip;
		pd.Effect = v.Effect;
		pd.Background = v.Background;
		-- 是玩家自己，强制放到1号桌子
		if pd.PlayerId == ZTD.PlayerData.GetPlayerId() then
			M.Data.SrcPlayerChairId = pd.ChairId;
			ZTD.PlayerData.SetVipLevel(v.VipLevel)
			ZTD.PlayerData.SetIsVip(v.IsVip)
			pd.ChairId = 1;
		else	
			M.Data.ChairIdMap[pd.ChairId] = pd;
		end	
		
		if not pd.heroInfo then
			pd.heroInfo = {};
		end
		
		-- 删除不要的
		for posId, hd in pairs(pd.heroInfo) do
			local isRemove = false;
			for __, vv in ipairs(v.Info) do
				if posId == vv.PositionId then
					isRemove = true;
					break;
				end
			end
			
			if isRemove then
				pd.heroInfo[posId] = nil;
			end	
		end			
		
		-- 同步现有的
		for __, vv in ipairs(v.Info) do
			if not pd.heroInfo[vv.PositionId] then
				pd.heroInfo[vv.PositionId] = {};
			end
			local hd = pd.heroInfo[vv.PositionId];
			hd.HeroId = vv.HeroId;
			hd.PositionId = vv.PositionId;
			hd.Uuid = vv.UniqueId;
			hd.IsAtk = vv.IsAtk;
			hd.Timestamp = vv.Timestamp;
			hd.TargetPositionId = vv.TargetPositionId;
		end	
	end
	
	for _, v in pairs(M.Data.ChairIdMap) do
		if(1 == v.ChairId) then
			v.ChairId = M.Data.SrcPlayerChairId;
			break;
		end
	end
	
	if #M.DealFuns then
		for _, df in ipairs(M.DealFuns) do
			df(M.Data.TableID);
		end
		M.DealFuns = {};
	end
	
	return true;
end

function M.AddTFunc(df)
	table.insert(M.DealFuns, df);
end	

function M.GetData(playerId, infoKey)
	if M.Data.Info[playerId] then
		return M.Data.Info[playerId][infoKey];	
	end	
end

function M.SetData(playerId, infoKey, value)
	if M.Data.Info[playerId] then
		M.Data.Info[playerId][infoKey] = value;	
	end	
end

function M.GetTable()
	return M.Data.TableID;
end	

function M.DealLeave(playerId, heroLeaveFunc)
	local pd = M.Data.Info[playerId];
	if pd then
		for _, v in pairs(pd.heroInfo) do
			heroLeaveFunc(v);
		end
		M.Data.Info[playerId] = nil;
	end	
	
	-- 处理余留在场上的毒爆怪
	local poxData = M.PoxData[playerId];
	if poxData then
		for _, rc in pairs(poxData) do
			rc();
		end
		M.PoxData[playerId] = nil;
	end	
end

-- 记录毒爆怪信息
function M.AddPoxData(playerId, emyId, removeCall)
	if not M.PoxData[playerId] then
		M.PoxData[playerId] = {};
	end
	M.PoxData[playerId][emyId] = removeCall;
end	

function M.UpdateHeroInfo(playerId, positionId, heroData)
	local pd = M.Data.Info[playerId];
	if not pd then
		return;
	end
	
	if not pd.heroInfo[positionId] then
		pd.heroInfo[positionId] = {};
	end
	
	if heroData then
		local hd = pd.heroInfo[positionId];
		for _key, _v in pairs(heroData) do
			hd[_key] = heroData[_key];
		end		
	else
		pd.heroInfo[positionId] = nil;
	end
end

-- tgId 为-1时，表示英雄取消锁定，停止了攻击
M.NullTarget = -1;
function M.SetLockTarget(positionId, tgId)
	for _, v in pairs (M.Data.Info) do
		if v.heroInfo[positionId] then
			if tgId == M.NullTarget then
				--logError("M.NullTarget = -1;M.NullTarget = -1;M.NullTarget = -1:" .. positionId)
				tgId = nil;
			end
			v.heroInfo[positionId].TargetPositionId = tgId;
		end
	end
end

function M.GetLockTarget(positionId)
	for _, v in pairs (M.Data.Info) do
		if v.heroInfo[positionId] then
			return v.heroInfo[positionId].TargetPositionId;
		end	
	end	
end

function M.CleanLockInfo()
	M.SetReadyLockTarget();
	for _, v in pairs (M.Data.Info) do
		for _, vvv in pairs (v.heroInfo) do
			vvv.TargetPositionId = nil;
		end	
	end	
end

-- positionId 为空时，代表所有英雄
-- positionId tgId同时为空时，清空ready数据
function M.SetReadyLockTarget(positionId, tgId)
	if (positionId == nil and tgId == nil) then
		M.Data.ReadyLock = {};
		M.Data.CustomLockId = nil;
		return;
	end
	
	local playerId = ZTD.PlayerData.GetPlayerId();
	if M.Data.Info[playerId] == nil then
		return;
	end
	local hi = M.Data.Info[playerId].heroInfo;
	
	local function _set(positionId)
		if hi[positionId] and hi[positionId].TargetPositionId ~= tgId then
			M.Data.ReadyLock[positionId] = tgId;
		end
	end
	
	if positionId then
		_set(positionId)
	elseif positionId == nil then
		for positionId, v in pairs(hi) do
			_set(positionId);
		end
		--if next(M.Data.ReadyLock) == nil then
		--	return true;
		--end
		
		-- 如果代表所有英雄，则表示是自己选的目标，记录
		M.Data.CustomLockId = tgId;
	end
end

function M.GetReadyLockTarget()
	return M.Data.ReadyLock, M.Data.CustomLockId;
end

function M.WarpInfo(warpFunc)
	local afterList = {};
	-- 保证玩家的warpFunc在第一个执行
	for _, v in pairs(M.Data.Info) do
		if v.PlayerId == ZTD.PlayerData.GetPlayerId() then
			warpFunc(v);
		else
			table.insert(afterList, v);
		end	
	end
	
	for _, v in pairs(afterList) do
		warpFunc(v);
	end
end

-- 记录单个英雄炮塔的输赢
M.HeroUuidRecoard = {};
M.HeroUuidRecoardBindUi = {};
M.HeroUuidMXLSkillTimes = {};

function M.GetHeroUuidMoeny(heroUuid)
	return M.HeroUuidRecoard[heroUuid];
end

function M.BindHeroUuidUi(heroUuid, uiObj)
	M.HeroUuidRecoardBindUi[heroUuid] = uiObj;
end

function M.WriteHeroUuidMoeny(heroUuid, changeVar)
	if heroUuid == 0 then
		return;
	end
	
	if not M.HeroUuidRecoard[heroUuid] then
		M.HeroUuidRecoard[heroUuid] = 0;
	end
	
	M.HeroUuidRecoard[heroUuid] = M.HeroUuidRecoard[heroUuid] + changeVar;
	
	if M.HeroUuidRecoardBindUi[heroUuid] then
		M.HeroUuidRecoardBindUi[heroUuid]:UpdateScoreUi();
	end
end

function M.ResetHeroUuidMoeny(heroUuid)
	if heroUuid == nil then
		M.HeroUuidRecoard = {};
	else
		M.HeroUuidRecoard[heroUuid] = nil;
	end	
end

-- 获取马小玲技能次数
function M.GetMaSkillTimes(heroUuid)
	if not M.HeroUuidMXLSkillTimes[heroUuid] then
		M.HeroUuidMXLSkillTimes[heroUuid] = 0;
	end
    return M.HeroUuidMXLSkillTimes[heroUuid]
end

-- 设置马小玲技能次数
function M.SetMaSkillTimes(heroUuid, times)
    M.HeroUuidMXLSkillTimes[heroUuid] = times
end

function M.ResetMaSkillTimes(heroUuid)
	if heroUuid == nil then
		M.HeroUuidMXLSkillTimes = {};
	else
		M.HeroUuidMXLSkillTimes[heroUuid] = nil;
	end
end

return M