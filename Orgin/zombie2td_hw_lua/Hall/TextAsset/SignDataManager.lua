-- region SignDataManager.lua
-- Date: 2019.7.13
-- Desc: 签到，宝箱的 model类
-- Author: chris

local CC = require("CC")

local SignDataManager = CC.class2("SignDataManager")

local IsSign = false
local Month = 1
local Date = {}
local RemainingTimes = {}
local Expend = 0
local AskReplenish = {}
local AskBox = {}
local DailyTab = {}
local WeekTab ={}
local BoxHalfMonthTab = {}
local BoxMonthTab = {}
local RollTab = {}
local RankTab = {}
local SignRewards = {}

--写入是否签到
function SignDataManager.SetSignState(b)
	IsSign = b
end

--读取是否签到
function SignDataManager.GetSignState()
	return IsSign
end

--写入补签查询返回
function SignDataManager.SetAskReplenish(data)
	AskReplenish = {}
	AskReplenish  = data
	SignDataManager.SetDate()
end

--获取d年份
function SignDataManager.GetYeath()
	return AskReplenish.Year
end

function SignDataManager.GetCurrenDate()
	return AskReplenish.Day
end

--获取月份
function SignDataManager.GetMonth()
	return AskReplenish.Month
end

--获取日期相应的签到状态
function SignDataManager.GetDateStatu(index)
	if not Date then
		return 1
	end
	for i,v in ipairs(Date) do
		if index == i then
			return v
		end
	end
end

--获取日期
function SignDataManager.GetDateShow(index)
	if not Date then
		return 1
	end
	for i,v in ipairs(Date) do
		if index == i then
			return i
		end
	end
end

--将服务器端发过来的日期重新放到一个tab里面
function SignDataManager.SetDate()
	Date = {}
	for i,v in ipairs(AskReplenish.Date) do
		table.insert(Date,v)
	end
end

function SignDataManager.GetDateListLen()
	return #Date
end


--获取剩余次数
function SignDataManager.GetRemainingTimes()
	return AskReplenish.RemainingTimes
end

--消耗
function SignDataManager.GetExpend()
	return AskReplenish.Expend
end

function SignDataManager.SetSignRewards(data)
	SignRewards.ConfigId = data.ConfigId
	SignRewards.Count = data.Count	
end

--奖品id
function SignDataManager.GetSignConfigId()
	if not SignRewards.ConfigId then
		return 1
	end
	return SignRewards.ConfigId
end

--奖品数量
function SignDataManager.GetSignCount()
	if not SignRewards.Count then
		return 1
	end
	return SignRewards.Count
end

--写入是否可以开宝箱
function SignDataManager.SetAskBox(data)	
	AskBox = {}

	for _,v in ipairs(data.Value) do
		local t = {}
		t.SignTimes = v.SignTimes
		t.NeedTimes = v.NeedTimes
		t.IsOpen = v.IsOpen
		t.CanOpen = v.CanOpen
		t.NextOpenTime = v.NextOpenTime
		t.BoxType = v.BoxType
		t.Content = v.Content
		t.Expire = v.Expire
		t.NextAtivityTime = v.NextAtivityTime
		table.insert(AskBox,t)
	end
end

--读取是否可以开宝箱
function SignDataManager.GetAskBox()	
	return AskBox
end

--获取宝箱数据长度
function SignDataManager.GetAskBoxLen()
	return #AskBox or 0 
end

function SignDataManager.GetExpire(index)
	if not AskBox then
		return false
	end
	for i,v in ipairs(AskBox) do

		if v.BoxType == index then
			-- logError("index = "..index.."  v.Expire = "..v.Expire)
			return v.Expire
		end
	end
end

--是否可开启
function SignDataManager.GetCanOpen(index)
	if not AskBox then
		return false
	end
	for i,v in ipairs(AskBox) do
		if v.BoxType == index then
			return v.CanOpen
		end
	end
end

--是否已开启
function SignDataManager.GetIsOpen(index)
	if not AskBox then
		return false
	end	
	for i,v in ipairs(AskBox) do
		if v.BoxType == index then
			return v.IsOpen
		end
	end
end

--需要签到次数
function SignDataManager.GetNeedTimes(index)
	if not AskBox then
		return
	end	
	for i,v in ipairs(AskBox) do
		if v.BoxType == index then
			return v.NeedTimes
		end
	end
end

--已签到次数
function SignDataManager.GetSignTimes(index)
	if not AskBox then
		return 0
	end	
	for i,v in ipairs(AskBox) do
		if v.BoxType == index then
			return v.SignTimes
		end
	end
end

--开奖时间
function SignDataManager.GetNextOpenTime(index)
	if not AskBox then
		return
	end
	for i,v in ipairs(AskBox) do
		if v.BoxType == index then
			return v.NextOpenTime
		end
	end
end

--下次活动倒计时
function SignDataManager.GetNextAtivityTime(index)
	if not AskBox then
		return false
	end
	for i,v in ipairs(AskBox) do
		if v.BoxType == index then
			return v.NextAtivityTime
		end
	end
end

--奖品ID
function SignDataManager.GetEntityId(index)
	if not AskBox then
		return
	end	
	for i,v in ipairs(AskBox) do
		if v.BoxType == index then
			return v.Content.EntityId
		end
	end
end

--奖励数量
function SignDataManager.GetEntityIdValue(index)
	if not AskBox then
		return
	end	
	for i,v in ipairs(AskBox) do
		if v.BoxType == index then
			return v.Content.Value
		end
	end
end

--修改奖品ID
function SignDataManager.SetEntityId(index,id)
	if not AskBox then
		return
	end	
	for i,v in ipairs(AskBox) do
		if v.BoxType == index then
			v.Content.EntityId = id
		end
	end
