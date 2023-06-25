local CC = require("CC")
local DonateViewCtr = CC.class2("DonateViewCtr")

function DonateViewCtr:ctor(view,param)
	self:InitVar(view,param)
end

function DonateViewCtr:InitVar(view,param)
	self.view = view
	self.param = param
	self.serverScore = nil
	self.rankData = {}
	self.donateNum = 0
end

function DonateViewCtr:OnCreate()
	self:RegisterEvent()
	self:ReqDonateNum()
	self:ReqDonateRank()
	self:ReqMarqueeList()
end

function DonateViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnDonateRsp,CC.Notifications.NW_ReqDonate)
	CC.HallNotificationCenter.inst():register(self,self.OnDonateNumRsp,CC.Notifications.NW_ReqDonateNums)
	CC.HallNotificationCenter.inst():register(self,self.OnMarqueeRsp,CC.Notifications.NW_ReqDonateBroadCast)
	CC.HallNotificationCenter.inst():register(self,self.OnDonateRankRsp,CC.Notifications.NW_ReqDonateRankRecord)
	CC.HallNotificationCenter.inst():register(self,self.OnChangeSelfInfo,CC.Notifications.changeSelfInfo)
end

function DonateViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqDonate)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqDonateNums)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqDonateBroadCast)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqDonateRankRecord)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.changeSelfInfo)
end

function DonateViewCtr:ReqDonateNum()
	local data = {}
	data.ActivityType = CC.proto.client_time_activities_pb.Merits
	CC.Request("ReqDonateNums",data)
end

function DonateViewCtr:OnDonateNumRsp(code,result)
	if code ~= 0 then
		logError("ReqDonateNums err:"..code)
		return
	end
	CC.uu.Log(result,"OnDonateNumRsp",1)
	self.view:RefreshSelfInfo(result)
end

function DonateViewCtr:ReqDonateRank()
	local data = {}
	data.ActivityType = CC.proto.client_time_activities_pb.Merits
	CC.Request("ReqDonateRankRecord",data)
end

function DonateViewCtr:OnDonateRankRsp(code,result)
	if code ~= 0 then
		logError("ReqDonateRankRecord err:"..code)
		return
	end
	CC.uu.Log(result,"OnDonateRankRsp",1)
	self.rankData = result.RecordList
	self.view:RefreshRankList(result)
end

function DonateViewCtr:ReqDonate()
	local ownNum = CC.Player.Inst():GetSelfInfoByKey("EPC_Merits")
	if ownNum < 10 then
		CC.ViewManager.ShowTip(self.view.language.donateTip)
		return
	end
	self.view:SetCanClick(false)
	local data = {}
	data.ActivityType = CC.proto.client_time_activities_pb.Merits
	if ownNum < 1000 then
		data.DonateNum = ownNum
	else
		data.DonateNum = 1000
	end
	self.donateNum = data.DonateNum
	CC.Request("ReqDonate",data)
end

function DonateViewCtr:OnDonateRsp(code,result)
	if code ~= 0 then
		self.view:SetCanClick(true)
		logError("ReqDonate err:"..code)
		return
	end
	CC.uu.Log(result,"OnDonateRsp",1)
	if not self.hadPlayAni then
		self.hadPlayAni = true
		self.view:ShowDonateAnimation()
	else
		self.view:SetCanClick(true)
		self:ReqDonateNum()
		self:ReqDonateRank()
	end
end

function DonateViewCtr:ReqMarqueeList()
	local data = {}
	data.ActivityType = CC.proto.client_time_activities_pb.Merits
	CC.Request("ReqDonateBroadCast",data)
end

function DonateViewCtr:OnMarqueeRsp(code,result)
	if code ~= 0 then
		logError("ReqDonateBroadCast:"..code)
		return
	end
	CC.uu.Log(result,"OnMarqueeRsp",1)
	for k,v in ipairs(result.RecordList) do
		self.view:ShowMarquee(v.PlayerName,v.PropNum)
	end
end

function DonateViewCtr:OnChangeSelfInfo(props,source)
	--CC.uu.Log(props,"OnChangeSelfInfo",1)
	for _,v in ipairs(props) do
		local count = v.Count
		if v.ConfigId == CC.shared_enums_pb.EPC_Merits then
			self.view:ShowDonateRed()
		end
	end
end

function DonateViewCtr:OnDestroy()

	self:UnRegisterEvent()
end

return DonateViewCtr