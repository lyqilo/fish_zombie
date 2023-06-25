local CC = require("CC")
local Action = CC.Action
local class = CC.class2
local uu = CC.uu

local View = class("SubGameUiView")
local SubGameUiViewErrCode = {
	["还没有设置自动下注次数，调用SetAutoSpinCount传表设置"] = "SubGameUiViewErr:1",
	["先调用SetCurBet设置当前下注额"] = "SubGameUiViewErr:2",
	["先调用SetMoney设置玩家当前筹码数"] = "SubGameUiViewErr:3",
	["ชิปยังไม่ได้เติมเข้าตัวสำเร็จ"] = "SubGameUiViewErr:4",
	["在设置当前下注额之前先调用SetMaxBet设置当前场最大下注额"] = "SubGameUiViewErr:5",
	["你可以重载OnCreate做你游戏想做的初始化"] = "SubGameUiViewErr:6",
	["如果你设置了是体验场，这个接口会自动调用，重载写你需要做的操作"] = "SubGameUiViewErr:7",
	["重载OnBtnHelp,展示派彩表界面"] = "SubGameUiViewErr:8",
	["重载OnBetIncrease,发送下注增加的请求"] = "SubGameUiViewErr:9",
	["重载OnBetReduce,发送下注减少的请求"] = "SubGameUiViewErr:10",
	["重载OnBetMax,发送下注最大值的请求"] = "SubGameUiViewErr:11",
	["重载OnBtnStop,在开始转动之后点击Stop按钮触发"] = "SubGameUiViewErr:12",
	["重载OnSelectQuick,快速展示结果"] = "SubGameUiViewErr:13",
	["重载OnBtnBack,菜单界面退出时候触发"] = "SubGameUiViewErr:14",
	["重载BeginSpin,当开始转动的时候触发的接口，已经判断了金币是否足够"] = "SubGameUiViewErr:15",
	["重载BeginFreeSpin,当免费次数开始转动的时候触发的接口"] = "SubGameUiViewErr:16",
}

-- 接口即将遗弃
function View.Extend(viewName,parent)
    local c = class(viewName,View)
    c.viewName = viewName
    c.parent = parent.transform;
    return c
end

-- param参数即将遗弃
function View:ctor(param)
	self._timers = {}
	self._cos = {}
	self._updates = {}

	self._actionMap = {};
	self._actionKey = 0;

	self._param = param;
end

function View:Create(param)
	self._param = self._param or param;

	local viewPrefabName = "SubGameUiView";
	local parent = self.parent

	if self._param then
		if self._param.gameUiViewName then
			viewPrefabName = self._param.gameUiViewName;
		end
		
		if self._param.parent then
			parent = self._param.parent
			self.parent = parent 
		end
	end
	self.transform = CC.uu.LoadHallPrefab("prefab", 
		viewPrefabName,
		parent,
		viewPrefabName,
		nil
	)
	self:_OnCreate();
end

function View:Destroy()
	self:_OnDestroy();
	self:ClearEntryEffect();
	self:CancelAllDelayRun()
	self:StopAllAction();
	self:StopAllTimer()
	self:OnDestroy();
	self:OnDestroyFinish()
	GameObject.Destroy(self.transform.gameObject)
end

function View:SetLineNum(num)
	--派奖线总数
	self._lineNum = num;
end

function View:SetGameId(id)
	self._gameId = id
end

function View:SetRoomId(id)
	self._roomId = id
end

function View:FindChild(childNodeName)
	return self.transform:FindChild(childNodeName);
end

function View:AddLongClick(node, data)
	local funcClick = data.funcClick;
	local funcLongClick = data.funcLongClick;
	local funcDown = data.funcDown;
	local funcUp = data.funcUp;
	local funcExit = data.funcExit;
	local time = data.time or 1;
	local clickSound = data.clickSound or "click";
	local longClickSound = data.longClickSound or  "click";

	self.__longClickCount = self.__longClickCount and self.__longClickCount + 1 or 0;
	local curCount = self.__longClickCount

	node.onDown = function(obj, eventData)
		CC.Sound.PlayEffect(clickSound)
		self.__longClickFlag = false;
		self:StartTimer("CheckLongClick"..curCount,time,function()
			if eventData.pointerCurrentRaycast.gameObject == node.gameObject then 
				self.__longClickFlag = true;
				funcLongClick(obj, eventData);
				CC.Sound.StopExtendEffect(longClickSound);
			end
		end)
		if funcDown then 
			funcDown(obj,eventData);
		end
		CC.Sound.PlayLoopEffect(longClickSound);
	end

	node.onUp = function(obj,eventData)
		if funcUp then 
			funcUp(obj,eventData);
		end
		self:StopTimer("CheckLongClick"..curCount);
		CC.Sound.StopExtendEffect(longClickSound);
	end

	node.onClick = function(obj, eventData)		
		if not self.__longClickFlag then	
			funcClick(obj, eventData);
		end
	end

	node.onExit = function(obj, eventData)
		if funcExit then
			funcExit(obj,eventData);
		end
		self:StopTimer("CheckLongClick"..curCount);
		CC.Sound.StopExtendEffect(longClickSound);
	end
