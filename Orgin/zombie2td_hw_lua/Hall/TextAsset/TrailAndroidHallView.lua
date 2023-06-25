local CC = require("CC")

local HallView = require("View/HallView/HallView")
local TrailAndroidHallView = CC.uu.ClassView("TrailAndroidHallView",nil,HallView)
local viewCtrClass = require("View/TrailView/TrailAndroidHallViewCtr")

function TrailAndroidHallView:OnCreate()
	CC.uu.LoadHallPrefab("prefab","hallSupportRotate",GameObject.Find("HallCamera/GUICamera").transform)
	CC.uu.DelayRun(1.0,function()
		CC.uu.destroyObject(GameObject.Find("HallCamera/GUICamera/hallSupportRotate"))
	end)

	self.GaussBlur.enabled = false

	self.viewCtr = viewCtrClass.new(self);
	self.viewCtr:OnCreate()

	self:InitUI()
	self:InitTextByLanguage()
	self:RefreshSwitchState()

	self:AddClickEvent()
end

function TrailAndroidHallView:InitUI()
	self.language = CC.LanguageManager.GetLanguage("L_HallView");

	self.co_InitUI = coroutine.start(function()

		local chipNode = self:FindChild("Panel/TopBG/NodeMgr/ChipNode")
		self.chipCounter = CC.HeadManager.CreateChipCounter({parent = chipNode})
		coroutine.step(1)
		local diamondNode = self:FindChild("Panel/TopBG/NodeMgr/DiamondNode")
		self.diamondCounter = CC.HeadManager.CreateDiamondCounter({parent = diamondNode});
		coroutine.step(1)
		local headNode = self:FindChild("Panel/TopBG/HeadNode")
		self.headIcon = CC.HeadManager.CreateHeadIcon({parent = headNode})
		coroutine.step(1)
		local vipNode = self:FindChild("Panel/TopBG/NodeMgr/VipNode")
		chipNode.localPosition = vipNode.localPosition
		coroutine.step(1)

		self:InitGameList()
	end)

	--初始化更多界面屏蔽点击的宽高
	self:FindChild("Panel/DownBG/MorePanel").transform.width = self:FindChild("Panel"):GetComponent('RectTransform').rect.width
	self:FindChild("Panel/DownBG/MorePanel").transform.height = self:FindChild("Panel"):GetComponent('RectTransform').rect.height

	self.SendBtn = self:FindChild("Panel/TopBG/RightMgr/SendBtn")

	if not CC.ChannelMgr.GetSwitchByKey("bShowSendChip") then
		self.SendBtn:SetActive(false);
	end

	if not CC.ChannelMgr.GetSwitchByKey("bShowTotalRank") then
		self:FindChild("Panel/DownBG/RankBtn"):SetActive(false);
	end

	if not CC.ChannelMgr.GetSwitchByKey("bHasActive") then
		self:FindChild("Panel/DownBG/ActiveBtn"):SetActive(false);
	end	
end

function TrailAndroidHallView:InitGameList()
	local classname = "TrailAndroidGameList"
	self.gameList = CC.uu.CreateHallView(classname,self:FindChild("Panel/GameList"),self,self.transform)
end

