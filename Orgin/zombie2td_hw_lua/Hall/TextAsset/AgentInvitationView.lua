local CC = require("CC")
local AgentInvitationView = CC.uu.ClassView("AgentInvitationView")

local btnType = {
	{2,4,6},
	{1,2,3,4,5,6,7}
}

function AgentInvitationView:ctor(param)
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView");
	self.param = param or {}
    self.IconTab = {}
    self.invitationList = {}
	self.BroadCastList = {}
	self.countDownTime = 0
	self.param.newAgent = self.param.isLimit and true or self.param.newAgent
	self.cardValue = self.param.newAgent and 20 or 50
	self.invateBtnList = self.param.newAgent and btnType[1] or btnType[2]
    self:RegisterEvent()
	--测试代码
	-- self.param.isLimit = true
	-- self.param.newAgent = true

end

function AgentInvitationView:OnCreate()
	self:InitContent()
end

function AgentInvitationView:InitContent()

	for _,v in ipairs(self.invateBtnList) do
        local index = v
		local tb = {}
		tb.child = self:FindChild(string.format("%s", index))
		self:AddClick(tb.child:FindChild("Add"), "OnBtnClick")
		tb.child:SetActive(true)

        -- self.invitationList[index] = self:FindChild(string.format("%s", index))
        -- self:AddClick(self.invitationList[index]:FindChild("Add"), "OnBtnClick")
		-- self.invitationList[index]:SetActive(true)
		if self.param.isLimit then
			tb.child:SetActive(false)
			if v~=4 then
				tb.child:SetActive(true)
				tb.child:FindChild("Image"):SetActive(true)
				tb.child:FindChild("Text").y = -60
				table.insert(self.invitationList, tb)
			end
			tb.child.y = 60
		else
			table.insert(self.invitationList, tb)
		end

	end
    -- for i = 1, 7 do
    --     local index = i
    --     self.invitationList[index] = self:FindChild(string.format("%s", index))
    --     self:AddClick(self.invitationList[index]:FindChild("Add"), "OnBtnClick")
    -- end
	self:FindChild("Card_20"):SetActive(self.param.newAgent)
	self:FindChild("Card_50"):SetActive(not self.param.newAgent)
    self:AddClick("BtnGet/Btn", "OnBtnClick")
	self:AddClick("BtnGuide", "OnBtnGuideClick")
	self:AddClick("Guide/Btn", "OnGuideBtnClick")
	self:AddClick("TopFitter/btnHelp", "OnRuleBtnClick")
    self:InitTextByLanguage()
	CC.Request("ReqHomePageData")
	CC.Request("ReqAgentBroadcast")

	if self.param.isLimit then
		self:FindChild("TimeLimit"):SetActive(true)
		self:FindChild("TopFitter/TopText"):SetActive(false)
		self:FindChild("TopFitter/Image"):SetActive(true)
		self:FindChild("Card_20").y = 53
		self:FindChild("TopFitter/Image/LText").width = 170
	else
		self:FindChild("TopFitter/Image"):SetActive(false)
		self:FindChild("TopFitter/TopText"):SetActive(true)
	end
end

function AgentInvitationView:InitTextByLanguage()
	for _,v in pairs(self.invitationList) do
		v.child:FindChild("Text").text = self.language.invitationPlay
	end
    -- for i = 1, 7 do
    --     local index = i
    --     self.invitationList[index]:FindChild("Text").text = s elf.language.invitationPlay
    -- end
    self:FindChild("BtnGet/Btn/Text").text = self.language.freeGet
	-- self:FindChild("AwardText").text = self.language.invitationAward
	self:FindChild("BtnGuide/Text").text = self.language.invitationBtnGuide
	self:FindChild("Guide/Text1").text = self.language.invitationGuideText1
	self:FindChild("Guide/Text2").text = self.language.invitationGuideText2
	self:FindChild("Guide/Btn/Text").text = self.language.invitationGuideBtn
	self:FindChild("TopFitter/TopText/Value").text = self.cardValue.."THB"
	self:FindChild("TopFitter/TopText/Text").text = string.format(self.language.InvitationText, self.param.newAgent and 3 or 7)
	self:FindChild("TimeLimit/TopText").text = self.language.limit_topText
	self:FindChild("TopFitter/Image/LText").text = self.language.limit_LTitle
	self:FindChild("TopFitter/Image/LText/RText").text = self.language.limit_RTitle

