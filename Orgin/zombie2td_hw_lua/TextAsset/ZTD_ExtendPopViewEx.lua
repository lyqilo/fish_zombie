local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

--通用框：仅用于藏宝阁碎片不足弹框，层级可设置，打开会调用Open方法不会关闭多余UI界面

local ExtendPopViewEx = ZTD.ClassView("ZTD_ExtendPopViewEx")

function ExtendPopViewEx:ctor(str, confirmFunc, cancelFunc, sortingOrder)
	self.sortingOrder = sortingOrder
    self.str = str
    self.confirmFunc = confirmFunc
	self.cancelFunc = cancelFunc
end

function ExtendPopViewEx:OnCreate()

	self:PlayAnimAndEnter()
	self.confirm = self:FindChild("root/confirm")
	self.cancel = self:FindChild("root/cancel")
	self.canvas = self.transform:GetComponent("Canvas")

	if self.cancelFunc then
		self.cancel:SetActive(true)
		self.confirm.localPosition = Vector3(100, -100, 0)
	else
		self.cancel:SetActive(false)
		self.confirm.localPosition = Vector3(0, -100, 0)
	end

	if self.str then
		self:FindChild("root/Content").text = self.str
	end

	self.canvas.sortingOrder = self.sortingOrder or self.canvas.sortingOrder

    self:AddClick("root/confirm",function()
		local function cb()
			if self.confirmFunc then
				self.confirmFunc()
			end

			self:Destroy()
		end
		self:PlayAnimAndExit(cb);		
    end)

	self:AddClick("root/cancel",function()
		local function cb()
			if self.cancelFunc then
				self.cancelFunc()
			end
			self:Destroy()
		end
		self:PlayAnimAndExit(cb);		
    end)

    self:AddClick("root/close",function()
		local function cb()
			self:Destroy()
		end
		self:PlayAnimAndExit(cb);	
	end)
end	

function ExtendPopViewEx:OnDestroy()
	
end

return ExtendPopViewEx