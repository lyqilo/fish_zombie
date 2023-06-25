local CC = require("CC")
local Act_FBChatGroup = CC.uu.ClassView("Act_FBChatGroup")

function Act_FBChatGroup:ctor(content)
	self.content = content
end

function Act_FBChatGroup:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:InitClickEvent()
end
function Act_FBChatGroup:InitClickEvent()
	self:AddClick(
		"BG",
		function()
			Client.OpenURL(CC.UrlConfig.Facebook.ChatGroup)
		end
	)
end

function Act_FBChatGroup:OnDestroy()
end

return Act_FBChatGroup
