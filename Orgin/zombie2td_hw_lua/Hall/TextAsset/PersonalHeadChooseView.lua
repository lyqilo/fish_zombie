local CC = require("CC")

local PersonalHeadChooseView = CC.uu.ClassView("PersonalHeadChooseView")

local define = {
	HeadIcon = 1,
	HeadFrame = 2,
	EntryEffect = 3,
}

local gridLayoutDefine = {
	HeadIcon = {
		cellSize = Vector2(120, 120),
		constraintCount = 4,
	},
	HeadFrame = {
		cellSize = Vector2(170, 170),
		constraintCount = 3,
	},
	EntryEffect = {
		cellSize = Vector2(120, 120),
		constraintCount = 4,
	},
}

--[[
@param
callback 回调
headFrame 当前显示的头像框id
]]
function PersonalHeadChooseView:ctor(param)
	self.param = param;
	self.createTime = os.time()+math.random()
	self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView");

	self.initPortrait = CC.Player.Inst():GetSelfInfoByKey("Portrait")
	self.curSelectPortrait = self.initPortrait or 1;
	self.HasCustomPortrait = CC.Player.Inst():GetSelfInfo().Data.Player.HasCustomPortrait
	self.initFrame = CC.Player.Inst():GetSelfInfoByKey("Background") or 0
	self.curSelectFrame = self.initFrame

	local card1 = CC.Player.Inst():GetSelfInfoByKey("EPC_Super") or 0 --小月卡

	if self.curSelectFrame == 3034 and card1 <= 0 then --检查月卡是否失效
		self.curSelectFrame = 0
	end

	self.initSelectEntry = CC.Player.Inst():GetSelfInfoByKey("Effect") or 0;
	self.curSelectEntry = self.initSelectEntry

	local portraitCfg = CC.ConfigCenter.Inst():getConfigDataByKey("HeadPortrait");

	self.portraitData = {}
	for i = 1, #portraitCfg.HeadIcon do
		if portraitCfg.HeadIcon[i].Id <= 20 then
			table.insert(self.portraitData, portraitCfg.HeadIcon[i])
		end
	end
	if self.param.specialHeadList then
		--特殊活动头像
		for _, v in ipairs(self.param.specialHeadList) do
			if v > 100 and portraitCfg.HeadIcon[v] then
				table.insert(self.portraitData, 1, portraitCfg.HeadIcon[v])
			end
		end
	end
	self.headFrameData = {}
	--默认头像框
	table.insert(self.headFrameData, portraitCfg.HeadFrame[1])
	for i = 1, #portraitCfg.HeadFrame do
		local t = portraitCfg.HeadFrame[i];
		if t.HeadId > 0 and CC.Player.Inst():GetSelfInfoByKey(t.HeadId) and CC.Player.Inst():GetSelfInfoByKey(t.HeadId) > 0 then
			if not (t.HeadId == 3034 and card1 <= 0) then --not(月卡限时头像框，月卡失效头像框也不能用)
				table.insert(self.headFrameData, t)
			end
		end
	end
	--入场特效
	self.entryEffectData = {}
	--入场特效打开的类型
	local entryEffectType = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("ChristmasTaskView").switchOn and 3 or -1
	for _, v in ipairs(portraitCfg.EntryEffect) do
		--圣诞入场特效type=1， 春节入场特效type=2,泼水节入场特效type=3
		if v.EffectId > 0 and (v.EffectType == 0 or v.EffectType == entryEffectType) and
		CC.Player.Inst():GetSelfInfoByKey(v.EffectId) and CC.Player.Inst():GetSelfInfoByKey(v.EffectId) > 0 then
			table.insert(self.entryEffectData, v)
		end
	end

	self.headIconList = {};
	self.headFrameList = {};
	self.entryEffectList = {};

	self.curTab = define.HeadIcon;

	self.reqSaveHeadPortrait = false;
end

function PersonalHeadChooseView:OnCreate()
	self:InitContent();
end

