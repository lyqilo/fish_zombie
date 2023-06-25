local CC = require("CC")
local unicode = require("Common/unicode")
--uu是UnityFrameWork Utils的缩写
--用来表示命名空间
local uu = {}

function uu.LoadImgSpriteFromAb(abName, path)
    local texture = ResourceManager.LoadAsset(abName, path)
    return Sprite.Create(texture, UnityEngine.Rect(0, 0, texture.width, texture.height), Vector2(0.5, 0.5))
end

function uu.LoadAssets(bundleName, prefabName, callback)
    ResourceManager.LoadAssets(bundleName, prefabName, callback)
end

function uu.LoadImgSprite(path,abName)
    --默认从image.u3d 或者xxx_image.u3d这个ab包内读取
    if path == nil or path == "" then
        logError("LoadImgSprite path error")
        return
    end
    abName = abName or "image"
    local texture = ResourceManager.LoadAsset(abName, path)
    if texture then
        return Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5))
    end
end

function uu.LoadPrefab(bundleName, prefabName, parent, name, useSelfLayer)
    return ResourceManager.LoadPrefab(bundleName,
            prefabName, 
            parent or GameObject.Find("Canvas/Main").transform,
            name or prefabName,
            useSelfLayer)
end

function uu.LoadHallPrefab(bundleName, prefabName, parent, name, useSelfLayer)
    local CC = require("CC");
    local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Prefab[prefabName];
    return ResourceManager.LoadPrefab(abName or "prefab",
            prefabName, 
            parent or GameObject.Find("Canvas/Main").transform,
            name or prefabName,
            useSelfLayer)
end

--查找对象--
function uu.findObject(str)
	local obj = GameObject.Find(str);
    return obj and obj.transform
end

function uu.destroyObject(obj)
    if obj and tostring(obj) ~= "null" then
	   GameObject.Destroy(obj.gameObject or obj.transform.gameObject)
    end
end

-- 判断mono对象是否为空
function uu.IsNil(uobj)
    return uobj == nil or uobj:Equals(nil)
end

function uu.newObject(prefab, parent)
    if not prefab then return end;
    local object = GameObject.Instantiate(prefab);
    if parent then
        object.transform:SetParent(parent.transform, false);
    end
    return object;
end

function uu.UguiAddChild(parent, prefab, childName)
    if not prefab then
        log("Can not add null prefab!!!")
        return
    end
    local newObj = uu.newObject(prefab)
    if parent then
        newObj.transform:SetParent(parent.transform, false)
    end
    if childName and type(childName) == "string" then
        newObj.name = childName
    end
    newObj:SetActive(true)
    return newObj
end

function uu.MakeFunc( func, ... )
    local args = {...}
    return function()
        if func then
            func(unpack(args))
        end
    end
end

function uu.SafeCallFunc( func, ... )
    if func then
        -- 开发下的异常必须处理
        if CC.DebugDefine.GetDebugMode() then
            func(...)
            return true
        else
            local ret, err = pcall(func, ...)
            if not ret then
                logError(err)
                return false
            end
            return true
        end
    end
    return false
end

function uu.SafeDoFunc( func, ... )
    if func then
        -- 开发下的异常必须处理
        if CC.DebugDefine.GetDebugMode() then
            return func(...)
        else
        	local result = {}
            local ret, err = pcall(function(...)
            	result = {func(...)}
            end, ...)
            if ret then
            	return unpack(result)
            end
            logError(err)
        end
    end
end

function uu.DelayRun( second, func, ... )
	local args = {...}
	return coroutine.start(function()
		if second ~= nil then
            coroutine.wait(second)
        end
		func(unpack(args))
	end);
end

function uu.CancelDelayRun( co )
    if co then
        if co ~= coroutine.running() then
            coroutine.stop(co)
        else
            uu.DelayRun(nil, coroutine.stop, co)
        end
    end
end

function uu.StartTimer( delay, func, times, forever )
    return coroutine.start(function()
        times = times or 1
        repeat
            coroutine.wait(delay);
            uu.SafeCallFunc(func)
            times = times - 1
        until(times == 0 or forever == false)
    end)
end

function uu.StopTimer(timer)
    uu.CancelDelayRun(timer)
end

function uu.isString( value )
    return type(value) == "string"
end

function uu.isNumber( value )
    return type(value) == "number"
end

function uu.isFunction( value )
    return type(value) == "function"
end

function uu.isTable( value )
    return type(value) == "table"
end

--合并2table
function uu.merge(dst, src)
    table.foreach(src, 
        function(i,v) 
            dst[i] = v 
        end
    )
