
local CC = require("CC")
local PackbackItemDes = CC.class2("PackbackItemDes");

--[[
@param
parent: 挂载的父节点
sortingLayerName
sortingOrder
]]
function PackbackItemDes:Create(param)

	self:InitVar(param);
	self:InitContent();
end

function PackbackItemDes:InitVar(param)

	self.param = param;

    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop");
    
    self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")

	self.uilanguage = CC.LanguageManager.GetLanguage("L_BackpackView");

	self.language = CC.LanguageManager.GetLanguage("L_Prop");
end

function PackbackItemDes:InitContent()

	self.transform = CC.uu.LoadHallPrefab("prefab", "PackbackItemDes", self.param.parent);

    self.propName = self.transform:FindChild("Content/Prop/PropName");
    self.propNum = self.transform:FindChild("Content/Prop/PropNum");
	self.propIcon = self.transform:FindChild("Content/Prop/Frame/Sprite");
	self.propLabel = self.transform:FindChild("Content/Prop/Text")
    
    self.item = self.transform:FindChild("Item");
    self.awardNode = self.transform:FindChild("Content/AwardNode")

	self:SetText(self.propLabel, self.uilanguage.itemDesLabel);
end

function PackbackItemDes:RefreshContent(param)
    
    local id = param.value and param.value.Id

	local propImg = param.icon or self.propCfg[id].Icon;
	self:SetImage(self.propIcon, propImg);

	local propName = param.propName or self.language[id];
	self:SetText(self.propName, propName);

	local propLabel = param.propLabel
	if propLabel then
		self:SetText(self.propLabel, propLabel);
	end

	local propNum = param.count or param.value and param.value.count or nil
	if propNum then
		self:SetText(self.propNum, self.uilanguage.numLable..propNum);
	else
		self.propNum:SetActive(false)
	end
	
	local propTips = param.Tips or param.value.Tips
    self:InitAward(propTips)
end

function PackbackItemDes:InitAward(param)
    Util.ClearChild(self.awardNode,false)
    for i, v in ipairs(param) do
        local item = CC.uu.newObject(self.item, self.awardNode)
        local node = item:FindChild("Sprite")
        self:SetImage(node,self.PropDataMgr.GetIcon(v.ConfigID))
    end
end

function PackbackItemDes:Show(param)
    LayoutRebuilder.ForceRebuildLayoutImmediate(self.awardNode)
	self:RefreshContent(param);
	self.transform:SetParent(param.parent, false);
    self.transform:SetActive(true);
end

function PackbackItemDes:Hide()

	self.transform:SetActive(false);
end

function PackbackItemDes:SetImage(childNode, path)
	if CC.uu.isString(childNode) then
		childNode = self.transform:FindChild(childNode);
	end
	CC.uu.SetHallImage(childNode, path);
end

function PackbackItemDes:SetText( childNodeName, text )
	local obj = childNodeName;
	if CC.uu.isString(childNodeName) then
		obj = self.transform:FindChild(childNodeName)
	end
	if obj then
		obj.text = text
	end
end

function PackbackItemDes:Destroy()

	if self.transform then
		CC.uu.destroyObject(self.transform);
		self.transform = nil;
	end
end

return PackbackItemDes;