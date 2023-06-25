-- ************************************************************
-- @File: UIInterface.lua
-- @Summary: 对子游戏暴露操作UI的一些接口，包括打开界面,打开消息框创建icon, chipCounter diamondCounter等
-- @Version: 1.0
-- @Author: luo qiu zhang
-- @Date: 2023-03-28 10:24:49
-- ************************************************************
local CC = require("CC")
local UIInterface = {}
local PlayerInfoInterface = require("SubGame/Interface/PlayerInfoInterface")
local M = {}
M.__index = function(t, key)
    if M[key] then
        return M[key]
    else
        return function()
            logError("无法访问 UIInterface.lua 里 函数为 " .. key .. "() 的接口, 请确认接口名字")
        end
    end
end
setmetatable(UIInterface, M)

function M.CreateHeadIcon(data)
    return CC.HeadManager.CreateHeadIcon(data)
end

function M.GetHeadIconPathById(id)
    return CC.HeadManager.GetHeadIconPathById(id)
end

function M.CreateVIPCounter()
    return CC.HeadManager.CreateVIPCounter()
end

function M.DestroyVIPCounter(counter)
    CC.HeadManager.DestroyVIPCounter(counter)
end

function M.DestroyHeadIcon(icon, isDestroyObj)
    CC.HeadManager.DestroyHeadIcon(icon, isDestroyObj)
end

function M.SetHeadIcon(portrait, headIcon, playerId)
    CC.HeadManager.SetHeadIcon(portrait, headIcon, playerId)
end

function M.SetHeadVipLevel(vipLevel, vipNode)
    CC.HeadManager.SetHeadVipLevel(vipLevel, vipNode)
end

function M.CreateHeadFrame(id, parent)
    return CC.HeadManager.CreateHeadFrame(id, parent)
end

function M.OpenPersonalInfoView(param)
    if CC.ChannelMgr.GetTrailStatus() then
        return false
    end
    return CC.HeadManager.OpenPersonalInfoView(param or {})
end

--[[
effectId:玩家入场特效，玩家信息的Effect
parant:父节点
content:展示的说明内容
]]
function M.CreateEntryEffect(effectId, parent, content)
    -- if not CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("ChristmasTaskView").switchOn then
    --     return nil
    -- end
    --3054，3055，3056 特效捕鱼(3002,3005,3007)专有
    local gameId = CC.ViewManager.GetCurGameId() or 1
    if gameId ~= 3002 and gameId ~= 3005 and gameId ~= 3007 then
        return false
    end
    return CC.IconManager.CreateEntryEffect(effectId, parent, content)
end

function M.OpenMenu(param)
    return CC.ViewManager.Open("SetUpView", param)
end

function M.OpenChat(Chips)
    if not Chips then
        logError("游戏内调起OpenChat，需要把当前子游戏的筹码作为参数传进来，用于刷新大厅数据")
        return false
    end

    local language = CC.LanguageManager.GetLanguage("L_Common")
    local chatPanelToggle = CC.ChatManager.ChatPanelToggle()
    local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("ChatPanel")

    if chatPanelToggle and switchOn then
        PlayerInfoInterface.ChangeHallUserProp(CC.shared_enums_pb.EPC_ChouMa, Chips, 0)
        return CC.ViewManager.ShowChatPanel()
    else
        return CC.ViewManager.ShowTip(language.tip10)
    end
end

function M.ExOpenChat(param)
    if not param then
        logError("游戏内调起ExOpenChat，需要把当前子游戏的筹码或者礼券作为参数传进来，用于刷新大厅数据")
        return false
    end
    local language = CC.LanguageManager.GetLanguage("L_Common")
    local chatPanelToggle = CC.ChatManager.ChatPanelToggle()
    local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("ChatPanel")

    if chatPanelToggle and switchOn then
        if param.ChouMa then
            PlayerInfoInterface.ChangeHallUserProp(CC.shared_enums_pb.EPC_ChouMa, param.ChouMa, 0)
        end
        if param.Integral then
            PlayerInfoInterface.ChangeHallUserProp(CC.shared_enums_pb.EPC_New_GiftVoucher, param.Integral, 0)
        end

        return CC.ViewManager.ShowChatPanel()
    else
        return CC.ViewManager.ShowTip(language.tip10)
    end
end

function M.OpenShop(ChouMa, func)
    if not ChouMa then
        logError("游戏内调起OpenShop，需要把当前子游戏的筹码作为参数传进来，用于刷新大厅数据")
        return false
    end

    PlayerInfoInterface.ChangeHallUserProp(CC.shared_enums_pb.EPC_ChouMa, ChouMa, 0)
    CC.ViewManager.Open("StoreView", {callback = func})