end

function uu.StringFromat( srcStr,replacestr,...)
    local arg = {...}
    for i=1,#arg do
        srcStr = string.gsub(srcStr,replacestr,arg[i],1)
    end
    return srcStr
end


--把这样的数字1234567转换成这样的字符串1,234,567
function uu.numberToStrWithComma(num)
    local strNum = tostring(num)
    local lenStr = string.len(strNum)
    local ret = ""
    for i = 1 , math.ceil(lenStr/3) do
        local startIdx = lenStr - 3 * i + 1
        local endIdx = lenStr - 3 * (i - 1)
        if startIdx < 1 then startIdx = 1 end
        if i == 1 then
            ret = string.sub(strNum,startIdx,endIdx) .. ret
        else
            ret = string.sub(strNum,startIdx,endIdx) .. "," .. ret
        end
    end
    return ret
end

--用于把AssetsList.ini里面的字符串末尾换行符全部换成'\r\n'形式
function uu.addEnterAscii(str)
  local str1 = string.gsub(str,'\r\n','\n')
  local str2 = string.gsub(str1,'\r','\n')
  local ret = string.gsub(str2,'\n','\r\n')
  return ret
end

--手机号码加密，例如17712345678显示成177XXXXX678
function uu.phoneNumberToSecret(str,startIndex,endIndex)
    local len = string.len(tostring(str))
    local ret = ""
    for i = 1,len do
        if i > (startIndex or 3) and i < (endIndex or 9) then
            ret = ret .. "*"
        else
            ret = ret .. string.sub(str,i,i)
        end
    end
    return ret
end

function uu.now()
    return os.date("%Y-%m-%d %X")
end


function uu.TimeOut(UserTime)
    return os.date("%Y-%m-%d %H:%M:%S",UserTime)
end

function uu.TimeOut2(UserTime)
    return os.date("%m-%d %H:%M:%S",UserTime)
end

function uu.TimeOut3(UserTime)
    return os.date("%d-%m-%Y %H:%M:%S",UserTime)
end

function uu.TimeOut4(UserTime)
	return os.date("%H:%M:%S",UserTime)
end

function uu.TimeOut5(UserTime)
    return os.date("%m/%d/%Y %H:%M:%S",UserTime)
end

function uu.date2time(date)
    --data = "2017-06-22 17:27:20"
    local Y = string.sub(date, 1, 4)
    local M = string.sub(date, 6, 7)
    local D = string.sub(date, 9, 10)
    local h = string.sub(date, 12, 13)
    local m = string.sub(date, 15, 16)
    local s = string.sub(date, 18, 19)
    return os.time({year=Y, month=M, day=D, hour=h, min=m, sec=s}) or 0
end

function uu.date3time(date)
    --data = "06-22-2017 17:27:20"
    local D = string.sub(date, 1, 2)
    local M = string.sub(date, 4, 5)
    local Y = string.sub(date, 7, 10)
    local h = string.sub(date, 12, 13)
    local m = string.sub(date, 15, 16)
    local s = string.sub(date, 18, 19)
    return os.time({year=Y, month=M, day=D, hour=h, min=m, sec=s}) or 0
end

function uu.date4time(date)
    --data = "12/25/2018 17:54:29"
    local M = string.sub(date, 1, 2)
    local D = string.sub(date, 4, 5)
    local Y = string.sub(date, 7, 10)
    local h = string.sub(date, 12, 13)
    local m = string.sub(date, 15, 16)
    local s = string.sub(date, 18, 19)
    return os.time({year=Y, month=M, day=D, hour=h, min=m, sec=s}) or 0
end

function uu.getUserMac()
    local CC = require("CC")
    local usermac = "00:00:00:00:00:00"
    local temp = CC.Platform.GetDeviceId()
    if CC.Platform.isIOS then
        if temp ~= "" then
            usermac = temp
        end
    elseif CC.Platform.isAndroid then
        if temp == "" then
            temp = Client.GetMACAddress()
            if temp ~= "" then
                usermac = temp
            end
        else
            usermac = temp
        end
    end

    return usermac
end

function uu.TimeFormat(BeginHour,BeginMin,EndHour,EndMin)
    if BeginHour < 10 then
        BeginHour = "0"..BeginHour
    end
    if BeginMin < 10 then
        BeginMin = "0"..BeginMin
    end
    if EndHour < 10 then
        EndHour = "0"..EndHour
    end
    if EndMin < 10 then
        EndMin = "0"..EndMin
    end
    return BeginHour..":"..BeginMin.."-"..EndHour..":"..EndMin
