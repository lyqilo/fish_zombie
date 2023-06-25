local CC = require("CC")

local function param_pack( params, callback )
    table.insert(params, callback)
    return params
end

local function future( ... )
    local order = {result = true}
    local function callback( ... )
        order.res = { ... }
        if order.co then
            coroutine.resume(order.co)
        end
    end
    function order:result()
        if (self.res == nil) then
            local co, main = coroutine.running()
            if not main then 
                self.co = co 
            else 
                return 
            end
            coroutine.yield()
        end
        return unpack(self.res)
    end
    local params = {...} 
    local host, service = params[1], table.remove(params, 2)
    if type(params[#params]) == 'function' then
        params = table.remove(params)(params, callback)
    else
        params = param_pack(params, callback)
    end
    if type(host[service]) == 'function' then
        -- local p = {}
        -- for _,v in ipairs(params) do
        --     if v ~= host then
        --         table.insert(p,v)
        --     end
        -- end
        -- host[service](unpack(p))
        host[service](unpack(params))
        return order
    else
        logError('service:'..service..' not implement at '..tostring(host))
    end
end
local function asyncall( ... )
    return future(...):result()
--[[
    local co, main = coroutine.running()
    if main then
        print('Please use .call(...) in .run(func) context')
        return
    end
    local function callback( ... )
        return coroutine.resume(co, ...)
    end
    local params = {...}
    local host, service = params[1], table.remove(params, 2)
    if type(params[#params]) == 'function' then
        params = table.remove(params)(params, callback)
    else
        params = param_pack(params, callback)
    end
    if type(host[service]) == 'function' then
        return coroutine.yield(host[service](unpack(params)))
    else
        print('service:'..service..' not implement at '..tostring(host))
    end
--]]
end

local function http(...)
    -- local order = http([method,] url [, params])
    -- status, resp = order:result()
    local method, url, params
    if select('#', ...) < 3 then
        method, url, params = 'GET', ...
    else
        method, url, params = ...
    end
    method = string.upper(method)
    local support = {GET = true, POST = true}
    if not support[method] then 
        return 
    end

    local obj = {}

    local request = {}
    if method == "GET" then
        if params then
            request = BestHTTP.HTTPRequest.New(System.Uri.New(url..'?'..params))
        else
            request = BestHTTP.HTTPRequest.New(System.Uri.New(url))
        end
    else
        request = BestHTTP.HTTPRequest.New(System.Uri.New(url),BestHTTP.HTTPMethods.Post)
    end
    request.Callback = function(req, rsp)
        local callback = obj.callback
        if callback then
            callback(rsp.StatusCode, rsp.DataAsText)
        end
    end
    function obj:script(params, callback)
        if type(params) == 'function' then
            callback = params
            params = nil
        end
        self.callback = callback
        -- self.request.responseType = "JSON"

        if method == "GET" then
            self.request:Send()
        else
            -- self:setRequestHeader("Content-Type","application/x-www-form-urlencoded;")
            if params then
                self.request.RawData = Util.ToUTF8Bytes(params)
            end
            self.request:Send()
        end
    end
    if params~=nil then
        local function url_encode(params)
            if type(params) ~= 'table' then
                return CC.uu.urlEncode(tostring(params))
            end

            local pp = {}
            for k, v in pairs(params) do
                pp[#pp+1] = k..'='..CC.uu.urlEncode(tostring(v))
            end
            return table.concat(pp, '&')
        end
        return future(obj, 'script', url_encode(params))
    end
    obj.request = request
    return future(obj, 'script')
end

local function runProcess( ... )
    local func = select(-1, ...)
    assert(type(func)=='function', 'the last argument must be a function for coroutine process')
    local co = coroutine.create(func)

    local function process( ... )
        coroutine.resume(co, ...)
    end
    process(...)
    return process
end

local target = {
    call = asyncall,
    book = future,
    http = http,
    run = runProcess
}

return target

--[[
-- example

local AsynCall = require("Common/AsynCall")

local model = {}
function model:TestFunc(params, callback)
    local data = nil

    local cb = function ()
        if data then
            callback(0,"ok",data)
        else
            callback(-1,"data is nil",data)
        end
    end

    -- do something and wait
    data = {1,2,3}

    cb()
end

AsynCall.run(function ()
    for i=1,1 do
        local code, msg, info = AsynCall.call(model, 'TestFunc', 'p1')
        if code == 0 then
            logError(msg)
            logError(info)
        else
            logError(msg)
        end

        code, msg, info = AsynCall.call(model, 'TestFunc', 'p2')
        if code == 0 then
            logError(msg)
            logError(info)
        else
            logError(msg)
        end
    end

end)

--]]