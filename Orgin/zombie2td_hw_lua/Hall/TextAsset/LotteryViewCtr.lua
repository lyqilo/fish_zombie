local CC = require("CC")
local NetworkManager = require("Model/LotteryNetwork/NetworkManager")
local LotteryViewCtr = CC.class2("LotteryViewCtr")
local Request = require("Model/LotteryNetwork/Request")
local LotteryProto = require "Model/LotteryNetwork/game_message_pb"
local language = CC.LanguageManager.GetLanguage("L_LotteryView")
local ErrorText = CC.LanguageManager.GetLanguage("L_ErrorText")
local _InitVar
local _InitData
local _RegisterEvent
local _UnRegisterEvent
local _StartNetwork
local _OnNetworkOpen
local _OnNetworkClose
local _OnPushGameInfo
local _OnPushPropChange
local _OnPushOpenReward
local _OnPushRandSelection
local _OnPushLoginWithTokenRsp
local _OnPushPurchaseLotteryRsp
local _OnPushRewardPoolDataChangeNtf
local _OnPushLotteryLatternNtf
local _OnPushOpenRewardNtf
local _OnPushPingRsp

local errorDes={
	errorText1001 = language.Error_MoneyNotEnough,
	errorText1002 = language.Error_Purchase_Failed,
    errorText1003 = nil,
    errorText109 = language.Error_MoneyNotEnough,
	errorText1004 = language.Error_Player_NotExist,
	errorText1005 = language.Error_Net_Server,
	errorText1006 = language.Error_Lottery_Price_Illegal,
	errorText1007 = language.Error_Lottery_Sold_Out,
	errorText1008 = language.Error_Lottery_SoldAlready,
	errorText1009 = language.Error_Lottery_BookingAlready,
	errorText1010 = language.Error_Lottery_Index_Illegal,
	errorText1011 = language.Error_Lottery_Capacity_Illegal,
    errorText1012 = language.Error_Lottery_Issue_Illegal,
    errorText1014 = language.Error_Lottery_Data_ReadyIng
}
function LotteryViewCtr:ctor(view, param)
	_InitVar(self, view, param)
end

function LotteryViewCtr:OnCreate()
    _InitData(self)
    _RegisterEvent(self)
    _StartNetwork(self)
end

function LotteryViewCtr:Destroy()
    NetworkManager.Stop()

	_UnRegisterEvent(self)

	self.view = nil
end

function LotteryViewCtr:RandSelection()
    if self.view then
        CC.Sound.PlayHallEffect("lotteryZhuanDong")
        self.view:DelayRun(0.4, Request.RandLotteryNumberReq)
    end
end

function LotteryViewCtr:BuyLotteryMore(from,to,count,interval)
    local num = from-1
    local func 
    func = function()
        for i=1,count do
            num = num+1
            if num < to then
                if num >= 0 and num < 10^6 then
                    Request.PurchaseLotteryReq(string.format("%06d",num),self.GameInfo.lPrice,self.betNumber)
                end
            end
        end
        if num < to then
            self.view:DelayRun(interval,func)
        end
    end
    func()
end

function LotteryViewCtr:BuyLottery()
    if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") >= 200000 then
        if self.GameInfo then
            Request.PurchaseLotteryReq(self.InputNumber,self.GameInfo.lPrice,self.betNumber)
        end
    else
        local GetMoreMoney = function ()
            if CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
                CC.ViewManager.OpenEx("SelectGiftCollectionView")
            else
                CC.ViewManager.Open("StoreView")
            end
        end
        local box = CC.ViewManager.ShowConfirmBox(language.Lottery_tip,GetMoreMoney)
        self.view:SetBuyBtnState(true)
    end
end

function LotteryViewCtr:SetInputNumber(num)
    self.InputNumber=num
end

function LotteryViewCtr:SetBetNumber(num)
    self.betNumber=num
end

function LotteryViewCtr:GetBetNumber(num)
    return self.betNumber
end

function LotteryViewCtr:SetPrice(num)
    self.GameInfo.lPrice = num
end

