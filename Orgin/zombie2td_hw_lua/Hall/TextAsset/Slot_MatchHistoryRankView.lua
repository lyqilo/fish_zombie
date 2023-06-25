--Author:lijundao
--Time:2020年08月18日 09:03:23 Tuesday
--Describe:
local Slot_MatchHistoryRankItem = require("View/SlotMatch/Slot_MatchHistoryRankItem")
local CC = require("CC")
local M = CC.uu.ClassView("Slot_MatchHistoryRankView")
local slotMatch_message_pb = CC.slotMatch_message_pb
local SlotMatchManager = CC.SlotMatchManager
local Slot_MatchUtils = require("View/SlotMatch/Slot_MatchUtils")
local GameobjectPool = require("Common/GameobjectPool");

-------------------------------------创建及初始化-----------------------------------
function M:ctor(param)
    self.param = param;
end

function M:OnOpen()
    self:ResetRankData();
    self:Reset();
    self:ActionIn();
    self:OnMatchClick(slotMatch_message_pb.En_Match_Primary)
end

function M:OnCreate( ... )
    self.language = CC.LanguageManager.GetLanguage("L_SlotMatch");
    self:Init();
    self:RegisterEvent();
    self:ResetRankData();
    self:Reset();
    self:ActionOut(true);
end

function M:Init()
    local frame = self:FindChild("frame");
    frame:FindChild("bg/rankTitle").text = self.language.LANGUAGE_42;
    frame:FindChild("bg/nickTitle").text = self.language.LANGUAGE_43;
    frame:FindChild("bg/rewardTitle").text = self.language.LANGUAGE_44;
    self.btn_close = frame:FindChild("btn_close");
    self.btn_help = frame:FindChild("btn_help");

    self.btnMatchs = {
        [slotMatch_message_pb.En_Match_Primary] = frame:FindChild("btn_baseMatch"),
        [slotMatch_message_pb.En_Match_Middle] = frame:FindChild("btn_eliteMatch"),
        [slotMatch_message_pb.En_Match_High] = frame:FindChild("btn_masterMatch"),
    }
    self.btnMaskMatchs = {
        [slotMatch_message_pb.En_Match_Primary] = frame:FindChild("btnMask_baseMatch"),
        [slotMatch_message_pb.En_Match_Middle] = frame:FindChild("btnMask_eliteMatch"),
        [slotMatch_message_pb.En_Match_High] = frame:FindChild("btnMask_masterMatch"),
    }

    local rankFirstInfo = frame:FindChild("rankFirstInfo");
    self.rankNum_1_first = rankFirstInfo:FindChild("rankNum_1");
    self.firstIconPos = rankFirstInfo:FindChild("iconPos");
    self.text_awardChip_first = rankFirstInfo:FindChild("awardChip/text_awardChip"):GetComponent("Text");
    self.text_playerName_first = rankFirstInfo:FindChild("text_playerName"):GetComponent("Text");
    self.giftListScrollRect_first = rankFirstInfo:FindChild("giftList"):GetComponent("ScrollRect");
    local giftListContent_first = rankFirstInfo:FindChild("giftList/content");
    local giftPrefab_first = rankFirstInfo:FindChild("matchGift").gameObject;
    self.giftPool_first =  GameobjectPool.New(
        giftPrefab_first,
        function(obj)
            obj:SetActive(false);
            obj.transform:SetParent(giftListContent_first,false);
        end,
        function(obj)
            obj.transform:FindChild("image_giftIcon"):GetComponent("Image").sprite = nil;
            obj.transform:FindChild("text_giftCount").text = "";
        end,
        -1
    );

    local rankSelfInfo = frame:FindChild("rankSelfInfo");
    self.rankNum_1_Self = rankSelfInfo:FindChild("rankNum_1");
    self.rankNum_2_Self = rankSelfInfo:FindChild("rankNum_2");
    self.rankNum_3_Self = rankSelfInfo:FindChild("rankNum_3");
    self.rankNum_4up_Self = rankSelfInfo:FindChild("rankNum_4up");
    self.text_rankNum_Self = self.rankNum_4up_Self:FindChild("text_rankNum"):GetComponent("Text");
    self.selfIconPos = rankSelfInfo:FindChild("iconPos");
    self.text_awardChip_Self = rankSelfInfo:FindChild("text_awardChip"):GetComponent("Text");
    self.image_chipIcon = rankSelfInfo:FindChild("text_awardChip/chipIcon");
    self.text_playerName_Self = rankSelfInfo:FindChild("text_playerName"):GetComponent("Text");
    self.rankList = frame:FindChild("rankList"):GetComponent("LoopScrollRect");
    self.giftListScrollRect_self = rankSelfInfo:FindChild("giftList"):GetComponent("ScrollRect");
    local giftListContent_self = rankSelfInfo:FindChild("giftList/content");
    local giftPrefab_self = rankSelfInfo:FindChild("matchGift").gameObject;
    self.giftPool_self =  GameobjectPool.New(
        giftPrefab_self,
        function(obj)
            obj:SetActive(false);
            obj.transform:SetParent(giftListContent_self,false);
        end,
        function(obj)
            obj.transform:FindChild("image_giftIcon"):GetComponent("Image").sprite = nil;
            obj.transform:FindChild("text_giftCount").text = "";
        end,
        -1
    );
    
    self.frame = frame;
    self.itemPool = {};
    self.reqIntervalTime = 0.1;
    self.delayRunCos = {};
