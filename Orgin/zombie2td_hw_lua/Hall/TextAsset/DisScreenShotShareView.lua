

local CC = require("CC")

local DisScreenShotShareView = CC.uu.ClassView("DisScreenShotShareView")

--物理按键截屏分享
--[[
@param
callback:界面关闭回调
imageBytes:图片资源字节数组
]]
function DisScreenShotShareView:ctor(param)

    self.param = param and table.copy(param) or {};

    self.language = CC.LanguageManager.GetLanguage("L_CaptureScreenShareView");

    self.cacheTexture = nil;

    self.shareSucc = false;
end


function DisScreenShotShareView:OnCreate()

    self:InitUI()

    self:AddUIEvent()

    self:ShowImage()
end

function DisScreenShotShareView:InitUI()

    self.layer_UI = self:FindChild("Layer_UI")

    -- self.canvas = self:GetComponent("Canvas")
    
    self:InitTextByLanguage()
end

function DisScreenShotShareView:InitTextByLanguage()
	self:FindChild("Layer_UI/BtnGroup/BtnFitter/BtnFaceBook/Text").text = self.language.btnFB;
	self:FindChild("Layer_UI/BtnGroup/BtnFitter/BtnLine/Text").text = self.language.btnLine;
    self:FindChild("Layer_UI/BtnGroup/BtnFitter/BtnOther/Text").text = self.language.btnOther;
end

function DisScreenShotShareView:AddUIEvent()

    self:AddClick("Layer_UI/BtnGroup/BtnFitter/BtnFaceBook", "OnClickShareToFacebook");

    self:AddClick("Layer_UI/BtnGroup/BtnFitter/BtnLine", "OnClickShareToLine");

    self:AddClick("Layer_UI/BtnGroup/BtnFitter/BtnOther", "OnClickShareToOther");

    self:AddClick("Layer_UI/BtnGroup/BtnService", "OnClickBtnService");

    self:AddClick("Layer_UI/BtnGroup/BtnClose", function() self:Destroy() end);
end

function DisScreenShotShareView:ShowImage()
    if not self.param.imageBytes then return end
    local imageBytes = self.param.imageBytes
    local shareImage = self:FindChild("Layer_UI/Center/Img"):GetComponent("RawImage");
    local texture = Texture2D(shareImage.mainTexture.width, shareImage.mainTexture.height, UnityEngine.TextureFormat.RGBA32, false);
    UnityEngine.ImageConversion.LoadImage(texture, imageBytes);
    shareImage.texture = texture;
    self.cacheTexture = texture;
end

-- 获取分享链接参数
function DisScreenShotShareView:GetLinkParam()
    local param = {
        file = self.cacheTexture,
        errCb = function()
            self:SetCanClick(true);
        end,
        succCb = function(url) 
        end
    }
    return param
end

function DisScreenShotShareView:OnClickShareToFacebook()

    if not CC.HallUtil.JudgeHaveFacebookApp() then
        return;
    end

    self:SetCanClick(false)

    local param = self:GetLinkParam();
    param.succCb = function(url)
        local data = {};
        data.contentURL = url;
        data.callback = function(status, result)
            CC.uu.Log(" -----> DisScreenShotShareView FacebookUtil.ShareLink cb status:" .. tostring(status).." error:"..tostring(result));
        end
        self.shareSucc = true
        CC.SubGameInterface.ShareLinkToFacebook(data);
    end

    CC.HallUtil.CreateShareLink(param);
end

function DisScreenShotShareView:OnClickShareToLine()

    if not CC.HallUtil.JudgeHaveLineApp() then
        return;
    end

    self:SetCanClick(false)

    local param = self:GetLinkParam();
    param.succCb = function(url)
        self.shareSucc = true
        CC.SubGameInterface.ShareTextToLine(url);
    end

    CC.HallUtil.CreateShareLink(param);
end

function DisScreenShotShareView:OnClickShareToOther()
    self:SetCanClick(false)

    local param = self:GetLinkParam();
    param.succCb = function(url)
        self.shareSucc = true
        CC.SubGameInterface.ShareTextToOther({text = url,callback = function ()
            log(" -----> DisScreenShotShareView ShareTextToOtherCB ")
            --ios平台以webview形式启动分享的app，不走前后台切换，所以在回调接口处理
            if not CC.Platform.isIOS then return end
            self:SetCanClick(true)
            CC.Request("ReqOnClientShare", {ShareType = self.param.shareType or CC.shared_enums_pb.ClientShareCommon})
        end});
    end

    CC.HallUtil.CreateShareLink(param);
end

function DisScreenShotShareView:OnClickBtnService()

    -- local sortingLayer = "sort"..tonumber(string.gsub(self.canvas.sortingLayerName, "sort", "")+1)
    local param = {
        uploadImageBytes = self.param.imageBytes,
        -- sortingLayer = sortingLayer,
    }
    CC.ViewManager.OpenServiceView(param)
end

function DisScreenShotShareView:ActionIn()
    self.layer_UI.localScale = Vector3(0.5,0.5,1)
    self:RunAction(self.layer_UI, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()

    end})
end

function DisScreenShotShareView:ActionOut()
    self:RunAction(self.layer_UI, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
        self:Destroy();
    end})
end

function DisScreenShotShareView:OnResume()
    log(" -----> DisScreenShotShareView OnResume ")
    if not self.shareSucc then return end
    self.shareSucc = false
    self:SetCanClick(true)
    CC.Request("ReqOnClientShare", {ShareType = self.param.shareType or CC.shared_enums_pb.ClientShareCommon})
end

function DisScreenShotShareView:OnDestroy()

    if self.param.callback then
        self.param.callback();
    end

    if self.cacheTexture then
        GameObject.Destroy(self.cacheTexture);
        self.cacheTexture = nil;
    end
end

return DisScreenShotShareView