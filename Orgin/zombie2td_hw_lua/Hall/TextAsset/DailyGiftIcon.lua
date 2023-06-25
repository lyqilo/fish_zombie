
local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local DailyGiftIcon = CC.class2("DailyGiftIcon",ViewUIBase)

function DailyGiftIcon:OnCreate(param)
    self.param = param
    self:InitTextByLanguage()
	self:InitVar(param);
end

function DailyGiftIcon:InitTextByLanguage()
	local language = CC.LanguageManager.GetLanguage("L_HallView")

    self.transform:FindChild("effect/TuBiao/Text").text = language.tipDaily
end

function DailyGiftIcon:InitVar(param)
    if param then
        -- self.transform = CC.uu.LoadHallPrefab("prefab", "DailyGiftIcon", param.parent);
        -- self.transform.gameObject.layer = param.parent.transform.gameObject.layer;
        if not param.isHall then
            self.transform:FindChild("effect"):SetActive(false)
            self.transform:FindChild("Effect"):SetActive(false)
        end
    end
    self:AddClick(self.transform:FindChild("icon"), function()
        CC.ViewManager.Open("DailyGiftCollectionView", {currentView = self.param.currentView, isHall = self.param.isHall})
    end)
end

return DailyGiftIcon