end

function M:RegisterEvent()
    self:AddClick(self.btn_close,"OnCloseClick");
    self:AddClick(self.btn_help,"OnHelpClick");
    for enMatch,btn in pairs(self.btnMatchs) do
        btn:FindChild("textMatchName").text = Slot_MatchUtils.EnmatchToString(enMatch);
        self:AddClick(btn,function() self:OnMatchClick(enMatch) end);
    end
    for enMatch,btn in pairs(self.btnMaskMatchs) do
        btn:FindChild("textMatchName").text = Slot_MatchUtils.EnmatchToString(enMatch);
    end
    self.rankList:AddChangeItemListener(function(tran,index)
        local rank = index+1;
        if self.rankData[self.selectEnMatch] and self.rankData[self.selectEnMatch][rank] then
            tran.name = tostring(rank)
            local item = Slot_MatchHistoryRankItem.new(tran.gameObject);
            item:Reset();
            item:Refresh(self.rankData[self.selectEnMatch][rank]);
            self.itemPool[tran] = item;
        else
            logError("排行榜缓存不存在该索引数据，rank："..rank);
        end
	end)
    self.rankList:ToPoolItemListenner(function(tran,index)
        local item = self.itemPool[tran];
        if item then
            item:Reset();
            self.itemPool[tran] = nil;
        end
	end)

    CC.HallNotificationCenter.inst():register(self,self.OnReqMatchRank,CC.Notifications.MATCHRANK);
end

function M:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self);
end

-------------------------------------------事件---------------------------------
function M:OnCloseClick()
    SlotMatchManager.inst():CloseView(self.viewName);
end

function M:OnHelpClick()
    SlotMatchManager.inst():OpenView("Slot_MatchHelpView");
end

function M:OnMatchClick(selectEnMatch)
    if self.taskCount > 0 then
        return;
    end
    self.selectEnMatch = selectEnMatch;
    for k,v in pairs(self.btnMatchs) do
        if k == selectEnMatch then
            v:SetActive(false);
        else
            v:SetActive(true);
        end
    end
    for k,v in pairs(self.btnMaskMatchs) do
        if k == selectEnMatch then
            v:SetActive(true);
        else
            v:SetActive(false);
        end
    end
    self.taskCount = 0;
    local reqCount,everyCount = Slot_MatchUtils.EnmatchToReqCount(selectEnMatch);
    for i = 0,reqCount - 1 do
        table.insert(self.delayRunCos,CC.uu.DelayRun(self.reqIntervalTime * i,function() self.param.ReqMatchRankFunc(selectEnMatch,everyCount * i,everyCount * (i+1)); end));
        self.taskCount = self.taskCount + 1;
    end
end

function M:OnReqMatchRank(data)
    log(CC.uu.Dump(data,"OnReqMatchRank",10))
    self:RefreshRankData(data);
    self.taskCount = self.taskCount - 1;
    if self.taskCount <= 0 then
        self:Reset();
        self:Refresh();
    end
end

------------------------------------显示-----------------------------------------
function M:Refresh()
    self:RefreshFirstAndSelf();
    self:RefreshRankList();
end

function M:Reset()
    self.taskCount = 0;
    for k,v in pairs(self.delayRunCos) do
        CC.uu.CancelDelayRun(v)
    end
    self.delayRunCos = {};
    self:ResetFirstAndSelf();
    self:ResetRankList();
end

------结算后清空处理
function M:ResetAll()
    self:ResetRankData();
    self:Reset();
end

