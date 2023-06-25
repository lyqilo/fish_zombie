--[[
    ActivityServerDefine 对应 CC.shared_enums_pb.AE_Invalid 类型
    self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")

    筹码合集 获取 配置 switchOn , redDot
    筹码合集 监听配置变化
    CC.Notifications.OnRefreshActivityBtnsState
    CC.Notifications.OnRefreshActivityRedDotState
]]
local ActivityServerDefine = require("Model/Define/ActivityServerDefine")
local CC = require("CC")

local ActivityDataMgr = {}
local Mgr = ActivityDataMgr

local activityCfg = {
    -- 免费合集
    DailyTurntableView = {switchOn = false, redDot = false, CollectionView = "FreeChips"}, --des = "每日转盘"---免费合集
    SignInView = {switchOn = false, redDot = false, CollectionView = "FreeChips"}, --des = "三十日签到"---免费合集
    LimmitAwardView = {switchOn = true, redDot = false, CollectionView = "FreeChips"}, --des = "限时登录奖励"---免费合集
    OnlineAward = {switchOn = true, redDot = false, CollectionView = "FreeChips"}, --des = "在线奖励"---免费合集
    OnlineLottery = {switchOn = false, redDot = false, CollectionView = "FreeChips"}, --des = "在线福利"---免费合集
    LoyKraThong = {switchOn = false, redDot = false, CollectionView = "FreeChips"}, --des = "水灯节"---免费合集
    BlessLotteryView = {switchOn = false, redDot = false, CollectionView = "FreeChips"}, --des = "祈福抽奖"---免费合集
    ActSignInView = {switchOn = false, redDot = false, CollectionView = "FreeChips"}, --des = "活动抽奖"}---免费合集
    CapsuleView = {switchOn = false, reDot = false, CollectionView = "FreeChips"}, --des = "扭蛋抽奖"---免费合集
    DailyLotteryView = {switchOn = false, reDot = false, CollectionView = "FreeChips"}, --des = "每日抽奖"---免费合集
    NoviceSignInView = {switchOn = true, redDot = false, CollectionView = "FreeChips"}, --des = "新手签到"---免费合集
    NewbieTaskView = {switchOn = true, redDot = false, CollectionView = "FreeChips"}, --des = "新手任务"---免费合集
    FragmentTaskView = {switchOn = true, redDot = false, CollectionView = "FreeChips"}, --des = "碎片任务"---免费合集
    ChristmasTaskView = {switchOn = false, redDot = false, CollectionView = "FreeChips"}, --des = "圣诞任务"---免费合集
    HCoinView = {switchOn = false, redDot = true, CollectionView = "FreeChips"}, --des = "算力火币"---免费合集
    HalloweenLoginGiftView = {switchOn = false, redDot = false, CollectionView = "FreeChips"}, --des = "万圣节登录好礼"---免费合集
    HolidayTaskView = {switchOn = false, redDot = false, CollectionView = "FreeChips"}, --节日任务（2022泼水节沙塔）
    -- 火星任务&&世界杯
    MarsTaskEntryView = {switchOn = false, redDot = false, CollectionView = "MarsTaskEntryView"}, --火星任务入口页
    WorldCupADPageView = {switchOn = false, redDot = false, CollectionView = "WorldCupADPageView"}, --世界杯入口页
    FlowWaterTaskView = {switchOn = false, redDot = false, CollectionView = "WorldCupView"}, --世界杯流水任务
    --  限时合集
    AchievementGiftMainView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "成就礼包"---限时合集
    NoviceGiftView = {switchOn = true, redDot = false, CollectionView = "SelectGift"}, --des = "新手礼包"---限时合集
    Act_EveryGift = {switchOn = true, redDot = false, CollectionView = "SelectGift"}, --des = "捕鱼礼包"---限时合集
    FundView = {switchOn = true, redDot = false, CollectionView = "SelectGift"}, --des = "七日基金"---限时合集
    LuckyTurntableView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "限时转盘"---限时合集
    TreasureBoxGiftView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "泼水节夺宝宝箱"---限时合集
    VipThreeCardView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "VIP3直升卡"---限时合集
    BrokeGiftView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "破产礼包"---限时合集
    BrokeBigGiftView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "大额破产"---限时合集
    NewPayGiftView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "累冲礼包"---限时合集
    FortuneCatView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "招财猫活动"---限时合集
    ElkLimitGiftView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "春节限时礼包"---限时合集
    DragonTurntableView = {switchOn = true, redDot = false, CollectionView = "SelectGift"}, --des = "神龙转盘礼包"---限时合集
    BatteryLotteryView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "捕鱼炮台礼包活动（赤焰龙击炮）"---限时合集
    BirthdayView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "生日礼包"---限时合集
    ElephantPiggy = {switchOn = false, redDot = false, CollectionView = ""}, --des = "大象流水礼包"---大厅icon
    FirstBuyGift = {switchOn = false, redDot = false, CollectionView = ""}, --des = "新手首充礼包"---大厅icon
    DebrisGift = {switchOn = false, redDot = false, CollectionView = ""}, --des = "碎片礼包"---实物商城
    AirplaneTurntableView = {switchOn = true, redDot = false, CollectionView = "SelectGift"}, --des = "飞机神龙转"---限时合集
    NewElkLimitGiftView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "限时秒杀" --月末月中活动界面icon
    MonthCardView = {switchOn = true, redDot = false, CollectionView = "SelectGift"}, --des = "月卡" --限时合集
    SpecialOfferGiftView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --"特价礼包（2022泼水节）"
    DailyDealsView = {switchOn = true, redDot = false, CollectionView = "SelectGift"}, --"飞机每日特惠礼包"
    CommonHolidayGiftView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --"通用节日促销礼包"
    SuperDailyGiftView = {switchOn = false, redDot = false, CollectionView = "SelectGift"}, --des = "特惠礼包"---限时合集
    -- 每日合集
    DailyGiftBuyu = {switchOn = true, redDot = false, CollectionView = "DailyGift"}, --des = "捕鱼"---每日礼包合集
    DailyGiftFourBuyu = {switchOn = true, redDot = false, CollectionView = "DailyGift"}, --des = "四人捕鱼"---每日礼包合集
    DailyGiftDummy = {switchOn = true, redDot = false, CollectionView = "DailyGift"}, --des = "Dummy"---每日礼包合集
    DailyGiftPokdeng = {switchOn = true, redDot = false, CollectionView = "DailyGift"}, --des = "Pokdeng"---每日礼包合集
    DailyGiftAirplane = {switchOn = true, redDot = false, CollectionView = "DailyGift"}, --des = "飞机"---每日礼包合集
    DailyGiftDiglett = {switchOn = true, redDot = false, CollectionView = "DailyGift"}, --des = "地鼠"---每日礼包合集
    DailyGiftZombie = {switchOn = true, redDot = false, CollectionView = "DailyGift"}, --des = "塔防"---每日礼包合集
    DailyGiftBull = {switchOn = true, redDot = false, CollectionView = "DailyGift"}, --des = "猎牛"---每日礼包合集
    DailyGiftPharaoh = {switchOn = true, redDot = false, CollectionView = "DailyGift"}, --des = "地鼠大乱斗"---每日礼包合集
    HolidayDiscountsView = {switchOn = false, redDot = false, CollectionView = "DailyGift"}, --des = "假日特惠"---每日礼包合集
    GiftSignInView = {switchOn = true, redDot = false, CollectionView = "DailyGift"}, --des = "每日礼包购买签到"---每日礼包合集内嵌icon
    -- 排行榜
    RankingListView = {switchOn = true, redDot = false}, --des = "排行榜"---排行榜
    WeekRankView = {switchOn = true, redDot = false}, --des = "周排行榜"---排行榜
    SongkranRankView = {switchOn = false, redDot = false}, --des = "拨水节排行"---排行榜
    MonthRankView = {switchOn = false, redDot = false}, --des = "月中排行榜"---月中活动
    WaterCaptureRankView = {switchOn = false, redDot = false}, --des = "捕获流水排行榜"---周年庆活动（活动时每天累计流水排名）
    WaterOtherRankView = {switchOn = false, redDot = false}, --des = "综合流水排行榜"---周年庆活动（活动时每天累计流水排名）
    TotalWaterRankView = {switchOn = false, redDot = false}, --des = "流水排行榜"（整个活动期间累计总流水排名）
    SuperTreasureView = {switchOn = false, redDot = false}, --des = "超级夺宝"---月中活动
    GiftExchangeView = {switchOn = false, redDot = false}, --des = "夺宝礼包"---月中活动
    ComposeCapsuleView = {switchOn = false, redDot = false}, --des = "合成扭蛋"---月中月末活动
    CompositeView = {switchOn = false, redDot = false}, --des = "合成大作战"---月中月末活动
    CompositeGiftView = {switchOn = false, redDot = false}, --des = "合成礼包"---月中月末活动
    BatteryRankView = {switchOn = false, redDot = false}, --des = "排行榜"---炮台排行榜
    -- 其他礼包或者活动
    GobackRewardView = {switchOn = false, redDot = false}, --des = "老玩家回归礼包"
    InviteLotteryView = {switchOn = false, redDot = false}, --des = "周年庆免费抽奖"
    AnniversaryTurntableView = {switchOn = false, redDot = false}, --des = "周年庆幸运转盘"
    DonateView = {switchOn = false, redDot = false}, --des = "功德捐献活动"
    HalloweenView = {switchOn = false, redDot = false}, --des = "2021万圣节大作战\水灯节派对"
    MarsTaskView = {switchOn = false, redDot = false},
    MonopolyView = {switchOn = false, redDot = false}, --des = "大富翁小游戏"
    MonopolyRankView = {switchOn = false, redDot = false}, --des = "大富翁排行榜"
    BatteryGiftView = {switchOn = false, redDot = false}, --des = "炮台限时礼包"
    MonthRebateView = {switchOn = false, redDot = false} --des = "月度返利福利"
}

