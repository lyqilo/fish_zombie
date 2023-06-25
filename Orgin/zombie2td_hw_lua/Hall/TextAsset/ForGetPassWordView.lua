local CC = require("CC")

local ForGetPassWordView = CC.uu.ClassView("ForGetPassWordView")

function ForGetPassWordView:ctor(param)
	self.param = param or {}
	self.language = CC.LanguageManager.GetLanguage("L_VerSafePassWordView")
	--点击获取验证码
	self.canClickGetCode = true;
	self.phoneNumber = CC.Player.Inst():GetSelfInfo().Data.Player.Telephone
end

function ForGetPassWordView:OnCreate()
	self:InitUI()
	self:InitTextByLanguage()
	self:RegisterEvent()
end

function ForGetPassWordView:InitUI()
	self.codeInputField = self:FindChild("Layer_UI/Content/Code")
	self.getCodeBtn = self:FindChild("Layer_UI/Content/GetCodeBtn")
	self.getCodeBtnGray = self:FindChild("Layer_UI/Content/GetCodeBtnGray")
	self.OKBtn = self:FindChild("Layer_UI/OKBtn")
	
	self:AddClick(self.getCodeBtn,"OnClickGetCode")
	self:AddClick(self.OKBtn,"OnClickOKBtn")
	self:AddClick("Mask","OnClose")
	self:AddClick("Layer_UI/ServiceBtn","OnClickService")
end

function ForGetPassWordView:InitTextByLanguage()
	self:FindChild("Layer_UI/Title").text = self.param.title or self.language.forGetPass
	self:FindChild("Layer_UI/Content/Tel/Text").text = CC.uu.phoneNumberToSecret(self.phoneNumber,3,8)
    self.getCodeBtn:FindChild("Text").text = self.language.getCode
	self.codeInputField:FindChild("Placeholder").text = self.language.inputVerifyCode
	self.OKBtn:FindChild("Text").text = self.language.confirm
    self:FindChild("Layer_UI/Tips").text = self.language.teleTip
end

function ForGetPassWordView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnReqSafeResetRsp, CC.Notifications.NW_ReqSafeReset)
	CC.HallNotificationCenter.inst():register(self, self.OnReqGetSmsTokenRsp, CC.Notifications.NW_ReqGetSmsToken)
end

function ForGetPassWordView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function ForGetPassWordView:OnClickService()
	-- local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLocalServiceUrl();
	-- Client.OpenURL(url);
	CC.ViewManager.OpenServiceView()
end

function ForGetPassWordView:OnClickGetCode()
	if not self.canClickGetCode then
		return;
	end

	if #(self.phoneNumber) < 10 then
		log("错误的手机号码")
		return;
	end

	self:StartCodeTimer();
	CC.Request("ReqGetSmsToken",{Tel = self.phoneNumber})
end

function ForGetPassWordView:OnReqGetSmsTokenRsp(err,result)
	if err == 0 then
		log("vercode send success");
		CC.ViewManager.ShowTip(self.language.sendSMSSuccess)
	else
		log("vercode send failed");
		CC.ViewManager.ShowTip(self.language.sendSMSFailed)
	end
end

function ForGetPassWordView:OnClickOKBtn()
	if #(self.phoneNumber) < 10 then
		log("错误的手机号码")
		return
	end

	local smsToken = self.codeInputField:FindChild("Text").text;
	if string.len(smsToken) < 6 then
		CC.ViewManager.ShowTip(self.language.inputVerifyCode);
		return;
	end

	--请求重置安全码
	CC.Request("ReqSafeReset",{Iphone = self.phoneNumber,IphoneCode = smsToken})
end

function ForGetPassWordView:OnReqSafeResetRsp(err,result)
	if err == 0 then
		CC.Player.Inst():GetSafeCodeData().SafeStatus = 0

        self:Destroy()
		CC.ViewManager.Open("SetSafePassWordView")
	end
end

function ForGetPassWordView:StartCodeTimer()
	self.canClickGetCode = false;
	self.getCodeBtn:SetActive(false);
	self.getCodeBtnGray:SetActive(true);
	local count = 60;
	self.getCodeBtnGray:FindChild("Text").text = string.format("%d%s",count, self.language.second);
	self:StartTimer("CodeTimer", 1, function()
			count = count - 1;
			self.getCodeBtnGray:FindChild("Text").text = string.format("%d%s",count, self.language.second);
			if count == 0 then
				self.canClickGetCode = true;
				self.getCodeBtn:SetActive(true);
				self.getCodeBtnGray:SetActive(false);
			end
		end, count);
end

function ForGetPassWordView:OnClose()
	if self.param.callBack then
		self.param.callBack()
		self:Destroy()
	else
		self:ActionOut()
	end
end

function ForGetPassWordView:OnDestroy()
	self:UnRegisterEvent()
end

return ForGetPassWordView