
local CC = require("CC")
local Act_Service = CC.uu.ClassView("Act_Service")
--VIP活动
function Act_Service:ctor(content)
	self.content = content
end

function Act_Service:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:InitService()
end
--打开客服界面
function Act_Service:InitService()
	self:AddClick("BG",function ()
		-- local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLocalServiceUrl();
		-- Client.OpenURL(url)
		CC.ViewManager.OpenServiceView()
	end)
end

function Act_Service:OnDestroy()
end

return Act_Service