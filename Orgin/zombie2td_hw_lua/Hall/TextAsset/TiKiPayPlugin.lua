local CC = require("CC")
local M = {}
local payChannel = {
	tiki_truemoney = 24,
	tiki_airpay = 28,
	tiki_promptpay = 29
}

--[[
@param
wareId:商品id
subChannel:渠道id
可缺省参数:
extraData:额外数据
autoExchange:自动兑换筹码
callback:支付成功回调
errCallback:支付失败回调
]]
function M.PayEntrancePay(param)
	local data = {}
	data.wareId = param.wareId
	data.channel = payChannel[param.subChannel]
	data.extraData = param.extraData
	data.autoExchange = param.autoExchange
	data.ExchangeWareId = param.ExchangeWareId
	local succCb = function(code, result)
		CC.uu.Log(result, "TiKiPay:", 1)
		--Client.OpenURL(result.PayCode)
		local language = CC.LanguageManager.GetLanguage("L_StoreView")
		CC.ViewManager.OpenCommonWebView({webUrl = result.PayCode, title = language.webPayViewTitle})
		if param.callback then
			param.callback()
		end
	end
	local errCb = function(code, result)
		logError("TikiPay Fail")
		if param.errCallback then
			param.errCallback()
		end
	end

	CC.Request("TikipayPurchase", data, succCb, errCb)
end

return M
