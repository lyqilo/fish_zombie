
local CC = require("CC")
local Act_RelieveLine = CC.uu.ClassView("Act_RelieveLine")
--VIP活动
function Act_RelieveLine:ctor(content)
	self.content = content
end

function Act_RelieveLine:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:InitService()
end
--打开客服界面
function Act_RelieveLine:InitService()
	self:AddClick("BG",function ()
		-- local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLocalServiceUrl();
		-- Client.OpenURL(url)
		CC.ViewManager.OpenServiceView()
	end)
end
function Act_RelieveLine:OnDestroy()
end

return Act_RelieveLine