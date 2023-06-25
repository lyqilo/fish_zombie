
local CC = require("CC")
local SpecialRewardView = CC.uu.ClassView("SpecialRewardView")

function SpecialRewardView:ctor(param)
    self.param = param or {}
    self.language = self:GetLanguage()
    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
end

function SpecialRewardView:OnCreate()
    
    self:FindChild("Title/Text").text = self.param.title or ""
    self:FindChild("BgText").text = self.language.anyContinue
    self:FindChild("MoreBtn/Text").text = self.language.morePrivi

    if self.param.moreFun then
        self:FindChild("MoreBtn"):SetActive(true)
        self:AddClick(self:FindChild("MoreBtn"),function()
            self.param.moreFun()
            self:Destroy()
        end)
    else
        self:FindChild("MoreBtn"):SetActive(false)
    end
    if self.param.rewards and #(self.param.rewards) > 0 then
        local parent = self:FindChild("RewardNode")
        local prefab = parent:FindChild("Item")
        for i,v in ipairs(self.param.rewards) do
            local item = CC.uu.newObject(prefab,parent)
            self:SetImage(item:FindChild("Icon"),type(v.ConfigId) == "string" and v.ConfigId or self.propCfg[v.ConfigId].Icon)
            item:FindChild("Num").text = v.Count
            item:FindChild("Name").text = v.Des or self.propLanguage[v.ConfigId] 
            item:SetActive(true)
        end
    end

    self:CheckMonthCard()

    self:AddClick(self:FindChild("BgBtn"),"ActionOut")
end

function SpecialRewardView:CheckMonthCard()
    if self.param.showCard1 or self.param.showCard2 then
        self:FindChild("Title/Normal"):SetActive(false)
        self:FindChild("Title/Text"):SetActive(false)
        if self.param.showCard1 then
            self:FindChild("Title/Card1"):SetActive(true)
            self:FindChild("Title/CardTit1"):SetActive(true)
        else
            self:FindChild("Title/Card2"):SetActive(true)
            self:FindChild("Title/CardTit2"):SetActive(true)
        end
    else
        self:FindChild("Title/Normal"):SetActive(true)
        self:FindChild("Title/Text"):SetActive(true)
        self:FindChild("Title/Card1"):SetActive(false)
        self:FindChild("Title/CardTit1"):SetActive(false)
        self:FindChild("Title/Card2"):SetActive(false)
        self:FindChild("Title/CardTit2"):SetActive(false)
    end
end

return SpecialRewardView