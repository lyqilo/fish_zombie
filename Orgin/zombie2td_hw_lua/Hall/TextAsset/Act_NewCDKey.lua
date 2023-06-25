
local CC = require("CC")
local Act_NewCDKey = CC.uu.ClassView("Act_NewCDKey")

function Act_NewCDKey:ctor(content)
	self.content = content
end

function Act_NewCDKey:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:InitClickEvent()
end
function Act_NewCDKey:InitClickEvent()
	self:AddClick("BG",function ()
		Client.OpenURL("https://line.me/R/ti/p/%40076grbgh")
	end)
end

function Act_NewCDKey:OnDestroy()
end

return Act_NewCDKey