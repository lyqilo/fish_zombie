local CC = require("CC")
local uu = CC.uu
local Request = CC.Request
local MOLTHPlugin = {}

MOLTHPlugin.ErrorCode = {
	SUCCESS = 0,
	CANCEL = 1,
	FAIL = 2
}

local payDomain = "https://sea-api.gold.razer.com"
local sandboxPayDomain = "https://sea-api.gold-sandbox.razer.com"
local paymentUrl_webapi = "/ewallet/pay" --沙盒环境下跳转支付页面后，填写符合位数的手机号码，OTP填111111
local ibankPaymentUrl_webapi = "/ibanking/pay"
local paymentPSMSUrl_webapi = "/sms/pay"
local paymentDCBUrl_webapi = "/dcb/pay"
local merchantServiceID = "8080"
local sandboxServiceID = "8081"
local merchantServiceIDS2S = "8082"
local secretKey = "188f22f60d31d0654e707e3d335ea623"
local CHANNEL = {
	CHANNEL_12CALL = "12call",
	CHANNEL_TUREMONEY = "truemoney",
	CHANNEL_MOLPOINTS = "molpoints",
	CHANNEL_MPAY = "mpay",
	CHANNEL_LINEPAY = "linepay",
	CHANNEL_TRUEWALLET = "truewallet_deeplink",
	CHANNEL_BAY = "bay",
	CHANNEL_BBL = "bbl",
	CHANNEL_KTB = "ktb",
	CHANNEL_SCB = "scb",
	CHANNEL_KBANK = "kbank",
	CHANNEL_PSMS = "psms",
	CHANNEL_DCB = "dcb",
	CHANNEL_PROMPTPAY = "promptpay"
}
local SANDBOXCHANNEL = {
	[CHANNEL.CHANNEL_SCB] = true,
	[CHANNEL.CHANNEL_KTB] = true,
	[CHANNEL.CHANNEL_BBL] = true,
	[CHANNEL.CHANNEL_BAY] = true,
	[CHANNEL.CHANNEL_PSMS] = true,
	[CHANNEL.CHANNEL_MPAY] = true,
	[CHANNEL.CHANNEL_LINEPAY] = true,
	[CHANNEL.CHANNEL_TRUEWALLET] = true
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
------------点卡充值参数说明
--@pin		Pin card number(optional on 12call card)
--@serial	Serial of card(use only MOLPoints card)
--@card_no	Card number(use only 12call card)
--@cb
---------------------------------------------
local PayByCashCard = function(param)
	Request(
		"MolCashCardPurchase",
		param,
		function(errCode, result)
			log("PayByCashCard success. channel=" .. param.channel)
			if param.callback then
				param.callback(errCode, result)
			end
		end,
		function(errCode, result)
			logError("PayByCashCard Fail. channel=" .. param.channel .. ",errCode=" .. errCode)
			if param.callback then
				param.callback(errCode, result)
			end
		end
	)
end
function MOLTHPlugin.PayBy12call(param)
	param.channel = CHANNEL.CHANNEL_12CALL
	PayByCashCard(param)
end

function MOLTHPlugin.PayByTruemoney(param)
	param.channel = CHANNEL.CHANNEL_TUREMONEY
	PayByCashCard(param)
end

function MOLTHPlugin.PayByMolPoint(param)
	param.channel = CHANNEL.CHANNEL_MOLPOINTS
	PayByCashCard(param)
end

--[[
shortcode	price
4210501		10 THB
4210502		20 THB
4210503		30 THB
4210505		50 THB
4210506		60 THB
4210508		90 THB
4210510		100 THB
4210515		150 THB
4210520		200 THB
4210530		300 THB
4210550		500 THB
]]
function MOLTHPlugin.PayBySMSOld(param)
	local productId = tostring(param.wareId)
	local uid = param.playerId
	local price = param.shortcode
	local cb = param.callback
	local autoExchange = param.autoExchange
	local extraData = param.extraData
	GetOrder(
		productId,
		function(orderid)
			if orderid ~= "" then
				PayManagement.SetPayCallback(
					function(responseMsg)
						--responseMsg={type,result,phoneNumber}
						responseMsg = Json.decode(responseMsg)
						if responseMsg.type == "SendSMS" then
							--发送短信状态
							if responseMsg.result == -1 then
								log("短信发送成功:" .. responseMsg.phoneNumber)
							else
								log("短信发送失败:" .. responseMsg.phoneNumber .. " errorCode:" .. responseMsg.result)
								if cb then
									cb(MOLTHPlugin.ErrorCode.FAIL)
								end
							end
						elseif responseMsg.type == "OnSendSMS" then
							--对方已经收到短信
							log("对方已经收到短信:" .. responseMsg.phoneNumber)
							if cb then
								cb(MOLTHPlugin.ErrorCode.SUCCESS)
							end
						end
					end
				)
				if type(param.shortcode) ~= "string" then
					param.shortcode = tostring(param.shortcode)
				end
				local content = merchantServiceIDS2S .. " " .. orderid
				Client.SendSMS(param.shortcode, content)
			else
				cb(MOLTHPlugin.ErrorCode.FAIL)
			end
		end,
		autoExchange,
		extraData
	)
end

---------------------------------------------
------------电子钱包充值参数说明
--!!!NOTE	参数全部都是字符串，参数全部都是字符串，参数全部都是字符串，
--@orderid	不能有连续2个或以上空格
--@productName  不能有连续2个或以上空格
--@uid			User account of service
--@price		10THB
--@sid
--@channel
--@cb
---------------------------------------------
local PayByEWallet = function(param)
	local productId = tostring(param.wareId)
	local productName = param.productName
	local price = param.price
	local sid = param.sid
	local uid = param.playerId
	local channel = param.channel
	local cb = param.callback
	local webApi = param.webApi
	local autoExchange = param.autoExchange
	local extraData = param.extraData
	local operator = param.operator or ""
	local payUrl = payDomain .. webApi
	--Debug模式测试服 沙盒测试环境可用测试支付
	if CC.DebugDefine.GetDebugMode() and CC.DebugDefine.GetEnvState() == CC.DebugDefine.EnvState.Test then
		if SANDBOXCHANNEL[channel] then
			payUrl = sandboxPayDomain .. webApi
			sid = sandboxServiceID
		end
	end

	GetOrder(
		productId,
		function(orderid)
			if orderid ~= "" then
				--按字母排序拼接
				price = "" .. price .. "THB"
				local sig = Util.Md5(channel .. productName .. operator .. orderid .. price .. sid .. uid .. secretKey)
				local httpUrl =
					payUrl ..
					"?channel=" ..
						channel ..
							"&for=" ..
								productName ..
									"&operator=" ..
										operator .. "&price=" .. price .. "&sid=" .. sid .. "&orderid=" .. orderid .. "&uid=" .. uid .. "&sig=" .. sig
				if operator == "" then
					httpUrl = string.gsub(httpUrl, "operator=&", "")
				end
				log("PayByEWallet Url:" .. httpUrl)
				cb(httpUrl)
			else
				logError("PayByEWallet CreateOrder fail")
				cb("")
			end
		end,
		autoExchange,
		extraData
	)
end
function MOLTHPlugin.PayByMpay(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_MPAY
	param.webApi = paymentUrl_webapi
	return PayByEWallet(param)
end

function MOLTHPlugin.PayByLinepay(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_LINEPAY
	param.webApi = paymentUrl_webapi
	return PayByEWallet(param)
end

function MOLTHPlugin.PayByTruewallet(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_TRUEWALLET
	param.webApi = paymentUrl_webapi
	return PayByEWallet(param)
end

function MOLTHPlugin.PayByBay(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_BAY
	param.webApi = ibankPaymentUrl_webapi
	return PayByEWallet(param)
end

function MOLTHPlugin.PayByBbl(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_BBL
	param.webApi = ibankPaymentUrl_webapi
	return PayByEWallet(param)
end

function MOLTHPlugin.PayByKtb(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_KTB
	param.webApi = ibankPaymentUrl_webapi
	return PayByEWallet(param)
end

function MOLTHPlugin.PayByScb(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_SCB
	param.webApi = ibankPaymentUrl_webapi
	return PayByEWallet(param)
end

function MOLTHPlugin.PayByKbank(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_KBANK
	param.webApi = ibankPaymentUrl_webapi
	return PayByEWallet(param)
end

function MOLTHPlugin.PayByPromptpay(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_PROMPTPAY
	param.webApi = ibankPaymentUrl_webapi
	return PayByEWallet(param)
end

function MOLTHPlugin.PayBySMS(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_PSMS
	param.webApi = paymentPSMSUrl_webapi
	return PayByEWallet(param)
end

function MOLTHPlugin.PayByDcb(param)
	param.sid = merchantServiceID
	param.channel = CHANNEL.CHANNEL_DCB
	param.webApi = paymentDCBUrl_webapi
	param.operator = "DTAC-DCB"
	return PayByEWallet(param)
end
-- local ClientTestCashCard = function(wareId,channel,pin,serial,card_no)
-- 	local orderid = "firerocktest0001"
-- 	local sid = 3604
-- 	local uid = "112"
-- 	local sig = Util.Md5(card_no..channel..orderid..pin..serial..sid..uid..secretKey)
-- 	local httpUrl = "https://sea-s2s.molthailand.com/cashcard"
-- 				.."?orderid="..orderid
-- 				.."&sid="..sid
-- 				.."&uid="..uid
-- 				.."&channel="..channel
-- 				.."&pin="..pin
-- 				.."&serial="..serial
-- 				.."&card_no="..card_no
-- 				.."&sig="..sig
-- 	log("PayByCashCard Url:"..httpUrl)
-- end

-- function MOLTHPlugin.TestPayBy12call(productId,card_no,cb)
-- 	ClientTestCashCard(productId,CHANNEL.CHANNEL_12CALL,"","",card_no,cb)
-- end

-- function MOLTHPlugin.TestPayByTruemoney(productId,pin,cb)
-- 	ClientTestCashCard(productId,CHANNEL.CHANNEL_TUREMONEY,pin,"","",cb)
-- end

-- function MOLTHPlugin.TestPayByMolPoint(productId,pin,serial,cb)
-- 	ClientTestCashCard(productId,CHANNEL.CHANNEL_MOLPOINTS,pin,serial,"",cb)
-- end

return MOLTHPlugin
