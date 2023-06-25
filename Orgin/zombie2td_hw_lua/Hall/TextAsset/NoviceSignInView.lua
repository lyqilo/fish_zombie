
local CC = require("CC")
local NoviceSignInView = CC.uu.ClassView("NoviceSignInView")

function NoviceSignInView:ctor(param)

	self:InitVar(param);
end

function NoviceSignInView:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();

	self:InitContent();
	self:InitTextByLanguage();
end

function NoviceSignInView:InitVar(param)

	self.param = param;

	self.rewardItemList = {};

	self.exchangeItemList = {};

	self.commonExItem = nil;

	self.language = self:GetLanguage();

	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop");
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	self.propDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")

	self.marqueeQueue = nil
end

function NoviceSignInView:InitContent()
	--奖励描述窗口
	self.rewardItemTip = nil;
	--福袋描述窗口
	self.luckItemTip = self:FindChild("PackbackItemDes")
	--描述窗口奖励节点
	self.luckItemNode = self.luckItemTip:FindChild("Content/AwardNode")
	--福袋奖励Item
	self.awardItem = self:FindChild("Item")
	--奖励选中效果
	self.rewardSelected = self:FindChild("Frame/LeftPanel/RewardSelected");
	--补签提示
	self.reSignTip = self:FindChild("Frame/LeftPanel/ReSignTip");
	--右侧大奖
	self.sevenItem = self:FindChild("Frame/RightPanel/LayoutGroup")
	--7日可领取
	self.availableItem = self:FindChild("Frame/RightPanel/LayoutGroup/Decorate/Available")
	--7日不可领取
	self.unavailableItem = self:FindChild("Frame/RightPanel/LayoutGroup/Decorate/UnAvailable")
	--物品描述父节点
	self.desNode = self:FindChild("Frame/DesNode")

	--大奖Text
	self.awardText = self:FindChild("Frame/Show/Text")
	--大奖展示宽度
	self.awardWidth = self:FindChild("Frame/Show"):GetComponent('RectTransform').rect.width/2
	--跑马灯状态
	self.isTipMoving = false
	self:CheckGuide()

end

function NoviceSignInView:InitTextByLanguage()
	self:FindChild("Frame/RightPanel/LayoutGroup/Des/Text").text = self.language.bigReward
end

function NoviceSignInView:CheckGuide()
	if not self.gameDataMgr.GetSingleFlag(11) then
		self:DelayRun(0.2, function ( )
			CC.ViewManager.Open("GuideView", {singleFlag = 11})
			local btn = self:FindChild("Frame/LeftPanel/LayoutGroup/RewardItem1")
			local v2 = UnityEngine.RectTransformUtility.WorldToScreenPoint(self:GlobalCamera(),btn.position)
			local silder = 100
			local param = {vect1 = v2, sizeX1 = silder, sizeY1 = silder, maskMode = "_MASKMODE_RECTANGLE"}
			param.flag = 11
			CC.HallNotificationCenter.inst():post(CC.Notifications.OnHighlightInfo, param)
		end)
	elseif not self.gameDataMgr.GetSingleFlag(12) then
		self:DelayRun(0.2, function ( )
			CC.ViewManager.Open("GuideView", {singleFlag = 12})
		end)
	end
end

function NoviceSignInView:RefreshUI(param)

	if param.rewardItemData then
		self:CreateRewardItems(param.rewardItemData);
	end

	if param.refreshRewardItem then
		self:RefreshRewardItem(param.refreshRewardItem);
	end

	if param.showSelected ~= nil then
		self:SetCurSelectItem(param);
	end

	if param.time then
		self:FindChild("Frame/LeftPanel/ActTime").text = self.language.actTime..param.time
	end
end