end

--rawPointerPress 射线检测到的节点
--pointerPress 从rawPointerPress开始递归检测实现了(1.onDown,2.onClick)的节点
function View:AddClick(node, func, clickSound)
	clickSound = clickSound or "click";
	if node == self.transform then
		node.onClick = function(obj, eventData)
			CC.Sound.PlayHallEffect(clickSound)
			if eventData.rawPointerPress == eventData.pointerPress then
				func(obj, eventData)
			end
		end
	elseif node then
		node.onClick = function(obj, eventData)
			CC.Sound.PlayHallEffect(clickSound)
			func(obj, eventData)
		end
	end
end

function View:RunAction(target, action)
	self._actionKey = self._actionKey + 1;
	self._actionMap[self._actionKey] = Action.Run(target.transform or target, action);
	return self._actionKey;
end

function View:StopAction(actionKey,complete)
    if not actionKey then return end
	self._actionMap[actionKey]:Kill(complete or false);
	self._actionMap[actionKey] = nil;
end

function View:StopAllAction(complete)
	for _,v in pairs(self._actionMap) do 
		v:Kill(complete or false);
	end
	self._actionKey = 0;
	self._actionMap = {};
end

function View:DelayRun( second, func, ... )
	local co = uu.DelayRun(second, func, ...)
	self._cos[co] = co
	return co
end

function View:CancelDelayRun( co )
	if co then
		self._cos[co] = nil
		uu.CancelDelayRun(co)
	end
end

function View:CancelAllDelayRun()
	for _, co in pairs(self._cos) do
		uu.CancelDelayRun(co)
	end
	self._cos = {}
end

function View:StartTimer( name, delay, func, times )
	self:StopTimer(name)
	self._timers[name] = coroutine.start(function()
		times = times or 1
		repeat
			coroutine.wait(delay);
			uu.SafeCallFunc(func)
			times = times - 1
		until(times == 0)
	end)
end

function View:StopTimer(name)
	local co = self._timers[name]
	self._timers[name] = nil
	uu.CancelDelayRun(co)
end

function View:StopAllTimer()
	for _, co in pairs(self._timers) do
		uu.CancelDelayRun(co)
	end
	self._timers = {}
end

function View:StartUpdate(func)
	self:StopUpdate(func);
	self._updates[func] = func;
	UpdateBeat:Add(func,self);
end

function View:StopUpdate(func)
	if self._updates[func] then 
		self._updates[func] = nil;
		UpdateBeat:Remove(func,self);
	end
end

function View:StopAllUpdate()
	for i,v in pairs(self._updates) do 
		UpdateBeat:Remove(i,self);
	end
	self._updates = {};
end

function View:GetBtnStartPlane()
	return self:FindChild("Bottom/BtnStartPlane")
end

function View:OnDestroy()
	--待重写
end

function View:OnDestroyFinish()
	--待重写
	--该重写仅仅被ViewManager使用，用来管理view
end

--------------禁止重载----------------------
function View:_OnCreate()
	self:_InitData();
	self:_InitText();
	self:_InitHead();
	self:_InitBtn();
	self:ChangeWinMoney("Set", 0);
	self:OnCreate(self._param);
    self:ShowEntryEffect();
end

function View:_OnDestroy()
	self:_RemoveHead();
end

function View:_InitHead()
	self._headIcon = CC.SubGameInterface.CreateHeadIcon({
		parent = self:FindChild("Top/Head");
		clickFunc = function()
			CC.SubGameInterface.ChangeHallUserChouMa(self:GetUiMoney());
			CC.SubGameInterface.OpenPersonalInfoView();
		end,
	});
end

function View:_RemoveHead()
	CC.SubGameInterface.DestroyHeadIcon(self._headIcon);
