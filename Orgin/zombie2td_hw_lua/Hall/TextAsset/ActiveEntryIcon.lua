
local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local ActiveEntryIcon = CC.class2("ActiveEntryIcon", ViewUIBase);

local Vector3 = Vector3;
local math = math;

--[[
@param
parent: 挂载的父节点
]]
function ActiveEntryIcon:OnCreate(param)

	self:InitVar(param);
	self:InitContent();
	self:RegisterEvent();
end

function ActiveEntryIcon:InitVar(param)

	self.param = param or {};
end

function ActiveEntryIcon:InitContent()

	local activeEntryIsShow = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActiveEntryStatus();
	-- if CC.ChannelMgr.CheckOppoChannel() then
	-- 	activeEntryIsShow = false
	-- end

	self.transform:SetActive(activeEntryIsShow);

	local icon = self.transform:FindChild("Icon");
	self:AddClick(icon, "OnClickIcon");

	self.width = icon.width;
	self.height = icon.height;
	self.parentWidth = self.transform.parent:GetComponent("RectTransform").rect.width;
	self.parentHeight = self.transform.parent:GetComponent("RectTransform").rect.height;
	-- self:AddDragEvent(self.transform);
end

function ActiveEntryIcon:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self,self.OnRefreshActiveEntryBtn,CC.Notifications.OnRefreshActiveEntryBtn)
end

function ActiveEntryIcon:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnRefreshActiveEntryBtn)
end

function ActiveEntryIcon:OnRefreshActiveEntryBtn(isShow)
	-- if CC.ChannelMgr.CheckOppoChannel() then
	-- 	isShow = false
	-- end
	self.transform:SetActive(isShow);
end

function ActiveEntryIcon:AddDragEvent(target)
	target.onMove = function(obj, pos)
		self:moveLimit(obj)
	end
end

function ActiveEntryIcon:moveLimit(obj)
	local moveX = math.abs(obj.localPosition.x)
	local moveY = math.abs(obj.localPosition.y)

	local limitX = self.parentWidth/2;
	local limitY = self.parentHeight/2;

	if moveX > limitX - self.width/2 then
		local x = 0
		if obj.localPosition.x > 0 then
			x = limitX - self.width/2;
		else
			x = 0 - limitX + self.width/2;
		end
		obj.localPosition = Vector3(x, obj.localPosition.y, 0)
	end

	if moveY > limitY - self.height/2 then
		local y = 0
		if obj.localPosition.y > 0 then
			y = limitY - self.height/2;
		else
			y = 0 - limitY + self.height/2;
		end
		obj.localPosition = Vector3(obj.localPosition.x, y, 0)
	end
end

function ActiveEntryIcon:OnClickIcon()
	 CC.ViewManager.Open("ActiveEntryView", {mid = false});
	--CC.ViewManager.Open("ActiveEntryView", {special = true});
end

function ActiveEntryIcon:Destroy()

	self:UnRegisterEvent();
end

return ActiveEntryIcon;