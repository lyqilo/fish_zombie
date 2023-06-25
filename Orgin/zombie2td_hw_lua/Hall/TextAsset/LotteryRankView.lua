--***************************************************
--文件描述: 排行榜界面
--关联主体: LotteryRankView.prefab
--注意事项:无
--作者:flz
--时间:2018-03-11
--***************************************************
local CC = require("CC")
local Request = require("Model/LotteryNetwork/Request")
local BaseRecordView = require("View/LotteryView/BaseRecordView")
local LotteryRankView = CC.uu.ClassView("LotteryRankView",nil,BaseRecordView)
local LotteryProto = require("Model/LotteryNetwork/game_message_pb")

local _InitVar

function LotteryRankView:ctor(param)
    _InitVar(self,param)
end

--@SuperType
function LotteryRankView:InitData(  )
    self.super:InitData()
    --初始化浮标
    self.nStartIndex = self.config and self.config.StartIndex or 0 -- 起始index
    self.nCapacity = self.config and self.config.Capacity or 10 -- 页面容量
    self.nEndIndex = self.config and self.config.EndIndex or (self.nStartIndex + self.nCapacity - 1) -- 结束index
    self.IconTab = {}
    self.isRankView = true
    self.sequenceNum = 1
end

--@SuperType
function LotteryRankView:InitLanguage()
    local language = self.mainView.language
    -- title
    local title = self:SubGet("Title/Text","Text")
    title.text = language.RankList
    local title1 = self:SubGet("Title/Text (1)","Text")
    title1.text = language.TitleTop

    local myRank = self:SubGet("Frame/MyRank/Sequence","Text")
    myRank.text = language.MyRank

    local emptyTip = self.emptyObj:SubGet("Text","Text")
    emptyTip.text = language.RecordEmpty
end

--@SuperType
function LotteryRankView:FillItem(v ,myRank,myReward)
    local sequenceNum = self.sequenceNum

    local playerData = v.stPlayerInfo
    local itemName = "item" .. sequenceNum -- 以关键信息命名调试方便
    local itemPrefab = self:AddPrefab(self.item, self.itemParent,itemName)
    local sequence = itemPrefab:SubGet("Sequence/Num","Text")
    local sequenceImg = itemPrefab:SubGet("Sequence/Image","Image") --前三名会有特殊头像
    local number = itemPrefab:SubGet("Number","Text") -- 中奖总数量
    local playerNode =  itemPrefab:FindChild("Player")
    local myBg = itemPrefab:FindChild("Bg/MyBg")

    -- 头像相关
    local playerHead = itemPrefab:FindChild("Player/Head")-- ,"Image")
    local playerName = itemPrefab:SubGet("Player/NameMask/Name","Text")
    self.IconTab[sequenceNum] = CC.HeadManager.CreateHeadIcon({parent = playerHead,portrait =playerData.szPortrait,playerId = playerData.dwPlayerID, vipLevel =playerData.nVipLevel, clickFunc = "unClick"})
    playerName.text = playerData.szNickName
    -- 排行
    if sequenceNum <= 3 then
        sequence.transform:SetActive(false)
        sequenceImg.transform:SetActive(true)

        self:SetImage(itemPrefab:FindChild("Sequence/Image"),"cp_phbicon_" .. sequenceNum);
    else
        sequence.transform:SetActive(true)
        sequenceImg.transform:SetActive(false)
        sequence.text = sequenceNum
    end
    
    if string.len(v.lHitRewardNum) > 9 then
        number.text = CC.uu.ChipFormat(v.lHitRewardNum)
    else
        number.text = CC.uu.numberToStrWithComma(v.lHitRewardNum)
    end

    if myRank >= 0 and self.sequenceNum == 1 then
        local myRankNode = self.frame:GetChild(1)
        local tRank = myRankNode:FindChild("Sequence/Num")
        local tReward = myRankNode:FindChild("Number")
        local tBet =  myRankNode:FindChild("Bet")
        tRank.text = myRank
        if string.len(myReward) > 9 then
            tReward.text = CC.uu.ChipFormat(myReward)
        else
            tReward.text = CC.uu.numberToStrWithComma(myReward)
        end
        
        if myRank == 0 then -- 如果没有上榜,移除筹码显示
            tReward:SetActive(false)
            tBet:SetActive(false)
        end
    end
    
    if myRank == self.sequenceNum then
        myBg:SetActive(true)
    end
    -- 
    self.sequenceNum = self.sequenceNum + 1 
    itemPrefab:SetActive(true)

end

function LotteryRankView:ActionOut(  )
	self:SetCanClick(false);
    for i=1,4 do
        local tnode = self.transform:GetChild(i)
        self:RunAction(tnode, {"localMoveBy", 755, 0, 0.3, function() -- MoveTo是目标移动,传入的是目的位置的坐标 MoveBy:增加提供的坐标到游戏对象的位置。
            if i == 4 then
                self:DestroyHeadIcon();
                self:Destroy();
            end
        end,ease=CC.Action.EOutSine})
    end
end

function LotteryRankView:ActionIn(  )
    self:SetCanClick(false);
    for i=1,4 do
        local tnode = self.transform:GetChild(i)
        self:RunAction(tnode, {"localMoveBy", -755, 0, 0.5,function()
            if i == 4 then
                self:SetCanClick(true);
            end
        end,ease=CC.Action.EOutSine})
    end
end

function LotteryRankView:DestroyHeadIcon(  )
    log("LotteryRankView:OnDestroy")
    for k,v in pairs(self.IconTab) do
        if v then
			v:Destroy()
			v = nil
		end
    end
end

--@region 数据model
function LotteryRankView:Query(  )
    self:LoadingCtr()
    Request.LotteryRankListReq(self.nCapacity,self.nStartIndex,self.nEndIndex)
end

function LotteryRankView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.Refresh,CC.Notifications.LotteryRankListRsp)
end

function LotteryRankView:UnRegisterEvent(  )
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.LotteryRankListRsp)
end
--@endregion

_InitVar = function(self,param)
    self.mainView = param.mainView
    self.config = self.mainView.lotteryData.LotteryConfig.RankList
end

return LotteryRankView