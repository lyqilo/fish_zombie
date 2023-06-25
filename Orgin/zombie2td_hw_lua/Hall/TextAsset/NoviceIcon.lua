local CC = require("CC")
local NoviceIcon = CC.uu.ClassView("NoviceIcon")

--param
--parent:挂载的父节点

function NoviceIcon:Create(param)
	self:InitVar(param)
	self:InitContent()
	self:AddClickEvent()
end

function NoviceIcon:InitVar(param)
	self.param = param
	self.layer = self.param.layer
end

function NoviceIcon:InitContent()
	self.transform = CC.uu.LoadHallPrefab("prefab","NoviceBtn",self.param.parent)
	self:RefreshUI(self.param.data)
end

function NoviceIcon:AddClickEvent()
	self:AddClick(self.transform:FindChild("Novice"),"OpenSelectNovice")
end

function NoviceIcon:OpenSelectNovice()
	logError("----------接口已作废，请接新的礼包合集-----------")
end

function NoviceIcon:RefreshUI()
	self.transform:SetActive(true)
	self.transform:FindChild("Novice/RedDot"):SetActive(true)
	if self.layer then
		local layerTable = self.transform:GetComponentsInChildren(typeof(UnityEngine.Transform),true)
	    for k,v in pairs(layerTable:ToTable())  do
	   		v.gameObject.layer = self.layer
		end
	end
end

function NoviceIcon:Destroy()
	if self.transform then
		CC.uu.destroyObject(self.transform)
		self.transform = nil
	end
end

return NoviceIcon