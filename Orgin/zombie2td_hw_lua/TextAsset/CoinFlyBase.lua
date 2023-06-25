local GC = require("GC")
local ZTD = require("ZTD")

local CoinFlyBase = GC.class2("CoinFlyBase", ZTD.TimeMapBase)
local SUPER = ZTD.TimeMapBase;
local BundleName = "prefab";

----config
--coinNum 金币个数
--originPos 整个金币群中心位置的世界坐标
--targetPos 金币最终飞往的目标位置的世界坐标
--parent 父节点。因为金币是2D的，所以要提供一个在canvas下的父节点才能看到
--callback 每个金币飞到目标位置后的回调
function CoinFlyBase:Init(isNotStart, config, bulider)
	SUPER.Init(self);
	-- 记录释放的金币
	self._releaseCoin = {};
	for vname, vvalue in pairs(config) do
		self[vname] = vvalue;
	end	

    self.coinArray = {};
	self.finshCoinNum = 0;
	self.bulider = bulider;
	
	--local coinPrefab = self:CreateCoin()
    for i = 1, self.coinNum do
		local coinNode = self:CreateCopyCoin();
		self:InitCoin(coinNode, i);
        self.coinArray[i] = coinNode
    end
	--self:DestroyCoin(coinPrefab);
	self:CheckPlay(isNotStart)
end

function CoinFlyBase:CheckPlay(isNotStart)
	-- logError("isNotStart="..tostring(isNotStart))
    if isNotStart then
         return
    end
	self:DoPlay()
end

--CoinFlyBase.DEBUG_NAME = {}
--CoinFlyBase.DEBUG_I = 1;
function CoinFlyBase:InitCoin(coinNode, i)
	--coinNode.name = i.."--:--"..coinNode.gameObject:GetInstanceID()
	--CoinFlyBase.DEBUG_NAME[coinNode] = "coin_" .. CoinFlyBase.DEBUG_I;
	--CoinFlyBase.DEBUG_I = CoinFlyBase.DEBUG_I + 1;
	--logError(os.date("%Y-%m-%d %H:%M:%S:") .. "CoinFly create:" .. CoinFlyBase.DEBUG_NAME[coinNode] .. ",t:" .. tostring(coinNode));
	coinNode.name = i
	coinNode.transform.position = self.originPos
	coinNode:FindChild("jinbi/Trail").gameObject:SetActive(false)
	coinNode:FindChild("jinbi/Trail").gameObject:GetComponent(typeof(UnityEngine.Renderer)).enabled = false;
	coinNode:SetActive(false) 
end

-- 金币到达终点后的回调
function CoinFlyBase:TargetCallBack()	
	self.finshCoinNum = self.finshCoinNum + 1;
	if self.callback then 
		self.callback(self.finshCoinNum) 
	end	
	-- 当完成的金币数等于总金币数时，要通知builder以删除自己
	if self.finshCoinNum >= self.coinNum then	
		self.bulider:FinshCoinFly(self);
	end	
end	

function CoinFlyBase:DoPlay()
	
end

-- 如果需要提前结束，请调这个函数
function CoinFlyBase:Release()
    self:StopAllAction();
    for i,coin in ipairs(self.coinArray) do
		self:DestroyCoin(coin);
    end
	self.coinArray = {};
    self:StopAllTimer();
	self._releaseCoin = {};
end

function CoinFlyBase:CreateCoin()
	--return GC.uu.LoadPrefab(BundleName, self.coinPrefabName);
	return ZTD.PoolManager.GetGameItem(self.coinPrefabName, self.parent);
end

function CoinFlyBase:CreateCopyCoin(coinPrefab)
	--[[
	local coinNode = GC.uu.UguiAddChild(self.parent, coinPrefab, "");
	return coinNode;
	--]]
	return ZTD.PoolManager.GetGameItem(self.coinPrefabName, self.parent);
end

function CoinFlyBase:DestroyCoin(coin)
	if self._releaseCoin[coin] then
		return;
	end
	self._releaseCoin[coin] = true;
	--GC.uu.destroyObject(coin)
	--logError(os.date("%Y-%m-%d %H:%M:%S:") .. "CoinFly DestroyCoin:" .. tostring(CoinFlyBase.DEBUG_NAME[coin]) .. ",t:" .. tostring(coin));
	--CoinFlyBase.DEBUG_NAME[coin] = nil;
	--[-[
	coin:FindChild("jinbi/Trail").gameObject:SetActive(false);
	coin:SetActive(false);
	ZTD.PoolManager.RemoveGameItem(self.coinPrefabName, coin);
	--]]
end

return CoinFlyBase