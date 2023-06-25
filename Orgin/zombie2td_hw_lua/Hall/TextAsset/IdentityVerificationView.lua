local CC = require("CC")
local IdentityVerificationView = CC.uu.ClassView("IdentityVerificationView")

--认证输入类型
local INPUT_TYPE = {
	PHONE = 1,
	BANK = 2,
	DROPDOWN = 3
}

--下拉选项
local dropDownList = {
	[1] = {option = "", img = "smrz_icon04", inputLimit = 13},--身份证
	[2] = {option = "", img = "smrz_icon05", inputLimit = 10},--手机
}

--[[
param:
BankChannelID:银行渠道id
StatesList:实名验证渠道状态列表
]]
function IdentityVerificationView:ctor(param)
	self:InitVar(param)
end

function IdentityVerificationView:InitVar(param)
	self.param = param or {}
    self.language = self:GetLanguage()
	self.phoneNum = ""
	self.bankCard = ""
	self.idCardNum = ""
	self.selectInputStr = ""
	self.statusItemList = {}
	self.hideImg = false
	self.downloadImg = false
	self.reUpload = false
	self.selectChannelId = self.param.BankChannelID
	self.realAuthCfg = self:InitConfig()
end

function IdentityVerificationView:OnCreate()
    self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()

    self:InitContent()
	self:InitTextByLanguage()
	self:RefreshStatusList(self.param.StatesList)
end

function IdentityVerificationView:InitConfig()
	local cfg = {}
	local webCfg = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetRealAuthCfg()
	for _,v in pairs(webCfg) do
		cfg[v.BankEnum] = v
	end
	return cfg
end

function IdentityVerificationView:InitContent()
	
	self.submitPage = self:FindChild("SubmitPage")
	self.nextBtn = self:FindChild("SubmitPage/Picture1/NextBtn")
	self.submitBtn = self:FindChild("SubmitPage/Content/SubmitBtn")
	self.phoneNumInput = self:FindChild("SubmitPage/Content/PhoneNumInput")
	self.bankCardInput = self:FindChild("SubmitPage/Content/BankCardInput")
	self.selectInput = self:FindChild("SubmitPage/Content/SelectInput/InputField")
	self.selectInputField = self:FindChild("SubmitPage/Content/SelectInput/InputField"):GetComponent("InputField")
	self.phoneNumTips = self:FindChild("SubmitPage/Content/PhoneNumInput/Tips")
	self.bankCardTips = self:FindChild("SubmitPage/Content/BankCardInput/Tips")
	self.selectInputTips = self:FindChild("SubmitPage/Content/SelectInput/Tips")
	self.dropDownComp = self:FindChild("SubmitPage/Content/SelectInput/Dropdown"):GetComponent("Dropdown")
	
	self.statusPage = self:FindChild("StatusPage")
	self.statusItem = self:FindChild("StatusPage/Content/Item")
	self.statusList = self:FindChild("StatusPage/Content/Scroll View/Viewport/Content")
	
	self.imgGroup = {}
	self.imgGroup[1] = self:FindChild("SubmitPage/Picture1")
	self.imgGroup[2] = self:FindChild("SubmitPage/Content/Picture2")
	for i=1,2 do
		local btn = self.imgGroup[i]:FindChild("Img")
		self:AddClick(btn,function ()
				self:OnClickUploadBtn(i)
			end)
	end
	
	self:AddClick(self.nextBtn,"OnClickNextBtn")
	self:AddClick(self.submitBtn,"OnClickSubmitBtn")
	self:AddClick("CloseBtn","ActionOut")
	self:AddClick(self.phoneNumTips,function ()
		local bubble = self.phoneNumTips:FindChild("Bubble")
		bubble:SetActive(not bubble.activeSelf)
	end)
	self:AddClick(self.bankCardTips,function ()
		local bubble = self.bankCardTips:FindChild("Bubble")
		bubble:SetActive(not bubble.activeSelf)
	end)
	
	UIEvent.AddInputFieldOnValueChange(self.phoneNumInput, function(value)
		self.phoneNum = value;
	end)
	UIEvent.AddInputFieldOnValueChange(self.bankCardInput, function(value)
		self.bankCard = value;
	end)
	UIEvent.AddInputFieldOnValueChange(self.selectInput, function(value)
			self:OnSelectInputChange(value)
		end)
	
end

