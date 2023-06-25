
local CC = require("CC")

local GiveGiftSearchViewCtr = CC.class2("GiveGiftSearchViewCtr")

function GiveGiftSearchViewCtr:ctor(view, param)
	self:InitVar(view, param)
end

function GiveGiftSearchViewCtr:InitVar(view, param)
	self.param = param
	self.view = view
	self.mailDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Mail")
	self.ThreeCardState = false
end

function GiveGiftSearchViewCtr:OnCreate()
	self:RegisterEvent()
	
	self:ReqGetTradeRank()
	CC.Request("GetOrderStatus",{"23006"})

	CC.HallUtil.OnShowHallCamera(false);
end

function GiveGiftSearchViewCtr:Destroy()
	self:unRegisterEvent()
	CC.HallUtil.OnShowHallCamera(true);
end

function GiveGiftSearchViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.ResLoadTradeSended, CC.Notifications.NW_ReqLoadTradeSended)
	CC.HallNotificationCenter.inst():register(self, self.ResLoadTradeReceived, CC.Notifications.NW_ReqLoadTradeReceived)
	CC.HallNotificationCenter.inst():register(self, self.ResLoadTradeSummaries, CC.Notifications.NW_ReqLoadTradeSummaries)
	CC.HallNotificationCenter.inst():register(self, self.ResGetTradeRank, CC.Notifications.NW_ReqGetSuperRank)
	CC.HallNotificationCenter.inst():register(self, self.ReqOrderStatusResq,CC.Notifications.NW_GetOrderStatus)
	CC.HallNotificationCenter.inst():register(self, self.ReqLoadRecommandedFriendsResp,CC.Notifications.NW_ReqLoadRecommandedFriends)

	CC.HallNotificationCenter.inst():register(self,self.RefreshChatState,CC.Notifications.ChatFlash)
	CC.HallNotificationCenter.inst():register(self,self.VipThreeCardBuy,CC.Notifications.VipThreeCard)
	CC.HallNotificationCenter.inst():register(self,self.VipChanged,CC.Notifications.VipChanged)
	CC.HallNotificationCenter.inst():register(self,self.RefreshInformation,CC.Notifications.OnRefreshLoadNews)
	CC.HallNotificationCenter.inst():register(self,self.OnNoviceReward,CC.Notifications.NoviceReward)
	CC.HallNotificationCenter.inst():register(self,self.OnSearchFriend,CC.Notifications.OnSearchFriend)
	--CC.HallNotificationCenter.inst():register(self,self.OnReqTradeSuccess,CC.Notifications.ReqTradeSuccess)
	CC.HallNotificationCenter.inst():register(self,self.OnGetTrade,CC.Notifications.MailAdd)
end

function GiveGiftSearchViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function GiveGiftSearchViewCtr:ReqTradeSended()
	CC.Request("ReqLoadTradeSended",{Index = 1}) --请求拉取第一页
end

--赠送记录回调
function GiveGiftSearchViewCtr:ResLoadTradeSended(err,data)
	if err == 0 then
		self.view.GiftDataMgr:SetGiftRecordData(data)
		if #data.Records == 20 and data.Index < 5 then
			CC.Request("ReqLoadTradeSended",{Index = data.Index + 1})
		else
			if not self.recordInit then
				self.recordInit = true
				self.view.recordController:InitScroller(self.view.GiftDataMgr:GiftRecordLen())
			else
				self.view.recordController:RefreshScroller(self.view.GiftDataMgr:GiftRecordLen(),1 - self.view.recordScroRect.verticalNormalizedPosition)
			end
		end
	end
end

--收礼记录
function GiveGiftSearchViewCtr:ReqTradeReceived()
	CC.Request("ReqLoadTradeReceived",{Index = 1})
end

--收礼记录回调
function GiveGiftSearchViewCtr:ResLoadTradeReceived(err,data)
	if err == 0 then
		local index = data.Index
		self.view.GiftDataMgr:SetCollectData(data)
		if #data.Records == 20 and index < 5 then
			CC.Request("ReqLoadTradeReceived",{Index=index + 1})
		else
			if not self.collectInit then
				self.collectInit = true
				self.view.collectController:InitScroller(self.view.GiftDataMgr:CollectLen())
			else
				self.view.collectController:RefreshScroller(self.view.GiftDataMgr:CollectLen(),1 - self.view.collectScroRect.verticalNormalizedPosition)
			end
		end
	end
end

--月汇总
function GiveGiftSearchViewCtr:ReqTradeSummaries()
	CC.Request("ReqLoadTradeSummaries")
end

function GiveGiftSearchViewCtr:ResLoadTradeSummaries(err,data)
	if err == 0 then
		self.view.GiftDataMgr:SetSummaryData(data)
		if not self.summaryInit then
			self.summaryInit = true
			self.view.summaryController:InitScroller(self.view.GiftDataMgr:SummaryLen())
		else
			self.view.summaryController:RefreshScroller(self.view.GiftDataMgr:SummaryLen(),1 - self.view.summaryScroRect.verticalNormalizedPosition)
		end
	end
end

--赠送排行榜
function GiveGiftSearchViewCtr:ReqGetTradeRank()
	CC.Request("ReqGetSuperRank", {From = 0,To = 9})
end

--赠送排行榜回调
function GiveGiftSearchViewCtr:ResGetTradeRank(err,data)
	if err == 0 then
		self.view.GiftDataMgr:SetTradeRankData(data)
		self.view:HeadItem()
	end
