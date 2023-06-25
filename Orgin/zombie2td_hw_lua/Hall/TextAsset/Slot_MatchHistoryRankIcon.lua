--Author:LiJunDao
--Time:2020年11月27日
--Describe:

local CC = require("CC")
local M = CC.class2("Slot_MatchHistoryRankIcon")
local slotMatch_message_pb = CC.slotMatch_message_pb

--------------------------创建和初始化-----------------------------
function M:ctor(param)
    self.param = param;
end

function M:Create()
	self:Init();
    self:RegisterEvent();
end

function M:Init()
    local parent = GameObject.Find(self.param.parentPath).transform;
    self.transform = CC.uu.LoadHallPrefab("prefab", "Slot_MatchHistoryRankIcon", parent);
    local rectTran = self.transform:GetComponent("RectTransform");
    rectTran.anchorMin = self.param.anchorMin;
    rectTran.anchorMax = self.param.anchorMax;
    rectTran.anchoredPosition = self.param.anchoredPosition;
    self.icon = self.transform;

    self.screenWidthHalf = (self.transform.parent.rect.width - self.transform.rect.width) / 2;
    self.screenHeightHalf = (self.transform.parent.rect.height - self.transform.rect.height) / 2;
end

function M:RegisterEvent()
    self:AddClick(self.icon,"OnIconClick");
    self.icon.onBeginDrag = function(obj,eventData) self:OnIconBeiginDrag(obj,eventData) end
    self.icon.onDrag = function(obj,eventData) self:OnIconDrag(obj,eventData) end
    self.icon.onEndDrag = function(obj,eventData) self:OnIconEndDrag(obj,eventData) end

    CC.HallNotificationCenter.inst():register(self,self.OnMatchStage,CC.Notifications.MATCHSTAGE);
    CC.HallNotificationCenter.inst():register(self,self.OnPushStageChange,CC.Notifications.STAGECHANGE);
end

function M:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self);
end

----------------------------事件--------------------------------

function M:OnMatchStage(data)
    log(CC.uu.Dump(data,"OnMatchStage",10))
    if (data.matchStage.curStage == slotMatch_message_pb.En_Stage_Invalid or data.matchStage.curStage == slotMatch_message_pb.En_Stage_Game) then  ----比赛期不显示
        self:Reset();
    else
        self:Refresh();
    end
end

function M:OnPushStageChange(data)
    log(CC.uu.Dump(data,"OnPushStageChange",10))
    if (data.matchStage.curStage == slotMatch_message_pb.En_Stage_Invalid or data.matchStage.curStage == slotMatch_message_pb.En_Stage_Game) then  ----比赛期不显示
        self:Reset();
    else
        self:Refresh();
    end
end

function M:OnIconClick()
    CC.SlotMatchManager.inst():OpenView("Slot_MatchHistoryRankView");
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

----------------------------------------显示-----------------------------
function M:Refresh()
    self.transform.gameObject:SetActive(true);
end

function M:Reset()
    self.transform.gameObject:SetActive(false);
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