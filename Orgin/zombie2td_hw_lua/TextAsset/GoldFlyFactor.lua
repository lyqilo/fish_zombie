local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

-- 飞行流程工厂
local FlyFactor = {};

-- 飞行过程类
local GoldFlyProcess = GC.class2("ZTD_GoldFlyProcess");

function GoldFlyProcess:Init(coinNum, earnMoney, goldData, medalUi, comboNode, addRatio, GiantHitPower, balloonRatio)	
	self._coinNum = coinNum;
	
	self._medalUi = medalUi;
	
	self._comboNode = comboNode;
	
	self._addRatio = addRatio;
	self._GiantHitPower = GiantHitPower;
	self._balloonRatio = balloonRatio;

	-- 分配每个金币的金币量
	local everyMoneyOfCoin = math.floor(earnMoney / coinNum);
	self._coinList = {};
	for i = 1, coinNum - 1 do
		self._coinList[i] = everyMoneyOfCoin;
	end
	self._coinList[coinNum] = earnMoney - everyMoneyOfCoin * (coinNum - 1);
	
	self._goldData = goldData;
	
	self._goldData:AddRecorder(1);
	-- 金币动画完结回调
	local finshCallback = function()
		self._goldData:AddRecorder(-1);
		self:FinshCallRefresh();
	end
	
	-- 单个金币动画完结的回调
	local coinCallback = function(index)
		--累积加上所有飞行中获得的金币总量
		self._goldData:Add(self._coinList[index]);		
		self:CoinCallRefresh();
	end

	
	local initConfig = {};
	initConfig.targetPos = self._medalUi:GetGoldPos();
	initConfig.callback = coinCallback;	
	return finshCallback, initConfig;	 
end

function GoldFlyProcess:CoinCallRefresh()
	self._medalUi:UpdateGold(self._goldData.Show, self._comboNode, self._addRatio, self._GiantHitPower, self._balloonRatio);
end

function GoldFlyProcess:FinshCallRefresh()
end

------------------------------
local PoxFlyProcess = GC.class2("PoxFlyProcess", GoldFlyProcess)
------------------------------
local DragonFlyProcess = GC.class2("DragonFlyProcess", GoldFlyProcess)
------------------------------
local GhostFlyProcess = GC.class2("GhostFlyProcess", GoldFlyProcess)
------------------------------
local BalloonFlyProcess = GC.class2("BalloonFlyProcess", GoldFlyProcess)
------------------------------
local TurnTableFlyProcess = GC.class2("TurnTableFlyProcess", GoldFlyProcess)
------------------------------
local GiantFlyProcess = GC.class2("GiantFlyProcess", GoldFlyProcess)
------------------------------

--0.普通攻击杀死1.毒爆2.巨龙 3.尸鬼龙 4.气球怪 5.魅魔 6.巨人
FlyFactor.FlyClass = {};
FlyFactor.FlyClass[0] = GoldFlyProcess
FlyFactor.FlyClass[1] = PoxFlyProcess
FlyFactor.FlyClass[2] = DragonFlyProcess
FlyFactor.FlyClass[3] = GhostFlyProcess
FlyFactor.FlyClass[4] = BalloonFlyProcess
FlyFactor.FlyClass[5] = TurnTableFlyProcess
FlyFactor.FlyClass[6] = GiantFlyProcess
------------------------------

