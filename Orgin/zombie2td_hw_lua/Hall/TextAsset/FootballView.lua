local CC = require("CC")

local FootballView = CC.uu.ClassView("FootballView")

function FootballView:ctor(param)
    self.param = param
    --带入还是带出
    self.Enter = self.param.Enter
    --带出字段
    self.ExitChips = self.param.ExitChips   --带出筹码
    self.HallChips = self.param.HallChips   --进入大厅前剩余筹码
end

function FootballView:OnCreate()
    self:InitTextByLanguage()
    self:InitUI()
    if self.Enter then
        self:AddClick("Mask","ExitView")
        self:AddClick("Frame/Button","EnterGame")
    else
        self:AddClick("Frame/Button","ActionOut")
    end
end

function FootballView:InitTextByLanguage()
    self.language = self:GetLanguage()
    self:FindChild("Frame/ExchangeTips").text = self.language.ExchangeTips
    self:FindChild("Frame/Button/Text").text = self.language.BtnSure
    if self.Enter then
        self:FindChild("Frame/Title").text = self.language.EnterChips
        self:FindChild("Frame/Box/1/Text").text = self.language.CurChips
        self:FindChild("Frame/Box/2/Text").text = self.language.EnterChips
        self:FindChild("Frame/Box/3/Text").text = self.language.HallChips
    else
        self:FindChild("Frame/Title").text = self.language.OutChips
        self:FindChild("Frame/Box/1/Text").text = self.language.HallChips
        self:FindChild("Frame/Box/2/Text").text = self.language.OutChips
        self:FindChild("Frame/Box/3/Text").text = self.language.CurChips
        self:FindChild("Frame/ExitFail").text = self.language.ExitFail
    end
end

function FootballView:InitUI()
    local hallChip = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") or 0
    if self.Enter then
        local EnterChips = math.modf((hallChip - 3000) / 10000)
        if EnterChips > 10000 then EnterChips = 10000 end
        local Surplus = hallChip - EnterChips * 10000
        self:FindChild("Frame/Box/1/Text/Num").text = CC.uu.ChipFormat(hallChip)
        self:FindChild("Frame/Box/2/Text/Num").text = CC.uu.ChipFormat(EnterChips) .. self.language.FootballCoin
        self:FindChild("Frame/Box/3/Text/Num").text = CC.uu.ChipFormat(Surplus)
    else
        self:InitExitChips()
    end
end

function FootballView:InitExitChips()
    if self.ExitChips >= 0 then
        self:FindChild("Frame/Box/1/Text/Num").text = CC.uu.ChipFormat(self.HallChips)
        self:FindChild("Frame/Box/2/Text/Num").text = (self.ExitChips / 10000) .. self.language.FootballCoin
        self:FindChild("Frame/Box/3/Text/Num").text = CC.uu.ChipFormat(self.HallChips + self.ExitChips)
    else
        self:FindChild("Frame/Box"):SetActive(false)
        self:FindChild("Frame/ExitFail"):SetActive(true)
    end
end

function FootballView:EnterGame()
	CC.ViewManager.EnterGame(nil,5008)
end

function FootballView:ExitView()
    CC.HallNotificationCenter.inst():post(CC.Notifications.GameClickState,{id = 5008,state = false})
    self:ActionOut()
end

return FootballView