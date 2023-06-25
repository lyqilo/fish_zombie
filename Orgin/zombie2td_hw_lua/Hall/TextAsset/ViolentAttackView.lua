local CC = require("CC")

local ViolentAttackView = CC.uu.ClassView("ViolentAttackView")

function ViolentAttackView:ctor(param)

	self.param = param
end


function ViolentAttackView:OnCreate()
	self:InitUI()
	self:AddClickEvent()
end

function ViolentAttackView:InitUI()
	self.language = self:GetLanguage()
	self.CountText = self:FindChild("Frame/Text")
	self.tip = self:FindChild("Frame/Tip")
	self.BtnGet = self:FindChild("Frame/BtnGet")
	
	self.Spine = self:FindChild("Frame/zadan/SkeletonGraphic (zadan01)"):GetComponent("SkeletonGraphic")
	self.bao = self:FindChild("Frame/zadan/bao")
	self.Spine.AnimationState:SetAnimation(0, "stand01", false)
	 self.Co = self:DelayRun(0.2, function()
	 	CC.Sound.PlayHallEffect("zadan_1.ogg")
	end)
	
	self.zadan = self:FindChild("Frame/zadan")
    self.DelayCo = self:DelayRun(0, function()
		self.zadan.localPosition = Vector3(0,-260.75,0)		
	end)
	
	local testFun
	testFun = function ()
		self.Spine.AnimationState:ClearTracks()
        self.Spine.AnimationState:SetAnimation(0, "stand02", false)
        self.Co = self:DelayRun(0.7, function()
	        CC.Sound.PlayHallEffect("zadan_2.ogg")
		end)	
        self.bao:SetActive(true)
        self.Spine.AnimationState.Complete =  self.Spine.AnimationState.Complete - testFun
	end	
	self.Spine.AnimationState.Complete =  self.Spine.AnimationState.Complete + testFun

	self.Co = self:DelayRun(3.7, function()
		self.CountText:SetActive(true)
		self.BtnGet:SetActive(true)
		self.CountText.transform.localScale = Vector3(0,0,1)
	    self:RunAction(self.CountText.transform, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()

		end})
	end)				
	
	self.CountText:GetComponent("Text").text  = CC.uu.ChipFormat(self.param[1].Delta)
	self.tip:GetComponent("Text").text  = self.language.Tip
	self:InitTextByLanguage()
end

function ViolentAttackView:InitTextByLanguage()
	self:FindChild("Frame/BtnGet/Text").text = self.language.Get
end

function ViolentAttackView:AddClickEvent()
	self:AddClick("Frame/BtnGet",function ()
		self:Destroy() 

	end)
end


function ViolentAttackView:OnDestroy(destroyOnLoad)
	 CC.uu.CancelDelayRun(self.Co)
	 CC.uu.CancelDelayRun(self.DelayCo)
end

return ViolentAttackView