function LotteryViewCtr:GetPrice()
    return (self.GameInfo.lPrice or 1 ) * self.betNumber
end

function LotteryViewCtr:LotteryHistoryRecode()
    Request.LotteryHistoryRecodeReq(30 ,0, 29)
end

function LotteryViewCtr:LotteryLatternReq()
    Request.LotteryLatternReq()
end

function LotteryViewCtr:ShowErrorTip(error)
    local k="errorText"..error
    local str= errorDes[k] or ErrorText[k]
    if str then
        CC.ViewManager.ShowTip(str)
    end

    if error == LotteryProto.Error_MoneyNotEnough or error == 109  then
        -- CC.SubGameInterface.CheckRelief(CC.SubGameInterface.GetHallMoney(),function() CC.ViewManager.Open("StoreView") end)
        self:ReliefInfo()
    end
end

function LotteryViewCtr:CheckCoinEnough( noRelif )
    local curMoney = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
    if curMoney >= self:GetPrice() then
        return true
    else
        if not noRelif then
            self:ReliefInfo()
        end
        return false
    end
end

function LotteryViewCtr:ReliefInfo()
    local curMoney = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
    if CC.Player.Inst():GetThreshold() <= curMoney or CC.Player.Inst():GetLeftTimes() < 1 then 
        self:OpenShop()
        return 
    end
    -- log("救济金 请求领取GetReliefInfo")
    CC.Request("GetReliefInfo",nil,function (err,data)
        if data.LeftTimes > 0 and CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") < data.Threshold then
            local param = {}
            param.Type = data.Type
            param.UnderAmount = data.Threshold
            param.Amount = data.Amount
            param.Type = data.Type
            param.LeftTimes = data.LeftTimes
            CC.ViewManager.Open("BenefitsView",param)
        end
    end,
    function (err,data)
        log("拉取救济金失败:"..err)
        self:OpenShop()
    end)


end

function LotteryViewCtr:OpenShop()
    CC.ViewManager.ShowMessageBox(language.DIA_GO_SHOP,function() 
        CC.ViewManager.Open("StoreView")
    end)
