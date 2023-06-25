--Author:lijundao
--Time:2020年08月18日 09:03:23 Tuesday
--Describe:

local CC = require("CC")
local M = CC.uu.ClassView("Slot_MatchGiftView")
local Slot_MatchGiftViewCtr = require("View/SlotMatch/Slot_MatchGiftViewCtr")
local SlotMatchManager = CC.SlotMatchManager
local slotMatch_message_pb = CC.slotMatch_message_pb
local Slot_MatchUtils = require("View/SlotMatch/Slot_MatchUtils")
local SubGameInterface = CC.SubGameInterface

-------------------------------------创建及初始化-----------------------------------
function M:ctor(param)
    self.param = param;
end

function M:OnOpen()
    self:Reset();
    self:Refresh();
end

function M:OnCreate()
    self.language = CC.LanguageManager.GetLanguage("L_SlotMatch");
    self:Init();
    self:RegisterEvent();
    self:Reset();
end

function M:Init()
    local frame = self:FindChild("frame");
    self.btn_close = frame:FindChild("btn_close");
    local title = frame:FindChild("title");
    self.image_baseTitle = title:FindChild("image_baseTitle");
    self.image_eliteTitle_assist = title:FindChild("image_eliteTitle_assist");
    self.image_eliteTitle_sprint = title:FindChild("image_eliteTitle_sprint");
    self.image_masterTitle = title:FindChild("image_masterTitle");
    self.giftSelect = frame:FindChild("giftSelect");
    self.toggle_assist = self.giftSelect:FindChild("toggleGroup/toggle_assist");
    self.toggle_assist:FindChild("Image/giftName").text = self.language.LANGUAGE_45;
    self.toggle_assist:FindChild("Background/Checkmark/giftName").text = self.language.LANGUAGE_45;
    self.toggle_assist_com = self.toggle_assist:GetComponent("Toggle");
    self.toggle_sprint = self.giftSelect:FindChild("toggleGroup/toggle_sprint");
    self.toggle_sprint:FindChild("Image/giftName").text = self.language.LANGUAGE_46;
    self.toggle_sprint:FindChild("Background/Checkmark/giftName").text = self.language.LANGUAGE_46;
    self.toggle_sprint_com = self.toggle_sprint:GetComponent("Toggle");
    self.tableNode = frame:FindChild("turnTable/image_table");
    self.quaternion = Quaternion();
    self.text_ratioLists = {};
    for i = 0 , self.tableNode.childCount - 1 do
        local childText = self.tableNode:GetChild(i):GetComponent("Text");
        table.insert(self.text_ratioLists,childText);
    end
    self.pointerArrow = frame:Find("turnTable/image_pointer");
    self.text_baseChip = frame:FindChild("text_baseChip"):GetComponent("Text");
    self.text_awardCount = frame:FindChild("text_awardPrefix/text_awardCount"):GetComponent("Text");
    self.text_scoreCount = frame:FindChild("text_scorePrefix/text_scoreCount"):GetComponent("Text");
    self.btn_spin = frame:FindChild("btn_spin")
    self.btn_spin:FindChild("Text").text = self.language.BtnSpin
    self.text_diamondCount = self.btn_spin:FindChild("text_diamondCount"):GetComponent("Text");
    self.text_giftTip = frame:FindChild("text_giftTip"):GetComponent("Text");
    local text_awardTip = frame:FindChild("text_awardTip"):GetComponent("Text");
    text_awardTip.text = self.language.LANGUAGE_27;
    local text_baseChipPrefix = frame:FindChild("text_baseChip/text_baseChipPrefix"):GetComponent("Text");
    text_baseChipPrefix.text = self.language.LANGUAGE_32;
    local text_awardPrefix = frame:FindChild("text_awardPrefix"):GetComponent("Text");
    text_awardPrefix.text = self.language.LANGUAGE_33;
    local text_scorePrefix = frame:FindChild("text_scorePrefix"):GetComponent("Text");
    text_scorePrefix.text = self.language.LANGUAGE_34;
    self.viewCtr = Slot_MatchGiftViewCtr.new(self,self.param);
    self.viewCtr:OnCreate();
    self.frame = frame;
    self.walletView = CC.uu.CreateHallView("WalletView", {parent = self.transform,exchangeWareId = self.exchangeWareId});
end

function M:RegisterEvent()
    self:AddClick(self.btn_close,"OnCloseClick");
    UIEvent.AddToggleValueChange(self.toggle_assist, function(selected) self:OnGiftSelect(selected) end);
    UIEvent.AddToggleValueChange(self.toggle_sprint, function(selected) self:OnGiftSelect(selected) end);
    self:AddClick(self.btn_spin,"OnSpinClick");
end

-------------------------------------------事件---------------------------------
function M:OnCloseClick()
    SlotMatchManager.inst():CloseView(self.viewName);
end

function M:OnGiftSelect(selected)
    if not selected then
        return;
    end
    local assistOn = self.toggle_assist_com.isOn;
    local giftId = assistOn and "2" or "3";
    self:ResetContent();
    self:RefreshContent(giftId);
end

function M:OnSpinClick()
    local doingView = SlotMatchManager.inst():GetView("Slot_MatchDoingView");
    local matchRemainTime = doingView:GetRemainTime()
    if matchRemainTime ~= nil and matchRemainTime <= 15 then----比赛最后15秒不让购买了
        CC.HallNotificationCenter.inst():post(CC.Notifications.MATCHTIP,self.language.LANGUAGE_41);
        return;
    end
    if self.bought then
		return;
    end
    local param = {};
    param.wareId = self.wareId;
    param.walletView = self.walletView;
    SubGameInterface.DiamondBuyGift(param);
end

