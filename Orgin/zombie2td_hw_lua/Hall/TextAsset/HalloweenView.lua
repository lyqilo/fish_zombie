local CC = require("CC")
local HalloweenView = CC.uu.ClassView("HalloweenView")

function HalloweenView:ctor(param)
    self.param = param;
	self.language = self:GetLanguage()
	self.PrefabSignTab = {}
	self.PrefabTaskTab = {}
	self.PrefabShopTab = {}
	self.AwardProfab = {}
	self.togList = {}
	self.scollPlane = {}
	self.signPrefabList = {}
	self.taskPrefabList = {}
	self.shopPrefabList = {}
	--红点
	self.shopShowRedDot = false
	self.taskShowRedDot = false
	self.musicName = nil
	self.captureProcess,self.synthesisProcess = 0,0
end

function HalloweenView:OnCreate()
	self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
	self.prop = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self:InitUI()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
end

function HalloweenView:InitUI()
	--签到、任务、商店
	self.scollPlane[1] = self:FindChild("SignScroll")
	self:FindChild("SignScroll"):SetActive(true)
	self.scollPlane[2] = self:FindChild("TaskScroll")
	self.scollPlane[3] = self:FindChild("ShopScroll")
	self.signParent = self:FindChild("SignScroll/Viewport/Content")
	self.signItem = self:FindChild("SignScroll/Viewport/SignItem")
	self.taskParent = self:FindChild("TaskScroll/Content")
	-- HalloweenItem\TaskItem
	self.taskItem = self:FindChild("TaskScroll/HalloweenItem")
	self.shopParent = self:FindChild("ShopScroll/Viewport/Content")
	self.shopItem = self:FindChild("ShopScroll/Viewport/ShopItem")
	self.bubbleTip = self:FindChild("BubbleTip")
	self.awardScr = self.bubbleTip:FindChild("AwardScr")
	self.awardItem = self.bubbleTip:FindChild("AwardItem")
	self:AddClick("closeTip", function ()
		self.bubbleTip:SetActive(false)
		self:FindChild("closeTip"):SetActive(false)
	end)

	for i = 1, 3 do
		local index = i
		self.togList[index] = self:FindChild(string.format("RightPlane/Tog%s", index))
		UIEvent.AddToggleValueChange(self.togList[index], function(selected)
			if selected then
				self:ToggleChange(index)
			end
		end)
	end
	self.togList[1]:GetComponent("Toggle").isOn = true
	self:AddClick("TaskScroll/Banner", function ()
		local view = self.captureProcess >= self.synthesisProcess and "WaterCaptureRankView" or "WaterOtherRankView"
		if self.activityDataMgr.GetActivityInfoByKey(view).switchOn then
			CC.ViewManager.Open("RankCollectionView",{currentView = view})
		end
		
	end)
	self:AddClick("BtnClose", function ()
		self:CloseView()
	end)
	-- self:DelayRun(0.1, function()
	-- 	self.musicName = CC.Sound.GetMusicName();
	-- 	CC.Sound.PlayHallBackMusic("HalloweenBg");
	-- end)
	self:LanguageSwitch()

	self:AddClick("TaskPanel1/Mask", function() self:HidePanel(self:FindChild("TaskPanel1")) end)
	self:AddClick("TaskPanel2/Mask", function() self:HidePanel(self:FindChild("TaskPanel2")) end)
end

