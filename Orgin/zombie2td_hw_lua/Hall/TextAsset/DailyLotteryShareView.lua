---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by mayd.
--- DateTime: 2020/6/19 15:36
---

local CC = require("CC")

local DailyLotteryShareView = CC.uu.ClassView("DailyLotteryShareView")


--每日活动分享界面
--[[
@param
extraData:
    gameId:游戏id
    其他扩展参数(通过连接回传游戏)

descTop:图片中赋值的上文本
descBottom:图片中赋值的下文本
content: 文本分享内容

]]
function DailyLotteryShareView:ctor(param)
    
    self.param = param or {}

    self.param.bg = param.bg or ""

    self.param.descTop = param.descTop or ""

    self.param.descBottom = param.descBottom or ""
    
    self.param.content = param.content or ""

    self.param.extraData = param.extraData or { gameId = 1 }
    
end

function DailyLotteryShareView:OnCreate()

    self:Init()

end

function DailyLotteryShareView:Init()

    self:SetRawImageFromAb(self:FindChild("Layer_UI/ShareGroup/Bg"),self.param.bg)
    
    self.topTxt = self:SubGet("Layer_UI/ShareGroup/topTxt","Text")
    
    self.bottomTxt = self:SubGet("Layer_UI/ShareGroup/bottomTxt","RichText")
    
    self.topTxt.text = self.param.descTop
    
    self.bottomTxt.text = self.param.descBottom
    
    self:DelayRun(0.1, function()
        self:CaptureScreen()
    end)
    
end


function DailyLotteryShareView:CaptureScreen()
    
    local param = {
        extraData = self.param.extraData,
        isShowPlayerInfo = true,
        webText = self.param.content,
        afterCB = function() self:Destroy() end,
    }
    CC.SubGameInterface.CaptureScreenShare(param)
end

function DailyLotteryShareView:ActionIn()

end

return DailyLotteryShareView