end
-- 统一用游戏服数据
-- function LotteryViewCtr:RefreshChips(  )
--     self.view:OnCoinChange(CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa"))
-- end

_InitVar = function(self, view, param)
    self.view = view
    self.serverIp = param and param.serverIp  
    self.pingTimer = "lotteryPingTimer"
end

_InitData = function(self)
    self.view:InitContent()
    self.GameInfo={}
    self.InputNumber = " "
    self.rAnimData = nil
    self.betNumber = 1
end

_OnPushGameInfo = function(self,data)
    self.GameInfo=data
    self.view:OnChangeGameInfo(data)
end
_OnPushPropChange = function(self,data)
    for _,item in ipairs(data.Props) do
        local propData = {
            Items = {
                {
                    ConfigId = item.PropId,
                    Count = item.Count,
                    Delta = item.Delta
                }
            }
        }
        CC.Player.Inst():ChangeProp(propData);
    -- logError("改变大厅道具:"..id.. " 数量为:"..count);
    end
    if self.view then
        self.view:OnCoinChange(CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa"))
        self.view:UpdateButtonStatus()
    end
end

_OnPushRandSelection = function(self,data)
    if data.errorCode ~= 0 then 
        if data.errorCode == LotteryProto.Error_MoneyNotEnough 
        or data.errorCode == 109
        or data.errorCode == LotteryProto.Error_Lottery_GameStage_Illeagal then
            self:ShowErrorTip(data.errorCode)
        else
            self.view:DelayRun(1, 
            function(  )
                self:RandSelection()
            end
            )
        end
    else
        self.view:OnRandSelection(data)
    end
end
_OnPushLoginWithTokenRsp = function(self,data)
    if data.errorCode ~= 0 then
        self:ShowErrorTip(data.errorCode)
        CC.ViewManager.ShowConfirmBox(language.NETWORK_CLOSE,function() 
            self.view:Destroy()
        end)
    else
        self.view:StartTimer(self.pingTimer, 5, function() Request.LotteryPingReq(0) end, -1)
    end 
end
_OnPushPurchaseLotteryRsp = function(self,data)
    if data.errorCode == 0 then 
		CC.Sound.PlayHallEffect("lotteryBuySuc")
        self.view:OnBuyLottery(data) 

        self.GameInfo.nOwnLotteryNum = self.GameInfo.nOwnLotteryNum + data.lotteryInfo.nPurchaseNum
        self.view:OnPurchasedNum(self.GameInfo.nOwnLotteryNum,true)
    else
		CC.Sound.PlayHallEffect("lotteryBuyFailed")
        self:ShowErrorTip(data.errorCode)
    end
end
_OnPushRewardPoolDataChangeNtf = function(self,data)
    if self.view then
        self.view:OnPoolDataChange(data.lShowMoney,data.lDelta) 
    end
end

_OnPushLotteryLatternNtf = function(self,data  )
    if self.view then
        self.view:LotteryLatternNtf(data) 
    end
end

_OnPushOpenRewardNtf = function(self,data  )
    if self.view then
        if data and data.nIsHitReward > 0 then
            self.rAnimData = data
            self.view:UpdateRewardAnim() 
        else
            self.rAnimData = nil
        end
    end
end

_OnPushPingRsp = function(self,data)
    if data.errorCode ~= 0 then
        CC.ViewManager.ShowConfirmBox(language.NETWORK_CLOSE,function() self.view:Destroy() end)
    end
end

_RegisterEvent = function(self)
    CC.HallNotificationCenter.inst():register(self,_OnNetworkOpen,CC.Notifications.LotteryNetworkOpen)
    CC.HallNotificationCenter.inst():register(self,_OnNetworkClose,CC.Notifications.LotteryNetworkClose)

    CC.HallNotificationCenter.inst():register(self,_OnPushGameInfo,CC.Notifications.LotteryGameInfo)
    CC.HallNotificationCenter.inst():register(self,_OnPushPropChange,CC.Notifications.LotteryPropChange)

    CC.HallNotificationCenter.inst():register(self,_OnPushRandSelection,CC.Notifications.RandLotteryNumberRsp)
    CC.HallNotificationCenter.inst():register(self,_OnPushLoginWithTokenRsp,CC.Notifications.LoginWithTokenRsp)
    CC.HallNotificationCenter.inst():register(self,_OnPushPurchaseLotteryRsp,CC.Notifications.PurchaseLotteryRsp)
    CC.HallNotificationCenter.inst():register(self,_OnPushRewardPoolDataChangeNtf,CC.Notifications.RewardPoolDataChangeNtf)
	CC.HallNotificationCenter.inst():register(self,_OnPushLotteryLatternNtf, CC.Notifications.LotteryLatternNtf)
	CC.HallNotificationCenter.inst():register(self, _OnPushOpenRewardNtf, CC.Notifications.OpenRewardNtf)
    CC.HallNotificationCenter.inst():register(self, _OnPushPingRsp, CC.Notifications.LotteryPingRsp)
end

_UnRegisterEvent = function(self)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.LotteryNetworkOpen)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.LotteryNetworkClose)

    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.LotteryGameInfo)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.LotteryPropChange)

    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.RandLotteryNumberRsp)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.LoginWithTokenRsp)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.PurchaseLotteryRsp)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.RewardPoolDataChangeNtf)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.LotteryLatternNtf)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OpenRewardNtf)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.LotteryPingRsp)
end




_StartNetwork = function(self)
    local data = {
        serverIp =self.serverIp or "172.12.10.230:10111"
    }
    NetworkManager.Start(data)
end

_OnNetworkOpen = function(self)
    -- 临时放这里，应该是监听pushGameInfo的
    local taken = CC.GC.Player.Inst():GetLoginInfo()
    Request.LoginWithToken(taken.PlayerId,tostring(taken.Token))
end

_OnNetworkClose = function(self)
    CC.ViewManager.ShowConfirmBox(language.NETWORK_CLOSE,function() self.view:Destroy() end)
end

return LotteryViewCtr