
local CC = require("CC")
local SendSetView = CC.uu.ClassView("SendSetView")


function SendSetView:ctor(param)
    self.language = self:GetLanguage()
end

function SendSetView:OnCreate()
    self:RegisterEvent()
    self:InitNode()
    self:InitEvent()
    self:InitText()
end

function SendSetView:InitNode()
    self.UpBtn = self:FindChild("Up/Btn")
    self.DownBtn = self:FindChild("Down/Btn")
    self.UpConfirmPanel = self:FindChild("UpConfirmPanel")
    self.DownConfirmPanel = self:FindChild("DownConfirmPanel")
    self.UpInputField = self:FindChild("Up/InputField")
    self.DownInputField = self:FindChild("Down/InputField")
end

function SendSetView:InitEvent()
    self:AddClick(self.UpBtn,function()
        self:OnClick(true)
    end)
    self:AddClick(self.DownBtn,function()
        self:OnClick()
    end)
    self:AddClick(self.UpConfirmPanel:FindChild("Btn"),function() self.UpConfirmPanel:SetActive(false) end)
    self:AddClick(self.DownConfirmPanel:FindChild("Btn"),function() self.DownConfirmPanel:SetActive(false) end)
    self:AddClick(self:FindChild("BtnExit"),function() self:Destroy() end)

    UIEvent.AddInputFieldOnValueChange(self.UpInputField,function(str)
        self:OnChipsChange(str,true)
    end)
    UIEvent.AddInputFieldOnValueChange(self.DownInputField,function(str)
        self:OnChipsChange(str)
    end)
end

function SendSetView:InitText()
    self:FindChild("TopTip").text = self.language.Tip7
    self:FindChild("Title/Image/Text").text = self.language.Title
    self:FindChild("Up/Text").text = self.language.SingleLimit
    self:FindChild("Up/InputField/Placeholder").text = self.language.NoSet
    self:FindChild("Up/Btn/Text").text = self.language.Save
    self:FindChild("Down/Text").text = self.language.TotalLimit
    self:FindChild("Down/InputField/Placeholder").text = self.language.NoSet
    self:FindChild("Down/Btn/Text").text = self.language.Save
    self.UpConfirmPanel:FindChild("Btn/Text").text = self.language.Confirm
    self.UpConfirmPanel:FindChild("BG2/Text").text = self.language.SingleChangeSuccess
    self.DownConfirmPanel:FindChild("Btn/Text").text = self.language.Confirm
    self.DownConfirmPanel:FindChild("BG2/Text").text = self.language.TotalChangeSuccess

    if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < 14 then
        local VipData = self:GetVipDatas()
        self.DownInputField.text = VipData.MaxGiveCount
        self.Total = VipData.MaxGiveCount
    end
    CC.Request("ReqTradeInfo")
end

function SendSetView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnReqTradeInfoRsp, CC.Notifications.NW_ReqTradeInfo)
	CC.HallNotificationCenter.inst():register(self,function() CC.Request("ReqTradeInfo") end,CC.Notifications.OnTimeNotify)
    CC.HallNotificationCenter.inst():register(self, self.OnReqManageOneTimeLimitRsp, CC.Notifications.NW_ReqManageOneTimeLimit)
    CC.HallNotificationCenter.inst():register(self, self.OnReqManageDailyLimitRsp, CC.Notifications.NW_ReqManageDailyLimit)
end

function SendSetView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqTradeInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnTimeNotify)
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqManageOneTimeLimit)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqManageDailyLimit)
end

function SendSetView:OnChipsChange(str,isUp)
    local numberLength = string.len(str)
	if numberLength > 12 then
		--最高12位
		str = string.sub(str,1,12)
	end
    if isUp then
        self:FindChild("Up/InputField").text  = str
        self:FindChild("Up/ShowInputField").text = CC.uu.ChipFormat(str,true)
    else
        self:FindChild("Down/InputField").text  = str
        self:FindChild("Down/ShowInputField").text = CC.uu.ChipFormat(str,true)
    end
	
end

function SendSetView:OnClick(isUp)
    local vipData = self:GetVipDatas()
    if isUp then
        local num = tonumber(self.UpInputField.text)
        if num == nil then num = 0 end
        if num ~= 0 then
            if num < self.MinLimit then
                CC.ViewManager.ShowTip(string.format(self.language.Tip6,self.MinLimit))
                return
            end
            if num > vipData.MaxGiveCount then
                CC.ViewManager.ShowTip(string.format(self.language.Tip5,vipData.MaxGiveCount))
                return
            end
            if self.Total and num > self.Total then
                CC.ViewManager.ShowTip(self.language.Tip2)
                return
            end
        end
       
        --请求
        CC.Request("ReqManageOneTimeLimit",{PlayerID = CC.Player.Inst():GetSelfInfoByKey("Id"),Amount = num})
    else
        local num = tonumber(self.DownInputField.text)
        if num == nil then num = 0 end
        if num ~= 0 then
            if num < self.MinLimit then
                CC.ViewManager.ShowTip(string.format(self.language.Tip6,self.MinLimit))
                return
            end
            if num > vipData.MaxGiveCount then
                CC.ViewManager.ShowTip(string.format(self.language.Tip5,vipData.MaxGiveCount))
                return
            end
            if num < vipData.MaxGiveCount and self.Single and num < self.Single then
                CC.ViewManager.ShowTip(self.language.Tip4)
                return
            end
        end
        --请求
        CC.Request("ReqManageDailyLimit",{PlayerID = CC.Player.Inst():GetSelfInfoByKey("Id"),Amount = num})
    end
end

function SendSetView:OnReqTradeInfoRsp(err,data)
    if err == 0 then
        self.AlreadySentToday = CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < 3 and data.AlreadySentVip or data.AlreadySentToday
        self.MinLimit = data.MinLimit
        if data.SetOneTimeTradeLimit and data.SetOneTimeTradeLimit > 0 then
             self.UpInputField.text = data.SetOneTimeTradeLimit
             self.Single = data.SetOneTimeTradeLimit
        end
        if data.SetDailyTradeLimit and data.SetDailyTradeLimit > 0 then
             self.DownInputField.text = data.SetDailyTradeLimit
             self.Total = data.SetDailyTradeLimit
        end
        self:FindChild("Text").text = self.language.TotalSend..CC.uu.ChipFormat(self.AlreadySentToday,true)
    else
        self:Destroy()
    end
end

function SendSetView:OnReqManageOneTimeLimitRsp(err,data)
    if err == 0 then
        log(CC.uu.Dump(data,"OnReqManageOneTimeLimitRsp = "))
        self.Single = data.Amount
        self.UpConfirmPanel:SetActive(true)
    end
end

function SendSetView:OnReqManageDailyLimitRsp(err,data)
    if err == 0 then
        self.Total = data.Amount
        self.DownConfirmPanel:SetActive(true)
    end
end

--获取自己的VIP数据
function SendSetView:GetVipDatas()
	local vipDatas = CC.ConfigCenter.Inst():getConfigDataByKey("VIPRights")
	local curVipData = nil
	for k,v in pairs(vipDatas) do
		if v.Viplv == CC.Player.Inst():GetSelfInfoByKey("EPC_Level") then
			curVipData = v
			return curVipData
		end
    end
end

function SendSetView:ActionIn()
    
end

function SendSetView:OnDestroy()
	self:UnRegisterEvent()
end

return SendSetView