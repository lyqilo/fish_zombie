local CC = require("CC")
local BirthdayAwardView = CC.uu.ClassView("BirthdayAwardView")

function BirthdayAwardView:ctor()
	self.language = CC.LanguageManager.GetLanguage("L_BirthdayView")
end

function BirthdayAwardView:OnCreate(param)
    self.param = param or {}
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    self.musicName = nil
    self:RegisterEvent()
	self:InitUI()
end

function BirthdayAwardView:InitUI()
    self.btnOpen = self:FindChild("Effect/Effect_Birthday_LB01/BtnOpen")
    self:AddClick(self.btnOpen, function ()
        CC.Request("ReqBirthdayPrize", {PlayerID = CC.Player.Inst():GetSelfInfoByKey("Id")})
	end)
    self.musicName = CC.Sound.GetMusicName();
    CC.Sound.StopBackMusic();
    self:DelayRun(1.5,function ()
        self.btnOpen:SetActive(true)
        self:FindChild("Effect/Effect/caidai"):SetActive(true)
        self:FindChild("Title"):SetActive(true)
        self:FindChild("Time"):SetActive(true)
        CC.Sound.PlayHallBackMusic("birthdayBg");
        --self:FindChild("mask"):GetComponent("Image").color = Color(0, 0, 0, 0.8)
        self:RunAction(self:FindChild("mask"):GetComponent("Image"), {"colorTo", 0, 0, 0, 180, 0.5,ease=CC.Action.EOutSine})
    end)
    self:LanguageSwitch()
    CC.Sound.PlayHallEffect("birthdayGift")
end

--语言切换
function BirthdayAwardView:LanguageSwitch()
    local birthDayDate = CC.Player.Inst():GetBirthdayGiftData().Birth or ""
    birthDayDate = string.sub(birthDayDate, 1, 5)
	self:FindChild("Time").text = string.format(self.language.AwardTime, birthDayDate)
    self.btnOpen:FindChild("Text").text = self.language.BtnOpen
end

function BirthdayAwardView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.BirthdayPrizeResp, CC.Notifications.NW_ReqBirthdayPrize)
end

function BirthdayAwardView:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqBirthdayPrize)
end

function BirthdayAwardView:BirthdayPrizeResp(err, param)
    CC.uu.Log(param, "BirthdayPrizeResp")
    if err == 0 then
        local birthDayDate = CC.Player.Inst():GetBirthdayGiftData()
        birthDayDate.GiftEndAt = param.GiftEndAt
        birthDayDate.GiftStatus = param.GiftStatus
        birthDayDate.Status = param.Status
        if param.GiftStatus == 1 then
            CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetActivityInfoByKey("BirthdayView", {switchOn = true})
        end
        local data = {{ConfigId = param.ConfigId, Count = param.Count}}
        local Cb = function ()
            self:CloseView()
        end
        CC.ViewManager.OpenRewardsView({items = data, callback = Cb})
    end
end

function BirthdayAwardView:ActionIn()
end

function BirthdayAwardView:ActionOut()
end

--关闭界面
function BirthdayAwardView:CloseView()
	self:ActionOut()
    self:Destroy()
end

function BirthdayAwardView:OnDestroy()
    self:unRegisterEvent()
	CC.Sound.StopEffect()
	if self.musicName then
		CC.Sound.PlayHallBackMusic(self.musicName);
	else
		CC.Sound.StopBackMusic();
	end
end

return BirthdayAwardView;