end

function View:_InitData()
	--当前下注额
	self._curBetNum = nil;
	--最大下注额
	self._maxBetNum = nil;
	--当前筹码数
	self._curMoney = nil;
	--是否初始化了自动旋转的次数
	self._initAutoSpinCount = false;
	--自动旋转多少次
	self._autoSpinCount = 0;
	--当前是否是免费模式
	self._isFreeTime = false;
	--记录免费次数
	self._freeTime = 0;
	--当前转动是否完成
	self._rollFinish = true;
	--当前场次
	self._roomId = nil;
	-- 当前游戏id
	self._gameId = nil;
end

function View:_InitText()
	self._moneyText = self:FindChild("Top/Score/Num"):GetComponent("NumberRoller");
	self._moneyIcon = self:FindChild("Top/Score/Icon"):GetComponent("Image");

	self._curBetTextNode = self:FindChild("Bottom/BetText/Num");
	self._curBetText = self:FindChild("Bottom/BetText/Num"):GetComponent("NumberRoller");
	self._maxBetText = self:FindChild("Bottom/BetText/Text"):GetComponent("Text");
	self._betRateText = self:FindChild("Bottom/BetText/text_rate"):GetComponent("Text");

	self._freeTimeText = self:FindChild("Bottom/BtnStartPlane/Free/Text"):GetComponent("Text");

	self._autoSpinText = self:FindChild("Bottom/BtnStartPlane/Auto/Text"):GetComponent("Text");

	self._winParent = self:FindChild("Bottom/WinText")
	self._winNode = self:FindChild("Bottom/WinText/win")
	self._winText = self._winNode:FindChild("Num"):GetComponent("NumberRoller");
	self._goodNode = self:FindChild("Bottom/WinText/good")
	self._goodluckText = self._goodNode:FindChild("text_goodluck"):GetComponent("Text");
	self._winNodePosY = self._winNode.y
	self._goodNodePosY = self._goodNode.y
end

function View:_InitBtn()
	self._btnMenu = self:FindChild("Top/BtnMenu");
	self:AddClick(self._btnMenu,function()
		self:OnPreOpenShop();
		CC.SubGameInterface.OpenMenu({
			OnBackToHall = function()
				self:OnBtnBack();
			end
		});
	end);

	self._btnShop = self:FindChild("Top/Score/BtnShop");
	self:AddClick(self._btnShop,function()
		self:OnPreOpenShop();
		CC.SubGameInterface.OpenShop(self:GetUiMoney());
	end)

	self._btnChat = self:FindChild("Bottom/BtnChat");
	if CC.SubGameInterface.GetSwitchState then
		self._btnChat.gameObject:SetActive(CC.SubGameInterface.GetSwitchState({key = "EPC_LockLevel"}) == true);
	end
	self:AddClick(self._btnChat,function()
		CC.SubGameInterface.OpenChat(self:GetUiMoney());
	end)

	self._btnHelp = self:FindChild("Bottom/BtnHelp");
	self:AddClick(self._btnHelp,function()
		self:OnBtnHelp();
	end)

	self._btnBetIncrease = self:FindChild("Bottom/BetText/BtnIncrease");
	self:AddClick(self._btnBetIncrease,function()
		self:OnBetIncrease();
	end,"bet_add");

	self._btnBetReduce = self:FindChild("Bottom/BetText/BtnReduce");
	self:AddClick(self._btnBetReduce,function()
		self:OnBetReduce();
	end,"bet_less");

	self._btnMaxBet = self:FindChild("Bottom/BtnMaxBet");
	self:AddClick(self._btnMaxBet,function()
		self:OnBetMax();
	end)

	self._btnSpin = self:FindChild("Bottom/BtnStartPlane/Spin");
	self._btnSpin:SetActive(true);
	local longClickData = {
		funcClick = function()
			self._btnSpin:FindChild("PressEffect"):SetActive(false);
			self:_BeginSpin();
		end,
		funcLongClick = function()
			self._btnSpin:FindChild("PressEffect"):SetActive(false);

			if not self._initAutoSpinCount then 
				CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["还没有设置自动下注次数，调用SetAutoSpinCount传表设置"]);
			else
				self._btnAutoSpinPlane:SetActive(true);
				local frame = self._btnAutoSpinPlane:FindChild("Board");
				frame.localScale = Vector3(0,0,0);
				self:RunAction(frame, {"scaleTo", 1, 1, 0.2, ease = CC.Action.EOutBack});
			end

		end,
		funcDown = function()
			self._btnSpin:FindChild("PressEffect"):SetActive(true);
		end,
		funcUp = function()
			self._btnSpin:FindChild("PressEffect"):SetActive(false);
		end,
		funcExit = function()
			self._btnSpin:FindChild("PressEffect"):SetActive(false);
		end,
		clickSound = "subgame_spin_click",
		longClickSound = "subgame_spin_longclick",
	}
	self:AddLongClick(self._btnSpin,longClickData)

	self._btnAutoSpin = self:FindChild("Bottom/BtnStartPlane/Auto");
	self._btnAutoSpin:SetActive(false);
	self:AddClick(self._btnAutoSpin,function()
		self:_StopAutoSpin();
	end)

	self._btnFree = self:FindChild("Bottom/BtnStartPlane/Free");
	self._btnFree:SetActive(false);

	self._btnStop = self:FindChild("Bottom/BtnStartPlane/Stop");
	self:AddClick(self._btnStop,function()
		self:OnBtnStop();
		self._btnStop:GetComponent("Button"):SetBtnEnable(false);
	end)
	self._btnStop:SetActive(false);

	self._btnAutoSpinPlane = self:FindChild("CountChoose");
	self._btnAutoSpinPlane:SetActive(false);
	self:AddClick(self._btnAutoSpinPlane,function()
		local frame = self._btnAutoSpinPlane:FindChild("Board");
		self:RunAction(frame, {"scaleTo", 0, 0, 0.2, ease = CC.Action.EInBack,function()
			self._btnAutoSpinPlane:SetActive(false);
		end})
	end)

	self._toggleFast = self:FindChild("Bottom/ToggleFast");
	if self._toggleFast then----可能不存在，可能存在，看选择的是那种预制体
		UIEvent.AddToggleValueChange(self._toggleFast, function(selected)
			self:OnSelectQuick(selected)
	  	end)
	end
