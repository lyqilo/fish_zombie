-- ************************************************************
-- @File: SubGameInterface.lua
-- @Summary1: 对接子游戏的接口文件,所有子游戏对大厅的接口均可以从这边获取,如果有需要增加新的接口，可以联系大厅客户端；
-- @Summary2: 此接口文档,尽可能不实现业务逻辑,只做接口定义,保持文档清晰易读,做好分类，同类就都放在一起
-- @Summary3: 将逻辑处理放到SubGame/Interface文件夹里，能统一的就统一
-- @Summary4: SubGame/Interface 下目前
--            PlayerInfoInterface(用户数据道具操作相关)
--            ActivityInterface(活动相关,创建活动icon,打开活动界面等)
--            UIInterface(操作界面相关)
--            PayInterface(支付相关)
--            EventInterface(记录统计事件相关)
--            ShareInterface(分享相关)
--            SoundInterface(声音操作相关)
--            RequestInterface(Http 请求相关)
-- @Summary5: 有些不确定的,和弃用的API都放在文件末尾了
-- @Version: 1.0
-- @Date: 2023-03-28 10:04:32
-- ***********************************************************
local CC = require("CC")
local UIInterface = require("SubGame/Interface/UIInterface")
local PayInterface = require("SubGame/Interface/PayInterface")
local EventInterface = require("SubGame/Interface/EventInterface")
local ShareInterface = require("SubGame/Interface/ShareInterface")
local SoundInterface = require("SubGame/Interface/SoundInterface")
local RequestInterface = require("SubGame/Interface/RequestInterface")
local ActivityInterface = require("SubGame/Interface/ActivityInterface")
local PlayerInfoInterface = require("SubGame/Interface/PlayerInfoInterface")

local Interface = {}
local M = {}
M.__index = function(_, key)
    if M[key] then
        return M[key]
    else
        return function()
            logError("无法访问 CC.SubGameInterface." .. key .. "(), 请确认接口名字")
        end
    end
end
setmetatable(Interface, M)

-- 函数注释例子
--************************************************************
-- @FuncName Func(函数名称) (作用)
-- @Param1 param1
-- @Param1 param2
-- @Param1 param3
---************************************************************
function M.Func(param1, param2, param3)
    return false
end

----------------------------------------------------------------玩家信息相关----------------------------------------------------------------

-- .;%%%%%%%|;`        |#@:
-- `$###########@;     |#@:
-- `$#@:      '&##|    |#@:
-- `$#@:       '&#&:   |#@:
-- `$#@:       '&#@:   |#@:     |#########%.  .%##!        :@#%.    |########$`     |#@;;####!
-- `$#@:      .|##|.   |#@:    .!;      ;##$`  `$#@:      `$#$`   ;##&'    `$##;    |###&:
-- `$##|''':|@###!     |#@:              |##;   :&#$`     |#@:   ;##|       `$#$'   |##%.
-- `$#########$'       |#@:       :|&######@:    ;##|    !##;   .%##@&&&&&&&&##@:   |##;
-- `$#@:               |#@:    !###&!:.  |#@:     |#@;  :&#|    `$##$||||||||||!`   |#@:
-- `$#@:               |#@:   ;##|      .%#@:     .%#$``$#%.     |##!               |#@:
-- `$#@:               |#@:   !##|      !##@;      '&#%%#&'      '&##;              |#@:
-- `$#@:               |#@:   .%###&|%@#$$#@;       :@##@:        .%###@%||$##&'    |##;
--  :!;.               '!;.     .;$@@%:  '!;`        |##!            `!$@@&%;.      '!;`
--                                                  ;##|    `
--                                                 :@#%.    `
--                                             |#####!      `
--                                             '||;.

-- ************************************************************
-- @FuncName: GetVipLevel 获取玩家VIP等级
-- ************************************************************
function M.GetVipLevel()
    return PlayerInfoInterface.GetVipLevel()
end

-- ************************************************************
-- @FuncName: GetNickName 获取玩家昵称
-- ************************************************************
function M.GetNickName()
    return PlayerInfoInterface.GetNickName()
end

-- ************************************************************
-- @FuncName: GetPlayerId 获取玩家ID
-- ************************************************************
function M.GetPlayerId()
    return PlayerInfoInterface.GetPlayerId()
end

-- ************************************************************
-- @FuncName: GetHallMoney 获取玩家金币
-- ************************************************************
function M.GetHallMoney()
    return PlayerInfoInterface.GetHallMoney()
end

-- ************************************************************
-- @FuncName: GetHallDiamond 获取玩家钻石
-- ************************************************************
function M.GetHallDiamond()
    return PlayerInfoInterface.GetHallDiamond()
end

-- ************************************************************
-- @FuncName: GetHallIntegral 获取玩家礼券
-- ************************************************************
function M.GetHallIntegral()
    return PlayerInfoInterface.GetHallIntegral()
end

-- ************************************************************
-- @FuncName: GetHallRoomCard 获取玩家房卡
-- ************************************************************
function M.GetHallRoomCard()
    return PlayerInfoInterface.GetHallRoomCard()
end

-- ************************************************************
-- @FuncName: GetPortrait 获取玩家头像
-- ************************************************************
function M.GetPortrait()
    return PlayerInfoInterface.GetPortrait()
end

-- ************************************************************
-- @FuncName: GetHeadFrame 获取玩家头像框
-- ************************************************************
function M.GetHeadFrame()
    return PlayerInfoInterface.GetHeadFrame()
end

-- ************************************************************
-- @FuncName: GetEntryEffect 获取玩家入场特效
-- ************************************************************
function M.GetEntryEffect()
    return PlayerInfoInterface.GetEntryEffect()
end

-- ************************************************************
-- @FuncName: GetTelephone 获取玩家手机号码
-- ************************************************************
function M.GetTelephone()
    return PlayerInfoInterface.GetTelephone()
end

-- ************************************************************
-- @FuncName: GetPropNumByPropId    通过道具id获取道具数量
-- @Param1: PropId                  道具ID
-- ************************************************************
function M.GetPropNumByPropId(PropId)
    return PlayerInfoInterface.GetPropNumByPropId(PropId)
end

-- ************************************************************
-- @FuncName: GetThreshold 获取玩家救济金触发阈值
-- ************************************************************
function M.GetThreshold()
    return PlayerInfoInterface.GetThreshold()
end

-- ************************************************************
-- @FuncName: GetReliefLeftTimes 获取玩家救济金剩余次数
-- ************************************************************
function M.GetReliefLeftTimes()
    return PlayerInfoInterface.GetReliefLeftTimes()
end

-- ************************************************************
-- @FuncName: GetPlayerLoginData 获取玩家登录信息
-- ************************************************************
function M.GetPlayerLoginData()
    return PlayerInfoInterface.GetPlayerLoginData()
end

-- ************************************************************
-- @FuncName: GetJackpotsByID 根据GameId获取Jackpot
-- @Param1: GameId
-- ************************************************************
function M.GetJackpotsByID(GameId)
    return PlayerInfoInterface.GetJackpotsByID(GameId)
end

-- ************************************************************
-- @FuncName: GetAgentLevel 获取玩家高V等级
-- ************************************************************
function M.GetAgentLevel()
    return PlayerInfoInterface.GetAgentLevel()
end

-- ************************************************************
-- @FuncName: IsShowRoomCard 是否展示房卡
-- ************************************************************
function M.IsShowRoomCard()
    return PlayerInfoInterface.IsShowRoomCard()
end

-- ************************************************************
-- @FuncName: GetDailyGiftState 获取每日礼包购买状态, false 为已购买
-- ************************************************************
function M.GetDailyGiftState()
    return PlayerInfoInterface.GetDailyGiftState()
end

-- ************************************************************
-- @FuncName: ChangeHallUserProp    修改玩家道具
-- @Param1: PropId                  道具ID
-- @Param2: Count                   修改后总数量
-- @Param3: Delta                   变化值
-- ************************************************************

function M.ChangeHallUserProp(PropId, Count, Delta)
    return PlayerInfoInterface.ChangeHallUserProp(PropId, Count, Delta)
end

-- ************************************************************
-- @FuncName: ChangeHallUserChouMa 修改用户金币(当在子游戏时,如果调用大厅界面并且会显示金币时,可调用此接口,大厅会同步子游戏的金币数值)
-- @Param1: count
-- ************************************************************
function M.ChangeHallUserChouMa(count)
    PlayerInfoInterface.ChangeHallUserProp(CC.shared_enums_pb.EPC_ChouMa, count, 0)
end

-- ************************************************************
-- @FuncName: ChangeHallUserIntegral    覆盖大厅的礼券
-- @Param1: count                       数量
-- ************************************************************
function M.ChangeHallUserIntegral(count)
    PlayerInfoInterface.ChangeHallUserProp(CC.shared_enums_pb.EPC_New_GiftVoucher, count, 0)
end

-- ************************************************************
-- @FuncName: CheckUnlockPropState  传游戏ID检查解锁道具状态. true：购买过当前游戏解锁礼包; false：没购买或当前游戏无解锁礼包
-- @Param1: gameId?                 游戏ID(不传默认去当前游戏ID)
-- ************************************************************
function M.CheckUnlockPropState(gameId)
    return PlayerInfoInterface.CheckUnlockPropState(gameId)
end

-- ************************************************************
-- @FuncName: IsFriendByID  判断id玩家是否是当前玩家好友
-- @Param1: id              玩家ID
-- ************************************************************
function M.IsFriendByID(id)
    return PlayerInfoInterface.IsFriendByID(id)
end

-- ************************************************************
-- @FuncName: IsHasGuide    是否有新手引导
-- ************************************************************
function M.IsHasGuide()
    return PlayerInfoInterface.IsHasGuide()
end

----------------------------------------------------------------活动相关----------------------------------------------------------------

