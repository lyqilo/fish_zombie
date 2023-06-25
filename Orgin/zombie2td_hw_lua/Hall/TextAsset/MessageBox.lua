
local CC = require("CC")
local MessageBox = CC.uu.ClassView("MessageBox")

function MessageBox:ctor(str, okFunc, noFunc, layer, confirmSec)
	self.str = str
	self.okFunc = okFunc
	self.noFunc = noFunc
	self.layer = layer
	self.confirmSec = confirmSec
end

function MessageBox:CreateTransform(globalNode)
	return CC.uu.LoadHallPrefab("prefab",
		"MessageBox",
		globalNode,
		"MessageBox",
		self:GlobalLayer()
	)
end

function MessageBox:Create()
	local globalNode = nil
	if LuaFramework.SceneManager.GetCurSceneName() == CC.ViewManager.GetHallRootSceneName() then
		globalNode = GameObject.Find("Main/Canvas/Extend").transform
	else
		self:AddToDontDestroyNode();
		globalNode = GameObject.Find("DontDestroyGNode/GCanvas/GExtend").transform
	end

	self.transform = self:CreateTransform(globalNode)
	CC.uu.SafeCallFunc(self.OnCreate, self)

	-- if self.layer then
	-- 	local selfCanvas = self.transform:GetComponent("Canvas");
	-- 	selfCanvas.sortingOrder = self.layer;
	-- end
end

function MessageBox:OnCreate()
	self.transform.z = -1000
	self.countdownText = self:FindChild("Frame/Countdown")
	self:SetText("Frame/Message", self.str)
	self:AddClick("Frame/BtnFitter/BtnOk", "OnClickOk")
	self:AddClick("Frame/BtnFitter/BtnNo", "OnClickNo")
	self:AddClick("Frame/BtnClose", "OnClickNo")
	self:SetTextByLanguage()

	self:ActionIn();
	self:CheckCountdown()
end

function MessageBox:SetTextByLanguage()
	--语言包
	self.language = self:GetLanguage();
	self:FindChild("Frame/BtnFitter/BtnOk/Text").text = self.language.btnOk
	self:FindChild("Frame/BtnFitter/BtnNo/Text").text = self.language.btnCancel
end

function MessageBox:OnClickOk()
	self:ActionOut()
	if self.okFunc then
		self:okFunc()
	end
end

function MessageBox:OnClickNo()
	self:ActionOut()
	if self.noFunc then
		self:noFunc()
	end
end

function MessageBox:SetOkText(text)
	self:SetText("Frame/BtnFitter/BtnOk/Text", text)
end

function MessageBox:SetNoText(text)
	self:SetText("Frame/BtnFitter/BtnNo/Text", text)
end

function MessageBox:SetMsgText(text)
	self:SetText("Frame/Message", text)
end

function MessageBox:SetOneButton()
	self:Hide("Frame/BtnFitter/BtnNo")
end

function MessageBox:SetCloseBtn()
	self:Show("Frame/BtnClose")
	self:Hide("Frame/BtnFitter/BtnNo")
end

function MessageBox:ConvertBtnPos()
	self:FindChild("Frame/BtnFitter").localScale = Vector3(-1,1,1)
	self:FindChild("Frame/BtnFitter/BtnNo").localScale = Vector3(-1,1,1)
	self:FindChild("Frame/BtnFitter/BtnOk").localScale = Vector3(-1,1,1)
end

function MessageBox:CheckCountdown()
	if self.confirmSec then
		self.countdownText.text = string.format(self.language.countdown,self.confirmSec)
		self:StartTimer("confirm",1,function ()
				self.confirmSec = self.confirmSec - 1
				self.countdownText.text = string.format(self.language.countdown,self.confirmSec)
				if self.confirmSec <= 0 then
					self:StopTimer("confirm")
					self:OnClickOk()
				end
			end,-1)
	end
end

return MessageBox

