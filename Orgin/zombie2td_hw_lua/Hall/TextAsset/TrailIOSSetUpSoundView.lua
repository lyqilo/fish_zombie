
local CC = require("CC")

local TrailIOSSetUpSoundView = CC.uu.ClassView("TrailIOSSetUpSoundView")

function TrailIOSSetUpSoundView:OnCreate()

	self:InitContent();
	
	self:InitTextByLaguage();
end

function TrailIOSSetUpSoundView:InitContent()

	if CC.LocalGameData.GetFrames() > 30 then
		self:FindChild("Frame/GrayLayer/Frames/High"):GetComponent("Toggle").isOn = true
	else
		self:FindChild("Frame/GrayLayer/Frames/Low"):GetComponent("Toggle").isOn = true
	end

	self.soundSlider = self:CreateSliderItem("Sound");
	self.soundSlider.component.value = CC.Sound.GetMusicVolume();
	self.soundSlider.onSetStateByValue(self.soundSlider.component.value);
	UIEvent.AddSliderOnValueChange(self.soundSlider.transform, function(value)
			self.soundSlider.onSetStateByValue(value);
			CC.Sound.SetMusicVolume(value);
		end)

	self.effectlider = self:CreateSliderItem("Effect");
	self.effectlider.component.value = CC.Sound.GetEffectVolume();
	self.effectlider.onSetStateByValue(self.effectlider.component.value);
	UIEvent.AddSliderOnValueChange(self.effectlider.transform, function(value)
			self.effectlider.onSetStateByValue(value);
			CC.Sound.SetEffectVolume(value);
		end)

	if not CC.ViewManager.IsHallScene() then
		self:FindChild("Frame/BtnLogout"):SetActive(false);
	end
	
	self:AddClick("Frame/BtnClose", "OnClickClose");

	self:AddClick("Frame/BtnLogout", "OnClickLogout");
	self:AddClick("Frame/BtnRemove", "OnClickRemove");

	self:FindChild("Frame/GrayLayer/Frames/High").onClick = function()
		self:FindChild("Frame/GrayLayer/Frames/High"):GetComponent("Toggle").isOn = true
		CC.LocalGameData.ChangeFrames(true)
	end

	self:FindChild("Frame/GrayLayer/Frames/Low").onClick = function()
		self:FindChild("Frame/GrayLayer/Frames/Low"):GetComponent("Toggle").isOn = true
		CC.LocalGameData.ChangeFrames(false)
	end
	
	self:FindChild("Frame/BtnSafe"):SetActive(CC.Player.Inst():GetSafeCodeData().SafeStatus == 1)
	self:AddClick("Frame/BtnSafe", function()
		self:Destroy()
		CC.ViewManager.Open("SafePassWordExplainView");
	 end);

	 self:AddClick("Frame/Text/Button",function ()
		Util.CopyToClipboard(CC.Player.Inst():GetSelfInfoByKey("Id") or "")
		CC.ViewManager.ShowTip("คัดลอกสำเร็จ")
	 end)
	 
end

function TrailIOSSetUpSoundView:InitTextByLaguage()

	local language = CC.LanguageManager.GetLanguage("L_SetUpView");

	local title = self:FindChild("Frame/Top/Title");
	title.text = language.soundTitle;
	if CC.ViewManager.IsHallScene() then
		title.text = language.setTitle;
	end
	
	local soundDes = self:FindChild("Frame/GrayLayer/Sound/Title");
	soundDes.text = language.soundDes;
	local effectDes = self:FindChild("Frame/GrayLayer/Effect/Title");
	effectDes.text = language.effectDes;
	local logout = self:FindChild("Frame/BtnLogout/Text");
	logout.text = language.titleName7;
	local frame_Label = self:FindChild("Frame/GrayLayer/Frames/Label")
	frame_Label.text = language.frame
	local frame_High = self:FindChild("Frame/GrayLayer/Frames/High/Label")
	frame_High.text = language.highFrame
	local frame_Low = self:FindChild("Frame/GrayLayer/Frames/Low/Label")
	frame_Low.text = language.lowFrame
	self:FindChild("Frame/Text").text = "ID : "..CC.Player.Inst():GetSelfInfoByKey("Id")
	self:FindChild("Frame/Text/Button/Text").text = "สำเนา"
	self:FindChild("Frame/BtnRemove/Text").text = "ลบบัญชี"