end

--param = {}
--param.ChouMa      同步游戏内筹码数量
--param.Integral    同步游戏内礼券数量
--param.channelTab  打开商店相关页签，不传默认打开钻石购买(用M.GetStoreTab方法获取,就在下面)
--param.hideAutoExchange    隐藏自动兑换筹码按钮并强制购买为得到砖石
function M.ExOpenShop(param, func)
    if not param then
        logError("游戏内调起ExOpenShop，需要把当前子游戏的筹码/礼券等作为参数传进来，用于刷新大厅数据")
        return
    end

    if param.ChouMa then
        PlayerInfoInterface.ChangeHallUserProp(CC.shared_enums_pb.EPC_ChouMa, param.ChouMa, 0)
    end
    if param.Integral then
        PlayerInfoInterface.ChangeHallUserProp(CC.shared_enums_pb.EPC_New_GiftVoucher, param.Integral, 0)
    end

    local data = {}
    data.channelTab = param.channelTab
    data.hideAutoExchange = param.hideAutoExchange
    data.callback = func

    CC.ViewManager.Open("StoreView", data)
end

function M.OpenRealStore(param, func)
    if not CC.ChannelMgr.GetSwitchByKey("bHasRealStore") then
        return false
    end

    if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("TreasureView") then
        return false
    end

    if not param then
        logError("游戏内调起OpenRealStore，需要把当前子游戏的筹码/礼券作为参数传进来，用于刷新大厅数据")
        return false
    end

    if param.ChouMa then
        PlayerInfoInterface.ChangeHallUserProp(CC.shared_enums_pb.EPC_ChouMa, param.ChouMa, 0)
    end
    if param.Integral then
        PlayerInfoInterface.ChangeHallUserProp(CC.shared_enums_pb.EPC_New_GiftVoucher, param.Integral, 0)
    end

    CC.ViewManager.Open("TreasureView", {callback = func})
end

function M.OpenServiceView()
    CC.ViewManager.OpenServiceView()
end

function M.ShowTip(str, second, finishCall)
    CC.ViewManager.ShowTip(str, second or 5, finishCall)
end

function M.CloseTip()
    CC.ViewManager.CloseTip()
end

function M.CreateMessageBox(str, okFunc, noFunc)
    return CC.ViewManager.ShowMessageBox(str, okFunc, noFunc)
end

function M.GotoShopTip(ChouMa)
    if CC.ChannelMgr.GetIosTrailStatus() then
        return false
    end

    local confirm = function()
        M.OpenShop(ChouMa or 0)
    end

    local cancel = function()
    end

    local language = CC.LanguageManager.GetLanguage("L_Common")
    CC.ViewManager.ShowMessageBox(language.Go2ShopTips, confirm, cancel)
end

--老虎机通用特效
local WinEffectView = nil
-- shareParam = {extraData={},content=""}
function M.PlayWinEffect(baseMoney, deltaMoney, callback, shareParam)
    if WinEffectView then
        return WinEffectView:PlayWinEffect(
            {baseMoney = baseMoney, winMoney = deltaMoney, callback = callback, shareParam = shareParam}
        )
    end
end

function M.PlayFreeWinEffect(freeTime, callback, duration)
    if WinEffectView then
        return WinEffectView:PlayFreeSpinsEffect({freeTimes = freeTime, callback = callback, duration = duration})
    end
end

function M.PlayMajorWinEffect(deltaMoney, callback, duration)
    if WinEffectView then
        return WinEffectView:PlayBonusEffect({winMoney = deltaMoney, callback = callback, duration = duration})
    end
end

function M.CreateGameEffectView()
    M.ReleaseGameEffectView()

    if not WinEffectView then
        WinEffectView = CC.uu.CreateHallView("GameEffectView")
    end
end

function M.ReleaseGameEffectView(destroyOnLoad)
    if WinEffectView then
        WinEffectView:Destroy(destroyOnLoad)
        WinEffectView = nil
    end
end

function M.GetWinEffectCfg(winMul)
    if WinEffectView then
        return WinEffectView:GetEffectCfg(winMul)
    end
end

function M.CloseAllHallView()
    CC.ViewManager.CloseAllView()
end

function M.SetNoticeBordPos(vec3)
    CC.ViewManager.SetNoticeBordPos(vec3)
end

function M.SetNoticeBordPosEx(vec3)
    CC.ViewManager.SetNoticeBordPosEx(vec3)
end

function M.SetNoticeBordWidth(width)
    --传小于15数字，宽度都会变为负数，会打人的。
    CC.ViewManager.SetNoticeBordWidth(width)
