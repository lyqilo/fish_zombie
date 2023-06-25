
local CC = require("CC")
local VIPCounter = CC.class2("VIPCounter");

--[[
@param
parent: 挂载的父节点
tipsParent: VIP提示的父节点
]]
function VIPCounter:Create(param)

	self:InitVar(param);
	self:InitContent();
	self:RegisterEvent();
end

function VIPCounter:InitVar(param)

	self.param = param;
	--进度条起始X坐标
	self.progressOrgX = -170;
	--进度条铺满的X偏移量
	self.filledDeltaX = 170;
	--进度条特效起始X坐标
	self.progressEffectOrgX = -115;
	--进度条特效动作
	self.effectAction = nil;
	--vip升级提示节点
	self.VIPTips = nil;
	--记录上一次变化的vip经验值
	self.lastVIPExp = nil;

	self._actions = {};
	--VIP等级配置
	self.levelCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Level");

	self.vipRight = CC.ConfigCenter.Inst():getConfigDataByKey("VIPRights")

	self.language = CC.LanguageManager.GetLanguage("L_VIPRightShow");
end

function VIPCounter:InitContent()

	self.transform = CC.uu.LoadHallPrefab("prefab", "VIPCounter", self.param.parent);

	self.transform.onClick = function()
		self:CreateVIPTips();
	end

	self:RefreshVIP();
end

function VIPCounter:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self, self.OnChangeSelfInfo, CC.Notifications.changeSelfInfo)
end

function VIPCounter:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.changeSelfInfo)
end

function VIPCounter:OnChangeSelfInfo(props)
	local isNeedRefresh = false;
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_Level or v.ConfigId == CC.shared_enums_pb.EPC_Experience then
			isNeedRefresh = true;
		end
	end
	if not isNeedRefresh then return end;

	self:RefreshVIP(true);
end

function VIPCounter:RefreshVIP(flag)

	local VIPLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level");

	--即使刷新提示框内容
	self:RefreshVIPTips();

	--超出配置等级不处理
	if not self.levelCfg[VIPLevel+1] then
		self:SetProgressUI(1);
		return;
	end

	local curVIPExp = CC.Player.Inst():GetSelfInfoByKey("EPC_Experience");

	if self.lastVIPExp == curVIPExp then
		return;
	end

	self.lastVIPExp = curVIPExp;

	local levelUpExp = self.levelCfg[VIPLevel].Experience;

	local percent = curVIPExp / levelUpExp;

	self:SetProgressUI(percent);
end

function VIPCounter:SetProgressUI(percent, showEffect)

	local progress = self.transform:FindChild("Mask/Progress");

	local pos = progress.transform.localPosition;

	progress.transform.localPosition = Vector3(self.progressOrgX + self.filledDeltaX * percent, pos.y, pos.z);

	self.transform:FindChild("Percent"):SetText(string.format("%.2f%%",(percent * 100)));

	if showEffect then
		self:StopAction(self.effectAction, true);
		local progressEffect = self.transform:FindChild("Mask/ProgressEffect");
		progressEffect:SetActive(true);

		local pos = progressEffect.transform.localPosition;

		self.effectAction = self:RunAction(progressEffect,{"localMoveTo", self.progressEffectOrgX + self.filledDeltaX * percent, pos.y, 0.5, function()
					progressEffect.transform.localPosition = Vector3(self.progressEffectOrgX, pos.y, pos.z);
					progressEffect:SetActive(false);
					self.effectAction = nil;
				end});
	end
end

function VIPCounter:CreateVIPTips()

	if self.VIPTips or not self.param.tipsParent then return end

	local VIPTips = CC.uu.newObject(self.transform:FindChild("VIPTips"), self.param.tipsParent);
	VIPTips:SetActive(true);

	local pos = VIPTips.transform.localPosition;
	VIPTips.transform.localPosition = Vector3(pos.x, pos.y + VIPTips.height, pos.z);

	self:RunAction( VIPTips, {
			{"localMoveTo", pos.x, 0, 0.5, ease = CC.Action.EOutBounce},
			{"localMoveTo", delay = 2, pos.x, VIPTips.height, 0.4, ease = CC.Action.EInExpo, function()
				CC.uu.destroyObject(self.VIPTips);
				self.VIPTips = nil;
			end},
		});

	self.VIPTips = VIPTips;

	self:RefreshVIPTips();
end

function VIPCounter:RefreshVIPTips()

	if not self.VIPTips then return end

	local level = CC.Player.Inst():GetSelfInfoByKey("EPC_Level");

	local tips = self.language[level+1].Tips[1];

	local text = "";

	for i,v in ipairs(tips) do
		text = text..v..(i<#tips and "\n" or "");
	end

	local curVIPExp = CC.Player.Inst():GetSelfInfoByKey("EPC_Experience");

	local levelUpExp = self.levelCfg[level].Experience;

	local award = ""
	if level < 30 then
		award = CC.uu.numberToStrWithComma(self.vipRight[level+2].Freeprop[1].Count)
	end

	text = string.format(text, (levelUpExp-curVIPExp)/1000000,award);

	self.VIPTips:FindChild("Text").text = text;
end

function VIPCounter:RunAction(target, action)
	local tween = CC.Action.RunAction(target, action)
	table.insert(self._actions,tween)
	return tween
end

function VIPCounter:StopAction(tween, beComplete)
	for key, action in pairs(self._actions) do
		if tween == action then
			action:Kill(beComplete or false)
			self._actions[key] = nil
			break
		end
	end
end

function VIPCounter:StopAllAction(beComplete)
	for _, action in pairs(self._actions) do
        action:Kill(beComplete or false)
    end
    self._actions = {}
end

function VIPCounter:Destroy(isDestroyObj)

	self:StopAllAction();
	self:UnRegisterEvent();

	if isDestroyObj then
		if self.transform then
			CC.uu.destroyObject(self.transform);
			self.transform = nil;
		end
	end

	if self.VIPTips then
		CC.uu.destroyObject(self.VIPTips);
		self.VIPTips = nil;
	end
end

return VIPCounter;