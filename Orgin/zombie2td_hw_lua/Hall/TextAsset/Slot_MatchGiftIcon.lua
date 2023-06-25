--Author:AQ
--Time:2020年09月01日 10:13:02 Tuesday
--Describe:

local CC = require("CC")
local M = CC.class2("Slot_MatchGiftIcon")
local slotMatch_message_pb = CC.slotMatch_message_pb
local Slot_MatchUtils = require("View/SlotMatch/Slot_MatchUtils")

--------------------------创建和初始化-----------------------------
function M:ctor(param)
    self.param = param;
end

function M:Create()
    self.language = CC.LanguageManager.GetLanguage("L_SlotMatch");
	self:Init();
    self:RegisterEvent();
    self:Reset();
end

function M:Init()
    local parent = GameObject.Find(self.param.parentPath).transform;
    self.transform = CC.uu.LoadHallPrefab("prefab", "Slot_MatchGiftIcon", parent);
    if self.param.position then
        self.transform.localPosition = self.param.position;
    end
    if self.param.scale then
        self.transform.localScale = self.param.scale;
    end
    self.icon = self.transform:FindChild("btn_gift");
    self.guideHand = self.transform:FindChild("effect");
    self.text_score = self.transform:FindChild("text_score");

    self.sumScore = 0;
    self.screenWidthHalf = (self.transform.parent.rect.width - self.transform.rect.width) / 2;
    self.screenHeightHalf = (self.transform.parent.rect.height - self.transform.rect.height) / 2;
end

function M:RegisterEvent()
    self:AddClick(self.icon,"OnIconClick");
    self.icon.onBeginDrag = function(obj,eventData) self:OnIconBeiginDrag(obj,eventData) end
    self.icon.onDrag = function(obj,eventData) self:OnIconDrag(obj,eventData) end
    self.icon.onEndDrag = function(obj,eventData) self:OnIconEndDrag(obj,eventData) end

    CC.HallNotificationCenter.inst():register(self,self.OnMatchStage,CC.Notifications.MATCHSTAGE);
    CC.HallNotificationCenter.inst():register(self,self.OnMatchGiftGuide,CC.Notifications.MATCHGIFTGUIDE);
    CC.HallNotificationCenter.inst():register(self,self.OnPushStageChange,CC.Notifications.STAGECHANGE);
    CC.HallNotificationCenter.inst():register(self,self.OnPushReadyMatchInfo,CC.Notifications.READYMATCHINFO);
    CC.HallNotificationCenter.inst():register(self,self.OnPushGiftPurchase,CC.Notifications.GIFTPURCHASE);
    CC.HallNotificationCenter.inst():register(self,self.OnGiftData,CC.Notifications.MATCHGIFT);
end

function M:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self);
end

----------------------------事件--------------------------------

function M:OnIconClick()
    if self.hasGiftData then
        CC.HallNotificationCenter.inst():post(CC.Notifications.MATCHGIFTGUIDE,false);
        CC.SlotMatchManager.inst():OpenView("Slot_MatchGiftView");
        self.hasOpenTask = false;
    else
        local giftViewCtr = CC.SlotMatchManager.inst():GetView("Slot_MatchGiftView").viewCtr;
        giftViewCtr:RequestGiftData();
        self.hasOpenTask = true;
    end
end

function M:OnIconBeiginDrag(obj,eventData)
    self.lastPointPos = eventData.position;
end

function M:OnIconDrag(obj,eventData)
    local xOffset = eventData.position.x - self.lastPointPos.x;
    local yOffset = eventData.position.y - self.lastPointPos.y;
    if self:IsCanDrag(xOffset,yOffset) then
        self.transform.localPosition = Vector3(self.transform.localPosition.x + xOffset, self.transform.localPosition.y + yOffset, self.transform.localPosition.z);
    end
    self.lastPointPos = eventData.position;
end