end

--切换成可以立即停止的模式
function View:_ChangeToStopMode(flag)
	if self._autoSpinCount ~= 0 or self._isFreeTime then return end
	if flag then 
		self._btnSpin:SetActive(false);
		self._btnStop:SetActive(true);
		self._btnStop:GetComponent("Button"):SetBtnEnable(true);
	else
		self._btnSpin:SetActive(true);
		self._btnStop:SetActive(false);
	end
end

--转动的时候对界面的按钮的操作
function View:_DisableBtnWhenRoll()
	self._btnBetIncrease:GetComponent("Button"):SetBtnEnable(false);
  	self._btnBetReduce:GetComponent("Button"):SetBtnEnable(false);
	self._btnMaxBet:GetComponent("Button"):SetBtnEnable(false);
	self._btnHelp:GetComponent("Button"):SetBtnEnable(false);
end

function View:_EnableBtnWhenFinish()
	self._btnBetIncrease:GetComponent("Button"):SetBtnEnable(true);
	self._btnBetReduce:GetComponent("Button"):SetBtnEnable(true);
	if self._curBetNum == self._maxBetNum  then 
		self._btnMaxBet:GetComponent("Button"):SetBtnEnable(false);
	else
		self._btnMaxBet:GetComponent("Button"):SetBtnEnable(true);
	end
	self._btnHelp:GetComponent("Button"):SetBtnEnable(true);
end

--关闭自动旋转模式
function View:_StopAutoSpin()
	--重置自动转的次数
	self._autoSpinCount = 0;
	--隐藏自动转的按钮
	self._btnAutoSpin:SetActive(false);
	--显示普通转的按钮
	if self._rollFinish then 
		self._btnSpin:SetActive(true);
	else
		self:_ChangeToStopMode(true);
	end
end

function View:_CheckEnoughMoney()
	if not self._curBetNum then 
		CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["先调用SetCurBet设置当前下注额"]);
		return;
	end

	if not self._curMoney then 
		CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["先调用SetMoney设置玩家当前筹码数"]);
		return;
	end

	if self._isFreeTime then
		return true;
	else
		local bet = self._curBetNum;
		local uiMoney = self:GetUiMoney();
		local realMoney = self._curMoney;

		if uiMoney >= bet then
			return true;
		elseif realMoney >= bet then 
			self:_StopAutoSpin();
			CC.SubGameInterface.ShowTip("ชิปยังไม่ได้เติมเข้าตัวสำเร็จ",2);
			return false;
		else
			self:_StopAutoSpin();
			self:CheckChipEnough(function() self:BrokeDeal() end)  -----CC.SubGameInterface.GotoShopTip(realMoney);
			return false;
		end
	end
