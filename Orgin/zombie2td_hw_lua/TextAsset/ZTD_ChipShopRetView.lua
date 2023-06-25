local GC = require("GC")
local ZTD = require("ZTD")

local ChipShopRetView = ZTD.ClassView("ZTD_ChipShopRetView")

function ChipShopRetView:ctor(data)
    self.chipRetID = data.PropsID
    self.chipRetNum = data.buyChipNum
end

function ChipShopRetView:OnCreate()
    ZTD.PlayMusicEffect("ZTD_congratulations",nil, nil, true)
	self:PlayAnimAndEnter()
    self:InitData()
    self:InitUI()
    self:AddEvent()
end

function ChipShopRetView:InitData()
    self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_GiftCollectionView")
    self.chipRetNumText = self:FindChild("root/retNode/Text"):GetComponent("Text")
    self.chipRetIcon = self:FindChild("root/retNode/Image"):GetComponent("Image")
    self.titleText = self:FindChild("root/title/Text"):GetComponent("Text")
end

--获取对应图片
function ChipShopRetView:GetSprite(id)
    if id == 1112 then
        return "tf_bs1"
    elseif id == 1113 then
        return "tf_bs2"
    elseif id == 1114 then
        return "tf_bs3"
    elseif id == 1115 then
        return "tf_bs4"
    end
end

function ChipShopRetView:InitUI()
    self.chipRetNumText.text = self.chipRetNum
    self.titleText.text = self.language.txt_chipShopRet_title
    local str = self:GetSprite(self.chipRetID)
    self.chipRetIcon.sprite = ZTD.Extend.LoadSprite("prefab", str)
    self.chipRetIcon:SetNativeSize()
end

function ChipShopRetView:AddEvent()
    self:AddClick("root/confirmBtn", "PlayAnimAndExit")
end

function ChipShopRetView:OnDestroy()
    
end

return ChipShopRetView