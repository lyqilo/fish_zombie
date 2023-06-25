local CC = require("CC")

local CapsuleViewCtr = CC.class2("CapsuleViewCtr")

function CapsuleViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function CapsuleViewCtr:OnCreate()
    self:GetTwistEggInfo(0)
    self:GetTwistEggRecord()
end

function CapsuleViewCtr:InitVar(view,param)
    self.view = view
    self.param = param

    self.reward = nil

    self.shareState = false
    self.freeReq = false
    self.freeTimes = 0
	
	self.bigRecord = {}
	self.myRecord = {}
    self.countRecord = {}

    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.propDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
    self.realDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData")

    self:RegisterEvent()
end

function CapsuleViewCtr:RefreshOnlineTime()
    CC.Request("ReqSynOnlineTime");
end

function CapsuleViewCtr:GetTwistEggInfo(err,data)
    if err == 0 then
        CC.Request("GetTwistEggInfo")
    else
        CC.Request("GetTwistEggInfo")
    end
end

function CapsuleViewCtr:GetTwistEggRecord()
    --if self.realDataMgr.GetEggRecord() then
        --self.view:ShowRewardRecord()
    --else
        CC.Request("GetTwistEggRecord")
        CC.Request("GetTwistEggPlayerRecord")
        CC.Request("GetTwistEggRank", {From = 1, To = 10})
    --end
end

function CapsuleViewCtr:ShareComplete()
    CC.Request("ReqTwistEggShareNotice")
end

function CapsuleViewCtr:ReqLottery(Type,Times)
    if Type == self.view.CostType.Chips then
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
				end
            )
            return
        end
    elseif Type == self.view.CostType.GiftVoucher then
        if CC.Player.Inst():GetSelfInfoByKey("EPC_New_GiftVoucher") < Times * 20 then
            CC.ViewManager.ShowTip(self.view.language.TicketNotEnough)
            return
        end
    elseif Type == self.view.CostType.Free then
        if self.freeTimes <= 0 then return end
        self.freeReq = true
    elseif Type == self.view.CostType.Snow then
        --if CC.Player.Inst():GetSelfInfoByKey("EPC_Snow") < Times * 4 then
        if CC.Player.Inst():GetSelfInfoByKey("EPC_TwistEgg_Coin") < Times then
			self.view.jumpPanel:SetActive(true)
            --CC.ViewManager.ShowTip(self.view.language.SnowNotEnough)
            return
        end
    elseif Type == self.view.CostType.Star then
        if CC.Player.Inst():GetSelfInfoByKey("EPC_Lucky_Star") < Times * 10 then
			-- self.view.jumpPanel:SetActive(true)
            CC.ViewManager.ShowTip(self.view.language.SnowNotEnough)
            return
        end
    end
    self.view:SetCanClick(false);
    local data ={}
    data.Type = Type;
    data.Times = Times;
    CC.Request("GetTwistEgg",data);
end

function CapsuleViewCtr:OnGetTwistEggInfo(err,data)
    if err == 0 then
        self.freeTimes = data.Free
        self.shareState = data.IsShare
        local param = {}
        param.IsShare = data.IsShare
        param.Free = data.Free
        param.CD = data.CD
        self.view:RefreshUI(param)
    else
        log("拉取玩家扭蛋免费次数失败")
    end
end

function CapsuleViewCtr:OnGetTwistEggRecord(err,data)
	if err ~= 0 then
		logError("个人扭蛋记录拉取失败："..err)
		return
	end
	local t = {}
	for _,v in ipairs(data.Records) do
		table.insert(t,v)
	end
	self.bigRecord = t
end

function CapsuleViewCtr:OnGetTwistEggPlayerRecord(err,data)
	if err ~= 0 then
		logError("个人扭蛋记录拉取失败")
		return
	end
	local t = {}
	for _,v in ipairs(data.Records) do
		table.insert(t,v)
	end
	self.myRecord = t
end

