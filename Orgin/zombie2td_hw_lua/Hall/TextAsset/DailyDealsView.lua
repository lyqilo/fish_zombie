
local CC = require("CC")
local DailyDealsView = CC.uu.ClassView("DailyDealsView")

function DailyDealsView:ctor(param)

	self:InitVar(param);
	self.language = self:GetLanguage()

end

function DailyDealsView:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitContent();
	self:BtnClickEvent();
	self:InitTextByLanguage();

end

function DailyDealsView:InitVar(param)

	self.param = param;
end

function DailyDealsView:InitContent()
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self.activityDataMgr.SetActivityInfoByKey("DailyDealsView", {redDot = false})
end

function DailyDealsView:InitTextByLanguage()
	self.BtnBuy = self:FindChild("Image/Mrcz_btn")
    self:FindChild("Image/Text1").text = self.language.Tip1
    self:FindChild("Image/Text2").text = self.language.diban_Text
	self:FindChild("Image/Text3").text = self.language.Tip2
	self:FindChild("Image/Text4").text = self.language.dd_N_Text
	self:FindChild("Image/Mrcz_yj/Text").text = self.language.dd_Text
	self:FindChild("Image/Mrcz_btn/Text").text = self.language.Btn_Text
	
end

function DailyDealsView:BtnClickEvent()
	self:AddClick(self:FindChild("Image/Mrcz_btn"), function ()
		self.viewCtr:BuyAirDeals();
	end)
end

function DailyDealsView:ActionIn()
    self:SetCanClick(false);
    self.transform.size = Vector2(125, 0)
	self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function DailyDealsView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
        });
    self:Destroy()
end

function DailyDealsView:OnDestroy()

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return DailyDealsView