local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local Utils = {}
Utils.ScMoney = {};
--
local iWaitTipList = {};
local iWaitTipListEx = {};
local iWaitInxMark = 0;
local iWaitTip = nil;

local iGameCamera = nil;
local iUICamera = nil;
function Utils.Init()
    iGameCamera = ZTD.MainScene.CamObj--GameObject.Find("Camera"):GetComponent("Camera")
    iUICamera = GameObject.Find("Main/UICamera"):GetComponent("Camera")
end

function Utils.InitLimitUI_XY(x_left,x_right,y_up,y_down,y_fall)
    Utils.UIX_Left = x_left
    Utils.UIX_Right = x_right
    Utils.UIY_Up = y_up
    Utils.UIY_Down = y_down
    Utils.UIY_Fall = y_fall
end

--延时25s移除
local delayTime = 20
local waitRefs = 0
--转菊花的等待页面
--isHide 前1s隐藏界面
function Utils.ShowWaitTip(isHide)
	if Utils.iWaitTip then
		ZTD.GlobalTimer.StopTimer(Utils.wtTimer)
		Utils.wtTimer = ZTD.GlobalTimer.DelayRun(delayTime, function ()
			Utils.wtTimer = nil
			Utils.ForceCloseWaitTip()
		end)
	else
		Utils.iWaitTip = ZTD.CreateView("ZTD_WaitTip")
		Utils.wtTimer = ZTD.GlobalTimer.DelayRun(delayTime, function ()
			Utils.wtTimer = nil
			Utils.ForceCloseWaitTip()
		end)	
	end
	if isHide then
		Utils.iWaitTip:SetDelayTime(0.5)
	else
		Utils.iWaitTip:SetDelayTime(0)
	end	
	waitRefs = waitRefs + 1
end

--关闭转菊花的等待页面
function Utils.CloseWaitTip()
	waitRefs = waitRefs - 1
	if waitRefs <= 0 then
		Utils.ForceCloseWaitTip()
	end
end

function Utils.ForceCloseWaitTip()
	if not Utils.iWaitTip then return end
	ZTD.GlobalTimer.StopTimer(Utils.wtTimer)
	Utils.wtTimer = nil
	Utils.iWaitTip:Destroy()
	Utils.iWaitTip = nil
	waitRefs = 0
end 



--判断是否符合场限制条件
function Utils.IsNotMatchArenaLimit(str, callFun)
	local playerId = ZTD.PlayerData.GetPlayerId()
	local chouma = ZTD.TableData.GetData(playerId, "Money")
	-- log("chouma="..tostring(chouma))
	local groupId = ZTD.Flow.groupId
	-- log("groupId="..tostring(groupId))
	local data = Json.decode(ZTD.MJGame.gameData[groupId].UnlockCondition)
	-- log("data="..GC.uu.Dump(data))
	if not chouma then return false end
	if chouma < data.Min[1].Count then
		local confirmFunc = function()
			if callFun then
				callFun()
			end
		end
		ZTD.ViewManager.OpenExtenPopView(str, confirmFunc)
		return true
	end
	return false
end

--震屏 
-- 参数举例 Vector3(0.2, 0.2, 0), 0.1, 0, 30
function Utils.ShakeCameraPosition(pos, time, delay, vibrato)
	ZTD.Extend.RunAction(ZTD.MainScene.GetCameraTrans(), 
	{
		{"delay", delay},
		{"shakePosition", time, pos, vibrato, 0, false}
	})
    return true
end 

return Utils