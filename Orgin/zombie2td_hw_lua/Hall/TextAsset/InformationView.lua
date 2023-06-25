-- region InformationView.lua
-- Date: 2019.7.17
-- Desc: 玩家信息
-- Author: chris
local CC = require("CC")
local InformationView = CC.uu.ClassView("InformationView")


--公告
function InformationView:ctor(param)
	self.IdendityInfo = param.IdendityInfo--是否需要填写身份证
	self.PersonInfo = param.PersonInfo --是否需要填写个人信息
	self.Desc = param.Desc or "" --描述，例：300点卡
	self.EmailId = param.EmailId or "" -- 邮件id
	self.Icon = param.Icon --物品的名字
	self.Type = param.Type
	self.ActiveName = param.ActiveName or ""
	self.callback = param.callback  --回调
	self.successCallback = param.successCallback  --回调
	self.commitCallback = param.commitCallback  --回调
	self.Canclose = param.Canclose
	self.language = self:GetLanguage()
end

function InformationView:OnCreate()
	self.viewCtr = self:CreateViewCtr()
	self.viewCtr:OnCreate()
	self:Init()
	self:setLanguageByText()
	self:AddClickEvent()
end


function InformationView:Init()
	-- logError("InformationView init")
	self.Layer_Mask = self:FindChild("Layer_Mask")

	self.InformationPanel = self:FindChild("Layer_UI/InformationPanel")
	self.BtnClose = self.InformationPanel:FindChild("BtnClose")
	self.ContentGroup = self.InformationPanel:FindChild("ContentGroup")
	self.BtnCanmera = self.ContentGroup:FindChild("BtnCanmera")
	self.BtnCanmeraClose =self.BtnCanmera:FindChild("BtnClose")
	self.BtnMemorandum = self.ContentGroup:FindChild("BtnMemorandum")
	self.BtnSubmit = self.InformationPanel:FindChild("BtnSubmit")
	self.Input_Information = self:FindChild("Layer_UI/Input_Information")
	self.Input_InformationClose = self.Input_Information:FindChild("bg")
	self.NameInput = self.Input_Information:FindChild("NameObj/NameInput")
	self.PhoneInput = self.Input_Information:FindChild("PhoneObj/PhoneInput")
	self.AddressInput = self.Input_Information:FindChild("AddressObj/AddressInput")
	self.EmailInput = self.Input_Information:FindChild("EmailObj/EmailInput")

	self.NameText = self.Input_Information:FindChild("NameObj/Text")
	self.PhoneText = self.Input_Information:FindChild("PhoneObj/Text")
	self.AddressText = self.Input_Information:FindChild("AddressObj/Text")
	self.EmailText = self.Input_Information:FindChild("EmailObj/Text")

	self.BtnOK = self.Input_Information:FindChild("BtnOK")
	self.InformationData = self.BtnMemorandum:FindChild("InformationData")
	self.DataName = self.InformationData:FindChild("Name")
	self.DataPhone = self.InformationData:FindChild("Phone")
	self.DataEmail = self.InformationData:FindChild("Email")
	self.DataAddress = self.InformationData:FindChild("Scroll View/Viewport/Content/Address")

	self.DataNameText = self.InformationData:FindChild("NameText")
	self.DataPhoneText = self.InformationData:FindChild("PhoneText")
	self.DataEmailText = self.InformationData:FindChild("EmailText")
	self.DataAddressText = self.InformationData:FindChild("AddressText")

	self.InformationDataClose = self.InformationData:FindChild("BtnClose")
	self.ConfigImg = self.InformationPanel:FindChild("ConfigImg")
	self.TopText = self.InformationPanel:FindChild("Top/TopText")
	self.ContentText = self.InformationPanel:FindChild("ContentText")
	self.ContentText1 = self.InformationPanel:FindChild("ContentText1")
	self.toptext2 = self.InformationPanel:FindChild("toptext")
	self:InformationViewInit()

	self.viewCtr:GetLogisticsData()
	self:CanCloseView()
end

function  InformationView:CanCloseView()
	log("self.Canclose = "..tostring(self.Canclose))
	self.BtnClose:SetActive(self.Canclose)
end

--初始化信息界面
function InformationView:InformationViewInit()
	self.BtnCanmera:SetActive(self.IdendityInfo)
	self.BtnMemorandum:SetActive(self.PersonInfo)
	UIEvent.BtnInteractable(self.BtnCanmera,true)
 	if self.IdendityInfo == false and self.PersonInfo == false then	 --不能输入身份证和 个人信息
 		self.BtnCanmera:SetActive(true)
 		self.BtnMemorandum:SetActive(false)
		UIEvent.BtnInteractable(self.BtnCanmera,false)
	end 
	if self.Icon then
		self:SetImage(self.ConfigImg,self.Icon)
		self.ConfigImg:GetComponent("Image"):SetNativeSize()
	end
