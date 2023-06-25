--Author:lijundao
--Time:2020年08月18日 09:03:23 Tuesday
--Describe:

local CC = require("CC")
local M = CC.uu.ClassView("Slot_MatchPrepareView")
local Slot_MatchUtils = require("View/SlotMatch/Slot_MatchUtils")
local slotMatch_message_pb = CC.slotMatch_message_pb
local SlotMatchManager = CC.SlotMatchManager

local tableContain = nil

-------------------------------------创建及初始化-----------------------------------
function M:GlobalNode()
	return GameObject.Find(self.param.parentPath).transform
end

function M:GlobalLayer()
	return "UI"
end

function M:ctor(param)
    self.param = param;
end

function M:OnCreate( ... )
    self.language = CC.LanguageManager.GetLanguage("L_SlotMatch");
    self:Init();
    self:RegisterEvent();
    self:Reset();
    self:ResetMatchInfo();
end

function M:Init()
    local nodeDetail = self:FindChild("nodeDetail")
    self.text_countDown_detail = nodeDetail:FindChild("countDown/text_countDown"):GetComponent("Text");
    self.image_hide = nodeDetail:FindChild("image_hide");
    self.text_matchTip_detail = nodeDetail:FindChild("text_matchTip"):GetComponent("Text");
    self.btn_baseMatch = nodeDetail:FindChild("matchList/btn_baseMatch");
    self.text_baseAward = self.btn_baseMatch:FindChild("text_baseAward"):GetComponent("Text");
    self.btn_baseMatch:FindChild("text_title").text = self.language.LANGUAGE_19
    self.image_baseMask = self.btn_baseMatch:FindChild("image_baseMask");
    self.btn_eliteMatch = nodeDetail:FindChild("matchList/btn_eliteMatch");
    self.text_eliteAward = self.btn_eliteMatch:FindChild("text_eliteAward"):GetComponent("Text");
    self.btn_eliteMatch:FindChild("text_title").text = self.language.LANGUAGE_20
    self.image_eliteMask = self.btn_eliteMatch:FindChild("image_eliteMask");
    self.btn_masterMatch = nodeDetail:FindChild("matchList/btn_masterMatch")
    self.text_masterAward = self.btn_masterMatch:FindChild("text_masterAward"):GetComponent("Text");
    self.btn_masterMatch:FindChild("text_title").text = self.language.LANGUAGE_21
    self.image_masterMask = self.btn_masterMatch:FindChild("image_masterMask");
    self.btn_rank = nodeDetail:FindChild("btn_rank");
    self.btn_help = nodeDetail:FindChild("btn_help");
    self.btn_share = nodeDetail:FindChild("btn_share");
    self.shareGroup = nodeDetail:FindChild("shareGroup");
    self.btn_facebook = self.shareGroup:FindChild("btn_facebook");
    self.btn_line = self.shareGroup:FindChild("btn_line");
    local nodeSimple = self:FindChild("nodeSimple");
    if self.param.simpleInfo then
        local rectTran = nodeSimple:GetComponent("RectTransform");
        rectTran.anchorMin = self.param.simpleInfo.anchorMin;
        rectTran.anchorMax = self.param.simpleInfo.anchorMax;
        rectTran.anchoredPosition = self.param.simpleInfo.anchoredPosition;
    end
    self.image_bg = nodeSimple:FindChild("image_bg");
    self.text_countDown_simple = nodeSimple:FindChild("countDown/text_countDown"):GetComponent("Text");
    self.text_matchTip_simple = nodeSimple:FindChild("text_matchTip"):GetComponent("Text");

    self.clock = self:FindChild("clock");
    if self.param.clockInfo then
        self.clock.position = self.param.clockInfo.position;
        self.clock.localScale = self.param.clockInfo.scale;
    end
    self.text_sec = self.clock:FindChild("text_sec"):GetComponent("Text");
    self.btnTouch = self:FindChild("btnTouch");
    self.btnTouch.gameObject:SetActive(false);

    self.nodeDetail = nodeDetail;
    self.nodeSimple = nodeSimple;
    self.childViews = {};
    self.matchFlags = {
        [0] = self:FindChild("nodeDetail/flags/dayFlag").gameObject,
        [1] = self:FindChild("nodeDetail/flags/weekFlag").gameObject,
        [2] = self:FindChild("nodeDetail/flags/monthFlag").gameObject,
    };
end

