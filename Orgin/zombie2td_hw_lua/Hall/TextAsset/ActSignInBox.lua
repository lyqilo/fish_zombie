
local CC = require("CC")
local ActSignInBox = CC.uu.ClassView("ActSignInBox")

function ActSignInBox:ctor(param)

	self.param = param or {};

	self.language = CC.LanguageManager.GetLanguage("L_ActSignInView");
end

function ActSignInBox:OnCreate()

	self:InitContent();

	self:InitTextByLanguage();
end

function ActSignInBox:InitContent()

	local toggle = self:FindChild("Frame/Content/Tip/Toggle");
	UIEvent.AddToggleValueChange(toggle, function(selected)
			if selected then
				CC.Player.Inst():SetActSignTipState(true);
			end	
		end)

	self:AddClick("Frame/BtnClose","ActionOut");

	self:AddClick("Frame/BtnOk", "OnClickOk");
end

function ActSignInBox:InitTextByLanguage()

	self:FindChild("Frame/Title").text = self.language.exTipTitle;
	self:FindChild("Frame/Content/Text").text = self.language.exTipContent;
	self:FindChild("Frame/Content/Tip").text = self.language.exTipToggle;
	self:FindChild("Frame/BtnOk/Text").text = self.language.btnOk;
end

function ActSignInBox:OnClickOk()
	if self.param.callback then
		self.param.callback();
	end
	self:ActionOut();
end

return ActSignInBox