function M:IsCanDrag(xOffset,yOffset)
    if xOffset > 0 and self.transform.localPosition.x > self.screenWidthHalf then
        return false;
    end
    if xOffset < 0 and self.transform.localPosition.x < -self.screenWidthHalf then
        return false;
    end
    if yOffset > 0 and self.transform.localPosition.y > self.screenHeightHalf then
        return false;
    end
    if yOffset < 0 and self.transform.localPosition.y < -self.screenHeightHalf then
        return false;
    end
    return true;
end

function M:OnIconEndDrag(obj,eventData)
    self.lastPointPos = nil;
end

function M:AddClick(node, func, clickSound)
	clickSound = clickSound or "click"

	if CC.uu.isString(func) then
		func = self:Func(func)
	end
	if not node then
		logError("按钮节点不存在")
		return
	end
	--在按下时就播放音效，解决音效延迟问题
	node.onDown = function (obj, eventData)
		CC.Sound.PlayHallEffect(clickSound)
	end

	if node == self.transform then
		node.onClick = function(obj, eventData)
			if eventData.rawPointerPress == eventData.pointerPress then
				func(obj, eventData)
			end
		end
	else
		node.onClick = function(obj, eventData)
			func(obj, eventData)
		end
	end
end

function M:Func( funcName )
	return function( ... )
		local func = self[funcName]
		if func then
			func( self, ... )
		end
	end
end

function M:OnMatchStage(data)
    log(CC.uu.Dump(data,"OnMatchStage",10))
    if data.matchStage.curStage == slotMatch_message_pb.En_Stage_Reay or data.matchStage.curStage == slotMatch_message_pb.En_Stage_Game then  ----只有准备和阶段才打开显示
        self:Refresh(data);
    else
        self:Reset();
    end
end

function M:OnPushStageChange(data)
    log(CC.uu.Dump(data,"OnPushStageChange",10))
    if data.matchStage.curStage == slotMatch_message_pb.En_Stage_Reay or data.matchStage.curStage == slotMatch_message_pb.En_Stage_Game then
        self:Refresh(data);
    else
        self:Reset();
    end
end

function M:OnPushReadyMatchInfo(data)
    log(CC.uu.Dump(data,"OnPushReadyMatchInfo",10))
    self.sumScore = Slot_MatchUtils.Return0IfNil(data.readyScore);
    if self.sumScore > 0 then
        self.text_score.text = self.language.LANGUAGE_49..self.sumScore;
    end
end

function M:OnPushGiftPurchase(data)
    log(CC.uu.Dump(data,"OnPushGiftPurchase",10))
    self.sumScore = self.sumScore + data.extraScore;
    self.text_score.text = self.language.LANGUAGE_49..self.sumScore;
end

function M:OnMatchGiftGuide(open)
    self.guideHand:SetActive(open)
end

function M:OnGiftData(data)
    log(CC.uu.Dump(data,"OnGiftData",10))
    self.hasGiftData = true;
    if self.hasOpenTask then
        coroutine.start(function()---跳一帧再执行，因为可能mathGiftView还没有接收到data
            coroutine.step();
            self:OnIconClick();
        end)
    end
end

-----------------------------------------显示------------------------------
function M:Refresh(info)
    self.guideHand:SetActive(false);
    self.transform:SetActive(true);
    if info.matchStage.curStage == slotMatch_message_pb.En_Stage_Reay then
        self.text_score.gameObject:SetActive(true);
    else
        self.text_score.gameObject:SetActive(false);
    end
end

function M:Reset()
    self.transform:SetActive(false);
    self.guideHand:SetActive(false);
    self.text_score.text = "";
    self.sumScore = 0;
end

----------------------------------------清理-----------------------------
function M:Destroy()
    self:UnRegisterEvent();
    if not CC.uu.IsNil(self.transform) then
        coroutine.start(function()
            CC.uu.destroyObject(self)
        end)
    end
end

return M