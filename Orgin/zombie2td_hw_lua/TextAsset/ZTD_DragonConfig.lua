
local DragonConfig;

DragonConfig = 
{
[1] = 
{
	-- 帮助页描述
	helpDesc = "投入100倍底分召唤巨龙发动巨龙之怒，发出的强力龙息可以快速清扫怪群！";
	--
	lessTip = "能量不足";
	--
	cdTip = "巨龙之怒尚未结束";
	
	iconName = "巨龙之怒";
	iconPath = "ZTD_ext_icon_12";
	-- 一行有多少格火焰
	lineEffNums = 11;
	
	-- 走一条路消耗的时间（秒）
	runTime = 6;
	
	-- 调头等待时间
	delayTime = 0.1;
	
	--地面火技能ID(特效动画一个长一个短)
	fireSkillId1 = 10011;
	fireSkillId2 = 10012;
	--地面火终结技能ID
	fireEndSkillId = 10013;
	--空技能，处理后台回来时的结束
	fireEndSkillId_Empty = 10014;
	
	-- 地面火特效格子的Y轴(第一行和第二行)
	fireFloorY1 = 0.9;
	fireFloorY2 = -1.2;
	
	-- 龙在右边出来时的三轴旋转角度
	srcX = 0;
	srcY = -90;
	srcZ = 40;
	
	-- 离出口的高度偏差
	gapX = 10;
	gapY = 5.4;		
}
}

return DragonConfig