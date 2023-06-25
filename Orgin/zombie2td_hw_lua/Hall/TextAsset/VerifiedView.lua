local CC = require("CC")
local VerifiedView = CC.uu.ClassView("VerifiedView")

function VerifiedView:ctor(param)
    self.param = param

	self.imageBytes = nil;

	self.cacheList = {};

	self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView")
end

function VerifiedView:OnCreate()

    self:RegisterEvent()
    self:InitUI()
    self:InitTextByLanguage()
    self:AddClickEvent()
end

function VerifiedView:InitUI()

	self.photoNode = self:FindChild("Bg/Content/HorizontalLayout/Img/Photo");
end

function VerifiedView:InitTextByLanguage()

	self:FindChild("Bg/Title/Text").text = self.language.verifiedTitle;
	self:FindChild("Bg/Tips").text = self.language.verifiedTip3;
	self:FindChild("Bg/Content/HorizontalLayout/Example/Title").text = self.language.example;
	self:FindChild("Bg/Content/HorizontalLayout/Example/Text1").text = self.language.verifiedTip1;
	self:FindChild("Bg/Content/HorizontalLayout/Example/Text2").text = self.language.verifiedTip2;
	self:FindChild("Bg/Content/HorizontalLayout/BtnSubmit/Text").text = self.language.verifiedBtn;
end

function VerifiedView:AddClickEvent()

	self:AddClick("Bg/BtnClose", "ActionOut");
	self:AddClick("Bg/Content/HorizontalLayout/Img", "OpenPhoto");
	self:AddClick("Bg/Content/HorizontalLayout/BtnSubmit", "OnClickSubmit");
end

function VerifiedView:OpenPhoto()

	Client.OpenPhotoAlbum();
end

function VerifiedView:OnClickSubmit()
	if not self.imageBytes then return end
	self:OnSubmitData(self.imageBytes)
end

function VerifiedView:OnPickPhotoBack(imagePath)
	log("OnPickPhotoBack")
	--根据文件名判断是否为jpg图片
	if string.sub(imagePath,-4) ~= ".jpg" then
		return
	end
	--读取系统相册图片
	local url = "file://"..imagePath 
	CC.HttpMgr.GetTexture(url, function(www)
			if www.downloadHandler.texture then
				local texture = www.downloadHandler.texture 
				self.imageBytes = UnityEngine.ImageConversion.EncodeToJPG(texture, 32)
				local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5))
				local btnImage = self.photoNode:GetComponent("Image") 
				btnImage.sprite = sprite 
				table.insert(self.cacheList, sprite) 
				self:ShowPhoto()
			end
		end, function()
			logError("not get the image from phone") 
		end) 
end

function VerifiedView:OnPickPhotoBytesBack(imageBytes)
	if not imageBytes then return end
	log("OnPickPhotoBytesBack")
	self.imageBytes = imageBytes;
	local btnImage = self.photoNode:GetComponent("Image") 
	local texture = Texture2D(btnImage.mainTexture.width, btnImage.mainTexture.height, UnityEngine.TextureFormat.RGBA32, false) 
	UnityEngine.ImageConversion.LoadImage(texture, imageBytes) 
	local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5)) 
	btnImage.sprite = sprite 
	table.insert(self.cacheList, sprite) 
	self:ShowPhoto()
end

function VerifiedView:OnPickIOSPhotoBack(imageBytes, imageType)
	if not imageBytes then return end
	log("IOSPhotoType:"..(imageType == 0 and "jpg" or "others"))
	self.imageBytes = imageBytes;
	local btnImage = self.photoNode:GetComponent("Image") 
	local texture = Texture2D(btnImage.mainTexture.width, btnImage.mainTexture.height, UnityEngine.TextureFormat.RGBA32, false) 
	UnityEngine.ImageConversion.LoadImage(texture, imageBytes) 
	local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5)) 
	btnImage.sprite = sprite 
	table.insert(self.cacheList, sprite) 
	self:ShowPhoto()
end

function VerifiedView:ShowPhoto()
	local parent = self.photoNode.parent
	self.photoNode:GetComponent("Image"):SetNativeSize()
	local scale = math.min(parent.width/self.photoNode.width,parent.height/self.photoNode.height)
	self.photoNode.localScale = Vector3(scale,scale,1)
	self.photoNode:SetActive(true)
end

function VerifiedView:OnSubmitData(Bytes)

	local playerID = CC.Player.Inst():GetSelfInfoByKey("Id")
	local BirthDate = CC.Player.Inst():GetSelfInfoByKey("Birth")
	local ts = os.time()
	local sign = Util.Md5(playerID..BirthDate..ts..CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebKey())

	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetRealNameBrithDayUrl()
	local wwwForm = UnityEngine.WWWForm.New()
	wwwForm:AddField("PlayerId", playerID)
	wwwForm:AddField("BirthDate", BirthDate)
	wwwForm:AddField("ts", ts)
	wwwForm:AddField("sign", sign)
	wwwForm:AddBinaryData("IDImg", Bytes, "jpg")

	--log("Submit Identity Verification:"..url)
	CC.ViewManager.ShowConnecting()
	CC.HttpMgr.PostForm(url,wwwForm,
		function(www)
			CC.ViewManager.CloseConnecting()
			--log("Submit success:\n"..tostring(www.downloadHandler.text))
			local jsonData = Json.decode(www.downloadHandler.text)
			CC.uu.Log(jsonData,"Identity Verification",1)
			if jsonData.code == 0 then
				CC.ViewManager.ShowConfirmBox(CC.LanguageManager.GetLanguage("L_IdentityVerificationView").reviewTips,function ()
					self:Destroy();
					CC.HallNotificationCenter.inst():post(CC.Notifications.OnBirthUploadImage, 1)
				end)
			else
				CC.ViewManager.ShowTip(CC.LanguageManager.GetLanguage("L_Common").tip9)
				CC.HallNotificationCenter.inst():post(CC.Notifications.OnBirthUploadImage, 2)
			end
		end,
		function(error)
			CC.ViewManager.CloseConnecting()
			CC.ViewManager.ShowTip(CC.LanguageManager.GetLanguage("L_Common").tip9)
			self.view:ShowBrithRealUI(2)
			logError("Submit Identity Verification failed:"..tostring(error))
		end,nil,10)
end


function VerifiedView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnPickPhotoBack, CC.Notifications.OnPickPhotoBack)
	CC.HallNotificationCenter.inst():register(self, self.OnPickPhotoBytesBack, CC.Notifications.OnPickPhotoBytesBack)
	CC.HallNotificationCenter.inst():register(self, self.OnPickIOSPhotoBack, CC.Notifications.OnPickIOSPhotoBack)
end

function VerifiedView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function VerifiedView:OnDestroy()
    self:UnRegisterEvent()

	self.imageBytes = nil
	for _,v in ipairs(self.cacheList) do
		GameObject.Destroy(v) 
	end
end

return VerifiedView