function M:RefreshFirstAndSelf()
    local firstInfo = nil;
    local selfInfo = self:GetDefaultSelfInfo();
    if self.rankData[self.selectEnMatch] then
        local arrRank = self.rankData[self.selectEnMatch];
        firstInfo = arrRank[1];
        local selfId = CC.Player.Inst():GetSelfInfoByKey("Id");
        local selfKey = nil;
        table.filter(arrRank,function(v,k) 
            if v.playerInfo.playerId == selfId then
                selfKey = k;
                return true;
            else
                return false;
            end
        end);
        if selfKey ~= nil then
            selfInfo = arrRank[selfKey]; 
        end
    end
    self:RefreshRankFirstInfo(firstInfo);
    self:RefreshRankSelfInfo(selfInfo);
end

function M:ResetFirstAndSelf()
    self:ResetRankFirstInfo();
    self:ResetRankSelfInfo();
end

function M:RefreshRankFirstInfo(info)
    if info == nil then
        return;
    end
    self.firstIconPos.gameObject:SetActive(true);
    self.rankNum_1_first.gameObject:SetActive(true);
    local portrait = info.playerInfo.szPortrait;
    if portrait == "nil" then
        portrait = "";
    end
    self.firstIcon = CC.HeadManager.CreateHeadIcon({parent = self.firstIconPos,clickFunc = "unClick",unShowVip = true,portrait = portrait,playerId = info.playerInfo.playerId});
    self.text_playerName_first.text = info.playerInfo.szNickName;
    self.text_awardChip_first.text = CC.uu.ChipFormat(Slot_MatchUtils.Return0IfNil(info.lScore),true);

    local rewardCountMap = {};
    local itemCount = 0;
    for k,v in ipairs(info.props) do
        rewardCountMap[v.PropId] = rewardCountMap[v.PropId] == nil and v.Count or (rewardCountMap[v.PropId] + v.Count);
        itemCount = itemCount + 1;
    end
    for k,v in pairs(rewardCountMap) do
        local gift = self.giftPool_first:Get();
        local spriteName = "prop_img_"..k;
        local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[spriteName..".png"];
        gift.transform:FindChild("image_giftIcon"):GetComponent("Image").sprite = CC.uu.LoadImgSprite(spriteName,abName);
        gift.transform:FindChild("text_giftCount").text = "X"..v;
    end
    if itemCount > 1 then
        local deltaPos = 1/(itemCount - 1);
        self.giftListScrollRect_first.horizontalNormalizedPosition = 0;
        local tempCount = itemCount - 1;
        local loopShowFunc = nil;
        loopShowFunc = function()
            self.loopShowCor_first = CC.uu.DelayRun(2,function()
                if tempCount > 0 then
                    self.giftListScrollRect_first.horizontalNormalizedPosition = self.giftListScrollRect_first.horizontalNormalizedPosition + deltaPos;
                    tempCount = tempCount - 1;
                else
                    self.giftListScrollRect_first.horizontalNormalizedPosition = 0;
                    tempCount = itemCount - 1;
                end
                loopShowFunc();
            end);
        end
        loopShowFunc();
    end
end

function M:ResetRankFirstInfo()
    self.text_awardChip_first.text = "";
    self.text_playerName_first.text = "";
    self.firstIconPos.gameObject:SetActive(false);
    self.rankNum_1_first.gameObject:SetActive(false);
    if self.firstIcon then
        CC.HeadManager.DestroyHeadIcon(self.firstIcon);
        self.firstIcon = nil;
    end
    Util.ClearChild(self.firstIconPos,false);
    self.giftPool_first:RecycleAll();
    if self.loopShowCor_first then
        CC.uu.CancelDelayRun(self.loopShowCor_first);
        self.loopShowCor_first = nil;
    end
end

