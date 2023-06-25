
local CC = require("CC")

local PaymentManager = {}

local define = nil;
local language = nil;

function PaymentManager.Init()

	define = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine");

	language = CC.LanguageManager.GetLanguage("L_StoreView");
end

--请求订单号
function PaymentManager.RequestOrder(param)
    CC.Request("GetOrder",{wareId = param.wareId, extraData = param.extraData, autoExchange = param.autoExchange, ExchangeWareId = param.ExchangeWareId}, function(err, result)
			param.succCb(err, result);
		end,function(err, result)
			param.errCb(err, result);
			if err == CC.shared_en_pb.PurchaseCooldingDown then
				local tips = string.format(language.payCD, CC.uu.TicketFormat(math.floor(result.RemainTime)));
				CC.ViewManager.ShowTip(tips);
			elseif err == CC.shared_en_pb.PurchaseAmountLimited then
				--超过额度
				CC.ViewManager.ShowTip(language.quota);
			end

		end);
	
end

--调起所有支付的入口
--[[
@param
wareId: 商品id
subChannel: 渠道id
price:	购买金额
playerId：玩家id
可缺省参数:
extraData:额外数据
autoExchange:自动兑换筹码
callback:支付成功回调
closeCallback:点卡输入界面主动关闭回调
errCallback:支付失败回调
]]
function PaymentManager.RequestPay(param)
	CC.uu.Log(param,"PaymentManager.RequestPay:",3)

	local subChannel = param.subChannel;

	if subChannel == define.PayChannel.Pay12call then
		PaymentManager.PayBy12call(param);
	elseif subChannel == define.PayChannel.Truemoney then
		PaymentManager.PayByTruemoney(param);
	elseif subChannel == define.PayChannel.Molpoints then
		PaymentManager.PayByMolpoints(param);
	elseif subChannel == define.PayChannel.Truewallet then
		PaymentManager.PayByTruewallet(param);
	elseif subChannel == define.PayChannel.Mpay then
		PaymentManager.PayByMpay(param);
	elseif subChannel == define.PayChannel.Linepay or subChannel == define.PayChannel.Linepay1 then
		PaymentManager.PayByLinepay(param);
	elseif subChannel == define.PayChannel.Psms then
		PaymentManager.PayByPsms(param);
	elseif subChannel == define.PayChannel.AIS then
		PaymentManager.PayByAIS(param)
	elseif subChannel == define.PayChannel.Dcb then
		PaymentManager.PayByDcb(param);
	elseif subChannel == define.PayChannel.GooglePay then
		PaymentManager.PayByGoogle(param);
	elseif subChannel == define.PayChannel.ApplePay then
		PaymentManager.PayByApple(param);
	elseif subChannel == define.PayChannel.Bay or subChannel == define.PayChannel.Bay1 then
		PaymentManager.PayByBay(param);
	elseif subChannel == define.PayChannel.GuPayBayZ or subChannel == define.PayChannel.GuPayBay then
		PaymentManager.PayByGuPayBay(param);
	elseif subChannel == define.PayChannel.Bbl then
		PaymentManager.PayByBbl(param);
	elseif subChannel == define.PayChannel.Ktb or subChannel == define.PayChannel.Ktb1 then
		PaymentManager.PayByKtb(param);
	elseif subChannel == define.PayChannel.GuPayKtbZ or subChannel == define.PayChannel.GuPayKtb then
		PaymentManager.PayByGuPayKtb(param);
	elseif subChannel == define.PayChannel.Scb or subChannel == define.PayChannel.Scb2 then
		PaymentManager.PayByScb(param);
	elseif subChannel == define.PayChannel.Kbank or subChannel == define.PayChannel.Kbank1 then
		PaymentManager.PayByKbank(param);
	elseif subChannel == define.PayChannel.GuPayKbankZ or subChannel == define.PayChannel.GuPayKbank then
		PaymentManager.PayByGuPayKBank(param);
	elseif subChannel == define.PayChannel.Promptpay then
		PaymentManager.PayByPromptpay(param)
	elseif subChannel == define.PayChannel.OppoPay then
		PaymentManager.PayByOppo(param);
	elseif subChannel == define.PayChannel.VivoPayBank then
		PaymentManager.PayByVivoBank(param);
	elseif subChannel == define.PayChannel.VivoPaySms then
		PaymentManager.PayByVivoSms(param);
	elseif subChannel == define.PayChannel.tiki_truemoney
		or subChannel == define.PayChannel.tiki_airpay
		or subChannel == define.PayChannel.tiki_promptpay then
		PaymentManager.PayByTiKiPay(param)
	end