function TrailAndroidHallView:AddClickEvent()
	--打开邮箱
	self:AddClick("Panel/TopBG/RightMgr/MailBtn",function ()
		self.viewCtr.gameDataMgr.SetSwitchClick("MailView")
		CC.ViewManager.Open("MailView")
	end)
	---------------------------------------下方按钮---------------------------------------
	--好友
	self:AddClick("Panel/DownBG/FriendBtn/icon", function ()
		self.viewCtr.gameDataMgr.SetSwitchClick("FriendView")
		CC.ViewManager.Open("FriendView")
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshRedPointState, {key = "friend",state = false});
	end)

	-- 打开商店
	self:AddClick("Panel/DownBG/ShopBtn/icon",function ()
		self.viewCtr.gameDataMgr.SetSwitchClick("StoreView")
		CC.ViewManager.Open("StoreView")
	end)

	--打开排行榜
	self:AddClick("Panel/DownBG/RankBtn/icon", function ()
		--请求排行榜数据
		self.viewCtr.gameDataMgr.SetSwitchClick("RankingListView")
		CC.ViewManager.Open("RankCollectionView")
	end)

	--打开活动
	self:AddClick("Panel/DownBG/ActiveBtn/icon",function ()
		self.viewCtr.gameDataMgr.SetSwitchClick("ActiveView")
		CC.ViewManager.Open("ActiveView")
	end)

	--打开聊天
	self:AddClick("Panel/ChatPanel/ChatBtn",function ()
		if CC.ChatManager.ChatPanelToggle() then
			CC.ViewManager.ShowChatPanel()
		else
			CC.ViewManager.ShowTip(self.language.tip_fix)
		end
	end)

	--打开更多
	self:AddClick("Panel/DownBG/MoreBtn/icon", function ()
		if #CC.MessageManager.GetAdvertiseList() == 0 or not CC.ChannelMgr.GetSwitchByKey("bHasActive") then
			self:FindChild("Panel/DownBG/MoreBtn/MoreBG/advertiseBtn"):SetActive(false)
		end
		self:RunAction(self:FindChild("Panel/DownBG/MorePanel"):GetComponent("Image"),{"colorTo",0,0,0,50,0.2,ease=CC.Action.EOutSine})
		self:FindChild("Panel/DownBG/MorePanel"):SetActive(true)
		self:FindChild("Panel/DownBG/MoreBtn/MoreBG"):SetActive(true)
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

	--打开设置界面
	self:AddClick("Panel/DownBG/MoreBtn/MoreBG/settingBtn/btn",function ()
		self.viewCtr.gameDataMgr.SetSwitchClick("SetUpSoundView")
		CC.ViewManager.Open("SetUpSoundView")
	end)
end

function TrailAndroidHallView:RefreshMainRedDot(param)

end

function TrailAndroidHallView:RefreshSubRedDot(param)

end

function TrailAndroidHallView:RefreshWaterSprinklingBtnStatus(isShow,isOpen)
	
end

function TrailAndroidHallView:InitTextByLanguage()
	
end

function TrailAndroidHallView:OnFocusIn()
	if self.viewCtr.guideState then
		self.viewCtr:OpenGuideGive()
	end
	if self.viewCtr.RenameCardState then
		self.viewCtr:CheckRenameGuide()
	end
	self:ChangeGaussBlur(false);
end

--检查后续弹窗
function TrailAndroidHallView:CheckBehindView()
	if self:CheckInvited() then
		return
	end

	if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetPingSwitch() then
		local param = {}
		param.closeFunc = function ()
			--请求竞技场信息
			CC.DataMgrCenter.Inst():GetDataByKey("ArenaData").GetGameArena()
		end
		if CC.Player.Inst():GetBirthdayGiftData().Status == 1 then
			CC.ViewManager.OpenEx("BirthdayAwardView")
		end
		if self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") and self.activityDataMgr.GetActivityInfoByKey("AnniversaryTurntableView").switchOn then
			-- CC.ViewManager.OpenEx("AnniversaryTurntableView",param)
		else
			CC.ViewManager.OpenEx("FreeChipsCollectionView",param)
		end
		if CC.LocalGameData.GetLocalDataToKey("BirthdayGift", CC.Player.Inst():GetSelfInfoByKey("Id")) then
			--生日礼包
			if CC.Player.Inst():GetBirthdayGiftData().Status == 1 or CC.Player.Inst():GetBirthdayGiftData().GiftStatus == 1 then
				CC.ViewManager.OpenEx("BirthdayView")
			end
		end
		-- CC.ViewManager.OpenEx("SelectGiftCollectionView")
		if CC.LocalGameData.GetLocalDataToKey("LuckyTurntable", CC.Player.Inst():GetSelfInfoByKey("Id")) then
			--每日首次关闭,打开幸运礼包
			CC.ViewManager.OpenEx("LuckyTurntableView")
			CC.LocalGameData.SetLocalDataToKey("LuckyTurntable", CC.Player.Inst():GetSelfInfoByKey("Id"))
		end
	end

	self:CheckOpenPopView()
end


function TrailAndroidHallView:RefreshChatPri(priState)
	self:FindChild("Panel/ChatPanel/ChatBtn"):SetActive(not priState)
end

--筹码达到10w，游客玩家提示
function TrailAndroidHallView:ChipChange()

end

return TrailAndroidHallView