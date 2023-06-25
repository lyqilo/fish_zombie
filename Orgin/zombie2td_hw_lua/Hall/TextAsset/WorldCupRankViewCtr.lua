
local CC = require("CC")
local WorldCupRankViewCtr = CC.class2("WorldCupRankViewCtr")

function WorldCupRankViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function WorldCupRankViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();

	self:ReqGetWorldCupRank()
	-- self:ReqGetWorldJp()
end

function WorldCupRankViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
end

function WorldCupRankViewCtr:InitData()

end

function WorldCupRankViewCtr:ReqChampionInfo()
	CC.Request("ReqGetChampionInfo")
end

function WorldCupRankViewCtr:ReqGetWorldCupRank()
	CC.Request("ReqGetWorldCupRank",{From=0,To=49})
end

-- function WorldCupRankViewCtr:ReqGetWorldJp()
-- 	CC.Request("ReqGetWorldJackpot")
-- end

function WorldCupRankViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.GetReqWorldCupRankResult,CC.Notifications.NW_ReqGetWorldCupRank)
	-- CC.HallNotificationCenter.inst():register(self,self.GetReqWorldCupJpResult,CC.Notifications.NW_ReqGetWorldJackpot)
	CC.HallNotificationCenter.inst():register(self,self.ReqChampionInfoResult,CC.Notifications.NW_ReqGetChampionInfo)

	-- CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function WorldCupRankViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetChampionInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetWorldCupRank)
	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetWorldJackpot)

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

function WorldCupRankViewCtr:ReqChampionInfoResult(err,data)
	if err == 0 then
		if data.ChampionGenerate then
			CC.LocalGameData.SetWorldCupChampionData(data.ChampionCountry)
			self.view:SetChampionCountryImage(data.ChampionCountry)
		end
	end
end

function WorldCupRankViewCtr:GetReqWorldCupRankResult(err,data)
	if err == 0 then
		-- CC.uu.Log(data,"GetReqWorldCupRankResult-->>GetReqWorldCupRankResult,data:")
		self.view.RankData = data.RankInfo
		self.view.RankRewards = data.RewardList
		self.view:ShowRank()
	end
end

function WorldCupRankViewCtr:GetReqWorldCupJpResult(err,data)
	if err == 0 then
		-- CC.uu.Log(data,"GetReqWorldCupRankResult-->>GetReqWorldCupJpResult,data:")
	end
end



function WorldCupRankViewCtr:Destroy()

	self:UnRegisterEvent();
end

return WorldCupRankViewCtr;
