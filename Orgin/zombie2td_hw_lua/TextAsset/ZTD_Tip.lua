local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local ZTD_Tip = ZTD.ClassView("ZTD_Tip")
function ZTD_Tip:GlobalNode()
    return GameObject.Find("Main/Canvas/TopUIPanal").transform
end

function ZTD_Tip:ctor(str,seconds,finishCall,tipPos)
    self.str = str
    self.seconds = tonumber(seconds) or 2
    self.finishCall = finishCall   
	self.tipPos = tipPos
end

function ZTD_Tip:OnCreate()
    local content = self:SubGet("Str","Text")
    content.text = self.str
    if self.seconds == -1 then return end

	if self.tipPos then
		local img = self:FindChild("image");
		img.position = self.tipPos;
		content.transform.position = self.tipPos;
	end
	
    self:RunAction(self.transform,{"fadeToAll",0,self.seconds,onEnd = function()
        self:OnFinish()
    end})
end

function ZTD_Tip:OnFinish()
    self:Destroy()

    if self.finishCall then
        self.finishCall()
    end
end

return ZTD_Tip