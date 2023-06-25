
local CC = require("CC")
local Act_UserAgreement = CC.uu.ClassView("Act_UserAgreement")
--VIP活动
function Act_UserAgreement:ctor(content,language)
	self.content = content
	self.language = language
end

function Act_UserAgreement:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:InitTextByLanguage()
end

function Act_UserAgreement:InitTextByLanguage()
	self.transform:FindChild("Scroll View/Viewport/Content/Content").text = self.language["Act_UserAgreementText"]
end

function Act_UserAgreement:InitCDView()
end

function Act_UserAgreement:OnDestroy()
end

return Act_UserAgreement