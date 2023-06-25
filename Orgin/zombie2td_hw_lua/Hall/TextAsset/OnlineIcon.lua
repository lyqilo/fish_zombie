local CC = require("CC")
local OnlineIcon = CC.class2("OnlineIcon")

function OnlineIcon:Create(param)
	self:InitVar(param);
	self:InitContent();
	self:InitData();
	self:RegisterEvent();
end

function OnlineIcon:InitVar(param)
	self._timers = {}

	self.param = param or {};

	self.collectView = nil;

	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
end

function OnlineIcon:InitContent()
	self.transform = CC.uu.LoadHallPrefab("prefab", "OnlineIcon", self.param.parent);

	self.transform.gameObject.layer = self.param.parent.transform.gameObject.layer;

	self.redDot = self.transform:FindChild("RedDot")

	self.effect = self.transform:FindChild("Effect")

    self.countDownTimer = self.transform:SubGet("CountDownText","Text")

    self:AddClick(self.transform:FindChild("Icon"), "OnOpenFreeChipsCollection");
end

function OnlineIcon:OnOpenFreeChipsCollection()

    local param = {};
    param.SelectTab = {"OnlineAward"}
	param.openFunc = self.param.openFunc;
	param.closeFunc = function()
			self.collectView = nil;
			if self.param.closeFunc then
				self.param.closeFunc();
			end
		end
	if self.param.isHall then
		self.gameDataMgr.SetSwitchClick("FreeChipsCollectionView")
	end
	self.collectView = CC.ViewManager.Open("FreeChipsCollectionView", param);
end

function OnlineIcon:InitData()
     local playerId=CC.Player.Inst():GetSelfInfoByKey("Id") 
    CC.Request("GetOnlineRewardInfo",{PlayerId=playerId})
end

function OnlineIcon:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self, self.OnlineRewardInfo, CC.Notifications.NW_GetOnlineRewardInfo)
	CC.HallNotificationCenter.inst():register(self,	self.OnResume,CC.Notifications.OnResume)
end

function OnlineIcon:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetOnlineRewardInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnResume)
end

--切后台回来
function OnlineIcon:OnResume()
	local playerId=CC.Player.Inst():GetSelfInfoByKey("Id") 
    CC.Request("GetOnlineRewardInfo",{PlayerId=playerId})
end

function OnlineIcon:OnlineRewardInfo(err,data)
	if err == 0 then
		self:RefresState(data)
	end
end

function OnlineIcon:RefresState(param)
	self:StopTimer("OnlineAward")
	local Open = param.Open
	local RestSeconds = param.RestSeconds
	local HasReward = param.HasReward
	local time = 0
	local lastTime = 0
	if not Open or #param.RewardIds == 6 then
		--在线奖励关闭或所有奖励领取完毕
		self.transform:SetActive(false)
	else
		self.transform:SetActive(true)
	end
	
	if HasReward then
		self.redDot:SetActive(true)
		self.effect:SetActive(true)
		self.countDownTimer:SetActive(false)
	else
		if RestSeconds > 0 then
			self.countDownTimer:SetActive(true)
			self.redDot:SetActive(false)
			self.effect:SetActive(false)
		end
		self:StartTimer("OnlineAward", 0, function()
			time = time + Time.deltaTime
			if lastTime < math.floor(time) then
				lastTime = math.floor(time)
			end
			self.countDownTimer.text = CC.uu.TicketFormat(RestSeconds-lastTime)
			if lastTime >= RestSeconds then
				self.redDot:SetActive(true)
				self.effect:SetActive(true)
				self.countDownTimer:SetActive(false)
				self:StopTimer("OnlineAward")
			end
		end, -1)
	end
	
end

function OnlineIcon:AddClick(node, func, clickSound)
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

function OnlineIcon:Func( funcName )
	return function( ... )
		local func = self[funcName]
		if func then
			func( self, ... )
		end
	end
end

function OnlineIcon:StartTimer( name, delay, func, times )
	self:StopTimer(name)
	self._timers[name] = Timer.New(func, delay, times);
	self._timers[name]:Start();
end

function OnlineIcon:StopTimer(name)
	local timer = self._timers[name]
	if timer then
		timer:Stop();
		self._timers[name] = nil
	end
end

function OnlineIcon:StopAllTimer()
	for _, timer in pairs(self._timers) do
		timer:Stop();
	end
	self._timers = {}
end

function OnlineIcon:Destroy()
	if self.collectView then
		self.collectView:Destroy();
	end
	self:StopAllTimer()
	self:UnRegisterEvent();
end

return OnlineIcon