function IdentityVerificationView:InitTextByLanguage()
	self:FindChild("Bg/Title/Text").text = self.language.title
	self:FindChild("SubmitPage/Tips1").text = self.language.tips1
	self:FindChild("SubmitPage/Content/Tips3/Text").text = self.language.tips3
	
	self:FindChild("SubmitPage/Picture1/Example/Title").text = self.language.example
	self:FindChild("SubmitPage/Picture1/Example/Text1").text = self.language.pic1Text1
	self:FindChild("SubmitPage/Picture1/Example/Text2").text = self.language.pic1Text2
	self:FindChild("SubmitPage/Picture1/Img/Title").text = self.language.pic1
	self:FindChild("SubmitPage/Content/Picture2/Example/Title").text = self.language.example
	self:FindChild("SubmitPage/Content/Picture2/Example/Text1").text = self.language.pic2Text1
	self:FindChild("SubmitPage/Content/Picture2/Img/Title").text = self.language.pic2
	
	self:FindChild("StatusPage/Tips").text = self.language.tips1
	self:FindChild("StatusPage/Content/Text").text = string.format(self.language.selectTips,self.language.first)
	self.statusItem:FindChild("Yes").text = self.language.statusYes
	self.statusItem:FindChild("No").text = self.language.statusNo
	self.statusItem:FindChild("Check").text = self.language.statusCheck
	
	self.nextBtn:FindChild("Text").text = self.language.btnNext
	self.submitBtn:FindChild("Text").text = self.language.btnSubmit
	self.phoneNumInput:FindChild("Placeholder").text = self.language.inputPhoneNum
	self.bankCardInput:FindChild("Placeholder").text = self.language.inputBankCard
	self.selectInput:FindChild("Placeholder").text = self.language.inputPhoneNum
	self.phoneNumTips:FindChild("Bubble/Text").text = self.language.phoneNumErr
	self.bankCardTips:FindChild("Bubble/Text").text = self.language.bankCardErr
	self.selectInputTips:FindChild("Bubble/Text").text = self.language.idCardErr
end

function IdentityVerificationView:RefreshStatusList(data)
	
	for k,v in pairs(self.realAuthCfg) do
		local status = data[k] or false
		self.hideImg = self.hideImg or status == CC.shared_enums_pb.RAE_AuthSuc
		self.downloadImg = self.downloadImg or status == CC.shared_enums_pb.RAE_AuthFail
		if v.AmountLimit < 999999 then
			local item
			if self.statusItemList[k] then
				item = self.statusItemList[k]
			else
				item = CC.uu.newObject(self.statusItem,self.statusList)
				self.statusItemList[k] = item
			end
			item:FindChild("Name").text = v.Desc
			item:FindChild("Yes"):SetActive(status == CC.shared_enums_pb.RAE_AuthSuc)
			item:FindChild("No"):SetActive(status ~= CC.shared_enums_pb.RAE_AuthSuc and status ~= CC.shared_enums_pb.RAE_AuthCheck)
			item:FindChild("Check"):SetActive(status == CC.shared_enums_pb.RAE_AuthCheck)
			item:FindChild("Status/Tick"):SetActive(status == CC.shared_enums_pb.RAE_AuthSuc)
			self:AddClick(item,function ()
					self:OnClickChannel(k,status)
				end)
			item:SetActive(true)
		end
	end
end

function IdentityVerificationView:RefreshUI(id)
	local type = self.realAuthCfg[id].InputType
	local nodeList = {}
	self.selectChannelId = id
	self.phoneNumInput:SetActive(type == INPUT_TYPE.PHONE)
	self.bankCardInput:SetActive(type == INPUT_TYPE.BANK)
	self:FindChild("SubmitPage/Content/SelectInput"):SetActive(type == INPUT_TYPE.DROPDOWN)
	if self.hideImg then
		for _,v in ipairs(self.imgGroup) do
			v:SetActive(false)
		end
		self:FindChild("SubmitPage/Content"):SetActive(true)
	else
		for _,v in ipairs(self.imgGroup) do
			table.insert(nodeList,v)
		end
		if self.downloadImg then
			self.viewCtr:ReqImageDownloadUrl()
		end
	end
	
	if type == INPUT_TYPE.PHONE then
		table.insert(nodeList,self.phoneNumInput)
	end
	if type == INPUT_TYPE.BANK then
		table.insert(nodeList,self.bankCardInput)
	end
	if type == INPUT_TYPE.DROPDOWN then
		table.insert(nodeList,self:FindChild("SubmitPage/Content/SelectInput"))
		self:AddDropdown()
	end
	for k,v in ipairs(nodeList) do
		v:FindChild("Title").text = string.format(self.language.inputTitle,k)
	end
	
	self.statusPage:SetActive(false)
	self.submitPage:SetActive(true)
end

function IdentityVerificationView:AddDropdown()
	self.dropDownComp:ClearOptions()
	local OptionData = UnityEngine.UI.Dropdown.OptionData
	for i,v in ipairs(dropDownList) do
		local data = OptionData.New(v.option)
		local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[v.img..".png"];
		data.image = CC.uu.LoadImgSprite(v.img,abName or "image");
		self.dropDownComp.options:Add(data)
	end
	UIEvent.AddDropdownValueChange(
		self.dropDownComp.transform,
		function (value)
			self:OnDropdownValueChange(value)
		end)
	self.curOption = 0
	self.dropDownComp.value = self.curOption
	self.dropDownComp:RefreshShownValue()
