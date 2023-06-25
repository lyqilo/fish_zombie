
local CC = require("CC")
local ActSignInView = CC.uu.ClassView("ActSignInView")

function ActSignInView:ctor(param)

	self:InitVar(param);
end

function ActSignInView:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();

	self:InitContent();
	self:InitTextByLanguage();
end

function ActSignInView:InitVar(param)

	self.param = param;

	self.rewardItemList = {};

	self.exchangeItemList = {};

	self.commonExItem = nil;

	self.language = self:GetLanguage();

	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop");
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
end

function ActSignInView:InitContent()
	--奖励描述窗口
	self.rewardItemTip = nil;
	--奖励选中效果
	self.rewardSelected = self:FindChild("Frame/LeftPanel/RewardSelected");
	--补签提示
	self.reSignTip = self:FindChild("Frame/LeftPanel/ReSignTip");
	-- --暴击特效
	-- self.effectCrit = self:FindChild("Frame/LeftPanel/EffectCrit")
	-- self.effectHandle = self.effectCrit:GetComponent("Elf_AnimatorEventHandle");
	--物品描述父节点
	self.desNode = self:FindChild("Frame/DesNode")
	self.signEffObj = self:FindChild("Frame/SignEffect")
	self.signEffAnim = self.signEffObj:GetComponent("Animator")
	self.signEffHandle = self.signEffObj:GetComponent("Elf_AnimatorEventHandle")

	self:AddClick("Frame/BtnExplain", "OnClickBtnExplain");

	self:AddClick("Frame/PropFrame/Add", "OnClickBtnAdd");
end

function ActSignInView:InitTextByLanguage()

	self:FindChild("Frame/LeftPanel/ActTime").text = self.language.actTime;
end

function ActSignInView:RefreshUI(param)

	if param.rewardItemData then
		self:CreateRewardItems(param.rewardItemData);
	end

	if param.exchangeItemData then
		self:CreateExchangeItems(param.exchangeItemData);
	end

	if param.commonExItemData then
		self:CreateCommonExItem(param.commonExItemData);
	end

	if param.refreshRewardItem then
		self:RefreshRewardItem(param.refreshRewardItem);
	end

	if param.refreshExchangeItem then
		self:RefreshExchangeItem();
	end

	if param.refreshCount then
		self:SetText(self:FindChild("Frame/PropFrame/Count"), param.refreshCount);
	-- else
	-- 	self:SetText(self:FindChild("Frame/PropFrame/Count"), "0");
	end

	if param.showSelected ~= nil then
		self:SetCurSelectItem(param);
	end
end

function ActSignInView:SetCurSelectItem(param)
	if not param.showSelected then
		self.rewardSelected:SetActive(false);
		self.reSignTip:SetActive(false);
		return;
	end
	local item = self.rewardItemList[param.curSelect];
	self.rewardSelected:SetParent(item.obj:FindChild("SelectNode"), false);
	self.rewardSelected:SetActive(true);

	if item.data.reSignState then
		self.reSignTip:SetParent(item.obj, false);
		self.reSignTip:SetActive(true);
		self:SetText(self.reSignTip:FindChild("Text"), self.language.resign..param.resign.cost);
	else
		self.reSignTip:SetActive(false);
	end
end

function ActSignInView:CreateRewardItems(param)

	for _,v in ipairs(param) do
		local item = self:CreateRewardItem(v);
		table.insert(self.rewardItemList, item);
	end
end