end

function M.SetNoticeBordEffectState(active)
    CC.ViewManager.SetNoticeBordEffectState(active)
end

function M.SetSpeakBoardPos(vec3)
    CC.ViewManager.SetSpeakBoardPos(vec3)
end

function M.SetSpeakBoardPosEx(vec3)
    CC.ViewManager.SetSpeakBoardPosEx(vec3)
end

function M.SetSpeakBoardWidth(width)
    --传小于15数字，宽度都会变为负数，会打人的。
    CC.ViewManager.SetSpeakBoardWidth(width)
end

-- 设置喇叭开启状态
function M.SetSpeakBordState(bState)
    local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("HorseRaceLamp")
    local unLock = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel")

    if not switchOn or not unLock then
        bState = false
    end

    CC.ChatManager.SetSpeakBordState(bState)
end

--设置跑马灯开启状态
function M.SetNoticeBordState(bState)
    if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("HorseRaceLamp") then
        bState = false
    end
    CC.ChatManager.SetNoticeBordState(bState)
end

function M.CreateStarRateView(param)
    if
        CC.LocalGameData.GetLocalDataToKey("StarRatingView", CC.Player.Inst():GetSelfInfoByKey("Id")) and
            CC.LocalGameData.GetLocalDataToKey("StarRatingReward", CC.Player.Inst():GetSelfInfoByKey("Id"))
     then
        CC.ViewManager.Open("StarRatingView", {reward = param.reward, succCb = param.succCb, errCb = param.errCb})
    end
end

--[[
控制浮动按钮组显示哪些按钮
@param
state:字符串数组，1返回 2商店
例如：
state = {"1"}		 --仅显示返回
state = {"1","2"}	 --返回和商店都显示
]]
function M.SetFloatBtnGroupState(state)
    if type(state) ~= "table" then
        logError("SetFloatBtnGroupState 参数错误")
        return
    end

    --兼容旧版本接口
    if tonumber(AppInfo.androidVersionCode) <= 16 then
        Client.CreateBackButton()
        local btnState = {}
        for _, v in ipairs(state) do
            btnState[tonumber(v)] = true
        end
        for i = 1, 2 do
            local isLock = not btnState[i]
            --旧版本接口参数有2个(int,boolean)
            Client.SetFloatBtnState(i, isLock)
        end
    else
        --新版本接口参数只有1个(string[])
        Client.SetFloatBtnState(state)
    end
end

--[[
创建/销毁浮动按钮组
@param
state:控制按钮 0销毁，1创建
创建前先调用SetFloatBtnGroupState，否则默认两个按钮都显示
]]
function M.CreateFloatBtnGroup(state)
    --兼容旧版本接口
    if tonumber(AppInfo.androidVersionCode) <= 16 then
        Client.CreateBackButton()
    end
    Client.SetFloatActionButtonState(tonumber(state))
end

--[[
-- 子游戏打开解锁礼包(大厅不做入场判断)
@param:
vipLimit:大厅不限制入场后，获取不到入场VIP等级，需要子游戏传
返回false,说明玩家购买了解锁礼包或当前游戏没有解锁礼包
]]
function M.OpenUnlockGift(param)
    local vipLimit = param.vipLimit
    local HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
    local gameID = CC.ViewManager.GetCurGameId()
    if gameID ~= 1 and HallDefine.UnlockCondition[gameID] then
        local prop = HallDefine.UnlockCondition[gameID].Prop
        local view = HallDefine.UnlockCondition[gameID].View
        local lock = HallDefine.UnlockCondition[gameID].Lock
        local propNum = CC.Player.Inst():GetSelfInfoByKey(prop) or 0
        if propNum > 0 then
            return false
        else
            if not lock or CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel") then
                return CC.ViewManager.Open(view)
            end
            if vipLimit > 1 and vipLimit <= 3 then
                return CC.ViewManager.Open("VipThreeCardView")
            elseif CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
                return CC.ViewManager.Open("SelectGiftCollectionView", {SelectGiftTab = {"NoviceGiftView"}})
            else
                return false
            end
        end
    else
        return false
    end
end

--[[
    @param
    gameId: 游戏id
    callback: 无需下载回调。 callback(enterFunc,gameData) 回调需要接收两个参数
                @param
                enterFunc: 确认进入方法，子游戏手动调用。 enterFunc(enterData) 方法需要回传 enterData，即callback传过去的gameData
                gameData: 回传给enterFunc的参数

    下载进度可监听
    GC.Notifications.DownloadGame ，下载Process，function ({gameID,process}) end ，可能同时下载多个，最好做gameID校验
    GC.Notifications.DownloadFail ，下载失败（失败会弹出重新下载框，如果取消下载会收到此消息），function (gameID) end
    PS:由于下载完不走callback回调，后续只能在Process==1后，合适的时候再次调用此接口
]]
function M.GameToGame(gameId, callback)
    CC.ViewManager.SubGameToGame(gameId, callback)