end

function PaymentManager.PayBy12call(param)
	if param.pin then
		local data = {};
		data.wareId = param.wareId;
		data.pin = param.pin;
		data.extraData = param.extraData;
		data.autoExchange = param.autoExchange;
		data.ExchangeWareId = param.ExchangeWareId;
		data.callback = function(errCode, result)
			if errCode ~= 0 and result == "" then
				param.errCallback(errCode)
			end
		end
		CC.uu.Log(param,"PaymentManager:",3)
		CC.MOLTHPlugin.PayBy12call(data)
		return
	end

	local inputView;
	local inputCallback = function(inputData)
		local data = {};
		data.wareId = param.wareId;
		data.pin = inputData.pinCode;
		data.extraData = param.extraData;
		data.autoExchange = param.autoExchange;
		data.ExchangeWareId = param.ExchangeWareId;
		data.callback = function(errCode, result)
			if errCode ~= 0 and result == "" then
				CC.ViewManager.ShowTip(language.payFailed);
				if param.errCallback then
					param.errCallback()
				end
			else
				if inputView then
					inputView:Destroy();
				end
			end
		end
		CC.MOLTHPlugin.PayBy12call(data)
	end

	local closeCallback = function()
		if param.closeCallback then
			param.closeCallback();
		end
	end

	local data = {};
	data.inputType = define.InputBoxType.Single;
	data.title = "AIS MOL";
	data.iconImage = "input_ais12c.png";
	data.inputCallback = inputCallback;
	data.closeCallback = closeCallback;
	inputView = CC.ViewManager.Open("StoreInputBoxView",data);
end

function PaymentManager.PayByTruemoney(param)
	if param.pin then
		local data = {};
		data.wareId = param.wareId;
		data.pin = param.pin;
		data.extraData = param.extraData;
		data.autoExchange = param.autoExchange;
		data.ExchangeWareId = param.ExchangeWareId;
		data.callback = function(errCode, result)
			if errCode ~= 0 and result == "" then
				param.errCallback(errCode)
			end
		end
		CC.MOLTHPlugin.PayByTruemoney(data)
		return
	end

	local inputView;
	local inputCallback = function(inputData)
		local data = {};
		data.wareId = param.wareId;
		data.pin = inputData.pinCode;
		data.extraData = param.extraData;
		data.autoExchange = param.autoExchange;
		data.ExchangeWareId = param.ExchangeWareId;
		data.callback = function(errCode, result)
			if errCode ~= 0 and result == "" then
				CC.ViewManager.ShowTip(language.payFailed);
			else
				if inputView then
					inputView:Destroy();
				end
			end
		end
		CC.MOLTHPlugin.PayByTruemoney(data)
	end

	local closeCallback = function()
		if param.closeCallback then
			param.closeCallback();
		end
	end

	local data = {};
	data.inputType = define.InputBoxType.Single;
	data.title = "ture money MOL";
	data.iconImage = "input_truemoney.png";
	data.inputCallback = inputCallback;
	data.closeCallback = closeCallback;
	inputView = CC.ViewManager.Open("StoreInputBoxView",data);
end

