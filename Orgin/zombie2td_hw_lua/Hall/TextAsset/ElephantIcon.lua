local CC = require("CC")
local ElephantIcon = CC.class2("ElephantIcon")

function ElephantIcon:Create(param)
	self:InitVar(param);
	self:InitContent();
	self:InitData();
end

function ElephantIcon:InitVar(param)

	self.param = param or {};

	self.openView = nil;

	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game");

	self.delayCo = nil;
end

function ElephantIcon:InitContent()
	self.transform = CC.uu.LoadHallPrefab("prefab", "GiftIcon", self.param.parent);

	self.transform.gameObject.layer = self.param.parent.transform.gameObject.layer;

	self.redDot = self.transform:FindChild("RedDot")

	self.effect = self.transform:FindChild("Effect")

	self.shakeAnimator = self.transform:GetComponent("Animator");

	self.shakeAnimator.enabled = false;

	self.elephantIcon = self.transform:FindChild("ElephantIcon")
	self.firstBuyIcon = self.transform:FindChild("FirstBuyIcon")
	self:AddClick(self.elephantIcon, "OnOpenGoldenElephant")
	self:AddClick(self.firstBuyIcon, "OnOpenFirstBuyGift")

	if CC.Player.Inst():GetFirstGiftState() then
		self.firstBuyIcon:SetActive(true)
	else
		self:ShowElephanGift()
	end
end

function ElephantIcon:OnOpenGoldenElephant()
	self.redDot:SetActive(false);
	self.shakeAnimator.enabled = false;
	self.effect:SetActive(false);
	local param = {};
	param.openFunc = self.param.openFunc;
	param.closeFunc = function()
			self.openView = nil;
			if self.param.closeFunc then
				self.param.closeFunc();
			end
		end
    self.openView = CC.ViewManager.Open("GoldenElephant",param)
	Util.SaveToPlayerPrefs("elephantOpenDay",os.date("%d-%m-%Y"))
end

function ElephantIcon:OnOpenFirstBuyGift()
	self.redDot:SetActive(false);
	self.shakeAnimator.enabled = false;
	self.effect:SetActive(false);
	local param = {};
	param.openFunc = self.param.openFunc;
	param.closeFunc = function()
			self.openView = nil;
			if self.param.closeFunc then
				self.param.closeFunc();
			end
		end
    self.openView = CC.ViewManager.Open("FirstBuyGiftView",param)
end

function ElephantIcon:InitData()
	CC.HallNotificationCenter.inst():register(self,self.RefreshGiftIcon,CC.Notifications.OnRefreshActivityBtnsState)
	CC.HallNotificationCenter.inst():register(self,self.OnTenFristGiftInfoRsp,CC.Notifications.NW_ReqTenFristGiftInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnTenFristGiftInfoRsp,CC.Notifications.NW_ReqTenFristGiftLottery)
end

function ElephantIcon:ReqElephant()
	local lastOpenDay = Util.GetFromPlayerPrefs("elephantOpenDay")
	if lastOpenDay == os.date("%d-%m-%Y") then  ----一天只弹出一次
		return;
	end
	self.redDot:SetActive(false);
	self.shakeAnimator.enabled = false;
	self.effect:SetActive(false);
	CC.Request("ReqElephantPiggy",nil,function(err,result)
		log("err = ".. err.."  "..CC.uu.Dump(result,"ReqElephantPiggy",10))
		if err == 0 then
			if result.Info.Extra >= 30000 then
				self.redDot:SetActive(true);
				self.shakeAnimator.enabled = true;
				self.effect:SetActive(true);
				self.delayCo = CC.uu.DelayRun(180, function()
					self:OnOpenGoldenElephant()
				end);
			end
		end
	end)

end

function ElephantIcon:RefreshGiftIcon(key,switchOn)
	if key == "ElephantPiggy" then
		switchOn = switchOn and not CC.ChannelMgr.CheckOppoChannel() and not CC.ChannelMgr.CheckVivoChannel() and not CC.ChannelMgr.CheckOfficialWebChannel() and not CC.Player.Inst():GetFirstGiftState()
		self.elephantIcon:SetActive(switchOn)
	elseif key == "FirstBuyGift" then
		if not switchOn then
			self.firstBuyIcon:SetActive(false)
			local isShow = not CC.ChannelMgr.CheckOppoChannel() and not CC.ChannelMgr.CheckVivoChannel() and not CC.ChannelMgr.CheckOfficialWebChannel() and CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("ElephantPiggy").switchOn
			self.elephantIcon:SetActive(isShow)
		else
			if not CC.ChannelMgr.GetSwitchByKey("bHasGift") then return end
			CC.Request("ReqTenFristGiftInfo")
		end
	end
end

function ElephantIcon:OnTenFristGiftInfoRsp(err,data)
	log(CC.uu.Dump(data, "OnTenFristGiftInfoRsp"))
	if err == 0 then
		if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") <= 0 or data.IsValid then
			local isShow = true
			if data.PayTimes > data.CanPayTimes or (data.PayTimes >= data.CanPayTimes and data.AbleTimes <= 0) then
				isShow = false
			end
			self.firstBuyIcon:SetActive(isShow)

			if not isShow then
				self:ShowElephanGift()
			else
				self.elephantIcon:SetActive(false)
			end
		end
	end
end

function ElephantIcon:ShowElephanGift()
	if CC.ChannelMgr.CheckOppoChannel() or CC.ChannelMgr.CheckVivoChannel() or CC.ChannelMgr.CheckOfficialWebChannel() or not CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("ElephantPiggy").switchOn then
		return
	end
	self.elephantIcon:SetActive(true)
	self:ReqElephant()
end

function ElephantIcon:AddClick(node, func, clickSound)
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

function ElephantIcon:Func( funcName )
	return function( ... )
		local func = self[funcName]
		if func then
			func( self, ... )
		end
	end
end


function ElephantIcon:Destroy()

	CC.HallNotificationCenter.inst():unregisterAll(self)

	if self.openView then
		self.openView:Destroy();
	end
	if self.delayCo then
		CC.uu.CancelDelayRun(self.delayCo);
		self.delayCo = nil;
	end

end

return ElephantIcon