
local CC = require("CC")
local IntegralCounter = CC.class2("IntegralCounter");

--[[
@param
parent: 挂载的父节点
clickFunc: 加号触发的点击方法
hideBtnAdd: 是否隐藏加号按钮
]]
function IntegralCounter:Create(param)

	self:InitVar(param);
	self:InitContent();
	self:RegisterEvent();
end

function IntegralCounter:InitVar(param)

	self.param = param;
end

function IntegralCounter:InitContent()

	self.transform = CC.uu.LoadHallPrefab("prefab", "IntegralCounter", self.param.parent);

	if not self.param.hideBtnAdd then
		self.transform.onClick = function ()
			self:OnClickBtnAdd();
		end
	end

	self:RefreshIntegral();
end

function IntegralCounter:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self, self.OnChangeSelfInfo, CC.Notifications.changeSelfInfo)
end

function IntegralCounter:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.changeSelfInfo)
end

function IntegralCounter:OnClickBtnAdd()

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

function IntegralCounter:OnOpenStore()
	if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("TreasureView") then
		CC.ViewManager.OpenAndReplace("TreasureView");
	end
end

function IntegralCounter:OnChangeSelfInfo(props)
	local isNeedRefresh = false;
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_New_GiftVoucher then
			isNeedRefresh = true;
		end
	end
	if not isNeedRefresh then return end;

	self:RefreshIntegral();
end

function IntegralCounter:RefreshIntegral()

	local integralCount = CC.Player.Inst():GetSelfInfoByKey("EPC_New_GiftVoucher");
	local integral = self.transform:FindChild("Effect/Icon/Text");
	integral.text = CC.uu.DiamondFortmat(integralCount);
end

function IntegralCounter:Destroy(isDestroyObj)

	self:UnRegisterEvent();
	if isDestroyObj then
		if self.transform then
			CC.uu.destroyObject(self.transform);
			self.transform = nil;
		end
	end
end

return IntegralCounter;