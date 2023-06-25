local CC = require("CC")

local LoginView = CC.uu.ClassView("LoginView")

function LoginView:ctor(param)
	self.param = param
end

function LoginView:OnCreate()
	self.notice = self:FindChild("NoticeParent/Notice")
	self.noticeIsShow = false
	self.playSound = false
	--解决ios问题
	self.isInvoked = false
	--保存登录手机号码
	self.PhoneNum = nil

	self:InitContent()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()

	self:InitTextByLanguage()
	self:SubscribeCommonTopic()

	log("Util.userPath = " .. Util.userPath)
end

function LoginView:InitContent()
	self.ShowBG = self:FindChild("LoadingNode/BG")

	self:AddClick("BtnPanel/BtnFacebook", "OnClickFacebook", nil, true)

	self:AddClick("BtnPanel/BtnSmall/BtnGuest", "OnClickGuest", nil, true)

	self:AddClick("BtnPanel/BtnLine", "OnClickLine", nil, true)

	self:AddClick("BtnPanel/BtnService", "OnClickService", nil, true)

	self:AddClick(
		"Exit",
		function()
			Application.Quit()
		end,
		nil,
		true
	)

	self:AddClick(
		"NoticeBtn",
		function()
			self:Show()
		end
	)

	self:AddClick(
		"NoticeParent/Notice/Back",
		function()
			self:Hide()
		end
	)

	self:AddClick(
		"PhoneCheck/BG/Close",
		function()
			self:ClearPhonePanel()
		end
	)

	self:AddClick(
		"PhoneLogin/BG/Close",
		function()
			self:ClearPhonePanel()
		end
	)

	self:AddClick("PhoneCheck/BG/Login", "PhoneLogin")

	self:AddClick("PhoneCheck/BG/GetCode", "GetPhoneVerCode")

	self:FindChild("BtnPanel/BtnService"):SetActive(false)
	self:RefreshUI({refreshBtnService = true})
	-- self:AddClick("DebugListener/Node1", "OnclickNode1")
	-- self:AddClick("DebugListener/Node2", "OnclickNode2")

	self.loadingPercent = self:FindChild("LoadingNode/LoadingPtg")
	self.loadingSlider = self:FindChild("LoadingNode/Slider")

	self:RunAction(self:FindChild("LoadingNode/CircleImg"), {"rotateBy", 360, 2, loop = -1})

	if not CC.ChannelMgr.GetSwitchByKey("bHasGuestLogin") or CC.ChannelMgr.GetIosTrailStatus() then
		local btnGuest = self:FindChild("BtnPanel/BtnSmall/BtnGuest")
		btnGuest:SetActive(false)
	end

	if CC.ChannelMgr.GetSwitchByKey("bHasChannelLogin") then
		self:FindChild("BtnPanel/BtnOppo"):SetActive(true)
		self:AddClick("BtnPanel/BtnOppo", "OnClickOppo", nil, true)
		self:FindChild("BtnPanel/Mask/Tips"):SetActive(false)
		self:FindChild("BtnPanel/BtnFacebook").y = -310
		self:FindChild("BtnPanel/BtnLine").y = -450
	end

	if CC.ChannelMgr.GetSwitchByKey("bHasAppleLogin") then
		local version = AppleUtil.GetSystemVersion()
		version = CC.uu.splitString(version, ".")[1]
		if version ~= "" and tonumber(version) >= 13 then
			self:FindChild("BtnPanel/BtnSmall/BtnApple"):SetActive(true)
			self:AddClick("BtnPanel/BtnSmall/BtnApple", "OnClickApple", nil, true)
		end
	end

	if CC.ChannelMgr.GetIosTrailStatus() then
		local btnPanel = self:FindChild("BtnPanel")
		btnPanel.y = btnPanel.y + 100
		btnPanel:FindChild("Mask"):SetActive(false)
		btnPanel:FindChild("BtnSmall"):SetActive(false)
		btnPanel:FindChild("BtnTrailApple"):SetActive(true)
		self:AddClick("BtnPanel/BtnTrailApple", "OnClickApple", nil, true)
		btnPanel:FindChild("BtnTrailGuest"):SetActive(true)
		self:AddClick("BtnPanel/BtnTrailGuest", "OnClickGuest", nil, true)
		self:FindChild("Icon"):SetActive(false)
		btnPanel:FindChild("BtnService"):SetActive(false)
	end

	self:RandomShowBG()
