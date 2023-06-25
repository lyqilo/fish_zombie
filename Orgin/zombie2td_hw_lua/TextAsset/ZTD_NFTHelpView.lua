local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local HelpView = ZTD.ClassView("ZTD_NFTHelpView")

function HelpView:OnCreate()

	self.helpType = self._args[1]
	self.data = self._args[2]
	self:PlayAnimAndEnter();
    self.isLoadOK = false
    self.RankDataList = {}
    self.o_DrugItemParent = self:FindChild("root/ScrollView/Viewport/Content")
    self.Des = self:FindChild("root/Des")
    self.Des:SetActive(false)
    self.Des2 = self:FindChild("root/Des2")
    self.Des2:SetActive(false)	
	self:InitLan()
	
	local tmp = {"dayPool","seasonPool","pack"}
	for i=1,3 do
		self:FindChild("root/"..tmp[i].."Title"):SetActive(tmp[i] == self.helpType)
	end
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
	
	if self.helpType == "seasonPool" then
		self:InitSeasonPool()
	else
		self:InitUI()
	end
    
end

function HelpView:InitSeasonPool()
    self:DelayRun(0.01, function()
        local language = self.lan[self.helpType]
        for i=1,#language.pool1 do
            local desInfo = language.pool1[i]	
			self:CreateUIItem(desInfo, self.Des2)	
        end
		-- if self.data then
		-- 	for _,v in ipairs(self.data) do
		-- 		local str
		-- 		if v.start_rank == v.end_rank then
		-- 			str = string.format(language.poolItem1, 
		-- 				v.start_rank, v.ratio*100, v.ratio*100)
		-- 		else
		-- 			str = string.format(language.poolItem2, 
		-- 				v.start_rank, v.end_rank, v.ratio*100, v.ratio*100)
		-- 		end
		-- 		self:CreateUIItem(str, self.Des2)
		-- 	end
		-- end
		
        for i=1,#language.pool2 do
            local desInfo = language.pool2[i]	
			self:CreateUIItem(desInfo, self.Des2)	
        end
        self.isLoadOK = true
    end)
end
function HelpView:InitUI()
    self:DelayRun(0.01, function()
        local language = self.lan[self.helpType]
        for i=1,#language do
            local desInfo = language[i]	
			self:CreateUIItem(desInfo, self.Des2)	
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