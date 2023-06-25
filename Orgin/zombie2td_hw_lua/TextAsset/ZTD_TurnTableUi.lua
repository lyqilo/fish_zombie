local TimeMapBase = require "_ZTD_GoldPlay.TimeMapBase"
--魅魔转盘逻辑

local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local Prefab = "TD_TurnTableUi"
local guangEffectPb = "Effect_UI_ZhuanPanShuZiTw"
local bulletPrefab = "TD_HERO_02_zidan01"
local textPrefab = "TD_TurnTextEffect"

local TurnTableUi = GC.class2("ZTD_TurnTableUi", ZTD.TimeMapBase)
local SUPER = ZTD.TimeMapBase

function TurnTableUi:Init(data)
    SUPER.Init(self)
    self:InitData(data)
    self:InitUI()
    self:AddEvent()
end

function TurnTableUi:InitData(data)
    -- logError("TurnTableUi data="..GC.uu.Dump(data))
    self.data = data
    self.callBack = self.data.callback
    self.targetPos = self.data.targetPos
    self.PlayerId = self.data.dt.PlayerId
    self.addRatio = self.data.dt.AddRatio
    self.GiantHitPower = self.data.dt.GiantHitPower
    self.balloonRatio = self.data.dt.BalloonRatio
    -- logError("addRatio="..tostring(self.addRatio)..("  balloonRatio=")..tostring(self.balloonRatio))
    self.uiEffectParent = ZTD.BattleView.inst.tbContainer
    self.effect = ZTD.PoolManager.GetUiItem(Prefab, self.uiEffectParent)
    self.effect.localPosition = Vector3(229, 50, 0)
    self.effect.localScale = Vector3.one
    self.effectPos = self.effect.position
    self.effect.transform:SetAsFirstSibling()

    self.coinNode = self.effect:FindChild("TurnTable/coinNode")
    self.coinTxt = self.coinNode:FindChild("text"):GetComponent("Text")
    self.coinTxt.text = ""
    self.centerNode = self.effect:FindChild("TurnTable/center")
    self.iconNode = self.effect:FindChild("TurnTable/center/iconNode")
    self.showNode = self.effect:FindChild("TurnTable/center/showNode")
    self.showBg = self.effect:FindChild("TurnTable/center/showNode/bg")
    self.wkdNode = self.effect:FindChild("TurnTable/center/showNode/wkdNode")
    self.showTxt = self.showNode:FindChild("score"):GetComponent("Text")
    self.tb1Node = self.effect:FindChild("TurnTable/tb1")
    self.tb2Node = self.effect:FindChild("TurnTable/tb2")
    self.maskImg = self.effect:FindChild("TurnTable/mask")
    self.effectNode = self.effect:FindChild("EffectNode")
    self.tableNum = self.effect:FindChild("tableNum"):GetComponent("Text")
    self.textEffectNode = self.effect:FindChild("textEffectNode")

    --转盘分值
    self.scoreList = self.data and self.data.scoreList or {}
    --转盘索引
    self.scoreListIdx = 2
    --转盘分值配置表(乘以倍率后的分值)
    self.cfgList = {}
    --中心头像结果
    self.centerIdx = self.data and self.data.centerIdx or 4
    --龙母随机值
    self.longmuScore = self.data and self.data.rat or 1

    --最终金币值
    self.coin = 0
    --金币显示值
    self.coinStr = ""
    --金币的实际值和显示值
	self.realMoney = 0
	self.showMoney = 0
    
    --转盘旋转目标角度:转n圈，停在m处，那么最终的目标角度就是 turnAngle*turnTimes+unitAngle*（旋转所得值-1）
    self.targetAngle1 = 0
    self.targetAngle2 = 0

    --延迟关闭转盘时长
    self.closeDelay = 2

    --是否启动转盘
    self.isTurning = false

    self.heroConfig = ZTD.HeroConfig
    self.turnTableConfig = ZTD.TurnTableConfig
    local heroRat = self.data.dt.AddRatio > 0 and self.data.dt.AddRatio or 1
    local douleRat = 2
    self.multiple = self.data.dt.Ratio / douleRat / heroRat--ZTD.PlayerData.GetMultiple() or 1

    --箭头特效存储表
    self.effList = {}
    --飘字特效存储表 
    self.textEffList = {}
    --维克多跑马灯中奖表
    self.curNumXList = {}
end