end

function View:_BeginSpin()
	if not self._rollFinish then return end
	if not self:_CheckEnoughMoney() then return end
	self._rollFinish = false;
	self:_ChangeToStopMode(true);
	self:_DisableBtnWhenRoll();
	CC.HallNotificationCenter.inst():post(CC.Notifications.LIMITREFRESHREALTIMERANK,true);

	if self._isFreeTime then
		self:SetFreeTime(self._freeTime  - 1);
		self:BeginFreeSpin();
	else
		if self._autoSpinCount ~= -1 and self._autoSpinCount > 0 then 
			self._autoSpinText.text = self._autoSpinCount - 1;
		end
		self:BeginSpin();	
	end	
end

--开始自动旋转
function View:_BeginAutoSpin(count)
	self._autoSpinCount = count;
	self._autoSpinText.text = count == -1 and "Until bonus" or count;

	self._btnAutoSpin:SetActive(true);
	self._btnSpin:SetActive(false);

	self._btnAutoSpinPlane:SetActive(false);

	self:_BeginSpin();
end

--调用NumberRoller滚动数字
function View:_ChangeText(textNode,howToChange,...)
	local arg = {...};
	local len = #arg;
	if howToChange == "By" and len == 2 then 
		textNode:RollBy(arg[1],arg[2]);
		return true
	elseif howToChange == "To" and len == 2 then 
		textNode:RollTo(arg[1],arg[2]);
		return true
	elseif howToChange == "Set" and len == 1 then 
		textNode:RollFromTo(arg[1],arg[1],1);
		return true
	elseif howToChange == "FromTo" and len == 3 then 
		textNode:RollFromTo(arg[1],arg[2],arg[3]);
		return true
	end
	return false
end

---入场特效
function View:ShowEntryEffect()
	if CC.SubGameInterface.GetEntryEffect == nil then
		return;
	end
	local entryEffectId = CC.SubGameInterface.GetEntryEffect();
	if entryEffectId == nil or entryEffectId == 0 then
	  return;
	end
	local showArea = self.transform:GetComponent("RectTransform");
	local areaWidth = 1280/2-50;
	local areaHeight = 720/2-50;
	if self.entryEffects == nil then
	  self.entryEffects = {};
	end
	if self.entryEffectCors == nil then
	  self.entryEffectCors = {};
	end
	for i = 1,10 do
	  local cor = self:DelayRun(1*i,function() 
		  local effect = CC.SubGameInterface.CreateEntryEffect(entryEffectId,showArea);
		  if effect then
			effect.localPosition = Vector3(math.random(-areaWidth, areaWidth),math.random(-areaHeight, areaHeight),0);
			table.insert(self.entryEffects,effect);
		  end
	  end);
	  table.insert(self.entryEffectCors,cor);
	  if i == 10 then
		table.insert(self.entryEffectCors,self:DelayRun(12,function() self:ClearEntryEffect() end));
	  end
	end
  end
  ---删除入场特效
  function View:ClearEntryEffect()
	  if self.entryEffectCors then
		for k,v in pairs(self.entryEffectCors) do
		  self:CancelDelayRun(v);
		end
		self.entryEffectCors = nil;
	  end
	  if self.entryEffects then
		for k,v in pairs(self.entryEffects) do
		  uu.destroyObject(v);
		end
		self.entryEffects = nil;
	  end
  end
----------------禁止重载----------------------



----------------可以调用，但禁止重载---------------
--这个接口要在每次子游戏希望可以开始下次下注的时候调用
--可以开始下一次下注了
function View:CanBeginNextSpin()
	self._rollFinish = true;
	CC.HallNotificationCenter.inst():post(CC.Notifications.LIMITREFRESHREALTIMERANK,false);
	if not self._isFreeTime then
		--转动完成转回来正常的按钮显示
		self:_ChangeToStopMode(false);
		self:_EnableBtnWhenFinish();

		if self._autoSpinCount > 0 then
			self._autoSpinCount = self._autoSpinCount - 1;
			if self._autoSpinCount == 0 then 
				self:_StopAutoSpin();
			else
				self:_BeginSpin();
			end
		elseif self._autoSpinCount == -1 then 
			self:_BeginSpin();
		end
	else
		self:_BeginSpin();
	end
end

