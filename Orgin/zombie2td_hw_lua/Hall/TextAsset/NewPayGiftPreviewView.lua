local CC = require("CC")
local NewPayGiftPreviewView = CC.uu.ClassView("NewPayGiftPreviewView")
local M = NewPayGiftPreviewView

--[[
累充奖励预览页
@param
rechargeCfg
boxCfg
]]
function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param or {}
	self.rechargeCfg = param.rechargeCfg
	self.boxCfg = param.boxCfg
	self.autoScrollList = {}
end

function M:OnCreate()

	self:AddClick("Close","ActionOut")
    self:InitPreviewPanel()
end

function M:InitPreviewPanel()
	local prefab = self:FindChild("ListItem")
	local parent = self:FindChild("Scroll View/Viewport/Content")
	for i=1,8 do
		local data = self.boxCfg["box"..i]
		local listObj = CC.uu.newObject(prefab,parent)
		listObj:FindChild("Bg"):SetActive(i%2==0)
		self:SetImage(listObj:FindChild("Box/Image"),data.boxImg)
		listObj:FindChild("Box/Image"):GetComponent("Image"):SetNativeSize()
		listObj:FindChild("Box/Text").text = self.rechargeCfg[i]..CC.CurrencyDefine.CurrencySymbol
		local autoScroll = CC.ViewCenter.AutoScroll.new()
		table.insert(self.autoScrollList,autoScroll)
		local param = {}
		param.parent = listObj:FindChild("List")
		param.list = data.list
		param.type = 1
		autoScroll:Create(param)
		autoScroll:SetTrundleState(true)
		listObj:SetActive(true)
	end
end

function M:ActionIn()
	
end

function M:OnDestroy()
	for _,v in ipairs(self.autoScrollList) do
		if v then
			v:Destroy()
			v = nil
		end
	end
end

return NewPayGiftPreviewView