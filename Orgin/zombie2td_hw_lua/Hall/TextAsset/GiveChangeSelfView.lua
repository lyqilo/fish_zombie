
local CC = require("CC")

local GiveChangeSelfView = CC.uu.ClassView("GiveChangeSelfView")

function GiveChangeSelfView:ctor(param)
	self.param = param
	self.language = CC.LanguageManager.GetLanguage("L_GiveGiftSearchView");
	self.GiftDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("GiftData")

	self.modData = {}
    self.headIcon = nil;
end

function GiveChangeSelfView:OnCreate()
	self:RegisterEvent()
	self:InitUI()
end

function GiveChangeSelfView:InitUI()

    self:FindChild("Frame/Nick"):GetComponent("Text").text = CC.Player.Inst():GetSelfInfoByKey("Nick")
	self:FindChild("Frame/Id"):GetComponent("Text").text = string.format("ID:%s", CC.Player.Inst():GetSelfInfoByKey("Id"))

	self.phoneInputField = self:SubGet("Frame/PhoneNumberInput","InputField")
	self.addressInput = self:SubGet("Frame/AddressInput","InputField")
	self.fbInput = self:SubGet("Frame/FbInput","InputField")
	self.lineInput = self:SubGet("Frame/LineInput","InputField")
	self.desInput = self:SubGet("Frame/DesInput","InputField")

    self.phonePlaceholder = self:FindChild("Frame/PhoneNumberInput/Placeholder")

    self:AddClick("Frame/BtnClose", "ActionOut")
	self:AddClick("Frame/BtnBind", "ImproveInformation")
	self:HeadItem()
	self:LanguageSwitch()
	self:UpdateInfo(self.GiftDataMgr:GetReInformationSelf())
end

function GiveChangeSelfView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqLoadModifyNewsRsp,CC.Notifications.NW_ReqLoadModifyNews)
end

function GiveChangeSelfView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqLoadModifyNews)
end

function GiveChangeSelfView:LanguageSwitch()
	self:FindChild("Frame/Title/Label"):GetComponent("Text").text = self.language.MyInfo
	self:FindChild("Frame/BtnBind/Text"):GetComponent("Text").text = self.language.Upload
	self.phoneInputField.transform:FindChild("Placeholder"):GetComponent("Text").text = self.language.InputTel
	self.addressInput.transform:FindChild("Des"):GetComponent("Text").text = self.language.AddEng
	self.phoneInputField.transform:FindChild("Des"):GetComponent("Text").text = self.language.TelEng
	self.addressInput.transform:FindChild("Placeholder"):GetComponent("Text").text = self.language.InputAdd
	self.fbInput.transform:FindChild("Placeholder"):GetComponent("Text").text = self.language.InputFB
	self.lineInput.transform:FindChild("Placeholder"):GetComponent("Text").text = self.language.InputLine
	self.desInput.transform:FindChild("Placeholder"):GetComponent("Text").text = self.language.InputDes
end

function GiveChangeSelfView:HeadItem()
    local headNode = self:FindChild("Frame/Head")
	local param = {}
	param.parent = headNode
	param.vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	param.clickFunc = "unClick"
	self:SetHeadIcon(param)
end

-- 核实修改信息 true有修改信息
function GiveChangeSelfView:Verification()
	--和初始数据比较，是否修改
	local data = self.GiftDataMgr:GetReInformationSelf()
	self.modData = {}
	if (data.Telephone and self.phoneInputField.text ~= data.Telephone) or
	(not data.Telephone and self.phoneInputField.text ~= "") then
		if string.len(self.phoneInputField.text) > 0 and string.len(self.phoneInputField.text) < 10 then
			CC.ViewManager.ShowTip(self.language.phoneNumberTip)
			return
		end
		self.modData.Telephone = self.phoneInputField.text
	end
	if (data.Address and self.addressInput.text ~= data.Address) or
	(not data.Address and self.addressInput.text ~= "") then
		self.modData.Address = self.addressInput.text
	end
	if (data.FBAddress and self.fbInput.text ~= data.FBAddress) or
	(not data.FBAddress and self.fbInput.text ~= "") then
		if self.fbInput.text ~= "" and (string.len(self.fbInput.text) < 9 or string.sub(self.fbInput.text,1,8) ~= "https://") then
			CC.ViewManager.ShowTip(self.language.fbTip)
			self.modData = {}
			return
		end
		self.modData.FBAddress = self.fbInput.text
	end
	if (data.LineAddress and self.lineInput.text ~= data.LineAddress) or
	(not data.LineAddress and self.lineInput.text ~= "") then
		if self.lineInput.text ~= "" and (string.len(self.lineInput.text) < 9 or string.sub(self.lineInput.text,1,8) ~= "https://") then
			CC.ViewManager.ShowTip(self.language.lineTip)
			self.modData = {}
			return
		end
		self.modData.LineAddress = self.lineInput.text
	end
	if (data.Content and self.desInput.text ~= data.Content) or
	(not data.Content and self.desInput.text ~= "") then
		self.modData.Content = self.desInput.text
	end
end

--确认修改
function GiveChangeSelfView:ImproveInformation()
	self:Verification()
	if not next(self.modData) then return end
	local tips = CC.ViewManager.ShowMessageBox(self.language.EditSure,
			function ()
				self:EditInfo()
			end,
			function ()
			end)
	tips:SetOkText(self.language.btnOk)
end

-- 修改个人资讯
function GiveChangeSelfView:EditInfo()
	CC.Request("ReqLoadModifyNews",self.modData)
end

function GiveChangeSelfView:ReqLoadModifyNewsRsp(err,result)
	log("err = ".. err.."  "..CC.uu.Dump(result,"ReqLoadModifyNews",10))
	if err == 0 then
		CC.ViewManager.ShowTip(self.language.UploadSucceed)
		self.GiftDataMgr:SetReInformationSelf(result)
		if self.param and self.param.callback then
			self.param.callback()
		end
		self:UpdateInfo(self.GiftDataMgr:GetReInformationSelf())
		self:ActionOut()
	end
end

function GiveChangeSelfView:UpdateInfo(data)
	if not data then return end
	if data.Telephone then
		self.phoneInputField.text = data.Telephone
	end
	if data.Address then
		self.addressInput.text = data.Address
	end
	if data.FBAddress then
		self.fbInput.text = data.FBAddress
	end
	if data.LineAddress then
		self.lineInput.text = data.LineAddress
	end
	if data.Content then
		self.desInput.text = data.Content
	end
end

function GiveChangeSelfView:OnDestroy( ... )
	if self.headIcon then
		self.headIcon:Destroy();
		self.headIcon = nil;
	end
	self:UnRegisterEvent()
end

function  GiveChangeSelfView:SetHeadIcon(param)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
end

return GiveChangeSelfView;