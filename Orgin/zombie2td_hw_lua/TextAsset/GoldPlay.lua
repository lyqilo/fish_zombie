local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local GoldPlay = {}

-- 枚举
GoldPlay.TYPE_NORMAL = 1;
GoldPlay.TYPE_ICON_SHOOT = 2;
GoldPlay.TYPE_ICON_COLLECT = 3;
GoldPlay.TYPE_DROP_ONLY = 4;
GoldPlay.TYPE_OTHERS = 999;

-- 获取金币初始化参数（默认）
GoldPlay.GetCoinDefalut = function(coinNum, coinDropPos)
	local defaultCfg = {};
	defaultCfg.durationTo = 0.8;
	defaultCfg.targetPos = GoldPlay.TopGoldNode.position;
	defaultCfg.callback = nil;
	defaultCfg.coinPrefabName = "TD_Effect_JinBi";
	defaultCfg.coinNum = coinNum;
	defaultCfg.originPos = coinDropPos;
	defaultCfg.parent = GoldPlay.EffectParent;
	return defaultCfg;
end;

GoldPlay.PlayStructs = 
{		
	[GoldPlay.TYPE_NORMAL] =
	{
		-- 音效
		soundName = "ZTD_moneyGet";
		-- 使用的builder类
		builderClass = ZTD.CoinFlyBuilderBase;
		-- 使用的coinfly类
		coinFlyClass = ZTD.CoinFlyNormal;
		-- 获取对应coinfly默认初始化参数
		getCoinDefalut = function(coinNum, coinDropPos)
			local defaultCfg = GoldPlay.GetCoinDefalut(coinNum, coinDropPos);
			return defaultCfg;
		end;
	};
	
	-- 搭配转盘使用 向终点发射金币
	[GoldPlay.TYPE_ICON_SHOOT] =
	{
		-- 音效
		soundName = "ZTD_moneyGet";
		-- 使用的builder类
		builderClass = ZTD.CoinFlyBuilderBase;
		-- 使用的coinfly类
		coinFlyClass = ZTD.CoinFlyIconShoot;
		-- 获取对应coinfly默认初始化参数
		getCoinDefalut = function(coinNum, coinDropPos)
			local defaultCfg = GoldPlay.GetCoinDefalut(coinNum, coinDropPos);
			-- 偏移坐标使起点上移，让转盘遮住
			--defaultCfg.originPos = coinDropPos + Vector3(0, 2, 0);
			return defaultCfg;
		end;
	};
	
	[GoldPlay.TYPE_OTHERS] =
	{
		-- 音效
		soundName = "ZTD_moneyGet";
		-- 使用的builder类
		builderClass = ZTD.CoinFlyBuilderBase;
		-- 使用的coinfly类
		coinFlyClass = ZTD.CoinFlyDrop;
		-- 获取对应coinfly默认初始化参数
		getCoinDefalut = function(coinNum, coinDropPos)
			local defaultCfg = GoldPlay.GetCoinDefalut(coinNum, coinDropPos);
			--使用灰色金币
			defaultCfg.coinPrefabName = "TD_Effect_JinBi1";
			return defaultCfg;
		end;
	};	
	
	[GoldPlay.TYPE_DROP_ONLY] =
	{
		-- 音效
		soundName = "ZTD_moneyGet";
		-- 使用的builder类
		builderClass = ZTD.CoinFlyBuilderBase;
		-- 使用的coinfly类
		coinFlyClass = ZTD.CoinFlyDrop;
		-- 获取对应coinfly默认初始化参数
		getCoinDefalut = function(coinNum, coinDropPos)
			local defaultCfg = GoldPlay.GetCoinDefalut(coinNum, coinDropPos);
			--使用灰色金币
			defaultCfg.coinPrefabName = "TD_Effect_JinBi";
			return defaultCfg;
		end;
	};	
}


