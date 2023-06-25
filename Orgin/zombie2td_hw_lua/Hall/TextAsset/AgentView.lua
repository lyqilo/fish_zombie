--[[
	高V主界面
]]

local CC = require("CC")

local BaseClass = CC.uu.ClassView("AgentView")

function BaseClass:ctor(param)
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView");
	self.param = param;
end

function BaseClass:OnCreate()
	self:LoadUnReceiveEarn()
	self:LoadSubAgentList()
	self:RegisterEvent()

	self.musicName = nil
	self.guide = false
	self.btnTab = {}
	self:InitContent()
	self:InitTextByLanguage();
end

function BaseClass:InitContent()
	self.mask = self:FindChild("mask")

	local headNode = self:FindChild("content/Top/HeadNode");
	self.HeadIcon = CC.HeadManager.CreateHeadIcon({parent = headNode, clickFunc = true});

	local diamondNode = self:FindChild("content/Top/NodeMgr/DiamondNode");
	self.diamondCounter = CC.HeadManager.CreateDiamondCounter({parent = diamondNode, hideBtnAdd = true});

	local chipNode = self:FindChild("content/Top/NodeMgr/ChipNode");
	self.chipCounter = CC.HeadManager.CreateChipCounter({parent = chipNode, hideBtnAdd = true});

	local VipNode = self:FindChild("content/Top/NodeMgr/VipNode");
	self.VIPCounter = CC.HeadManager.CreateVIPCounter({parent = VipNode, tipsParent = self:FindChild("content/Top/VIPTipsNode")});

	local integralNode = self:FindChild("content/Top/NodeMgr/IntegralBG")
	self.integralCounter = CC.HeadManager.CreateIntegralCounter({parent = integralNode,hideBtnAdd = true})
	self:AddClick("content/Top/MailBtn",function ()
		self.gameDataMgr.SetSwitchClick("MailView")
		CC.ViewManager.Open("MailView")
	end)
	-- local roomcardNode = self:FindChild("content/Top/NodeMgr/RoomcardNode");
	-- self.roomcardCounter = CC.HeadManager.CreateRoomcardCounter({parent = roomcardNode, hideBtnAdd = true});
	-- roomcardNode:SetActive(CC.Player.Inst():IsShowRoomCard())

	self:AddClick(self:FindChild("content/Top/Back/BtnBack"),slot(self.Destroy,self))
	self.middle = self:FindChild("content/Middle")
	for i = 1, 9 do
		--1-3收益领取，4-6收益记录，历史记录，伙伴列表，7-9，规则，客服，分享
		self.btnTab[i] = self.middle:FindChild(string.format("btn%d", i))
	end
	self:AddClick(self.btnTab[1], slot(self.OnBtn1Click,self))
	self:AddClick(self.btnTab[2], slot(self.OnBtn2Click,self))
	self:AddClick(self.btnTab[3], slot(self.OnBtn3Click,self))
	self:AddClick(self.btnTab[4], slot(self.OnEarningsBtnClick,self))
	self:AddClick(self.btnTab[5], slot(self.OnGeneralizeBtnClick,self))
	self:AddClick(self.btnTab[6], slot(self.OnJuniorBtnClick,self))
	self:AddClick(self.btnTab[7],slot(self.OnRuleBtnClick,self))
	self:AddClick(self.btnTab[8], slot(self.OnServiceBtnClick,self))
	self:AddClick(self.btnTab[9], slot(self.OnShareBtnClick,self))

	self.effBtn1 = self.btnTab[1]:FindChild("Effect")
	self.effBtn2 = self.btnTab[2]:FindChild("Effect")
	self.effBtn3 = self.btnTab[3]:FindChild("Effect")

	self.effBtn1:SetActive(false)
	self.effBtn2:SetActive(false)
	self.effBtn3:SetActive(false)

	self.Skeleton = {}
	for i = 1, 9 do
		--1-3默认状态收益icon，4-6动效状态，7-9按钮动效
		self.Skeleton[i] = self:FindChild(string.format("content/Skeleton/Skeleton%d", i))
	end
	-- test
	self:AddClick(self.middle:FindChild("Button"),slot(self.TestBtn,self))

	self:CheckGuide()
	self:DelayRun(0.1, function()
		self.musicName = CC.Sound.GetMusicName();
		CC.Sound.PlayHallBackMusic("AgentBg");
	end)

	CC.Request("PromoteTask")
	CC.Request("GrandTotalEarn", {agentid = CC.Player.Inst():GetSelfInfoByKey("Id")})
