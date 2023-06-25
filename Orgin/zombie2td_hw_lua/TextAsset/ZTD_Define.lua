
local Def = {}

-- msg

-- 登录成功
Def.MsgLoginSuccess = "ZTD_LoginSuccess";

-- 金币同步
Def.MsgScMoneyChange = "ZTD_ScMoneyChange";

-- 玩家加入
Def.MsgPlayerJoin = "ZTD_PlayerJoin";

-- 有玩家离开
Def.MsgPlayerLeave = "ZTD_PlayerLeave";

-- 打开某英雄位置的召唤页
Def.MsgOpenSummon = "ZTD_OpenSummon";

-- 打开了英雄菜单
Def.MsgOpenHeroMenu = "ZTD_OpenHeroMenu";

-- 开始挂机
Def.MsgTrustOn = "ZTD_TrustOn";

--重连
Def.MsgReconnect = "ZTD_Reconnect";

-- 清楚英雄锁定
Def.MsgCleanHeroLock = "ZTD_CleanLock";

-- 金币不足
Def.MsgLackMoney = "ZTD_LackMoney";

-- 刷新倍率
Def.MsgRefreshRadio = "ZTD_RefreshRadio";

-- 塔防模式销毁
Def.MsgRelease = "ZTD_Release";

-- 退出模式
Def.MsgDoExit = "ZTD_DoExit";

-- 英雄换位
Def.MsgHeroChange = "ZTD_HeroChange";

-- 点击了地图
Def.MsgClkMap = "ZTD_ClkMap";

-- 英雄分值变化
Def.MsgCostChange = "ZTD_CostChange";

-- 后台回复
Def.MsgGameResume = "ZTD_GameResume";

-- 刷新当前顶部总金币
Def.MsgRefreshGold = "ZTD_RefreshGold";
-- 刷新当前顶部总金币
Def.MsgRefreshFRT = "ZTD_RefreshFRT";

-- 刷新当前顶部总金币的挣钱量
Def.MsgRefreshGoldEarn = "ZTD_RefreshGold_E";

-- 关闭网络
Def.MsgNetClose = "ZTD_MsgNetClose";

-- 金币柱
Def.MsgGoldPillar = "ZTD_GoldPillar";

-- 新手引导用消息
Def.MsgGuideBattleView = "ZTD_GuideBattleView";
Def.MsgGuideOpenSummonHero = "ZTD_GuideOpenSummonHero";
Def.MsgGuideDoneSummonHero = "MsgGuideDoneSummonHero";
Def.MsgGuideAutoAtk = "MsgGuideAutoAtk";
Def.MsgGuideOpenMenu = "ZTD_GuideOpenMenu";

-- layer

-- 敌人层
Def.LayerZombie = "layer10";--"Zombie";
-- 英雄层
Def.LayerPlayer = "layer9";--"Player";
-- 触摸层
Def.LayerTouchObj = "layer8";--"Ground";
-- 点地板
Def.LayerMap = "layer11";--"Map";

--暗补
-- Def.OnpushShake = "OnpushShake";
-- Def.OnpushShakeClose = "OnpushShakeClose";
--周卡礼包
Def.OnDailyGiftGameReward = "OnDailyGiftGameReward";

--巨龙之怒
Def.OnPushSelfDragonState = "OnPushSelfDragonState";

--巨龙之怒红点刷新
Def.OnPushDragonRedPoint = "OnPushDragonRedPoint";

--藏宝阁碎片刷新
Def.OnPushChipRedPoint = "OnPushChipRedPoint";

--跳场
Def.OnPushMainToGame = "OnPushMainToGame";

--刷新挂机按钮
Def.OnPushTrusteeshipBtn = "OnPushTrusteeshipBtn";

--道具推送
Def.OnPushPropsInfo = "OnPushPropsInfo";

--碎片掉落
Def.OnPushDropMaterials = "OnPushDropMaterials";

--刷新玩家信息
Def.changeSelfInfo = "changeSelfInfo";

--气球怪免费次数
Def.SCPushBalloonTimes = "SCPushBalloonTimes";

--开关功能
Def.OnFunctionSwitch = "OnFunctionSwitch";

-- 推送这一批次连接怪
Def.OnPushConnectMonster = "OnPushConnectMonster";

Def.RefreshSealMoney = "RefreshSealMoney";

Def.OnPushSealConvertMoney = "OnPushSealConvertMoney";

Def.HistoryTrend = "HistoryTrend";

--------------nft start--------------
--卡片增加
Def.NFTCardAdd = "NFTCardAdd"
--卡片移除
Def.NFTCardRemove = "NFTCardRemove"

--------------nft end--------------
return Def