--  一级锁需要屏蔽的界面
local needLockView = {
    ChristmasTaskView = true,
    ActSignInView = true,
    ElkLimitGiftView = true,
    MonthRankView = true,
    GiftSignInView = true,
    DailyLotteryView = true,
    HolidayDiscountsView = true,
    OnlineLottery = true,
    HCoinView = true,
    NewElkLimitGiftView = true,
    GobackRewardView = true,
    InviteLotteryView = true,
    AnniversaryTurntableView = true,
    DonateView = true,
    HalloweenLoginGiftView = true,
    CapsuleView = true,
    HalloweenView = true,
    MarsTaskView = true,
    MarsTaskEntryView = true,
    WaterCaptureRankView = true,
    WaterOtherRankView = true,
    WorldCupADPageView = true,
    BatteryLotteryView = true,
    BlessLotteryView = true
}

function Mgr.Register()
    CC.HallNotificationCenter.inst():register(Mgr, Mgr.ReqInfo, CC.Notifications.OnResume)
end

function Mgr.UnInit()
    CC.HallNotificationCenter.inst():unregisterAll(Mgr)
end

-- 进入大厅会调用
function Mgr.ReqInfo()
    CC.Request(
        "ReqGetActivityInfo",
        nil,
        function(errCode, data)
            if errCode == 0 then
                -- log(CC.uu.Dump(data,"ReqGetActivityInfo =",10))
                Mgr.SetInfo(data)
                CC.HallNotificationCenter.inst():post(CC.Notifications.ActivitySwitch)
            end
        end,
        function(data)
            -- logError(CC.uu.Dump(data,"ReqGetActivityInfo =",10))
        end
    )