end

function BaseClass:InitTextByLanguage()
	self.middle:FindChild("btn1/Tip/Text").text = self.language.agentbtntips1
	self.middle:FindChild("btn2/Tip/Text").text = self.language.agentbtntips2
	self.middle:FindChild("btn3/Tip/Text").text = self.language.agentbtntips3
	self.middle:FindChild("btn9/tips/Text").text = self.language.agentbtntips9
	self.middle:FindChild("InputField/Placeholder").text = self.language.Placeholder
	self.btnTab[3]:FindChild("Tip/Text").text = self.language.receiveTip
end

function BaseClass:CheckGuide()
	if CC.DebugDefine.GetGuideDebugState() then
		return
	end
	if not self.gameDataMgr.GetSingleFlag(26) then
		self.guide = true
		self:SetBtnEnable(2, false)
		self:DelayRun(1, function ( )
			CC.ViewManager.Open("GuideView", {singleFlag = 26, btnTab = self.btnTab, ReceiveEarn = function()
				self:OnBtn2Click()
			end})
			self:SetBtnEnable(2, true)
		end)
		for i = 1, 9 do
			self.btnTab[i]:SetActive(false)
			self.Skeleton[i]:SetActive(false)
		end
		self:OnGuideStepAgent({agentStep = 2})
	elseif not self.gameDataMgr.GetSingleFlag(25) then
		self.guide = true
		self:DelayRun(1, function ( )
			CC.ViewManager.Open("GuideView", {singleFlag = 25, btnTab = self.btnTab})
		end)
		for i = 1, 9 do
			self.btnTab[i]:SetActive(false)
			self.Skeleton[i]:SetActive(false)
		end
		self:OnGuideStepAgent({agentStep = 1})
	else
		self.guide = false
	end
	self:SetCanClick(not self.guide)
	self.HeadIcon:SetIconClick(self.guide)
end

function BaseClass:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnReflashAgentReceiveBtns,CC.Notifications.OnReflashAgentReceiveBtns)
	CC.HallNotificationCenter.inst():register(self,self.OnGuideStepAgent,CC.Notifications.OnGuideStepAgent)
	CC.HallNotificationCenter.inst():register(self,self.LoadSubAgentListResp,CC.Notifications.NW_LoadSubAgentList)
	CC.HallNotificationCenter.inst():register(self,self.OnReceiveEarnSucc,CC.Notifications.NW_ReceiveEarn)
	CC.HallNotificationCenter.inst():register(self,self.PromoteTaskResp, CC.Notifications.NW_PromoteTask)
	CC.HallNotificationCenter.inst():register(self,self.GrandTotalEarnResp, CC.Notifications.NW_GrandTotalEarn)
end

function BaseClass:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnReflashAgentReceiveBtns)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnGuideStepAgent)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_LoadSubAgentList)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReceiveEarn)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_PromoteTask)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_GrandTotalEarn)
end

function BaseClass:OnReflashAgentReceiveBtns(data)
	self:RefreshBtns(data)
end

function BaseClass:OnGuideStepAgent(data)
	if data.agentStep == 1 then
		self.Skeleton[2]:SetActive(true)
		self.Skeleton[4]:SetActive(true)
		self.Skeleton[5]:SetActive(false)
	elseif data.agentStep == 2 then
		self.Skeleton[5]:SetActive(true)
		self.btnTab[2]:SetActive(true)
	elseif data.agentStep == 3 then
		self.Skeleton[1]:SetActive(true)
		self.Skeleton[4]:SetActive(false)
		self.Skeleton[6]:SetActive(true)
	elseif data.agentStep == 4 then
		self.Skeleton[3]:SetActive(true)
		self.Skeleton[6]:SetActive(false)
		self.Skeleton[7]:SetActive(true)
		for i = 4, 9 do
			self.btnTab[i]:SetActive(false)
		end
	elseif data.agentStep == 6 then
		self.Skeleton[7]:SetActive(false)
		self.btnTab[4]:SetActive(true)
		for i = 1, 3 do
			self.btnTab[i]:SetActive(true)
		end
		for i = 7, 9 do
			self.btnTab[i]:SetActive(true)
		end
		self.guide = false
		self:SetCanClick(true)
		self.HeadIcon:SetIconClick(false)
	elseif data.agentStep == 8 then
		self:SetGeneralizeAndJuniorBtn(true, false)
		self.Skeleton[8]:SetActive(false)
		self.Skeleton[9]:SetActive(true)
	elseif data.agentStep == 9 then
		self:SetGeneralizeAndJuniorBtn(true, true)
		self.Skeleton[9]:SetActive(false)
	end
