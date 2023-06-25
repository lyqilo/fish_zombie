-- region InformationViewCtr.lua
-- Date: 2019.7.13
-- Desc: 信息管理
-- Author: chris
local CC = require("CC")

local InformationViewCtr = CC.class2("InformationViewCtr")

function InformationViewCtr:ctor(view)
	self.InformationDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("InformationData")
	self:InitVar(view)
end

function InformationViewCtr:OnCreate()
	self:RegisterEvent()
end

function InformationViewCtr:OnDestroy()
	self:unRegisterEvent()
	self.view = nil
	--上传的截图
	self.upLoadPicture = nil

	for _,v in ipairs(self.cacheList) do
		GameObject.Destroy(v)
	end
end

function InformationViewCtr:InitVar(view)
	--UI对象
	self.view = view
	--上传的截图
	self.upLoadPicture = nil

	self.cacheList = {}

	self.UserName = ""
	self.PhoneNum = ""
	self.StrAddress = ""
	self.MailAddress = ""

	self.imageBytes = nil
end

--保存输入的个人信息
function InformationViewCtr:SetInformationData()
	self.UserName = self.view.NameInput:GetComponent("InputField").text
	self.PhoneNum = self.view.PhoneInput:GetComponent("InputField").text
	self.StrAddress = self.view.AddressInput:GetComponent("InputField").text
	self.MailAddress = self.view.EmailInput:GetComponent("InputField").text
end

function InformationViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnPickPhotoBack, CC.Notifications.OnPickPhotoBack)
	CC.HallNotificationCenter.inst():register(self, self.OnPickPhotoBytesBack, CC.Notifications.OnPickPhotoBytesBack);
	CC.HallNotificationCenter.inst():register(self, self.OnPickIOSPhotoBack, CC.Notifications.OnPickIOSPhotoBack)
	CC.HallNotificationCenter.inst():register(self,self.BuyPhysicalGoods,CC.Notifications.NW_ReqGoodsBuy)
end

function InformationViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnPickPhotoBack)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnPickPhotoBytesBack);
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnPickIOSPhotoBack)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGoodsBuy)
end

--购买成功
function InformationViewCtr:BuyPhysicalGoods(err,date)
	if err == 0 then
		self:OnClickSubmit()
	else
		self.view:Close()
	end
end


function InformationViewCtr:OnPickPhotoBack(imagePath)

	log("OnPickPhotoBack:"..tostring(imagePath))
	--根据文件名判断是否为jpg图片
	if string.sub(imagePath,-4) ~= ".jpg" then
		CC.ViewManager.ShowTip(self.view.language.serviceTips2)
		return
	end
	--读取系统相册图片
	local url = "file://"..imagePath
	CC.HttpMgr.GetTexture(url, function(www)
			if www.downloadHandler.texture then
				--显示在上传按钮上
				local texture = www.downloadHandler.texture
				local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5))
				self.view.BtnCanmera:FindChild("Image"):SetActive(false)
				self.view.BtnCanmera:FindChild("Text"):SetActive(false)
				local btnImage = self.view.BtnCanmera:FindChild("ImageNode")
				btnImage:SetActive(true)
				btnImage = btnImage:GetComponent("Image")
				btnImage.sprite = sprite
				self.upLoadPicture = texture
				table.insert(self.cacheList, sprite)
			end
		end, function()
			logError("not get the image from phone")
		end);
end

function InformationViewCtr:OnPickPhotoBytesBack(imageBytes)
	if not imageBytes then return end
	--显示在上传按钮上
	self.view.BtnCanmera:FindChild("Image"):SetActive(false)
	self.view.BtnCanmera:FindChild("Text"):SetActive(false)
	local btnImage = self.view.BtnCanmera:FindChild("ImageNode")
	btnImage:SetActive(true)
	btnImage = btnImage:GetComponent("Image")
	local texture = Texture2D(btnImage.mainTexture.width, btnImage.mainTexture.height, UnityEngine.TextureFormat.RGBA32, false)
	UnityEngine.ImageConversion.LoadImage(texture, imageBytes)
	local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5))
	btnImage.sprite = sprite
	self.upLoadPicture = texture
end