end

function AgentInvitationView:RegisterEvent()
	-- CC.HallNotificationCenter.inst():register(self,self.OnReceiveEarnSucc,CC.Notifications.NW_ReceiveEarn)
	CC.HallNotificationCenter.inst():register(self,self.ReqHomePageDataResq,CC.Notifications.NW_ReqHomePageData)
	CC.HallNotificationCenter.inst():register(self,self.ReqAgentBroadcastResq,CC.Notifications.NW_ReqAgentBroadcast)
	CC.HallNotificationCenter.inst():register(self,self.ReqReceiveNewAgentPrizeResq,CC.Notifications.NW_ReqReceiveNewAgentPrize)
	
end

function AgentInvitationView:UnRegisterEvent()
	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReceiveEarn)
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function AgentInvitationView:OnRuleBtnClick()
	CC.ViewManager.Open("AgentRuleView")
end

function AgentInvitationView:OnBtnClick()
    -- CC.HallNotificationCenter.inst():post(CC.Notifications.OnChangeAgentView, "AgentShareView")
	CC.ViewManager.Open("AgentShareView", {value = self.cardValue})
end

function AgentInvitationView:OnGuideBtnClick()
	if self.agentDataMgr.GetAgentLockStatus() then
        CC.ViewManager.ShowTip(self.language.auditTip)
		return
    end
	CC.Request("ReqHomeStatus", {StatusType = 0})
    CC.HallNotificationCenter.inst():post(CC.Notifications.OnChangeAgentView, "AgentRevenueView")
end

function AgentInvitationView:OnBtnGuideClick()
	local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level") or 0
	if vipLevel < 1 and self.param.isLimit then
		CC.ViewManager.ShowMessageBox(self.language.guide_Text,function ()
			CC.ViewManager.Open("StoreView")
		end,function ()
			
		end)
	end
	if self.agentDataMgr.GetAgentLockStatus() then
		CC.ViewManager.ShowTip(self.language.auditTip)
		return
	end
	local data = {}
	data.ReceiveType = self.param.isLimit and 2 or 1
	if self.param.newAgent or self.param.isLimit then
		CC.Request("ReqReceiveNewAgentPrize",data)
		return
	end
    self:FindChild("Guide"):SetActive(true)
end

function AgentInvitationView:ReqHomePageDataResq(err, param)
	log("err = ".. err.."  "..CC.uu.Dump(param, "ReqHomePageDataResq",10))
	-- local param = {
	-- 	AgentNum = 3,
	-- 	homeStatus = 1,
	-- 	List = {
	-- 		{
	-- 			playerID = 1,
	-- 			Portrait = 2,
	-- 			nickname = 3
	-- 		}
	-- 	}
	-- }
	if err == 0 then
		self.countDownTime = param.ActivityCountdown
		self:StartTimer("AgentLimitTimer",1,function ()
			self.countDownTime = self.countDownTime - 1
			if self.countDownTime < 0 then
				self:StopTimer("AgentLimitTimer")
			else
				self:SetCountDown(self.countDownTime)
			end
		end,-1)

		for k, v in ipairs(param.List) do
			self:SetInvitationInfo(v, k)
		end
		if self.param.isLimit then
			self:FindChild("AwardText").text = string.format(self.language.tips_Text, param.ActivityNum)
			if param.AgentNum >= 2 then
				self:FindChild("Tip"):SetActive(false)
				self:FindChild("BtnGuide"):SetActive(true)
				self:FindChild("BtnGet"):SetActive(false)
			end
			return
		end
		self:FindChild("AwardText").text = self.language.invitationAward
		if self.param.newAgent then
			if param.AgentNum >= 3 then
				self:FindChild("Tip"):SetActive(false)
				self:FindChild("BtnGuide"):SetActive(true)
				self:FindChild("BtnGet"):SetActive(false)
			end
			return
		end
		if param.AgentNum >= 7 then
			self:FindChild("Tip"):SetActive(true)
			self:FindChild("Tip/Text").text = string.format(self.language.invitationTip, param.AgentNum)
			if param.homeStatus and param.homeStatus == 0 then
				self:FindChild("BtnGuide"):SetActive(true)
				self:FindChild("BtnGet"):SetActive(false)
			end
		end

	end
end

