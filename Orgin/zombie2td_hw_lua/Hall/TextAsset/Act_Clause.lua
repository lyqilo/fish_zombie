
local CC = require("CC")
local Act_Clause = CC.uu.ClassView("Act_Clause")
--VIP活动
function Act_Clause:ctor(content,language)
	self.content = content
	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
	self.language = language
end

function Act_Clause:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:InitTextByLanguage()

	local richText = self:FindChild("Scroll View/Viewport/Content/Content"):GetComponent("RichText")
	richText.onLinkClick = function (url)
		logError(url)
		Client.OpenURL(url);
	end
end

function Act_Clause:InitTextByLanguage()
	self.transform:FindChild("Scroll View/Viewport/Content/Content").text = self.language["Act_ClauseText"]
end

function Act_Clause:InitCDView()
end

function Act_Clause:OnDestroy()
end

return Act_Clause