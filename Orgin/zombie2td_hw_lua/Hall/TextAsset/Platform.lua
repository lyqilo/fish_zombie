local CC = require("CC")
local Platform = {}

local enum = 
{
    UNKNOWN = 0,
    IOS = 1,
    ANDROID = 2,
    WIN32 = 3,
    OSX = 4,
}

Platform.name = nil
-- Platform.id = nil
Platform.isWin32 = nil
Platform.isAndroid = nil
Platform.isIOS = nil
-- Platform.isOSX = nil

function Platform.Init()
    Platform.name = Util.GetPlatform()
    -- Platform.id = enum[Platform.name] or enum.UNKNOWN
    Platform.isWin32 = "WIN32" == Platform.name
    Platform.isAndroid = "ANDROID" == Platform.name
    Platform.isIOS = "IOS" == Platform.name
    -- Platform.isOSX = "OSX" == Platform.name
end

function Platform.getPlatformName()
  
    if Platform.isIOS then
        return "ios"
    elseif Platform.isAndroid then
        return "android"
    elseif Platform.isWin32 then
        return "win32"
    else
        return "UNKNOWN"
    end
end

--大厅服平台枚举
function Platform.GetOSEnum()
    if Platform.isAndroid then
        return CC.shared_enums_pb.OST_Android;
    elseif Platform.isIOS then
        return CC.shared_enums_pb.OST_IOS;
    elseif Platform.isWin32 then
        return CC.shared_enums_pb.OST_PC;
    end
end

--web平台枚举(android:1 ios:2 ios私包:3)
function Platform.GetOSValueByChannel()
    if CC.Platform.isIOS then
        --私包渠道
        if AppInfo.ChannelID == "10000" then
            return 3;
        end
        return 2;
    end
    return 1;
end

function Platform.GetDeviceId()
    if CC.DebugDefine.GetAccount() then
        return CC.DebugDefine.GetAccount()
    else
        return Client.GetDeviceId();
    end
end

return Platform