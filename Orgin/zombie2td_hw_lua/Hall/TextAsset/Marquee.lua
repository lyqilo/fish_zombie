local CC = require("CC")
local Marquee = CC.uu.ClassView("Marquee")

function Marquee:ctor(param)
    self.param = param
    self.MessageTable = {}
    self.timerTag = "Report"
end

function Marquee:OnCreate()
    self.ImageBg = self:FindChild("ImageBg")
    self.ImageBgWidth = self:FindChild("ImageBg"):GetComponent('RectTransform').rect.width / 2
    self.Text = self.ImageBg:FindChild("Text")
    self.EffectNode = self:FindChild("Effect")
    
    if self.param.parent then
        self.transform:SetParent(self.param.parent)
        self.transform.localPosition = Vector3.zero
    end
    if self.param.ImageBgPath then
        self:SetImage(self.ImageBg,self.param.ImageBgPath)
    end
    if self.param.ImageBgSize then
        if self.param.ImageBgSize.w then
            self.ImageBg.transform.width = self.param.ImageBgSize.w
            self.ImageBgWidth = self.param.ImageBgSize.w / 2
        end
        if self.param.ImageBgSize.h then
            self.ImageBg.transform.height = self.param.ImageBgSize.h
        end
    end
    if self.param.effectPrefab then
        self.effect = CC.uu.LoadHallPrefab("", self.param.effectPrefab, self.EffectNode)
        self.effect:SetActive(true)
        self.EffectNode:SetActive(true)
    end
    if self.param.effectPos and self.effect then
        self.effect.localPosition = Vector3(self.param.effectPos.x,self.param.effectPos.y,0)
    end
end

function Marquee:Report(Message,Priority)
	if Priority then
        table.insert(self.MessageTable,1,Message)
    else
        table.insert(self.MessageTable,Message)
    end

    self:StartReport()
end

function Marquee:StartReport()
	if self.isReporting then return end
	self.isReporting = true

	self:StartTimer(self.timerTag,0.5,function()
		if self.isTipMoving then 
			return
		else
			self:StopAction(self.action)
			self.action = nil
        end
        
		if table.length(self.MessageTable) <= 0 then
			self.Text:GetComponent('Text').text = ""
			self.transform:SetActive(false)
			self:StopTimer(self.timerTag)
            self.isReporting = false
            if self.param.ReportEnd then
                self.param.ReportEnd()
            end
		else
			self.isTipMoving = true
	        local text = self.MessageTable[1]
			table.remove(self.MessageTable,1)
			self.Text.localPosition = Vector3(1000,self.param.TextPos or 0,0)
			self.Text:GetComponent('Text').text = string.gsub(CC.uu.ReplaceFace(text,23),"\n"," ")
			self.transform:SetActive(true)
			self:DelayRun(0.1,function()
				local textW = self.Text:GetComponent('RectTransform').rect.width
                local half = textW/2
				self.Text.localPosition = Vector3(half + self.ImageBgWidth, self.param.TextPos or 0, 0)
				self.action = self:RunAction(self.Text, {"localMoveTo", -half - self.ImageBgWidth, self.param.TextPos or 0, self.param.ReportSpeed or (0.5 * math.max(16,textW/40)), function()
					self.action = nil
					self.isTipMoving = false
				end})
			end)
		end
	end,-1)
end

function Marquee:OnDestroy()
	if self.isReporting then
		self.Text:GetComponent('Text').text = ""
		self:Hide()
		self.isReporting = false
	end
end

return Marquee