-- 判断金币类型
function FlyFactor.GetGoldType(IsConnect, IsGiantHitPower, enemyCfg, isPlayerKill, moneyEarn, data)
	local goldPlayType = 1;
	if enemyCfg then
		goldPlayType = enemyCfg.GoldPlayType;
	end
	
	local CustomGoldPlayType;
	if not isPlayerKill then
		return ZTD.GoldPlay.TYPE_OTHERS;
	elseif enemyCfg == nil then
		return goldPlayType;
	elseif not goldPlayType then
		local cfg = ZTD.ConstConfig[1];
		goldPlayType = cfg.GoldPlayType;
		CustomGoldPlayType = IsConnect and cfg.SpecialGoldPlayType or cfg.CustomGoldPlayType;
		CustomGoldPlayType = IsGiantHitPower and cfg.SpecialGoldPlayType or cfg.CustomGoldPlayType;
	else
		CustomGoldPlayType = enemyCfg.CustomGoldPlayType or {};
	end
	
	local function pairsByKeys(t)  
		local a = {}  
		for n in pairs(t) do  
			a[#a+1] = n  
		end  
		table.sort(a)  
		local i = 0  
		return function()  
			i = i + 1  
			return a[i], t[a[i]]  
		end 
	end
	
	local winRario = moneyEarn/data.Ratio;
	if CustomGoldPlayType then
		for k, v in pairsByKeys(CustomGoldPlayType) do
			if winRario >= k then
				goldPlayType = v;
			end
		end
	end
	return goldPlayType;
end

-- 计算金币个数
function FlyFactor.GetCoinNum(radio, earnMoney)
    local rewardRadio = earnMoney/radio
    local coinNum = math.ceil((rewardRadio/5) + 1)
    if coinNum >= 10 then
        coinNum = 10
    end
    if coinNum > earnMoney then
        coinNum = earnMoney
    end
	
	return coinNum;
end

-- 播放飞金币接口
function FlyFactor.PlayCoinWork(dieData, isPlayerKill, moneyEarn, coinDropPos, eCfg, isUnSelect)
	local enemyCfg = eCfg; --or ZTD.MainScene.GetEnemyCfg(4001)

	local coinDropPos = coinDropPos or ZTD.MainScene.GetMapObj().position

	local enemyMgr = ZTD.Flow.GetEnemyMgr()
	local IsConnect = enemyMgr.connectList[dieData.PositionId]
	local giantRatio = dieData.GiantHitPower or 0
	local IsGiantHitPower = giantRatio > 0
	
	local goldPlayType = FlyFactor.GetGoldType(IsConnect, IsGiantHitPower, enemyCfg, isPlayerKill, moneyEarn, dieData);
	
	local coinNum = FlyFactor.GetCoinNum(dieData.Ratio, moneyEarn)
	
	local function playMyGoldBreak(IsConnect, isUnSelect, goldPlayType, flyClass, goldData, goldUiView, comboNode)	
		local double = 1
		if enemyCfg and enemyCfg.IsDouble then
			double = 2
		end
		local uiView = goldUiView
		-- 类型1，普通掉金币
		if goldPlayType == 1 then
			local goldFly = flyClass:new()
			local goldData = goldData
			local finshCallback, initConfig = goldFly:Init(coinNum, moneyEarn, goldData, uiView, comboNode, 
			dieData.AddRatio, dieData.GiantHitPower, dieData.BalloonRatio, IsConnect);
			ZTD.GoldPlay.PlayGoldEffect(ZTD.GoldPlay.TYPE_NORMAL, coinDropPos, coinNum, finshCallback, initConfig, false);
			ZTD.GoldPlay.PlayTextEffect(coinDropPos, moneyEarn, nil, dieData.AddRatio, dieData.GiantHitPower, 
			dieData.BalloonRatio, IsConnect);	
			ZTD.Notification.GamePost(ZTD.Define.MsgGoldPillar, moneyEarn / dieData.Ratio * double, moneyEarn)
			return true
		-- 类型2，3，4，对应铜银金奖牌
		elseif goldPlayType == 2 or goldPlayType == 3 or goldPlayType == 4 then
			local goldFly = flyClass:new()
			local goldData = goldData
			local finshCallback, initConfig = goldFly:Init(coinNum, moneyEarn, goldData, uiView, comboNode, 
			dieData.AddRatio, dieData.GiantHitPower, dieData.BalloonRatio, IsConnect);
			ZTD.GoldPlay.PlayGoldEffect(ZTD.GoldPlay.TYPE_ICON_SHOOT, coinDropPos, coinNum, finshCallback, initConfig, false);
			local prizeLevel = goldPlayType
			local rollTimes = coinNum
			local function callBack()
				ZTD.Notification.GamePost(ZTD.Define.MsgGoldPillar, moneyEarn / dieData.Ratio * double, moneyEarn)
			end
			local targetPos = uiView:GetGoldPos()
			local language = ZTD.LanguageManager.GetLanguage("L_ZTD_EnemyConfig")
    		local name = language[enemyCfg.id].name
			ZTD.GoldPlay.PlayPrizeMedal(coinDropPos, moneyEarn, prizeLevel, rollTimes, name, enemyCfg.icon, callBack, 
			targetPos, dieData.AddRatio, dieData.GiantHitPower, dieData.BalloonRatio, IsConnect);
			return true
		--类型5，对应气球怪特殊爆奖牌
		elseif goldPlayType == 5 then
			local goldFly = flyClass:new()
			local goldData = goldData
			local finshCallback, initConfig = goldFly:Init(coinNum, moneyEarn, goldData, uiView, comboNode, 
			dieData.AddRatio, dieData.GiantHitPower, dieData.BalloonRatio, IsConnect)
			ZTD.GoldPlay.PlayGoldEffect(ZTD.GoldPlay.TYPE_ICON_SHOOT, coinDropPos, coinNum, finshCallback, initConfig, false)
			return true
		--类型6，对应魅魔特殊转盘
		elseif goldPlayType == 6 then
			local goldFly = flyClass:new()
			local goldData = goldData
			local finshCallback, initConfig = goldFly:Init(coinNum, moneyEarn, goldData, uiView, comboNode, 
			dieData.AddRatio, dieData.GiantHitPower, dieData.BalloonRatio, IsConnect)
			local tmp = ZTD.GoldPlay.PlayGoldEffect(ZTD.GoldPlay.TYPE_ICON_SHOOT, coinDropPos, coinNum, finshCallback, initConfig, not isUnSelect)
			if not isUnSelect then
				local function callBack()
					tmp:CheckPlay(false)
					ZTD.Notification.GamePost(ZTD.Define.MsgGoldPillar, moneyEarn / dieData.Ratio * double, moneyEarn);
				end
				local temp = string.split(dieData.Others, ":")
				local tempData = {}
				tempData.centerIdx =  tonumber(temp[1])
				tempData.rat = tonumber(temp[2])
				local list = string.split(temp[3], ";")
				tempData.scoreList = {}
				for k, v in ipairs(list) do
					if v then
						local tmp = string.split(v, ",")
						table.insert(tempData.scoreList, {x = tonumber(tmp[1]), y = tonumber(tmp[2])})
					end
				end
				tempData.dt = dieData
				local targetPos = uiView:GetGoldPos()
				tempData.targetPos = targetPos
				tempData.callback = callBack
				ZTD.TurnTableMgr:AddTurnTable(dieData.PlayerId, tempData)
			end
			return true
		--类型7，对应巨人
		elseif goldPlayType == 7 then
			local goldFly = flyClass:new()
			local goldData = goldData
			local finshCallback, initConfig = goldFly:Init(coinNum, moneyEarn, goldData, uiView, comboNode, 
			dieData.AddRatio, dieData.GiantHitPower, dieData.BalloonRatio, IsConnect)
			ZTD.GoldPlay.PlayGoldEffect(ZTD.GoldPlay.TYPE_ICON_SHOOT, coinDropPos, coinNum, finshCallback, initConfig, false)
			local rollTimes = coinNum
			local function callBack()
				ZTD.Notification.GamePost(ZTD.Define.MsgGoldPillar, moneyEarn / dieData.Ratio * double, moneyEarn)
			end
			local targetPos = uiView:GetGoldPos()
			ZTD.GoldPlay.PlayGiantMedal(coinDropPos, moneyEarn, rollTimes, callBack, targetPos, dieData.AddRatio, 
			dieData.GiantHitPower, dieData.BalloonRatio, IsConnect);
			return true
		--类型8，对应熊
		elseif goldPlayType == 8 then
			local goldFly = flyClass:new()
			local goldData = goldData
			local finshCallback, initConfig = goldFly:Init(coinNum, moneyEarn, goldData, uiView, comboNode, dieData.AddRatio, dieData.GiantHitPower, dieData.BalloonRatio, IsConnect)
			local tmp = ZTD.GoldPlay.PlayGoldEffect(ZTD.GoldPlay.TYPE_ICON_SHOOT, coinDropPos, coinNum, finshCallback, initConfig, true)
			local rollTimes = coinNum
			local function coinFlyFunc()
				tmp:CheckPlay(false)
			end
			local function callBack()
				ZTD.Notification.GamePost(ZTD.Define.MsgGoldPillar, moneyEarn / dieData.Ratio * double, moneyEarn)
			end
			local targetPos = uiView:GetGoldPos()
			ZTD.GoldPlay.PlayBearMedal(coinDropPos, moneyEarn, rollTimes, coinFlyFunc, callBack, targetPos, dieData.AddRatio, dieData.GiantHitPower, dieData.BalloonRatio, IsConnect, dieData.BearMultiple);
			return true
		else
		-- 其他玩家爆奖类，灰色金币灰数字
		end
	end	
	
	if isPlayerKill then
		local comboNode
		if not comboNode then
			local avData = dieData.AttackInfo
			local f_id = avData.KillID
			local n_id = avData.SelfID
			-- logError(string.format("PlayCoinWork PositionId:%s, KillID: %s, SelfID:%s", dieData.PositionId, f_id, n_id));
			if f_id ~= 0 then
				comboNode = ZTD.ComboShowTree.FindNode(f_id)
			end
		end
		if comboNode then
			local nodeData = comboNode:GetNodeData()
			nodeData.goldData:AddSync(moneyEarn)
			local TFlyClass = FlyFactor.FlyClass[nodeData.atkType]
			playMyGoldBreak(IsConnect, isUnSelect, goldPlayType, TFlyClass, nodeData.goldData, nodeData.medalUi, comboNode);
		else
			-- 没有特殊节点标识，即为普通掉金币
			playMyGoldBreak(IsConnect, isUnSelect, goldPlayType, FlyFactor.FlyClass[0], ZTD.GoldData.Gold, ZTD.BattleView.inst)
		end	
	else
		ZTD.GoldPlay.PlayGoldEffect(ZTD.GoldPlay.TYPE_OTHERS, coinDropPos, coinNum)
		ZTD.GoldPlay.PlayTextEffect(coinDropPos, moneyEarn, true)
	end
end

return FlyFactor;