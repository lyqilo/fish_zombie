
local CC = require("CC")
local MessageBox = require("View/OtherView/MessageBox")
local M = CC.uu.ClassView("MessageBoxNewStyle", nil, MessageBox)

function M:CreateTransform(globalNode)
	return CC.uu.LoadHallPrefab("prefab",
		"MessageBoxNewStyle",
		globalNode,
		"MessageBoxNewStyle",
		self:GlobalLayer()
	)
end

function M:GetLanguage()
	return CC.LanguageManager.GetLanguage("L_MessageBox");
end

function M:SetTitleText(text)
	self:SetText("Frame/Title/Text", text)
end

return M

