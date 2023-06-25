local CC = require("CC")
local PirateTreasureGiftViewCtr = CC.class2("PirateTreasureGiftViewCtr")

function PirateTreasureGiftViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function PirateTreasureGiftViewCtr:InitVar(view,param)
	self.param = param
	self.view = view
end

function PirateTreasureGiftViewCtr:OnCreate()
	self:InitData()
	self:RegisterEvent()
end

function PirateTreasureGiftViewCtr:InitData()

end

function PirateTreasureGiftViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqOrderStatusResq,CC.Notifications.NW_GetOrderStatus)
	CC.HallNotificationCenter.inst():register(self,self.RewardRecordResp,CC.Notifications.NW_ReqPirateRecord)
	CC.HallNotificationCenter.inst():register(self,self.GiftReward,CC.Notifications.OnDailyGiftGameReward)
end

function PirateTreasureGiftViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetOrderStatus)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqPirateRecord)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
end

function PirateTreasureGiftViewCtr:ReqOrderStatusResq(err, data)
	log(CC.uu.Dump(data,"PirateData",10))
	if data.Items then
        for _, v in ipairs(data.Items) do
            if v.WareId == self.view.pirateWareId and not v.Enabled then
                self.view:ActionOut()
			end
        end
    end
end

function PirateTreasureGiftViewCtr:ReqRecord()
	CC.Request("ReqPirateRecord")
end

function PirateTreasureGiftViewCtr:RewardRecordResp(err, data)
	log("err = ".. err.."  "..CC.uu.Dump(data,"PirateRewardRecord",10))
	if err == 0 then
		self.view:InitInfo(data.Records)
	end
end

function PirateTreasureGiftViewCtr:GiftReward(param)
    log(CC.uu.Dump(param,"param",10))
    if param.Source == CC.shared_transfer_source_pb.TS_Lhdb_Unlock then
        local data = {};
		for k,v in ipairs(param.Rewards) do
			if v.ConfigId ~= CC.shared_enums_pb.EPC_Lhdb_Unlock_9001 then
				data[k] = {}
				data[k].ConfigId = v.ConfigId
				data[k].Count = v.Count
			end
		end
		local Cb = function()
			self.view:ActionOut()
		end
		CC.ViewManager.OpenRewardsView({items = data, callback = Cb})
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnGameUnlockGift, {GameId = 1008})
    end
end


function PirateTreasureGiftViewCtr:Destroy()
	self:unRegisterEvent()
end

return PirateTreasureGiftViewCtr