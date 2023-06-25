local CC = require("CC")

local SendAntifraudView = CC.uu.ClassView("SendAntifraudView")

function SendAntifraudView:ctor(param)

    self.param = param

    self.language = self:GetLanguage()
end

function SendAntifraudView:OnCreate()
    self:InitTextByLanguage()
    self:AddClickEvent()
end

function SendAntifraudView:InitTextByLanguage()
    self:FindChild("Layer_UI/Title").text = string.format(self.language.title,self.param)
    self:FindChild("Layer_UI/Condition/Text").text = self.language.sendRecord
    self:FindChild("Layer_UI/Tips").text = self.language.tips
    self:FindChild("Layer_UI/Btn/Text").text = self.language.btn
end

function SendAntifraudView:AddClickEvent()
    self:AddClick("Layer_UI/Btn","ActionOut")
end

function SendAntifraudView:OnDestroy()
end

return SendAntifraudView
