local CC = require("CC")

local RenameView = CC.uu.ClassView("RenameView")

function RenameView:ctor(param)

    self.param = param
    self.nickName = ""
	self.consumeProp = CC.shared_enums_pb.EPC_Mod_Name_Card
	if self.param and self.param.consumeProp then
		self.consumeProp = self.param.consumeProp
	end
	if self.consumeProp == CC.shared_enums_pb.EPC_ModifyNicknameCard then
		self.propStr = "EPC_ModifyNicknameCard"
	else
		self.propStr = "EPC_Mod_Name_Card"
	end
end

function RenameView:OnCreate()
    self:RegisterEvent()
    self:InitUI()
    self:InitTextByLanguage()
    self:AddClickEvent()
end

function RenameView:InitUI()
    self.inputField = self:FindChild("Layer_UI/Content/NickInputField"):GetComponent("InputField");
    local propNum = CC.Player.Inst():GetSelfInfoByKey(self.propStr)
    self:FindChild("Layer_UI/Content/Text").text = "x1"
    if propNum == 0 then
        self.inputField.enabled = false;
        self:FindChild("Layer_UI/JumpBtn"):GetComponent("Button"):SetBtnEnable(false)
        self:FindChild("Layer_UI/Content/EmptyBtn"):SetActive(true)
    else
        self:FindChild("Layer_UI/Content/EmptyBtn"):SetActive(false)
    end
end

function RenameView:InitTextByLanguage()
    self.language = self:GetLanguage()
    self:FindChild("Layer_UI/Title").text = self.language.title
    self:FindChild("Layer_UI/JumpBtn/Text").text = self.language.sureBtn
    self:FindChild("Layer_UI/Tips").text = self.language.consume
end

function RenameView:AddClickEvent()
    self:AddClick("Layer_UI/Content/EmptyBtn",function ()
        CC.ViewManager.ShowTip(self.language.emptyTips)
    end)
    self:AddClick("Mask","ActionOut")
    self:AddClick("Layer_UI/JumpBtn","OnClickSubmit")
end

function RenameView:OnClickSubmit()
    self.nickName = self.inputField.text
    local str = string.gsub(self.nickName,'%s+','')
    if str == "" then
        self.inputField.text = ""
        CC.ViewManager.ShowTip(self.language.empty)
        return
    end
    if string.byte(self.nickName) == 0 then
        BuglyUtil.ReportException("ReqSavePlayerNick:", "string.byte(nick) = 0", "string.byte(nick) = 0");
    end
    self:ReqModifyNickname()
end

function RenameView:ReqModifyNickname()
	if self.consumeProp == CC.shared_enums_pb.EPC_ModifyNicknameCard then
		CC.Request("ReqModifyNicknameByCard",{Nickname=self.nickName})
	else
		CC.Request("ReqSavePlayerNick",{Nick=self.nickName})
	end
end

function RenameView:SavePlayerNickResp(err,data)
    if err == 0 then
        local selfInfo = CC.Player.Inst():GetSelfInfo();
        selfInfo.Data.Player.Nick = self.nickName
        CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeNick);
        self:ActionOut()
    else
        --改名失败
    end
end

function RenameView:ModifyNicknameByCardResp(err,data)
	if err == 0 then
		local selfInfo = CC.Player.Inst():GetSelfInfo();
		selfInfo.Data.Player.Nick = self.nickName
		CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeNick);
		self:ActionOut()
	else
		--改名失败
	end
end

function RenameView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.SavePlayerNickResp,CC.Notifications.NW_ReqSavePlayerNick)
	CC.HallNotificationCenter.inst():register(self,self.ModifyNicknameByCardResp,CC.Notifications.NW_ReqModifyNicknameByCard)
end

function RenameView:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqSavePlayerNick)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqModifyNicknameByCard)
end

function RenameView:OnDestroy()
    self:UnRegisterEvent()
end

return RenameView
