local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local CoinFlyBuilderMedal = GC.class2("CoinFlyBuilderMedal", ZTD.CoinFlyBuilderBase)
local SUPER = ZTD.CoinFlyBuilderBase;


CoinFlyBuilderMedal:CreateCoinFly()
    SUPER.CreateCoinFly(self);
end

return CoinFlyBuilderMedal