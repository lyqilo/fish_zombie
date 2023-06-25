local CC = require("CC")

local UnbindTelView = CC.uu.ClassView("UnbindTelView")

function UnbindTelView:ctor(param)
	self.param = param or {}
	self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView")
	--点击获取验证码
	self.canClickGetCode = true;
	self.playerData = CC.Player.Inst():GetSelfInfo().Data.Player
	self.phoneNumber = self.playerData.Telephone
end

function UnbindTelView:OnCreate()
	self:InitUI()
	self:InitTextByLanguage()
	self:RegisterEvent()
end

function UnbindTelView:InitUI()
	self.phoneInputField = self:FindChild("Layer_UI/Content/Tel")
	self.codeInputField = self:FindChild("Layer_UI/Content/Code")
	self.getCodeBtn = self:FindChild("Layer_UI/Content/GetCodeBtn")
	self.getCodeBtnGray = self:FindChild("Layer_UI/Content/GetCodeBtnGray")
	self.unbindBtn = self:FindChild("Layer_UI/UnbindBtn")
	
	self:AddClick(self.getCodeBtn,"OnClickGetCode")
	self:AddClick(self.unbindBtn,"OnClickUnbind")
	self:AddClick("Mask","ActionOut")
	self:AddClick("Layer_UI/BtnClose","ActionOut")
	self:AddClick("Layer_UI/ServiceBtn","OnClickService")
end

function UnbindTelView:InitTextByLanguage()
	self:FindChild("Layer_UI/Title").text = self.language.unbindTelTitle
	self:FindChild("Layer_UI/Tips").text = self.language.unbindTelTip
	self:FindChild("Layer_UI/Content/Consume/Text").text = self.language.consume
	self:FindChild("Layer_UI/Content/Consume/Num").text = " x1"
	if self.phoneNumber ~= "" then
		self.phoneInputField:GetComponent("InputField").text = self.phoneNumber
		self.phoneInputField:GetComponent("InputField").interactable = false
	else
		self.phoneInputField:FindChild("Placeholder").text = self.language.phonePlaceholder
	end
	self.codeInputField:FindChild("Placeholder").text = self.language.verCodePlaceholder
	self.unbindBtn:FindChild("Text").text = self.language.btnOk
	self.getCodeBtn:FindChild("Text").text = self.language.btnGetCode
end


function UnbindTelView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnReqGetSmsTokenRsp, CC.Notifications.NW_ReqGetSmsToken)
	CC.HallNotificationCenter.inst():register(self, self.OnUnbindTelRsp, CC.Notifications.NW_ReqUnbindTelBySMS)
end

function UnbindTelView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqGetSmsToken)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqUnbindTelBySMS)
end

function UnbindTelView:OnClickService()
	-- local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLocalServiceUrl();
	-- Client.OpenURL(url);
	CC.ViewManager.OpenServiceView()
end

function UnbindTelView:OnClickGetCode()
	if not self.canClickGetCode then
		return;
	end

	local phoneText = self.phoneInputField:FindChild("Text")
	local phoneNumber = phoneText.text
	if string.len(phoneNumber) < 10 then
		CC.ViewManager.ShowTip(self.language.phoneNumberTip)
		return;
	end

	self:StartCodeTimer();
	CC.Request("ReqGetSmsToken",{Tel=phoneNumber})
end

function UnbindTelView:OnReqGetSmsTokenRsp(err,result)
	if err == 0 then
		log("vercode send success");
		CC.ViewManager.ShowTip(self.language.sendSMSSuccess)
	else
		log("vercode send failed");
		CC.ViewManager.ShowTip(self.language.sendSMSFailed)
	end
end

function UnbindTelView:OnClickUnbind()
	local phoneText = self.phoneInputField:FindChild("Text")
	local phoneNumber = phoneText.text
	if string.len(phoneNumber) < 10 then
		CC.ViewManager.ShowTip(self.language.phoneNumberTip);
		return;
	end

	local codeText = self.codeInputField:FindChild("Text")
	local smsToken = codeText.text;
	if string.len(smsToken) < 6 then
		CC.ViewManager.ShowTip(self.language.verCodeTip);
		return;
	end

	self.phoneNumber = phoneNumber

	local data = {};
	data.Tel = phoneNumber;
	data.SMSToken = smsToken;
	CC.Request("ReqUnbindTelBySMS",data)
end

function UnbindTelView:OnUnbindTelRsp(err,result)
	if err == 0 then
		local selfInfo = CC.Player.Inst():GetSelfInfo();
		selfInfo.Data.Player.Telephone = ""
		local loginData = CC.Player.Inst():GetLoginInfo();
		loginData.BindingFlag = bit.bxor(loginData.BindingFlag, CC.shared_enums_pb.EF_TelBinded)
		CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeTelephone);
		CC.ViewManager.ShowTip(self.language.unbindTelSucc)
		self:ActionOut();
	else
		--CC.ViewManager.ShowTip(self.language.unbindTelFail)
	end
end

function UnbindTelView:StartCodeTimer()
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

function UnbindTelView:OnDestroy()
	self:UnRegisterEvent()
end

return UnbindTelView