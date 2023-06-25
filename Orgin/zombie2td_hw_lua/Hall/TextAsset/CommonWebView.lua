local CC = require("CC")
local CommonWebView = CC.uu.ClassView("CommonWebView")
local M = CommonWebView

--[[
WebView
@param
webUrl:网页链接
]]
function M:ctor(param)
	self:InitVar(param)
end

function M:GlobalNode()
	return GameObject.Find("DontDestroyGNode/GCanvas/GMain").transform
end

function M:InitVar(param)
	self.param = param
	self.webUrl = param.webUrl
    self.language = self:GetLanguage()
end

function M:OnCreate()

    self:InitContent()
	self:InitTextByLanguage()
	self:RegisterEvent()
	self:LoadUrl()
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnReLoginDisconnectToLogin,CC.Notifications.OnReLoginDisconnectToLogin);
	CC.HallNotificationCenter.inst():register(self,self.OnResume,CC.Notifications.OnResume)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self);
end

function M:OnMenuBack()
	log("WebView OnMenuBack")
	self:Destroy()
end

function M:OnReLoginDisconnectToLogin()
	CC.ViewManager.ShowTip(self.language.connectFail)
	self:Destroy()
end

function M:InitContent()
	
	self.webView = self:FindChild("Main/WebView"):GetComponent("WebViewObject")
	self.webView:Init(nil, nil, nil, nil, nil, nil, true)
	self.webView:SetVisibility(true)
	--根据分辨率设置显示尺寸
	local scale = math.min(Screen.width/1280, Screen.height/720)
	local offset = math.ceil(scale * 90)
	self.webView:SetMargins(0, offset, 0, 0, false)
	
	self:AddClick("Top/BtnBack","ActionOut")
end

function M:InitTextByLanguage()
	self:FindChild("Top/Title").text = self.param.title or ""
end

function M:LoadUrl()
	
	if not self.webUrl then
		logError("Url is nil")
		self:Destroy()
		return
	end

	self.webView:LoadURL(self.webUrl)
end

function M:ActionIn()
	
end

function M:ActionOut()
	self:Destroy()
end

function M:OnResume()
	if self.param and self.param.switchApp then
		self:Destroy()
	end
end

function M:OnDestroy()
	if self.webView then
		self.webView:SetVisibility(false)
		self.webView:Destroy()
		self.webView = nil
	end
	self:UnRegisterEvent()
end

return CommonWebView