--                                                      '%|.                     .!%:
--         .%###;                                      '&##|                     !##@:
--         |####&'                          .%#@:                                         .%#@:
--        ;##!:@#$`                         .%#@:                                         .%#@:
--       '&#%. !##|            .!&####@|. !&&###@&&&:   !&$'  ;&&!         ;&&:  '%&!   !&&###@&&&:'%&%'        .|&%`
--      `$#&'  .%##;         !###@|::!$&' !&&###@&&&:   |#@:  `$#@;       ;##%.  :@#%.  !&&###@&&&: ;##$`       |##;
--      |##;    '&#&'      .%##!            .%#@:       |#@:   '&#$`     '&#$`   :@#%.    .%#@:      |##!      ;##!
--     ;##|.     :@#$`     |##!             .%#@:       |#@:    ;##|    .%#&'    :@#%.    .%#@:      .%#@:    '&#%.
--    :&###@@@@@@####|    `$#@:             .%#@:       |#@:     |##;   !##;     :@#%.    .%#@:       `$#$`  .%#$'
--   `$###@@@@@@@@####!   .%#@:             .%#@:       |#@:     `$#&' :@#!      :@#%.    .%#@:        :@#|  !#@:
--   |##!          '&#@:   ;##$`            .%#@:       |#@:      '&#%'$#%.      :@#%.    .%#@:         ;#@;:@#!
--  !##%.           ;##$`   ;###%.    .;'    !##|.      |#@:       ;#@@#$`       :@#%.     !##%.         |####|
-- :@#&'             |##%.    ;@#######&'     |#####!   |#@:        |##@:        :@#%.      |#####!      `$##%.
--                                                                                                       `$#&'
--                                                                                                      .%#@:
--                                                                                                     :&#@:
--                                                                                                  |####!

-- ************************************************************
-- @FuncName: CheckRelief   救济金相关,检测当前传入的筹码数是否可以领取救济,func会在领取失败的时候触发
-- @Param1: curMoney        当前筹码数
-- @Param2: errCb           失败回调, 拉取救济金失败，或者领取不成功会回调,如果不传，会默认打开商城
-- @Param3: succCb          完成回调，打开礼包界面，或者商城界面，或者成功领取救济金会调用此回调
-- ************************************************************
function M.CheckRelief(curMoney, errCb, succCb)
    return ActivityInterface.CheckRelief(curMoney, errCb, succCb)
end

-- ************************************************************
-- @FuncName: OpenVipBestGiftView 打开v2,v3最优惠礼包
-- @Param1: param
--          param.needLevel 需要达到的vip等级，只能2和3
-- ************************************************************
function M.OpenVipBestGiftView(param)
    return ActivityInterface.OpenVipBestGiftView(param)
end

-- ************************************************************
-- @FuncName: CheckBrokeOrRelief    检查破检查破产和救济金产和救济金
-- @Param1: param
--          param.curMoney          当前筹码(int类型)
--          param.brokeMoney        破产条件筹码(int类型)
--          param.againBroke        是否可以多次触发（在破产触发过再次触发，bool值，可以不传，true：只要有档位没购买就会一直打开礼包)
--          param.entryLimit        入场金币限制
--          param.closeFunc         破产关闭回调
--          param.errCb             救济金回调
--          param.succCb            救济金回调
-- ************************************************************
function M.CheckBrokeOrRelief(param)
    return ActivityInterface.CheckBrokeOrRelief(param)
end

-- ************************************************************
-- @FuncName: BrokeGiftTrigger  破产礼包触发
-- @Param1: param
-- ************************************************************
function M.BrokeGiftTrigger(param)
    return ActivityInterface.BrokeGiftTrigger(param)
end

--[[
iconName:创建按钮的类型，现有 {GC.ViewDefine.WaterIcon(泼水节水滴活动icon)}
@param
parent:父节点
openFunc: icon点击打开界面回调(可缺省)
closeFunc: 界面关闭回调(可缺省)
]]
function M.CreateIcon(iconName, param)
    return CC.IconManager.CreateIcon(iconName, param)
end

--删除对应Icon
function M.DestroyIcon(icon)
    if icon then
        CC.IconManager.DestroyIcon(icon)
    end
end

-- ************************************************************
-- @FuncName: ByWareIdGetState  查询礼包是否购买
-- @Param1: wareId              礼包的wareId;
--                              礼包id有“22011”:dummy礼包,"22012"：pokdeng礼包,"22013":二人捕鱼
--                              "22014":四人捕鱼,"22015":飞机礼包,"22016":地鼠礼包,"30015":僵尸礼包
-- ************************************************************
function M.ByWareIdGetState(wareId)
    return ActivityInterface.ByWareIdGetState(wareId)
end

-- ************************************************************
-- @FuncName: GetDailySwitch    新手礼包是否打开
-- ************************************************************
function M.GetDailySwitch()
    return ActivityInterface.GetDailySwitch()
end

-- ************************************************************
-- @FuncName: Novice_Bool   是否满足打开新手礼包条件
-- ************************************************************
function M.Novice_Bool()
    return ActivityInterface.Novice_Bool()
end

-- ************************************************************
-- @FuncName: OpenNovice    创建新手礼包Icon,已废弃?
-- @Param1: parent          挂在的父节点
-- @Param2: layer           层级
-- ************************************************************
function M.OpenNovice(parent, layer)
    return ActivityInterface.OpenNovice(parent, layer)
end

-- ************************************************************
-- @FuncName: DestryNovice  销毁新手礼包Icon
-- @Param1: icon            对象
-- ************************************************************
function M.DestryNovice(icon)
    ActivityInterface.DestroyNovice(icon)
end

-- ************************************************************
-- @FuncName: CreateFreeChipsCollectionIcon     创建免费金币合集Icon
-- @Param1: param
--          param.parent                        挂载的父节点(创建后layer和父节点一致)
--          param.sprite                        入口按钮sprite(可缺省)
--          param.width                         sprite width(可缺省)
--          param.height                        sprite height(可缺省)
--          param.openFunc                      界面打开回调(可缺省)
--          param.closeFunc                     界面关闭回调(可缺省)
--          param.SelectTab                     填写你要显示的礼包
--                                              目前活动有(DailyTurntableView(每日转盘); OnlineAward(在线宝箱); LimmitAwardView(登陆奖励))
--                                              可根据各位心情随意选择想要的礼包。如下方例子1所示
--                                              例子1：SelectTab = {GC.ViewDefine.DailyTurntableView,GC.ViewDefine.LimmitAwardView}
-- ************************************************************
function M.CreateFreeChipsCollectionIcon(param)
    return ActivityInterface.CreateFreeChipsCollectionIcon(param)
end

function M.CreateSlotFreeChipsCollectionIcon(param)
    return ActivityInterface.CreateSlotFreeChipsCollectionIcon(param)
end

function M.DestroyFreeChipsCollectionIcon(icon)
    return ActivityInterface.DestroyFreeChipsCollectionIcon(icon)
end

-- ************************************************************
-- @FuncName: CreateSelectGiftCollectionIcon    创建礼包合集Icon
-- @Param1: param
--          param.parent                        挂载的父节点(创建后layer和父节点一致)
--          param.openFunc                      界面打开回调(可缺省)
--          param.closeFunc                     界面关闭回调(可缺省)
--          param.shakeIfRedDot                 是否红点显示的时候同时有抖动效果(默认不抖动)
--          param.SelectGiftTab                 填写你要显示的礼包
--                                              目前活动有(NoviceGiftView(新手礼包); FundView(七日基金); Act_EveryGift(捕鱼礼包))
--                                              可根据各位心情随意选择想要的礼包。如下方例子1所示
--                                              例子1：SelectGiftTab = {GC.ViewDefine.NoviceGiftView,GC.ViewDefine.FundView}
-- ************************************************************
function M.CreateSelectGiftCollectionIcon(param)
    return ActivityInterface.CreateSelectGiftCollectionIcon(param)
end

-- ************************************************************
-- @FuncName: CreateSlotSelectGiftCollectionIcon    创建礼包合集Icon(为了slot单独的接口?)
-- @Param1: param                                   参数如  CreateSelectGiftCollectionIcon
-- ************************************************************
function M.CreateSlotSelectGiftCollectionIcon(param)
    return ActivityInterface.CreateSlotSelectGiftCollectionIcon(param)
end

-- ************************************************************
-- @FuncName: CreateSelectGiftCollectionIconWithoutDailyGift    创建礼包合集icon,排除每日礼包
-- @Param1: param                                               参数如  CreateSelectGiftCollectionIcon
-- ************************************************************
function M.CreateSelectGiftCollectionIconWithoutDailyGift(param)
    return ActivityInterface.CreateSelectGiftCollectionIconWithoutDailyGift(param)
end

function M.CreateSlotBrokeGiftIcon(param)
    return ActivityInterface.CreateSlotBrokeGiftIcon(param)
end

function M.DestroySelectGiftCollectionIcon(icon)
    return ActivityInterface.DestroySelectGiftCollectionIcon(icon)
end

-- ************************************************************
-- @FuncName: CreateDailyGiftCollectionIcon     创建每日礼包合集Icon
-- @Param1: param
-- ************************************************************
function M.CreateDailyGiftCollectionIcon(param)
    return ActivityInterface.CreateDailyGiftCollectionIcon(param)
end

-- ************************************************************
-- @FuncName: DestroyDailyGiftCollectionIcon    销毁每日合集礼包Icon
-- @Param1: icon
-- ************************************************************
function M.DestroyDailyGiftCollectionIcon(icon)
    return ActivityInterface.DestroyDailyGiftCollectionIcon(icon)
end

-- ************************************************************
-- @FuncName: CreateSlotCommonNoticeIcon
-- @Param1: param
--          param.parent    挂载的父节点
-- ************************************************************
function M.CreateSlotCommonNoticeIcon(param)
    return ActivityInterface.CreateSlotCommonNoticeIcon(param)
end

function M.DestroySlotCommonNoticeIcon(icon)
    return ActivityInterface.DestroySlotCommonNoticeIcon(icon)
end

-- ************************************************************
-- @FuncName: CreateOnlineIcon  创建在线奖励单独按钮（带倒计时）
-- @Param1: param
--          param.parent    挂载的父节点
-- ************************************************************
function M.CreateOnlineIcon(param)
    return ActivityInterface.CreateOnlineIcon(param)
end

function M.CreateSlotsOnlineIcon(param)
    return ActivityInterface.CreateSlotsOnlineIcon(param)
end

function M.DestroyOnlineIcon(icon)
    return ActivityInterface.DestroyOnlineIcon(icon)
end

-- ************************************************************
-- @FuncName: CreateElephantIcon    大象礼包icon
-- @Param1: param
--          param.parent    挂载的父节点
-- ************************************************************
function M.CreateElephantIcon(param)
    return ActivityInterface.CreateElephantIcon(param)
end

function M.DestroyElephantIcon(icon)
    return ActivityInterface.DestroyElephantIcon(icon)
end

function M.OpenGoldElephantView()
    return ActivityInterface.OpenGoldElephantView()
end

-- ************************************************************
-- @FuncName: OpenGiftSelectionView     打开礼包合集
-- @Param1: param
--          param.SelectGiftTab         填写你要显示的礼包
--                                      目前活动有(NoviceGiftView(新手礼包);FundView(七日基金);Act_EveryGift(捕鱼礼包))
--                                      可根据各位心情随意选择想要的礼包。如下方例子1所示
--                                      例子1：SelectGiftTab = {GC.ViewDefine.NoviceGiftView,GC.ViewDefine.FundView}
-- ************************************************************
function M.OpenGiftSelectionView(param)
    return ActivityInterface.OpenGiftSelectionView(param)
end

-- ************************************************************
-- @FuncName: OpenDailyGiftView     打开每日礼包合集
-- @Param1: param
--          param.currentView       打开合集后第一个显示的界面
--                                  目前每日礼包有(DailyGiftBuyu(捕鱼);DailyGiftDummy(Dummy);DailyGiftPokdeng(Pokdeng);DailyDealsView(飞机))
--                                  例子1：currentView = {GC.ViewDefine.DailyGiftBuyu}
-- ************************************************************
function M.OpenDailyGiftView(param)
    return ActivityInterface.OpenDailyGiftView(param)
end

-- ************************************************************
-- @FuncName: OpenFreeChipsCollectionView   打开免费金币合集界面
-- @Param1: param
--          param.currentView               打开合集后第一个显示的界面
-- ************************************************************
function M.OpenFreeChipsCollectionView(param)
    return ActivityInterface.OpenFreeChipsCollectionView(param)
end

-- ************************************************************
-- @FuncName: CreateMonthRankIcon
-- @Param1: param
--          param.parent    挂载的父节点
-- ************************************************************
function M.CreateMonthRankIcon(param)
    return ActivityInterface.CreateMonthRankIcon(param)
end

function M.DestroyMonthRankIcon(icon)
    return ActivityInterface.DestroyMonthRankIcon(icon)
end

-- ************************************************************
-- @FuncName: CreateCashCowIcon
-- @Param1: param
--          param.parent    挂载的父节点
-- ************************************************************
function M.CreateCashCowIcon(param)
    return ActivityInterface.CreateCashCowIcon(param)
end
function M.DestroyCashCowIcon(icon)
    return ActivityInterface.DestroyCashCowIcon(icon)
end

function M.OpenCashCowView()
    return ActivityInterface.OpenCashCowView()
end

function M.GetAllDailyGiftStatus()
    return ActivityInterface.GetAllDailyGiftStatus()
end

-- ************************************************************
-- @FuncName: GetFortuneCatGiftState    幸运猫? 活动; 返回 true 活动开始， 返回 false 则活动未开始
-- ************************************************************
function M.GetFortuneCatGiftState()
    return ActivityInterface.GetFortuneCatGiftState()
end

function M.GetSelectGiftSwitch(Key)
    return ActivityInterface.GetSelectGiftSwitch(Key)
end

local giftCfg = {
    PiggyGift = "23005",
    BY_FishMatchGiftTree = "30001",
    BY_FishMatchGiftNor = "30002",
    BY_FishMatchGiftVIP_1 = "30003",
    BY_FishMatchGiftVIP_2 = "30004",
    BY_FishMatchGiftVIP_3 = "30005",
    PD_MatchGift = "30007",
    PD_MatchGiftVIP = "30008",
    PW_MatchGift_1 = "30009",
    PW_MatchGift_2 = "30010",
    PW_MatchGift_3 = "30011"
}
-- ************************************************************
-- @FuncName: GetGiftWareId 根据名称获取礼包ID
-- @Param1: giftName        飞机金猪礼包(eg. PiggyGift)
-- ************************************************************
function M.GetGiftWareId(giftName)
    if giftCfg[giftName] then
        return giftCfg[giftName]
    end
end

----------------------------------------------------------------UI操作相关----------------------------------------------------------------

--    '&#$`          '&#&'    `$#@:
--    '&#$`          '&#&'    `$#@:
--    '&#$`          '&#&'    `$#@:
--    '&#$`          '&#&'    `$#@:
--    '&#$`          '&#&'    `$#@:
--    '&#$`          '&#&'    `$#@:
--    '&#$`          '&#&'    `$#@:
--    '&#$`          '&#$'    `$#@:
--    '$#@:          :@#%`    `$#@:
--     !##$`        `$#@;     `$#@:
--      |###$'    '$###;      `$#@:
--       .|#########@:        `$#@:
--

