local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

--通用框：用于跳场提示框,点击推送框，层级可设置，打开会调用Open方法不会关闭多余UI界面

local ExtendPopView = ZTD.ClassView("ZTD_ExtendPopView")

function ExtendPopView:ctor(str, confirmFunc, cancelFunc, confirmTxt, cancelTxt, sortingOrder)
	self.sortingOrder = sortingOrder
    self.str = str
    self.confirmFunc = confirmFunc
    self.cancelFunc = cancelFunc   
	self.confirmTxt = confirmTxt
	self.cancelTxt = cancelTxt
end

function ExtendPopView:OnCreate()

	self:PlayAnimAndEnter()

	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig")
	self.confirm = self:FindChild("root/confirm")
	self.cancel = self:FindChild("root/cancel")
	self.canvas = self.transform:GetComponent("Canvas")

	if not self.cancelFunc then
		self.cancel:SetActive(false)
		local pos = self.confirm.localPosition
		self.confirm.localPosition = Vector3(0, pos.y, pos.z)
	end

	if self.str then
		self:FindChild("root/Content").text = self.str
	end
	
	if self.confirmTxt then
		self:FindChild("root/confirm/text").text = self.confirmTxt
	else
		self:FindChild("root/confirm/text").text = language.txt_btn_confirm
	end
	
	if self.cancelTxt then
		self:FindChild("root/cancel/text").text = self.cancelTxt
	else
		self:FindChild("root/cancel/text").text = language.txt_btn_cancle
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
end	

function ExtendPopView:OnDestroy()
	
end

return ExtendPopView