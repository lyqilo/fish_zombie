local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local ZTD_Request = {}
function ZTD_Request.LoginReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSLoginGameWithToken")
    req.PlayerId = param.PlayerId
    req.Token = param.Token
    ZTD.NetworkManager.Request("CSLoginGameWithToken", req, succCb, errCb, true)
end

function ZTD_Request.AttackReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSRequestAttack")
    req.Ratio = param.Ratio
    req.MonsterId = param.MonsterId
    req.Mode = param.Mode
    req.PositionId = param.PositionId
	-- 特殊怪相关
    req.UsePositionId = param.UsePositionId or 0
    req.UsePositionTimes = param.UsePositionTimes or 0
	-- 巨龙之怒相关
	req.DragonEnd = param.DragonEnd or false;
	if req.DragonEnd then
		req.SpecialType = param.SpecialType;
		--logError(os.date("%Y-%m-%d %H:%M:%S:") .. "00000000000000DragonEnd:" .. req.DragonMode)
	end	
	
	-- 共通怪物列表
	if param.SpecialInfo then
		req.SpecialType = param.SpecialType;
		for _,v in ipairs(param.SpecialInfo) do
			local data = ZTD.NetworkHelper.MakeMessage("SpecialMonsterAttack");
			data.PositionId = v.PositionId;
			data.MonsterId = v.MonsterId;
			data.ChannelId = v.ChannelId or 0;
			data.ProcessTime = v.ProcessTime or 0;			
			table.insert(req.SpecialInfo, data)
		end
		--logError(os.date("%Y-%m-%d %H:%M:%S:") .. "DragonInfos") 
	end	
	
	req.HeroUniqueId = param.HeroUniqueId or 0;
	--logError(os.date("%Y-%m-%d %H:%M:%S:") .. "AttackReq----------->" .. GC.uu.Dump(req))
    ZTD.NetworkManager.Request("CSRequestAttack", req, succCb, errCb)
end

function ZTD_Request.UpGradeHeroReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSUpgradeHeroInfo")
    req.ID = param.ID
    req.KeyToUpgrade = param.KeyToUpgrade
    ZTD.NetworkManager.Request("CSUpgradeHeroInfo", req, succCb, errCb)
end

function ZTD_Request.UnlockHeroReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSUnlockHeroInfo")
    req.ID = param.ID
    ZTD.NetworkManager.Request("CSUnlockHeroInfo", req, succCb, errCb)
end

function ZTD_Request.UpdateHeroInfoReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSUpdateHeroInfo")
    for _,v in ipairs(param) do
        local data = ZTD.NetworkHelper.MakeMessage("HeroInfo")
        data.ID = v.ID
        data.Level = v.Level
        data.Position = v.Position
        data.Unlock = v.Unlock
        table.insert(req.Info,data)
    end    
    ZTD.NetworkManager.Request("CSUpdateHeroInfo", req, succCb, errCb)
end