-- ************************************************************
-- @FuncName: GameToGame                    子游戏中，切换到别的子游戏
-- @Param1: gameId                          游戏id
-- @Param2: callback(enterFunc,gameData)    无需下载回调,callback(enterFunc,gameData) 回调需要接收两个参数
--                                          enterFunc 确认进入方法，子游戏手动调用。 enterFunc(enterData) 方法需要回传 enterData，即callback传过去的gameData
--                                          gameData 回传给enterFunc的参数
--
-- 下载进度可监听
-- GC.Notifications.DownloadGame ，下载Process，function ({gameID,process}) end ，可能同时下载多个，最好做gameID校验
-- GC.Notifications.DownloadFail ，下载失败（失败会弹出重新下载框，如果取消下载会收到此消息），function (gameID) end
-- PS:由于下载完不走callback回调，后续只能在Process==1后，合适的时候再次调用此接口
-- -- ************************************************************
function M.GameToGame(gameId, callback)
    return UIInterface.GameToGame(gameId, callback)
end

-- ************************************************************
-- @FuncName: BackToHall    返回大厅
-- @Param1: callback        返回大厅完成回调
-- ************************************************************
function M.BackToHall(callback)
    return UIInterface.BackToHall(callback)
end

-- ************************************************************
-- @FuncName: BackToLogin       返回到登录界面
-- ************************************************************
function M.BackToLogin()
    return UIInterface.BackToLogin()
end

-- ************************************************************
-- @FuncName: BackToHallByReconnect     棋牌游戏主动踢回大厅重连
-- ************************************************************
function M.BackToHallByReconnect()
    return UIInterface.BackToHallByReconnect()
end

-- ************************************************************
-- @FuncName: KickedOutTip      踢回到登录界面
-- ************************************************************
function M.KickedOutTip()
    return UIInterface.KickedOutTip()
end

-- ************************************************************
-- @FuncName: CreateHeadIcon    创建头像Icon
-- @Param1: data 元表,具体参数如下
--          data.parent             挂载的父节点
--          data.playerId           玩家id
--          data.portrait           头像图片索引路径
--          data.showChat           显示聊天按钮
--          data.chatCallback       点击聊天按钮回调
--          data.clickFunc          头像点击方法
--          data.vipLevel           vip等级
--          data.nick               昵称
--          data.unShowVip          不显示vip等级
--          data.headFrame          头像框id
--          data.showFrameEffect    展示头像框特效
--          data.isShowDefault      是否只显示默认白底
--          data.unChangeHeadFrame  是否监听头像框变化
-- ************************************************************
function M.CreateHeadIcon(data)
    return UIInterface.CreateHeadIcon(data)
end

-- ************************************************************
-- @FuncName: DestroyHeadIcon   销毁头像Icon
-- @Param1: icon                创建时返回的icon
-- @Param2: isDestroyObj        是否销毁gameObject
-- ************************************************************
function M.DestroyHeadIcon(icon, isDestroyObj)
    UIInterface.DestroyHeadIcon(icon, isDestroyObj)
end

-- ************************************************************
-- @FuncName: SetHeadIcon   设置玩家头像
-- @Param1: portrait        头像id
-- @Param2: headIcon        头像节点
-- @Param3: playerId        玩家id
-- ************************************************************
function M.SetHeadIcon(portrait, headIcon, playerId)
    UIInterface.SetHeadIcon(portrait, headIcon, playerId)
end

-- ************************************************************
-- @FuncName: SetHeadVipLevel   设置头像vip等级
-- @Param1: vipLevel            vip等级
-- @Param2: vipNode             vip节点
-- ************************************************************
function M.SetHeadVipLevel(vipLevel, vipNode)
    UIInterface.SetHeadVipLevel(vipLevel, vipNode)
end

-- ************************************************************
-- @FuncName: CreateHeadFrame   加载动态头像框
-- @Param1: id                  头像框ID
-- @Param2: parent              父节点
-- ************************************************************
function M.CreateHeadFrame(id, parent)
    return UIInterface.CreateHeadFrame(id, parent)
end

-- ************************************************************
-- @FuncName: GetHeadIconPathById   获取头像路径
-- @Param1: id                      头像ID
-- ************************************************************
function M.GetHeadIconPathById(id)
    return UIInterface.GetHeadIconPathById(id)
end

-- ************************************************************
-- @FuncName: CreateVIPCounter      创建vip进度条,退出游戏请销毁
-- ************************************************************
function M.CreateVIPCounter()
    return UIInterface.CreateVIPCounter()
end

-- ************************************************************
-- @FuncName: DestroyVIPCounter     销毁vip进度条
-- @Param1: counter                 vip进度条对象
-- ************************************************************
function M.DestroyVIPCounter(counter)
    UIInterface.DestroyVIPCounter(counter)
end

function M.CreatePersonlInfoView(param)
    CC.uu.Log("该API已弃用,请调用SubGameInterface.OpenPersonalInfoView")
    return M.OpenPersonalInfoView(param)
end

-- ************************************************************
-- @FuncName: OpenPersonalInfoView  打开个人信息界面,默认打开自己的个人信息界面
-- @Param1: param
--          param.curChips          当前筹码,打开界面时用作展示
--          param.playerId          玩家ID
--          param.Upgrade           控制个人信息页签,显示默认为个人信息,1 代表vip权益页签,2代表vip礼包页签 (打开自己信息界面时可用)
--          param.maxWin            最大赢取(打开别人信息界面时可用)
--          param.totalWin          总赢取(打开别人信息界面时可用)
-- ************************************************************
function M.OpenPersonalInfoView(param)
    return UIInterface.OpenPersonalInfoView(param)
end

-- ************************************************************
-- @FuncName: CreateEntryEffect     创建玩家入场特效
-- @Param1: effectId                特效ID, 一般为游戏ID
-- @Param2: parent                  挂载节点
-- @Param3: content                 展示的说明内容
-- ************************************************************
function M.CreateEntryEffect(effectId, parent, content)
    return UIInterface.CreateEntryEffect(effectId, parent, content)
end

-- ************************************************************
-- @FuncName: OpenMenu              打开菜单栏
-- @Param1: param
--          param.showPersonalInfo  是否展示个人信息按钮
--          param.OnBackToHall      点击返回大厅回调; 如果传入,将会覆盖菜单的返回大厅函数
-- ************************************************************
function M.OpenMenu(param)
    return UIInterface.OpenMenu(param)
end

-- ************************************************************
-- @FuncName: OpenChat  打开聊天界面
-- @Param1: Chips       需要带筹码过来用作刷新
-- ************************************************************
function M.OpenChat(Chips)
    return UIInterface.OpenChat(Chips)
end

-- ************************************************************
-- @FuncName: ExOpenChat    打开聊天界面
-- @Param1: param
--          param.ChouMa    金币
--          param.Integral  礼券
-- ************************************************************
function M.ExOpenChat(param)
    return UIInterface.ExOpenChat(param)
end

-- ************************************************************
-- @FuncName: OpenShop          打开商城界面
-- @Param1: ChouMa              金币
-- @Param2: func(buyInStore)    关闭商店回调, buyInStore 是否充值标记
-- ************************************************************
function M.OpenShop(ChouMa, func)
    logError("方法已经弃用，请启用新接口---> SubGameInterface.ExOpenShop")
    return UIInterface.OpenShop(ChouMa, func)
end

-- ************************************************************
-- @FuncName: ExOpenShop
-- @Param1: param
--          param.ChouMa                同步游戏内筹码数量
--          param.Integral              同步游戏内礼券数量
--          param.channelTab            打开商店相关页签，不传默认打开钻石购买(用M.GetStoreTab()方法获取,就在下面)
--          param.hideAutoExchange      隐藏自动兑换筹码按钮并强制购买为得到砖石
-- @Param2: func(buyInStore)            关闭商店回调, buyInStore 是否充值标记
-- ************************************************************
function M.ExOpenShop(param, func)
    return UIInterface.ExOpenShop(param, func)
end

--[[
    StoreDefine.CommodityType = {
        Horn = 12, --喇叭
        Chip = 13, --筹码
        RoomCard = 14 --房卡
    }
]]
-- ************************************************************
-- @FuncName: GetStoreTab 返回大厅商店页签枚举,具体可以去StoreDefine里查看 例子如上
-- ************************************************************
function M.GetStoreTab()
    return CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine").CommodityType
end

-- ************************************************************
-- @FuncName: OpenRealStore 打开实物商城
-- @Param1: param
--          param.ChouMa    同步游戏内筹码数量
--          param.Integral  同步游戏内礼券数量
-- @Param2: func            关闭界面回调
-- ************************************************************
function M.OpenRealStore(param, func)
    return UIInterface.OpenRealStore(param, func)
end

-- ************************************************************
-- @FuncName: OpenService   打开客服界面
-- ************************************************************
function M.OpenService()
    return UIInterface.OpenServiceView()
end

-- ************************************************************
-- @FuncName: ShowTip   游戏上方往下的弹框提示
-- @Param1: str         展示内容
-- @Param2: second      持续时间
-- @Param3: finishCall  如果显示按钮, 则点击按钮后回调
-- ************************************************************
function M.ShowTip(str, second, finishCall)
    return UIInterface.ShowTip(str, second, finishCall)
