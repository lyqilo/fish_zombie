local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu
local CoinFlyBuilderBase = GC.class2("CoinFlyBuilderBase", ZTD.TimeMapBase)
local SUPER = ZTD.TimeMapBase;

function CoinFlyBuilderBase:Init(config, isNotStart)
	SUPER.Init(self);
	
	for vname, vvalue in pairs(config) do
		self[vname] = vvalue;
	end
	
	-- 存放coinFly类对象的列表
	self.CoinFlyLua = {};
	
	local tmp = self:CreateCoinFly(isNotStart);
	return tmp
end

function CoinFlyBuilderBase:FinshCoinFly(coinFly)
	for k, v in ipairs(self.CoinFlyLua) do
		if v == coinFly then
			v:Release();
			table.remove(self.CoinFlyLua, k);
			break;
		end
	end
	
	-- 列表删空，则流程结束
	if next(self.CoinFlyLua) == nil and not self._isFinsh then
		self:Finish();
		self._isFinsh = true;
	end
end

function CoinFlyBuilderBase:CreateCoinFly(isNotStart)    
	local coinFlyLua = self.coinFlyClass:new()
	coinFlyLua:Init(isNotStart, self.flyCoinConfig, self);
	table.insert(self.CoinFlyLua, coinFlyLua);
	return coinFlyLua
end

function CoinFlyBuilderBase:Release()  
    self:StopAllTimer()
	for _, v in ipairs(self.CoinFlyLua) do
		v:Release();
	end
	self.CoinFlyLua = {};
end

function CoinFlyBuilderBase:Finish()
    ZTD.GoldPlay.RemoveGoldPlayByLua(self)  
	if self.finshCallback then
		self.finshCallback()
	end	
end

return CoinFlyBuilderBase