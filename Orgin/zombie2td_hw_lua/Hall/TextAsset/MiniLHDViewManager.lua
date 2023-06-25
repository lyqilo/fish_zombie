local CC = require("CC")

local MiniLHDViewManager = {}
local M = {}
M.__index = M
setmetatable(MiniLHDViewManager, M)

local View2FilePath = {
    MiniLHDHistoryView = "View/MiniLHDView/MiniLHDHistoryView",
    MiniLHDChatView = "View/MiniLHDView/MiniLHDChatView",
    MiniLHDRuleView = "View/MiniLHDView/MiniLHDRuleView",
    MiniLHDDebugView = "View/MiniLHDView/MiniLHDDebugView"
}

function M.OpenView(viewName, parent, params)
    -- local view = CC.uu.CreateHallView(viewName, params)
    log("MiniLHDViewManager OpenView " .. viewName)
    local view = (require(View2FilePath[viewName])).new(params)
    view:Create()
    view.transform:SetParent(parent, false)

    if view.ActionIn then
        view:ActionIn()
        CC.Sound.PlayHallEffect("click_boardopen")
    end
    return view
end

return MiniLHDViewManager