function ActSignInView:CreateRewardItem(param)

	local item = {};

	item.data = param;

	local obj = self:FindChild("Frame/LeftPanel/LayoutGroup/RewardItem"..param.id);
	item.obj = obj;

	local propIcon = obj:FindChild("PropIcon");
	self:SetImage(propIcon, param.propIcon);

	--self:SetText(obj:FindChild("DateFrame/Text"), "DAY "..param.id)

	self:SetText(obj:FindChild("PropCount"), param.propCount);

	--self:SetText(obj:FindChild("PropDes"), self.propLanguage[param.propId]);

	local mask = obj:FindChild("Mask");
	mask:SetActive(param.alreadyGet);

	local itemDesNode = obj:FindChild("ItemDesNode");
	local btnData = {};
	btnData.funcLongClick = function()
		local data = {};
		data.node = itemDesNode;
		data.propId = param.propId;
		self:ShowRewardItemTip(true,data);
	end
	btnData.funcUp = function()
		self:ShowRewardItemTip(false);
	end
	btnData.funcClick = function()
		if param.alreadyGet then return end;
		self:OnClickBtnSign(param);
	end
	btnData.time = 0.3;
	self:AddLongClick(obj:FindChild("Btn"), btnData);

	item.refreshUI = function(data)
		mask:SetActive(data.alreadyGet);

		if data.rewards then
			self.signEffObj.position = obj.position
			self.signEffHandle:SetHandleEventFun(function (event)
					if event == "Hit" then
						self:RefreshSignInRound()
						self.viewCtr:RefreshCurRewardItem(data.info);
						self.viewCtr:OnShowRewards(data.rewards);
					end
				end)
			self.signEffAnim:Play("SignEffectCtrl",0,0)
		end
	end

	return item;
end

function ActSignInView:RefreshRewardItem(param)

	for _,v in ipairs(self.rewardItemList) do
		if v.data.id == param.id then
			v.refreshUI(param);
		end
	end
end

function ActSignInView:RefreshSignInRound()
	if self.viewCtr.curSignedDay >= 7 then
		for _,v in ipairs(self.rewardItemList) do
			v.obj:SetActive(v.data.id > 7)
		end
	end
end

function ActSignInView:CreateExchangeItems(param)

	for index,v in ipairs(param) do
		local item = self:CreateExchangeItem(v, index);
		table.insert(self.exchangeItemList, item);
	end
end

function ActSignInView:CreateExchangeItem(param, index)

	local item = {};

	item.data = param;

	local obj = self:FindChild("Frame/RightPanel/LayoutGroup/ExchangeItem"..index);
	item.obj = obj;

	if param.costProps[1] then
		self:SetImage(obj:FindChild("RightPanel/Icon1"), param.costProps[1].icon);
	end
	--if param.costProps[2] then
		--self:SetImage(obj:FindChild("RightPanel/Icon2"), param.costProps[2].icon);
		--self:SetText(obj:FindChild("RightPanel/Icon2/Text"), param.costProps[2].amountText);
	--else
		--obj:FindChild("RightPanel/Add"):SetActive(false)
		--obj:FindChild("RightPanel/Icon2"):SetActive(false)
	--end

	local rewardNode = obj:FindChild("RewardNode");
	-- local Des = rewardNode:FindChild("Des")
	-- Des.color = self.viewCtr.color
	-- local Count = rewardNode:FindChild("Count")
	-- Count.color = self.viewCtr.color
	-- self:SetText(Des, self.propLanguage[param.rewardPropId]);
	-- self:SetText(Count, "x"..param.rewardCount);
	item.rewardIcon = self:CreateExItemByPropId(param.rewardPropId, rewardNode);

	local btnText = obj:FindChild("BtnText");
	local btnExchange = obj:FindChild("BtnExchange");
	local btnExchangeGray = obj:FindChild("BtnExchangeGray");
	local btnExchangeGreen = obj:FindChild("BtnExchangeGreen");

	item.refreshUI = function(data)

		btnExchange:SetActive(not data.alreadyGet and data.canExchange);
		btnExchangeGray:SetActive(not data.alreadyGet and not data.canExchange);
		btnExchangeGreen:SetActive(data.alreadyGet);
		self:SetText(obj:FindChild("RightPanel/Icon1/Text"), data.costProps[1].amountText);

		btnText.color = data.btnTextColor;
		local text = data.alreadyGet and self.language.btnUnExchange or data.canExchange and self.language.btnExchange or self.language.btnExchangeGray;
		self:SetText(btnText, text);
	end

	item.refreshUI(param);

	local itemDesNode = obj:FindChild("ItemDesNode");
	local btnData = {};
	btnData.funcLongClick = function()
		local data = {};
		data.node = itemDesNode;
		data.propId = param.rewardPropId;
		self:ShowRewardItemTip(true,data);
	end
	btnData.funcUp = function()
		self:ShowRewardItemTip(false);
	end
	btnData.time = 0.1;
	self:AddLongClick(rewardNode, btnData);

	self:AddClick(btnExchange, function()

			self:OnClickBtnExchange(param);
		end);

	local comp = btnExchangeGray:GetComponent("Graphic");
	comp.raycastTarget = true;
	self:AddClick(btnExchangeGray, function()

			self:OnClickBtnExGray();
		end);

	return item;
