local CC = require("CC")

local ApplePayPlugin = {}

ApplePayPlugin.PayResponeType = {
	Success = "Success",
	Failed = "Failed"
}

function ApplePayPlugin.Login(cb)
	AppleUtil.Login(cb)
end

function ApplePayPlugin.ClearToken()
	AppleUtil.ClearAppleToken()
end

function ApplePayPlugin.Pay(wareId, extraData, autoExchange, errCallback, exchangeWareId)
	CC.uu.Log(wareId, "applePay wareId:")
	local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	local wareData = wareCfg[wareId]

	local data = {}
	data.wareId = wareId
	data.extraData = extraData
	data.autoExchange = autoExchange
	data.ExchangeWareId = exchangeWareId
	data.succCb = function(err, result)
		-- 设置服务器下发的订单id
		CC.uu.Log(result.Order, "applePay orderId:")

		AppleUtil.PlayerBuyProduct(wareData.ProductId, result.Order)
		CC.ViewManager.ShowConnecting()
		PayManagement.SetIosPayCallback(
			function(responseMsg, responseType)
				if responseType == ApplePayPlugin.PayResponeType.Success then
					ApplePayPlugin.PaySuccess(wareData.ProductId, responseMsg, errCallback)
				elseif responseType == ApplePayPlugin.PayResponeType.Failed then
					ApplePayPlugin.PayFailed(responseMsg, errCallback)
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

function ApplePayPlugin.PaySuccess(productId, orderMsg, errCallback)
	CC.ViewManager.CloseConnecting()
	local msg = Json.decode(orderMsg)
	local data = {}
	data.Order = msg.orderid
	data.Data = msg.receipt
	CC.Request(
		"IOSPurchaseVerify",
		data,
		function(err, result)
			CC.uu.Log("支付校验成功~")
			AppleUtil.PlayerResumeProduct(productId)
		end,
		function(err, result)
			CC.uu.Log(err, "IOSPurchaseVerify errorCode=")
			if
				err == CC.shared_en_pb.OrderAlreadyHandled or err == CC.shared_en_pb.OrderNotExist or
					err == CC.shared_en_pb.KeyNotExist
			 then
				AppleUtil.PlayerResumeProduct(productId)
			else
				if errCallback then
					errCallback()
				end
			end
		end
	)
end

function ApplePayPlugin.PayFailed(orderMsg, errCallback)
	CC.ViewManager.CloseConnecting()
	if errCallback then
		errCallback()
	end
end

function ApplePayPlugin.QueryInventory()
	AppleUtil.PlayerQueryInventory()
end

return ApplePayPlugin
