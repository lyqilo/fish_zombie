
local CC = require("CC")

local PersonalBindPhoneView = CC.uu.ClassView("PersonalBindPhoneView")

--[[
@param
callback 绑定成功回调
]]
function PersonalBindPhoneView:ctor(param)
	self.param = param or {}

	self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView");
	--点击获取验证码
	self.canClickGetCode = true;

end

function PersonalBindPhoneView:OnCreate()
	self.playerData = CC.Player.Inst():GetSelfInfo();

	self.currentYear = os.date("%Y",os.time())
	self.currentMonth = os.date("%m",os.time())
	self.currentDay = os.date("%d",os.time())

	self:InitContent();

	self:RegisterEvent();
end

function PersonalBindPhoneView:InitContent()

	--日期输入框
	self.DayInputFieldText = self:SubGet("Frame/Shadow/DayInput","InputField")
	self.MouthInputFieldText = self:SubGet("Frame/Shadow/MouthInput","InputField")
	self.YearInputFieldText = self:SubGet("Frame/Shadow/YearInput","InputField")

	self.title = self:FindChild("Frame/Title/Text")
	self.birthLabel = self:FindChild("Frame/Shadow/BirthLabel")
	self.dayLabel = self:FindChild("Frame/Shadow/DayInput/Des")
	self.monLabel = self:FindChild("Frame/Shadow/MouthInput/Des")
	self.yearLabel = self:FindChild("Frame/Shadow/YearInput/Des")
	self.sexLabel = self:FindChild("Frame/Shadow/Sex/Label")
	self.maleLabel = self:FindChild("Frame/Shadow/Sex/Male/Label")
	self.feMaleLabel = self:FindChild("Frame/Shadow/Sex/Female/Label")
	self.tips = self:FindChild("Frame/Tips")

	self.btnBind = self:FindChild("Frame/BtnBind")
	self.btnGetCode = self:FindChild("Frame/Shadow/BtnGetCode")
	self.btnGetCodeGray = self:FindChild("Frame/Shadow/BtnGetCodeGray");

	self.phoneNumberDes = self:FindChild("Frame/Shadow/PhoneNumberInput/Des");
	self.verCodeDes = self:FindChild("Frame/Shadow/VerificationCodeInput/Des");
	self.btnBindText = self:FindChild("Frame/BtnBind/Text");
	self.btnGetCodeGrayText = self:FindChild("Frame/Shadow/BtnGetCodeGray/Text");
	self.btnGetCodeText = self:FindChild("Frame/Shadow/BtnGetCode/Text");

	self.phonePlaceholder = self:FindChild("Frame/Shadow/PhoneNumberInput/Placeholder");
	self.verCodePlaceholder = self:FindChild("Frame/Shadow/VerificationCodeInput/Placeholder");

	self.phoneInputField = self:SubGet("Frame/Shadow/PhoneNumberInput","InputField")
	self.verCodeInputField = self:SubGet("Frame/Shadow/VerificationCodeInput","InputField");

	self.guideText = self:FindChild("Frame/guide/Text")
	self.guideBtn = self:FindChild("Frame/guide/Btn/Text")
	
	self.phoneNumber = self.playerData.Data.Player.Telephone

	self:AddClick("Frame/BtnBind", "ImproveInformation");

	self:AddClick("Frame/Shadow/BtnGetCode", "OnClickGetCode");

	self:AddClick("Frame/BtnClose", "ActionOut");

	self:FindChild("Frame/Shadow/Sex/Female").onClick = function()
		self:FindChild("Frame/Shadow/Sex/Female"):GetComponent("Toggle").isOn = true
		self.sex = CC.shared_enums_pb.S_Female
	end

	self:FindChild("Frame/Shadow/Sex/Male").onClick = function()
		self:FindChild("Frame/Shadow/Sex/Male"):GetComponent("Toggle").isOn = true
		self.sex = CC.shared_enums_pb.S_Male
	end

	if self.param.guide then
		self:FindChild("Frame/guide"):SetActive(true)
		self:FindChild("Frame/mask"):SetActive(true)
		self:AddClick(self:FindChild("Frame/guide/Btn"), function()
			self:FindChild("Frame/guide"):SetActive(false)
		self:FindChild("Frame/mask"):SetActive(false)
		end)
	end

	local dayInput = self:FindChild("Frame/Shadow/DayInput")
	UIEvent.AddInputFieldOnValueChange(dayInput, function( str )
		self:OnDayInputChange(str)
	end)

	local mouthInput = self:FindChild("Frame/Shadow/MouthInput")
	UIEvent.AddInputFieldOnValueChange(mouthInput, function( str )
		self:OnMouthInputChange(str)
	end)

	local yearInput = self:FindChild("Frame/Shadow/YearInput")
	UIEvent.AddInputFieldOnValueChange(yearInput, function( str )
		self:OnYearInputChange(str)
	end)

	self:InitTextByLanguageAndState();
