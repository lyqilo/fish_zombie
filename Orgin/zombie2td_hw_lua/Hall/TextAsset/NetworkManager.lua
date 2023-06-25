local CC = require("CC")
local uu = CC.uu
local ViewManager = CC.ViewManager
local DTproto = CC.proto
local HallNotificationCenter = CC.HallNotificationCenter
local Notifications = CC.Notifications
local LotteryProto = require "Model/LotteryNetwork/game_message_pb"
local Response = require("Model/LotteryNetwork/Response")
local MessageManager = require("Model/LotteryNetwork/MessageManager")
local gameServerName = "Server_Lottery"
local reconnectTryTimes = 3
local reconnectInterval = 2

local NetworkManager = {}

--请求列表配置 ，一旦协议改名，改下这即可
local REQUESTLIST = {
    LOGIN = "CSLoginWithTokenReq",
    CSPurchaseLotteryReq = "CSPurchaseLotteryReq",
    CSRandLotteryNumberReq = "CSRandLotteryNumberReq",
    CSLotteryPurchaseRecodeReq = "CSLotteryPurchaseRecodeReq",
    CSLotteryHistoryRecodeReq = "CSLotteryHistoryRecodeReq",
    CSLotteryDetailRecodeReq = "CSLotteryDetailRecodeReq",
    CSLotteryLatternReq = "CSLotteryLatternReq",
    CSFirstPrizeRecodeReq = "CSFirstPrizeRecodeReq",
    CSLotteryRankReq = "CSLotteryRankReq",
    CSPingReq = "CSPingReq",
}
NetworkManager.REQUESTLIST = REQUESTLIST

local _OnClose
local _OnError
local _OnOpen
local _OnPush
local _StartReconnet
local _Reconnect
local _InsertRequest
local _DeleteRequest
local _ShowLoading
local _CloseLoading

local requestList = {}


function NetworkManager.Start(param)
    local args = IO.LauncherArgs()
    args.ConnectionStr = param.serverIp
    args.AutoReconnectEnabled = false
    log("NetworkManager:Start 请求链接服务器：" .. args.ConnectionStr)
    _ShowLoading(NetworkManager)
    IO.Launcher.Start(gameServerName,args,function(itype,msg,data)
        if itype == "OnPush" then
            _OnPush(data)
        end
        if itype == "OnOpen" then
            _CloseLoading(NetworkManager)
            _OnOpen()
        end
        if itype == "OnClose" then
            _OnClose(msg)
        end
        if itype == "OnError" then
            _OnError(msg)
        end
    end);
end


function NetworkManager.Request(name, reqData, cb)
    local MessageManager = MessageManager.Inst()
    --获取下请求的信息配置
    local proConfig = MessageManager:GetRequestProConfig(name)
    if not proConfig then
        logError("没找到请求协议配置 name:" .. name)
        return
    end
    if name ~= "LoginWithToken" then
        uu.Log(reqData,string.format("请求的数据 name=%s",name))
    end
    local msg = NetworkManager.MakeMessage("Message")
    msg.Ops = proConfig.Ops
    --msg.PlayerId = CC.GC.Player.Inst():GetLoginInfo().PlayerId
    if reqData then
        msg.Data = reqData:SerializeToString()
    end
    local req_send = msg:SerializeToString()
    
    -- 保存请求到队列
    _InsertRequest(name,reqData,cb)

    --发送请求
    IO.Launcher.Push(gameServerName,req_send)
    -- , function(code, data)
    --     -- 请求回来，从队列中删除
    --     _DeleteRequest(name)

    --     local result = data
    --     if proConfig.ResName then--如果有ResName表示处理结果数据
    --         result = NetworkManager.MakeMessage(proConfig.ResName,data)
    --     end
    --     uu.Log(result,string.format("请求收到的数据 name=%s code=%d",name,code))

    --     if cb then
    --         cb(code, result)
    --     end
    -- end)
end