--选择ios手机图片
function InformationViewCtr:OnPickIOSPhotoBack(imageBytes, imageType)
	log("IOSPhotoType:"..(imageType == 0 and "jpg" or "others"));
	if imageType ~= 0 then 
		CC.ViewManager.ShowTip(self.view.language.serviceTips2);
		return
	end
	--显示在上传按钮上
	self.view.BtnCanmera:FindChild("Image"):SetActive(false)
	self.view.BtnCanmera:FindChild("Text"):SetActive(false)
	local btnImage = self.view.BtnCanmera:FindChild("ImageNode")
	btnImage:SetActive(true)
	btnImage = btnImage:GetComponent("Image")
	local texture = Texture2D(btnImage.mainTexture.width, btnImage.mainTexture.height, UnityEngine.TextureFormat.RGBA32, false)
	UnityEngine.ImageConversion.LoadImage(texture, imageBytes)
	local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5))
	btnImage.sprite = sprite
	self.upLoadPicture = texture
end

--校验填写的信息
function InformationViewCtr:VerificationData()
	if self.UserName == nil or self.UserName == "" then
		CC.ViewManager.ShowTip(self.view.language.tip3)
		return ""
	end

	if self.PhoneNum == nil or self.PhoneNum == "" then
		CC.ViewManager.ShowTip(self.view.language.tip4)
		return ""
	end

	if self.StrAddress == nil or self.StrAddress == "" then
		CC.ViewManager.ShowTip(self.view.language.tip5)
		return ""
	end

	if self.MailAddress == nil or self.MailAddress == "" then
		CC.ViewManager.ShowTip(self.view.language.tip6)
		return ""
	end
end

--检测图片
function InformationViewCtr:EncodeJPG()
	self.imageBytes = nil
	if self.upLoadPicture then
		--jpg图片转bytes
		self.imageBytes = UnityEngine.ImageConversion.EncodeToJPG(self.upLoadPicture, 32)
		--判断图片内存大小是否超过3M
		if self.imageBytes and self.imageBytes.Length >= 32505856 then
			CC.ViewManager.ShowTip(self.view.language.serviceTips3)
			return ""
		end
	else
		CC.ViewManager.ShowTip(self.view.language.tip7)
		return ""
	end
end

function InformationViewCtr:MakeData()
	local StrPerson = ""
	if self.UserName and self.UserName ~= "" then
		StrPerson = StrPerson..self.view.language.NameText..self.UserName.." ,"
	end
	if self.PhoneNum and self.PhoneNum ~= "" then
		StrPerson = StrPerson..self.view.language.PhoneText..self.PhoneNum.." ,"
	end
	if self.StrAddress and self.StrAddress ~= "" then
		StrPerson = StrPerson..self.view.language.AddressText..self.StrAddress.." ,"
	end
	if self.MailAddress and self.MailAddress ~= "" then
		StrPerson = StrPerson..self.view.language.EmailText..self.MailAddress.." ,"
	end
	StrPerson = WWW.EscapeURL(StrPerson)
	return StrPerson
end

--点击提交
function InformationViewCtr:OnClickSubmit()
	local url = ""
	local wwwForm
	if self.view.IdendityInfo == true  and self.view.PersonInfo == true then  --需要上传身份证和个人信息
		url,wwwForm = self:IDAndPerson(url,wwwForm)
	elseif self.view.IdendityInfo == true  and self.view.PersonInfo == false then --上传身份证，不用上传个人信息
		url,wwwForm = self:IDImgUp(url,wwwForm)
	elseif self.view.IdendityInfo == false  and self.view.PersonInfo == true then --不用上传身份证。需要上传个人信息
		url,wwwForm = self:LogisticsInfoUp(url,wwwForm)
	else  --不用上传身份证，不用上传个人信息
		url,wwwForm = self:NoneInfoUp(url,wwwForm)
	end
	log("-----UpLoadServiceUrl: "..url)
	CC.ViewManager.ShowConnecting()
	CC.HttpMgr.PostForm(url,wwwForm,function(www)
		CC.ViewManager.CloseConnecting()
		CC.ViewManager.ShowTip(self.view.language.serviceTips1)
		self.InformationDataMgr.UpdateLogisticsData({Name=self.UserName,PhoneNum=self.PhoneNum,Address=self.StrAddress,Contact=self.MailAddress})
		if self.view.commitCallback then
			self.view.commitCallback()
		end
		self.view:Close()
		log("upLoad success   "..tostring(www.downloadHandler.text))
	end, function(error)
		logError("upLoad failed   "..tostring(error))
		self.view:SetCanClick(true)
		CC.ViewManager.ShowTip(self.view.language.serviceTips6)
	end)
end

--点击提交
function InformationViewCtr:GetLogisticsData()
	CC.ViewManager.ShowConnecting()
	self.InformationDataMgr.GetLogisticsData(function (data)
		if data then
			self.UserName = data.Name or ""
			self.PhoneNum = data.PhoneNum or ""
			self.StrAddress = data.Address or ""
			self.MailAddress = data.Contact or ""
			self.view:RefreshInformation()
		else
			self.UserName = ""
			self.PhoneNum = ""
			self.StrAddress = ""
			self.MailAddress = ""
		end
		CC.ViewManager.CloseConnecting()
	end)
