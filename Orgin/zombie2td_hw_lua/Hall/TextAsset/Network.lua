--网络连接重连逻辑，可以对着大厅开发文档中的《海外大厅游戏网络状态转移图.png》理解
--svn路径：https://172.13.0.100/svn/Z_Frame/_Common/开发文档/海外平台客户端

local CC = require("CC")

local Network = {}

--大厅服务器唯一标识
--起多个服务器的时候，tag是区分这些服务器的，所以每个游戏服务器tag不能一样
--除了大厅服务器移植连着，子游戏退回大厅必须断开服务器
local _hallServerTag = "main"

--网络状态枚举
local _netState = {
    --无网络状态
    Origin = 0,
    --等待登录状态
    Ready = 1,
    --游戏进行中
    InGame = 2,
    --游戏中断线，等待重连
    InGameDisconnected = 3
}

--_netState.InGameDisconnected状态下，允许尝试重新连接的次数(假如是3次)
local _MaxReconnectTime = 3

--再次尝试重连是在x秒之后，暂定10s
local _nextTryReconnectTime = 5

--_netState.InGameDisconnected状态下，当前尝试重新连接的次数
local _tmpReconnectTime = 0

--初始状态为无网络初始状态
local _tmpNetState = _netState.Origin

--自动弹出loading记数
local _connectingCount = 0

--注册到RegToPublisher
local _RegToPublisher = false

--链接服务器成功
local function OnOpen()
    log("大厅链接服务器成功")
    log("当前网络状态：" .. _tmpNetState)
    if _tmpNetState == _netState.Ready then
        --链接服务器成功（登录--游戏）
        _tmpNetState = _netState.InGame
        --TODO！！！登录界面监听：监听到该消息再请求登录
        CC.HallNotificationCenter.inst():post(CC.Notifications.OnConnectServer)
    elseif _tmpNetState == _netState.InGameDisconnected then
        --重连链接服务器成功（断线重连--回到游戏）
        _tmpNetState = _netState.InGame
        _tmpReconnectTime = 0
        --TODO！！！大厅全局监听该消息，表示大厅重连成功，请求登录（默默进行，并且刷新数据）
        CC.HallNotificationCenter.inst():post(CC.Notifications.OnReConnectServer)
    end
end

--统一处理服务器断开或异常
local function DealConnectException()
    log("当前网络状态：" .. _tmpNetState)
    if _tmpNetState == _netState.Ready then
        --（登录--游戏）过程中网络Close或者Error,回到当前状态
        Network.StopServer()
        --TODO！！！只在登录界面做监听，请求链接服务器失败，该界面弹个提示即可
        CC.HallNotificationCenter.inst():post(CC.Notifications.OnLoginDisconnect)
    elseif _tmpNetState == _netState.InGameDisconnected then
        --(重连--游戏)过程中网络Close或者Error，回到当前状态
        _tmpReconnectTime = _tmpReconnectTime + 1
        if _tmpReconnectTime > _MaxReconnectTime then
            _tmpReconnectTime = 0
            Network.StopServer()
            --TODO！！！case1：大厅场景，收到该消息，弹出提示框返回登录，必须返回
            --TODO！！！case2：游戏场景，收到该消息，在游戏退回大厅时检测网络状态，直接返回登录界面
            CC.HallNotificationCenter.inst():post(CC.Notifications.OnReLoginDisconnectToLogin)
        else
            CC.uu.DelayRun(
                _nextTryReconnectTime,
                function()
                    Network.Reconnect()
                end
            )
            --TODO！！！case1：大厅场景，收到该消息，提示网络重连中
            --TODO！！！case2：游戏场景，收到该消息，不用理会
            CC.HallNotificationCenter.inst():post(CC.Notifications.OnReLoginDisconnect)
        end
    elseif _tmpNetState == _netState.InGame then
        --游戏中监听到网络Close或者Error，状态转移
        _tmpNetState = _netState.InGameDisconnected
        _tmpReconnectTime = _tmpReconnectTime + 1
        Network.Reconnect()
        --TODO！！！case1：大厅场景，收到该消息，提示网络重连中
        --TODO！！！case2: 游戏场景，收到该消息，不用理会
        CC.HallNotificationCenter.inst():post(CC.Notifications.OnDisconnect)
    end
end

--服务器关闭(服务器或者客户端主动断开socket)，原因reason
local function OnClose(reason)
    logError("大厅服务器关闭：" .. reason)
    DealConnectException()
end

--链接错误(IP解析出错/超时等)，错误信息msg
local function OnError(msg)
    logError("大厅链接错误，错误信息：" .. msg)
    DealConnectException()