end

--ticket转换成： 00:00:00:00这种格式
function uu.TicketFormatDay(Second,DontFormat)
    local day = math.modf(Second / 86400)
    local szDayText = tostring(day)
    if not DontFormat and (day < 10) then
        szDayText = "0"..szDayText
    end
    return szDayText;
end

--ticket转换成： 00:00:00:00这种格式
function uu.TicketFormat3(Second)
    local day = math.modf(Second / 86400)
    local nHour = math.modf((Second - day * 86400) / 3600 )
    local nMin = math.modf((Second - (day * 86400) - (nHour * 3600)) / 60)
    local nSec = math.modf(Second % 60)
    local szDayText = tostring(day)
    local szHourText = tostring(nHour)
    local szMinText = tostring(nMin)
    local szSecText = tostring(nSec)
    if (day < 10) then
        szDayText = "0"..szDayText
    end
    if (nHour < 10) then
        szHourText = "0"..szHourText
    end
    if (nMin < 10) then
        szMinText = "0"..szMinText
    end
     if (nSec < 10) then
        szSecText = "0"..szSecText
    end   
    return szHourText..":"..szMinText..":"..szSecText;
end

--ticket转换成： 00:00:00:00这种格式
function uu.TicketFormat2(Second)
    local day = math.modf(Second / 86400)
    local nHour = math.modf((Second - day * 86400) / 3600 )
    local nMin = math.modf((Second - (day * 86400) - (nHour * 3600)) / 60)
    local nSec = math.modf(Second % 60)
    local szDayText = tostring(day)
    local szHourText = tostring(nHour)
    local szMinText = tostring(nMin)
    local szSecText = tostring(nSec)
    if (day < 10) then
        szDayText = "0"..szDayText
    end
    if (nHour < 10) then
        szHourText = "0"..szHourText
    end
    if (nMin < 10) then
        szMinText = "0"..szMinText
    end
     if (nSec < 10) then
        szSecText = "0"..szSecText
    end   
    return szDayText..":"..szHourText..":"..szMinText..":"..szSecText;
end

--ticket转换成： 00:00:00这种格式
function uu.TicketFormat(nTicket,noHour)
    local nHour = math.modf(nTicket / 3600);
    local nMin = math.modf((nTicket - nHour * 3600) / 60);
    local nSec = math.modf(nTicket % 60);
    local szHourText = tostring(nHour);
    local szMinText = tostring(nMin);
    local szSecText = tostring(nSec);
    if (nHour < 10) then
        szHourText = "0" .. szHourText;
    end
    if (nMin < 10) then
        szMinText = "0" .. szMinText;
    end
    if (nSec < 10) then
        szSecText = "0" .. szSecText;
    end
    return (noHour and "" or szHourText..":")..szMinText..":"..szSecText;
end

--ticket转换成： 00:00:00这种格式
function uu.TicketReturnText(nTicket,noHour)
    local nHour = math.modf(nTicket / 3600);
    local nMin = math.modf((nTicket - nHour * 3600) / 60);
    local nSec = math.modf(nTicket % 60);
    local szHourText = tostring(nHour);
    local szMinText = tostring(nMin);
    local szSecText = tostring(nSec);
    if (nHour < 10) then
        szHourText = "0" .. szHourText;
    end
    if (nMin < 10) then
        szMinText = "0" .. szMinText;
    end
    if (nSec < 10) then
        szSecText = "0" .. szSecText;
    end
    return (noHour and "" or szHourText),szMinText,szSecText;
end

function uu.HttpGet( url, onResponse, onError, onFinish, timeOut)
    --防止http请求阻塞
    if nil == url or "" == url then
        uu.SafeCallFunc(onError, "HttpGet Url is null")
        return nil,nil
    end
    local www = BestHttpWWW(url)
    www.timeout = timeOut or 15;
    local co = coroutine.start(function()
        www:Send()
        coroutine.www(www)
        if not www.error then
            uu.SafeCallFunc(onResponse, www)
        else
            uu.SafeCallFunc(onError, www.error,www)
        end
        uu.SafeCallFunc(onFinish, www)
        www:Dispose()
    end)
    return www, co
end

function uu.HttpWWWGet( url, onResponse, onError, onFinish )
    --防止http请求阻塞
    if nil == url or "" == url then
        uu.SafeCallFunc(onError, "HttpGet Url is null")
        return nil,nil
    end
    local www = WWW(url)
    local co = coroutine.start(function()
        coroutine.www(www)
        if not www.error then
            uu.SafeCallFunc(onResponse, www)
        else
            uu.SafeCallFunc(onError, www.error,www)
        end
        uu.SafeCallFunc(onFinish, www)
    end)
    return www, co
