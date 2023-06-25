local GC = require("GC")
local CC = require("CC")
local ZTD = require("ZTD")
local tools = GC.uu

local ZTD_NetworkManager = {}

--僵尸2服务器唯一标识
local _hallServerTag = "zombieTower"

--网络状态枚举
local _netState = {
    --无网络状态
    Origin = 0,
    --等待登录状态
    Ready = 1,
    --游戏进行中
    InGame = 2,
    --游戏中断，等待重连
    InGameDisconnected = 3,
}

--_netState.InGameDisconnected状态下，允许尝试重新连接的次数(假如是3次)
local _MaxReconnectTime = 3

--再次尝试重连是在x秒之后，暂定10s
local _nextTryReconnectTime = 10

--_netState.InGameDisconnected状态下，当前尝试重新连接的次数
local _tmpReconnectTime = 0

--初始状态为无网络初始状态
local _tmpNetState = _netState.Origin

--自动弹出loading记数
local _connectingCount = 0

--是否从大厅进到主界面
ZTD_NetworkManager.isFromHall = nil
--链接服务器成功
local function OnOpen()
	ZTD_NetworkManager.isStop = false;
    log("xxx链接服务器成功")
    log("当前网络状态：" .. _tmpNetState)
    if _tmpNetState == _netState.Ready then
        --链接服务器成功（登录--游戏）
        _tmpNetState = _netState.InGame
        --开始作登录请求
        ZTD_NetworkManager.StartLoinGame()
    elseif _tmpNetState == _netState.InGameDisconnected then
        --重连链接服务器成功（断线重连--回到游戏）
        _tmpNetState = _netState.InGame
        _tmpReconnectTime = 0
		ZTD_NetworkManager.StartLoinGame()
        --TODO！！！重连成功，请求登录（默默进行，并且刷新数据）
    end
end

--统一处理服务器断开或异常
local function DealConnectException()
    log("当前网络状态：" .. _tmpNetState)
    if _tmpNetState == _netState.Ready or _tmpNetState == _netState.Origin then
        --登录过程中网络Close或者Error,关闭网络退出游戏
        ZTD_NetworkManager.StopServer()
		ZTD.GameLogin.ExitGame()
        --处于断线重连状态，重连游戏
    elseif _tmpNetState == _netState.InGameDisconnected then
        _tmpReconnectTime = _tmpReconnectTime + 1
        if _tmpReconnectTime > _MaxReconnectTime then
            _tmpReconnectTime = 0
            ZTD_NetworkManager.StopServer()
			ZTD.GameLogin.ExitGame()
        else
			ZTD_NetworkManager.Reconnect()
        end
		--第一次出现错误，前一个状态还是游戏中，启动重连
    elseif _tmpNetState == _netState.InGame then
        _tmpNetState = _netState.InGameDisconnected
        _tmpReconnectTime = _tmpReconnectTime + 1
        ZTD_NetworkManager.Reconnect()
    end
end

--服务器关闭(服务器或者客户端主动断开socket)，原因reason
--弹窗返回大厅
local function OnClose(reason)
    log("xxx服务器关闭：" .. reason)
	ZTD_NetworkManager.StopServer()
	ZTD.GameLogin.ExitGame()
	ZTD.Notification.GamePost(ZTD.Define.MsgNetClose);
end

--链接错误(IP解析出错/超时等)，错误信息msg
local function OnError(msg)
    logError("xxx链接错误，错误信息：" .. msg)
	ZTD.GameLogin.RemovePing()
	ZTD.GameLogin.isReConnect = false
    DealConnectException()
end

--客户端主动断开socket
function ZTD_NetworkManager.CloseManual(msg)
    OnClose(msg or "CloseManual")
end

local function OnPush(data)
    local msg = ZTD.NetworkHelper.MakeMessage("Message",data)
    --游戏数据：msg.Ops ,msg.Data
    local rspName = ZTD.NetworkHelper.OnPushName[msg.Ops]
    if rspName then
		ZTD.Notification.NetworkPost(rspName, ZTD.NetworkHelper.MakeMessage(rspName, msg.Data));
    else
        logError("服务器主推协议未定义：" .. msg.Ops)
    end
end

