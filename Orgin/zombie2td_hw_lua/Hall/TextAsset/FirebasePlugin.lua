local CC = require("CC")
local M = {}
local FirebaseAnalytics = Firebase.Analytics.FirebaseAnalytics
local dynamicLinkCache = {}

local LogAppEvent = function(eventName, eventValues)
    if not FirebaseUtil.IsInitialized then
        return
    end
    eventValues = eventValues or {}
    eventValues = Json.encode(eventValues)
    FirebaseUtil.LogEvent(eventName, eventValues)
end

function M.TrackInAppPurchase(revenue, quantity, channel)
    if not FirebaseUtil.IsInitialized then
        return
    end
    local eventValues = {}
    eventValues[FirebaseAnalytics.ParameterCurrency] = CC.CurrencyDefine.CurrencyCode
    eventValues[FirebaseAnalytics.ParameterValue] = revenue
    eventValues[FirebaseAnalytics.ParameterQuantity] = quantity
    eventValues[FirebaseAnalytics.ParameterContentType] = channel

    eventValues = Json.encode(eventValues)

    FirebaseUtil.LogPurchase(revenue, CC.CurrencyDefine.CurrencyCode, eventValues)
end

function M.TrackRregister(registerType)
    if not FirebaseUtil.IsInitialized then
        return
    end
    local eventValues = {}
    eventValues[FirebaseAnalytics.UserPropertySignUpMethod] = registerType

    local eventName = FirebaseAnalytics.EventSignUp

    LogAppEvent(eventName, eventValues)
end

function M.TrackSendChips()
    LogAppEvent("hys_sendchips")
end

function M.TrackDebugMode()
    if not CC.DebugDefine.CheckReleaseServer() then
        return
    end
    local eventValues = {}
    eventValues.DebugMode = tostring(CC.DebugDefine.GetDebugMode())
    LogAppEvent("hys_DebugMode", eventValues)
end

function M.TrackRegisterTotalLose()
    if Util.GetFromPlayerPrefs("isNewPlayer") ~= "true" then
        return
    end
    if CC.LocalGameData.GetEventLogByKey("hys_totallose") then
        return
    end
    local totalLose = CC.Player.Inst():GetSelfInfoByKey("EPC_TotalLose")
    log("TrackRegisterTotalLose:" .. tostring(totalLose))
    if totalLose < 1000000 then
        return
    end
    CC.LocalGameData.SetEventLogByKey("hys_totallose")
end

function M.TrackGiftPurchase(wareData)
    local eventValues = {}
    eventValues.Id = wareData.Id
    eventValues.Name = wareData.Name
    LogAppEvent("hys_GiftPurchase", eventValues)
end

function M.TrackEnterGame(gameId)
    local eventValues = {}
    eventValues.GameId = gameId
    eventValues.Name = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetProNameByID(gameId)
    LogAppEvent("hys_EnterGame", eventValues)
end

function M.TrackEnterMatchGame(gameId)
    local eventValues = {}
    eventValues.GameId = gameId
    eventValues.Name = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetProNameByID(gameId)
    LogAppEvent("hys_EnterMatchGame", eventValues)
end

function M.TrackHttpReqTime(reqType, time, url)
    --上报频繁、加个开关控制
    if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("FCMReport", false) then
        return
    end

    local eventValues = {}
    if reqType == "API" then
        local timeRange = "req_api_time_100_less"
        if time > 100 and time <= 200 then
            timeRange = "req_api_time_200"
        elseif time > 200 and time <= 500 then
            timeRange = "req_api_time_500"
        elseif time > 500 and time <= 1000 then
            timeRange = "req_api_time_1000"
        elseif time > 1000 then
            timeRange = "req_api_time_1000_more"
        end
        eventValues.ReqApiTimeRange = timeRange

        --上报hall和activity耗时Api
        if url then
            local str = string.match(url, ".com/(.-)&")
            if not str then
                str = string.gsub(url, ".*com/", "")
            end
            local server = "hall"
            if string.find(tostring(str), "hall/") and time > 200 then
                if string.find(tostring(str), "activity/") then
                    server = "activity"
                end
                local timeRange = time > 500 and "500_more" or "500"
                local ops = string.gsub(tostring(str), ".*=", "")
                eventValues.ReqSpApiTimeRange = "req_spApi_" .. server .. tostring(ops) .. "_time_" .. timeRange
            end
        end
    elseif reqType == "RES" then
        local timeRange = "req_res_time_200_less"
        if time > 200 and time <= 500 then
            timeRange = "req_res_time_500"
        elseif time > 500 and time <= 1000 then
            timeRange = "req_res_time_1000"
        elseif time > 1000 and time <= 1500 then
            timeRange = "req_res_time_1500"
        elseif time > 1500 and time <= 2000 then
            timeRange = "req_res_time_2000"
        elseif time > 2000 then
            timeRange = "req_res_time_2000_more"
        end
        eventValues.ReqResTimeRange = timeRange
    end
    LogAppEvent("hys_HttpReqTimeConsume", eventValues)
end

function M.TrackLogGameEvent(key, data)
    if table.isEmpty(data) then
        return
    end
    LogAppEvent("hysgame_" .. tostring(key), data)
