
local CC = require("CC")

local SetUpPolicyView = CC.uu.ClassView("SetUpPolicyView")

function SetUpPolicyView:OnCreate()

	self:InitContent();
	
	self:InitTextByLaguage();
end

function SetUpPolicyView:InitContent()

	self:AddClick("Frame/BtnClose", "ActionOut");
end

function SetUpPolicyView:InitTextByLaguage()

	local language = CC.LanguageManager.GetLanguage("L_SetUpView");

	local title = self:FindChild("Frame/Tab/Title");
	title.text = language.policyTitle;
	local clauseContent = self:FindChild("Frame/Clause/ScrollView/ItemPanel/Text");
	clauseContent.text = language.clauseContent
	local policyContent = self:FindChild("Frame/Policy/ScrollView/ItemPanel/Text");
	policyContent.text = language.policyContent
end

return SetUpPolicyView;