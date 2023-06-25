--[[
	高V主界面
]]
local CC = require("CC")
local AgentNewView = CC.uu.ClassView("AgentNewView")

function AgentNewView:ctor(param)
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView");
	self.param = param;
	self.newAgent = false
	self.isLimit = false
    self:RegisterEvent()
    self.subViewCfg = {
		new = {
			{viewName = "AgentInvitationView", btnName = "btn_NewInvitation", Note = "新手玩家赚钱"},
		},
		old = {
			{viewName = "AgentInvitationView", btnName = "btn_Invitation", Note = "百亿补贴"},
			{viewName = "AgentRevenueView", btnName = "btn_Revenue", Note = "我的收益"},
			{viewName = "AgentMyGrades", btnName = "btn_Grades", Note = "我的等级"},
			{viewName = "AgentRank", btnName = "btn_Rank", Note = "周排行"},
			-- {viewName = "AgentShareView", btnName = "btn_Share", Note = "我的推广码"},
		}
	}
    self.currentView = nil

	self.btnListInited = false
end

function AgentNewView:OnCreate()
	self.musicName = nil
	self.btnList = {}
	CC.Request("ReqNewAgentData")
	self:InitContent()
	CC.HallUtil.OnShowHallCamera(false);
end

function AgentNewView:InitContent()
	local headNode = self:FindChild("Top/HeadNode");
	self.HeadIcon = CC.HeadManager.CreateHeadIcon({parent = headNode, clickFunc = true});

	local diamondNode = self:FindChild("Top/NodeMgr/DiamondNode");
	self.diamondCounter = CC.HeadManager.CreateDiamondCounter({parent = diamondNode, hideBtnAdd = true});

	local chipNode = self:FindChild("Top/NodeMgr/ChipNode");
	self.chipCounter = CC.HeadManager.CreateChipCounter({parent = chipNode, hideBtnAdd = true});

	local VipNode = self:FindChild("Top/NodeMgr/VipNode");
	self.VIPCounter = CC.HeadManager.CreateVIPCounter({parent = VipNode, tipsParent = self:FindChild("Top/VIPTipsNode")});

	local integralNode = self:FindChild("Top/NodeMgr/IntegralBG")
	local param = {}
	param.parent = integralNode
	param.clickFunc = function()
		CC.ViewManager.Open("GetTicketView",{callback = function() self:Destroy() end})
	end
	self.integralCounter = CC.HeadManager.CreateIntegralCounter(param)
	self:AddClick("Top/MailBtn",function ()
		self.gameDataMgr.SetSwitchClick("MailView")
		CC.ViewManager.Open("MailView")
	end)
    self:AddClick("Top/serverBtn", slot(self.OnServiceBtnClick, self))
	self:AddClick("AgentIcon", "OnBindAgentClick")
	self:AddClick(self:FindChild("Top/Back/BtnBack"), slot(self.Destroy, self))

	self:DelayRun(0.1, function()
		self.musicName = CC.Sound.GetMusicName();
		CC.Sound.PlayHallBackMusic("AgentBg");
	end)
end

function AgentNewView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnChangeViewByKey,CC.Notifications.OnChangeAgentView)
	CC.HallNotificationCenter.inst():register(self,self.ReqAgentDataResq,CC.Notifications.NW_ReqAgentData)
	CC.HallNotificationCenter.inst():register(self,self.ReqNewAgentDataResq,CC.Notifications.NW_ReqNewAgentData)
end

function AgentNewView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnChangeAgentView)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqAgentData)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqNewAgentData)
end

function AgentNewView:CreateBtnItem(cfg)
	local t = {};
	t.btn = CC.uu.newObject(self.btnPrefab, self.btnRoot)
	t.btn.name = cfg.btnName
	t.btn:SetActive(true)
	t.viewName = cfg.viewName;
	t.viewParam = {newAgent = self.newAgent,isLimit = self.isLimit}
	t.toggle = t.btn:GetComponent("Toggle")
	UIEvent.AddToggleValueChange(t.btn, function(selected)
			if selected then
				--选中按钮后销毁上一个显示的界面并创建当前按钮指向的界面
				if self.currentView then
                    --选中和当前界面一样
					if self.currentView.viewName == t.viewName then return end
					self.currentView:ActionOut();
				end
				self.currentView = CC.uu.CreateHallView(cfg.viewName, t.viewParam)
				self.currentView.transform:SetParent(self:FindChild("Content"), false);
				self.currentView:ActionIn()
			end
		end)

	t.btn:FindChild("Text").text = self.language[cfg.btnName];
	t.btn:FindChild("Selected/Text").text = self.language[cfg.btnName];

	return t
