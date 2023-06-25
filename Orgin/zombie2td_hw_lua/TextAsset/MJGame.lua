--- region NewFile_1.lua
-- Author : vk
-- Date   : 2017/10/10
-- 此文件由[BabeLua]插件自动生成
local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local MJGame = { }

MJGame.gameData = nil

function MJGame.Start(data)
	-- log("大厅配置数据 data="..GC.uu.Dump(data))
    Util.ClearMemory()
	
	if data and data.___isEditEnter then
		local ef = require("ZTD_EffectPlayerView")
		ef.Start();		
	else	
		ZTD.Init()
		MJGame.gameData = data
		ZTD.GameCenter.GetInstance():EnterGame()		
	end
end

function MJGame.Destroy()
	ZTD.Destroy()
end

--回到登录页面
function MJGame.Back2Login()
	ZTD.Flow.OnLogoutGame(ZTD.Flow, {LogoutType = 99})
	ZTD.PoolManager.Release();
	ZTD.NetworkManager.StopServer()
	GC.SubGameInterface.BackToHall()
	ZTD.GlobalTimer.Release()
	MJGame.Destroy()
end

--回到大厅
function MJGame.Back2Hall(isFlowRelease)
	ZTD.ViewManager.CloseAllView(true)
	if not isFlowRelease then
		ZTD.Flow.ReleaseAll()
	end
	ZTD.PoolManager.Release()
	ZTD.NetworkManager.StopServer()
	GC.SubGameInterface.BackToHall()
	ZTD.GlobalTimer.Release()
	MJGame.Destroy()
end

return MJGame

