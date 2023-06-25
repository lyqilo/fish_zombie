--------------------------------------------
-- 游戏介绍界面
--------------------------------------------
local CC = require("CC")
local MiniLHDDebugView = CC.uu.ClassView("MiniLHDDebugView")
local proto = require("View/MiniLHDView/MiniLHDNetwork/game_pb")
local bindClickListener
local initView

function MiniLHDDebugView:ctor(param)
    self.mainView = param.mainView
end

function MiniLHDDebugView:ActionIn()
    self.transform.width = 559.8
    self.transform.height = 106
    self.transform.localPosition = Vector3(0, 0, 0)
end

function MiniLHDDebugView:OnCreate()
    initView(self)
end

function MiniLHDDebugView:registerEvent()
end

function MiniLHDDebugView:unregisterEvent()
end

function MiniLHDDebugView:OnDestroy()
    self:unregisterEvent()
end

function MiniLHDDebugView:initLanguage()
end

function MiniLHDDebugView:onCloseBtnClick()
    self:ActionOut()
end

initView = function(self)
    self:AddClick("CloseBtn", "onCloseBtnClick")

    self.longBetBtn = self:FindChild("longBet")
    self.huBetBtn = self:FindChild("huBet")
    self.heBetBtn = self:FindChild("heBet")

    self.longBetText = self:FindChild("long"):GetComponent("InputField")
    self.huBetText = self:FindChild("hu"):GetComponent("InputField")
    self.heBetText = self:FindChild("he"):GetComponent("InputField")

    self:AddClick(
        self.longBetBtn,
        function()
            local value = self.longBetText.text
            self.mainView.viewCtr:sendBetFromDebug(value, proto.Long)
        end
    )

    self:AddClick(
        self.huBetBtn,
        function()
            local value = self.huBetText.text
            self.mainView.viewCtr:sendBetFromDebug(value, proto.Hu)
        end
    )
    self:AddClick(
        self.heBetText,
        function()
            local value = self.heBetText.text
            self.mainView.viewCtr:sendBetFromDebug(value, proto.He)
        end
    )
end

return MiniLHDDebugView
