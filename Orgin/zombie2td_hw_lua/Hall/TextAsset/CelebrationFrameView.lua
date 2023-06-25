local CC = require("CC")
local CelebrationFrameView = CC.uu.ClassView("CelebrationFrameView")

function CelebrationFrameView:ctor(param)
    self.param = param or {}
end


function CelebrationFrameView:OnCreate()
    self:AddClick(self:FindChild("mask"), function()
        self:Destroy()
    end)

    CC.Sound.StopEffect()
    CC.Sound.PlayHallEffect("congratulations")
    self:LanguageSwitch()
end

function CelebrationFrameView:LanguageSwitch()
    self:FindChild("Text").text = "กดคลิกเพื่อไปต่อ"
end

function CelebrationFrameView:OnDestroy()
	if self.param.callBack then
		self.param.callBack()
	end
end

return CelebrationFrameView