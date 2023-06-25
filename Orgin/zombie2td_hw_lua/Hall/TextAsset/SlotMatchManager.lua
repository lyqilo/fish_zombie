--Author:AQ
--Time:2020年08月31日 17:31:29 Monday
--Describe:

local CC = require "CC"
local M = CC.class2("SlotMatchManager")
local Slot_MatchGiftIcon = require("View/SlotMatch/Slot_MatchGiftIcon")
local Slot_MatchHistoryRankIcon = require("View/SlotMatch/Slot_MatchHistoryRankIcon")
local SubGameInterface = CC.SubGameInterface
local slotMatch_message_pb = CC.slotMatch_message_pb

function M:ctor()
    self.views = {};
    self.giftIcon = nil;
    self.rankIcon = nil;
end

--静态方法
local _inst = nil
function M.inst()
	if not _inst then
		_inst = M.new()
	end
	return _inst
end

----param.xxxViewParam   哪个View的参数
function M:Init(param)
    if #self.views > 0 then
        logError("上一次的view尚未释放");
        return;
    end
    self.language = CC.LanguageManager.GetLanguage("L_SlotMatch")
    self.param = param.managerParam;
    self:CreateView("Slot_MatchPrepareView",param.prepareViewParam);
    self:CreateView("Slot_MatchDoingView",param.doingViewParam);
    self:CreateView("Slot_MatchRealRankView",param.realRankViewParam);
    self:CreateView("Slot_MatchRewardRankView",param.rewardRankViewParam);
    self:CreateIcon(param.giftIconParam,param.rankIconParam);
    self:CreateView("Slot_MatchTipsView");
    self:CreateView("Slot_MatchSettlementView",param.settlementViewParam);
    self:CreateView("Slot_MatchHelpView");
    self:CreateView("Slot_MatchHistoryRankView",param.historyRankViewParam);
    self:CreateView("Slot_MatchGiftView",param.giftViewParam);
    self:CreateView("Slot_MatchRewardsView");

    self:RegisterEvent();
    self:ReqMatchStage();
end

function M:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnContext,CC.Notifications.SLOTMATCHCONTEXT);
    CC.HallNotificationCenter.inst():register(self,self.OnMatchStage,CC.Notifications.MATCHSTAGE);
    CC.HallNotificationCenter.inst():register(self,self.OnPushStageChange,CC.Notifications.STAGECHANGE);
    CC.HallNotificationCenter.inst():register(self,self.OnSlotGuideOver,CC.Notifications.OnSlotGuideOver)
end

function M:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self);
end

function M:OnContext(data)
    log(CC.uu.Dump(data,"OnContext",10))
    self.context = data;
    
    local checkGiftReward = function ()
        local giftReward = self:GetContextInfoByKey("giftReward");
        if giftReward and giftReward > 0 then
            CC.ViewManager.ShowMessageBox(string.format(self.language.LANGUAGE_50,giftReward),
            function() 
                if self.param.AddRewardFunc then 
                    self.param.AddRewardFunc({giftReward = giftReward});
                    CC.uu.DelayRun(1,function()
                        if CC.Notifications.OnCanShowNotice then
                            CC.HallNotificationCenter.inst():post(CC.Notifications.OnCanShowNotice,true);
                        end
                    end);
                end 
            end):SetOneButton();
        else
            if CC.Notifications.OnCanShowNotice then
                CC.HallNotificationCenter.inst():post(CC.Notifications.OnCanShowNotice,true);
            end
        end
    end
    local upDataNotify = self:GetContextInfoByKey("notify");
    local playerId = CC.Player.Inst():GetSelfInfoByKey("Id");
    --[[if upDataNotify and #upDataNotify > 0 and Util.GetFromPlayerPrefs("slotMatchNotify") ~= playerId..os.date("%Y-%m-%d") then
        self.guideOverDo = function()
            self:OpenView("Slot_MatchHelpView",self.language.LANGUAGE_51,upDataNotify,function() checkGiftReward(); end);
            Util.SaveToPlayerPrefs("slotMatchNotify",playerId..os.date("%Y-%m-%d"));
        end
    else
        self.guideOverDo = checkGiftReward;
    end]]
    
    --[[if Util.GetFromPlayerPrefs("showHelpView") ~= playerId..os.date("%Y-%m-%d") then
        self.guideOverDo = function()
            self:OpenView("Slot_MatchHelpView",nil,nil,function() checkGiftReward(); end);
            Util.SaveToPlayerPrefs("showHelpView",playerId..os.date("%Y-%m-%d"));
        end
    else
        self.guideOverDo = checkGiftReward;
    end--]]

    self.guideOverDo = checkGiftReward;
end

