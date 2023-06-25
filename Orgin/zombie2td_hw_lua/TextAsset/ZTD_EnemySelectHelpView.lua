local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local EnemySelectHelpView = ZTD.ClassView("ZTD_EnemySelectHelpView")

function EnemySelectHelpView:OnCreate()
	self:PlayAnimAndEnter();
	self._ItemParent = self:FindChild("root/ItemList/Viewport/Content")
    self:Init();
	self:InitItemList();
end

function EnemySelectHelpView:Init()
	self:AddClick("root/Buttons/close","PlayAnimAndExit")
	self:AddClick("Panel","PlayAnimAndExit")
end

function EnemySelectHelpView:InitItemList()
	for _, v in pairs(ZTD.EnemyConfig) do
		self:CreateItem(_, v);
	end
end

function EnemySelectHelpView:CreateItem(index, info)
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_EnemyConfig");
	local item = ResMgr.LoadPrefab("prefab","ZTD_EnemySelectHelpDescItem",self._ItemParent,nil,nil)
	local txtdesc = item:FindChild("ItemList/Viewport/txt_desc");
	txtdesc.text = language[info.id].desc;
	
	local txt_name = item:FindChild("txt_name");
	txt_name.text = language[info.id].name;
	
    item:FindChild("img_head"):GetComponent("Image").sprite = ResMgr.LoadAssetSprite("prefab", info.icon)
	item:FindChild("img_head"):SetActive(true);
    item:FindChild("img_head"):GetComponent("Image"):SetNativeSize()	
end



return EnemySelectHelpView