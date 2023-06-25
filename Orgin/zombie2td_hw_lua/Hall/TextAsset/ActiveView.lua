
local CC = require("CC")
local ActiveView = CC.uu.ClassView("ActiveView")

local FIRSTSTATE = {CannotGet = 0,CanGet = 1,AlreadyGet = 2}     --------------首充礼包状态 0-不可领取，1-可以领取，2-已经领取

--vip特权页面
function ActiveView:ctor(notice)
		self.ActiveTab = {
		[1] = {btnName = "btn_Facebook",actName = "Act_Facebook",IsShow = false,redShow = false},
		[2] = {btnName = "btn_CDKey",actName = "Act_CDKey",IsShow = true,redShow = false},
		-- [3] = {btnName = "btn_proxy",actName = "Act_proxy",IsShow = true,redShow = false},
		--[4] = {btnName = "btn_EveryGift",actName = "Act_EveryGift",IsShow = true,redShow = true},
		-- [3] = {btnName = "btn_Service",actName = "Act_Service",IsShow = true,redShow = false},
		[3] = {btnName = "btn_Line",actName = "Act_Line",IsShow = false,redShow = false},
		[4] = {btnName = "btn_SendTutorial",actName = "Act_SendTutorial",IsShow = true,redShow = false},
		[5] = {btnName = "btn_RelieveLine",actName = "Act_RelieveLine",IsShow = true,redShow = false},
		[6] = {btnName = "btn_Rank",actName = "Act_Rank",IsShow = false,redShow = false},
		[7] = {btnName = "btn_GoToFacebook",actName = "Act_GoToFacebook",IsShow = true,redShow = false},
		[8] = {btnName = "btn_NewFraudNotice",actName = "Act_NewFraudNotice",IsShow = true,redShow = false},
		[9] = {btnName = "btn_NewCDKey",actName = "Act_NewCDKey",IsShow = true,redShow = false},
		[10] = {btnName = "btn_FBChatGroup",actName = "Act_FBChatGroup",IsShow = true,redShow = false},
	}

	self.NoticeTab = {
		[100] = {btnName = "btn_Notice",actName = "Act_Notice",IsShow = false,redShow = false},
		[101] = {btnName = "btn_Clause",actName = "Act_Clause",IsShow = true,redShow = false},
		[102] = {btnName = "btn_SetUpPolicy",actName = "Act_SetUpPolicy",IsShow = true,redShow = false},
		[103] = {btnName = "btn_FraudNotice",actName = "Act_FraudNotice",IsShow = true,redShow = false},
		[104] = {btnName = "btn_UserAgreement",actName = "Act_UserAgreement",IsShow = true,redShow = false},
	}
	self.ActivesortTab = {6,1,3,7,10,3,8,4,9,2}
	self.NoticesortTab = {100,103,102,101,104}

	self.ActiveCurrentIndex = self.ActivesortTab[1]
	self.NoticeCurrentIndex = self.NoticesortTab[2]
	self.IsOneActive = false
	self.notice = notice
	self.CurrentView = nil
end

function ActiveView:OnCreate()

	self:RegisterEvent()
	self.language = self:GetLanguage()
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");
	self.ActiveGroup = {}
	self.LeftPanel = self:FindChild("Frame/SurpriseInfoPanel/LeftPanel")
	self.ActivePrefab = self.LeftPanel:FindChild("ActBtnItem")
	self.btnContent = self.LeftPanel:FindChild("SurprisePanel/Viewport/Content")
	self.NoticeContent = self.LeftPanel:FindChild("NoticePanel/Viewport/Content")
	self.RightPanel = self:FindChild("Frame/SurpriseInfoPanel/RightPanel")

	self.BtnNotivce = self:FindChild("Frame/SurpriseInfoPanel/BtnTab/BtnNotivce")
	self.BtnActive = self:FindChild("Frame/SurpriseInfoPanel/BtnTab/BtnActive")
	self.flagGroup = {}
	self:InitActiveShow()
	self:AddClick("Frame/BtnClose", "ActionOut")
	self:InitTextByLanguage()
	self:RefreshRedPointState()
	self:InitBtn(self.ActivesortTab,self.ActiveTab,self.btnContent,self.RightPanel)
	self:InitBtn(self.NoticesortTab,self.NoticeTab,self.NoticeContent,self.RightPanel)
	self:GetCurrentView(self.ShowActive[1].index,self.ActiveTab)
	self.BtnActive.transform:GetComponent("Toggle").isOn = true
	self:AddClick(self.BtnNotivce, "OnClickChangeToNotivce", "click_tabchange")
	self:AddClick(self.BtnActive, "OnClickChangeToActive", "click_tabchange")

	self:ShowNotice()
end

--打开默认显示公告
function ActiveView:ShowNotice()
	if self.notice then
		self.BtnNotivce.transform:GetComponent("Toggle").isOn = true

		self:GetCurrentView(self.NoticeCurrentIndex,self.NoticeTab)

	end
end

function ActiveView:InitTextByLanguage()
	self.BtnNotivce:FindChild("Text").text = self.language.RightAct
	self.BtnActive:FindChild("Text").text = self.language.LeftAct
	self:FindChild("Frame/SurpriseInfoPanel/BtnTab/BtnNotivceSelect/Text").text = self.language.RightAct
	self:FindChild("Frame/SurpriseInfoPanel/BtnTab/BtnActiveSelect/Text").text = self.language.LeftAct
