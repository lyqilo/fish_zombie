local CC = require("CC")
local AgentRevenueView = CC.uu.ClassView("AgentRevenueView")

function AgentRevenueView:ctor(param)
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView");
	self.param = param or {}
    self:RegisterEvent()
    self.showShareTip = false
    self.showTradeTip = false
    self.curChouma = 0
    self.curGiftVoucher = 0
end

function AgentRevenueView:OnCreate()
	self.btnList = {}
	self:InitContent()
end

function AgentRevenueView:InitContent()
    self:AddClick("BtnEarn", "OnBtnEarnClick")
    self:AddClick("BtnPromote", "OnBtnPromoteClick")
    self:AddClick("BtnJunior", "OnBtnJuniorClick")
    self:AddClick("BtnGet/Icon", "OnGetUnReceiveEarn")
    self:AddClick("earnFromNewer", "OnTaskClick")
    self:AddClick("earnFromShare/name/Image", function()
        self.showShareTip = not self.showShareTip
        self:OnShareTip(self.showShareTip)
    end)
    self:AddClick("earnFromNewer/name/Image", function()
        self:OnTaskClick()
    end)
    self:AddClick("earnFromTrade/name/Image", function()
        self.showTradeTip = not self.showTradeTip
        self:OnTradeTip(self.showTradeTip)
    end)
    self:InitTextByLanguage()
    self:InitViewData()
    self:LoadUnReceiveEarn()
    CC.Request("PromoteTask")
end

function AgentRevenueView:InitTextByLanguage()
    self:FindChild("BtnGet/Icon/Text").text = self.language.btnAll
    self:FindChild("BtnGet/Gray/Text").text = self.language.btnAll
    self:FindChild("TotleRevenue").text = self.language.totalEran
    self:FindChild("Invite").text = self.language.Invite
    self:FindChild("InviteSucced").text = self.language.InviteSucced
    self:FindChild("NoneEarn").text = self.language.noneEarn
    self:FindChild("earnFromTrade/name").text = self.language.TradeEarn
    self:FindChild("earnFromShare/name").text = self.language.ShareEarn
    self:FindChild("earnFromNewer/name").text = self.language.NewerEarn
    self:FindChild("earnFromShare/Tip/Text").text = self.language.ShareEarnTip
    self:FindChild("earnFromTrade/Tip/Text").text = self.language.TradeEarnTip
    self:FindChild("Lock/Text").text = self.language.auditPeriod
end

function AgentRevenueView:InitViewData()
    self:FindChild("Chip/Text").text = 0
    self:FindChild("IntegralCounter/Text").text = 0
    self:FindChild("Invite/Num").text = 0
    self:FindChild("InviteSucced/Num").text = 0
    if self.agentDataMgr.GetAgentLockStatus() then
        self:FindChild("earnFromShare/Lock"):SetActive(true)
        self:FindChild("earnFromNewer/Lock"):SetActive(true)
        self:FindChild("earnFromTrade/Lock"):SetActive(true)
        self:FindChild("Lock"):SetActive(true)
        local time = os.date("%d-%m-%Y %H:%M",self.agentDataMgr.GetAgentLockTime())
        self:FindChild("Lock/Time").text = string.format(self.language.auditTime, time)
    end
end

function AgentRevenueView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.RefreshBtns,CC.Notifications.NW_LoadUnReceiveEarn)
    CC.HallNotificationCenter.inst():register(self,self.PromoteTaskResp, CC.Notifications.NW_PromoteTask)
    CC.HallNotificationCenter.inst():register(self,self.OnReqReceiveAllEarnSucc,CC.Notifications.NW_ReqReceiveAllEarn)
end

function AgentRevenueView:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function AgentRevenueView:OnBtnEarnClick()
	CC.ViewManager.Open("AgentEarningsView")
end

function AgentRevenueView:OnBtnPromoteClick()
	CC.ViewManager.Open("AgentGeneralizeView")
end

function AgentRevenueView:OnBtnJuniorClick()
	CC.ViewManager.Open("AgentJuniorView")
end

function AgentRevenueView:OnGetUnReceiveEarn()
    CC.Request("ReqReceiveAllEarn")
end

function AgentRevenueView:OnTaskClick()
	CC.ViewManager.Open("AgentTaskView")
end

function AgentRevenueView:OnShareTip(show)
	self:FindChild("earnFromShare/Tip"):SetActive(show)
end

function AgentRevenueView:OnTradeTip(show)
	self:FindChild("earnFromTrade/Tip"):SetActive(show)
end

function AgentRevenueView:LoadUnReceiveEarn()
	self.agentDataMgr.LoadUnReceiveEarn()
end

function AgentRevenueView:SetStatus()
    local BeEarn = self.curChouma > 0 or self.curGiftVoucher > 0
    if self.agentDataMgr.GetAgentLockStatus() then
        BeEarn = false
    end
    self:FindChild("NoneEarn"):SetActive(not BeEarn)
    self:FindChild("BtnGet/Icon"):SetActive(BeEarn)
    self:FindChild("BtnGet/Gray"):SetActive(not BeEarn)
end

function AgentRevenueView:RefreshBtns(err, param)
	if err == 0 then
        local data = param or self.agentDataMgr.GetUnReceiveEarn()
        --待领取的赠送收益
        local earnFromTrade = data.earnFromTrade
        --待领取的分成收益
        local earnFromShare = data.earnFromShare
        --待领取的人头收益
        -- local earnFromNewer = data.earnFromNewer
        self:FindChild("earnFromShare/Count").text = CC.uu.ChipFormat(earnFromShare)
        self:FindChild("earnFromTrade/Count").text = CC.uu.ChipFormat(earnFromTrade)
        self:FindChild("Chip/Text").text = data.grantTotalEarn
        self:FindChild("IntegralCounter/Text").text = data.grantTotalGiftEarn
        self:FindChild("Invite/Num").text = data.ChildNum
        self:FindChild("InviteSucced/Num").text = data.ActiveNum
        self.curChouma = earnFromTrade + earnFromShare
        self:SetStatus()
	end
end

function AgentRevenueView:PromoteTaskResp(err, data)
	local list = data.promoteTask
	if not list then return end

	local earnFromNewer = 0
	for _,v in ipairs(list) do
		earnFromNewer = earnFromNewer + v.earn
	end
	self:FindChild("earnFromNewer/Count").text = CC.uu.ChipFormat(earnFromNewer)
    self.curGiftVoucher = earnFromNewer
    self:SetStatus()
end

function AgentRevenueView:OnReqReceiveAllEarnSucc(err,param)
    log("err = ".. err.."  "..CC.uu.Dump(param, "OnReqReceiveAllEarnSucc",10))
	if err == 0 then
        local ChouMa = param.ShareEarn + param.TradeEarn
        local GiftVoucher = param.TaskEarn
        local data = {}
        if ChouMa > 0 then
            table.insert(data, {ConfigId = CC.shared_enums_pb.EPC_ChouMa, Count = ChouMa})
        end
        if GiftVoucher > 0 then
            table.insert(data, {ConfigId = CC.shared_enums_pb.EPC_New_GiftVoucher, Count = GiftVoucher})
        end
		CC.ViewManager.OpenRewardsView({items = data})
		self:LoadUnReceiveEarn()
        CC.Request("PromoteTask")
	end
end

function AgentRevenueView:OnDestroy()
	self:CancelAllDelayRun()
	self:UnRegisterEvent()
end

function AgentRevenueView:ActionIn()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
		{"fadeToAll", 0, 0},
		{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
	});
end

function AgentRevenueView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

return AgentRevenueView