function M:RegisterEvent()
    self:AddClick(self.image_hide,"OnRightArrowClick");
    self:AddClick(self.btn_baseMatch,"OnBaseMatchClick");
    self:AddClick(self.btn_eliteMatch,"OnEliteMatchClick");
    self:AddClick(self.btn_masterMatch,"OnMasterMatchClick");
    self:AddClick(self.btn_rank,"OnRankClick");
    self:AddClick(self.btn_help,"OnHelpClick");
    self:AddClick(self.btn_share,"OnShareClick");
    self:AddClick(self.btn_facebook,"OnFaceBookClick");
    self:AddClick(self.btn_line,"OnLineClick");
    self:AddClick(self.image_bg,"OnLeftArrowClick");
    self:AddClick(self.btnTouch,"OnTouchOther");

    CC.HallNotificationCenter.inst():register(self,self.OnMatchStage,CC.Notifications.MATCHSTAGE);
    CC.HallNotificationCenter.inst():register(self,self.OnPushReadyMatchInfo,CC.Notifications.READYMATCHINFO);
    CC.HallNotificationCenter.inst():register(self,self.OnPushStageChange,CC.Notifications.STAGECHANGE);
    CC.HallNotificationCenter.inst():register(self,self.OnPushGiftPurchase,CC.Notifications.GIFTPURCHASE);
    CC.HallNotificationCenter.inst():register(self,self.OnGiftData,CC.Notifications.MATCHGIFT);
    CC.HallNotificationCenter.inst():register(self,self.OnContext,CC.Notifications.SLOTMATCHCONTEXT);
end

function M:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self);
end

-------------------------------------------事件---------------------------------
function M:OnRightArrowClick()
    self:DestroyChildViews();
    SlotMatchManager.inst():CloseView(self.viewName);
end

function M:OnBaseMatchClick()
    local hasOpenRewardRankView = self:HasChildView("Slot_MatchRewardRankView");
    self:DestroyChildViews();
    if self.enMatch ~= slotMatch_message_pb.En_Match_Primary then
        return;
    end
    --显示该级别奖励列表
    if not hasOpenRewardRankView then
        local childView = SlotMatchManager.inst():OpenView("Slot_MatchRewardRankView",slotMatch_message_pb.En_Match_Primary);
        table.insert(self.childViews,childView);
        self.btnTouch.gameObject:SetActive(true);
    end
end

function M:OnEliteMatchClick()
    local hasOpenRewardRankView = self:HasChildView("Slot_MatchRewardRankView");
    self:DestroyChildViews();
    if self.enMatch == slotMatch_message_pb.En_Match_High then
        return;
    end
    if self.enMatch == slotMatch_message_pb.En_Match_Primary then
        self:OpenMatchGiftView(self.language.LANGUAGE_22);
    else
        --显示该级别奖励列表
        if not hasOpenRewardRankView then
            local childView = SlotMatchManager.inst():OpenView("Slot_MatchRewardRankView",slotMatch_message_pb.En_Match_Middle);
            table.insert(self.childViews,childView);
            self.btnTouch.gameObject:SetActive(true);
        end
    end
end

function M:OnMasterMatchClick()
    local hasOpenRewardRankView = self:HasChildView("Slot_MatchRewardRankView");
    self:DestroyChildViews();
    if self.enMatch ~= slotMatch_message_pb.En_Match_High then
        if self.enMatch == slotMatch_message_pb.En_Match_Primary then
            self:OpenMatchGiftView(self.language.LANGUAGE_22);
        else
            self:OpenMatchGiftView(self.language.LANGUAGE_23);
        end
    else
        if not hasOpenRewardRankView then
            local childView = SlotMatchManager.inst():OpenView("Slot_MatchRewardRankView",slotMatch_message_pb.En_Match_High);
            table.insert(self.childViews,childView);
            self.btnTouch.gameObject:SetActive(true);
        end
    end
end

function M:OpenMatchGiftView(postStr)
    if self.hasGiftData then
        if postStr then
            CC.HallNotificationCenter.inst():post(CC.Notifications.MATCHTIP,postStr);
        end
        SlotMatchManager.inst():OpenView("Slot_MatchGiftView");
        self.hasOpenTask = false;
        self.postStr = nil;
    else
        local giftViewCtr = SlotMatchManager.inst():GetView("Slot_MatchGiftView").viewCtr;
        giftViewCtr:RequestGiftData();
        self.hasOpenTask = true;
        self.postStr = postStr;
    end
end

function M:OnRankClick()
    self:DestroyChildViews();
    local childView = SlotMatchManager.inst():OpenView("Slot_MatchHistoryRankView");
    table.insert(self.childViews,childView);
end

function M:OnHelpClick()
    self:DestroyChildViews();
    local childView = SlotMatchManager.inst():OpenView("Slot_MatchHelpView");
    table.insert(self.childViews,childView);
end

function M:OnShareClick()
    self.shareGroup:SetActive(not self.shareGroup.activeSelf);
end

function M:OnFaceBookClick()
    local param = {
        content = self.language.LANGUAGE_4,
		extraData = {
            gameId = self.gameId,
            inviteType = nil,
        },
        delayTime=1,
        timeOut = 15,
        errCb=function()
        end,
    }
    CC.SubGameInterface.InviteFriendFromFacebook(param)
