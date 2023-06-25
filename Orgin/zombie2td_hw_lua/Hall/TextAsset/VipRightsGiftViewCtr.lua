local CC = require("CC")
local VipRightsGiftViewCtr = CC.class2("VipRightsGiftViewCtr")

function VipRightsGiftViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function VipRightsGiftViewCtr:InitVar(view, param)
	self.param = param;
    self.view = view;
	self.MessageList = {}
	self.DataList = {}
	CC.Request("ReqTimesbuy",{PackIDs = self.view.WareIds})
end

function VipRightsGiftViewCtr:OnCreate()
	self:RegisterEvent()
end

function VipRightsGiftViewCtr:RegisterEvent()
	 CC.HallNotificationCenter.inst():register(self,self.ReqTimesbuy,CC.Notifications.NW_ReqTimesbuy)
	 CC.HallNotificationCenter.inst():register(self,self.RightsGiftReward,CC.Notifications.OnDailyGiftGameReward)
end

function VipRightsGiftViewCtr:UnRegisterEvent()
	 CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqTimesbuy)
	 CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
end

function VipRightsGiftViewCtr:ReqTimesbuy(err,data)
	log(CC.uu.Dump(data, "ReqTimesbuy"))
	local isShowGift = false
	if err == 0 and not table.isEmpty(data.TimesBuy) then
		self.view.Gifts = {}
		for i,v in ipairs(data.TimesBuy) do
			for j,gift in ipairs(self.view.BaseGifts) do
				if v.PackID == gift.WareId then
					if v.TotalTimes < gift.LimitBuyTime then
						local pack = table.copy(gift)
						pack.BuyTime = v.TotalTimes
						pack.VIP = pack.VIP + v.TotalTimes
						table.insert(self.view.Gifts,pack)
					end
					break
				end
			end
		end
		if table.length(self.view.Gifts) > 0 then
			isShowGift = true
			self.view.GiftNum = table.length(self.view.Gifts)
			self.view.CurGift = 1
			self.view:RefreshView(self.view.CurPage , self.view.CurGift)
		else
			self.isFinishBuy = true
			Util.SaveToPlayerPrefs("RightGiftFinishBuy"..CC.Player.Inst():GetSelfInfoByKey("Id"),"true")
			if not self.view.isSmashEggs then
				CC.HallNotificationCenter.inst():post(CC.Notifications.ShowRightGift, false)
			end
		end
	else
		CC.ViewManager.ShowTip(self.view.language.TimeOut)
	end
	if not self.isFinishBuy then
		CC.HallNotificationCenter.inst():post(CC.Notifications.ShowRightGift, isShowGift)
	end
end

function VipRightsGiftViewCtr:RightsGiftReward(data)
	log(CC.uu.Dump(data, "RightsGiftReward"))
	if not self:CheckSourceid(data.Source) then return end
	CC.Request("ReqTimesbuy",{PackIDs = self.view.WareIds})
	local isOpenCrystalStore = false
	if Util.GetFromPlayerPrefs("isOpenCrystalStore"..CC.Player.Inst():GetSelfInfoByKey("Id")) ~= "true" then
		for _,v in ipairs(data.Rewards) do
			if v.ConfigId == CC.shared_enums_pb.EPC_Crystal then
				Util.SaveToPlayerPrefs("isOpenCrystalStore"..CC.Player.Inst():GetSelfInfoByKey("Id"),"true")
				isOpenCrystalStore = true
			end
		end
	end
	table.insert(self.DataList,{reward = data.Rewards,isOpenCrystalStore = isOpenCrystalStore})
	self.view:SmashEggs()
end

function VipRightsGiftViewCtr:CheckSourceid(id)
	for i=1,11 do
		if id == CC.shared_transfer_source_pb["TS_Vip_Right_Pack"..i] then
			return true
		end
	end
	return false
end

function VipRightsGiftViewCtr:Destroy()
	self:UnRegisterEvent();
end

return VipRightsGiftViewCtr;
