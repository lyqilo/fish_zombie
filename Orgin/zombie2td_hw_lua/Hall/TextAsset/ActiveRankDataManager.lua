-- region ActiveRankDataManager.lua
-- Date: 2017.10.27
-- Desc: 任务管理类
-- Author: Chaoe

local CC = require("CC")

local ActiveRankDataManager = CC.class2("ActiveRankDataManager")

local _rankMgr = nil
function ActiveRankDataManager.Inst()
	if not _rankMgr then
		_rankMgr = ActiveRankDataManager.new()
	end
	return _rankMgr
end

function ActiveRankDataManager:ctor()
	self.ActieveRank = {}	--排行榜数据
	self.ActieveMyRank = nil	--排行榜数据
	self.ActiveRankCount = 0
end

--消费榜数据
function ActiveRankDataManager:SetActieveRankData(tab)
	self.ActieveRank = tab.data.Rank
	self.ActieveMyRank = tab.data.Me.Index
	self.ActiveRankCount = tab.data.Me.Count
end

--获取相应下标的消费榜数据
function ActiveRankDataManager:GetActieveRankItemData(index)
	if not self.ActieveRank then
		return
	end
	for i,v in ipairs(self.ActieveRank) do
		if i == index then
			return self.ActieveRank[index]
		end
	end	
end

--获取消费榜数据
function ActiveRankDataManager:GetActieveRankData()
	return self.ActieveRank or nil
end

--获取消费榜长度
function ActiveRankDataManager:GetActieveRankLen()
	return #self.ActieveRank or 0
end

--根据玩家id修改每消费榜昵称
function ActiveRankDataManager:SetActiveRankitemName(Id,name)
	for i,v in ipairs(self.ActieveRank) do
		if v.Player.Id == Id then
			self.ActieveRank[i].Player.Nick = name
		end
	end	
end


--玩家排名
function ActiveRankDataManager:GetMyRank()
		if self.ActieveMyRank ~= 0 then
			return self.ActieveMyRank
		else
			return "No ranking"
		end
end

--玩家消费筹码
function ActiveRankDataManager:GetMyCount()
	return self.ActiveRankCount
end

return ActiveRankDataManager

