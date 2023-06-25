local CC = require("CC")

local HallView = CC.uu.ClassView("HallView")

function HallView:ctor(param)
	self.param = param
	self.GaussBlur = GameObject.Find("HallCamera/GaussCamera"):GetComponent("GaussBlur")
end

function HallView:GlobalNode()
	return GameObject.Find("GNode/GaussCanvas/GMain").transform
end

function HallView:GlobalCamera()
	return GameObject.Find("HallCamera/GaussCamera"):GetComponent("Camera")
end

function HallView:GlobalLayer()
	return "layer30"
end

function HallView:OnCreate()
	
	CC.HallUtil.RotateCamera()

	self.grayMaterial = ResMgr.LoadAsset("material", "Gray")
	self.switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")

	self.GaussBlur.enabled = false
	self:InitUI()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
	self:InitTextByLanguage()
	self:RefreshSwitchState()

	self:AddClickEvent()
	self:ShowLockLevelStatus()
	self:ShowWorldCupActivity()
	self:ShowAnniversaryIcon()
	self:RefreshWaterSprinklingBtnStatus()
	local activityView = {"MonthRebateView"}
	for _, v in pairs(activityView) do
		self:RefreshBtnStatus(v)
	end
end

function HallView:InitUI()
	self.language = self:GetLanguage()
	self:FindChild("Panel/TopBG/RightMgr/SendBtn/tip/Text"):GetComponent("Text").text = self.language.give_gift_tip
	-- self:SetFestivalUI()

	self.co_InitUI = coroutine.start(function()
		if CC.ChannelMgr.GetSwitchByKey("bHasRealStore") then
			local integralNode = self:FindChild("Panel/TopBG/NodeMgr/IntegralBG")
			integralNode:SetActive(true);
			self.integralCounter = CC.HeadManager.CreateIntegralCounter({parent = integralNode,clickFunc = function() CC.ViewManager.Open("GetTicketView") end})
			coroutine.step(1)
		end
		local chipNode = self:FindChild("Panel/TopBG/NodeMgr/ChipNode")
		self.chipCounter = CC.HeadManager.CreateChipCounter({parent = chipNode})
		coroutine.step(1)
		local headNode = self:FindChild("Panel/TopBG/HeadNode")
		self.headIcon = CC.HeadManager.CreateHeadIcon({parent = headNode, showFrameEffect = true})
		coroutine.step(1)
		if CC.ChannelMgr.GetSwitchByKey("bHasVip") then
			local vipNode = self:FindChild("Panel/TopBG/NodeMgr/VipNode")
			vipNode:SetActive(true);
			self.VIPCounter = CC.HeadManager.CreateVIPCounter({parent = vipNode, tipsParent = self:FindChild("Panel/TopBG/VIPTipsNode")});
			coroutine.step(1)
		end
		local diamondNode = self:FindChild("Panel/TopBG/NodeMgr/DiamondNode")
		self.diamondCounter = CC.HeadManager.CreateDiamondCounter({parent = diamondNode});
		coroutine.step(1)
	    if CC.ChannelMgr.GetSwitchByKey("bHasFreeChips") then
			local freeChipsNode = self:FindChild("Panel/DownBG/FreeBtn");
			freeChipsNode:SetActive(true);
			self.freeChipsBtn = CC.FreeChipsManager.CreateIcon({parent = freeChipsNode,isHall = true});
			coroutine.step(1)
		end
		if CC.ChannelMgr.GetSwitchByKey("bHasGift") then
			local GiftNode = self:FindChild("Panel/DownBG/GiftBtn");
			GiftNode:SetActive(true);
			self.effectTipTex = GiftNode:FindChild("effect/TuBiao/Text")
			self.initTxt = self.effectTipTex.text
			self.GiftBtn = CC.SelectGiftManager.CreateIcon({parent = GiftNode,isHall = true,viewParams = {NewPayGiftView = {closeFunc = function(state)
				local lan = CC.LanguageManager.GetLanguage("L_NewPayGiftView")
				self.effectTipTex.text = state and lan.Lottery or self.initTxt
			end}}});
			coroutine.step(1)
		end
		local DailyNode = self:FindChild("Panel/DownBG/DailyBtn")
		DailyNode:SetActive(true)
		self.DailyGiftBtn = CC.SelectGiftManager.CreateDialyIcon({parent = DailyNode,isHall = true})
		coroutine.step(1)
		local marsTaskNode = self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/MarsTaskIcon")
		local taskListNode = self:FindChild("Panel/GameList/MarsTaskList")
		self.marsTaskIcon = CC.IconManager.CreateMarsTaskIcon({parent = marsTaskNode,listParent = taskListNode})
		self:InitGameList()

		if CC.DebugDefine.GetPackageDebugState() then
			self.packageTest = CC.uu.LoadHallPrefab("prefab", "PackageEntry", GameObject.Find("GNode/GCanvas/GMain").transform);
			self.packageTest.onClick = function()
				CC.ViewManager.Open("PackageTestView");
			end
		end
		self:CreateActiveEntryIcon();
		self:AddPortraitTestBtn()
	end)

	self.rightBtnGroup = self:FindChild("Panel/TopBG/RightMgr");

	self.MailBtn = self:FindChild("Panel/TopBG/RightMgr/MailBtn")
	self.SendBtn = self:FindChild("Panel/TopBG/RightMgr/SendBtn")

	self.ElephantBtn = self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/ElephantBtn")
	self.agentBtn = self:FindChild("Panel/TopBG/RightMgr/AgentBtn")
	self.FirstGiftBtn = self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/FirstGiftBtn")
	self.RebateBtn = self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/RebateBtn")
	self.HalloweenIcon = self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/HalloweenIcon")
	self:SetImage(self.HalloweenIcon:FindChild("Tu"),"hdrk_icon_wsj")
	self.WorldCupIcon = self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/WorldCupIcon")
	self.BatteryIcon = self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/BatteryIcon")

	--扫光特效
	self.mailEffect = self:FindChild("Panel/TopBG/RightMgr/MailBtn/xinxian")
	self.sendEffect = self:FindChild("Panel/TopBG/RightMgr/SendBtn/dacouma")


	--记录下部菜单栏Y轴位置
	self.hallPanel = self:FindChild("Panel/DownBG")
	self.hideHallPanel = false

	self:InitMailEffect()
	self:InitSendEffect()
	--self:InitVipEffect()

	--初始化更多界面屏蔽点击的宽高
	self.morePanel = self:FindChild("Panel/DownBG/MorePanel")
	local width = self:FindChild("Panel"):GetComponent('RectTransform').rect.width
	local high = self:FindChild("Panel"):GetComponent('RectTransform').rect.height
	self.morePanel.width = width + 200
	self.morePanel.height = high + 200
	self.morePanel.localPosition = Vector3(width/2,high/2,0)
	if not CC.ChannelMgr.GetSwitchByKey("bShowSendChip") or not self.switchDataMgr.GetSwitchStateByKey("CV") then
		self.SendBtn:SetActive(false);
	end

	self:FindChild("Panel/GameList/Viewport/Content/SpecialNode/Jackpot/Text").localPosition = Vector3(0,-10,0)
	self:FindChild("Panel/GameList/Viewport/Content/SpecialNode/Jackpot/Text"):GetComponent('Text').fontSize = 30

	if not CC.DebugDefine.GetGuideDebugState() then
		self:GuideHideBtn()
	end

	if not CC.ChannelMgr.GetSwitchByKey("bShowTotalRank") then
		self:FindChild("Panel/DownBG/RankBtn"):SetActive(false);
	end

	if not CC.ChannelMgr.GetSwitchByKey("bHasActive") then
		self:FindChild("Panel/DownBG/ActiveBtn"):SetActive(false);
	end
	local HorizontalLayoutGroup = self:FindChild("Panel/GameList/Viewport/Content"):GetComponent("HorizontalLayoutGroup")
	if not self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") then
		self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup"):SetActive(false)
		HorizontalLayoutGroup.padding.left = 70
	end
	if not self.switchDataMgr.GetSwitchStateByKey("ChatPanel") then
		self:FindChild("Panel/ChatPanel"):SetActive(false)
	end
	local curScale = (UnityEngine.Screen.width / UnityEngine.Screen.height)
	if curScale > 2 then
		--长屏
		HorizontalLayoutGroup.padding.left = 70
	end
