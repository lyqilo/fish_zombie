local CC = require("CC")
local IdentityVerificationViewCtr = CC.class2("IdentityVerificationViewCtr")

local responceCode = {
	SUCCESS = 0,
}

function IdentityVerificationViewCtr:ctor(view,param)
	self:InitVar(view,param)
end

function IdentityVerificationViewCtr:InitVar(view,param)
    self.view = view
	self.param = param
	self.cacheList = {}
	self.downloadReq = {}
	self.upLoadPicture = {}
end

function IdentityVerificationViewCtr:RegisterEvent()
	
	CC.HallNotificationCenter.inst():register(self, self.OnPickPhotoBack, CC.Notifications.OnPickPhotoBack)

	CC.HallNotificationCenter.inst():register(self, self.OnPickPhotoBytesBack, CC.Notifications.OnPickPhotoBytesBack)
	
	CC.HallNotificationCenter.inst():register(self, self.OnPickIOSPhotoBack, CC.Notifications.OnPickIOSPhotoBack)
end

function IdentityVerificationViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function IdentityVerificationViewCtr:OnCreate()

	self:RegisterEvent()

end

function IdentityVerificationViewCtr:OnPickPhotoBack(imagePath)
	log("OnPickPhotoBack")
	--根据文件名判断是否为jpg图片
	if string.sub(imagePath,-4) ~= ".jpg" then
		return
	end
	--读取系统相册图片
	local url = "file://"..imagePath 
	CC.HttpMgr.GetTexture(url, function(www)
			if www.downloadHandler.texture then
				--显示在上传按钮上
				local texture = www.downloadHandler.texture 
				local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5))
				local btnImage = self.view.photoNode:GetComponent("Image") 
				btnImage.sprite = sprite 
				self.upLoadPicture[self.view.curUpload] = texture 
				table.insert(self.cacheList, sprite) 
				self.view.reUpload = true
				self.view:ShowPhoto()
			end
		end, function()
			logError("not get the image from phone") 
		end) 
end

function IdentityVerificationViewCtr:OnPickPhotoBytesBack(imageBytes)
	if not imageBytes then return end
	log("OnPickPhotoBytesBack")
	local btnImage = self.view.photoNode:GetComponent("Image") 
	local texture = Texture2D(btnImage.mainTexture.width, btnImage.mainTexture.height, UnityEngine.TextureFormat.RGBA32, false) 
	UnityEngine.ImageConversion.LoadImage(texture, imageBytes) 
	local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5)) 
	btnImage.sprite = sprite 
	self.upLoadPicture[self.view.curUpload] = texture 
	table.insert(self.cacheList, sprite) 
	self.view.reUpload = true
	self.view:ShowPhoto()
end

function IdentityVerificationViewCtr:OnPickIOSPhotoBack(imageBytes, imageType)
	if not imageBytes then return end
	log("IOSPhotoType:"..(imageType == 0 and "jpg" or "others"))
	local btnImage = self.view.photoNode:GetComponent("Image")
	local texture = Texture2D(btnImage.mainTexture.width, btnImage.mainTexture.height, UnityEngine.TextureFormat.RGBA32, false)
	UnityEngine.ImageConversion.LoadImage(texture, imageBytes)
	local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5))
	btnImage.sprite = sprite
	self.upLoadPicture[self.view.curUpload] = texture
	table.insert(self.cacheList, sprite)
	self.view.reUpload = true
	self.view:ShowPhoto()
end

