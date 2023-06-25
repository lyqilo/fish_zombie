
local CC = require("CC")
local CaptureScreenShareView = CC.uu.ClassView("CaptureScreenShareView")

--截屏分享界面
--[[
@param
extraData(必传):
    gameId:游戏id(必传)
    其他扩展参数(通过连接回传游戏)

btnPerfab:子游戏自定义按钮(没有则使用默认按钮)
	(必现包含 BtnFaceBook,BtnLine,btnSave,BtnClose 且按钮名称与之对应)

isShowPlayerInfo:是否显示玩家信息(bool类型)默认不显示
callback:界面关闭回调
beforeCB:截屏之前回调
afterCB:截屏之后回调
webTitle:web页面上的标题
webText:web页面上的文本
content:分享的文本内容（废弃，统一换成webText）
shareType:完成任务分享类型
errCb:分享错误回调
isHideImg:是否隐藏图片，只分享链接
defaultUrl:是否用自带链接

]]
function CaptureScreenShareView:ctor(param)

	self.param = param or {};

	self.captureTexture = nil;

	self.language = self:GetLanguage();

	self.param.webText = param.webText or self.param.content;

	-- self.param.content = param.content or "";

	self.shareSucc = false
end

function CaptureScreenShareView:OnCreate()

    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()

	self:InitContent();

	self:InitTextByLanguage();

	if self.param.beforeCB then
		self.param.beforeCB();
	end

	Util.CaptureScreenShot(function(texture)

			if self.param.afterCB then
				self.param.afterCB();
			end

			self:DelayRun(0.1, function()
					self:CaptureScreenShow(texture);
				end)
		end);
end

function CaptureScreenShareView:CreateViewCtr(...)
    local viewCtrClass = require("View/ShareView/"..self.viewName.."Ctr");
    return viewCtrClass.new(self, ...);
end

function CaptureScreenShareView:InitContent()

	if self.param.btnPerfab then

		self.btnGroup = self.param.btnPerfab
		self.btnGroup:SetParent(self:FindChild("Frame"),false)
		self.btnGroup:SetActive(false)

		self:AddBtnEvent(self.btnGroup:FindChild("BtnFaceBook"),
				self.btnGroup:FindChild("BtnLine"),
				self.btnGroup:FindChild("BtnSavePhoto"),
				self.btnGroup:FindChild("BtnClose"),
				self.btnGroup:FindChild("BtnOther"))
	else

		self.btnGroup = self:FindChild("Frame/Layer")
		self.btnGroup:SetActive(false)

		self:AddBtnEvent(self:FindChild("Frame/Layer/BtnFitter/BtnFaceBook"),
				self:FindChild("Frame/Layer/BtnFitter/BtnLine"),
				self:FindChild("Frame/Layer/BtnSavePhoto"),
				self:FindChild("Frame/Layer/BtnClose"),
				self:FindChild("Frame/Layer/BtnFitter/BtnOther"))
	end

	--玩家信息
    if self.param.isShowPlayerInfo then
        self:FindChild("Frame/WaterMark/HeadFrame"):SetActive(true)
        local headNode = self:FindChild("Frame/WaterMark/HeadFrame/HeadNode");
        self.headIcon = CC.HeadManager.CreateHeadIcon({parent = headNode, clickFunc = "unClick", unShowVip = true});

        local vipLvl = CC.Player.Inst():GetSelfInfoByKey("EPC_Level");
        local vip = self:FindChild("Frame/WaterMark/HeadFrame/Vip/Text");
        vip.text = vipLvl;

        local nickName = CC.Player.Inst():GetSelfInfoByKey("Nick");
        local nick = self:FindChild("Frame/WaterMark/HeadFrame/Nick");
        nick.text = nickName
    end
end

--ui按钮事件处理
function CaptureScreenShareView:AddBtnEvent(fbBtn,lineBtn,saveBtn,closeBtn,otherBtn)

	self:AddClick(fbBtn, "OnClickShareToFacebook");

	self:AddClick(lineBtn, "OnClickShareToLine");

	self:AddClick(saveBtn, "OnClickSaveToPhotoAlbum");

	self:AddClick(closeBtn, function() self:Destroy() end);

	if otherBtn then
		self:AddClick(otherBtn, "OnClickShareToOther");
	end
end

function CaptureScreenShareView:InitTextByLanguage()

	self:FindChild("Frame/Layer/BtnSavePhoto/Text").text = self.language.btnSave;
	self:FindChild("Frame/Layer/BtnFitter/BtnFaceBook/Text").text = self.language.btnFB;
	self:FindChild("Frame/Layer/BtnFitter/BtnLine/Text").text = self.language.btnLine;
	self:FindChild("Frame/Layer/BtnFitter/BtnOther/Text").text = self.language.btnOther;
end