end

-- ************************************************************
-- @FuncName: CloseTip  主动关闭提示
-- ************************************************************
function M.CloseTip()
    return UIInterface.CloseTip()
end

-- ************************************************************
-- @FuncName: CreateMessageBox  显示消息框
-- @Param1: str                 显示信息
-- @Param2: okFunc              确认按钮回调
-- @Param3: noFunc              取消按钮回调
-- ************************************************************
function M.CreateMessageBox(str, okFunc, noFunc)
    return UIInterface.CreateMessageBox(str, okFunc, noFunc)
end

-- ************************************************************
-- @FuncName: GotoShopTip   展示提示后,跳转商城
-- @Param1: ChouMa          同步游戏内筹码数量
-- ************************************************************
function M.GotoShopTip(ChouMa)
    return UIInterface.GotoShopTip(ChouMa)
end

-- ************************************************************
-- @FuncName: CreateGameEffectView 创建老虎机通用特效
-- ************************************************************
function M.CreateGameEffectView()
    UIInterface.CreateGameEffectView()
end

-- ************************************************************
-- @FuncName: ReleaseGameEffectView 销毁老虎机通用特效
-- @Param1: destroyOnLoad
-- ************************************************************
function M.ReleaseGameEffectView(destroyOnLoad)
    UIInterface.ReleaseGameEffectView(destroyOnLoad)
end

-- ************************************************************
-- @FuncName: GetWinEffectCfg 获取老虎机通用特效配置
-- @Param1: winMul
-- ************************************************************
function M.GetWinEffectCfg(winMul)
    return UIInterface.GetWinEffectCfg(winMul)
end

-- ************************************************************
-- @FuncName: PlayWinEffect             播放赢取特效
-- @Param1: baseMoney                   起始金币
-- @Param2: deltaMoney                  变化金币
-- @Param3: callback                    回调
-- @Param4: shareParam                  分享参数
--          shareParam.extraData        额外的数据
--          shareParam.content          内容
-- ************************************************************
function M.PlayWinEffect(baseMoney, deltaMoney, callback, shareParam)
    return UIInterface.PlayWinEffect(baseMoney, deltaMoney, callback, shareParam)
end

-- ************************************************************
-- @FuncName: PlayFreeWinEffect 播放免费赢取特效
-- @Param1: freeTime            免费次数
-- @Param2: callback            特效显示时长
-- @Param3: duration            特效结束回调
-- ************************************************************
function M.PlayFreeWinEffect(freeTime, callback, duration)
    return UIInterface.PlayFreeWinEffect(freeTime, callback, duration)
end

-- ************************************************************
-- @FuncName: PlayMajorWinEffect    播放Major赢取特效
-- @Param1: deltaMoney              获奖数额
-- @Param2: callback                特效结束回调
-- @Param3: duration                特效显示时长
-- ************************************************************
function M.PlayMajorWinEffect(deltaMoney, callback, duration)
    return UIInterface.PlayMajorWinEffect(deltaMoney, callback, duration)
end

-- ************************************************************
-- @FuncName: SetNoticeBordPos 设置跑马灯位置
-- @Param1: vec3
-- ************************************************************
function M.SetNoticeBordPos(vec3)
    UIInterface.SetNoticeBordPos(vec3)
end

-- ************************************************************
-- @FuncName: SetNoticeBordPosEx    设置跑马灯位置, 会根据设计高度，重新设置y值
-- @Param1: vec3                    vector3
-- ************************************************************
function M.SetNoticeBordPosEx(vec3)
    UIInterface.SetNoticeBordPosEx(vec3)
end

-- ************************************************************
-- @FuncName: SetNoticeBordWidth    设置跑马灯宽度,传小于15数字，宽度都会变为负数，会打人的!!!!!
-- @Param1: width                   宽度
-- ************************************************************
function M.SetNoticeBordWidth(width)
    UIInterface.SetNoticeBordWidth(width)
end

-- ************************************************************
-- @FuncName: SetNoticeBordEffectState  设置跑马灯特效状态
-- @Param1: active                      显示与否
-- ************************************************************
function M.SetNoticeBordEffectState(active)
    UIInterface.SetNoticeBordEffectState(active)
end

-- ************************************************************
-- @FuncName: SetSpeakBoardPos  设置喇叭位置（位于跑马灯下方）
-- @Param1: vec3                vector3
-- ************************************************************
function M.SetSpeakBoardPos(vec3)
    UIInterface.SetSpeakBoardPos(vec3)
end

-- ************************************************************
-- @FuncName: SetSpeakBoardPosEx    设置喇叭位置, 会根据设计高度，重新设置y值
-- @Param1: vec3                    vector3
-- ************************************************************
function M.SetSpeakBoardPosEx(vec3)
    UIInterface.SetSpeakBoardPosEx(vec3)
end

-- ************************************************************
-- @FuncName: SetSpeakBoardWidth    设置喇叭宽度,传小于15数字，宽度都会变为负数，会打人的!!!!!
-- @Param1: width                   宽度
-- ************************************************************
function M.SetSpeakBoardWidth(width)
    UIInterface.SetSpeakBoardWidth(width)
end

-- ************************************************************
-- @FuncName: SetSpeakBordState     设置喇叭开启状态
-- @Param1: bState                  是否启用
-- ************************************************************
function M.SetSpeakBordState(bState)
    UIInterface.SetSpeakBordState(bState)
end

-- ************************************************************
-- @FuncName: SetNoticeBordState    设置跑马灯开启状态
-- @Param1: bState                  是否启用
-- ************************************************************
function M.SetNoticeBordState(bState)
    UIInterface.SetNoticeBordState(bState)
end

-- ************************************************************
-- @FuncName: CloseAllHallView 销毁大厅所有界面,一般场景切换到游戏需要调用该方法
-- ************************************************************
function M.CloseAllHallView()
    UIInterface.CloseAllHallView()
end

-- ************************************************************
-- @FuncName: SetFloatBtnGroupState 控制浮动按钮组显示哪些按钮
-- @Param1: state                   字符串数组，1代表返回按钮 2代表商店按钮, eg. state = {"1"} --仅显示返回按钮,state = {"1","2"},返回和商店都显示
-- ************************************************************
function M.SetFloatBtnGroupState(state)
    UIInterface.SetFloatBtnGroupState(state)
end

-- ************************************************************
-- @FuncName: CreateFloatBtnGroup   创建/销毁浮动按钮组,创建前先调用 SubGameInterface.SetFloatBtnGroupState(state),否则默认两个按钮都显示
-- @Param1: state                   控制按钮 0销毁，1创建
-- ************************************************************
function M.CreateFloatBtnGroup(state)
    UIInterface.CreateFloatBtnGroup(state)
end

-- ************************************************************
-- @FuncName: CreateStarRateView    打开五星好评界面
-- @Param1: param
--          param.reward            奖励（数值），不传则默认显示大厅写死的数值
--          param.succCb            成功回调
--          param.errCb             失败回调
-- ************************************************************
function M.CreateStarRateView(param)
    return UIInterface.CreateStarRateView(param)
end

-- ************************************************************
-- @FuncName: SetOnlineWelfare      在线福利活动，弹窗提示开关
-- @Param1: isOpen                  是否开启，默认true （可缺省）
-- @Param2: isLeft                  是否在左边，默认false（可缺省）
-- @Param3: offset                  上下偏移值，窗口往下是正，默认0（可缺省）
-- ************************************************************
function M.SetOnlineWelfare(isOpen, isLeft, offset)
    UIInterface.SetOnlineWelfare(isOpen, isLeft, offset)
end

-- ************************************************************
-- @FuncName: SetArenaNoticeView    竞技场推送提示开关，强制弹窗3s后消失。如需要弹窗，必须监听玩家请求跳转事件。
--                                  退出游戏的时候设置回缺省值，除非能保证跳转过去的子游戏设置这个接口。
-- @Param1: isOpen                  是否开启，默认false（可缺省）
-- @Param2: isLeft                  是否在左边，默认false（可缺省）
-- @Param3: offset                  上下偏移值，窗口往下是正，默认0（可缺省）
-- @Param4: whiteList               允许显示的gameid白名单，如{3001,3004}, 默认所有都显示
-- ************************************************************
function M.SetArenaNoticeView(isOpen, isLeft, offset, whiteList)
    UIInterface.SetArenaNoticeView(isOpen, isLeft, offset, whiteList)
end

-- ************************************************************
-- @FuncName: BackToLoginByDisconnect   给独立选场提供断线踢回登录界面
-- ************************************************************
function M.BackToLoginByDisconnect()
    UIInterface.BackToLoginByDisconnect()
end

-- ************************************************************
-- @FuncName: IsLiuHaiScreen    判断是不是刘海屏
-- ************************************************************
function M.IsLiuHaiScreen()
    return UIInterface.IsLiuHaiScreen()
end

-- ************************************************************
-- @FuncName: OpenCommonRewardsView     显示公共奖励界面
-- @Param1: data
--          data.ConfigId               道具id
--          data.Count                  总数
--          data.Delta                  差值
-- ************************************************************
function M.OpenCommonRewardsView(data)
    return UIInterface.OpenCommonRewardsView(data)
end

-- ************************************************************
-- @FuncName: OpenCommonRewardsViewEx   显示公共奖励界面
-- @Param1: param
--          param.items                 奖励数组(奖励数组，参考上面方法(OpenCommonRewardsView))
--          param.title                 通用奖励弹窗标题
--          param.callback              回调
--          param.tips                  通用奖励弹窗Tips，用于提示玩家，例:提示玩家点卡需要去邮箱领取
--          param.gameTips              游戏内传出Tips,用于游戏显示通用奖励弹窗Tips
--          param.btnText               确定按钮改文字
--          param.splitState            是否拆分，True的话，不会合并同一个数组里相同ID的奖励
--          param.needShare             是否显示分享按钮
--          param.source                奖励源
-- ************************************************************
function M.OpenCommonRewardsViewEx(param)
    return UIInterface.OpenCommonRewardsViewEx(param)
end

-- ************************************************************
-- @FuncName: CaptureScreenShare    截屏分享
-- @Param1: param
--          param.extraData         必传,gameId:游戏id(必传);其他扩展参数(通过连接回传游戏)
--                extraData.gameId  必传,gameId:游戏id(必传)
--          param.btnPerfab         子游戏自定义按钮(没有则使用默认按钮)(必须包含 BtnFaceBook,BtnLine,btnSave,BtnClose 且按钮名称与之对应)
--          param.isShowPlayerInfo  是否显示玩家信息(bool类型)默认不显示
--          param.callback          界面关闭回调
--          param.beforeCB          截屏之前回调
--          param.afterCB           截屏之后回调
--          param.content           分享的文本内容
--          param.errCb             分享错误回调
-- ************************************************************
function M.CaptureScreenShare(param)
    return UIInterface.CaptureScreenShare(param)
end

-- ************************************************************
-- @FuncName: OpenUnlockGift    子游戏打开解锁礼包(大厅不做入场判断),返回false,说明玩家购买了解锁礼包或当前游戏没有解锁礼包
-- @Param1: param
--          param.vipLimit      大厅不限制入场后，获取不到入场VIP等级，需要子游戏传
-- ************************************************************
function M.OpenUnlockGift(param)
    return UIInterface.OpenUnlockGift(param)
end