end

function ActiveView:OnClickChangeToNotivce()
	self:GetCurrentView(self.NoticeCurrentIndex,self.NoticeTab)
end


function ActiveView:OnClickChangeToActive()
	self:GetCurrentView(self.ActiveCurrentIndex,self.ActiveTab)
end

function ActiveView:InitActiveShow()

	if CC.ChannelMgr.GetTrailStatus() then
		local trailDefine = {
			['ios'] = {"btn_Facebook"},
			['android'] = {"btn_Facebook","btn_Line","btn_RelieveLine"}
		}
		local ls = CC.Platform.isIOS and trailDefine['ios'] or trailDefine['android'];
		for _,v in ipairs(self.ActiveTab) do
			v.IsShow = false;
			for _,c in ipairs(ls) do
				if v.btnName == c then
					v.IsShow = true;
				end
			end
		end
	end

	local bindingFlag = CC.Player.Inst():GetLoginInfo().BindingFlag
	local anyBinded = bit.band(bindingFlag, CC.shared_enums_pb.EF_Binded) == 0 and bit.band(bindingFlag, CC.shared_enums_pb.EF_LineBinded) == 0;
	self.ActiveTab[1].IsShow = anyBinded
	self.ActiveTab[5].IsShow = anyBinded

	-- local createTime = CC.uu.date4time(CC.Player.Inst():GetSelfInfoByKey("CreateTime"))
	-- local curryTime = os.time()
	-- log("绑定状态:"..CC.Player.Inst():GetSelfInfoByKey("EPC_AgentLevel"))
	-- log("Time = "..curryTime - createTime)
	-- if curryTime - createTime > 86400 and CC.Player.Inst():GetSelfInfoByKey("EPC_AgentLevel") == 0 then
	-- 	self.ActiveTab[3].IsShow = false
	-- end

	self.ShowActive = {}
	self:SetActiveIdnex()
end

--活动默认第一个显示的界面
function ActiveView:SetActiveIdnex()
	for i,v in ipairs(self.ActivesortTab) do
		if self.ActiveTab[v].IsShow == true then
			self.ActiveCurrentIndex = v
			self:ShowIndexActive(self.ActiveCurrentIndex)
			return
		end
	end
end

function ActiveView:InitBtn(sortTable,Input_tab,content,RightContent)
	for i = 1,#sortTable do
		local index = sortTable[i]
		local tran = CC.uu.newObject(self.ActivePrefab,content)
		tran.name = tostring(index)
		tran:GetComponent("Toggle").group = content:GetComponent("ToggleGroup")
		tran:SetActive(Input_tab[index].IsShow)
		tran:FindChild("UnSelect/Text").text = self.language[Input_tab[index].actName]
		tran:FindChild("Select/Text").text = self.language[Input_tab[index].actName]
		if Input_tab[index].redShow then
			tran:FindChild("UnSelect/RedDot"):SetActive(true)
		end
		tran.onClick = function ()
			if index >=100 then
				self.NoticeCurrentIndex = index
			else
				self.ActiveCurrentIndex = index
			end
			self:GetCurrentView(index,Input_tab)
			self:ShowIndexActive(index)
		end

		if i == 1 then
			self.IsOneActive = false
		end

		if Input_tab[index].IsShow == true and self.IsOneActive == false then
			tran.transform:GetComponent("Toggle").isOn = true
			self.IsOneActive = true
		end
		if Input_tab[index].IsShow then
			local param = {}
			param.index = index
			param.tran = tran
			table.insert(self.ShowActive,param)
		end
	end
end

function ActiveView:GetCurrentView(index,Input_tab)
	if self.CurrentView then
		if self.CurrentView.actName == Input_tab[index].actName then return	end
		self.CurrentView:Destroy()
	end
	self.CurrentView = CC.uu.CreateHallView(Input_tab[index].actName,self.RightPanel,self.language,Input_tab)
	self.CurrentView.transform:SetActive(true)
end

function ActiveView:RefreshRedPointState()
	-- self.ActiveTab[4].redShow = CC.Player.Inst():GetDailyGiftState()
end

function ActiveView:ShowIndexActive(index)
	for i=1,#self.ShowActive do
		if self.ShowActive[i].index == index then
			self.ShowActive[i].tran:FindChild("UnSelect/RedDot"):SetActive(false)
		end
	end

	if index == 2 then
		if self.CurrentView and self.CurrentView.webview then
			self.CurrentView.webview:SetVisibility(true)
		end
	else

		if self.CurrentView and self.CurrentView.webview then
			self.CurrentView.webview:SetVisibility(false)
		end
	end
end

function ActiveView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ActionOut,CC.Notifications.OnDisconnect)
end

function ActiveView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDisconnect)
end

function ActiveView:OnResume()
	self:ActionOut()
end

function ActiveView:OnMenuBack()
	self:ActionOut()
end

function ActiveView:OnDestroy()

	self:unRegisterEvent()
end

function ActiveView:ActionOut()
	if self.CurrentView and self.CurrentView.webview then
		self.CurrentView.webview:SetVisibility(false)
	end
	self.CurrentView:OnDestroy()
	self:SetCanClick(false);
    self:RunAction(self, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    		self:Destroy();
    	end})

end

return ActiveView