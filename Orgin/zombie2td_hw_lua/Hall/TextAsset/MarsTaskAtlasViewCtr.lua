local CC = require("CC")
local MarsTaskAtlasViewCtr = CC.class2("MarsTaskAtlasViewCtr")
local M = MarsTaskAtlasViewCtr

function M:ctor(view,param)
	self:InitVar(view,param)
end

function M:InitVar(view,param)
    self.view = view
	self.param = param
	self.boxData = {}
	self.hasAvatar = {}
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnLevelAwardListRsp,CC.Notifications.NW_Req_UW_MarsGetLevelAwardList)
	CC.HallNotificationCenter.inst():register(self,self.OnReceiveLevelAwardRsp,CC.Notifications.NW_Req_UW_MarsReceiveLevelAward)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function M:OnCreate()
	self:RegisterEvent()
end

function M:StartRequest()
	self:ReqLevelAwardList()
end

--请求层级奖励信息
function M:ReqLevelAwardList()
	CC.Request("Req_UW_MarsGetLevelAwardList")
end

function M:OnLevelAwardListRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_MarsGetLevelAwardList err:"..err)
		return
	end
	--CC.uu.Log(data,"Req_UW_MarsGetLevelAwardList Rsp:",2)
	self.hasAvatar = {}
	for _,v in ipairs(data.ObtainAvatarIDs) do
		self.hasAvatar[v] = true
	end
		
	local t = {}
	for _,v in ipairs(data.LevelAwardList) do
		t[v.level] = v
	end
	self.boxData = t
	self.view:RefreshBoxState(t)
	if self.param.OpenBox then
		self.view:OnClickBox(self.param.OpenBox)
		self.param.OpenBox = nil
	end
end

--请求领取阶层奖励
function M:ReqReceiveLevelAward(level,avatarId)
	local param = {}
	param.level = level
	param.avatarId = avatarId
	CC.Request("Req_UW_MarsReceiveLevelAward",param)
end

function M:OnReceiveLevelAwardRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_MarsReceiveLevelAward err:"..err)
		return
	end
	--CC.uu.Log(data,"Req_UW_MarsReceiveLevelAward Rsp:",2)
	self.view.selectPanel:SetActive(false)
	local rewards = {}
	for _,v in ipairs(self.boxData[self.view.selectLevel].RewardsList) do
		table.insert(rewards,{ConfigId = v.PropID, Count = v.PropNum})
	end
	local headIcon = {}
	table.insert(headIcon,{HeadId = self.view.selectedId, Count = 1})
	
	self.view:ShowBoxAnimation()
	self.view:DelayRun(2,function ()
		CC.ViewManager.OpenMarsTaskRewardsView({items = rewards, avatars = headIcon,callback = self.CheckRedPacket})
		self:ReqLevelAwardList()
	end)

end

function M:CheckRedPacket()
	local num = CC.Player.Inst():GetSelfInfoByKey("EPC_One_Red_env") or 0
	if num >= 20 then
		CC.ViewManager.OpenAndReplace("TreasureView",{exchangeId = "100064"})
	end
end

function M:Destroy()
	self:UnRegisterEvent()
end

return MarsTaskAtlasViewCtr