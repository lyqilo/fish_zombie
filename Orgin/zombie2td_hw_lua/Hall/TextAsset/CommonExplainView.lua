
local CC = require("CC")

local CommonExplainView = CC.uu.ClassView("CommonExplainView")

--[[
@param
title:	标题
content:内容
alignment:对齐方式 (UnityEngine.TextAnchor.MiddleCenter、MiddleLeft、MiddleRight)
padding:坐标偏移
	padding.left
	padding.right
	padding.top
	padding.bottom
lineSpace:行距
prefab:
]]
function CommonExplainView:ctor(param)

	self.param = param or {};
end

function CommonExplainView:Create()
	local viewName = self.viewName;
	if self.param.prefab then
		viewName = self.param.prefab;
	end
	self.transform = CC.uu.LoadHallPrefab(self.bundleName, 
		viewName,
		self:GlobalNode(),
		viewName,
		self:GlobalLayer())
	self:OnCreate()
end

function CommonExplainView:OnCreate()

	self:InitContent();
end

function CommonExplainView:InitContent()

	--设置布局属性
	local content = self:FindChild("Frame/ScrollText/Viewport/Content");
	local layoutGroup = content:GetComponent("LayoutGroup");
	if self.param.alignment then
		layoutGroup.childAlignment = self.param.alignment;
	end
	if self.param.padding then
		for k,v in pairs(self.param.padding) do
			layoutGroup.padding[k] = v;
		end
	end

	local text = content:FindChild("Text"):GetComponent("Text");
	if self.param.alignment then
		text.alignment = self.param.alignment;
	end
	if self.param.lineSpace then
		text.lineSpacing = self.param.lineSpace;
	end

	self:AddClick("Frame/BtnClose", "ActionOut");

	self:InitTextByLanguage();
end

function CommonExplainView:InitTextByLanguage()

	local title = self:FindChild("Frame/Tittle/Text");
	title.text = self.param.title;

	local content = self:FindChild("Frame/ScrollText/Viewport/Content/Text");
	content.text = self.param.content;
	if self.param.tableData then
		local content = self:FindChild("Frame/ScrollText/Viewport/Content")
		local title = self:FindChild("Frame/ScrollText/Viewport/Content/Title")
		local prefab = self:FindChild("Frame/ScrollText/Viewport/Content/Item")
		title:SetActive(true)
		for i, v in ipairs(self.param.tableData) do
			if i == 1 then
				for j, k in ipairs(v) do
					title:FindChild(string.format("%s/Text",j)).text = k
				end
			else
				local item = CC.uu.newObject(prefab, content)
				for j, k in ipairs(v) do
					if j == 1 then
						self:SetImage(item:FindChild(string.format("%s/Image",j)), k)
					else
						item:FindChild(string.format("%s/Text",j)).text = k
					end
				end
				item:SetActive(true)
			end
		end
		title:FindChild()
	end
end

return CommonExplainView;
