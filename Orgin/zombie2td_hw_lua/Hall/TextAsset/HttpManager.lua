local CC = require("CC")

local HttpMgr = {}
local reqList = {}
local timers = {}
local cacheList = {}
local keyIndex = 0
local resetIndex = 0
local arraySize = 1024

local function StopTimer(key)
    if not timers[key] then
        return
    end
    timers[key]:Stop()
    timers[key] = nil
end

local function StartTimer(key, func, delay)
    StopTimer(key)
    timers[key] = Timer.New(func, delay, -1)
    timers[key]:Start()
end

local function CheckForResetList()
    if resetIndex < arraySize then
        return
    end
    if table.isEmpty(reqList) then
        reqList = {}
        timers = {}
        cacheList = {}
        resetIndex = 0
    end
end

local function CheckReqDone(request, func)
    CheckForResetList()
    keyIndex = keyIndex + 1
    resetIndex = resetIndex + 1
    local index = keyIndex
    StartTimer(
        index,
        function()
            if not request.isDone then
                return
            end
            func()
            HttpMgr.DisposeByKey(index)
        end,
        0.032
    )
    reqList[index] = request
    return index
end

function HttpMgr.CacheRequest(index)
    cacheList[index] = true
end

function HttpMgr.DisposeByKey(index)
    if not reqList[index] then
        return
    end
    StopTimer(index)
    reqList[index]:Dispose()
    reqList[index] = nil
    if cacheList[index] then
        cacheList[index] = nil
    end
end

function HttpMgr.DisposeWithoutCache()
    for index, v in pairs(reqList) do
        if not cacheList[index] then
            HttpMgr.DisposeByKey(index)
        end
    end
end

function HttpMgr.DisposeAll()
    for index, v in pairs(reqList) do
        HttpMgr.DisposeByKey(index)
    end
    reqList = {}
    timers = {}
    cacheList = {}
    keyIndex = 0
    resetIndex = 0
end

-- ************************************************************
-- HttpResultHandler 统一处理http请求返回，
-- @url 地址
-- @requestTime 请求时间
-- @request UnityWebRequest
-- @onResponse http 成功回调
-- @onError http error回调
-- @onFinish http完成回调
-- @isJson 是否要解析json
-- ************************************************************
function HttpMgr.HttpResultHandler(url, requestTime, request, onResponse, onError, onFinish, isJson)
    if url then
        log("HttpResultHandler url = " .. url)
    end
    local logUrl = string.match(url, ".com/(.-)&")
    if not logUrl then
        logUrl = url
    end
    CC.uu.Log(
        string.format(
            "Http请求响应: 请求地址:%s, 耗时:%sms, 状态码为:%s",
            logUrl,
            math.floor((os.clock() - requestTime) * 1000),
            request.responseCode
        )
    )

    if
        request.result == UnityWebRequest.Result.ConnectionError or
            request.result == UnityWebRequest.Result.ProtocolError
     then
        CC.uu.SafeCallFunc(onError, request.error, request)
    else
        if isJson then
            if request.downloadHandler.text and request.downloadHandler.text ~= "" then
                local jsonData = Json.decode(request.downloadHandler.text)
                CC.uu.SafeCallFunc(onResponse, jsonData)
            else
                CC.uu.SafeCallFunc(onError)
            end
        else
            CC.uu.SafeCallFunc(onResponse, request)
        end
    end
    CC.uu.SafeCallFunc(onFinish, request)
end

function HttpMgr.Get(url, onResponse, onError, onFinish, timeout)
    log("HttpMgr.Get url = " .. url)
    local time = os.clock()
    local request = UnityWebRequest.Get(url)
    if timeout then
        request.timeout = timeout
    end
    request:SendWebRequest()
    return CheckReqDone(
        request,
        function()
            HttpMgr.HttpResultHandler(url, time, request, onResponse, onError, onFinish, false)
        end
    )
end

--使用UnityWebRequest实现的GetTexture
function HttpMgr.GetTexture(url, onResponse, onError, onFinish, timeout)
    local request = UnityWebRequest.Get(url)
    local time = os.clock()
    request.downloadHandler = DownloadHandlerTexture.New()
    request.disposeDownloadHandlerOnDispose = true
    if timeout then
        request.timeout = timeout
    end
    request:SendWebRequest()
    return CheckReqDone(
        request,
        function()
            HttpMgr.HttpResultHandler(url, time, request, onResponse, onError, onFinish, false)
        end
    )
end

