local GC = require("GC")
local CC = require("CC")
local ZTD = require("ZTD")
local tools = GC.uu

local AttackData = GC.class2("AttackData")

--0.普通攻击杀死1.毒爆2.巨龙 3.尸鬼龙 4.气球怪 5.魅魔 6.巨人 （补充注释：对应FlyFactor.FlyClass）
AttackData.TypeNormal = 0
AttackData.TypePox = 1
AttackData.TypeDragon = 2
AttackData.TypeGhost = 3
AttackData.TypeBalloon = 4
AttackData.TypeTurnTable = 5
AttackData.TypeGiant = 6

function AttackData:ctor(_, vData)
	self.varData = vData or 0;
end

function AttackData:GetData()
	return self.varData;
end

-- 0~8位代表攻击类型 范围0~FF
function AttackData:GetNodeId()
	return ZTD.MathBit.andOp(self.varData, 0xFF);
end

-- 8~16位代表触发该攻击的父ID 范围0~FF
function AttackData:GetFatherId()
	return ZTD.MathBit.rShiftOp(ZTD.MathBit.andOp(self.varData, 0xFF00), 8);
end
	
function AttackData:SetNodeId(var)
	if var > 0xFF then
		var = 0xFF;
	elseif var < 0 then	
		var = 0;
	end
	self.varData = ZTD.MathBit.andOp(self.varData, 0xFF00);
	self.varData = ZTD.MathBit.orOp(self.varData, var);
end

function AttackData:SetFatherId(var)
	if var > 0xFF then
		var = 0xFF;
	elseif var < 0 then	
		var = 0;		
	end
	self.varData = ZTD.MathBit.andOp(self.varData, 0xFF);
	local tmppp = ZTD.MathBit.lShiftOp(var, 8);
	self.varData = ZTD.MathBit.orOp(self.varData, tmppp);
end

return AttackData;