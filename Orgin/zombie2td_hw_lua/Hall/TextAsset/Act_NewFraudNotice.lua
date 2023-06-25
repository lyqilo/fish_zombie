
local CC = require("CC")
local Act_NewFraudNotice = CC.uu.ClassView("Act_NewFraudNotice")

function Act_NewFraudNotice:ctor(content)
	self.content = content
end

function Act_NewFraudNotice:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:InitClickEvent()
end
function Act_NewFraudNotice:InitClickEvent()
	--self:AddClick("BG",function ()

	--end)
end

function Act_NewFraudNotice:OnDestroy()
end

return Act_NewFraudNotice