end

function M:OnLineClick()
    local param = {
        content = self.language.LANGUAGE_4,
		extraData = {
            gameId = self.gameId,
            inviteType = nil,
        },
        delayTime=1,
        timeOut = 15,
        errCb=function()
        end,
    }
    CC.SubGameInterface.InviteFriendFromLine(param);
end

function M:OnLeftArrowClick()
    self:ActionIn();
end

function M:OnTouchOther()
    self:DestroyChildViews();
    self.btnTouch.gameObject:SetActive(false);
end

function M:OnMatchStage(data)
    log(CC.uu.Dump(data,"OnMatchStage",10))
    if data.matchStage.curStage == slotMatch_message_pb.En_Stage_Reay then  ----只有准备阶段才打开显示
        self:Refresh(data);
    else
        self:Reset();
        self:ActionOut(true);
        self:DestroyChildViews();
    end
end

function M:OnPushReadyMatchInfo(data)
    log(CC.uu.Dump(data,"OnPushReadyMatchInfo",10))
    self:ResetMatchInfo();
    self:RefreshMatchInfo(data);
    self.btn_rank.gameObject:SetActive(data.hasHistory);
    self.dataCache = data;
end

function M:OnPushStageChange(data)
    log(CC.uu.Dump(data,"OnPushStageChange",10))
    if data.matchStage.curStage == slotMatch_message_pb.En_Stage_Reay then
        self:Refresh(data);
    else
        self:Reset();
        self:ActionOut(true);
        self:DestroyChildViews();
    end
    for i = 0,2 do
        self.matchFlags[i]:SetActive(i == data.MatchFlag);
    end
end

function M:OnPushGiftPurchase()
    if self.dataCache then
        if self.enMatch < self:SafeEnMatch(self.dataCache.enMatch) then
            local matchName = Slot_MatchUtils.EnmatchToString(self:SafeEnMatch(self.dataCache.enMatch));
            CC.HallNotificationCenter.inst():post(CC.Notifications.MATCHTIP,string.format(self.language.LANGUAGE_38,matchName,matchName));
        end
        self:OnPushReadyMatchInfo(self.dataCache);
    elseif self.isShow then
        logError("没有准备阶段信息缓存");
        return;
    end
end

function M:OnGiftData(data)
    log(CC.uu.Dump(data,"OnGiftData",10))
    self.hasGiftData = true;
    if self.hasOpenTask then
        coroutine.start(function()---跳一帧再执行，因为可能mathGiftView还没有接收到data
            coroutine.step();
            self:OpenMatchGiftView(self.postStr);
        end);
    end
end

function M:OnContext(data)
    for i = 0,2 do
        self.matchFlags[i]:SetActive(i == data.MatchFlag);
    end
end

---------------------------------显示------------------------------------------
function M:Refresh(info)
    if not self.isShow then
        self:ActionIn();
        self.isShow = true;
    end
    local ramainTime = self:CalculateTime(info.matchStage.matchTime,info.matchStage.curStage);
    self:ResetCountDown();
    self:RefreshCountDown(ramainTime,function(time) self:ClockTip(time); end);
end

function M:Reset()
    self.transform:SetActive(false);
    self.isShow = false;
    self.clock:SetActive(false);
    self.text_sec.text = "";
end

function M:RefreshMatchInfo(info)
    self.enMatch = self:SafeEnMatch(info.enMatch);
    self.gameId = CC.ViewManager.GetCurGameId();
    self:RefreshMatchTip();
    self:RefreshMatchList(info.matchData);
end

function M:ResetMatchInfo()
    self.enMatch = nil;
    self.gameId = nil;
    self:ResetMatchTip();
    self:ResetMatchList();
end

function M:RefreshMatchTip()
    if self.enMatch == slotMatch_message_pb.En_Match_Primary then----非vip
        self.text_matchTip_detail.text = self.language.LANGUAGE_1;
        self.text_matchTip_simple.text = self.language.LANGUAGE_1;
    elseif self.enMatch ~= slotMatch_message_pb.En_Match_High then----精英
        self.text_matchTip_detail.text = self.language.LANGUAGE_2;
        self.text_matchTip_simple.text = self.language.LANGUAGE_2;
    else----牛人
        self.text_matchTip_detail.text = self.language.LANGUAGE_3;
        self.text_matchTip_simple.text = self.language.LANGUAGE_3;
    end
end

function M:ResetMatchTip()
    self.text_matchTip_detail.text = "";
    self.text_matchTip_simple.text = "";
end

