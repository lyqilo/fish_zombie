local CC = require("CC")
local uu = CC.uu
local Request = CC.Request
local GuPayPlugin = {}

GuPayPlugin.ErrorCode = {
	SUCCESS = 0,
	CANCEL = 1,
	FAIL = 2
}

local payDomain = "https://api.gupay.co/v1/charges"
local sandboxPayDomain = "https://sandbox.gupay.co/v1/charges"
local merchantServiceID = "1002"
local secretKey =
	"sk_QlDIIzBUZ5Y2MIYAYApAitd3a4HnQCJOVYwjjPekP32X54UNYOVNQcXfILcV44Y4PFPjgR5VZUSTkMKdeJqYDljyx25IeuE36BnI12"
local sandboxSecretKey =
	"sk_test_QlDIIzBUZ5Y2MIYAYApAitd3a4HnQCJOVYwjjPekP32X54UNYOVNQcXfILcV44Y4PFPjgR5VZUSTkMKdeJqYDljyx25IeuE36BnI12"
local returnUrl = "huoysgamethailand://royalcasino"
local returnUrlIos = "com.huoys.royalcasinoonline://"
local CHANNEL = {
	CHANNEL_GuPayKBank = "kbank",
	CHANNEL_GuPayKtb = "ktb",
	CHANNEL_GuPayBay = "bay",
}

local GetOrder = function(wareId, cb, autoExchange, extraData, exchangeWareId)
	if not cb then
		return
	end
	local data = {}
	data.wareId = wareId
	data.autoExchange = autoExchange
	data.extraData = extraData
	data.ExchangeWareId = exchangeWareId
	data.succCb = function(err, result)
		cb(result.Order)
	end
	data.errCb = function(err, result)
		logError("GetOrder errorCode:" .. err)
		cb("")
	end
	CC.PaymentManager.RequestOrder(data)
end

---------------------------------------------
------------充值参数说明
--!!!NOTE	参数全部都是字符串，参数全部都是字符串，参数全部都是字符串，
--@orderid	不能有连续2个或以上空格
--@productName  不能有连续2个或以上空格
--@uid			User account of service
--@price		10THB
--@sid
--@channel
--@cb
---------------------------------------------
local PayByGuPay = function(param)
	local productId = tostring(param.wareId)
	local price = param.price / 100
	local sid = param.sid
	local uid = param.playerId
	local channel = param.channel
	local autoExchange = param.autoExchange
	local extraData = param.extraData
	local payUrl = payDomain
	local secretkey = secretKey
	local returnurl = returnUrl
	if CC.DebugDefine.GetDebugMode() and CC.DebugDefine.GetEnvState() == CC.DebugDefine.EnvState.Test then
		payUrl = sandboxPayDomain
		secretkey = sandboxSecretKey
	end
	if CC.Platform.isIOS then
		returnurl = returnUrlIos
	end

	GetOrder(
		productId,
		function(orderid)
			if orderid ~= "" then
				local data = {
					type = channel,
					service_id = sid,
					amount = price,
					currency = "thb",
					description = string.format("Purchase %s thb", price),
					reference_id = orderid,
					customer_id = tostring(uid),
					flow = "redirect",
					return_url = returnurl
				}
				log(CC.uu.Dump(data, "data:"))
				CC.HttpMgr.PostJson(
					payUrl,
					data,
					function(result)
						-- Client.OpenURL(result.redirect_url)
						CC.uu.Log(result, "reportData success")
						if result.redirect_url and result.redirect_url ~= "" then
							--Client.OpenURL(result.redirect_url)
							if tonumber(AppInfo.androidVersionCode) >= 25 then
								CC.ViewManager.OpenCommonWebView({webUrl = result.redirect_url, switchApp = true})
							else
								Client.OpenURL(result.redirect_url)
							end
						end
					end,
					function()
						CC.uu.Log("reportData failed")
					end,
					nil,
					nil,
					secretkey
				)
			else
				logError("PayByGuPay CreateOrder fail")
			end
		end,
		autoExchange,
		extraData
	)
end

function GuPayPlugin.PayByKBank(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_GuPayKBank
	return PayByGuPay(param)
end

function GuPayPlugin.PayByKtb(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_GuPayKtb
	return PayByGuPay(param)
end

function GuPayPlugin.PayByBay(param)
	param.sid = merchantServiceID;
	param.channel = CHANNEL.CHANNEL_GuPayBay;
	return PayByGuPay(param)
end

return GuPayPlugin