function CapsuleViewCtr:OnGetTwistEggCountRank(err,data)
    log(CC.uu.Dump(data, "countRecord:"))
	if err ~= 0 then
		logError("扭蛋次数记录排行拉取失败")
		return
	end
	local t = {}
	for _,v in ipairs(data.Rank) do
		table.insert(t,v)
	end
	self.countRecord = t
end

function CapsuleViewCtr:OnGetTwistEgg(err,data)
    CC.uu.Log(data,"OnGetTwistEgg")
    if err == 0 then
		self:GetTwistEggRecord()
        if self.freeReq then
            self.freeReq = false
            self.freeTimes = self.freeTimes - 1
            if self.freeTimes <= 0 then
                self:RefreshOnlineTime()
            else
                local param = {}
                param.Free = self.freeTimes
                self.view:RefreshUI(param)
            end
        end
        self.reward = data
        local count = #self.reward.Rewards
        self.view:PlayLotteryAnim(count > 1 and true or false)
    elseif err == 401 then
        --401错误引导玩家升级VIP
        self.view:SetCanClick(true);
        if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") > 1 then
            CC.ViewManager.ShowTip(self.view.language.FreeTimsNotEnough)
        else
            CC.ViewManager.ShowMessageBox(self.view.language.VIPNotEnough,
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
        end
    else
        log("扭蛋请求错误:"..err)
        --请求失败，界面可以接收点击事件
        self.view:SetCanClick(true);
    end
end

function CapsuleViewCtr:OpenRewardPanel()
    CC.HallNotificationCenter.inst():post(CC.Notifications.FreeChipsCollectionClickState, true);
    
    CC.ViewManager.OpenRewardsView({items = self.reward.Rewards,title = "Capsule",callback = function ()
        self.view:RefreshSelfInfo()
    end,splitState = true});
    --判断是否额外奖励
    if self.reward.ExtraRewards[1] then
        CC.ViewManager.OpenRewardsView({items = self.reward.ExtraRewards,title = "CapsuleEx",callback = function ()
            self.view:RefreshSelfInfo()
        end,splitState = true});
    end
    
    self.view:SetCanClick(true);
end

function CapsuleViewCtr:OnRefrshEggRecord(param)
    self.view:RefrshEggRecord(param)
end

function CapsuleViewCtr:OnGetTwistEggShareNotice(err,data)
    if err == 0 then
        self:RefreshOnlineTime()
    end
end

function CapsuleViewCtr:OnPropChange(props, source)
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_TwistEgg_Coin then
			self.view:RefreshSelfInfo()
			if v.Delta > 0 then
				CC.ViewManager.OpenRewardsView({items = props});
			end
		end
	end
end

function CapsuleViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnGetTwistEggInfo,CC.Notifications.NW_GetTwistEggInfo)
    CC.HallNotificationCenter.inst():register(self,self.OnGetTwistEggRecord,CC.Notifications.NW_GetTwistEggRecord)
    CC.HallNotificationCenter.inst():register(self,self.OnGetTwistEggPlayerRecord,CC.Notifications.NW_GetTwistEggPlayerRecord)
    CC.HallNotificationCenter.inst():register(self,self.OnGetTwistEggCountRank,CC.Notifications.NW_GetTwistEggRank)
    CC.HallNotificationCenter.inst():register(self,self.OnGetTwistEggShareNotice,CC.Notifications.NW_ReqTwistEggShareNotice)
    CC.HallNotificationCenter.inst():register(self,self.OnGetTwistEgg,CC.Notifications.NW_GetTwistEgg)
    CC.HallNotificationCenter.inst():register(self,self.OnRefrshEggRecord,CC.Notifications.RefrshEggRecord)
    --CC.HallNotificationCenter.inst():register(self,self.GetTwistEggInfo,CC.Notifications.NW_ReqSynOnlineTime)
	CC.HallNotificationCenter.inst():register(self,self.OnPropChange,CC.Notifications.changeSelfInfo)
end

function CapsuleViewCtr:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function CapsuleViewCtr:Destroy()
    self:unRegisterEvent()
    self.view = nil
end

return CapsuleViewCtr