--------------------------------------------
-- 游戏介绍界面
--------------------------------------------
local CC = require("CC")
local MiniLHDRuleView = CC.uu.ClassView("MiniLHDRuleView")

local bindClickListener

function MiniLHDRuleView:ctor(param)
    self.mainView = param.mainView
end

function MiniLHDRuleView:OnCreate()
    self:initContent()
    bindClickListener(self)
    self:initLanguage()
end

function MiniLHDRuleView:OnDestroy()
end

function MiniLHDRuleView:initContent()
    local title = self:FindChild("InsideNode/Title/Image")
    title:GetComponent("Image"):SetNativeSize()
end

function MiniLHDRuleView:initLanguage()
    local language = self.mainView.language
    -- 规则界面文本
    local ruleText = self:SubGet("InsideNode/Scroll View/Viewport/Content", "Text")
    ruleText.text = language.RuleText
end

function MiniLHDRuleView:onCloseBtnClick()
    self:ActionOut()
end

bindClickListener = function(self)
    self:AddClick("InsideNode/Close", "onCloseBtnClick")
end

return MiniLHDRuleView