function TurnTableUi:InitUI()
    self.tb1Node.localRotation = Vector3.zero
    self.tb2Node.localRotation = Vector3.zero
    
    --初始化转盘数值
    for k, v in ipairs(self.turnTableConfig.cfg) do
        local txt1 = self.tb1Node:GetChild(k-1):FindChild("text"):GetComponent("Text")
        local txt2 = self.tb2Node:GetChild(k-1):FindChild("text"):GetComponent("Text")
        txt1.text = "x" .. v.x
        txt2.text = v.y * self.multiple
        table.insert(self.cfgList, {v.x, v.y*self.multiple})
        self.tb1Node:GetChild(k - 1):FindChild("select"):SetActive(false)
        self.tb2Node:GetChild(k - 1):FindChild("select"):SetActive(false)
        self.tb2Node:GetChild(k - 1):FindChild("Effect_UI_ZhuanPanShuZiTw"):SetActive(false)
    end
    -- log("cfgList="..GC.uu.Dump(self.cfgList))
    self.maskImg:SetActive(false)
    self.effect:FindChild("TurnTable/img_r"):SetActive(false)
    self.effect:FindChild("TurnTable/img_s"):SetActive(false)
    self.effect:FindChild("TurnTable/img_giant"):SetActive(false)
    self.effect:FindChild("TurnTable/img_ss"):SetActive(false)
    self.effect:FindChild("TurnTable/node_zd"):SetActive(false)
    self.effect:FindChild("Effect_LaBaJiChaiDai01YanHua"):SetActive(false)
    self.showTxt.text = ""
    local childCount = self.effectNode.childCount
    for i = 1, childCount, 1 do
        self.effectNode:GetChild(i-1):SetActive(false)
    end
    self:RollCenterBase(0)
    self.wkdNode:SetActive(false)
    self.showBg:SetActive(false)
    for i = 1, 4, 1 do
        local obj = self.wkdNode:GetChild(i-1)
        obj:FindChild("text"):SetActive(true)
        obj.localRotation = Vector3.zero
    end
end

function TurnTableUi:AddEvent()
end

--根据转盘值获取转盘索引
function TurnTableUi:GetTableKey(tab, idx, value)
    for k, v in ipairs(tab) do
        if v[idx] == value then
            return k
        end
    end
end

--启动转盘
function TurnTableUi:StartTurnTable()
    self.isTurning = true
    self:RollCenter()
    self:RollTurnTable()
end

--滚动转盘
function TurnTableUi:RollTurnTable()
    local idx = self:GetTableKey(self.cfgList, 1, self.scoreList[1].x)
    local idy = self:GetTableKey(self.cfgList, 2, self.scoreList[1].y * self.multiple)
    self.targetAngle1 = self.turnTableConfig.turnAngle * self.turnTableConfig.turnTimes + self.turnTableConfig.unitAngle * (idx - 1)
    self.targetAngle2 = self.turnTableConfig.turnAngle * self.turnTableConfig.turnTimes + self.turnTableConfig.unitAngle * (idy - 1)
    -- log("targetAngle1="..tostring(self.targetAngle1))
    -- log("targetAngle2="..tostring(self.targetAngle2))
    self:StartAction(self.tb1Node,
    {
        {
            {"spawn",
                {"to", 1, 100, self.turnTableConfig.turnInterval1, function()
                    ZTD.PlayMusicEffect("ZTD_TurnTableRoll")
                end, ease=ZTD.Action.EInOutQuad},
                {"rotateTo", 0, 0, self.targetAngle1, self.turnTableConfig.turnInterval1,
                    onEnd = function()		
                        self.tb1Node:GetChild(idx - 1):FindChild("select"):SetActive(true)				
                        -- log("第一轮旋转结束")
                    end,
                    ease=ZTD.Action.EInOutQuad
                }
            }
        }
            
    })
    ZTD.GameTimer.DelayRun(self.turnTableConfig.turnInterval, function()
        self:StartAction(self.tb2Node, 
        {
            {"rotateTo", 0, 0, self.targetAngle2, self.turnTableConfig.turnInterval2,
            onEnd = function()			
                self.maskImg:SetActive(true)
                self.tb2Node:GetChild(idy - 1):FindChild("select"):SetActive(true)	
                self.effectNode:FindChild("Effect_UI_ZhuanPanGuang01"):SetActive(true)
                local callFunc = function()
                    self.coin = self.coin + self.cfgList[idx][1] * self.cfgList[idy][2]
                    self.coinStr = self.cfgList[idx][1].."x"..self.cfgList[idy][2]
                    self:ShowCoin()
                    self:ShowRatio()
                end
                self:CreateGuangEffect(idy - 1, callFunc)	
                -- log("第二轮旋转结束")
                ZTD.PlayMusicEffect("ZTD_TurnTableStop")
            end,
            ease=ZTD.Action.EInOutQuad}
        })
    end)
