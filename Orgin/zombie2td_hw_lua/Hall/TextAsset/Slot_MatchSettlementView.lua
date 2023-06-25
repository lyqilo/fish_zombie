--Author:lijundao
--Time:2020年08月18日 09:03:23 Tuesday
--Describe:

local CC = require("CC")
local M = CC.uu.ClassView("Slot_MatchSettlementView")
local SlotMatchManager = CC.SlotMatchManager
local slotMatch_message_pb = CC.slotMatch_message_pb
local GameobjectPool = require("Common/GameobjectPool");

-------------------------------------创建及初始化-----------------------------------
---param.GetSlotMatchRewardFunc ---获取比赛奖励方法
function M:ctor(param)
    self.param = param;
end

function M:OnCreate()
    self.language = CC.LanguageManager.GetLanguage("L_SlotMatch");
    self:Init();
    self:RegisterEvent();
    self:Reset();
end

function M:Init()
    local frame = self:FindChild("frame");
    local winNode = frame:FindChild("winNode");
    self.text_name = winNode:FindChild("text_name"):GetComponent("Text");
    self.text_winContent = winNode:FindChild("text_winContent"):GetComponent("Text");
    self.text_winRank = winNode:FindChild("text_winRank"):GetComponent("Text");
    self.image_chipBg = winNode:FindChild("rewardList/image_chipBg");
    self.text_chipCount = winNode:FindChild("rewardList/image_chipBg/text_chipCount"):GetComponent("Text");
    self.btn_share = winNode:FindChild("btn_share");
    winNode:FindChild("btn_share/text_share").text = self.language.LANGUAGE_40;
    self.btn_sure_win = winNode:FindChild("btn_sure");
    winNode:FindChild("btn_sure/text_sure").text = self.language.LANGUAGE_39;
    self.btn_rank_win = winNode:FindChild("btn_rank");
    self.text_tip = winNode:FindChild("text_tip");
    self.giftListScrollRect = winNode:FindChild("rewardList/giftList"):GetComponent("ScrollRect");
    local giftListContent = winNode:FindChild("rewardList/giftList/content");
    local giftPrefab = winNode:FindChild("matchGift").gameObject;
    self.giftPool = GameobjectPool.New(
        giftPrefab,
        function(obj)
            obj:SetActive(false);
            obj.transform:SetParent(giftListContent,false);
        end,
        function(obj)
            obj.transform:FindChild("image_giftIcon"):GetComponent("Image").sprite = nil;
            obj.transform:FindChild("text_giftCount").text = "";
        end,
        -1
    );

    local normalNode = frame:FindChild("normalNode");
    self.iconPos1 = normalNode:FindChild("iconPos1");
    self.text_name1 = normalNode:FindChild("text_name1"):GetComponent("Text");
    self.iconPos2 = normalNode:FindChild("iconPos2");
    self.text_name2 = normalNode:FindChild("text_name2"):GetComponent("Text");
    self.iconPos3 = normalNode:FindChild("iconPos3");
    self.text_name3 = normalNode:FindChild("text_name3"):GetComponent("Text");
    self.text_normalContent = normalNode:FindChild("text_normalContent"):GetComponent("Text");
    self.btn_rank_normal = normalNode:FindChild("btn_rank");
    self.btn_sure_normal = normalNode:FindChild("btn_sure");
    normalNode:FindChild("btn_sure/text_sure").text = self.language.LANGUAGE_36;

    self.frame = frame;
    self.winNode = winNode;
    self.normalNode = normalNode;
    self.corArray = {};
end

function M:RegisterEvent()
    self:AddClick(self.btn_share,"OnShareClick");
    self:AddClick(self.btn_sure_win,"OnSureClick_win");
    self:AddClick(self.btn_rank_win,"OnRankClick");
    self:AddClick(self.btn_rank_normal,"OnRankClick");
    self:AddClick(self.btn_sure_normal,"OnSureClick_normal");
    CC.HallNotificationCenter.inst():register(self,self.OnSlotGuideOver,CC.Notifications.OnSlotGuideOver)
    CC.HallNotificationCenter.inst():register(self,self.OnPushBalanceMatchInfo,CC.Notifications.BALANCEMATCHINFO);
end

function M:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self);
end

-------------------------------------------事件---------------------------------
function M:OnShareClick()
    local param = {};
    CC.SubGameInterface.CaptureScreenShare(param);
end

function M:OnSureClick_win()
    if self.param and self.param.GetSlotMatchRewardFunc then
        self.param.GetSlotMatchRewardFunc();
    end
    if self.openBackpack then
        local co = CC.uu.DelayRun(3,function()
            local backpackView = CC.ViewManager.OpenAndReplace("BackpackView");
            if backpackView.ClickGame then
                coroutine.step();
                backpackView:ClickGame();
            end
        end);
        self.openBackpack = false;
        table.insert(self.corArray,co);
    end
    if self.openEmail then
        local co = CC.uu.DelayRun(3,function()
            CC.ViewManager.Open("MailView");
        end);
        self.openEmail = false;
        table.insert(self.corArray,co);
    end
    SlotMatchManager.inst():CloseView(self.viewName);
