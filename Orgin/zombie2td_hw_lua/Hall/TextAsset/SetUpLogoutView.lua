
local CC = require("CC")

local SetUpLogoutView = CC.uu.ClassView("SetUpLogoutView")

function SetUpLogoutView:OnCreate()

	self:InitContent();
	
	self:InitTextByLaguage();
end

function SetUpLogoutView:InitContent()


	self:AddClick("Frame/BtnOk", "OnClickBtnOk");

	self:AddClick("Frame/BtnCancel", "ActionOut");

	self:AddClick("Frame/BtnClose", "ActionOut");
end

function SetUpLogoutView:InitTextByLaguage()

	local language = CC.LanguageManager.GetLanguage("L_SetUpView");

	local title = self:FindChild("Frame/Top/Title");
	title.text = language.logOutTitle;
	local des = self:FindChild("Frame/Tips/Text");
	des.text = language.logOutTips;
	local btnOk = self:FindChild("Frame/BtnOk/Text");
	btnOk.text = language.btnOk;
	local btnCancel = self:FindChild("Frame/BtnCancel/Text");
	btnCancel.text = language.btnCancel;
end

function SetUpLogoutView:OnClickBtnOk()

	local loginDefine = CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine");
	if CC.Player.Inst().GetCurLoginWay() == loginDefine.LoginWay.Facebook then
		CC.FacebookPlugin.Logout();
	elseif CC.Player.Inst().GetCurLoginWay() == loginDefine.LoginWay.Line then
		CC.LinePlugin.Logout();
	end
	CC.Player.Inst().SetCurLoginWay();
	CC.ViewManager.BackToLogin(loginDefine.LoginType.Logout);
end

return SetUpLogoutView;