function GoldPlay.Init()
    GoldPlay.GoldPlayList = {}	
	GoldPlay.GoldTextParent = ZTD.BattleView.inst.coinEffect;--GameObject.Find("Main/Canvas/TopUIPanal").transform;
	GoldPlay.EffectParent = ZTD.BattleView.inst.coinEffect;--GameObject.Find("effectParent").transform
	GoldPlay.topNode = ZTD.BattleView.inst.topNode;
	GoldPlay.TopGoldNode = ZTD.BattleView.inst.TopGoldNode;
	GoldPlay.WorldPos2UiPos = ZTD.MainScene.SetupPos2UiPos;
end

function GoldPlay.PlayGoldEffect(GoldType, coinDropPos, coinNum, finshCallback, flyCoinConfig, isNotStart)	
	local playStruct = GoldPlay.PlayStructs[GoldType];
	if playStruct then
		ZTD.PlayMusicEffect(playStruct.soundName);

		coinDropPos = GoldPlay.WorldPos2UiPos(coinDropPos)

		local flyCoinBuilder = playStruct.builderClass:new()
		
		local builderConfig = {};
		
		if playStruct.extendBuilder then
			playStruct.extendBuilder(builderConfig);
		end	
		
		builderConfig.coinFlyClass = playStruct.coinFlyClass;
		builderConfig.finshCallback = finshCallback;
		
		--根据defaultCfg扩张flyCoinConfig
		local defaultCfg = playStruct.getCoinDefalut(coinNum, coinDropPos);		
		flyCoinConfig = flyCoinConfig or {};
		for k, v in pairs(defaultCfg) do
			flyCoinConfig[k] = flyCoinConfig[k] or v;
		end
		
		builderConfig.flyCoinConfig = flyCoinConfig;
		
		if flyCoinConfig.parent == nil then
			logError("-----------------------------flyCoinConfig.parent == nil")
		end
		local tmp = flyCoinBuilder:Init(builderConfig, isNotStart)
		GoldPlay.GoldPlayList[flyCoinBuilder] = flyCoinBuilder
		return tmp
	else
		logError("找不到金币播放枚举GoldType:" .. tostring(GoldType));
	end	
end

function GoldPlay.RemoveGoldPlayByLua(PlayLua)
    if GoldPlay.GoldPlayList[PlayLua] then
		GoldPlay.GoldPlayList[PlayLua]:Release();
        GoldPlay.GoldPlayList[PlayLua] = nil
    end
end

function GoldPlay.Release()
    for _,v in pairs(GoldPlay.GoldPlayList) do
        v:Release()
    end

    GoldPlay.GoldPlayList = {}
end

--飘文字
function GoldPlay.PlayTextEffect(currentPos,earnMoney, isGray, addRatio, GiantHitPower, balloonRatio, IsConnect)
    local config = {}
    config.parent = GoldPlay.EffectParent;
    config.currentPos = GoldPlay.WorldPos2UiPos(currentPos)
    config.earnMoney = earnMoney
    config.goldTextParent = GoldPlay.GoldTextParent
	config.isGray = isGray
	config.addRatio = addRatio or 0
	config.GiantHitPower = GiantHitPower or 0
	config.balloonRatio = balloonRatio or 0
	config.IsConnect = IsConnect
    local textEffect = ZTD.TextEffect:new()
    textEffect:OnCreate(config)
    textEffect:CreateNormalText()
	GoldPlay.GoldPlayList[textEffect] = textEffect
end