end

function HallView:InitTextByLanguage()
	--文本修改
	--self:FindChild("Panel/DownBG/SongkranBtn/effect/TuBiao/Text").text = self.language.songkran_tip
	self:FindChild("Panel/DownBG/GiftBtn/effect/TuBiao/Text").text = self.language.gift_tip
end

function HallView:InitSendEffect()
	self:DelayRun(math.random(1,10),function ()
		self.sendEffect:SetActive(true)
		self:DelayRun(2,function ()
			self.sendEffect:SetActive(false)
			self:InitSendEffect()
		end)
	end)
end

function HallView:SetFestivalUI()
	local newyearTimeStamp = 1672506000;
	local bg = self:FindChild("Panel");
	if CC.TimeMgr.GetSvrTimeStamp() > newyearTimeStamp then
		CC.uu.SetHallRawImage(bg, "hall_bg_newyear")
		bg:FindChild("ChrisEffect"):SetActive(false);
		bg:FindChild("NewyearEffect1"):SetActive(true);
		bg:FindChild("NewyearEffect2"):SetActive(true);
	end
end

function HallView:InitMailEffect()
	self:DelayRun(math.random(1,10),function ()
		self.mailEffect:SetActive(true)
		self:DelayRun(2,function ()
			self.mailEffect:SetActive(false)
			self:InitMailEffect()
		end)
	end)
