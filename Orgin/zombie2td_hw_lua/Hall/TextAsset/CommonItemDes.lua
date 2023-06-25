
local CC = require("CC")
local CommonItemDes = CC.class2("CommonItemDes");

--[[
@param
parent: 挂载的父节点
sortingLayerName
sortingOrder
]]
function CommonItemDes:Create(param)

	self:InitVar(param);
	self:InitContent();
end

function CommonItemDes:InitVar(param)

	self.param = param;

	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop");

	self.language = CC.LanguageManager.GetLanguage("L_Prop");
end

function CommonItemDes:InitContent()

	self.transform = CC.uu.LoadHallPrefab("prefab", "CommonItemDes", self.param.parent);

	self.propName = self.transform:FindChild("Content/PropName");
	self.propIcon = self.transform:FindChild("Frame/Icon");
	self.propDes = self.transform:FindChild("Content/PropDes");
	self.propIcon.localScale = Vector3(1.2,1.2,1)

end

function CommonItemDes:RefreshContent(param)

	if not param.propId then return end;

	local propCfg = self.propCfg[param.propId];

	local propImg = param.icon or self.propCfg[param.propId].Icon;
	self:SetImage(self.propIcon, propImg);

	local propName = param.propName or self.language[param.propId];
	self:SetText(self.propName, propName);

	local propDes = param.propDes or self.language["des"..param.propId];
	self:SetText(self.propDes, propDes);
end

function CommonItemDes:Show(param)

	self:RefreshContent(param);
	self.transform:SetParent(param.parent, false);
	self.transform:SetActive(true);
end

function CommonItemDes:Hide()

	self.transform:SetActive(false);
end

function CommonItemDes:SetImage(childNode, path)
	if CC.uu.isString(childNode) then
		childNode = self.transform:FindChild(childNode);
	end
	CC.uu.SetHallImage(childNode, path);
end

function CommonItemDes:SetText( childNodeName, text )
	local obj = childNodeName;
	if CC.uu.isString(childNodeName) then
		obj = self.transform:FindChild(childNodeName)
	end
	if obj then
		obj.text = text
	end
end

function CommonItemDes:Destroy()

	if self.transform then
		CC.uu.destroyObject(self.transform);
		self.transform = nil;
	end
end

return CommonItemDes;