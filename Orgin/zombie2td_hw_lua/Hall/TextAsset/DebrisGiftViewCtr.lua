
local CC = require("CC")
local DebrisGiftViewCtr = CC.class2("DebrisGiftViewCtr")

function DebrisGiftViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function DebrisGiftViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
end

function DebrisGiftViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function DebrisGiftViewCtr:InitData()

end

function DebrisGiftViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.DebrisGiftBuyReward,CC.Notifications.OnDailyGiftGameReward)
	CC.HallNotificationCenter.inst():register(self,self.RefreshView,CC.Notifications.OnRefreshActivityBtnsState)
end

function DebrisGiftViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnRefreshActivityBtnsState)
end

function DebrisGiftViewCtr:DebrisGiftBuyReward(data)
	log(CC.uu.Dump(data, "DebrisGiftBuyReward"))
	if data.Source == CC.shared_transfer_source_pb.TS_CardFragment_Treasure_143 or data.Source == CC.shared_transfer_source_pb.TS_CardFragment_Treasure_49 then
		local Rewards={}
        for _,v in ipairs(data.Rewards) do
            table.insert(Rewards,{id = v.ConfigId,count = v.Count})
        end
		self:RewardGold(Rewards)
		self.view:RefreshDebris()
	end
end

--奖励
function DebrisGiftViewCtr:RewardGold(Rewards)
    local param = {}
    for i,v in ipairs(Rewards) do
        param[i]=
        {
            ConfigId=v.id,
            Delta=v.count
        }
    end
    CC.ViewManager.OpenRewardsView({items = param})
end

function DebrisGiftViewCtr:RefreshView(key,switchOn)
	if key == "DebrisGift" and not switchOn then
		self.view:ActionIn()
	end
end

function DebrisGiftViewCtr:Destroy()

	self:UnRegisterEvent();
end

return DebrisGiftViewCtr;
