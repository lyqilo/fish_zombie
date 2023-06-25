-- region FundDataManager.lua
-- Date: 2018.12.10
-- Desc: FundDataManager管理类
-- Author: chris

local CC = require("CC")

local FundDataManager = CC.class2("FundDataManager")

local FundStatusTab = {}

function FundDataManager.SetFundStatus(data)
	for i,v in ipairs(data) do
		FundStatusTab[v.WareId] = v
	end
end

function FundDataManager.GetFundStatus()
	return FundStatusTab
end

function FundDataManager.GetFundItemStatus(key)
	return FundStatusTab[key]
end

function FundDataManager.SetPurchaseDays(key)
	FundStatusTab[key].Day = 0
end

function FundDataManager.GetPurchaseDays(key)
	return FundStatusTab[key].Day
end

function FundDataManager.SetDailyStatus(key,b)
	FundStatusTab[key].CanReward = b
end

function FundDataManager.SetpurchaseStatus(key,b)
	FundStatusTab[key].CanBuy = b
end

function FundDataManager.SetTotal(key,amount)
	FundStatusTab[key].TotalGain = FundStatusTab[key].TotalGain + amount
end

--获取总金额
function FundDataManager.GetTotal(key)
	return FundStatusTab[key].TotalGain
end

function FundDataManager.IsRedDot()
	for key,data in pairs(FundStatusTab) do
		if not data.CanBuy then
			if data.CanReward then
				return true
			else
				return false
			end
		end
	end
	return true
end

return FundDataManager