end

function AgentNewView:OnServiceBtnClick()
	CC.ViewManager.OpenServiceView();
end

function AgentNewView:OnBindAgentClick()
	CC.ViewManager.Open("AgentProxy")
end

function AgentNewView:OnChangeViewByKey(key)
	if key == "AgentShareView" then
		CC.ViewManager.Open("AgentShareView", {value = 50})
	end
	--合集内切换页签
	for _,v in ipairs(self.btnList) do
		if key == v.viewName then
			v.toggle.isOn = true;
		end
	end
end

function AgentNewView:ReqAgentDataResq(err, param)
	log("err = ".. err.."  "..CC.uu.Dump(param, "ReqAgentDataResq",10))
	if err == 0 then
		self.agentDataMgr.SetAgentSatus(param)
		self:SetCountDown()
		if not self.btnListInited then
			self:InitBtnList();
		end
	end
end

function AgentNewView:ReqNewAgentDataResq(err, param)

	if err == 0 then
		CC.uu.Log(param, "ReqNewAgentDataResq-----------", 3)
		self.newAgent = true;
		self.isLimit = param.InviteActivityStatus
		if param.AgentPlayerType == CC.client_agent_pb.AgentPlayerTypeOld then
			self.newAgent = false;
		end
		-- self:InitContent();
		CC.Request("ReqAgentData")
	end
end

function AgentNewView:InitBtnList()
	self.btnListInited = true
	self.btnRoot = self:FindChild("Scroll/Viewport/BtnList")
	self.btnPrefab = self:FindChild("Scroll/Viewport/BtnList/Btn")
	self.btnPrefab:SetActive(false)
	local subView = self.newAgent and self.subViewCfg.new or self.subViewCfg.old
    for _, cfg in ipairs(subView) do
		local btnItem = self:CreateBtnItem(cfg)
		table.insert(self.btnList, btnItem)
	end
	self.btnList[1].toggle.isOn = true
end

function AgentNewView:SetCountDown()
	local isAgent = self.agentDataMgr.GetAgentSatus()
	local timer = self.agentDataMgr.GetRemainTime()
	if not isAgent and timer and timer > 0 then
		self:FindChild("AgentIcon"):SetActive(true)
		self:StartTimer("AgentCountDown", 1, function()
			if timer < 0 then
				self:StopTimer("AgentCountDown")
				self:FindChild("AgentIcon"):SetActive(false)
				return
			end
			self:FindChild("AgentIcon/Text").text = CC.uu.TicketFormat3(timer)
			timer = timer - 1
		end, -1)
	else
		self:FindChild("AgentIcon"):SetActive(false)
		self:StopTimer("AgentCountDown")
	end
end

function AgentNewView:OnDestroy()

	CC.HallUtil.OnShowHallCamera(true);
	
	self.isDestroy = true
	self:StopTimer("AgentCountDown")
	self:CancelAllDelayRun()
	self:UnRegisterEvent()

	if self.currentView then
		self.currentView:Destroy();
	end
	if self.HeadIcon then
		self.HeadIcon:Destroy();
		self.HeadIcon = nil;
	end

	if self.chipCounter then
		self.chipCounter:Destroy();
		self.chipCounter = nil;
	end

	if self.diamondCounter then
		self.diamondCounter:Destroy();
		self.diamondCounter = nil;
	end

	if self.VIPCounter then
		self.VIPCounter:Destroy();
		self.VIPCounter = nil;
	end

	if self.integralCounter then
		self.integralCounter:Destroy()
		self.integralCounter = nil
	end

	if self.musicName then
		CC.Sound.PlayHallBackMusic(self.musicName);
	else
		CC.Sound.StopBackMusic();
	end
end

function AgentNewView:ActionIn() end

function AgentNewView:ActionOut() end

return AgentNewView