end

function BaseClass:SetBtnEnable(index, status)
	self.btnTab[index]:GetComponent("Button"):SetBtnEnable(status)
end

function BaseClass:RefreshBtns(data)
	if self.isDestroy then
		return
	end
	data = data or self.agentDataMgr.GetUnReceiveEarn()
	--待领取的交易收益
	local earnFromTrade = data.earnFromTrade
	--待领取的分成收益
	local earnFromShare = data.earnFromShare
	--待领取的人头收益
	local earnFromNewer = data.earnFromNewer
	self.effBtn1:SetActive(earnFromTrade > 0)
	self.btnTab[1]:FindChild("Receive"):SetActive(earnFromTrade > 0)
	self.btnTab[1]:FindChild("Receive/Text").text = CC.uu.ChipFormat(earnFromTrade)
	self.effBtn2:SetActive(earnFromShare > 0)
	self.btnTab[2]:FindChild("Receive"):SetActive(earnFromShare > 0)
	self.btnTab[2]:FindChild("Receive/Text").text = CC.uu.ChipFormat(earnFromShare)
	self.effBtn3:SetActive(earnFromNewer > 0)
	-- self.btnTab[3]:FindChild("Receive"):SetActive(earnFromNewer > 0)
	-- self.btnTab[3]:FindChild("Receive/Text").text = CC.uu.ChipFormat(earnFromNewer)

end

function BaseClass:LoadUnReceiveEarn()
	self.agentDataMgr.LoadUnReceiveEarn(function (data)
		if data then
			self:RefreshBtns(data)
		end
	end)
end

function BaseClass:LoadSubAgentList()
	local param = {sortType = CC.proto.client_agent_pb.SortByLastActivityTime, cursor = 0, smallToBig = false}
	CC.Request("LoadSubAgentList",param)
end

function BaseClass:LoadSubAgentListResp(err,data)
	log(CC.uu.Dump(data, "LoadSubAgentListResp", 10))
	if err == 0 then
		if data.subAgentNum <= 0 or self.guide then
			self:SetGeneralizeAndJuniorBtn(false, false)
		else
			if not CC.DebugDefine.GetGuideDebugState() and not self.gameDataMgr.GetSingleFlag(24) then
				self:DelayRun(1, function ( )
					CC.ViewManager.Open("GuideView", {singleFlag = 24, btnTab = self.btnTab})
				end)
				self.Skeleton[8]:SetActive(true)
				self:SetGeneralizeAndJuniorBtn(false, false)
			else
				self:SetGeneralizeAndJuniorBtn(true, true)
			end
		end
	end
end

function BaseClass:SetGeneralizeAndJuniorBtn(gStatus, jStatus)
	self.btnTab[5]:SetActive(gStatus)
	self.btnTab[6]:SetActive(jStatus)
end

function BaseClass:OnEarningsBtnClick()
	CC.ViewManager.Open("AgentEarningsView")
end

function BaseClass:OnGeneralizeBtnClick()
	CC.ViewManager.Open("AgentGeneralizeView")
end

function BaseClass:OnJuniorBtnClick()
	CC.ViewManager.Open("AgentJuniorView")
end

function BaseClass:OnServiceBtnClick()
	CC.ViewManager.OpenServiceView();
end

function BaseClass:OnRuleBtnClick()
	CC.ViewManager.Open("AgentRuleView")
end