--根据点击的场ID获取对应的端口
function ZTD_NetworkManager.GetLocalGameIP()
    local groupId = tonumber(ZTD.Flow.groupId)
    if groupId == 1 then
        return 10351
    elseif groupId == 2 then
        return 10352
    elseif groupId == 3 then
        return 10353
    elseif  groupId == 4 then
        return 10354
    end
end

function ZTD_NetworkManager.Init(gameData,callFunc)
    ZTD_NetworkManager.isFromHall = true
    if GC.SubGameInterface.GetLocalGameIP() then
        -- logError("111="..tostring(GC.SubGameInterface.GetLocalGameIP()))
        local ipAdress = string.split(tostring(GC.SubGameInterface.GetLocalGameIP()), ":")
        -- logError("ipAdress="..GC.uu.Dump(ipAdress))
        local oriPort = ipAdress[2]
        local port = oriPort and oriPort or ZTD_NetworkManager.GetLocalGameIP()
        -- logError("port="..tostring(port))
        local serverIp = ipAdress[1]..":"..port
        log("!!!获取本地配置IP="..serverIp)
        callFunc(serverIp)
	else
        local allocSuccCb = function(err, data)
            -- log("data="..GC.uu.Dump(data))
            local serverIp = data.Address
            log("  获取服务器IP成功！！ serverIp="..serverIp) 
            if callFunc then
                callFunc(serverIp)
            end 
        end
        local allocErrCb = function(err, data)
            logError("__serverIP 获取失败！！"..err)    
            ZTD.Flow.OnLogoutGame(ZTD.Flow, {LogoutType = -1})   
        end
        local param = {
            gameId = tonumber(gameData.GameID),
            groupId = tonumber(ZTD.Flow.groupId),
            allocSuccCb = allocSuccCb,
            allocErrCb = allocErrCb,
        }
        -- log("param="..GC.uu.Dump(param))
        GC.SubGameInterface.ReqAllocServer(param)
    end
end

--服务器尝试连接
function ZTD_NetworkManager.Start(serverIp)
	
    if _tmpNetState ~= _netState.Origin then return end
    _tmpNetState = _netState.Ready

    local args = IO.LauncherArgs()
    args.ConnectionStr = serverIp;
    args.AutoReconnectEnabled = false
    log("xxx请求链接服务器：" .. serverIp)
	
    IO.Launcher.Start(_hallServerTag,args,function(itype,msg,data)
        if itype == "OnPush" then
            OnPush(data)
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
    end);
end

--请求
--showWait 0.5s没有响应就开启菊花
local reqCount = 1;
function ZTD_NetworkManager.Request(name, req, successcb, errorcb, showWait)
    local requestCfg = ZTD.NetworkHelper.RequestCfg[name] or {}
	
	--logError(os.date("%Y-%m-%d %H:%M:%S:") .. "reqCount:" .. reqCount .. "---ZTD_NetworkManager.Request: "..name);
	reqCount = reqCount + 1;
    --local delayTime = requestCfg.delayTime
    local errorcb = errorcb or successcb
	if showWait then
		ZTD.Utils.ShowWaitTip(true)
	end
    local sucCb = function(...)
			if showWait then
				ZTD.Utils.CloseWaitTip()
			end
            if not successcb then return end
            --如果协议回包调用函数报错，输出协议名称(方便查bug)
            if not tools.SafeCallFunc(successcb,...) then
                logError("---network successcb error: "..name.."协议回包调用函数报错");
            end
        end
    local errCb = function(...)
			if showWait then
				ZTD.Utils.CloseWaitTip()
			end
            local args = { ... }
            local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
			if language[args[1]] then
				ZTD.ViewManager.ShowTip(language[args[1]])
			end
			
            if not errorcb then return end
            --如果协议回包调用函数报错，输出协议名称(方便查bug)
            if not tools.SafeCallFunc(errorcb,...) then
                logError("---network errorcb error: "..name.."协议回包调用函数报错");
            end
        end

    
    local msg = ZTD.NetworkHelper.MakeMessage("Message")
    if not ZTD.NetworkHelper.RequestOps[name] then 
        logError("---ZTD_NetworkManager 协议名字不存在：" .. name)
        return
    end
    msg.Ops = ZTD.NetworkHelper.RequestOps[name]
    if req then
        msg.Data = req:SerializeToString()
    end
    local req = msg:SerializeToString()
    IO.Launcher.Request(_hallServerTag,req, function(err, data)
         
        local result = {}
        local cb = function(err, data)     
			if ZTD_NetworkManager.isStop then
				logError("network is stoped!")
			end      
            if err == 0 then
                sucCb(err, data)
                return
            end
            errCb(err, data)
        end
        if ZTD.NetworkHelper.ResponseName[name] and ZTD.NetworkHelper.ResponseName[name] ~= "" then
            result = ZTD.NetworkHelper.MakeMessage(ZTD.NetworkHelper.ResponseName[name],data)
            cb(err, result)
        else
            cb(err, data)
        end      
    end)
