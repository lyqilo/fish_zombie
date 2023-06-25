local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

--通用框：仅用于各种退出游戏的提示框，层级高于各UI界面，打开会调用OpenMessageBox方法关闭多余UI界面

local PopView = ZTD.ClassView("ZTD_PopView")

function PopView:GlobalNode()
    return GameObject.Find("Main/Canvas/TopUIPanal").transform
end

function PopView:ctor(str,confirmFunc,cancelFunc, confirmTxt, cancelTxt)
    self.str = str
    self.confirmFunc = confirmFunc
    self.cancelFunc = cancelFunc   
	self.confirmTxt = confirmTxt;
	self.cancelTxt = cancelTxt;
end

function PopView:SetDestroyCall(cb)
	self._destoryCalc = cb;
end

function PopView:OnDestroy()
	if self._destoryCalc then
		self._destoryCalc();
	end
end	

function PopView:OnCreate()
	self:PlayAnimAndEnter();
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	self:FindChild("root/cancel/text").text = language.txt_btn_cancle
	self:FindChild("root/confirm/text").text = language.txt_btn_confirm
    local content = self:SubGet("root/Content","Text")
    content.text = self.str
	self.confirm = self:FindChild("root/confirm")
	self.cancel = self:FindChild("root/cancel")
	if not self.cancelFunc then
		self.cancel:SetActive(false)
		local pos = self.confirm.localPosition
		self.confirm.localPosition = Vector3(0, pos.y, pos.z)
	end
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
	
	if self.confirmTxt then
		self:FindChild("root/confirm/text").text = self.confirmTxt;
	end
	
	if self.cancelTxt then
		self:FindChild("root/cancel/text").text = self.cancelTxt;
	end	
end

return PopView