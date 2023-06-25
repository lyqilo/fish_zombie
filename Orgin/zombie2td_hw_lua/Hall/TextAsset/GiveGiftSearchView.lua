local CC = require("CC")

local GiveGiftSearchView = CC.uu.ClassView("GiveGiftSearchView")

function GiveGiftSearchView:ctor(param)
	self.param = param
	self.language = self:GetLanguage()
	self.GiftDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("GiftData")
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	self.switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")
	self.curTab = 1 --页签
	self.curSubTab = 1 --子页签
	self.infoAction = {} --资讯action
	self.sendRecoItem = {} --赠送推荐
	self.IconTab = {} --头像
	self.headIndex = 0 --头像下标
	self.infoData = {}	--咨询
end

function GiveGiftSearchView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
	self:InitUI()
end

function GiveGiftSearchView:InitUI()
	self.Layer_UI =self:FindChild("Layer_UI")
	self.guide = self.Layer_UI:FindChild("Guide")

-----------------------------InfoView----------------------------
	self.infoLoopScrollRect = self.Layer_UI:FindChild("Center/InfoView/News/VerticalScroll"):GetComponent("LoopScrollRect")
	self.infoVerticalLayoutGroup = self.infoLoopScrollRect.transform:FindChild("Content"):GetComponent("VerticalLayoutGroup")
	self.infoLoopScrollRect:AddChangeItemListener(function(tran,index)
		self:InfoItemData(tran,index)
	end)

	self.infoLoopScrollRect:ToPoolItemListenner(function(tran,index)
		self:ReturnToPool(tran,index)
	end)

------------------------------GiftView--------------------------
	self.SeachInputField = self.Layer_UI:FindChild("Center/GiftView/SeachInputField")
	self.Scroll_Init = self.Layer_UI:FindChild("Center/GiftView/Scroll_Init")
	self.Scroll_Result = self.Layer_UI:FindChild("Center/GiftView/Scroll_Result")

------------------------------GiftRecord----------------------------
	self.recordScroRect = self.Layer_UI:FindChild("Center/GiftRecord/Record/ScrollView"):GetComponent("ScrollRect")
	self.recordController = self.Layer_UI:FindChild("Center/GiftRecord/Record/ScrollerController"):GetComponent("ScrollerController")
	self.recordController:AddChangeItemListener(function(tran,dataIndex,cellIndex) 
		self:Record_ItemData(tran,dataIndex + 1)
	end)

	self.collectScroRect = self.Layer_UI:FindChild("Center/GiftRecord/Collect/ScrollView"):GetComponent("ScrollRect")
	self.collectController = self.Layer_UI:FindChild("Center/GiftRecord/Collect/ScrollerController"):GetComponent("ScrollerController")
	self.collectController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:Collect_ItemData(tran,dataIndex + 1)
	end)

	self.summaryScroRect = self.Layer_UI:FindChild("Center/GiftRecord/Summary/ScrollView"):GetComponent("ScrollRect")
	self.summaryController = self.Layer_UI:FindChild("Center/GiftRecord/Summary/ScrollerController"):GetComponent("ScrollerController")
	self.summaryController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:Summary_ItemData(tran,dataIndex + 1)
	end)

	self:AddUIEvent()
    self:AddClickEvent()
	self:InitTopNode()
	self:LanguageSwitch()
	self:ClientInfoTest()
	-- self:Effect()

	if self.switchDataMgr.GetSwitchStateByKey("BSGuide") then
		if self.param and self.param.guide then
			self:StartGuide()
		elseif self:GetSelfInfoByKey("EPC_Level") >= 3 then
			self:GiftGuide()
		end
	end
end

function GiveGiftSearchView:AddUIEvent()
	self.toggle = {self.Layer_UI:FindChild("Center/TopBG/InfoBtn"),self.Layer_UI:FindChild("Center/TopBG/GiftBtn"),self.Layer_UI:FindChild("Center/TopBG/RecordBtn")}
	self.subToggle = {self.Layer_UI:FindChild("Center/GiftRecord/LeftToggle/RecordText"),self.Layer_UI:FindChild("Center/GiftRecord/LeftToggle/CollectText"),self.Layer_UI:FindChild("Center/GiftRecord/LeftToggle/SummaryText")}
	self.toggle[1]:SetActive(self.switchDataMgr.GetSwitchStateByKey("BSGuide"))
	for i = 1,3 do
		local index = i
		UIEvent.AddToggleValueChange(self.toggle[index],function(value)
			CC.Sound.PlayHallEffect("click_tabchange")
			if value then
				self:OnToggleValueChange(index)
			else
				if index == 2 then self.SeachInputField:GetComponent("InputField").text = "" end
			end
		end)

		UIEvent.AddToggleValueChange(self.subToggle[index],function(value)
			if value then self:OnSbuToggleValueChange(index) end
		end)
		self.toggle[index]:GetComponent("Toggle").isOn = false
	end

	UIEvent.AddInputFieldOnValueChange(self.SeachInputField, function(str) self:OnInputFieldChange(str) end)
