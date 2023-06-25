---------------------------------
-- region DailyTurntableView.lua    -
-- Date: 2019.7.18        -
-- Desc: 每日转盘  -
-- Author: Bin        -
---------------------------------

local CC = require("CC")
local DailyTurntableView = CC.uu.ClassView("DailyTurntableView")

function DailyTurntableView:ctor(param)

	self:InitVar(param);
end

function DailyTurntableView:InitVar(param)
	self.param = param;

	self.turntableCfg = nil;

	self.awardType = nil;

	self.turntableList = {};
	--存放特效节点,用于界面弹出隐藏
	self.effectList = {};

	self.language = self:GetLanguage();

	self.effectCfg = {
		{name = "rewardEffect", path = "RightPanel/Turntable/Frame/RewardEffect"},
		{name = "rewardJPEffect", path = "RightPanel/Turntable/Frame/RewardJPEffect"},
		{name = "pointerSparkEffect", path = "RightPanel/Turntable/Pointer/Arrow/SparkEffect"},
		{name = "pointerSpreadEffect", path = "RightPanel/Turntable/Pointer/SpreadEffect"},
		{name = "btnSignEffect", path = "RightPanel/BtnSign/Effect"},
		{name = "turntableEffect", path = "RightPanel/Turntable/TurntableEffect"},
		{name = "btnVIPEffect", path = "LeftPanel/Frame/BtnVIP/Effect"},
		{name = "lightEffect", path = "LeftPanel/Frame/JackpotFrame/LightEffect"},
		{name = "JPFrameEffect", path = "LeftPanel/Frame/JackpotFrame/JPFrameEffect"},
	}
	self.PrefabInfo = {}
	self.IconTab = {}
	self.RankNum = 0
	self.quaternion = Quaternion();
end

function DailyTurntableView:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();

	self:InitContent();

	self:InitTextByLanguage();
end

function DailyTurntableView:InitContent()
	self.turntableCfg = self.viewCtr.turntableCfg;

	self.awardType = self.viewCtr.awardType;

	self.pointer = self:FindChild("RightPanel/Turntable/Pointer");

	self.pointerArrow = self.pointer:FindChild("Arrow");

	self.jackpot = self:FindChild("LeftPanel/Frame/JackpotFrame/GoldCount"):GetComponent("NumberRoller");

	for _, v in ipairs(self.effectCfg) do

		self.effectList[v.name] = self:FindChild(v.path);
	end

	for i,v in ipairs(self.turntableCfg) do

		local tb = self:InitTurntable(i);

		table.insert(self.turntableList, tb);

		self:RefreshTableAngle(i, v.orgDeltaAngle)--360 / #v.blockItems / 2);
	end

	self:AddClick("RightPanel/BtnSign", "OnClickBtnSignIn");

	self:AddClick("LeftPanel/Frame/BtnExplain", "OnClickBtnExplain");

	self:AddClick("LeftPanel/Frame/BtnVIP", "OnClickBtnVIP");
	--中奖排行榜
	self.RankPanel = self:FindChild("RankPanel")
	self.Info_Content = self.RankPanel:FindChild("InfoView/Scroller/Viewport/Content")
	self.Info_Item = self.RankPanel:FindChild("InfoView/Scroller/Viewport/Item")
	self:OptimizeAlter()
    self:AddClick(self.RankPanel:FindChild("RankBtn"), function ()
        self:OnRankClick()
	end)

	self:RunAction(self.transform, {
			{"delay", 0, function() self:FindChild("RightPanel"):SetActive(true); end},
			{"delay", 0, function() self:FindChild("LeftPanel"):SetActive(true); end},
		});
end

function DailyTurntableView:InitTextByLanguage()
	self:FindChild("LeftPanel/Frame/Tips").text = self.language.tips;
	self:FindChild("LeftPanel/Frame/BtnVIP/Text").text = self.language.btnLevelUp;
	self:FindChild("RightPanel/BtnSign/SizeFitter/Text").text = self.language.btnSign;
	self.RankPanel:FindChild("InfoView/Image/Name").text = self.language.roleName;
	self.RankPanel:FindChild("InfoView/Image/Info").text = self.language.winInfo;
end

function DailyTurntableView:InitTurntable(index)
	local tb = {};
	tb.tableNode = self:FindChild("RightPanel/Turntable/Frame/Tb"..index);
	tb.arrowNode = self:FindChild("RightPanel/Turntable/Frame/TbArrow"..index);
	tb.rollEffect = tb.tableNode:FindChild("RollEffect");
	tb.blockEffect = tb.tableNode:FindChild("BlockEffect");
	tb.arrows = {};
	tb.blocks = {};

	local tbCfg = self.turntableCfg[index];

	for i,v in ipairs(tbCfg.blockItems) do
		local awardItem = tb.tableNode:FindChild(string.format("AwardItemNode/AwardItem%s",i));

		if v.iconImg then
			local icon  = awardItem:FindChild("Image");
			icon:SetActive(true);
			self:SetImage(icon, v.iconImg);
		end

		self:SetText(awardItem:FindChild("Text"), v.desc);

		if v.type == self.awardType.ARROW then
			awardItem:SetActive(false);
			-- local arrow = tb.tableNode:FindChild(string.format("Area%s/Arrow",i));
			local arrow = tb.arrowNode:FindChild(string.format("Area%s/Arrow",i));
			arrow:SetActive(true);
			self:AddClick(arrow, function()
				self:OnClickArrow(index);
			end)
			table.insert(tb.arrows, arrow);
		end

		local image = tb.tableNode:FindChild(string.format("Area%s/Image", i));
		table.insert(tb.blocks, image);
	end

	return tb;
