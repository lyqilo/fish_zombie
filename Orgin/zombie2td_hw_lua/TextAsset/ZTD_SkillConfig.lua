local TdSkillConfig = {
	-- 毒爆怪技能
	{
		-- 技能id
		id = 10001;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 击中后的激活类型_技能_怪物
		hitActObj = "1_10003_10001";
		-- 单格碰撞宽高
		collWidth = 3;
		collHigh = 1.5;
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 技能框开始时间
		RectStartTime = 1.5;
		-- 技能框持续时间
		RectStayTime = 0.01;
		-- 免疫该技能的怪物（ID）
		InvalidId = 10001;
	},
	
	-- 派生毒爆怪的爆炸技能
	{
		-- 技能id
		id = 10003;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 单格碰撞宽高
		collWidth = 2;
		collHigh = 1;
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 技能框开始时间
		RectStartTime = 0.5;
		-- 技能框持续时间
		RectStayTime = 0.01;
		-- 免疫该技能的怪物（ID）
		InvalidId = 10001;
	},	
		
	-- 地面燃烧技能1
	{
		-- 技能id
		id = 10011;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 单格碰撞宽高
		collWidth = 1.4;
		collHigh = 0.8;
		-- 特效开始时间
		startTime = 0;
		-- 特效删除时间
		playTime = 7;		
		-- 资源文件
		file = "TD_Effect_dimianbao";		
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 技能框开始时间
		RectStartTime = 0.5;
		-- 技能框持续时间
		RectStayTime = 0.01;
		
		hitEff = "TD_dragon_baodian";
	},

	-- 地面燃烧技能2
	{
		-- 技能id
		id = 10012;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 单格碰撞宽高
		collWidth = 1;
		collHigh = 0.8;
		-- 特效开始时间
		startTime = 0;	
		-- 特效删除时间
		playTime = 8;	
		-- 资源文件
		file = "TD_Effect_dimianbao";		
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 技能框开始时间
		RectStartTime = 0.5;
		-- 技能框持续时间
		RectStayTime = 0.01;
		
		hitEff = "TD_dragon_baodian";
	},
	
	-- 地面派生技能
	{
		-- 技能id
		id = 10013;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 单格碰撞宽高
		collWidth = 13;
		collHigh = 1;
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 技能框开始时间
		RectStartTime = 0.0;
		-- 技能框持续时间
		RectStayTime = 0.01;
		
		hitEff = "TD_dragon_baodian";
	},

	-- 地面派生技能(强制结束)
	{
		-- 技能id
		id = 10014;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 单格碰撞宽高
		collWidth = 0;
		collHigh = 0;
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 技能框开始时间
		RectStartTime = 0.0;
		-- 技能框持续时间
		RectStayTime = 0;
	},	

	-- 喷火龙技能
	{
		-- 技能id
		id = 10015;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 单格碰撞宽高
		collWidth = 5;
		collHigh = 5;
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 技能框开始时间
		RectStartTime = 0.0;
		-- 技能框持续时间
		RectStayTime = 0.01;
	},		

	-- 气球怪技能
	{
		-- 技能id
		id = 10016;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 单格碰撞宽高
		collWidth = 3;
		collHigh = 1.5;
		-- 特效开始时间
		startTime = 1;	
		-- 特效删除时间
		playTime = 8;	
		-- 资源文件
		file = "Effect_TF_baozha";
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 技能框开始时间
		RectStartTime = 1;
		-- 技能框持续时间
		RectStayTime = 0.01;
		-- 免疫该技能的怪物（ID）
		InvalidId = 10005;
		balloonHitEff = "Effect_TF_baozhazhandan";
		balloonPrefab = "TD_BalloonPoint",
	},	
	-- 气球怪技能
	{
		-- 技能id
		id = 10017;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 单格碰撞宽高
		collWidth = 3;
		collHigh = 1.5;
		-- 特效开始时间
		startTime = 1;	
		-- 特效删除时间
		playTime = 8;	
		-- 资源文件
		file = "Effect_TF_baozha";
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 技能框开始时间
		RectStartTime = 1;
		-- 技能框持续时间
		RectStayTime = 0.01;
		-- 免疫该技能的怪物（ID）
		InvalidId = 10005;
		balloonHitEff = "Effect_TF_baozhazhandan";
		balloonPrefab = "TD_BalloonPoint",
	},	
	-- 气球怪技能
	{
		-- 技能id
		id = 10018;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 单格碰撞宽高
		collWidth = 3;
		collHigh = 1.5;
		-- 特效开始时间
		startTime = 1;	
		-- 特效删除时间
		playTime = 8;	
		-- 资源文件
		file = "Effect_TF_baozha";
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 技能框开始时间
		RectStartTime = 1;
		-- 技能框持续时间
		RectStayTime = 0.01;
		-- 免疫该技能的怪物（ID）
		InvalidId = 10005;
		balloonHitEff = "Effect_TF_baozhazhandan";
		balloonPrefab = "TD_BalloonPoint",
	},	
	-- 巨人技能
	{
		-- 技能id
		id = 10019;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 单格碰撞宽高
		collWidth = 13;
		collHigh = 8;
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 资源文件
		file = "Effect_ET_SSjurenbao";
		-- 特效开始时间
		startTime = 0;	
		-- 特效删除时间
		playTime = 5;	
		-- 技能框开始时间
		RectStartTime = 2;
		-- 技能框持续时间
		RectStayTime = 0.01;
		-- 免疫该技能的怪物（ID）
		InvalidId = 10008;
	},	
	-- 巨人技能
	{
		-- 技能id
		id = 10020;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 单格碰撞宽高
		collWidth = 13;
		collHigh = 8;
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 资源文件
		file = "Effect_ET_SSjurenbao";
		-- 特效开始时间
		startTime = 0;	
		-- 特效删除时间
		playTime = 5;	
		-- 技能框开始时间
		RectStartTime = 2;
		-- 技能框持续时间
		RectStayTime = 0.01;
		-- 免疫该技能的怪物（ID）
		InvalidId = 10008;
	},	
	-- 巨人技能
	{
		-- 技能id
		id = 10021;
		-- 类型1:瞬发，范围内
		sType = 1;
		-- 单格碰撞宽高
		collWidth = 13;
		collHigh = 8;
		-- 碰撞形状（矩形）
		rect = "ZTD_Skill_Rect";
		-- 资源文件
		file = "Effect_ET_SSjurenbao";
		-- 特效开始时间
		startTime = 0;	
		-- 特效删除时间
		playTime = 5;	
		-- 技能框开始时间
		RectStartTime = 2;
		-- 技能框持续时间
		RectStayTime = 0.01;
		-- 免疫该技能的怪物（ID）
		InvalidId = 10008;
	},	
}

return TdSkillConfig;