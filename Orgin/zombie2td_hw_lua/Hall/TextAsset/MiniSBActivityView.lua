--------------------------------------------
-- 召唤龙凤界面活动界面
--------------------------------------------
local CC = require("CC")
local MiniSBActivityView = CC.uu.ClassView("MiniSBActivityView")
local Request = require("View/MiniSBView/MiniSBNetwork/Request")
local proto = require("View/MiniSBView/MiniSBNetwork/game_pb")

local initContext
local bindClickListener

local showRulePanel
local showActivityPanel

-- 前三名特殊颜色
local textColor = {
    Color(0.97, 0.87, 0.19, 1),
    Color(0.77, 0.78, 0.86, 1),
    Color(0.95, 0.61, 0.34, 1)
}

function MiniSBActivityView:ctor(param)
    self.mainView = param.mainView
    -- 排行榜单
    self.ranks = {}
    -- 只init 一次下拉框
    self.initedDropdownBox = false
end

function MiniSBActivityView:OnCreate()
    initContext(self)
    bindClickListener(self)
    self:initLanguage()
    self:registerEvent()

    local window = CC.MiniGameMgr.GetCurWindowMode()
    if window then
        self:toWindowsSize()
    else
        self:toFullScreenSize()
    end
end

function MiniSBActivityView:registerEvent()
    CC.HallNotificationCenter.inst():register(self, self.toWindowsSize, CC.Notifications.OnSetWindowScreen)
    CC.HallNotificationCenter.inst():register(self, self.toFullScreenSize, CC.Notifications.OnSetFullScreen)
end

function MiniSBActivityView:unregisterEvent()
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetWindowScreen)
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetFullScreen)
end

function MiniSBActivityView:OnDestroy()
    self:unregisterEvent()
end

function MiniSBActivityView:initLanguage()
    local language = self.mainView.language
    -- 规则界面文本
    local ruleText = self:SubGet("InsideNode/RulePanel/Scroll View/Viewport/Content", "Text")
    ruleText.text = language.LongPhoneRuleText

    local rankText = self:SubGet("InsideNode/ActivityPanel/Info/Rank", "Text")
    local nameText = self:SubGet("InsideNode/ActivityPanel/Info/Name", "Text")
    local streakText = self:SubGet("InsideNode/ActivityPanel/Info/Streak", "Text")
    local awardText = self:SubGet("InsideNode/ActivityPanel/Info/Award", "Text")
    local betCountText = self:SubGet("InsideNode/ActivityPanel/Info/BetCount", "Text")

    rankText.text = language.RankText
    nameText.text = language.NameText
    streakText.text = language.StreakText
    awardText.text = language.AwardText
    betCountText.text = language.BetCountText
end

-- 点击关闭按钮
function MiniSBActivityView:onCloseBtnClick()
    self:ActionOut()
end

-- 点击规则Toggle
function MiniSBActivityView:onRuleBtnClick()
    showRulePanel(self)
end

-- 点击活动Toggle
function MiniSBActivityView:onActivityBtnClick()
    showActivityPanel(self)
end

-- 显示活动，拉取当前龙榜
function MiniSBActivityView:refresh()
    self:loadLongPhoneData(0)
end

-- 拉取榜单
function MiniSBActivityView:loadLongPhoneData(index)
    local cb = function(err, sCLongphoneRankRsp)
        if err == proto.ErrSuccess then
            self:refreshData(sCLongphoneRankRsp)
        end
    end
    Request.LoadLongphoneData(index, cb)
end

local function getTimeByTimeStamp(timeStamp)
    return os.date("%d/%m/%Y ", timeStamp) --日 月 年格式返回（20.11.2019）
end

-- 刷新榜单
function MiniSBActivityView:refreshData(sCLongphoneRankRsp)
    log(CC.uu.Dump(sCLongphoneRankRsp, "refreshData sCLongphoneRankRsp =", 10))
    local ranks = sCLongphoneRankRsp.ranks
    local count = #ranks
    self.ranks = ranks
    -- 刷新榜单
    self.scrollerController:RefreshScroller(count, 0)

    local language = self.mainView.language
    self.myStreakText.text = language.MyStreakText .. sCLongphoneRankRsp.myScore
    self.myPositionText.text = language.MyPositionText .. sCLongphoneRankRsp.myRank

    self.histSummary = sCLongphoneRankRsp.histSummary

    if not self.initedDropdownBox then
        local dropdownItems = {}
        for i, v in ipairs(self.histSummary) do
            local historyText
            -- 如果时间戳为0 则代表当前榜单，榜单分为龙凤两榜
            if v.timeStamp == 0 then
                if v.longphoneType == proto.Long then
                    historyText = language.RankLongNow
                elseif v.longphoneType == proto.Phone then
                    historyText = language.RankPhoneNow
                end
            else
                -- 其他榜单
                local typeText
                if v.longphoneType == proto.Long then
                    typeText = language.Long
                elseif v.longphoneType == proto.Phone then
                    typeText = language.Phone
                end

                local time = getTimeByTimeStamp(v.timeStamp)
                historyText = time .. language.God .. v.index .. typeText
            end

            table.insert(dropdownItems, historyText)
        end

        self.initedDropdownBox = true

        -- 默认选中0
        DropdownUI.SetDropdown(self.dropdownTransform, 0, dropdownItems, nil)
        -- 下拉框选中事件
        DropdownUI.AddDropdownOnValueChange(
            self.dropdownTransform,
            function(index)
                self:loadLongPhoneData(index)
            end
        )
    end
