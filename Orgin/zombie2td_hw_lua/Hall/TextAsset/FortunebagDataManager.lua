-- region FortunebagDataManager.lua
-- Date: 2019.1.8
-- Desc: FortunebagDataManager管理类
-- Author: chris

local CC = require("CC")

local FortunebagDataManager = CC.class2("FortunebagDataManager")

local FortunebagTab = {}

--领取春节奖励信息
function FortunebagDataManager.SetFortunebagData(data)
	FortunebagTab = data
end

--获取春节奖励累计活动币
function FortunebagDataManager.GetFortunebagCurrency()
	return FortunebagTab.Currency or 0
end

--登录可以领取的活动币
function FortunebagDataManager.GetFortunebagLogin()
	return FortunebagTab.Login or  0
end

--是否已经领取
function FortunebagDataManager.GetFortunebagHasTaken()
	return FortunebagTab.HasTaken
end

--写入是否已经领取
function FortunebagDataManager.SetFortunebagHasTaken(b)
	 FortunebagTab.HasTaken = b
end

--活动累计充值
function FortunebagDataManager.GetFortunebagTotalRecharge()
	return FortunebagTab.TotalRecharge or 0
end

--已经领取的活动币
function FortunebagDataManager.GetFortunebagRechargeHasConverted()
	return FortunebagTab.RechargeHasConverted or 0
end

--设置已经领取的活动币
function FortunebagDataManager.SetFortunebagRechargeHasConverted(num)
	FortunebagTab.RechargeHasConverted = FortunebagTab.RechargeHasConverted + num
end

--可以领取的活动币
function FortunebagDataManager.GetFortunebagRechargeCanConvert()
	return FortunebagTab.RechargeCanConvert or 0
end

--领取完活动币之后，需要设置回0
function FortunebagDataManager.SetFortunebagRechargeCanConvert()
	 FortunebagTab.RechargeCanConvert = 0
end

--vip等级
function FortunebagDataManager.GetFortunebagVIP()
	return FortunebagTab.VIP or 0
end

--PlayerId
function FortunebagDataManager.GetFortunebagPlayerId()
	return FortunebagTab.PlayerId or 0
end

return FortunebagDataManager

