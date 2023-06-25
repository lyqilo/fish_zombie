local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local PoolHelpView = ZTD.ClassView("ZTD_PoolHelpView")

function PoolHelpView:ctor(idx)
    self.idx = idx
end

function PoolHelpView:OnCreate()
	self:PlayAnimAndEnter()
    self:InitData()
    self:InitUI()
    self:InitEvent()
end

function PoolHelpView:InitData()
    self.isLoadOK = false
    self.o_DrugItemParent = self:FindChild("root/ScrollView/Viewport/Content")
    self.Des = self:FindChild("root/Des")
    self.Des2 = self:FindChild("root/Des2")
end

function PoolHelpView:InitUI()
    self.Des:SetActive(false)
    self.Des2:SetActive(false)	
    ZTD.GameTimer.DelayRun(0.01, function()
        local language = ZTD.LanguageManager.GetLanguage("L_ZTD_HelpConfig")
        local desInfo = language[self.idx]
        for j=1, #desInfo do
            if j == 1 then
                self:CreateUIItem(desInfo[j], self.Des)
            else	
                self:CreateUIItem(desInfo[j], self.Des2)
            end	
        end
        self.isLoadOK = true
    end)
end

function PoolHelpView:InitEvent()
    self:AddClick("root/back",function()
        if self.isLoadOK then
            self:PlayAnimAndExit()
        end
    end)
	self:AddClick("Mask", function()
        if self.isLoadOK then
            self:PlayAnimAndExit()
        end
    end)
end

function PoolHelpView:CreateUIItem(des, desItem)
    local item = tools.newObject(desItem)
    item:SetActive(true)
    item:SetParent(self.o_DrugItemParent)
    item.localScale = Vector3.one
    item:GetComponent("Text").text = des
	return item
end

return PoolHelpView