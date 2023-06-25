--Author:lijundao
--Time:2020年08月18日 09:03:23 Tuesday
--Describe:
local Slot_MatchRealRankItem = require("View/SlotMatch/Slot_MatchRealRankItem")
local CC = require("CC")
local M = CC.uu.ClassView("Slot_MatchDoingView")
local slotMatch_message_pb = CC.slotMatch_message_pb
local SlotMatchManager = CC.SlotMatchManager

local tableContain = nil;

-------------------------------------创建及初始化-----------------------------------
function M:GlobalNode()
	return GameObject.Find(self.param.parentPath).transform
end

function M:GlobalLayer()
	return "UI"
end

function M:ctor(param)
    self.param = param
end

function M:OnCreate( ... )
    self.language = CC.LanguageManager.GetLanguage("L_SlotMatch");
    self:Init();
    self:RegisterEvent();
    self:ResetRankData();
    self:Reset();
    self:ResetMatchInfo();
end

function M:Init()
    local nodeDetail = self:FindChild("nodeDetail")
    self.text_countDown_detail = nodeDetail:FindChild("countDown/text_countDown"):GetComponent("Text");
    self.image_hide = nodeDetail:FindChild("image_hide");
    self.btn_awardPool_base = nodeDetail:FindChild("btn_awardPool_base");
    self.btn_awardPool_elite = nodeDetail:FindChild("btn_awardPool_elite");
    self.btn_awardPool_master = nodeDetail:FindChild("btn_awardPool_master");
    self.text_totalAward_base = self.btn_awardPool_base:FindChild("text_totalAward"):GetComponent("NumberRoller");
    self.text_totalAward_elite = self.btn_awardPool_elite:FindChild("text_totalAward"):GetComponent("NumberRoller");
    self.text_totalAward_master = self.btn_awardPool_master:FindChild("text_totalAward"):GetComponent("NumberRoller");  
    self.btn_awardPool_base:FindChild("text_title"):GetComponent("Text").text = self.language.LANGUAGE_19;
    self.btn_awardPool_elite:FindChild("text_title"):GetComponent("Text").text = self.language.LANGUAGE_20;
    self.btn_awardPool_master:FindChild("text_title"):GetComponent("Text").text = self.language.LANGUAGE_21;
    self.shareGroup = nodeDetail:FindChild("shareGroup");
    self.btn_facebook = self.shareGroup:FindChild("btn_facebook");
    self.btn_line = self.shareGroup:FindChild("btn_line");
    local selfInfo = nodeDetail:FindChild("selfInfo");
    self.iconPos = selfInfo:FindChild("iconPos");
    self.text_name = selfInfo:FindChild("text_name"):GetComponent("Text");
    self.text_score = selfInfo:FindChild("image_scoreBg/text_score"):GetComponent("Text");
    self.image_up = selfInfo:FindChild("image_up");
    self.image_down = selfInfo:FindChild("image_down");
    self.text_offset = selfInfo:FindChild("text_offset"):GetComponent("Text");
    self.btn_share = selfInfo:FindChild("btn_share");
    self.text_rank = selfInfo:FindChild("text_rank");
    self.rank1_3 = {};
    for i = 1,3 do
        self.rank1_3[i] = selfInfo:FindChild("rank"..i).gameObject;
    end
    self.text_playerCount = nodeDetail:FindChild("text_playerCount"):GetComponent("NumberRoller");
    self.btn_touch = nodeDetail:FindChild("rankList/btn_touch");
    self.btn_help = nodeDetail:FindChild("btn_help");
    self.rankList = nodeDetail:FindChild("rankList"):GetComponent("LoopScrollRect");

    local nodeSimple = self:FindChild("nodeSimple");
    if self.param.simpleInfo then
        local rectTran = nodeSimple:GetComponent("RectTransform");
        rectTran.anchorMin = self.param.simpleInfo.anchorMin;
        rectTran.anchorMax = self.param.simpleInfo.anchorMax;
        rectTran.anchoredPosition = self.param.simpleInfo.anchoredPosition;

        nodeSimple:FindChild("slider_rank").y = self.param.simpleInfo.sliderRankPosY;
    end
    self.text_matchTip = nodeSimple:FindChild("text_matchTip"):GetComponent("Text");
    self.image_bg = nodeSimple:FindChild("image_bg");
    self.text_countDown_simple = nodeSimple:FindChild("countDown/text_countDown"):GetComponent("Text");
    self.slider_rank = nodeSimple:FindChild("slider_rank"):GetComponent("Slider");
    self.iconPos_slider = self.slider_rank.transform:FindChild("Handle Slide Area/Handle/iconPos");
    local offsetTip = self.slider_rank.transform:FindChild("Handle Slide Area/Handle/offsetTip");
    self.text_rankNum_slider = offsetTip:FindChild("text_rankNum_slider"):GetComponent("Text");
    self.text_rankOffset_slider = offsetTip:FindChild("text_rankOffset_slider"):GetComponent("Text");
    self.image_up_slider = offsetTip:FindChild("image_up_slider");
    self.image_down_slider = offsetTip:FindChild("image_down_slider");

    self.animator = self.transform:GetComponent("Animator")
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
    self.itemPool = {};
    self.canRefresh = true;
    self.remainTime = nil;
    self.canOpenRealAgain = true;
    self.matchFlags = {
        [0] = self:FindChild("nodeDetail/flags/dayFlag").gameObject,
        [1] = self:FindChild("nodeDetail/flags/weekFlag").gameObject,
        [2] = self:FindChild("nodeDetail/flags/monthFlag").gameObject,
    };
    self.giftFlags = {
        [0] = self:FindChild("nodeDetail/floatGiftEffect/pokdeng_mrlb_9x/giftImage_suiPian").gameObject,
        [1] = self:FindChild("nodeDetail/floatGiftEffect/pokdeng_mrlb_9x/giftImage_dianKa").gameObject,
        [2] = self:FindChild("nodeDetail/floatGiftEffect/pokdeng_mrlb_9x/giftImage_lian").gameObject,
    }
