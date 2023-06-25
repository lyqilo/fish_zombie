--------------------------------------------
-- 游戏介绍界面
--------------------------------------------
local CC = require("CC")
local MiniSBDebugView = CC.uu.ClassView("MiniSBDebugView")
local proto = require("View/MiniSBView/MiniSBNetwork/game_pb")
local bindClickListener
local initView

function MiniSBDebugView:ctor(param)
    self.mainView = param.mainView
end

function MiniSBDebugView:ActionIn()
    self.transform.width = 795.8
    self.transform.height = 106
    self.transform.localPosition = Vector3(0, 0, 0)
end

function MiniSBDebugView:OnCreate()
    initView(self)
end

function MiniSBDebugView:registerEvent()
end

function MiniSBDebugView:unregisterEvent()
end

function MiniSBDebugView:OnDestroy()
    self:unregisterEvent()
end

function MiniSBDebugView:initLanguage()
end

function MiniSBDebugView:onCloseBtnClick()
    self:ActionOut()
end

initView = function(self)
    self:AddClick("CloseBtn", "onCloseBtnClick")
    self.daBetBtn = self:FindChild("daBet")
    self.xiaoBetBtn = self:FindChild("xiaoBet")

    self.daBetText = self:FindChild("da"):GetComponent("InputField")
    self.xiaoBetText = self:FindChild("xiao"):GetComponent("InputField")

    self:AddClick(
        self.daBetBtn,
        function()
            local value = tonumber(self.daBetText.text)
            self.mainView.viewCtr:testBet(proto.Big, value)
        end
    )

    self:AddClick(
        self.xiaoBetBtn,
        function()
            local value = tonumber(self.xiaoBetText.text)
            self.mainView.viewCtr:testBet(proto.Small, value)
        end
    )
end

return MiniSBDebugView
