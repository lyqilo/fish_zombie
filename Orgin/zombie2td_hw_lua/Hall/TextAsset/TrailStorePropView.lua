
local CC = require("CC")

local TrailStorePropView = CC.uu.ClassView("TrailStorePropView")

function TrailStorePropView:ctor(param)

	self:InitVar(param);
end

function TrailStorePropView:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
end

function TrailStorePropView:CreateViewCtr(...)
	local viewCtrClass = require("View/TrailView/"..self.viewName.."Ctr");
	return viewCtrClass.new(self, ...);
end

function TrailStorePropView:InitVar(param)

	self.param = param;

	self.storeDefine = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine");

	self.callback = self.param and self.param.callback;
end

function TrailStorePropView:InitContent(param)

	local headNode = self:FindChild("TopPanel/HeadBG/Node");
	self.HeadIcon = CC.HeadManager.CreateHeadIcon({parent = headNode, clickFunc = "unClick"});

	local chipNode = self:FindChild("TopPanel/ChipBG");
	self.chipCounter = CC.HeadManager.CreateChipCounter({parent = chipNode, hideBtnAdd = true});

	--切换返回按钮上的图标
	if param.showBackIcon then
		local hallIcon = self:FindChild("TopPanel/BtnBG/BtnBack/HallIcon");
		hallIcon:SetActive(false);
		local backIcon = self:FindChild("TopPanel/BtnBG/BtnBack/GameIcon");
		backIcon:SetActive(true);
	end

	-- self:AddClick("TopPanel/BtnBG/BtnBack", "Destroy");
	for _,v in ipairs(param.items) do
		self:CreatePropItem(v);
	end

	self:AddClick("TopPanel/BtnBG/BtnBack", function()
			self:Destroy();
		end);
end

function TrailStorePropView:CreatePropItem(param)

	local item = {};
	item.data = param;
	local parent = self:FindChild("RightPanel/ScrollPanel/Viewport/Content");
	item.transform = CC.uu.newObject(self:FindChild("PropItem"), parent);
	item.transform:SetActive(true);
	local btn = item.transform:FindChild("Board/BtnPay");
	self:AddClick(btn, function()
			self.viewCtr:OnPay(item.data);
		end)

	item.onRefreshData = function(param)
		if param.icon then
			local icon = item.transform:FindChild("Board/Icon");
			icon:SetImage(param.icon);
		end
		if param.count then
			local count = item.transform:FindChild("Board/Bottom/CurCount");
			count.text = param.count;
		end
		if param.price then
			local price = btn:FindChild("Price/Text");
			price.text = string.format("%s฿", param.price);
		end
	end;

	item.onRefreshData(param);

	return item;
end

function TrailStorePropView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end

	if self.HeadIcon then
		self.HeadIcon:Destroy();
		self.HeadIcon = nil;
	end

	if self.chipCounter then
		self.chipCounter:Destroy();
		self.chipCounter = nil;
	end

	if self.callback then 
		self.callback();
		self.callback = nil;
	end
end

function TrailStorePropView:ActionIn()

end

return TrailStorePropView;