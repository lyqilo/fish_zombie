
local CC = require("CC")

local Request = {}
local DoRequest = function(reqKey, msg, succCb, errCb)
    local reqCfg = CC.NetworkHelper.Cfg[reqKey];
    local doReq = reqCfg.ReqUrlMethod or CC.Network.RequestHttp;
    return doReq(reqKey, msg, succCb, errCb);
end

local mt = {
    __call = function(tb, key, ...)
        local param,succCb,errCb = unpack({...});
        if Request[key] then
            return Request[key](param,succCb,errCb);
        end
        local reqCfg = CC.NetworkHelper.Cfg[key];
        if not reqCfg then
            logError("---协议未配置："..key);
            return;
        end
        --构造proto数据(这里不考虑数组类型和嵌套的Message类型,会让接口变复杂且效率变低,遇到这种情况重写对应请求方法)
        local msg;
        if reqCfg.ReqProto then
            msg = CC.NetworkHelper.MakeMessage(reqCfg.ReqProto);
            for k,v in pairs(param) do
                msg[k] = v;
            end
        end
        return DoRequest(key, msg, succCb, errCb);
    end
}
setmetatable(Request, mt)

local MakeCommonMessage = function(reqKey, param)
    local req = CC.NetworkHelper.MakeReqMessage(reqKey)
    for k,v in pairs(param) do
        req[k] = v;
    end
    return req;
end

function Request:RequestAsyn(req,callback)

    return Request(req.name, req.data, callback, callback)
end

function Request:RequestActivityAsyn(req,callback)
    return CC.Network.RequestActivityHttp(req.name,req.proto,callback)
end

function Request.Register(param,succCb,errCb)

    local req = MakeCommonMessage("Register", param);
    req.Channel = tonumber(AppInfo.ChannelID)
    return DoRequest("Register",req,succCb,errCb)
end

function Request.Login(param,succCb,errCb)
    -- succCb("", {PlayerId = 99999, Token = "7dce00018818470e817efa6c4a67574e"})
    -- do return end
    local req = MakeCommonMessage("Login", param);
    req.Channel = tonumber(AppInfo.ChannelID)
    req.AppsFlyerId = AppsFlyerUtil.GetAppsFlyerId()
    req.FireBaseToken = FirebaseUtil.GetToken()
    req.AndroidVersion = AppInfo.androidVersionCode
    return DoRequest("Login",req,succCb,errCb)
end

function Request.AppleLogin(param,succCb,errCb)
    local req = MakeCommonMessage("AppleLogin", param);
    req.Channel = tonumber(AppInfo.ChannelID)
    req.AppsFlyerId = AppsFlyerUtil.GetAppsFlyerId()
    req.FireBaseToken = FirebaseUtil.GetToken()
    req.AndroidVersion = AppInfo.androidVersionCode
    return DoRequest("AppleLogin",req,succCb,errCb)
end

function Request.ResetLogout(param,succCb,errCb)
    local req = MakeCommonMessage("ResetLogout", param);
    -- req.Channel = tonumber(AppInfo.ChannelID)
    -- req.AppsFlyerId = AppsFlyerUtil.GetAppsFlyerId()
    -- req.FireBaseToken = FirebaseUtil.GetToken()
    -- req.AndroidVersion = AppInfo.androidVersionCode
    return DoRequest("ResetLogout",req,succCb,errCb)
end

function Request.FacebookLogin(param,succCb,errCb)

    local req = MakeCommonMessage("FacebookLogin", param);
    req.Channel = tonumber(AppInfo.ChannelID)
    req.AppsFlyerId = AppsFlyerUtil.GetAppsFlyerId()
    req.FireBaseToken = FirebaseUtil.GetToken()
    req.AndroidVersion = AppInfo.androidVersionCode
    return DoRequest("FacebookLogin",req,succCb,errCb)
end

function Request.LineLogin(param,succCb,errCb)

    local req = MakeCommonMessage("LineLogin", param);
    req.Channel = tonumber(AppInfo.ChannelID)
    req.AppsFlyerId = AppsFlyerUtil.GetAppsFlyerId()
    req.FireBaseToken = FirebaseUtil.GetToken()
    req.AndroidVersion = AppInfo.androidVersionCode
    return DoRequest("LineLogin",req,succCb,errCb)
