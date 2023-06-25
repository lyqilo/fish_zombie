local CC = require("CC")
local ReBirthdayView = CC.uu.ClassView("ReBirthdayView")

function ReBirthdayView:ctor(param)
    self.param = param
    self.nickName = ""
end

function ReBirthdayView:OnCreate()
    self.currentYear = os.date("%Y",os.time())
	self.currentMonth = os.date("%m",os.time())
	self.currentDay = os.date("%d",os.time())
    self:RegisterEvent()
    self:InitUI()
    self:InitTextByLanguage()
    self:AddClickEvent()
end

function ReBirthdayView:InitUI()
    self.DayInputFieldText = self:SubGet("Layer_UI/DayInput","InputField")
	self.MouthInputFieldText = self:SubGet("Layer_UI/MouthInput","InputField")
	self.YearInputFieldText = self:SubGet("Layer_UI/YearInput","InputField")
	-- local vip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	-- if vip < 5 then
		self:FindChild("Layer_UI/UpLoad"):SetActive(false)
	-- end
end

function ReBirthdayView:InitTextByLanguage()
    self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView")
    self:FindChild("Layer_UI/Title").text = self.language.birthTitle
    self:FindChild("Layer_UI/BtnSure/Text").text = self.language.btnOk
    self:FindChild("Layer_UI/Tips").text = self.language.birthTip
	-- self:FindChild("Layer_UI/Tips2").text = self.language.realName_tip2
    self:FindChild("Layer_UI/YearInput/Des").text = self.language.year
    self:FindChild("Layer_UI/MouthInput/Des").text = self.language.mon
    self:FindChild("Layer_UI/DayInput/Des").text = self.language.day
	self:FindChild("Layer_UI/UpLoad/U/Text").text = "40K-2.1M"
end

function ReBirthdayView:AddClickEvent()
    local dayInput = self:FindChild("Layer_UI/DayInput")
    UIEvent.AddInputFieldOnValueChange(dayInput, function( str )
		self:OnDayInputChange(str)
	end)

	local mouthInput = self:FindChild("Layer_UI/MouthInput")
	UIEvent.AddInputFieldOnValueChange(mouthInput, function( str )
		self:OnMouthInputChange(str)
	end)

	local yearInput = self:FindChild("Layer_UI/YearInput")
	UIEvent.AddInputFieldOnValueChange(yearInput, function( str )
		self:OnYearInputChange(str)
	end)
    self:AddClick("Mask","ActionOut")
	self:AddClick("Layer_UI/CloseBtn","ActionOut")
    self:AddClick("Layer_UI/BtnSure","OnClickSubmit")
	self:AddClick("Layer_UI/UpLoad","OpenPhoto")
end

function ReBirthdayView:OpenPhoto()

	CC.ViewManager.Open("VerifiedView")
end

function ReBirthdayView:OnDayInputChange(str)
	if str == "-" or str == "" then
		self.DayInputFieldText.text = ""
		return
	elseif str == "00" then
		self.DayInputFieldText.text = "01"
	end
	local strNum = tonumber(str)
	if strNum < 0 or strNum > 31 then
		self.DayInputFieldText.text = 01
	end
end

function ReBirthdayView:OnMouthInputChange(str)
	if str == "-" or str == "" then
		self.MouthInputFieldText.text = ""
		return
	elseif str == "00" then
		self.MouthInputFieldText.text = "01"
	end
	local strNum = tonumber(str)
	if strNum < 0 or strNum > 12 then
		self.MouthInputFieldText.text = 01
	end
end

function ReBirthdayView:OnYearInputChange(str)
	if str == "-" or str == "" then
		self.YearInputFieldText.text = ""
		return
	end
	if string.len(str) == 4 then
		local strNum = tonumber(str)
		if strNum < 1900 then
			self.YearInputFieldText.text = 1900
		elseif strNum > tonumber(self.currentYear) then
			self.YearInputFieldText.text = self.currentYear
		end
	end
end

function ReBirthdayView:OnClickSubmit()
    local day = tonumber(self.DayInputFieldText.text)
	local mouth = tonumber(self.MouthInputFieldText.text)
	local year = tonumber(self.YearInputFieldText.text)
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
    --CC.ViewManager.ShowTip(self.language.empty)
    local Birth = self.MouthInputFieldText.text.."/"..self.DayInputFieldText.text.."/"..self.YearInputFieldText.text
    CC.Request("ReqUpdateBirth",{PlayerID = CC.Player.Inst():GetSelfInfoByKey("Id"), Birth = Birth})
end

function ReBirthdayView:UpdateBirthResp(err,data)
    log(CC.uu.Dump(data, "++++++++"))
    if err == 0 then
        local selfInfo = CC.Player.Inst():GetSelfInfo()
        selfInfo.Data.Player.Birth = data.Birth
        CC.Player.Inst():GetBirthdayGiftData().UpdateBirthStatus = false
        CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeBirth)
        self:ActionOut()
    end
end

function ReBirthdayView:UpLoad()
	self:Destroy()
end

function ReBirthdayView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.UpdateBirthResp,CC.Notifications.NW_ReqUpdateBirth)
	CC.HallNotificationCenter.inst():register(self,self.UpLoad,CC.Notifications.OnBirthUploadImage)
end

function ReBirthdayView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function ReBirthdayView:OnDestroy()
    self:UnRegisterEvent()
end

return ReBirthdayView
