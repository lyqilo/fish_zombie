
local CC = require("CC")

local TrailStorePropViewCtr = CC.class2("TrailStorePropViewCtr")

-- local testData = {
-- 	MolOpenChips = 0,
-- 	MolHide = 0,
-- 	Chip = {
-- 		Other = {
-- 			{CommodityType = 31, WareIds = {'com.huoys.royalcasino.product1','com.huoys.royalcasino.product2','com.huoys.royalcasino.product3',
-- 				'com.huoys.royalcasino.product4','com.huoys.royalcasino.product5','com.huoys.royalcasino.product6','com.huoys.royalcasino.product7'}},
-- 		},
-- 		Mol = {
-- 			{CommodityType = 21, WareIds = {91001,91002,91003,91004,91005}},
-- 			{CommodityType = 22, WareIds = {92001,92002,92003,92004,92005}},
-- 			{CommodityType = 23, WareIds = {93001,93002,93003,93004,93005,93006,93007}},
-- 			{CommodityType = 24, WareIds = {95003,95004,95005,95006,95007,95008,95009,95010,95011,95012,95013,95014,95015,95016}},
-- 			{CommodityType = 25, WareIds = {96003,96004,96005,96006,96007,96008,96009,96010,96011,96012,96013,96014,96015,96016}},
-- 			{CommodityType = 26, WareIds = {97003,97004,97005,97006,97007,97008,97009,97010,97011,97012,97013,97014,97015,97016}},
-- 			{CommodityType = 27, WareIds = {94003,94004,94005,94006,94007,94008,94009,94010,94011}},
-- 		}
-- 	},
-- 	Prop = {
-- 		{CommodityType = 12, WareIds = {20001,20002,20003,20004,20005}},
-- 	}
-- }

--[[
@param
storeTab	--物品页签(筹码和道具)
]]
function TrailStorePropViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function TrailStorePropViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function TrailStorePropViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;

	self.localData = nil;

	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");

	self.hallCamera = GameObject.Find("HallCamera/GaussCamera"):GetComponent("Camera");
end

function TrailStorePropViewCtr:InitData()

	self.localData = self:GetChannelItems();

	local data = {};
	data.showBackIcon = not CC.ViewManager.IsHallScene();
	data.items = self.localData;
	self.view:InitContent(data);

	self:OnShowHallCamera(false);
end

function TrailStorePropViewCtr:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
end

function TrailStorePropViewCtr:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);
end

function TrailStorePropViewCtr:OnShowHallCamera(flag)
	if not CC.ViewManager.IsHallScene() then
		return;
	end
	self.hallCamera:SetActive(flag);
end

function TrailStorePropViewCtr:GetChannelItems()

	local data = {
		{id = 'com.huoys.royalcasino.productios1', icon = 'store_horn.png', count = 24, price = 35, subChannel = "ios"},
		{id = 'com.huoys.royalcasino.productios2', icon = 'store_horn.png', count = 48, price = 69, subChannel = "ios"},
		{id = 'com.huoys.royalcasino.productios8', icon = 'store_horn.png', count = 70, price = 99, subChannel = "ios"},
		{id = 'com.huoys.royalcasino.productios3', icon = 'store_horn.png', count = 97, price = 139, subChannel = "ios"},
		{id = 'com.huoys.royalcasino.productios4', icon = 'store_horn.png', count = 146, price = 209, subChannel = "ios"},
		{id = 'com.huoys.royalcasino.productios5', icon = 'store_horn.png', count = 272, price = 389, subChannel = "ios"},
		{id = 'com.huoys.royalcasino.productios6', icon = 'store_horn.png', count = 489, price = 699, subChannel = "ios"},
		{id = 'com.huoys.royalcasino.productios7', icon = 'store_horn.png', count = 636, price = 909, subChannel = "ios"},
	}

	return data;
end

function TrailStorePropViewCtr:OnPay(param)
	--购买道具商品
	local data = {};
	data.wareId = tostring(param.id);
	data.subChannel = param.subChannel;
	CC.PaymentManager.RequestPay(data);
end

function TrailStorePropViewCtr:OnPurchaseSuccess(param)
	if not self.localData then return end

	local wareData;
	for _,v in ipairs(self.localData) do
		if v.id == param.WareId then
			wareData = v;
		end
	end

	if wareData then
		local rewards = {
			{
				ConfigId = CC.shared_enums_pb.EPC_Speaker,
				Count = wareData.count
			},
		}
		CC.ViewManager.OpenRewardsView({items = rewards})
	end
end

function TrailStorePropViewCtr:Destroy()

	self:UnRegisterEvent();

	self:OnShowHallCamera(true);

	self.view = nil;
end

return TrailStorePropViewCtr;