end

function Mgr.SetInfo(data)
    -- // 活动信息
    -- message ActivityData {
    --     required int64 Id = 1;
    --     optional string Name = 2;
    --     optional string Desc = 3;
    --     optional int64 LoopInterval = 4;
    --     optional int32 Type = 5;
    --     repeated ActivityPlatform Platforms = 6;
    -- }
    -- //活动区分平台信息
    -- message ActivityPlatform {
    --     optional int32 OS = 1;
    --     optional bool Open = 2;
    --     optional string Start = 3;
    --     optional string End = 4;
    --     optional string ShowStart = 5;
    --     optional string ShowEnd = 6;
    --     optional int64 StartCD = 7;
    --     optional bool Show = 8;
    -- }
    local Items = data.Items or {}
    -- 服务器没有配置PC的活动配置，开发环境先这么处理
    local osEnum = CC.Platform.GetOSEnum()
    if Application.isEditor or osEnum == CC.shared_enums_pb.OST_PC then
        osEnum = CC.shared_enums_pb.OST_Android
    end

    for _, activityData in ipairs(Items) do
        local param = nil
        if activityData.Channels and table.length(activityData.Channels) > 0 then
            for _, v in ipairs(activityData.Channels) do
                if v.Channel == tonumber(AppInfo.ChannelID) then
                    param = v
                    break
                end
            end
        end
        if not param then
            param = activityData.Platforms[osEnum]
        end
        local key = ActivityServerDefine[activityData.Id]

        if key and activityCfg[key] then
            if param then
                local info = {}
                info.switchOn = param.Show
                info.redDot = param.Show and param.Open
                Mgr.SetActivityInfoByKey(key, info)
            end
        end
    end

    Mgr.CheckSwitchData()
    Mgr.SetMidActivetyStatus()
    Mgr.CheckActiveEntryStatus()
