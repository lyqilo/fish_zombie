
local CC = require("CC")
local VipRightsGiftView = CC.uu.ClassView("VipRightsGiftView")

function VipRightsGiftView:ctor(param)
	self:InitVar(param);
end

function VipRightsGiftView:InitVar(param)
    self.param = param
    self.WareIds = {"30069","30070","30071","30072","30073","30074","30075","30076","30077","30078","30079"}
    self.language = self:GetLanguage()
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.BaseGifts = {{WareId = "30069",VIP = 0,BuyTime = 0,LimitBuyTime = 1,IconId = 1,Rewards ={"prop_img_3006",0,"57K","100K"}},
	              {WareId = "30070",VIP = 1,BuyTime = 0,LimitBuyTime = 1,IconId = 1,Rewards ={"",1,"160K","500K"}},
				  {WareId = "30071",VIP = 2,BuyTime = 0,LimitBuyTime = 1,IconId = 1,Rewards ={"",3,"365K","1M"}}, 
				  {WareId = "30072",VIP = 3,BuyTime = 0,LimitBuyTime = 1,IconId = 2,Rewards ={"",5,"600K","2M"}},
				  {WareId = "30073",VIP = 4,BuyTime = 0,LimitBuyTime = 1,IconId = 2,Rewards ={"",7,"1M","3M"}},
				  {WareId = "30074",VIP = 5,BuyTime = 0,LimitBuyTime = 3,IconId = 3,Rewards ={"prop_img_3007",10,"1.96M","5M"}},
				  {WareId = "30075",VIP = 8,BuyTime = 0,LimitBuyTime = 3,IconId = 3,Rewards ={"",15,"3.15M","8M"}},
				  {WareId = "30076",VIP = 11,BuyTime = 0,LimitBuyTime = 5,IconId = 3,Rewards ={"prop_img_3008",20,"6.8M","10M"}},
				  {WareId = "30077",VIP = 16,BuyTime = 0,LimitBuyTime = 5,IconId = 4,Rewards ={"prop_img_3009",25,"21M","30M"}},
				  {WareId = "30078",VIP = 21,BuyTime = 0,LimitBuyTime = 5,IconId = 4,Rewards ={"prop_img_3010",30,"40M","50M"}},
				  {WareId = "30079",VIP = 26,BuyTime = 0,LimitBuyTime = 5,IconId = 5,Rewards ={"",50,"82M","100M"}}
				 }
	self.Gifts = {}
	self.CurGift = 1
	self.CurPage = 1
end

function VipRightsGiftView:OnCreate()
	self:InitNode()
    self:InitView()
    self:InitClickEvent()
    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()
end

function VipRightsGiftView:InitNode()
	self.SmashEggsPanel = self:FindChild("SmashEggsPanel")
	self.BgBtn = self:FindChild("Bg/BgBtn")
	self.LeftBtn = self:FindChild("Bg/LeftBtn")
	self.RightBtn = self:FindChild("Bg/RightBtn")
end

function VipRightsGiftView:InitView()
	if self.param and self.param.parent then
		self.transform:SetParent(self.param.parent)
		self:FindChild("Bg/CloseBtn"):SetActive(false)
	end
	self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform})
	self.walletView.DiamondNode:SetActive(false)
end

function VipRightsGiftView:InitClickEvent()
	self:AddClick(self:FindChild("Bg/Light/ExplainBtn") , function() self:OpenExplainView(self.language.explainTitle,self.language.explainContent) end)
	self:AddClick(self.LeftBtn , function() self:GiftSwitch("Left") end)
	self:AddClick(self.RightBtn , function() self:GiftSwitch("Right") end)
	self:AddClick(self.BgBtn , function() self:OnClickBgBtn() end)
	self:AddClick(self:FindChild("Bg/CloseBtn") , function() self:Destroy() end)
	for i=1,2 do
	   self:AddClick(self:FindChild("Bg/Content/Group/"..i.."/BuyBtn") , function() self:ReqBuyGift() end)
	end
end

function VipRightsGiftView:OpenExplainView(tit, cont)
	local data = {
		title = tit,
		content = cont,
	}
	CC.ViewManager.Open("CommonExplainView",data )
end