--[[
ktb:手机+卡号+身份证照片
promptpay:(身份证or手机)+身份证签名照片+半身身份证合照
]]
function IdentityVerificationViewCtr:OnSubmitData()

	local channelId = self.view.selectChannelId
	local playerID = CC.Player.Inst():GetSelfInfoByKey("Id")
	local bankCardId = self.view.bankCard
	local phoneNum = self.view.phoneNum
	local idCardNum = self.view.idCardNum
	local isSuccess = self.view.hideImg and 1 or 0--是否有任意通过的渠道
	local ts = os.time()
	local sign = Util.Md5(channelId..playerID..bankCardId..phoneNum..idCardNum..ts..CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebKey())

	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetIdentityVerificationUrl()
	local wwwForm = UnityEngine.WWWForm.New()
	wwwForm:AddField("BankChannelID", channelId)
	wwwForm:AddField("PlayerId", playerID)
	wwwForm:AddField("BankCardId", bankCardId)
	wwwForm:AddField("PhoneNum", phoneNum)
	wwwForm:AddField("IDNumber", idCardNum)
	wwwForm:AddField("IsSuccess", isSuccess)
	wwwForm:AddField("ts", ts)
	wwwForm:AddField("sign", sign)
	
	local addImg = function()
		for _,v in ipairs(self.upLoadPicture) do
			--jpg图片转bytes
			local Bytes = UnityEngine.ImageConversion.EncodeToJPG(v, 32)
			wwwForm:AddBinaryData("IDImg", Bytes, "jpg")
		end
	end
	
	if not self.view.hideImg then
		if self.view.downloadImg then
			if self.view.reUpload then
				addImg()
			end
		else
			addImg()
		end 
	end

	--log("Submit Identity Verification:"..url)
	CC.ViewManager.ShowConnecting()
	CC.HttpMgr.PostForm(url,wwwForm,
		function(www)
			CC.ViewManager.CloseConnecting()
			--log("Submit success:\n"..tostring(www.downloadHandler.text))
			local jsonData = Json.decode(www.downloadHandler.text)
			CC.uu.Log(jsonData,"Identity Verification",1)
			if jsonData.code == responceCode.SUCCESS then
				CC.ViewManager.ShowConfirmBox(self.view.language.reviewTips,function ()
					self.view:Destroy();
				end)
			else
				CC.ViewManager.ShowTip(CC.LanguageManager.GetLanguage("L_Common").tip9)
				self.view:Destroy();
			end
		end,
		function(error)
			CC.ViewManager.CloseConnecting()
			CC.ViewManager.ShowTip(CC.LanguageManager.GetLanguage("L_Common").tip9)
			logError("Submit Identity Verification failed:"..tostring(error))
		end,nil,10)
end

--下载之前上传的图片
function IdentityVerificationViewCtr:ReqImageDownloadUrl()
	
	local playerID = CC.Player.Inst():GetSelfInfoByKey("Id")
	local ts = os.time()
	local sign = Util.Md5(playerID..ts..CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebKey())

	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetRealNameImage()
	local wwwForm = UnityEngine.WWWForm.New()
	wwwForm:AddField("PlayerId", playerID)
	wwwForm:AddField("ts", ts)
	wwwForm:AddField("sign", sign)

	CC.HttpMgr.PostForm(url,wwwForm,
		function(www)
			local jsonData = Json.decode(www.downloadHandler.text)
			CC.uu.Log(jsonData,"Image download url:",1)
			if jsonData.code == 0 then
				local imgUrl = CC.uu.splitString(jsonData.data.ImageUrl,",")
				self.view.reUpload = false
				for i=1,2 do
					if imgUrl[i] and imgUrl[i] ~= "" then
						local url = imgUrl[i]
						self:DownloadImage(url,i)
					end
				end
			else
				logError(string.format("GetRealNameImage err:%s, msg:%s",jsonData.code,jsonData.msg))
			end

		end,
		function(error)
			logError("GetRealNameImage faile:"..tostring(error))
		end,nil,10)
end

function IdentityVerificationViewCtr:DownloadImage(url,index)
	
	self.downloadReq[index] = CC.HttpMgr.GetTexture(url,
		function(www)
			if www.downloadHandler.texture then
				local texture = www.downloadHandler.texture
				local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5))
				self.view:SetPhotoIndex(index)
				local btnImage = self.view.photoNode:GetComponent("Image")
				btnImage.sprite = sprite
				self.upLoadPicture[self.view.curUpload] = texture
				table.insert(self.cacheList, sprite)
				self.view:ShowPhoto()
			end
		end,
		function()
			logError("download image faile")
		end,
		function ()
			self.downloadReq[index] = nil
		end)
end

function IdentityVerificationViewCtr:Destroy()

	self:UnRegisterEvent() 

	for _,v in ipairs(self.downloadReq) do
		if v then
			CC.HttpMgr.DisposeByKey(v);
			v = nil;
		end
	end

	
	for _,v in ipairs(self.cacheList) do
		GameObject.Destroy(v) 
	end

end

return IdentityVerificationViewCtr