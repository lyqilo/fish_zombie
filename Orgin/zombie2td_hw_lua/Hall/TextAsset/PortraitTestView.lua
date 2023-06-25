local CC = require("CC")
local PortraitTestView = CC.uu.ClassView("PortraitTestView")
local M = PortraitTestView

local testView = {
	["PersonalInfoView"] = {},
	["GameExitTipView"] = {gameList = {1003,1009,1015},gameFunc=function(id,defaultFunc)CC.uu.SafeDoFunc(defaultFunc)end},
	["SetUpView"] = {},
	["SelectGiftCollectionView"] = {},
	["FreeChipsCollectionView"] = {},
	["DailyGiftCollectionView"] = {},
	["MessageBox"] = {testFunc = function()	CC.ViewManager.ShowMessageBox("测试") end}
}

function M:GlobalNode()
	return GameObject.Find("GNode/GPortraitCanvas/GMain").transform
end

function M:ctor(param)
end

function M:OnCreate()

    self:InitContent()
	self:InitBtnGroup()
end

function M:InitContent()
	self.btnPrefab = self:FindChild("Button")
	self.btnGroup = self:FindChild("Group")
	
	self:AddClick("BtnClose","OnClickExit")
end

function M:InitBtnGroup()
	for k,v in pairs(testView) do
		local btn = CC.uu.newObject(self.btnPrefab,self.btnGroup)
		btn:FindChild("Text").text = k
		self:AddClick(btn,function ()
				if v.testFunc then
					CC.uu.SafeDoFunc(v.testFunc)
				else
					CC.ViewManager.Open(k,v)
				end
			end)
		btn:SetActive(true)
	end
end

function M:OnClickExit()
	self:SetCanClick(false);
	self:DelayRun(0.5, function()
			CC.HallUtil.RotateCamera()
			self:Destroy()
		end)
end

function M:ActionIn()
	
end

function M:OnDestroy()

end

return PortraitTestView