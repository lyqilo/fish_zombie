-- ************************************************************
-- @File: ActivityInterface.lua
-- @Summary: 对子游戏暴露操作 活动类接口，包括创建活动icon，打开活动界面等
-- @Version: 1.0
-- @Author: luo qiu zhang
-- @Date: 2023-03-28 10:24:49
-- ************************************************************
local CC = require("CC")
local PlayerInfoInterface = require("SubGame/Interface/PlayerInfoInterface")
local ActivityInterface = {}
local M = {}
M.__index = function(t, key)
    if M[key] then
        return M[key]
    else
        return function()
            logError("无法访问 ActivityInterface.lua 里 函数为 " .. key .. "() 的接口, 请确认接口名字")
        end
    end
end
setmetatable(ActivityInterface, M)

-- 救济金唯一弹框
local ReliefManager = nil

--救济金相关,检测当前传入的筹码数是否可以领取救济,func会在领取失败的时候触发
function M.CheckRelief(curMoney, errCb, succCb)
    local threshold = PlayerInfoInterface.GetThreshold() or 0
    local leftTimes = PlayerInfoInterface.GetReliefLeftTimes() or 0
    if threshold <= curMoney or leftTimes < 1 then
        return false
    end

    if not ReliefManager then
        log("CheckRelief pass, ready to show BenefitsView")
        local data = {}
        data.curMoney = curMoney
        data.errCb = errCb
        data.succCb = succCb
        data.callback = function()
            ReliefManager = nil
        end
        ReliefManager = CC.ReliefManager.new(data)
        ReliefManager:OnCreate()
    end

    return true
end

--[[
--检查破产和救济金
@param:
curMoney：当前筹码(int类型)
brokeMoney：破产条件筹码(int类型)
againBroke：是否可以多次触发（在破产触发过再次触发，bool值，可以不传，true：只要有档位没购买就会一直打开礼包)
entryLimit：入场金币限制
closeFunc:破产关闭回调
errCb,succCb：救济金回调
]]
--破产界面
local brokeManager = nil
--触发
local reqTriggerBroke = true

function M.CheckBrokeOrRelief(param)
    if CC.ChannelMgr.GetTrailStatus() then
        return false
    end
    if brokeManager or not reqTriggerBroke then
        return true
    end
    param = param or {}
    local curMoney = param.curMoney or PlayerInfoInterface.GetHallMoney()
    if (param.brokeMoney and curMoney <= param.brokeMoney) or curMoney <= PlayerInfoInterface.GetThreshold() then
        M.BrokeGiftTrigger(param)
        if not reqTriggerBroke then
            return true
        end
    end
    --救济金
    if not brokeManager and reqTriggerBroke then
        return M.CheckRelief(curMoney, param.errCb, param.succCb)
    end
    return false
end

--破产礼包触发
function M.BrokeGiftTrigger(param)
    local curMoney = param.curMoney or PlayerInfoInterface.GetHallMoney()
    local entryLimit = param.entryLimit or 0
    local activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
    --触发小额破产
    local smallBrokeView = true
    if entryLimit >= 4000000 then
        smallBrokeView = false
    end
    local brokeData = smallBrokeView and activityDataMgr.GetBrokeGiftData() or activityDataMgr.GetBrokeBigGiftData()
    local bState = false
    if brokeData.nStatus == 0 then
        --首次触发破产礼包
        bState = true
    elseif brokeData.nStatus == 1 and param.againBroke then
        if brokeData.arrBrokenGift then
            for _, v in ipairs(brokeData.arrBrokenGift) do
                if v.bStatus then
                    --有档位没有购买
                    bState = true
                    break
                end
            end
        end
    end
    if bState and reqTriggerBroke then
        reqTriggerBroke = false
        local reqName = smallBrokeView and "ReqBrokeGiftInfo" or "ReqBrokeBigGiftInfo"
        CC.Request(
            reqName,
            nil,
            function(err, data)
                --请求触发破产
                if err == 0 then
                    if smallBrokeView then
                        activityDataMgr.SetBrokeGiftData(data)
                    else
                        activityDataMgr.SetBrokeBigGiftData(data)
                    end
                    if data.nStatus == 1 then
                        --触发成功
                        local openViewName = smallBrokeView and "BrokeGiftView" or "BrokeBigGiftView"
                        activityDataMgr.SetActivityInfoByKey(openViewName, {switchOn = true})
                        brokeManager =
                            CC.ViewManager.Open(
                            openViewName,
                            {
                                callback = function(buyInBroke)
                                    brokeManager = nil
                                    if not buyInBroke then
                                        M.CheckRelief(curMoney, param.errCb, param.succCb)
                                    end
                                    if param.closeFunc then
                                        param.closeFunc()
                                    end
                                end
                            }
                        )
                    end
                end
                reqTriggerBroke = true
            end,
            function()
                reqTriggerBroke = true
            end
        )
    end
