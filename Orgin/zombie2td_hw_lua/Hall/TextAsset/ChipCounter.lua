
local CC = require("CC")
local ChipCounter = CC.class2("ChipCounter");

--[[
@param
parent: 挂载的父节点
clickFunc: 加号触发的点击方法
hideBtnAdd: 是否隐藏加号按钮
]]
function ChipCounter:Create(param)

	self:InitVar(param);
	self:InitContent();
	self:RegisterEvent();
end

function ChipCounter:InitVar(param)

	self.param = param;
end

function ChipCounter:InitContent()

	self.transform = CC.uu.LoadHallPrefab("prefab", "ChipCounter", self.param.parent);

	if not self.param.hideBtnAdd then
		self.transform.onClick = function ()
			self:OnClickBtnAdd();
		end
	end

	-- --获取上层挂载的canvas组件,得到sortLayer和orderLayer
	-- local canvas = CC.uu.GetCanvas(self.transform);

	-- --设置整个预制体层级与canvas层级一致
	-- local transforms = self.transform:GetComponentsInChildren(typeof(UnityEngine.Transform));
	-- if transforms  then
	-- 	for i = 0, transforms.Length-1 do
	-- 		transforms[i].gameObject.layer = canvas.transform.gameObject.layer;
	-- 	end
	-- end

	-- --获取子节点下的粒子组件并设置orderLayer
	-- local particleParent = self.transform:FindChild("Effect")
	-- local particleComps = particleParent:GetComponentsInChildren(typeof(UnityEngine.ParticleSystemRenderer));
	-- if particleComps then
	-- 	for i = 0, particleComps.Length-1 do
	-- 		particleComps[i].sortingLayerName = canvas.sortingLayerName;
	-- 		particleComps[i].sortingOrder = canvas.sortingOrder + 1;
	-- 	end
	-- end

	self:RefreshChips();
end

function ChipCounter:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self, self.OnChangeSelfInfo, CC.Notifications.changeSelfInfo)
end

function ChipCounter:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.changeSelfInfo)
end

function ChipCounter:OnClickBtnAdd()
	
	CC.Sound.PlayHallEffect("click")

	local clickFunc = self.param.clickFunc;

	if not clickFunc then
		self:OnOpenStore();
		return;
	end

	if type(clickFunc) == "function" then
		clickFunc();
	end
end

function ChipCounter:OnOpenStore()

	CC.ViewManager.Open("StoreView", {channelTab = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine").CommodityType.Chip});
end

function ChipCounter:OnChangeSelfInfo(props)
	local isNeedRefresh = false;
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
			isNeedRefresh = true;
		end
	end
	if not isNeedRefresh then return end;

	self:RefreshChips();
end

function ChipCounter:RefreshChips()

	local chipsCount = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa");
	local chips = self.transform:FindChild("Effect/Icon/Text");
	chips.text = CC.uu.ChipFormat(chipsCount);
end

function ChipCounter:Destroy(isDestroyObj)

	self:UnRegisterEvent();
	if isDestroyObj then
		if self.transform then
			CC.uu.destroyObject(self.transform);
			self.transform = nil;
		end
	end
end

return ChipCounter;