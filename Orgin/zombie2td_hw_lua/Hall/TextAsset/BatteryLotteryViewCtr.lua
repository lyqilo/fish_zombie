
local CC = require("CC")
local BatteryLotteryViewCtr = CC.class2("BatteryLotteryViewCtr")

function BatteryLotteryViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function BatteryLotteryViewCtr:InitVar(view, param)
	self.param = param
	self.view = view
	self.MessageList = {}
	self.pb = CC.shared_enums_pb
	self.BlockTab = {
		[self.view.batteryProp] = 1,
		[self.view.batteryFragment] = 2,
		[self.view.pointCard] = 3,
		[self.pb.EPC_New_GiftVoucher] = 6,
		[self.pb.EPC_RocketGun_1022] = 7,
		[self.pb.EPC_GiftFishV3] = 7,
		[self.pb.EPC_Nuclear_Bomb_1035] = 7,
		[self.pb.EPC_TenGift_Sign_97] = 8
	}
end

function BatteryLotteryViewCtr:OnCreate()
    self:RegisterEvent()
    CC.Request("ReqCommonBatteryInfo")
    CC.Request("ReqCommonBatteryRecord")
end

function BatteryLotteryViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqCommonBatteryInfo,CC.Notifications.NW_ReqCommonBatteryInfo)
	CC.HallNotificationCenter.inst():register(self,self.ReqCommonBatteryRecord,CC.Notifications.NW_ReqCommonBatteryRecord)
	CC.HallNotificationCenter.inst():register(self,self.BatteryLotteryShareSuccess,CC.Notifications.NW_ReqCommonBatteryShare)
	CC.HallNotificationCenter.inst():register(self,self.BatteryLotteryReqExchange,CC.Notifications.NW_ReqExchange)
	CC.HallNotificationCenter.inst():register(self,self.BatteryLotteryFreeReward,CC.Notifications.NW_ReqCommonBatteryFree)
	CC.HallNotificationCenter.inst():register(self,self.ReqHolyBeastBatteryLotteryResp,CC.Notifications.NW_ReqHolyBeastBatteryLottery)

	CC.HallNotificationCenter.inst():register(self,self.BatteryLotteryReward,CC.Notifications.OnDailyGiftGameReward)
	CC.HallNotificationCenter.inst():register(self,self.BatteryLotteryOnTimeNotify,CC.Notifications.OnTimeNotify)
	CC.HallNotificationCenter.inst():register(self,self.BatteryLotteryPushRecord,CC.Notifications.PushCommonBatteryRecord)
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshSkin,CC.Notifications.OnRefreshBatterySkin)
	CC.HallNotificationCenter.inst():register(self,self.OnPropChange,CC.Notifications.changeSelfInfo)
end

function BatteryLotteryViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function BatteryLotteryViewCtr:ReqCommonBatteryInfo(err,data)
	log(CC.uu.Dump(data, "ReqCommonBatteryInfo"))
	if err == 0 and data.BeginStamp and data.EndStamp then
		local startTime = os.date("%d/%m %H:%M",data.BeginStamp)
		local stopTime = os.date("%d/%m %H:%M",data.EndStamp)
		Util.SaveToPlayerPrefs("BatteryLotteryActTime",startTime.." - "..stopTime)
		local tempTime = data.EndStamp - os.time()
		local day =  math.modf(tempTime / 86400)
		if math.fmod(tempTime, 86400) > 0 then day = day + 1 end
		self.view:RefreshActTime({actTime = startTime.." - "..stopTime,lastDay = data.LastDay,day = day})
		self.view.FreeLotteryBtn:SetActive(data.FreeTimes > 0)
	end
end

function BatteryLotteryViewCtr:ReqCommonBatteryRecord(err,data)
	log(CC.uu.Dump(data, "ReqCommonBatteryRecord",10))
	if err == 0 and data and data.List and table.length(data.List) > 0  then
		for k,v in pairs(data.List) do
			if v.Name then
				if self.view.Marquee then
					self.view.Marquee:Report(string.format(self.view.language.BroadCast,v.Name,""),false)
				end
			end
		end
	end
end

function BatteryLotteryViewCtr:BatteryLotteryShareSuccess(err,data)
	CC.Request("ReqCommonBatteryInfo")
end

function BatteryLotteryViewCtr:BatteryLotteryReqExchange(err,data)
	log(CC.uu.Dump(data, "BatteryLotteryReqExchange"))
	if err == 0 and data.Items then
		if data.Items[1].ConfigId == self.view.batteryProp then
			CC.ViewManager.Open("CompoundPanel", {batteryType = self.view.batteryProp})
		end
	end
end

function BatteryLotteryViewCtr:BatteryLotteryFreeReward(err,data)
	log(CC.uu.Dump(data, "BatteryLotteryFreeReward"))
	CC.Request("ReqCommonBatteryInfo")
	if err == 0 then
		local Rewards = {{ConfigId = data.ConfigId,Count = data.Count,Block = self.BlockTab[data.ConfigId]}}
		self.view:StartLottery(Rewards)
	end
