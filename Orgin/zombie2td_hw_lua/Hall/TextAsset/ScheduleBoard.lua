local CC = require("CC")

local ScheduleBoard = CC.uu.ClassView("ScheduleBoard")
local M = ScheduleBoard

function M:ctor(param)
	self.param = param or {}
	self.language = CC.LanguageManager.GetLanguage("L_WorldCupView");
end

function M:OnCreate()

	self:InitUI()
	self:InitTextByLanguage()
	self:AddClickEvent()
end

function M:InitUI()
	if not self.param[1] then return end;
	local timeStamp = self.param[1].GameStartTime;
	local date = self:FindChild("TopPanel/Date");
	date.text = CC.TimeMgr.GetTimeFormat3(timeStamp);

	for i,v in ipairs(self.param) do
		local item = self:FindChild("MidPanel/Item"..i);
		item:SetActive(true);
		local gameDes = item:FindChild("GameDes");
		gameDes.text = v.GameName;
		local gameTime = item:FindChild("Time");
		gameTime.text = CC.TimeMgr.GetTimeFormat2(v.GameStartTime);
		local lNation = item:FindChild("LNation");
		self:SetImage(lNation, "circle_"..v.Countrys[1].CountryId);
		local rNation = item:FindChild("RNation");
		self:SetImage(rNation, "circle_"..v.Countrys[2].CountryId);
	end
end

function M:InitTextByLanguage()
	self:FindChild("BtnPlay/Text").text = self.language.joinBet;
	self:FindChild("TopPanel/Tittle").text = self.language.joinQuiz;
end

function M:AddClickEvent()
	self:AddClick(self:FindChild("BtnPlay"), function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.WorldCupSubViewChange, "WorldCupBetView");
	end)
end

function M:ActionIn()

end

function M:ActionOut()

end

function M:OnDestroy()

end

return M