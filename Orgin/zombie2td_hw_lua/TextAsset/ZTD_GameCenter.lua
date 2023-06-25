local ZTD = require("ZTD")
local GC = require("GC")

--游戏管理中心--
local GameCenter = GC.class2('GameCenter')
local _instance = nil

function GameCenter.GetInstance()
    if not _instance then
        _instance = GameCenter.new()
    end
    return _instance
end

function GameCenter:EnterGame()
	ZTD.ViewManager.CloseAllView()
    ZTD.ViewManager.Open("ZTD_MainView")
end

return GameCenter