---------------------------------显示------------------------------------------
function M:Refresh()
    local giftId = "1";--nil
    if self.enMatch == slotMatch_message_pb.En_Match_Primary then
        giftId = "1";
    elseif self.enMatch == slotMatch_message_pb.En_Match_Middle then
        giftId = "3";
        self.toggle_assist_com.isOn = false;
        self.toggle_sprint_com.isOn = true;
    elseif self.enMatch == slotMatch_message_pb.En_Match_High then
        giftId = "4";
    end
    self:RefreshContent(giftId);
    self:ActionIn();
end

function M:Reset()
    self:ActionOut(true);
    self:ResetContent();
end

function M:RefreshContent(giftId)
    self:ConstructWalletView(giftId);
    local info = self.viewCtr:GetGiftInfo(giftId);
    self.viewCtr:SetTurntableMul(info.allSpinRatios);
    self.exchangeWareId = info.giftId;
    self.text_baseChip.text = CC.uu.ChipFormat(Slot_MatchUtils.Return0IfNil(info.baseReward),true);
    self.text_awardCount.text = CC.uu.NumberFormat(Slot_MatchUtils.Return0IfNil(info.rewardAddition.min)).."-"..CC.uu.NumberFormat(Slot_MatchUtils.Return0IfNil(info.rewardAddition.max));
    self.text_scoreCount.text = CC.uu.NumberFormat(Slot_MatchUtils.Return0IfNil(info.scoresAddition.min)).."-"..CC.uu.NumberFormat(Slot_MatchUtils.Return0IfNil(info.scoresAddition.max));
    self.text_diamondCount.text = CC.uu.DiamondFortmat(Slot_MatchUtils.Return0IfNil(info.price));
    if giftId == "1" then
        self.image_baseTitle:SetActive(true);
        self.text_giftTip.text = self.language.LANGUAGE_28;
    elseif giftId == "2" then
        self.image_eliteTitle_assist:SetActive(true);
        self.text_giftTip.text = self.language.LANGUAGE_29;
        self.giftSelect:SetActive(true);
    elseif giftId == "3" then
        self.image_eliteTitle_sprint:SetActive(true);
        self.text_giftTip.text = self.language.LANGUAGE_30;
        self.giftSelect:SetActive(true);
    elseif giftId == "4" then
        self.image_masterTitle:SetActive(true);
        self.text_giftTip.text = self.language.LANGUAGE_31;
    end
    for i,v in pairs(info.allSpinRatios) do
        if self.text_ratioLists[i] then
            self.text_ratioLists[i].text = "X"..v
        end
    end
    if self.viewCtr.curStage == slotMatch_message_pb.En_Stage_Game then
        self.toggle_assist.gameObject:SetActive(true);
    end
end

function M:ResetContent()
    self.text_baseChip.text = "";
    self.text_awardCount.text = "";
    self.text_scoreCount.text = "";
    self.text_diamondCount.text = "";
    self.text_giftTip.text = "";
    self.image_baseTitle:SetActive(false);
    self.image_eliteTitle_assist:SetActive(false);
    self.image_eliteTitle_sprint:SetActive(false);
    self.image_masterTitle:SetActive(false);
    self.giftSelect:SetActive(false);
    self.toggle_assist.gameObject:SetActive(false);
    for k,v in pairs(self.text_ratioLists) do
        v.text = "";
    end
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
    CC.uu.DelayRun(1,function() self.viewCtr:ClearRewardData(); end);
end

function M:ConstructWalletView(giftId)
    if self.walletView then
        SubGameInterface.DestroyWalletView(self.walletView);
        self.walletView = nil;
    end

    self.wareId = M.GetGiftWareId(giftId);
    local param={};
    param.wareId = self.wareId;
    param.parent = self.transform;
    param.width = 1280;
    param.height = 720;
    param.succCb = function() end;
    self.walletView = SubGameInterface.CreateWalletView(param);
end

---------------------------------数据--------------------------------------------
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

function M:RefreshEnMatch(enMatch)
    self.enMatch = self:SafeEnMatch(enMatch);
end

function M:ResetEnMatch()
    self.enMatch = nil;
end

function M:OnSpinNowTurn(multi)
	self.bought = true;
	CC.Sound.PlayHallEffect("Turntable")
	self:SetCanClick(false)
	CC.uu.DelayRun(1.1, function ()
		self.viewCtr:StartRoll(multi)
	end)
end

function M:SetCanClick(flag)
    M.super.SetCanClick(self,flag);
    self.toggle_assist_com.interactable = flag;
    self.toggle_sprint_com.interactable = flag;
end

--设置中奖结果
function M:SetReceiveResult(rewardData)
    self:SetCanClick(true);
    CC.Sound.PlayHallEffect("Award");
    self.bought = false;
    SlotMatchManager.inst():OpenView("Slot_MatchRewardsView",rewardData);
end

function M:GetTableAngle()
	return self.tableNode.transform.localEulerAngles.z;
end

--设置转盘角度
function M:RefreshTableAngle(zAngle)
	self.tableNode.transform.localRotation = self.quaternion:SetEuler(0, 0, zAngle);
end

--设置指针
function M:RefreshPointerArrowAngle(zAngle)
	self.pointerArrow.transform.localRotation = self.quaternion:SetEuler(0, 0, zAngle);
end

local giftCfg = {
    ["1"] = "30030",
    ["2"] = "30031",
    ["3"] = "30032",
    ["4"] = "30033",
}

function M.GetGiftWareId(giftIndex)
    if giftCfg[giftIndex] then
        return giftCfg[giftIndex];
    end
end

-------------------------------------清理------------------------------------------
function M:OnDestroy()
    if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
    end
    if self.walletView then
		self.walletView:Destroy();
	end
end
return M


