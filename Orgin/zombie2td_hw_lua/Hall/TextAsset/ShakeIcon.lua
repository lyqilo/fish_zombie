local CC = require("CC")
local ShakeIcon = CC.uu.ClassView("ShakeIcon")

--param
--parent:挂载的父节点

function ShakeIcon:Create(param)
	self.ShakeData = CC.DataMgrCenter.Inst():GetDataByKey("ShakeData")
	self:RegisterEvent()
	self:InitVar(param)
	self:InitContent()
end

function ShakeIcon:InitVar(param)
	self.param = param
	self.layer = self.param.layer
	self.GameId = self.param.GameId
end

function ShakeIcon:InitContent()
	self:Req_Ask()
	self.transform = CC.uu.LoadHallPrefab("prefab", "ShakeBtn", self.param.parent)
	self.transform:SetActive(false)
	self.effParent = self:FindChild("cs_hd_rktb/Particle System")
	self:RefreshUI()
	self:AddClickEvent()
end

function ShakeIcon:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.Resp_Ask, CC.Notifications.NW_ReqShakeAsk)
	CC.HallNotificationCenter.inst():register(self, self.OnpushShakeClose, CC.Notifications.OnpushShakeClose)
	CC.HallNotificationCenter.inst():register(self, self.OnpushShake, CC.Notifications.OnpushShake)
end

function ShakeIcon:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqShakeAsk)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnpushShake)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnpushShakeClose)
end

function ShakeIcon:OnpushShake()
	self.effParent:SetActive(self.ShakeData.GetExistState())
	self.transform:FindChild("RedDot"):SetActive(self.ShakeData.GetExistState())
	self:FindChild("cs_hd_rktb"):GetComponent("Animator").enabled = self.ShakeData.GetExistState()
	self.transform:SetActive(self.ShakeData.GetExistState())
end

function ShakeIcon:SetLayerOrder(layerName, Order, effLayerName, effOrder)
	-- local an = self:FindChild("cs_hd_rktb/an")
	-- if an then
	-- 	local ancanvas = an:GetComponent("Canvas")
	-- 	if ancanvas then
	-- 		ancanvas.sortingLayerName = layerName
	-- 		ancanvas.sortingOrder = Order
	-- 	end
	-- end
	if self.effParent then
		local layerTable = self.effParent:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
		for k, v in pairs(layerTable:ToTable()) do
			v.sortingLayerName = effLayerName
			v.sortingOrder = effOrder
		end
	end
	-- local ret = self.transform:FindChild("RedDot")
	-- if ret then
	-- 	local retcanvas = ret:GetComponent("Canvas")
	-- 	if retcanvas then
	-- 		retcanvas.sortingLayerName = layerName
	-- 		retcanvas.sortingOrder = Order
	-- 	end
	-- end
end

function ShakeIcon:SetEffectScale(param)
	if self.effParent then
		local layerTable = self.effParent:GetComponentsInChildren(typeof(UnityEngine.Transform), true)
		for k, v in pairs(layerTable:ToTable()) do
			v.transform.localScale = Vector3(param[1], param[2], param[3])
		end
	end
end

function ShakeIcon:AddClickEvent()
	self:AddClick(self.transform, "ReqShake")
end

function ShakeIcon:ReqShake()
	CC.ViewManager.OpenEx("ShakeView", self.GameId, self.param.callback)
end

function ShakeIcon:OnpushShakeClose()
	local show = self.ShakeData.GetExistState()
	self.transform:FindChild("RedDot"):SetActive(show)
	self:FindChild("cs_hd_rktb"):GetComponent("Animator").enabled = show
	self.effParent:SetActive(show)
	self.transform:SetActive(show)
end

function ShakeIcon:Resp_Ask(err, data)
	if err == 0 then
		self.ShakeData.SetExistState(data.Exist)
		self:OnpushShake()
		self.transform:SetActive(self.ShakeData.GetExistState())
	else
		self.ShakeData.SetExistState(false)
		self.transform:SetActive(self.ShakeData.GetExistState())
	end
end

function ShakeIcon:RefreshUI()
	if self.layer then
		local layerTable = self.transform:GetComponentsInChildren(typeof(UnityEngine.Transform), true)
		for k, v in pairs(layerTable:ToTable()) do
			v.gameObject.layer = self.layer
		end
	end
end

function ShakeIcon:Req_Ask()
	CC.Request("ReqShakeAsk")
end

function ShakeIcon:Destroy()
	if self.transform then
		CC.uu.destroyObject(self.transform)
		self.transform = nil
	end
	self:unRegisterEvent()
end

return ShakeIcon
