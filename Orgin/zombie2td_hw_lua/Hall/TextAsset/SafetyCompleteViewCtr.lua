
local CC = require("CC")
local SafetyCompleteViewCtr = CC.class2("SafetyCompleteViewCtr")

function SafetyCompleteViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function SafetyCompleteViewCtr:OnCreate()
	self:InitData();
	self:RegisterEvent();
end

function SafetyCompleteViewCtr:InitVar(view, param)
	self.param = param;
	self.view = view;
end

function SafetyCompleteViewCtr:InitData()

	self:CheckSafetyFactor();
end

function SafetyCompleteViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnBindFaceBookRsp, CC.Notifications.NW_BindFacebook)
end

function SafetyCompleteViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function SafetyCompleteViewCtr:CheckSafetyFactor()

	self.view:ResetUI();

	local deltaTime = 1;
	local percent = 30;

	
	local bindState = CC.HallUtil.CheckTelBinded();
	percent = bindState and (percent + 40) or percent;
	self.view:StartTimer("telephone", deltaTime/3, function() 
		self:SetSafetyIcon("telephone", bindState);
	end);
	
	local fbBinded = CC.HallUtil.CheckFacebookBinded();
	percent = fbBinded and (percent + 30) or percent;
	self.view:StartTimer("facebook", deltaTime/2, function() 
		self:SetSafetyIcon("facebook", fbBinded);
	end);

	local lineBinded = CC.HallUtil.CheckLineBinded();
	percent = lineBinded and (percent + 30) or percent;
	self.view:StartTimer("line", deltaTime, function() 
		self:SetSafetyIcon("line", lineBinded);
	end);

	if fbBinded then
		self.view:SetBtnActive("line",false)
	elseif lineBinded then
		self.view:SetBtnActive("fb",false)
	end

	percent = percent <= 100 and percent or 100
	self:ShieldScanning(percent, deltaTime);
end

function SafetyCompleteViewCtr:SetSafetyIcon(iconType, binded)

	local data = {};
	data.refreshSafetyIcon = true;
	data.iconType = iconType;
	data.state = binded;
	self.view:RefreshUI(data);
end

function SafetyCompleteViewCtr:ShieldScanning(percent, time)

	local data = {};
	data.refreshShield = true;
	data.time = time;
	data.target = percent;
	self.view:RefreshUI(data);
end

function SafetyCompleteViewCtr:OnOpenBindPhoneView()
	CC.ViewManager.Open("BindTelView")
end

function SafetyCompleteViewCtr:OnBindFacebook()

	CC.HallUtil.BlindFacebook();
end

function SafetyCompleteViewCtr:OnBindLine()

	CC.HallUtil.BindLine();
end

function SafetyCompleteViewCtr:OnBindFaceBookRsp()

	--CC.Player.Inst():SetSafetyBindState(true);	
end

function SafetyCompleteViewCtr:Destroy()

	self:UnRegisterEvent();
end

return SafetyCompleteViewCtr;
