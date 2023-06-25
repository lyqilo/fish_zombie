local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local HelpView = ZTD.ClassView("ZTD_HelpView")

function HelpView:OnCreate()
	self:PlayAnimAndEnter();
    self.isLoadOK = false
    self.RankDataList = {}
    self.o_DrugItemParent = self:FindChild("root/ScrollView/Viewport/Content")
    self.Des = self:FindChild("root/Des")
    self.Des:SetActive(false)
    self.Des2 = self:FindChild("root/Des2")
    self.Des2:SetActive(false)	

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
	
    self:InitUI()
end

function HelpView:InitUI()
    ZTD.GlobalTimer.DelayRun(0.01, function()
        local language = ZTD.LanguageManager.GetLanguage("L_ZTD_HelpConfig");
        for i=1,#language do
            local desInfo = language[i]
            for j=1,#desInfo do
				if j == 1 then
					self:CreateUIItem(desInfo[j], self.Des)
				else	
					self:CreateUIItem(desInfo[j], self.Des2)
				end	
            end
        end
        self.isLoadOK = true
    end)
end

function HelpView:CreateUIItem(des, desItem)
    local item = tools.newObject(desItem)
    item:SetActive(true)
    item:SetParent(self.o_DrugItemParent)
    item.localScale = Vector3.one
    item:GetComponent("Text").text = des
	return item;
end

return HelpView