end

function HallView:InitVipEffect()
	self:DelayRun(math.random(1,10),function ()
		self.vipEffect:SetActive(true)
		self:DelayRun(2,function ()
			self.vipEffect:SetActive(false)
			self:InitVipEffect()
		end)
	end)
end

function HallView:InitElephantEffect(isShow)
	self.ElephantBtn:FindChild("icon"):SetActive(not isShow)
	self.ElephantBtn:FindChild("Effect_Extra"):SetActive(isShow)
end

function HallView:ShowElephant(isShow)
	isShow = isShow and self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel")

	if isShow and CC.Player.Inst():GetFirstGiftState() then isShow = false end --防止首冲正打开着，这里直接不显示

	self.ElephantBtn:SetActive(isShow)
end

function HallView:ShowLockLevelStatus()
	if self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") and self.viewCtr.activityDataMgr.GetActivityInfoByKey("HalloweenView").switchOn then
		self.HalloweenIcon:SetActive(true)
	else
		self.HalloweenIcon:SetActive(false)
	end
end

function HallView:ShowAnniversaryIcon()
	if self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") and self.viewCtr.activityDataMgr.GetActivityInfoByKey("AnniversaryTurntableView").switchOn then
		self.anniversaryIcon:SetActive(true)
		self:RefreshDonateRedDot()
	else
		self.anniversaryIcon:SetActive(false)
	end
end

function HallView:RefreshDonateRedDot()
	local propNum = CC.Player.Inst():GetSelfInfoByKey("EPC_Merits") or 0
	self.anniversaryIcon:FindChild("RedDot"):SetActive(propNum >= 10)
end

function HallView:ShowFirstGift(isShow)
	isShow = isShow and self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel")
	CC.Player.Inst():SetFirstGiftState(isShow)
	self.FirstGiftBtn:SetActive(isShow)

	if isShow then
		self:ShowElephant(not isShow) --防止大象礼包打开了，这里关闭。需求是有首冲显示首冲，首冲买完就显示大象
	else
		self.viewCtr:LoadElephantExtra() --首冲礼包没有了就显示大象礼包
	end
end

function HallView:ShowWorldCupActivity()
	self:ShowWorldCupIcon()
	self:ShowWorldCupBatteryIcon()
end

function HallView:ShowWorldCupIcon()
	local switchOn  = self.viewCtr.activityDataMgr.GetActivityInfoByKey("WorldCupADPageView").switchOn
	if switchOn and CC.ViewManager.IsHallScene() then
		self.WorldCupIcon:SetActive(true)
	end
end

function HallView:ShowWorldCupBatteryIcon()
	local switchOn  = self.viewCtr.activityDataMgr.GetActivityInfoByKey("BatteryLotteryView").switchOn
	if switchOn and CC.ViewManager.IsHallScene() then
		self.BatteryIcon:SetActive(true)
	else
		self.BatteryIcon:SetActive(false)
	end
end

