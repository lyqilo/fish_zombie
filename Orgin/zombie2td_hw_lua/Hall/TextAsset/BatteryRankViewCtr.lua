local CC = require("CC")
local BatteryRankViewCtr = CC.class2("BatteryRankViewCtr")

function BatteryRankViewCtr:ctor(view,param)
	self:InitVar(view,param)
end

function BatteryRankViewCtr:InitVar(view,param)
	self.view = view
	self.param = param or {}
	self.rankData = {}
end

function BatteryRankViewCtr:OnCreate()
	self:RegisterEvent()
	self:OnReqRankInfo()
end

function BatteryRankViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqGetBatteryRankRsp,CC.Notifications.NW_ReqGetBatteryRank)
end

function BatteryRankViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function BatteryRankViewCtr:OnReqRankInfo()
	CC.Request("ReqGetBatteryRank", {From = 0,To = 49})
end

function BatteryRankViewCtr:ReqGetBatteryRankRsp(err,result)
	if err ~= 0 then
		logError("ReqGetBatteryRank err:"..err)
		self:OnShowErrorTips(err)
		return
	end
    log(CC.uu.Dump(result, "ReqGetBatteryRank"))
	self.rankData = result.Rank
	self.view:RefreshRankList(result)
end

function BatteryRankViewCtr:OnShowErrorTips(err)
	if err == -1 then
		local tips = CC.LanguageManager.GetLanguage("L_Common").tip9
		CC.ViewManager.ShowTip(tips)
	end
end

function BatteryRankViewCtr:OnDestroy()
	self:UnRegisterEvent()
end

return BatteryRankViewCtr