function CaptureScreenShareView:CaptureScreenShow(texture)

	self.captureTexture = texture;

	local mask = self:FindChild("Mask"):GetComponent("Graphic");
	mask.color = Color(0,0,0,0.7);

	self:FindChild("Frame/WaterMark"):SetActive(false);

	local captureFrame = self:FindChild("Frame/CaptureFrame");
	captureFrame:SetActive(true);
	local textureObj = captureFrame:FindChild("CaptureTexture");
	local captureScreen = textureObj:GetComponent("Image");
	local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5));
	captureScreen.sprite = sprite;

	local fadeInTime = 0.2;
	local fadeInAlpha = 255;
	local stopTime = 0.2;

	self:RunAction(captureFrame, {
			{"fadeTo", fadeInAlpha, fadeInTime},
			{"scaleTo", 0.75, 0.75, 0.3, ease = CC.Action.EOutSine},
		});

	self:RunAction(textureObj,{
			{"fadeTo", fadeInAlpha, fadeInTime, function()
					--self:FindChild("Frame/Layer"):SetActive(true);
					self.btnGroup:SetActive(true)
			 	end},
			{"delay", stopTime},
		});

	self:RunAction(captureFrame:FindChild("Mask"),{
			{"fadeTo", fadeInAlpha, fadeInTime},
			{"delay", stopTime},
			{"fadeTo", 0, 0.5, ease = CC.Action.EOutSine},
		})
end

-- 获取分享链接参数
function CaptureScreenShareView:GetLinkParam()
	local param = {
		webTitle = self.param.webTitle,
		webText = self.param.webText,
		file = self.param.isHideImg and "" or self.captureTexture,
		urlData = {
			extraData = Util.EncodeBase64(Json.encode(self.param.extraData))
		},
		errCb = function()
			self:SetCanClick(true);
			if self.param.errCb then
				self.param.errCb();
			end
	    end,
		succCb = nil
	}
	return param
end

function CaptureScreenShareView:OnClickShareToFacebook()

    if not CC.HallUtil.JudgeHaveFacebookApp() then
        return;
    end

	self:SetCanClick(false)

	local param = self:GetLinkParam()
	param.succCb = function(url)
	--log("---------->CaptureScreenShareView shareUrl " .. tostring(data))
		local data = {};
		data.contentURL = url;
		data.contentTitle = self.param.webTitle;
		data.contentDescription = self.param.webText;
		data.callback = function(status)
			CC.uu.Log(" -----> CaptureScreenShareView FacebookUtil.ShareLink cb " .. tostring(status));
		end
		self.shareSucc = true
		CC.SubGameInterface.ShareLinkToFacebook(data)
	end
	if self.param.defaultUrl then
		param.succCb(self.param.defaultUrl)
	else
		CC.HallUtil.CreateShareLink(param)
	end
end

function CaptureScreenShareView:OnClickShareToLine()

    if not CC.HallUtil.JudgeHaveLineApp() then
        return;
    end

	self:SetCanClick(false)

	local param = self:GetLinkParam()
	param.succCb = function(data)
		self.shareSucc = true
		CC.SubGameInterface.ShareTextToLine(data)
	end
	if self.param.defaultUrl then
		param.succCb(self.param.defaultUrl)
	else
		CC.HallUtil.CreateShareLink(param)
	end
end

function CaptureScreenShareView:OnClickShareToOther()
	self:SetCanClick(false)

	local param = self:GetLinkParam()
	param.succCb = function(data)
		self.shareSucc = true
		CC.SubGameInterface.ShareTextToOther({text = data,callback = function ()
			log(" -----> CaptureScreenShareView ClickShareToOtherCB ")
            --ios平台以webview形式启动分享的app，不走前后台切换，所以在回调接口处理
            if not CC.Platform.isIOS then return end
            self:SetCanClick(true)
            CC.Request("ReqOnClientShare", {ShareType = self.param.shareType or CC.shared_enums_pb.ClientShareCommon})
		end})
	end
	if self.param.defaultUrl then
		param.succCb(self.param.defaultUrl)
	else
		CC.HallUtil.CreateShareLink(param)
	end
end

function CaptureScreenShareView:OnClickSaveToPhotoAlbum()

	if not self.captureTexture then return end;
	local bytes = UnityEngine.ImageConversion.EncodeToPNG(self.captureTexture);
	if Client.SaveToPhotoAlbum(bytes) then
		CC.ViewManager.ShowTip(self.language.saveSuccess);
	else
		CC.ViewManager.ShowTip(self.language.saveFailed);
	end
end

function CaptureScreenShareView:OnResume()

	self:SetCanClick(true)
	log(" -----> CaptureScreenShareView OnResume ")

	if self.shareSucc then
		self.shareSucc = false
		CC.Request("ReqOnClientShare", {ShareType = self.param.shareType or CC.shared_enums_pb.ClientShareCommon})
		-- CC.ViewManager.ShowMessageBox("分享成功")
		if self.param.shareCallBack then
            self.param.shareCallBack()
        end
	end
end

function CaptureScreenShareView:OnPause()
	--log(" -----> CaptureScreenShareView OnPause ")
end

function CaptureScreenShareView:ActionIn()

end

function CaptureScreenShareView:ActionOut()

end

function CaptureScreenShareView:OnDestroy()

	if self.headIcon then
		self.headIcon:Destroy();
	end

	if self.param.callback then
		self.param.callback();
	end

	self.btnGroup = nil

    if self.viewCtr then
        self.viewCtr:Destroy()
        self.viewCtr = nil
    end
end

return CaptureScreenShareView