function HallView:InitGameList()
	local classname = "GameList"
	self.gameList = CC.uu.CreateHallView(classname,self:FindChild("Panel/GameList"),self,self.transform)
end

function HallView:CreateActiveEntryIcon()
	if CC.SubGameInterface.IsHasGuide() then
		return;
	end
	local activeEntryIcon = CC.ViewCenter.ActiveEntryIcon.new();
	activeEntryIcon:Init(self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/ActiveEntryIcon"))
	--self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/ActiveEntryIcon/Icon"):GetComponent("Image"):SetNativeSize()
	self.activeEntryIcon = activeEntryIcon;
	local midActiveIcon = CC.ViewCenter.MidActiveIcon.new();
	midActiveIcon:Init(self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/MidActiveIcon"));
	self.midActiveIcon = midActiveIcon;
end

function HallView:AddClickEvent()
	---------------------------------------上方按钮---------------------------------------
	--Logo--打开权益界面
	self:AddClick(self:FindChild("Panel/TopBG/logo/lg"),function ()
		CC.ViewManager.Open("PersonalInfoView",{Upgrade = 1})
	end)

	-- 高级vip
	self:AddClick(self.agentBtn,function ()
		if self.viewCtr.agentDataMgr.GetForbiddenAgentSatus() then
			CC.ViewManager.ShowTip(self.language.tipAgent)
		elseif self.viewCtr.agentDataMgr.GetAgentSatus() or self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") then
			CC.ViewManager.Open("AgentNewView")
		else
			CC.ViewManager.Open("AgentProxy")
		end
	end)

	--老玩家回归礼包
	self.GobackBtn = self:FindChild("Panel/TopBG/RightMgr/GobackBtn")
	self.GobackRedDot = self.GobackBtn:FindChild("RedDot")
	self:AddClick(self.GobackBtn,function() CC.ViewManager.Open("GobackRewardView",{closeFunc = function(state1,state2)
		self.GobackBtn:SetActive(state1)
		self.GobackRedDot:SetActive(state2)
	end}) end)

	--打开邮箱
	self:AddClick("Panel/TopBG/RightMgr/MailBtn",function ()
		self.viewCtr.gameDataMgr.SetSwitchClick("MailView")
		CC.ViewManager.Open("MailView")
	end)
	--打开赠送
	self:AddClick("Panel/TopBG/RightMgr/SendBtn",function ()
		self.viewCtr.gameDataMgr.SetSwitchClick("GiveGiftSearchView")
		CC.ViewManager.Open("GiveGiftSearchView")
	end)
	--打开大象礼包
	self:AddClick("Panel/GameList/Viewport/Content/ActiveGroup/Object/ElephantBtn",function ()
		--self.viewCtr.gameDataMgr.SetSwitchClick("GoldenElephant")
		CC.ViewManager.Open("GoldenElephant")
	end)
	--打开首冲礼包
	self:AddClick("Panel/GameList/Viewport/Content/ActiveGroup/Object/FirstGiftBtn",function ()
		CC.ViewManager.Open("FirstBuyGiftView")
	end)
	--月度返利
	self:AddClick("Panel/GameList/Viewport/Content/ActiveGroup/Object/RebateBtn",function ()
		CC.ViewManager.Open("MonthRebateView")
	end)
	--打开免费抽奖
	self.FreeLotteryBtn = self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/FreeLotteryBtn")
	self.FreeLotteryRedDot = self.FreeLotteryBtn:FindChild("RedDot")
	local musicName = nil
	self:DelayRun(0.15,function() musicName = CC.Sound.GetMusicName() end) --这里延时时间比ctr里的多一点点，保证背景音乐已经播放
	-- self:AddClick(self.FreeLotteryBtn,function() CC.ViewManager.Open("InviteLotteryView",{closeFunc = function(state)
	-- 	self.FreeLotteryRedDot:SetActive(state)
	-- 	CC.Player.Inst():SetFreeLotRedState(state)
	-- 	if musicName then
	-- 		CC.Sound.PlayHallBackMusic(musicName)
	-- 	else
	-- 		CC.Sound.StopBackMusic()
	-- 	end
	-- end,enterFunc = function()
	-- 	--CC.Sound.PlayHallBackMusic("HalloweenBg")
	-- end}) end)

	--打开万圣节
	self:AddClick("Panel/GameList/Viewport/Content/ActiveGroup/Object/HalloweenIcon",function ()
			CC.ViewManager.Open("HalloweenView")
	end)
	--打开世界杯
	self:AddClick(self.WorldCupIcon,function ()
		CC.ViewManager.Open("WorldCupView")
	end)
	self:AddClick(self.BatteryIcon,function ()
		CC.ViewManager.Open("SelectGiftCollectionView", {currentView = "BatteryLotteryView"})
	end)

	self.anniversaryIcon = self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/AnniversaryIcon")
	self.anniversaryIconRedDot = self.anniversaryIcon:FindChild("RedDot")
	self:AddClick(self.anniversaryIcon,function ()
		CC.ViewManager.Open("CelebrationView")
	end)
	---------------------------------------下方按钮---------------------------------------
	--好友
	self.FriendBtnMore = self:FindChild("Panel/DownBG/MoreBtn/MoreBG/FriendBtn")
	self:AddClick(self:FindChild("Panel/DownBG/MoreBtn/MoreBG/FriendBtn/icon"), function ()
		self.viewCtr.gameDataMgr.SetSwitchClick("FriendView")
		CC.ViewManager.Open("FriendView")
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshRedPointState, {key = "friend",state = false});
	end)

	--打开聊天
	self:AddClick("Panel/ChatPanel/ChatBtn",function ()
		if CC.ChatManager.ChatPanelToggle() then
			self:StopTimer("HallTenSecCountDown")
			CC.ViewManager.ShowChatPanel()
		else
			CC.ViewManager.ShowTip(self.language.tip_fix)
		end
	end)
	self:AddClick("Panel/ChatPanel/ChatPriBtn",function ()
		if CC.ChatManager.ChatPanelToggle() then
			self:StopTimer("HallTenSecCountDown")
			CC.ViewManager.ShowChatPanel({HallPriBtn = true})
		else
			CC.ViewManager.ShowTip(self.language.tip_fix)
		end
	end)
	-- 打开商店
	self:AddClick("Panel/DownBG/ShopBtn/icon",function ()
		self.viewCtr.gameDataMgr.SetSwitchClick("StoreView")
			CC.ViewManager.Open("StoreView")
		end,"")
	--打开排行榜
	self:AddClick("Panel/DownBG/RankBtn/icon", function ()
		--请求排行榜数据
		self.viewCtr.gameDataMgr.SetSwitchClick("RankingListView")
		CC.ViewManager.Open("RankCollectionView")
	end)
	--打开一元夺宝
	self:AddClick("Panel/DownBG/RealStoreBtn/icon",function ()
		self.viewCtr.gameDataMgr.SetSwitchClick("TreasureView")
		self:ShowTreasureTip(false)
		CC.LocalGameData.SetDataByKey("StockTime",CC.Player.Inst():GetSelfInfoByKey("Id"),self.viewCtr.stockTime)
		CC.ViewManager.Open("TreasureView")
	end)
	--打开活动
	self:AddClick("Panel/DownBG/ActiveBtn/icon",function ()
		self.viewCtr.gameDataMgr.SetSwitchClick("ActiveView")
		CC.ViewManager.Open("ActiveView")
	end)

	 --打开泼水节
	 self.WaterIcon = self:FindChild("Panel/GameList/Viewport/Content/ActiveGroup/Object/WaterIcon")
	 self:AddClick(self.WaterIcon,function ()
		CC.ViewManager.Open("ActivityCollectionView")
	 end)

	--打开更多
	self:AddClick("Panel/DownBG/MoreBtn/icon", function ()
			if not self.switchDataMgr.GetSwitchStateByKey("PhysicalLock") or not CC.ChannelMgr.GetSwitchByKey("bHasActive") or #CC.MessageManager.GetAdvertiseList() == 0 then
				self:FindChild("Panel/DownBG/MoreBtn/MoreBG/advertiseBtn"):SetActive(false)
			end
			self:RunAction(self:FindChild("Panel/DownBG/MorePanel"):GetComponent("Image"),{"colorTo",0,0,0,50,0.2,ease=CC.Action.EOutSine})
			self:FindChild("Panel/DownBG/MorePanel"):SetActive(true)
			self:FindChild("Panel/DownBG/MoreBtn/MoreBG"):SetActive(true)
			if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= 20 then
				self:FindChild("Panel/DownBG/MoreBtn/MoreBG/vipServerBtn"):SetActive(true)
			end
		end, "click_setupopen")
	--关闭更多
	self:AddClick("Panel/DownBG/MorePanel",function ()
			self:RunAction(self:FindChild("Panel/DownBG/MorePanel"):GetComponent("Image"),{"colorTo",0,0,0,0,0.2,ease=CC.Action.EOutSine})
			self:FindChild("Panel/DownBG/MorePanel"):SetActive(false)
			self:FindChild("Panel/DownBG/MoreBtn/MoreBG"):SetActive(false)
		end, "click_setupopen")

	--打开客服界面
	self:AddClick("Panel/DownBG/MoreBtn/MoreBG/serverBtn/btn",function ()
		CC.ViewManager.OpenServiceView();
	end)
	self:AddClick("Panel/DownBG/MoreBtn/MoreBG/vipServerBtn/btn",function ()
		local url = self.viewCtr.webDataMgr.GetSpecialServiceUrl()
		Client.OpenURL(url)
	end)

	--打开设置界面
	self:AddClick("Panel/DownBG/MoreBtn/MoreBG/settingBtn/btn",function ()
		self.viewCtr.gameDataMgr.SetSwitchClick("SetUpSoundView")
		CC.ViewManager.Open("SetUpSoundView")
	end)

    --打开广告界面
	self:AddClick("Panel/DownBG/MoreBtn/MoreBG/advertiseBtn/btn",function()
		local popListCount = #(CC.MessageManager.GetAdvertiseList())
		local unreadIndex = CC.MessageManager.GetUnreadPouupIndex()
		if popListCount > 0 then
			if not unreadIndex then unreadIndex = math.random(1,popListCount) end
			CC.ViewManager.Open("PopupView", unreadIndex)
		end
	end)

end

function HallView:SetAgentBtnStatus()
	local agentStatus = self.viewCtr.agentDataMgr.GetAgentSatus()
	local promotionStatus = false
	if self.viewCtr.agentDataMgr.GetAgentSatus() or self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") then
		agentStatus = true
		self:StopTimer("HallAgentCountDown")
	elseif self.viewCtr.agentDataMgr.GetRemainTime() > 0 then
		promotionStatus = true
		self:SetCountDown()
	end
	self.agentBtn:SetActive(agentStatus or promotionStatus)
	self.agentBtn:FindChild("Effect/TuBiao/Agent"):SetActive(agentStatus)
	self.agentBtn:FindChild("Effect/TuBiao/Promotion"):SetActive(promotionStatus)
end
function HallView:SetAgentBtnEffet(value)
	self.agentBtn:FindChild("Effect_TGXT"):SetActive(value)
end
function HallView:SetCountDown()
	local timer = self.viewCtr.agentDataMgr.GetRemainTime()
	self.agentBtn:FindChild("Effect/TuBiao/Promotion/Time"):SetActive(true)
	self:StopTimer("HallAgentCountDown")
	self:StartTimer("HallAgentCountDown", 1, function()
		if timer < 0 then
			self:StopTimer("HallAgentCountDown")
			self.agentBtn:SetActive(false)
			return
		end
		self.agentBtn:FindChild("Effect/TuBiao/Promotion/Time").text = CC.uu.TicketFormat3(timer)
		timer = timer - 1
	end, -1)
end

--打开礼包
function HallView:OpenSelectActive()
	CC.ViewManager.OpenEx("SelectGiftCollectionView")
end

function HallView:RefreshUI(param)

	if param.showActiveBtns ~= nil then
		for _,v in ipairs(param.showActiveBtns) do
			self:FindChild(v.nodeName):SetActive(v.show)
		end
	end
end

function HallView:RefreshWaterSprinklingBtnStatus()
	-- local switchOn = self.viewCtr.activityDataMgr.GetActivityInfoByKey("MonopolyView").switchOn
	-- self.WaterIcon:SetActive(switchOn)
end

function HallView:RefreshBtnStatus(key)
	if key == "MonthRebateView" then
		local switchOn = self.switchDataMgr.GetSwitchStateByKey("Monthendrebate") and self.viewCtr.activityDataMgr.GetActivityInfoByKey("MonthRebateView").switchOn
		self.RebateBtn:SetActive(switchOn)
	end
end

function HallView:ChangeGaussBlur(b)
	self.GaussBlur.enabled = b
end

function HallView:OnFocusIn()
	if self.viewCtr.guideState then
		self.viewCtr:OpenGuideGive()
	end
	if self.viewCtr.RenameCardState then
		self.viewCtr:CheckRenameGuide()
	end
	self:ChangeGaussBlur(false);

	if not CC.LocalGameData.GetDailyStateByKey("TenSecTip") and not self.viewCtr.guideView then
		--大厅界面15秒提示
		self.remainTime = 15
		self:StopTimer("HallTenSecCountDown")
		self:StartTimer("HallTenSecCountDown", 1, function()
			if self.remainTime < 0 then
				self:StopTimer("HallTenSecCountDown")
				CC.LocalGameData.SetDailyStateByKey("TenSecTip", true)
				CC.ViewManager.Open("GameTipView", {tipType = 1})
				return
			end
			self.remainTime = self.remainTime - 1
		end, -1)
	end
end

function HallView:OnFocusOut()
	self:StopTimer("HallTenSecCountDown")
	self:ChangeGaussBlur(true);
end

function HallView:RefreshChat(state)
	self:FindChild("Panel/ChatPanel/ChatBtn/xinxi"):SetActive(state)
end

function HallView:RefreshChatPri(priState)
	self:FindChild("Panel/ChatPanel/ChatBtn"):SetActive(not priState)
	self:FindChild("Panel/ChatPanel/ChatPriBtn"):SetActive(priState)
end

function HallView:RefreshMainRedDot(param)
	self:FindChild(param.node):SetActive(param.state)
end

function HallView:RefreshSubRedDot(param)
	if param.node ~= nil then
		self:FindChild(param.node):SetActive(param.state)
	end
end

function HallView:RefreshSwitchState()
	local realStoreBtn = self:FindChild("Panel/DownBG/RealStoreBtn")
	if CC.ChannelMgr.GetTrailStatus() then
		realStoreBtn:SetActive(false);
	else
		realStoreBtn:SetActive(self.switchDataMgr.GetSwitchStateByKey("TreasureView"))
		--self:FindChild("Panel/DownBG/RealStoreBtn/Effect_UI_DuoBao"):SetActive(self.switchDataMgr.GetSwitchStateByKey("TreasureEffect"))
	end
end

function HallView:ShowTreasureTip(state, isNotStock)
	local Text = self:FindChild("Panel/DownBG/RealStoreBtn/tip/Text"):GetComponent("Text")
	if state and isNotStock then
		Text.text = self.language.treasure_tip
	else
		if Text.text ~= self.language.treasure_tip then
			Text.text = self.language.treasure_tip1
		end
	end
	self:FindChild("Panel/DownBG/RealStoreBtn/tip"):SetActive(state)
end

--筹码达到10w，游客玩家提示
function HallView:ChipChange()
	if not CC.HallUtil.CheckGuest() then return end
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") >= 100000 and not CC.DataMgrCenter.Inst():GetDataByKey("Game").GetChipTip() then
		CC.DataMgrCenter.Inst():GetDataByKey("Game").SetChipTip()
		local box = CC.ViewManager.ShowMessageBox(self.language.tipChouma)
		box:SetOneButton()
	end
end

function HallView:ShowSendTip(state)
	self:FindChild("Panel/TopBG/RightMgr/SendBtn/tip"):SetActive(state)
end

function HallView:SetCanClick(flag)
	self._canClick = flag
end

--引导已完成显示上下按钮
function HallView:GuideShowButton()
	if not self.hideHallPanel then return end
	self.hideHallPanel = false
	self:FindChild("Panel/TopBG/NodeMgr"):SetActive(true)
	self:RunAction(self.hallPanel,  {"localMoveTo", self.hallPanel.transform.x, self.hallPanel.transform.y + 300, 0.2, ease=CC.Action.EOutSine})
	self:RunAction(self.rightBtnGroup,  {"localMoveTo", self.rightBtnGroup.transform.x, self.rightBtnGroup.transform.y - 300, 0.2, ease=CC.Action.EOutSine})

	self:FindChild("Panel/ChatPanel/ChatBtn"):SetActive(self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel"))
	self:FindChild("Panel/TopBG/Mask"):SetActive(false)
end

function HallView:GuideHideBtn()
	local guideData = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetGuide()
	if guideData.state and guideData.Flag < 1 then
		self.hideHallPanel = true
		self.hallPanel.localPosition = Vector3(self.hallPanel.transform.x, self.hallPanel.transform.y - 300, 0)
		self.rightBtnGroup.localPosition = Vector3(self.rightBtnGroup.transform.x, self.rightBtnGroup.transform.y + 300, 0)

		self:FindChild("Panel/ChatPanel"):SetActive(false)
		self:FindChild("Panel/TopBG/Mask"):SetActive(true)
		self:FindChild("Panel/TopBG/NodeMgr"):SetActive(false)
	end
end

function HallView:GuideGetVector(index)
	local btn = nil
	if index == 4 then
		btn = self:FindChild("Panel/DownBG/FreeBtn")
	elseif index == 5 then
		btn = self:FindChild("Panel/DownBG/GiftBtn")
	elseif index == 30 then
		btn = self:FindChild("Panel/TopBG/RightMgr/SendBtn")
	elseif index == 8 then
		btn = self:FindChild("Panel/DownBG/RealStoreBtn")
	elseif index == 32 then
		btn = self:FindChild("Panel/TopBG/HeadNode")
	elseif index == 27 then
		btn = self:FindChild("Panel/TopBG/RightMgr/AgentBtn")
	end
	if btn then
		local v2 = UnityEngine.RectTransformUtility.WorldToScreenPoint(self:GlobalCamera(),btn.position)
		local silder,  offset_y = 60, -100
		if index == 4 or index == 5 or index == 8 then
			silder = 80
			offset_y = 130
		end
		local param = {vect1 = v2, sizeX1 = silder, sizeY1 = silder, offset_y = offset_y, maskMode = "_MASKMODE_RECTANGLE"}
		param.flag = index
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnHighlightInfo, param)
		--self.viewCtr.guideView:SetHighlight(param, index)
	end
end

--临时用竖版界面测试
function HallView:AddPortraitTestBtn()
	if CC.DebugDefine.GetDebugMode() and CC.DebugDefine.GetEnvState() == CC.DebugDefine.EnvState.Dev then
		local btn = CC.uu.newObject(self:FindChild("Panel/DownBG/MoreBtn/MoreBG/settingBtn"),self:FindChild("Panel/DownBG/MoreBtn/MoreBG"))
		self:AddClick(btn:FindChild("btn"),function ()
				CC.ViewManager.Open("PortraitTestView")
			end)
	end
end

function HallView:OnDestroy(destroyOnLoad)
	if self.co_InitUI then
		coroutine.stop(self.co_InitUI)
		self.co_InitUI = nil
	end
	self:CancelAllDelayRun()
	self:StopTimer("HallAgentCountDown")
	self:StopTimer("HallTenSecCountDown")

	if self.headIcon then
		self.headIcon:Destroy()
		self.headIcon = nil
	end
	if self.chipCounter then
		self.chipCounter:Destroy()
		self.chipCounter = nil
	end
	if self.integralCounter then
		self.integralCounter:Destroy()
		self.integralCounter = nil
	end
	if self.VIPCounter then
		self.VIPCounter:Destroy()
		self.VIPCounter = nil
	end
	if self.diamondCounter then
		self.diamondCounter:Destroy()
		self.diamondCounter = nil
	end
	if self.freeChipsBtn then
		self.freeChipsBtn:Destroy()
		self.freeChipsBtn = nil
	end
	if self.GiftBtn then
		self.GiftBtn:Destroy()
		self.GiftBtn = nil
	end
	if self.marsTaskIcon then
		self.marsTaskIcon:Destroy()
		self.marsTaskIcon = nil
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
	if self.gameList then
		self.gameList:Destroy(destroyOnLoad)
		self.gameList = nil
	end

	if self.activeEntryIcon then
		self.activeEntryIcon:Destroy();
	end
	if self.midActiveIcon then
		self.midActiveIcon:Destroy();
	end

	if self.packageTest then
		CC.uu.destroyObject(self.packageTest);
	end

	-- CC.SubGameInterface.DestryShake(self.anbu)
end

return HallView