end

function M:RegisterEvent()
    self:AddClick(self.image_hide,"OnRightArrowClick");
    self:AddClick(self.btn_awardPool_base,"OnAwardPoolClick_base");
    self:AddClick(self.btn_awardPool_elite,"OnAwardPoolClick_elite");
    self:AddClick(self.btn_awardPool_master,"OnAwardPoolClick_master");
    self:AddClick(self.btn_touch,"OnRankListClick");
    self:AddClick(self.btn_share,"OnShareClick");
    self:AddClick(self.btn_facebook,"OnFaceBookClick");
    self:AddClick(self.btn_line,"OnLineClick");
    self:AddClick(self.image_bg,"OnLeftArrowClick");
    self:AddClick(self.btn_help,"OnHelpClick");
    self:AddClick(self.btnTouch,"OnTouchOther");

    self.rankList:AddChangeItemListener(function(tran,index)
        local rank = index+1;
        if self.rankData[self.enMatch] and self.rankData[self.enMatch][rank] then
            tran.name = tostring(rank)
            local item = Slot_MatchRealRankItem.new(tran.gameObject);
            item:Reset();
            item:Refresh(self.rankData[self.enMatch][rank]);
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

    CC.HallNotificationCenter.inst():register(self,self.OnMatchStage,CC.Notifications.MATCHSTAGE);
    CC.HallNotificationCenter.inst():register(self,self.OnPushProcessMatchInfo,CC.Notifications.PROCESSMATCHINFO);
    CC.HallNotificationCenter.inst():register(self,self.OnPushStageChange,CC.Notifications.STAGECHANGE);
    CC.HallNotificationCenter.inst():register(self,self.OnLimitRefreshRealtimeRank,CC.Notifications.LIMITREFRESHREALTIMERANK);
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


function M:OnAwardPoolClick_base()
    local hasOpenRewardRankView = self:HasChildView("Slot_MatchRewardRankView");
    self:DestroyChildViews();
    if not hasOpenRewardRankView then  
        local childView = SlotMatchManager.inst():OpenView("Slot_MatchRewardRankView",slotMatch_message_pb.En_Match_Primary);
        table.insert(self.childViews,childView);
        self.btnTouch.gameObject:SetActive(true);
    end
end

function M:OnAwardPoolClick_elite()
    local hasOpenRewardRankView = self:HasChildView("Slot_MatchRewardRankView");
    self:DestroyChildViews();
    if not hasOpenRewardRankView then
        local childView = SlotMatchManager.inst():OpenView("Slot_MatchRewardRankView",slotMatch_message_pb.En_Match_Middle);
        table.insert(self.childViews,childView);
        self.btnTouch.gameObject:SetActive(true);
    end
end

function M:OnAwardPoolClick_master()
    local hasOpenRewardRankView = self:HasChildView("Slot_MatchRewardRankView");
    self:DestroyChildViews();
    if not hasOpenRewardRankView then
        local childView = SlotMatchManager.inst():OpenView("Slot_MatchRewardRankView",slotMatch_message_pb.En_Match_High);
        table.insert(self.childViews,childView);
        self.btnTouch.gameObject:SetActive(true);
    end
end

function M:OnRankListClick()
    if self.canOpenRealAgain == false then
        return;
    end
    local hasOpenRealRankView = self:HasChildView("Slot_MatchRealRankView");
    self:DestroyChildViews();
    if not hasOpenRealRankView then
        local childView = SlotMatchManager.inst():OpenView("Slot_MatchRealRankView");
        table.insert(self.childViews,childView);
        self.btnTouch.gameObject:SetActive(true);
    end
    self.canOpenRealAgain = false;
    CC.uu.DelayRun(1,function() self.canOpenRealAgain = true end);
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

function M:OnHelpClick()
    self:DestroyChildViews();
    local childView = SlotMatchManager.inst():OpenView("Slot_MatchHelpView");
    table.insert(self.childViews,childView);
end

function M:OnTouchOther()
    self:DestroyChildViews();
    self.btnTouch.gameObject:SetActive(false);
end

function M:OnMatchStage(data)
    log(CC.uu.Dump(data,"OnMatchStage",10))
    if data.matchStage.curStage == slotMatch_message_pb.En_Stage_Game then  ----只有比赛阶段才打开显示
        self:Refresh(data);
    else
        self:Reset();
        self:ActionOut(true);
        self:DestroyChildViews();
    end
end

function M:OnPushProcessMatchInfo(data)
    if self.canRefresh then
        log(CC.uu.Dump(data,"OnPushProcessMatchInfo",10))
        self:RefreshRankData(data);
        self:ResetMatchInfo();
        self:RefreshMatchInfo(data);
        self.dataCache = nil;
    else
        self.dataCache = data;
    end
end

function M:OnPushStageChange(data)
    log(CC.uu.Dump(data,"OnPushStageChange",10))
    if data.matchStage.curStage == slotMatch_message_pb.En_Stage_Game then  ----只有比赛阶段才打开显示
        self:Refresh(data);
    else
        self:Reset();
        self:ActionOut(true);
        self:DestroyChildViews();
    end
    for i = 0,2 do
        self.matchFlags[i]:SetActive(i == data.MatchFlag);
        self.giftFlags[i]:SetActive(i == data.MatchFlag);
        if i == data.MatchFlag then
            local spriteName = "prop_img_"..SlotMatchManager.inst():GetContextInfoByKey("TopProps")[data.MatchFlag + 1].Props[1].PropId;
            local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[spriteName..".png"];
            self.giftFlags[i]:GetComponent("Image").sprite = CC.uu.LoadImgSprite(spriteName,abName);
        end
    end
end

function M:OnLimitRefreshRealtimeRank(yes)
    self.canRefresh = not yes;
    if self.canRefresh then
        if self.dataCache and self.isShow then
            self:OnPushProcessMatchInfo(self.dataCache);
        end
    end
end

function M:ReqProcessMatchInfo(time)
    if self.startTime == nil then
        self.startTime = time
    elseif (self.startTime - time) % 5 ~= 0 then
        return
    end
    if self.param and self.param.GetProcessMatchInfo then
        self.param.GetProcessMatchInfo();
    end
end

function M:OnContext(data)
    for i = 0,2 do
        self.matchFlags[i]:SetActive(i == data.MatchFlag);
        self.giftFlags[i]:SetActive(i == data.MatchFlag);
        if i == data.MatchFlag then
            local spriteName = "prop_img_"..data.TopProps[data.MatchFlag + 1].Props[1].PropId;
            local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[spriteName..".png"];
            self.giftFlags[i]:GetComponent("Image").sprite = CC.uu.LoadImgSprite(spriteName,abName);
        end
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
    self:RefreshCountDown(ramainTime,function(time) self:ShowCountDownAni(time) self:CheckCanClickGift(time) self:ReqProcessMatchInfo(time) self:ClockTip(time) end);
end

function M:Reset()
    self.transform:SetActive(false);
    self.isShow = false;
    self.hasTipWillOver = false;
    self.hasCheckCanClickGift = false;
    self.canRefresh = true;
    self.remainTime = nil;
    self.text_sec.text = "";
    self.clock:SetActive(false);
    self:ResetCountDown();
end

------结算后清空处理
function M:ResetAll()
    self:ResetRankData();
    self:ResetRankList();
    self:Reset();
    self:ResetMatchInfo();
end

function M:RefreshMatchInfo(info)
    self.gameId = CC.ViewManager.GetCurGameId();
    self.enMatch = info.enMatch;
    self:RefreshMatchTip(info.enMatch);
    self:RefreshRewardPool(info.enMatch,info.poolValue);
    self:RefreshRankList();
    self:RefreshSelfInfo(info.myRank,info.totalCount);
    self:RefreshPlayerCountAndRankSlider(info.totalCount,info.myRank);
end

function M:ResetMatchInfo()
    self.gameId = nil;
    self.enMatch = nil;
    self:ResetMatchTip();
    self:ResetRewardPool();
    self:ResetRankList();
    self:ResetSelfInfo();
    self:ResetPlayerCountAndRankSlider();
end

function M:RefreshMatchTip(enMatch)
    if enMatch == slotMatch_message_pb.En_Match_Primary then----非vip
        self.text_matchTip.text = self.language.LANGUAGE_16;
    elseif enMatch == slotMatch_message_pb.En_Match_Middle then----精英
        self.text_matchTip.text = self.language.LANGUAGE_17;
    elseif enMatch == slotMatch_message_pb.En_Match_High then----牛人
        self.text_matchTip.text = self.language.LANGUAGE_18;
    end
end

function M:ResetMatchTip()
    self.text_matchTip.text = "";
end

function M:RefreshRewardPool(enMatch,poolValue)
    if enMatch == slotMatch_message_pb.En_Match_Primary then----非vip
        self.btn_awardPool_base:SetActive(true);
        self.text_totalAward_base:RollTo(poolValue,2);--CC.uu.ChipFormat(poolValue,true)
    elseif enMatch == slotMatch_message_pb.En_Match_Middle then----精英
        self.btn_awardPool_elite:SetActive(true);
        self.text_totalAward_elite:RollTo(poolValue,2);--CC.uu.ChipFormat(poolValue,true)
    elseif enMatch == slotMatch_message_pb.En_Match_High then----牛人
        self.btn_awardPool_master:SetActive(true);
        self.text_totalAward_master:RollTo(poolValue,2);--CC.uu.ChipFormat(poolValue,true)
    end
end

function M:ResetRewardPool()
    self.btn_awardPool_base:SetActive(false);
    self.btn_awardPool_elite:SetActive(false);
    self.btn_awardPool_master:SetActive(false);
end

function M:RefreshRankList()
    self.rankList.totalCount = #self.rankData[self.enMatch];
end

function M:ResetRankList()
    self.rankList:ClearCells();
end

function M:RefreshSelfInfo(myRank,playerCount)
    local portrait = myRank.playerInfo.szPortrait;
    if portrait == "nil" then
        portrait = "";
    end
    self.icon = CC.HeadManager.CreateHeadIcon({parent = self.iconPos,clickFunc = "unClick",unShowVip = true,portrait = portrait,playerId = myRank.playerInfo.playerId});
    self.icon_slider = CC.HeadManager.CreateHeadIcon({parent = self.iconPos_slider,clickFunc = "unClick",unShowVip = true,portrait = portrait,playerId = myRank.playerInfo.playerId});
    if self.lastRank then
        local offset = myRank.rank - self.lastRank;
        if offset < 0 then
            self.image_up:SetActive(true);
            self.image_up_slider:SetActive(true);
            --if offset < -10 then
                CC.HallNotificationCenter.inst():post(CC.Notifications.MATCHTIP,string.format(self.language.LANGUAGE_25,playerCount-myRank.rank));
            --end
        elseif offset > 0 then
            self.image_down:SetActive(true);
            self.image_down_slider:SetActive(true);
            CC.HallNotificationCenter.inst():post(CC.Notifications.MATCHTIP,string.format(self.language.LANGUAGE_26,playerCount-myRank.rank));
        end
        self.text_offset.text = tostring(math.abs(offset));
        self.text_rankOffset_slider.text = tostring(math.abs(offset));
    end
    self.lastRank = myRank.rank;
    self.text_rankNum_slider.text = "No."..tostring(myRank.rank);
    self.text_name.text = myRank.playerInfo.szNickName;
    self.text_score.text = CC.uu.numberToStrWithComma(myRank.lScore);
    if myRank.rank > 100 then
        self.text_rank.text = "100+";
    elseif myRank.rank > 3 then
        self.text_rank.text = tostring(myRank.rank);
    elseif myRank.rank > 0 then
        self.rank1_3[myRank.rank]:SetActive(true);
    end
end

function M:ResetSelfInfo()
    self.text_name.text = "";
    self.text_score.text = "";
    self.image_up:SetActive(false);
    self.image_down:SetActive(false);
    self.text_offset.text = "";
    self.image_up_slider:SetActive(false);
    self.image_down_slider:SetActive(false);
    self.text_rankNum_slider.text = "";
    self.text_rankOffset_slider.text = "";
    self.text_rank.text = "";
    for i = 1,3 do
        self.rank1_3[i]:SetActive(false);
    end
    if self.icon then
        CC.HeadManager.DestroyHeadIcon(self.icon);
        self.icon = nil;
    end
    if self.icon_slider then
        CC.HeadManager.DestroyHeadIcon(self.icon_slider);
        self.icon_slider = nil;
    end
    Util.ClearChild(self.iconPos,false);
    Util.ClearChild(self.iconPos_slider,false);
end

function M:RefreshPlayerCountAndRankSlider(count,myRank)
    self.text_playerCount:RollTo(count,2);
    if myRank.rank > 100 then
        self.slider_rank.value = (1 - (myRank.rank * 3 - 1)/(count - 1))  ----排名乘以3，因为总人数是假的，防止穿帮
    else
        self.slider_rank.value = count == 1 and 1 or (1 - (myRank.rank - 1)/(count - 1));
    end
end

function M:ResetPlayerCountAndRankSlider()
    self.slider_rank.value = 0;
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

-------------------------------------数据------------------------------------------
function M:RefreshRankData(info)
    local enMatch = info.enMatch;
    if info.arrRankInfo and #info.arrRankInfo > 0 then
        for i,v in ipairs(info.arrRankInfo) do
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

-------------------------------------其他------------------------------------------
function M:ClockTip(time)
    if time <= 10 then
        self.clock:SetActive(true);
        CC.Sound.PlayHallEffect("prepareClock")
        self.text_sec.text = tostring(time);
        if self.hasTipWillOver == false then
            CC.HallNotificationCenter.inst():post(CC.Notifications.MATCHTIP,self.language.LANGUAGE_47);
            self.hasTipWillOver = true
        end
    end
end

function M:CheckCanClickGift(time)
    if time <= 300 and self.hasCheckCanClickGift == false then ---最后五分钟而且未上榜，引导手指点击礼包
        CC.HallNotificationCenter.inst():post(CC.Notifications.MATCHGIFTGUIDE,true);
        CC.HallNotificationCenter.inst():post(CC.Notifications.MATCHTIP,self.language.LANGUAGE_37);
        self.hasCheckCanClickGift = true;
    end
end

function M:ShowCountDownAni(time)
    if time <= 10 then ---最后10秒，高亮提示时间
        self.animator.enabled = true;
    else
        self.animator.enabled = false;
    end
end

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

----------------------------------倒计时------------------------------------------
function M:RefreshCountDown(time,listener)
    self:StopTimer("matchTimer");
    self:RefreshTimeUI(time);
    self.remainTime = time;
    self:StartTimer("matchTimer", 1, function()
        time = time - 1;
        self.remainTime = time;
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
    self.startTime = nil;
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

function M:GetRemainTime()
    return self.remainTime;
end

-------------------------------------清理------------------------------------------
function M:DestroyChildViews()
    for k,view in pairs(self.childViews) do
        SlotMatchManager.inst():CloseView(view.viewName,true);
    end
    self.childViews = {};
end

function M:OnDestroy()
    for k,v in pairs(self.itemPool) do
        v:Reset();
    end
    self:ResetAll();
    self:UnRegisterEvent();
    self:StopTimer("matchTimer");
    self.rankList:DelectPool();
	self.rankList = nil;
end

return M


