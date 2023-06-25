local CC = require("CC")
local SetSexView = CC.uu.ClassView("SetSexView")

function SetSexView:ctor(param)
    self.param = param
end

function SetSexView:OnCreate()
    self.toggles = {self:FindChild("Layer_UI/Image/Male"),self:FindChild("Layer_UI/Image/Female")}

    self:RegisterEvent()
    self:InitTextByLanguage()
    self:AddClickEvent()
end

function SetSexView:InitTextByLanguage()
    self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView")
    self:FindChild("Layer_UI/Title").text = self.language.setsex
    self:FindChild("Layer_UI/Image/Male/Label").text = self.language.male
    self:FindChild("Layer_UI/Image/Female/Label").text = self.language.female
    self:FindChild("Layer_UI/BtnSure/Text").text = self.language.btnOk
end

function SetSexView:AddClickEvent()
    UIEvent.AddToggleValueChange(self.toggles[1],function(select)
        if select then
            self.sex = CC.shared_enums_pb.S_Male
        end
    end)
    UIEvent.AddToggleValueChange(self.toggles[2],function(select)
        if select then
            self.sex = CC.shared_enums_pb.S_Female
        end
    end)
    local playerData = CC.Player.Inst():GetSelfInfo()
    self.toggles[playerData.Data.Player.Sex == CC.shared_enums_pb.S_Male and 1 or 2]:GetComponent("Toggle").isOn = true
   
    self:AddClick("Mask","ActionOut")
    self:AddClick("Layer_UI/BtnSure","OnClickSubmit")
end

function SetSexView:OnClickSubmit()
    if not self.sex then
        return
    end
    if self.sex == CC.Player.Inst():GetSelfInfo().Data.Player.Sex then
        self:ActionOut()
        return
    end

    CC.Request("ReqSavePlayer",{Sex = tostring(self.sex)})
end

function SetSexView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnReqSavePlayerResp,CC.Notifications.NW_ReqSavePlayer)
end

function SetSexView:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function SetSexView:OnReqSavePlayerResp(err,data)
    if err == 0 then
        CC.Player.Inst():GetSelfInfo().Data.Player.Sex = tonumber(self.sex)
        CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeSex)
        self:ActionOut()
    end
end

function SetSexView:OnDestroy()
    self:UnRegisterEvent()
end

return SetSexView
