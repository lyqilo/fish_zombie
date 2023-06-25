local CC = require("CC")
local MiniGameIcon = require("View/MiniGame/MiniGameIcon")
local MiniGameCtr = require("Model/MiniGame/MiniGameCtr")
local MiniGameMgr = {}

local this = MiniGameMgr

local _icon = nil
local ctr = nil

function this.CreateIcon(param)
	if not CC.ChannelMgr.GetSwitchByKey("bHasMiniHall") then
		return
	end
	if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("MiniHall",false) then
		return
	end
	if ctr == nil then
		ctr = MiniGameCtr.new()
	end
	local icon = MiniGameIcon.new()

	icon:Init(nil, param.parent)
	if param.pos then
		icon.transform.localPosition = Vector3(param.pos.x, param.pos.y, 0)
	end
	_icon = icon

	return icon
end

function this.DestroyIcon(icon)
	if icon then
		icon:Destroy()
		_icon = nil
	end
	if ctr then
		ctr:Destroy()
		ctr = nil
	end
end

function this.GetMiniCtr()
	return ctr
end

function this.IsReady()
	if ctr then
		return ctr:CheckCanPlay()
	end
end

local curGameId = 0
local lastGameId = 0
local windowMode = true

function this.SetCurWindowMode(flag)
	windowMode = flag
end

function this.GetCurWindowMode()
	return windowMode
end

function this.SetCurMiniGameId(id)
	if curGameId ~= id then
		curGameId = id
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnSetMiniCurGame, curGameId)
	end
end

function this.GetCurMiniGameId()
	return curGameId
end

function this.SetLastGameId()
	lastGameId = curGameId
	curGameId = 0
end

function this.GetLastGameId()
	return lastGameId
end

-- CC.Notifications.OnMiniHallChipsChange
function this.GetMiniGameChips()
	return CC.Player.Inst():GetSelfInfoByKey("EPC_MiniChouMa") or 0
end

function this.GetHallChips()
	return CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") or 0
end

-- 游戏内点击关闭
function this.OnMiniGameClose(gameId)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnMiniGameClose, gameId)
end

-- bValue 是否开启自动
function this.SetMiniGameAuto(gameId, bValue)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnSetMiniGameAuto, gameId, bValue)
end

-- nValue 当局下注总数
function this.SetMiniGameBet(gameId, nValue)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnSetMiniGameBet, gameId, nValue)
end

-- nValue 当局输赢情况，赢为正
function this.SetMiniGameResult(gameId, nValue)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnSetMiniGameResult, gameId, nValue)
end

-- 获取主界面筹码pos，需要判空
function this.GetChipNodePos()
	return _icon and _icon.mainView and _icon.mainView.miniChipBg and _icon.mainView.miniChipBg.position
end

return this
