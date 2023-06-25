
local CC = require("CC")

local feedbackType = {
	Login = 1,
	Pay = 2,
	Bug = 3,
	Other = 4
}

local SetUpServiceView = CC.uu.ClassView("SetUpServiceView")

function SetUpServiceView:ctor(param)

	self.param = param or {};
end

function SetUpServiceView:OnCreate()
	--反馈的类型
	self.selectFeedbackType = 0;
	--反馈内容
	self.contentText = "";
	--联系方式
	self.contactText = "";
	--上传的截图
	self.upLoadPicture = nil;

	self.cacheList = {};

	self.language = CC.LanguageManager.GetLanguage("L_SetUpView");

	self:InitTextByLanguage();

	self:InitContent();

	self:RegisterEvent();
end

function SetUpServiceView:InitContent()

	self:InitToggles();

	self:InitInputfield();

	self:AddClick("Frame/ContentBg/BtnUpload", "OnClickUpload");

	self:AddClick("Frame/BtnSubmit", "OnClickSubmit");
	self:AddClick("Frame/BtnVip", "OnClickVipService");

	self:AddClick("Frame/BtnClose", "ActionOut");

	local richText = self:FindChild("Frame/FacebookText"):GetComponent("RichText")
	self:FindChild("Frame/FacebookText"):SetActive(false)
	richText.onLinkClick = function (url)
		self:OnClickUrlText(url);
	end

	if self.param.uploadImageBytes then
		local btnImage = self:FindChild("Frame/ContentBg/BtnUpload"):GetComponent("Image");
		local texture = Texture2D(btnImage.mainTexture.width, btnImage.mainTexture.height, UnityEngine.TextureFormat.RGBA32, false);
		UnityEngine.ImageConversion.LoadImage(texture, self.param.uploadImageBytes);
		local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5));
		btnImage.sprite = sprite;
		self.upLoadPicture = texture;
	end


	-- if self.param.sortingLayer then
	-- 	local canvas = self:GetComponent("Canvas");
	-- 	local compList = {UnityEngine.ParticleSystemRenderer,UnityEngine.Canvas}
	-- 	for _,v in pairs(compList) do
	-- 		local comps = self.transform:GetComponentsInChildren(typeof(v));
	-- 		if comps then
	-- 			for i = 0, comps.Length-1 do
	-- 				comps[i].sortingLayerName = self.param.sortingLayer or comps[i].sortingLayerName;
	-- 			end
	-- 		end
	-- 	end
	-- end
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= 20 and not CC.ChannelMgr.GetTrailStatus() then
		self:FindChild("Frame/BtnVip"):SetActive(true)
	end
end

function SetUpServiceView:InitTextByLanguage()

	local language = self.language;

	local frame = self:FindChild("Frame");
	local title = frame:FindChild("Top/Title");
	title.text = language.serviceTitle;

	for i = 1, 4 do
		local toggle = frame:FindChild("Toggle/Toggle"..i.."/Label");
		toggle.text = language["serviceType"..i];
	end

	local feedbackPlaceholder = frame:FindChild("ContentBg/ServiceInputField/Placeholder");
	feedbackPlaceholder.text = language.feedbackPlaceholder;
	local addressPlaceholder = frame:FindChild("ContactInputField/Placeholder");
	addressPlaceholder.text = language.addressPlaceholder;
	local btnSubmit = frame:FindChild("BtnSubmit/Text");
	btnSubmit.text = language.btnSubmit;
	local btnUploadPicture = frame:FindChild("ContentBg/BtnUpload/Text");
	btnUploadPicture.text = language.btnUploadPicture;
	local facebookText = frame:FindChild("FacebookText"):GetComponent("RichText");
	facebookText.text = string.format(language.facebookText, CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLocalServiceUrl());
	local mailText = frame:FindChild("MailText");
	mailText.text = language.mailText;
end

function SetUpServiceView:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self, self.OnPickPhotoBack, CC.Notifications.OnPickPhotoBack);

	CC.HallNotificationCenter.inst():register(self, self.OnPickPhotoBytesBack, CC.Notifications.OnPickPhotoBytesBack);
	
	CC.HallNotificationCenter.inst():register(self, self.OnPickIOSPhotoBack, CC.Notifications.OnPickIOSPhotoBack);
end

function SetUpServiceView:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnPickPhotoBack);

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnPickPhotoBytesBack);
	
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnPickIOSPhotoBack);
end

function SetUpServiceView:OnDestroy()

	self:UnRegisterEvent();

	for _,v in ipairs(self.cacheList) do
		GameObject.Destroy(v);
	end
end

function SetUpServiceView:InitToggles()

	for _,v in pairs(feedbackType) do
		local toggle = self:FindChild("Frame/Toggle/Toggle"..v);
		UIEvent.AddToggleValueChange(toggle, function(selected)
				if selected then
					self.selectFeedbackType = v;
				end
			end)
	end

	--默认显示bug类型
	self.selectFeedbackType = feedbackType.Bug;
	local toggle = self:FindChild("Frame/Toggle/Toggle"..feedbackType.Bug):GetComponent("Toggle");
	toggle.isOn = true;
end

function SetUpServiceView:InitInputfield()

	local contentInput = self:FindChild("Frame/ContentBg/ServiceInputField");
	UIEvent.AddInputFieldOnEndEdit(contentInput, function(value)
			self.contentText = value;
			CC.DebugDefine.CheckDebugKey(value);
		end)

	local contactInput = self:FindChild("Frame/ContactInputField");
	UIEvent.AddInputFieldOnEndEdit(contactInput, function(value)
			self.contactText = value;
		end)
end