end

--滚动中心头像
function TurnTableUi:RollCenter()
    local iconIdx = 1
    self:StartAction(self.iconNode, 
        {
            {"to", 1, self.turnTableConfig.turnCenterRatio, self.turnTableConfig.turnCenterInterval, function()
                self:RollCenterBase(iconIdx)
                iconIdx = iconIdx + 1
                if iconIdx > 4 then
                    iconIdx = 1
                end
            end, onEnd = function()										
                self:RollCenterBase(self.centerIdx)
                -- log("中心头像旋转结束")
                self.effectNode:FindChild("Effect_UI_ZhuanPan"):SetActive(true)
                if self.centerIdx ~= 4 then
                    self:ShowTextEffect()
                end
            end},
            {"delay", self.turnTableConfig.showRewardDelay},
            {"call", function()
                self:ShowReward()
            end}
        })
end

--切换中心头像
function TurnTableUi:RollCenterBase(index)
    for i = 1, 4, 1 do
        self.iconNode:GetChild(i - 1):SetActive(false)    
    end
    if index == 0 then
        return
    end
    self.iconNode:GetChild(index - 1):SetActive(true)    
end

--展示总奖励效果
function TurnTableUi:ShowReward()
    self:ShowIcon()
end

--英雄模式
function TurnTableUi:ShowIcon()
    if self.centerIdx == 4 then
        self:RollCenterBase(0)
        self.showBg:SetActive(true)
        self.wkdNode:SetActive(true)
        self:ShowWKD()
    elseif self.centerIdx == 3 then
        self.effectNode:FindChild("Effect_UI_AiRuiKaDcGj"):SetActive(true)
        ZTD.PlayMusicEffect("ZTD_ERK")
        self:ShowARK()
    elseif self.centerIdx == 2 then
        self:ShowLZ()
    elseif self.centerIdx == 1 then
        self:RollCenterBase(0)
        self:ShowLM()
    end
end

--飘字效果
function TurnTableUi:ShowTextEffect(isGrandSlam)
    -- logError("isGrandSlam="..tostring(isGrandSlam))
    local textObj = ZTD.PoolManager.GetUiItem(textPrefab, self.textEffectNode)
    local index = #self.textEffList
    self.textEffList[index+1] = textObj
    textObj.localPosition = Vector3.zero
    textObj.localScale = Vector3.zero
    self:StartAction(textObj, {
        {"fadeToAll", 255, 0.01}
    })
    local str = "TurnTextImg"..self.centerIdx
    if isGrandSlam then
        str = "TurnTextImg5"
    end
    -- logError("centerIdx="..tostring(self.centerIdx))
    textObj:GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", str)
    textObj:GetComponent("Image"):SetNativeSize()
    local endFunc = function()
        self:StartAction(textObj, {
            {"fadeToAll", 255, 0.01}
        })
        ZTD.PoolManager.RemoveUiItem(textPrefab, textObj)
        self.textEffList[index+1] = nil
    end
    self:StartAction(textObj, {
        {"delay", 0.6},
        {"scaleTo", 1, 1, 1, 0.1},
        {"delay", 0.5},
        {"spawn",
            {"localMoveBy", 0, 50, 0, 1},
            {"fadeToAll", 0, 1}
        , onEnd = function ()
            endFunc()
        end},
    })
end

