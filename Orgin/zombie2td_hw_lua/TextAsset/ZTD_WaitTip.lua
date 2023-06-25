local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local ZTD_WaitTip = ZTD.ClassView("ZTD_WaitTip")

function ZTD_WaitTip:GlobalNode()
    return GameObject.Find("Main/Canvas/TopUIPanal").transform
end

function ZTD_WaitTip:OnCreate()
	-- logError("ZTD_WaitTip OnCreate:" .. debug.traceback())
	self.ani = self:FindChild("Effect_UI_JiaZai")
end

function ZTD_WaitTip:HideMask()
    self:FindChild("mask").color = Color(1, 1, 1, 0);
    self.ani:SetActive(false)
end 
function ZTD_WaitTip:ShowMask()
    self:FindChild("mask").color = Color(1, 1, 1, 0.5);
    self.ani:SetActive(true)
end 

--延时显示动画
function ZTD_WaitTip:SetDelayTime(time)
	self:HideMask()
	ZTD.GlobalTimer.StopTimer(self.delayTimer)
	self.delayTimer = ZTD.GlobalTimer.DelayRun(time,function ()
		self:ShowMask()
		self.delayTimer = nil
	end)
end


function ZTD_WaitTip:OnDestroy()
	-- logError("ZTD_WaitTip OnDestory:" .. debug.traceback())
	if self.delayTimer then
		ZTD.GlobalTimer.StopTimer(self.delayTimer)
	end
end


return ZTD_WaitTip