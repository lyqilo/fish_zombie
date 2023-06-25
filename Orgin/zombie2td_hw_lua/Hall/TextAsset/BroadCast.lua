local CC = require("CC")
local BroadCast = CC.uu.ClassView("BroadCast")

function BroadCast:ctor(param)
    self.transform = param.transform
end

function BroadCast:Create()
    self:OnCreate()
end

function BroadCast:OnCreate() 
	self.tipText = self:FindChild("hedi/Text")
	self.hediWidth = (self:FindChild("hedi"):GetComponent('RectTransform').rect.width - 15)/2
	self.timerTag = "BroadCast"
	self.isBroadCast = false

	--滚动标记,false时停止当前播放立即播放下一条消息   
	self.isTipMoving = false 
	self.messageList = {}
	self.action = nil
end

function BroadCast:Show(data)
	table.insert(self.messageList,data)

	self:Start()
end

function BroadCast:OnDestroy()
	if self.isBroadCast then
		self.tipText:GetComponent('Text').text = ""
		self:Hide()
		self:StopTimer(self.timerTag)
		self.isBroadCast = false
	end
end

function BroadCast:GetNextTip()
	if table.length(self.messageList) > 0 then
		return true
	else
		return false
	end
	 
end

function BroadCast:Start()
	if self.isBroadCast then return end
	self.isBroadCast = true

	--每0.5s检测一次
	self:StartTimer(self.timerTag,0.5,function()
		--当前有消息在显示，则返回
		if self.isTipMoving then 
			return
		else
			self:StopAction(self.action)
			self.action = nil
		end
		--消息队列已经为空，停止计时
		if not self:GetNextTip() then
			self.tipText:GetComponent('Text').text = ""
			self:Hide()
			self:StopTimer(self.timerTag)
			self.isBroadCast = false
		else
			self.isTipMoving = true
	        local text = self.messageList[1].Message
			table.remove(self.messageList,1)
			self.tipText.localPosition = Vector3(1000,0,0)
			self.tipText:GetComponent('Text').text = text
			self.transform.gameObject:SetActive(true)
			self:DelayRun(0.1,function()
				local textW = self.tipText:GetComponent('RectTransform').rect.width
				local half = textW/2
				self.tipText.localPosition = Vector3(half + self.hediWidth, -2, 0)
				self.action = self:RunAction(self.tipText, {"localMoveTo", -half - self.hediWidth, -2, 0.65 * math.max(16,textW/40), function()
					self.action = nil
					self.isTipMoving = false
				end})
			end)
		end
	end,-1)
end

return BroadCast