end

function InformationView:setLanguageByText()
	self.TopText:GetComponent("Text").text = self.language.TopText
	if self.Type == 9 then --判断是实物还是点卡
		self.ContentText:GetComponent("Text").text = self.language.TickerTip
	elseif self.Type == 10 then
		self.ContentText:GetComponent("Text").text = self.language.TealTip
	end
	self.ContentText1:GetComponent("Text").text = self.language.IDupText
	self.toptext2:GetComponent("Text").text = self.language.DearPer
	-- self.BtnCanmera:FindChild("Text"):GetComponent("Text").text = self.language.IDupText
	-- self.BtnCanmera:FindChild("Dayu"):GetComponent("Text").text = self.language.Dayu
	-- logError("self.language.Dayu = "..self.language.Dayu)
	self.BtnMemorandum:FindChild("Text"):GetComponent("Text").text = self.language.PersonInfoText
	self.BtnSubmit:FindChild("Text"):GetComponent("Text").text = self.language.SubMit
	self.NameText:GetComponent("Text").text = self.language.NameText
	self.PhoneText:GetComponent("Text").text = self.language.PhoneText
	self.AddressText:GetComponent("Text").text = self.language.AddressText
	self.EmailText:GetComponent("Text").text = self.language.EmailText
	self.DataNameText:GetComponent("Text").text = self.language.NameText
	self.DataPhoneText:GetComponent("Text").text = self.language.PhoneText
	self.DataAddressText:GetComponent("Text").text = self.language.AddressText
	self.DataEmailText:GetComponent("Text").text = self.language.EmailText
	self:FindChild("Layer_UI/Input_Information/BtnOK/Text").text = self.language.SubMit
end

function InformationView:AddClickEvent()
	self:AddClick(self.BtnClose,"Close")
	self:AddClick(self.BtnCanmera,"CanmeraFunc")
	self:AddClick(self.BtnMemorandum,"MemorandumFunc")
	self:AddClick(self.Input_InformationClose,"MemorandumCloseFunc")
	self:AddClick(self.BtnSubmit,"SubmitFunc")
	self:AddClick(self.BtnOK,"DataFunc")
	self:AddClick(self.InformationDataClose,"InformationDataCloseFunc")
end

function InformationView:InformationDataCloseFunc()	
	self.InformationData:SetActive(false)
	self.DataName:GetComponent("Text").text = ""
	self.DataPhone:GetComponent("Text").text = ""
	self.DataAddress:GetComponent("Text").text = ""
	self.DataEmail:GetComponent("Text").text = ""
end

--刷新个人信息界面
function InformationView:RefreshInformation()
	if self.viewCtr.UserName ~= "" or self.viewCtr.PhoneNum ~= "" or self.viewCtr.StrAddress ~= "" or self.viewCtr.MailAddress ~= "" then
		self.InformationData:SetActive(true)
		self.DataName:GetComponent("Text").text = self.viewCtr.UserName
		self.DataPhone:GetComponent("Text").text = self.viewCtr.PhoneNum
		self.DataAddress:GetComponent("Text").text = self.viewCtr.StrAddress
		self.DataEmail:GetComponent("Text").text = self.viewCtr.MailAddress
	else
		self.viewCtr:VerificationData()
	end	
end

function InformationView:DataFunc()
	self.viewCtr:SetInformationData()
	self.Input_Information:SetActive(false)
	self:RefreshInformation() --刷新个人信息界面

end

function InformationView:CanmeraFunc()
	Client.OpenPhotoAlbum()
end

function InformationView:MemorandumFunc()
	self.Input_Information:SetActive(true)
end

function InformationView:MemorandumCloseFunc()
	self.Input_Information:SetActive(false)
end

function InformationView:SubmitFunc()
	self:SetCanClick(false)
	local tipse = CC.ViewManager.ShowMessageBox(self.language.Tip2,
		function ()
			if self.IdendityInfo == true then
				if self.viewCtr:EncodeJPG() == "" then
					self:SetCanClick(true)
					return
				end
			end
			if self.PersonInfo == true then
				if self.viewCtr:VerificationData() == "" then 
					self:SetCanClick(true)
					return 
				end
			end

			if self.callback then
				self.callback()
			else
				self.viewCtr:OnClickSubmit()
			end			
		end,
		function ()
			self:SetCanClick(true)
		end
	)
end

--关闭
function InformationView:Close()
	self:Destroy()
end


function InformationView:OnDestroy()
	self.viewCtr:OnDestroy()
end

return InformationView