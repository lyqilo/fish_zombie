--Author:lijundao
--Time:2020年08月18日 09:03:23 Tuesday
--Describe:
local Slot_MatchRewardRankItem = require("View/SlotMatch/Slot_MatchRewardRankItem")
local CC = require("CC")
local M = CC.uu.ClassView("Slot_MatchRewardRankView")
local slotMatch_message_pb = CC.slotMatch_message_pb
local Slot_MatchUtils = require("View/SlotMatch/Slot_MatchUtils")

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

function M:OnOpen(enMatch)
    self:ResetRankData();
    self:Reset();
    self.enMatch = enMatch;
    self:ActionIn(true);
    if self.param and self.param.ReqMatchRewardRankFunc then
        self.param.ReqMatchRewardRankFunc(self.enMatch);
    end
    local giftIcon = CC.SlotMatchManager.inst():GetGiftIcon();
    self.transform:SetSiblingIndex(giftIcon.transform:GetSiblingIndex()-1);
end

function M:OnCreate()
    self.language = CC.LanguageManager.GetLanguage("L_SlotMatch");
    self:Init();
    self:RegisterEvent();
    self:ResetRankData();
    self:Reset();
    self:ActionOut(true);
end

function M:Init()
    local node = self:FindChild("node");
    self.text_awardTip = node:FindChild("text_awardTip"):GetComponent("Text");
    self.rankList = node:FindChild("rankList"):GetComponent("LoopScrollRect");

    self.node = node;
    self.itemPool = {};
end

function M:RegisterEvent()
    self.rankList:AddChangeItemListener(function(tran,index)
        local rank = index+1;
        if self.rankData[self.enMatch] and self.rankData[self.enMatch][rank] then
            tran.name = tostring(rank)
            local item = Slot_MatchRewardRankItem.new(tran.gameObject);
            item:Reset();
            item:Refresh(self.rankData[self.enMatch][rank],rank);
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
    CC.HallNotificationCenter.inst():register(self,self.OnReqMatchRewardRank,CC.Notifications.MATCHREWARDRANK);
end

function M:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self);
end

-------------------------------------------事件---------------------------------
function M:OnReqMatchRewardRank(data)
    log(CC.uu.Dump(data,"OnReqMatchRewardRank",10))
    self:RefreshRankData(data)
    self:Reset();
    self:Refresh(data);
end

---------------------------------显示------------------------------------------
function M:Refresh(info)
    self:RefreshAwardTip(info.enMatch);
    self:RefreshRankList();
end

function M:Reset()
    self:ResetAwardTip();
    self:ResetRankList();
end

------结算后清空处理
function M:ResetAll()
    self:ResetRankData();
    self:Reset();
end

function M:RefreshAwardTip(enMatch)
    enMatch = Slot_MatchUtils.Return0IfNil(enMatch);
    if enMatch == slotMatch_message_pb.En_Match_Primary then----非vip
        self.text_awardTip.text = self.language.LANGUAGE_5;
    elseif enMatch == slotMatch_message_pb.En_Match_Middle then----精英
        self.text_awardTip.text = self.language.LANGUAGE_6;
    elseif enMatch == slotMatch_message_pb.En_Match_High then----牛人
        self.text_awardTip.text = self.language.LANGUAGE_7;
    end
end

function M:ResetAwardTip()
    self.text_awardTip.text = "";
end

function M:RefreshRankList()
    self.rankList.totalCount = #self.rankData[self.enMatch];
end

function M:ResetRankList()
    self.rankList:ClearCells();
end

function M:ActionIn(immediately)
    if self.isOpen then
        return;
    end
    self.node:SetActive(true);
    self.transform:SetActive(true);
    if immediately then
        self.node.localPosition = Vector3(-390,0,0);
    else
        self.node.localPosition = Vector3(390,0,0);
        self:RunAction(self.node, {"localMoveTo", -390, 0, 0.3, ease = CC.Action.EInOutQuart, function()
    
        end});
    end
    self.isOpen = true;
end

function M:ActionOut(immediately)
    if self.isOpen == false then
        return;
    end
    if immediately then
        self.node.localPosition = Vector3(390,0,0);
        self.node:SetActive(false);
        self.transform:SetActive(false);
    else
        self:RunAction(self.node, {"localMoveTo", 390, 0, 0.3, ease = CC.Action.EInOutQuart, function()
            self.node:SetActive(false);
            self.transform:SetActive(false);
        end});
    end
    self.isOpen = false;
end

-------------------------------------数据------------------------------------------
function M:RefreshRankData(info)
    local enMatch = Slot_MatchUtils.Return0IfNil(info.enMatch);
    if info.propsRank and #info.propsRank > 0 then
        for i,v in ipairs(info.propsRank) do
            self.rankData[enMatch][i] = v;
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

-------------------------------------清理------------------------------------------
function M:OnDestroy()
    self:UnRegisterEvent();
    self.rankList:DelectPool()
	self.rankList = nil
end
return M