end

function GiveGiftSearchView:AddClickEvent()

	self:AddClick(self.Layer_UI:FindChild("VipButton"),"OnSelectGiftViewBtnClick")
	self:AddClick(self.Layer_UI:FindChild("TopBG/Back/BtnBack"),"OnBackBtnClick")
	self:AddClick(self.Layer_UI:FindChild("Right/BtnRank"),"OpendRankView")
	self:AddClick(self.Layer_UI:FindChild("Center/GiftView/BtnSearch"),"SearchPersonData")
	self:AddClick(self.Layer_UI:FindChild("VipThreeBtn/Btn/zsk"), function() CC.ViewManager.Open("VipThreeCardView") end)
	self:AddClick(self.Layer_UI:FindChild("Left/BtnChat"),function() CC.ViewManager.ShowChatPanel() end)
	self:AddClick(self.Layer_UI:FindChild("Center/InfoView/EmptyInfo/bg"), function()
		if self:GetSelfInfoByKey("EPC_Level") >= 20 then
			self.viewCtr:OnChangeSelf()
		end
	end)

	self.Layer_UI:FindChild("VipButton"):SetActive(CC.SelectGiftManager.CheckNoviceGiftCanBuy())
	self.Layer_UI:FindChild("Right"):SetActive(self.switchDataMgr.GetSwitchStateByKey("FreeSwitch"))
	self.Layer_UI:FindChild("Left/BtnChat"):SetActive(self.switchDataMgr.GetSwitchStateByKey("ChatPanel"))
end

function GiveGiftSearchView:InitTopNode()
	self:SetHeadIcon({parent = self.Layer_UI:FindChild("TopBG/HeadNode"),playerId = self:GetSelfInfoByKey("Id"),portrait = 0,showFrameEffect = true})
	self.chipCounter = CC.HeadManager.CreateChipCounter({parent = self.Layer_UI:FindChild("TopBG/NodeMgr/ChipNode")})
	self.VIPCounter = CC.HeadManager.CreateVIPCounter({parent = self.Layer_UI:FindChild("TopBG/NodeMgr/VipNode"), tipsParent = self.Layer_UI:FindChild("TopBG/VIPTipsNode")})
end

function GiveGiftSearchView:Effect()
	--获取裁剪区域左下角和右上角的世界坐标
	local wordPos = self.Scroll_Init:FindChild("Viewport"):GetComponent("RectTransform"):GetWorldCorners()
	local minX = wordPos[0].x;
	local minY = wordPos[0].y;
	local maxX = wordPos[2].x;
	local maxY = wordPos[2].y;

	--把坐标传入shader(maskParticle.shader，maskShine.shader)
	local nodePath = {"Layer_UI/GiftItem/Effect"}
	for _,path in ipairs(nodePath) do
		local particleComps = self:FindChild(path):GetComponentsInChildren(typeof(UnityEngine.Renderer))
		if particleComps then
			for i,v in ipairs(particleComps:ToTable()) do
				v.material:SetFloat("_MinX",minX);
				v.material:SetFloat("_MinY",minY);
				v.material:SetFloat("_MaxX",maxX);
				v.material:SetFloat("_MaxY",maxY);
			end
		end
	end
end

function GiveGiftSearchView:GetSelfInfoByKey(key)
	return CC.Player.Inst():GetSelfInfoByKey(key)
end

--语言切换
function GiveGiftSearchView:LanguageSwitch()

-----------------------------InfoView-----------------------------
	self.toggle[1]:FindChild("Text").text = self.language.Info
	self.toggle[1]:FindChild("onSelect/Text").text = self.language.Info
	self.Layer_UI:FindChild("Center/InfoView/EmptyInfo/Text").text = self.language.emptyInfo
	self.Layer_UI:FindChild("Center/InfoView/EmptyInfo/Vip").text = self.language.needVip
	self.Layer_UI:FindChild("Center/InfoView/News/Vip").text = self.language.needVip
	self.Layer_UI:FindChild("Center/InfoView/News/Name").text = self.language.Name
	self.Layer_UI:FindChild("Center/InfoView/News/Id").text = self.language.ID
	self.Layer_UI:FindChild("Center/InfoView/News/Tel").text = self.language.Tel
	self.Layer_UI:FindChild("Center/InfoView/News/Add").text = self.language.Add
