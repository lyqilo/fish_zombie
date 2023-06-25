
local CC = require("CC")
local MessageBox = require("View/OtherView/MessageBox")
local MessageBoxExtend = CC.uu.ClassView("MessageBoxExtend",nil,MessageBox)


--[[
@param
str:内容
okFunc:确定回调
noFunc:取消回调
layer：Layer
posX：文本框X坐标
posY：文本框Y坐标
width：文本框宽度
height：文本框高度
btnY:按钮Y坐标
btnOkText:确认按钮文本
btnNoText:取消按钮文本
]]
function MessageBoxExtend:ctor(param)
	self.str = param.str
	self.okFunc = param.okFunc
	self.noFunc = param.noFunc
    self.layer = param.layer
    self.posX = param.posX or 0
    self.posY = param.posY or 49.04
    self.width = param.width or 600
    self.height = param.height or 200
    self.btnY = param.btnY or -122
    self.btnOkText = param.btnOkText
    self.btnNoText = param.btnNoText
end

function MessageBoxExtend:CreateTransform(globalNode)
	return CC.uu.LoadHallPrefab("prefab",
		"MessageBox",
		globalNode,
		"MessageBox",
		self:GlobalLayer()
	)
end

function MessageBoxExtend:OnCreate()
    self.transform.z = -1000
    self.textBox = self:FindChild("Frame/Message")
    self.textBox.x = self.posX
    self.textBox.y = self.posY
    self.textBox.sizeDelta = Vector2(self.width,self.height)
    self:FindChild("Frame/BtnFitter").y = self.btnY
	self:SetText("Frame/Message", self.str)
	self:AddClick("Frame/BtnFitter/BtnOk", "OnClickOk")
	self:AddClick("Frame/BtnFitter/BtnNo", "OnClickNo")
	self:AddClick("Frame/BtnClose", "OnClickNo")
	self:SetTextByLanguage()

	self:ActionIn();
end

function MessageBoxExtend:SetTextByLanguage()
    --语言包
	self.language = CC.LanguageManager.GetLanguage("L_MessageBox");
	self:FindChild("Frame/BtnFitter/BtnOk/Text").text = self.btnOkText or self.language.btnOk
	self:FindChild("Frame/BtnFitter/BtnNo/Text").text = self.btnNoText or self.language.btnCancel
end

return MessageBoxExtend

