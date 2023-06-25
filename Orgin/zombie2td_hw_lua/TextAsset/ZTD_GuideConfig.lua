local ZTD = require("ZTD")

-- 消息一览：
-- 是否在战斗页面打开，ZTD.Define.MsgGuideBattleView
-- 是否展开了右上菜单栏，ZTD.Define.MsgGuideOpenMenu
-- 是否打开了英雄召唤页，ZTD.Define.MsgGuideOpenSummonHero
-- 是否召唤了英雄，ZTD.Define.MsgGuideDoneSummonHero
-- 是否开启了自动攻击,ZTD.Define.MsgGuideAutoAtk

-- 完成条件:
-- 使用消息，当收到消息后完成
-- Click，点击引导后完成
-- Show, 显示的瞬间就当作完成

local GuideConfig = {
[1] = 
{
	-- 引导步数
	step = 1,
	-- 光圈坐标
	pos = "HeroPos",
	-- 光圈伸缩
	haloScale = 0.8;
	-- 引导文字
	gText = "点击展开<color=#D26F13FF>召唤面板</color>",
	-- 点击执行节点
	addClick = "HeroPos",
	-- 绑定的消息
	bindGameMsg = ZTD.Define.MsgGuideBattleView,
	-- 完成条件
	finshCondition = ZTD.Define.MsgGuideOpenSummonHero,
	arrowDir = 3,	
},

[2] = 
{
	-- 引导步数
	step = 1,
	-- 光圈坐标
	pos = "ZTD_NodeSummon/btn_summon_confirm",
	-- 光圈伸缩
	haloScale = 0.8;	
	-- 引导文字
	gText = "点击召唤英雄<color=#D26F13FF>出战</color>",
	-- 点击执行节点
	addClick = "ZTD_NodeSummon/btn_summon_confirm",
	-- 绑定的消息
	bindGameMsg = ZTD.Define.MsgGuideOpenSummonHero,
	-- 完成条件
	finshCondition = "Click",
	arrowDir = 0,	
},


[3] = 
{
	-- 引导步数
	step = 2,
	-- 光圈坐标
	pos = "btn_autoBattle",
	-- 光圈伸缩
	haloScale = 0.4;	
	-- 引导文字
	gText = "点击开启<color=#D26F13FF>自动攻击</color>",
	-- 点击执行节点
	addClick = "btn_autoBattle",
	-- 绑定的消息
	bindGameMsg = ZTD.Define.MsgGuideDoneSummonHero,
	-- 完成条件
	finshCondition = "Show",	
	arrowDir = 0,	
},
--[[
[4] = 
{
	-- 引导步数
	step = 3,
	-- 光圈坐标
	pos = "top_right/btn_more",
	-- 光圈伸缩
	haloScale = 0.4;	
	-- 引导文字
	gText = nil,
	-- 点击执行节点
	addClick = "top_right/btn_more",
	-- 绑定的消息
	bindGameMsg = ZTD.Define.MsgGuideBattleView,
	-- 完成条件
	finshCondition = "Click",	
},

[5] = 
{
	-- 引导步数
	step = 3,
	-- 光圈坐标
	pos = "top_right/bg_menu/btn_room",
	-- 光圈伸缩
	haloScale = 0.4;	
	-- 引导文字
	gText = "点击可以<color=#D26F13FF>更换房间</color>",
	-- 强制箭头方向 0:上 1:下 2:左 3:右
	arrowDir = 2,	
	-- 点击执行节点
	addClick = "top_right/bg_menu/btn_room",
	-- 绑定的消息
	bindGameMsg = ZTD.Define.MsgGuideOpenMenu,
	-- 完成条件
	finshCondition = "Show",	
	-- 退出条件
	--quitCondition = ZTD.Define.MsgGuideOpenMenu,
},
--]]
}

return GuideConfig;