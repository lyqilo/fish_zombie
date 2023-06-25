---
--- 滚动文本数值
--- Created by wangxx.
--- DateTime: 2021/7/12 18:50
--- 用法：
--- 1.创建需要滚动的文本
---   self.numberRoller = CC.ViewCenter.NumberRollerEx.new();
---   self.numberRoller:Create(param);
---   param.bindText（绑定文本）
---   param.showAbbr(展示方式)不传默认显示1,000,000,传了显示1M
--- 2.初始化文本数字 time:0时候就是直接显示
---   self.roller:RollTo(235, 0)
--- 3.更新文本 RollTo(to, time),time>0有变化效果
--- 4.销毁可以调用Destroy()
---

local CC = require("CC")

local M = CC.class2("NumberRollerEx")

function M:Create(param)
    self.bindText = param.bindText -- 绑定的文本
    self.showAll = not param.showAbbr
    self.realValue = 0  --当前显示
    self.toValue = 0    --最终显示值
end

function M:RollBy(delta,time)
    self:KillAction()

    self.toValue = self.toValue + delta

    if time == 0 then
        self:SetRollText(self.toValue)
        return
    end

    self:RollFromTo(self.realValue,self.toValue,time)
end

function M:RollTo(to, time)
    self:KillAction()

    self.toValue = to
    if time == 0 then
        self:SetRollText(self.toValue)
        return
    end

    self:RollFromTo(self.realValue,self.toValue,time)
end

function M:RollFromTo(from,to,time)
    self:KillAction()
    self.realValue = from
    self.toValue = to
    if time == 0 then
        self:SetRollText(self.toValue)
        return
    end

    local disValue = to - from
    self.toAction = CC.Action.RunAction(self.bindText, {
        "to", 0, 100, time,
        function(value)
            local t = value * 0.01;
            local tempValue = from + math.floor(disValue * t);
            --log("self.realValue.."..tempValue)
            self:SetRollText(tempValue)
        end,
        ease = CC.Action.EOutQuad,
        onEnd = function()
            self:SetRollText(to)
            self.toAction = nil
        end
    })
end

function M:GetFinalNum()
    return self.toValue
end

function M:SetRollText(num)
    self.realValue = num
    self.bindText.text = CC.uu.ChipFormat(num or 0,self.showAll)
end

function M:KillAction()
    if self.toAction then
        self.toAction:Kill(false)
        self.toAction = nil
    end
end

function M:Destroy()
    self.bindText = nil
    self:KillAction()
end

return M