end

function Request.OppoLogin(param,succCb,errCb)

    local req = MakeCommonMessage("OppoLogin", param);
    req.Channel = tonumber(AppInfo.ChannelID)
    req.AppsFlyerId = AppsFlyerUtil.GetAppsFlyerId()
    req.FireBaseToken = FirebaseUtil.GetToken()
    req.AndroidVersion = AppInfo.androidVersionCode
    return DoRequest("OppoLogin",req,succCb,errCb)
end

function Request.ReqLoginByPhone(param,succCb,errCb)

    local req = MakeCommonMessage("ReqLoginByPhone", param);
    req.Channel = tonumber(AppInfo.ChannelID)
    req.AppsFlyerId = AppsFlyerUtil.GetAppsFlyerId()
    req.FireBaseToken = FirebaseUtil.GetToken()
    req.AndroidVersion = AppInfo.androidVersionCode
    return DoRequest("ReqLoginByPhone",req,succCb,errCb)
end

function Request.LoginWithToken(param,succCb,errCb)

    local req = MakeCommonMessage("LoginWithToken", param);
    req.Channel = tonumber(AppInfo.ChannelID)
    return DoRequest("LoginWithToken",req,succCb,errCb)
end

function Request.ReqSavePlayer(param,succCb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("ReqSavePlayer")
    for key, value in pairs(param) do
        local CKeyValue = CC.NetworkHelper.MakeMessage("CKeyValue")
        CKeyValue.Key = key;
        CKeyValue.Value = value;
        table.insert(req.Pairs, CKeyValue);
    end
    return DoRequest("ReqSavePlayer",req,succCb,errCb)
end

function Request.ReqLoadPlayerWithProps(param, succCb, errCb)
    local req = CC.NetworkHelper.MakeReqMessage("ReqLoadPlayerWithProps")
    req.PlayerId = param.playerId
    for _,v in pairs(param.propIds) do
        table.insert(req.PropIds, v)
    end
    return DoRequest("ReqLoadPlayerWithProps",req,succCb,errCb)
end

function Request.ReqLoadPlayerWithPropType(param, succCb, errCb)
    local req = CC.NetworkHelper.MakeReqMessage("ReqLoadPlayerWithPropType")
    req.PlayerId = param.playerId
    for k,v in pairs(param.propTypes) do
        table.insert(req.TypeId,v)
    end
    return DoRequest("ReqLoadPlayerWithPropType",req,succCb,errCb)
end

function Request.ReqGetSpecialProps(param, succCb, errCb)
    local req = CC.NetworkHelper.MakeReqMessage("ReqGetSpecialProps")
    req.PlayerId = param.playerId
    for k,v in pairs(param.propIds) do
        table.insert(req.PropIds, v)
    end
    return DoRequest("ReqGetSpecialProps",req,succCb,errCb)
end

function Request.ReqLoadFriendsList(param,succCb,errCb)
    --获取好友列表
    local req = MakeCommonMessage("ReqLoadFriendsList", param);
    req.From = req.From or 0;
    req.To = req.To or 0;
    return DoRequest("ReqLoadFriendsList",req,succCb,errCb)
end

function Request.ReqLoadModifyNews(param,succCb,errCb)
    --获取修改资讯信息
    local req = CC.NetworkHelper.MakeReqMessage("ReqLoadModifyNews")
    for key, value in pairs(param) do
        local NKeyValue = CC.NetworkHelper.MakeMessage("NKeyValue")
        NKeyValue.Key = key;
        NKeyValue.Value = value;
        table.insert(req.PartNew,NKeyValue)
    end
    return DoRequest("ReqLoadModifyNews",req,succCb,errCb)
end

function Request.ReqAgreeFriend(param,succCb,errCb)
    --同意添加好友
    local req = CC.NetworkHelper.MakeReqMessage("ReqAgreeFriend")
    for k,v in ipairs(param.ids) do
        table.insert(req.FriendId,v)
    end
    return DoRequest("ReqAgreeFriend",req,succCb,errCb)
end

function Request.ReqRefuseFriend(param,succCb,errCb)

    local req = CC.NetworkHelper.MakeReqMessage("ReqRefuseFriend")
    for k,v in ipairs(param.ids) do
        table.insert(req.FriendId,v)
    end
     for k,v in ipairs(param.flags) do
        table.insert(req.NomoreFlag,v)
    end
    return DoRequest("ReqRefuseFriend",req,succCb,errCb)
end

function Request.ReqMailLoad(param,succCb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("ReqMailLoad")
    for _,v in ipairs(param.Ids) do
        table.insert(req.MailsId, v);
    end
    return DoRequest("ReqMailLoad",req,succCb,errCb)
end

function Request.GetOrder(param,succCb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("GetOrder")
    req.WareId = tostring(param.wareId)
    if param.extraData then
        req.ExtraData = param.extraData;
    end
    if param.autoExchange then
        req.AutoExchange = param.autoExchange
    end
    if CC.ViewManager.GetCurGameId() then
        req.GameId = tonumber(CC.ViewManager.GetCurGameId());
    end
    if CC.ViewManager.GetCurGroupId() then
        req.GroupId = tonumber(CC.ViewManager.GetCurGroupId());
    end
    if param.ExchangeWareId then
        req.ExchangeWareId = tostring(param.ExchangeWareId);
    end
    req.PackageChn = tonumber(AppInfo.ChannelID);
    return DoRequest('GetOrder',req,succCb,errCb)
end

function Request.MolCashCardPurchase(param,succCb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("MolCashCardPurchase")
    req.WareId = tostring(param.wareId)
    req.channel = tostring(param.channel)
    if param.card_no then
        req.card_no = tostring(param.card_no)
    end
    if param.pin then
        req.pin = tostring(param.pin)
    end
    if param.serial then
        req.serial = tostring(param.serial)
    end
    if param.extraData then
        req.ExtraData = param.extraData;
    end
    if param.autoExchange then
        req.AutoExchange = param.autoExchange
    end
    if CC.ViewManager.GetCurGameId() then
        req.GameId = tonumber(CC.ViewManager.GetCurGameId());
    end
    if CC.ViewManager.GetCurGroupId() then
        req.GroupId = tonumber(CC.ViewManager.GetCurGroupId());
    end
    if param.ExchangeWareId then
        req.ExchangeWareId = tostring(param.ExchangeWareId);
    end
    req.PackageChn = tonumber(AppInfo.ChannelID);
    return DoRequest('MolCashCardPurchase',req,succCb,errCb)
end

function Request.ReqBuyWithId(param,succCb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("ReqBuyWithId")
    req.WareId = tostring(param.WareId)
    if param.Channel then
        req.Channel = tostring(param.Channel)
    end
    if param.ExtraData then
        req.ExtraData = param.ExtraData;
    end
    if CC.ViewManager.GetCurGameId() then
        req.GameId = tonumber(CC.ViewManager.GetCurGameId());
    end
    if CC.ViewManager.GetCurGroupId() then
        req.GroupId = tonumber(CC.ViewManager.GetCurGroupId());
    end
    if param.ExchangeWareId then
        req.ExchangeWareId = tostring(param.ExchangeWareId);
    end
    req.PackageChn = tonumber(AppInfo.ChannelID);
    return DoRequest('ReqBuyWithId',req,succCb,errCb)
end

function Request.LoadPlayerBaseInfo(PlayerId,cb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("LoadPlayerBaseInfo")
    req.PlayerId = PlayerId
    return CC.Network.RequestHttp('LoadPlayerBaseInfo',req,cb,errCb)
end

function Request.GetResourceVersionInfo(param,succCb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("GetResourceVersionInfo")

    if param.gameIds then
        for _, id in ipairs(param.gameIds) do
            table.insert(req.GameIds, id);
        end
    end

    return CC.Network.RequestAuthHttp('GetResourceVersionInfo',req,succCb,errCb)
end

--春节活动信息
function Request.GetFestivalInfo(PlayerId,succCb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("GetFestivalInfo")
    req.PlayerId = PlayerId
    return CC.Network.RequestHttp('GetFestivalInfo',req,succCb,errCb)
end

function Request.GetOrderStatus(wareIds,succCb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("GetOrderStatus")
    if wareIds then
        for _,id in ipairs(wareIds) do
            table.insert(req.WareIds, id);
        end
    end
    return DoRequest('GetOrderStatus',req,succCb,errCb)
end

function Request.ReqLimitTimeGiftInfo(param,succCb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("ReqLimitTimeGiftInfo");
    req.nGiftID = param.nGiftID
    return CC.Network.RequestActivityHttp("ReqLimitTimeGiftInfo",req,succCb,errCb);
end

function Request.ReqTriggerLuckySpin(succCb,errCb)
    return CC.Network.RequestActivityHttp("ReqTriggerLuckySpin",nil,succCb,errCb);
end

function Request.ReqTreasureReward(wareIds,succCb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("ReqTreasureReward")
    if wareIds then
        for _,id in ipairs(wareIds) do
            table.insert(req.WareIds, id);
        end
    end
    return DoRequest('ReqTreasureReward',req,succCb,errCb)
end

function Request.ReqTimesbuy(param,succCb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("ReqTimesbuy")
    if param then
        for _,id in ipairs(param.PackIDs) do
            table.insert(req.PackIDs, id);
        end
    end
    return DoRequest('ReqTimesbuy',req,succCb,errCb)
end

function Request.ReqStockPackGet(param,succCb,errCb)
    local req = CC.NetworkHelper.MakeReqMessage("ReqStockPackGet")
    if param then
        for _,id in ipairs(param.PackIDs) do
            table.insert(req.PackIDs, id);
        end
    end
    return DoRequest('ReqStockPackGet',req,succCb,errCb)
end

--客户端埋点
function Request.Req_ClientRecord(param,succCb,errCb)
    local LogMsg = CC.NetworkHelper.MakeMessage("LogMsg")
    LogMsg.Category = CC.server_log_pb.ELC_MLogGameCollectPoint
    LogMsg.Json = param
    LogMsg.OS = CC.Platform.GetOSEnum()
    LogMsg.Time = CC.uu.TimeOut(os.time())
    local req = CC.NetworkHelper.MakeMessage("LogMsgs")
    table.insert(req.Messages,LogMsg)
    return DoRequest("Req_ClientRecord",req,succCb,errCb);
end

function Request.TikipayPurchase(param,succCb,errCb)
	local req = CC.NetworkHelper.MakeReqMessage("TikipayPurchase")
	req.WareId = tostring(param.wareId)
	req.Channel = tostring(param.channel)
	if CC.ViewManager.GetCurGameId() then
		req.GameId = tonumber(CC.ViewManager.GetCurGameId());
	end
	if CC.ViewManager.GetCurGroupId() then
		req.GroupId = tonumber(CC.ViewManager.GetCurGroupId());
	end
	if param.autoExchange then
		req.AutoExchange = param.autoExchange
	end
	if param.ExchangeWareId then
		req.ExchangeWareId = tostring(param.ExchangeWareId);
	end
	if param.extraData then
		req.ExtraData = tostring(param.extraData);
	end
	req.PackageChn = tonumber(AppInfo.ChannelID);

	return DoRequest('TikipayPurchase',req,succCb,errCb)
end

function Request.ReqSafeData(param,succCb,errCb)
	local req = CC.NetworkHelper.MakeReqMessage("ReqSafeData")
	if param.IMei == "" then
		req.IMei = Client.GetUUID()
	else
		req.IMei = param.IMei
	end
	if CC.DebugDefine.GetDebugMode() then
		log(string.format("DeviceId:%s,\nUUID:%s,\nReqIMEI:%s",param.IMei,Client.GetUUID(),req.IMei))
	end
	return DoRequest('ReqSafeData',req,succCb,errCb)
end

return Request