--随机一个唯一值
function TurnTableUi:Random(tab)
    local newTab = {}
    for i = 1, #tab, 1 do
        local idx = math.random(1, #tab)
        table.insert(newTab, tab[idx])
        table.remove(tab, idx)
    end
    return newTab
end

--维克多中心文字动画
function TurnTableUi:RotateTW(isOver)
    local tab = self:Random({1, 2, 3, 4})
    local radnum = 0
    local state = false
    if isOver then
        radnum = math.random(1, 4)
        -- logError("radnum="..tostring(radnum))
    end
    -- logError("tab="..GC.uu.Dump(tab))
    for k, v in ipairs(tab) do
        local obj = self.wkdNode:GetChild(v-1)
        local timeTab = self:Random({0, 0.1, 0.1, 0.2})
        local delayTime = timeTab[k]
        self:StartAction(obj, 
           {
            {"delay", delayTime},
            {"rotateTo", 0, 630, 0, 0.2},
            {"call", function()
                if isOver and radnum >= k then
                    state = false
                else
                    state = true
                end
                obj:FindChild("text"):SetActive(state)
            end},
            {"rotateTo", 0, 0, 0, 0.2, onEnd = function()
                if not isOver then
                    ZTD.PlayMusicEffect("ZTD_WKD")
                end
            end}
           }
        ) 
    end
    -- logError("111 scoreListIdx="..tostring(self.scoreListIdx))
    local isGrandSlam = false
    if self.scoreListIdx == 8 and self.scoreListIdx == #self.scoreList then
        isGrandSlam = true
    end
    -- logError("isOver="..tostring(isOver))
    if not isOver then
        self:ShowTextEffect(isGrandSlam)
    end
end

--跑马灯
function TurnTableUi:RotateSelect()
    -- logError("cfgList="..GC.uu.Dump(self.cfgList))
    local totalNum = #self.cfgList
    local count = 2
    local curNumX = self:GetTableKey(self.cfgList, 1, self.scoreList[self.scoreListIdx-1].x)
    local curNumY = self:GetTableKey(self.cfgList, 2, self.scoreList[self.scoreListIdx-1].y * self.multiple)
    local nextNumX = self:GetTableKey(self.cfgList, 1, self.scoreList[self.scoreListIdx].x)
    local nextNumY = self:GetTableKey(self.cfgList, 2,  self.scoreList[self.scoreListIdx].y * self.multiple)
    local times = (nextNumX + totalNum - curNumX) % totalNum + totalNum * count
    table.insert(self.curNumXList, {curNumX, curNumY})
    -- logError("times="..tostring(times))
    local num = 1
    -- logError("curNumXList="..GC.uu.Dump(self.curNumXList))
    -- logError("curNumX="..tostring(curNumX))
    -- logError("curNumY="..tostring(curNumY))
    -- logError("nextNumX="..tostring(nextNumX))
    -- logError("nextNumY="..tostring(nextNumY))

    ZTD.GameTimer.StartTimer(function()
        -- logError("num="..tostring(num))
        local indexX = (curNumX + num) % totalNum
        local indexY = (curNumY + num) % totalNum
        if indexX == 0 then
            indexX = 8
        end
        if indexY == 0 then
            indexY = 8
        end
        -- logError("indexX="..tostring(indexX))
        -- logError("indexY="..tostring(indexY))
        self:StartAction(self.effect,
            {
                {"call", function()
                    self.tb1Node:GetChild(indexX - 1):FindChild("select"):SetActive(true)
                    self.tb2Node:GetChild(indexY - 1):FindChild("select"):SetActive(true)
                end},
                {"delay", 0.1},
                {"call", function()
                    self.tb1Node:GetChild(indexX - 1):FindChild("select"):SetActive(false)
                    self.tb2Node:GetChild(indexY - 1):FindChild("select"):SetActive(false)
                    for k, v in ipairs(self.curNumXList) do
                        if not v then
                            return
                        end
                        if indexX == v[1] then
                            self.tb1Node:GetChild(indexX - 1):FindChild("select"):SetActive(true)
                        end
                        if indexY == v[2] then
                            self.tb2Node:GetChild(indexY - 1):FindChild("select"):SetActive(true)
                        end
                    end
                    -- logError("indexX="..tostring(indexX))
                    -- logError("nextNumX="..tostring(nextNumX))
                    -- logError("num="..tostring(num))
                    -- logError("times="..tostring(times))
                    -- logError("indexY="..tostring(indexY))
                    -- logError("nextNumY="..tostring(nextNumY))
                    if indexX == nextNumX and num == times+1 then
                        self.tb1Node:GetChild(indexX - 1):FindChild("select"):SetActive(true)
                    end
                    if indexY == nextNumY and num == times+1 then
                        self.tb2Node:GetChild(indexY - 1):FindChild("select"):SetActive(true)
                        local callFunc = function()
                            self.coin = self.coin + self.cfgList[indexX][1] * self.cfgList[indexY][2] 
                            self.coinStr = self.coinStr.."+".. self.cfgList[indexX][1].. "x".. self.cfgList[indexY][2] 
                            self:ShowCoin()
                            ZTD.GameTimer.DelayRun(self.turnTableConfig.rewardInterval, function()
                                self.scoreListIdx = self.scoreListIdx + 1
                                -- logError("scoreListIdx="..tostring(self.scoreListIdx))
                                -- logError("scoreList="..tostring(#self.scoreList))
                                if self.scoreListIdx <= #self.scoreList then
                                    self:ShowWKD()
                                else
                                    ZTD.GameTimer.DelayRun(0.2, function()
                                        if self.scoreListIdx < 9 then
                                            self:RotateTW(true)
                                        end
                                        self:OnAllFinish()
                                    end)
                                end 
                            end)
                        end
                        self:CreateGuangEffect(indexY - 1, callFunc)
                    end
                end}
            }
        )
        num = num + 1		
    end, 0.01, times)
end

--维克多模式
function TurnTableUi:ShowWKD()
    self:StartAction(self.showNode,
    {
        {"delay", 0.2},
        {"call", function()
            self:RotateTW(false)
        end},
        {"delay", 2},
        {"call", function()
            self:RotateSelect()
        end}
    })
end

--艾瑞卡模式
function TurnTableUi:ShowARK()
    ZTD.GameTimer.DelayRun(1.6, function()
        for i = self.scoreListIdx, #self.scoreList, 1 do
            local idx = self:GetTableKey(self.cfgList, 1, self.scoreList[i].x)
            local idy = self:GetTableKey(self.cfgList, 2, self.scoreList[i].y * self.multiple)
            local parent = self.tb2Node:GetChild(idy - 1)
            local eff = ZTD.PoolManager.GetGameItem(bulletPrefab, parent)
            eff:FindChild("Jian01/Trail").gameObject:SetActive(false)
            eff:FindChild("Jian01/Trail").gameObject:GetComponent("TrailRenderer").enabled = false
            local oriPos = self.centerNode.position
            local endPos = self.tb2Node:GetChild(idy - 1):FindChild("text").localPosition
            eff.position = oriPos
            eff.localScale = Vector3.one
			eff.localRotation = Vector3.zero
            local index = #self.effList
            self.effList[index+1] = eff
            local callFunc = function()
                self.coin = self.coin + self.cfgList[idx][1] * self.cfgList[idy][2] 
                self.coinStr = self.coinStr.. "+".. self.cfgList[idx][1].. "x".. self.cfgList[idy][2] 
                self:ShowCoin()
                self:OnAllFinish()
            end
            local baseFunc = function()
                self:CreateGuangEffect(idy - 1, callFunc)
                ZTD.PoolManager.RemoveGameItem(bulletPrefab, eff)
                self.effList[index+1] = nil
            end
            local action = 
            {
                {"spawn",
                    {
                        {"delay", 0.3, onEnd = function() 
                            eff:FindChild("Jian01/Trail").gameObject:SetActive(true)
                            eff:FindChild("Jian01/Trail").gameObject:GetComponent("TrailRenderer").enabled = true
                        end},
                    },
                    {
                        {"localMoveTo", endPos.x, endPos.y + 20, endPos.z, 0.3},
                    }, 
                    {
                        {"call", function()
                            ZTD.PlayMusicEffect("ZTD_Shoot")
                        end}
                    }
                },
                {"call", function()
                    self.tb1Node:GetChild(idx - 1):FindChild("select"):SetActive(true)		
                    self.tb2Node:GetChild(idy - 1):FindChild("select"):SetActive(true)
                end},
                {"delay", 0.3},
                {"call", function()
                    baseFunc()
                end}
            }
            if eff then
                self:StartAction(eff, action)
            end
        end
    end)
end

--狼主模式
function TurnTableUi:ShowLZ()
    self:StartAction(self.showNode, 
    {
        {"delay", 0},
        {"delay", 0.2, onEnd = function()
            local idx = self:GetTableKey(self.cfgList, 1, self.scoreList[self.scoreListIdx].x)
            local idy = self:GetTableKey(self.cfgList, 2, self.scoreList[self.scoreListIdx].y * self.multiple)
            self.tb1Node:GetChild(idx - 1):FindChild("select"):SetActive(true)		
            self.tb2Node:GetChild(idy - 1):FindChild("select"):SetActive(true)
            local callFunc = function()
                self.coin = self.coin + self.cfgList[idx][1] * self.cfgList[idy][2] 
                self.coinStr = self.coinStr.."+"..self.cfgList[idx][1].. "x".. self.cfgList[idy][2] 
                self:ShowCoin()
            end
            self:CreateGuangEffect(idy - 1, callFunc)
            ZTD.GameTimer.DelayRun(self.turnTableConfig.rewardInterval, function()
                self.scoreListIdx = self.scoreListIdx + 1
                if self.scoreListIdx <= #self.scoreList then
                    self:ShowLZ()
                else
                    ZTD.GameTimer.DelayRun(0.2, function()
                        self:OnAllFinish()
                    end)
                end
            end)
        end}
    }
)
end

--龙母模式
function TurnTableUi:ShowLM()
    self.showBg:SetActive(true)
    local eff = self.effectNode:FindChild("Effect_LongMuBeiShu_HuoQiu")
    local oriPos = eff.position
    local iconIdx = 2
    local endPos = self.coinNode.localPosition
    local spawnAction =
    {
        {"to", 1, self.turnTableConfig.longmuRatio, self.turnTableConfig.longmuInterval, function()
            self.showTxt.text = "X" .. iconIdx
            iconIdx = iconIdx + 1
            if iconIdx > 5 then
                iconIdx = 2
            end
        end, onEnd = function()	
            self.showTxt.text = "X" .. self.longmuScore
            self.coin = self.coin * self.longmuScore
            self.coinStr = self.coinStr.. "x".. self.longmuScore
            -- log("龙母中心展示结束")
        end},
        {"delay", 0.2},
        {"call", function()
            eff:SetActive(true)
        end},
        {"localMoveTo", endPos.x, endPos.y, endPos.z, self.turnTableConfig.longmuInterval, onEnd = function()
            self:ShowCoin()
            self:OnAllFinish()
            self.effectNode:FindChild("Effect_UI_ZhuanPanFire"):SetActive(true)
            ZTD.PlayMusicEffect("ZTD_Fire")
            eff:SetActive(false)
            eff.position = oriPos
        end}
    }
    self:StartAction(eff, spawnAction)
end

function TurnTableUi:ShowRatio()
    local pos1 = Vector3(155, -138, 0)
    local pos2 = Vector3(225, -138, 0)
    local pos3 = Vector3(325, -138, 0)
    if self.addRatio and self.addRatio > 1 then
        self.effect:FindChild("TurnTable/img_r"):SetActive(true)
        self.effect:FindChild("TurnTable/img_s"):SetActive(true)
        if self.GiantHitPower and self.GiantHitPower > 1 then
            self.effect:FindChild("TurnTable/img_ss"):SetActive(true)
            self.effect:FindChild("TurnTable/img_giant").localPosition = pos2
            self.effect:FindChild("TurnTable/node_zd").localPosition = pos3
        else
            self.effect:FindChild("TurnTable/node_zd").localPosition = pos2
        end
        self.effect:FindChild("TurnTable/node_zd").localPosition = pos3
        if self.addRatio > 1 and self.addRatio < 5 then
            local cfg = ZTD.ConstConfig[1]
            self.effect:FindChild("TurnTable/img_r"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "jb_bj_s" .. self.addRatio)
        else
            self.effect:FindChild("TurnTable/img_r"):SetActive(false)
        end
    else
        if self.GiantHitPower and self.GiantHitPower > 1 then
            self.effect:FindChild("TurnTable/img_giant").localPosition = pos1
            self.effect:FindChild("TurnTable/node_zd").localPosition = pos2
        else
            self.effect:FindChild("TurnTable/node_zd").localPosition = pos1
        end
    end
    if self.GiantHitPower and self.GiantHitPower > 1 then
        self.effect:FindChild("TurnTable/img_giant"):SetActive(true)
        self.effect:FindChild("TurnTable/img_giant"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "jb_bj_s" .. self.GiantHitPower)
    else
        self.effect:FindChild("TurnTable/img_giant"):SetActive(false)
    end
    if self.balloonRatio and self.balloonRatio > 1 then
        self.effect:FindChild("TurnTable/node_zd"):SetActive(true)
        if self.balloonRatio > 1 and self.balloonRatio < 4 then
            self.effect:FindChild("TurnTable/node_zd/img_rzd"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "jb_bj_s" .. self.balloonRatio);
            self.effect:FindChild("TurnTable/node_zd/img_zd"):SetActive(true)
        else
            self.effect:FindChild("TurnTable/node_zd"):SetActive(false)
        end
    end
end

function TurnTableUi:ShowCoin()
    -- logError("coinStr="..tostring(self.coinStr))
    self.coinTxt.text = self.coinStr
end

function TurnTableUi:OnAllFinish()
	if self.effect == nil then
		logError("! ! ! self.effect = nil")
		return
	end
	self:StartAction(self.effect, nil)
	self._isEnd = false
	local endFunc = function()		
		if self._isEnd then
			return
		end		
		self._isEnd = true
        self:FinishTurnTable()
	end
    if self.timer then
        ZTD.GameTimer.StopTimer(self.timer)
        self.timer = nil
    end
    self.timer = ZTD.GameTimer.StartTimer(function()
		local spawnAction = 
        {
            {"delay", 1},
            {"call", function()
                self.coinTxt.text = tools.numberToStrWithComma(self.coin)
                local multi = self.coin / self.multiple
                if multi >= 500 then
                    self.effect:FindChild("Effect_LaBaJiChaiDai01YanHua"):SetActive(true)
                    ZTD.PlayMusicEffect("ZTD_Fireworks")
                end
            end},
            {"spawn",
                {
                    { "delay", 2.2},
                    {"call", function()
                        self.effect:FindChild("Effect_LaBaJiChaiDai01YanHua"):SetActive(false)
                    end} 
                },
				{
					{ "delay", 2.2},
					{ "scaleTo", 0.1, 0.1, 0.1, 0.5}
				},
				{
                    {"delay", 1},
                    {"call", function()
                        if self.callBack then
                            self.callBack()
                        end
                    end},
					{ "delay", 1},
					{ "call"  , function()
						if self.effect then
                            self.tableNum.text = ""
							local targetPos = self.targetPos
							self:StartBezier(targetPos, self.effectPos, self.effect, nil, endFunc, 0.5)
						end
					end	
					},
				}
		   }
        }
        if self.effect then
			self:StartAction(self.effect, spawnAction)
		end	
    end, 0.5, 1)	
end

--结束转盘
function TurnTableUi:FinishTurnTable()
    ZTD.GameTimer.DelayRun(self.turnTableConfig.closeDelay, function()
        -- log("结束转盘")
        self.isTurning = false
        ZTD.TurnTableMgr:RemoveTurnTable(self.PlayerId)
        self:Release()
    end)
end

--创建光点特效
function TurnTableUi:CreateGuangEffect(idx, callFunc)
    local eff = self.tb2Node:GetChild(idx):FindChild("Effect_UI_ZhuanPanShuZiTw")
    eff:SetActive(true)
    ZTD.PlayMusicEffect("ZTD_Light")
    local oriPos = self.tb2Node:GetChild(idx):FindChild("text").position
    eff.position = oriPos
    eff.localScale = Vector3.one
    local action = 
    {
        {"call", function()
            local effectPos = eff.position
            local endPos = self.coinNode.position
            local endFunc = function()
                eff:SetActive(false)
                eff.position = oriPos
                if callFunc then
                    callFunc()
                end
            end
            self:StartBezier(endPos, effectPos, eff, nil, endFunc, 1)
        end}
    }
    self:StartAction(eff, action)
end

--刷新转盘数量
function TurnTableUi:RefreshTableNum(tableNum)
    local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig")
    if tableNum > 1 then
        self.tableNum.text = language.turnTableTimes..tableNum
    else
        self.tableNum.text = ""
    end
end

function TurnTableUi:Update()
end

function TurnTableUi:Release()
    if self.effect ~= nil and tostring(self.effect) ~= "null" then
		ZTD.PoolManager.RemoveUiItem(Prefab, self.effect)
        self.effect = nil
    end
    for k, v in pairs(self.effList) do
        if v ~= nil and tostring(v) ~= "null" then
            ZTD.PoolManager.RemoveGameItem(bulletPrefab, v) 
        end
    end
    for k, v in pairs(self.textEffList) do
        if v ~= nil and tostring(v) ~= "null" then
            ZTD.PoolManager.RemoveUiItem(textPrefab, v)
        end
    end
    local count = self.textEffectNode.childCount
    if count > 0 then
        local textObj = self.textEffectNode:GetChild(count - 1)
        ZTD.PoolManager.RemoveUiItem(textPrefab, textObj)
    end
	if self.timer then
        ZTD.GameTimer.StopTimer(self.timer)
        self.timer = nil
    end
    self:StopAll()
end

return TurnTableUi