end

--身份证，个人信息
function InformationViewCtr:IDAndPerson(url,wwwForm)
	self:EncodeJPG()
	local ts = os.time()
	local playerID = CC.Player.Inst():GetSelfInfoByKey("Id")
	local nickName = CC.Player.Inst():GetSelfInfoByKey("Nick")
	local sign = Util.Md5(playerID..ts..CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebKey())
	local StrPerson = self:MakeData()
	url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetRealRewardUrl()
	wwwForm = UnityEngine.WWWForm.New()
	wwwForm:AddField("PlayerID",playerID)
	wwwForm:AddField("ActiveName",self.view.ActiveName)
	wwwForm:AddField("NickName",CC.uu.utf8_to_unicode(nickName))
	wwwForm:AddField("Reward",self.view.Desc)
	wwwForm:AddField("EmailId",self.view.EmailId)
	wwwForm:AddField("LogisticsInfo",StrPerson)
	wwwForm:AddField("ts",ts)
	wwwForm:AddField("sign",sign)
	if self.imageBytes then
		wwwForm:AddBinaryData("picture", self.imageBytes, "jpg")
	end
	return url,wwwForm
end

--身份证
function InformationViewCtr:IDImgUp(url,wwwForm)
	self:EncodeJPG()
	local ts = os.time()
	local playerID = CC.Player.Inst():GetSelfInfoByKey("Id")
	local nickName = CC.Player.Inst():GetSelfInfoByKey("Nick")
	local sign = Util.Md5(playerID..ts..CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebKey())
	--local StrPerson = self:MakeData()
	url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetRealRewardUrl()
	wwwForm = UnityEngine.WWWForm.New()
	wwwForm:AddField("PlayerID",playerID)
	wwwForm:AddField("ActiveName",self.view.ActiveName)
	wwwForm:AddField("NickName",CC.uu.utf8_to_unicode(nickName))
	wwwForm:AddField("Reward",self.view.Desc)
	wwwForm:AddField("EmailId",self.view.EmailId)
	-- wwwForm:AddField("LogisticsInfo",StrPerson)
	wwwForm:AddField("ts",ts)
	wwwForm:AddField("sign",sign)
	if self.imageBytes then
		wwwForm:AddBinaryData("picture", self.imageBytes, "jpg")
	end
	return url,wwwForm
end

--个人信息
function InformationViewCtr:LogisticsInfoUp(url,wwwForm)
	local ts = os.time()
	local playerID = CC.Player.Inst():GetSelfInfoByKey("Id")
	local nickName = CC.Player.Inst():GetSelfInfoByKey("Nick")
	local sign = Util.Md5(playerID..ts..CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebKey())
	local StrPerson = self:MakeData()
	url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetRealRewardUrl()
	wwwForm = UnityEngine.WWWForm.New()
	wwwForm:AddField("PlayerID",playerID)
	wwwForm:AddField("ActiveName",self.view.ActiveName)
	wwwForm:AddField("NickName",CC.uu.utf8_to_unicode(nickName))
	wwwForm:AddField("Reward",self.view.Desc)
	wwwForm:AddField("EmailId",self.view.EmailId)
	wwwForm:AddField("LogisticsInfo",StrPerson)
	wwwForm:AddField("ts",ts)
	wwwForm:AddField("sign",sign)
	return url,wwwForm
end

--不用输入任何信息
function InformationViewCtr:NoneInfoUp(url,wwwForm)
	local ts = os.time()
	local playerID = CC.Player.Inst():GetSelfInfoByKey("Id")
	local nickName = CC.Player.Inst():GetSelfInfoByKey("Nick")
	local sign = Util.Md5(playerID..ts..CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebKey())
	-- local StrPerson = self:MakeData()
	url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetRealRewardUrl()
	wwwForm = UnityEngine.WWWForm.New()
	wwwForm:AddField("PlayerID",playerID)
	wwwForm:AddField("ActiveName",self.view.ActiveName)
	wwwForm:AddField("NickName",CC.uu.utf8_to_unicode(nickName))
	wwwForm:AddField("Reward",self.view.Desc)
	wwwForm:AddField("EmailId",self.view.EmailId)
	wwwForm:AddField("ts",ts)
	wwwForm:AddField("sign",sign)
	return url,wwwForm
end

return InformationViewCtr