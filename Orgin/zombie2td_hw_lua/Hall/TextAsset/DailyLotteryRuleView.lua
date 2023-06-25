---------------------------------
-- region DailyLotteryRuleView.lua
-- Date: 2020-06-18 19:22
-- Desc: 每日抽奖规则界面
-- Author: GuoChaoWen
---------------------------------

local CC = require("CC")
local DailyLotteryRuleView = CC.uu.ClassView("DailyLotteryRuleView")

--[[
@param

]]
function DailyLotteryRuleView:ctor(param)
    self:InitVar(param)
end

function DailyLotteryRuleView:InitVar(param)
    self.param = param
    self.language = self:GetLanguage()
	self.lotteryCfg = CC.ConfigCenter.Inst():getConfigDataByKey("DailyLotteryConfig")
end

function DailyLotteryRuleView:OnCreate()
    self:InitContent()
    self:InitTextByLanguage()
end

function DailyLotteryRuleView:InitContent()
    self:AddClick("BtnClose","ActionOut")
end

function DailyLotteryRuleView:InitTextByLanguage()
    local title = self:FindChild("Title/Text")
    title:GetComponent("Text").text = self.language.activityRule
    local content = self:FindChild("ScrollView/Viewport/Content")
    content:FindChild("Item01"):GetComponent("Text").text = string.format(self.language.activityTime,self.lotteryCfg.actTime)
    content:FindChild("Item02"):GetComponent("Text").text = self.language.activityRule.."："
    content:FindChild("Item03"):GetComponent("Text").text = self.language.decs1
    content:FindChild("Item04"):GetComponent("Text").text = self.language.decs2
    content:FindChild("Item04_1"):GetComponent("Text").text = self.language.decs3
    content:FindChild("Item05/Image1/Text"):GetComponent("Text").text = self.language.vipLevel
    content:FindChild("Item05/Image2/Text"):GetComponent("Text").text = self.language.finshTime
	content:FindChild("Item06/Image1/Text"):GetComponent("Text").text = "1-2"
	content:FindChild("Item06/Image2/Text"):GetComponent("Text").text = "1"
	content:FindChild("Item07/Image1/Text"):GetComponent("Text").text = "3-9"
	content:FindChild("Item07/Image2/Text"):GetComponent("Text").text = "2"
	content:FindChild("Item08/Image1/Text"):GetComponent("Text").text = "10"
	content:FindChild("Item08/Image2/Text"):GetComponent("Text").text = "3"
    content:FindChild("Item09"):GetComponent("Text").text = self.language.finishTaskTips
    content:FindChild("Item10"):GetComponent("Text").text = self.language.task1
    content:FindChild("Item11"):GetComponent("Text").text = self.language.task2
    content:FindChild("Item12"):GetComponent("Text").text = self.language.task3
end

function DailyLotteryRuleView:ActionIn()
    self:SetCanClick(false)
    self:RunAction(self.transform, {
        {"fadeToAll", 0, 0},
            {"fadeToAll", 255, 0.5, function()
                self:SetCanClick(true) end}
        })
end

function DailyLotteryRuleView:ActionOut()
    self:SetCanClick(false)
    self:OnDestroy()
    self:RunAction(self.transform, {
        {"fadeToAll", 0, 0.5, function() self:Destroy() end},
        })
end

function DailyLotteryRuleView:ActionShow()
    self:DelayRun(0.5, function() self:SetCanClick(true) end)
    self.transform:SetActive(true)
end

function DailyLotteryRuleView:ActionHide()
    self:SetCanClick(false)
    self.transform:SetActive(false)
end

function DailyLotteryRuleView:OnDestroy()
    if self.viewCtr then
        self.viewCtr:OnDestroy()
        self.viewCtr = nil
    end
end

return DailyLotteryRuleView