function HttpMgr.Post(url, byteData, onResponse, onError, onFinish, timeout)
    local time = os.clock()
    local request = UnityWebRequest.New(url, "POST")
    if timeout then
        request.timeout = timeout
    end
    request.uploadHandler = UploadHandlerRaw.New(byteData)
    request.downloadHandler = DownloadHandlerBuffer.New()
    request:SendWebRequest()
    return CheckReqDone(
        request,
        function()
            HttpMgr.HttpResultHandler(url, time, request, onResponse, onError, onFinish, false)
        end
    )
end

function HttpMgr.PostForm(url, wwwForm, onResponse, onError, onFinish, timeout)
    local time = os.clock()
    local request = UnityWebRequest.Post(url, wwwForm)
    if timeout then
        request.timeout = timeout
    end
    request:SendWebRequest()
    return CheckReqDone(
        request,
        function()
            HttpMgr.HttpResultHandler(url, time, request, onResponse, onError, onFinish, false)
        end
    )
end

function HttpMgr.GetJson(url, onResponse, onError, onFinish, timeout)
    local time = os.clock()
    --local logUrl = string.match(url,".com/(.-)&")
    local request = UnityWebRequest.Get(url)
    if timeout then
        request.timeout = timeout
    end
    request:SetRequestHeader("Content-Type", "application/json;charset=utf-8")
    request:SendWebRequest()
    return CheckReqDone(
        request,
        function()
            -- log(string.format("url:%s   耗时:%sms",logUrl, math.floor((os.clock() - time)*1000)))
            HttpMgr.HttpResultHandler(url, time, request, onResponse, onError, onFinish, true)
        end
    )
end

function HttpMgr.PostJson(url, jsonData, onResponse, onError, onFinish, timeout, secretKey)
    local time = os.clock()
    --local logUrl = string.match(url,".com/(.-)&")
    jsonData = Json.encode(jsonData)
    local request = UnityWebRequest.New(url, "POST")
    if timeout then
        request.timeout = timeout
    end
    request.uploadHandler = UploadHandlerRaw.New(Util.ToUTF8Bytes(jsonData))
    request.downloadHandler = DownloadHandlerBuffer.New()
    if secretKey then
        request:SetRequestHeader("Authorization", "Basic " .. Util.Base64(secretKey))
    -- request:SetRequestHeader("Authorization", "Basic " .. secretKey)
    end
    request:SetRequestHeader("Content-Type", "application/json;charset=utf-8")
    request:SendWebRequest()
    return CheckReqDone(
        request,
        function()
            -- log(string.format("url:%s   耗时:%sms",logUrl, math.floor((os.clock() - time)*1000)))

            HttpMgr.HttpResultHandler(url, time, request, onResponse, onError, onFinish, true)
        end
    )
end

--用来统计与大厅服交互的请求耗时
function HttpMgr.APIGet(url, onResponse, onError)
    local time = os.clock()
    local logUrl = string.match(url, ".com/(.-)&")

    local request = UnityWebRequest.Get(url)
    return CheckReqDone(
        request,
        function()
            log(string.format("Http请求响应：url:%s  耗时:%sms", logUrl, math.floor((os.clock() - time) * 1000)))
            CC.FirebasePlugin.TrackHttpReqTime("API", math.floor((os.clock() - time) * 1000), url)

            if
                request.result == UnityWebRequest.Result.ConnectionError or
                    request.result == UnityWebRequest.Result.ProtocolError
             then
                CC.uu.Log(request.responseCode, url .. " Http ErrCode:", 3)
                CC.uu.SafeCallFunc(onError, request.error, request)
            else
                CC.uu.SafeCallFunc(onResponse, request)
            end
        end
    )
end

--用来统计与大厅服交互的请求耗时
function HttpMgr.APIPost(url, byteData, onResponse, onError)
    local time = os.clock()
    local logUrl = string.match(url, ".com/(.-)&")

    local request = UnityWebRequest.New(url, "POST")
    request.uploadHandler = UploadHandlerRaw.New(byteData)
    request.downloadHandler = DownloadHandlerBuffer.New()
    request:SendWebRequest()
    return CheckReqDone(
        request,
        function()
            log(string.format("Http请求响应：url:%s  耗时:%sms", logUrl, math.floor((os.clock() - time) * 1000)))
            CC.FirebasePlugin.TrackHttpReqTime("API", math.floor((os.clock() - time) * 1000), url)
            if
                request.result == UnityWebRequest.Result.ConnectionError or
                    request.result == UnityWebRequest.Result.ProtocolError
             then
                CC.uu.Log(request.responseCode, url .. " Http ErrCode:", 3)
                CC.uu.SafeCallFunc(onError, request.error, request)
            else
                CC.uu.SafeCallFunc(onResponse, request)
            end
        end
    )
end

return HttpMgr