--语言切换
function HalloweenView:LanguageSwitch()
	self:FindChild("RightPlane/Time").text = string.format("%s\n%s",self.language.TimeTitle,self.language.time)
	self:FindChild("TaskPanel1/Frame/Scroll View/Image/Target").text = self.language.WaterCapture
	self:FindChild("TaskPanel1/Frame/Scroll View/Image/Reward").text = self.language.jiangli
	self:FindChild("TaskPanel1/Frame/BottomText").text = self.language.alltasktip
	self:FindChild("TaskPanel2/Frame/Scroll View/Image/Target").text = self.language.WaterOther
	self:FindChild("TaskPanel2/Frame/Scroll View/Image/Reward").text = self.language.jiangli
	self:FindChild("TaskPanel2/Frame/BottomText").text = self.language.alltasktip
	self.togList[2]:FindChild("Text").text = self.language.Challenge
	self.togList[2]:FindChild("Selected/Text").text = self.language.Challenge
	self.togList[1]:FindChild("Text").text = self.language.Sign
	self.togList[1]:FindChild("Selected/Text").text = self.language.Sign
	self.togList[3]:FindChild("Text").text = self.language.Shop
	self.togList[3]:FindChild("Selected/Text").text = self.language.Shop
	self.signItem:FindChild("GoBtn/Text").text = self.language.GoBtn
	self.signItem:FindChild("GetBtn/Text").text = self.language.GetBtn
	self.signItem:FindChild("GrayBtn/Text").text = self.language.GrayBtn
	self.taskItem:FindChild("GoBtn/Text").text = self.language.GoBtn
	self.taskItem:FindChild("GetBtn/Text").text = self.language.GetBtn
	self.taskItem:FindChild("GrayBtn/Text").text = self.language.GetBtn
	self.taskItem:FindChild("help").text = self.language.taskHelp
	self.shopItem:FindChild("GoBtn/Text").text = self.language.GoBtn
	self.shopItem:FindChild("GetBtn/Text").text = self.language.ConvertBtn

	self:FindChild("Left/title").text = self.language.title
	for i = 1,4 do
		self:FindChild("Left/explain"..i).text = self.language["explain"..i]
		
	end
end

function HalloweenView:ToggleChange(index)
	for i = 1, #self.scollPlane do
		if index == i then
			self.scollPlane[i]:SetActive(true)
		else
			self.scollPlane[i]:SetActive(false)
		end
	end
end

--初始化item
function HalloweenView:InitScrollItem(data, PrefabTab, item, parent)
	local list = data
	for _,v in pairs(PrefabTab) do
		v.transform:SetActive(false)
	end
	if #list > 0 then
		for i = 1, #list do
			local index = i
			local obj = PrefabTab[index]
			if obj == nil then
				obj = CC.uu.newObject(item)
				obj.transform.name = tostring(index)
				obj.transform:SetParent(parent, false)
				PrefabTab[index] = obj.transform
			end
		end
	end
end

--签到列表
function  HalloweenView:InitSignInfo(data)
	self:InitScrollItem(data, self.PrefabSignTab, self.signItem, self.signParent)
	local list = data
	for i = 1,#list do
		self:AddSignItemData(i,list[i])
	end
end

function HalloweenView:AddSignItemData(index, data)
	local item = self.PrefabSignTab[index]
	if item then
		item:SetActive(true)
		local num = math.floor(data.ID / 1000)
		item:FindChild("name").text = string.format(self.language.SignDes, num)
		-- if self.viewCtr.signRewardList[num] then
		-- 	item:FindChild("reward").text = string.format("x%s", self.viewCtr.signRewardList[num])
		-- end
		item:FindChild("reward").text = string.format("x%s", data.RewardInfos[1].PropNum)
		self:SetImage(item:FindChild("Goods/icon"),self.prop[data.RewardInfos[1].PropID].Icon)
		item:FindChild("GrayBtn"):SetActive(not data.IsFinish)
		item:FindChild("fulfill"):SetActive(data.IsFinish and data.IsReward or false)
		item:FindChild("GetBtn"):SetActive(data.IsFinish and not data.IsReward or false)
		self:AddClick(item:FindChild("GetBtn"), function( )
			self.viewCtr:ReqSignReward(data.ID)
		end)
	end
end

--任务列表
function  HalloweenView:InitTaskInfo(data)
	CC.uu.Log(data,"InitTaskInfo-->>data:")
	local list = data
	self:InitScrollItem(data, self.PrefabTaskTab, self.taskItem, self.taskParent)
	self.taskShowRedDot = false
	for i = 1,#list do
		self:AddTaskItemData(i,list[i])
	end
	self.togList[2]:FindChild("RedDot"):SetActive(self.taskShowRedDot)
end