function PaymentManager.PayByMolpoints(param)
	if param.pin then
		local data = {};
		data.wareId = param.wareId;
		data.pin = param.pin;
		data.serial = param.serial;
		data.extraData = param.extraData;
		data.autoExchange = param.autoExchange;
		data.ExchangeWareId = param.ExchangeWareId;
		data.callback = function(errCode, result)
			if errCode ~= 0 and result == "" then
				param.errCallback(errCode)
			end
		end
		CC.MOLTHPlugin.PayByMolPoint(data)
		return
	end

	local inputView;
	local inputCallback = function(inputData)
		local data = {};
		data.wareId = param.wareId;
		data.pin = inputData.pinCode;
		data.serial = inputData.serialCode;
		data.extraData = param.extraData;
		data.autoExchange = param.autoExchange;
		data.ExchangeWareId = param.ExchangeWareId;
		data.callback = function(errCode, result)
			if errCode ~= 0 and result == "" then
				CC.ViewManager.ShowTip(language.payFailed);
			else
				if inputView then
					inputView:Destroy();
				end
			end
		end
		CC.MOLTHPlugin.PayByMolPoint(data)
	end

	local closeCallback = function()
		if param.closeCallback then
			param.closeCallback();
		end
	end

	local data = {};
	data.inputType = define.InputBoxType.Double;
	data.title = "RAZER GOLD";
	data.iconImage = "input_zgold.png";
	data.inputCallback = inputCallback;
	data.closeCallback = closeCallback;
	inputView = CC.ViewManager.Open("StoreInputBoxView",data);

end

function PaymentManager.PayByTruewallet(param)
	
	local data = PaymentManager.GetMolWebPayData(param);
	CC.MOLTHPlugin.PayByTruewallet(data);
end

function PaymentManager.PayByMpay(param)
	
	local data = PaymentManager.GetMolWebPayData(param);
	CC.MOLTHPlugin.PayByMpay(data);
end

function PaymentManager.PayByLinepay(param)
	
	local data = PaymentManager.GetMolWebPayData(param);
	CC.MOLTHPlugin.PayByLinepay(data);
end

function PaymentManager.PayByBay(param)
	
	local data = PaymentManager.GetMolWebPayData(param);
	CC.MOLTHPlugin.PayByBay(data);
end

function PaymentManager.PayByBbl(param)
	
	local data = PaymentManager.GetMolWebPayData(param);
	CC.MOLTHPlugin.PayByBbl(data);
end

function PaymentManager.PayByKtb(param)
	
	local data = PaymentManager.GetMolWebPayData(param);
	CC.MOLTHPlugin.PayByKtb(data);
end

function PaymentManager.PayByScb(param)
	
	local data = PaymentManager.GetMolWebPayData(param);
	CC.MOLTHPlugin.PayByScb(data);
end

function PaymentManager.PayByKbank(param)
	
	local data = PaymentManager.GetMolWebPayData(param);
	CC.MOLTHPlugin.PayByKbank(data);
end

function PaymentManager.PayByPsms(param)
	
	local data = PaymentManager.GetMolWebPayData(param);
	data.operator = "TRUEMOVEH"
	CC.MOLTHPlugin.PayBySMS(data);
end

function PaymentManager.PayByAIS(param)
	local data = PaymentManager.GetMolWebPayData(param);
	data.operator = "AIS"
	CC.MOLTHPlugin.PayBySMS(data);
end

function PaymentManager.PayByPromptpay(param)
	
	local data = PaymentManager.GetMolWebPayData(param);
	CC.MOLTHPlugin.PayByPromptpay(data);
end

function PaymentManager.PayByDcb(param)

	local data = PaymentManager.GetMolWebPayData(param);
	data.operator = "DTAC"
	-- CC.MOLTHPlugin.PayByDcb(data);
	CC.MOLTHPlugin.PayBySMS(data);
end

