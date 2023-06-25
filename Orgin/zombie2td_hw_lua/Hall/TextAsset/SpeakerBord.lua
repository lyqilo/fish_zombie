------------------------------------
--- 大喇叭
--- 注释代码实现没有新消息，循环播放20s
------------------------------------
local CC = require("CC")
local SpeakerBord = CC.uu.ClassView("SpeakerBord")

local deltaPos = Vector3(0, 0, 0)
local basePos = Vector3(0, 0, 0)

function SpeakerBord:GlobalNode()
	return GameObject.Find("DontDestroyGNode/GaussCanvas/GExtend").transform
end

function SpeakerBord:OnCreate()
	self:AddToDontDestroyNode();
	self.transform.z = -100
	self.transform.localPosition = Vector3(deltaPos.x + basePos.x, deltaPos.y + basePos.y, deltaPos.z + deltaPos.z)

	-- self.tipText = self:FindChild("SpeakerImg/TextTip")
	-- self.SpeakerImg = self:FindChild("SpeakerImg"):GetComponent('RectTransform').rect.width
	-- self.timerTag = "NoticeTimer"
	-- self.isTimerOn = false
	-- self.isTipMoving = false
	-- self.tips = {}
	-- self.SumTim = 0
	-- self.LastSumTime = 20
	-- self.LastTip = ""

	self.tipText = self:FindChild("SpeakerImg/TextTip")
	self.hediWidth = (self:FindChild("SpeakerImg"):GetComponent('RectTransform').rect.width - 15)/2
	self.timerTag = "SpeakTimer"
	self.isTimerOn = false
	self.isTipMoving = false
	self.tips = {}
	self.action = nil
end

function SpeakerBord:SetDeltaPos(vec3)
	deltaPos = vec3
	self:ResetPos()
end

function SpeakerBord:SetWidth(width)
	self:FindChild("SpeakerImg").transform.width = width
	-- self.SpeakerImg = (width - 15)/2
	self.hediWidth = (width - 15)/2
	self:ResetPos()
end

function SpeakerBord:ResetPos()
	self.transform.localPosition = Vector3(deltaPos.x + basePos.x, deltaPos.y + basePos.y, deltaPos.z + deltaPos.z)
end

function SpeakerBord:Show(tip)
	if tip == nil or tip == "" then return end
	table.insert(self.tips,tip)

	self:ResetPos()
	self:Start()
end

function SpeakerBord:OnDestroy()
	if self.isTimerOn then
		self.tipText:GetComponent('Text').text = ""
		self:Hide()
		self:StopTimer(self.timerTag)
		self.isTimerOn = false
	end
end

function SpeakerBord:Start()
	if not CC.ChatManager.GetSpeakBordState()  then return end

	if self.isTimerOn then return end
	self.isTimerOn = true

	--每0.5s检测一次
	self:StartTimer(self.timerTag,0.5,function()
		self.transform.gameObject:SetActive(CC.ChatManager.GetSpeakBordState())
		--当前有消息在显示，则返回
		if self.isTipMoving then 
			return
		else
			self:StopAction(self.action)
			self.action = nil
		end
		--消息队列已经为空，停止计时
		if 0 == #self.tips or not CC.ChatManager.GetSpeakBordState() then
			self.tipText:GetComponent('Text').text = ""
			self:Hide()
			self:StopTimer(self.timerTag)
			self.isTimerOn = false
		else
			self.transform.gameObject:SetActive(true)
			self.isTipMoving = true
	        local text = self.tips[1]
			table.remove(self.tips,1)
			self.tipText.localPosition = Vector3(10000,10000,10000)
			self.tipText:GetComponent('Text').text = self:DealWithString(text)
			self:DelayRun(0.1,function()
				local textW = self.tipText:GetComponent('RectTransform').rect.width
				local half = textW/2
				self.tipText.localPosition = Vector3(half + self.hediWidth, 0, 0)
				self.action = self:RunAction(self.tipText, {"localMoveTo", -half - self.hediWidth, 0, 0.65 * math.max(16,textW/40), function()
					self.action = nil
					self.isTipMoving = false
				end})
			end)
		end
	end,-1)
end

function SpeakerBord:DealWithString(text)
	local str = string.gsub(CC.uu.ReplaceFace(text,23,true),'%s+',' ')
	return str
end

return SpeakerBord