function BaseClass:OnShareBtnClick()
	self.middle:FindChild("btn9/tips"):SetActive(false)
	CC.ViewManager.Open("AgentShareView")
end

function BaseClass:TestBtn()
	local agentid = tonumber(self.middle:FindChild("InputField").text)
	self.agentDataMgr.BindAgent(agentid,function (code,data)
		logError(code)
		logError(CC.uu.Dump(data))
	end)
end

function BaseClass:OnBtn1Click()
	local data = self.agentDataMgr.GetUnReceiveEarn()
	if data and data.earnFromTrade and data.earnFromTrade > 0 then
		CC.Request("ReceiveEarn", {earnType = CC.proto.client_agent_pb.EarnFromTrade})
	else
		self.btnTab[1]:FindChild("Tip"):SetActive(true)
		self:DelayRun(1, function ( )
			self.btnTab[1]:FindChild("Tip"):SetActive(false)
		end)
	end
end

function BaseClass:OnBtn2Click()
	local data = self.agentDataMgr.GetUnReceiveEarn()
	if data and data.earnFromShare and data.earnFromShare > 0 then
		CC.Request("ReceiveEarn", {earnType = CC.proto.client_agent_pb.EarnFromShare})
	elseif self.guide then
		--有引导，没有收益时
		self:CheckGuide()
	else
		self.btnTab[2]:FindChild("Tip"):SetActive(true)
		self:DelayRun(1, function ( )
			self.btnTab[2]:FindChild("Tip"):SetActive(false)
		end)
	end
end

function BaseClass:OnBtn3Click()
	-- local data = self.agentDataMgr.GetUnReceiveEarn()
	-- if data and data.earnFromNewer and data.earnFromNewer > 0 then
	-- 	CC.Request("ReceiveEarn", {earnType = CC.proto.client_agent_pb.EarnFromNewer})
	-- else
	-- 	self.btnTab[3]:FindChild("Tip"):SetActive(true)
	-- 	self:DelayRun(1, function ( )
	-- 		self.btnTab[3]:FindChild("Tip"):SetActive(false)
	-- 	end)
	-- end
	CC.ViewManager.Open("AgentTaskView")
end

function BaseClass:OnReceiveEarnSucc(code,param)
	self.agentDataMgr.SetUnReceiveEarn(code, param)
	if code == 0 then
		--local earnType = data.earnType
		local earn = param.earn
		local data = {{ConfigId = CC.shared_enums_pb.EPC_ChouMa, Count = earn}}
		local Cb = nil
		if self.guide then
			Cb = function()
				self:CheckGuide()
			end
		elseif earn >= 100000 then
			--收益大于10万，打开分享页
			Cb = function()
				self:OnShareBtnClick()
			end
		end
		CC.ViewManager.OpenRewardsView({items = data, callback = Cb})
		-- self:RefreshBtns()
		self:LoadUnReceiveEarn()
	else
		if self.guide then
			self:CheckGuide()
		end
	end
end

function BaseClass:PromoteTaskResp(err, data)
	local list = data.promoteTask
	if not list then return end

	local earnFromNewer = 0
	for _,v in ipairs(list) do
		earnFromNewer = earnFromNewer + v.earn
	end
	self.btnTab[3]:FindChild("Receive"):SetActive(earnFromNewer > 0)
	self.btnTab[3]:FindChild("Receive/Text").text = CC.uu.ChipFormat(earnFromNewer)
	self.btnTab[3]:FindChild("Tip"):SetActive(earnFromNewer > 0)
end

function BaseClass:GrandTotalEarnResp(err, data)
	log(CC.uu.Dump(data, "GrandTotalEarnResp", 10))
	if err == 0 then
		self.agentDataMgr.SetShareTotalEarn(data)
	end
end

function BaseClass:OnDestroy()
	self.isDestroy = true
	self:CancelAllDelayRun()
	self:UnRegisterEvent()

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

	if self.roomcardCounter then
		self.roomcardCounter:Destroy()
		self.roomcardCounter = nil
	end
	if self.musicName then
		CC.Sound.PlayHallBackMusic(self.musicName);
	else
		CC.Sound.StopBackMusic();
	end
end

function BaseClass:ActionIn() end

function BaseClass:ActionOut() end

return BaseClass