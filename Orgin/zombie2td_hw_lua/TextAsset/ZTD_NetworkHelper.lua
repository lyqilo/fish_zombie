local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local proto = ZTD.ClientProto;

local ZTD_NetworkHelper = {}

--请求消息的协议号
ZTD_NetworkHelper.RequestOps = {
    CSLoginGameWithToken = proto.shared_operation_pb.Req_LoginGameWithToken,
    CSRequestAttack = proto.shared_operation_pb.Req_RequestAttack,
    --游戏模式
    CSEnterStage = proto.shared_operation_pb.Req_EnterStage, 
     --退出游戏
    CSLogoutGame = proto.shared_operation_pb.Req_LogoutGame,
    CSPing = proto.shared_operation_pb.Req_Ping,
    --倍率发给服务器
    CSKeepRatio = proto.shared_operation_pb.Req_KeepRatio,
	--挂机
	CSGetTrusteeship = proto.shared_operation_pb.Req_GetTrusteeship,
	CSSetTrusteeship = proto.shared_operation_pb.Req_SetTrusteeship;
	CSEndTrusteeship = proto.shared_operation_pb.Req_EndTrusteeship;	
	-----塔防模式相关-----
	CSGetTowerMonster = proto.shared_operation_pb.Req_GetTowerMonster;
	CSTowerUpdateHero = proto.shared_operation_pb.Req_TowerUpdateHero;
	CSTowerHeroAtkInfo = proto.shared_operation_pb.Req_TowerHeroAtkInfo;
	CSTowerPlayerLockTarget = proto.shared_operation_pb.Req_TowerPlayerLockTarget;
	
	CSTowerMonsterExit = proto.shared_operation_pb.Req_TowerMonsterExit;
	CSGetTowerStep = proto.shared_operation_pb.Req_GetTowerNewGuide;
	CSSetTowerStep = proto.shared_operation_pb.Req_SetTowerNewGuide;
	----------------------
	
	CSGetCurrentTime = proto.shared_operation_pb.Req_GetCurrentTime,
	
	CSChangeBackground = proto.shared_operation_pb.Req_ChangeBackground,
	
	CSChangePoisonBomTimes = proto.shared_operation_pb.Req_ChangePoisonBomTimes,
	
	CSTowerExchangeHero = proto.shared_operation_pb.Req_TowerExchangeHero,
	
	CSPoisonBombLocation = proto.shared_operation_pb.Req_PoisonBombLocation;
	
	CSOneKeyUpdateHero = proto.shared_operation_pb.Req_OneKeyUpdateHero;
	
	CSDragonRelease = proto.shared_operation_pb.Req_DragonRelease;
	
	CSGetRemoveMonsters = proto.shared_operation_pb.Req_GetRemoveMonsters;
	
	CSButtonRecords = proto.shared_operation_pb.Req_ButtonRecords;
	
	CSDebugData = proto.shared_operation_pb.Req_DebugData;

	CSGetDragonProps = proto.shared_operation_pb.Req_GetDragonProps;

	CSEquipDragonProps = proto.shared_operation_pb.Req_EquipDragonProps;

	CSGetShopInfo = proto.shared_operation_pb.Req_GetShopInfo;
	CSGetMaterialsInfo = proto.shared_operation_pb.Req_GetMaterialsInfo;
	CSExchangeBox = proto.shared_operation_pb.Req_ExchangeBox;
	CSDoublingBox = proto.shared_operation_pb.Req_DoublingBox;
	CSShopBuy = proto.shared_operation_pb.Req_ShopBuy;
	CSSetExchangeBox = proto.shared_operation_pb.Req_SetExchangeBox;
	CSAutoExchangeBox = proto.shared_operation_pb.Req_AutoExchangeBox;
	CSSealConvertMoney = proto.shared_operation_pb.Req_SealConvertMoney;
}

--请求和返回一一对应，返回是没有协议号的，只有协议名
--如果不需要处理请求返回的参数，则写空字符串
ZTD_NetworkHelper.ResponseName = {
    CSLoginGameWithToken = "SCLoginGameWithToken",
	CSGetCurrentTime = "SCGetCurrentTime",
	CSChangeBackground = "",
	CSEnterStage = "SCEnterStage",
	CSTowerExchangeHero = "";
	-----塔防模式相关-----
	CSGetTowerMonster = "",
	CSTowerUpdateHero = "SCTowerUpdateHero",
	CSTowerHeroAtkInfo = "",
    CSGetTrusteeship = "SCGetTrusteeship",
    CSSetTrusteeship = "",	
	CSEndTrusteeship = "",	
	CSTowerPlayerLockTarget = "SCTowerPlayerLockTarget",
	CSTowerMonsterExit = "",
	CSGetTowerStep = "SCGetTowerGuide",
	CSSetTowerStep = "",
	CSPoisonBombLocation = "",
	CSOneKeyUpdateHero = "",
	CSDragonRelease = "SCDragonRelease",
	CSGetRemoveMonsters = "SCGetRemoveMonsters",
	CSButtonRecords = "",
	CSDebugData = "",
	CSGetDragonProps = "SCGetDragonProps",
	CSEquipDragonProps = "SCEquipDragonProps",
	CSGetShopInfo = "SCGetShopInfo",
	CSGetMaterialsInfo = "SCGetMaterialsInfo",
	CSExchangeBox = "SCExchangeBox",
	CSDoublingBox = "SCDoublingBox",
	CSShopBuy = "SCShopBuy",
	CSSetExchangeBox = "SCSetExchangeBox",
	CSAutoExchangeBox = "SCAutoExchangeBox",
	CSSealConvertMoney = "SCSealConvertMoney",
	----------------------
}