-----------------------------GiftView--------------------------
	self.toggle[2]:FindChild("Text").text = self.language.Gift
	self.toggle[2]:FindChild("onSelect/Text").text = self.language.Gift
	self.SeachInputField:FindChild("Placeholder").text = self.language.InputID
	self.Layer_UI:FindChild("Center/GiftView/BtnSearch/Text").text = self.language.Search
	self.Scroll_Init:FindChild("TipsBG/TipsText").text = self.language.RecommendPlayer
-----------------------------GiftRecord--------------------------
	self.toggle[3]:FindChild("Text").text = self.language.GiftRecord
	self.toggle[3]:FindChild("onSelect/Text").text = self.language.GiftRecord
	self.Layer_UI:FindChild("Center/GiftRecord/LeftToggle/RecordText").text = self.language.GiftRecord_Lab
	self.Layer_UI:FindChild("Center/GiftRecord/LeftToggle/RecordText/onSelect/Text").text = self.language.GiftRecord_Lab
	self.Layer_UI:FindChild("Center/GiftRecord/LeftToggle/CollectText").text = self.language.Collect
	self.Layer_UI:FindChild("Center/GiftRecord/LeftToggle/CollectText/onSelect/Text").text = self.language.Collect
	self.Layer_UI:FindChild("Center/GiftRecord/LeftToggle/SummaryText").text = self.language.Summary
	self.Layer_UI:FindChild("Center/GiftRecord/LeftToggle/SummaryText/onSelect/Text").text = self.language.Summary
	self.Layer_UI:FindChild("Center/GiftRecord/Record/TopText/NameText").text = self.language.Name --Record
	self.Layer_UI:FindChild("Center/GiftRecord/Record/TopText/ID").text = self.language.ID
	self.Layer_UI:FindChild("Center/GiftRecord/Record/TopText/Level").text = self.language.Level
	self.Layer_UI:FindChild("Center/GiftRecord/Record/TopText/Number").text = self.language.ChipsNumber
	self.Layer_UI:FindChild("Center/GiftRecord/Record/TopText/Fee").text = self.language.SendCost
	self.Layer_UI:FindChild("Center/GiftRecord/Record/TopText/TimeText").text = self.language.Time
	self.Layer_UI:FindChild("Center/GiftRecord/Collect/TopText/NameText").text = self.language.Name --Collect
	self.Layer_UI:FindChild("Center/GiftRecord/Collect/TopText/ID").text = self.language.ID
	self.Layer_UI:FindChild("Center/GiftRecord/Collect/TopText/Level").text = self.language.Level
	self.Layer_UI:FindChild("Center/GiftRecord/Collect/TopText/Number").text = self.language.ChipsNumber
	self.Layer_UI:FindChild("Center/GiftRecord/Collect/TopText/TimeText").text = self.language.Time
	self.Layer_UI:FindChild("Center/GiftRecord/Summary/TopText/TimeText").text = self.language.Time --Summary
	self.Layer_UI:FindChild("Center/GiftRecord/Summary/TopText/TotalcollectionText").text = self.language.TotalcollectionText
	self.Layer_UI:FindChild("Center/GiftRecord/Summary/TopText/TotalGiftDelivery").text = self.language.TotalGiftDelivery
----------------------------引导---------------------------
	self.guide:FindChild("BG/Name").text = self.language.Name
	self.guide:FindChild("BG/Id").text = self.language.ID
	self.guide:FindChild("BG/Tel").text = self.language.Tel
	self.guide:FindChild("BG/Add").text = self.language.Add
	self.guide:FindChild("BG/di/Info/Nick").text = self.language.NameEx
	self.guide:FindChild("BG/di/Info/Id").text = self.language.IDEx
	self.guide:FindChild("BG/di/Info/Tel").text = self.language.TelEX
	self.guide:FindChild("BG/di/Info/Add").text = self.language.AddEx
	self.guide:FindChild("Grid/InfoBtn/Text").text = self.language.Info
	self.guide:FindChild("Grid/GiftBtn/Text").text = self.language.Gift
	self.guide:FindChild("Grid/RecordBtn/Text").text = self.language.GiftRecord
	self.guide:FindChild("Vip").text = self.language.needVip
	for i=1,3 do
		self.guide:FindChild("step"..i.."/Content/Text").text = self.language["guide_step"..i.."_Content"]
		self.guide:FindChild("step"..i.."/Text1").text = self.language["guide_step"..i.."_1"]
		self.guide:FindChild("step"..i.."/Text2").text = self.language["guide_step"..i.."_2"]
		self.guide:FindChild("step"..i.."/Btn/Text").text = self.language["guide_step"..i.."_Btn"]
	end
