local CC = require("CC")

local MiniSBViewManager = {}
local M = {}
M.__index = M
setmetatable(MiniSBViewManager, M)

local View2FilePath = {
    MiniSBActivityView = "View/MiniSBView/MiniSBActivityView",
    MiniSBChatView = "View/MiniSBView/MiniSBChatView",
    MiniSBHistoryView = "View/MiniSBView/MiniSBHistoryView",
    MiniSBLineHistoryView = "View/MiniSBView/MiniSBLineHistoryView",
    MiniSBMyHistoryView = "View/MiniSBView/MiniSBMyHistoryView",
    MiniSBRankingView = "View/MiniSBView/MiniSBRankingView",
    MiniSBRuleView = "View/MiniSBView/MiniSBRuleView",
    MiniSBDebugView = "View/MiniSBView/MiniSBDebugView"
}

function M.OpenView(viewName, parent, params)
    -- local view = CC.uu.CreateHallView(viewName, params)
    local view = (require(View2FilePath[viewName])).new(params)
    view:Create()
    view.transform:SetParent(parent, false)

    if view.ActionIn then
        view:ActionIn()
        CC.Sound.PlayHallEffect("click_boardopen")
    end
    return view
end

return MiniSBViewManager
