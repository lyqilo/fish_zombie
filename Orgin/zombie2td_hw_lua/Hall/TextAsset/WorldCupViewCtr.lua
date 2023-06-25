local CC = require("CC")

local WorldCupViewCtr = CC.class2("WorldCupViewCtr")
local M = WorldCupViewCtr

function M:ctor(view, param)
	self:InitVar(view,param)
end

function M:InitVar(view, param)
	self.param = param
	self.view = view
	self.worldCupData = CC.DataMgrCenter.Inst():GetDataByKey("WorldCupData");
end

function M:OnCreate()

	self:RegisterEvent();
	
	self:ReqHomePageInfo();
end

function M:ReqHomePageInfo()
	CC.Request("ReqGetWorldCupHomePage");
	CC.Request("ReqGetWorldJackpot");
	self.view:StartTimer("Jackpot", 300, function()
		CC.Request("ReqGetWorldJackpot");
	end, -1)
	local giftData = self.worldCupData.GetWorldCupGiftData()
	if #giftData < 1 then
		CC.Request("ReqWorldCupBuyGiftInfo")
	end
	local giftStatus = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetGiftStatus("30329")
	self.view:SetTaskEffect(not giftStatus)
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshGiftStatus,CC.Notifications.OnTimeNotify);

	CC.HallNotificationCenter.inst():register(self,self.OnRefreshHomePage,CC.Notifications.NW_ReqGetWorldCupHomePage);
	
	CC.HallNotificationCenter.inst():register(self,self.SetJackpotData,CC.Notifications.NW_ReqGetWorldJackpot);

	CC.HallNotificationCenter.inst():register(self,self.OnSubViewChange,CC.Notifications.WorldCupSubViewChange);

	CC.HallNotificationCenter.inst():register(self,self.SetJackpotNode,CC.Notifications.WorldCupJackpotChange);


	CC.HallNotificationCenter.inst():register(self, self.OnPlayerBet, CC.Notifications.NW_ReqPlayerBet)

	CC.HallNotificationCenter.inst():register(self, self.OnChangeProp, CC.Notifications.changeSelfInfo);

	CC.HallNotificationCenter.inst():register(self,self.SetWorldCupBuyGiftInfo,CC.Notifications.NW_ReqWorldCupBuyGiftInfo);
	CC.HallNotificationCenter.inst():register(self,self.DailyGiftReward,CC.Notifications.OnDailyGiftGameReward)
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshSwitchOn,CC.Notifications.OnRefreshActivityBtnsState)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self);
end

function M:OnRefreshGiftStatus()
	CC.Request("ReqWorldCupBuyGiftInfo")
end

function M:OnRefreshHomePage(err, data)
	CC.uu.Log(data,"HomePageData:")
	if err ~= 0 then return end;

	self.worldCupData.SetHomePageData(data);

	self.view:ShowSubView("WorldCupMainView");
end

function M:SetJackpotData(err, data)
	if err ~= 0 then return end
	self.view:RefreshJackpotRoller(data);
end

function M:OnSubViewChange(viewName)

	self.view:ShowSubView(viewName);
end

function M:SetJackpotNode(data)
	if data.type == "champion" then
		self.view.championJPRoller:ChangeTextNode(data.node);
	elseif data.type == "rank" then
		self.view.rankJPRoller:ChangeTextNode(data.node);
	end
end


function M:OnPlayerBet(err,param)
	if err == 0 then
		self.view:SetRecordRed()
	end
end

function M:SetWorldCupBuyGiftInfo(err, data)
	if err == CC.shared_en_pb.End then
		self.view.btnGift:SetActive(false)
		return;
	end
	self.worldCupData.SetWorldCupGiftData(data);
end

function M:DailyGiftReward(data)
	if data.Source == CC.shared_transfer_source_pb.TS_WorldCup_Quizgift then
		self.view:SetTaskEffect(true)
	end
end


function M:OnRefreshSwitchOn(key, switchOn)
	if key == "FlowWaterTaskView" then
		self.view:SetTaskBtn(switchOn)
	end
end

function M:OnChangeProp()
	
	self.view:RefreshInfo();
end

function M:Destroy()

	self:UnRegisterEvent()
end

return M