function NoviceSignInView:SetCurSelectItem(param)
	if not param.showSelected then
		self.rewardSelected:SetActive(false);
		self.reSignTip:SetActive(false);
		return;
	end
	local item = self.rewardItemList[param.curSelect];
	if param.curSelect < 7 then
		self.rewardSelected:SetParent(item.obj:FindChild("SelectNode"), false);
		self.rewardSelected:SetActive(true);

		if item.data.reSignState then
			self.reSignTip:SetParent(item.obj, false);
			self.reSignTip:SetActive(true);
			self:SetText(self.reSignTip:FindChild("Text"), self.language.resign..param.resign.cost);
		else
			self.reSignTip:SetActive(false);
		end
	else
		self.rewardSelected:SetActive(false);
		if item.data.reSignState then
			self.reSignTip:SetParent(self.sevenItem, false);
			self.reSignTip:SetActive(true);
			self:SetText(self.reSignTip:FindChild("Text"), self.language.resign..param.resign.cost);
			self.unavailableItem:SetActive(false)
			self.availableItem:SetActive(true)
		else
			self.reSignTip:SetActive(false);
			self.unavailableItem:SetActive(false)
			self.availableItem:SetActive(true)
		end
	end
end

function NoviceSignInView:CreateRewardItems(param)
	for _,v in ipairs(param) do
		local item = self:CreateRewardItem(v);
		table.insert(self.rewardItemList, item);
	end
end

function NoviceSignInView:CreateRewardItem(param)
	local item = {};

	item.data = param;

	if param.id == 7 then
		local count = 100000
		for i,v in ipairs(param.awards) do
			if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
				count = v.High
			end
		end
		self:FindChild("Frame/RightPanel/LayoutGroup/DateFrame/Text").text = "DAY 7"
		self:FindChild("Frame/RightPanel/LayoutGroup/Decorate/Bubble2/Tips/Text").text = self.language.theHigh..count
		self:AddClick(self:FindChild("Frame/RightPanel/Btn"),function ()
			if param.alreadyGet then return end;
			self:OnClickBtnSign(param);
		end)
		return item
	end

	local obj = self:FindChild("Frame/LeftPanel/LayoutGroup/RewardItem"..param.id);
	item.obj = obj;

	local propIcon = obj:FindChild("PropIcon");
	self:SetImage(propIcon, param.propIcon);
	self:SetText(obj:FindChild("DateFrame/Text"),"DAY "..param.id);
	self:SetText(obj:FindChild("PropCount"), "x"..param.propCount);

	if type(param.propId) == "string" then
		self:SetText(obj:FindChild("PropDes"), self.language["fd_"..param.propId]);
	else
		self:SetText(obj:FindChild("PropDes"), self.propLanguage[param.propId]);
	end

	local mask = obj:FindChild("Mask");
	mask:SetActive(param.alreadyGet);

	local itemDesNode = obj:FindChild("ItemDesNode");
	local itemPropNode = obj:FindChild("ItemPropNode");
	local btnData = {};
	btnData.funcLongClick = function()
		local data = {};
		data.propId = param.propId;
		if type(param.propId) == "string" then
			data.node = itemDesNode;
			data.awards = param.awards
			self:ShowLuckItemTip(true,data)
		else
			data.node = itemPropNode;
			self:ShowRewardItemTip(true,data);
		end
	end
	btnData.funcUp = function()
		if type(param.propId) == "string" then
			self:ShowLuckItemTip(false)
		else
			self:ShowRewardItemTip(false);
		end
	end
	btnData.funcClick = function()
		if param.alreadyGet then return end;
		self:OnClickBtnSign(param);
	end
	btnData.time = 0.1;
	self:AddLongClick(obj:FindChild("Btn"), btnData);

	item.refreshUI = function(data)
		mask:SetActive(data.alreadyGet);

		if data.rewards then
			self.viewCtr:RefreshCurRewardItem(data.info);
			self.viewCtr:OnShowRewards(data.rewards);
		end
	end

	return item;
end

function NoviceSignInView:RefreshRewardItem(param)
	if param.id < 7 then
		for _,v in ipairs(self.rewardItemList) do
			if v.data.id == param.id then
				v.refreshUI(param);
			end
		end
	else
		if param.alreadyGet then
			self.reSignTip:SetActive(false);
			self.unavailableItem:SetActive(true)
			self.availableItem:SetActive(false)
		end
		if param.rewards then
			self.viewCtr:OnShowRewards(param.rewards);
			CC.DataMgrCenter.Inst():GetDataByKey("NoviceDataMgr").SetNoviceDataByKey("NoviceSignInView",false)
		end
	end
end

