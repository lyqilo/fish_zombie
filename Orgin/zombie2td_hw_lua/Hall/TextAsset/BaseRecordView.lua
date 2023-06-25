--***************************************************
--文件描述: 记录界面父类
--关联主体: 父类hallviewbase.lua
--注意事项:无
--作者:flz
--时间:2018-11-27
--***************************************************
local CC = require("CC")
local Request = require("Model/LotteryNetwork/Request")
local BaseRecordView = CC.uu.ClassView("BaseRecordView")

local _InitVar
local _FillItem
local _FindIssueInCache

function BaseRecordView:ctor(param)
    _InitVar(self,param)
end

function BaseRecordView:OnCreate()
    -- 声明viewCtr
    self.viewCtr = self:CreateViewCtr(self.param)
    
    self:InitData()
    -- self:OverrideData()
    self:InitContent()
    self:RegisterEvent()

    -- 初始化viewCtr -- 注意:不要移动这个顺序
    self.viewCtr:OnCreate()
    self.viewCtr:QueryServerRecord()
end

function BaseRecordView:CreateViewCtr(...)
	local viewCtrClass = require("View/"..self.mainView.viewName.."/RecordCtr");
	return viewCtrClass.new(self, ...);
end


function BaseRecordView:InitData(  )
    self.fristLoad = true
    -- 请求锁, 用于防止频繁的向服务器发送请求
    self.queryLock = 0   -- 0 解锁 1 加锁  2 永久加锁
end

function BaseRecordView:InitContent(param)
    self.item = self:FindChild("Item")
    self.frame = self:FindChild("Frame")
    self.emptyObj = self:FindChild("Empty")
    self.itemParent= self:FindChild("Frame/ScrollView/Viewport/Content")
    self.scrollview = self:FindChild("Frame/ScrollView")
    self.scrollBar = self:SubGet("Frame/ScrollView/Scrollbar", "Scrollbar")

    self:InitUI()
    self:InitEvent()
end

function BaseRecordView:InitUI(  )
    self:ShowEmpty(true)
    self:InitLanguage()
    self:InitOther()
end

function BaseRecordView:InitEvent(  )
    self:AddClick("Close",function(  )
        self:ActionOut()
    end)
    self:AddClick("Mask",function(  )
        self:ActionOut()
    end)
    -- 通过下拉来获取新的记录
    self.scrollview.onEndDrag = function ( obj,eventData )
        if eventData.rawPointerPress == eventData.pointerPress then
            -- 下拉处理 -- 注意:需要防止用户疯狂的进行下拉操作导致重复取或多取数据
            local fnQuery = function(  )

                if self.scrollBar.value == 0 then
                    self:StopTimer("timer_bar")

                    self.queryLock = 1
                    self.viewCtr:QueryServerRecord()
                end
            end
        
            -- 做个流畅性处理 1s内检测
            local totalTime = 10
            self:StartTimer("timer_bar", 0.1,
            function (  )
                totalTime = totalTime - 1
                if totalTime < 0 then
                    self:StopTimer("timer_bar")
                else
                    if self.queryLock == 0 then
                        fnQuery()
                    end
                end
            end,totalTime)
        end
    end

    --滑动开始时清理下计时器
	self.scrollview.onBeginDrag = function(obj, eventData)
        self:StopTimer("timer_bar")
	end

end

function BaseRecordView:InitLanguage()
end

function BaseRecordView:InitOther(  )
end

function BaseRecordView:Refresh(rsp)
    -- log("PastLog" ..CC.uu.Dump(rsp,"BaseRecordView:Refresh收到的广播数据"))
    -- 关闭小菊花
    self:CloseLoading()
    if self.loadingDelay1S then
        self:CancelDelayRun(self.loadingDelay1S)
    end

    if rsp then
        -- 先刷新数据
        local data = self.viewCtr:DataConversion(rsp)
        if data then
            -- 更新浮标
            self.nStartIndex = self.nEndIndex + 1 -- 起始index
            self.nEndIndex = self.nStartIndex + self.nCapacity - 1 -- 结束index
            if self.queryLock ~= 2 then
                self.queryLock = 0
            end
            if data.nCount < self.nCapacity then
                -- 数据取完, 不再向服务器请求数据
                self.queryLock = 2
            end
            if self.nEndIndex >= 59 and self.isRankView then
                self.queryLock = 2
            end
            -- 再根据数据刷新UI  -- 这种方式有个问题, 当数据量太大会导致,item太多, 玩家不便于操作
            if #data.arrLotteryInfo > 0 then
                self:ShowEmpty(false)
                for i,v in ipairs(data.arrLotteryInfo) do
                    table.insert( self.viewCtr.writeCache, v ) 
                    if self.isRankView then
                        self:FillItem(v,data.nMyRank,data.lMyHitReward)
                    else
                        self:FillItem(v)
                    end

                end
            end
            -- log("PastLog" ..CC.uu.Dump(self.viewCtr.writeCache,"UI初始缓存self.viewCtr.writeCache"))
        else
            --@TODO 2018-11-20 15:05:18 暂无错误码  999 暂定数据取完
            if rsp.errorCode == 999 then
                self.queryLock = 2 -- 外部加锁,不可激活,需要重新打开界面激活
                return
            end
            self.mainView.viewCtr:ShowErrorTip(rsp.errorCode)
            -- 数据内容有误
            self:ShowEmpty(true)
        end
    else
        -- 服务器未反馈数据
        self:ShowEmpty(true)
    end
end

function BaseRecordView:OnDestroy()
    log("PastLog" .."BaseRecordView:OnDestroy")
    self:UnRegisterEvent()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
    end
end

--[[
    @desc: 填充记录
]]
function BaseRecordView:FillItem(v )
     
end

function BaseRecordView:ShowEmpty(flag )
    self.frame:SetActive(not flag)
    self.emptyObj:SetActive(flag)
end

function BaseRecordView:LoadingCtr(  )
    if self.fristLoad then
        self:ShowLoading()
    else
        -- 检查: 如果1秒内没有收到数据, 开始转小菊花
        self.loadingDelay1S = self:DelayRun(1,function (  )
            self:ShowLoading()
        end)
    end
end

function BaseRecordView:ShowLoading()
    local loading = CC.ViewManager.ShowLoading()
    if loading then
        loading:FindChild("Content/Text"):SetActive(false)
        self.loadingDelay = self:DelayRun(5,function (  )
            self:CloseLoading()
        end)
    end
end

function BaseRecordView:CloseLoading()
    self.fristLoad = false
    if self.loadingDelay then
        self:CancelDelayRun(self.loadingDelay)
    end
    CC.ViewManager.CloseLoading()
end
----------------------------------------------------------------------- 私有方法
_InitVar = function(self,param)
end

return BaseRecordView