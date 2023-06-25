
local CC = require("CC")

local WeekRankViewCtr = CC.class2("WeekRankViewCtr")

function WeekRankViewCtr:ctor(view, param)
	self:InitVar(view, param)
end

function WeekRankViewCtr:OnCreate()
	self:RegisterEvent()
	self:ReqGetWeeklyRank()
end

function WeekRankViewCtr:Destroy()
	self:unRegisterEvent()
end


function WeekRankViewCtr:InitVar(view, param)
	self.param = param
	--UI对象
	self.view = view
end

--获取周榜奖励的长度
function WeekRankViewCtr:GetConfigRwardCount(rank)
	if rank == 0 then
		return 10000000
	elseif rank == 1 then
		return 7000000
	elseif rank == 2 then
		return 5000000
	elseif rank < 10 then
		return 3000000
	elseif rank < 30 then
		return 2000000
	else
		return 1000000
	end
end

function WeekRankViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ResGetWeeklyRank,CC.Notifications.NW_ReqGetWeeklyRank)
end

function WeekRankViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetWeeklyRank)
end

--获取周邦
function WeekRankViewCtr:ReqGetWeeklyRank()
	if self.view.RankDataMgr.GetRankMgrLen(3) ~= 0 then
		self.view:SetNewLen(self.view.WeekendLoopScrollRect)
		self.view:DownTip(self.view.Weeken_RankItem)
		self.view:HeadItem()
	else		
		CC.Request("ReqGetWeeklyRank",{From=0,To=49})
	end
	
end

--获取周邦回调
function WeekRankViewCtr:ResGetWeeklyRank(err,data)
	if err == 0 then
		self.view.RankDataMgr.SetWeeklyRankData(data)
		self.view:SetNewLen(self.view.WeekendLoopScrollRect)
		self.view:DownTip(self.view.Weeken_RankItem)
		self.view:HeadItem()
	end	
end

return WeekRankViewCtr