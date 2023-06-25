--***************************************************
--文件描述: 纪录界面通用的Ctr组件
--关联主体: PastLotteryView.lua, PurchaseRecordView.lua,MyPurchaseNumView.lua
--注意事项: 因为三个记录界面几乎通用,所以放到了一起
-- Tips:2019.3.12缓存实际运行效率不高,逻辑混乱,整个缓存暂时移除,等待重构
--作者:flz
--时间:2018-12-07
--***************************************************
local CC = require("CC")
local NetworkManager = require("Model/LotteryNetwork/NetworkManager")
local Request = require("Model/LotteryNetwork/Request")
local LotteryProto = require "Model/LotteryNetwork/game_message_pb"
local RecordCtr = CC.class2("RecordCtr")
-- 私有方法声明
local _InitVar
local _FillItem
local _ShowEmpty
local _FindIssue
local _FindLotteryNumber

function RecordCtr:ctor(view, param)
	_InitVar(self, view, param)
end

function RecordCtr:OnCreate()
    self:InitData()
end

function RecordCtr:InitData()
    self.sMinIssue = 0
    self.cMaxIssue = 0
    self.writeCache = {}
    self.FindKey = self.view.isNumView and _FindLotteryNumber or _FindIssue
end

function RecordCtr:Destroy()
	self.view = nil
end

-- 向服务器请求记录
function RecordCtr:QueryServerRecord()
    -- log("PastLog" .."向服务器请求数据PastLotteryView:QueryServerRecord \n" .. debug.traceback())
    self.view:Query()
end

--用来转换和检查服务器数据
function RecordCtr:DataConversion(param)
    -- log("PastLog" .."PastLotteryView:DataConversion")
    local data = nil
    if param and param.errorCode == 0 and param.nCount >= 0 then
        data  = param
        if data.nCount > 0 then -- 如果是缓存数据说明已经去重,不再重复操作
            -- 倒序
            if self.view.mainView:IsResultNumberScrolling() then
                self:BlockLasetItemData(data)
            end


            -- 清理重复数据 ps:table.copy在proto数据情况下用不了,不知什么问题,真蛋疼
            -- local removeList = {}
            -- for i,v in ipairs(data.arrLotteryInfo) do
            --     local key = self.view.isNumView and v.szLotteryNumber or v.szIssue
            --     if self.FindKey(key,self.writeCache) then
            --         logError("PastLog警告:有重复数据 szIssue = " .. tostring(v.szIssue))
            --         removeList[#removeList + 1] = i
            --     end
            -- end
            -- for i,v in ipairs(removeList) do
            --     table.remove( data.arrLotteryInfo, v - i + 1 )
            -- end
        end
        -- log("PastLog" ..CC.uu.Dump(data.arrLotteryInfo,"数据转换且排序后data.arrLotteryInfo"))
    end
    return data
end

-- 播动画时,服务消息就过来了,此时客户端不能显示
function RecordCtr:BlockLasetItemData( data )
    if self.view.isPastLottery then
        table.remove(data.arrLotteryInfo,1)
    elseif self.view.isNumView or self.view.isPurchaseRecord then
        if data.arrLotteryInfo[1].szIssue == self.view.mainView.szIssue then
            data.arrLotteryInfo[1].nLotteryState = 0
        end
    end
end

--获取命中颜色
function RecordCtr:GetHitNumStr(lotteryNum,hitFlag,colorStr)
    local tempStr = ""
    local tempChar = ""
    if hitFlag and #hitFlag > 0 then
        for i,v in ipairs(hitFlag) do
            tempChar = string.sub(lotteryNum,i,i)
            if v == 1 then
                tempChar = string.format ("<color=#%s>%s</color>" ,colorStr,tempChar)
            end
            tempStr = tempStr .. tempChar
        end
    else
        tempStr = lotteryNum
    end
    return tempStr
end

_InitVar = function(self, view, param)
    self.view = view
end

_FindIssue = function(key , tlist )
    -- local low = 1
    -- local high = #tlist
    -- local mid
    -- while low < high do
    --     mid = (low + high)%2
    --     if tlist[mid].szIssue == key then
    --         return mid
    --     elseif tlist[mid].szIssue > key then
    --         high = mid -1
    --     else
    --         low = mid + 1
    --     end
    -- end
    local list = tlist
    local index = nil
    for i, v in ipairs(list) do
        if v.szIssue == key then
            index = i
            break
        end
    end
    return index

end

_FindLotteryNumber = function(key , tlist )
    local list = tlist
    local index = nil
    for i, v in ipairs(list) do
        if v.szLotteryNumber == key then
            index = i
            break
        end
    end
    return index
end

return RecordCtr