--设置自动旋转的次数
function View:SetAutoSpinCount(t)
	for i = 1,4 do 
		local count = self._btnAutoSpinPlane:FindChild("Board/Count"..i);
		count:GetComponent("Text").text = t[i];
		self:AddClick(count,function()
			self:_BeginAutoSpin(t[i]);
		end)
	end

	self:AddClick(self._btnAutoSpinPlane:FindChild("Board/Untilbonus"),function()
		self:_BeginAutoSpin(-1);
	end)

	self._initAutoSpinCount = true;
end

--获取当前是否是自动旋转
function View:GetIsAutoSpin()
	return self._autoSpinCount ~= 0;
end

--获取当前是否免费模式
function View:GetIsFreeMode()
	return self._isFreeTime;
end

--获取剩余免费次数
function View:GetFreeTime()
	return self._freeTime;
end

--设置免费次数
function View:SetFreeTime(time)
	self._freeTime = time;
	self._freeTimeText.text = self._freeTime;
end

function View:SetMoney(money)
	self:ChangeUiMoney("Set",money);
	self:SetRealMoney(money);
end

--获得玩家当前显示的筹码
function View:GetUiMoney()
	return self._moneyText:GetFinalNum();
end

function View:ChangeUiMoney(howToChange,...)
	if self:_ChangeText(self._moneyText,howToChange,...) then
		local uiMoney = self:GetUiMoney();

		-- CC.SubGameInterface.CheckRelief(uiMoney);

		CC.SubGameInterface.ChangeHallUserChouMa(uiMoney);
		return
	end
	logError("ChangeUiMoney接口调用"..howToChange.."参数错误");
end

function View:ChangeWinMoney(howToChange,...)
	self._winNode.y = self._winNodePosY
	self._goodNode.y = self._goodNodePosY + 10000
	if self:_ChangeText(self._winText,howToChange,...) then return end
	logError("ChangeWinMoney接口调用"..howToChange.."参数错误");
end 

--设置玩家当前最终筹码
function View:SetRealMoney(money)
	self._curMoney = money;
end

function View:AddRealMoney(money)
	self._curMoney = self._curMoney + money;
end

--获得玩家当前最终的筹码
function View:GetRealMoney()
	return self._curMoney;
end

--设置当前下注额
function View:SetCurBet(ratio)
	if not self._maxBetNum then 
		CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["在设置当前下注额之前先调用SetMaxBet设置当前场最大下注额"]);
	end
	self._curBetNum = ratio;
	self._curBetText.text = ratio;
	if ratio == self._maxBetNum  then 
		self._maxBetText.text = "Max Bet";
		self._btnMaxBet:GetComponent("Button"):SetBtnEnable(false);
	else
		self._maxBetText.text = "Bet";
		self._btnMaxBet:GetComponent("Button"):SetBtnEnable(true);
	end		

	if self._lineNum then
		self._betRateText:SetActive(true)
		self._betRateText.text = string.format("%d*%s",self._lineNum,CC.uu.Chipformat2(ratio/self._lineNum));
		self._curBetTextNode.y = -8
	else
		self._betRateText:SetActive(false)
		self._curBetTextNode.y = -18
	end
end

function View:GetCurBet()
	return self._curBetNum;
end

--设置最大下注额
function View:SetMaxBet(ratio)
	self._maxBetNum = ratio;
end

function View:GetMaxBet()
	return self._maxBetNum;
end

function View:ShowGoodluck()
	self._winNode.y = self._winNodePosY + 10000
	self._goodNode.y = self._goodNodePosY
end

--添加内容
function View:AddChild(node,path)
	node:SetParent(self:FindChild(path),false);
	node.localScale = Vector3.one;
	return node;
end

--设置是否是体验场
function View:SetIsExperience()
	self._moneyIcon.sprite = CC.uu.LoadImgSprite("zjm_icon_cm_f","newAtlas");
	self:OnSetIsExperience();
end

function View:EnterAction(time,useEase)
	local time = time or 0.5;
	local useEase = useEase and Action.EOutSine or Action.ELinear;

	local top = self:FindChild("Top");
	self._baseTopPos = self._baseTopPos or top.localPosition;
	top.localPosition = Vector3(self._baseTopPos.x,self._baseTopPos.y + 200,self._baseTopPos.z);
	self:RunAction(top, {"localMoveTo",self._baseTopPos.x,self._baseTopPos.y, time, ease = useEase});

	local bottom = self:FindChild("Bottom");
	self._baseBottomPos = self._baseBottomPos or bottom.localPosition;
	bottom.localPosition = Vector3(self._baseBottomPos.x,self._baseBottomPos.y - 200,self._baseBottomPos.z);
	self:RunAction(bottom, {"localMoveTo",self._baseBottomPos.x,self._baseBottomPos.y, time, ease = useEase});
