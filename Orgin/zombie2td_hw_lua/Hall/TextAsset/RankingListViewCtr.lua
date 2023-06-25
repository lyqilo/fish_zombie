
local CC = require("CC")

local RankingListViewCtr = CC.class2("RankingListViewCtr")

function RankingListViewCtr:ctor(view, param)
	self:InitVar(view, param)	
end

function RankingListViewCtr:OnCreate()
	self:RegisterEvent()
	self:ReqGetSuperRank()
	self:ReqGetDailyRank()
end

function RankingListViewCtr:InitVar(view, param)
	self.param = param
	self.view = view
end

--最大筹码榜
function RankingListViewCtr:ReqGetSuperRank()
	if self.view.RankDataMgr.GetSuperRankLen() == 0 then
		CC.Request("ReqGetSuperRank",{From=0,To=49})
	else
		self.view:DelatRankShow()
	end
end

--获取每日赢取榜单
function RankingListViewCtr:ReqGetDailyRank()
	if self.view.RankDataMgr.GetDailyRankLen() == 0 then
		CC.Request("ReqGetDailyRank",{From=0,To=49})
	end
end

function RankingListViewCtr:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self,self.ResGetSuperRank,CC.Notifications.NW_ReqGetSuperRank)
	CC.HallNotificationCenter.inst():register(self,self.ResGetDailyRank,CC.Notifications.NW_ReqGetDailyRank)
	
end

function RankingListViewCtr:unRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetSuperRank)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetDailyRank)
	
end

--最大筹码榜回调
function RankingListViewCtr:ResGetSuperRank(err,data)
	if err == 0 then
		self.view.RankDataMgr.SetSuperRankData(data)
		self.view:DelatRankShow()
	else
		log("最大筹码榜拉取失败")
	end
end

--获取每日赢取榜单回调
function RankingListViewCtr:ResGetDailyRank(err,data)
	if err == 0 then
		self.view.RankDataMgr.SetDailyRankData(data)
	else
		log("每日赢取榜拉取失败")
	end
end

function RankingListViewCtr:Destroy()
	self:unRegisterEvent()
end

return RankingListViewCtr