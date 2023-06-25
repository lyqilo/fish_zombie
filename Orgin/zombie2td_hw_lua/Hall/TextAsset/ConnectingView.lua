
local CC = require("CC")

local ConnectingView = CC.uu.ClassView("ConnectingView")

function ConnectingView:ctor(isDelay,time)
	self.isDelay = isDelay
	self.time = time or 1
end

function ConnectingView:GlobalNode()
	return GameObject.Find("DontDestroyGNode/GCanvas/GMain").transform
end

function ConnectingView:OnCreate()
	self:FindChild("Content"):SetActive(false)
	self:FindChild("ShieldingLayer"):GetComponent("RawImage").color = Color(255,255,255,0)
	self:AddToDontDestroyNode();
	if self.isDelay then
		self:InitDelay()
	else
		self:FindChild("ShieldingLayer"):GetComponent("RawImage").color = Color(255,255,255,255)
		self:FindChild("Content"):SetActive(true)
	end
	self:FindChild("Content/Text").text = "Connecting"
	for i=1,3 do
		self:FindChild("Content/Point/0"..i).text = "."
	end
end

function ConnectingView:InitDelay()
	self:DelayRun(self.time,function ()
		self:FindChild("ShieldingLayer"):GetComponent("RawImage").color = Color(255,255,255,255)
		self:FindChild("Content"):SetActive(true)
	end)
end

return ConnectingView