function HalloweenView:AddTaskItemData(index, data)
	local num = math.floor(data.ID / 1000)
	if num ~= 8 and num ~= 9 then return end
	local item = self.PrefabTaskTab[index]
	if item then
		item:SetActive(true)
		item:FindChild("Text").text = self.language.getlight
		-- local scale = data.CurProcess / data.AllTarget
		-- item:FindChild("totalprogress/image"):GetComponent("Image").fillAmount = data.CurProcess >= data.AllTarget and 1 or scale
		-- item:FindChild("totalprogress/Text").text = string.format("%s%s",data.CurProcess >= data.AllTarget and "100" or CC.uu.keepDecimal(scale,2,true)*100,"%")
		-- if num == 8 then
		-- 	item:FindChild("name").text = self.language.WaterCapture
		-- 	self.captureProcess = data.CurProcess
		-- else
		if index == 2 then
			item:FindChild("name").text = "สะสมเดิมพันเกมรวม"
		end
		
		-- 	self.synthesisProcess = data.CurProcess
		-- end
		item:FindChild("num").text = string.format("%s/%s", CC.uu.DiamondFortmat(data.Process), CC.uu.DiamondFortmat(data.Target))
		item:FindChild("Text/Text").text = string.format("%s/%s",  data.CurTaskNum,data.AllTaskNum)
		
		item:FindChild("Goods/num").text = string.format("x%s", data.RewardInfos[1].PropNum) 
		self:SetImage(item:FindChild("Goods/icon"),self.prop[data.RewardInfos[1].PropID].Icon)
		item:FindChild("GoBtn"):SetActive(not data.IsFinish)
		item:FindChild("fulfill"):SetActive(data.IsFinish and data.IsReward or false)
		item:FindChild("GetBtn"):SetActive(data.IsFinish and not data.IsReward or false)
		if data.IsFinish and not data.IsReward then
			self.taskShowRedDot = true
		end
		self:AddClick(item:FindChild("GoBtn"), function( )
			local gameType = num == 8 and 1 or 0
			local rNum = math.random(1000)
			-- log("rNum:"..rNum)
			if index == 2 then
				--随机弹出Slots或Poker
				gameType = rNum > 500 and 2 or 3
			end
			CC.HallNotificationCenter.inst():post(CC.Notifications.RefreshGameList, gameType)
			self:CloseView()
		end)
		self:AddClick(item:FindChild("GetBtn"), function( )
			self.viewCtr:ReqAcquireReward(data.ID)
		end)

		-- self:AddClick(item:FindChild("alltask"), function() self:ShowPanel(num == 8 and self:FindChild("TaskPanel1") or self:FindChild("TaskPanel2")) end)
	end
end

--兑换商店信息
function HalloweenView:InitShopInfo(data)
	local list = data
	self:InitScrollItem(data, self.PrefabShopTab, self.shopItem, self.shopParent)
	self.shopShowRedDot = false
	for i = 1,#list do
		self:AddShopItemData(i,list[i])
	end
	self.togList[3]:FindChild("RedDot"):SetActive(self.shopShowRedDot)
	self:FindChild("bg/Info/Text").text = "x"..CC.Player.Inst():GetSelfInfoByKey("EPC_WizardHat")
end

