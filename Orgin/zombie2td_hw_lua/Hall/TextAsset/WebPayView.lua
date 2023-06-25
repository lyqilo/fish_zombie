
local CC = require("CC")
local WebPayView = CC.uu.ClassView("WebPayView")

--vip特权页面
function WebPayView:ctor(webUrl)
	self.webUrl = webUrl
end

function WebPayView:OnCreate()

	self:AddClickEvents()
	self:InitView()
	self:InitTextByLanguage();
end

function WebPayView:AddClickEvents()
	self:AddClick("Frame/BtnExit","onBtnBtnExitClicked")
	
end

function WebPayView:InitView()
	--初始化界面
	self.webview = self:SubAdd("Frame/WebView", WebViewBehavior)
	self.webview:Init(self:GlobalCamera())
	self.webview:LoadURL(self.webUrl)
	self.webview:SetVisibility(true)
end

function WebPayView:InitTextByLanguage()

	local language = CC.LanguageManager.GetLanguage("L_StoreView");

	local title = self:FindChild("Frame/Title");
	title.text = language.webPayViewTitle;
end

function WebPayView:onBtnBtnExitClicked()
	self:Destroy()
end

return WebPayView