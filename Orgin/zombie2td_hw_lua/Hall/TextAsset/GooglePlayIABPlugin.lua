local CC = require("CC")
local Request = CC.Request
local GooglePlayIABPlugin = {}

GooglePlayIABPlugin.BILLING_RESPONSE = {
	BILLING_RESPONSE_RESULT_OK = 0,
	BILLING_RESPONSE_RESULT_USER_CANCELED = 1,
	BILLING_RESPONSE_RESULT_ITEM_UNAVAILABLE = 4,
	BILLING_RESPONSE_RESULT_DEVELOPER_ERROR = 5,
	BILLING_RESPONSE_RESULT_ERROR = 6, --购买失败
	BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED = 7, --购买失败
	BILLING_RESPONSE_RESULT_ITEM_NOT_OWNED = 8
}

local IABHELPER_USER_CANCELLED = -1005
local verifyQueue = List:new()
local isTimerRunning = false
local lastReqTime = 0

local CreateCallBack = function(_type, errCallBack)
	return function(responseMsg)
		responseMsg = Json.decode(responseMsg)
		CC.uu.Log(responseMsg, "谷歌充值回调日志 responseMsg: ", 1)
		local response = responseMsg.response
		log("GooglePay responeType:" .. tostring(responseMsg.type) .. "   GooglePay respone:" .. tostring(response))
		if responseMsg.type == "GooglePlay_Pay" and _type == responseMsg.type then
			if CC.DebugDefine.DebugInfo.googleiap == 1 then
				if response == GooglePlayIABPlugin.BILLING_RESPONSE.BILLING_RESPONSE_RESULT_OK then
					local sku = responseMsg.sku

					local data = {}
					data.Order = responseMsg.developerPayload
					data.Sign = responseMsg.signature
					data.Data = responseMsg.data
					data.PackageName = AppInfo.PackageName

					local jsonData = Json.decode(responseMsg.data)
					local buglylog =
						"PlayerId:" ..
						CC.Player.Inst():GetSelfInfoByKey("Id") ..
							", OrderId:" ..
								data.Order .. ", GoogleOrderId:" .. jsonData.orderId .. ", purchaseState:" .. jsonData.purchaseState

					local reqVerify = function(param)
						lastReqTime = os.time()
						Request(
							"ReqGetGooglePurchaseVerify",
							param.data,
							function(err, result)
								log("ReqGetGooglePurchaseVerify Success")
								BuglyUtil.ReportException("GooglePay", buglylog .. ", RspCode:" .. err, debug.traceback())
								--订单校验成功，先消耗商品
								GooglePlayIABPlugin.Consume(param.sku)
								if errCallBack then
									errCallBack(0, 0)
								end
							end,
							function(err, result)
								log("ReqGetGooglePurchaseVerify Error:" .. err)
								BuglyUtil.ReportException("GooglePay", buglylog .. ", RspCode:" .. err, debug.traceback())
								if
									err == CC.shared_en_pb.OrderAlreadyHandled or err == CC.shared_en_pb.OrderNotExist or
										err == CC.shared_en_pb.KeyNotExist
								 then
									GooglePlayIABPlugin.Consume(param.sku)
								else
									if errCallBack then
										errCallBack(response, err)
									end
								end
							end
						)
					end
					--增加队列，防止请求频繁（318）
					if os.time() - lastReqTime > 1 then
						reqVerify({data = data, sku = sku})
					else
						verifyQueue:push({data = data, sku = sku})
						if not isTimerRunning then
							isTimerRunning = true
							local timer
							timer =
								CC.uu.StartTimer(
								2,
								function()
									local param = verifyQueue:pop()
									reqVerify(param)
									if verifyQueue.length == 0 then
										isTimerRunning = false
										CC.uu.StopTimer(timer)
									end
								end,
								-1
							)
						end
					end

					BuglyUtil.ReportException("GooglePay", buglylog, debug.traceback())
				else
					log(string.format("GooglePlay Pay response=%d,orderId=%s", responseMsg.response, responseMsg.developerPayload))
					if
						response == GooglePlayIABPlugin.BILLING_RESPONSE.BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED or
							response == IABHELPER_USER_CANCELLED
					 then
						GooglePlayIABPlugin.QueryInventory()
					end

					if errCallBack then
						errCallBack(response)
					end
				end
			else
				GooglePlayIABPlugin.Consume(responseMsg.sku)
			end
		elseif responseMsg.type == "GooglePlay_Consume" and _type == responseMsg.type then
			if response == GooglePlayIABPlugin.BILLING_RESPONSE.BILLING_RESPONSE_RESULT_OK then
				--商品消耗成功，通知服务器
				log("GooglePay Consume success")
				local data = {}
				data.Order = responseMsg.developerPayload
				data.Sign = responseMsg.signature
				data.Data = responseMsg.data
				data.PackageName = AppInfo.PackageName

				Request(
					"ReqGoolePurchaseSendReward",
					data,
					function(err, result)
						log("ReqGoolePurchaseSendReward success")
					end,
					function(err, result)
						log("ReqGoolePurchaseSendReward Error:" .. err)
					end
				)
			else
				log("GooglePlay consume response=" .. response)
			end
		else
			logError("_type:" .. _type .. "  responeType:" .. tostring(responseMsg.type))
		end
	end
end

function GooglePlayIABPlugin.QueryInventory()
	local skuList = {}
	local hasProduct = {}
	for i, product in pairs(CC.ConfigCenter.Inst():getConfigDataByKey("Ware")) do
		if product.SubChannel == "GooglePay" then
			if not hasProduct[product.ProductId] then
				hasProduct[product.ProductId] = true
				table.insert(skuList, product.ProductId)
			end
		end
	end

	PayManagement.SetPayCallback(
		CreateCallBack(
			"GooglePlay_Pay",
			function()
			end
		)
	)
	skuList = Json.encode(skuList)
	GooglePlayUtil.RequestQuery(skuList)
end

function GooglePlayIABPlugin.Pay(wareId, extraData, autoExchange, errCallBack, exchangeWareId)
	local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	local wareData = wareCfg[wareId]
	if not wareData then
		log("GooglePlayIABPlugin: no wareData by Id:" .. tostring(wareId))
		return
	end

	local data = {}
	data.wareId = wareId
	data.extraData = extraData
	data.autoExchange = autoExchange
	data.ExchangeWareId = exchangeWareId
	data.succCb = function(err, result)
		PayManagement.SetPayCallback(CreateCallBack("GooglePlay_Pay", errCallBack))
		GooglePlayUtil.RequestPay(result.Order, wareData.ProductId)
	end
	data.errCb = function(err, result)
		log("GetOrder errorCode:" .. err)
		if errCallBack then
			errCallBack(0, err)
		end
	end
	CC.PaymentManager.RequestOrder(data)
end

function GooglePlayIABPlugin.Consume(sku)
	PayManagement.SetConsumeCallback(CreateCallBack("GooglePlay_Consume"))
	GooglePlayUtil.RequestConsume(sku)
end

function GooglePlayIABPlugin.DealWithNotConsumedOrders(list)
	PayManagement.SetConsumeCallback(CreateCallBack("GooglePlay_Consume"))
	for _, v in ipairs(list) do
		log("not finished productId:" .. v)
		GooglePlayUtil.RequestConsume(v)
	end
end

return GooglePlayIABPlugin