end

--重连
function ZTD_NetworkManager.Reconnect()
	
	ZTD.GameLogin.Reconnect(function ()
		IO.Launcher.Reconnect(_hallServerTag)
	end)
end

--主动停止服务器（主动请求返回登录界面需要执行）
function ZTD_NetworkManager.StopServer()
    --无论何时，主动请求断开服务器，状态恢复到最原始
    _tmpNetState = _netState.Origin
    IO.Launcher.Stop(_hallServerTag)
	ZTD.GameLogin.RemovePing();
	ZTD_NetworkManager.isStop = true
end

function ZTD_NetworkManager.StartLoinGame()
	--IsSkipLogOutDlg在此初始化，防止跳场时弹出断网弹框
    ZTD.Flow.IsSkipLogOutDlg = false
    ZTD.GameTimer.Init()
	ZTD.GameLogin.Login()
end

------------------------------ HTTP Post 请求 ------------------------------
function ZTD_NetworkManager.HttpPost(url, data, succCb, errCb, showWait)
	if showWait then
		ZTD.Utils.ShowWaitTip(true)
	end
	
	--logError(url .. "  HttpPostdata:" .. GC.uu.Dump(data))
    ZTD_NetworkManager.PostJson(url, data, 
    function(www)

		if showWait then
			ZTD.Utils.CloseWaitTip()
		end
	--logError(url .. "   HttpPost Response:" .. GC.uu.Dump(www, nil, 6))
        if www.code == 0 and succCb then
            succCb(www.data)
		else
			ZTD.ViewManager.ShowTip(ZTD.HttpErrConfig[www.code] or "Http request error, code:" .. www.code)
			 if errCb then
				errCb(www.code)
			end
        end
    end, 
    function(err)
        if showWait then
			ZTD.Utils.CloseWaitTip()
		end
		logError("Request url:" .. url .. " Error:")
        if errCb then
            errCb()
        end
    end)
end



function ZTD_NetworkManager.PostJson(url, jsonData, onResponse, onError)
    -- local time = os.clock();
    --local logUrl = string.match(url,".com/(.-)&")
    jsonData = Json.encode(jsonData)
    local request = UnityWebRequest.New(url, 'POST');
    request.uploadHandler = UploadHandlerRaw.New(Util.ToUTF8Bytes(jsonData))
    request.downloadHandler = DownloadHandlerBuffer.New();
    request:SetRequestHeader("Content-Type", "application/json;charset=utf-8")
	
    if not GC.Platform.isIOS then
		request:SetRequestHeader("Accept-Encoding", "gzip")
	end
    request:SendWebRequest()
    local co = coroutine.start(function()
        coroutine.www(request)
        -- log(string.format("url:%s   耗时:%sms",logUrl, math.floor((os.clock() - time)*1000)))
        if request.isHttpError or request.isNetworkError then
            GC.uu.SafeCallFunc(onError, request.error)
        else
            if request.downloadHandler.text and request.downloadHandler.text ~= "" then
                local jsonStr = Util.FromUTF8Bytes(ZTD_NetworkManager.DecompressBytes(request))
                local jsonData = Json.decode(jsonStr)
                GC.uu.SafeCallFunc(onResponse, jsonData)
            else
                GC.uu.SafeCallFunc(onError)
            end
        end
        request:Dispose()
    end)
    return request, co
end

function ZTD_NetworkManager.DecompressBytes(request)

    local encode = request:GetResponseHeader("Content-Encoding");
    local decompressBytes = request.downloadHandler.data;

    if not GC.Platform.isIOS and encode == "gzip" then
        decompressBytes = Util.DecompressGZip(request.downloadHandler.data);
    end

    return decompressBytes;
end

return ZTD_NetworkManager