function AgentInvitationView:SetCountDown(time)
	if time <= 0 then
		self:FindChild("TimeLimit/TopText").text = self.language.limit_topText.."00:00:00"
	else
		if time > 7*86400 then
			self:FindChild("TimeLimit/TopText").text = self.language.limit_topText..CC.uu.TicketFormatDay(time).."วัน"
		elseif time < 86400 then
			self:FindChild("TimeLimit/TopText").text = self.language.limit_topText..CC.uu.TicketFormat(time)

		else
			self:FindChild("TimeLimit/TopText").text = self.language.limit_topText..CC.uu.TicketFormat2(time)
		end
	end
end

function AgentInvitationView:SetInvitationInfo(data, index)

	local child = self.invitationList[index].child
    local headNode = child.transform:FindChild("head")
	child:FindChild("Add"):SetActive(false)
	child:FindChild("Text").text = data.nickname
	headNode:SetActive(true)
	self:DeleteHeadIconByKey(headNode)
	local param = {}
	param.parent = headNode
	param.portrait = data.Portrait
	param.playerId = data.playerID
	param.clickFunc = "unClick"
	self:SetHeadIcon(param, index)
end

--删除头像对象
function AgentInvitationView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.IconTab[tonumber(headtran.transform.name)] ~= nil then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end
end

--设置头像
function  AgentInvitationView:SetHeadIcon(param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

function  AgentInvitationView:ReqAgentBroadcastResq(err, param)
	log("err = ".. err.."  "..CC.uu.Dump(param, "ReqAgentBroadcastResq",10))
	if err == 0 then
		self:FindChild("BroadCast"):SetActive(true)
		self.BroadCastList = param.broadcast
		self:UpdataMarquee()
	end
end

function AgentInvitationView:ReqReceiveNewAgentPrizeResq(err)
	if err == 0 then
		-- CC.uu.Log("领取奖励成功， 弹出奖励分享窗")
		local data = {}
		data.items = {{ConfigId = CC.shared_enums_pb.EPC_True_Money_Card, Count = 1}}
		data.callback = function ()
			CC.ViewManager.OpenAndReplace("TreasureView")
		end
		CC.ViewManager.OpenRewardsView(data)
	elseif err == 607 then
		CC.ViewManager.ShowMessageBox(self.language.guide_Text,function ()
			CC.ViewManager.Open("StoreView")
		end,function ()
			
		end)
	else

	end
end

function AgentInvitationView:UpdataMarquee()
	if #self.BroadCastList <= 0 then return end
	if not self.Marquee then
		local ReportEnd = function()
			self:UpdataMarquee()
		end
		self.Marquee = CC.uu.CreateHallView("Marquee",{parent = self:FindChild("BroadCast"), ReportEnd = ReportEnd})
	end
	for _, v in ipairs(self.BroadCastList) do
		local str = ""
		if v.chouMaEarn < 500000 and v.giftEarn < 6000 then
			if v.chouMaEarn > 0 and v.giftEarn > 0 then
				str = string.format(self.language.Marquee_1, v.nickname,v.giftEarn, v.chouMaEarn)
			elseif v.chouMaEarn > 0 then
				str = string.format(self.language.Marquee_2, v.nickname,v.chouMaEarn)
			elseif v.giftEarn > 0 then
				str = string.format(self.language.Marquee_3, v.nickname,v.giftEarn)
			end
		else
			if v.chouMaEarn > 0 and v.giftEarn > 0 then
				str = string.format(self.language.Marquee_4, v.nickname,v.giftEarn, v.chouMaEarn)
			elseif v.chouMaEarn > 0 then
				str = string.format(self.language.Marquee_5, v.nickname,v.chouMaEarn)
			elseif v.giftEarn > 0 then
				str = string.format(self.language.Marquee_6, v.nickname,v.giftEarn)
			end
		end
		self.Marquee:Report(str)
	end
end

function AgentInvitationView:OnDestroy()
	self:CancelAllDelayRun()
    for _,v in pairs(self.IconTab) do
		if v then
			v:Destroy()
			v = nil
		end
    end
	if self.Marquee then
        self.Marquee:Destroy()
        self.Marquee = nil
    end
	self:UnRegisterEvent()
end

function AgentInvitationView:ActionIn()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
		{"fadeToAll", 0, 0},
		{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
	});
end

function AgentInvitationView:ActionOut()
    self:SetCanClick(false);
	CC.HallUtil.HideByTagName("Effect", false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

return AgentInvitationView