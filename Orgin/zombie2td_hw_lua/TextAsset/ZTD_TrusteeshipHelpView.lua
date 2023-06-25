local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TrusteeshipHelpView = ZTD.ClassView("ZTD_TrusteeshipHelpView")
function TrusteeshipHelpView:ctor(descStr)
	self._desc = descStr;
end

function TrusteeshipHelpView:OnCreate()	
	self:PlayAnimAndEnter();	
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	self:FindChild("root/Buttons/btn_confirm/txt").text = language.txt_btn_confirm
	self:AddClick("root/Buttons/btn_confirm","PlayAnimAndExit")
	self:AddClick("bg","PlayAnimAndExit")
	local txtdesc = self:FindChild("root/ItemList/Viewport/txt_desc")
    txtdesc.text = self._desc;
end


return TrusteeshipHelpView