end

function PersonalBindPhoneView:InitTextByLanguageAndState()
	self.title.text = self.language.btnBindPhone
	self.birthLabel.text = self.language.birth
	self.sexLabel.text = self.language.sex
	self.maleLabel.text = self.language.male
	self.feMaleLabel.text = self.language.female
	self.dayLabel.text = self.language.day
	self.monLabel.text = self.language.mon
	self.yearLabel.text = self.language.year
	self.tips.text = self.language.bindPhoneTips

	self.phoneNumberDes.text = self.language.phoneNumberDes;
	self.verCodeDes.text = self.language.verCodeDes;
	self.btnBindText.text = self.language.btnOk;
	
	self.guideText.text = self.language.guideText
	self.guideBtn.text = self.language.btnOk

	if self.phoneNumber ~= "" then
		self.phonePlaceholder.text = self.phoneNumber
		self.phoneInputField.interactable = false
		self.verCodePlaceholder.text = self.language.blinded;
		self.verCodeInputField.interactable = false
		self.btnGetCodeGrayText.text = self.language.blinded
		self.btnGetCodeGray:SetActive(true);
		self.btnGetCode:SetActive(false)
	else
		self.phonePlaceholder.text = self.language.phonePlaceholder;
		self.verCodePlaceholder.text = self.language.verCodeTip;
		self.btnGetCode.text = self.language.btnGetCode;
		self.btnGetCodeText.text = self.language.btnGetCode
		self.btnGetCodeGray:SetActive(false);
		self.btnGetCode:SetActive(true)
	end

	if self.playerData.Data.Player.Sex == CC.shared_enums_pb.S_Female then
		self:FindChild("Frame/Shadow/Sex/Female"):GetComponent("Toggle").isOn = true
		self.sex = CC.shared_enums_pb.S_Female
	else
		self:FindChild("Frame/Shadow/Sex/Male"):GetComponent("Toggle").isOn = true
		self.sex = CC.shared_enums_pb.S_Male
	end
	
	if self.playerData.Data.Player.Birth ~= "" then
		local birth = self.playerData.Data.Player.Birth
		local time = CC.uu.date4time(birth)
		local year = os.date("%Y",time)
		local month = os.date("%m",time)
		local day = os.date("%d",time)
		self.YearInputFieldText.text = year
		self.YearInputFieldText.interactable = false
		self.MouthInputFieldText.text = month
		self.MouthInputFieldText.interactable = false
		self.DayInputFieldText.text = day
		self.DayInputFieldText.interactable = false
	end
end

function PersonalBindPhoneView:OnDayInputChange(str)
	if str == "-" or str == "" then
		self.DayInputFieldText.text = ""
		return
	elseif str == "00" then
		self.DayInputFieldText.text = "01"
	end
	str = tonumber(str)
	if str < 0 or str > 31 then
		self.DayInputFieldText.text = 01
	end
end

