--***************************************************
--文件描述: 展现某一期玩家自己购买的全部号码
--关联主体: MyPurchaseNumView.prefab
--注意事项:无
--作者:flz
--时间: 2018-11-21
--***************************************************
local CC = require("CC")
local LotteryProto = require("Model/LotteryNetwork/game_message_pb")
local Request = require("Model/LotteryNetwork/Request")
local BaseRecordView = require("View/LotteryView/BaseRecordView")
local MyPurchaseNumView = CC.uu.ClassView("MyPurchaseNumView",nil,BaseRecordView)

local _InitVar

function MyPurchaseNumView:ctor(param)
    _InitVar(self,param)
end

--@SuperType
function MyPurchaseNumView:InitData(  )
    --小检查
    if self.szIssue == nil then
        logError("彩票期号为空!")
        self:ActionOut()
    end
    self.super:InitData()
    --初始化浮标
    self.nStartIndex = self.config and self.config.StartIndex or 0 -- 起始index
    self.nCapacity = self.config and self.config.Capacity or 30 -- 页面容量
    self.nEndIndex = self.config and self.config.EndIndex or (self.nStartIndex + self.nCapacity - 1) -- 结束index
    self.isNumView = true
end

-- function MyPurchaseNumView:InitUI(  )
--     log("MyPurchaseNumView:InitUI" .. " 参数:self.className  值:" .. tostring( self.className))
--     self.super:InitUI() -- 会破坏调用链,谨慎使用
-- end

function MyPurchaseNumView:InitOther()
    if self.fromMainView then
        local mask = self:SubGet("Mask","Image")
        mask.color = Color(0,0,0,0.9)
    end
end

--@SuperType
function MyPurchaseNumView:InitLanguage()
    local language = self.mainView.language
    -- title
    local title = self:SubGet("Title/Text","Text")
    title.text = language.MyPurchaseDetail
    
    local emptyTip = self.emptyObj:SubGet("Text","Text")
    emptyTip.text = language.RecordEmpty

end

--@SuperType
function MyPurchaseNumView:FillItem(v )
    local tdata = v
    local itemName = "item" .. tdata.szLotteryNumber
    local itemPrefab = self:AddPrefab(self.item, self.itemParent,itemName)
    local number = itemPrefab:SubGet("Text","Text") -- 彩票号
    local number1 = itemPrefab:SubGet("Corner/Text","Text") -- 数量
    local lotteryNum = tdata.szLotteryNumber 
    if tdata.nLotteryState == 1 then
        if tdata.enType == LotteryProto.en_reward_type_firstPrize then
            lotteryNum = self.viewCtr:GetHitNumStr(tdata.szLotteryNumber,tdata.arrHitNumFlag , "0EFF2A")--头奖
        elseif tdata.enType ~= LotteryProto.en_reward_type_invalid then
            lotteryNum = self.viewCtr:GetHitNumStr(tdata.szLotteryNumber,tdata.arrHitNumFlag , "FFF900")--中奖
        end
    end
    
    itemPrefab:SetActive(true)
    number.text =  lotteryNum
    number1.text = tdata.nPurchaseNum
end

--@region 数据model
function MyPurchaseNumView:Query(  )
    self:LoadingCtr()
    Request.LotteryDetailRecodeReq( self.szIssue ,self.nCapacity ,self.nStartIndex,self.nEndIndex )
end
function MyPurchaseNumView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.Refresh,CC.Notifications.PurchaseDetail)
end

function MyPurchaseNumView:UnRegisterEvent(  )
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.PurchaseDetail)
end
--@endregion

_InitVar = function(self,param)
    self.mainView = param.mainView
    self.szIssue = param.szIssue
    self.config = self.mainView.lotteryData.LotteryConfig.PurchaseNum
    self.fromMainView = param.fromMainView
end

return MyPurchaseNumView