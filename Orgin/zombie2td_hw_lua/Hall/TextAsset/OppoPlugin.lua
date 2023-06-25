local CC = require("CC")
local OppoPlugin = {}

local PayResultCode = {
	CODE_SUCCESS = 1001,
	ERROR_ORDERID_REPEAT = 1002,
	ERROR_OVER_MAX_LIMIT = 1003,
	CODE_CANCEL = 1004,
	CODE_RESULT_UNKNOWN = 1005,
	ERROR_NO_NEW_VERSION = 1007,
	ERROR_PAY_FAILED_OTHER = 1010,
	ERROR_IN_PROGRESS = 1012,
	ERROR_PAY_FAIL = 1100,
	ERROR_SINAGURE_ERROR = 1200,
	ERROR_ABSENCE_PARAM = 1201,
	ERROR_AMOUNT_ERROR = 5000,
	ERROR_SYSTEM_ERROR = 5001,
	ERROR_BALANCE_NOT_ENOUGH = 5002,
	ERROR_PARAM_INVALID = 5003,
	ERROR_USER_NOT_EXISTS = 5004,
	ERROR_AUTH_FAILED = 5005,
	ERROR_MERCHANT_ORDERID_REPEAT = 5006,
	ERROR_PAY_FAILED = 5555,
	ERROR_QUERY_BALANCE_SUCCESS = 30000,
	ERROR_QUERY_BALANCE_FAILED = 30001,
	ERROR_QUERY_BALANCE_UNKNOWN = 30002,
	ERROR_DIRECTPAY_SUCCESS = 40000,
	ERROR_DIRECTPAY_FAILED = 40001,
	ERROR_DIRECTPAY_UNKNOWN = 40002,
	ERROR_DIRECTPAY_FAILED_UNSAFE = 40003,
	ERROR_QUERY_ORDER_SUCCESS = 50000,
	ERROR_QUERY_ORDER_FAILED = 50001,
	ERROR_QUERY_ORDER_UNKNOWN = 50002
}

local LoginResultCode = {
	CODE_SUCCESS = 0,
	CODE_LOGIN_FAIL = 1,
	CODE_GETTOKEN_FAIL = 2
}

function OppoPlugin.Init()
	if not CC.ChannelMgr.CheckOppoChannel() then
		return
	end

	OppoUtil.Init()
end

function OppoPlugin.Login(succCb, errCb)
	if not CC.ChannelMgr.CheckOppoChannel() then
		return
	end
	OppoUtil.Login(
		function(result)
			CC.uu.Log(result)
			local result = Json.decode(result)
			if result.resultCode == LoginResultCode.CODE_SUCCESS then
				if succCb then
					succCb(result)
				end
			else
				if errCb then
					errCb()
				end
			end
		end
	)
end

function OppoPlugin.Pay(wareId, autoExchange, errCallback, exchangeWareId)
	if not CC.ChannelMgr.CheckOppoChannel() then
		return
	end
	local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	local wareData = wareCfg[wareId]

	local data = {}
	data.wareId = wareId
	data.autoExchange = autoExchange
	data.ExchangeWareId = exchangeWareId
	data.succCb = function(err, result)
		local param = {
			orderId = result.Order,
			amount = wareData.Price,
			productName = "Diamond",
			productDesc = "ซื้อรายการจะได้รับเพชร เพชรสามารถนำไปแลกอุปกรณ์ได้",
			callbackUrl = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetOppoPayCallbackUrl()
		}
		OppoUtil.Pay(
			Json.encode(param),
			function(result)
				CC.uu.Log(result)
				local result = Json.decode(result)
				if result.resultCode == PayResultCode.CODE_SUCCESS then
					CC.uu.Log("pay Success")
				else
					CC.uu.Log("pay failed")
					if errCallback then
						errCallback()
					end
				end
			end
		)
	end
	data.errCb = function(err, result)
		CC.uu.Log(err, "GetOrder errorCode:")
		if errCallback then
			errCallback()
		end
	end
	CC.PaymentManager.RequestOrder(data)
end

return OppoPlugin
