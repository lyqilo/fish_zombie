local CC = require("CC")
local M = CC.class2("SlotCommonNoticeViewCtr")
local slotMatch_message_pb = CC.slotMatch_message_pb;

--[[
@param
playerId
--]]
function M:ctor(view, param)
	self:InitVar(view, param);
end

function M:OnCreate()
	self:InitData();
	self:RegisterEvent();
end

function M:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self, self.SetCanShowNotice, CC.Notifications.OnCanShowNotice);
    CC.HallNotificationCenter.inst():register(self, self.AddNotice, CC.Notifications.OnAddSlotNotice);
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self);
end

function M:Destroy()
	self:UnRegisterEvent();
end

function M:InitVar(view, param)
	self.view = view;
end

function M:InitData()
    self["countDown_"..slotMatch_message_pb.Public] = -1; ---   -1为不自动取显示
    self["countDown_"..slotMatch_message_pb.SideFrame] = -1;
    self["countDown_"..slotMatch_message_pb.Lattern] = 10;
    self["countDown_"..slotMatch_message_pb.BulletMsg] = 3;
    self.noticeQueueMap = {
        [slotMatch_message_pb.Public] = {unlock = true},  ----公告   解锁
        [slotMatch_message_pb.SideFrame] = {unlock = true},----侧拉框   解锁
        [slotMatch_message_pb.Lattern] = {unlock = true},----跑马灯   解锁
        [slotMatch_message_pb.BulletMsg] = {unlock = true},---弹幕   解锁
    };
    self.noticeHistoryQueueMap = {
        [slotMatch_message_pb.Public] = {},  ----历史公告   解锁
    };
end

function M:SetCanShowNotice(can)
    self.canShow = can;
    if self.canShow then
        self:CheckNotice(slotMatch_message_pb.Public);
        self:CheckNotice(slotMatch_message_pb.SideFrame);
        self:CheckNotice(slotMatch_message_pb.Lattern);
        self:CheckNotice(slotMatch_message_pb.BulletMsg);
    end
end

function M:AddNotice(data,isHistoryData)
    if not data or not data.nType then
        logError("空消息或者消息类型不存在")
        return;
    end
    if self.noticeQueueMap[data.nType] then
        if not isHistoryData and not self:NoticeFilter(data) then
            return;
        end
        table.insert(self.noticeQueueMap[data.nType],data);
        if not isHistoryData and data.nType == slotMatch_message_pb.Public then ---历史只存弹窗类型公告
            table.insert(self.noticeHistoryQueueMap[data.nType],data);
        end
    else
        logError("非法消息类型"..data.nType);
        return;
    end
    self:CheckNotice(data.nType);
end

function M:CheckNotice(noticeType)
    if not self.canShow then
        return;
    end
    if not self.noticeQueueMap[noticeType].unlock then
        return;
    end
    local noticeData = table.remove(self.noticeQueueMap[noticeType],1);
    if noticeData then
        self:ShowCurrent(noticeData);
    end
end

function M:ShowCurrent(noticeData)
    self:StartAutoShowTimer(noticeData.nType);
    self.noticeQueueMap[noticeData.nType].unlock = false;
    self.view:ShowCurrent(noticeData);
end

function M:StartAutoShowTimer(nType)
    local countDown = self["countDown_"..nType];
    local timerName = "notice_"..nType;
    if countDown ~= -1 then
        self.view:StartTimer(timerName, 1, function()
            countDown = countDown - 1;
            if countDown < 0 then
                self.view:ShowNext(nType);
            end
        end, -1);
    end
end

function M:ShowNext(nType)
    self.view:StopTimer("notice_"..nType);
    self.noticeQueueMap[nType].unlock = true;
    self:CheckNotice(nType);
end

function M:ReadHistoryPublic()
    local hasHistory = false;
    for i = #self.noticeHistoryQueueMap[slotMatch_message_pb.Public],1,-1 do
        self:AddNotice(self.noticeHistoryQueueMap[slotMatch_message_pb.Public][i],true);
        hasHistory = true;
    end
    return hasHistory;
end

function M:NoticeFilter(noticeData)
    if noticeData.nType == slotMatch_message_pb.Public and noticeData.ShowCount and noticeData.ShowCount > 0 then
        local playerId = CC.Player.Inst():GetSelfInfoByKey("Id");
        local recordKey = string.format("%s_%d_notice_%d_%d",os.date("%Y-%m-%d"),playerId,noticeData.nType,noticeData.publicId);
        local recordStr = Util.GetFromPlayerPrefs(recordKey);
        local countRecord = tonumber(recordStr == "" and 0 or recordStr);
        if countRecord >= noticeData.ShowCount then
            return false;
        else
            countRecord = countRecord + 1;
            Util.SaveToPlayerPrefs(recordKey,tostring(countRecord));
        end
    end
    return true;
end

return M