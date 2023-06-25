
local CC = require("CC")
local Act_SendTutorial = CC.uu.ClassView("Act_SendTutorial")
--VIP活动
function Act_SendTutorial:ctor(content)
	self.content = content
end

function Act_SendTutorial:OnCreate()
	self.transform:SetParent(self.content.transform, false)

	self:InitSendTutorial()
end

function Act_SendTutorial:OnDestroy()
end

function Act_SendTutorial:InitSendTutorial()
	self:AddClick("BG",function ()
		CC.ViewManager.OpenAndReplace("GiveGiftSearchView")
	end)
end


return Act_SendTutorial