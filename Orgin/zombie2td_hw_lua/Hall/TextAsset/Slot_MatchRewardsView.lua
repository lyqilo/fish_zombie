--Author:AQ
--Time:2020年09月03日 01:21:03 Thursday
--Describe:

local CC = require("CC")
local M = CC.uu.ClassView("Slot_MatchRewardsView")
local SlotMatchManager = CC.SlotMatchManager
local Slot_MatchUtils = require("View/SlotMatch/Slot_MatchUtils")

function M:OnOpen(info)
    self:Reset();
    self:Refresh(info);
end

function M:OnCreate( ... )
    self.language = CC.LanguageManager.GetLanguage("L_SlotMatch");
    self:Init();
    self:RegisterEvent();
    self:Reset();
end

function M:Init()
    local frame = self:FindChild("frame");
	frame:FindChild("title/text_title"):GetComponent("Text").text = self.language.LANGUAGE_35
    self.btn_close = frame:FindChild("btn_close");
    self.btn_close:FindChild("Text").text = self.language.LANGUAGE_39;
    self.text_baseReward = frame:FindChild("baseReward/bg/text_count"):GetComponent("Text");
    local rewardAddition = frame:FindChild("rewardAddition");
    rewardAddition:FindChild("bg/text_countPrefix"):GetComponent("Text").text = self.language.LANGUAGE_33;
    self.text_rewardAddition = rewardAddition:FindChild("bg/text_count"):GetComponent("Text");
    local scoreAddition = frame:FindChild("scoreAddition");
    scoreAddition:FindChild("bg/text_countPrefix"):GetComponent("Text").text = self.language.LANGUAGE_34;
    self.text_scoreAddition = scoreAddition:FindChild("bg/text_count"):GetComponent("Text");

    self.frame = frame;
end

function M:RegisterEvent()
	self:AddClick(self.btn_close, "OnCloseClick");
end

-----------------------------事件------------------------
function M:OnCloseClick()
    SlotMatchManager.inst():CloseView(self.viewName);
    SlotMatchManager.inst():CloseView("Slot_MatchGiftView");
end

-----------------------------显示-------------------------
function M:Refresh(info)
    self.text_baseReward.text = CC.uu.ChipFormat(Slot_MatchUtils.Return0IfNil(info.baseReward),true);
    self.text_rewardAddition.text = CC.uu.ChipFormat(Slot_MatchUtils.Return0IfNil(info.extraReward));
    self.text_scoreAddition.text = CC.uu.ChipFormat(Slot_MatchUtils.Return0IfNil(info.extraScore));
    self:ActionIn();
end

function M:Reset()
    self.text_baseReward.text = "";
    self.text_rewardAddition.text = "";
    self.text_scoreAddition.text = "";
    self:ActionOut(true);
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

return M