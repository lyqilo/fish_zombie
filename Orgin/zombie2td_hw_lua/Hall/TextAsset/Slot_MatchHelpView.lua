--Author:lijundao
--Time:2020年08月18日 09:03:23 Tuesday
--Describe:

local CC = require("CC")
local M = CC.uu.ClassView("Slot_MatchHelpView")
local SlotMatchManager = CC.SlotMatchManager

-------------------------------------创建及初始化-----------------------------------
function M:OnOpen(otherTitle,otherStr,closeCallback)
    self:Reset();
    self:Refresh(otherTitle,otherStr,closeCallback);
end

function M:OnCreate( ... )
    self.language = CC.LanguageManager.GetLanguage("L_SlotMatch");
    self:Init();
    self:RegisterEvent();
    self:Reset();
end

function M:Init()
    self.frame = self:FindChild("frame");
    self.contentList = self.frame:FindChild("content/contentList");
    self.text_content = self.frame:FindChild("content/contentList/text_content");
    self.text_rewardContent = self.frame:FindChild("content/contentList/text_rewardContent");
    self.text_title = self.frame:FindChild("title/text_title");
    self.btn_close = self.frame:FindChild("btn_close");
    self.dayMatchToggle = self.frame:FindChild("content/contentList/text_rewardContent/matchListToggle/dayMatchToggle");
    self.dayMatchToggleCom = self.dayMatchToggle:GetComponent("Toggle");
    self.weekMatchToggle = self.frame:FindChild("content/contentList/text_rewardContent/matchListToggle/weekMatchToggle");
    self.weekMatchToggleCom = self.weekMatchToggle:GetComponent("Toggle");
    self.monthMatchToggle = self.frame:FindChild("content/contentList/text_rewardContent/matchListToggle/monthMatchToggle");
    self.monthMatchToggleCom = self.monthMatchToggle:GetComponent("Toggle");
    self.frame:FindChild("content/contentList/text_rewardContent/matchListToggle/dayMatchToggle/Label").text = self.language.LANGUAGE_56;
    self.frame:FindChild("content/contentList/text_rewardContent/matchListToggle/weekMatchToggle/Label").text = self.language.LANGUAGE_57;
    self.frame:FindChild("content/contentList/text_rewardContent/matchListToggle/monthMatchToggle/Label").text = self.language.LANGUAGE_58;
end

function M:RegisterEvent()
    self:AddClick(self.btn_close,"OnCloseClick");
    UIEvent.AddToggleValueChange(self.dayMatchToggle, function(selected) if selected then self.text_rewardContent.text = "\n\n"..self.language.LANGUAGE_53;self:ForceRebuildLayoutImmediate(); end end);
    UIEvent.AddToggleValueChange(self.weekMatchToggle, function(selected) if selected then self.text_rewardContent.text = "\n\n"..self.language.LANGUAGE_54;self:ForceRebuildLayoutImmediate(); end end);
    UIEvent.AddToggleValueChange(self.monthMatchToggle, function(selected) if selected then self.text_rewardContent.text = "\n\n"..self.language.LANGUAGE_55;self:ForceRebuildLayoutImmediate(); end end);
    CC.HallNotificationCenter.inst():register(self,self.OnContext,CC.Notifications.SLOTMATCHCONTEXT);
end

function M:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self);
end

-------------------------------------------事件---------------------------------
function M:OnCloseClick()
    SlotMatchManager.inst():CloseView(self.viewName);
    if self.closeCallback then
        self.closeCallback();
        self.closeCallback = nil;
    end
end

function M:OnContext(data)
    log(CC.uu.Dump(data,"OnContext",10))
    CC.uu.DelayRun(0.1,function()
        self:DealShowContent();
    end);
end
-------------------------------------------显示---------------------------------
function M:Refresh(otherTitle,otherStr,closeCallback)
    if self.showStr == nil then
        self:DealShowContent();
    end
    self.text_title.text = otherTitle and otherTitle or self.language.LANGUAGE_24;
    self.text_content.text = otherStr and otherStr or self.showStr;
    self.monthMatchToggleCom.isOn = true;
    self.closeCallback = closeCallback;
    coroutine.start(function()
        coroutine.step();
        self.text_content.gameObject:SetActive(true);
        self.text_rewardContent.gameObject:SetActive(otherTitle == nil);
        self:ForceRebuildLayoutImmediate();
    end)
    self:ActionIn();
end

function M:Reset()
    self.text_content.text = "";
    self.text_rewardContent.text = "";
    self.dayMatchToggleCom.isOn = false;
    self.weekMatchToggleCom.isOn = false;
    self.monthMatchToggleCom.isOn = false;
    self.text_content.gameObject:SetActive(false);
    self.text_rewardContent.gameObject:SetActive(false);
    self.transform:SetActive(false);
    self.closeCallback = nil;
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

function M:DealShowContent()
    local timeQuantum = SlotMatchManager.inst():GetContextInfoByKey("timeQuantum");--参赛时间段
    local matchTime = SlotMatchManager.inst():GetContextInfoByKey("matchTime");---比赛时间
    local matchRewardCount = SlotMatchManager.inst():GetContextInfoByKey("matchRewardCount");---奖励人数
    self.showStr = string.format(self.language.LANGUAGE_8,timeQuantum,matchTime,matchRewardCount[1],matchRewardCount[2],matchRewardCount[3]);
end

function M:OnDestroy()
    self:UnRegisterEvent();
end

function M:ForceRebuildLayoutImmediate()
    LayoutRebuilder.ForceRebuildLayoutImmediate(self.text_content);
    LayoutRebuilder.ForceRebuildLayoutImmediate(self.text_rewardContent);
    LayoutRebuilder.ForceRebuildLayoutImmediate(self.contentList);
end

return M


