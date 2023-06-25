local CC = require("CC")

local ComposeCapsuleViewCtr = CC.class2("ComposeCapsuleViewCtr")

function ComposeCapsuleViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function ComposeCapsuleViewCtr:InitVar(view,param)
    self.view = view
    self.param = param
    self.reward = nil

    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.propDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
    self.realDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData")

    self:RegisterEvent()
end

function ComposeCapsuleViewCtr:OnCreate()
    -- CC.Request("ReqGetCombineEggMarquee")
end

function ComposeCapsuleViewCtr:ReqLottery(Type,Times)
    if Type == 1 then
        if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") < Times * 10000 then
            CC.ViewManager.ShowMessageBox(self.view.language.ChipNotEnough,
				function ()
					if CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
						local param = {}
						param.SelectGiftTab = {"NoviceGiftView"}
						CC.ViewManager.Open("SelectGiftCollectionView",param)
    				else
        				CC.ViewManager.Open("StoreView")
    				end
				end,
				function ()
					--取消不作任何处理
				end)
            return
        end
    elseif Type == 4 then
        if CC.Player.Inst():GetSelfInfoByKey("EPC_CombineEgg_Key") < Times then
            local box = CC.ViewManager.ShowMessageBox(self.view.language.TicketNotEnough,
				function ()
					CC.HallNotificationCenter.inst():post(CC.Notifications.OnCollectionViewJumpToView, "CompositeGiftView")
				end,
				function ()
					--取消不作任何处理
                end)
            box:SetCloseBtn()
            return
        end
    end
    self.view:SetCanClick(false);
    local data ={}
    data.Type = Type;
    data.Times = Times;
    CC.Request("ReqCombineEgg",data);
end

function ComposeCapsuleViewCtr:OnGetCombineEggMarquee(err,data)
    if err == 0 then
        CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData").SetCombineEggMarquee(data)
        self.view:ShowMarquee()
    else
        log("扭蛋记录拉取失败!")
    end
end

function ComposeCapsuleViewCtr:OnCombineEgg(err,data)
    if err == 0 then
        self.reward = data
        local count = #self.reward.Rewards
        self.view:PlayLotteryAnim(count > 1 and true or false)
    elseif err == 401 then
        --401错误引导玩家升级VIP
        self.view:SetCanClick(true);
        local box = CC.ViewManager.ShowMessageBox(self.view.language.TimesNotEnough,
        function ()
            CC.HallNotificationCenter.inst():post(CC.Notifications.OnCollectionViewJumpToView, "CompositeGiftView")
        end,
        function ()
            --取消不作任何处理
        end)
        box:SetCloseBtn()
    else
        log("扭蛋请求错误:"..err)
        --请求失败，界面可以接收点击事件
        self.view:SetCanClick(true);
    end
end

function ComposeCapsuleViewCtr:OpenRewardPanel()
    CC.ViewManager.OpenRewardsView({items = self.reward.Rewards,title = "Capsule",forceSize = true,callback = function ()
        self.view:RefreshSelfInfo()
    end,splitState = true});
    --判断是否额外奖励
    if self.reward.ExtraRewards[1] then
        CC.ViewManager.OpenRewardsView({items = self.reward.ExtraRewards,title = "CapsuleEx",forceSize = true,callback = function ()
            self.view:RefreshSelfInfo()
        end,splitState = true});
    end
    self.view:SetCanClick(true);
end

function ComposeCapsuleViewCtr:OnCombineEggMarquee()
    self.view:ShowMarquee()
end

function ComposeCapsuleViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnGetCombineEggMarquee,CC.Notifications.NW_ReqGetCombineEggMarquee)
    CC.HallNotificationCenter.inst():register(self,self.OnCombineEgg,CC.Notifications.NW_ReqCombineEgg)
    CC.HallNotificationCenter.inst():register(self,self.OnCombineEggMarquee,CC.Notifications.RefrshCombineEggMarquee)
end

function ComposeCapsuleViewCtr:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetCombineEggMarquee)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqCombineEgg)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.RefrshCombineEggMarquee)
end

function ComposeCapsuleViewCtr:Destroy()
    self:unRegisterEvent()
    self.view = nil
end

return ComposeCapsuleViewCtr