function PersonalBindPhoneView:OnMouthInputChange(str)
	if str == "-" or str == "" then
		self.MouthInputFieldText.text = ""
		return
	elseif str == "00" then
		self.MouthInputFieldText.text = "01"
	end
	str = tonumber(str)
	if str < 0 or str > 12 then
		self.MouthInputFieldText.text = 01
	end
end

function PersonalBindPhoneView:OnYearInputChange(str)
	if str == "-" or str == "" then
		self.YearInputFieldText.text = ""
		return
	end
	if string.len(str) == 4 then
		local str = tonumber(str)
		if str < 1900 then
			self.YearInputFieldText.text = 1900
		elseif str > tonumber(self.currentYear) then
			self.YearInputFieldText.text = self.currentYear
		end
	end
end

function PersonalBindPhoneView:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self, self.OnReqTelBindRsp, CC.Notifications.NW_ReqTelBind)

	CC.HallNotificationCenter.inst():register(self, self.OnReqGetSmsTokenRsp, CC.Notifications.NW_ReqGetSmsToken)
end

function PersonalBindPhoneView:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqTelBind)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqGetSmsToken)
end

function PersonalBindPhoneView:Verification()
	local day = tonumber(self.DayInputFieldText.text)
	local mouth = tonumber(self.MouthInputFieldText.text)
	local year = tonumber(self.YearInputFieldText.text)

	if not self.sex then
		CC.ViewManager.ShowTip(self.language.sexTips)
		return false
	end

	if not (day and mouth and year) then
		CC.ViewManager.ShowTip(self.language.birthTips)
		return false
	end

	self.DayInputFieldText.text = string.format("%02d", day)
	self.MouthInputFieldText.text = string.format("%02d", mouth)

	if year < 1900 or year > tonumber(self.currentYear) then
		CC.ViewManager.ShowTip(self.language.yearTips)
		self.YearInputFieldText.text = "1900"
		return false
	end
	if year == tonumber(self.currentYear) and mouth > tonumber(self.currentMonth) then
		CC.ViewManager.ShowTip(self.language.dayTips)
		self.MouthInputFieldText.text = self.currentMonth
		return false
	end
	if year == tonumber(self.currentYear) and mouth == tonumber(self.currentMonth) and day > tonumber(self.currentDay) then
		CC.ViewManager.ShowTip(self.language.dayTips)
		self.DayInputFieldText.text = self.currentDay
		return false
	end

	if mouth == 4 or mouth == 6 or mouth == 9 or mouth == 11 then
		if day > 30 then
			CC.ViewManager.ShowTip(self.language.dayTips)
			return false
		end
	elseif mouth == 2 then
		if (year % 4 == 0 and year % 100 ~=0) or year % 400 == 0 then
			if day > 29 then
				CC.ViewManager.ShowTip(self.language.dayTips)
				return false
			end
		else
			if day > 28 then
				CC.ViewManager.ShowTip(self.language.dayTips)
				return false
			end
		end
	end
	return true
end

function PersonalBindPhoneView:ImproveInformation()
	if not self:Verification() then return end
	local tips = CC.ViewManager.ShowMessageBox(self.language.onlyOne,
			function ()
				if self.phoneNumber ~= "" then
					self:SavePlayer()
				else
					self:OnClickBind()
				end
			end,
			function ()
			end)
	tips:SetOkText(self.language.btnOk)
end

function PersonalBindPhoneView:OnClickBind()

	local phoneInputField = self:FindChild("Frame/Shadow/PhoneNumberInput/Text");
	local phoneNumber = phoneInputField.text;
	if string.len(phoneNumber) < 10 then
		CC.ViewManager.ShowTip(self.language.phoneNumberTip);
		return;
	end

	local codeInputField = self:FindChild("Frame/Shadow/VerificationCodeInput/Text");
	local smsToken = codeInputField.text;
	if string.len(smsToken) < 6 then
		CC.ViewManager.ShowTip(self.language.verCodeTip);
		return;
	end

	self.phoneNumber = phoneNumber

	local data = {};
	data.Tel = phoneNumber;
	data.SmsToken = smsToken;
	CC.Request("ReqTelBind",data)