end

function Mgr.SetActivityInfoByKey(key, data)
    local cfg = activityCfg[key]

    for nkey, v in pairs(data) do
        local oldValue = cfg[nkey]
        if nkey == "switchOn" and Mgr.SetShowLockView(key) then
            v = false
        end
        if (key == "SuperTreasureView" or key == "GiftExchangeView") and CC.ChannelMgr.CheckOppoChannel() then
            v = false
        end
        cfg[nkey] = Mgr.CheckClientSwitch(nkey, key, v)

        if nkey == "switchOn" and v ~= oldValue then
            --开关变化
            CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshActivityBtnsState, key, v)
        end
        if nkey == "redDot" and v ~= oldValue then
            --红点变化
            CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshActivityRedDotState, key, v)
        end
    end

    -- if key == "CompositeView" then
    --     activityCfg["ComposeCapsuleView"].switchOn = cfg.switchOn
    --     activityCfg["CompositeView"].switchOn = cfg.switchOn
    --     activityCfg["CompositeGiftView"].switchOn = cfg.switchOn
    -- end

    -- 不知道为啥，DailyDealsView,这个没放在activity活动配置里面,直冲礼包的,其他渠道屏蔽
    if
        key == "DailyDealsView" and
            (CC.Platform.isIOS or CC.ChannelMgr.CheckOppoChannel() or CC.ChannelMgr.CheckVivoChannel() or
                CC.ChannelMgr.CheckOfficialWebChannel())
     then
        activityCfg["DailyDealsView"].switchOn = false
    end

    if key == "MarsTaskView" then
        activityCfg["MarsTaskEntryView"].switchOn = cfg.switchOn
    end
    if key == "MonopolyView" then
        activityCfg["MonopolyRankView"].switchOn = cfg.switchOn
    end
end

--检查客户端的开关设置
function Mgr.CheckClientSwitch(nkey, key, v)
    local switchOn = v
    if nkey ~= "switchOn" then
        return switchOn
    end
    if CC.ChannelMgr.CheckOppoChannel() or CC.ChannelMgr.CheckVivoChannel() or CC.ChannelMgr.CheckOfficialWebChannel() then
        if Mgr.CheckIsShield(key) then
            switchOn = false
        end
    end
    if key == "VipThreeCardView" and CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= 3 then
        --vip3直升卡
        switchOn = false
    end
    if key == "NoviceGiftView" and not CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
        --新手礼包
        switchOn = false
    end
    if key == "NewPayGiftView" and not CC.ChannelMgr.CheckOppoChannel() then
        switchOn =
            switchOn and CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("ChargeRewardLock")
        if CC.ChannelMgr.CheckVivoChannel() then
            switchOn = false
        end
    end
    return switchOn
end

--只使用switch配置的开关
function Mgr.CheckSwitchData()
    local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("MonthCard")
    activityCfg["MonthCardView"].switchOn = switchOn
end

--活动开关
function Mgr.GetActivityInfoByKey(key)
    if CC.ChannelMgr.GetTrailStatus() then
        if Mgr.GetTrailInfoByKey(key) then
            return Mgr.GetTrailInfoByKey(key)
        end
    end
    if key == "CommonHolidayGiftView" then
        local status = Mgr.GetGiftStatus("30335") or true
        activityCfg[key].switchOn = activityCfg[key].switchOn and status
    end
    return activityCfg[key]
end

function Mgr.GetActivityInfo()
    return activityCfg
end

--月末活动
local activeEntryList = {
    "HolidayDiscountsView",
    "NewPayGiftView",
    "HalloweenLoginGiftView",
    "DailyLotteryView",
    "CapsuleView"
}
-- local activeEntryList = {}
local activeEntryIsShow = false
function Mgr.CheckActiveEntryStatus()
    if #activeEntryList <= 0 then
        return
    end

    local isShow = false
    for _, key in ipairs(activeEntryList) do
        local list = activityCfg[key]
        if list then
            local switchOn = list.switchOn
            if key == "HalloweenLoginGiftView" then
                switchOn = switchOn and CC.HallUtil.ShowHalloweenLoginGift()
            end
            isShow = isShow or switchOn
        end
    end
    activeEntryIsShow = isShow

    CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshActiveEntryBtn, isShow)
end

function Mgr.GetActiveEntryStatus()
    return activeEntryIsShow
end