end

--收到服务器主推的消息
local function OnPush(data)
    local msg = CC.NetworkHelper.MakeMessage("Message", data)
    --游戏数据：msg.Ops ,msg.Data
    local _onPushCfg = CC.NetworkHelper.OnPushName[msg.Ops]
    if _onPushCfg then
        CC.uu.SafeCallFunc(
            CC.OnPush[_onPushCfg.method],
            _onPushCfg.proto and CC.NetworkHelper.MakeMessage(_onPushCfg.proto, msg.Data) or data
        )
    else
        logError("服务器主推协议未定义：" .. msg.Ops)
    end
end

function Network.GetReconnectTimes()
    return _tmpReconnectTime
end

function Network.GetMaxReconnectTimes()
    return _MaxReconnectTime
end

--服务器尝试连接
function Network.Start()
    _tmpNetState = _netState.Ready

    local server = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetServerAddress()

    local args = IO.LauncherArgs()
    args.ConnectionStr = server
    args.AutoReconnectEnabled = false
    log("大厅请求链接服务器：" .. server)
    IO.Launcher.Start(
        _hallServerTag,
        args,
        function(itype, msg, data)
            if itype == "OnPush" then
                if _RegToPublisher then
                    OnPush(data)
                end
            end
            if itype == "OnOpen" then
                OnOpen()
            end
            if itype == "OnClose" then
                OnClose(msg)
            end
            if itype == "OnError" then
                OnError(msg)
            end
        end
    )
end

--请求
function Network.Request(name, req, successcb, errorcb)
    local reqCfg = CC.NetworkHelper.Cfg[name]
    if not reqCfg then
        logError("---协议名字不存在或未配置:" .. name)
        return
    end

    local sucCb = function(...)
        if not successcb then
            return
        end
        --如果协议回包调用函数报错，输出协议名称(方便查bug)
        if not CC.uu.SafeCallFunc(successcb, ...) then
            logError("---network successcb error: " .. name .. "协议回包调用函数报错")
        end
    end
    local errCb = function(...)
        if not errorcb then
            return
        end
        --如果协议回包调用函数报错，输出协议名称(方便查bug)
        if not CC.uu.SafeCallFunc(errorcb, ...) then
            logError("---network errorcb error: " .. name .. "协议回包调用函数报错")
        end
    end

    local notificationKey = string.format("NW_%s", name)

    local delayTime = reqCfg.Timeout
    local co = nil
    local isDelay = false
    local showConnect = Network.CheckShowConnecting(reqCfg)
    if delayTime then
        if showConnect then
            if _connectingCount == 0 then
                CC.ViewManager.ShowConnecting(true)
            end
            _connectingCount = _connectingCount + 1
        end

        co =
            CC.uu.DelayRun(
            delayTime,
            function()
                isDelay = true
                _connectingCount = _connectingCount - 1
                if _connectingCount == 0 and showConnect then
                    CC.ViewManager.CloseConnecting()
                end
                CC.ViewManager.ShowTip(CC.LanguageManager.GetLanguage("L_Common").tip2)
                errCb(CC.NetworkHelper.DelayErrCode, "timeOut")
                CC.HallNotificationCenter.inst():post(
                    CC.Notifications[notificationKey],
                    CC.NetworkHelper.DelayErrCode,
                    "timeOut"
                )
            end
        )
    end

    local msg = CC.NetworkHelper.MakeMessage("Message")
    msg.Ops = reqCfg.Ops
    if req then
        msg.Data = req:SerializeToString()
    end
    local req = msg:SerializeToString()
    IO.Launcher.Request(
        _hallServerTag,
        req,
        function(err, data)
            if isDelay then
                return
            end
            if delayTime then
                CC.uu.CancelDelayRun(co)
                if showConnect then
                    _connectingCount = _connectingCount - 1
                    if _connectingCount == 0 then
                        CC.ViewManager.CloseConnecting()
                    end
                end
            end
            CC.Network.ShowTip(err, name, reqCfg)

            local result = {}
            local cb = function(err, data)
                if err == 0 then
                    sucCb(err, data)
                    return
                end
                errCb(err, data)
            end
            if reqCfg.RspProto then
                result = CC.NetworkHelper.MakeMessage(reqCfg.RspProto, data)
                cb(err, result)
            else
                cb(err, data)
            end
        end
    )
end

function Network.FixReqUrlParam(name, url)
    local PlayerId = CC.Player.Inst():GetLoginInfo().PlayerId
    local Token = CC.Player.Inst():GetLoginInfo().Token
    local RequestOps = CC.NetworkHelper.RetrunOps(name)
    return string.format(url, RequestOps, PlayerId, Token)
