local CC = require("CC")

local BindTelView = CC.uu.ClassView("BindTelView")

function BindTelView:ctor(param)
	self.param = param or {}
	self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView")
	--点击获取验证码
	self.canClickGetCode = true;
end

function BindTelView:OnCreate()
	self:InitUI()
	self:InitTextByLanguage()
	self:RegisterEvent()
end

function BindTelView:InitUI()
	self.phoneInputField = self:FindChild("Layer_UI/Content/Tel")
	self.codeInputField = self:FindChild("Layer_UI/Content/Code")
	self.getCodeBtn = self:FindChild("Layer_UI/Content/GetCodeBtn")
	self.getCodeBtnGray = self:FindChild("Layer_UI/Content/GetCodeBtnGray")
	self.bindBtn = self:FindChild("Layer_UI/BindBtn")
	
	self:AddClick(self.getCodeBtn,"OnClickGetCode",nil,true)
	self:AddClick(self.bindBtn,"OnClickBind",nil,true)
	self:AddClick("Mask","ActionOut")
end

function BindTelView:InitTextByLanguage()
	self:FindChild("Layer_UI/Title").text = self.language.bindTel
    self.phoneInputField:FindChild("Placeholder").text = self.language.phonePlaceholder
	self.codeInputField:FindChild("Placeholder").text = self.language.verCodePlaceholder
	self.bindBtn:FindChild("Text").text = self.language.btnOk
	self.getCodeBtn:FindChild("Text").text = self.language.btnGetCode
end


function BindTelView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnReqGetSmsTokenRsp, CC.Notifications.NW_ReqGetSmsToken)
	CC.HallNotificationCenter.inst():register(self, self.OnBindTelRsp, CC.Notifications.NW_ReqTelBind)
end

function BindTelView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function BindTelView:OnClickGetCode()
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

function BindTelView:OnReqGetSmsTokenRsp(err,result)
	if err == 0 then
		log("vercode send success");
		CC.ViewManager.ShowTip(self.language.sendSMSSuccess)
	else
		log("vercode send failed");
		CC.ViewManager.ShowTip(self.language.sendSMSFailed)
	end
end

function BindTelView:OnClickBind()
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

    self.phoneInputField.interactable = false

	local data = {};
	data.Tel = phoneNumber;
	data.SmsToken = smsToken;
	CC.Request("ReqTelBind",data)
end

function BindTelView:OnBindTelRsp(err,result)
    self.phoneInputField.interactable = true
	if err == 0 then
		local selfInfo = CC.Player.Inst():GetSelfInfo();
		selfInfo.Data.Player.Telephone = self.phoneNumber
		local loginData = CC.Player.Inst():GetLoginInfo();
        loginData.BindingFlag = bit.bor(loginData.BindingFlag, CC.shared_enums_pb.EF_TelBinded)
		CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeTelephone);
		CC.ViewManager.ShowTip(self.language.bindSuccess)
		if self.param.callback then
			self.param.callback()
		end
		self:ActionOut();
	elseif err ~= 217 and err ~= 229 and err ~= 242 and err ~= 244 then
		CC.ViewManager.ShowTip(self.language.bindFailed)
	end
end

function BindTelView:StartCodeTimer()
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

function BindTelView:OnDestroy()
	self:UnRegisterEvent()
end

return BindTelView