end

function ActSignInView:CreateExItemByPropId(id, parent)
	local rewardIcon = CC.uu.LoadHallPrefab("prefab", "SignInProp"..id, parent);
	if id == 3001 or id == 3002 then
		local spine = rewardIcon:GetComponent("SkeletonGraphic");
		spine.AnimationState:SetAnimation(0, "stand2", true)
	end
	if rewardIcon then rewardIcon:SetAsFirstSibling() end
	return rewardIcon;
end


function ActSignInView:CreateCommonExItem(param)

	local item = {};

	item.data = param;

	local obj = self:FindChild("Frame/RightPanel/LayoutGroup/CommonExItem");

	-- self:SetImage(obj:FindChild("Icon1"), param.costIcon);

	-- self:SetImage(obj:FindChild("Icon2"), param.rewardIcon);

	-- self:SetText(obj:FindChild("Icon2/Text"), param.rewardCount);

	local btnText = obj:FindChild("BtnText");
	local btnExchange = obj:FindChild("BtnExchange");
	-- local btnExchangeGray = obj:FindChild("BtnExchangeGray");

	item.refreshUI = function(data)

		-- btnExchange:SetActive(data.canExchange);
		-- btnExchangeGray:SetActive(not data.canExchange);
		-- self:SetText(obj:FindChild("Icon1/Text"), data.curCount.."/"..data.costCount);

		-- btnText.color = data.btnTextColor;
		self:SetText(btnText, self.language.btnGo);
	end

	item.refreshUI(param);

	self:AddClick(btnExchange, function()
		if self.activityDataMgr.GetActivityInfoByKey("CapsuleView").switchOn then
			CC.HallNotificationCenter.inst():post(CC.Notifications.OnChangeFreeChipsView, "CapsuleView")
		end
	end);

	self.commonExItem = item;
end

function ActSignInView:RefreshExchangeItem()

	for _,v in ipairs(self.exchangeItemList) do
		v.refreshUI(v.data);
	end

	self.commonExItem.refreshUI(self.commonExItem.data);
end

function ActSignInView:ShowRewardItemTip(isShow, param)
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

function ActSignInView:OnClickBtnSign(data)
	self.viewCtr:OnGetRewardItem(data);
end

function ActSignInView:OnClickBtnExchange(data)
	self.viewCtr:OnExchangeItem(data);
end

function ActSignInView:OnClickBtnExGray()
	self.viewCtr:OnChangeToCapsule();
end

function ActSignInView:OnClickBtnExplain()
	self.viewCtr:OnOpenExplainView();
end

function ActSignInView:OnClickBtnAdd()
	self.viewCtr:OnChangeToCapsule();
end

function ActSignInView:ActionIn()
	self:SetCanClick(false);

	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					self:SetCanClick(true);
				end}
		});
end

function ActSignInView:ActionOut()
	self:SetCanClick(false);
	self:OnDestroy();
	CC.HallUtil.HideByTagName("Effect", false)

	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function ActSignInView:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true)
end

function ActSignInView:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function ActSignInView:OnDestroy()

	if self.rewardItemTip then
		self.rewardItemTip:Destroy();
		self.rewardItemTip = nil;
	end

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return ActSignInView