end

function DailyTurntableView:RefreshArrowState(stateList)
	for i,lock in ipairs(stateList) do
		local tb = self.turntableList[i];
		for _,arrow in ipairs(tb.arrows) do
			arrow.interactable = lock;
		end
	end
end

function DailyTurntableView:GetTableAngle(tableIndex)
	local tb = self.turntableList[tableIndex];
	return tb.tableNode.transform.localEulerAngles.z;
end

function DailyTurntableView:RefreshTableAngle(tableIndex, zAngle)
	local tb = self.turntableList[tableIndex];
	tb.tableNode.transform.localRotation = self.quaternion:SetEuler(0, 0, zAngle);
	tb.arrowNode.transform.localRotation = self.quaternion:SetEuler(0, 0, zAngle);
end

function DailyTurntableView:RefreshPointerArrowAngle(zAngle)
	self.pointerArrow.transform.localRotation = self.quaternion:SetEuler(0, 0, zAngle);
end

function DailyTurntableView:RefreshPointerPos(layerIndex)
	local posNode = self:FindChild("RightPanel/Turntable/Frame/PointerPos/"..layerIndex);
	self.pointer.x, self.pointer.y = posNode.x, posNode.y;
end

function DailyTurntableView:RefreshJackpot(number, time)
	local time = time or 0;
	self.jackpot:RollTo(number, time);
end

function DailyTurntableView:RefreshSignInTimes(text, showIcon)
	local btnText = self:FindChild("RightPanel/BtnSign/SizeFitter/Text");
	btnText.text =text;
	showIcon = showIcon or false;
	self:FindChild("RightPanel/BtnSign/SizeFitter/Icon"):SetActive(showIcon);
end

function DailyTurntableView:ResetBtnSignInClick(clickType)
	if clickType == "signIn" then
		self:AddClick("RightPanel/BtnSign", "OnClickBtnSignIn");
		return;
	end

	local btn = self:FindChild("RightPanel/BtnSign");
	btn.onClick = function()
		self.viewCtr:ShowFinishImmediately();
	end
end

function DailyTurntableView:ShakePointer()
	self:RunAction(self.pointer, {
			{"localMoveBy", 0, -20, 0.1, ease = CC.Action.EInSine},
			{"localMoveBy", 0, 20, 0.1}
		})
end

function DailyTurntableView:MovePointer(layerIndex, callback, delay)
	local delay = delay or 0;
	local posNode = self:FindChild("RightPanel/Turntable/Frame/PointerPos/"..layerIndex);

	self:RunAction(self.pointer,
		{
			{"delay", delay, function() CC.Sound.PlayHallEffect("turntable_pointermove"); end},
			{"localMoveTo", posNode.x, posNode.y, 0.2, ease = CC.Action.EOutBack},
			{"delay", 0, function() self:ShowPointerSpreadEffect() end},
			{"delay", 0.8, callback}
		})
end

function DailyTurntableView:ShowPointerSpreadEffect()
	self.effectList["pointerSpreadEffect"]:SetActive(true);
	self:DelayRun(1, function()
			self.effectList["pointerSpreadEffect"]:SetActive(false);
		end);
end

function DailyTurntableView:ShowPointerSparkEffect(flag)
	self.effectList["pointerSparkEffect"]:SetActive(flag);
end

function DailyTurntableView:ShowRollEffect(tableIndex)
	local effect = self.turntableList[tableIndex].rollEffect;
	effect:SetActive(true);
	self:DelayRun(1, function()
			effect:SetActive(false);
		end);
end

function DailyTurntableView:ShowRewardEffect(flag)
	local effect = self.effectList["rewardEffect"];
	effect:SetActive(true);
	self:DelayRun(1, function()
			effect:SetActive(false);
		end);
	CC.Sound.PlayHallEffect("turntable_rewardeffect");
end

function DailyTurntableView:ShowJackpotRewardEffect(flag)
	self.effectList["rewardJPEffect"]:SetActive(flag);
end

function DailyTurntableView:ShowBlockEffect(flag, tableIndex, blockIndex, immediately)

	local turntable = self.turntableList[tableIndex];

	turntable.blockEffect:SetActive(flag);

	if not flag then return end;

	turntable.blockEffect:SetParent(turntable.blocks[blockIndex], false);

	if not immediately then return end;

	local animator = turntable.blockEffect:GetComponent("Animator");

	animator:Update(1);
end

function DailyTurntableView:OnClickBtnSignIn()
	self.viewCtr:OnReqTurntableSpin();
end

function DailyTurntableView:OnClickBtnExplain()
	self.viewCtr:OnOpenExplainView();