function M:RefreshMatchList(info)
    for k,v in pairs(info) do
        if v.matchType == slotMatch_message_pb.En_Match_Primary then
            self.text_baseAward.text = CC.uu.ChipFormat(v.lRewardNum,true);
        elseif v.matchType == slotMatch_message_pb.En_Match_Middle then
            self.text_eliteAward.text = CC.uu.ChipFormat(v.lRewardNum,true);
        elseif v.matchType == slotMatch_message_pb.En_Match_High then
            self.text_masterAward.text = CC.uu.ChipFormat(v.lRewardNum,true);
        end
    end
    
    if self.enMatch == slotMatch_message_pb.En_Match_Primary then----非vip
        self.image_baseMask:SetActive(false);
    elseif self.enMatch ~= slotMatch_message_pb.En_Match_High then----精英
        self.image_eliteMask:SetActive(false);
    else----牛人
        self.image_masterMask:SetActive(false);
    end
end

function M:ResetMatchList()
    self.text_baseAward.text = "";
    self.text_eliteAward.text = "";
    self.text_masterAward.text = "";
    self.image_baseMask:SetActive(true);
    self.image_eliteMask:SetActive(true);
    self.image_masterMask:SetActive(true);
end


function M:ActionIn(immediately)
    if self.isOpen then
        return;
    end
    self.nodeSimple:SetActive(false);
    self.nodeDetail:SetActive(true);
    self.transform:SetActive(true);
    if immediately then
        self.nodeDetail.localPosition = Vector3(-130,0,0);
    else
        self.nodeDetail.localPosition = Vector3(130,0,0);
        self:RunAction(self.nodeDetail, {"localMoveTo", -130, 0, 0.3, ease = CC.Action.EInOutQuart, function()
    
        end});
    end
    self.isOpen = true;
end

function M:ActionOut(immediately)
    if self.isOpen == false then
        return;
    end
    if immediately then
        self.nodeDetail.localPosition = Vector3(130,0,0);
        self.nodeSimple:SetActive(true);
        self.nodeDetail:SetActive(false);
    else
        self:RunAction(self.nodeDetail, {"localMoveTo", 130, 0, 0.3, ease = CC.Action.EInOutQuart, function()
            self.nodeSimple:SetActive(true);
            self.nodeDetail:SetActive(false);
        end});
    end
    self.isOpen = false;
end

----------------------------------其他-------------------------------------------
function M:ClockTip(time)
    if time <= 5 then
        self.clock:SetActive(true);
        CC.Sound.PlayHallEffect("prepareClock")
        self.text_sec.text = tostring(time);
    end
end

function M:SafeEnMatch(enMatch)
    if enMatch == nil then
        local level = CC.Player.Inst():GetSelfInfoByKey("EPC_Level");
        if level < 1 then
            enMatch = 0;
        elseif level < 5 then
            enMatch = 1;
        else
            enMatch = 2;
        end
    end
    return enMatch;
end

----------------------------------倒计时------------------------------------------
function M:RefreshCountDown(time,listener)
    self:StopTimer("matchTimer");
    self:RefreshTimeUI(time);
    self:StartTimer("matchTimer", 1, function()
        time = time - 1;
        if time >= 0 then
            self:RefreshTimeUI(time);
            if listener then
                listener(time);
            end
        else
            self:StopTimer("matchTimer");
        end
    end, -1);
end

function M:RefreshTimeUI(time)
    local timeStr = CC.uu.TicketFormat(time,true);
    self.text_countDown_detail.text = timeStr;
    self.text_countDown_simple.text = timeStr;
end

function M:ResetCountDown()
    self:StopTimer("matchTimer");
    self.text_countDown_detail.text = "";
    self.text_countDown_simple.text = "";
end

function M:CalculateTime(matchTime,curStage)
    if curStage == slotMatch_message_pb.En_Stage_Reay then ----距离比赛开始还有多长时间
        return matchTime.curServerZeroTime + matchTime.startTime - matchTime.curServerTime;
    elseif curStage == slotMatch_message_pb.En_Stage_Game then ----距离比赛结束还有多长时间
        return (matchTime.curServerZeroTime + matchTime.startTime + matchTime.matchTime) - matchTime.curServerTime;
    else
        return 0;
    end
end

-------------------------------------清理------------------------------------------
function M:DestroyChildViews()
    for k,view in pairs(self.childViews) do
        SlotMatchManager.inst():CloseView(view.viewName,true);
    end
    self.childViews = {};
end

function M:OnDestroy()
    self:UnRegisterEvent();
    self:StopTimer("matchTimer");
end

------------------------------------other-------------------------------
function M:HasChildView(viewName)
    return tableContain(self.childViews,function(view)
        return view.viewName == viewName;
    end);
end

tableContain = function (tab,func)
    for k,v in pairs(tab) do
        if func(v) then
            return true;
        end
    end
    return false;
end
return M


