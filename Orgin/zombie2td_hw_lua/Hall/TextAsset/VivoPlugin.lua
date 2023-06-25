local CC = require("CC")
local VivoPlugin = {}

local PayResultCode = {
	CODE_SUCCESS = 0,
	CODE_CANCEL = 1,
	CODE_FAILED = 2,
	CODE_EXCEPTION = 3,
	CODE_PARAMERR = 4,
	CODE_TIMEOUT = 5
}

function VivoPlugin.Pay(wareId, autoExchange, errCallback, exchangeWareId, payType)
	if not CC.ChannelMgr.CheckVivoChannel() then
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
			payType = payType,
			orderId = result.Order,
			amount = string.format("%.2f", wareData.Price / 100),
			productName = "Diamond",
			callbackUrl = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetVivoPayCallbackUrl(),
			extInfo = "vivo",
			serviceName = "",
			serviceId = "",
			roleName = CC.Player.Inst():GetSelfInfoByKey("Nick"),
			roleId = CC.Player.Inst():GetSelfInfoByKey("Id"),
			roleGrade = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
		}
		VivoUtil.Pay(
			Json.encode(param),
			function(result)
				CC.uu.Log(result)
				if tonumber(result) == PayResultCode.CODE_SUCCESS then
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

return VivoPlugin
