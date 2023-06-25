local CC = require("CC")

local SetUpSoundView = CC.uu.ClassView("SetUpSoundView")

function SetUpSoundView:OnCreate()
	self:InitContent()

	self:InitTextByLaguage()
end

function SetUpSoundView:InitContent()
	if CC.LocalGameData.GetFrames() > 30 then
		self:FindChild("Frame/GrayLayer/Frames/High"):GetComponent("Toggle").isOn = true
	else
		self:FindChild("Frame/GrayLayer/Frames/Low"):GetComponent("Toggle").isOn = true
	end

	self.soundSlider = self:CreateSliderItem("Sound")
	self.soundSlider.component.value = CC.Sound.GetMusicVolume()
	self.soundSlider.onSetStateByValue(self.soundSlider.component.value)
	UIEvent.AddSliderOnValueChange(
		self.soundSlider.transform,
		function(value)
			self.soundSlider.onSetStateByValue(value)
			CC.Sound.SetMusicVolume(value)
			CC.HallNotificationCenter.inst():post(CC.Notifications.SoundVolumeChange, value)
		end
	)

	self.effectlider = self:CreateSliderItem("Effect")
	self.effectlider.component.value = CC.Sound.GetEffectVolume()
	self.effectlider.onSetStateByValue(self.effectlider.component.value)
	UIEvent.AddSliderOnValueChange(
		self.effectlider.transform,
		function(value)
			self.effectlider.onSetStateByValue(value)
			CC.Sound.SetEffectVolume(value)
			CC.HallNotificationCenter.inst():post(CC.Notifications.EffectVolumeChange, value)
		end
	)

	if not CC.ViewManager.IsHallScene() then
		self:FindChild("Frame/BtnLogout"):SetActive(false)
	end

	self:AddClick("Frame/BtnClose", "OnClickClose")

	self:AddClick("Frame/BtnLogout", "OnClickLogout")

	self:FindChild("Frame/GrayLayer/Frames/High").onClick = function()
		self:FindChild("Frame/GrayLayer/Frames/High"):GetComponent("Toggle").isOn = true
		CC.LocalGameData.ChangeFrames(true)
	end

	self:FindChild("Frame/GrayLayer/Frames/Low").onClick = function()
		self:FindChild("Frame/GrayLayer/Frames/Low"):GetComponent("Toggle").isOn = true
		CC.LocalGameData.ChangeFrames(false)
	end

	self:FindChild("Frame/BtnSafe"):SetActive(CC.Player.Inst():GetSafeCodeData().SafeStatus == 1)
	self:AddClick(
		"Frame/BtnSafe",
		function()
			self:Destroy()
			CC.ViewManager.Open("SafePassWordExplainView")
		end
	)

	local bigVersion = AppInfo.version or 1
	local hotFixVersion = Util.GetFromPlayerPrefs("LocalAssetsVersion")
	hotFixVersion = hotFixVersion ~= "" and hotFixVersion or 1
	local buildTime = CC.ResCommitTime
	log(
		string.format("bigVersion = %s ,hotFixVersion = %s ,buildTime = %s", bigVersion, hotFixVersion, buildTime.CommitTime)
	)
end

function SetUpSoundView:InitTextByLaguage()
	local language = CC.LanguageManager.GetLanguage("L_SetUpView")

	local title = self:FindChild("Frame/Top/Title")
	title.text = language.soundTitle
	if CC.ViewManager.IsHallScene() then
		title.text = language.setTitle
	end

	local soundDes = self:FindChild("Frame/GrayLayer/Sound/Title")
	soundDes.text = language.soundDes
	local effectDes = self:FindChild("Frame/GrayLayer/Effect/Title")
	effectDes.text = language.effectDes
	local logout = self:FindChild("Frame/BtnLogout/Text")
	logout.text = language.titleName7
	local frame_Label = self:FindChild("Frame/GrayLayer/Frames/Label")
	frame_Label.text = language.frame
	local frame_High = self:FindChild("Frame/GrayLayer/Frames/High/Label")
	frame_High.text = language.highFrame
	local frame_Low = self:FindChild("Frame/GrayLayer/Frames/Low/Label")
	frame_Low.text = language.lowFrame
end

function SetUpSoundView:CreateSliderItem(itemName)
	local item = {}

	item.transform = self:FindChild("Frame/GrayLayer/" .. itemName .. "/Slider")
	item.component = item.transform:GetComponent("Slider")

	local iconOn = self:FindChild("Frame/GrayLayer/" .. itemName .. "/IconOn")
	local iconOff = self:FindChild("Frame/GrayLayer/" .. itemName .. "/IconOff")

	local setIconOff = function(flag)
		iconOn:SetActive(not flag)
		iconOff:SetActive(flag)
	end
	item.onSetStateByValue = function(value)
		setIconOff(value == 0)
	end

	return item
end

function SetUpSoundView:OnClickClose()
	CC.Sound.Save()
	self:ActionOut()
end

function SetUpSoundView:OnClickLogout()
	CC.ReportManager.SetDot("CLICKLOGOUT")
	local loginDefine = CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine")
	if CC.Player.Inst().GetCurLoginWay() == loginDefine.LoginWay.Facebook then
		CC.FacebookPlugin.Logout()
	elseif CC.Player.Inst().GetCurLoginWay() == loginDefine.LoginWay.Line then
		CC.LinePlugin.Logout()
	end
	CC.Player.Inst().SetCurLoginWay()
	CC.ViewManager.BackToLogin(loginDefine.LoginType.Logout)
end

function SetUpSoundView:OnDestroy(...)
	self.soundSlider = nil
	self.effectlider = nil
end

return SetUpSoundView
