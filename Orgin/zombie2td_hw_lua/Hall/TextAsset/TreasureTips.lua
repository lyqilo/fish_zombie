---------------------------------
-- region TreasureTips.lua		-
-- Date: 2019.12.03				-
-- Desc:  一元夺宝               -
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local TreasureTips = CC.uu.ClassView("TreasureTips")

function TreasureTips:ctor(param)
	self:InitVar(param)
end

function TreasureTips:ActionIn()
    self:SetCanClick(false);
    self.transform.size = Vector2(3000, 3000)
    self.transform.localScale = Vector3(0,0,1)
    self:RunAction(self, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    		self:SetCanClick(true);
    	end})
end

function TreasureTips:InitVar(param)
    self.param = param

    self.RequestTimes = param.RequestTimes

    self.SuccessTimes = param.SuccessTimes
end

function TreasureTips:OnCreate()

    self.language = CC.LanguageManager.GetLanguage("L_TreasureView");

    self:AddClickEvent()

    self:InitTextByLanguage()

    self:SetInfo()
end

function TreasureTips:AddClickEvent()
    self:AddClick("Mask",function ()
        self:ActionOut()
    end)
end

function TreasureTips:InitTextByLanguage()
    self:FindChild("BG/PurchaseSuccess/PurchaseTimes/Text").text = self.language.tips_RequestTimes
    self:FindChild("BG/PurchaseSuccess/SuccessTimes/Text").text = self.language.tips_SuccessTimes
    self:FindChild("BG/PurchaseFail/PurchaseTimes/Text").text = self.language.tips_RequestTimes
    self:FindChild("BG/PurchaseFail/Label").text = self.language.tips_Fail
end

function TreasureTips:SetInfo()
    if self.SuccessTimes == 0 then
        self:FindChild("BG/PurchaseFail/PurchaseTimes").text = self.RequestTimes
        self:FindChild("BG/PurchaseFail"):SetActive(true)
    else
        self:FindChild("BG/PurchaseSuccess/PurchaseTimes").text = self.RequestTimes
        self:FindChild("BG/PurchaseSuccess/SuccessTimes").text = self.SuccessTimes
        self:FindChild("BG/PurchaseSuccess"):SetActive(true)
    end
end

function TreasureTips:ActionOut()
	self:SetCanClick(false);
    self:RunAction(self, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    		self:Destroy();
    	end})
end

function TreasureTips:OnDestroy()
end

return TreasureTips