end

function Network.RequestActivityHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetActivityAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestLotteryHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLotteryAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestSupplyHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetSupplyAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestMSignHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetMSignAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestTreasureHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetTreasureUrl()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestAgentHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetAgentAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestAuthHttp(name, req, okcb, errorcb)
    local url =
        string.format(
        CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetHallHttpAddress() .. "/hall/?ops=%s",
        CC.NetworkHelper.RetrunOps(name)
    )
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestIPHttp(name, req, okcb, errorcb)
    local url =
        string.format(CC.DebugDefine.GetEntryUrlPrefixByEnv() .. "/newgeoip?ops=%s", CC.NetworkHelper.RetrunOps(name))
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestTaskHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetTaskAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestHalloweenTaskHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetHalloweenTaskAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestWaterLightHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWaterLightAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestRealShopHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetRealShopAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end
function Network.RequestGiftSignHttp1(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetGiftSignAddressWithOps1()
    local PlayerId = CC.Player.Inst():GetLoginInfo().PlayerId
    local Token = CC.Player.Inst():GetLoginInfo().Token
    url = string.format(url, PlayerId, Token)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end
function Network.RequestGiftSignHttp2(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetGiftSignAddressWithOps2()
    local PlayerId = CC.Player.Inst():GetLoginInfo().PlayerId
    local Token = CC.Player.Inst():GetLoginInfo().Token
    url = string.format(url, PlayerId, Token)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end
function Network.RequestGiftSignHttp3(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetGiftSignAddressWithOps3()
    local PlayerId = CC.Player.Inst():GetLoginInfo().PlayerId
    local Token = CC.Player.Inst():GetLoginInfo().Token
    url = string.format(url, PlayerId, Token)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestGiftPackHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetGiftPackAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestCompositeHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetCompositeAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestUserWelfareHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetUserWelfareAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestRechargeHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetRechargeAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestBlockchainHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetBlockchainAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestLogHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLogAddress()
    url = string.format(url, CC.NetworkHelper.RetrunOps(name))
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestOnlineLimitHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetOnlineLimitAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestFreeLotteryHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetFreeLotteryAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestLoginQueueHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLoginQueueAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

function Network.RequestTimeActivitiesHttp(name, req, okcb, errorcb)
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetTimeActivitiesAddressWithOps()
    url = Network.FixReqUrlParam(name, url)
    return Network.RequestHttp(name, req, okcb, errorcb, url)
end

--请求web
function Network.RequestHttp(name, req, okcb, errorcb, url)
    local reqCfg = CC.NetworkHelper.Cfg[name]
    if not reqCfg then
        logError("---协议名字不存在或未配置:" .. name)
        return
    end

    url =
        url or Network.FixReqUrlParam(name, CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetHallHttpAddressWithOps())
    local wwwForm
    if req then
        wwwForm = req:SerializeToString()
    end
    local sucCb = function(...)
        if not okcb then
            return
        end
        --如果协议回包调用函数报错，输出协议名称(方便查bug)
        if not CC.uu.SafeCallFunc(okcb, ...) then
            logError("---network successcb error: " .. name .. "协议回包调用函数报错")
        end
    end
    local errCb = function(...)
        if not errorcb then
            return
        end
        --如果协议回包调用函数报错，输出协议名称(方便查bug)
        if not CC.uu.SafeCallFunc(errorcb, ...) then
            logError("---network errorcb error: " .. name .. "协议回包调用函数报错")
        end
    end

    local notificationKey = string.format("NW_%s", name)
    local delayTime = reqCfg.Timeout
    local co = nil
    local isDelay = false
    local showConnect = Network.CheckShowConnecting(reqCfg)
    if delayTime then
        if showConnect then
            if _connectingCount == 0 then
                CC.ViewManager.ShowConnecting(true)
            end
            _connectingCount = _connectingCount + 1
        end

        co =
            CC.uu.DelayRun(
            delayTime,
            function()
                isDelay = true
                _connectingCount = _connectingCount - 1
                if _connectingCount == 0 and showConnect then
                    CC.ViewManager.CloseConnecting()
                end
                CC.ViewManager.ShowTip(CC.LanguageManager.GetLanguage("L_Common").tip2)
                errCb(CC.NetworkHelper.DelayErrCode, "timeOut")
                CC.HallNotificationCenter.inst():post(
                    CC.Notifications[notificationKey],
                    CC.NetworkHelper.DelayErrCode,
                    "timeOut"
                )
            end
        )
    end

    local okback = nil
    local errback = nil
    okback = function(www)
        if isDelay then
            return
        end
        local data = Util.ByteToLuaByteBuffer(www.downloadHandler.data)
        data = CC.NetworkHelper.DealHttpMessage(data)
        if delayTime then
            CC.uu.CancelDelayRun(co)
            if showConnect then
                _connectingCount = _connectingCount - 1
                if _connectingCount == 0 then
                    CC.ViewManager.CloseConnecting()
                end
            end
        end
        local result = {}
        if reqCfg.RspProto then
            if data.Data then
                result = CC.NetworkHelper.MakeMessage(reqCfg.RspProto, data.Data)
            end
        else
            result = data.Data
        end
        if data.En == 0 then
            sucCb(data.En, result)
            CC.HallNotificationCenter.inst():post(CC.Notifications[notificationKey], data.En, result)
        else
            CC.Network.ShowTip(data.En, name, reqCfg)
            errCb(data.En, result)
            CC.HallNotificationCenter.inst():post(CC.Notifications[notificationKey], data.En, result)
        end
    end
    errback = function(err)
        logError(string.format("reqName:%s  error:%s  url:%s", tostring(name), tostring(err), tostring(url)))
        if isDelay then
            return
        end
        if delayTime then
            CC.uu.CancelDelayRun(co)
            if showConnect then
                _connectingCount = _connectingCount - 1
                if _connectingCount == 0 then
                    CC.ViewManager.CloseConnecting()
                end
            end
        end
        --err是url请求的错误信息
        errCb(err, "httpError")
        CC.HallNotificationCenter.inst():post(CC.Notifications[notificationKey], err, "httpError")
    end

    if wwwForm then
        return CC.HttpMgr.Post(url, wwwForm, okback, errback), url
    else
        return CC.HttpMgr.Get(url, okback, errback), url
    end
end
--推送
function Network.Push(name, push)
    local msg = CC.NetworkHelper.MakeMessage("Message")
    msg.Ops = CC.NetworkHelper.PushOps[name]
    if push then
        msg.Data = push:SerializeToString()
    end

    local data = msg:SerializeToString()
    IO.Launcher.Push(_hallServerTag, data)
end

--重连
function Network.Reconnect()
    IO.Launcher.Reconnect(_hallServerTag)
end

--主动停止服务器（主动请求返回登录界面需要执行）
function Network.StopServer()
    --无论何时，主动请求断开服务器，状态恢复到最原始
    _tmpNetState = _netState.Origin
    IO.Launcher.Stop(_hallServerTag)
end

function Network.CheckShowConnecting(reqCfg)
    if not reqCfg.ExceptView then
        return true
    end
    local curView = CC.ViewManager.GetCurrentView()
    if not curView then
        return
    end
    for _, v in pairs(reqCfg.ExceptView) do
        if curView.viewName == v then
            return false
        end
    end
    return true
end

function Network.ShowTip(errorCode, opsName, reqCfg)
    --网络错误码显示
    if errorCode and errorCode ~= 0 then
        log(string.format("errCode : %s, opsName : %s, opsCode : %s", errorCode, opsName, reqCfg.Ops))
        if errorCode == CC.shared_en_pb.TokenExpired then
            if CC.ViewManager.IsHallScene() and CC.ViewManager.GetCurrentView().viewName ~= "LoginView" then
                local loginDefine = CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine")
                local box =
                    CC.ViewManager.ShowMessageBox(
                    CC.LanguageManager.GetLanguage("L_Common").tip8,
                    function()
                        CC.ViewManager.BackToLogin(loginDefine.LoginType.Logout)
                    end
                )
                box:SetOneButton()
            else
                log("token TokenExpired trigger on " .. (CC.ViewManager.GetCurrentView().viewName or "nil"))
            end
        else
            local errorText =
                require("Model/Language/" .. require("Model/Manager/LanguageManager").GetType() .. "/L_ErrorText")
            local errorKey = "errorText" .. errorCode
            local errorValue = errorText[errorKey]
            if errorValue and errorValue ~= "" then
                if not reqCfg.NotErrorTip then --根据配置该请求是否要弹错误提示，默认都要弹
                    CC.ViewManager.ShowTip(errorValue)
                end
                log("errTips" .. errorValue)
            end
        end
    end
end

function Network.SetPublisherState(bState)
    _RegToPublisher = bState
end

function Network.GetHallPing(cb)
    local pingFunc = function(value)
        cb(value)
    end
    IO.Launcher.Lag(_hallServerTag, pingFunc)
end

function Network.isInGame()
    return _tmpNetState == _netState.InGame
end

return Network