function PaymentManager.GetMolWebPayData(param)
	local callback = function(url)
		if url ~= "" then
			if tonumber(AppInfo.androidVersionCode) < 25 then
				if param.subChannel == define.PayChannel.Linepay
				or param.subChannel == define.PayChannel.Linepay1
				or param.subChannel == define.PayChannel.Scb 
				or param.subChannel == define.PayChannel.Scb2 
				or param.subChannel == define.PayChannel.Truewallet 
				or param.subChannel == define.PayChannel.Ktb 
				or param.subChannel == define.PayChannel.Ktb1 then
					
					Client.OpenURL(url)
				else
					CC.ViewManager.OpenCommonWebView({webUrl = url, title = language.webPayViewTitle})
				end			
			else
				--linepay支付渠道特殊，返回游戏后会有后续支付流程，所以linepay充值返回游戏不主动关闭webView界面
				local switchApp = param.subChannel == define.PayChannel.Scb 
				or param.subChannel == define.PayChannel.Scb2 
				or param.subChannel == define.PayChannel.Truewallet 
				or param.subChannel == define.PayChannel.Ktb 
				or param.subChannel == define.PayChannel.Ktb1
				CC.ViewManager.OpenCommonWebView({webUrl = url, title = language.webPayViewTitle, switchApp = switchApp})
			end
		else
			--提示失败
			CC.ViewManager.ShowTip(language.payFailed);
		end
	end
	local data = {};
	data.wareId = param.wareId;
	data.productName = param.subChannel;
	data.price = param.price/100;
	data.playerId = param.playerId;
	data.callback = callback;
	data.extraData = param.extraData;
	data.autoExchange = param.autoExchange;
	return data;
end

function PaymentManager.PayByPsmsOld(param)

	local callBack = function()
		local thb = "THB"..param.price/100;
		local shortcode = define.ShortcodeRely[thb];
		local data = {}
		data.wareId = param.wareId;
		data.playerId = param.playerId;
		data.shortcode = shortcode;
		data.ExchangeWareId = param.ExchangeWareId;
		data.callback = function(errCode)
			if errCode == CC.MOLTHPlugin.ErrorCode.SUCCESS then
				--发送短信成功，这里可以给相应提示
				CC.ViewManager.ShowTip(language.paySMSSuccess)
			elseif errCode == CC.MOLTHPlugin.ErrorCode.FAIL then
				--购买失败，相应提示
				CC.ViewManager.ShowTip(language.payFailed)
			end
		end

		CC.MOLTHPlugin.PayBySMSOld(data);
	end
	CC.ViewManager.ShowMessageBox(language.paySMSTips, callBack);
end

function PaymentManager.PayByGoogle(param)

	CC.ViewManager.ShowConnecting();
	local callback = function(clientErr, serverErr)
		if clientErr ~= 0 then
			if clientErr == CC.GooglePlayIABPlugin.BILLING_RESPONSE.BILLING_RESPONSE_RESULT_ERROR
				or clientErr == CC.GooglePlayIABPlugin.BILLING_RESPONSE.BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED then
				CC.ViewManager.ShowTip(language.payFailed);
			end

			if param.errCallback then
				param.errCallback()
			end
		else
			if serverErr ~= 0 then
				if serverErr == CC.shared_en_pb.OpsLocked then
					CC.ViewManager.ShowTip(language.opsLock);
				else
					CC.ViewManager.ShowTip(language.payFailed);
				end
				if param.errCallback then
					param.errCallback(serverErr)
				end
			end

			-- --根据serverErr提示错误
			-- if serverErr == CC.shared_en_pb.GooglePurchasePlayerIdMismatch then
			-- 	CC.ViewManager.ShowTip("")
			-- elseif serverErr == CC.shared_en_pb.GooglePurchaseSignMismatch then
			-- 	CC.ViewManager.ShowTip("")
			-- elseif serverErr == CC.shared_en_pb.GooglePurchaseWareIdMismatch then
			-- 	CC.ViewManager.ShowTip("")
			-- elseif serverErr == CC.shared_en_pb.InvalidGooglePurchaseData then
			-- 	CC.ViewManager.ShowTip("")
			-- end
		end
		CC.ViewManager.CloseConnecting();
	end
	CC.GooglePlayIABPlugin.Pay(param.wareId, param.extraData, param.autoExchange, callback, param.ExchangeWareId);