-- ************************************************************
-- @FuncName: CreateRechargeMessageBox  老虎机付费引导弹窗1
-- @Param1: okFunc                      确认回调
-- ************************************************************
function M.CreateRechargeMessageBox(okFunc)
    return UIInterface.CreateRechargeMessageBox(okFunc)
end

-- ************************************************************
-- @FuncName: CreateRechargeOrSmallerMessageBox     老虎机付费引导弹窗2
-- @Param1: okFunc                                  确认回调
-- @Param2: noFunc                                  取消回调
-- ************************************************************
function M.CreateRechargeOrSmallerMessageBox(okFunc, noFunc)
    return UIInterface.CreateRechargeOrSmallerMessageBox(okFunc, noFunc)
end

-- ************************************************************
-- @FuncName: CreateRechargeOrAdjustMessageBox      老虎机付费引导弹窗3
-- @Param1: okFunc                                  确认回调
-- ************************************************************
function M.CreateRechargeOrAdjustMessageBox(okFunc)
    return UIInterface.CreateRechargeOrAdjustMessageBox(okFunc)
end

-- ************************************************************
-- @FuncName: OpenInformationView   打开填写资料面板
-- @Param1: data
--          data.PropId             奖励道具ID
--          data.ActiveName         活动名称
--          data.Callback           提交回调
--          data.Canclose           能否主动关闭(true or false)
-- ************************************************************
function M.OpenInformationView(data)
    UIInterface.OpenInformationView(data)
end

-- ************************************************************
-- @FuncName: CreateExitGameTipView                 创建退出游戏时的提示View
-- @Param1: param
--          param.gameList                          要展示的游戏ID列表
--          param.exitFunc                          退出回调
--          param.cancelFunc                        取消回调
--          param.gameFunc(gameId,defaultFunc)      选中游戏回调
--                                                  gameId      玩家选择游戏的id
--                                                  defaultFunc 如果是大厅通用选场界面，会跳转到相应gameId的选场界面；如果是子游戏自己有选场界面，则跳到子游戏
-- ************************************************************
function M.CreateExitGameTipView(param)
    return UIInterface.CreateExitGameTipView(param)
end

-- ************************************************************
-- @FuncName: OpenVipView   打开vip界面
-- ************************************************************
function M.OpenVipView()
    UIInterface.OpenVipView()
end

-- ************************************************************
-- @FuncName: ShowLimitTimeGiftView     显示成就奖励动画界面
-- @Param1: parent                      父节点Transform，动画非常大请放在屏幕中间
-- @Param2: targetScreenPoint           飞向的屏幕坐标;可通过UnityEngine.RectTransformUtility.WorldToScreenPoint(Camera,targetPos)计算
-- @Rerurn  view                        动画view对象
-- ************************************************************
function M.ShowLimitTimeGiftView(parent, targetScreenPoint)
    return UIInterface.ShowLimitTimeGiftView(parent, targetScreenPoint)
end

-- ************************************************************
-- @FuncName: DestroyLimitTimeGiftView  游戏退出前或view父节点销毁前调用，确保礼包view已被销毁。
-- @Param1: giftView                    成就奖励动画界面对象
-- ************************************************************
function M.DestroyLimitTimeGiftView(giftView)
    UIInterface.DestroyLimitTimeGiftView(giftView)
end

-- ************************************************************
-- @FuncName: CreateWalletView  生成礼包购买View,礼包界面，礼包父节点销毁时需要调用DestroyWalletView(view)
-- @Param1: param
--          param.wareId        礼包WareId
--          param.parent        父节点
--          param.width         游戏的CavasScaler X
--          param.height        游戏的CavasScaler Y
--          param.succCb        成功回调
-- ************************************************************
function M.CreateWalletView(param)
    return UIInterface.CreateWalletView(param)
end

-- ************************************************************
-- @FuncName: DestroyWalletView     销毁礼包购买View
-- @Param1: walletView              view对象
-- ************************************************************
function M.DestroyWalletView(walletView)
    UIInterface.DestroyWalletView(walletView)
end

-- ************************************************************
-- @FuncName: ExitToGuide   退出游戏走引导
-- @Param1: param
--          param.id        保留游戏ID，引导结束后拉回游戏选场
--          param.cb        退出游戏func
-- ************************************************************
function M.ExitToGuide(param)
    return UIInterface.ExitToGuide(param)
end

-- ************************************************************
-- @FuncName: CreateRealStoreIcon   生成实物商城Icon
-- @Param1: param
--          param.parent            挂载的父节点(创建后layer和父节点一致)
--          param.OpenViewId        打开标签页(1,2,3),左侧1、2、3页（可缺省）
--          param.closeFunc         界面关闭回调(可缺省)
-- ************************************************************
function M.CreateRealStoreIcon(param)
    return UIInterface.CreateRealStoreIcon(param)
end

-- ************************************************************
-- @FuncName: DestroyRealStoreIcon  销毁实物商城Icon
-- @Param1: icon                    icon对象
-- ************************************************************
function M.DestroyRealStoreIcon(icon)
    return UIInterface.DestroyRealStoreIcon(icon)
end

-- ************************************************************
-- @FuncName: IsHallViewOpened    是否有已打开大厅界面
-- ************************************************************
function M.IsHallViewOpened()
    return UIInterface.IsHallViewOpened()
end

----------------------------------------------------------------声音声效相关----------------------------------------------------------------

--                                                                                               :|!`
--       `%########@:                                                                           .%#@:
--     ;###&!`..`;$@:                                                                           .%#@:
--    :@#$`                                                                                     .%#@:
--    ;##%.                   '!|%|;`         `'`        .''.     ''`   :|%|:            '!%|!` .%#@:
--    `$##@;               |#####@####@;     '&#$`       !##!    :@#$|@##@####&'      :@####@###&&#@:
--      :@####%`         :@#@:      .%##%.   '&#$`       !##!    :@##$`     !##$`   .%##%.     `$##@:
--         :&####@:     `$#&'         |##;   '&#$`       !##!    :@#$`      .%#@:   !##|        `$#@:
--             ;@##@;   ;@#%.         ;##%.  '&#$`       !##!    :@#%.       |#@:  .%#@:        .%#@:
--               :@#@:  ;##%.         ;##|   '&#$`       !##!    :@#%.       |#@:  `$#@:        .%#@:
--               `$#@:  `$#@:        .%#@;   `$#&'      .%##!    :@#%.       |#@:   !##|        :&#@:
--    !$'       .%##%.   :&##!      `$##;     |##$`    `%###!    :@#%.       |#@:   `$##%.     !###@:
--    !###########@:       !##########%.       !########!|##!    :@#%.       |#@;     !########&;%#@:
--        .'::'.               `::'               `::`                                   .::'

-- ************************************************************
-- @FuncName: SetMusicVolumeTransition 设置背景音变化
-- @Param1: data
--          data.from 起始值(0-1)
--          data.to 结束值(0-1)
--          data.duration 变化时间,默认为0
-- ************************************************************
function M.SetMusicVolumeTransition(data)
    SoundInterface.SetMusicVolumeTransition(data)
end

-- ************************************************************
-- @FuncName: GetMusicVolume 获取音乐音量百分比(0~1)
-- ************************************************************
function M.GetMusicVolume()
    return SoundInterface.GetMusicVolume()
end

-- ************************************************************
-- @FuncName: GetSoundVolume  获取音效音量百分比(0~1)
-- ************************************************************
function M.GetSoundVolume()
    return SoundInterface.GetSoundVolume()
end

-- ************************************************************
-- @FuncName: SetMusicVolume    设置音乐音量
-- @Param1: value               值范围{0-1}
-- ************************************************************
function M.SetMusicVolume(value)
    SoundInterface.SetMusicVolume(value)
end

-- ************************************************************
-- @FuncName: SetEffectVolume   设置音效音量
-- @Param1: value               值范围{0-1}
-- ************************************************************
function M.SetEffectVolume(value)
    SoundInterface.SetEffectVolume(value)
end

-- ************************************************************
-- @FuncName: PlayBackMusic  播放背景音乐
-- @Param1: name            音乐名称
-- @Param2: abName          ab名称,默认为sound
-- ************************************************************
function M.PlayBackMusic(name, abName)
    SoundInterface.PlayBackgroundMusic(name, abName)
end

-- ************************************************************
-- @FuncName: StopBackMusic 停止播放背景音乐
-- ************************************************************
function M.StopBackMusic()
    SoundInterface.StopBackgroundMusic()
end

-- ************************************************************
-- @FuncName: PlayEffect    播放音效
-- @Param1: name            音效名称
-- @Param2: abName          ab名称,默认为sound
-- ************************************************************
function M.PlayEffect(name, abName)
    SoundInterface.PlayEffect(name, abName)
end

-- ************************************************************
-- @FuncName: PlayLoopEffect    循环播放音效
-- @Param1: audioName           音效名称
-- @Param2: abName              ab名称,默认为sound
-- ************************************************************
function M.PlayLoopEffect(audioName, abName)
    SoundInterface.PlayLoopEffect(audioName, abName)
end

-- ************************************************************
-- @FuncName: StopExtendEffect      删除扩展的音效组件
-- @Param1: audioName               音效名称
-- ************************************************************
function M.StopExtendEffect(audioName)
    SoundInterface.StopExtendEffect(audioName)
end

-- ************************************************************
-- @FuncName: Save 保存音量设置,调用此方法后,才会保存起来.否则任何设置都是一次性的,重新打开app会被重置
-- ************************************************************
function M.Save()
    SoundInterface.Save()
end

----------------------------------------------------------------网络类----------------------------------------------------------------

--
-- .;%%%%%%%|!'
-- `$############!                                                                                                   `!;
-- `$#@:      '&##|                                                                                                 :@#%.
-- `$#@:       :@#$`           .                 .                                       .                .         :@#%.
-- `$#@:       ;##%.      '&########;       ;@#######%|@#|.   '&#$`       !##!      '&#######@;      !########!  :@########$`
-- `$#@:     .%##$`     `$##!     ;##%.   `$##|.    `$###%.   '&#$`       !##!    `$##!     ;##%.  `$#@:            :@#%.
-- `$#########@|.      `$#&'       ;##!  `$#@;        !##%.   '&#$`       !##!   `$#&'       ;##!  '&#&'            :@#%.
-- `$#@|'';$##@:       :@##&&&&&&&&@##%. :@#%.        :@#%.   '&#$`       !##!   :@##&&&&&&&&@##%.  ;####$'         :@#%.
-- `$#@:    .|##%.     ;##&|||||||||||:  ;##|         :@#%.   '&#$`       !##!   ;##&|||||||||||:     .!@####$`     :@#%.
-- `$#@:      !##&'    '&#$`             :&#$`        !##%.   '&#$`       |##!   '&#$`                     ;@#@:    :@#%.
-- `$#@:       :@#@:    !##%.             |##%.      !###%.   .%##|      !###!    !##%`                     |##;    :@#$`
-- `$#@:        '&##!    :@###&||%@##!     !####$|$@#$%@#%.    `$###@%%@#$$##!     ;@###&||%@##!   :@#@%||$###!     .%###$%|`
--  :!;.         .:!!'      :%&@@$|'         `!&@@$:  :@#%.      .;$@@$:  '!!`        :%&@@&|'      `!$@@@$;.         `|&@$;.
--                                                    :@#%.
--                                                    :@#%.
--                                                    :@#%.

