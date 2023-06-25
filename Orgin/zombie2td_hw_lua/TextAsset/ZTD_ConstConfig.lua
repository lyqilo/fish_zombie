-- 塔防通用配置
local TdConstConfig = {
[1] = {

-- 适配长宽
LogicWidth = 1136,--1366,
LogicWidthBig = 1366,
LogicHeight = 640,--768,

-- 资源文件夹路径
ResPath = "prefab",

-- 游戏模式号，由服务器规定
ParamMode = 2;

-- 默认金币特效类型
GoldPlayType = 1;

-- 超过倍数时候改变特效类型
CustomGoldPlayType =
{
	[11] = 2; 
	[21] = 3; 
	[30] = 4;
},

-- 连接怪/巨人超过倍数时的特效类型配置
SpecialGoldPlayType =
{
	[1] = 2; 
	[3] = 3; 
	[10] = 4;
},

-- 趋势图，多长时间记录一次数据（秒）
TrendCd = 60,

-- 最大玩家数
TotalPlayer = 4,

-- 用于服务器传输和同步的秒数倍率
SecondRate = 1000,

-- 用于服务器传输的坐标扩大
PosRate = 10000,

-- 怪物间隔
MonsterCd = 2,
-- 英雄拖拽响应（秒）
HeroPressTime = 0.5,
-- 英雄拖拽拉伸
HeroPressScale = 1.1,
-- 转盘格子划分
GirdXNums = 9,
GirdYNums = 6,

-- 美术做英雄特效时候，假定英雄层级是10
HeroFakerOrder = 10;
},
}

return TdConstConfig;