local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TdBulletMgr = GC.class2("TdBulletMgr", ZTD.ObjectMgr);


function TdBulletMgr:createBullet(bulletInfo)
	return self:CreateObject(bulletInfo);
end


function TdBulletMgr:getBulletHeroPos(bulletId)
	local ctrl = self:GetCtrlById(bulletId);
	return ctrl._heroPos;
end

return TdBulletMgr;