end

function LoginView:InitTextByLanguage()
	local language = self:GetLanguage()
	self:FindChild("BtnPanel/BtnFacebook/Text").text = language.btnFB
	self:FindChild("BtnPanel/BtnFacebook/Node/Text").text = "5000"
	self:FindChild("BtnPanel/BtnLine/Text").text = language.btnLine
	self:FindChild("BtnPanel/BtnLine/Node/Text").text = "5000"
	self:FindChild("BtnPanel/BtnSmall/BtnApple/Text").text = language.btnApple
	self:FindChild("BtnPanel/BtnTrailApple/Text").text = language.btnApple
	self:FindChild("LoadingNode/LoadingTip").text = language.loadingTips
	local btnGuest = self:FindChild("BtnPanel/BtnSmall/BtnGuest/Text")
	btnGuest.text = language.btnGuest
	local btnExit = self:FindChild("Exit/Text")
	btnExit.text = language.exit

	local btnOppo = self:FindChild("BtnPanel/BtnOppo/Text")
	btnOppo.text = language.btnOppo

	local tips = self:FindChild("BtnPanel/Mask/Tips")
	tips.text = language.loginTips

	if CC.ChannelMgr.GetIosTrailStatus() then
		local btnGuest = self:FindChild("BtnPanel/BtnTrailGuest/Text")
		btnGuest.text = language.btnGuest
	end
	self:FindChild("LoadingNode/LoadingWarn").text = language.LoadingWarn

	--手机登录相关修改
	self:FindChild("PhoneCheck/BG/PhoneNum/Placeholder").text = language.PhoneNum
	self:FindChild("PhoneCheck/BG/PhoneNum/Label").text = language.PhoneNum
	self:FindChild("PhoneCheck/BG/VerCode/Placeholder").text = language.OTPCode
	self:FindChild("PhoneCheck/BG/VerCode/Label").text = language.OTPCode
	self:FindChild("PhoneCheck/BG/Login/Text").text = language.Commit
	self:FindChild("PhoneCheck/BG/GetCode/Text").text = language.GetCode
	self:FindChild("PhoneLogin/BG/Title/Text").text = language.ChoosePhoneNum

	self.IDNode = self:FindChild("PhoneLogin/BG/Scroll View/Viewport/Content")
	self.IDBtn = self:FindChild("PhoneLogin/Btn")
end

function LoginView:RefreshUI(param)
	if param.showBtns ~= nil then
		local btnPanel = self:FindChild("BtnPanel")
		btnPanel:SetActive(param.showBtns)
	end

	if param.percent then
		if not self.loadingPercent then
			self.loadingPercent = self:FindChild("LoadingNode/LoadingPtg")
		end
		self.loadingPercent.text = param.percent .. "%"
		self.loadingSlider:GetComponent("Slider").value = param.percent / 100
	end

	if param.showPercent ~= nil then
		local loadingNode = self:FindChild("LoadingNode")
		loadingNode:SetActive(param.showPercent)
		if param.showPercent and not self.playSound then
			self.playSound = true
			-- CC.Sound.StopEffect()
			CC.Sound.PlayHallEffect("RoyalCasino")
		end
	end

	if param.refreshBtnService then
		local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("WebService", false)
		self:FindChild("BtnPanel/BtnService"):SetActive(switchOn)
	end
end