end

-------------------------------------------------
-- 初始化榜单Item
-- @tran GameObiect
-- @tran 索引，从0开始
-------------------------------------------------
function MiniSBActivityView:initItem(tran, index)
    local rankId = index + 1
    -- 取出记录
    local data = self.ranks[rankId]

    tran:SetActive(true)
    tran.name = tostring(rankId)

    local rank = tran.transform:FindChild("Rank")
    local rankImage = tran.transform:FindChild("RankImage")
    local bg = tran.transform:FindChild("Bg")
    local name = tran.transform:FindChild("Name"):GetComponent("Text")
    -- 背景
    bg:SetActive(index % 2 == 0)

    -- 前三名 有Icon 字体颜色区别
    if index < 3 then
        rank:SetActive(false)
        self:SetImage(rankImage, "d" .. rankId)
        rankImage:SetActive(true)
        name.color = textColor[rankId]
    else
        rank:SetActive(true)
        rankImage:SetActive(false)
        rank:GetComponent("Text").text = tostring(rankId)
        name.color = Color(0.87, 0.71, 0.47, 1)
    end

    local nick = data.nick
    if string.len(nick) > 17 then
        nick = string.sub(nick, 1, 17) .. "..."
        log(string.format("index = %s, nick = %s ", index, nick))
    end

    name.text = data.nick
    local award = CC.uu.ChipFormat(data.award)
    local allBet = CC.uu.ChipFormat(data.allBet)

    tran.transform:FindChild("Streak"):GetComponent("Text").text = data.score
    tran.transform:FindChild("Award"):GetComponent("Text").text = award
    tran.transform:FindChild("BetCount"):GetComponent("Text").text = allBet
end

initContext = function(self)
    self.activityPanel = self:FindChild("InsideNode/ActivityPanel")
    self.rulePanel = self:FindChild("InsideNode/RulePanel")

    self.scrollerController =
        self:FindChild("InsideNode/ActivityPanel/ScrollerController"):GetComponent("ScrollerController")
    self.scrollerController:AddChangeItemListener(
        function(tran, dataIndex, cellIndex)
            self:initItem(tran, dataIndex, cellIndex)
        end
    )
    self.scrollerController:InitScroller(0)

    local pubScrollRect = self:FindChild("InsideNode/ActivityPanel/Scroller")
    self.scrollRect = pubScrollRect:GetComponent("ScrollRect")

    self.myStreakText = self:FindChild("InsideNode/ActivityPanel/MyStreak"):GetComponent("Text")
    self.myPositionText = self:FindChild("InsideNode/ActivityPanel/MyPosition"):GetComponent("Text")

    self.dropdownUI = self:FindChild("InsideNode/ActivityPanel/HistoryDropdown")
    self.dropdownTransform = self:FindChild("InsideNode/ActivityPanel/HistoryDropdown").transform

    self:FindChild("InsideNode/ActivityBtn"):GetComponent("Toggle").isOn = true
    showActivityPanel(self)
    self:refresh()
end

-------------------------------------------------
--  显示召唤龙凤界面
-------------------------------------------------
showActivityPanel = function(self)
    self.activityPanel:SetActive(true)
    self.rulePanel:SetActive(false)
end

-------------------------------------------------
--  显示规则界面
-------------------------------------------------
showRulePanel = function(self)
    self.activityPanel:SetActive(false)
    self.rulePanel:SetActive(true)
end

bindClickListener = function(self)
    self:AddClick("InsideNode/Close", "onCloseBtnClick")
    self:AddClick("InsideNode/ActivityBtn", "onActivityBtnClick")
    self:AddClick("InsideNode/RuleBtn", "onRuleBtnClick")
end

function MiniSBActivityView:toWindowsSize()
    self:FindChild("InsideNode").localScale = Vector3(0.67, 0.67, 0.67)
end

function MiniSBActivityView:toFullScreenSize()
    self:FindChild("InsideNode").localScale = Vector3(0.8, 0.8, 0.8)
end

return MiniSBActivityView
