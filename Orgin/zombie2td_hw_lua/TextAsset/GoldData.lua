local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu
local GoldData = {}

--------------------------------------
local GoldHelper = GC.class2("ZTD_GoldHelper")
function GoldHelper:ctor(_, money)
	self:Set(money or 0)
	self.Recorder = 0
end

function GoldHelper:Sysc()
	self.Show = self.Sync
	self.Recorder = 0
end

function GoldHelper:Add(var)
	self.Show = self.Show + var
	if self.Show > self.Sync then
		self.Show = self.Sync
		logError("!!!Sync gold error:" .. debug.traceback())
	end
end

function GoldHelper:AddRecorder(var)
	self.Recorder = self.Recorder + var
end	

function GoldHelper:AddSync(var)
	self.Sync = self.Sync + var
end
	
function GoldHelper:Set(money)
	self.Show = money
	self.Sync = money
end

---------------------------------------

-- 记录所有延迟加到总金币上的goldDatas
GoldData.HoldGoldDatas = {};

function GoldData.AddHoldGold(hg)
	GoldData.HoldGoldDatas[hg] = true;
end

function GoldData.SyncHoldGoldDatas()
	for gd, _ in ipairs(GoldData.HoldGoldDatas) do
		gd:Sysc();
	end	
end

function GoldData.GetHoldTotalGold()
	local totalGold = 0;
	for gd, _ in ipairs(GoldData.HoldGoldDatas) do
		totalGold = totalGold + gd.Sync;
	end
	return totalGold;
end

function GoldData.FinshGoldData(goldData, parentGoldData)
	-- 玩家总金币已经在EnemyMgr:ScMoneyChange里强制同步过，这里在加会重复
	if parentGoldData ~= GoldData.Gold then
		parentGoldData:AddSync(goldData.Sync);
	end	
	parentGoldData:Add(goldData.Sync);
	goldData:Set(0);
	GoldData.HoldGoldDatas[goldData] = nil;
end

function GoldData.ResetHoldGold()
	for gd, _ in ipairs(GoldData.HoldGoldDatas) do
		gd:Set(0);
	end
	GoldData.HoldGoldDatas = {};	
end

-- 金币统计类模板
GoldData.Helper = GoldHelper;
-- 当前总金币
GoldData.Gold = GoldHelper:new();
-- 当前龙金币
GoldData.DragonGold = GoldHelper:new();
-- 当前尸鬼龙金币
GoldData.GhostGold = GoldHelper:new();
-- 当前气球怪金币
GoldData.BalloonGold = GoldHelper:new();
-- 当前魅魔金币
GoldData.TurnTableGold = GoldHelper:new();
--当前始祖巨人金币
GoldData.OriGiantGold = GoldHelper:new();

return GoldData;