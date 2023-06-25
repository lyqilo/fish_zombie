--***************************************************
--文件描述: 往期中奖纪录
--关联主体: BetDetailView.prefab
--注意事项:无
--作者:flz
--时间:2018-11-19
--***************************************************
local CC = require("CC")
local Request = require("Model/LotteryNetwork/Request")
local BaseRecordView = require("View/LotteryView/BaseRecordView")
local BetDetailView = CC.uu.ClassView("BetDetailView",nil,BaseRecordView)

local _InitVar

function BetDetailView:ctor(param)
    _InitVar(self,param)
end

--@SuperType
function BetDetailView:InitData(  )
    self.super:InitData()
    --初始化浮标
    self.nStartIndex = self.config and self.config.StartIndex or 0 -- 起始index
    self.nCapacity = self.config and self.config.Capacity or 30 -- 页面容量
    self.nEndIndex = self.config and self.config.EndIndex or (self.nStartIndex + self.nCapacity - 1) -- 结束index
    self.isBetDetail = true
end

--@SuperType
function BetDetailView:InitLanguage()
    local language = self.mainView.language
    -- title
    local title = self:SubGet("Title/Text","Text")
    title.text = language.PastLottery
    -- top
    local topPlayer = self:SubGet("Frame/Top/Player","Text")
    topPlayer.text = language.JackpotMan
    local topNum = self:SubGet("Frame/Top/Bet","Text")
    topNum.text = language.PurchaseNum

    local emptyTip = self.emptyObj:SubGet("Text","Text")
    emptyTip.text = language.RecordEmpty

end

--@SuperType
function BetDetailView:FillItem(v )
    local lotteryData = v.stLotteryInfo
    local playerData = v.stPlayerInfo
    local itemName = "item" .. lotteryData.szIssue
    local itemPrefab = self:AddPrefab(self.item, self.itemParent,itemName)
    local betNum = itemPrefab:FindChild("Bet") -- 下注数量
    local playerHead = itemPrefab:FindChild("Player/Head")-- ,"Image")
    local playerName = itemPrefab:SubGet("Player/Name","Text")

    itemPrefab:SetActive(true)
    CC.HeadManager.CreateHeadIcon({parent = playerHead,portrait =playerData.szPortrait,
    playerId = playerData.dwPlayerID, vipLevel =playerData.nVipLevel, clickFunc = "unClick"})
    playerName.text = playerData.szNickName
    betNum:GetComponent("Text").text = lotteryData.nPurchaseNum or 0
end

--@region 数据model
function BetDetailView:Query(  )
    self:LoadingCtr()
    Request.FirstPrizeRecodeReq(self.szIssue,self.nCapacity,self.nStartIndex,self.nEndIndex)
end

function BetDetailView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.Refresh,CC.Notifications.FirstPrizeRecodeRsp)
end

function BetDetailView:UnRegisterEvent(  )
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.FirstPrizeRecodeRsp)
end

--@endregion

_InitVar = function(self,param)
    self.mainView = param.mainView
    self.szIssue = param.szIssue
    self.config = self.mainView.lotteryData.LotteryConfig.BetDetail
end

return BetDetailView