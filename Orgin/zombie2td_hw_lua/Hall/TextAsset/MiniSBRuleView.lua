--------------------------------------------
-- 游戏介绍界面
--------------------------------------------
local CC = require("CC")
local MiniSBRuleView = CC.uu.ClassView("MiniSBRuleView")

local bindClickListener

function MiniSBRuleView:ctor(param)
    self.mainView = param.mainView
end

function MiniSBRuleView:OnCreate()
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

function MiniSBRuleView:initLanguage()
    local language = self.mainView.language
    -- 规则界面文本
    local ruleText = self:SubGet("InsideNode/Scroll View/Viewport/Content", "Text")
    ruleText.text = language.RuleText
end

function MiniSBRuleView:registerEvent()
    CC.HallNotificationCenter.inst():register(self, self.toWindowsSize, CC.Notifications.OnSetWindowScreen)
    CC.HallNotificationCenter.inst():register(self, self.toFullScreenSize, CC.Notifications.OnSetFullScreen)
end

function MiniSBRuleView:unregisterEvent()
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetWindowScreen)
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetFullScreen)
end

function MiniSBRuleView:OnDestroy()
    self:unregisterEvent()
end

function MiniSBRuleView:onCloseBtnClick()
    self:ActionOut()
end

bindClickListener = function(self)
    self:AddClick("InsideNode/Close", "onCloseBtnClick")
end

function MiniSBRuleView:toWindowsSize()
    self:FindChild("InsideNode").localScale = Vector3(0.9, 0.9, 0.9)
end

function MiniSBRuleView:toFullScreenSize()
    self:FindChild("InsideNode").localScale = Vector3(1, 1, 1)
end

return MiniSBRuleView