--月中活动
local midActiveList = {"SuperDailyGiftView", "MonthRankView", "MonopolyView"}
local midActiveShow = false
function Mgr.SetMidActivetyStatus()
    if #midActiveList <= 0 then
        return
    end

    local isShow = false
    for _, key in ipairs(midActiveList) do
        local list = activityCfg[key]
        if list then
            isShow = isShow or list.switchOn
        end
    end
    midActiveShow = isShow
    CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshMidActiveBtn, isShow)
end

function Mgr.GetMidActivetyStatus()
    return midActiveShow
end

function Mgr.GetFreeChipsInfo()
    local freeChipsCfg = {}
    for _, v in pairs(activityCfg) do
        if v.CollectionView == "FreeChips" then
            table.insert(freeChipsCfg, v)
        end
    end
    return freeChipsCfg
end

function Mgr.GetSelectGiftInfo()
    local SelectGiftCfg = {}
    for _, v in pairs(activityCfg) do
        if v.CollectionView == "SelectGift" then
            table.insert(SelectGiftCfg, v)
        end
    end
    return SelectGiftCfg
end

function Mgr.GetTrailInfoByKey(key)
    if key == "Act_EveryGift" then
        local cfg = activityCfg[key]
        cfg.switchOn = false
        cfg.redDot = false
        return cfg
    elseif key == "MonthRankView" then
        local cfg = activityCfg[key]
        cfg.switchOn = false
        return cfg
    end
    return false
end

--  设置一级锁需要屏蔽的界面
function Mgr.SetShowLockView(key)
    if
        not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel") and
            needLockView[key]
     then
        --一级锁没开并在需要屏蔽的活动中
        local cfg = activityCfg[key]
        if cfg then
            return true
        end
    end
    return false
end

local ChannelShieldView = {
    -- OPPO
    ["20002"] = {"NoviceGiftView", "Act_EveryGift", "ElephantPiggy"},
    -- VIVO
    ["20003"] = {
        "NoviceGiftView",
        "FundView",
        "AchievementGiftMainView",
        "Act_EveryGift",
        "ElephantPiggy"
    },
    -- 官网包
    ["20010"] = {
        "NoviceGiftView",
        "FundView",
        "AchievementGiftMainView",
        "Act_EveryGift",
        "ElephantPiggy"
    }
}
--  检查oppo、vivo获取其他渠道需要屏蔽的界面
function Mgr.CheckIsShield(Key)
    local shieldView = ChannelShieldView[AppInfo.ChannelID]

    if shieldView then
        for i, v in ipairs(shieldView) do
            if v == Key then
                log("CheckIsShield Key = " .. Key)
                return true
            end
        end
    end

    return false
end

local LuckyData = {}
--设置幸运礼包滚动信息数据
function Mgr.SetLuckyRollData(data)
    LuckyData = data
end

function Mgr.GetLuckyRollData()
    local tab = {}
    local i = 0
    if not LuckyData.Records then
        return tab
    end
    for k, v in ipairs(LuckyData.Records) do
        i = i + 1
        tab[i] = v
    end
    return tab
end

--礼包拉去状态
local ReqGiftState = false

function Mgr.SetReqGiftState(state)
    ReqGiftState = state
end

function Mgr.GetReqGiftState()
    return ReqGiftState
end

--礼包购买状态
local GiftStatus = {}
function Mgr.SetGiftStatus(wareId, status)
    GiftStatus[wareId] = status
end
function Mgr.GetGiftStatus(wareId)
    return GiftStatus[wareId]
end

local BrokeGiftData = {}
function Mgr.SetBrokeGiftData(param)
    BrokeGiftData = param
end
function Mgr.GetBrokeGiftData()
    return BrokeGiftData
end
function Mgr.SetBrokeGiftGrade(wareId)
    if BrokeGiftData.arrBrokenGift then
        for _, v in ipairs(BrokeGiftData.arrBrokenGift) do
            if v.nGiftID == wareId then
                v.bStatus = false
            end
        end
    end
end

local BrokeBigGiftData = {}
function Mgr.SetBrokeBigGiftData(param)
    BrokeBigGiftData = param
end
function Mgr.GetBrokeBigGiftData()
    return BrokeBigGiftData
end
function Mgr.SetBrokeBigGiftGrade(wareId)
    if BrokeBigGiftData.arrBrokenGift then
        for _, v in ipairs(BrokeBigGiftData.arrBrokenGift) do
            if v.nGiftID == wareId then
                v.bStatus = false
            end
        end
    end
end

Mgr.Register()

return Mgr
