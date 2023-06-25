local CC = require("CC")
local StarRatingView = CC.uu.ClassView("StarRatingView")

--[[
@param
reward:奖励（数值），不传则默认显示写死的数值
succCb:成功回调
errCb:失败回调
]]
function StarRatingView:ctor(param)
	self:InitVar(param)
end

function StarRatingView:InitVar(param)
	self.param = param or {}
    self.language = self:GetLanguage()

	self.reward = self.param.reward or "1000"
end

function StarRatingView:OnCreate()
    self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()

    self:InitContent()
	self:InitTextByLanguage()
end

function StarRatingView:InitContent()
	self:AddClick("Frame/BtnNotNow","OnClickBtnNotNow")
	self:AddClick("Frame/BtnClose","OnClickBtnNotNow")
	self:AddClick("Frame/BtnOK","OnClickBtnOK")
end

function StarRatingView:InitTextByLanguage()
	self:FindChild("Frame/Title/Text").text = self.language.title
	self:FindChild("Frame/Content/Text1").text = self.language.text1
	self:FindChild("Frame/Content/Text2").text = self.language.text2
	self:FindChild("Frame/Content/Text3").text = string.format(self.language.text3,self.reward)
	self:FindChild("Frame/BtnNotNow/Text").text = self.language.btnNotNow
	self:FindChild("Frame/BtnOK/Text").text = self.language.btnOK
end

function StarRatingView:OnClickBtnNotNow()
	CC.LocalGameData.SetLocalDataToKey("StarRatingView", CC.Player.Inst():GetSelfInfoByKey("Id"))
	if self.param.errCb then
		self.param.errCb()
	end
	self:ActionOut()
end

function StarRatingView:OnClickBtnOK()
	Client.ShowAppRate(true)
end

function StarRatingView:OnDestroy()
	
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end

end

return StarRatingView