-- 内存池配置
local M = {
	--怪物模型
	{name = "TD_ENEMY_SS_0101Y",num = 8},
	{name = "TD_ENEMY_SS_0201Y",num = 8},
	{name = "TD_ENEMY_SS_0301Y",num = 8},
	{name = "TD_ENEMY_SS_0401Y",num = 8},
	{name = "TD_ENEMY_SS_0501",num = 8},
	{name = "TD_ENEMY_SS_0601",num = 8},
	{name = "TD_ENEMY_JY_0101Y",num = 4},
	{name = "TD_ENEMY_JY_0201Y",num = 4},	
	{name = "TD_ENEMY_JY_0301Y",num = 4},--[[
	{name = "SS_05_01",num = 1},
	{name = "SS_04_01",num = 1},
	{name = "SLC_02_01_forShow",num = 1},--]]
	--英雄模型
	{name = "TD_HERO_01",num = 1},	
	{name = "TD_HERO_02",num = 1},	
	{name = "TD_HERO_03",num = 1},	
	{name = "TD_HERO_04",num = 1},
	{name = "TD_HERO_05",num = 1},		
	{name = "TD_HERO_01_zidan",num = 3},	
	{name = "TD_HERO_02_zidan",num = 3},	
	{name = "TD_HERO_03_zidan",num = 1},	
	{name = "TD_HERO_04_zidan",num = 1},	
	{name = "TD_HERO_05_zidan",num = 1},	
	{name = "TD_HERO_01_shifa",num = 1},	
	{name = "TD_HERO_02_shifa",num = 1},	
	{name = "TD_HERO_04_shifa",num = 1},	
	{name = "TD_HERO_05_shifa",num = 1},	
	{name = "TD_HERO_01_baodian",num = 1},	
	{name = "TD_HERO_02_baodian",num = 1},	
	{name = "TD_HERO_03_baodian",num = 1},	
	{name = "TD_HERO_04_baodian",num = 1},	
	--{name = "TD_HERO_05_baodian",num = 1},	
			
	{name = "TD_ef_jiaodiyan",num = 1},
	{name = "TD_SUMMON_TIPS",num = 19},
	--{name = "TD_HERO_RANGE",num = 1},

	{name = "TD_Effect_UI_JB_TiShi", num = 1},
	
	{name = "TD_Effect_PAOTAI1", num = 2},
	{name = "TD_Effect_PAOTAI2", num = 1},
	{name = "TD_Effect_PAOTAI3", num = 1},
	{name = "TD_Effect_PAOTAI4", num = 1},
	--{name = "ZTD_Skill_PoxBomb2", num = 3},
	
	{name = "TD_Effects_ts_dbjingshi1", num = 2},
	
	{name = "ZTD_GoldPillar", num = 2},
	{name = "ZTD_GoldPillar_Gold", num = 20},
	--{name = "ZTD_SL_02_02", num = 1},
	-- 尸鬼龙模型
	--{name = "ZTD_ICE_SL", num = 1},
	
	{name = "TD_Effect_dimianbao", num = 2},
	
	{name = "TD_dragon_baodian", num = 2},
	
	{name = "TD_Effect_fangzhi_2", num = 2},
	{name = "TD_Effect_fangzhi_1", num = 2},
	
	-- 毒爆怪特效
	{name = "SS_04_01_baoza02_circle", num = 1},
	{name = "TD_Effect_dubaoguai", num = 1},
	{name = "TD_Effect_fumo", num = 2},
	
	-- 金币因为拖尾问题暂时不使用内存池
	{name = "TD_Effect_JinBi",num = 5},	
	{name = "TD_Effect_JinBi1",num = 5},	
	{name = "TD_Effect_JinBi001", num = 5},
	
	-- 物理碰撞块
	{name = "ZTD_Skill_Rect",num = 5},

	--气球怪特效
	{name = "Effect_TF_baozha", num = 5},
	{name = "Effect_TF_baozhazhandan", num = 5},
	{name = "TD_BalloonPoint", num = 5},
	
	--ui放到ui池子里
	{name = "TD_TextEffect", num = 2, isUI = true},	
	{name = "TD_TextEffect1", num = 2, isUI = true},
	{name = "ZTD_NodeTablePlayer",num = 2, isUI = true},
	--{name = "ZTD_NodeGuideMask",num = 1, isUI = true},
	
	--{name = "TD_Effect_UI_Beishuzengjia",num = 1, isUI = true},
	--{name = "TD_Effect_UI_BSZJSX",num = 1, isUI = true},	
	
	-- {name = "ZhuanPan_yigui",num = 2, isUI = true},
	-- {name = "ZhuanPan",num = 2, isUI = true},
	-- {name = "ZhuanPan_dubao",num = 2, isUI = true},
	
	{name = "TD_BombZhuanPan", num = 2, isUI = true},
	{name = "TD_BalloonUi", num = 2, isUI = true},
	
	--转盘
	{name = "TD_TurnTableUi", num = 2, isUI = true},
	{name = "TD_TurnTextEffect", num = 2, isUI = true},
	-- {name = "Effect_UI_ZhuanPanShuZiTw", num = 1},
	{name = "TD_HERO_02_zidan01", num = 1},
	
	-- 尸鬼龙奖牌
	--{name = "ZTD_ghost_show", num = 1, isUI = true},
	--碎片掉落
	{name = "TD_Effect_baoshi", num = 1, isUI = true},
	{name = "Effects_suipianhuishou", num = 1, isUI = true},

	--闪电特效
	{name = "Effect_UI_AmuletLine", num = 1, isUI = true},
	--闪电球
	{name = "TD_Effect_Sandian01", num = 1},
	--巨人奖牌
	{name = "GiantMedal", num = 2, isUI = true},
	--碎屏UI
	{name = "Effect_UI_SSjurenbao", num = 1, isUI = true},
	--碎屏特效
	{name = "Effect_ET_SSjurenbao", num = 1},
	
	--奖池排行榜Item
	{name = "ZTD_RankItem", num = 2, isUI = true},
	--奖池前三排行榜Item
	{name = "ZTD_TopThreeItem", num = 2, isUI = true},

	--封印UI
	{name = "Effect_UI_baojiang01", num = 1, isUI = true},
	--马小玲头顶UI
	{name = "Effect_UI_WXzi", num = 1, isUI = true},
	{name = "Effect_UI_WXzi01", num = 1, isUI = true},
}


return M