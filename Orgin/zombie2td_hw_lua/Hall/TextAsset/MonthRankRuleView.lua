local CC = require("CC")
local MonthRankRuleView = CC.uu.ClassView("MonthRankRuleView")

local RewardConfig = {}
RewardConfig[1] = {
    [1] = {Rank = "1",Des = "Oppo A92\n10000000ชิป"},
    [2] = {Rank = "2",Des = "50000000ชิป"},
    [3] = {Rank = "3",Des = "30000000ชิป"},
    [4] = {Rank = "4",Des = "20000000ชิป"},
    [5] = {Rank = "5",Des = "10000000ชิป"},
    [6] = {Rank = "6",Des = "5000000ชิป"},
    [7] = {Rank = "7-10",Des = "5000000ชิป"},
    [8] = {Rank = "11-15",Des = "3000000ชิป"},
    [9] = {Rank = "15-20",Des = "1000000ชิป"},
}
RewardConfig[3] = {
    -- [1] = {Rank = "1",Des = "iPhone12\n20000000ชิป"},
    -- [1] = {Rank = "1",Des = "iPhone 14 128GB\n10000000ชิป"},
    -- [2] = {Rank = "2",Des = "Apple Watch Series 8\n9000000ชิป"},
    -- [3] = {Rank = "3",Des = "ipad10.2\n80000000ชิป"},
    [1] = {Rank = "1",Des = "400Mชิป"},
    [2] = {Rank = "2",Des = "200Mชิป"},
    [3] = {Rank = "3",Des = "150Mชิป"},
    [4] = {Rank = "4",Des = "8Mชิป"},
    [5] = {Rank = "5",Des = "8Mชิป"},
    [6] = {Rank = "6",Des = "7Mชิป"},
    [7] = {Rank = "7-10",Des = "7Mชิป"},
    [8] = {Rank = "11-20",Des = "5Mชิป"},
    [9] = {Rank = "21-30",Des = "2Mชิป"},
}
RewardConfig[5] = {
    [1] = {Rank = "1",Des = "Oppo A92\n10000000ชิป"},
    [2] = {Rank = "2",Des = "50000000ชิป"},
    [3] = {Rank = "3",Des = "30000000ชิป"},
    [4] = {Rank = "4",Des = "20000000ชิป"},
    [5] = {Rank = "5",Des = "10000000ชิป"},
    [6] = {Rank = "6",Des = "5000000ชิป"},
    [7] = {Rank = "7-10",Des = "5000000ชิป"},
    [8] = {Rank = "11-15",Des = "3000000ชิป"},
    [9] = {Rank = "15-20",Des = "1000000ชิป"},
}
RewardConfig[6] = {
    -- [1] = {Rank = "1",Des = "iPhone12\n20000000ชิป"},
    [1] = {Rank = "1",Des = "400Mชิป"},
    [2] = {Rank = "2",Des = "200Mชิป"},
    [3] = {Rank = "3",Des = "150Mชิป"},
    [4] = {Rank = "4",Des = "8Mชิป"},
    [5] = {Rank = "5",Des = "8Mชิป"},
    [6] = {Rank = "6",Des = "7Mชิป"},
    [7] = {Rank = "7-10",Des = "7Mชิป"},
    [8] = {Rank = "11-20",Des = "5Mชิป"},
    [9] = {Rank = "21-30",Des = "2Mชิป"},
}

local LotteryConfig = {
    [1] = {Rank = "1",Des = "2000"},
    [2] = {Rank = "2",Des = "1500"},
    [3] = {Rank = "3",Des = "1000"},
    [4] = {Rank = "4",Des = "500"},
    [5] = {Rank = "5",Des = "500"},
    [6] = {Rank = "6",Des = "500"},
    [7] = {Rank = "7-10",Des = "500"},
    [8] = {Rank = "11-20",Des = "100"},
    [9] = {Rank = "21-30",Des = "100"},
}

function MonthRankRuleView:ctor(param)
    self:InitVar(param)
end

function MonthRankRuleView:InitVar(param)
    self.param = param
    self.language = self:GetLanguage()
end

function MonthRankRuleView:OnCreate()
    self:InitContent()
    self:InitTextByLanguage()
end

function MonthRankRuleView:InitContent()
    self:AddClick("BtnClose","ActionOut")
end

function MonthRankRuleView:InitTextByLanguage()
    self:FindChild("Title/Text").text = self.language.activityRule
    local content = self:FindChild("ScrollView/Viewport/Content")
    for i=1,9 do
        content:FindChild("Item0"..i).text = self.language[i]
    end
    for i=1,5 do
        content:FindChild("Title/"..i.."/Text").text = self.language["Title"..i]
        -- content:FindChild("Title1/"..i.."/Text").text = self.language["Title"..i]
    end
    -- content:FindChild("Item10").text = self.language[10]
    for i=1,9 do
        content:FindChild("Reward"..i.."/Rank/Text").text = RewardConfig[3][i].Rank
        content:FindChild("Reward"..i.."/3/Text").text = RewardConfig[3][i].Des
        content:FindChild("Reward"..i.."/3"):SetActive(true)
        content:FindChild("Reward"..i.."/6/Text").text = RewardConfig[6][i].Des
        content:FindChild("Reward"..i.."/6"):SetActive(true)

        -- content:FindChild("Reward1"..i.."/Rank/Text").text = LotteryConfig[i].Rank
        -- content:FindChild("Reward1"..i.."/1/Text").text = LotteryConfig[i].Des
        -- content:FindChild("Reward1"..i.."/2/Text").text = LotteryConfig[i].Des
    end
    self:HideInformation()
end

function MonthRankRuleView:HideInformation()
    local content = self:FindChild("ScrollView/Viewport/Content")
    content:FindChild("Item07"):SetActive(false)
    content:FindChild("Item08"):SetActive(false)
    content:FindChild("Title/3"):SetActive(false)
    content:FindChild("Title/4"):SetActive(false)
end

function MonthRankRuleView:ActionIn()
    self:SetCanClick(false)
    self:RunAction(self.transform, {
        {"fadeToAll", 0, 0},
            {"fadeToAll", 255, 0.5, function()
                self:SetCanClick(true) end}
        })
end

function MonthRankRuleView:ActionOut()
    self:SetCanClick(false)
    self:OnDestroy()
    self:RunAction(self.transform, {
        {"fadeToAll", 0, 0.5, function() self:Destroy() end},
        })
end

function MonthRankRuleView:ActionShow()
    self:DelayRun(0.5, function() self:SetCanClick(true) end)
    self.transform:SetActive(true)
end

function MonthRankRuleView:ActionHide()
    self:SetCanClick(false)
    self.transform:SetActive(false)
end

function MonthRankRuleView:OnDestroy()
    if self.viewCtr then
        self.viewCtr:OnDestroy()
        self.viewCtr = nil
    end
end

return MonthRankRuleView