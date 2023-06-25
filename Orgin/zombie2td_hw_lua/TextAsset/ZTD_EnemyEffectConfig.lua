local TdEnemyEffConfig = {
	-- 特效id对应ZTD_EnemyConfig文件中effectId
	{
		id = 1;
		-- 死亡特效(开始)
		deadStartEffect = {"TD_Effect_dubaoguai"};
		-- 死亡特效(结束)
		deadEndEffect = {"SS_04_01_baoza02_circle"};
	},
	
	{
		id = 2;
		-- 死亡特效(开始)
		deadStartEffect = {"TD_Effect_fumo","TD_Effect_dubaoguai"};
		-- 死亡特效(结束)
		deadEndEffect = {"SS_04_01_baoza02_circle"};
	},	
	
	{
		id = 3;
		-- 死亡特效(开始)
		deadStartEffect = {"TD_Efffect_ywzhaohuan", "TD_Efffect_ywtou"};	
	},
}

return TdEnemyEffConfig;