end

function M:OnSureClick_normal()
    SlotMatchManager.inst():CloseView(self.viewName);
end

function M:OnRankClick()
    SlotMatchManager.inst():OpenView("Slot_MatchHistoryRankView");
end

function M:OnSlotGuideOver()
    self.isSlotGuideOver = true;
    if self.showViewFuncCache then
        self.showViewFuncCache();
        self.showViewFuncCache = nil;
    end
end

function M:OnPushBalanceMatchInfo(data)
    log(CC.uu.Dump(data,"OnPushBalanceMatchInfo",10))
    self.showViewFuncCache = function()
        self:Reset();
        self:Refresh(data);
    end
    if self.isSlotGuideOver then
        self.showViewFuncCache();
        self.showViewFuncCache = nil;
    end
end

---------------------------------显示------------------------------------------
function M:Refresh(info)
    if info.data.rank == 0 and (info.arrRankInfo == nil or #info.arrRankInfo == 0) then
        return;
    end
    if info.data.score > 0 then
        self:RefreshWinNode(info.data,info.enMatch);
    elseif info.data.rank > 0 then
        self:RefreshNormalNode(info.arrRankInfo,true,info.data.rank,info.enMatch);
    elseif info.data.rank == 0 then
        self:RefreshNormalNode(info.arrRankInfo,false,nil,info.enMatch);
    end
    self:ActionIn();
end

function M:Reset()
    self:ResetWinNode();
    self:ResetNormalNode();
    self:ActionOut(true);
end

function M:RefreshWinNode(info,enMatch)
    if info.playerId ~= CC.Player.Inst():GetSelfInfoByKey("Id") then
        Util.LogError("赢的人不是自己")
        return;
    end
    local rewardCountMap = {};
    local itemCount = 0;
    for k,v in ipairs(info.props or {}) do
        rewardCountMap[v.PropId] = rewardCountMap[v.PropId] == nil and v.Count or (rewardCountMap[v.PropId] + v.Count);
        itemCount = itemCount + 1;
    end
    local hasGift = false;
    self.openBackpack = false;
    self.openEmail = false;
    for k,v in pairs(rewardCountMap) do
        local gift = self.giftPool:Get();
        local spriteName = "prop_img_"..k;
        local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[spriteName..".png"];
        gift.transform:FindChild("image_giftIcon"):GetComponent("Image").sprite = CC.uu.LoadImgSprite(spriteName,abName);
        gift.transform:FindChild("text_giftCount").text = "X"..v;
        hasGift = true;
        if k == CC.shared_enums_pb.EPC_PointCard_Fragment then
            self.openBackpack = true;
        elseif k == CC.shared_enums_pb.EPC_50Card_zgold then
            self.openEmail = true;
        elseif k == CC.shared_enums_pb.EPC_100Card_zgold then
            self.openEmail = true;
        elseif k == CC.shared_enums_pb.EPC_300Card_zgold then
            self.openEmail = true;
        elseif k == CC.shared_enums_pb.EPC_500Card_zgold then
            self.openEmail = true;
        elseif k == CC.shared_enums_pb.EPC_Gold_Necklace_Quarter then
            self.openEmail = true;
        elseif k == CC.shared_enums_pb.EPC_50Card then
            self.openEmail = true;
        elseif k == CC.shared_enums_pb.EPC_150Card then
            self.openEmail = true;
        elseif k == CC.shared_enums_pb.EPC_300Card then
            self.openEmail = true;
        elseif k == CC.shared_enums_pb.EPC_500Card then
            self.openEmail = true;
        elseif k == CC.shared_enums_pb.EPC_1000Card then
            self.openEmail = true;
        elseif k == CC.shared_enums_pb.EPC_90Card then
            self.openEmail = true;
        end
    end
    if itemCount > 1 then
        local deltaPos = 1/(itemCount - 1);
        self.giftListScrollRect.horizontalNormalizedPosition = 0;
        local tempCount = itemCount - 1;
        local loopShowFunc = nil;
        loopShowFunc = function()
            self.loopShowCor = CC.uu.DelayRun(2,function()
                if tempCount > 0 then
                    self.giftListScrollRect.horizontalNormalizedPosition = self.giftListScrollRect.horizontalNormalizedPosition + deltaPos;
                    tempCount = tempCount - 1;
                else
                    self.giftListScrollRect.horizontalNormalizedPosition = 0;
                    tempCount = itemCount - 1;
                end
                loopShowFunc();
            end);
        end
        loopShowFunc();
    end
    self.text_name.text = CC.Player.Inst():GetSelfInfoByKey("Nick");
    if enMatch == slotMatch_message_pb.En_Match_Primary then
        self.text_winContent.text = self.language.LANGUAGE_9;
    elseif enMatch ~= slotMatch_message_pb.En_Match_High then
        self.text_winContent.text = self.language.LANGUAGE_10;
    else
        self.text_winContent.text = self.language.LANGUAGE_11;
    end
    self.text_winRank.text = tostring(info.rank);
    self.image_chipBg.localScale = (hasGift and Vector3(1,1,1) or Vector3(1.6,1.6,1));
    self.text_chipCount.text = CC.uu.ChipFormat(info.score,true);
    self.winNode:SetActive(true);
    self.giftListScrollRect:GetComponent("RectTransform").width = hasGift and 161 or 0;
    self.text_tip.text = hasGift and self.language.LANGUAGE_52 or "";
end

function M:ResetWinNode(info)
    self.text_name.text = "";
    self.text_winContent.text = "";
    self.text_winRank.text = "";
    self.image_chipBg.localScale = Vector3(1,1,1);
    self.text_chipCount.text = "";
    self.winNode:SetActive(false);
    self.text_tip.text = "";
    self.giftPool:RecycleAll();
    if self.loopShowCor then
        CC.uu.CancelDelayRun(self.loopShowCor);
        self.loopShowCor = nil;
    end
end

---isPlayed   参与了
function M:RefreshNormalNode(info,isPlayed,selfRank,enMatch)
    local count = #info > 3 and 3 or #info;
    for i = 1,count do
        local rankInfo = info[i];
        local icon = nil;
        local portrait = rankInfo.playerInfo.szPortrait;
        if portrait == "nil" then
            portrait = "";
        end
        if rankInfo.rank == 1  then
            self.icon1 = CC.HeadManager.CreateHeadIcon({parent = self.iconPos1,clickFunc = "unClick",unShowVip = true,portrait = portrait,playerId = rankInfo.playerInfo.playerId});
            self.text_name1.text = rankInfo.playerInfo.szNickName;
        elseif rankInfo.rank == 2 then
            self.icon2 = CC.HeadManager.CreateHeadIcon({parent = self.iconPos2,clickFunc = "unClick",unShowVip = true,portrait = portrait,playerId = rankInfo.playerInfo.playerId});
            self.text_name2.text = rankInfo.playerInfo.szNickName;
        elseif rankInfo.rank == 3 then
            self.icon3 = CC.HeadManager.CreateHeadIcon({parent = self.iconPos3,clickFunc = "unClick",unShowVip = true,portrait = portrait,playerId = rankInfo.playerInfo.playerId});
            self.text_name3.text = rankInfo.playerInfo.szNickName;
        end
    end

    local matchName = nil
    if enMatch == slotMatch_message_pb.En_Match_Primary then
        matchName = self.language.LANGUAGE_19;
    elseif enMatch == slotMatch_message_pb.En_Match_Middle then
        matchName = self.language.LANGUAGE_20;
    else
        matchName = self.language.LANGUAGE_21;
    end

    if isPlayed then
        self.text_normalContent.text = string.format(self.language.LANGUAGE_12_1,matchName,selfRank,SlotMatchManager.inst():GetContextInfoByKey("timeQuantum"));
    else
        self.text_normalContent.text = string.format(self.language.LANGUAGE_12_2,matchName,SlotMatchManager.inst():GetContextInfoByKey("timeQuantum"));
    end
    self.normalNode:SetActive(true);
end

function M:ResetNormalNode()
    if self.icon1 then
        CC.HeadManager.DestroyHeadIcon(self.icon1);
		self.icon1 = nil;
    end
    if self.icon2 then
        CC.HeadManager.DestroyHeadIcon(self.icon2);
		self.icon2 = nil;
    end
    if self.icon3 then
        CC.HeadManager.DestroyHeadIcon(self.icon3);
		self.icon3 = nil;
    end
    Util.ClearChild(self.iconPos1,false);
    Util.ClearChild(self.iconPos2,false);
    Util.ClearChild(self.iconPos3,false);
    self.text_name1.text = "";
    self.text_name2.text = "";
    self.text_name3.text = "";
    self.text_normalContent.text = "";
    self.normalNode:SetActive(false);
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
    self.transform:SetActive(true);
    self.isOpen = true;
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

-------------------------------------清理------------------------------------------
function M:OnDestroy()
    self:Reset();
    self:UnRegisterEvent();
    for k,v in pairs(self.corArray) do
        CC.uu.CancelDelayRun(v);
    end
    self.corArray = {};
end
return M