-- ************************************************************
-- @FuncName: ReqAllocServer 请求分配游戏服ip
-- @Param1: param
--          param.gameId    游戏id
--          param.groupId   游戏场id
--          param.allocSuccCb   获取游戏ip成功回调
--          param.allocErrCb    失败回调
-- ************************************************************
function M.ReqAllocServer(param)
    RequestInterface.ReqAllocServer(param)
end

-- ************************************************************
-- @FuncName: ReqOnlineFriends 获取在线好友列表
-- @Param1: cursor 拉取列表的游标，如果为nil，则默认为0。注：服务器的下标从0开始的
-- @Param2: count  拉取好友个数，如果为nil，则默认为30。
-- @Param3: succCb(code,data) 成功回调, data的结构看 client_client.proto -> LoadFriendsForTeamResp
-- @Param4: errCb 失败回调
-- ************************************************************
function M.ReqOnlineFriends(cursor, count, succCb, errCb)
    RequestInterface.ReqOnlineFriends(cursor, count, succCb, errCb)
end

-- ************************************************************
-- @FuncName: ReqInviteFriend   邀请好友组队
-- @Param1: playerId            想要邀请的玩家id
-- @Param2: succCb              成功回调, 邀请成功后，对方会收到 OnPushTeamNotify 事件
-- @Param3: errCb               失败回调
-- ************************************************************
function M.ReqInviteFriend(playerId, succCb, errCb)
    RequestInterface.ReqInviteFriend(playerId, succCb, errCb)
end

-- ************************************************************
-- @FuncName: ReqInviteAnswer   同意或者拒绝邀请
-- @Param1: teamId              队伍id
-- @Param2: bIsAgree            false表示拒绝邀请，true表示同意邀请
-- @Param3: succCb(code,data)   成功回调, data的结构看 client_client.proto -> InviteAnswerResp
-- @Param4: errCb               失败回调
-- ************************************************************
function M.ReqInviteAnswer(teamId, bIsAgree, succCb, errCb)
    RequestInterface.ReqInviteAnswer(teamId, bIsAgree, succCb, errCb)
end

-- ************************************************************
-- @FuncName: ReqDisbandTeam    解散队伍
-- @Param1: teamId              队伍id
-- @Param2: succCb(code)        解散成功后，对方会收到 OnPushTeamNotify 事件
-- @Param3: errCb               失败回调
-- ************************************************************
function M.ReqDisbandTeam(teamId, succCb, errCb)
    RequestInterface.ReqDisbandTeam(teamId, succCb, errCb)
end

-- ************************************************************
-- @FuncName: ReqLoadPlayerTeam     获取队伍信息
-- @Param1: succCb(code,data)       成功回调,data的结构看 client_client.proto LoadPlayerTeamResp
-- @Param2: errCb                   失败回调
-- ************************************************************
function M.ReqLoadPlayerTeam(succCb, errCb)
    RequestInterface.ReqLoadPlayerTeam(succCb, errCb)
end

-- ************************************************************
-- @FuncName: ReqLoadPlayerWithPropType     拉取玩家道具
-- @Param1: param
--          param.propTypes                 需要查询的道具id列表
--          param.succCb                    成功回调
--          param.errCb                     失败回调
-- ************************************************************
function M.ReqLoadPlayerWithPropType(param)
    RequestInterface.ReqLoadPlayerWithPropType(param)
end

-- ************************************************************
-- @FuncName: ReqPrivateGameRecord  请求游戏记录?
-- @Param1: param
--          param.gameId            游戏id
--          param.isCreator         是否房主
--          param.succCb            成功回调
--          param.errCb             失败回调
-- ************************************************************
function M.ReqPrivateGameRecord(param)
    RequestInterface.ReqPrivateGameRecord(param)
end

-- ************************************************************
-- @FuncName: ReqPrivateTotalProp   拉取在游戏内的道具?
-- @Param1: param
--          param.gameId            游戏id
--          param.propId            道具id (eg. GC.shared_enums_pb.EPC_ChouMa)
--          param.succCb            成功回调
--          param.errCb             失败回调
-- ************************************************************
function M.ReqPrivateTotalProp(param)
    RequestInterface.ReqPrivateTotalProp(param)
end

-- ************************************************************
-- @FuncName: ReqPrivateTodayProp   拉取在游戏内的道具?今天的?不太清楚
-- @Param1: param
--          param.gameId            游戏id
--          param.propId            道具id (eg. GC.shared_enums_pb.EPC_ChouMa)
--          param.succCb            成功回调
--          param.errCb             失败回调
-- ************************************************************
function M.ReqPrivateTodayProp(param)
    RequestInterface.ReqPrivateTodayProp(param)
end

-- ************************************************************
-- @FuncName: ReqPrivateRoomList    拉取游戏玩家列表?
-- @Param1: param
--          param.playerId          玩家id
--          param.gameId            游戏id
--          param.succCb            成功回调
--          param.errCb             失败回调
-- ************************************************************
function M.ReqPrivateRoomList(param)
    RequestInterface.ReqPrivateRoomList(param)
end

-- ************************************************************
-- @FuncName: ReqFriendList     拉取玩家好友列表
-- @Param1: param
--          param.index         页数编号(目前一页50条数据)
--          param.succCb        成功回调
--          param.errCb         失败回调
-- ************************************************************
function M.ReqFriendList(param)
    RequestInterface.ReqFriendList(param)
end

-- ************************************************************
-- @FuncName: ReqAddFriend  请求添加好友
-- @Param1: param
--          param.playerId  玩家id
--          param.succCb    成功回调
--          param.errCb     失败回调
-- ************************************************************
function M.ReqAddFriend(param)
    RequestInterface.ReqAddFriend(param)
end

-- ************************************************************
-- @FuncName: ReqLoadPlayerGameInfo     拉取玩家所在游戏信息
-- @Param1: param
--          param.playerId              玩家id
--          param.succCb                成功回调
--          param.errCb                 失败回调
-- ************************************************************
function M.ReqLoadPlayerGameInfo(param)
    RequestInterface.ReqLoadPlayerGameInfo(param)
end

-- ************************************************************
-- @FuncName: ReqGameTableList      拉取玩家桌子数据
-- @Param1: param
--          param.gameId            游戏id
--          param.groupId           场id
--          param.succCb            成功回调
--          param.errCb             失败回调
-- ************************************************************
function M.ReqGameTableList(param)
    RequestInterface.ReqGameTableList(param)
end

-- ************************************************************
-- @FuncName: H5ExchangeChip        H5游戏钻石兑换筹码
-- @Param1: param
--          param.Amount            数量
--          param.GameId?           游戏ID
--          param.GroupId?          场ID
--          param.errCallback?      错误回调
-- ************************************************************
function M.H5ExchangeChip(param)
    RequestInterface.H5ExchangeChip(param)
end

-- ************************************************************
-- @FuncName: ReqLimitTimeGift      请求成就礼包?
-- @Param1: param
--          param.dwPlayerId        玩家ID，可缺省
--          param.nVipLevel         玩家vip 等级，可缺省
--          param.lPlayerMoney      玩家身上剩余金币数量
--          param.lDelta            玩家输赢情况
--
-- @PS
-- CC.Notifications.OnLimitTimeGiftShow -- 监听礼包掉落通知，调用ShowLimitTimeGiftView(parent,target)
-- CC.Notifications.OnLimitTimeGiftTimeOut -- 监听礼包购买时间到，暂无发现有什么用，子游戏自己视情况决定是否监听
-- ************************************************************
function M.ReqLimitTimeGift(param)
    RequestInterface.ReqLimitTimeGift(param)
end

-- ************************************************************
-- @FuncName: PropUse       请求使用背包道具,成功或失败会发通知 CC.Notifications.OnPropUse
-- @Param1: param
--          param.ConfigId  道具ID
--          param.Count     道具数量
-- ************************************************************
function M.PropUse(param)
    RequestInterface.PropUse(param)
end

-- ************************************************************
-- @FuncName: ByWareIdOrderState    请求获取订单状态
-- @Param1: param
--          param.wareId            商品ID
--          param.succCb            成功回调
--          param.errCb             失败回调
-- ************************************************************
function M.ByWareIdOrderState(param)
    RequestInterface.ByWareIdOrderState(param)
end

-- ************************************************************
-- @FuncName: ReqPlayerPropByIds    根据道具id请求玩家道具信息
-- @Param1: param
--          param.playerId          玩家id（不传默认是自己）
--          param.propIds           道具id列表（不传默认请求筹码数据）
--          param.succCb            成功回调
--          param.errCb             失败回调
-- ************************************************************
function M.ReqPlayerPropByIds(param)
    CC.HallUtil.ReqPlayerPropByIds(param)
end

-- ************************************************************
-- @FuncName: ReqGroupCfgByGameId   请求游戏版本号及场次配置
-- @Param1: param
--          param.gameId            游戏Id
--          param.succCb            成功回调
--          param.errCb             失败回调
-- ************************************************************
function M.ReqGroupCfgByGameId(param)
    CC.HallUtil.ReqGameGroupConfig(param.gameId, param.succCb, param.errCb)
end

----------------------------------------------------------------支付相关----------------------------------------------------------------
-- ;###########@:
-- ;##%.     :&##$`
-- ;##%.      .%##|
-- ;##%.       !##%.   '$#######@:   `$##;        '&#$`
-- ;##%.      `$##;   .%&;.   `$##%.  :&#&'      .%#@:
-- ;##%.    `%###;             .%#@:   ;##%.     !##;
-- ;##########@;          .';|$@##@;    |##;    :@#|
-- ;##%.             :@#$`      |#@;     '&#%..|#&'
-- ;##%.             !##!      :@#@;      :@#!!#@:
-- ;##%.             '&##$' .;&###@:       !####;
-- ;##%.               ;@####&: |##;        |##|
--                                         '&#$`
--                                        '$#$'
--                                    |###|.

-- ************************************************************
-- @FuncName: RequestPay            请求购买支付商品
-- @Param1: param
--          param.wareId            商品id
--          param.subChannel        渠道id
--          param.price             购买金额
--          param.playerId          playerId：玩家id
--          param.ExchangeWareId    商品兑换id
--          param.autoExchange?     字段只控制自动兑换筹码并且不会通知游戏服(游戏内不要使用)
-- ************************************************************
function M.RequestPay(param)
    return PayInterface.RequestPay(param)
end

-- ************************************************************
-- @FuncName: RequestOfficialPay    提供给子游戏调取官方付费,非官方渠道勿用
-- @Param1: wareId                  官方计费点ID
-- ************************************************************
function M.RequestOfficialPay(wareId)
    PayInterface.RequestOfficialPay(wareId)
end

-- ************************************************************
-- @FuncName: H5RequestPay      H5游戏游戏通过WareID付费
-- @Param1: data
--          data.wareId         商品id
-- ************************************************************
function M.H5RequestPay(data)
    PayInterface.H5RequestPay(data)
end

-- ************************************************************
-- @FuncName: RequestPayDailyGift   每日礼包支付请求
-- @Param1: callback                已购买回调
-- ************************************************************
function M.RequestPayDailyGift(callback)
    return PayInterface.RequestPayDailyGift(callback)
end

-- ************************************************************
-- @FuncName: OnNovicePay   购买礼包 （捕鱼vip1礼包)
-- @Param1: callback            失败回调
-- ************************************************************
function M.OnNovicePay(callback)
    return PayInterface.OnNovicePay(callback)
end

-- ************************************************************
-- @FuncName: DiamondBuyGift    钻石购买礼包?
-- @Param1: param
--          param.wareId        礼包WareId
--          param.walletView    钱包界面
-- ************************************************************
function M.DiamondBuyGift(param)
    PayInterface.DiamondBuyGift(param)