end

function M.BackToHall(callback)
    CC.ViewManager.GameEnterMainScene(callback)
end

function M.BackToLogin()
    local callback = function()
        CC.ViewManager.BackToLogin(CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.Logout)
    end
    CC.ViewManager.GameEnterMainScene(callback)
end

--棋牌游戏主动踢回大厅重连
function M.BackToHallByReconnect()
    local callback = function()
        local playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
        CC.Request("ReqLoadPlayerGameInfo", {PlayerId = playerId})
    end
    CC.ViewManager.GameEnterMainScene(callback)
end

-- 断线踢回登录
function M.BackToLoginByDisconnect()
    CC.ViewManager.BackToLoginByDisconnect()
end

function M.KickedOutTip()
    local callback = function()
        CC.ViewManager.BackToLogin(CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.Kickedout)
    end
    CC.ViewManager.GameEnterMainScene(callback)
end

--[[
在线福利活动，弹窗提示开关
@param:
isOpen:是否开启，默认true（可缺省）
isLeft:是否在左边，默认false（可缺省）
offset:上下偏移值，窗口往下是正，默认0（可缺省）
]]
function M.SetOnlineWelfare(isOpen, isLeft, offset)
    CC.ViewManager.SetRewardNoticeView(isOpen, isLeft, offset)
end

--竞技场推送提示开关，强制弹窗3s后消失。如需要弹窗，必须监听玩家请求跳转事件。
--退出游戏的时候设置回缺省值，除非能保证跳转过去的子游戏设置这个接口。
--[[
@param:
isOpen:是否开启，默认false（可缺省）
isLeft:是否在左边，默认false（可缺省）
offset:上下偏移值，窗口往下是正，默认0（可缺省）
whiteList:允许显示的gameid白名单，如{3001,3004}, 默认所有都显示
]]
function M.SetArenaNoticeView(isOpen, isLeft, offset, whiteList)
    CC.ViewManager.SetArenaNoticeView(isOpen, isLeft, offset, whiteList)
end

function M.IsLiuHaiScreen()
    local designWidth, designHeight = 720, 1280
    local specialWidth, specialHeight = 1080, 2248
    local screenWidth, screenHeight = math.min(Screen.width, Screen.height), math.max(Screen.width, Screen.height)
    local limitScale = specialWidth / specialHeight
    local limitWidth = limitScale * designHeight
    local trueWidth = (screenWidth / screenHeight) * designHeight
    return trueWidth - limitWidth <= 0
end

--[[
@param
ConfigId:道具id
Count:总数
Delta:差值
]]
function M.OpenCommonRewardsView(data)
    return CC.ViewManager.OpenRewardsView({items = data})
end

--[[
@param
	--param.items	奖励数组(奖励数组，参考上面方法)
	--param.title	通用奖励弹窗标题
	--param.callback	回调
	--param.tips	通用奖励弹窗Tips，用于提示玩家，例:提示玩家点卡需要去邮箱领取
	--param.gameTips	游戏内传出Tips,用于游戏显示通用奖励弹窗Tips
	--param.btnText	确定按钮改文字
	--param.splitState	是否拆分，True的话，不会合并同一个数组里相同ID的奖励
	--param.needShare 是否显示分享按钮
	--param.source	奖励源
]]
function M.OpenCommonRewardsViewEx(param)
    return CC.ViewManager.OpenRewardsView(param)
end

function M.CaptureScreenShare(param)
    CC.ViewManager.Open("CaptureScreenShareView", param)
end

--[[
-- 老虎机付费引导弹窗
]]
function M.CreateRechargeMessageBox(okFunc)
    local language = CC.LanguageManager.GetLanguage("L_SlotRechargeGuide")
    local box = CC.ViewManager.Open("MessageBoxNewStyle", language.tip1, okFunc)
    box:SetTitleText(language.title)
    box:SetOkText(language.recharge)
    box:SetCloseBtn()
    return box
end

function M.CreateRechargeOrSmallerMessageBox(okFunc, noFunc)
    local language = CC.LanguageManager.GetLanguage("L_SlotRechargeGuide")
    local box = CC.ViewManager.Open("MessageBoxNewStyle", language.tip2, okFunc, noFunc)
    box:SetTitleText(language.title)
    box:SetOkText(language.recharge)
    box:SetNoText(language.goRoom)
    return box
