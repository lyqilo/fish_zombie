local CC = require("CC")
local PropSentView = CC.uu.ClassView("PropSentView")

function PropSentView:ctor(param)
	self:InitVar(param)
end

function PropSentView:InitVar(param)
    self.param = param or {}
    self.language = self:GetLanguage()
    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    self.proplanguage = CC.LanguageManager.GetLanguage("L_Prop")
    self.recordItme = {}
end

function PropSentView:OnCreate()
    self:RegisterEvent()
    self:InitClickEvent()
    self:InitView()

    CC.Request("ReqLoadTradePropSended")
end

function PropSentView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnLoadPlayerBaseInfoResp,CC.Notifications.NW_LoadPlayerBaseInfo)
    CC.HallNotificationCenter.inst():register(self,self.OnReqLoadTradePropSendedResp,CC.Notifications.NW_ReqLoadTradePropSended)
    CC.HallNotificationCenter.inst():register(self,self.OnReqTradePropResp,CC.Notifications.NW_ReqTradeProp)
end

function PropSentView:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function PropSentView:InitClickEvent()
    self:AddClick("Bg/BackBtn","ActionOut")
    self:AddClick("Bg/AffirmBtn","AffirmSent")
    self:AddClick("Bg/RecordBtn","ShowRecord")
    self:AddClick("RecordPanel/Bg/BackBtn","HideRecord")
    
    self.reParent = self:FindChild("RecordPanel/Bg/Scroll View/Viewport/Content")
    self.reItem = self.reParent:FindChild("Item")
    self.notRe = self:FindChild("RecordPanel/Bg/Scroll View/Viewport/NotRecord")

    self.inputNum = self:FindChild("Bg/InputNum/InputField")
    self.inputNum:GetComponent("InputField").characterLimit = 15
    UIEvent.AddInputFieldOnEndEdit(self.inputNum,function(str)
        if tonumber(str) then
            if tonumber(str) <= 0 then
                CC.ViewManager.ShowTip(self.language.sendError1)
            end
            if tonumber(str) > CC.Player.Inst():GetSelfInfoByKey(self.param.Id) then
                CC.ViewManager.ShowTip(self.language.sendError4)
            end
        end
    end)
    self.inputId = self:FindChild("Bg/InputId/InputField")
    UIEvent.AddInputFieldOnEndEdit(self.inputId,function(str)
        if not tonumber(str) then
            return
        end
        CC.Request("LoadPlayerBaseInfo",tonumber(str))
    end)
end

function PropSentView:InitView()
    self:FindChild("Bg/Title/Image/Text").text = self.language.propSend
    self:FindChild("Bg/InputNum/Text").text = self.language.sendNum..":"
    self:FindChild("Bg/InputId/Text").text = self.language.receiverId..":"
    self:FindChild("Bg/Nick/Text").text = self.language.receiverNick..":"
    self:FindChild("Bg/AffirmBtn/Text").text = self.language.send

    local iconImage = self:FindChild("Bg/Prop/Icon")
    self:SetImage(iconImage,self.propCfg[self.param.Id].Icon)
    self:FindChild("Bg/Prop/Num").text = CC.Player.Inst():GetSelfInfoByKey(self.param.Id)

    self:FindChild("RecordPanel/Bg/Title/Image/Text").text = self.language.sendRecord
    self:FindChild("RecordPanel/Bg/Top/Time").text = self.language.time
    self:FindChild("RecordPanel/Bg/Top/ID").text = self.language.receiverId
    self:FindChild("RecordPanel/Bg/Top/Nick").text = self.language.receiverNick
    self:FindChild("RecordPanel/Bg/Top/PropType").text = self.language.prop
    self:FindChild("RecordPanel/Bg/Top/Num").text = self.language.num
    self:FindChild("RecordPanel/Bg/Scroll View/Viewport/NotRecord/Text").text = self.language.notRecord
    self:FindChild("RecordPanel/Bg/Text").text = self.language.notRecor
end

function PropSentView:AffirmSent()
    local num = tonumber(self.inputNum.text)
    if not num or num <= 0 then
        CC.ViewManager.ShowTip(self.language.sendError1)
        return
    end
    if num > CC.Player.Inst():GetSelfInfoByKey(self.param.Id) then
        CC.ViewManager.ShowTip(self.language.sendError4)
        return
    end
    local Id = tonumber(self.inputId.text)
    if not Id or not self.sentPlayer then
        CC.ViewManager.ShowTip(self.language.sendError2)
        return
    end
    if Id == CC.Player.Inst():GetSelfInfoByKey("Id") then
        CC.ViewManager.ShowTip(self.language.sendError3)
        return
    end
    local box = CC.ViewManager.ShowMessageBox(string.format(self.language.affirmTip,Id,self.proplanguage[self.param.Id],num),
                function()
                    --请求赠送
                    local data = {}
                    data.Target = Id
                    data.Amount = num
                    data.MailTitle = self.language.propSend
                    data.MailContent = string.format(self.language.receiveProp,CC.Player.Inst():GetSelfInfoByKey("Nick"),num,self.proplanguage[self.param.Id])
                    data.PropId = self.param.Id
                    CC.Request("ReqTradeProp",data)
                end) 
    box:SetOkText(self.language.affirmSend)
end

function PropSentView:OnLoadPlayerBaseInfoResp(err,data)
    if err == 0 then
        self.sentPlayer = data.Player
	    self:FindChild("Bg/Nick/Name").text = data.Player.Nick
    else
        self.sentPlayer = nil
        self:FindChild("Bg/Nick/Name").text = ""
    end
end

function PropSentView:OnReqLoadTradePropSendedResp(err,data)
    log("err = ".. err.."  OnReqLoadTradePropSendedResp:\n"..tostring(data))
    if err == 0 and #data.Records > 0 then
        self.notRe:SetActive(false)

        for i,v in ipairs(data.Records) do
            local item = self.recordItme[i]
            if not item then
                item = CC.uu.newObject(self.reItem,self.reParent)
                table.insert(self.recordItme,item)
            end
            item:FindChild("Mask"):SetActive(i % 2 > 0)
            item:FindChild("Time").text = v.Time
            item:FindChild("ID").text = v.To
            item:FindChild("Nick").text = v.ToName
            item:FindChild("PropType").text = self.proplanguage[v.PropId]
            item:FindChild("Num").text = v.Amount

            if not item.activeSelf then item:SetActive(true) end
        end
    end
end

function PropSentView:OnReqTradePropResp(err,data)
    if err == 0 then
        self:ActionOut()
        CC.ViewManager.ShowTip(self.language.sendSuccess)
    end
end

function PropSentView:ShowRecord()
    self:SetCanClick(false);
    self:FindChild("RecordPanel"):SetActive(true)
    local node = self:FindChild("RecordPanel/Bg")
    node.transform.localScale = Vector3(0.5,0.5,1)
    self:RunAction(node, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
            self:SetCanClick(true)
    end})
end

function PropSentView:HideRecord()
    self:SetCanClick(false);
    self:RunAction(self:FindChild("RecordPanel/Bg"), {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
        self:SetCanClick(true);
        self:FindChild("RecordPanel"):SetActive(false)
    end})
end

function PropSentView:OnDestroy()
	self:UnRegisterEvent()
end

return PropSentView    