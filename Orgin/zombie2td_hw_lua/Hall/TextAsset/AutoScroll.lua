local CC = require("CC")
local AutoScroll = CC.class2("AutoScroll")
local M = AutoScroll
local TYPE = {
	Horizontal = 1,--水平
	HorizontalSp = 2,--水平(特殊展示)
	HorizontalWorldCup = 3,--水平(特殊展示)
}

--[[
parent:父节点
list:物品列表 {--id物品id text文本 icon:显示icon,如果没有则默认物品icon
			{id,text},
			{id,text}}
type:滚动类型TYPE
]]
function M:Create(param)
	self.param = param
	self.type = param.type or TYPE.Horizontal
	self.list = param.list or {}
	self.speedX = param.speedX or 50
	self.startTrundle = false
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    self:InitContent()
end

function M:InitContent()
	
	self.transform = CC.uu.LoadHallPrefab("prefab", "AutoScroll", self.param.parent);
	
	if self.type == TYPE.Horizontal then
		self.frame = self.transform:FindChild("Horizontal")
	elseif self.type == TYPE.HorizontalSp then
		self.frame = self.transform:FindChild("HorizontalSp")
	elseif self.type == TYPE.HorizontalWorldCup then
		self.frame = self.transform:FindChild("HorizontalWorldCup")
	end
	self.scroll = self.frame:FindChild("Scroll View")
	self.container = self.frame:FindChild("Scroll View/Container")
	self.scrollRect = self.frame:FindChild("Scroll View"):GetComponent("ScrollRect")
	self.scrollCtrl = self.frame:FindChild("ScrollerController"):GetComponent("ScrollerController")
	
	self.scrollCtrl:AddChangeItemListener(function(trans,dataIndex,cellIndex)
			self:RefreshItem(trans,dataIndex)
		end)
	self.scrollCtrl:AddRycycleAction(function (trans)
			self:RycycleItem(trans)
		end)
	
	self.scrollCtrl:InitScroller(#self.list)
	self:CheckListNum()
end

function M:RefreshItem(trans,index)
	
	local dataIdx = index + 1
	local data = self.list[dataIdx]
	if not data or table.isEmpty(data) then
		return
	end
	trans.name = dataIdx
	if self.type == TYPE.HorizontalWorldCup then
		local spriteName = data.Icon
		if not string.match(spriteName,".png") then
			spriteName = spriteName..".png"
		end
		local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[spriteName];
		local imageCmp = trans:FindChild("Node/Icon"):GetComponent("Image")
		imageCmp.sprite = CC.uu.LoadImgSprite(spriteName,abName);
		imageCmp:SetNativeSize()
		trans:FindChild("Node/Text").text = data.Text
		trans:FindChild("Node/Des").text = data.Des
		trans:FindChild("Node/D1"):SetActive(data.Di)
		trans:FindChild("Node/D2"):SetActive(not data.Di)
		trans:FindChild("Node/Icon2"):SetActive(false)
		if data.Text == "บัตรเควสเดิมพัน\nรางวัลสองเท่า" then
			trans:FindChild("Node/effect"):SetActive(true)
		end
		if dataIdx == 2 then
			trans:FindChild("Node/Icon2"):SetActive(true)
		end
	else
		local spriteName = (data.icon and data.icon ~= "") and data.icon or self.propCfg[data.id].Icon
		if not string.match(spriteName,".png") then
			spriteName = spriteName..".png"
		end
		local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[spriteName];
		local imageCmp = trans:FindChild("Node/Icon"):GetComponent("Image")
		imageCmp.sprite = CC.uu.LoadImgSprite(spriteName,abName);
		imageCmp:SetNativeSize()
		trans:FindChild("Node/Text").text = data.text
	end
	
	if self.type == TYPE.HorizontalSp then
		trans:FindChild("Node").localPosition = dataIdx%2 == 0 and Vector3(0,-18,0) or Vector3(0,18,0)
	elseif self.type == TYPE.HorizontalWorldCup then
		-- trans:FindChild("Node").localPosition = dataIdx%2 == 0 and Vector3(0,-18,0) or Vector3(0,18,0)
		-- trans:FindChild("Node").localPosition = Vector3(-30,0,0)
	end
end

function M:RycycleItem(trans)
	--local index = tonumber(trans.transform.name)
end

function M:CheckListNum()
	local itemSize = self.frame:FindChild("Item").width
	if self.type == TYPE.HorizontalWorldCup then
		itemSize = self.frame:FindChild("Item").height
	end
	local scrollSize = self.scroll.rect.width
	local num = scrollSize/itemSize
	if #self.list > num then
		self.scroll:GetComponent("EnhancedScroller").Loop = true
		UpdateBeat:Add(self.Update,self)
	end
end

function M:SetTrundleState(bool)
	self.startTrundle = bool
end

function M:Update()
	if not self.transform then return end
	if not self.startTrundle then return end
	local posX = self.container.localPosition.x
	self.container.localPosition = Vector3(posX-self.speedX*Time.deltaTime,0,0)
end

function M:Destroy()
	
	UpdateBeat:Remove(self.Update,self)
end

return AutoScroll