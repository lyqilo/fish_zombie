local CC = require("CC")
local SetSafePassWordView = CC.uu.ClassView("SetSafePassWordView")

function SetSafePassWordView:ctor(param)
	self:InitVar(param);
end

function SetSafePassWordView:InitVar(param)
    self.param = param or {}
    self.language = self:GetLanguage()
    self.isReqSeting = false
    self.showPass1 ,self.realPass1 ,self.fakePass1 = false , "" , ""
    self.showPass2 ,self.realPass2 ,self.fakePass2 = false , "" , ""
end

function SetSafePassWordView:OnCreate()
    self:RegisterEvent()
    self:InitView()
end

function SetSafePassWordView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnReqSetSafeResp, CC.Notifications.NW_ReqSetSafe)
end

function SetSafePassWordView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function SetSafePassWordView:InitView()
    self:FindChild("Bg/Tip").text = self.language.tip
    for i = 1,2 do
        local node = i == 1 and self:FindChild("Bg/SetPanel") or self:FindChild("Bg/ConfirmPanel")
        node:FindChild("Title").text = i == 1 and self.language.setPass or self.language.confirmPass
        node:FindChild("Input/Text").text = self.language.inputCode
        node:FindChild("KeyBoard/Clear/Text").text = self.language.againInput
        for j = 0,9 do
            node:FindChild("KeyBoard/"..j.."/Text").text = j
            self:AddClick(node:FindChild("KeyBoard/"..j),function() self:OnChangePass("Number",node,i,j) end,nil,true)
        end
        self:AddClick(node:FindChild("KeyBoard/Clear"),function() self:OnChangePass("Clear",node,i) end,nil,true)
        self:AddClick(node:FindChild("KeyBoard/OK"),function() self:OnClickOK(node,i) end,nil,true)
        self:AddClick(node:FindChild("Close"),function() self:OnClickClose(node,i) end)
        self:AddClick(node:FindChild("Input/Delete"),function() self:OnChangePass("Delete",node,i) end,nil,true)
        self:AddClick(node:FindChild("Input/Btn"),function() 
            self["showPass"..i] = not self["showPass"..i]
            self:ShowCode(node,i) 
        end)

        self:SetCode(node,i)
        self:ShowCode(node,i)
    end
end

function SetSafePassWordView:ShowCode(node,i)
	node:FindChild("Input/Btn/Show"):SetActive(self["showPass"..i])
    node:FindChild("Input/Btn/Hide"):SetActive(not (self["showPass"..i]))
end

function SetSafePassWordView:SetCode(node,i)
    node:FindChild("Input/Btn/Show/Code").text = self["realPass"..i]
    node:FindChild("Input/Btn/Hide/Code").text = self["fakePass"..i]
   
    node:FindChild("Input/Text"):SetActive(#(self["realPass"..i]) <= 0)
    if #(self["realPass"..i]) <= 0 then node:FindChild("Input/Text").text = self.language.inputCode end

    node:FindChild("Input/Delete"):SetActive(#(self["realPass"..i]) > 0)
end

function SetSafePassWordView:OnChangePass(flag,node,i,j)
    local len = #(self["realPass"..i])
    if flag == "Number" then
        if len >= 6 then return end
        self["realPass"..i] = self["realPass"..i]..j
        self["fakePass"..i] = self["fakePass"..i].."*"
    elseif flag == "Clear" then
        if len <= 0 then return end
        self["realPass"..i] = ""
        self["fakePass"..i] = ""
    elseif flag == "Delete" then
        if len <= 0 then return end
        self["realPass"..i] = len == 1 and "" or string.sub(self["realPass"..i],1,len-1)
        self["fakePass"..i] = len == 1 and "" or string.sub(self["fakePass"..i],1,len-1)
    end

	self:SetCode(node,i)
end

function SetSafePassWordView:OnClickOK(node,i)
    if #(self["realPass"..i]) < 6 then 
        CC.ViewManager.ShowTip(self.language.inputCode)
        return 
    end
	if i == 1 then
        self:ShowPanel(self:FindChild("Bg/SetPanel"),self:FindChild("Bg/ConfirmPanel"))
        self:FindChild("Bg/ConfirmPanel/Input/Text").text = self.language.inputCode
    else
        if self.realPass1 ~= self.realPass2 then
            self:OnChangePass("Clear",node,i)
            CC.ViewManager.ShowTip(self.language.passDiff)
            node:FindChild("Input/Text").text = self.language.repeatInput
        else
            if self.isReqSeting then
                log("稍等，正在请求设置中")
                return
            end
            CC.ViewManager.ShowMessageBox(self.language.confirmPassTip,function()
                self.isReqSeting = true
               
                CC.Request("ReqSetSafe",{Pwd = self.realPass2})
            end)
        end
    end
end

function SetSafePassWordView:OnReqSetSafeResp(err,data)
    self.isReqSeting = false
	if err == 0 then
        CC.Player.Inst():GetSafeCodeData().SafeStatus = 1
        CC.Player.Inst():GetSafeCodeData().FreezeStatus = false
        
        CC.ViewManager.ShowTip(self.language.setSucc)
        self:Destroy()

        CC.HallNotificationCenter.inst():post(CC.Notifications.SetSafePassWordSucc, self.realPass2)
    elseif err == CC.shared_en_pb.ExistSafePwdFailed then
        --已设置安全码重新请求下安全码状态
        CC.Request("ReqSafeData",{IMei = CC.Platform.GetDeviceId()})
    end
end

function SetSafePassWordView:OnClickClose(node,i)
	if i == 1 then
        self:ActionOut()
    else
        self.showPass1 = true
        self:ShowCode(self:FindChild("Bg/SetPanel"),1)
        self:ShowPanel(self:FindChild("Bg/ConfirmPanel"),self:FindChild("Bg/SetPanel"))
    end
end

function SetSafePassWordView:ShowPanel(panel1,panel2)
    self:SetCanClick(false);
    self:RunAction(panel1, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
        self:SetCanClick(true);
        panel1:SetActive(false)
        panel2:SetActive(true)
        panel1.localScale = Vector3(1,1,1) --还原大小
    	end})
end

function SetSafePassWordView:OnDestroy()
    self:UnRegisterEvent()
end

return SetSafePassWordView    