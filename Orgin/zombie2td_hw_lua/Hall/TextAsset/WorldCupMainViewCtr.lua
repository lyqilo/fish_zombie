local CC = require("CC")

local WorldCupMainViewCtr = CC.class2("WorldCupMainViewCtr")
local M = WorldCupMainViewCtr

function M:ctor(view, param)
	self:InitVar(view,param)
end

function M:InitVar(view, param)
	self.param = param

	self.view = view

	self.worldCupData = CC.DataMgrCenter.Inst():GetDataByKey("WorldCupData");
end

function M:OnCreate()

	self:InitUIByData();

	self:RegisterEvent();

	self:ReqRankData();
end

function M:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self,self.OnRefreshRankHead,CC.Notifications.NW_ReqGetWorldCupRank);
end

function M:UnRegisterEvent()
	
	CC.HallNotificationCenter.inst():unregisterAll(self);
end

function M:InitUIByData()

	local data = self.worldCupData.GetHomePageData();
	local adData = {};
	if data.GameResults then
		for _,v in ipairs(data.GameResults) do
			local t = {};
			t.type = "Match";
			t.country = {};
			for k,c in ipairs(v.Countrys) do
				t.country[k] = {};
				t.country[k].id = c.CountryId;
				t.country[k].score = c.Score;
			end
			table.insert(adData, t);
		end
	end
	if data.LuckPlayers then
		for _,v in ipairs(data.LuckPlayers) do
			local t = {
				type = "Lucker",
				playerId = v.PlayerId,
				portrait = v.Portrait,
				nick = v.Nick,
				headFrame = v.Background,
				bonus = v.Bonus
			};
			table.insert(adData, t);		
		end
	end
	self.view:InitAdScroller(adData);
	if data.TodayGames then
		self.view:InitScheduleBoard(data.TodayGames);
	end
end

function M:ReqRankData()
	CC.Request("ReqGetWorldCupRank",{From = 0, To = 2});
end

function M:OnRefreshRankHead(err, data)
	if err ~= 0 then return end
	CC.uu.Log(data, "WorldCupRank:")
	local score = data.RankInfo.MyScore >= 0 and data.RankInfo.MyScore or 0;
	self.worldCupData.SetScore(score);
	CC.HallNotificationCenter.inst():post(CC.Notifications.changeSelfInfo,{})
	self.view:RefreshRankHeadIcon(data);
end

function M:Destroy()

	self:UnRegisterEvent()
end

return M