function LoginView:RefreshNotice(param)
	self:FindChild("NoticeParent/Notice/Viewport/Content/Title").text = param.Title
	self:FindChild("NoticeParent/Notice/Viewport/Content/Content").text = param.Content
	LayoutRebuilder.ForceRebuildLayoutImmediate(self:FindChild("NoticeParent/Notice/Viewport/Content"))
end

function LoginView:Show()
	if not self.noticeIsShow then
		self.noticeIsShow = true
		self:SetCanClick(false)
		self:FindChild("NoticeBtn"):SetActive(false)
		self:RunAction(
			self.notice,
			{
				"localMoveTo",
				self.notice.transform.x + 680,
				self.notice.transform.y,
				0.2,
				ease = CC.Action.EOutSine,
				function()
					self:SetCanClick(true)
				end
			}
		)
	end
end

function LoginView:Hide()
	if self.noticeIsShow then
		self.noticeIsShow = false
		self:SetCanClick(false)
		self:RunAction(
			self.notice,
			{
				"localMoveTo",
				self.notice.transform.x - 680,
				self.notice.transform.y,
				0.2,
				ease = CC.Action.EOutSine,
				function()
					self:FindChild("NoticeBtn"):SetActive(true)
					self:SetCanClick(true)
				end
			}
		)
	else
		self:FindChild("NoticeBtn"):SetActive(true)
	end
end

function LoginView:ShowNotice(show)
	if show and not self.noticeIsShow then
		self.noticeIsShow = true
		self:SetCanClick(false)
		self:FindChild("NoticeBtn"):SetActive(false)
		self:RunAction(
			self.notice,
			{
				"localMoveTo",
				self.notice.transform.x + 680,
				self.notice.transform.y,
				0.2,
				ease = CC.Action.EOutSine,
				function()
					self:SetCanClick(true)
				end
			}
		)
	else
		self:FindChild("NoticeBtn"):SetActive(false)
	end
end

function LoginView:UnderMaintenance()
	if not self.noticeIsShow then
		self.noticeIsShow = true
		self:SetCanClick(false)
		self:FindChild("NoticeBtn"):SetActive(false)
		self:RunAction(
			self.notice,
			{
				"localMoveTo",
				self.notice.transform.x + 680,
				self.notice.transform.y,
				0.2,
				ease = CC.Action.EOutSine,
				function()
					self:SetCanClick(true)
				end
			}
		)
		self:FindChild("Exit"):SetActive(true)
	end
end

function LoginView:RandomShowBG()
	if CC.ChannelMgr.GetTrailStatus() then
		local mask = self:FindChild("LoadingNode/Mask")
		mask:SetActive(false)
		return
	end
	-- local rd = math.random(1 ,10000)
	local loadImage = "loading_psj2023"
	self:FindChild("LoadingNode/Icon"):SetActive(false)
	--local time = os.time({year = 2021,month = 12,day = 31,hour = 23,min = 59,sec = 59})
	--local loadImage = os.time() <= time and "Christmas_loading" or "New_Year_loading"
	self:SetRawImageFromAb(self.ShowBG, loadImage)
	self.ShowBG:SetActive(true)
end

function LoginView:OnClickFacebook()
	CC.ReportManager.SetDot("CLICKFBBTN")
	CC.Player.Inst():SetAppleLoginState(false)
	self.viewCtr:OnFacebookLogin()
	self:Hide()
end

function LoginView:OnClickGuest()
	CC.ReportManager.SetDot("CLICKGUESTBTN")
	CC.Player.Inst():SetAppleLoginState(false)
	self.viewCtr:OnGuestLogin()
	self:Hide()
end

function LoginView:OnClickApple()
	CC.ReportManager.SetDot("CLICKAPPLEBTN")
	CC.Player.Inst():SetAppleLoginState(true)
	self.viewCtr:OnAppleLogin()
	self:Hide()
end

function LoginView:OnClickLine()
	CC.ReportManager.SetDot("CLICKLINEBTN")
	CC.Player.Inst():SetAppleLoginState(false)
	self.viewCtr:OnLineLogin()
	self:Hide()
