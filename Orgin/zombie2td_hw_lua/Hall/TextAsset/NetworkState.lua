--[[
!Note：一定要在建立socket之后再调用start方法
!Note：stop socket之后一定要调用stop方法
!Note：退出游戏之前一定要调用destory方法
]]
local CC = require("CC")
local uu = CC.uu
local M = CC.class2("NetworkState")

--WIFI等级对应延迟数据列表
local _levelTb = {
    [1] = math.huge,
    [2] = 400,
    [3] = 200,
    [4] = 50,
}

--WIFI等级对应颜色数据列表
local _levelColorTb = {
    [1] = "<color=#db1b1b>%sms</color>",
    [2] = "<color=#e9853c>%sms</color>",
    [3] = "<color=#f9dc3e>%sms</color>",
    [4] = "<color=#3ae42d>%sms</color>",
}

--WIFI最大等级
local _levelMax = 4
--默认检查间隔 /秒
local _defaultInterval = 1

local _CreatePrefab
local _SetLvInfo
local _Ping

--WIFI类
--@sessionTag. 建立socket时的tag
--@parent
function M:ctor(sessionTag, parent, launcher)
    self.tag = sessionTag
    self.checkInterval = _defaultInterval
    self.launcher = launcher or IO.Launcher
    self.checkCount = 0
    self.bIsWorking = false
    self.pongFunc = function(value) _SetLvInfo(self, value) end
    _CreatePrefab(self, parent)
end

--启动WIFI
function M:Start()
    if self.bIsWorking then
        return
    end

    self.bIsWorking = true
    UpdateBeat:Add(_Ping, self)
    self:Show()
end

function M:Stop()
    self.checkCount = 0
    self.bIsWorking = false
    UpdateBeat:Remove(_Ping, self)
    self:Hide()
end

--销毁WIFI
function M:Destroy()
    self:Stop()
    -- 销毁渲染模型
    if self.v_prefab_obj then
        uu.destroyObject(self.v_prefab_obj)
    end
end

function M:Show()
    if not self.v_prefab_obj then
        return
    end
    self.v_prefab_obj:SetActive(true)
end

function M:Hide()
    if not self.v_prefab_obj then
        return
    end
    self.v_prefab_obj:SetActive(false)

    for i=1,4 do
        self.wifiImages[i]:SetActive(false)
    end

    self.lagValueText:SetText("")
end

-- @interval. 多久检测1次网络延时，单位为秒
function M:SetCheckInterval(interval)
    self.checkInterval = interval
end

--创建WIFI预制体
_CreatePrefab = function(self, parent)
    --创建WIFI渲染模型
    self.v_prefab_obj = uu.LoadHallPrefab("prefab", "SubGameUi_NetworkState", parent, "SubGameUi_NetworkState")
    if not self.v_prefab_obj then
        return
    end
    
    --其余数据
    self.wifiImages = {}
    for i=1,4 do
        local image = self.v_prefab_obj:FindChild("Root/NetworkImgTips/wifi"..i)
        self.wifiImages[i] = image
    end
    self.lagValueText = self.v_prefab_obj:FindChild("Root/Tip/lagValue")
end

--设置WIFI等级信息
_SetLvInfo = function(self, value)
    if not self.bIsWorking then return end
    
    --筛选渲染等级
    local lv = _levelMax
    for k = #_levelTb , 1,-1 do
        if value / _levelTb[k] <= 1 then
            lv = k
            break
        end
    end
    --填充渲染数据
    for i=1,4 do
        self.wifiImages[i]:SetActive(i == lv)
    end
    local showValue = (lv == 1) and 999 or value
    local str = string.format(_levelColorTb[lv], showValue)
    self.lagValueText:SetText(str)
end

_Ping = function(self)
    local delta = 1/Application.targetFrameRate*Time.timeScale
    self.checkCount = self.checkCount + delta
    if self.checkCount >= self.checkInterval then
        self.checkCount = self.checkCount - self.checkInterval
        self.launcher.Lag(self.tag, self.pongFunc)
    end
end

return M