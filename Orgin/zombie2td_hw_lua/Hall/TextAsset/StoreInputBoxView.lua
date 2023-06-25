
local CC = require("CC")

local StoreInputBoxView = CC.uu.ClassView("StoreInputBoxView")

--[[
@param
inputType:点卡输入类型
inputCallback: 回调方法
closeCallback: 点击关闭按钮回调
]]
function StoreInputBoxView:ctor(param)

	self:InitVar(param);
end

function StoreInputBoxView:OnCreate()

	self:InitContent();
end

function StoreInputBoxView:InitVar(param)

	self.param = param;

	self.storeDefine = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine");

	self.language = CC.LanguageManager.GetLanguage("L_StoreView");
end

function StoreInputBoxView:InitContent()

	-- self.transform:GetComponent("Canvas").sortingOrder = 100

	local title = self:FindChild("Frame/Top/Title");
	title.text = self.param.title;

	local icon = self:FindChild("Frame/IconFrame/Icon");
	icon:SetImage(self.param.iconImage);

	if self.param.inputType == self.storeDefine.InputBoxType.Double then
		local InputField2 = self:FindChild("Frame/ConSizeFitter/InputField2");
		InputField2:SetActive(true);
	end

	self:AddClick("Frame/BtnOk", "OnClickOk")

	self:AddClick("Frame/BtnClose", "OnClickClose");

	self:InitTextByLanguage();
end

function StoreInputBoxView:InitTextByLanguage()

	local language = CC.LanguageManager.GetLanguage("L_StoreView");

	local des = self:FindChild("Frame/ConSizeFitter/Des");
	des.text = language.msgboxTitle;

	local btnOk = self:FindChild("Frame/BtnOk/Text");
	btnOk.text = language.btnOk;
end

function StoreInputBoxView:OnClickOk()

	if self.param.inputCallback then
		local data = {};
		data.pinCode = self:FindChild("Frame/ConSizeFitter/InputField1/Text").text;
		data.serialCode = self:FindChild("Frame/ConSizeFitter/InputField2/Text").text;
		
		if self.param.inputType == self.storeDefine.InputBoxType.Single then
			if data.pinCode == "" then
				CC.ViewManager.ShowTip(self.language.molTip);
				return;
			end
		elseif self.param.inputType == self.storeDefine.InputBoxType.Double then
			if data.pinCode == "" or data.serialCode == "" then
				CC.ViewManager.ShowTip(self.language.molTip);
				return;
			end
		end

		self.param.inputCallback(data);
	end
end

function StoreInputBoxView:OnClickClose()
	if self.param.closeCallback then
		self.param.closeCallback();
	end
	self:ActionOut();
end

return StoreInputBoxView;
