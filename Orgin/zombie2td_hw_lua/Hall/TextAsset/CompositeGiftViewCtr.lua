local CC = require("CC")
local CompositeGiftViewCtr = CC.class2("CompositeGiftViewCtr")

function CompositeGiftViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function CompositeGiftViewCtr:InitVar(view, param)
	self.param = param;
    self.view = view;
    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop");
    self.CompositeBaseCfg = CC.ConfigCenter.Inst():getConfigDataByKey("CompositeBase");
    self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop");
end

function CompositeGiftViewCtr:OnCreate()
    self:RegisterEvent()
end

function CompositeGiftViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.GiftReward,CC.Notifications.OnDailyGiftGameReward)
end

function CompositeGiftViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
end

function CompositeGiftViewCtr:GiftReward(data)
    local isShowReward = data.Source == CC.shared_transfer_source_pb.TS_CombineEgg_Gift1 or data.Source ==CC.shared_transfer_source_pb.TS_CombineEgg_Gift2
                        or data.Source == CC.shared_transfer_source_pb.TS_CombineEgg_Gift3 or data.Source ==CC.shared_transfer_source_pb.TS_CombineEgg_Gift4
    if not isShowReward then return end
    local param = {}
    for k,v in ipairs(data.Rewards) do
        param[k] = {}
        param[k].ConfigId = v.ConfigId
        param[k].Count = v.Count
    end
    CC.ViewManager.OpenRewardsView({items = param, composite = true, forceSize = true})
    self.view:RefreshSelfInfo()
end

function CompositeGiftViewCtr:Destroy()
	self:UnRegisterEvent();
end

return CompositeGiftViewCtr;
