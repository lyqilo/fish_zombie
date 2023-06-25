local CC = require("CC")
local SelectActiveView = CC.uu.ClassView("SelectActiveView")

function SelectActiveView:ctor(callback)
	--self.language = self:GetLanguage()
	self.pos = 0
	self.leftNum = 0
	self.rightNum = 0
	self.ismove = false
	self.speed = 2
	self.movetime = 0
	self.CurrentId = 1
	self.callback = callback
end

function SelectActiveView:OnCreate()

	self:Init()
	self.viewCtr = self:CreateViewCtr(self.content)
	self.viewCtr:OnCreate()
	self:RegisterEvent()
	self:StartUpdate()
	self:CurrentFunc()
end

function SelectActiveView:Init()
	self.Scroll = self:FindChild("Layer_UI/Scroll View"):GetComponent("ScrollRect")
	self.content = self:FindChild("Layer_UI/Scroll View/Viewport/Content")
	self.BtnClose = self:FindChild("Layer_UI/BtnClose")
	self.BtnLeft = self:FindChild("Layer_UI/BtnLeft")
	self.BtnRight = self:FindChild("Layer_UI/BtnRight")
	self:AddClickEvnt()
	-- self.Scroll.horizontalNormalizedPosition = 0 --默认显示第一个item
end

function SelectActiveView:StartUpdate()
	UpdateBeat:Add(self.Update,self);
end

function SelectActiveView:StopUpdate()
	UpdateBeat:Remove(self.Update,self);
end

function SelectActiveView:Update()
	if self.ismove then
		self.movetime = self.movetime + (Time.deltaTime * self.speed)
		if self.movetime >= 1 then
			self.movetime = 1
			self.ismove = false
		end
		 self.Scroll.horizontalNormalizedPosition =  Mathf.Lerp(self.Scroll.horizontalNormalizedPosition, self.pos,self.movetime)--逐帧插值
	end
end

function SelectActiveView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ActionOut,CC.Notifications.NoviceReward)
end

function SelectActiveView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NoviceReward)
end

function SelectActiveView:AddClickEvnt()
	self:AddClick(self.BtnClose,function ()
		self:ActionOut() 
	end)
	self:AddClick(self.BtnLeft,"BtnLeftFunc")
	self:AddClick(self.BtnRight,"BtnRightFunc")
end

function SelectActiveView:CurrentFunc()
	if self.CurrentId == 1 then
		self.BtnLeft:SetActive(false)
		self.BtnRight:SetActive(true)
	elseif self.CurrentId == #self.viewCtr.configData then
		self.BtnRight:SetActive(false)
		self.BtnLeft:SetActive(true)
	else
		self.BtnRight:SetActive(true)
		self.BtnLeft:SetActive(true)
	end
	if self.CurrentId == 1 and #self.viewCtr.configData == 1 then
		self.BtnRight:SetActive(false)
		self.BtnLeft:SetActive(false)
	end
end

--左边点击按钮
function SelectActiveView:BtnLeftFunc()
	if not self.ismove then
		if self.Scroll.horizontalNormalizedPosition >= 0 then
			self.pos = self.Scroll.horizontalNormalizedPosition - self.viewCtr:GetHorizontalMoveSize()
			if self.pos < 0 then
				self.pos = 0
			end
		end
		self.CurrentId = self.CurrentId - 1
		self:CurrentFunc()
		self.ismove = true
		self.movetime = Time.deltaTime
	end
end

--右边点击按钮
function SelectActiveView:BtnRightFunc()	
	if not self.ismove then
		if self.Scroll.horizontalNormalizedPosition <= 1 then
		self.pos = self.Scroll.horizontalNormalizedPosition + self.viewCtr:GetHorizontalMoveSize()
			if self.pos > 1 then
				self.pos = 1
			end
		end
		self.CurrentId = self.CurrentId + 1
		self:CurrentFunc()
		self.ismove = true
		self.movetime = Time.deltaTime
	end	
end

function SelectActiveView:OnDestroy()

	if self.callback then
		self.callback()
	end

	self:unRegisterEvent()
	self:StopUpdate()
	if self.viewCtr ~= nil then
		self.viewCtr:Destroy()
	end
end


function SelectActiveView:ActionOut()
	self:SetCanClick(false)
    self:RunAction(self, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    		self:Destroy()
    	end})
end

return SelectActiveView
