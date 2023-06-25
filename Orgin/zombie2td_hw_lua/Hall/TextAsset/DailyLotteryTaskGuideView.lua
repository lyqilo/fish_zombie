---------------------------------
-- region DailyLotteryTaskGuideView.lua
-- Date: 2020-07-01 11:09
-- Desc: 每日抽奖任务引导
-- Author: GuoChaoWen
---------------------------------

local CC = require("CC")
local DailyLotteryTaskGuideView = CC.uu.ClassView("DailyLotteryTaskGuideView")

--[[
@param
bOnlineFinish   在线任务完成情况
bShareFinish    分享任务完成情况
]]
function DailyLotteryTaskGuideView:ctor(param)
    self:InitVar(param)
end

function DailyLotteryTaskGuideView:InitVar(param)
    self.param = param
    self.language = CC.LanguageManager.GetLanguage("L_DailyLotteryRuleView")
end

function DailyLotteryTaskGuideView:OnCreate()
    self:InitContent()
    self:InitTextByLanguage()
    self:RegisterEvent()
    self:RefreshTaskStatus(self.param)
end

function DailyLotteryTaskGuideView:InitContent()
    self.onlineTaskStatus = self:FindChild("Task1/Status")
    self.shareTaskStatus = self:FindChild("Task2/Status")
    self.btnShare = self:FindChild("Task2/BtnShare")
    self:AddClick("Mask","ActionOut")
    self:AddClick("Task2","OnClickShare")
end

-- 点击分享
function DailyLotteryTaskGuideView:OnClickShare()
    if not self.bShareFinish then
        local data = {}
        data.imgName = "share_1_2"
        data.content = CC.LanguageManager.GetLanguage("L_CaptureScreenShareView").shareContent1
        data.shareCallBack = function()
            if not self.param.bShareFinish then
                local playerId = CC.Player.Inst():GetLoginInfo().PlayerId
                CC.Request("ReqAddLotteryTimes",{PlayerID=playerId})
            end
        end
        CC.ViewManager.Open("ImageShareView",data)
    end
end

function DailyLotteryTaskGuideView:InitTextByLanguage()
    self:SetText("Task1/Desc",self.language.task1)
    self:SetText("Task2/Desc",self.language.task3)
end

-- 刷新任务状态
function DailyLotteryTaskGuideView:RefreshTaskStatus(data)
    if data and type(data) == "table" then
        log(CC.uu.Dump(data, "data===",10))
        self.onlineTaskStatus:SetActive(data.bOnlineFinish)
        self.shareTaskStatus:SetActive(data.bShareFinish)
        self.btnShare:SetActive(not data.bShareFinish)
        self.bShareFinish = data.bShareFinish or false
    end
end

function DailyLotteryTaskGuideView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnRefreshTaskStatus,CC.Notifications.NW_ReqGetDailyLotteryInfo)
end

function DailyLotteryTaskGuideView:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetDailyLotteryInfo)
end

-- 返回每日抽奖信息
function DailyLotteryTaskGuideView:OnRefreshTaskStatus(err, result)
    if err == 0 then
        local data = {}
        data.bOnlineFinish = result.OnlineTask
        data.bShareFinish = result.ShareTask
        self:RefreshTaskStatus(data)
    else
        self:OnShowErrorTips(err)
    end
end

function DailyLotteryTaskGuideView:ActionIn()
    self:SetCanClick(false)
    self:RunAction(self.transform, {
        {"fadeToAll", 0, 0},
            {"fadeToAll", 255, 0.5, function()
                self:SetCanClick(true) end}
        })
end

function DailyLotteryTaskGuideView:ActionOut()
    self:SetCanClick(false)
    self:OnDestroy()
    self:RunAction(self.transform, {
        {"fadeToAll", 0, 0.5, function() self:Destroy() end},
        })
end

function DailyLotteryTaskGuideView:ActionShow()
    self:DelayRun(0.5, function() self:SetCanClick(true) end)
    self.transform:SetActive(true)
end

function DailyLotteryTaskGuideView:ActionHide()
    self:SetCanClick(false)
    self.transform:SetActive(false)
end

function DailyLotteryTaskGuideView:OnDestroy()
    self:UnRegisterEvent()
    if self.viewCtr then
        self.viewCtr:OnDestroy()
        self.viewCtr = nil
    end
end

return DailyLotteryTaskGuideView