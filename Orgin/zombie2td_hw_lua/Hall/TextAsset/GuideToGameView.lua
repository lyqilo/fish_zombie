local CC = require("CC")

local GuideToGameView = CC.uu.ClassView("GuideToGameView")

function GuideToGameView:ctor(param)
    self.Time = 3
end

function GuideToGameView:OnCreate()
    self:InitUI()
    self:InitTextByLanguage()
    self:AddClickEvent()
end

function GuideToGameView:InitUI()
    self:StartTimer("ToGame",1,function ()
        self.Time = self.Time - 1
        if self.Time == 0 then
            self:StopTimer("ToGame")
            self:BackGame()
        end
        self:FindChild("BG/Time").text = self.Time
    end,-1)
end

function GuideToGameView:InitTextByLanguage()
    self.language = self:GetLanguage()
    self:FindChild("BG/Text1").text = self.language.guide1
    self:FindChild("BG/Text2").text = self.language.guide2
end

function GuideToGameView:AddClickEvent()
    self:AddClick("BG/Button","Destroy")
end

function GuideToGameView:BackGame()
    local id = CC.ViewManager.GetExitToGuideId()
    if id then
        CC.ViewManager.SetExitToGuideId(nil)
        CC.HallUtil.CheckAndEnter(id)
    end
end

function GuideToGameView:OnDestroy()
    --玩家拒绝自动拉回游戏，也将数据置nil
    CC.ViewManager.SetExitToGuideId(nil)
end

return GuideToGameView