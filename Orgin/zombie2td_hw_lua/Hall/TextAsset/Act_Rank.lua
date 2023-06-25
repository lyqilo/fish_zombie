
local CC = require("CC")
local Act_Rank = CC.uu.ClassView("Act_Rank")
--赢分榜活动
function Act_Rank:ctor(content,language,ActiveTab)
	self.content = content
	self.language = language
	self.ActiveTab = ActiveTab
end

function Act_Rank:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:InitService()
	self:FindChild("BG/Text").text = self.language[self.ActiveTab[8].btnName]
end
--打开赢分榜界面
function Act_Rank:InitService()
	self:AddClick("BG",function ()
		CC.ViewManager.OpenAndReplace("ActiveRankView")
	end)
end
function Act_Rank:OnDestroy()
end

return Act_Rank