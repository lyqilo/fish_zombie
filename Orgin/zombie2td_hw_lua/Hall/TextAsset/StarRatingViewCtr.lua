local CC = require("CC")
local StarRatingViewCtr = CC.class2("StarRatingViewCtr")

function StarRatingViewCtr:ctor(view,param)
	self:InitVar(view,param)
end

function StarRatingViewCtr:InitVar(view,param)
    self.view = view
	self.param = param
end

function StarRatingViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnSendRewardForAppRateRsp,CC.Notifications.NW_ReqSendRewardForAppRate)
	CC.HallNotificationCenter.inst():register(self,self.OnAppRateCallBack,CC.Notifications.OnAppRateCallBack)
end

function StarRatingViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function StarRatingViewCtr:OnCreate()
	self:RegisterEvent()
end

function StarRatingViewCtr:OnAppRateCallBack(msg)
	if msg then
		local table = Json.decode(msg)
		local code = table.code
		logError("Reviews response:"..code)
		if code == 0 then
			--完成调起流程
			self:ReqSendRewardForAppRate()
		else
			logError("调起系统评价失败")
			if self.param.errCb then
				self.param.errCb()
			end
		end
	end
end

function StarRatingViewCtr:ReqSendRewardForAppRate()
	CC.Request("ReqSendRewardForAppRate")
end

function StarRatingViewCtr:OnSendRewardForAppRateRsp(err,data)
	if err ~= 0 then
		logError("ReqSendRewardForAppRate err:"..err)
		if self.param.errCb then
			self.param.errCb()
		end
		self.view:ActionOut()
		return
	end
	log("发放五星好评奖励")
	CC.LocalGameData.SetLocalDataToKey("StarRatingReward", CC.Player.Inst():GetSelfInfoByKey("Id"))
	if self.param.succCb then
		self.param.succCb()
	end
	self.view:ActionOut()
end

function StarRatingViewCtr:Destroy()
	self:UnRegisterEvent()
end

return StarRatingViewCtr