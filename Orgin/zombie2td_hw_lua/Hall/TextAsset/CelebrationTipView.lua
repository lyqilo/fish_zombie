local CC = require("CC")
local CelebrationTipView = CC.uu.ClassView("CelebrationTipView")

function CelebrationTipView:ctor(param)
    self.param = param or {}
    self.language = CC.LanguageManager.GetLanguage("L_CelebrationView")
    self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
end

function CelebrationTipView:OnCreate()
    self:AddClick("Mask", "ActionOut")
    self:LanguageSwitch()
    self:FindChild("DragonPanel/DragonNum/Num").text = CC.Player.Inst():GetSelfInfoByKey("EPC_Props_80")
    self:FindChild("StonePanel/StoneNum/Num").text = CC.Player.Inst():GetSelfInfoByKey("EPC_Props_81")
    if self.param.Stone then
        self:FindChild("DragonPanel"):SetActive(false)
        self:FindChild("StonePanel"):SetActive(true)
    end
    self:AddClick(self:FindChild("DragonPanel/Dragon1"), function()
        if self:CheckActivitySwitch("WaterCaptureRankView") then
            CC.ViewManager.Open("RankCollectionView", {currentView = "WaterCaptureRankView"})
            self:ActionOut()
        end
    end)
    self:AddClick(self:FindChild("DragonPanel/Dragon2"), function()
        if self:CheckActivitySwitch("AnniversaryTurntableView") then
            CC.ViewManager.Open("AnniversaryTurntableView")
            self:ActionOut()
        end
    end)
    self:AddClick(self:FindChild("StonePanel/Stone1"), function()
        CC.ViewManager.Open("StoreView")
        self:ActionOut()
    end)
    self:AddClick(self:FindChild("StonePanel/Stone2"), function()
        if self:CheckActivitySwitch("WaterCaptureRankView") then
            CC.ViewManager.Open("RankCollectionView", {currentView = "WaterCaptureRankView"})
            self:ActionOut()
        end
    end)
    self:AddClick(self:FindChild("StonePanel/Stone3"), function()
        if self:CheckActivitySwitch("HolidayDiscountsView") then
            CC.ViewManager.Open("DailyGiftCollectionView", {currentView = "HolidayDiscountsView"})
            self:ActionOut()
        end
    end)
    self:AddClick(self:FindChild("StonePanel/Stone4"), function()
        if self:CheckActivitySwitch("AnniversaryTurntableView") then
            CC.ViewManager.Open("AnniversaryTurntableView")
            self:ActionOut()
        end
    end)
end

function CelebrationTipView:LanguageSwitch()
    self:FindChild("DragonPanel/Text").text = self.language.getTip
    self:FindChild("DragonPanel/Bottom/Text").text = self.language.dragonTip
    self:FindChild("DragonPanel/Dragon1/Text").text = self.language.left_2_2
    self:FindChild("DragonPanel/Dragon2/Text").text = self.language.right_2
    self:FindChild("StonePanel/Text").text = self.language.getTip
    self:FindChild("StonePanel/Bottom/Text").text = self.language.stoneTip
    self:FindChild("StonePanel/Stone1/Text").text = self.language.Stone1
    self:FindChild("StonePanel/Stone2/Text").text = self.language.left_2_2
    self:FindChild("StonePanel/Stone3/Text").text = self.language.left_3
    self:FindChild("StonePanel/Stone4/Text").text = self.language.right_2
end

--检查活动是否打开
function CelebrationTipView:CheckActivitySwitch(viewName)
    if not self.activityDataMgr.GetActivityInfoByKey(viewName).switchOn then
        CC.ViewManager.ShowTip(self.language.tip)
        return false
    end
    return true
end

function CelebrationTipView:ActionIn()
end
function CelebrationTipView:ActionOut()
    self:Destroy()
end
return CelebrationTipView