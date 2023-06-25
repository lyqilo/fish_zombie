local CC = require("CC")
local VerSafePassWordView = CC.uu.ClassView("VerSafePassWordView")

function VerSafePassWordView:ctor(param)
	self:InitVar(param);
end

function VerSafePassWordView:InitVar(param)
    self.param = param or {}
    self.language = self:GetLanguage()
    self.showPass ,self.realPass ,self.fakePass = false , "" , ""
    self.codeData = CC.Player.Inst():GetSafeCodeData()
end

function VerSafePassWordView:OnCreate()
    self:RegisterEvent()
    self:InitView()
end

function VerSafePassWordView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnReqSafeVerifyResp, CC.Notifications.NW_ReqSafeVerify)
end

function VerSafePassWordView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function VerSafePassWordView:InitView()
    self:FindChild("Bg/VerifyPanel/ForGet"):SetActive(CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("OTPVerify"))
    
    --------------------VerifyPanel---------------------
    self:FindChild("Bg/VerifyPanel/Tip").text = self.language.lockTip
    self:FindChild("Bg/VerifyPanel/Input/Text").text = self.language[self.codeData.FreezeStatus and "lockPassed" or "inputSafeCode"]
    self:FindChild("Bg/VerifyPanel/KeyBoard/Clear/Text").text = self.language.againInput
    self:FindChild("Bg/VerifyPanel/ForGet").text = self.language.forGetPass.."?"
    for i = 0,9 do
        self:FindChild("Bg/VerifyPanel/KeyBoard/"..i.."/Text").text = i
        self:AddClick(self:FindChild("Bg/VerifyPanel/KeyBoard/"..i),function() self:OnChangePass("Number",i) end,nil,true)
    end
    self:AddClick(self:FindChild("Bg/VerifyPanel/Close"),function() self:ActionOut() end)
    self:AddClick(self:FindChild("Bg/VerifyPanel/KeyBoard/Clear"),function() self:OnChangePass("Clear") end,nil,true)
    self:AddClick(self:FindChild("Bg/VerifyPanel/Input/Delete"),function() self:OnChangePass("Delete") end,nil,true)
    self:AddClick(self:FindChild("Bg/VerifyPanel/KeyBoard/OK"),function() self:OnClickOK() end,nil,true)
    self:AddClick(self:FindChild("Bg/VerifyPanel/Service"),function() 
        -- Client.OpenURL(CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLocalServiceUrl()) 
        CC.ViewManager.OpenServiceView()
    end,nil,true)
    self:AddClick(self:FindChild("Bg/VerifyPanel/ForGet"),function() self:OnForGetPassWord() end,nil,true)
    self:AddClick(self:FindChild("Bg/VerifyPanel/Input/Btn"),function() 
        if self.codeData.FreezeStatus then
            CC.ViewManager.ShowTip(self.language.lockPassed)
            return 
        end
        self.showPass = not self.showPass
        self:ShowCode() 
     end)

    self:SetCode()
    self:ShowCode()

    --------------------LockPanel---------------------
    self:FindChild("Bg/LockPanel/Title").text = self.language.lockPass
    self:FindChild("Bg/LockPanel/Image/Text").text = self.language.lockStr
    self:FindChild("Bg/LockPanel/Service/Text").text = self.language.callService
    self:AddClick(self:FindChild("Bg/LockPanel/Close"),function() self:ShowPanel(self:FindChild("Bg/LockPanel"),self:FindChild("Bg/VerifyPanel")) end)
    self:AddClick(self:FindChild("Bg/LockPanel/Service"),function() 
        -- Client.OpenURL(CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLocalServiceUrl()) 
        CC.ViewManager.OpenServiceView()
    end,nil,true)

end

function VerSafePassWordView:ShowCode()
	self:FindChild("Bg/VerifyPanel/Input/Btn/Show"):SetActive(self.showPass)
    self:FindChild("Bg/VerifyPanel/Input/Btn/Hide"):SetActive(not self.showPass)
end

