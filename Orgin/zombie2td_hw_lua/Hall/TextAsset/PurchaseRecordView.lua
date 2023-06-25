--***************************************************
--文件描述: 往期购买记录
--关联主体: PurchaseRecordView.prefab
--注意事项:无
--作者:flz
--时间:2018-11-19
--***************************************************
local CC = require("CC")
local Request = require("Model/LotteryNetwork/Request")
local BaseRecordView = require("View/LotteryView/BaseRecordView")
local PurchaseRecordView = CC.uu.ClassView("PurchaseRecordView",nil,BaseRecordView)
local LotteryProto = require("Model/LotteryNetwork/game_message_pb")

local _InitVar

function PurchaseRecordView:ctor(param)
    _InitVar(self,param)
end

--@SuperType
function PurchaseRecordView:InitData(  )
    self.super:InitData()
    --初始化浮标
    self.nStartIndex = self.config and self.config.StartIndex or 0 -- 起始index
    self.nCapacity = self.config and self.config.Capacity or 30 -- 页面容量
    self.nEndIndex = self.config and self.config.EndIndex or (self.nStartIndex + self.nCapacity - 1) -- 结束index
    self.isPurchaseRecord = true
end

--@SuperType
function PurchaseRecordView:InitLanguage()
    local language = self.mainView.language
    -- title
    local title = self:SubGet("Title/Text","Text")
    title.text = language.MyPurchaseRecord
    -- top
    local topIssue = self:SubGet("Frame/Top/Issue","Text")
    topIssue.text = language.LotteryIssue
    local topStatus = self:SubGet("Frame/Top/Status","Text")
    topStatus.text = language.LotteryState
    local topNum = self:SubGet("Frame/Top/Num","Text")
    topNum.text = language.LotteryNum

    local emptyTip = self.emptyObj:SubGet("Text","Text")
    emptyTip.text = language.RecordEmpty
    
    local itemNoLottery = self.item:SubGet("Status/NoLottery","Text")
    itemNoLottery.text = language.NoLottery

end

--@SuperType
function PurchaseRecordView:FillItem(v )
    local tdata = v
    local itemName = "item" .. tdata.szIssue
    local itemPrefab = self:AddPrefab(self.item, self.itemParent,itemName)
    local sequence = itemPrefab:SubGet("Sequence","Text")
    local number = itemPrefab:SubGet("Number","Text") -- 彩票号
    local moreBtn = itemPrefab:FindChild("MoreBtn") -- 更多
    local lotteryNum = tdata.szLotteryNumber

    if tdata.nLotteryState == 1 then
        if tdata.enType == LotteryProto.en_reward_type_invalid then -- 未中奖
            itemPrefab:FindChild("Status/Lose"):SetActive(true)
        elseif tdata.enType == LotteryProto.en_reward_type_firstPrize then -- 头奖
            lotteryNum = self.viewCtr:GetHitNumStr(tdata.szLotteryNumber,tdata.arrHitNumFlag , "0EFF2A")--头奖
            itemPrefab:FindChild("Status/LuckyBoy"):SetActive(true)
        else
            lotteryNum = self.viewCtr:GetHitNumStr(tdata.szLotteryNumber,tdata.arrHitNumFlag , "FFF900")--中奖
            itemPrefab:FindChild("Status/Win"):SetActive(true)
        end
    else
        itemPrefab:FindChild("Status/NoLottery"):SetActive(true)
    end
    
    number.text =  lotteryNum
    sequence.text = tdata.szIssue
    itemPrefab:SetActive(true)

    self:AddClick(moreBtn,function (  )
        self:OpenMoreNumView(tdata.szIssue)
    end)
end

function PurchaseRecordView:OpenMoreNumView(param)
    -- CC.ViewManager:Open("MyPurchaseNumView",{mainView = self.mainView , purchaseList = param})
    log("PurchaseRecordView:OpenMoreNumView")
    CC.ViewManager.Open("MyPurchaseNumView",{mainView = self.mainView , szIssue = param})
end

--@region 数据model
function PurchaseRecordView:Query(  )
    self:LoadingCtr()
    Request.LotteryPurchaseRecodeReq(self.nCapacity,self.nStartIndex,self.nEndIndex)
end

function PurchaseRecordView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.Refresh,CC.Notifications.PurchaseRecord)
end

function PurchaseRecordView:UnRegisterEvent(  )
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.PurchaseRecord)
end
--@endregion

_InitVar = function(self,param)
    self.mainView = param.mainView
    self.config = self.mainView.lotteryData.LotteryConfig.PurchaseRecord
end

return PurchaseRecordView