end

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

--[[
--v2，v3最优惠礼包
needLevel:需要达到的vip等级，只能v2和v3
]]
function M.OpenVipBestGiftView(param)
    -- 只接受vip level == 1 or 2
    if PlayerInfoInterface.GetVipLevel() < 1 or PlayerInfoInterface.GetVipLevel() > 2 then
        return false
    end
    if CC.ChannelMgr.CheckOppoChannel() or CC.ChannelMgr.CheckVivoChannel() or CC.ChannelMgr.CheckOfficialWebChannel() then
        CC.ViewManager.Open("VipThreeCardView")
        return true
    end
    local needLv = param and param.needLevel
    if needLv and needLv >= 2 and needLv <= 3 then
        local curVIPExp = CC.Player.Inst():GetSelfInfoByKey("EPC_Experience")
        local levelCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Level")
        local levelUpExp = levelCfg[param.needLevel - 1].Experience
        local needExp = (levelUpExp - curVIPExp) / 1000000
        local wareId = nil
        local BaseGifts = {
            {
                wareId = "30288",
                MaxEpx = 10,
                MinEpx = 1,
                Level = 2,
                diamond = 49,
                Platform = CC.shared_enums_pb.OST_Android
            },
            {
                wareId = "30289",
                MaxEpx = 29,
                MinEpx = 11,
                Level = 2,
                diamond = 94,
                Platform = CC.shared_enums_pb.OST_Android
            },
            {
                wareId = "30290",
                MaxEpx = 69,
                MinEpx = 30,
                Level = 2,
                diamond = 196,
                Platform = CC.shared_enums_pb.OST_Android
            },
            {wareId = "30291", MaxEpx = 35, MinEpx = 1, Level = 2, diamond = 173, Platform = CC.shared_enums_pb.OST_IOS},
            {
                wareId = "30292",
                MaxEpx = 69,
                MinEpx = 36,
                Level = 2,
                diamond = 167,
                Platform = CC.shared_enums_pb.OST_IOS
            },
            {
                wareId = "30293",
                MaxEpx = 149,
                MinEpx = 70,
                Level = 2,
                diamond = 390,
                Platform = CC.shared_enums_pb.OST_IOS
            },
            {wareId = "30294", MaxEpx = 10, MinEpx = 1, Level = 2, diamond = 49},
            {wareId = "30295", MaxEpx = 30, MinEpx = 11, Level = 2, diamond = 68},
            {wareId = "30296", MaxEpx = 50, MinEpx = 31, Level = 2, diamond = 110},
            {wareId = "30297", MaxEpx = 60, MinEpx = 51, Level = 2, diamond = 52},
            {wareId = "30298", MaxEpx = 90, MinEpx = 61, Level = 2, diamond = 145},
            {wareId = "30299", MaxEpx = 100, MinEpx = 91, Level = 2, diamond = 52},
            {
                wareId = "30300",
                MaxEpx = 10,
                MinEpx = 1,
                Level = 3,
                diamond = 49,
                Platform = CC.shared_enums_pb.OST_Android
            },
            {
                wareId = "30301",
                MaxEpx = 29,
                MinEpx = 11,
                Level = 3,
                diamond = 94,
                Platform = CC.shared_enums_pb.OST_Android
            },
            {
                wareId = "30302",
                MaxEpx = 69,
                MinEpx = 30,
                Level = 3,
                diamond = 196,
                Platform = CC.shared_enums_pb.OST_Android
            },
            {wareId = "30303", MaxEpx = 35, MinEpx = 1, Level = 3, diamond = 173, Platform = CC.shared_enums_pb.OST_IOS},
            {
                wareId = "30304",
                MaxEpx = 69,
                MinEpx = 36,
                Level = 3,
                diamond = 167,
                Platform = CC.shared_enums_pb.OST_IOS
            },
            {
                wareId = "30305",
                MaxEpx = 149,
                MinEpx = 70,
                Level = 3,
                diamond = 390,
                Platform = CC.shared_enums_pb.OST_IOS
            },
            {wareId = "30306", MaxEpx = 10, MinEpx = 1, Level = 3, diamond = 49},
            {wareId = "30307", MaxEpx = 30, MinEpx = 11, Level = 3, diamond = 68},
            {wareId = "30308", MaxEpx = 50, MinEpx = 31, Level = 3, diamond = 110},
            {wareId = "30309", MaxEpx = 60, MinEpx = 51, Level = 3, diamond = 52},
            {wareId = "30310", MaxEpx = 90, MinEpx = 61, Level = 3, diamond = 145},
            {wareId = "30311", MaxEpx = 100, MinEpx = 91, Level = 3, diamond = 52}
        }
        local playerDiamond = PlayerInfoInterface.GetHallDiamond()
        for _, v in ipairs(BaseGifts) do
            if needLv == v.Level then
                --经验在挡位中间,钻石不够
                if needExp >= v.MinEpx and needExp <= v.MaxEpx and playerDiamond < v.diamond then
                    if M.GetMolChannelState() then
                        --解锁三方支付
                        if not v.Platform then
                            wareId = v.wareId
                        end
                    elseif v.Platform and CC.Platform.GetOSEnum() == v.Platform then
                        wareId = v.wareId
                    end
                end
            end
            if wareId then
                break
            end
        end
        log("needExp:" .. needExp .. " Platform:" .. CC.Platform.GetOSEnum())
        logError(wareId)
        if wareId then
            CC.ViewManager.Open("VIPBestGfitView", {wareId = wareId})
            return true
        else
            CC.ViewManager.Open("VipThreeCardView")
            return true
        end
    end
    return false
