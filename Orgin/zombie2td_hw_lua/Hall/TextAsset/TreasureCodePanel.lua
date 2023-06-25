---------------------------------
-- region TreasureCodePanel.lua		-
-- Date: 2019.11.11				-
-- Desc:  一元夺宝               -
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local TreasureCodePanel = CC.uu.ClassView("TreasureCodePanel")

function TreasureCodePanel:ctor(param)
	self:InitVar(param)
end

function TreasureCodePanel:InitVar(param)
    self.param = param
end

function TreasureCodePanel:OnCreate()

    self.language = CC.LanguageManager.GetLanguage("L_TreasureView");
    
    local viewCtrClass = require("View/TreasureView/TreasureCodePanelCtr")
	
    self.viewCtr = viewCtrClass.new(self,self.param);
    
    self.ScrollerController = self:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
    xpcall(function() self.viewCtr:SetCodeData(tran,dataIndex,cellIndex) end,function(error) logError(error) end) end)
    
    self.viewCtr:OnCreate()

    self:AddClickEvent()

    self:InitTextByLanguage()
end

function TreasureCodePanel:AddClickEvent()
    self:AddClick("BG/CloseBtn",function ()
        self:ActionOut()
    end)
end

function TreasureCodePanel:InitTextByLanguage()
    self:FindChild("BG/Title/Label").text = self.language.code_Title
end

function TreasureCodePanel:SetCodeList(count)
    self:FindChild("BG/Tips").text = string.format(self.language.code_Tips,count)
    self.ScrollerController:InitScroller(count)
end

function TreasureCodePanel:SetCodeItem(tran,data)
    local num = data
    local sWin = tostring(string.format("1%07d",num))
	local sLen = #sWin - 1
	local index = 1
	for i = 8-sLen, 8 do
		tran:FindChild(i.."/Text").text = string.sub(sWin,index,index)
		index = index + 1
	end
end

function TreasureCodePanel:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return TreasureCodePanel