end

function LoginView:OnClickOppo()
	CC.Player.Inst():SetAppleLoginState(false)
	self.viewCtr:OnOppoLogin()
	self:Hide()
end

function LoginView:OnClickService()
	if CC.Platform.isIOS and not self.isInvoked then
		--ios横竖屏崩溃问题
		self.isInvoked = true
		CC.ApplePayPlugin.QueryInventory()
	end
	self.viewCtr:OnOpenService()
end

function LoginView:OnclickNode1()
	self.viewCtr:OnAddNodeCount(1)
end

function LoginView:OnclickNode2()
	self.viewCtr:OnAddNodeCount(2)
end

function LoginView:PhoneLogin()
	local PhoneNum = self:SubGet("PhoneCheck/BG/PhoneNum", "InputField").text
	local VerCode = self:SubGet("PhoneCheck/BG/VerCode", "InputField").text
	self.PhoneNum = PhoneNum
	self.VerCode = VerCode
	CC.Request("ReqVerifyPhoneToken", {Phone = PhoneNum, Token = VerCode})
end

function LoginView:GetPhoneVerCode()
	local PhoneNum = self:SubGet("PhoneCheck/BG/PhoneNum", "InputField").text
	CC.Request("ReqGetTokenByPhone", {Phone = PhoneNum})
end

function LoginView:InitIDBtn(param)
	if self.PhoneNum and self.VerCode then
		Util.ClearChild(self.IDNode, false)
		for i, v in ipairs(param.PlayerId) do
			local btn = CC.uu.newObject(self.IDBtn, self.IDNode)
			btn:FindChild("Text").text = v
			btn:SetActive(true)
			self:AddClick(
				btn.transform,
				function()
					local data = {}
					data.PlayerId = v
					data.Phone = self.PhoneNum
					data.Token = self.VerCode
					data.Imei = CC.Platform.GetDeviceId()
					data.OS = CC.Platform.GetOSEnum()
					CC.Request("ReqLoginByPhone", data)
				end
			)
		end
		self:FindChild("PhoneCheck"):SetActive(false)
		self:FindChild("PhoneLogin"):SetActive(true)
	end
end

function LoginView:ClearPhonePanel()
	self:SubGet("PhoneCheck/BG/PhoneNum", "InputField").text = nil
	self:SubGet("PhoneCheck/BG/VerCode", "InputField").text = nil
	self.PhoneNum = nil
	self.VerCode = nil
	self:FindChild("PhoneCheck"):SetActive(false)
	self:FindChild("PhoneLogin"):SetActive(false)
end

function LoginView:OpenPhoneLogin()
	self:FindChild("PhoneCheck"):SetActive(true)
end

function LoginView:StartPhoneTimer()
	local time = 60
	local btn = self:FindChild("PhoneCheck/BG/GetCode"):GetComponent("Button")
	btn:SetBtnEnable(false)
	self:FindChild("PhoneCheck/BG/GetCode/Text").text = time
	self:StartTimer(
		"VerCode",
		1,
		function()
			time = time - 1
			self:FindChild("PhoneCheck/BG/GetCode/Text").text = time
			if time < 1 then
				local language = self:GetLanguage()
				self:FindChild("PhoneCheck/BG/GetCode/Text").text = language.GetCode
				btn:SetBtnEnable(true)
			end
		end,
		60
	)
end

--订阅通用Firebase主题
function LoginView:SubscribeCommonTopic()
	if not CC.LocalGameData.GetLocalStateToKey("Topic_AllPlayer") then
		CC.FirebasePlugin.SubscribeTopic("AllPlayer")
		CC.LocalGameData.SetLocalStateToKey("Topic_AllPlayer", true)
	end
end

function LoginView:OnDestroy()
	if self.viewCtr and self.viewCtr.Destroy then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
end

return LoginView
