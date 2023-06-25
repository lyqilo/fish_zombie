
local CC = require("CC")
local BatteryLotteryView = CC.uu.ClassView("BatteryLotteryView")

--[[
若更换炮台除了修改当前界面的配置以外
还要修改游戏接口SubGameInterface.GetSelectGiftSwitch给子游戏返回的当前炮台ID
之后写一个Define或者配置表统一处理
]]

function BatteryLotteryView:ctor(param)

	self:InitVar(param);
end

function BatteryLotteryView:InitVar(param)
	--是否四圣兽炮台
	self.isHolyBeast = false
	self.count = 1
	self.param = param
	self.WareId1 = self.isHolyBeast and "30354" or "30156"
	self.WareId2 = self.isHolyBeast and "30355" or "30157"
	self.WareId3 = "30158"
	self.language = self:GetLanguage()
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.RewardObj = {}
	self.TurnBaseTime = 0
	--炮台
	self.batteryProp = 1154
	--炮台碎片
	self.batteryFragment = 1153
	--点卡
	self.pointCard = 10001
	--奖励展示
	self.RewardCfg = {
		{id = self.batteryProp,text = ""},
		{id = self.batteryFragment,text = ""},
		{id = self.pointCard,text = ""},
		{id = 2,text = "x75000"},
		{id = 2,text = "x100000"},
		{id = 46,text = "x1200"},
		{},
		{id = 97,text = "x2"}
	}
	--兑换ID
	self.exchangeId = 31--14龙击炮 15朱雀炮台 18白虎炮台 20玉兔炮台 21蛋糕炮台 22水枪炮台 26青龙炮台 27世界杯炮台 31电音炮台
end

function BatteryLotteryView:OnCreate()
	self:InitNode()
	self:InitView()
	self:InitClickEvent()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
end

function BatteryLotteryView:InitNode()
	for i=1,8 do
		table.insert(self.RewardObj,self:FindChild("Bg/Prop"..i.."/BaseMap/Select"))
		if self.RewardCfg[i] and not table.isEmpty(self.RewardCfg[i]) then
			self:SetImage(self:FindChild("Bg/Prop"..i.."/Icon"),self.propCfg[self.RewardCfg[i].id].Icon)
			self:FindChild("Bg/Prop"..i.."/Icon"):GetComponent("Image"):SetNativeSize()
			self:FindChild("Bg/Prop"..i.."/Count").text = self.RewardCfg[i].text
		end
		--if i == 1 or i == 2 then
			--self:SetImage(self:FindChild("Bg/Prop"..i.."/Icon"),self.propCfg[4025].Icon)
		--elseif i == 3 then
			--self:SetImage(self:FindChild("Bg/Prop"..i.."/Icon"),self.propCfg[10002].Icon)
		--elseif i == 6 then
			--self:SetImage(self:FindChild("Bg/Prop"..i.."/Icon"),self.propCfg[46].Icon)
		--elseif i == 8 then
			--self:SetImage(self:FindChild("Bg/Prop"..i.."/Icon"),self.propCfg[1012].Icon)
		--end
	end
	self.ActTime = self:FindChild("Bg/ActTime")
	self.OverTip = self:FindChild("Bg/OverTip")
	self.Fragment = self:FindChild("Bg/Fragment")
	self.TaiJiNode = self:FindChild("Btn/TaiJiNode")
	self.CompoundBtn = self:FindChild("Btn/Compound")
	self.BuyBtn = self:FindChild("Btn/Buy")
	self.FreeLotteryBtn = self:FindChild("Btn/Lottery1/FreeLottery")
	self.Lottery1Btn = self:FindChild("Btn/Lottery1")
	self.Lottery2Btn = self:FindChild("Btn/Lottery2")
	self.ExplainBtn = self:FindChild("Btn/Explain")
	self.PreviewBtn = self:FindChild("Btn/Preview")
	self.PreviewPanel = self:FindChild("PreviewPanel")
	self.ShareBtn = self:FindChild("Btn/Share")
	self.shopBtn = self:FindChild("Btn/Shop")
	
	self.shopBtn:SetActive(self.isHolyBeast)
	self.TaiJiNode:SetActive(self.isHolyBeast)

	self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform})
	self.Marquee = CC.uu.CreateHallView("Marquee",{parent = self:FindChild("MarqueeNode"),TextPos = 1.5})
