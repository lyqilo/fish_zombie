local CC = require("CC")
local AnniversaryRankViewCtr = CC.class2("AnniversaryRankViewCtr")

function AnniversaryRankViewCtr:ctor(view,param)
	self:InitVar(view,param)
end

function AnniversaryRankViewCtr:InitVar(view,param)
	self.view = view
	self.param = param
	self.rankData = {}
	self.boxData = {}
end

function AnniversaryRankViewCtr:OnCreate()
	self:RegisterEvent()
	self:OnReqRankInfo()
	self:OnReqKeyGiftInfo()
end

function AnniversaryRankViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnRankInfoRsp,CC.Notifications.NW_ReqGetLuckyRouletteRank)
	CC.HallNotificationCenter.inst():register(self,self.OnKeyGiftInfoRsp,CC.Notifications.NW_ReqGetGetKeyBoxInfoList)
	CC.HallNotificationCenter.inst():register(self,self.OnOpenKeyBoxRsp,CC.Notifications.NW_ReqOpenKeyBox)
end

function AnniversaryRankViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function AnniversaryRankViewCtr:OnReqRankInfo()
	local data = {}
	data.From = 0
	data.To = 49
	CC.Request("ReqGetLuckyRouletteRank",data)
end

function AnniversaryRankViewCtr:OnRankInfoRsp(err,result)
	if err ~= 0 then
		logError("ReqGetLuckyRouletteRank err:"..err)
		self:OnShowErrorTips(err)
		return 
	end
	--CC.uu.Log("ReqGetLuckyRouletteRank",result,3)
	self.rankData = result
	self.view:RefreshRankList(result)
end

function AnniversaryRankViewCtr:OnReqKeyGiftInfo()
	CC.Request("ReqGetGetKeyBoxInfoList")
end

function AnniversaryRankViewCtr:OnKeyGiftInfoRsp(err,result)
	if err ~= 0 then
		logError("ReqKeyGiftInfo err:"..err)
		self:OnShowErrorTips(err)
		return
	end
	--CC.uu.Log("KeyGiftInfo",result,3)
	self.boxData = result.BoxList
	self.view:RefreshKeyGiftProgress(result.BoxList)
end

function AnniversaryRankViewCtr:OnReqGetGiftReward(index)
	local data = {}
	data.BoxId = tonumber(index)
	CC.Request("ReqOpenKeyBox",data)
end

function AnniversaryRankViewCtr:OnOpenKeyBoxRsp(err,result)
	if err ~= 0 then
		logError("ReqOpenKeyBox Error:"..err)
		self:OnShowErrorTips(err)
		return
	end
	local param = {}
	param.items = {{ConfigId = result.RewardId, Count = result.RewardNum}}
	param.callback = function()
		self:OnReqKeyGiftInfo()
	end
	CC.ViewManager.OpenRewardsView(param)
end

function AnniversaryRankViewCtr:OnShowErrorTips(err)
	if err == 0 then return end
	if err == -1 then
		local tips = CC.LanguageManager.GetLanguage("L_Common").tip9
		CC.ViewManager.ShowTip(tips)
	end
end

function AnniversaryRankViewCtr:OnDestroy()
	self:UnRegisterEvent()
end

return AnniversaryRankViewCtr