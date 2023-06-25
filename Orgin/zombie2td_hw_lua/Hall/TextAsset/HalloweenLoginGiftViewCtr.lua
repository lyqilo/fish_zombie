local CC = require("CC")
local HalloweenLoginGiftViewCtr = CC.class2("HalloweenLoginGiftViewCtr")

function HalloweenLoginGiftViewCtr:ctor(view,param)
	self:InitVar(view,param)
end

function HalloweenLoginGiftViewCtr:InitVar(view,param)
	self.view = view
	self.param = param
	self.aniConfig = {
		orgInterval = 0.8, 		--初始跳动时间间隔/s
		intervalChange = 0.2,	--每次时间间隔变化值/s
		intervalMin = 0.12,		--最小时间间隔/s
		intervalMax = 1.0,		--最大时间间隔/s
		baseTimes = 18,			--基础跳动次数
		randomTimes= 4,			--随机增加0-X次跳动次数
	}
	self.curTimes = 1			--当前跳动次数
	self.totalTimes = 0			--总跳动次数
	self.finalTarget = 1		--目标
	--前六天奖励配置
	self.rewardsCfg = {
		[1] = {Id = 2,Num = 2000},
		[2] = {Id = 71,Num = 1},
		[3] = {Id = 46,Num = 10},
		[4] = {Id = 10001,Num = 1},
	}
	--第七天奖励
	self.finalRewardsCfg = {
		[1] = {Id = 10004,Num = 1},
		[2] = {Id = 10003,Num = 1},
		[3] = {Id = 10002,Num = 1},
		[4] = {Id = 10001,Num = 1},
		[5] = {Id = 46,Num = 10},
		[6] = {Id = 71,Num = 1},
		[7] = {Id = 2,Num = 2000},
	}
	--当前是否最终奖励
	self.isFinal = false
	self.rewardsInfo = nil
end

function HalloweenLoginGiftViewCtr:OnCreate()
	
	self:RegisterEvent()
	local epcWaterSign = CC.Player.Inst():GetSelfInfoByKey("EPC_TenGift_Sign_88")
	if (epcWaterSign and epcWaterSign > 0) then 
		self:ReqGiftInfo()
	else
		self:CheckCanBuy()
	end
end

function HalloweenLoginGiftViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnGiftInfoRsp,CC.Notifications.NW_GetHalloween10thbGiftInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnGetRewardsRsp,CC.Notifications.NW_GetHalloween10thbGiftReward)
	CC.HallNotificationCenter.inst():register(self,self.OnChangeSelfInfo,CC.Notifications.changeSelfInfo)
end

function HalloweenLoginGiftViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetHalloween10thbGiftInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetHalloween10thbGiftReward)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.changeSelfInfo)
end

function HalloweenLoginGiftViewCtr:CheckCanBuy()
	
	if CC.HallUtil.IsHalloweenLoginGiftCanBuy() then
		self.view:RefreshBtnStatus(1)
		self.view:StartTimer("CheckCanBuyTimer",1,function ()
			if not CC.HallUtil.IsHalloweenLoginGiftCanBuy() then
				self.view:StopTimer("CheckCanBuyTimer")
				self.view:RefreshBtnStatus()
			end
		end,-1)
	else
		self.view:RefreshBtnStatus()
	end
end

function HalloweenLoginGiftViewCtr:ReqGiftInfo()
	CC.Request("GetHalloween10thbGiftInfo")
end

function HalloweenLoginGiftViewCtr:OnGiftInfoRsp(err,result)
	if err ~= 0 then
		logError("ReqGiftInfo Error:"..err)
		return
	end
	CC.uu.Log(result,"OnGiftInfoRsp",1)
	self.isFinal = result.IsFinalReward
	if result.CanGetReward then
		self.view:RefreshBtnStatus(2)
	elseif result.IsAllReward then
		self.view:RefreshBtnStatus(4)
	else
		self.view:RefreshBtnStatus(3)
	end
end

function HalloweenLoginGiftViewCtr:ReqGetRewards()
	CC.Request("GetHalloween10thbGiftReward")
end

function HalloweenLoginGiftViewCtr:OnGetRewardsRsp(err,result)
	if err ~= 0 then
		logError("ReqGetRewards Error:"..err)
		return
	end
	--CC.uu.Log(result,"OnGetRewardsRsp",1)
	self.view:RefreshBtnStatus(3)
	
	self.rewardsInfo = result.Reward
	
	if self.isFinal then
		self.view:ShowRewardsView(result.Reward)
	else
		for k,v in ipairs(self.rewardsCfg) do
			if result.Reward.ConfigId == v.Id then
				self:StartAnimation(k)
			end
		end
	end
end

function HalloweenLoginGiftViewCtr:OnChangeSelfInfo(props,source)
	if source == CC.shared_transfer_source_pb.TS_Halloween_PayBag_Rewards then
		for _,v in ipairs(props) do
			if v.ConfigId == CC.shared_enums_pb.EPC_TenGift_Sign_88 then
				self:ReqGiftInfo()
			end
		end
	end
end

function HalloweenLoginGiftViewCtr:StartAnimation(target)
	self:SetCanClick(false)
	self.finalTarget = target
	self.curTimes = 1
	self.curSelect = math.random(1,4)
	self.curInterval = self.aniConfig.orgInterval
	self.totalTimes = self.aniConfig.baseTimes + math.random(0,self.aniConfig.randomTimes)
	self.view:ShowItemLight(self.curSelect)
	self.view:DelayRun(self.curInterval,function ()
		self:OnAnimation()
	end)
end

function HalloweenLoginGiftViewCtr:OnAnimation()
	
	self.curTimes = self.curTimes + 1
	local nextSelect = math.random(1,4)
	if self.curTimes < self.totalTimes - 1 then
		while (nextSelect == self.curSelect) do
			nextSelect = math.random(1,4)
		end
	else
		while (nextSelect == self.curSelect) or (nextSelect == self.finalTarget)do
			nextSelect = math.random(1,4)
		end
	end
	self.curSelect = nextSelect
	self.view:ShowItemLight(nextSelect)
	
	--下一次的间隔
	if self.curTimes < self.totalTimes*(3/4) then
		--减少间隔(加速)
		self.curInterval = Mathf.Clamp(self.curInterval - self.aniConfig.intervalChange,self.aniConfig.intervalMin,self.aniConfig.intervalMax)
	else
		--增加间隔(减速)
		self.curInterval = Mathf.Clamp(self.curInterval + self.aniConfig.intervalChange,self.aniConfig.intervalMin,self.aniConfig.intervalMax)
	end
	
	if self.curTimes < self.totalTimes - 1 then
		self.view:DelayRun(self.curInterval,function ()
			self:OnAnimation()
		end)
	else
		self.view:ShowItemLight(self.finalTarget,true)
		self.view:DelayRun(self.curInterval,function ()
			self.view:ShowRewardsView(self.rewardsInfo)
			self:SetCanClick(true)
		end)
	end
end

function HalloweenLoginGiftViewCtr:SetCanClick(flag)

	self.view:SetCanClick(flag);

	CC.HallNotificationCenter.inst():post(CC.Notifications.FreeChipsCollectionClickState, flag);
end

function HalloweenLoginGiftViewCtr:OnDestroy()
	self:UnRegisterEvent()
end

return HalloweenLoginGiftViewCtr