end

function PaymentManager.PayByApple(param)
	local errCb = function(err)
		if err == CC.shared_en_pb.OpsLocked then
			CC.ViewManager.ShowTip(language.opsLock);
		end
		if param.errCallback then
			param.errCallback()
		end
	end
	CC.ApplePayPlugin.Pay(param.wareId, param.extraData, param.autoExchange, errCb, param.ExchangeWareId);
end

function PaymentManager.PayByOppo(param)
	local errCb = function(err)
		if err == CC.shared_en_pb.OpsLocked then
			CC.ViewManager.ShowTip(language.opsLock);
		end
		if param.errCallback then
			param.errCallback()
		end
	end
	CC.OppoPlugin.Pay(param.wareId, param.autoExchange, errCb, param.ExchangeWareId);
end

function PaymentManager.PayByVivoBank(param)
	local errCb = function(err)
		if err == CC.shared_en_pb.OpsLocked then
			CC.ViewManager.ShowTip(language.opsLock);
		end
		if param.errCallback then
			param.errCallback()
		end
	end
	CC.VivoPlugin.Pay(param.wareId, param.autoExchange, errCb, param.ExchangeWareId, "bank");
end

function PaymentManager.PayByVivoSms(param)
	local errCb = function(err)
		if err == CC.shared_en_pb.OpsLocked then
			CC.ViewManager.ShowTip(language.opsLock);
		end
		if param.errCallback then
			param.errCallback()
		end
	end
	CC.VivoPlugin.Pay(param.wareId, param.autoExchange, errCb, param.ExchangeWareId, "sms");
end

function PaymentManager.PayByTiKiPay(param)
	CC.TiKiPayPlugin.PayEntrancePay(param)
end

function PaymentManager.PayByGuPayKBank(param)
	CC.GuPayPlugin.PayByKBank(param)
end

function PaymentManager.PayByGuPayKtb(param)
	CC.GuPayPlugin.PayByKtb(param)
end

function PaymentManager.PayByGuPayBay(param)
	CC.GuPayPlugin.PayByBay(param)
end

function PaymentManager.GetActiveWareIdByKey(key, id)

	if key == "buyu" then
		if CC.Platform.isIOS then
			return "com.huoys.royalcasino.ios.buyu";
		else
			return "com.huoys.royalcasino.product11";
		end
	elseif key == "vip" then
		if CC.Platform.isIOS then
			return "com.huoys.royalcasino.ios.vip";
		else
			return "com.huoys.royalcasino.product9";
		end
	elseif key == "fund" then
		if CC.Platform.isIOS then
			return string.format("com.huoys.royalcasino.fundios%s", id);
		else
			if CC.ChannelMgr.CheckOppoChannel() then
				return string.format("com.huoys.royalcasino.fundoppo%s",id);
			end
			return string.format("com.huoys.royalcasino.fund%s", id);
		end
	elseif key == "sevenday" then
		if CC.Platform.isIOS then
			return "com.huoys.royalcasino.ios.serven";
		else
			return "com.huoys.royalcasino.product8";
		end
	elseif key == "limitGift" then
		if CC.Platform.isIOS then
			return "com.huoys.royalcasino.time.ios";
		else
			return "com.huoys.royalcasino.time";
		end
	elseif key == "elephant" then
		if CC.Platform.isIOS then
			return "com.huoys.royalcasino.turnover.ios";
		else
			return "com.huoys.royalcasino.turnover";
		end
	end

	logError("PaymentManager: no match key");
end

return PaymentManager