function M:RefreshRankSelfInfo(info)
    if info == nil then
        return;
    end
    info.rank = Slot_MatchUtils.Return0IfNil(info.rank)
    local portrait = info.playerInfo.szPortrait;
    if portrait == "nil" then
        portrait = "";
    end
    self.selfIcon = CC.HeadManager.CreateHeadIcon({parent = self.selfIconPos,clickFunc = "unClick",unShowVip = true,portrait = portrait,playerId = info.playerInfo.playerId});
    self.text_playerName_Self.text = info.playerInfo.szNickName;
    local selfScore = Slot_MatchUtils.Return0IfNil(info.lScore);
    self.text_awardChip_Self.text = selfScore == 0 and self.language.LANGUAGE_48 or CC.uu.ChipFormat(selfScore,true);
    self.image_chipIcon.gameObject:SetActive(not (selfScore == 0))
    if info.rank == 1 then
        self.rankNum_1_Self:SetActive(true);
    elseif info.rank == 2 then
        self.rankNum_2_Self:SetActive(true);
    elseif info.rank == 3 then
        self.rankNum_3_Self:SetActive(true);
    elseif info.rank >= 4 then
        self.rankNum_4up_Self:SetActive(true);
        self.text_rankNum_Self.text = tostring(info.rank);
    end
    local rewardCountMap = {};
    local itemCount = 0;

    if info.props then
        for k,v in ipairs(info.props) do
            rewardCountMap[v.PropId] = rewardCountMap[v.PropId] == nil and v.Count or (rewardCountMap[v.PropId] + v.Count);
            itemCount = itemCount + 1;
        end
    end
    for k,v in pairs(rewardCountMap) do
        local gift = self.giftPool_self:Get();
        local spriteName = "prop_img_"..k;
        local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[spriteName..".png"];
        gift.transform:FindChild("image_giftIcon"):GetComponent("Image").sprite = CC.uu.LoadImgSprite(spriteName,abName);
        gift.transform:FindChild("text_giftCount").text = "X"..v;
    end
    if itemCount > 1 then
        local deltaPos = 1/(itemCount - 1);
        self.giftListScrollRect_self.horizontalNormalizedPosition = 0;
        local tempCount = itemCount - 1;
        local loopShowFunc = nil;
        loopShowFunc = function()
            self.loopShowCor_self = CC.uu.DelayRun(2,function()
                if tempCount > 0 then
                    self.giftListScrollRect_self.horizontalNormalizedPosition = self.giftListScrollRect_self.horizontalNormalizedPosition + deltaPos;
                    tempCount = tempCount - 1;
                else
                    self.giftListScrollRect_self.horizontalNormalizedPosition = 0;
                    tempCount = itemCount - 1;
                end
                loopShowFunc();
            end);
        end
        loopShowFunc();
    end
end

function M:ResetRankSelfInfo()
    self.text_playerName_Self.text = "";
    self.text_awardChip_Self.text = "";
    self.rankNum_1_Self:SetActive(false);
    self.rankNum_2_Self:SetActive(false);
    self.rankNum_3_Self:SetActive(false);
    self.rankNum_4up_Self:SetActive(false);
    self.text_rankNum_Self.text = "";
    if self.selfIcon then
        CC.HeadManager.DestroyHeadIcon(self.selfIcon);
        self.selfIcon = nil;
    end
    Util.ClearChild(self.selfIconPos,false);
    self.giftPool_self:RecycleAll();
    if self.loopShowCor_self then
        CC.uu.CancelDelayRun(self.loopShowCor_self);
        self.loopShowCor_self = nil;
    end
end

function M:RefreshRankList()
    self.rankList.totalCount = #self.rankData[self.selectEnMatch];
end

function M:ResetRankList()
    self.rankList:ClearCells();
end

function M:ActionIn(immediately)
    if self.isOpen then
        return;
    end
    if immediately then
        self.frame.localScale = Vector3(1,1,1);
    else
        self.frame.localScale = Vector3(0.5,0.5,1)
        self:RunAction(self.frame, {"scaleTo", 1, 1, 0.3, ease = CC.Action.EOutBack, function()
    
        end});
    end
    self.isOpen = true;
    self.transform:SetActive(true);
end

function M:ActionOut(immediately)
    if self.isOpen == false then
        return;
    end
    if immediately then
        self.transform:SetActive(false);
    else
        self:RunAction(self.frame, {"scaleTo", 0.5, 0.5, 0.3, ease = CC.Action.EInBack, function()
            self.transform:SetActive(false);
        end})
    end
    self.isOpen = false;
end
-------------------------------------数据------------------------------------------
function M:RefreshRankData(info)
    local enMatch = info.enMatch;
    if info.arrRank and #info.arrRank > 0 then
        for i,v in ipairs(info.arrRank) do
            self.rankData[enMatch][v.rank] = v;
        end
    end
end

function M:ResetRankData()
    self.rankData = {
        [slotMatch_message_pb.En_Match_Primary] = {},
        [slotMatch_message_pb.En_Match_Middle] = {},
        [slotMatch_message_pb.En_Match_High] = {}
    };
end

function M:GetDefaultSelfInfo()
    local localSelfInfo = CC.Player.Inst():GetSelfInfo().Data.Player;
    local selfInfo = {playerInfo = {szNickName = localSelfInfo.Nick,szPortrait = localSelfInfo.Portrait}}
    return selfInfo;
end

-------------------------------------清理------------------------------------------
function M:OnDestroy()
    self:ResetAll();
    self:UnRegisterEvent();
    self.rankList:DelectPool()
	self.rankList = nil
end
return M


