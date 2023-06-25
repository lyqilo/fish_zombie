local CC = require("CC")
local baseClass = CC.class2("ItemBaseClass")

local showTime = 3 -- 显示时间
local showInterval = 3 -- 显示间隔

function baseClass:ctor(view,obj,closeCallback)
	self.view = view
	self.gameObject = obj
	self.closeCallback = closeCallback
	self.transform = obj.transform
end

function baseClass:FindChild(childNodeName)
	return self.transform:FindChild(childNodeName)
end

function baseClass:SubGet(childNodeName, typeName)
	return self.transform:SubGet(childNodeName,typeName)
end

function baseClass:SetClick()
	self.view:AddClick(self.btn,function ()
		self:Hide()
	end)
	self.view:AddClick(self.bgRTr,function()
		if self.callback then
			self.callback()
			self:Hide()
		end
	end)
end

function baseClass:InitData(data, isLeft, offset)
	self.showTime = data.showTime or showTime
	self.showInterval = data.showInterval or showInterval
	self.callback = data.callback

	offset = offset or 0
	offset = self:GetOffset(offset)
	isLeft = isLeft or false

	local bgRTr = self.bgRTr
	local anchorY = - (offset + bgRTr.sizeDelta.y / 2)
	self.startX = (isLeft and -1 or 1 ) * (self.view.screenWidth + bgRTr.rect.width)/2
	self.endX = (isLeft and -1 or 1 ) * (self.view.screenWidth - bgRTr.rect.width)/2

	bgRTr.anchoredPosition = Vector2(self.startX,anchorY);
	self.localY = bgRTr.localPosition.y
end

function baseClass:GetOffset(offset)
	logError("must override function GetOffset")
	return 0
end

local easePlay = CC.Action.EOutBack

function baseClass:PlayAnim()
	self.bgRTr:SetActive(true)
	self.view:RunAction(self.bgRTr, {"localMoveTo",self.endX,self.localY, 0.5, ease = easePlay,function ()
			self.view:StartTimer("AutoHide"..self.createTime,self.showTime,function()
				self:Hide()
			end)
		end})
end

function baseClass:OnHide()
	return
end

local easeHide = CC.Action.EOutBack

function baseClass:Hide()
	self:OnHide()
	self.view:StopTimer("AutoHide"..self.createTime)
	self.view:RunAction(self.bgRTr, {"localMoveTo",self.startX,self.localY, 0.3, ease = easeHide,function ()
		self.view:StopTimer("UpdateCountDown"..self.createTime)
		self.view:StopTimer("UpdateArenaCountDown"..self.createTime)
		self.bgRTr:SetActive(false)

		if self.closeCallback then
			self.closeCallback(self)
		end
	end})
end

return baseClass