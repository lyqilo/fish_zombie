--------------------------------------------
--@Description: 工具接口
--@Author: Xie Ling Yun
--------------------------------------------
local M = {}

M.ReqOpsSuffix = "Ops_Req_"
M.PushOpsSuffix = "Ops_Push_"
M.CSMessageSuffix = "CS_"
M.SCRspMessageSuffix = "SC_Rsp_"
M.SCPushMessageSuffix = "SC_Push_"

M.NETWORKOPEN = "NETWORKOPEN"
M.NETWORKCLOSE = "NETWORKCLOSE"
M.NETWORKCLOSE_RECONNECT = "NETWORKCLOSE_RECONNECT"
M.NETWORKDISCONNECT = "NETWORKDISCONNECT"
M.NETWORKNOTRESPOND = "NETWORKNOTRESPOND"
M.NETWORKUNDERMAINTANCEN = "NETWORKUNDERMAINTANCEN"
M.NETWORKUPDATELAG = "NETWORKUPDATELAG"

function M.GetRspMessageName(name)
    return M.SCRspMessageSuffix .. name
end

function M.GetPushMessageName(name)
    return M.SCPushMessageSuffix .. name
end

function M.GetReqMessageName(name)
    return M.CSMessageSuffix .. name
end

function M.ConvertReqToRsp(name)
    return string.gsub(name, "Req", "Resp")
end

return M