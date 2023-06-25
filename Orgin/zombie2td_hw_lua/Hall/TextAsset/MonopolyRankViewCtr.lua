local CC = require("CC")
local MonopolyRankViewCtr = CC.class2("MonopolyRankViewCtr")
local M = MonopolyRankViewCtr

function M:ctor(view,param)
	self:InitVar(view,param)
end

function M:InitVar(view,param)
    self.view = view
	self.param = param
	self.rankList = {}
	self.curLevel = 0
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnRankDataRsp,CC.Notifications.NW_Req_UW_MonopolyListRanks)
	CC.HallNotificationCenter.inst():register(self,self.OnUserInfoRsp,CC.Notifications.NW_Req_UW_MonopolyGetUserInfo)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function M:OnCreate()
	self:RegisterEvent()
end

function M:StartRequest()
	self:ReqRankData()
	self:ReqUserInfo()
end

function M:ReqRankData()
	CC.Request("Req_UW_MonopolyListRanks",{GameId = CC.shared_enums_pb.AE_Breakthrough_party})
end

function M:OnRankDataRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_MonopolyListRanks err:"..err)
		return
	end
	--CC.uu.Log(data,"UWMonopolyRankRsp:",1)
	local param = {}
	param.rankList = {}
	for k,v in ipairs(data.ranks) do
		param.rankList[k] = v
	end
	param.myRank = data.myRank
	self.rankList = param.rankList
	self.view:RefreshUI(param)
end

function M:ReqUserInfo()
	CC.Request("Req_UW_MonopolyGetUserInfo",{GameId = CC.shared_enums_pb.AE_Breakthrough_party})
end

function M:OnUserInfoRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_MonopolyGetUserInfo err:"..err)
		return
	end
	--CC.uu.Log(data,"MonopolyGetUserInfoRsp:",1)
	self.curLevel = data.CurrentLever
	local param = {}
	param.myRankData = {level = data.CurrentLever}
	self.view:RefreshUI(param)
end

function M:Destroy()
	self:UnRegisterEvent()
end

return MonopolyRankViewCtr