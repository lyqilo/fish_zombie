
local CC = require("CC")
local Act_GoToFacebook = CC.uu.ClassView("Act_GoToFacebook")

function Act_GoToFacebook:ctor(content,language,ActiveTab)
	self.content = content
	self.language = language
	self.ActiveTab = ActiveTab
end

function Act_GoToFacebook:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:InitClickEvent()
end
--跳转facebook
function Act_GoToFacebook:InitClickEvent()
	self:AddClick("BG",function ()
        --local pageId = CC.ConfigCenter.Inst():getConfigDataByKey("SDKConfig")[AppInfo.ChannelID].facebook.pageId;
		--Client.OpenFacebook(pageId);
		Client.OpenURL(CC.UrlConfig.Facebook.MainPage)
	end)
end

function Act_GoToFacebook:OnDestroy()
end

return Act_GoToFacebook