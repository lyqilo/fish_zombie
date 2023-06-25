local CC = require("CC")
local M = {}

local url = CC.UrlConfig.ReportUrl.Release
local gameId = 200
local apiKey = "85b5b61cc7ec36fd5064868b43fdcd0d"
local timeZone = "Asia/Bangkok"
local uploading = false
local cachedData = {}
local loginDefine

function M.Init()
    url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetReportQUrl()

    loginDefine = CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine")

    if not CC.LocalGameData.GetLocalStateToKey("deviceActive") then
        M.DeviceEvent("$device_activation")
        CC.LocalGameData.SetLocalStateToKey("deviceActive", true)
    end
end

function M.MoveCahcedData()
    local reportData = CC.LocalGameData.GetReportQData()
    for i, v in ipairs(cachedData) do
        table.insert(reportData, v)
    end
    CC.LocalGameData.SetReportQData(reportData)
    cachedData = {}
end

function M.DeviceEvent(eventName, param)
    if not CC.Platform.isAndroid and not CC.Platform.isIOS then
        return
    end

    local deviceId = Client.GetDeviceId()
    local deviceType
    if CC.Platform.isIOS then
        deviceType = "uuid"
    else
        if deviceId then
            deviceType = string.find(tostring(deviceId), "-") and "androidId_serial" or "imei"
        else
            deviceType = "UNKOWN"
        end
    end

    local deviceInfo = CC.HallUtil.GetDeviceInfo()
    local deviceName = table.isEmpty(deviceInfo) and "Unknown" or (deviceInfo.BRAND .. " " .. deviceInfo.MODEL)

    local param = param or {}
    param.os = CC.Platform.getPlatformName()

    local data = {
        type = "device",
        event = eventName,
        device_no = deviceId,
        device_type = deviceType,
        time = os.time(),
        device_name = deviceName,
        properties = param
    }

    M.AddData(data)

    M.Upload()
end

function M.ActionEvent(eventName, param)
    local playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
    local loginWay = CC.Player.Inst():GetCurLoginWay()
    local uidType = loginWay == loginDefine.LoginWay.Guest and 0 or 1
    local data = {
        type = "action",
        event = eventName,
        uid = playerId,
        uid_type = uidType,
        time = os.time(),
        properties = param or {}
    }
    if uploading then
        table.insert(cachedData, data)
    else
        M.AddData(data)
    end
end

function M.AddData(data)
    local reportData = CC.LocalGameData.GetReportQData()
    table.insert(reportData, data)
    CC.LocalGameData.SetReportQData(reportData)
end

function M.Upload()
    if uploading then
        return
    end
    local stepList = CC.LocalGameData.GetReportQData()
    if #stepList == 0 then
        return
    end
    uploading = true
    local param = {
        apiKey = apiKey,
        gameId = gameId,
        timezone = timeZone,
        dataList = stepList
    }

    if not apiKey then
        --上报异常追踪
        BuglyUtil.ReportException("ReportQManager:", "no apiKey", "no apiKey")
    end

    CC.HttpMgr.PostJson(
        url,
        param,
        function(result)
            if result.code == 0 then
                uploading = false
                CC.LocalGameData.SetReportQData({})
                M.MoveCahcedData()
                CC.uu.Log(result.code, "reportQData success")
                return
            end

            CC.uu.Log(result.code, "reportQData failed")
        end,
        function()
            uploading = false
            M.MoveCahcedData()
            CC.uu.Log("reportQData failed")
        end
    )
end

return M
