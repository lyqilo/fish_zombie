local CC = require("CC")
local CommonHolidayGiftViewCtr = CC.class2("CommonHolidayGiftViewCtr")
local M = CommonHolidayGiftViewCtr

function M:ctor(view,param)
	self:InitVar(view,param)
end

function M:InitVar(view,param)
    self.view = view
	self.param = param
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnGetOrderStatusRsp, CC.Notifications.NW_GetOrderStatus)
	CC.HallNotificationCenter.inst():register(self,self.OnPropChange,CC.Notifications.changeSelfInfo)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function M:OnCreate()
	self:RegisterEvent()
	self:GetOrderStatus()
end

function M:GetOrderStatus()
	CC.Request("GetOrderStatus",{self.view.wareId})
end

function M:OnGetOrderStatusRsp(err,data)
	-- CC.uu.Log(data,"OnGetOrderStatusRsp data:")
	if err ~= 0 then
		logError("GetOrderStatus err:"..err)
		self.view:SetBuyBtnState(false)
		return
	end
	if data.Items then
		for _, v in ipairs(data.Items) do
			if v.WareId == "30335" then
				self.view:SetBuyBtnState(v.Enabled)
				self.activityDataMgr.SetGiftStatus(v.WareId, v.Enabled)
				-- self.view:RefreshUI(v.WareId,v.Enabled)
				self.activityDataMgr.SetActivityInfoByKey("CommonHolidayGiftView", {switchOn = v.Enabled})
			end
		end
	end
end
-- CC.Notifications.OnDailyGiftGameReward
function M:OnPropChange(props,source)
	if source == CC.shared_transfer_source_pb.TS_Holiday_PromotionalPackage then
		self:GetOrderStatus()
	end
end

function M:Destroy()
	self:UnRegisterEvent()
end

return CommonHolidayGiftViewCtr