end

function GiveGiftSearchViewCtr:ReqOrderStatusResq(err, data)
	if err == 0 and data.Items then
		for _, v in ipairs(data.Items) do
			if v.WareId == "23006" then --直升卡
				self.ThreeCardState = v.Enabled
				self.view:SetVipThreeBtnShow(v.Enabled)
			end
		end
	end
end

function GiveGiftSearchViewCtr:VipThreeCardBuy(param)
	if param.Source == CC.shared_transfer_source_pb.TS_Vip_GoStraightTo then
		self.ThreeCardState = false
		self.view:SetVipThreeBtnShow(false)
    end
end

function GiveGiftSearchViewCtr:VipChanged(level)
	if level >= 3 then
		self.view:GiftGuide()
		self.view:SetVipThreeBtnShow(false)
	end
end

function GiveGiftSearchViewCtr:RefreshChatState(state)
	self.view:RefreshChat(state)
end

function GiveGiftSearchViewCtr:OnNoviceReward()
	self.view:OnNoviceReward()
end

--资讯列表
function GiveGiftSearchViewCtr:ReqLoadInformation()
	CC.Request("ReqLoadNews")
end

function GiveGiftSearchViewCtr:RefreshInformation()
	self.view:InitInfo()
end

--资讯修改
function GiveGiftSearchViewCtr:OnChangeSelf()
	CC.ViewManager.Open("GiveChangeSelfView",{callback = function()
		self.view:InitInfo()
		self.view:UpdataSelfInfo()
	end})
end

--推荐列表
function GiveGiftSearchViewCtr:ReqLoadRecommandedFriends()
	CC.Request("ReqLoadRecommandedFriends")
end

--请求推荐列表返回
function GiveGiftSearchViewCtr:ReqLoadRecommandedFriendsResp(err,data)
	--log("err = ".. err.."  "..CC.uu.Dump(data,"ReqLoadRecommandedGuies",10))
	if err == 0 then
		self.view.GiftDataMgr:SetReCommandGuy(data)
		self.view:InitPerson(self.view.GiftDataMgr:GetReCommandGuy())
	end
end

--领取邮件
function GiveGiftSearchViewCtr:OnGetAttachments(Amount,mailid,BtnSelect)
	local param = {}
	param.MailId = mailid
	local reward =  {}
		reward[1] ={
			["ConfigId"] = 2,
			["Count"] = tonumber(Amount)
		}
	--请求领取邮件附件

    CC.Request("ReqMailTakeAttachments",param,function(err, data)
		self.mailDataMgr.SetMailAttackTook(param.MailId)
		self.mailDataMgr.SetMailOpen(param.MailId)
		CC.ViewManager.OpenRewardsView({items = reward})
		BtnSelect()
		CC.HallNotificationCenter.inst():post(CC.Notifications.MailOpen);
	end)
end

--获取好友数据
function GiveGiftSearchViewCtr:RequestSearchView(str)
	local param = {
		playerId = str,
		propTypes = {CC.shared_enums_pb.EPT_Wealth}
	}
	CC.Request("ReqLoadPlayerWithPropType",param, function(err,data)
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnSearchFriend,err,data)
	end, function(err, data)
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnSearchFriend,err,data)
	end)
end

--获取好友结果
function GiveGiftSearchViewCtr:OnSearchFriend(err,data)
	if err == 0 then
		self.view.Scroll_Init:SetActive(false)
		self.view.Scroll_Result:SetActive(true)
		self.view.GiftDataMgr:SetSeachPersonData(data)
		local GiftData = self.view.GiftDataMgr:GetSeachPersonData()
		local chouma = self:GetPropValueByKey("EPC_ChouMa",data)
		self.view:ItemData(1,GiftData,self.view.Scroll_Result:FindChild("Viewport/Content"),GiftData.Id,chouma)
	else
		CC.ViewManager.ShowTip(self.view.language.NoSearchResult)
	end
end

--获取玩家筹码总量
function GiveGiftSearchViewCtr:GetPropValueByKey(key,data)
	local propId = CC.shared_enums_pb[key];
	if not propId then
		logError("PersonalInfoViewCtr:shared_enums_pb has no enum value of "..tostring(key))
		return
	end
	local propsData = data.Data.Props
	for _,v in ipairs(propsData) do
		if v.ConfigId == propId then
			return v.Count
		end
	end
	logError("PersonalInfoViewCtr:has no this propId-"..tostring(propId))
end

--赠送成功
function GiveGiftSearchViewCtr:OnReqTradeSuccess(data)
	self.view.GiftDataMgr:AddGiftRecordData(data)
	--及时刷新界面
	if self.view.curTab == 3 then
	    if self.view.curSubTab == 1 then
			self.view.recordController:RefreshScroller(self.view.GiftDataMgr:GiftRecordLen(),1 - self.view.recordScroRect.verticalNormalizedPosition)
		elseif self.view.curSubTab == 3 then
			self:ReqTradeSummaries()
		end
	end
end

--收到赠送，目前收到赠送走的是邮件，所以这里监听邮件的推送，后续如果走单独的推送，这里的监听可以取消
function GiveGiftSearchViewCtr:OnGetTrade()
	--及时刷新界面
	if self.view.curTab == 3 then
		if self.view.curSubTab == 2 then
			self:ReqTradeReceived()
		elseif self.view.curSubTab == 3 then
			self:ReqTradeSummaries()
		end
	end
end
return GiveGiftSearchViewCtr;