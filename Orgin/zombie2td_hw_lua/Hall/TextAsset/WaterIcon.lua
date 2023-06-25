local CC = require("CC")
local WaterIcon = CC.class2("WaterIcon")

function WaterIcon:Create(param)
	self:InitVar(param);
	self:InitContent();
	self:RegisterEvent();
end

function WaterIcon:InitVar(param)
	self.param = param or {};
    self.delayCo = nil
    self.actionTween = nil
	self.totalWaterNum = 0
end

function WaterIcon:InitContent()
	self.transform = CC.uu.LoadHallPrefab("prefab", "WaterIcon", self.param.parent);

	self.transform.gameObject.layer = self.param.parent.transform.gameObject.layer;

	self.effect = self.transform:FindChild("Effect")
	self.WaterImage = self.transform:FindChild("WaterNum/Image")
    self.WaterNum = self.transform:FindChild("WaterNum/Text")

	self.WaterIcon = self.transform:FindChild("Icon")
	self:AddClick(self.WaterIcon, "OnOpenView")

    self:ShowWaterIcon()
end

function WaterIcon:OnOpenView()
	local param = {};
	if self.param.openFunc then
		param.openFunc = self.param.openFunc
	end
	if self.param.closeFunc then
		param.closeFunc = self.param.closeFunc
	end
    CC.ViewManager.Open("ActivityCollectionView", param)
end

function WaterIcon:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.RefreshGiftIcon,CC.Notifications.OnRefreshActivityBtnsState)
	CC.HallNotificationCenter.inst():register(self, self.OnChangeSelfInfo, CC.Notifications.changeSelfInfo)
end

function WaterIcon:RefreshGiftIcon(key,switchOn)
	if key == "MonopolyView" then
		self.transform:SetActive(switchOn)
	end
end

function WaterIcon:OnChangeSelfInfo(props)
	local isNeedRefresh = false
    local delta = 0
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_TenGift_Sign_97 then
			isNeedRefresh = true;
            delta = v.Delta
		end
	end
	if not isNeedRefresh then return end;
	self:SetWaterNum(delta)
end

function WaterIcon:SetWaterNum(deltaNum)
	self.totalWaterNum = CC.Player.Inst():GetSelfInfoByKey("EPC_TenGift_Sign_97")
    self.WaterNum.text = CC.uu.DiamondFortmat(self.totalWaterNum)
	if deltaNum and deltaNum >= 1 then
		if not self.delayCo then
			self.effect:SetActive(false)
			self.effect:SetActive(true)
			self.delayCo = CC.uu.DelayRun(1, function()
				self.effect:SetActive(false)
				CC.uu.CancelDelayRun(self.delayCo);
				self.delayCo = nil
			end)
		end
	end
	if not self.actionTween then
		self.actionTween = CC.Action.RunAction(self.WaterImage,{
			{"scaleTo", 1.5, 1.5, 0.5, ease=CC.Action.EOutBack},
			{"scaleTo", 1, 1, 0.5, ease=CC.Action.EOutBack, function ()
				if self.actionTween then
					self.actionTween:Kill(false)
					self.actionTween = nil;
				end
			end}
		})
	end
end

function WaterIcon:ShowWaterIcon()
	if not CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("MonopolyView").switchOn then
		self.transform:SetActive(false)
		return
	end
	self.transform:SetActive(true)
	self:SetWaterNum()
end

function WaterIcon:AddClick(node, func, clickSound)
	clickSound = clickSound or "click"

	if CC.uu.isString(func) then
		func = self:Func(func)
	end
	if not node then
		logError("按钮节点不存在")
		return
	end
	--在按下时就播放音效，解决音效延迟问题
	node.onDown = function (obj, eventData)
		CC.Sound.PlayHallEffect(clickSound)
	end

	if node == self.transform then
		node.onClick = function(obj, eventData)
			if eventData.rawPointerPress == eventData.pointerPress then
				func(obj, eventData)
			end
		end
	else
		node.onClick = function(obj, eventData)
			func(obj, eventData)
		end
	end
end

function WaterIcon:Func( funcName )
	return function( ... )
		local func = self[funcName]
		if func then
			func( self, ... )
		end
	end
end


function WaterIcon:Destroy()
	CC.HallNotificationCenter.inst():unregisterAll(self)
    if self.delayCo then
		CC.uu.CancelDelayRun(self.delayCo);
		self.delayCo = nil;
	end
    if self.actionTween then
		self.actionTween:Kill(false)
        self.actionTween:Destroy()
		self.actionTween = nil;
	end
end

return WaterIcon