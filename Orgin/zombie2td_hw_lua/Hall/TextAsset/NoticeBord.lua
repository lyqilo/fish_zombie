local CC = require("CC")
local NoticeBord = CC.uu.ClassView("NoticeBord")

local deltaPos = Vector3(0, 0, 0)
local basePos = Vector3(0, 0, 0)

function NoticeBord:GlobalNode()
	return GameObject.Find("DontDestroyGNode/GaussCanvas/GExtend").transform
end

function NoticeBord:OnCreate()
	self:AddToDontDestroyNode();
	self.transform.z = -100
	self.transform.localPosition = Vector3(deltaPos.x + basePos.x, deltaPos.y + basePos.y, deltaPos.z + deltaPos.z)

	self.tipText = self:FindChild("seven/hedi/TextTip")
	self.hediWidth = (self:FindChild("seven/hedi"):GetComponent('RectTransform').rect.width - 15)/2
	self.timerTag = "NoticeTimer"
	self.isTimerOn = false

	--当前播放级别，用于判断是否可改变self.isTipMoving
	self.curLevel = 0
	--滚动标记,false时停止当前播放立即播放下一条消息   
	self.isTipMoving = false
	--所有消息列表
	--1:IMMEDIATELY
	--2:sys
	--3:activity_timer
	--4:activity_normal
	--5:game
	self.total = {}
	for i=1,5 do
		self.total[i] = {}
	end

	self.action = nil
end

function NoticeBord:SetDeltaPos(vec3)
	deltaPos = vec3
	self:ResetPos()
end

function NoticeBord:SetWidth(width)
	self:FindChild("seven/hedi").transform.width = width
	self.hediWidth = (width - 15)/2
	self:ResetPos()
end

function NoticeBord:SetEffectState(state)
	self:FindChild("seven/7/Particle/lg"):SetActive(state)
	self:FindChild("seven/7/Particle/lg2"):SetActive(state)
end

function NoticeBord:ResetPos()
	self.transform.localPosition = Vector3(deltaPos.x + basePos.x, deltaPos.y + basePos.y, deltaPos.z + deltaPos.z)
end

function NoticeBord:Show(data)
	if data.MessageType == CC.ChatConfig.CHATTYPE.IMMEDIATELY then
		--立即播放，无条件优先于任何消息，立即停止当前播放，播放这一条消息
		table.insert(self.total[1],data)
	elseif data.MessageType == CC.ChatConfig.CHATTYPE.SYSTEM then
		self.total[2] = {}
		table.insert(self.total[2],data)
	elseif data.MessageType == CC.ChatConfig.CHATTYPE.ACTIVITY_TIMER then
		table.insert(self.total[3],data)
	elseif data.MessageType == CC.ChatConfig.CHATTYPE.ACTIVITY_NORMAL then
		table.insert(self.total[4],data)
	elseif data.MessageType == CC.ChatConfig.CHATTYPE.GAMESYSTEM then
		table.insert(self.total[5],data)
		if #self.total[5] > 180 then
			table.remove(self.total[5],2)
		end
	end

	if data.MessageType == CC.ChatConfig.CHATTYPE.SYSTEM or data.MessageType > self.curLevel then
		self.isTipMoving = false
	end

	self:ResetPos()
	self:Start()
end

function NoticeBord:OnDestroy()
	if self.isTimerOn then
		self.tipText:GetComponent('Text').text = ""
		self:Hide()
		self:StopTimer(self.timerTag)
		self.isTimerOn = false
	end
end

function NoticeBord:GetNextTip()
	for i,v in ipairs(self.total) do
		if #self.total[i] > 0 then
			return i 
		end
	end
	return 0
end

function NoticeBord:Start()
	if not CC.ChatManager.GetNoticeBordState()  then return end

	if self.isTimerOn then return end
	self.isTimerOn = true

	--每0.5s检测一次
	self:StartTimer(self.timerTag,0.5,function()
		self.transform.gameObject:SetActive(CC.ChatManager.GetNoticeBordState())
		--当前有消息在显示，则返回
		if self.isTipMoving then 
			return
		else
			self:StopAction(self.action)
			self.action = nil
		end
		--消息队列已经为空，停止计时
		if self:GetNextTip() == 0 or not CC.ChatManager.GetNoticeBordState() then
			self.tipText:GetComponent('Text').text = ""
			self:Hide()
			self:StopTimer(self.timerTag)
			self.isTimerOn = false
		else
			self.isTipMoving = true
			local index = self:GetNextTip()
	        local text = self.total[index][1].Message
	        self.curLevel = self.total[index][1].MessageType
			table.remove(self.total[index],1)
			self.tipText.localPosition = Vector3(10000,10000,10000)
			self.tipText:GetComponent('Text').text = string.gsub(CC.uu.ReplaceFace(text,23),"\n"," ")
			self.transform.gameObject:SetActive(true)
			self:DelayRun(0.1,function()
				local textW = self.tipText:GetComponent('RectTransform').rect.width
				local half = textW/2
				self.tipText.localPosition = Vector3(half + self.hediWidth, 14.5, 0)
				self.action = self:RunAction(self.tipText, {"localMoveTo", -half - self.hediWidth, 14.5, 0.65 * math.max(16,textW/40), function()
					self.action = nil
					self.isTipMoving = false
				end})
			end)
		end
	end,-1)
end

return NoticeBord