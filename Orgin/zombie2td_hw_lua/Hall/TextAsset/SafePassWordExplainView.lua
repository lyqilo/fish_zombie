local CC = require("CC")

local SafePassWordExplainView = CC.uu.ClassView("SafePassWordExplainView")

function SafePassWordExplainView:ctor(param)
	self.param = param or {}
	self.language = CC.LanguageManager.GetLanguage("L_VerSafePassWordView")
end

function SafePassWordExplainView:OnCreate()
	self:InitUI()
end

function SafePassWordExplainView:InitUI()
    self:FindChild("Layer_UI/Left/Btn"):SetActive(CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("OTPVerify"))
    
	self:FindChild("Layer_UI/Right/Text").text = self.language.safePassWordExp
    self:FindChild("Layer_UI/Left/Btn/Text").text = self.language.changePassWord
    
    self:AddClick(self:FindChild("Layer_UI/Left/Btn"),function()
        if CC.HallUtil.CheckTelBinded() then
            CC.ViewManager.Open("ForGetPassWordView",{title = self.language.changePassWord})
            self:Destroy()
        else
            CC.ViewManager.ShowTip(self.language.needBindTel)
        end
    end,nil,true)

    self:AddClick(self:FindChild("Mask"),function() self:ActionOut() end)
end

return SafePassWordExplainView