end

function View:ExitAction(time,useEase)
	local time = time or 0.5;
	local useEase = useEase and Action.EOutSine or Action.ELinear;

	local top = self:FindChild("Top");
	self._baseTopPos = self._baseTopPos or top.localPosition;
	top.localPosition = self._baseTopPos;
	self:RunAction(top, {"localMoveTo",self._baseTopPos.x,self._baseTopPos.y + 200, time, ease = useEase});

	local bottom = self:FindChild("Bottom");
	self._baseBottomPos = self._baseBottomPos or bottom.localPosition;
	bottom.localPosition = self._baseBottomPos
	self:RunAction(bottom, {"localMoveTo",self._baseBottomPos.x,self._baseBottomPos.y - 200, time, ease = useEase});
end

--切换成免费模式
function View:ChangeToFreeMode(flag,time)
	time = time or 0;
	self._isFreeTime = flag;
	if self._isFreeTime then 
		self._btnFree:SetActive(true);
		if self._autoSpinCount ~= 0 then 
			self._btnAutoSpin:SetActive(false);
		else
			self._btnSpin:SetActive(false);
			self._btnStop:SetActive(false);
		end

		self:SetFreeTime(time);
	else
		self._btnFree:SetActive(false);
		if self._autoSpinCount ~= 0 then 
			self._btnAutoSpin:SetActive(true);
		else
			self._btnStop:SetActive(true);
		end
	end
end
------------可以调用，禁止重载----------------------

---是否破产
function View:CheckChipEnough(brokeDo)
    --账户余额<当前场次最小下注额
    if self._curMoney < self:GetBetRatio(1) then
        ---破产处理
        if brokeDo then
            brokeDo()
        end
        return false
            --当前档金币不足了
    else 
        if self._curMoney < self._curBetNum then
            log("当前档，金币不足了")
            local rechargeParam = {
                ChouMa = self:GetUiMoney(),
                channelTab = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine").CommodityType.Chip
            }
            CC.SubGameInterface.CreateRechargeOrAdjustMessageBox(function()      
                CC.SubGameInterface.ExOpenShop(rechargeParam);
            end)----调整下注额或者充值
            return false
        end
    end
    return true
end

----获取某档下注额
function View:GetBetRatio(index)
	return 99999999
end

function View:BrokeDeal()
    local param = {}
    local curMoney = self._curMoney;
    param.curMoney = curMoney
    param.brokeMoney = self:GetBetRatio(1);
	param.againBroke = true;
	-- 符合救济金领取条件但是因为发生错误最终没有打开救济金界面
	param.errCb = function()
        self:CheckRechargeOrSmaller()
	end
	-- 打开了破产礼包界面
	param.closeFunc = function()
		-- if buyInBroke then
		-- 	-- 购买了破产礼包，不需要处理
		-- else
		-- 	-- 没有购买破产礼包
		-- 	-- 不符合救济金领取条件或者救济金次数用完
		-- 	if CC.SubGameInterface.GetThreshold() <= curMoney or CC.SubGameInterface.GetReliefLeftTimes() < 1 then
		-- 		self:CheckRechargeOrSmaller()
		-- 	else
		-- 		-- 如果满足条件，肯定会尝试打开救济金界面。
		-- 		-- 如果打开成功，则不需处理
		-- 		-- 如果打开失败，则会调用param.errCb
		-- 	end
		-- end
		if CC.SubGameInterface.GetThreshold() <= curMoney or CC.SubGameInterface.GetReliefLeftTimes() < 1 then
			self:CheckRechargeOrSmaller()
		end
    end
    local checkResult = CC.SubGameInterface.CheckBrokeOrRelief(param);
    if not checkResult then
        self:CheckRechargeOrSmaller()
    end
end

