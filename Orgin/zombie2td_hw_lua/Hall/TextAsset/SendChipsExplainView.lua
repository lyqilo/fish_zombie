
local CC = require("CC")

local SendChipsExplainView = CC.uu.ClassView("SendChipsExplainView")

function SendChipsExplainView:OnCreate()
    self.subConfig = {{vipStr = "0",minSendCount = 150000},
                      {vipStr = "1",minSendCount = 250000},
                      {vipStr = "2",minSendCount = 400000},
	                  {vipStr = "3 - 19",minSendCount = 900000},
	                  {vipStr = "20",minSendCount = 150000}
                     }
	self:InitContent();
	
end

function SendChipsExplainView:InitContent()

	self:AddClick("Frame/BtnClose", "ActionOut");

	self:InitTextByLanguage();
end

function SendChipsExplainView:InitTextByLanguage()

	local language = self:GetLanguage();

	local title = self:FindChild("Frame/Title");
	title.text = language.title;

	local content = self:FindChild("Frame/ScrollText/Viewport/Content/Text");
	content.text = string.format(language.content,CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("OTPVerify") and language.bindTel or "");
	local content2 = self:FindChild("Frame/ScrollText/Viewport/Content/Text2");	
	content2.text = language.content2;
	local ScrollContent = self:FindChild("Frame/ScrollText/Viewport/Content");
	for i=1,3 do
		ScrollContent:FindChild("Title/"..i.."/Text").text = language.tableTitle[i]
	end
	for i=1,5 do		
		ScrollContent:FindChild("Reward"..i.."/1/Text").text = self.subConfig[i].vipStr
		ScrollContent:FindChild("Reward"..i.."/2/Text").text = self.subConfig[i].minSendCount
		if i < 4 then
		    ScrollContent:FindChild("Reward"..i.."/3/Text").text = language.belongStr1
		else 
			ScrollContent:FindChild("Reward"..i.."/3/Text").text = language.belongStr2
		end
	end
end

return SendChipsExplainView