end

function PersonalBindPhoneView:SavePlayer()
	local data = {}
	data.Birth = self.MouthInputFieldText.text.."/"..self.DayInputFieldText.text.."/"..self.YearInputFieldText.text
	data.Sex = tostring(self.sex)
	CC.Request("ReqSavePlayer",data, function(err, result)
		if err == 0 then
			local selfInfo = CC.Player.Inst():GetSelfInfo();
			selfInfo.Data.Player.Sex = tonumber(data.Sex)
			selfInfo.Data.Player.Birth = data.Birth
			local loginData = CC.Player.Inst():GetLoginInfo();
			loginData.BindingFlag = bit.bor(loginData.BindingFlag, CC.shared_enums_pb.EF_TelBinded)
			if self.param and self.param.callback then
				self.param.callback({Birth = data.Birth ,Sex = tonumber(data.Sex)})
			end
			CC.ViewManager.ShowTip(self.language.bindSuccess);
			selfInfo.Data.Player.Telephone = self.phoneNumber;
			CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeTelephone);
			self:ActionOut();
		else
			log("SavePlayer failed");
			CC.ViewManager.ShowTip(self.language.saveFailed);
		end
	end);
end

function PersonalBindPhoneView:OnReqTelBindRsp(err, result)

	if err == 0 then
		log("phone bind success");
		self.phonePlaceholder.text = self.phoneNumber
		self.phoneInputField.interactable = false
		self.verCodePlaceholder.text = self.language.verCodePlaceholder;
		self.verCodeInputField.interactable = false
		self.btnGetCodeGrayText.text = self.language.blinded
		self.btnGetCodeGray:SetActive(true);
		self.btnGetCode:SetActive(false)
		self:SavePlayer()
	elseif err == 217 or err == 229 or err == 242 or err == 244 then
		self.phoneNumber = ""
		self.phoneInputField.text = ""
		self.verCodeInputField.text = ""
	else
		log("phone bind failed");
		self.phoneNumber = ""
		self.phoneInputField.text = ""
		self.verCodeInputField.text = ""
		CC.ViewManager.ShowTip(self.language.bindFailed);
	end
end

function PersonalBindPhoneView:OnClickGetCode()

	if not self.canClickGetCode then
		return;
	end

	local phoneInputField = self:FindChild("Frame/Shadow/PhoneNumberInput/Text");
	local phoneNumber = phoneInputField.text;
	if string.len(phoneNumber) < 10 then
		CC.ViewManager.ShowTip(self.language.phoneNumberTip);
		return;
	end

	self:StartCodeTimer();
	CC.Request("ReqGetSmsToken",{Tel=phoneNumber})

end

function PersonalBindPhoneView:OnReqGetSmsTokenRsp(err, result)

	if err == 0 then
		log("vercode send success");
		CC.ViewManager.ShowTip(self.language.sendSMSSuccess);
	else
		log("vercode send failed");
		CC.ViewManager.ShowTip(self.language.sendSMSFailed);
	end
end

function PersonalBindPhoneView:StartCodeTimer()
	self.canClickGetCode = false;
	self.btnGetCode:SetActive(false);
	self.btnGetCodeGray:SetActive(true);
	local count = 60;
	self.btnGetCodeGrayText.text = string.format("%d%s",count, self.language.second);
	self:StartTimer("CodeTimer", 1, function()
			count = count - 1;
			self.btnGetCodeGrayText.text = string.format("%d%s",count, self.language.second);
			if count == 0 then
				self.canClickGetCode = true;
				self.btnGetCode:SetActive(true);
				self.btnGetCodeGray:SetActive(false);
			end
		end, count);
end

function PersonalBindPhoneView:OnDestroy()

	self:UnRegisterEvent();
end

return PersonalBindPhoneView;
