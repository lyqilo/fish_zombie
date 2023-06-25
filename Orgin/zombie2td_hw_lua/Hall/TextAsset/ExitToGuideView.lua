local CC = require("CC")

local ExitToGuideView = CC.uu.ClassView("ExitToGuideView")

function ExitToGuideView:ctor(param)
    self.id = param.id
    self.cb = param.cb
end

function ExitToGuideView:OnCreate()
    self:InitTextByLanguage()
    self:AddClickEvent()
end

function ExitToGuideView:InitTextByLanguage()
    self.language = self:GetLanguage()
    self:FindChild("BG/Text1").text = self.language.guide1
    self:FindChild("BG/Text2").text = self.language.guide2
    self:FindChild("BG/Btn/Text").text = self.language.btnText
end

function ExitToGuideView:AddClickEvent()
    self:AddClick("BG/Btn","Destroy")
end

function ExitToGuideView:OnDestroy()
    CC.ViewManager.SetExitToGuideId(self.id)
    if self.cb then
        self.cb()
    end
end

return ExitToGuideView
