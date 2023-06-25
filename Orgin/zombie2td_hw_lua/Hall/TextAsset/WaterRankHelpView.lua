local CC = require("CC")
local WaterRankHelpView = CC.uu.ClassView("WaterRankHelpView")

function WaterRankHelpView:ctor(param)
	self:InitVar(param);
end

function WaterRankHelpView:InitVar(param)
	self.param = param or {}
	self.language = CC.LanguageManager.GetLanguage("L_WaterRankView")
    self.gameType = self.param.gameType or 1
	--排行榜奖励
	self.rewardConfig = {
		[1] = {Rank = "1",Des = "20%"},
        [2] = {Rank = "2",Des = "10%"},
        [3] = {Rank = "3",Des = "8%"},
		[4] = {Rank = "4",Des = "6%"},
        [5] = {Rank = "5-7",Des = "5%"},
        [6] = {Rank = "8-10",Des = "3%"},
        [7] = {Rank = "11-20",Des = "1.5%"},
        [8] = {Rank = "21-30",Des = "0.8%"},
        [9] = {Rank = "31-40",Des = "0.5%"},
        [10] = {Rank = "41-50",Des = "0.4%"},
	}
end

function WaterRankHelpView:OnCreate()
    self:AddClick("Mask", "ActionOut")
	self:InitTextByLanguage()
end

function WaterRankHelpView:InitTextByLanguage()
	self:FindChild("Frame/Title/Text").text = self.language.activityRule
    local content = self:FindChild("Frame/ScrollView/Viewport/Content")
    content:FindChild("Time").text = self.language.activityTime
    content:FindChild("Text").text = self.language.ruleText
    content:FindChild("Content").text = self.language.ruleContent
	if self.gameType == 1 then
		content:FindChild("GameType").text = self.language.ruleCapture
		content:FindChild("Title/1/Text").text = self.language.captureRank
	elseif self.gameType == 2 then
		content:FindChild("GameType").text = self.language.ruleOhter
		content:FindChild("Title/1/Text").text = self.language.otherRank
	end
    content:FindChild("Tip").text = self.language.ruleTip
    content:FindChild("Title/2/Text").text = self.language.jpRate
    for i = 1, 10 do
        content:FindChild("Reward"..i.."/1/Text").text = self.rewardConfig[i].Rank
        content:FindChild("Reward"..i.."/2/Text").text = self.rewardConfig[i].Des
    end
end

function WaterRankHelpView:OnDestroy()
end

return WaterRankHelpView