end

function M.ByWareIdGetState(wareId)
    return CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetGiftStatus(wareId)
end

function M.GetDailySwitch()
    if not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
        return false
    end
    return CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("NoviceGiftView").switchOn
end

--是否满足打开新手礼包条件
function M.Novice_Bool()
    return CC.SelectGiftManager.CheckNoviceGiftCanBuy()
end

--打开新手礼包
function M.OpenNovice(node, layer)
    local icon = CC.ViewCenter.NoviceIcon.new()
    icon:Create({parent = node, layer = layer})
    return icon
end

--销毁新手礼包
function M.DestroyNovice(icon)
    icon:Destroy()
end

--[[
@param:
parent: 挂载的父节点(创建后layer和父节点一致)
sprite: 入口按钮sprite(可缺省)
width:  sprite width(可缺省)
height: sprite height(可缺省)
openFunc: 界面打开回调(可缺省)
closeFunc: 界面关闭回调(可缺省)
SelectTab：填写你要显示的礼包（目前礼包有，“DailyTurntableView”(每日转盘)，“OnlineAward（在线宝箱）”，“LimmitAwardView（登陆奖励）”，
可根据各位心情随意选择想要的礼包。如下方例子1所示）
例子1：        SelectTab = {"DailyTurntableView","LimmitAwardView"}
]]
function M.CreateFreeChipsCollectionIcon(param)
    if not CC.ChannelMgr.GetSwitchByKey("bHasFreeChips") then
        return false
    end
    return CC.FreeChipsManager.CreateIcon(param)
end

function M.CreateSlotFreeChipsCollectionIcon(param)
    if not CC.ChannelMgr.GetSwitchByKey("bHasFreeChips") then
        return false
    end
    return CC.FreeChipsManager.CreateSlotIcon(param)
end

function M.DestroyFreeChipsCollectionIcon(icon)
    if not CC.ChannelMgr.GetSwitchByKey("bHasFreeChips") then
        return false
    end
    if not icon then
        return false
    end
    CC.FreeChipsManager.DestroyIcon(icon)
