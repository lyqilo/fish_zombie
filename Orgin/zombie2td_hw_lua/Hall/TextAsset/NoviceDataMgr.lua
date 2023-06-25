local CC = require("CC")

local NoviceDataMgr = {}

local noviceDataCfg = {
    NoviceSignInView = {open = false},
    NewbieTaskView = {open = false},
    FragmentTaskView = {open = false},
}

local bPushState = false

function NoviceDataMgr.Init()

    -- CC.HallNotificationCenter.inst():register(NoviceDataMgr,NoviceDataMgr.RefreshInfo,CC.Notifications.changeSelfInfo)
    CC.HallNotificationCenter.inst():register(NoviceDataMgr,NoviceDataMgr.NewbieTaskInfoResp,CC.Notifications.NW_ReqTaskListInfo)
    CC.HallNotificationCenter.inst():register(NoviceDataMgr,NoviceDataMgr.NewPlayerSignStatusResp,CC.Notifications.NW_ReqNewPlayerSignStatus)
    CC.HallNotificationCenter.inst():register(NoviceDataMgr,NoviceDataMgr.GetNoviceSignInState,CC.Notifications.OnTimeNotify)
end

function NoviceDataMgr.Unregister()
	CC.HallNotificationCenter.inst():unregisterAll(NoviceDataMgr)
end

function NoviceDataMgr.RefreshInfo(data)
    for _,v in ipairs(data) do
        if v.ConfigId == CC.shared_enums_pb.EPC_LockLevel and v.Delta and v.Delta > 0 then
            bPushState = true
            if CC.Player.Inst():GetSelfInfoByKey("EPC_GreenHand") ~= 0 then
                NoviceDataMgr.SetNoviceDataByKey("NoviceSignInView",true)
            end
            CC.Request("ReqTaskListInfo")
            CC.DataMgrCenter.Inst():GetDataByKey("Activity").ReqInfo()
		end
	end
end

function NoviceDataMgr.NewbieTaskInfoResp(err, data)
    if err == 0 then
        if bPushState then
            bPushState = false
            NoviceDataMgr.SetNoviceDataByKey("NewbieTaskView", not data.IsNewTaskAllAward)
            NoviceDataMgr.SetNoviceDataByKey("FragmentTaskView", data.IsNewTaskAllAward)
            log("==========================>一级锁修改，发送消息给子游戏准备拉回大厅<==========================")
            CC.HallNotificationCenter.inst():post(CC.Notifications.ExitToGuide)
        end
    end
end

function NoviceDataMgr.GetNoviceSignInState()
    local cfg = noviceDataCfg["NoviceSignInView"]
    if cfg.open then
        CC.Request("ReqNewPlayerSignStatus")
    end
end

function NoviceDataMgr.NewPlayerSignStatusResp(err,data)
    if err == 0 then
        NoviceDataMgr.SetNoviceDataByKey("NoviceSignInView",data.Open)
    end
end

function NoviceDataMgr.SetNoviceDataByKey(key,bState)
    local cfg = noviceDataCfg[key]
    if not cfg then return end

    if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel") then return end

    local oldValue = cfg.open
    cfg.open = bState
    if bState ~= oldValue then
        CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshActivityBtnsState, key, bState)
    end
end

function NoviceDataMgr.GetNoviceDataByKey(key)
    return noviceDataCfg[key]
end

NoviceDataMgr.Init()

return NoviceDataMgr