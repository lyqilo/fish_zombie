
local CC = require("CC")
local RoomcardCounter = CC.class2("RoomcardCounter");

--[[
@param
parent: 挂载的父节点
clickFunc: 加号触发的点击方法
hideBtnAdd: 是否隐藏加号按钮
]]
function RoomcardCounter:Create(param)

	self:InitVar(param);
	self:InitContent();
	self:RegisterEvent();
end

function RoomcardCounter:InitVar(param)

	self.param = param;
end

function RoomcardCounter:InitContent()

	self.transform = CC.uu.LoadHallPrefab("prefab", "RoomcardCounter", self.param.parent);

	if not self.param.hideBtnAdd then
		self.transform.onClick = function ()
			self:OnClickBtnAdd();
		end
	end

	self:RefreshRoomcards();
end

function RoomcardCounter:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self, self.OnChangeSelfInfo, CC.Notifications.changeSelfInfo)
end

function RoomcardCounter:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.changeSelfInfo)
end

function RoomcardCounter:OnClickBtnAdd()
	
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

function RoomcardCounter:OnOpenStore()

	CC.ViewManager.Open("StoreView",{channelTab = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine").CommodityType.RoomCard});
end

function RoomcardCounter:OnChangeSelfInfo(props)
	local isNeedRefresh = false;
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_RoomCard then
			isNeedRefresh = true;
		end
	end
	if not isNeedRefresh then return end;

	self:RefreshRoomcards();
end

function RoomcardCounter:RefreshRoomcards()

	local roomcardCount = CC.Player.Inst():GetSelfInfoByKey("EPC_RoomCard");
	local roomcards = self.transform:FindChild("Effect/Text");
	roomcards.text = CC.uu.DiamondFortmat(roomcardCount);
end

function RoomcardCounter:Destroy(isDestroyObj)

	self:UnRegisterEvent();
	if isDestroyObj then
		if self.transform then
			CC.uu.destroyObject(self.transform);
			self.transform = nil;
		end
	end
end

return RoomcardCounter;