end

--[[
@param:
parent: 挂载的父节点(创建后layer和父节点一致)
openFunc: 界面打开回调(可缺省)
closeFunc: 界面关闭回调(可缺省)
SelectGiftTab：填写你要显示的礼包（目前礼包有，“NoviceGiftView”(新手礼包)，“FundView（七日基金）”，“Act_EveryGift（捕鱼礼包）”，
shakeIfRedDot:是否红点显示的时候同时有抖动效果（默认不抖动）
可根据各位心情随意选择想要的礼包。如下方例子1所示）
例子1：        SelectGiftTab = {"NoviceGiftView","FundView"}
]]
function M.CreateSelectGiftCollectionIcon(param)
    if CC.ChannelMgr.CheckOppoChannel() or CC.ChannelMgr.CheckVivoChannel() or CC.ChannelMgr.CheckOfficialWebChannel() then
        return M.CreateDailyGiftCollectionIcon(param)
    end
    if not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
        return false
    end
    return CC.SelectGiftManager.CreateIcon(param)
end

function M.CreateSlotSelectGiftCollectionIcon(param)
    if not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
        return false
    end
    return CC.SelectGiftManager.CreateSlotIcon(param)
end

function M.CreateSelectGiftCollectionIconWithoutDailyGift(param)
    if not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
        return false
    end
    return CC.SelectGiftManager.CreateIconWithoutDailyGift(param)
end

function M.CreateSlotBrokeGiftIcon(param)
    if not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
        return false
    end
    return CC.SelectGiftManager.CreateSlotBrokeGiftIcon(param)
end

function M.DestroySelectGiftCollectionIcon(icon)
    if CC.ChannelMgr.CheckOppoChannel() or CC.ChannelMgr.CheckVivoChannel() or CC.ChannelMgr.CheckOfficialWebChannel() then
        return M.DestroyDailyGiftCollectionIcon(icon)
    end
    if not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
        return false
    end
    if not icon then
        return false
    end
    CC.SelectGiftManager.DestroyIcon(icon)
end

--[[
@param:
parent: 挂载的父节点
]]
function M.CreateDailyGiftCollectionIcon(param)
    return CC.SelectGiftManager.CreateDialyIcon(param)
end

function M.DestroyDailyGiftCollectionIcon(icon)
    if not icon then
        return false
    end
    CC.SelectGiftManager.DestroyIcon(icon)
end

--[[
@param:
parent: 挂载的父节点
]]
function M.CreateSlotCommonNoticeIcon(param)
    return CC.SlotCommonNoticeManager.CreateIcon(param)
end

function M.DestroySlotCommonNoticeIcon(icon)
    if not icon then
        return false
    end
    CC.SlotCommonNoticeManager.DestroyIcon(icon)
end

--[[
创建在线奖励单独按钮（带倒计时）
@param
parent = 父节点
]]
function M.CreateOnlineIcon(param)
    if not CC.ChannelMgr.GetSwitchByKey("bHasFreeChips") then
        return false
    end
    return CC.OnlineManager.CreateIcon(param)
end

function M.CreateSlotsOnlineIcon(param)
    if not CC.ChannelMgr.GetSwitchByKey("bHasFreeChips") then
        return false
    end
    return CC.OnlineManager.CreateSlotsIcon(param)
end

function M.DestroyOnlineIcon(icon)
    if not CC.ChannelMgr.GetSwitchByKey("bHasFreeChips") then
        return false
    end
    if not icon then
        return false
    end
    CC.OnlineManager.DestroyIcon(icon)
end

--[[
创建礼包按钮
@param
parent = 父节点
]]
function M.CreateElephantIcon(param)
    if CC.ChannelMgr.GetTrailStatus() then
        return false
    end
    if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel") then
        return false
    end
    return CC.ElephantManager.CreateIcon(param)
end

function M.OpenGoldElephantView()
    if not CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("ElephantPiggy").switchOn then
        return false
    end
    CC.ViewManager.Open("GoldenElephant")
end