end

function BatteryLotteryView:InitView()
	if self.param then
		self:FindChild("Btn/Close"):SetActive(false)
	end
	self:FindChild("Bg/Shell/TitleImg/Text").text = self.language.TitleText
	self:FindChild("Btn/Shop/Text").text = self.language.shop
	self.ShareBtn.text = self.language.ShareTip
	self.PreviewBtn:FindChild("Text").text = self.language.Preview
	self.Lottery1Btn:FindChild("Text").text = self.language.Lottery1
	self.Lottery1Btn:FindChild("Price").text = self.wareCfg[self.WareId1].Price
	self.Lottery2Btn:FindChild("Text").text = self.language.Lottery2
	self.Lottery2Btn:FindChild("Price").text = self.wareCfg[self.WareId2].Price
	self.BuyBtn:FindChild("Text").text = "+1"
	self.BuyBtn:FindChild("Price").text = self.wareCfg[self.WareId3].Price
	self.FreeLotteryBtn:FindChild("Text").text = self.language.FreeLottery
	self:FindChild("Bg/Tip").text = self.language.Tip
	self.OverTip:FindChild("Lastday").text = self.language.LastDay
	self.OverTip:FindChild("Text").text = self.language.ActOverTip
	self.PreviewPanel:FindChild("Up/Text").text = self.language.BatteryName
	self.PreviewPanel:FindChild("Right/Title").text = self.language.PreviewTitle
	self.PreviewPanel:FindChild("Right/Details").text = self.language.PreviewDetails
	--for i,v in ipairs(self.RewardCfg) do
		--if v ~= "" then
			--self:FindChild("Bg/Prop"..i.."/Count").text = v
		--end
	--end
	
	--设置锁定攻击射线(LineRenderer)位置
	-- local lineNormal = self.PreviewPanel:FindChild("LockAttack/LineAttack/normal"):GetComponent(typeof(UnityEngine.LineRenderer))
	-- local lineRage = self.PreviewPanel:FindChild("LockAttack/LineAttack/rage"):GetComponent(typeof(UnityEngine.LineRenderer))
	-- local beginPos = self.PreviewPanel:FindChild("LockAttack/BeginPos")
	-- local endPos = self.PreviewPanel:FindChild("LockAttack/EndPos")
	-- lineNormal:SetPosition(0,beginPos.position)
	-- lineNormal:SetPosition(1,endPos.position)
	-- lineRage:SetPosition(0,beginPos.position)
	-- lineRage:SetPosition(1,endPos.position)
	
	if self.isHolyBeast then
		self:RefreshTaiJi()
	else
		self:RefreshSkin()
	end
	self:RefreshActTime()
end

function BatteryLotteryView:InitClickEvent()
	self:AddClick(self:FindChild("Btn/Close") , function() self:Destroy() end)
	self:AddClick(self.CompoundBtn, function() self:ReqExchange() end)
	self:AddClick(self.BuyBtn, function() self:ReqBuy(self.WareId3) end)
	self:AddClick(self.FreeLotteryBtn, function() self:ReqFreeLottery() end)
	self:AddClick(self.Lottery1Btn, function() self:ReqBuy(self.WareId1) end)
	self:AddClick(self.Lottery2Btn, function() self:ReqBuy(self.WareId2) end)
	self:AddClick(self.ExplainBtn, function() self:OpenExplainView() end)
	self:AddClick(self.PreviewBtn, function() self:ShowOrHidePreviewPanel(true) end)
	self:AddClick(self.ShareBtn:FindChild("btn"), function() self:OnClickShare(false) end)
	self:AddClick(self.PreviewPanel:FindChild("Up/Close") , function() self:ShowOrHidePreviewPanel(false) end)
	self:AddClick(self.shopBtn, function() self:OnShop() end)
end

function BatteryLotteryView:ReqExchange()
	local Battery = CC.Player.Inst():GetSelfInfoByKey(self.batteryProp)
	if Battery > 0 then
		return
	end
	local param = {}
	param.ID = self.exchangeId
	param.Amount = 1
	param.GameId = CC.ViewManager.GetCurGameId() or 1
	param.GroupId = CC.ViewManager.GetCurGroupId() or 0
	CC.Request("ReqExchange",param)
