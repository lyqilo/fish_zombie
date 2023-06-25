
local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local RealStoreIcon = CC.class2("RealStoreIcon",ViewUIBase)

function RealStoreIcon:OnCreate(param)
	self:InitVar(param)
	self:InitContent()
end

function RealStoreIcon:InitVar(param)
	self.param = param or {}
	self.HallLanguage = CC.LanguageManager.GetLanguage("L_HallView")
	self.StoreView = nil
end

function RealStoreIcon:InitContent()
	self.icon = self.transform:FindChild("icon")
	self:AddClick(self.icon, "OpenRealStoreView")
end

function RealStoreIcon:OpenRealStoreView()
	local param = {}
	param.OpenViewId = self.param.OpenViewId
	param.closeFunc = function()
		self.StoreView = nil
		if self.param.closeFunc then
			self.param.closeFunc()
		end
	end
	self.StoreView = CC.ViewManager.Open("TreasureView",param)
end

function RealStoreIcon:OnDestroy()
	if self.StoreView then
		self.StoreView:Destroy();
	end
end

return RealStoreIcon;