end

--修改奖品数量
function SignDataManager.SetEntityIdValue(index,Value)
	if not AskBox then
		return
	end	
	for i,v in ipairs(AskBox) do
		if v.BoxType == index then
			v.Content.Value = Value
		end
	end
end

--修改是否已经开奖
function SignDataManager.SetAskBoxIsOpen(index,b)
	if not AskBox then
		return
	end	
	for i,v in ipairs(AskBox) do
		if v.BoxType == index then
			v.IsOpen = b
		end
	end
end

--修改是否能够开奖
function SignDataManager.SetAskBoxCanOpen(index,b)
	-- logError("b = "..tostring(b))
	if not AskBox then
		return
	end	

	for i,v in ipairs(AskBox) do
		if v.BoxType == index then
			v.CanOpen = b
		end
	end
end
------------------开启次日宝箱------------------
function SignDataManager.SetDailyContent(data)
	DailyTab = {}
	DailyTab = data
end

function SignDataManager.GetDailyEntityId()
	if not DailyTab then
		return
	end	
	return DailyTab.EntityId
end

function SignDataManager.GetDailyEntityIdValue()
	if not DailyTab then
		return
	end	
	return DailyTab.Value
end

------------------开启7日宝箱------------------
function SignDataManager.SetWeekContent(data)
	WeekTab = {}
	WeekTab = data
end

function SignDataManager.GetWeekEntityId()
	if not WeekTab then
		return
	end	
	return WeekTab.EntityId
end

function SignDataManager.GetWeekEntityIdValue()
	if not WeekTab then
		return
	end	
	return WeekTab.Value
end

------------------开启15日宝箱------------------
function SignDataManager.SetBoxHalfMonthContent(data)
	BoxHalfMonthTab = {}
	BoxHalfMonthTab = data
end

function SignDataManager.GetBoxHalfMonthEntityId()
	if not BoxHalfMonthTab then
		return
	end	
	return BoxHalfMonthTab.EntityId
end

function SignDataManager.GetBoxHalfMonthTypeValue()
	if not BoxHalfMonthTab then
		return
	end	
	return BoxHalfMonthTab.Value
end
 

------------------开启30日宝箱------------------
function SignDataManager.SetBoxMonthContent(data)
	BoxMonthTab = {}
	BoxMonthTab = data
end

function SignDataManager.GetBoxMonthEntityId()
	if not BoxMonthTab then
		return
	end	
	return BoxMonthTab.EntityId
end

function SignDataManager.GetBoxMonthValue()
	if not BoxMonthTab then
		return
	end	
	return BoxMonthTab.Value
end

function SignDataManager.GetBoxValue(index)
	if index == 1 then
		return SignDataManager.GetDailyEntityIdValue()
	elseif index == 2 then
		return SignDataManager.GetWeekEntityIdValue()
	elseif index == 3 then
		return SignDataManager.GetBoxHalfMonthTypeValue()
	elseif index == 4 then
		return SignDataManager.GetBoxMonthValue()
	end
end

function SignDataManager.GetBoxType(index)
	if index == 1 then
		return SignDataManager.GetDailyEntityId()
	elseif index == 2 then
		return SignDataManager.GetWeekEntityId()
	elseif index == 3 then
		return SignDataManager.GetBoxHalfMonthEntityId()
	elseif index == 4 then
		return SignDataManager.GetBoxMonthEntityId()
	end
end



------------------滚幕------------------
function SignDataManager.SetRollData(data)
	RollTab = {}
	for _,v in ipairs(data.Value) do
		local t = {}
		t.PlayerNick = v.PlayerNick
		t.EntityId = v.EntityId
		t.Value = v.Value
		t.OpenTime = v.OpenTime
		t.PlayerId = v.PlayerId
		table.insert(RollTab,t)
	end
end

function SignDataManager.SetRollItemData(data)
	local len = SignDataManager.GetRollLen()
	-- logError("len = "..len)
	RollTab[len + 1] = {}
	RollTab[len + 1] = data
end

function SignDataManager.GetRollEntityId(i)
	if not RollTab then
		return
	end	
	return RollTab[i].EntityId
end

function SignDataManager.GetRollValue(i)
	if not RollTab then
		return
	end	
	return RollTab[i].Value
end


function SignDataManager.GetRollOpenTime(i)
	if not RollTab then
		return
	end	
	return RollTab[i].OpenTime
end


function SignDataManager.GetRollPlayerNick(i)
	if not RollTab then
		return
	end	
	return RollTab[i].PlayerNick
end



function SignDataManager.GetRollLen()
	if not RollTab then
		return
	end	
	return #RollTab or 0
end

-------------------------------排行榜--------------------

function SignDataManager.SetRankData(data)
	RankTab = {}
	RankTab = data.Value
end

function SignDataManager.GetRankEntityId(i)
	if not RankTab then
		return
	end	
	return RankTab[i].EntityId
end

function SignDataManager.GetRankValue(i)
	if not RankTab then
		return
	end	
	return RankTab[i].Value
end


function SignDataManager.GetRankOpenTime(i)
	if not RankTab then
		return
	end	
	return RankTab[i].OpenTime
end

function SignDataManager.GetRankPlayerId(i)
	if not RankTab then
		return
	end	
	return RankTab[i].PlayerId
end


function SignDataManager.GetRankPlayerNick(i)
	if not RankTab then
		return
	end	
	return RankTab[i].PlayerNick
end



function SignDataManager.GetRankLen()
	if not RankTab then
		return
	end	
	return #RankTab
end

return SignDataManager