end

function uu.HttpGet2(url, onResponse, onError, timeout)
    --防止http请求阻塞
    if nil == url or "" == url then
        uu.SafeCallFunc(onError, "HttpGet2 Url is null")
        return nil,nil
    end
    --访问国外地址,使用UnityWebRequest,可设置超时时间,防止请求阻塞
    local www = UnityEngine.Networking.UnityWebRequest.Get(url)
    www.timeout = timeout or 5;    --超时默认设置5秒
    local co = coroutine.start(function()
        www:SendWebRequest()
        coroutine.www(www)
        if not www.error then
            uu.SafeCallFunc(onResponse, www)
        else
            uu.SafeCallFunc(onError, www.error)
        end
    end)
    return www, co
end

function uu.HttpPost(url, wwwForm, onResponse, onError, onFinish)
    --防止http请求阻塞
    if nil == url or "" == url then
        uu.SafeCallFunc(onError, "HttpPost Url is null")
        return nil,nil
    end
    local www = BestHttpWWW(url, wwwForm)
    local co = coroutine.start(function()
        www:Send()
        coroutine.www(www)
        if not www.error then
            uu.SafeCallFunc(onResponse, www)
        else
            uu.SafeCallFunc(onError, www.error)
        end
        uu.SafeCallFunc(onFinish, www)
        www:Dispose()
    end)
    return www, co
end

function uu.HttpGetJson( url, onResponse, onError, onFinish )
    return  uu.HttpGet(url, function( www )
        log(www.text)
        local data = Json.decode(www.text).result
        if data.value == "0" then
            uu.SafeCallFunc(onResponse, data.data, www)
        else
            uu.SafeCallFunc(onError, data.message, www)
        end
    end, onError, onFinish)
end

function uu.initEnumTable( enumTable )
    local t = {}
    for name, id in pairs(enumTable) do      
        t[id] = name
    end
    for id, name in pairs(t) do
        enumTable[id] = name
    end
end

function uu.SafeRequire(path)
    local mdl = require(path)
    if type(mdl) == 'table' and mdl.InitRequire then
        mdl.InitRequire()
    end
    return mdl
end

 --针对UI交互的工具工具函数
function uu.UIAction(target)
    local CC = require("CC")
    local gameObject = target.transform.gameObject
    target.transform:AddComponent(typeof(Image)).color = Color(0,0,0,0)
    target.transform = gameObject.transform
    target.transform.size = Vector2(3000, 3000)
    target.transform.localScale = Vector3(0.5,0.5,1)
    target:RunAction(target, {"fadeTo", 179, 0.3})  -- 70%透明度
    target:RunAction(target, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack})
end

function uu.UIFadeOut(target)
    local gameObject = target.transform.gameObject
    target.transform = gameObject.transform

    target:RunAction(target, {"fadeToAll", 100, 0})
    target:RunAction(target, {"fadeToAll", 255, 0.2})
end

function uu.SetEmojiLimit( inputField )
    inputField.onValidateInput = function (text, charIndex, addedChar)
        logError("emoji "..addedChar)
        -- local asciiString = string.char(addedChar)
        -- logError("asciiString "..asciiString)

        -- Enclosed characters ( 24C2 - 1F251 )
        -- if addedChar >= 9312 and addedChar <= 9471 then
        --     return 0
        -- end
        -- Dingbats ( 2702 - 27B0 )
        if addedChar >= 9984 and addedChar <= 10175 then
            return 0
        end
        -- Emoticons ( 1F601 - 1F64F )
        if addedChar >= 128512 and addedChar <= 128591 then
            return 0
        end
        -- Transport and map symbols ( 1F680 - 1F6C0 )
        -- if addedChar >= 128640 and addedChar <= 128767 then
        --     return 0
        -- end
        -- emoji
        -- [0xE001,0xE05A]
        -- [0xE101,0xE15A]
        -- [0xE201,0xE253]
        -- [0xE301,0xE34D]
        -- [0xE401,0xE44C]
        -- [0xE501,0xE537]
        if addedChar >= 57345 and addedChar <= 57434 or addedChar >= 57601 and addedChar <= 57690 or addedChar >= 57857 and addedChar <= 57939 or addedChar >= 58113 and addedChar <= 58189 or addedChar >= 58369 and addedChar <= 58444 or addedChar >= 58625 and addedChar <= 58679 then
            return 0
        end
        return addedChar
    end
end

