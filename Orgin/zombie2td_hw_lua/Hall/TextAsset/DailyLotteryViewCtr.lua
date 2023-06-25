---------------------------------
-- region DailyLotteryViewCtr.lua
-- Date: 2020-06-17 14:21
-- Desc: 每日抽奖Control类
-- Author: GuoChaoWen
---------------------------------

local CC = require("CC")
local DailyLotteryViewCtr = CC.class2("DailyLotteryViewCtr")

function DailyLotteryViewCtr:ctor(view, param)
    self:InitVar(view, param)
end

function DailyLotteryViewCtr:OnCreate()
    self:RegisterEvent()
    --self:OnRefreshOnlineTime()
    self:OnReqGetDailyLotteryInfo()
    -- self:OnReqActivityMsg()
    self:OnReqLotteryRankInfo()
end

function DailyLotteryViewCtr:InitVar(view, param)
    self.view = view
    self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
end

-- 打开任务引导界面
function DailyLotteryViewCtr:OnOpenTaskGuideView(bOnlineFinish,bShareFinish)
    local param = {}
    param.bOnlineFinish = bOnlineFinish
    param.bShareFinish = bShareFinish
    CC.ViewManager.Open("DailyLotteryTaskGuideView",param)
end

-- 打开规则界面
function DailyLotteryViewCtr:OnOpenRuleView()
    CC.ViewManager.Open("DailyLotteryRuleView")
end

-- 打开新手礼包界面
function DailyLotteryViewCtr:OnOpenStoreView()
	local switchOn = self.activityDataMgr.GetActivityInfoByKey("NoviceGiftView").switchOn;
	if switchOn and CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, false)
        local param = {}
        param.currentView = "NoviceGiftView"
        param.closeFunc = function()
            CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, true)
        end
        CC.ViewManager.Open("SelectGiftCollectionView",param)
	else
		CC.ViewManager.Open("StoreView");
	end
end

--新年祈福道具，打开祝福
function DailyLotteryViewCtr:OnBlessSearchView()
    --CC.ViewManager.Open("BlessSearchView");
end

function DailyLotteryViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnDailyLotteryInfoResp,CC.Notifications.NW_ReqGetDailyLotteryInfo)
    CC.HallNotificationCenter.inst():register(self,self.OnLotteryResp,CC.Notifications.NW_ReqLottery)
    CC.HallNotificationCenter.inst():register(self,self.OnAddLotteryResp,CC.Notifications.NW_ReqAddLotteryTimes)
    CC.HallNotificationCenter.inst():register(self,self.OnLotteryRankInfoResp,CC.Notifications.NW_ReqLotteryRankInfo)
    -- 抽奖不读服务端的推送，改成读本地配置表
    -- CC.HallNotificationCenter.inst():register(self,self.OnLotteryAwardResp,CC.Notifications.OnDailyLotteryReward)
    -- CC.HallNotificationCenter.inst():register(self,self.OnLotteryBroadResp,CC.Notifications.OnPushActivityMsg)
    CC.HallNotificationCenter.inst():register(self,self.OnVIPLevelUp,CC.Notifications.VipChanged)
end

function DailyLotteryViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

-- 刷新在线时长
function DailyLotteryViewCtr:OnRefreshOnlineTime()
    CC.Request("ReqSynOnlineTime");
end

function DailyLotteryViewCtr:OnReqGetDailyLotteryInfo()
    local playerId=CC.Player.Inst():GetSelfInfoByKey("Id")
    CC.Request("ReqGetDailyLotteryInfo",{PlayerID = playerId})
end

-- 请求摇奖
function DailyLotteryViewCtr:OnReqLottery()
    local playerId = CC.Player.Inst():GetLoginInfo().PlayerId
    CC.Request("ReqLottery",{PlayerID=playerId})
end

-- 请求增加次数
function DailyLotteryViewCtr:OnReqAddLotteryTimes()
	local playerId = CC.Player.Inst():GetLoginInfo().PlayerId
    CC.Request("ReqAddLotteryTimes",{PlayerID=playerId})
end

-- 请求文字滚动播报
-- function DailyLotteryViewCtr:OnReqActivityMsg()
-- 	CC.Request.ReqActivityMsg()
-- end

-- 请求排行榜数据
function DailyLotteryViewCtr:OnReqLotteryRankInfo()
    CC.Request("ReqLotteryRankInfo")
end

-- 返回每日抽奖奖励配置信息
function DailyLotteryViewCtr:OnDailyLotteryInfoResp(err, result)
    if err == 0 then
        self.view:RefreshLotteryInfo(result)
    else
        self:OnShowErrorTips(err)
    end
end

-- 返回请求摇奖结果
function DailyLotteryViewCtr:OnLotteryResp(err, result)
    log(CC.uu.Dump(result, "LotteryResult"))
    if err == 0 then
        self:SetCanClick(false)
        self.view:ReadyLottery(result)
    else
        self:OnShowErrorTips(err)
    end
end

-- 返回增加摇奖次数
function DailyLotteryViewCtr:OnAddLotteryResp(err, result)
    if err == 0 then
        self:OnReqGetDailyLotteryInfo()
    else
        self:OnShowErrorTips(err)
    end
end

-- 返回排行榜数据
function DailyLotteryViewCtr:OnLotteryRankInfoResp(err, result)
    if err == 0 then
        self.view:RefreshLotteryRankInfo(result.AwardRanks)
    else
        self:OnShowErrorTips(err)
    end
end

-- VIP等级升级，也是重新请求次数
function DailyLotteryViewCtr:OnVIPLevelUp(level)
    self:OnReqGetDailyLotteryInfo()
end

-- 抽奖奖励回调
-- 抽奖不读服务端的推送，改成读本地配置表
function DailyLotteryViewCtr:OnLotteryAwardResp(data)
    -- self.view:SetRewardData(data)
end

-- 跑马灯播报
function DailyLotteryViewCtr:OnLotteryBroadResp(data)
    -- self.DailyLotteryDataMgr.InsertScrollData(data.Msg)
end

function DailyLotteryViewCtr:SetCanClick(flag)
	self.view:SetCanClick(flag)
	CC.HallNotificationCenter.inst():post(CC.Notifications.FreeChipsCollectionClickState, flag)
end

function DailyLotteryViewCtr:OnShowErrorTips(err)
    if err == 0 then return end
	if err == -1 then
		local tips = CC.LanguageManager.GetLanguage("L_Common").tip9
		CC.ViewManager.ShowTip(tips)
	end
end

function DailyLotteryViewCtr:OnDestroy()
    self:UnRegisterEvent()
end

return DailyLotteryViewCtr