--转盘
function GoldPlay.PlayPrizeMedal(dropPos, earnMoney, prizeLevel, rollTimes, iconName, iconPic, callBack, targetPos, 
	addRatio, GiantHitPower, balloonRatio, IsConnect)
    local config = {}
    config.prefabName = "TD_BombZhuanPan"
    config.earnMoney = earnMoney
    config.rollTimes = rollTimes
	config.prizeLevel = prizeLevel
	config.iconName = iconName
	config.iconPic = iconPic
	config.callBack = callBack
	config.targetPos = targetPos
	config.addRatio = addRatio or 0
	config.GiantHitPower = GiantHitPower or 0
	config.balloonRatio = balloonRatio or 0
	config.IsConnect = IsConnect
	
	local mapPos = ZTD.MainScene.GetMapObj().position
	local x, y, i, j = ZTD.MainScene.PanGirdData:GetFreeGrid(dropPos.x - mapPos.x, dropPos.y - mapPos.y)
	if x and y then
		config.dropPos = Vector3(mapPos.x + x, mapPos.y + y, dropPos.z)
		config.gridPos = {i = i, j = j}
		ZTD.MainScene.PanGirdData:WriteGridByInx(i, j, true)
	else
		-- logError("failed!!!!!:" .. dropPos.x .. "," .. dropPos.y)
	end

	config.dropPos = GoldPlay.WorldPos2UiPos(dropPos)
	
    local prizeMedal = ZTD.PrizeMedal:new()
    prizeMedal:Init(config)
    GoldPlay.GoldPlayList[prizeMedal] = prizeMedal	
end

--巨人中奖奖牌
function GoldPlay.PlayGiantMedal(dropPos, earnMoney, rollTimes, callBack, targetPos, addRatio, GiantHitPower, 
	balloonRatio, IsConnect)
	local config = {}
    config.prefabName = "GiantMedal"
    config.earnMoney = earnMoney
    config.rollTimes = rollTimes
	config.callBack = callBack
	config.targetPos = targetPos
	config.addRatio = addRatio or 0
	config.GiantHitPower = GiantHitPower or 0
	config.balloonRatio = balloonRatio or 0
	config.IsConnect = IsConnect
	local mapPos = ZTD.MainScene.GetMapObj().position
	local x, y, i, j = ZTD.MainScene.PanGirdData:GetFreeGrid(dropPos.x - mapPos.x, dropPos.y - mapPos.y)
	if x and y then
		config.dropPos = Vector3(mapPos.x + x, mapPos.y + y, dropPos.z)
		config.gridPos = {i = i, j = j}
		ZTD.MainScene.PanGirdData:WriteGridByInx(i, j, true)
	else
		-- log("failed!!!!!:" .. dropPos.x .. "," .. dropPos.y);
	end
	config.dropPos = GoldPlay.WorldPos2UiPos(dropPos)
    local GiantMedal = ZTD.GiantMedal:new()
    GiantMedal:Init(config)
    GoldPlay.GoldPlayList[GiantMedal] = GiantMedal	
end

-- 熊中奖奖牌
function GoldPlay.PlayBearMedal(dropPos, earnMoney, rollTimes, coinFlyFunc, callBack, targetPos, addRatio, GiantHitPower, balloonRatio, IsConnect, BearMultiple)
	local config = {}
    config.prefabName = "Effect_UI_xiong"
    config.earnMoney = earnMoney
    config.rollTimes = rollTimes
	config.coinFlyFunc = coinFlyFunc
	config.callBack = callBack
	config.targetPos = targetPos
	config.addRatio = addRatio or 0
	config.GiantHitPower = GiantHitPower or 0
	config.balloonRatio = balloonRatio or 0
	config.IsConnect = IsConnect
	config.BearMultiple = BearMultiple or "1-2-3"

	local mapPos = ZTD.MainScene.GetMapObj().position
	local x, y, i, j = ZTD.MainScene.PanGirdData:GetFreeGrid(dropPos.x - mapPos.x, dropPos.y - mapPos.y)
	if x and y then
		config.dropPos = Vector3(mapPos.x + x, mapPos.y + y, dropPos.z)
		config.gridPos = {i = i, j = j}
		ZTD.MainScene.PanGirdData:WriteGridByInx(i, j, true)
	else
		-- log("failed!!!!!:" .. dropPos.x .. "," .. dropPos.y);
	end
	
	config.dropPos = GoldPlay.WorldPos2UiPos(dropPos)

    local BearMedal = ZTD.BearMedal:new()
    BearMedal:Init(config)
    GoldPlay.GoldPlayList[BearMedal] = BearMedal
end

return GoldPlay