function uu.GetComponent(obj, typeName)
    if not obj then
        log("Can not getcomponent from null!!!")
        return nil
    end
    if obj:GetComponent(typeName) == nil then
        log("component not find : " .. obj.name .. "-->" .. typeName)
        return nil
    end
    return obj:GetComponent(typeName) 
end

function uu.SetText(obj, str)
    local u_text = uu.GetComponent(obj, "Text")
    if u_text then
        u_text.text = str
    end
end

-- image需要添加相应图片路径和名称
function uu.SetImage(obj, image, abName)
    local u_image = uu.GetComponent(obj, "Image")
    if u_image then
        u_image.sprite = uu.LoadImgSprite(image, abName)
    end
end

function uu.SetRawImage(obj, image, abName)
    local u_image = uu.GetComponent(obj, "RawImage")
    if u_image then
        u_image.texture = ResourceManager.LoadAsset(image, abName)
    end
end

function uu.SubSetImage( obj, childNode, texture )
    local img = uu.SubGetObject(obj, childNode, "Image")
    img.sprite = uu.LoadImgSprite(texture)
end

function uu.SetHallImage(obj, path,setnativesize)
    local CC = require("CC")
    local u_image = uu.GetComponent(obj, "Image")
    if u_image then
        local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[path];
        u_image.sprite = uu.LoadImgSprite(path, abName or "image");
        
        if setnativesize then
            u_image:SetNativeSize()
        end
    end
end

function uu.SetHallRawImage(obj, path, abName)
    local u_image = uu.GetComponent(obj, "RawImage")
    if u_image then
        local abName = abName or CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[path];
        u_image.texture = ResourceManager.LoadAsset(abName, path)
    end
end

function uu.SubSetText( obj, childNode, str )
    local _text = uu.SubGetObject(obj, childNode, "Text")
    _text.text = str
end

function uu.SubGetObject( node, childNode, typeName )
    return node.transform:SubGet(childNode, typeName)
end

function uu.DestroyAllChilds( transform, flag )
    Util.ClearChild(transform, flag or false)
end

function uu.ShowUIWithFadeOut(outUiName, dTime)
    local CC = require("CC")
    CC.ViewManager.Replace(outUiName)
    ActionManager:UIFadeOut(outUiName, dTime or 1, nil)
end

function uu.changeScene(sceneName, isAsync, callback)        
    if isAsync == nil then
        isAsync = true
    end
    LuaFramework.SceneManager.ChangeScene(sceneName, isAsync, function ()
        if callback then
            callback()
        end
    end)
end

--进入大厅场景
function uu.EnterMainScene()
    logError("！！！该API已废弃,请使用ViewManager.GameEnterMainScene()\n" .. debug.traceback())
    local CC = require("CC")
    CC.ViewManager.GameEnterMainScene()
end

function uu.ClassView( viewName, bundleName, super )
    --警告，该ClassView默认用于创建大厅界面类，游戏内的请自定义super
    local CC = require("CC")
    super = super or CC.HallViewBase
    bundleName = bundleName or "prefab"
    local c = CC.class2(viewName,super)
    c.bundleName = bundleName
    c.viewName = viewName
    return c
end

--创建View，该方法仅兼容游戏调用CreateView创建界面！大厅界面统一使用CreateHallView
function uu.CreateView( view, ... )
    local CC = require("CC")
    local obj = nil
    if uu.isString(view) then
        local viewName = view
        local viewClass = require("View/" .. viewName)
        if viewClass then
            obj =  viewClass.new(...)
            obj:Create()
        else
            logError('CreateView '..viewName.." not find!");
        end
    else
        logError("view must be string")
    end
    return obj
end

--创建大厅界面
function uu.CreateHallView( viewName, ... )
    local CC = require("CC")
    local obj = nil
    if uu.isString(viewName) then
        if CC.ChannelMgr.GetTrailStatus() then
            local trailViewName = CC.ChannelMgr.GetTrailView(viewName)
            if trailViewName then
                viewName = trailViewName
            end
        end
        local viewClass = CC.ViewCenter[viewName]
        if viewClass then
            obj = viewClass.new(...)
            obj:Create()
        else
            logError('uu.CreateHallView '..viewName.." not find!") 
        end
    end
    return obj
end

-- type:1为大厅，2位游戏内
function uu.panelShowAction(viewHandle, gPanel, type) 
    local CC = require("CC")
    local distance = -800
    if type ~= 1 then
        distance = 800
    end
    viewHandle:RunAction(gPanel,  {"localMoveBy", distance, 0, 0.2, from=1, ease=CC.Action.EOutSine})
end

