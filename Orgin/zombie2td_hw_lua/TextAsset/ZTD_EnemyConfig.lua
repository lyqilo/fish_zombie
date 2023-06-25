local TdEnemyConfig = {

	{
		id = 10009;
		modelPath = "TD_ENEMY_JY_0401Y";
		icon = "ZTD_monster_10009";
		desc = "攻击消耗双倍，击败后获得随机3颗熊珠，熊珠倍数乘积为最终奖励倍数";
		name = "暴熊";
		walkSpd = 0.4;
		-- 是否为双倍怪，需和服务器配置一致
		IsDouble = true;
		desc_r = "最高1600";
		GoldPlayType = 8;
		sortOrder = 5;--渲染顺序
	},

	{
		id = 10008;
		modelPath = "TD_ENEMY_SL_0401";
		icon = "ZTD_monster_10008";
		desc = "击杀巨人后召唤始祖之魂，对全图造成2~3波最高6倍的伤害";
		name = "战争巨人";
		walkSpd = 0.3;	
		-- 是否为双倍怪，需和服务器配置一致
		IsDouble = false;
		desc_r = "随机";
		GoldPlayType = 7;
		sortOrder = 10;--渲染顺序
	},

	{
		id = 10007;
		modelPath = "";
		icon = "ZTD_monster_10007";
		desc = "怪物出场后有几率携带“同气连枝”效果，所有“同气连枝”共享生命，击退其中一只，则其他怪物一同被击退";
		name = "同气连枝";
		walkSpd = 0.5;	
		-- 是否为双倍怪，需和服务器配置一致
		IsDouble = false;
		desc_r = "随机";
		sortOrder = 9;--渲染顺序
	},

	{
		id = 10006;
		modelPath = "TD_ENEMY_JY_0301Y";
		icon = "ZTD_monster_10006";
		desc = "女王";
		name = "每次攻击消耗2倍底分，击杀概率触发4种模式之一：龙母模式奖励翻2~4倍，狼主模式向后连续中3次奖励，艾瑞卡模式随机中3次奖励，维克多模式随机中2~8次奖励";
		walkSpd = 0.5;	
		-- 是否为双倍怪，需和服务器配置一致
		IsDouble = true;
		desc_r = "最高1040倍";
		-- 爆金币类型
		GoldPlayType = 6;
		sortOrder = 8;--渲染顺序
	},

	{
		id = 10005;
		modelPath = "TD_ENEMY_SL_0301";
		icon = "ZTD_monster_10005";
		desc = "气球怪被击败后，向周围发出三波炸弹，随机攻击范围内怪物，炸弹击杀其他怪物获得1-3倍奖励";
		name = "气球怪";
		walkSpd = 0.35;
		-- 是否为双倍怪，需和服务器配置一致
		IsDouble = false;
		desc_r = "100";
		-- 爆金币类型
		GoldPlayType = 5;
		sortOrder = 7
	},
	{
		id = 10004;
		modelPath = "TD_ENEMY_SL_0101";
		icon = "ZTD_ext_icon_14";
		desc = "暗夜之王，被击退会召唤出被恶灵化的强大巨龙，喷吐冰霜之火焚毁一切，巨龙最多对场地内进行300次攻击";
		name = "夜之王";
		walkSpd = 0.35;
		effectId = 3;
		-- 是否为双倍怪，需和服务器配置一致
		IsDouble = false;
		desc_r = "最高300倍";
		sortOrder = 6;--渲染顺序
	},

	{
		id = 10003;
		modelPath = "TD_ENEMY_JY_0201Y";
		icon = "ZTD_monster_10003";
		desc = "凛冬至阴孕育出至阳地火，怪兽小兵受地火影响而变得极其强大，每次攻击消耗2倍底分，强大的战火怪兽击退奖励极其丰厚，最高可达480倍";
		name = "战火怪兽";
		walkSpd = 0.4;
		-- 是否为双倍怪，需和服务器配置一致
		IsDouble = true;
		desc_r = "最高480";
		sortOrder = 5;--渲染顺序
	},

	{
		id = 10002;
		modelPath = "TD_ENEMY_JY_0101Y";
		icon = "ZTD_monster_10002";
		desc = "凛冬之地的强大怪兽，身负冰甲让它变得极难攻击，每次攻击消耗1倍底分，击退可获得最高38倍奖励";
		name = "凛冬怪兽";
		walkSpd = 0.5;
		
		-- 默认金币特效类型
		--GoldPlayType = 5;	
		desc_r = "最高38";
		sortOrder = 4;--渲染顺序
	},

	{
		id = 10001;
		modelPath = "TD_ENEMY_SS_0401Y";
		icon = "ZTD_monster_10001";
        desc = "击败必定触发【爆爆弹】，爆爆弹爆炸后返还大量金币，并有概率免费击退范围内一定数量怪物，每次触发爆炸，都有概率使附近目标同化，同化目标会触发和爆爆怪相同奖励的爆爆弹，同化爆炸最高基础奖励160倍，如有免费击败所得，还可以突破该倍数上限！";
		name = "爆爆怪";
		-- 行走速度（每秒百像素）
		walkSpd = 0.5;
		--
		effectId = 1;
		-- 爆金币类型
		--GoldPlayType = 1;
		desc_r = "16~160";
		sortOrder = 3;--渲染顺序
	},

	{
		id = 4000;
		modelPath = "TD_ENEMY_SS_0101Y";
		icon = "ZTD_monster_4000";
		desc = "夜王麾下小兵，惯用长矛，武力强大，每次攻击需消耗1倍底分，击退邪恶怪兽可获得18-22倍随机奖励。";
		name = "邪恶怪兽";
		-- 行走速度（每秒百像素）
		walkSpd = 0.5;
		desc_r = "18~22";
		sortOrder = 2;--渲染顺序
	},

	{
		id = 4001;
		modelPath = "TD_ENEMY_SS_0201Y";
		icon = "ZTD_monster_4001";
		desc = "身材弱不经风，因远超普通怪物的狡猾得以重用，每次攻击需消耗1倍底分，击败幽冥怪兽可以获得12-16倍随机奖励。";
		name = "幽冥怪兽";
		walkSpd = 0.5;
		desc_r = "12~16";
		sortOrder = 1;--渲染顺序
	},

	{
		id = 4002;
		modelPath = "TD_ENEMY_SS_0301Y";
		icon = "ZTD_monster_4002";
		desc = "夜王麾下小兵，手中的大刀让它也十分具有威胁性，每次攻击消耗1倍底分，击退必定获得获得6-10倍随机奖励";
		name = "怪兽步兵";
		walkSpd = 0.5;
		desc_r = "6~10";
		sortOrder = 1;--渲染顺序
	},

	{
		id = 4004;
		modelPath = "TD_ENEMY_SS_0601";
		icon = "ZTD_monster_4004";
		desc = "身材细小，擅长飞行，行动敏捷隐蔽，极难发现，击退可获得3-5倍随机奖励。";
		name = "小怪兽";
		-- 行走速度（每秒百像素）
		walkSpd = 0.5;
		desc_r = "3~5";
		sortOrder = 0;--渲染顺序
	},

	{
		id = 4003;
		modelPath = "TD_ENEMY_SS_0501";
		icon = "ZTD_monster_4003";
		desc = "嗅觉灵敏，警觉性强，动作悄而无声，是夜之王忠实的门卫，击退可获得2-3倍奖励。";
		name = "傀儡犬";
		-- 行走速度（每秒百像素）
		walkSpd = 0.5;
		desc_r = "2~3";
		sortOrder = 0;--渲染顺序
	},
}

return TdEnemyConfig;