function M.DestroyElephantIcon(icon)
    if not icon then
        return false
    end
    CC.ElephantManager.DestroyIcon(icon)
end

--[[
@param
SelectGiftTab：填写你要显示的礼包（目前礼包有，“NoviceGiftView”(新手礼包)，“FundView（七日基金）”，“Act_EveryGift（捕鱼礼包）”，
可根据各位心情随意选择想要的礼包。如下方例子1所示）
例子1：        SelectGiftTab = {"NoviceGiftView","FundView"}
]]
function M.OpenGiftSelectionView(param)
    if not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
        return false
    end
    if CC.Platform.isIOS then
        if param.SelectGiftTab then
            for i, v in ipairs(param.SelectGiftTab) do
                if v == "DailyDealsView" or v == "Act_EveryGift" then
                    return false
                end
            end
        end
    end

    return CC.ViewManager.Open("SelectGiftCollectionView", param)
end

--[[
@param
currentView = 打开合集后第一个显示的界面（目前礼包有，“DailyGiftBuyu”(捕鱼)，“DailyGiftDummy（dummy）”，“DailyGiftPokdeng（pokdeng）”, "DailyDealsView（飞机）" 
例子1：currentView = {"DailyGiftBuyu"}
]]
function M.OpenDailyGiftView(param)
    CC.ViewManager.Open("DailyGiftCollectionView", param)
end

--[[
@param
SelectTab：填写你要显示的礼包，不传此参数则默认显示所有礼包
currentView : 打开合集后第一个显示的界面
]]
function M.OpenFreeChipsCollectionView(param)
    if not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
        return false
    end
    return CC.ViewManager.Open("FreeChipsCollectionView", param)
end

--[[
@param:
parent: 挂载的父节点
id: 游戏ID
]]
function M.CreateMonthRankIcon(param)
    local activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
    if not param or not param.id then
        return false
    end
    if
        not activityDataMgr.GetActivityInfoByKey("MonthRankView").switchOn and
            not activityDataMgr.GetActivityInfoByKey("BatteryRankView").switchOn
     then
        return false
    end
    local HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
    local id = param.id
    if
        (HallDefine.MonthRank[id] and HallDefine.MonthRank[id].Open) or
            (HallDefine.BatteryRank[id] and HallDefine.BatteryRank[id].Open)
     then
        return CC.RankIconManager.CreateIcon(param)
    else
        return false
    end
end

function M.DestroyMonthRankIcon(icon)
    if not icon then
        return false
    end
    CC.RankIconManager.DestroyIcon(icon)
end

--[[
@param:
parent: 挂载的父节点
]]
function M.CreateCashCowIcon(param)
    if CC.ChannelMgr.GetTrailStatus() then
        return
    end
    return CC.CashCowIconManager.CreateIcon(param)
end
function M.DestroyCashCowIcon(icon)
    return CC.CashCowIconManager.DestroyIcon(icon)
end

function M.OpenCashCowView()
    if CC.ChannelMgr.GetTrailStatus() then
        return false
    end
    return CC.ViewManager.Open("CashCowView")
end

function M.GetAllDailyGiftStatus()
    local wareIds = {"22011", "22012", "22013", "22014", "22015", "22016", "30015"}
    local activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
    for _, v in ipairs(wareIds) do
        if activityDataMgr.GetGiftStatus(v) then
            return true
        end
    end
    return false
end

function M.GetFortuneCatGiftState()
    local activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
    return activityDataMgr.GetActivityInfoByKey("FortuneCatView").switchOn
end

function M.GetSelectGiftSwitch(Key)
    if not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
        return false
    end
    local activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")

    if Key == "BatteryLotteryView" then
        --如果是通用炮台活动——BatteryLotteryView
        --多返回一个当前炮台ID
        --龙击炮为1  朱雀炮台为2  白虎炮台为3 玉兔炮台为4 蛋糕炮台5 水枪炮台6 青龙炮台7 足球炮台8 四圣兽9 电音炮台10
        local currentBatteryID = 10
        return activityDataMgr.GetActivityInfoByKey(Key).switchOn, currentBatteryID
    end

    return activityDataMgr.GetActivityInfoByKey(Key).switchOn
end

return M