function NoviceSignInView:ShowLuckItemTip(isShow,param)
	if isShow then
		for i, v in ipairs(param.awards) do
        	local item = CC.uu.newObject(self.awardItem, self.luckItemNode)
			local spriteNode = item:FindChild("Image/Sprite")
			local textNode = item:FindChild("Text")
			self:SetImage(spriteNode,self.propDataMgr.GetIcon(v.ConfigId))
			local str = nil
			if v.High == 0 then
				str = string.format(self.language.spTips,v.Low)
			else
				str = string.format(self.language.propTips,v.Low,v.High)
			end
			self:SetText(textNode,str)
		end
		self.luckItemTip.parent = self.desNode
		self.desNode.position = param.node.transform.position;
		self.luckItemTip.localPosition = Vector3.zero;
		self:SetText(self.luckItemTip:FindChild("Content/Prop/PropName"), self.language["fd_"..param.propId]);
		self:SetImage(self.luckItemTip:FindChild("Content/Prop/Frame/Sprite"), "fd_"..param.propId);
		self.luckItemTip:SetActive(true)
		LayoutRebuilder.ForceRebuildLayoutImmediate(self.luckItemNode)
	else
		self.luckItemTip:SetActive(false)
		Util.ClearChild(self.luckItemNode,false)
	end
end

function NoviceSignInView:ShowRewardItemTip(isShow, param)
	if isShow then
		if not self.rewardItemTip then
			self.rewardItemTip = CC.ViewCenter.CommonItemDes.new();
			self.rewardItemTip:Create({parent = self.desNode});
		end
		local data = {
			parent = self.desNode,
			propId = param.propId,
		}
		self.desNode.position = param.node.transform.position
		self.rewardItemTip:Show(data);
	else
		if not self.rewardItemTip then return end;
		self.rewardItemTip:Hide();
	end
end

function NoviceSignInView:OnClickBtnSign(data)

	self.viewCtr:OnGetRewardItem(data);
end

function NoviceSignInView:OnClickBtnExplain()

	self.viewCtr:OnOpenExplainView();
end

function NoviceSignInView:CheckMarquee()
	self.marqueeQueue = self.viewCtr.signDataMgr.GetNoviceSignAwardInfo()
	if self.marqueeQueue and #self.marqueeQueue > 0 then
		--队列中中奖信息大于0
		self:PlayMarquee()
	end
end

function NoviceSignInView:PlayMarquee()
	local index = 1
	self:StartTimer("Marquee",1,function()
		if self.isTipMoving then
			return
		end
		self.isTipMoving = true
		local text = string.format(self.language.marquee,self.marqueeQueue[index].Name)
		index = index + 1
		if index > #self.marqueeQueue then
			index = 1
		end
		self.awardText.localPosition = Vector3(10000,10000,10000)
		self.awardText:GetComponent('Text').text = text
		self:DelayRun(0.1,function()
			local textW = self.awardText:GetComponent('RectTransform').rect.width
			local half = textW/2
			self.awardText.localPosition = Vector3(half + self.awardWidth, 0, 0)
			self.action = self:RunAction(self.awardText, {"localMoveTo", -half - self.awardWidth, 0, 0.65 * math.max(16,textW/40), function()
				self.action = nil
				self.isTipMoving = false
			end})
		end)
	end,-1)
end

function NoviceSignInView:ActionIn()

	self:SetCanClick(false);

	self:RunAction(self.transform, {

			{"fadeToAll", 0, 0},

			{"fadeToAll", 255, 0.5, function()

					self:SetCanClick(true);
				end}
		});
end

function NoviceSignInView:ActionOut()

	self:SetCanClick(false);

	self:OnDestroy();

	self:HideAllEffects();

	self:RunAction(self.transform, {

			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function NoviceSignInView:HideAllEffects()

	-- self:FindChild("Frame/Effect"):SetActive(false);

	-- for _,v in ipairs(self.exchangeItemList) do
	-- 	v.rewardIcon:SetActive(false);
	-- end
end

function NoviceSignInView:OnDestroy()
	if self.rewardItemTip then
		self.rewardItemTip:Destroy();
		self.rewardItemTip = nil;
	end

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return NoviceSignInView