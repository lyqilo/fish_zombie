
local CC = require("CC")
local Act_FraudNotice = CC.uu.ClassView("Act_FraudNotice")
--VIP活动
function Act_FraudNotice:ctor(content,language)
	self.content = content
	self.language = language
end

function Act_FraudNotice:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:InitTextByLanguage()
end

function Act_FraudNotice:InitTextByLanguage()
	self.transform:FindChild("Scroll View/Viewport/Content/Content").text = self.language["Act_FraudNoticeText"]
end

function Act_FraudNotice:InitCDView()
end

function Act_FraudNotice:OnDestroy()
end

return Act_FraudNotice