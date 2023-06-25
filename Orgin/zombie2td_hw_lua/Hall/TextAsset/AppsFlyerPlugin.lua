local CC = require("CC")

local AppsFlyerPlugin = {}
--[[
!NOTE:AppsFlyer所有的预设参数库除了在追踪收益时必须使用af_revenue, 其他都是可选，而且可以自定义。
]]
local TrackRichEvent = function(eventName, eventValues)
	eventValues = Json.encode(eventValues)
	AppsFlyerUtil.TrackRichEvent(eventName, eventValues)
end

--[[
追踪购买
currency:货币符号。USD,THB,CNY等。具体可以看这里https://www.xe.com/iso4217.php
revenue:金额数量。对应currency，
quantity:多少次。
比如currency是USD，revenue是0.99，quantity是2。就表示0.99*2美金
]]
function AppsFlyerPlugin.TrackInAppPurchase(revenue, quantity, channel)
	local eventValues = {}
	eventValues[CC.AFInAppEvents.CURRENCY] = CC.CurrencyDefine.CurrencyCode
	eventValues[CC.AFInAppEvents.REVENUE] = tostring(revenue)
	eventValues[CC.AFInAppEvents.QUANTITY] = tostring(quantity) or "1"
	eventValues[CC.AFInAppEvents.CHANNEL] = tostring(channel)

	local eventName = CC.AFInAppEvents.PURCHASE

	TrackRichEvent(eventName, eventValues)
end

--[[
追踪注册
]]
function AppsFlyerPlugin.TrackRregister(regType)
	local eventValues = {}
	eventValues[CC.AFInAppEvents.REGISTER_TYPE] = regType

	local eventName = CC.AFInAppEvents.COMPLETE_REGISTRATION

	TrackRichEvent(eventName, eventValues)
end

--全局的货币符号，设置之后如果purchase没有传currency参数，则用全局的
--USD,THB,CNY等。具体可以看这里https://www.xe.com/iso4217.php
function AppsFlyerPlugin.SetCurrencyCode(currencyCode)
	AppsFlyerUtil.SetCurrencyCode(currencyCode)
end

--有些应用会给每个独立用户指定一个的ID(玩家ID或者登陆邮箱等)作为标识其身份唯一性的标志。
--可将此ID上报给AppsFlyer，由此账户ID便可以和其他设备ID建立映射关系
function AppsFlyerPlugin.SetCustomerUserID(customerUserID)
	AppsFlyerUtil.SetCustomerUserID(customerUserID)
end

--AppsFlyer ID是基于AppsFlyer专利技术生成的设备唯一识别符，是AppsFlyer归因和统计的重要依据
function AppsFlyerPlugin.GetAppsFlyerId()
	return AppsFlyerUtil.GetAppsFlyerId()
end

return AppsFlyerPlugin