end

function IdentityVerificationView:OnDropdownValueChange(value)
	local limit = dropDownList[value+1].inputLimit
	if string.len(self.selectInputStr) > limit then
		self.selectInputStr = string.sub(self.selectInputStr, 1, limit)
		self.selectInputField.text = self.selectInputStr
	end
	self.selectInputTips:SetActive(false)
	if value == 0 then
		self.selectInputTips:FindChild("Bubble/Text").text = self.language.idCardErr
	elseif value == 1 then
		self.selectInputTips:FindChild("Bubble/Text").text = self.language.phoneNumErr
	end
end

function IdentityVerificationView:OnClickChannel(id,status)
	
	if status == CC.shared_enums_pb.RAE_AuthSuc then return end
	
	for k,v in pairs(self.param.StatesList) do
		local checking = v == CC.shared_enums_pb.RAE_AuthCheck
		if checking then
			CC.ViewManager.ShowTip(string.format(self.language.checkingTips,self.realAuthCfg[k].Desc))
			return
		end
	end	
	self:RefreshUI(id)
end

function IdentityVerificationView:OnClickNextBtn()
	if self.viewCtr.upLoadPicture[1] then
		self:FindChild("SubmitPage/Picture1"):SetActive(false)
		self:FindChild("SubmitPage/Content"):SetActive(true)
	else
		CC.ViewManager.ShowTip(self.language.photoErr)
	end
end

function IdentityVerificationView:OnClickUploadBtn(index)
	if self.viewCtr.downloadReq[index] then
		CC.HttpMgr.DisposeByKey(self.viewCtr.downloadReq[index]);
		self.viewCtr.downloadReq[index] = nil;
	end
	self:SetPhotoIndex(index)
	Client.OpenPhotoAlbum();
end

function IdentityVerificationView:SetPhotoIndex(index)
	self.curUpload = index
	self.photoNode = self.imgGroup[index]:FindChild("Img/Photo")
end

--[[
ktb:手机+卡号+身份证照片
promptpay:(身份证or手机)+身份证签名照片+半身身份证合照
]]
function IdentityVerificationView:OnClickSubmitBtn()
	
	if not self:CheckSubmitData() then return end
	
	local param = {}
	param.str = self.language.confirmTips
	param.btnOkText = self.language.btnConfirm
	param.btnNoText = self.language.btnCheck
	param.okFunc = function()
		self.viewCtr:OnSubmitData()
	end
	CC.ViewManager.MessageBoxExtend(param)
end

function IdentityVerificationView:CheckSubmitData()
	local type = self.realAuthCfg[self.selectChannelId].InputType

	if type == INPUT_TYPE.PHONE then
		if string.len(self.phoneNum) < 10 then
			self.phoneNumTips:SetActive(true)
			return false
		else
			self.phoneNumTips:SetActive(false)
		end
	end
	
	if type == INPUT_TYPE.BANK then
		if string.len(self.bankCard) < 10 then
			self.bankCardTips:SetActive(true)
			return false
		else
			self.bankCardTips:SetActive(false)
		end
	end
	
	if type == INPUT_TYPE.DROPDOWN then
		local limit = dropDownList[self.dropDownComp.value+1].inputLimit
		if string.len(self.selectInputStr) < limit then
			self.selectInputTips:SetActive(true)
			return false
		else
			self.selectInputTips:SetActive(false)
			if self.dropDownComp.value == 0 then
				self.idCardNum = self.selectInputStr
				self.phoneNum = ""
			elseif self.dropDownComp.value == 1 then
				self.idCardNum = ""
				self.phoneNum = self.selectInputStr
			end
		end
	end
	
	if not self.hideImg then
		for i=1,2 do
			if not self.viewCtr.upLoadPicture[i] then
				CC.ViewManager.ShowTip(self.language.photoErr)
				return false
			end
		end
	end

	return true
end

function IdentityVerificationView:ShowPhoto()
	local parent = self.photoNode.parent
	self.photoNode:GetComponent("Image"):SetNativeSize()
	local scale = math.min(parent.width/self.photoNode.width,parent.height/self.photoNode.height)
	self.photoNode.localScale = Vector3(scale,scale,1)
	self.photoNode:SetActive(true)
end

function IdentityVerificationView:OnSelectInputChange(str)
	if not str or str == "" then
		self.selectInputStr = ""
		return
	end
	local limit = dropDownList[self.dropDownComp.value+1].inputLimit
	if string.len(str) > limit then
		self.selectInputField.text = self.selectInputStr
	else
		self.selectInputStr = str
	end
end

function IdentityVerificationView:OnDestroy()
	
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end

end

return IdentityVerificationView