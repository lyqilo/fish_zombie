local TdHeroConfig = 
{
	{
		id = 1005;
		modelPath = "TD_HERO_05";
		bulletPath = "TD_HERO_05_zidan";
		bulletShootEff = nil;
		bulletHitEff = nil;
		-- 播放特效时间（攻击动画播放隔了多久后）
		bulletShootEffPlayTime = 0.25;
		shootCd = 0.9;
		atk = 30.0;
		atkRange = 3;

		-- 是否忽略射击声音
		isIgnoreShootSound = true;

		---描述相关---
		-- 英雄名称
		name_hero = "马小玲";
		-- 头像图标
		icon_head = "ZTD_heroIcon_0004";
		-- 技能图标
		icon_skill = "ZTD_skill0004";
		-- 技能名称
		name_skill = "五行封印";
		-- 技能描述
		desc_skill = "消耗4倍底分进行施法，施法成功所有英雄获得命中加成效果";
		-- 射程（显示格子用）
		desc_atk_ranged = 3;
		-- 攻速（显示格子用）
		desc_atk_spd = 2;
	},

	{
		id = 1004;
		modelPath = "TD_HERO_04";
		bulletPath = "TD_HERO_04_zidan";
		bulletShootEff = "TD_HERO_04_shifa";
		bulletHitEff = "TD_HERO_04_baodian";
		-- 播放特效时间（攻击动画播放隔了多久后）
		bulletShootEffPlayTime = 0.28;
		shootCd = 0.9;
		atk = 30.0;
		atkRange = 3;

		-- 是否忽略射击声音
		isIgnoreShootSound = true;

		---描述相关---
		-- 英雄名称
		name_hero = "龙母";
		-- 头像图标
		icon_head = "ZTD_heroIcon_0003";
		-- 技能图标
		icon_skill = "ZTD_skill0003";
		-- 技能名称
		name_skill = "炎爆冲击";
		-- 技能描述
		desc_skill = "消耗3倍底分发动炎爆攻击，命中获得2-4倍奖励";
		-- 射程（显示格子用）
		desc_atk_ranged = 3;
		-- 攻速（显示格子用）
		desc_atk_spd = 1;
		shootEffPos = {
			{x=0.65, y=-0.47},
			{x=0.86, y=0},
			{x=0.29, y=0.42},
			{x=-0.3, y=0.31},
			{x=0.29, y=0.42},
			{x=0.86, y=0},
			{x=0.65, y=-0.47},
			{x=0.24, y=-0.68},
		}
	},

	{
		id = 1001;
		modelPath = "TD_HERO_01";
		-- 子弹模型
		bulletPath = "TD_HERO_01_zidan";
		-- 发射特效
		bulletShootEff = "TD_HERO_01_shifa";
		-- 播放特效时间（攻击动画播放隔了多久后）
		bulletShootEffPlayTime = 0;
		-- 受击特效
		bulletHitEff = "TD_HERO_01_baodian";
		-- 发射间隔（秒）
		shootCd = 0.125;
		-- 假子弹，射多少发才真正发请求，默认为1
		fakerShootTimes = 2;
		-- 单发子弹伤害
		atk = 30.0;
		-- 射程（百像素）
		atkRange = 2.5;

		-- 是否有连续射击音效
		--isShootContinueSound = true;
		-- 是否忽略射击 受击声音
		--isIgnoreHitSound = true;

		---描述相关---
		-- 英雄名称
		name_hero = "维克多";
		-- 头像图标
		icon_head = "ZTD_heroIcon_0000";
		-- 技能图标
		icon_skill = "ZTD_skill0000";
		-- 技能名称
		name_skill = "急速冷却";
		-- 技能描述
		desc_skill = "自身攻速加倍";
		-- 射程（显示格子用）
		desc_atk_ranged = 2;
		-- 攻速（显示格子用）
		desc_atk_spd = 3;
		--右下为1， 逆时针1~8
		shootEffPos = {
			{x=0.28, y=-0.47},
			{x=0.65, y=-0.32},
			{x=0.7, y=0.16},
			{x=0.29, y=0.43},
			{x=0.7, y=0.16},
			{x=0.65, y=-0.32},
			{x=0.28, y=-0.47},
			{x=-0.29, y=-0.42},
		}
	},

	{
		id = 1003;
		modelPath = "TD_HERO_03";
		bulletPath = "TD_HERO_03_zidan";
		bulletShootEff = nil;
		bulletHitEff = "TD_HERO_03_baodian";
		shootCd = 0.55;
		atk = 30.0;
		atkRange = 2.5;

		-- 是否忽略射击声音
		isIgnoreShootSound = true;

		---描述相关---
		-- 英雄名称
		name_hero = "狼主";
		-- 头像图标
		icon_head = "ZTD_heroIcon_0002";
		-- 技能图标
		icon_skill = "ZTD_skill0002";
		-- 技能名称
		name_skill = "寒冰之刃";
		-- 技能描述
		desc_skill = "减速目标，持续3s,对减速目标进行双重攻击";
		-- 射程（显示格子用）
		desc_atk_ranged = 2;
		-- 攻速（显示格子用）
		desc_atk_spd = 2;
	},

	{
		id = 1002;
		modelPath = "TD_HERO_02";
		bulletPath = "TD_HERO_02_zidan";
		bulletShootEff = "TD_HERO_02_shifa";
		bulletHitEff = "TD_HERO_02_baodian";
		shootCd = 0.65;
		atk = 30.0;
		atkRange = 2.5;

		---描述相关---
		-- 英雄名称
		name_hero = "艾瑞卡";
		-- 头像图标
		icon_head = "ZTD_heroIcon_0001";
		-- 技能图标
		icon_skill = "ZTD_skill0001";
		-- 技能名称
		name_skill = "多重射击";
		-- 技能描述
		desc_skill = "多重箭矢，可以同时攻击3个目标";
		-- 射程（显示格子用）
		desc_atk_ranged = 2;
		-- 攻速（显示格子用）
		desc_atk_spd = 2;
		shootEffPos = {
			{x=0.15, y=-0.17},
			{x=0.25, y=-0.16},
			{x=0.21, y=0.11},
			{x=-0.04, y=0.21},
			{x=0.21, y=0.11},
			{x=0.25, y=-0.16},
			{x=0.15, y=-0.17},
			{x=-0.09, y=-0.24},
		}
	},
}

return TdHeroConfig;