end

function BatteryLotteryView:ReqBuy(WareId)
	local price = self.wareCfg[WareId].Price
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
		if self.isHolyBeast then
			local times = WareId == self.WareId2 and 5 or 1
			CC.Request("ReqHolyBeastBatteryLottery", {Type = CC.shared_enums_pb.HB_Normal, Times = times})
		else
			CC.Request("ReqBuyWithId",{WareId = WareId, ExchangeWareId = WareId})
		end
	else
		if self.walletView then
			self.walletView:SetBuyExchangeWareId(WareId)
			self.walletView:PayRecharge()
		end
	end
end

function BatteryLotteryView:ReqFreeLottery()
	if self.isHolyBeast then
		CC.Request("ReqHolyBeastBatteryLottery", {Type = CC.shared_enums_pb.HB_Free, Times = 1})
	else
		CC.Request("ReqCommonBatteryFree")
	end
end

function BatteryLotteryView:OpenExplainView()
	local data = {
		title = self.language.explainTitle,
		content = self.language.explainContent,
	}
	CC.ViewManager.Open("CommonExplainView", data)
end

function BatteryLotteryView:ShowOrHidePreviewPanel(flag)
	self.PreviewPanel:SetActive(flag)
end

function BatteryLotteryView:OnClickShare(isCompound)
	local param = {}
	param.isShowPlayerInfo = true
	param.beforeCB = function()
		self.ShareBtn:SetActive(false)
	end
	param.afterCB = function()
		self.ShareBtn:SetActive(true)
	end
	if not isCompound then
		param.shareCallBack = function()
			CC.Request("ReqCommonBatteryShare")
		end
	end
	CC.ViewManager.Open("CaptureScreenShareView", param)
end

function BatteryLotteryView:OnShop()
	CC.ViewManager.Open("BatteryExchangeShop")
end

function BatteryLotteryView:EnterGame(GameId)
	CC.HallUtil.CheckAndEnter(GameId, nil, function()
		CC.ViewManager.CloseAllOpenView()
	end)
end

function BatteryLotteryView:StartLottery(Rewards,isMultiple)
	self:SetCanClick(false)
	CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, false)
	self.TurnBaseTime = isMultiple and 1 or 3
	self.Rewards = Rewards
	self.index = 1
	self.count = self.count +1
	-- log("StartLottery:"..self.Rewards[self.index].Block)
	CC.Sound.PlayHallEffect("lightning")
	self:Turn({RewardObj = self.RewardObj,StartObjIndex = 1,TurnTime = 0,TargetTime = self.TurnBaseTime*8 + self.Rewards[self.index].Block,interval = 0.01,isMultiple = isMultiple})
end

function BatteryLotteryView:Turn(param)
	if tostring(self.transform) == "null" then return end
	param.RewardObj[param.StartObjIndex]:SetActive(true)
	CC.Sound.PlayHallEffect("LotterySelect")
	local last = param.StartObjIndex - 1 == 0 and #param.RewardObj or param.StartObjIndex - 1
	param.RewardObj[last]:SetActive(false)
	param.TurnTime = param.TurnTime +1
	if param.TurnTime == param.TargetTime then
			--选中光圈闪烁
			self:RunAction(param.RewardObj[param.StartObjIndex],
			{{"fadeToAll", 0, 0.08,function() CC.Sound.PlayHallEffect("LotteryResult") end},
			{"fadeToAll", 255, 0.08},
			{"fadeToAll", 0, 0.08},
			{"fadeToAll", 255, 0.08},
			{"fadeToAll", 0, 0.08},
			{"fadeToAll", 255, 0.08,function()
				if param.isMultiple then
					self.index = self.index + 1
					param.TurnTime = 0
					param.TargetTime = self.TurnBaseTime*8 + self.Rewards[self.index].Block +(8-param.StartObjIndex)
					--log(self.Rewards[self.index].Block)
					param.StartObjIndex = param.StartObjIndex +1 > #param.RewardObj and 1 or param.StartObjIndex +1
					param.interval = 0.01
					param.isMultiple = self.index < 5
					self:DelayRun(0.01,self.Turn,self,param)
				else
					self:DelayRun(param.interval + 0.5,function()
						CC.ViewManager.OpenRewardsView({items = self.Rewards,sound = "ShowReward",callback = function()
							self:SetCanClick(true)
							CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, true)
							if tostring(self.transform) == "null" then return end
							param.RewardObj[param.StartObjIndex]:SetActive(false)
							if not self.isHolyBeast then
								self:RefreshSkin()
							end
						end})
					end)
				end
			end}
			})
		return
	else
		param.StartObjIndex = param.StartObjIndex +1 > #param.RewardObj and 1 or param.StartObjIndex +1
	end

	if param.TurnTime < param.TargetTime/2 then
		param.interval = param.interval - 0.02 <= 0 and 0.006 or param.interval - 0.02
	else
		param.interval = param.interval + 0.02
	end
	self:DelayRun(param.interval,self.Turn,self,param)