end

function GiveGiftSearchView:ClientInfoTest()

	if self.switchDataMgr.GetSwitchStateByKey("BSGuide") then
		--是否显示资讯
		CC.LocalGameData.SetLocalDataToKey("GiveNews", self:GetSelfInfoByKey("Id"))
		self.Layer_UI:FindChild("Center/TopBG").sizeDelta = Vector2(1000, 82)
		self.toggle[1]:GetComponent("Toggle").isOn = true
		if not self.GiftDataMgr:GetLoadNews() then
			self.viewCtr:ReqLoadInformation()
		end
	else
		self.Layer_UI:FindChild("Center/TopBG").sizeDelta = Vector2(680, 82)
		self.toggle[2]:GetComponent("Toggle").isOn = true
	end
end

--直升卡引导
function GiveGiftSearchView:StartGuide()

	self:ShowGuide(true)
	self:DelayRun(0.1, function()
		CC.Sound.StopEffect()
		CC.Sound.PlayHallEffect("giveGiftStep1.ogg")
	end)
	self.guide:FindChild("step1"):SetActive(true)
	self:AddClick(self.guide:FindChild("step1/Btn"), function()
		CC.Sound.StopEffect()
		CC.Sound.PlayHallEffect("giveGiftStep2.ogg")
		self.guide:FindChild("step1"):SetActive(false)
		self.guide:FindChild("step2"):SetActive(true)
	end)
	self:AddClick(self.guide:FindChild("step2/Btn"), function()
		CC.Sound.StopEffect()
		self.guide:FindChild("step2"):SetActive(false)
		if self:GetSelfInfoByKey("EPC_Level") >= 3 then
			self:GiftGuide()
		else
			self:ShowGuide(false)
			local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("VipThreeCardView").switchOn
			if switchOn and self.viewCtr.ThreeCardState then
				CC.ViewManager.Open("VipThreeCardView")
			end
		end
	end)
end

function GiveGiftSearchView:ShowGuide(state)
	self.Layer_UI:FindChild("Center"):SetActive(not state)
	self.guide:SetActive(state)
end

--礼物赠送引导
function GiveGiftSearchView:GiftGuide()
	if self.gameDataMgr.GetGuide().TotalFlag and not self.gameDataMgr.GetSingleFlag(29) then
		self:ShowGuide(true)
		self.guide:FindChild("step3"):SetActive(true)
		self.guide:FindChild("step3/Text1"):SetActive(false)
		CC.Sound.StopEffect()
		--赠送引导
		CC.Request("ReqSaveNewPlayerFlag",{Flag = 29, IsSingle = true})
		self.gameDataMgr.SetGuide(29, true)
		self:AddClick(self.guide:FindChild("step3/Btn"), function()
			self.guide:FindChild("step3"):SetActive(false)
			self:ShowGuide(false)
		end)
	else
		self:ShowGuide(false)
	end
end

function GiveGiftSearchView:OnSelectGiftViewBtnClick()
	if CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
		CC.ViewManager.Open("SelectGiftCollectionView",{SelectGiftTab = {"NoviceGiftView"}})
	else
		CC.ViewManager.Open("StoreView")
	end
end

function GiveGiftSearchView:OnBackBtnClick()
	if self:GetSelfInfoByKey("EPC_Level") < 3 and not CC.LocalGameData.GetLocalStateToKey("VipThreeCard") then
		CC.LocalGameData.SetLocalStateToKey("VipThreeCard", true)
		CC.ViewManager.Open("VipThreeCardView")
	else
		self:Destroy()
	end
end

--打开排行榜界面
function GiveGiftSearchView:OpendRankView()
	self.Layer_UI:FindChild("Right"):SetActive(false)
	CC.ViewManager.Open("GiftRankView",{callback = function() self.Layer_UI:FindChild("Right"):SetActive(true) end})
end