end

function M.CreateRechargeOrAdjustMessageBox(okFunc)
    local language = CC.LanguageManager.GetLanguage("L_SlotRechargeGuide")
    local box = CC.ViewManager.ShowMessageBox(language.tip3, okFunc)
    return box
end

--[[
--打开填写资料面板
@data:
PropId:奖励道具ID
ActiveName：活动名称
Callback:提交回调
Canclose:能否主动关闭(true or false)
]]
function M.OpenInformationView(data)
    local propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    local propData = propCfg[data.PropId]

    --获得物品信息
    local param = {}
    param.Canclose = data.Canclose or false
    param.IdendityInfo = propData.IdendityInfo
    param.PersonInfo = propData.PersonInfo
    param.Desc = propData.Description
    param.Type = propData.Type
    param.Icon = propData.Icon
    param.ActiveName = data.ActiveName
    param.commitCallback = data.Callback
    CC.ViewManager.Open("InformationView", param)
end

--[[
param.gameList = {id,id}
param.exitFunc()
param.cancelFunc()
param.gameFunc(gameId,defaultFunc)
    gameId 玩家选择游戏的id
    defaultFunc 如果是大厅通用选场界面，会跳转到相应gameId的选场界面；如果是子游戏自己有选场界面，则跳到子游戏
]]
function M.CreateExitGameTipView(param)
    if CC.ChannelMgr.GetTrailStatus() or PlayerInfoInterface.IsHasGuide() then
        CC.uu.SafeDoFunc(param.exitFunc)
    else
        return CC.ViewManager.Open("GameExitTipView", param)
    end
end

--vip界面
function M.OpenVipView()
    CC.ViewManager.Open("PersonalInfoView", {Upgrade = 1})
end

--[[
    parent -- 父节点Transform，动画非常大请放在屏幕中间
    targetScreenPoint -- 飞向的屏幕坐标，
                        可通过UnityEngine.RectTransformUtility.WorldToScreenPoint(Camera,targetPos)计算

    return view -- 动画view
]]
function M.ShowLimitTimeGiftView(parent, targetScreenPoint)
    local view
    local param = {}

    param.parent = parent
    param.targetScreenPoint = targetScreenPoint
    param.closeFunc = function()
        if view then
            view:Destroy()
            view = nil
        end

        CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshSelectGiftIcon)
    end

    view = CC.uu.CreateHallView("AchievementGiftView", param)
    return view
end

-- 游戏退出前或view父节点销毁前调用，确保礼包view已被销毁。
function M.DestroyLimitTimeGiftView(giftView)
    if giftView then
        giftView:Destroy()
        giftView = nil
    end
end

--[[
@param
wareId: 礼包WareId
parent: 父节点，礼包界面，礼包父节点销毁时需要destroy钱包
width：游戏的CavasScaler X
height：游戏的CavasScaler Y
succCb: 成功回调
]]
function M.CreateWalletView(param)
    local data = {}
    data.exchangeWareId = param.wareId
    data.parent = param.parent
    data.succCb = param.succCb
    data.width = param.width
    data.height = param.height
    local walletView = CC.uu.CreateHallView("WalletView", data)
    return walletView
end

--礼包界面销毁时调用
function M.DestroyWalletView(walletView)
    if walletView then
        walletView:Destroy()
        walletView = nil
    end
end

--退出游戏走引导
--[[
    @param:
    id:保留游戏ID，引导结束后拉回游戏选场
    cb:退出游戏fun
]]
function M.ExitToGuide(param)
    CC.uu.CreateHallView("ExitToGuideView", param)
end

--[[
@param
parent:挂载的父节点(创建后layer和父节点一致)
OpenViewId:打开标签页，左侧1、2、3页（可缺省）
closeFunc:界面关闭回调(可缺省)
]]
function M.CreateRealStoreIcon(param)
    if CC.ChannelMgr.GetTrailStatus() then
        return false
    end
    if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("TreasureView") then
        return false
    end
    return CC.RealStoreIconManager.CreateIcon(param)
end

function M.DestroyRealStoreIcon(icon)
    if CC.ChannelMgr.GetTrailStatus() then
        return false
    end
    if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("TreasureView") then
        return false
    end
    if not icon then
        return false
    end
    CC.RealStoreIconManager.DestroyIcon(icon)
end

-- ************************************************************
-- @FuncName: IsHallViewOpened    是否有已打开大厅界面
-- ************************************************************
function M.IsHallViewOpened()
    return CC.ViewManager.IsHallViewOpened()
end

return M