function VipRightsGiftView:GiftSwitch(direction)
	if table.length(self.Gifts) <= 0 then return end
	local result = 0
	local NextPage =  self.CurPage == 1 and 2 or 1
	local TempGroup = self:FindChild("Bg/Content/Group")
	local CurPagePos = TempGroup:FindChild(self.CurPage).transform.localPosition
	if direction == "Left" then
		if self.CurGift == 1 then
			return
		end
		result = -1
	else
		if self.CurGift == self.GiftNum then
			return
		end
		result = 1
	end
	TempGroup:FindChild(NextPage):SetActive(true)
	TempGroup:FindChild(NextPage).transform.localPosition = Vector3(-82 + result * 1280,31.5,0)
	self:RefreshView(NextPage,self.CurGift + result)
	
	self:SetCanClick(false)
	self:RunAction(TempGroup:FindChild(self.CurPage),{"localMoveTo", -result*1280,31.5,0.3})
	self:RunAction(TempGroup:FindChild(NextPage),{"localMoveTo", -82,31.5, 0.3,function()
		TempGroup:FindChild(self.CurPage):SetActive(false)
		self.CurPage = NextPage
		self.CurGift = self.CurGift + result
		self:SetCanClick(true)
	end})
end

function VipRightsGiftView:RefreshView(Page,GiftIndex)
	if table.length(self.Gifts) <= 0 or CC.uu.IsNil(self.transform) then return end
	local Gift = self.Gifts[GiftIndex]
	local VipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	local tempTransform = self:FindChild("Bg/Content/Group/"..Page)
	tempTransform:FindChild("UI/Girl/Tip/Text").text = string.format(self.language.GirlTip,Gift.BuyTime.."/"..Gift.LimitBuyTime)
	tempTransform:FindChild("BuyBtn/Price").text = self.wareCfg[Gift.WareId].Price
	tempTransform:FindChild("UI/ChipBg/Text").text = string.format(self.language.Tip1, Gift.Rewards[4])
	tempTransform:FindChild("UI/ChipBg/Lock/Text").text = string.format(self.language.LockTxt,Gift.VIP)

	self:SetImage(tempTransform:FindChild("UI/JinDan/JinDan"),"grzx_thlb_jd0"..Gift.IconId)

	self.LeftBtn:SetActive(not (GiftIndex == 1))
	self.RightBtn:SetActive(not (GiftIndex == self.GiftNum))
	tempTransform:FindChild("UI/ChipBg/Lock"):SetActive(not ( VipLevel >= Gift.VIP))
	tempTransform:FindChild("UI/ChipBg/DengDai"):SetActive( VipLevel >= Gift.VIP)
	local isShowBgBtn = true
	local Index = ""
	for i=1,self.GiftNum do
		local tempGift = self.Gifts[i]
			if VipLevel >= tempGift.VIP and tempGift.BuyTime < tempGift.LimitBuyTime then
				Index = i
				break
			end
	end
	if Index ~= "" and Index == GiftIndex then
		isShowBgBtn = false
	end
	self.BgBtn:SetActive(isShowBgBtn)

	local tran = tempTransform:FindChild("UI/ChipBg/QiPao")
	for i=1,3 do
		local isActive = true
		local reward = Gift.Rewards[i]
		if reward ~= "" then
			if reward == 0 then
				self:SetImage(tran:FindChild(i.."/Image"),"Coin3")
				tran:FindChild(i.."/Text").text = string.format(self.language.Tip2, Gift.Rewards[3])
				tran:FindChild(tostring(3)):SetActive(false)
				break
			else
				if i == 1 then
					if Gift.BuyTime == 0 then
						self:SetImage(tran:FindChild("1/Image"),reward)
					else
						isActive = false
					end
				else
					self:SetImage(tran:FindChild(i.."/Image"),i==2 and "prop_img_36" or "Coin3")
					tran:FindChild(i.."/Text").text = i==2 and reward or string.format(self.language.Tip2, reward)
				end
			end
		else
			isActive = false
		end
		tran:FindChild(tostring(i)):SetActive(isActive)
	end
end

function VipRightsGiftView:OnClickBgBtn()
	local VipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	local Gift = self.Gifts[self.CurGift]
	local result = ""
	for i = 1,self.GiftNum do
		local Data = self.Gifts[i]
		if VipLevel >= Data.VIP and Data.BuyTime < Data.LimitBuyTime then
			result = i
			break
		end
	end
	if result ~= "" then
		local box = CC.ViewManager.ShowMessageBox(self.language.BuyBeforGift,function()
			self.CurGift = result
			self:RefreshView(self.CurPage,self.CurGift)
		end)
		box:SetOneButton()
	else
		local bLimit = CC.ChannelMgr.CheckOppoChannel() or CC.ChannelMgr.CheckVivoChannel() or CC.ChannelMgr.CheckOfficialWebChannel()
		if bLimit then
			if VipLevel >=0 and VipLevel <=3 then
				CC.ViewManager.Open("VipThreeCardView")
			else
				CC.ViewManager.Open("StoreView")
			end
		else
			if VipLevel == 0 or VipLevel == 1 then
				CC.ViewManager.Open("SelectGiftCollectionView", {currentView = "NoviceGiftView"})
			elseif VipLevel == 2 then
				CC.ViewManager.Open("SelectGiftCollectionView", {currentView = "VipThreeCardView"})
			else
				CC.ViewManager.Open("StoreView")
			end
		end
		local view = CC.ViewManager.GetViewByName("PersonalInfoView")
		if view then view:CloseView() end
	end