end

function BatteryLotteryView:RefreshSkin()
	 if tostring(self.transform) == "null" or self.isHolyBeast then return end
	 local Skin = CC.Player.Inst():GetSelfInfoByKey(self.batteryFragment) or 0
	 local Battery = CC.Player.Inst():GetSelfInfoByKey(self.batteryProp) or 0
	 self.Fragment.text = string.format(self.language.Fragment,Skin)
	 --local Tex = Battery <= 0 and self.language.Compound or self.language.CompoundFinish
	 local Tex = Battery <= 0 and Skin.."/20" or self.language.CompoundFinish
	 self.CompoundBtn:FindChild("Text").text = Tex
	 self.CompoundBtn:FindChild("Gray/Text").text = Tex

	 local isCanCompound = (Skin >= 20 and Battery <= 0) and true or false
	 self.CompoundBtn:FindChild("Gray"):SetActive(not isCanCompound)
	 if isCanCompound then
	 	self.CompoundBtn:FindChild("Text").text = self.language.Compound
	 	self.Fragment:SetActive(true)
	 else
	     self.Fragment:SetActive(false)
	 end

	 local isCanBuy = (Skin < 20 and Battery <= 0) and true or false
	 self.BuyBtn:SetActive(self.lastDay and isCanBuy)
end

function BatteryLotteryView:RefreshTaiJi()
	self.TaiJiNode:FindChild("Text").text = CC.Player.Inst():GetSelfInfoByKey(CC.shared_enums_pb.EPC_TaiJi_Totem)
end

function BatteryLotteryView:RefreshActTime(param)
	if param then
		self.ActTime.text = string.format(self.language.ActTime,param.actTime)
		if param.lastDay then
			self.lastDay = param.lastDay
			if not self.isHolyBeast then
				local Skin = CC.Player.Inst():GetSelfInfoByKey(self.batteryFragment) or 0
				local Battery = CC.Player.Inst():GetSelfInfoByKey(self.batteryProp) or 0
				self.BuyBtn:SetActive(Skin < 20 and Battery <= 0)
			end
		else
			self.OverTip:FindChild("Text/day").text = param.day
		end
	else
		local actTime = Util.GetFromPlayerPrefs("BatteryLotteryActTime")
		if actTime and actTime ~= "" then
			self.ActTime.text = string.format(self.language.ActTime,actTime)
		end
		param = {lastDay =true }
	end
	self.OverTip:FindChild("Lastday"):SetActive(param.lastDay)
	self.OverTip:FindChild("Text"):SetActive(not param.lastDay)
end

function BatteryLotteryView:ActionIn()
	self:SetCanClick(false);
	self.transform.size = Vector2(125, 0)
	self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function BatteryLotteryView:ActionOut()
	self:SetCanClick(false);
	-- self:RunAction(self.transform, {
	-- 		{"fadeToAll", 0, 0.5, function() self:Destroy() end},
	--     });
	self:Destroy()
end

function BatteryLotteryView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil;
	end
	if self.walletView then
		self.walletView:Destroy()
		self.walletView = nil
	end
	if self.Marquee then
		self.Marquee:Destroy()
		self.Marquee = nil
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, true)
end

return BatteryLotteryView