end

----------------------------------------------------------------事件数据类----------------------------------------------------------------

--
-- `$###########!
-- `$#@:                                                                    :@#%.
-- `$#@:                                                                    :@#%.
-- `$#@:          `$#@;        :@#%.    `$######@:      |##;.|######|.   :@########$`
-- `$#@:           :@#$`      '&#$`   '&##|.   !##&'    |###@!.  `%##&'   `'|##$:''`
-- `$##########$`   !##|      |#@:   :&#$`      '&#$`   |##%`      !##|     :@#%.
-- `$#@:             |##;    ;##!   .%##|''''''':$#@:   |#@:       :@#%.    :@#%.
-- `$#@:             `$#&'  '&#|    `$##############;  .|#@:       '&#%.    :@#%.
-- `$#@:              :@#%.`$#%`    .%##;               |#@:       '&#%.    :@#%.
-- `$#@:               !##!!#&'      :@#&'              |#@:       '&#%.    :@#%.
-- `$##@&&&&&&&&%'      |###@:        :@##&;.  `!@&'    |#@:       '&#%.    `$##%`.`.
-- `%###########&'      `$##!           `%#######|`     |##;       '&#%.      !####$`

-- ************************************************************
-- @FuncName: SetGameActionCount    游戏行为计数（每天重置）
-- @Param1: param
--          param.gameId            游戏id
--          param.action            行为的key，游戏自行定义
--          param.count             自定义计数基数，不传默认1
-- ************************************************************
function M.SetGameActionCount(param)
    EventInterface.SetGameActionCount(param)
end

-- ************************************************************
-- @FuncName: GetGameActionCount    获取游戏行为计数
-- @Param1: param
--          param.gameId            游戏id
--          param.action            行为的key，游戏自行定义
-- ************************************************************
function M.GetGameActionCount(param)
    return EventInterface.GetGameActionCount(param)
end

-- ************************************************************
-- @FuncName: TrackLogGameEvent     firebase后台数据上报接口
-- @Param1: key                     事件名称(传游戏名)
-- @Param2: data                    上报数据(key,value形式)
-- ************************************************************
function M.TrackLogGameEvent(key, data)
    EventInterface.TrackLogGameEvent(key, data)
end

-- ************************************************************
-- @FuncName: TrackEnterMatchGame   记录进入比赛场的游戏
-- @Param1: gameId                  子游戏ID
-- ************************************************************
function M.TrackEnterMatchGame(gameId)
    EventInterface.TrackEnterMatchGame(gameId)
    CC.FirebasePlugin.TrackEnterMatchGame(gameId)
end

-- ************************************************************
-- @FuncName: SetCurGroupId     设置当前游戏场次;进入到子游戏某个场时,设置场次;退回子游戏自己选场时，设置为0，切记退回选场是就要设置，而不是退回大厅游戏;不传默认设置0
-- @Param1: groupId             场ID
-- ************************************************************
function M.SetCurGroupId(groupId)
    CC.ViewManager.SetCurGroupId(groupId)
end

-- ************************************************************
-- @FuncName: GetGameLocalVersionByGameID   获取游戏版本号
-- @Param1: gameid                          子游戏ID
-- ************************************************************
function M.GetGameLocalVersionByGameID(gameid)
    return CC.LocalGameData.GetGameVersion(gameid)
end

----------------------------------------------------------------URL相关----------------------------------------------------------------

-- |##;           !##!                 |#@:
-- |##;           !##!                 |#@:
-- |##;           !##!                 |#@:
-- |##;           !##!     |#@;`$###!  |#@:
-- |##;           !##!     |##&@$:.'`  |#@:
-- |##;           !##!    .%##&'       |#@:
-- |##;           !##!     |##;        |#@:
-- |##!           !##!     |##;        |#@:
-- ;##%.         .%#@:     |##;        |#@:
-- .%##%.        |##|      |##;        |#@:
--  .%###@%;:;%@###!       |#@;        |#@:
--     :&#######%`         |##;        |#@:

--  获取Dummy比赛场信息
function M.GetDummyMatchInfoUrl()
    return CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetMatchInfoUrl()
end

-- 获取Dummy亲友房信息
function M.GetRoomfeeInfoUrl(GameId)
    return CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetRoomfeeInfoUrl()
end

function M.GetUrlPrefix()
    return CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetNginxPrefix()
end

function M.GetWebConfigUrlPrefix()
    return CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebConfigUrlPrefix()
end

-- 获取商店配置
function M.GetStoreUrl()
    return CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetStoreInfoUrl()
end

-- ************************************************************
-- @FuncName: GetWebCfgUrlByGame    获取子游戏的配置地址
-- @Param1: gameName                游戏模块名
-- @Param2: fileName                配置文件名
-- ************************************************************
function M.GetWebCfgUrlByGame(gameName, fileName)
    return string.format("%sAPI/Game/%s/%s.aspx", M.GetWebConfigUrlPrefix(), gameName, fileName)
end

-- ************************************************************
-- @FuncName: GetCDNUrlPrefix   获取广告图CDN地址，有的话已当前环境拉取到的配置为准，没有则默认返回线上CDN地址
-- ************************************************************
function M.GetCDNUrlPrefix()
    local url = CC.MessageManager.GetCDNUrlPrefix()
    return url or string.format("%s/web/Res/", CC.UrlConfig.CDNUrl.Release)
end

-- ************************************************************
-- @FuncName: GetExtraAddress debug模式下，获取debug界面额外地址
-- ************************************************************
function M.GetExtraAddress()
    return CC.DebugDefine.GetExtraAddress() or false
end

-- ************************************************************
-- @FuncName: GetLocalGameIP    debug模式下，获取debug界面子游戏ip地址
-- ************************************************************
function M.GetLocalGameIP()
    return CC.DebugDefine.GetGameAddress()
end

----------------------------------------------------------------分享相关----------------------------------------------------------------
--                     |##;          `
--    :&#########%.   .%#@:          `
--  :@##%`      ;!.    |##:          `
-- `$##;               |#@:          `
-- .%##!               |##; `%####$'        '|@####@;       !&$' :&##!     '$####&;
--  '&##@!             |#@$@@|::%###$`    .%#@|:':%###!     |##$&#&%&;   |##@|:'!&##%.
--    '&####&:         |##&'      |##|             `$#&:    |###;      `$#@:      :@#%.
--       .|#####;      |##;       :@#%.           `:$#@;    |##!       |##;       .%#@:
--           '&##&'    |#@:       :@#%.    ;@#########@;    |#@:      `$#############@:
--             !##%.   |#@:       :@#%.  '&#@;      |##;    |#@;      .%#@:
--             !##%.   |#@:       :@#%.  !##!      '$#@;    |##;       ;##%.
-- `$@|'     '$##&'    |#@:       :@#%.  :@#@:    !###@:    |#@;        !##@;      ;|'
-- .%##########&'      |##;       :@#%.   '&######%`|#@;    |##;         .|#########|.

-- ************************************************************
-- @FuncName: InviteFriendFromLine  通过生成链接和分享到line,邀请好友
-- @Param1: param
--          param.extraData
--          param.extraData.gameId  游戏id(必传)
--          param.extraData.????    其他扩展参数(通过邀请链接回传游戏)

--          param.title             分享的标题
--          param.content           分享的文本内容
--          param.delayTime         延迟显示菊花的时间(默认1秒)
--          param.timeOut           请求超时时间(默认15秒)
--          param.errCb             失败回调
-- ************************************************************
function M.InviteFriendFromLine(param)
    return ShareInterface.InviteFriendFromLine(param)
end

-- ************************************************************
-- @FuncName: InviteFriendFromFacebook  通过生成链接和分享到facebook,邀请好友
-- @Param1: param
--          param.extraData
--          param.extraData.gameId  游戏id(必传)
--          param.extraData.xxxxx   其他扩展参数(通过邀请链接回传游戏)

--          param.title             分享的标题
--          param.content           分享的文本内容
--          param.delayTime         延迟显示菊花的时间(默认1秒)
--          param.timeOut           请求超时时间(默认15秒)
--          param.errCb             失败回调
-- ************************************************************
function M.InviteFriendFromFacebook(param)
    return ShareInterface.InviteFriendFromFacebook(param)
end

-- ************************************************************
-- @FuncName: ShareTextToLine   分享文本到line
-- @Param1: content             分享的文本内容
-- ************************************************************
function M.ShareTextToLine(content)
    return ShareInterface.ShareTextToLine(content)
end

-- ************************************************************
-- @FuncName: ShareTextToOther  调用NativeShare分享文本内容
-- @Param1: param
--          param.title         分享窗标题
--          param.text          文本(必须带url?)
--          param.callback      分享回调(接收两个参数，分享结果和分享的app，不一定能成功回调)
-- ************************************************************
function M.ShareTextToOther(param)
    return ShareInterface.ShareTextToOther(param)
end

-- ************************************************************
-- @FuncName: GetTextureShareLink  图片分享连接
-- @Param1: param
--          param.extraData
--          param.extraData.gameId  游戏id(必传)
--          param.extraData.xxxxx   其他扩展参数(通过邀请链接回传游戏)

--          param.webTitle          链接标题(可缺省)
--          param.webText           链接描述内容(可缺省)
--          param.file              图片文件 Texture2D(可缺省)
--          param.succCb(url,imgUrl)成功回调 带回分享短连接和上传的图片地址
--          param.errCb             错误回调
-- ************************************************************
function M.GetTextureShareLink(param)
    ShareInterface.GetTextureShareLink(param)
end

-- ************************************************************
-- @FuncName: ShareLinkToFacebook   分享链接到facebook
-- @Param1: param
--          param.contentURL        分享到facebook链接
--          param.callback          分享回调
-- ************************************************************
function M.ShareLinkToFacebook(param)
    return ShareInterface.ShareLinkToFacebook(param)
end

----------------------------------------------------------------暂时不知道放哪----------------------------------------------------------------

--                                         :@#%.
--      `$##########@:                    :@#%
--    ;@##@!.     :&###|       :@#%.      :@#%
--  .%##$'           |##$'     :@#%.      :@#%
--  |##%.             !##%. '%&@###&&&|`  :@#%. ;@###@!.         '$####&;       !&$' :&##!
-- '&#&'              `$#@: '%&@###&&&|`  :@#&&#$;:!&###;      |##@|:'!&##%.    |##$&#&%&;
-- ;##%`              .%##!    :@#%.      :@##|      :&#&'   `$#@:      :@#%.  .|###;
-- ;##%.              .%##!    :@#%.      :@#$`      .|##;   |##;       .%#@:   |##!
-- '&#&'              '$#&'    :@#%.      :@#%.       |#@;  `$#############@;   |##:
--  |##%.             |##|     :@#%.      :@#%.       |#@;  .%#@:               |#@:
--  .%##&'          .%##%.     :@#%.      :@#%.       |#@:   ;##%.              |#@:
--    :@###%`    `|@##@;       '&#@:      :@#%.       |#@;    !##@;      ;%'    |#@:
--      `%##########%.          '&####$`  :@#%.       |##;     .|#########|.    |#@;
--

-- ************************************************************
-- @FuncName: CheckIsChouMa     检查是否是金币
-- @Param1: index               道具ID
-- ************************************************************
function M.CheckIsChouMa(index)
    return CC.shared_enums_pb.EPC_ChouMa == index
end

