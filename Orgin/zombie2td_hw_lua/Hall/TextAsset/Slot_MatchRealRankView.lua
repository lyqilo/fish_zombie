--Author:lijundao
--Time:2020年08月18日 09:03:23 Tuesday
--Describe:
local Slot_MatchRealRankItem = require("View/SlotMatch/Slot_MatchRealRankItem")
local CC = require("CC")
local M = CC.uu.ClassView("Slot_MatchRealRankView")
local slotMatch_message_pb = CC.slotMatch_message_pb

-------------------------------------创建及初始化-----------------------------------
function M:GlobalNode()
	return GameObject.Find(self.param.parentPath).transform
end

function M:GlobalLayer()
	return "UI"
end

function M:ctor(param)
    self.param = param
    self.delayRunCos = {};
end

function M:OnOpen()
    self:ActionIn(true);
    local giftIcon = CC.SlotMatchManager.inst():GetGiftIcon();
    self.transform:SetSiblingIndex(giftIcon.transform:GetSiblingIndex()-1);
    self:Reset();
    self:ResetRankData();
    if self.param and self.param.GetAllRealTimeRankInfo then
        local oneReqCount = 10
        for i=1,10 do
            table.insert(self.delayRunCos,CC.uu.DelayRun(self.reqIntervalTime * i,function() self.param.GetAllRealTimeRankInfo((i-1)*oneReqCount, i*oneReqCount-1); end));
        end
    end
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
    self.text_matchTitle = node:FindChild("text_matchTitle"):GetComponent("Text");
    local selfInfo = node:FindChild("selfInfo");
    self.image_up = selfInfo:FindChild("image_up");
    self.image_down = selfInfo:FindChild("image_down");
    self.text_name = selfInfo:FindChild("text_name"):GetComponent("Text");
    self.text_offset = selfInfo:FindChild("text_offset"):GetComponent("Text");
    self.iconPos = selfInfo:FindChild("iconPos");
    self.icon = CC.HeadManager.CreateHeadIcon({parent = self.iconPos,clickFunc = "unClick",unShowVip = true});

    self.rankList = node:FindChild("rankList"):GetComponent("LoopScrollRect");

    self.node = node;
    self.itemPool = {};
    self.reqIntervalTime = 0.1;
end

function M:RegisterEvent()
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
    --CC.HallNotificationCenter.inst():register(self,self.OnPushProcessMatchInfo,CC.Notifications.PROCESSMATCHINFO);
    CC.HallNotificationCenter.inst():register(self,self.OnPushAllRealtimeRankInfo,CC.Notifications.ALLREALTIMERANKINFO);
end

function M:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self);
end

-------------------------------------------事件---------------------------------
--[[function M:OnPushProcessMatchInfo(data)
    log(CC.uu.Dump(data,"OnPushProcessMatchInfo",10))
    self:RefreshRankData(data);
    self:Reset();
    self:Refresh(data);
end--]]

function M:OnPushAllRealtimeRankInfo(data)
    log(CC.uu.Dump(data,"OnPushAllRealtimeRankInfo",10))
    if data.arrRankInfo == nil or #data.arrRankInfo <= 0 then
        return;
    end
    self:RefreshRankData(data);
    --self:Reset();
    self:Refresh(data);
end

---------------------------------显示------------------------------------------
function M:Refresh(info)
    self.enMatch = info.enMatch;
    self:RefreshMatchTitle();
    self:RefreshRankList();
    --self:RefreshSelfInfo(info.myRank);
end

function M:Reset()
    self.enMatch = nil;
    self:ResetMatchTitle();
    self:ResetRankList();
    self:ResetSelfInfo();
end

------结算后清空处理
function M:ResetAll()
    self:ResetRankData();
    self:ResetRankList();
    self:Reset();
end

function M:RefreshMatchTitle()
    if self.enMatch == slotMatch_message_pb.En_Match_Primary then----非vip
        self.text_matchTitle.text = self.language.LANGUAGE_13;
    elseif self.enMatch == slotMatch_message_pb.En_Match_Middle then----精英
        self.text_matchTitle.text = self.language.LANGUAGE_14;
    elseif self.enMatch == slotMatch_message_pb.En_Match_High then----牛人
        self.text_matchTitle.text = self.language.LANGUAGE_15;
    end
end

function M:ResetMatchTitle()
    self.text_matchTitle.text = "";
end

function M:RefreshRankList()
    self.rankList.totalCount = #self.rankData[self.enMatch];
end

function M:ResetRankList()
    self.rankList:ClearCells();
end

function M:RefreshSelfInfo(myRank)
    self.icon:SetImage("Mask/Image",CC.HeadManager.GetHeadIconPathById(myRank.playerInfo.szPortrait));
    if self.lastRank then
        local offset = myRank.rank - self.lastRank;
        if offset < 0 then
            self.image_up:SetActive(true);
        elseif offset > 0 then
            self.image_down:SetActive(true);
        end
        self.text_offset.text = tostring(math.abs(offset))
    end
    self.lastRank = myRank.rank;
    self.text_name.text = myRank.playerInfo.szNickName;
end

function M:ResetSelfInfo()
    self.image_up:SetActive(false);
    self.image_down:SetActive(false);
    self.text_name.text = "";
    self.text_offset.text = "0";
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
    for k,v in pairs(self.delayRunCos) do
        CC.uu.CancelDelayRun(v)
    end
    self.delayRunCos = {};
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

-------------------------------------清理------------------------------------------
function M:OnDestroy()
    for k,v in pairs(self.itemPool) do
        v:Reset();
    end
    self:UnRegisterEvent();
    self.rankList:DelectPool()
    self.rankList = nil
    CC.HeadManager.DestroyHeadIcon(self.icon);
end
return M


