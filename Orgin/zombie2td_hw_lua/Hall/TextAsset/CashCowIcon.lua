local CC = require("CC")
local M = CC.uu.ClassView("CashCowIcon")

--param
--parent:挂载的父节点

function M:Create(param)
	self:InitVar(param)
	self:InitContent()
end

function M:InitVar(param)
	self.param = param
end

function M:InitContent()
	self.transform = CC.uu.LoadHallPrefab("prefab","CashCowIcon",self.param.parent)
	self:AddClickEvent()
end

function M:AddClickEvent()
	self:AddClick("yqs_shu","OpenCashCowView")
end

function M:OpenCashCowView()
    CC.ViewManager.Open("CashCowView")
end

function M:Destroy()
	if self.transform then
		CC.uu.destroyObject(self.transform)
		self.transform = nil
	end
end

return M