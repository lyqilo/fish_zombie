
local CC = require("CC")
local ThirdGameTipView = CC.uu.ClassView("ThirdGameTipView")

function ThirdGameTipView:ctor(param)
	self.language = self:GetLanguage();
	self:InitVar(param);
end

function ThirdGameTipView:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:BtnClickEvent();
	self:InitTextByLanguage();
end

function ThirdGameTipView:InitVar(param)

	self.param = param or {}
end

function ThirdGameTipView:InitContent()

end

function ThirdGameTipView:InitTextByLanguage()
	local tips = self.language.tips1.."\n"..self.language.tips2
	self:FindChild("Panel/Bg/Yeqian/Text").text = self.language.title
	self:FindChild("Panel/Bg/Text").text = tips
	self:FindChild("Panel/Bg/Kuang/Tips3").text = self.language.tips3
	self:FindChild("Panel/Bg/NextBtn/Text").text = self.language.neBtn_Text
	self:FindChild("Panel/Bg/ContinueBtn/Text").text = self.language.conBtn_Text
end

function ThirdGameTipView:BtnClickEvent()

	self:AddClick(self:FindChild("Panel/Bg/NextBtn"),function ()
		if self.param.nextCallback then
			self.param.nextCallback()
		end
		self:ActionOut()
	end)

	self:AddClick(self:FindChild("Panel/Bg/ContinueBtn"),function ()
		if self.param.conCallback then
			self.param.conCallback()
		end
		self:ActionOut()
	end)
end

function ThirdGameTipView:OnDestroy()

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return ThirdGameTipView