function uu.ReplaceFace(message, size, isNormal)
    local CC = require("CC")
    --防止玩家自行写富文本，伪造官方聊天
    local message = message
    if isNormal then
        message = string.gsub(message,"<[%s]*/?[%s]*[%w]*[=]*#*[%w]*>?","") -- </?\w+=[\w#'"]+>
    end
    local ret = ""
    local isz = size or 25
    local r_idx = string.find(message, ']')
    while r_idx do
        local len = string.len(message)
        local rec = string.sub(message, 1, r_idx)
        local l_idx = uu.StringLastFind(rec, '%[')
        
        if l_idx and (r_idx - l_idx <= CC.ChatConfig.CHAT_FACE_LENGHT + 1) then
            local front = (l_idx > 1) and (string.sub(message, 1, l_idx - 1)) or ""
            local name = string.sub(message, l_idx + 1, r_idx - 1)
            local temp = string.format("%s<size=%d>[%s]</size>", front, isz, name)
            ret = ret .. temp
        else
            ret = ret .. string.sub(message, 1, r_idx)
        end
        -- next
        local i = r_idx + 1
        if i < len then
            message = string.sub(message, i, len)
        else
            message = ""
        end
        r_idx = string.find(message, ']')
    end
    ret = ret .. message
    return ret
end

function uu.splitString(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end


function uu.StringLen(str)
    local curIndex = 0
    local lastCount = 1
    local i = 1
    repeat 
        lastCount = uu.StringByteCount(str, i)
        i = i + lastCount
        curIndex = curIndex + 1
    until(lastCount == 0)
    return curIndex - 1
end

--返回当前字符实际占用的字符数
function uu.StringByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte >= 192 and curByte < 223 then
        byteCount = 2
    elseif curByte >= 224 and curByte <239 then
        byteCount = 3
    elseif curByte >= 240 and curByte <= 247 then
        byteCount = 4
    end
    return byteCount
end

function uu.StringLastFind(str, pattern)
    -- 反向搜索:xxxxxxixx i的位置
    
    --1、先把str反转
    --2、从头开始查找i的位置(index)
    --3、str的长度 - index + 1 = i反向搜索的位置
    local rev = string.reverse(str)
    --local key = string.reverse(pattern)
    local pos = string.find(rev, pattern)
    if not pos then
        return nil
    end
    local _i = string.len(str) - pos + 1
    return _i
end

--人数数值格式化
function uu.NumberFormat(number)
    if not number then
        logError("uu.NumberFormat:必须传值");
        return
    end
    if (number < 1000) then
        return tostring(number)
    elseif (number < 1000000) then
        return uu.MergeNumber(number, 1000).."K"
    else
        return uu.MergeNumber(number, 1000000).."M"
    end
end

function uu.ChipFormat(number,showAll)
    if not number then
        logError("uu.NumberFormat:必须传值");
        return
    end
    if showAll then
        return uu.Chipformat2(number)
    else
        return Util.MergeChip(number)
    end
end

function uu.Chipformat2(num)
    local str1 =""
	local t = uu.splitString(num,".")
    local str,str2 = t[1],t[2]
    local strLen = string.len(str)
        
    for i=1,strLen do
        str1 = string.char(string.byte(str,strLen+1 - i)) .. str1
        if i%3 == 0 then
            if strLen - i ~= 0 then
                str1 = ","..str1
            end
        end
    end
    return str2 and str1 .. "." .. str2 or str1
end

function uu.DiamondFortmat(number)
    if not number then
        logError("uu.NumberFormat:必须传值");
        return
    end

    local function formatnumberthousands(num)
        local formatted = num
        local k
        while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then 
                break end
            end
        return formatted
    end

    if number < 1e6 then
        return formatnumberthousands(number)
    elseif number < 1e9 then
        return formatnumberthousands(string.format("%.2f",number/1e6)).."M"
    elseif number < 1e12 then
        return formatnumberthousands(string.format("%.2f",number/1e9)).."B"
    elseif number < 1e15 then
        return formatnumberthousands(string.format("%.2f",number/1e12)).."T"
    else
        return "999.99T"
    end
end

--人数数值合并
function uu.MergeNumber(number, divNumber)
    local numberLength = 7    --数值最多显示6位
    local interger, decimal = math.modf(number/divNumber)
    local len = numberLength - #tostring(interger) + 1    --小数部分长度
    --取小数前len位的值
    local decimalFormat = string.format("%.10f", decimal)   --零界点会自动四舍五入 ，需要将小数点后延长几位
    decimal = tonumber(string.sub(tostring(decimalFormat), 1, len))     
    --print("decimal format: "..decimalFormat)
    local total = interger
    if (decimal > 1e-5) then
        total = total + decimal     --确保小数结果最后一位不为0
    end
    
    local result = tostring(total)
    result = string.sub(result, 1, numberLength)
    return result
end

-- function uu.HttpGet( url, onResponse, onError, onFinish )
--     local www = WWW(url)
--     local co = coroutine.start(function()
--         coroutine.www(www)
--         if not www.error then
--             uu.SafeCallFunc(onResponse, www)
--         else
--             uu.SafeCallFunc(onError, www.error,www)
--         end
--         uu.SafeCallFunc(onFinish, www)
--     end)
--     return www, co
-- end

--给url加上时间戳，解决缓存问题
function uu.UrlWithTimeStamp(url)
    --外网不准加时间戳访问资源，否则可导致CDN失效致文件服访问爆炸。
    --加时间戳仅在测试和预发布使用，解决iOS自带缓存问题
    --return url .. "?timestamp=" .. Util.GetTimeStamp(false)
    local CC = require("CC")
    if CC.DebugDefine.GetDebugMode() then
        return url .. "?timestamp=" .. Util.GetTimeStamp(false)
    end
    return url
end

--从一个路径中窃取文件名，例如 xx/xx/xx/a.apk,执行将得到a.apk
function uu.CutFileNameFromPath(path)
    return string.gsub(path, "(.*/)", "")
end

--求x字节的大小，超过1024B显示KB，超过1M显示MB
function uu.GetByteSizeString(byteSize)
    local sizestring = ""
    if byteSize>1024 and byteSize<=1048576 then
        sizestring=Mathf.Round(byteSize/1024).."KB"
    elseif byteSize>1048576 then
        sizestring=Mathf.Round(byteSize/1048576).."MB"
    else
        sizestring=byteSize.."B"
    end
    return sizestring
end


--------------------------------------------
-----dump 打印结构
-- content 要打印的值
--tab 描述
-- level  1,log 2,警告 3，error
--------------------------------------------
function uu.Log(content, tab, level)
    
    if not Util.hasLog then
        return;
    end
    local  tab = not tab and "" or tostring(tab);
    local level = level or 1;
    local logFunc;
    if level == 1 then
        logFunc = log;
    elseif level == 2 then
        logFunc = logWarn;
    elseif level == 3 then
        logFunc = logError;
    end

    local date = os.date("%H:%M:%S");

    if type(content) == "table" and content._fields then
        logFunc(string.format("%s Proto %s \n%s", date, tab, tostring(content)));
        return;
    elseif type(content) == "table" then
        local str = {}
        table.insert(str, "{\n")
        local function internal(tab, str, indent)
            for k,v in pairs(tab)  do
                if type(v) == "table" and not v._fields then
                    table.insert(str, indent..tostring(k).." = {\n")
                    internal(v, str, indent..'          ')
                else
                    table.insert(str, indent..tostring(k).." = "..tostring(v)..",\n")
                end
            end
            table.insert(str, string.sub(indent,1,-5).."}\n")
        end
        internal(content, str, '    ')
        logFunc(string.format("%s LuaTable %s \n%s", date, tab, table.concat(str, '')));
    else
        logFunc(string.format("%s %s %s %s", date, type(content), tab, content));
    end
end


--------------------------------------------
-----dump 打印结构
-- value[all type ??] 要打印的值
-- desciption 描述
-- nesting[int]  深度 默认为3
--------------------------------------------
function uu.Dump(value, desciption, nesting,str_begin)
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    --local traceback = string.split(debug.traceback("", 2), "\n")
    --rint("dump from: " .. string.trim(traceback[3]))

    local function _dump(value, desciption, indent, nest, keylen)
        --协议结构处理
        local fields = type(value) == "table" and value._fields or nil
        if fields then
            value = table.copy(value)
            for k,v in pairs(fields) do
                if type(v) == "table" then
                    v = table.copy(v)
                    v._listener = nil
                    v._type_checker = nil
                     v._message_descriptor = nil
                end
                value[k.name] = v
            end
            --屏蔽字段
            value._fields = nil
            value._cached_byte_size = nil
            value._cached_byte_size_dirty = nil
            value._is_present_in_parent = nil
            value._listener = nil
            value._listener_for_children = nil
            value._message_descriptor = nil
        end

        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_v(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
        elseif lookupTable[value] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    _dump(value, desciption, str_begin or " ", 1)
    local str_res = ""
    for i, line in ipairs(result) do
        str_res = str_res ..line.."\n"
    end

    return str_res
end

function uu.StrSplin(str)
    -- 拆分成{"1","2","3","4","a","b","c","d"}
    local len = string.len(str)
    local list={}
    for i=1,len do
        list[i]=string.sub(str,i,i)
    end

    return list
end

function uu.urlEncode(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function uu.urlDecode(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

local _UnityLogViewNode = nil
function uu.OpenLogView()
    if _UnityLogViewNode then
        _UnityLogViewNode.transform:Show()
    else
        ResMgr.LoadAssets("prefab", {"UnityLogViewer"}, function(pref) 
            local pref = pref[0]
            _UnityLogViewNode = uu.UguiAddChild(nil, pref,"[UnityLogViewer]")
        end)
    end
end

function uu.CloseLogView()
    if _UnityLogViewNode then
        _UnityLogViewNode.transform:Hide()
    end
end

--获取上层挂载的canvas组件
function uu.GetCanvas(node)
    local parent = node.transform.parent;
    if parent then
        local canvas = parent:GetComponent("Canvas");
        return canvas and canvas or uu.GetCanvas(parent);
    end
    logError("uu.GetCanvas: canvas has not found");
end

function uu.unicode_to_utf8(convertStr)
    local str
    if uu.SafeCallFunc(function() str = unicode.unicode_to_utf8(convertStr) end) then
        return str
    else
        logError(convertStr)
        return ""
    end
end

function uu.utf8_to_unicode(convertStr)
    local str
    if uu.SafeCallFunc(function() str = unicode.utf8_to_unicode(convertStr) end) then
        return str
    else
        logError(convertStr)
        return ""
    end
end

function uu.ExplainContentSplit(parent,item,content)
    local cList = content:split('\n')
    for i=1,#cList do
        local obj
        if i == 1 then
            obj = item.gameObject
        else
            obj = GameObject.Instantiate(item.gameObject)
            obj.transform:SetParent(parent,false)
        end
        local text = obj.transform:GetComponent("Text")
        text.text = cList[i]
    end
end

--解析url参数
function uu.parseUrlParam(url)
    local t = nil
    t = uu.splitString(url,'?')
    local param = t[2]
    if not param then
        logError("parseUrl error:"..tostring(url))
        return
    end
    --&
    t = uu.splitString(param,'&')
    local res = {}
    for k,v in pairs(t) do
        local t = uu.splitString(v,'=')
        res[t[1]]=t[2]
    end
    return res
end

--拼接url参数, param参数为table
function uu.spliceUrlParam(url, param)
    local paramStr = "?";
    for k,v in pairs(param) do
        paramStr = paramStr..k.."="..tostring(v).."&";
    end
    --截掉最后一个&符号
    paramStr = string.sub(paramStr,0,-2);
    return url..paramStr
end

function uu.isSpecialThai(char)
    local temp = unicode.utf8_to_unicode(char)
    local Thai = {"\\u0e31","\\u0e33","\\u0e34","\\u0e35","\\u0e36","\\u0e37","\\u0e38","\\u0e39","\\u0e47","\\u0e48","\\u0e49","\\u0e4a","\\u0e4b","\\u0e4c","\\u0e4d","\\u0e4e"}
    for i=1,#Thai do
        if temp == Thai[i] then
            return true
        end
    end
    return false
end

function uu.ThaiStrSplit(str,limit)
    local str = str or ""
    local limit = limit or 10
    local cList = {}
	local len = string.len(str)
	local i = 1
	while i <= len do
		local c = string.byte(str,i)
		local shift = 1
		if c > 0 and c <= 127 then
			shift = 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
		end
		local char = string.sub(str,i,i+shift-1)
        i = i + shift
		table.insert(cList, char)
    end
    limit = limit < #cList and limit or #cList
    local result = ""
    for i=1,limit do
		result = result..cList[i]
    end
    local c1 = cList[limit+1] or ""
    local c2 = cList[limit+2] or ""
    if uu.isSpecialThai(c1) then
        result = result..c1
    end
    if uu.isSpecialThai(c2) then
        result = result..c2
    end
    return result.."..."
end

--保留n位小数
function uu.keepDecimal(num,n,isRound)
    if type(num) ~= "number" then
        logError("请输数字类型")
    end
    n = n or 1
    if isRound then
        --四舍五入
        return string.format("%." .. n .. "f", num)
    else
        --直接舍弃后面的数值
        if num < 0 then
            return -(math.abs(num) - math.abs(num) % 0.1 ^ n)
        else
            return num - num % 0.1 ^ n
        end
    end
end

return uu

