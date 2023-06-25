
local CC = require("CC")
local FortuneCatViewCtr = CC.class2("FortuneCatViewCtr")

function FortuneCatViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function FortuneCatViewCtr:InitVar(view, param)
	self.param = param
	self.view = view
end

function FortuneCatViewCtr:OnCreate()
	self:RegisterEvent()
	CC.Request("ReqCatBatteryInfo")
	CC.Request("ReqCatBatteryRecord")
end

function FortuneCatViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnReqCatBatteryInfoRsq,CC.Notifications.NW_ReqCatBatteryInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnReqExchangeRsq,CC.Notifications.NW_ReqExchange)
	CC.HallNotificationCenter.inst():register(self,self.OnReqCatBatteryRecordRsq,CC.Notifications.NW_ReqCatBatteryRecord)
	CC.HallNotificationCenter.inst():register(self,self.FortuneCatReward,CC.Notifications.OnDailyGiftGameReward)
	CC.HallNotificationCenter.inst():register(self,self.PushCatBatteryRecord,CC.Notifications.PushCatBatteryRecord)
end

function FortuneCatViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function FortuneCatViewCtr:OnReqCatBatteryInfoRsq(err,data)
	log(CC.uu.Dump(data, "OnReqCatBatteryInfoRsq"))
	if err == 0 and data.BeginStamp and data.BeginStamp > 0 and data.EndStamp and data.EndStamp > 0 then
		local startTime = os.date("%d/%m %H:%M",data.BeginStamp)
		local stopTime = os.date("%d/%m %H:%M",data.EndStamp)
		self.view:ShowActTime(startTime.." - "..stopTime)
	end
end

function FortuneCatViewCtr:OnReqExchangeRsq(err,data)
	log(CC.uu.Dump(data, "OnReqExchangeRsq"))
	if err == 0 and #data.Items > 0 then
		local battery = false
		for i,v in ipairs(data.Items) do
			if v.ConfigId == CC.shared_enums_pb.EPC_Cat_Battery_1110 then
				battery = true
				break
			end
		end
		if battery then
			self.view:ShowCompoundPanel()
		end
	end
end

function FortuneCatViewCtr:OnReqCatBatteryRecordRsq(err,data)
	log(CC.uu.Dump(data, "OnReqCatBatteryRecordRsq",10))
	if err == 0 and data.List and table.length(data.List) > 0  then
		for k,v in pairs(data.List) do
			if v.Name and self.view.Marquee then
				self.view.Marquee:Report(string.format(self.view.language.GetBattery,v.Name,""),false)
			end
		end
	end
end

function FortuneCatViewCtr:FortuneCatReward(data)
	log(CC.uu.Dump(data, "FortuneCatReward"))
	if #data.Rewards > 0 then
		if data.Source == CC.shared_transfer_source_pb.TS_CatBattery_Ticket then
			CC.ViewManager.OpenRewardsView({items = data.Rewards,callback = function() self.view:RefreshDisplay() end})
		elseif data.Source == CC.shared_transfer_source_pb.TS_CatBattery then
			self.view:StartLottery(data.Rewards)
		end
	end
end

function FortuneCatViewCtr:PushCatBatteryRecord(data)
	if self.view.Marquee then
		self.view.Marquee:Report(string.format(self.view.language.GetBattery,data.Name,""),true)
    end
end

function FortuneCatViewCtr:Destroy()
	self:UnRegisterEvent()
end

return FortuneCatViewCtr;