end

function M.GetDynamicLink()
    return FirebaseUtil.GetDynamicLink()
end

function M.ClearDynamicLink()
    FirebaseUtil.SetDynamicLink("")
end

--创建高V链接
function M.CreateAgentLink(param)
    param.fallbackLink = "https://go.onelink.me/uVzx/41bdad6"
    param.keeplive = 1 --高V链接需要保活
    M.CreateCommonLink(param)
end

--创建通用分享链接
function M.CreateCommonShareLink(param)
    param.fallbackLink = "https://rcshare.onelink.me/sIxh/share"
    M.CreateCommonLink(param)
end

--[[
@param:
webTitle: 链接标题
webText:  链接描述内容
textureUrl: 图片地址(可缺省)
urlData: 拼在动态链接上的参数
callback(url): 回调(返回的url有值证明创建成功，否则失败)
]]
function M.CreateCommonLink(param)
    param.urlData = param.urlData or {}
    if param.urlData.extraData then
        --转完之后字符串会出现含 '=' 的情况，下面 urlEncode 时会丢失掉，这里统一用 '#' 替换，解析的地方再替换回来
        param.urlData.extraData = string.gsub(param.urlData.extraData, "=", "#")
    end
    param.callback = param.callback or function()
        end
    local callback = function(url)
        M.RedirectDynamicLink(url, param)
    end
    local cacheLink = dynamicLinkCache[Json.encode(param.urlData)]
    if cacheLink then
        CC.uu.Log(cacheLink, "cacheLink:")
        callback(cacheLink)
        return
    end
    M.CreateShortDynamicLink(param, callback)
end

--对firebase动态链接重定向(解决fb内点链接无效的问题)
function M.RedirectDynamicLink(url, param)
    if not url then
        param.callback()
        return
    end
    local data = {
        textureUrl = param.textureUrl,
        webTitle = param.webTitle,
        webText = param.webText,
        keeplive = param.keeplive,
        url = url
    }
    local redirectUrl = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetRedirectUrl(data)
    CC.uu.Log(url, "RedirectDynamicLink:")
    CC.uu.DelayRun(
        0.016,
        function()
            CC.uu.Log(redirectUrl, "RredirectUrl:")
            CC.HttpMgr.Get(
                redirectUrl,
                function(www)
                    local result = Json.decode(www.downloadHandler.text)
                    CC.uu.Log(result.data, "RedirectUrl:", 3)
                    param.callback(result.data)
                end,
                function(err)
                    CC.uu.Log(err, "dynamicLink Redirect failed:", 3)
                    param.callback()
                end
            )
        end
    )
end

function M.CreateShortDynamicLink(param, callback)
    local callback = callback or function(url)
            CC.uu.Log("CreateShortDynamicLink:" .. tostring(url))
        end

    if not FirebaseUtil.IsInitialized then
        callback()
        return
    end

    --10秒超时处理
    local isDelay = false
    local co =
        CC.uu.DelayRun(
        10,
        function()
            isDelay = true
            local lan = CC.LanguageManager.GetLanguage("L_Common")
            CC.ViewManager.ShowTip(lan.tip2)
            callback()
        end
    )

    local cb = function(url)
        CC.uu.Log(url, "lua callback")
        if isDelay then
            return
        end
        CC.uu.CancelDelayRun(co)
        if url and url ~= "" then
            callback(url)
            dynamicLinkCache[Json.encode(param.urlData)] = url
            return
        end
        callback()
    end

    local fallbackLink = param.fallbackLink or "http://M.RC.firerock.in.th/"
    local link = "http://M.RC.firerock.in.th/" .. CC.uu.urlEncode(CC.uu.spliceUrlParam("", param.urlData))

    local data = {}
    data.dynamicLink = link
    local cfg = CC.ConfigCenter.Inst():getConfigDataByKey("SDKConfig")
    data.urlPrefix = cfg[AppInfo.ChannelID].firebase.dynamicLinkPrefix
    data.androidAppIdentifier = "com.huoys.royalcasinoonline" --设定google官方包名
    data.iosAppIdentifier = "com.hyuans.throyalcasino" --设定ios台湾包包名
    data.androidFallbackUrl = fallbackLink
    data.iosFallbackUrl = fallbackLink
    FirebaseUtil.CreateShortDynamicLink(Json.encode(data), cb)
end

--firebase主题订阅，非强制更新，做版本兼容
function M.CheckVersionCompatible()
    if tonumber(AppInfo.androidVersionCode) > 21 then
        return true
    end
    return false
end

--通过原生平台获取firebase token
function M.ReqToken()
    if not M.CheckVersionCompatible() then
        return
    end
    FirebaseUtil.ReqToken()
end

--订阅主题
function M.SubscribeTopic(topic)
    if not M.CheckVersionCompatible() then
        return
    end
    if topic and type(topic) == "string" then
        FirebaseUtil.SubscribeTopic(topic)
    end
end

--取消订阅主题
function M.UnsubscribeTopic(topic)
    if not M.CheckVersionCompatible() then
        return
    end
    if topic and type(topic) == "string" then
        FirebaseUtil.UnsubscribeTopic(topic)
    end
end

return M
