local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local MidActiveIcon = CC.class2("MidActiveIcon", ViewUIBase);

local Vector3 = Vector3;
local math = math;

--[[
@param
parent: 挂载的父节点
]]
function MidActiveIcon:OnCreate(param)
	self:InitVar(param);
	self:InitContent();
	self:RegisterEvent();
end

function MidActiveIcon:InitVar(param)
	self.param = param or {};
end

function MidActiveIcon:InitContent()
    --实物锁
    local treasure = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel")
    local midActiveIsShow = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetMidActivetyStatus();
	self.transform:SetActive(treasure and midActiveIsShow);

	local icon = self.transform:FindChild("Icon");
	self:AddClick(icon, "OnClickIcon");

	self.width = icon.width;
	self.height = icon.height;
	self.parentWidth = self.transform.parent:GetComponent("RectTransform").rect.width;
	self.parentHeight = self.transform.parent:GetComponent("RectTransform").rect.height;
	-- self:AddDragEvent(self.transform);
end

function MidActiveIcon:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshMidActiveBtn,CC.Notifications.OnRefreshMidActiveBtn)
end

function MidActiveIcon:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnRefreshMidActiveBtn)
end

function MidActiveIcon:OnRefreshMidActiveBtn(isShow)
    local treasure = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel")
	self.transform:SetActive(treasure and isShow);
end

function MidActiveIcon:AddDragEvent(target)
	target.onMove = function(obj, pos)
		self:moveLimit(obj)
	end
end

function MidActiveIcon:moveLimit(obj)
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

function MidActiveIcon:OnClickIcon()
	-- CC.ViewManager.Open("ActiveEntryView", {mid = true})
	CC.ViewManager.Open("ActivityCollectionView")
end

function MidActiveIcon:Destroy()
	self:UnRegisterEvent();
end

return MidActiveIcon;