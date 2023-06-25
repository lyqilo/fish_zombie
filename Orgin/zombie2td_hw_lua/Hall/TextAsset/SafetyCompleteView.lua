
local CC = require("CC")
local SafetyCompleteView = CC.uu.ClassView("SafetyCompleteView")

function SafetyCompleteView:ctor(param)

	self:InitVar(param);
end

function SafetyCompleteView:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();

	self:InitContent();
	self:InitTextByLanguage();
end

function SafetyCompleteView:InitVar(param)

	self.param = param or {};
	self.scanning = false;
end

function SafetyCompleteView:InitContent()
	self:SetText("Frame/Shield/Percent/Symbol", "%");
	self:SetText("Frame/BtnFitter/BtnBindPhone/Reward/Text", "10,000");
	self:SetText("Frame/BtnFitter/BtnBindFB/Reward/Text", "5,000");
	self:SetText("Frame/BtnFitter/BtnBindLine/Reward/Text", "5,000");

	self:AddClick("Frame/BtnFitter/BtnBindPhone", "OnClickBtnBindPhone");
	self:AddClick("Frame/BtnFitter/BtnBindFB", "OnClickBtnBindFacebook");
	self:AddClick("Frame/BtnFitter/BtnBindLine", "OnClickBtnBindLine");
	self:AddClick("Mask", "OnClickBtnCloseArea");

	self:ResetUI();
end

function SafetyCompleteView:InitTextByLanguage()

	local lan = self:GetLanguage();
	self:SetText("Frame/Top/Title", lan.title);
	self:SetText("Frame/Shield/Text", lan.safetyFactor);
	--self:SetText("Frame/TipSafety", lan.safetyTip1);
	self:SetText("Frame/BtnCloseArea/TipContinue", lan.btnCloseTip);
	self:SetText("Frame/BtnFitter/BtnBindPhone/Text", lan.btnBindPhone);
	self:SetText("Frame/BtnFitter/BtnBindFB/Text", lan.btnBindFacebook);
	self:SetText("Frame/BtnFitter/BtnBindLine/Text", lan.btnBindLine);
end

function SafetyCompleteView:SetBtnActive(node,active)
	node = node == "fb" and "BtnBindFB" or "BtnBindLine"
	self:FindChild("Frame/BtnFitter/"..node):SetActive(active)
end

function SafetyCompleteView:RefreshUI(param)

	if param.refreshSafetyIcon then
		self:SetSafetyIcon(param);
	end

	if param.refreshShield then
		self:PlayScanningEffect(param);
	end
end

function SafetyCompleteView:ResetUI()
	self:SetBtnState("BtnBindPhone", false);
	self:SetBtnState("BtnBindFB", false);
	self:SetBtnState("BtnBindLine", false);
	self:FindChild("Frame/Shield/Effect_ZT01"):SetActive(false);
	self:FindChild("Frame/Shield/Effect_ZT02"):SetActive(false);
end

function SafetyCompleteView:SetBtnState(btnNode, state)

	local btn = self:FindChild("Frame/BtnFitter/"..btnNode);
	btn.interactable = state;

	local icon = btn:FindChild("StateIcon");
	icon:SetLocalScale(0,0,1);
end

function SafetyCompleteView:SetSafetyIcon(param)
	local btnNode = nil
	if param.iconType == "telephone" then
		btnNode = "BtnBindPhone"
	elseif param.iconType == "facebook" then
		btnNode = "BtnBindFB"
	else
		btnNode = "BtnBindLine"
	end

	self:SetBtnState(btnNode, not param.state);

	local icon = self:FindChild("Frame/BtnFitter/"..btnNode.."/StateIcon");
	local img = param.state and "aqjc_jczt02" or "aqjc_jczt01";
	self:SetImage(icon, img);

	self:RunAction(icon,{"scaleTo", 1, 1, 0.5,ease = CC.Action.EOutBack, function()
			local sound = param.state and "safety_pass" or "safety_unpass";
			CC.Sound.PlayHallEffect(sound);
		end});
end

function SafetyCompleteView:PlayBGEffect(flag)

	local effect = self:FindChild("Frame/Shield/Effect_ZT01");
	effect:SetActive(flag);
	local effect = self:FindChild("Frame/Shield/Effect_ZT02");
	effect:SetActive(not flag);
end

function SafetyCompleteView:SetSafetyTip(flag)

	local lan = self:GetLanguage();
	local tip = flag and lan.safetyTip2 or (lan[self.param.str] or lan.safetyTip1);
	self:SetText("Frame/TipSafety", tip);
end

function SafetyCompleteView:PlayScanningEffect(param)

	if self.scanning then return end
	self.scanning = true;

	local effect = self:FindChild("Frame/Shield/Icon/Effect");
	effect:SetActive(true);
	self:SetSafetyTip(param.target >= 100);
	self:RunAction(effect, {
		{"scaleTo", 1, 1, 0.5,ease = CC.Action.EOutBack},
		{"delay", param.time},
		{"scaleTo", 0, 0, 0.5,ease=CC.Action.EInBack, function() 
				self.scanning = false;
				local finish = param.target >= 100;
				self:PlayBGEffect(finish);
				
			end}
	})

	self.numberCtrl = CC.ViewCenter.NumberRollerEx.new();
	local data = {}
	data.bindText = self:FindChild("Frame/Shield/Percent/Number")
	self.numberCtrl:Create(data)
	self.numberCtrl:RollFromTo(0,param.target,param.time)

	CC.Sound.PlayHallEffect("safety_scanning");
end

function SafetyCompleteView:OnClickBtnBindPhone()

	self.viewCtr:OnOpenBindPhoneView();
	self:Destroy()
end

function SafetyCompleteView:OnClickBtnBindFacebook()
	self.viewCtr:OnBindFacebook();
	self:Destroy()
end

function SafetyCompleteView:OnClickBtnBindLine()
	self.viewCtr:OnBindLine();
	self:Destroy()
end

function SafetyCompleteView:OnClickBtnCloseArea()

	self:ActionOut();
end

function SafetyCompleteView:OnFocusIn()

	self.viewCtr:CheckSafetyFactor();
end

function SafetyCompleteView:OnDestroy()
	if self.numberCtrl then
		self.numberCtrl:Destroy()
		self.numberCtrl = nil
	end

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return SafetyCompleteView