end

function VipRightsGiftView:SmashEggs()
	if self.isSmashEggs then return end
	self.isSmashEggs = true
	local Rewards = self.viewCtr.DataList[1].reward
	local isOpenCrystalStore = self.viewCtr.DataList[1].isOpenCrystalStore
	table.remove(self.viewCtr.DataList,1)
	local Data = self.Gifts[self.CurGift]
	self.SmashEggsSkeleton = self.SmashEggsPanel:FindChild("Skeleton"):GetComponent("SkeletonGraphic")
	self.SmashEggsPanel:SetActive(true)
	self.SmashEggsSkeleton:SetActive(true)
	CC.Sound.PlayHallEffect("rightgift_zd")
	if self.SmashEggsSkeleton.AnimationState then
		self.SmashEggsSkeleton.AnimationState:ClearTracks()
		self.SmashEggsSkeleton.AnimationState:SetAnimation(0, "stand", false)
	end
	
	local CompleteFun1 = nil
	local CompleteFun2 = nil
	CompleteFun1 = function ()
		self.SmashEggsSkeleton.AnimationState:ClearTracks()
		self.SmashEggsSkeleton.AnimationState:SetAnimation(0, "stand2", false)
		CompleteFun2 = function ( )
			self:ShowReward(Rewards,isOpenCrystalStore)
			self.SmashEggsSkeleton.AnimationState.Complete =  self.SmashEggsSkeleton.AnimationState.Complete - CompleteFun2
		end
		self.SmashEggsSkeleton.AnimationState.Complete =  self.SmashEggsSkeleton.AnimationState.Complete + CompleteFun2
		self.SmashEggsSkeleton.AnimationState.Complete =  self.SmashEggsSkeleton.AnimationState.Complete - CompleteFun1
    end
	self.SmashEggsSkeleton.AnimationState.Complete =  self.SmashEggsSkeleton.AnimationState.Complete + CompleteFun1
end

function VipRightsGiftView:ShowReward(Rewards,isOpenCrystalStore)
	if self.SmashEggsSkeleton.AnimationState then
        self.SmashEggsSkeleton.AnimationState:ClearTracks()
        self.SmashEggsSkeleton.AnimationState:SetAnimation(0, "stand2", false)
	end
	
	self:DelayRun(0.016,function()
		self.SmashEggsSkeleton:SetActive(false)
		local callbackFun = function()
			if CC.uu.IsNil(self.transform) then return end
			self.SmashEggsPanel:SetActive(false)
			if self.viewCtr.isFinishBuy then
				CC.HallNotificationCenter.inst():post(CC.Notifications.ShowRightGift, false)
			end
			if isOpenCrystalStore then
				CC.ViewManager.Open("CrystalStoreView")
			end
			self.isSmashEggs = false
			if table.length(self.viewCtr.DataList) > 0 and not self.isSmashEggs then
				self:SmashEggs()
			end
		end
		CC.ViewManager.OpenRewardsView({items = Rewards ,callback = callbackFun})
	end)
end

function VipRightsGiftView:ReqBuyGift()
	if table.length(self.Gifts) <= 0 then return end
	local Data = self.Gifts[self.CurGift]
	local wareInfo = self.wareCfg[Data.WareId]
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= wareInfo.Price then
		CC.Request("ReqBuyWithId",{WareId = wareInfo.Id , ExchangeWareId = wareInfo.Id})
    else
		if self.walletView then
			self.walletView:SetBuyExchangeWareId(wareInfo.Id)
            self.walletView:PayRecharge()
		end
    end
end

function VipRightsGiftView:ActionIn()  
end

function VipRightsGiftView:ActionOut() 
end

function VipRightsGiftView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
    end
    if self.walletView then
		self.walletView:Destroy()
	end
end

return VipRightsGiftView