end

function TrailIOSSetUpSoundView:CreateSliderItem(itemName)

	local item = {};

	item.transform = self:FindChild("Frame/GrayLayer/"..itemName.."/Slider");
	item.component = item.transform:GetComponent("Slider");

	local iconOn = self:FindChild("Frame/GrayLayer/"..itemName.."/IconOn");
	local iconOff = self:FindChild("Frame/GrayLayer/"..itemName.."/IconOff");

	local setIconOff = function(flag)
		iconOn:SetActive(not flag);
		iconOff:SetActive(flag);
	end
	item.onSetStateByValue = function(value)
		setIconOff(value==0);
	end

	return item;
end

function TrailIOSSetUpSoundView:OnClickClose()
	CC.Sound.Save();
	self:ActionOut();
end

function TrailIOSSetUpSoundView:OnClickLogout()
	CC.ReportManager.SetDot("CLICKLOGOUT")
	local loginDefine = CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine");
	if CC.Player.Inst().GetCurLoginWay() == loginDefine.LoginWay.Facebook then
		CC.FacebookPlugin.Logout();
	elseif CC.Player.Inst().GetCurLoginWay() == loginDefine.LoginWay.Line then
		CC.LinePlugin.Logout();
	end
	CC.Player.Inst().SetCurLoginWay();
	CC.ViewManager.BackToLogin(loginDefine.LoginType.Logout);
end

function TrailIOSSetUpSoundView:OnClickRemove()
	CC.ViewManager.ShowMessageBox("หลังลบบัญชีแล้ว ข้อมูลเกมทั้งหมดของบัญชีดังกล่าวจะถูกลบไป\nยืนยันต้องการลบบัญชีหรือไม่?",
	function ()
		local appleResult = {};
		-- local bid = CC.LocalGameData.GetLocalStateToKey("AppleLoginBid")
		-- appleResult.UserIdentifier = bid;
		appleResult.Imei = CC.Platform.GetDeviceId()
		appleResult.OS = CC.Platform.GetOSEnum()
		appleResult.GuestUsr = CC.Platform.GetDeviceId()
		appleResult.GuestPwd = CC.Platform.GetDeviceId()

		CC.Request("ResetLogout",appleResult,function(err,result)
				-- CC.uu.Log(err,"Request.ResetLogout success err:")
				-- CC.uu.Log(result,"Request.ResetLogout success result:")
				CC.ReportManager.SetDot("CLICKLOGOUT")
				local loginDefine = CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine");
				if CC.Player.Inst().GetCurLoginWay() == loginDefine.LoginWay.Facebook then
					CC.FacebookPlugin.Logout();
				elseif CC.Player.Inst().GetCurLoginWay() == loginDefine.LoginWay.Line then
					CC.LinePlugin.Logout();
				elseif CC.Player.Inst().GetCurLoginWay() == loginDefine.LoginWay.Apple then
					CC.ApplePayPlugin.ClearToken()
				end
				CC.ViewManager.BackToLogin(loginDefine.LoginType.Logout);
				-- CC.ApplePayPlugin.ClearToken()
				CC.Player.Inst():SetCurLoginWay(nil);
			end,
			function(err)
				CC.uu.Log("Request.ResetLogout fail")
			end)
	end,
	function ()
		log("ResetLogout cannel")
	end)
end

function TrailIOSSetUpSoundView:OnDestroy( ... )
	self.soundSlider = nil
	self.effectlider = nil
end

return TrailIOSSetUpSoundView;