-- ************************************************************
-- @FuncName: CheckIsDiamond    检查是否是钻石
-- @Param1: index               道具ID
-- ************************************************************
function M.CheckIsDiamond(index)
    return CC.shared_enums_pb.EPC_ZuanShi == index
end

-- ************************************************************
-- @FuncName: GetGameLanguage   获取游戏语言
-- ************************************************************
function M.GetGameLanguage()
    return CC.LanguageManager.GetType()
end

-- ************************************************************
-- @FuncName: GetTrailStatus    获取提审状态
-- ************************************************************
function M.GetTrailStatus()
    return CC.ChannelMgr.GetTrailStatus()
end

-- ************************************************************
-- @FuncName: CheckIOSTrail     是否是IOS提审状态
-- ************************************************************
function M.CheckIOSTrail()
    return CC.ChannelMgr.GetIosTrailStatus()
end

-- ************************************************************
-- @FuncName: CheckIOSPrivate   是否是IOS私包
-- ************************************************************
function M.CheckIOSPrivate()
    return CC.ChannelMgr.GetIOSPrivateStatus()
end

-- ************************************************************
-- @FuncName: GetMolChannelState    是否开启三方渠道
-- ************************************************************
function M.GetMolChannelState()
    if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("ShowMol", false) then
        if not CC.ChannelMgr.GetSwitchByKey("bShowMol") then
            return false
        end
        return true
    else
        return false
    end
end

-- ************************************************************
-- @FuncName: CheckHallDisconnect   检测大厅链接是否断开
-- ************************************************************
function M.CheckHallDisconnect()
    return CC.ViewManager.CheckHallDisconnect()
end

-- ************************************************************
--[[
    泰文比较奇怪
    ผ   ผู   ผู้   这三个字符显示都是一个字符
    但是占的字节不一样，分别是3，6，9
    主体字上面的鞋子，帽子和音调都占3个字节
    limit   就是让传3个字节的个数
    例如：ผผูผู้截取3长度，返回的实际是ผผู，如果帽子和鞋子截取后丢失，会补上
    泰文有问题可以看一下下面这个链接
    http://blog.sina.com.cn/s/blog_5d8cc6410100s2ux.html
]]
-- @FuncName: ThaiStrSplit  泰文字符串截取
-- @Param1: str             传需要截取的字符串
-- @Param2: limit           limit：传截取长度
-- ************************************************************
function M.ThaiStrSplit(str, limit)
    return CC.uu.ThaiStrSplit(str, limit)
end

-- ************************************************************
-- @FuncName: CheckSpecialChannel 判断当前渠道是安卓官方渠道, true:安卓官方渠道,false:非安卓官方渠道(ios|oppo|vivo)
-- ************************************************************
function M.CheckSpecialChannel()
    return (CC.Platform.isIOS or CC.ChannelMgr.CheckOppoChannel() or CC.ChannelMgr.CheckVivoChannel() or
        CC.ChannelMgr.CheckOfficialWebChannel()) and
        false or
        true
end

-- ************************************************************
-- @FuncName: CheckAndroidSpecialChannel 判断当前渠道是否android 三方渠道, true:安卓三方渠道, false:安卓官方渠道
-- ************************************************************
function M.CheckAndroidSpecialChannel()
    return CC.ChannelMgr.CheckOppoChannel() or CC.ChannelMgr.CheckVivoChannel() or
        CC.ChannelMgr.CheckOfficialWebChannel()
end

-- ************************************************************
-- @FuncName: OpenWin32LogOutByPlayerId     pc平台根据玩家id 日志打印开关;
--                                          子游戏根据需要调用 建议在MJGame初始化入口;
--                                          返回一个关闭接口 建议在退出游戏回到大厅时调用 CloseFun()  注意要加个判断是否为nil的处理;
-- ************************************************************
function M.OpenWin32LogOutByPlayerId()
    if CC.Platform.isWin32 and Util.hasLog then
        local pID = M.GetPlayerId()
        local logPath = Util.logPath
        logPath = string.gsub(logPath, "outLog", "outLog_" .. pID)
        local file = io.open(logPath, "a+")

        local fun = function(condition, stackTrace, type)
            file:write(condition .. "\r\n")
        end

        Application.logMessageReceived = Application.logMessageReceived + fun
        local CloseFun = function()
            Application.logMessageReceived = Application.logMessageReceived - fun
        end

        return CloseFun
    end
end

-- ************************************************************
-- @FuncName: GetWareInfoById   通过wareID获取ware信息
-- @Param1: wareIds             wareId列表
-- ************************************************************
function M.GetWareInfoById(wareIds)
    local wareTable = {}
    local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    for _, v in ipairs(wareIds) do
        local wareData = wareCfg[tostring(v)]
        if wareData then
            table.insert(wareTable, wareData)
        end
    end
    return wareTable
end

-- ************************************************************
-- @FuncName: GetPropIconById   获取大厅道具icon图标
-- @Param1: id                  道具ID
-- ************************************************************
function M.GetPropIconById(id)
    local propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    if not propCfg[id] or propCfg[id].Icon == "" then
        CC.uu.Log("prop表没有该道具配置或者该道具没配置Icon路径;id: = " .. id)
        return
    end
    local path = propCfg[id].Icon
    local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[path]
    return CC.uu.LoadImgSprite(path, abName or "image")
end

-- ************************************************************
-- @FuncName: GetPropNameById   获取大厅道具名称, 大厅语言表中有该道具返回名称，无则返回空字符串
-- @Param1: id                  道具ID
-- ************************************************************
function M.GetPropNameById(id)
    local languageCfg = CC.LanguageManager.GetLanguage("L_Prop")
    if languageCfg[id] then
        return languageCfg[id]
    else
        log("L_Prop表中无该道具名称")
        return ""
    end
end

-- ************************************************************
-- @FuncName: IsNeedInformation     判断是否需要打开信息面板
-- @Param1: PropId                  奖励道具ID
-- ************************************************************
function M.IsNeedInformation(PropId)
    local propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    local propData = propCfg[PropId]

    local IdendityInfo = propData.IdendityInfo
    local PersonInfo = propData.PersonInfo
    if IdendityInfo and PersonInfo then
        return true
    end
    return false
end

-- ************************************************************
-- @FuncName: GetPhysicalState  实物风控;true:可以打开,false:屏蔽
-- ************************************************************
function M.GetPhysicalState()
    return CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("GameMatch")
end

-- ************************************************************
-- @FuncName: GetSwitchState    获取功能开关状态
-- @Param1: param
--          param.key           需要获取开关状态的key值
--          param.bState        默认状态，如果没有拉取到数据,bState为nil,默认返回true,反之返回bState
-- ************************************************************
function M.GetSwitchState(param)
    return CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey(param.key, param.bState)
end

----------------------------------------------------------------废弃接口----------------------------------------------------------------

--           ..             |##;                                                                 :@#%.
--         '&###!           |##;                                                                 :@#%.
--        .%#@&#@:          |##;                                                                 :@#%.
--        !##;'&#&'         |##;                                                                 :@#%.
--       :@#|  :@#%.        |#@:.!######@:       '$#######&:      |##;.|######|.       .!######@:;@#%.      `%########!.      :@#%`:&#####&:
--      '&#$`   |##|        |##@#$`   '&##&'    .%&;.   `$##%.    |###@!.  `%##&'     |##@;   .|####%.    '&##&'    !@##|     :@###&'   ;@##|
--     .%#@:    `$##;       |##$`       ;##$`            .%#@:    |##%.      !##|    |##!       .%##%.   :@#&'        !##|    :@##;      '$#@:
--     |##!      '&#&'      |##;        .%#@:        ';|%@##@:    |#@:       :@#%.  '&#$`        :@#%.  .%##;         `$#&'   :@#%.       |#@:
--    ;##############$`     |#@:        .%#@;   `$####@%|!$##;    |#@:       '&#%.  ;##|         :@#%.  `$#&'         .%#@:   :@#%.       |#@:
--   '&#@!::::::::;$##|     |##;        '$#&'  :@#$`      |#@;    |#@:       '&#%.  :@#$`        ;##%.  .%##;         `$#$`   :@#%.       |#@:
--  `$##;          `$##;    |##$`      .%##!   !##!      :@#@;    |#@:       '&#%.  `$##!       :@##%.   :@#@:       .%##;    :@#%.       |#@:
--  |##|            :@#&'   |####&:. '$###!    '&##$' .;&@###:    |#@:       '&#%.   `%###%' `!@#&##%.    `$##@|' .:$##@:     :@#%.       |#@:
-- ;##$`             !##$`  |##;.|#####&:        ;@####&: |#@;    |##;       '&#%.     .%#####@: :@#%.       ;@#####@|.       :@#%.       |##;

-- ************************************************************
-- @FuncName: OpenSelectionView 设置游戏ID, 为了弹出选场？似乎不用了
-- @Param1: id                  游戏ID
-- ************************************************************
function M.OpenSelectionView(id)
    CC.DataMgrCenter.Inst():GetDataByKey("Game").SetSelectViewGameID(id)
end

--打开碎片礼包,点卡碎片已移除
function M.OpenDebrisGiftView()
    CC.uu.Log("OpenDebrisGiftView 接口已废弃", "", 3)
end

function M.OpenFootballView()
    CC.uu.Log("OpenFootballView 接口已废弃", "", 3)
end

-- ************************************************************
-- CreateMiniGameIcon 创建小厅入口图标（小厅已下线2022-02-17）
-- @param : 挂载参数
-- param.parent（必填项） 挂载的父节点，父节点大小必须全屏，因为要移动，如果有需要自定义位置，可以传坐标
-- param.pos（可选项） 挂载的位置坐标，Icon挂在父节点上的位置
-- ************************************************************
function M.CreateMiniGameIcon(param)
    CC.uu.Log("CreateMiniGameIcon 接口已废弃", "", 3)
    return false
end

-- 当拖动小厅图标后，小厅会发出一个事件，用来记录小厅拖动后的位置，推送的值为 localPosition，如果有需要记录小厅Icon位置的，可以监听这个事件，
-- 收到时保存到Playerprefs，创建时再作为参数传进去
-- CC.Notifications.OnSetMiniIconPos
-- 例如：
-- GC.HallNotificationCenter.inst():register(M, M.OnSetMiniIconPos, GC.Notifications.OnSetMiniIconPos)

-- ************************************************************
-- DestroyMiniGameIcon 销毁小厅入口图标 （小厅已下线2022-02-17）
-- @icon : 小厅图标
-- ************************************************************
function M.DestroyMiniGameIcon(icon)
    if icon then
        CC.MiniGameMgr.DestroyIcon(icon)
    end
end

-- 打开摇摇乐
function M.CreateShake(node, layer, GameId, call)
    CC.uu.Log("CreateShake 接口已废弃", "", 3)
    local icon = CC.ViewCenter.ShakeIcon.new()
    icon:Create({parent = node, layer = layer, GameId = GameId, callback = call})
    return icon
end

-- 销毁摇摇乐
function M.DestryShake(icon)
    CC.uu.Log("DestryShake 接口已废弃", "", 3)
    icon:Destroy()
end

-- ************************************************************
-- @FuncName: OpenShake
-- @Param1: GameId
-- @Param2: callback
-- ************************************************************
function M.OpenShake(GameId, callback)
    CC.uu.Log("OpenShake 接口已废弃", "", 3)
end

--新手礼包
function M.NoviceEndTime()
    logError("----------接口已作废，请接新的礼包合集-----------")
end

return Interface