function PersonalHeadChooseView:InitContent()

	local headNode = self:FindChild("Frame/LeftPanel/HeadModel/HeadNode");
	self.headIcon = CC.HeadManager.CreateHeadIcon({parent = headNode, clickFunc = "unClick", showFrameEffect = true});

	self:FindChild("Frame/LeftPanel/HeadModel/Nick").text = CC.Player.Inst():GetSelfInfoByKey("Nick");
	self:FindChild("Frame/LeftPanel/HeadModel/Id").text = "ID:"..CC.Player.Inst():GetSelfInfoByKey("Id");

	self.headIconSelected = self:FindChild("Frame/HeadIconSelected");
	self.headFrameSelected = self:FindChild("Frame/HeadFrameSelected");

	self.parent = self:FindChild("Frame/RightPanel/Viewport/Content");
	self:AddClick("Frame/BtnOk", "OnClickOk");
	self:AddClick("Frame/BtnClose", "ActionOut");
	self:AddClick("Frame/LeftPanel/Btn", "CustomPortrait");

	UIEvent.AddToggleValueChange(self:FindChild("Frame/BtnTab/BtnHeadIcon"), function(selected)
			if selected then
				self:ChangeTab(define.HeadIcon);
			end
		end);

	UIEvent.AddToggleValueChange(self:FindChild("Frame/BtnTab/BtnHeadFrame"), function(selected)
			if selected then
				self:ChangeTab(define.HeadFrame);
			end
		end);
	UIEvent.AddToggleValueChange(self:FindChild("Frame/BtnTab/BtnHeadEffect"), function(selected)
			if selected then
				self:ChangeTab(define.EntryEffect);
			end
		end);

	local btnTab = self:FindChild("Frame/BtnTab/BtnHeadIcon");
	btnTab:SetActive(true);
	btnTab:GetComponent("Toggle").isOn = false;
	btnTab:GetComponent("Toggle").isOn = true;
	self:FindChild("Frame/BtnTab/BtnHeadEffect"):SetActive(#self.entryEffectData > 0)
	self.entryEffecLeft = {}
	local parent = self:FindChild("Frame/LeftPanel/EntryEffect")
	for _, v in ipairs(self.entryEffectData) do
		self.entryEffecLeft[v.EffectId] = CC.uu.LoadHallPrefab("prefab", "EntryEffect"..v.EffectId, parent)
		if v.EffectScale then
			self.entryEffecLeft[v.EffectId].localScale = Vector3(v.EffectScale, v.EffectScale, 1)
		end
	end
	self:FindChild("Frame/LeftPanel/Btn/ON"):SetActive(not self.HasCustomPortrait)
	self:FindChild("Frame/LeftPanel/Btn/OFF"):SetActive(self.HasCustomPortrait)
	self:InitTextByLanguage();
	self:PlayEntryEffect()
end

function PersonalHeadChooseView:InitTextByLanguage()
	self:FindChild("Frame/BtnTab/BtnHeadIcon/Text").text = self.language.changeHead
	self:FindChild("Frame/BtnTab/BtnHeadIcon/Select/Text").text = self.language.changeHead
	self:FindChild("Frame/BtnTab/BtnHeadFrame/Text").text = self.language.changeHeadFrame
	self:FindChild("Frame/BtnTab/BtnHeadFrame/Select/Text").text = self.language.changeHeadFrame
	self:FindChild("Frame/BtnTab/BtnHeadEffect/Text").text = self.language.entryEffect
	self:FindChild("Frame/BtnTab/BtnHeadEffect/Select/Text").text = self.language.entryEffect
	self:FindChild("Frame/BtnOk/Text").text = self.language.btnOk
	self:FindChild("Frame/LeftPanel/EntryEffect/EntryEffectText").text = self.language.effectDes
	self:FindChild("Frame/LeftPanel/Btn/ON/Text").text = "ON"
	self:FindChild("Frame/LeftPanel/Btn/OFF/Text").text = "OFF"
end

function PersonalHeadChooseView:ChangeTab(tab)

	self.curTab = tab;
	self:ShowItemByTab(tab);

	local itemList = {}
	if tab == define.HeadIcon then
		itemList = self.headIconList
	elseif tab == define.HeadFrame then
		itemList = self.headFrameList
	elseif tab == define.EntryEffect then
		itemList = self.entryEffectList
	end
	if table.isEmpty(itemList) then
		self:CreateItems(tab);
	end

	for k,v in pairs(define) do
		if tab == v then
			local cfg = gridLayoutDefine[k];
			local gridLayoutGroup = self:FindChild("Frame/RightPanel/Viewport/Content"):GetComponent("GridLayoutGroup");
			gridLayoutGroup.constraintCount = cfg.constraintCount;
			gridLayoutGroup.cellSize = cfg.cellSize;
		end
	end
end

function PersonalHeadChooseView:ShowItemByTab(tab)
	for _,v in ipairs(self.headIconList) do
		v:SetActive(tab == define.HeadIcon);
	end
	for _,v in ipairs(self.headFrameList) do
		v.item:SetActive(tab == define.HeadFrame);
	end
	for _,v in ipairs(self.entryEffectList) do
		v:SetActive(tab == define.EntryEffect);
	end
	if tab == define.EntryEffect then
		self:FindChild("Frame/LeftPanel/HeadModel"):SetActive(false)
		self:FindChild("Frame/LeftPanel/Btn"):SetActive(false)
		if self.curSelectEntry > 0 then
			for k, v in ipairs(self.entryEffecLeft) do
				v:SetActive(k == self.curSelectEntry)
			end
			self:FindChild("Frame/LeftPanel/EntryEffect"):SetActive(true)
		end
	else
		self:FindChild("Frame/LeftPanel/Btn"):SetActive(true)
		self:FindChild("Frame/LeftPanel/HeadModel"):SetActive(true)
		self:FindChild("Frame/LeftPanel/EntryEffect"):SetActive(false)
	end
end

function PersonalHeadChooseView:RefreshHeadModel(iconId, frameId)

	if iconId then
		self.headIcon:SetHeadImage(iconId);
	end
	self:FindChild("Frame/BtnOk"):SetActive(tostring(self.curSelectPortrait) ~= tostring(self.initPortrait) or tostring(self.curSelectFrame) ~= tostring(self.initFrame) or tostring(self.curSelectEntry) ~= tostring(self.initSelectEntry))
	if frameId then
		self.headIcon:SetHeadFrame(frameId);
	end
end

function PersonalHeadChooseView:CreateItems(tab)

	if tab == define.HeadIcon then
		self:CreateHeadIcons();
	elseif tab == define.HeadFrame then
		self:CreateHeadFrames();
	elseif tab == define.EntryEffect then
		self:CreateEntryEffects();
	end
end

function PersonalHeadChooseView:CreateHeadIcons()
	local obj = self:FindChild("Frame/HeadIconItem");
	local temp = nil
	for i,v in ipairs(self.portraitData) do
		if self.initPortrait == tostring(v.Id) then
			temp = v
			table.remove(self.portraitData, i)
			break
		end
	end
	if temp then
		table.insert(self.portraitData, 1, temp)
	end
	for index,v in ipairs(self.portraitData) do
		self:DelayRun(0 + index * 0.016, function()
				local data = {};
				data.parent = self.parent;
				data.obj = obj;
				data.data = v;
				data.index = index;
				local item = self:CreateHeadIconItem(data);
				table.insert(self.headIconList, item);
			end)
	end
end

function PersonalHeadChooseView:CreateHeadIconItem(param)

	local headObj = CC.uu.newObject(param.obj, param.parent);
	headObj:SetActive(self.curTab == define.HeadIcon);

	local headIcon = headObj:FindChild("Mask/Image");
	self:SetImage(headIcon, param.data.Headportrait);

	UIEvent.AddToggleValueChange(headObj, function(flag)
			if self.HasCustomPortrait then
				if not self.initCreate then
					CC.ViewManager.ShowTip(self.language.lockModeTip)
				end
				self.initCreate = false
				return
			end
			self.headIconSelected:SetParent(headObj, false);
			self.curSelectPortrait = param.data.Id;
			self:RefreshHeadModel(self.curSelectPortrait);
		end)

	if param.data.Id == tonumber(self.curSelectPortrait) then
		self.headIconSelected:SetParent(headObj, false);
		self.headIconSelected:SetActive(true);
		self.initCreate = true
		headObj:GetComponent("Toggle").isOn = true;
	end

	return headObj;
end

function PersonalHeadChooseView:CreateHeadFrames()
	local obj = self:FindChild("Frame/HeadFrameItem");
	for index,v in ipairs(self.headFrameData) do
		self:DelayRun(0 + index * 0.016, function()
				local data = {};
				data.parent = self.parent;
				data.obj = obj;
				data.data = v;
				data.index = index;
				local item = self:CreateHeadFrameItem(data);
				table.insert(self.headFrameList, {item = item,headFrame = v});
			end)
	end
end

function PersonalHeadChooseView:PlayEntryEffect()
	local countDown = 2
	self:StartTimer("countDown"..self.createTime, 1, function ()
		countDown = countDown - 1
		if countDown < 0 then
			countDown = 2
			if self.curSelectEntry > 0 and self.entryEffecLeft[self.curSelectEntry] then
				self.entryEffecLeft[self.curSelectEntry]:SetActive(false)
				self.entryEffecLeft[self.curSelectEntry]:SetActive(true)
			end
		end
	end,-1)
end

function PersonalHeadChooseView:CreateHeadFrameItem(param)

	local headObj = CC.uu.newObject(param.obj, param.parent);
	headObj:SetActive(self.curTab == define.HeadFrame);

	local headFrame = headObj:FindChild("Image");
	self:SetImage(headFrame, param.data.Image);

	UIEvent.AddToggleValueChange(headObj, function(flag)
			self.headFrameSelected:SetParent(headObj, false);
			self.curSelectFrame = param.data.HeadId;
			self:RefreshHeadModel(nil, self.curSelectFrame);
		end)

	if param.data.HeadId == tonumber(self.curSelectFrame) then
		self.headFrameSelected:SetParent(headObj, false);
		self.headFrameSelected:SetActive(true);
		headObj:GetComponent("Toggle").isOn = true;
	end

	return headObj;
end

function PersonalHeadChooseView:CreateEntryEffects()
	local obj = self:FindChild("Frame/HeadEffectItem");
	for index,v in ipairs(self.entryEffectData) do
		self:DelayRun(0 + index * 0.016, function()
				local data = {};
				data.parent = self.parent;
				data.obj = obj;
				data.data = v;
				data.index = index;
				local item = self:CreateEntryEffectItem(data);
				table.insert(self.entryEffectList, item);
			end)
	end
end

function PersonalHeadChooseView:CreateEntryEffectItem(param)
	local effectObj = CC.uu.newObject(param.obj, param.parent);
	effectObj:SetActive(self.curTab == define.EntryEffect);

	local effectIcon = effectObj:FindChild("Image");
	self:SetImage(effectIcon, param.data.Image);
	effectIcon:GetComponent("Image"):SetNativeSize()
	if param.data.ImageScale then
		effectIcon.localScale = Vector3(param.data.ImageScale, param.data.ImageScale, 1)
	end

	UIEvent.AddToggleValueChange(effectObj, function(flag)
			effectObj:FindChild("Select"):SetActive(flag)
			self.curSelectEntry = param.data.EffectId;
			for k, v in pairs(self.entryEffecLeft) do
				v:SetActive(k == self.curSelectEntry)
			end
			self:FindChild("Frame/LeftPanel/EntryEffect"):SetActive(true)
			self:RefreshHeadModel(nil, nil);
		end)

	if param.data.EffectId == tonumber(self.curSelectEntry) then
		effectObj:FindChild("Select"):SetActive(true)
		effectObj:GetComponent("Toggle").isOn = true;
	end

	return effectObj
end

function PersonalHeadChooseView:OnClickOk()
	if self.reqSaveHeadPortrait then return end
	self.reqSaveHeadPortrait = true;

	local data = {};
	data.Portrait = tostring(self.curSelectPortrait);
	data.Background = tostring(self.curSelectFrame);
	data.Effect = tostring(self.curSelectEntry);
	data.HasCustomPortrait = tostring(self.HasCustomPortrait)
	CC.Request("ReqSavePlayer",data, function(err, result)
			--本地保存一下头像id
			local selfInfo = CC.Player.Inst():GetSelfInfo();
			selfInfo.Data.Player.Portrait = tostring(self.curSelectPortrait);
			selfInfo.Data.Player.Background = tonumber(self.curSelectFrame);
			selfInfo.Data.Player.Effect = tonumber(self.curSelectEntry);
			selfInfo.Data.Player.HasCustomPortrait = self.HasCustomPortrait
			local param = {};
			param.headFrame = self.curSelectFrame;
			param.portrait = self.curSelectPortrait
			--发消息通知头像换icon
			CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeHeadIcon, param);
			self:Destroy();
		end, function()
			self.reqSaveHeadPortrait = false;
		end);
end

--自由模式false，锁定true
function PersonalHeadChooseView:CustomPortrait()
	self.HasCustomPortrait = not self.HasCustomPortrait
	if self.HasCustomPortrait then
		CC.ViewManager.ShowTip(self.language.lockMode)
	else
		CC.ViewManager.ShowTip(self.language.freeMode)
	end
	self:FindChild("Frame/LeftPanel/Btn/ON"):SetActive(not self.HasCustomPortrait)
	self:FindChild("Frame/LeftPanel/Btn/OFF"):SetActive(self.HasCustomPortrait)
end

function PersonalHeadChooseView:OnDestroy()
	self:StopTimer("countDown"..self.createTime)
	if self.headIcon then
		self.headIcon:Destroy();
	end

	if self.param and self.param.callback then
		self.param.callback();
	end
end

return PersonalHeadChooseView;
