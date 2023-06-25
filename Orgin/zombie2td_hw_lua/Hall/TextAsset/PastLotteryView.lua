--***************************************************
--文件描述: 往期中奖纪录
--关联主体: PastLotteryView.prefab
--注意事项:无
--作者:flz
--时间:2018-11-19
--***************************************************
local CC = require("CC")
local Request = require("Model/LotteryNetwork/Request")
local BaseRecordView = require("View/LotteryView/BaseRecordView")
local PastLotteryView = CC.uu.ClassView("PastLotteryView",nil,BaseRecordView)

local _InitVar

function PastLotteryView:ctor(param)
    _InitVar(self,param)
end

--@SuperType
function PastLotteryView:InitData(  )
    self.super:InitData()
    --初始化浮标
    self.nStartIndex = self.config and self.config.StartIndex or 0 -- 起始index
    self.nCapacity = self.config and self.config.Capacity or 30 -- 页面容量
    self.nEndIndex = self.config and self.config.EndIndex or (self.nStartIndex + self.nCapacity - 1) -- 结束index
    self.isPastLottery = true
end

--@SuperType
function PastLotteryView:InitLanguage()
    local language = self.mainView.language
    -- title
    local title = self:SubGet("Title/Text","Text")
    title.text = language.PastLottery
    -- top
    local topIssue = self:SubGet("Frame/Top/Issue","Text")
    topIssue.text = language.LotteryIssue
    local topPlayer = self:SubGet("Frame/Top/Player","Text")
    topPlayer.text = language.JackpotMan
    local topNum = self:SubGet("Frame/Top/Num","Text")
    topNum.text = language.JackpotNum
    local betNum = self:SubGet("Frame/Top/Bet","Text")
    betNum.text = language.PurchaseNum

    local emptyTip = self.emptyObj:SubGet("Text","Text")
    emptyTip.text = language.RecordEmpty

end

--@SuperType
function PastLotteryView:FillItem(v )
    local playerData = v.stPlayerInfo
    local itemName = "item" .. v.stLotteryInfo.szIssue
    local itemPrefab = self:AddPrefab(self.item, self.itemParent,itemName)
    local playerNode =  itemPrefab:FindChild("Player")
    local sequence = itemPrefab:SubGet("Sequence/Text","Text")
    local moreBtn = itemPrefab:FindChild("Sequence/Image")
    local number = itemPrefab:SubGet("Number","Text") -- 彩票号
    local betNum = itemPrefab:FindChild("Bet") -- 下注数量

    itemPrefab:SetActive(true)
    sequence.text = v.stLotteryInfo.szIssue
    number.text =  v.stLotteryInfo.szLotteryNumber

    if v.stLotteryInfo.dwPlayerID > 0 then -- 如果有玩家Id >0说明有人购买了
        local playerHead = itemPrefab:FindChild("Player/Head")-- ,"Image")
        local playerName = itemPrefab:SubGet("Player/Name","Text")
        CC.HeadManager.CreateHeadIcon({parent = playerHead,portrait =playerData.szPortrait,playerId = playerData.dwPlayerID, vipLevel =playerData.nVipLevel, clickFunc = "unClick"})
        playerName.text = playerData.szNickName
        betNum:GetComponent("Text").text = v.stLotteryInfo.nPurchaseNum

    else
        betNum:SetActive(false)
        playerNode:SetActive(false)
        -- 显示奖金累计到奖池
        local toJackpot = itemPrefab:FindChild("toJackpot")-- ,"Image")
        -- local banLine = itemPrefab:FindChild("Number/BanLine")
        toJackpot:SetActive(true)
        toJackpot.text = self.mainView.language.ToJockpot
        -- banLine:SetActive(true)
    end
    self:AddClick(moreBtn,function (  )
        self:OpenBetDetailView(v.stLotteryInfo.szIssue)
    end)
end

function PastLotteryView:OpenBetDetailView(param)
    CC.ViewManager.Open("BetDetailView",{mainView = self.mainView , szIssue = param})
end

--@region 数据model
function PastLotteryView:Query(  )
    self:LoadingCtr()
    Request.LotteryHistoryRecodeReq(self.nCapacity,self.nStartIndex,self.nEndIndex)
end

function PastLotteryView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.Refresh,CC.Notifications.PastLotteryRecord)
end

function PastLotteryView:UnRegisterEvent(  )
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.PastLotteryRecord)
end

--@endregion

_InitVar = function(self,param)
    self.mainView = param.mainView
    self.config = self.mainView.lotteryData.LotteryConfig.PastLottery
end

return PastLotteryView