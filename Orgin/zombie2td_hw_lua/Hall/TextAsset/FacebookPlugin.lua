local CC = require("CC")
local FBInAppEvents = require("Model/Plugin/FBInAppEvents")
local FacebookPlugin = {}

FacebookPlugin.ERROR = {
    SUCCESS = 0,
    FAILED = 1,
    CANCEL = 2
}

FacebookPlugin.LoginBehavior = {
    DEVICE_AUTH = "DEVICE_AUTH", --在Android平台使用会crash，应该是给iOS用的
    NATIVE_ONLY = "NATIVE_ONLY", --仅使用app登录
    WEB_ONLY = "WEB_ONLY", --仅使用web登录，也就是h5
    WEB_VIEW_ONLY = "WEB_VIEW_ONLY", --看效果好像跟WEB_ONLY一样
    NATIVE_WITH_FALLBACK = "NATIVE_WITH_FALLBACK" --优先app登录，如果没有，则使用WEB_ONLY
}

--测试代码
-- local data = {}
-- data.user_id = "122823908564613"
-- data.access_token = "EAAaRi1qBkuYBAGCFjXufmqjtWNKm2go5wYlD9NsXPKsKYhIlpM5rwp3ZCanA8iX1mYQr7IyMdyrMT58ma2A9Hfv2MD4AOXvUJ0pd9ZCFdNhqoUiEE1T8CbZAMLqOM3j1D18ONhpEGQYCmIXlvpEGQxDuWQY0odJryYwX7uf3qgRaPJr0jfX6czYmZA6ippZAPulZBrQSxenwZDZD"
-- succCb(0,"",data)

function FacebookPlugin.Init(cb)
    local cb = cb or function()
            log("FackbookSDK init finish!")
        end
    FacebookUtil.Init(cb)
end

function FacebookPlugin.LogIn(succCb, errCb)
    local field = {"public_profile"}

    FacebookUtil.LogIn(
        field,
        function(code, error, data)
            log("code = " .. tostring(code) .. "    error = " .. tostring(error) .. "    data = " .. tostring(data))
            if code == FacebookPlugin.ERROR.SUCCESS then
                CC.ReportManager.SetDot("FBLOGINSUCC")
                if succCb then
                    succCb(Json.decode(data))
                end
            else
                CC.ReportManager.SetDot("FBLOGINFAIL")
                if errCb then
                    errCb()
                end
            end
        end
    )
end

function FacebookPlugin.LogInForPublish(cb)
    local loginBehavior = FacebookPlugin.LoginBehavior.NATIVE_WITH_FALLBACK
    local field = {"publish_actions"}
    FacebookUtil.LogInForPublish(
        field,
        function(code, error, data)
            if cb then
                data = code == FacebookPlugin.ERROR.SUCCESS and Json.decode(data) or ""
                cb(code, error, data)
            end
        end
    )
end

function FacebookPlugin.Logout()
    FacebookUtil.LogOut()
end

local LogAppEvent = function(eventName, eventValues)
    eventValues = Json.encode(eventValues)
    FacebookUtil.LogAppEvent(eventName, eventValues)
end

--[[
追踪购买
currency:货币符号。USD,THB,CNY等。具体可以看这里https://www.xe.com/iso4217.php
revenue:金额数量。对应currency，
quantity:多少次。
比如currency是USD，revenue是0.99，quantity是2。就表示0.99*2美金
]]
function FacebookPlugin.TrackInAppPurchase(revenue, quantity, channel)
    local eventValues = {}
    eventValues[FBInAppEvents.AppEventParameterName.Currency] = CC.CurrencyDefine.CurrencyCode
    eventValues[FBInAppEvents.AppEventParameterName.NumItems] = quantity
    eventValues[FBInAppEvents.AppEventParameterName.ContentType] = channel

    eventValues = Json.encode(eventValues)

    FacebookUtil.LogPurchase(revenue, CC.CurrencyDefine.CurrencyCode, eventValues)
end

function FacebookPlugin.TrackRregister(registerType)
    local eventValues = {}
    eventValues[FBInAppEvents.AppEventParameterName.RegistrationMethod] = registerType
    eventValues[FBInAppEvents.AppEventParameterName.Currency] = CC.CurrencyDefine.CurrencyCode
    eventValues[FBInAppEvents.AppEventParameterName.NumItems] = 0

    local eventName = FBInAppEvents.AppEventName.CompletedRegistration

    LogAppEvent(eventName, eventValues)
end

-- string contentURL = null, string contentTitle = "", string contentDescription = "", string photoURL = null, LuaFunction cb = null
function FacebookPlugin.ShareLink(contentURL, cb)
    FacebookUtil.ShareLink(contentURL, "", "", contentURL, cb)
end

--获取延迟深度链接
function FacebookPlugin.GetDynamicLink()
    CC.uu.Log("FacebookPlugin.GetDynamicLink---")
    return FacebookUtil.GetDefferedLink()
end

function FacebookPlugin.ClearDynamicLink()
    FacebookUtil.SetDefferedLink("")
end

return FacebookPlugin