function ZTD_Request.GetLiquidMedicineReq(succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetLiquidMedicine")
    ZTD.NetworkManager.Request("CSGetLiquidMedicine", req, succCb, errCb)
end

function ZTD_Request.CSBuyLiquidMedicineReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSBuyLiquidMedicine")
    req.ID = param.ID
    req.Num = param.Num
    ZTD.NetworkManager.Request("CSBuyLiquidMedicine", req, succCb, errCb)
end

function ZTD_Request.CSUseLiquidMedicineReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSUseLiquidMedicine")
    req.ID = param.ID
    ZTD.NetworkManager.Request("CSUseLiquidMedicine", req, succCb, errCb)
end

function ZTD_Request.CSCompoundLiquidMedicineReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSCompoundLiquidMedicine")
    req.SrcID = param.SrcID
    req.DestID = param.DestID
    req.DestNum = param.DestNum
    ZTD.NetworkManager.Request("CSCompoundLiquidMedicine", req, succCb, errCb)
end

function ZTD_Request.CSAchievementInfoReq(succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetAchievementInfo")    
    ZTD.NetworkManager.Request("CSGetAchievementInfo", req, succCb, errCb)
end

function ZTD_Request.CSGetLaboratoryInfoReq(succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetLaboratoryInfo")    
    ZTD.NetworkManager.Request("CSGetLaboratoryInfo", req, succCb, errCb)
end

function ZTD_Request.CSUpdateLaboratoryInfoReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSUpdateLaboratoryInfo")
    req.ID = param.ID
    req.OneKey = param.OneKey
    ZTD.NetworkManager.Request("CSUpdateLaboratoryInfo", req, succCb, errCb)
end

function ZTD_Request.CSUnlockLaboratoryInfoReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSUnlockLaboratoryInfo")
    req.ID = param.ID
    ZTD.NetworkManager.Request("CSUnlockLaboratoryInfo", req, succCb, errCb)
end

function ZTD_Request.CSEnterStageReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSEnterStage")
    req.enter = param.enter
    req.Mode = param.Mode
    ZTD.NetworkManager.Request("CSEnterStage", req, succCb, errCb)
end

function ZTD_Request.CSGetDailyTaskInfoReq(succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetDailyTaskInfo")
    ZTD.NetworkManager.Request("CSGetDailyTaskInfo", req, succCb, errCb)
end

function ZTD_Request.CSGetDailyTaskAwardReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetDailyTaskAward")
    req.ID = param.ID
    ZTD.NetworkManager.Request("CSGetDailyTaskAward", req, succCb, errCb)
end

function ZTD_Request.CSGetDailyTaskScheduleAwardReq(id,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetDailyTaskScheduleAward")
    req.ScheduleId = id
    ZTD.NetworkManager.Request("CSGetDailyTaskScheduleAward", req, succCb, errCb)
end

function ZTD_Request.CSShareFriendCircleReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSShareFriendCircle")
    req.ID = param.ID
    ZTD.NetworkManager.Request("CSShareFriendCircle", req, succCb, errCb)
end


function ZTD_Request.CSGetHighModeMonsterCfgReq(succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetHighModeMonsterCfg")
    ZTD.NetworkManager.Request("CSGetHighModeMonsterCfg", req, succCb, errCb)
end

function ZTD_Request.CSSetHighModeMonsterCfgReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSSetHighModeMonsterCfg")
    for _,v in ipairs(param.MonsterSet) do
        local data = ZTD.NetworkHelper.MakeMessage("HighModeMonster")
        data.Type = v.Type
        data.IsSelect = v.IsSelect
        table.insert(req.MonsterSet,data)
    end
	req.Number = param.Number;
    ZTD.NetworkManager.Request("CSSetHighModeMonsterCfg", req, succCb, errCb)
end

function ZTD_Request.CSGetTrusteeshipReq(succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetTrusteeship")
    ZTD.NetworkManager.Request("CSGetTrusteeship", req, succCb, errCb, true)
end

function ZTD_Request.CSSetTrusteeshipReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSSetTrusteeship")
	local Info = req.Info;
	
	Info.IsTrusteeship = param.IsTrusteeship;
	Info.HighSetValue = param.HighSetValue;
	Info.HighSetOpen = param.HighSetOpen;
	Info.LowSetValue = param.LowSetValue;
	Info.LowSetOpen = param.LowSetOpen;
	Info.TimeSetValue = param.TimeSetValue;
	Info.TimeSetOpen = param.TimeSetOpen;
	
    ZTD.NetworkManager.Request("CSSetTrusteeship", req, succCb, errCb)
end

function ZTD_Request.CSEndTrusteeshipReq(param, succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSEndTrusteeship")
	req.Notify = param.Notify;
    ZTD.NetworkManager.Request("CSEndTrusteeship", req, succCb, errCb, true)
end

function ZTD_Request.CSLogoutGameReq(succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSLogoutGame")
    ZTD.NetworkManager.Request("CSLogoutGame", req, succCb, errCb)
end

function ZTD_Request.CSChangeModeReq(succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSChangeMode")
    ZTD.NetworkManager.Request("CSChangeMode", req, succCb, errCb)
end

function ZTD_Request.CSGetNewGuideReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetNewGuide")
    req.StepType = param.StepType
    ZTD.NetworkManager.Request("CSGetNewGuide", req, succCb, errCb)
end

function ZTD_Request.CSUpdateNewGuideReq(succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSUpdateNewGuide")
    ZTD.NetworkManager.Request("CSUpdateNewGuide", req, succCb, errCb)
end

function ZTD_Request.CSGetAwardRecordReq(succCb,errCb)    
    local req = ZTD.NetworkHelper.MakeMessage("CSGetAwardRecord")
    ZTD.NetworkManager.Request("CSGetAwardRecord", req, succCb, errCb)
end

function ZTD_Request.CSGetWarFirePoolReq(succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetWarFirePool")
    ZTD.NetworkManager.Request("CSGetWarFirePool", req, succCb, errCb)
end

function ZTD_Request.CSLiquidMedicineUseTimeReq(param ,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSLiquidMedicineUseTime")
    req.ID = param.ID
    req.IsStop = param.IsStop
    ZTD.NetworkManager.Request("CSLiquidMedicineUseTime", req, succCb, errCb)
end

function ZTD_Request.CSPingReq(succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSPing")
    ZTD.NetworkManager.Request("CSPing", req, succCb, errCb)
end

function ZTD_Request.CSKeepRatioReq(Ratio,succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSKeepRatio")
    req.Ratio = Ratio
    ZTD.NetworkManager.Request("CSKeepRatio", req, succCb, errCb, true)
end

function ZTD_Request.CSStageResultReq(param,succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSStageResult")
    req.Success = param.Success
    ZTD.NetworkManager.Request("CSStageResult", req, succCb, errCb)
end

function ZTD_Request.CSTowerUpdateHeroReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSTowerUpdateHero")
	req.Info.HeroId = param.Info.HeroId;
	req.Info.PositionId = param.Info.PositionId;
	req.Leave = param.Leave;
    ZTD.NetworkManager.Request("CSTowerUpdateHero", req, succCb, errCb, true)
end

function ZTD_Request.CSTowerHeroAtkInfoReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSTowerHeroAtkInfo")
	for _, v in ipairs(param.Info) do
		local atkInfo = ZTD.NetworkHelper.MakeMessage("TowerHeroAtkInfo")
		atkInfo.HeroPositionId = v.HeroPositionId;
		atkInfo.IsAtk = v.IsAtk;
		table.insert(req.Info, atkInfo);
	end
    ZTD.NetworkManager.Request("CSTowerHeroAtkInfo", req, succCb, errCb)
end

function ZTD_Request.CSTowerPlayerLockTargetReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSTowerPlayerLockTarget")
	for _, v in ipairs(param.LockInfo) do
		local lockInfo = ZTD.NetworkHelper.MakeMessage("LockTargetInfo")
		lockInfo.PositionId = v.PositionId;
		lockInfo.TargetPositionId = v.TargetPositionId;
		table.insert(req.LockInfo, lockInfo);
	end
    ZTD.NetworkManager.Request("CSTowerPlayerLockTarget", req, succCb, errCb)
end

function ZTD_Request.CSGetCurrentTimeReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetCurrentTime")
    ZTD.NetworkManager.Request("CSGetCurrentTime", req, succCb, errCb)
end

function ZTD_Request.CSChangeBackgroundReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSChangeBackground")
	req.IsBack = param.IsBack;
    ZTD.NetworkManager.Request("CSChangeBackground", req, succCb, errCb, true)
end

function ZTD_Request.CSTowerMonsterExitReq(param,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSTowerMonsterExit")
	req.PositionId = param.PositionId;
    ZTD.NetworkManager.Request("CSTowerMonsterExit", req, succCb, errCb)
end

function ZTD_Request.CSGetTowerStepReq(succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetTowerStep")
    ZTD.NetworkManager.Request("CSGetTowerStep", req, succCb, errCb, true)
end

function ZTD_Request.CSSetTowerStepReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSSetTowerStep");
	req.GuideInfo.GuideStep = param.GuideStep;
	req.GuideInfo.IsFinsh = param.IsFinsh or false;

    ZTD.NetworkManager.Request("CSSetTowerStep", req, succCb, errCb)
end

----------------------

function ZTD_Request.CSChangePoisonBomTimes(param ,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSChangePoisonBomTimes")
    req.PositionId = param.PositionId
    req.UsePositionTimes = param.UsePositionTimes
    req.NewPositionId  = param.NewPositionId
    ZTD.NetworkManager.Request("CSChangePoisonBomTimes", req, succCb, errCb)
end

function ZTD_Request.CSTowerExchangeHeroReq(param ,succCb,errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSTowerExchangeHero")
    req.NewPositionId = param.NewPositionId
    req.OldPositionId  = param.OldPositionId 
    ZTD.NetworkManager.Request("CSTowerExchangeHero", req, succCb, errCb, true)
end

function ZTD_Request.CSPoisonBombLocationReq(param ,succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSPoisonBombLocation")
	for i, v in ipairs(param) do
		local bombInfo = ZTD.NetworkHelper.MakeMessage("PoisonBombLocation")
		bombInfo.id = v.id
		bombInfo.x = v.x
		bombInfo.y = v.y
		bombInfo.angle = v.angle
		table.insert(req.Info, bombInfo);
	end
    ZTD.NetworkManager.Request("CSPoisonBombLocation", req, succCb, errCb)
end

function ZTD_Request.CSOneKeyUpdateHeroReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSOneKeyUpdateHero")
	for i, v in ipairs(param.heroId) do
		table.insert(req.heroId, v);
	end
    ZTD.NetworkManager.Request("CSOneKeyUpdateHero", req, succCb, errCb)
end

function ZTD_Request.CSDragonReleaseReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSDragonRelease")
    req.Ratio = param.Ratio
    req.PropsID = param.PropsID
    ZTD.NetworkManager.Request("CSDragonRelease", req, succCb, errCb)
end

function ZTD_Request.CSGetRemoveMonstersReq(succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetRemoveMonsters")
    ZTD.NetworkManager.Request("CSGetRemoveMonsters", req, succCb, errCb)	
end

function ZTD_Request.CSButtonRecordsReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSButtonRecords")
    req.ID = param.ID;
    req.Mode = param.Mode;	
    ZTD.NetworkManager.Request("CSButtonRecords", req, succCb, errCb)	
end

function ZTD_Request.CSDebugDataReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSDebugData")
    req.DebugData = param.DebugData;
    ZTD.NetworkManager.Request("CSDebugData", req, succCb, errCb)	
end

function ZTD_Request.CSEquipDragonPropsReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSEquipDragonProps")
    req.PropsID = param.PropsID;
    ZTD.NetworkManager.Request("CSEquipDragonProps", req, succCb, errCb)	
end

function ZTD_Request.CSGetDragonPropsReq(succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetDragonProps")
    ZTD.NetworkManager.Request("CSGetDragonProps", req, succCb, errCb)	
end

function ZTD_Request.CSGetShopInfoReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetShopInfo")
    req.ShopInfoType = param.ShopInfoType
    ZTD.NetworkManager.Request("CSGetShopInfo", req, succCb, errCb, true)	
end

function ZTD_Request.CSGetMaterialsInfoReq(succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSGetMaterialsInfo")
    ZTD.NetworkManager.Request("CSGetMaterialsInfo", req, succCb, errCb)	
end

function ZTD_Request.CSExchangeBoxReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSExchangeBox")
    req.TypeID = param.TypeID
    ZTD.NetworkManager.Request("CSExchangeBox", req, succCb, errCb, true)	
end

function ZTD_Request.CSDoublingBoxReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSDoublingBox")
    req.IsDoubling = param.IsDoubling
    ZTD.NetworkManager.Request("CSDoublingBox", req, succCb, errCb, true)	
end

function ZTD_Request.CSShopBuyReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSShopBuy")
    req.PropsID = param.PropsID
    req.PropsNum = param.PropsNum
    ZTD.NetworkManager.Request("CSShopBuy", req, succCb, errCb, true)	
end

function ZTD_Request.CSSetExchangeBoxReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSSetExchangeBox")
    req.IsAutoExchange = param.IsAutoExchange
    req.IsAutoDoubling = param.IsAutoDoubling
    req.IsStart = param.IsStart
    ZTD.NetworkManager.Request("CSSetExchangeBox", req, succCb, errCb, true)	
end

function ZTD_Request.CSAutoExchangeBoxReq(param, succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSAutoExchangeBox")
    req.IsAuto = param.IsAuto
    ZTD.NetworkManager.Request("CSAutoExchangeBox", req, succCb, errCb, true)	
end

function ZTD_Request.CSSealConvertMoneyReq(succCb, errCb)
    local req = ZTD.NetworkHelper.MakeMessage("CSSealConvertMoney")
    ZTD.NetworkManager.Request("CSSealConvertMoney", req, succCb, errCb, true)	
end


---------------------Http请求协议相关部分---------------------
local HttpOpsMap = {
	--请求nft配置
    ReqNFTConfig = "/chain_prize/sync",
	--请求修改frtapp密码
    ReqModifyPwd = "/chain_prize/set_pwd",
    --请求当天排行
    ReqCurDayRank = "/chain_prize/daily/get_record_today",
    ReqTotalPower = "/chain_prize/season/power",
	--请求每日排行记录
    ReqDayRecord = "/chain_prize/daily/get_record",
	--请求当赛季排行
    ReqCurSeasonRank = "/chain_prize/season/get_record_today",
	--请求赛季排行记录
    ReqSeasonRecord = "/chain_prize/season/get_record",
	--请求当天奖池
    ReqDayPool = "/chain_prize/season/daily_pool",
	--请求当赛季奖池
    ReqSeasonPool = "/chain_prize/season/prize_pool",
	--领取奖池奖励
    ReqPoolReward = "/chain_prize/prize/receive",
	--历史赛季保存的记录
    ReqRecordList = "/chain_prize/season/list",
	--请求我的卡包
	ReqPack = "/chain_card/user/getusercard",
	--请求装备
	ReqArm = "/chain_card/user/setusercardequip",
	--请求合成
	ReqCompose = "/chain_card/user/cardfusion",
	--请求洗练
	ReqEnhance = "/chain_card/user/cardenhancement",
	ReqMarket = "/chain_exchange/shop/query",
	ReqBuyCard = "/chain_exchange/shop/buy",
	ReqSellCard = "/chain_card/user/cardexchange",
	ReqCancelSell = "/chain_exchange/shop/cancel",
	ReqSellingData = "/chain_exchange/shop/self/query",
	ReqSellRecord = "/chain_exchange/user/shop/record",
    --请求是否获得每日赠送卡牌
    ReqIsCard = "/chain_card/user/dailygivestatus",
    --领取每日赠送卡牌
    ReqGetCard = "/chain_card/user/getcarddailygive",
    -- 获取箱子数量
    ReqBoxes = "/chain_prize/boxes",
    -- 开启箱子
    ReqOpenbox = "/chain_prize/open_box",
    -- 玩家信息
    ReqNFTUserInfo = "/chain_card/user/userinfo",
}

function ZTD_Request.HttpRequest(name, data, sucFunc, errFunc, showWait)

	if not HttpOpsMap[name] or HttpOpsMap[name] == "" then logError(name.." Http 请求没有注册url") return end

    local ops = HttpOpsMap[name]

    --[[local ip = GC.SubGameInterface.GetUrlPrefix();
    local localGameIP = GC.SubGameInterface.GetLocalGameIP()
    if(localGameIP) then
        local splitStr = ZTD.Extend.SplitMask(localGameIP,'|')
        ip = 'http://'..splitStr[1]
    end--]]
	
	--正式服
	local ip = "https://rc.in-nft.com"
	--测试服
	--local ip = "http://47.241.27.199:80"
	--开发服
	--local ip = "http://172.13.7.15:80"
    
    if GC.DebugDefine.GetWebConfigState() == GC.DebugDefine.WebConfigState.Dev then
        ip = "http://172.13.7.15:80" -- "172.18.6.127:8000"
    elseif GC.DebugDefine.GetWebConfigState() == GC.DebugDefine.WebConfigState.Test then
        ip = "http://47.241.27.199:80"
    end

    local url = ip .. ops .. string.format("?token=%s&PlayerID=%s"
		,GC.Player.Inst():GetLoginInfo().Token
		,ZTD.PlayerData.GetPlayerId())
        
    -- log(GC.uu.Dump(url))
    ZTD.NetworkManager.HttpPost(url, data, sucFunc, errFunc, showWait)
end




return ZTD_Request