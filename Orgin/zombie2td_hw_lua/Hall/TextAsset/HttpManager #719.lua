--------------------------------------------
--@Description: http request
--@Author: Xie Ling Yun
--------------------------------------------

local CC = require("CC")
local NetworkTools = require("SubGame/NetworkFramework/NetworkTools")
local NetworkManagerBase = require("SubGame/NetworkFramework/NetworkManagerBase")
local M = CC.class2("HttpManager",NetworkManagerBase)

local logTag = "HttpManager"
local _HttpRequestWrap

function M:ctor(gameProto, messageCenter)
    self.messageCenter = messageCenter
end

local JsonHandleResultFunc = function(self, name, buff)
    local result
    local data = Json.decode(buff)
    local En = data.En

    if not En then
        En = 0
        result = data
    else
        if En == 0 and data.Data then
            result = Json.decode(data.Data)
        end
    end
    return En, result
end

-- 请求内容用json格式
-- 服务器回包用json格式
function M:HttpRequestJsonWithJson(name, req, url)
    _HttpRequestWrap(self, name, req, url, JsonHandleResultFunc, "JSON")
end

-- 请求内容用protobuffer
-- 服务器回包用json格式
function M:HttpRequestJsonWithProto(name, req, url)
    _HttpRequestWrap(self, name, req, url, JsonHandleResultFunc, "PROTO")
end

local ProtoHandleResultFunc = function(self, name, buff)
    local result
    local data = self:MakeMessage("HttpResult", buff)
    if data:HasField("Data") then
        result = self:MakeMessage(NetworkTools.GetRspMessageName(name), data.Data)
    end
    return data.En, result
end

-- 请求内容用protobuffer
-- 服务器回包用jprotobuffer
function M:HttpRequestProtoWithProto(name, req, url)
    _HttpRequestWrap(self, name, req, url, ProtoHandleResultFunc, "PROTO")
end

_HttpRequestWrap = function(self, name, req, url, handleResultFunc, dataType)
    local wwwForm = nil
    if req then
        if dataType == "JSON" then
            wwwForm = Util.ToUTF8Bytes(Json.encode(req))
        elseif dataType == "PROTO" then
            wwwForm = req:SerializeToString()
        end
    end
    local comsumeKey = self:GetTimeConsumeKey(self, name)
    self.comsumeRecordArray[comsumeKey] = os.clock()

    local okback = function (www)
        local t = self.comsumeRecordArray[comsumeKey] - os.clock()
        if self.bDebug then
            log(string.format("[%s]reqeust %s -> response comsume %dms",logTag,name,t))
        end

        local buff = Util.ByteToLuaByteBuffer(www.downloadHandler.data)
        local code, result = handleResultFunc(self, name, buff)

        if result then
            if self.bDebug then
                local rspName = NetworkTools.GetRspMessageName(name)
                CC.uu.Log(result, string.format("[%s]receive data name=%s code=%d", logTag, rspName, code))
            end
        end
        self.messageCenter:PostResponse(name, code, result)
    end
    local errback = function(err)
        local t = self.comsumeRecordArray[comsumeKey] - os.clock()
        if self.bDebug then
            log(string.format("[%s]reqeust %s -> response comsume %dms",logTag,name,t))
        end

        log(string.format("[%s]reqName:%s  error:%s  url:%s", logTag, name, tostring(err), url))
        self.messageCenter:PostResponse(name, -1)
    end
    if wwwForm then
        CC.HttpMgr.Post(url,wwwForm,okback,errback)
    else
        CC.HttpMgr.Get(url,okback,errback)
    end
end

return M