function View:CheckRechargeOrSmaller()
	local brokeDo = function ()
		local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
		local unlockConditions = Json.decode(gameDataMgr.GetGroupInfo(self._gameId, 1).UnlockCondition) 
        local rechargeParam = {
            ChouMa = self:GetUiMoney(),
            channelTab = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine").CommodityType.Chip
		}

        if unlockConditions.Min[1].Count <= self._curMoney then----大于一场的入场额
            CC.SubGameInterface.CreateRechargeOrSmallerMessageBox(
                function()      
                    CC.SubGameInterface.ExOpenShop(rechargeParam);
                end,
				function()
					CC.SlotMatchManager.inst():Release();
					local SlotGiftFallManager = require("MJGame").SlotGiftFallManager;
					if SlotGiftFallManager then
						SlotGiftFallManager.inst():Release();
					end
					self:ChangeRoom();
				end
            ) ---充值或者降场
        else
            CC.SubGameInterface.CreateRechargeMessageBox(function()      
                CC.SubGameInterface.ExOpenShop(rechargeParam);
            end) ---充值
        end
    end
    self:CheckChipEnough(brokeDo)
end

function View:ChangeRoom()

end

function View:GuideGetVector(index)
	if index == 4 then
		return self:GuideGetVectorOfJackpot();
	else
		return self:GuideGetVectorCommon(index);
	end
end

function View:GuideGetVectorCommon(index)
	local btn = nil
    local offset_y = -100;
	if index == 1 then
        btn = self:FindChild("Bottom/BtnStartPlane/Spin");
        offset_y = 110;
	elseif index == 2 then
        btn = self:FindChild("Bottom/BetText/BtnIncrease");
        offset_y = 110;
	elseif index == 3 then
        btn = self:FindChild("Bottom/BtnHelp");
        offset_y = 110;
    elseif index == 5 then
        btn = self:FindChild("Top/BtnMenu");
	end
    if btn then
        local rect = btn:GetComponent("RectTransform").rect;
        local sizeX1 = rect.width / 2 + 10;
        local sizeY1 = rect.height / 2 + 10;
        local sizeX2 = nil;
        local sizeY2 = nil;
        local pos1 = UnityEngine.RectTransformUtility.WorldToScreenPoint(self:CanvasCamera(),btn.position)
        local pos2 = nil;
        local maskMode = "_MASKMODE_RECTANGLE";
        if index == 2 then
            local otherBtn = self:FindChild("Bottom/BetText/BtnReduce");
            pos2 = UnityEngine.RectTransformUtility.WorldToScreenPoint(self:CanvasCamera(),otherBtn.position)
            sizeX2 = sizeX1;
            sizeY2 = sizeY1;
            maskMode = "_MASKMODE_MORE";
        end

		local param = {vect1 = pos1, vect2 = pos2, sizeX1 = sizeX1, sizeY1 = sizeY1, sizeX2 = sizeX2, sizeY2 = sizeY2, offset_y = offset_y, maskMode = maskMode}

		return param;
	end
	return nil;
end

---返回奖池引导时高光区域
function View:GuideGetVectorOfJackpot()
	return nil;
end

---返回奖池位置
function View:GetJackpot()
	return nil;
end

---获取当前canvas摄像机
function View:CanvasCamera()
	return GameObject.Find("Main/UICamera"):GetComponent("Camera");
end


----------------------子游戏需要重载的接口----------------------
function View:OnCreate(param)
	CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["你可以重载OnCreate做你游戏想做的初始化"]);
end

function View:OnSetIsExperience()
	CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["如果你设置了是体验场，这个接口会自动调用，重载写你需要做的操作"]);
end

function View:OnBtnHelp()
	CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["重载OnBtnHelp,展示派彩表界面"]);
end

function View:OnBetIncrease()
	CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["重载OnBetIncrease,发送下注增加的请求"]);
end

function View:OnBetReduce()
	CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["重载OnBetReduce,发送下注减少的请求"]);
end

function View:OnBetMax()
	CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["重载OnBetMax,发送下注最大值的请求"]);
end

function View:OnBtnStop()
	CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["重载OnBtnStop,在开始转动之后点击Stop按钮触发"]);
end

function View:OnSelectQuick(selected)
	CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["重载OnSelectQuick,快速展示结果"]);
end

function View:OnBtnBack()
	CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["重载OnBtnBack,菜单界面退出时候触发"]);
end

function View:BeginSpin()
	CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["重载BeginSpin,当开始转动的时候触发的接口，已经判断了金币是否足够"]);
end

function View:BeginFreeSpin()
	CC.SubGameInterface.ShowTip(SubGameUiViewErrCode["重载BeginFreeSpin,当免费次数开始转动的时候触发的接口"]);
end

function View:OnPreOpenShop()
	--打开商店前会触发的方法
end

return View