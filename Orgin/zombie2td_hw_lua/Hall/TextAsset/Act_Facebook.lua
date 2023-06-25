
local CC = require("CC")
local Act_Facebook = CC.uu.ClassView("Act_Facebook")

function Act_Facebook:ctor(content)
	self.content = content
	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
	self.facebookBinding = false;
end

function Act_Facebook:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:BlindFacebook()
end

------------------------------------------------------------------------------------------------------------------------
--绑定Facebook
function Act_Facebook:BlindFacebook()
	self:AddClick("BG",function ()
		CC.HallUtil.BlindFacebook()
	end)
end
------------------------------------------------------------------------------------------------------------------------

function Act_Facebook:OnDestroy()
end

return Act_Facebook