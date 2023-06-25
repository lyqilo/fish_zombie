--连接怪闪电
local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local shandianPrefab = "Effect_UI_AmuletLine"

local Lightning = GC.class2("Lightning")

function Lightning:Init(config)
    self.startPoint = ZTD.MainScene.SetupPos2UiPos(config.startPoint)
    self.endPoint = ZTD.MainScene.SetupPos2UiPos(config.endPoint)
    self.curCount = config.curCount
    self.connectCount = config.connectCount
    self.ConnectID = config.ConnectID
    self.enemyList = config.enemyList
	self.eff, self.effID = ZTD.EffectManager.PlayEffect(shandianPrefab)
    self.eff.gameObject:SetActive(false)
    self:StartAction()
end

function Lightning:StartAction()
    local num = 0
    local count = 10
    local offset = 0.1
    local l = self.eff:GetComponent(typeof(UnityEngine.LineRenderer))
    l.positionCount = 0
    self.timer1 = ZTD.GameTimer.StartTimer(function()
        num = num + 1
        if num >= count + 1 then
            self.eff.gameObject:SetActive(true)
            self.timer2 = ZTD.GameTimer.StartTimer(function()
                if self.eff and l and l.positionCount then
                    for i = 1, l.positionCount do
                        local vec = Vector3.Lerp(self.startPoint, self.endPoint, i / l.positionCount)
                        if num ~= 1 and num ~= count then
                            vec.x = vec.x + math.random(-offset,offset);
                            vec.y = vec.y + math.random(-offset,offset); 
                        end
                        if i == 1 then
                            vec = self.startPoint
                        end
                        if i == l.positionCount then
                            vec = self.endPoint
                        end
                        l:SetPosition(i - 1,vec)
                    end
                end
            end, 0.1, 7)
            self.timer3 = ZTD.GameTimer.StartTimer(function()
                if self.curCount >= self.connectCount then
                    -- logError("enemyList="..#self.enemyList)
                    -- logError("curCount="..tostring(self.curCount))
                    -- logError("connectCount="..tostring(self.connectCount))
                    --logError("time="..tostring(time))
                    for index, value in ipairs(self.enemyList) do
                        -- logError("value="..GC.uu.Dump(value))
                        -- local epos = self.enemyPos
		                -- local objPos = Vector3(epos.x, epos.y, epos.z);
                        -- logError("objPos="..GC.uu.Dump(objPos))
                        value.enemy:CheckPlayCoin(value.position)
                    end
                    ZTD.GameTimer.DelayRun(0.1,function()
                        -- log("111 ConnectID="..tostring(self.ConnectID))
                        ZTD.LightningMgr:RemoveLightning(self.ConnectID)
                    end)
                end
            end, 0.7, 1)
            return
        end
        l.positionCount = num
        local vec = Vector3.Lerp(self.startPoint, self.endPoint, (num - 1) / count)
        if num ~= 1 and num ~= count then
            vec.x = vec.x + math.random(-offset,offset);
            vec.y = vec.y + math.random(-offset,offset);
        end
        if num == count then
            vec = self.endPoint
        end
        l:SetPosition(num - 1,vec)
    end, 0.02, count + 1)
end

function Lightning:Release()
    if self.timer1 then
        ZTD.GameTimer.StopTimer(self.timer1)
        self.timer1 = nil
        -- log("self.timer1 = nil")
    end
    if self.timer2 then
        ZTD.GameTimer.StopTimer(self.timer2)
        self.timer2 = nil
        -- log("self.timer2 = nil")
    end
    if self.timer3 then
        ZTD.GameTimer.StopTimer(self.timer3)
        self.timer3 = nil
        -- log("self.timer3 = nil")
    end
    self.eff.gameObject:SetActive(false)
    ZTD.EffectManager.RemoveEffectByID(self.effID)
    self.eff = nil
    -- log("self.eff = nil")
end

return Lightning