function HalloweenView:AddShopItemData(index, data)
	local item = self.PrefabShopTab[index]
	if item then
		item:SetActive(true)
		item.transform:SetParent(self.shopParent, false)
		local propNum = CC.Player.Inst():GetSelfInfoByKey("EPC_WizardHat")
		item:FindChild("num").text = string.format("<color=#209F53FF>%s</color><color=#9C92D9>/%s</color>", propNum, data.Price)
		if propNum >= data.Price then
			self.shopShowRedDot = true
		end
		item:FindChild("GoBtn"):SetActive(propNum < data.Price)
		item:FindChild("GetBtn"):SetActive(propNum >= data.Price)
		local boxInd = data.ID % 10
		if boxInd > 0 and boxInd < 6 then
			--宝箱只有5个
			self:SetImage(item:FindChild("ShopGoods/icon"), string.format("wsj_bx0%s", boxInd),true);
			
		else
			--水灯节头像框
			self:SetImage(item:FindChild("ShopGoods/icon"), self.prop[CC.shared_enums_pb.EPC_2022_Halloween_Avatar_Frame].Icon)
			if CC.Player.Inst():GetSelfInfoByKey("EPC_2022_Halloween_Avatar_Frame") > 0 then
				item:SetActive(false)
				self.shopShowRedDot = false
				return
			end
		end
		self:AddClick(item:FindChild("GoBtn"), function( )
			CC.ViewManager.Open("FreeChipsCollectionView", {currentView = "HalloweenLoginGiftView"});
			self:CloseView()
		end)
		self:AddClick(item:FindChild("GetBtn"), function( )
			self.viewCtr:ReqHalloweenShopBuy(data.ID)
		end)
		self:AddClick(item:FindChild("ShopGoods"), function( )
			self.bubbleTip.transform:SetParent(item:FindChild("ShopGoods"))
			self.bubbleTip.transform.localPosition = Vector3(-50,  120, 0)
			self.bubbleTip:SetActive(true)
			self:FindChild("closeTip"):SetActive(true)
			self:SetBubbleAward(data.Rewards)
		end)
	end
end

function HalloweenView:SetBubbleAward(param)
	self:InitScrollItem(param, self.AwardProfab, self.awardItem, self.awardScr)
	for i=1, #param do
		self:AddAwardItem(i, param[i])
	end
end

function HalloweenView:AddAwardItem(index, param)
	local obj = self.AwardProfab[index]
	if obj then
		obj.transform:SetParent(self.awardScr, false)
		obj:SetActive(true)
		obj:FindChild("num").text = CC.uu.DiamondFortmat(param.PropNum)
		local node = obj.transform:FindChild("Sprite")
		local sprite = self.PropDataMgr.GetIcon(param.PropID)
		self:SetImage(node, sprite,true);
		node.sizeDelta = node.sizeDelta * 0.8
	end
end

function HalloweenView:UpdataMarquee()
	if #self.viewCtr.BroadCastList <= 0 then return end
	if not self.Marquee then
		local ReportEnd = function()
			self:UpdataMarquee()
		end
		self.Marquee = CC.uu.CreateHallView("Marquee",{parent = self:FindChild("BroadCast"), ReportEnd = ReportEnd})
	end
	for _, v in ipairs(self.viewCtr.BroadCastList) do
		local str = string.format(self.language.Marquee0, v.PlayerName, self.propLanguage[v.PropID])
		self.Marquee:Report(str)
	end
end

function HalloweenView:TaskDes(ID,data)
	local node = ID == CC.proto.client_task_pb.TotalFlowCatch and "TaskPanel1" or "TaskPanel2"
	local parent = self:FindChild(node.."/Frame/Scroll View/Viewport/Content")
	local prefab = parent:FindChild("Task")
	self.inittask = coroutine.start(function()
		for i,v in ipairs(data) do
			if CC.uu.IsNil(parent) or CC.uu.IsNil(prefab) then return end
			
			local item = CC.uu.newObject(prefab,parent)
			item:FindChild("Text").text = CC.uu.DiamondFortmat(v.Target)
			item:FindChild("Prop/Text").text = string.format("x%s",v.RewardInfos[1].PropNum)
			self:SetImage(item:FindChild("Prop/Icon"),self.prop[v.RewardInfos[1].PropID].Icon)
			item:FindChild("Image"):SetActive(i%2 ~= 0)
			item:SetActive(true)
			coroutine.step(1)
		end
	end)
	
end

function HalloweenView:ActionIn() end

function HalloweenView:ActionOut() end

--关闭界面
function HalloweenView:CloseView()
	self:Destroy()
end

function HalloweenView:OnDestroy()
	-- if self.musicName then
	-- 	CC.Sound.PlayHallBackMusic(self.musicName);
	-- else
	-- 	CC.Sound.StopBackMusic();
	-- end
	self:CancelAllDelayRun()
	if self.Marquee then
        self.Marquee:Destroy()
        self.Marquee = nil
    end
	if self.param and self.param.callBack then
		self.param.callBack(true)
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
	if self.inittask then
		coroutine.stop(self.inittask)
		self.inittask = nil
	end
end

return HalloweenView;