function VerSafePassWordView:SetCode()
    self:FindChild("Bg/VerifyPanel/Input/Btn/Show/Code").text = self.realPass
    self:FindChild("Bg/VerifyPanel/Input/Btn/Hide/Code").text = self.fakePass
   
    self:FindChild("Bg/VerifyPanel/Input/Text"):SetActive(#(self.realPass) <= 0)
    self:FindChild("Bg/VerifyPanel/Input/Delete"):SetActive(#(self.realPass) > 0)
end

function VerSafePassWordView:OnChangePass(flag,i)
    if self.codeData.FreezeStatus then
        CC.ViewManager.ShowTip(self.language.lockPassed)
        return 
    end
    local len = #(self.realPass)
    if flag == "Number" then
        if len >= 6 then return end
        self.realPass = self.realPass..i
        self.fakePass = self.fakePass.."*"
    elseif flag == "Clear" then
        if len <= 0 then return end
        self.realPass = ""
        self.fakePass = ""
    elseif flag == "Delete" then
        if len <= 0 then return end
        self.realPass = len == 1 and "" or string.sub(self.realPass,1,len-1)
        self.fakePass = len == 1 and "" or string.sub(self.fakePass,1,len-1)
    end

	self:SetCode()
end

function VerSafePassWordView:OnClickOK()
    if self.codeData.FreezeStatus then
        CC.ViewManager.ShowTip(self.language.lockPassed)
        return 
    end
    if #(self.realPass) < 6 then 
        CC.ViewManager.ShowTip(self.language.inputSafeCode)
        return 
    end
   
    local reqFun = function()
        local data = {
            Pwd = self.realPass,
            ServiceType = self.param.serviceType,
            IsVerify = self.param.isVerify
        }
        
        CC.Request("ReqSafeVerify",data)
    end
    if self.param.confirmStr then
        CC.ViewManager.ShowMessageBox(self.param.confirmStr,reqFun)
    else
        reqFun()
    end
end

function VerSafePassWordView:OnReqSafeVerifyResp(err,data)
    log(string.format("err: %s      OnReqSafeVerifyResp: %s",err,tostring(data)))
    if self.param.verifySuccFun then
        self.param.verifySuccFun(err,data)
    end
   if err == 0 then
        self:Destroy()
   elseif err == CC.shared_en_pb.SafeVerifyFailed or err == CC.shared_en_pb.SafeFreezeFailed then --安全码验证错误或者安全码被冻结
        self:FindChild("Bg/VerifyPanel/Input/Tip"):SetActive(true)
        self:FindChild("Bg/VerifyPanel/Input/Tip/Text").text = string.format(self.language.surplusTime,data.ErrNum)
        self:OnChangePass("Clear")
        if data.ErrNum <= 0 then
            self:ShowPanel(self:FindChild("Bg/VerifyPanel"),self:FindChild("Bg/LockPanel"),"OpenLockPanel") 
        end
   end
end

function VerSafePassWordView:OnForGetPassWord()
    if not CC.HallUtil.CheckTelBinded() then 
        CC.ViewManager.ShowTip(self.language.needBindTel)
        return
    end

    self:Destroy()
    CC.ViewManager.Open("ForGetPassWordView",{callBack = function() 
        CC.ViewManager.Open("VerSafePassWordView",self.param)
    end})
end

function VerSafePassWordView:ShowPanel(panel1,panel2,flag)
    if flag == "OpenLockPanel" then
         self.codeData.FreezeStatus = true
         CC.Player.Inst():GetSafeCodeData().FreezeStatus = true
         self:FindChild("Bg/VerifyPanel/Input/Text").text = self.language.lockPassed
    end

    self:SetCanClick(false);
    self:RunAction(panel1, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
        self:SetCanClick(true);
        panel1:SetActive(false)
        panel2:SetActive(true)
        panel1.localScale = Vector3(1,1,1) --还原大小
    	end})
end

function VerSafePassWordView:OnDestroy()
	self:UnRegisterEvent()
end

return VerSafePassWordView    