end

function DailyTurntableView:OnClickBtnVIP()
	self.viewCtr:OnOpenStoreView();
end

--中奖排行名单
function DailyTurntableView:OnRankClick()
	--没有打开
	if self.RankPanel:FindChild("RankBtn/Dir_l").activeSelf then
		self.viewCtr:ReqRankRecord()
		self.RankPanel:FindChild("bg"):SetActive(true)
		self.RankPanel:FindChild("RankBtn").localPosition = Vector3(230,10,0)
		self.RankPanel:FindChild("RankBtn/Dir_l"):SetActive(false)
		self.RankPanel:FindChild("RankBtn/Dir_r"):SetActive(true)
		self.RankPanel:FindChild("InfoView").localPosition = Vector3(452,0,0)
	else
		self.RankPanel:FindChild("bg"):SetActive(false)
		self.RankPanel:FindChild("RankBtn").localPosition = Vector3(602,10,0)
		self.RankPanel:FindChild("RankBtn/Dir_l"):SetActive(true)
		self.RankPanel:FindChild("RankBtn/Dir_r"):SetActive(false)
		self.RankPanel:FindChild("InfoView").localPosition = Vector3(826,0,0)
	end
end

--初始化中奖排行列表
function  DailyTurntableView:InitInfo(data)
	local list = data
	for _,v in pairs(self.PrefabInfo) do
		v.transform:SetActive(false)
	end
	local isShow = true
	self.rankCoroutine = coroutine.start(function()
		for i = 1,#list do
			isShow = not isShow
			self:InfoItemData(i,list[i], isShow)
			coroutine.step(1)
		end
	end)
end

--大奖玩家信息
function DailyTurntableView:InfoItemData(index,InfoData,bgShow)
	local tran = nil
	local item = nil
	if self.PrefabInfo[index] == nil then
        tran = self.Info_Item
        item = CC.uu.newObject(tran)
        item.transform.name = tostring(index)
        self.PrefabInfo[index] = item.transform
    else
        item = self.PrefabInfo[index]
    end
	item:SetActive(true)
	local headNode = item.transform:FindChild("ItemHead")
	self:DeleteHeadIconByKey(headNode)
	Util.ClearChild(headNode,false)
	self.RankNum = self.RankNum + 1
	local param = {}
	param.parent = headNode
	param.portrait = InfoData.Portrait
	param.playerId = InfoData.PlayerId
	param.vipLevel = InfoData.Level
	param.clickFunc = "unClick"
	self:SetHeadIcon(param,self.RankNum)
	if item then
		item.transform:SetParent(self.Info_Content, false)
		item.transform:FindChild("Nick"):GetComponent("Text").text = InfoData.Name
		item.transform:FindChild("Num"):GetComponent("Text").text = InfoData.JackPot
        item.transform:FindChild("Time"):GetComponent("Text").text = os.date("%H:%M:%S %d/%m",InfoData.TimeSTamp)
        item.transform:FindChild("bg"):SetActive(bgShow)
	end
end

--优化更新
function DailyTurntableView:OptimizeAlter()
	self.Info_Item.sizeDelta = Vector2(374, 80)
	self.Info_Item:FindChild("Num").sizeDelta = Vector2(170, 50)
	self.Info_Item:FindChild("ItemHead").localScale = Vector3(0.7,0.7,0.7)
	self.Info_Item:FindChild("Nick").localPosition = Vector3(-46,-4,0)
end

--设置头像
function  DailyTurntableView:SetHeadIcon(param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

--删除头像对象
function DailyTurntableView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.IconTab[tonumber(headtran.transform.name)] ~= nil then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end
end

function DailyTurntableView:OnClickArrow(tableIndex)
	self.viewCtr:OnShowArrowTips(tableIndex);
end

function DailyTurntableView:OnFocusIn()
	self.viewCtr:OnFocusIn();
end

function DailyTurntableView:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					self:SetCanClick(true);
				end}
		});
end

function DailyTurntableView:ActionOut()
	self:SetCanClick(false);
	self:OnDestroy();
	CC.HallUtil.HideByTagName("Effect", false)
	for _,v in pairs(self.turntableList) do
		for _,arrow in ipairs(v.arrows) do
			arrow:SetActive(false)
		end
	end

	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function DailyTurntableView:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true);
end

function DailyTurntableView:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function DailyTurntableView:HideAllEffects()
	for _,v in pairs(self.effectList) do
		v:SetActive(false);
	end

	for _,v in pairs(self.turntableList) do
		v.rollEffect:SetActive(false);
		v.blockEffect:SetActive(false);
	end
end

function DailyTurntableView:OnDestroy()
	self:CancelAllDelayRun()
	self:StopAllTimer()
	self:StopAllAction()

	if self.rankCoroutine then
		coroutine.stop(self.rankCoroutine)
		self.rankCoroutine = nil
	end
	for i,v in pairs(self.IconTab) do
		if v then
			v:Destroy()
			v = nil
		end
	end
	if self.viewCtr then
		self.viewCtr:OnDestroy();
		self.viewCtr = nil;
	end
end

return DailyTurntableView