--客户端推送消息的协议号
ZTD_NetworkHelper.PushOps = {
    
}

--服务器主推协议号
ZTD_NetworkHelper.OnPushName = {
    [proto.shared_operation_pb.Push_SyncMoney] = "SCSyncMoney",
	[proto.shared_operation_pb.Push_LogoutGame] = "SCLogoutGame",
	[proto.shared_operation_pb.Push_EndTrusteeship] = "SCEndTrusteeship",
	
	-- 毒爆
	[proto.shared_operation_pb.Push_PoisonBomTimes] = "SCPoisonBomTimes",
    [proto.shared_operation_pb.Push_BalloonTimes] = "SCPushBalloonTimes",
	
	-----塔防模式相关-----
	 [proto.shared_operation_pb.Push_LeaveTowerTable] = "SCLeaveTowerTable",
	 [proto.shared_operation_pb.Push_NotifyTowerTablePlayer] = "SCNotifyTowerTablePlayer",
	 [proto.shared_operation_pb.Push_GetTowerMonster] = "SCGetTowerMonster",
	 [proto.shared_operation_pb.Push_TowerMonster] = "SCTowerMonster",
	 [proto.shared_operation_pb.Push_TowerUpdateHero] = "SCPushTowerUpdateHero",
	 [proto.shared_operation_pb.Push_TowerHeroAtkInfo] = "SCTowerHeroAtkInfo",
	 [proto.shared_operation_pb.Push_TowerPlayerLockTarget] = "SCTowerPlayerLockTarget",
	 [proto.shared_operation_pb.Push_SyncGetTowerMonster] = "SCSyncGetTowerMonster",
	 [proto.shared_operation_pb.Push_TowerExchangeHero] = "SCTowerExchangeHero",
	 [proto.shared_operation_pb.Push_LeaveTowerTableCountdown] = "SCLeaveTowerTableCountdown",
	 [proto.shared_operation_pb.Push_PoisonBombLocation] = "SCPoisonBombLocation",
	 [proto.shared_operation_pb.Push_PoisonBombConvert] = "SCPoisonBombConvert",
	 [proto.shared_operation_pb.Push_PoisonBombType] = "SCPoisonbombTypes",
	 [proto.shared_operation_pb.Push_OneKeyUpdateHero] = "SCOneKeyUpdateHero",
	
	 [proto.shared_operation_pb.Push_DragonRelease] = "SCPushDragonRelease",
	 [proto.shared_operation_pb.Push_DragonEnd] = "SCPushDragonEnd",
	 [proto.shared_operation_pb.Push_SelfDragonState] = "SCPushSelfDragonState",
	
	 [proto.shared_operation_pb.Push_GhostDragonRelease] = "SCPushGhostDragonRelease",
	 [proto.shared_operation_pb.Push_GhostDragonEnd] = "SCPushGhostDragonEnd",
	 [proto.shared_operation_pb.Push_SelfGhostDragonState] = "SCPushSelfGhostDragonState",
	
	 [proto.shared_operation_pb.Push_SyncHeroMoney] = "SCPushSyncHeroMoney",
	
	 [proto.shared_operation_pb.Push_PushMonsterDead] = "SCPushMonsterDead",
	
	 [proto.shared_operation_pb.Push_PushMonsterBuff] = "SCPushMonsterBuff",

	 [proto.shared_operation_pb.Push_PlayerVipLevel] = "SCPlayerVipLevel",

	 [proto.shared_operation_pb.Push_DragonProps] = "SCPushDragonProps",
	 [proto.shared_operation_pb.Push_PropsInfo] = "SCPushPropsInfo",
	 [proto.shared_operation_pb.Push_DropMaterials] = "SCPushDropMaterials",
	 [proto.shared_operation_pb.Push_FunctionSwitch] = "SCFunctionSwitch",
	 [proto.shared_operation_pb.Push_ConnectMonster] = "SCPushConnectMonster",
	 [proto.shared_operation_pb.Push_GiantUpgrade] = "SCGiantUpgrade",
	 [proto.shared_operation_pb.Push_PushGiantEnd] = "SCPushGiantEnd",
	 [proto.shared_operation_pb.Push_AcquireMxlSeal] = "SCAcquireSeal",
	 [proto.shared_operation_pb.Push_DropCard] = "SCDropCard",
	----------------------
}


ZTD_NetworkHelper.RequestCfg = {
    --请求个人信息
    CSLoginGameWithToken = {delayTime = 10},
    CSPing = {delayTime = 5},
}        

function ZTD_NetworkHelper.MakeMessage(name,buff)
    local msg = proto.client[name]
    if msg == nil then
        log("--------------协议不存在：" .. name)
    else
        msg = msg()
        if buff and buff ~= "" then
            msg:ParseFromString(buff)
        end
    end
    return msg
end


function ZTD_NetworkHelper.HttpMakeMessage(name,data)
 
	local msg = proto.client[name]
    if msg == nil then
        logError("Http协议不存在：" .. name)
    else
        msg = msg()
    end
    if(data) then
        for k,v in pairs(data) do
            msg[k] = v
        end
    end
	local req = msg:SerializeToString();
    return req
end



return ZTD_NetworkHelper
