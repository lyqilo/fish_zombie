local GiantConfig = {}

--key值代表巨人等级

--巨人大小配置
GiantConfig.scaleCfg = 
{
    [1] = 0.5,
	[2] = 0.7,
	[3] = 0.8,
	[4] = 1,
	[5] = 1.2,
}
-- 巨人移速配置
GiantConfig.spdCfg = {
	[1] = 0.4,
	[2] = 0.35,
	[3] = 0.3,
	[4] = 0.3,
	[5] = 0.3,
}

--巨人头顶倍数配置
GiantConfig.mulCfg = 
{
	[1] = "level1",
	[2] = "level2",
	[3] = "level3",
	[4] = "level4",
	[5] = "level5",
}

--巨人升级特效大小
GiantConfig.effScaleCfg = 
{
    [1] = 1,
	[2] = 1.5,
	[3] = 2,
	[4] = 2.5,
	[5] = 3,
}

return GiantConfig 