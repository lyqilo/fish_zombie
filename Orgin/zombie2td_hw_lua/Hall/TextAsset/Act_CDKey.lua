
local CC = require("CC")
local Act_CDKey = CC.uu.ClassView("Act_CDKey")

--vip特权页面
function Act_CDKey:ctor(content)
	self.content = content
	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
	--self.webview = nil
end

function Act_CDKey:OnCreate()
	self.transform:SetParent(self.content.transform, false)

	self:InitCDView()
	if self.webview then
		--self.webview:SetVisibility(fasel)
	end
end

function Act_CDKey:InitCDView()
	local web_CDkey = self.WebUrlDataManager.GetCDKeyUrl()
	if not self.webview then
		self.webview = self:AddComponent(WebViewBehavior)
		self.webview:Init(self:GlobalCamera())
	end
	log(web_CDkey)
	self.webview:LoadURL(web_CDkey)
	self.webview:SetVisibility(false)
end

function Act_CDKey:OnDestroy()
end

return Act_CDKey