function GiveGiftSearchView:OnToggleValueChange(index)
	self.curTab = index
	if index == 1 then  --点击资讯
		self:InitInfo()
	elseif index == 2 then  --点击赠送
		local tab = self.GiftDataMgr:GetReCommandGuy()
		if table.isEmpty(tab) then
			self.viewCtr:ReqLoadRecommandedFriends()
		else
			self:InitPerson(tab) 
		end
	elseif index == 3 then  --点击赠送记录
		self.subToggle[self.curSubTab]:GetComponent("Toggle").isOn = false
		self.subToggle[self.curSubTab]:GetComponent("Toggle").isOn = true
	end

	for i,v in ipairs(self.toggle) do
		v:FindChild("Red"):SetActive(not (i == index))
	end
	self.Layer_UI:FindChild("Left/BtnChat"):SetActive(index ~= 3 and self.switchDataMgr.GetSwitchStateByKey("ChatPanel"))
end

function GiveGiftSearchView:OnSbuToggleValueChange(index)
	self.curSubTab = index
	if index == 1 then  --赠送记录
		self.viewCtr:ReqTradeSended()
		-- if not self.viewCtr.recordInit then
		-- 	self.viewCtr:ReqTradeSended()
		-- else
		-- 	self.recordController:RefreshScroller(self.GiftDataMgr:GiftRecordLen(),1 - self.recordScroRect.verticalNormalizedPosition)
		-- end
	elseif index == 2 then
		self.viewCtr:ReqTradeReceived() --收礼记录
	elseif index == 3 then
		self.viewCtr:ReqTradeSummaries() --月汇总
	end
end