end

function BatteryLotteryViewCtr:ReqHolyBeastBatteryLotteryResp(err, data)
	log(CC.uu.Dump(data, "ReqHolyBeastBatteryLotteryResp"))
	if err == 0 then
		if not table.isEmpty(data.Rewards) then
			local Rewards = {}
			for _,v in ipairs(data.Rewards) do
				local configId = v.Props[1].ConfigId
				local count = v.Props[1].Count
				local Block = self.BlockTab[configId]
				if configId == self.pb.EPC_ChouMa then
					Block = count == 75000 and 4 or 5
				elseif configId == self.pb.EPC_TaiJi_Totem then
					Block = count == 20 and 1 or 2
				end
				if configId == self.pb.EPC_RocketGun_1022 or configId == self.pb.EPC_GiftFishV3 or configId == self.pb.EPC_Nuclear_Bomb_1035 then
					table.insert(Rewards,{ConfigId = configId,Count = count,Block = Block})
				else
					table.insert(Rewards,1,{ConfigId = configId,Count = count,Block = Block})
				end
			end
			local isMultiple = #Rewards > 1 and true or false
			for _,v in ipairs(Rewards) do
				if #Rewards == 3 and (v.ConfigId == self.pb.EPC_RocketGun_1022 or v.ConfigId == self.pb.EPC_GiftFishV3 or v.ConfigId == self.pb.EPC_Nuclear_Bomb_1035) then
					isMultiple = false
					break
				end
			end
			if not table.isEmpty(Rewards) then
				self.view:StartLottery(Rewards,isMultiple)
				CC.Request("ReqCommonBatteryInfo")
			end
		end
	end
end

function BatteryLotteryViewCtr:BatteryLotteryReward(data)
	log(CC.uu.Dump(data, "BatteryLotteryReward"))
	local result
	local source
	if self.view.isHolyBeast then
		source = CC.shared_transfer_source_pb.TS_Fourbeasts_Battery
		result = data.Source == source
	else
		source = CC.shared_transfer_source_pb.TS_Common_Battery
		result = data.Source == source or data.Source == CC.shared_transfer_source_pb.TS_Common_Battery5 or data.Source == CC.shared_transfer_source_pb.TS_Common_Battery_Ticket
	end
	if result and data.Rewards then
		if not table.isEmpty(data.Rewards) then
			if data.Source == CC.shared_transfer_source_pb.TS_Common_Battery_Ticket then
				CC.ViewManager.OpenRewardsView({items = data.Rewards,sound = "ShowReward",callback = function ()
					self.view:RefreshSkin()
				end})
			elseif data.Source == source or data.Source == CC.shared_transfer_source_pb.TS_Common_Battery5 then
				local Rewards = {}
				for _,v in ipairs(data.Rewards) do
					local Block = self.BlockTab[v.ConfigId]
					if v.ConfigId == self.pb.EPC_ChouMa then
						Block = v.Count == 75000 and 4 or 5
					elseif v.ConfigId == self.pb.EPC_TaiJi_Totem then
						Block = v.Count == 20 and 1 or 2
					end
					if v.ConfigId == self.pb.EPC_RocketGun_1022 or v.ConfigId == self.pb.EPC_GiftFishV3 or v.ConfigId == self.pb.EPC_Nuclear_Bomb_1035 then
						table.insert(Rewards,{ConfigId = v.ConfigId,Count = v.Count,Block = Block})
					else
						table.insert(Rewards,1,{ConfigId = v.ConfigId,Count = v.Count,Block = Block})
					end
				end
				local isMultiple = #Rewards > 1 and true or false
				for _,v in ipairs(Rewards) do
					if #Rewards == 3 and (v.ConfigId == self.pb.EPC_RocketGun_1022 or v.ConfigId == self.pb.EPC_GiftFishV3 or v.ConfigId == self.pb.EPC_Nuclear_Bomb_1035) then
						isMultiple = false
						break
					end
				end
				self.view:StartLottery(Rewards,isMultiple)
			end
		end
	end
end

function BatteryLotteryViewCtr:BatteryLotteryOnTimeNotify(err,data)
	log("炮台零点刷新提示")
	CC.Request("ReqCommonBatteryInfo")
end

function BatteryLotteryViewCtr:BatteryLotteryPushRecord(data)
	if self.view.Marquee then
		self.view.Marquee:Report(string.format(self.view.language.BroadCast,data.Name,""),true)
	end
end

function BatteryLotteryViewCtr:OnRefreshSkin()
	 self.view:RefreshSkin();
end

function BatteryLotteryViewCtr:OnPropChange(props, source)
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_TaiJi_Totem then
            self.view:RefreshTaiJi()
		end
	end
end

function BatteryLotteryViewCtr:Destroy()
	self:UnRegisterEvent()
end

return BatteryLotteryViewCtr;