--- CS推送
function NetworkManager.Push(name, push)
	local MessageManager = MessageManager.Inst()
   --获取下请求的信息配置
	local proConfig = MessageManager:GetpushProConfig(name)
	if not proConfig then
		logError("没找到客户端主动协议配置 name:" .. name)
		return
	end
	uu.Log(push,string.format("push name=%s ops=%d",proConfig.Name,proConfig.Ops))
	local msg = NetworkManager.MakeMessage("Message")
    msg.Ops = proConfig.Ops
    
    if push then
        msg.Data = push:SerializeToString()
    end
    
    local data = msg:SerializeToString()
    IO.Launcher.Push(gameServerName,data)
end

--根据名称生成消息数据
function NetworkManager.MakeMessage(name,buff)
    local msg = LotteryProto[name] or DTproto.client_pb[name]
	if msg == nil then
		logError("--------------协议不存在：" .. name)
	else
		msg = msg()
		if buff and buff ~= "" then
            msg:ParseFromString(buff)
        end
    end
	return msg
end

function NetworkManager.Stop()
    IO.Launcher.Stop(gameServerName)
end

function NetworkManager.ReRequest()
    -- 这两个，在断线重连时已经处理了，所以要删掉
    _DeleteRequest(NetworkManager.REQUESTLIST.LOGIN)
    
    local tmpRequestList = requestList
    requestList = {}
    for i,request in ipairs(tmpRequestList) do
        NetworkManager.Request(request.name,request.reqData,request.cb)
    end
end

_StartReconnet = function()
    NetworkManager.reconnectCount = (NetworkManager.reconnectCount or 0) + 1
    if NetworkManager.reconnectCount > reconnectTryTimes then
        NetworkManager.reconnectCount = nil
        _CloseLoading(NetworkManager)
        HallNotificationCenter.inst():post(Notifications.LotteryNetworkClose)
        return
    end

    if NetworkManager.reconnectCO then
        uu.CancelDelayRun(NetworkManager.reconnectCO)
    end
    NetworkManager.reconnectCO = uu.DelayRun(reconnectInterval,function() 
        if NetworkManager.reconnectCount == 1 then
            _ShowLoading(NetworkManager)
        end
        _Reconnect()
    end)
end

--服务器的推送
_OnPush = function(data)
    --推送配置
    local msg = NetworkManager.MakeMessage("Message",data)
	local MessageManager = MessageManager.Inst()
    local proConfig = MessageManager:GetOnpushProConfig(msg.Ops)
    if proConfig then
        if type(proConfig.CallBack) == "function" then
            local result = NetworkManager.MakeMessage(proConfig.Name,msg.Data)
            uu.Log(result,string.format("服务器推送的数据 %s",proConfig.Name))
            uu.SafeCallFunc(proConfig.CallBack,result)
        end
    else
        logError("没找到服务器推送协议配置 " .. msg.Ops)
    end
end

_OnOpen = function()
    --链接服务器成功
    log("NetworkManager.OnOpen 链接服务器成功")
    if NetworkManager.reconnectCO then
        uu.CancelDelayRun(NetworkManager.reconnectCO)
        NetworkManager.reconnectCount = nil
        _CloseLoading(NetworkManager)
    end
    HallNotificationCenter.inst():post(Notifications.LotteryNetworkOpen)
end

_OnClose = function(reason)
    --服务器关闭，原因reason
    logError(string.format("%s服务器关闭：%s",gameServerName,reason))
    if reason == "Stop" then
        HallNotificationCenter.inst():post(Notifications.LotteryNetworkClose)
    else
        _StartReconnet()
    end
end

_OnError = function(msg)
    --链接错误，错误信息msg
    logError(string.format("%s链接错误，错误信息：%s",gameServerName,msg))
    _StartReconnet()
end

-- 重连
_Reconnect = function()
    IO.Launcher.Reconnect(gameServerName)
end

_InsertRequest = function(name,reqData,cb)
    local request = {}
    request.name = name
    request.reqData = reqData
    request.cb = cb
    requestList[#requestList+1] = request
end

_DeleteRequest = function(name)
    for i,request in ipairs(requestList) do
        if request.name == name then
            requestList[i] = nil
        end
    end
end

_ShowLoading = function(self)
    if not self.loadingFlag then
        ViewManager.ShowLoading()
        self.loadingFlag = true
    end
end

_CloseLoading = function(self)
    self.loadingFlag = false
    ViewManager.CloseLoading()
end

return NetworkManager