-------------------InfoView-----------------------
--初始化资讯列表
function GiveGiftSearchView:InitInfo()
	self.infoData = self.GiftDataMgr:GetReInformation()
	local curVip = self:GetSelfInfoByKey("EPC_Level")
	self.Layer_UI:FindChild("Center/InfoView/EmptyInfo"):SetActive(not (#self.infoData > 0))
	self.Layer_UI:FindChild("Center/InfoView/News"):SetActive(#self.infoData > 0)
	if #self.infoData <= 0 then
		self.Layer_UI:FindChild("Center/InfoView/EmptyInfo/Vip").text = curVip >= 20 and self.language.ownCanEdit or self.language.needVip
		return
	end
	self:RankListCount(self.infoLoopScrollRect, #self.infoData)
	self.Layer_UI:FindChild("Center/InfoView/News"):SetActive(#self.infoData > 0)
end

--设置循环列表长度
function GiveGiftSearchView:RankListCount(loopscrollrect,len)
	local count = len
	if count  == 0 then
		loopscrollrect:ClearCells()
	else
		loopscrollrect.totalCount = len
	end
end

function GiveGiftSearchView:UpdataSelfInfo()
	local tan = self.infoVerticalLayoutGroup.transform:FindChild("1")
	if tan then
		self:InfoItemData(tan,0)
	end
end

function GiveGiftSearchView:ReturnToPool(tran,index)
	-- local headNode = tran.transform:FindChild("Info/ItemHead")
	-- self:DeleteHeadIconByKey(headNode)
	-- Util.ClearChild(headNode,false)
	local id = index + 1;
	self:StopAction(self.infoAction[id])
	tran:FindChild("Info/Close"):SetActive(true)
	tran:FindChild("Info/Open"):SetActive(false)
	tran:FindChild("Empty"):SetActive(false)
	tran:FindChild("Info"):SetActive(false)
	tran:FindChild("Content"):SetActive(false)
end

function GiveGiftSearchView:InfoItemData(tran, index)
	local id = index + 1;
	tran.name = tostring(id)
	local InfoData = self.infoData[id]
	if not InfoData then return end
	if InfoData.PlayerID == self:GetSelfInfoByKey("Id") and not self.GiftDataMgr:CheckData(InfoData) then
		--自己并且没有数据
		tran:FindChild("Empty"):SetActive(true)
		tran:FindChild("Info"):SetActive(false)
		tran:FindChild("Content"):SetActive(false)
		tran:FindChild("Empty/Text").text = self.language.EditSelf
		self:AddClick(tran:FindChild("Empty/EditBtn"), function() self.viewCtr:OnChangeSelf() end)
	else
		tran:FindChild("Empty"):SetActive(false)
		tran:FindChild("Info"):SetActive(true)
	end

	local headNode = tran:FindChild("Info/ItemHead")
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.IconTab[tonumber(headtran.transform.name)] ~= nil then
			self.IconTab[tonumber(headtran.transform.name)]:RefreshOtherUI({playerId = InfoData.PlayerID,portrait = InfoData.Portrait,vipLevel = InfoData.Level,clickFunc = "unClick"})
		end
	else
		self:SetHeadIcon({parent = headNode,playerId = InfoData.PlayerID,portrait = InfoData.Portrait,vipLevel = InfoData.Level,clickFunc = "unClick"})
	end
	tran:FindChild("Info/Nick").text = InfoData.Name
	tran:FindChild("Info/Id").text = InfoData.PlayerID
	tran:FindChild("Info/Tel").text = InfoData.Telephone
	tran:FindChild("Info/Add").text = InfoData.Address
	tran:FindChild("Content/Text").text = InfoData.Content
	tran:FindChild("Info/Bg"):SetActive(id % 2 == 0)

	if self.infoAction[id] then self:StopAction(self.infoAction[id]) end
	tran:FindChild("Info/Close").color = Color(1,0.72,0,1)
	self.infoAction[id] = self:RunAction(tran:FindChild("Info/Close"), {"fadeTo", 100, 1, loop = {-1, CC.Action.LTYoyo}})

	--展开详细资讯
	self:AddClick(tran:FindChild("Info"),function() 
		local closeAct = tran:FindChild("Info/Close").activeSelf
		tran:FindChild("Info/Close"):SetActive(not closeAct)
		tran:FindChild("Info/Open"):SetActive(closeAct)
		tran:FindChild("Content"):SetActive(closeAct)
		-- LayoutRebuilder.ForceRebuildLayoutImmediate(Parent)
	end)
	--facebook
	tran:FindChild("Info/BtnFB"):SetActive(InfoData.FBAddress and InfoData.FBAddress ~= "")
	self:AddClick(tran:FindChild("Info/BtnFB"),function() Client.OpenURL(InfoData.FBAddress) end)
    --line
	tran:FindChild("Info/BtnLine"):SetActive(InfoData.LineAddress and InfoData.LineAddress ~= "")
	self:AddClick(tran:FindChild("Info/BtnLine"),function() Client.OpenURL(InfoData.LineAddress) end)

	if InfoData.PlayerID ~= self:GetSelfInfoByKey("Id") then
		tran:FindChild("Info/BtnGift"):SetActive(true)
		tran:FindChild("Info/BtnEdit"):SetActive(false)
		self:AddClick(tran:FindChild("Info/BtnGift"),function()
			if self:HasBindPhone() then
				CC.ViewManager.Open("SendChipsView",{playerId = InfoData.PlayerID,playerName = InfoData.Name,portrait = InfoData.Portrait,vipLevel = InfoData.Level})
			else
				CC.ViewManager.Open("BeforeSendTipsView",{HasBindPhone = CC.HallUtil.CheckTelBinded()})
			end
		end)
	else
		tran:FindChild("Info/BtnGift"):SetActive(false)
		tran:FindChild("Info/BtnEdit"):SetActive(true)
		self:AddClick(tran:FindChild("Info/BtnEdit"), function() self.viewCtr:OnChangeSelf() end)
	end
end

-------------------GiftView-----------------------
function GiveGiftSearchView:InitPerson(data) --初始化推荐列表
	if not data or #data <= 0 then return end

	self.co_InitUI = coroutine.start(function()
		for i = 1,#data do
			self:ItemData(i,data[i].Player,self.Scroll_Init:FindChild("Viewport/Content"),data[i].Player.PlayerId,data[i].ChouMa,data[i].IsRecommand)
			coroutine.step(1)
		end
	end)
end

function GiveGiftSearchView:ItemData(index,GiftData,Content,PlayerId,ChouMa,IsRecommand)
	local item = self.sendRecoItem[index]
	if not item then
		item = CC.uu.newObject(self:FindChild("Layer_UI/GiftItem"))
		item.transform.name = tostring(index)
		self.sendRecoItem[index] = item.transform
	end
	item.transform:SetParent(Content, false)
	item:SetActive(true)
	item.transform:FindChild("Effect"):SetActive(not self.switchDataMgr.GetSwitchStateByKey("FreeSwitch") and IsRecommand and IsRecommand == 1)

	local headNode = item.transform:FindChild("ItemHeadMask/Node")
	self:DeleteHeadIconByKey(headNode)
	Util.ClearChild(headNode,false)
	self:SetHeadIcon({parent = headNode,playerId = PlayerId,portrait = GiftData.Portrait,vipLevel = GiftData.Level})

	item.transform:FindChild("ItemName").text = GiftData.Nick
	item.transform:FindChild("ItemMoneyImg/ItemMoneyText").text = CC.uu.ChipFormat(ChouMa)
	self:AddClick(item.transform:FindChild("BtnGift"),function()
		if self:HasBindPhone() then
			CC.ViewManager.Open("SendChipsView",{playerId = PlayerId,playerName = GiftData.Nick,portrait = GiftData.Portrait,vipLevel = GiftData.Level})
		else
			CC.ViewManager.Open("BeforeSendTipsView",{HasBindPhone = CC.HallUtil.CheckTelBinded()})
		end
	end)
end

function GiveGiftSearchView:HasBindPhone()
	if not self.switchDataMgr.GetSwitchStateByKey("OTPVerify") then
		return true
	else
		return CC.HallUtil.CheckTelBinded()
	end
end

function GiveGiftSearchView:OnInputFieldChange(str)
	if str == "" and self.Scroll_Result.activeSelf then
		self.Scroll_Init:SetActive(true)
		self.Scroll_Result:SetActive(false)
		self:InitPerson(self.GiftDataMgr:GetReCommandGuy())
	end
end

--搜索玩家
function GiveGiftSearchView:SearchPersonData()
	local str = self.SeachInputField:GetComponent("InputField").text
	if tostring(self:GetSelfInfoByKey("Id")) == str then
		CC.ViewManager.ShowTip(self.language.connectfriendReturn1)
	elseif str == "" then
		CC.ViewManager.ShowTip(self.language.InputID)
	else
		self.viewCtr:RequestSearchView(str)
	end
end

-----------------------------GiftRecord----------------------------
--赠送
function GiveGiftSearchView:Record_ItemData(tran,index)
	local data = self.GiftDataMgr:GetAllGiftRecordData()[index]
	if not data then return end

	tran.name = tostring(index)
	tran:FindChild("Info/Name").text = data.AnotherPlayer.Nick
	tran:FindChild("Info/ID").text = data.To
	tran:FindChild("Info/Total_Collection").text = CC.uu.numberToStrWithComma(data.Amount)
	tran:FindChild("Info/Time").text = data.Time
	tran:FindChild("Info/Level").text = data.VipLevelTo or "--"
	tran:FindChild("BtnAgain/Agiain").text = self.language.GiveAgain

	--显示高v赠送手续费
	if self:GetSelfInfoByKey("EPC_Level") >= 25 then
		local feeObj = self.Layer_UI:FindChild("Center/GiftRecord/Record/TopText/Fee")
		if not feeObj.activeSelf then feeObj:SetActive(true) end
		tran:FindChild("Info/Fee"):SetActive(true)
        tran:FindChild("Info/Fee").text = CC.uu.numberToStrWithComma(data.AgentRevenue)
	end
	tran:FindChild("xian"):SetActive(index == self.GiftDataMgr:GiftRecordLen()) --每个item下面的线条
	tran:SetActive(true)
	
	self:AddClick(tran:FindChild("BtnAgain"),function()
		if self:HasBindPhone() then
			CC.ViewManager.Open("SendChipsView",{playerId = data.To,playerName =  data.AnotherPlayer.Nick,portrait = data.AnotherPlayer.Portrait,vipLevel = data.AnotherPlayer.Level})
		else
			CC.ViewManager.Open("BeforeSendTipsView",{HasBindPhone = CC.HallUtil.CheckTelBinded()})
		end
	end)

	--self:DoTweenTranMove(self.Record_VerticalLayoutGroup,tran,self.GiftDataMgr:GiftRecordLen(),index)
end

--收礼
function GiveGiftSearchView:Collect_ItemData(tran,index)
	local data = self.GiftDataMgr:GetAllGiftCollectData()[index]
	if not data then return end

	tran.name = tostring(index)
	tran:FindChild("Name").text = data.AnotherPlayer.Nick
	tran:FindChild("ID").text = data.From
	tran:FindChild("Total_Collection").text = CC.uu.numberToStrWithComma(data.Amount)
	tran:FindChild("Time").text = data.Time
	tran:FindChild("Level").text = data:HasField("VipLevel") and data.VipLevel or "--"
	tran:FindChild("xian"):SetActive(index == self.GiftDataMgr:CollectLen()) --每个item下面的线条
	tran:SetActive(true)

	local BtnGet = tran:FindChild("BtnGet")
	local BtnUnGet = tran:FindChild("BtnUnGet")
	BtnGet:FindChild("Agiain").text = self.language.Get
	BtnUnGet:FindChild("Agiain").text = self.language.UnGet
	BtnGet:SetActive(not data.Took)
	BtnUnGet:SetActive(data.Took)

	--2018/10/25之后的赠送记录显示领取按钮
	if  data.MailId == "" or data.MailId == nil then
		BtnGet:SetActive(false)
		BtnUnGet:SetActive(false)
	end
	
	self:AddClick(BtnGet,function()
		self.viewCtr:OnGetAttachments(data.Amount,data.MailId,function()
			if CC.uu.IsNil(self.transform) then return end
			
			data.Took = true
			BtnGet:SetActive(false)
		    BtnUnGet:SetActive(true)
		end)
	end)
	
	--self:DoTweenTranMove(self.Collect_VerticalLayoutGroup,tran,self.GiftDataMgr:CollectLen(),index)
end

--月汇总
function GiveGiftSearchView:Summary_ItemData(tran,index)
	local data = self.GiftDataMgr:GetAllSummaryData()[index]
	if not data then return end
	
	tran.name = tostring(index)
	tran:FindChild("Total_Collection").text = CC.uu.numberToStrWithComma(data.Received)
	tran:FindChild("Time").text = data.Month.."/"..data.Year
	tran:FindChild("Total_Gift_Delivery").text = CC.uu.numberToStrWithComma(data.Sended)
	tran:FindChild("xian"):SetActive(index == self.GiftDataMgr:SummaryLen()) --每个item下面的线条
	tran:SetActive(true)

	--self:DoTweenTranMove(self.Summary_VerticalLayoutGroup,tran,self.GiftDataMgr:SummaryLen(),index)
end

--列表的item动画
function GiveGiftSearchView:DoTweenTranMove(VerticalLayoutGroup,tran,len,index)
	if not VerticalLayoutGroup.enabled then
		tran.transform.localPosition = Vector3(1105,-50 + ((index-1) * -100),0)
		self:RunAction(tran, {"localMoveTo", 0, -50 + ((index-1) * -100),0.15*index, function()
			local count = len <= 4 and len or 5
			if index == count then VerticalLayoutGroup.enabled = true end
		end})
	end
end

--排行榜的前三名头像
function GiveGiftSearchView:HeadItem()
	if not self.switchDataMgr.GetSwitchStateByKey("FreeSwitch") then return end

	local len = self.GiftDataMgr:GetTradeRankLen() < 3 and self.GiftDataMgr:GetTradeRankLen() or 3
	for i = 1,len do
		local headNode = self.Layer_UI:FindChild("Right/ItemHeadMask"..i.."/Node")
		local data = self.GiftDataMgr:GetTradeRankItemData(i)
		self:SetHeadIcon({parent = headNode,playerId = data.Player.Id,portrait = data.Player.Portrait,vipLevel = data.Level})
	end
end

function GiveGiftSearchView:SetVipThreeBtnShow(enabled)
	if self:GetSelfInfoByKey("EPC_Level") >= 3 or CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
		enabled = false
	end
	self.Layer_UI:FindChild("VipThreeBtn"):SetActive(enabled)
end

--有私聊的时候，聊天按钮抖动
function GiveGiftSearchView:RefreshChat(state)
	self.Layer_UI:FindChild("Left/BtnChat/xinxi"):SetActive(state)
end

function GiveGiftSearchView:OnNoviceReward()
	self.Layer_UI:FindChild("VipButton"):SetActive(false)
end

--设置头像
function  GiveGiftSearchView:SetHeadIcon(param)
	self.headIndex = self.headIndex + 1
	local headIcon = CC.HeadManager.CreateHeadIcon(param)
	headIcon.transform.name = tostring(self.headIndex)
	self.IconTab[self.headIndex] = headIcon
end

--删除头像对象
function GiveGiftSearchView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.IconTab[tonumber(headtran.transform.name)] ~= nil then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end
end

function GiveGiftSearchView:OnDestroy()
	for _,v in pairs(self.IconTab) do
		if v then
			v:Destroy()
			v = nil
		end
	end

	if self.chipCounter then
		self.chipCounter:Destroy()
		self.chipCounter = nil
	end

	if self.co_InitUI then
		coroutine.stop(self.co_InitUI)
		self.co_InitUI = nil
	end

	if self.co_InitInfo then
		coroutine.stop(self.co_InitInfo)
		self.co_InitInfo = nil
	end

	if self.VIPCounter then
		self.VIPCounter:Destroy()
		self.VIPCounter = nil
	end

	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end

	self.infoLoopScrollRect:DelectPool()
	self.infoLoopScrollRect = nil
	self.infoVerticalLayoutGroup = nil

	self.Record_VerticalLayoutGroup = nil
	self.Collect_VerticalLayoutGroup = nil
	self.Summary_VerticalLayoutGroup = nil
	if self.param and self.param.callback then
		self.param.callback()
	end
end

function GiveGiftSearchView:ActionIn()
end

return GiveGiftSearchView