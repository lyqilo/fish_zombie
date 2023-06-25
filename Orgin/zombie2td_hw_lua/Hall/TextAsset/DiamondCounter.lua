
local CC = require("CC")
local DiamondCounter = CC.class2("DiamondCounter");

--[[
@param
parent: 挂载的父节点
clickFunc: 加号触发的点击方法
hideBtnAdd: 是否隐藏加号按钮
]]
function DiamondCounter:Create(param)

	self:InitVar(param);
	self:InitContent();
	self:RegisterEvent();
end

function DiamondCounter:InitVar(param)

	self.param = param;
end

function DiamondCounter:InitContent()

	self.transform = CC.uu.LoadHallPrefab("prefab", "DiamondCounter", self.param.parent);

	if not self.param.hideBtnAdd then
		self.transform.onClick = function ()
			self:OnClickBtnAdd();
		end
	end

	self:RefreshDiamonds();
end

function DiamondCounter:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self, self.OnChangeSelfInfo, CC.Notifications.changeSelfInfo)
end

function DiamondCounter:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.changeSelfInfo)
end

function DiamondCounter:OnClickBtnAdd()
	
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

function DiamondCounter:OnOpenStore()

	CC.ViewManager.Open("StoreView");
end

function DiamondCounter:OnChangeSelfInfo(props)
	local isNeedRefresh = false;
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_ZuanShi then
			isNeedRefresh = true;
		end
	end
	if not isNeedRefresh then return end;

	self:RefreshDiamonds();
end

function DiamondCounter:RefreshDiamonds()

	local diamondCount = CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi");
	local diamonds = self.transform:FindChild("Effect/Icon/Text");
	diamonds.text = CC.uu.DiamondFortmat(diamondCount);
end

function DiamondCounter:Destroy(isDestroyObj)

	self:UnRegisterEvent();
	if isDestroyObj then
		if self.transform then
			CC.uu.destroyObject(self.transform);
			self.transform = nil;
		end
	end
end

return DiamondCounter;