function SetUpServiceView:OnClickSubmit()

	if self.contentText == "" then
		CC.ViewManager.ShowMessageBox(self.language.serviceTips4);
		return;
	end

	if self.contactText == "" then
		CC.ViewManager.ShowMessageBox(self.language.serviceTips5);
		return;
	end

	local curTimeStamp = os.time();
	local deltaTime = curTimeStamp - CC.Player.Inst():GetServiceUpTime();
	if deltaTime >= 120 then
		CC.Player.Inst():SetServiceUpTime(curTimeStamp);
	else
		CC.ViewManager.ShowTip(string.format(self.language.ServiceTips7, (120-deltaTime)));
		return;
	end

	-- self.upLoadPicture = ResourceManager.LoadAsset("image", "mrjl_bg1.jpg");
	local imageBytes;
	if self.upLoadPicture then
		--jpg图片转bytes
		imageBytes = UnityEngine.ImageConversion.EncodeToJPG(self.upLoadPicture, 32);
		--判断图片内存大小是否超过3M
		if imageBytes and imageBytes.Length >= 32505856 then
			CC.ViewManager.ShowTip(self.language.serviceTips3);
			return;
		end
	end
	local ts = os.time();
	local playerID = CC.Player.Inst():GetSelfInfoByKey("Id");
	local nickName = CC.Player.Inst():GetSelfInfoByKey("Nick");
	local content = self.contentText;
	local contactInfo = self.contactText;
	local feedType = self.selectFeedbackType;
	local gameId = CC.ViewManager.GetCurGameId();
	local sign = Util.Md5(playerID..nickName..content..contactInfo..feedType..ts..CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebKey());

	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetFeedBackUrl();
	local wwwForm = UnityEngine.WWWForm.New();
	wwwForm:AddField("playerID", playerID);
	wwwForm:AddField("nickName", nickName);
	wwwForm:AddField("content", content);
	wwwForm:AddField("contactInfo", contactInfo);
	wwwForm:AddField("feedType", feedType);
	wwwForm:AddField("ts", ts);
	wwwForm:AddField("gameid", gameId);
	wwwForm:AddField("sign", sign);
	if imageBytes then
		wwwForm:AddBinaryData("picture", imageBytes, "jpg");
	end

	log("-----UpLoadServiceUrl: "..url);
	CC.ViewManager.ShowConnecting();
	CC.HttpMgr.PostForm(url,wwwForm,function(www)
			CC.ViewManager.CloseConnecting();
			CC.ViewManager.ShowTip(self.language.serviceTips1);
			log("upLoad success   "..tostring(www.downloadHandler.text));
		end, function(error)
			CC.ViewManager.CloseConnecting();
			logError("upLoad failed   "..tostring(error));
			CC.ViewManager.ShowTip(self.language.serviceTips6);
		end);
end

function SetUpServiceView:OnClickUpload()
	log("OnClickUpload!!!")
	Client.OpenPhotoAlbum();
end

function SetUpServiceView:OnClickUrlText(url)
	log(url)
	Client.OpenURL(url);
end

function SetUpServiceView:OnClickVipService()
	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetSpecialServiceUrl()
	Client.OpenURL(url)
end

function SetUpServiceView:OnPickPhotoBack(imagePath)

	log("OnPickPhotoBack:"..tostring(imagePath));
	--根据文件名判断是否为jpg图片
	if string.sub(imagePath,-4) ~= ".jpg" then
		CC.ViewManager.ShowTip(self.language.serviceTips2);
		return
	end
	--读取系统相册图片
	local url = "file://"..imagePath;
	CC.HttpMgr.GetTexture(url, function(www)
			if www.downloadHandler.texture then
				--显示在上传按钮上
				local texture = www.downloadHandler.texture;
				local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5));
				local btnImage = self:FindChild("Frame/ContentBg/BtnUpload"):GetComponent("Image");
				btnImage.sprite = sprite;
				self.upLoadPicture = texture;
				table.insert(self.cacheList, sprite);
			end
		end, function()
			logError("not get the image from phone");
		end);
end

function SetUpServiceView:OnPickPhotoBytesBack(imageBytes)
	if not imageBytes then return end
	local btnImage = self:FindChild("Frame/ContentBg/BtnUpload"):GetComponent("Image");
	local texture = Texture2D(btnImage.mainTexture.width, btnImage.mainTexture.height, UnityEngine.TextureFormat.RGBA32, false);
	UnityEngine.ImageConversion.LoadImage(texture, imageBytes);
	local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5));
	btnImage.sprite = sprite;
	self.upLoadPicture = texture;
	table.insert(self.cacheList, sprite);
end

function SetUpServiceView:OnPickIOSPhotoBack(imageBytes, imageType)
	log("IOSPhotoType:"..(imageType == 0 and "jpg" or "others"));
	if imageType ~= 0 then
		CC.ViewManager.ShowTip(self.language.serviceTips2);
		return
	end
	--显示在上传按钮上
	local btnImage = self:FindChild("Frame/ContentBg/BtnUpload"):GetComponent("Image");
	local texture = Texture2D(btnImage.mainTexture.width, btnImage.mainTexture.height, UnityEngine.TextureFormat.RGBA32, false);
	UnityEngine.ImageConversion.LoadImage(texture, imageBytes);
	local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5));
	btnImage.sprite = sprite;
	self.upLoadPicture = texture;
end

function SetUpServiceView:ActionIn()
	--竖屏临时适配
	local scale = self:IsPortraitScreen() and 1.2 or 1 
	self.transform.size = Vector2(3000, 3000)
	self.transform.localScale = Vector3(0.5,0.5,1)
	self:RunAction(self, {"scaleTo", scale, scale, 0.3, ease=CC.Action.EOutBack, function()
				self:SetCanClick(true);
			end})
	CC.Sound.PlayHallEffect("click_boardopen");
end

return SetUpServiceView;