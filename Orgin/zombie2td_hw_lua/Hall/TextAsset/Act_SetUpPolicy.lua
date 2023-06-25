
local CC = require("CC")
local Act_SetUpPolicy = CC.uu.ClassView("Act_SetUpPolicy")
--VIP活动
function Act_SetUpPolicy:ctor(content,language)
	self.content = content
	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
	self.language = language
end

function Act_SetUpPolicy:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:InitTextByLanguage()
end

function Act_SetUpPolicy:InitTextByLanguage()
	self.transform:FindChild("Scroll View/Viewport/Content/Content").text = self.language["Act_SetUpPolicyText"]
end

function Act_SetUpPolicy:InitCDView()
end

function Act_SetUpPolicy:OnDestroy()
end



return Act_SetUpPolicy