function M:GetContextInfoByKey(key)
    if self.context == nil then
        logError("尚未拿到服务器上下文信息");
        local defaultValue = nil;
        if key == "MatchFlag" then
            defaultValue = 0;
        elseif key == "giftReward" then
            defaultValue = 0;
        elseif key == "notify" then
            defaultValue = "";
        elseif key == "matchDate" then
            defaultValue = nil;
        elseif key == "matchInfo" then
            defaultValue = nil;
        elseif key == "timeQuantum" then
            defaultValue = "00:10-00:40、19:50-20:20、22:10-22:40";
        elseif key == "matchTime" then
            defaultValue = 30;
        elseif key == "matchRewardCount" then
            defaultValue = {100,50,20};
        elseif key == "Text" then
            defaultValue = {};
        elseif key == "PropValue" then
            defaultValue = {};
        elseif key == "TopProps" then
            defaultValue = {{},{},{}};
        end
        return defaultValue;
    end
    if key == "MatchFlag" then
        return self.context.MatchFlag;
    elseif key == "giftReward" then
        return self.context.giftReward;
    elseif key == "notify" then
        return self.context.gameConfigs.notify;
    elseif key == "matchDate" then
        return self.context.gameConfigs.matchDate;
    elseif key == "matchInfo" then
        return self.context.gameConfigs.matchInfo;
    elseif key == "timeQuantum" then
        local timeQuantumStr = "";
        local matchTime = self.context.gameConfigs.matchDate[1].matchTime;
        for i,v in ipairs(self.context.gameConfigs.matchDate) do
            timeQuantumStr = timeQuantumStr .. self:GetTimeStr(v.startTime).."-"..self:GetTimeStr(v.startTime + matchTime);
            if i < #self.context.gameConfigs.matchDate then
                timeQuantumStr = timeQuantumStr .. "、"
            end
        end
        return  timeQuantumStr;
    elseif key == "matchTime" then
        return self.context.gameConfigs.matchDate[1].matchTime/60;
    elseif key == "matchRewardCount" then
        local countArray = {};
        for i,v in ipairs(self.context.gameConfigs.matchInfo) do
            table.insert(countArray,(v.reward[#v.reward].Rank)[#(v.reward[#v.reward].Rank)]);
        end
        return countArray;
    elseif key == "Text" then
        return self.context.Text;
    elseif key == "PropValue" then
        if self.PropValue == nil then
            self.PropValue = {};
            for k,v in ipairs(self.context.PropValue) do
                self.PropValue[v.PropId] = v.Count;
            end
        end
        return self.PropValue;
    elseif key == "TopProps" then
        return self.context.TopProps;
    end
end

function M:GetTimeStr(seconds,showSecond)
    local hour = math.floor(seconds/3600);
    local minute = math.floor(seconds%3600/60);
    local second = math.floor(seconds%3600%60);

    if showSecond then
        return string.format("%02d:%02d:%02d",hour,minute,second);
    else
        return string.format("%02d:%02d",hour,minute);
    end
end

function M:OnMatchStage(data)
    log(CC.uu.Dump(data,"OnMatchStage",10))
    if data.matchStage.curStage == slotMatch_message_pb.En_Stage_Game then
        if SubGameInterface.TrackEnterMatchGame then
            SubGameInterface.TrackEnterMatchGame(CC.ViewManager.GetCurGameId());
        end
    end
    if data.giftReward and data.giftReward > 0 then
        CC.ViewManager.ShowMessageBox(string.format(self.language.LANGUAGE_50,data.giftReward),function() if self.param.AddRewardFunc then self.param.AddRewardFunc(data) end end):SetOneButton();
    end
end

function M:OnPushStageChange(data)
    log(CC.uu.Dump(data,"OnPushStageChange",10))
    if data.matchStage.curStage == slotMatch_message_pb.En_Stage_Game then
        if SubGameInterface.TrackEnterMatchGame then
            SubGameInterface.TrackEnterMatchGame(CC.ViewManager.GetCurGameId());
        end
    elseif data.matchStage.curStage == slotMatch_message_pb.En_Stage_Balance then
        for name,view in pairs(self.views) do
            if view.ResetAll then
                CC.uu.DelayRun(0.2,function()
                    view:ResetAll();
                end);
            end
        end
    end
end

function M:OnSlotGuideOver()
    if self.guideOverDo then
        self.guideOverDo();
        self.guideOverDo = nil;
    end
end

function M:OpenView(viewName,...)
    local view = nil;
    if self.views[viewName] then
        view = self.views[viewName];
    else
        view = self:CreateView(viewName);
    end
    if view.OnOpen then
        view.transform:SetAsLastSibling();
        view:OnOpen(...);
    end
    return view;
end

function M:GetView(viewName)
    return self.views[viewName];
end

function M:GetGiftIcon()
    return self.giftIcon;
end

function M:CloseView(viewName,immediately)
    if self.views[viewName] then
        self.views[viewName]:ActionOut(immediately);
    end
end

function M:CreateView(viewName,param)
    if self.views[viewName] then
        return self.views[viewName];
    end
    local newView = CC.uu.CreateHallView(viewName,param);
    self.views[viewName] = newView;
    return newView;
end

function M:CreateIcon(giftIconParam,rankIconParam)
    if not self.giftIcon then
        self.giftIcon = Slot_MatchGiftIcon.new(giftIconParam);
        self.giftIcon:Create();
    end
    if not self.rankIcon then
        self.rankIcon = Slot_MatchHistoryRankIcon.new(rankIconParam);
        self.rankIcon:Create();
    end
end

function M:DestroyIcons()
    if self.giftIcon then
        self.giftIcon:Destroy();
        self.giftIcon = nil;
    end
    if self.rankIcon then
        self.rankIcon:Destroy();
        self.rankIcon = nil;
    end
end

function M:ReqMatchStage()
    if self.param and self.param.ReqMatchStageFunc then
        self.param.ReqMatchStageFunc();
    end
end

function M:DestroyViews()
    for k,v in pairs(self.views) do
        v:Destroy();
    end
    self.views = {};
end

function M:Release()
    self:DestroyViews();
    self:DestroyIcons();
    self:UnRegisterEvent();
    self.guideOverDo = nil;
end



return M