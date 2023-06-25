
local CC = require("CC")
local ShakeExplainView = CC.uu.ClassView("ShakeExplainView")


--排行榜
function ShakeExplainView:ctor(callback)
	self.language = self:GetLanguage()
	self.callback = callback
end

function ShakeExplainView:OnCreate()
	-- self:AddClick("Frame/BtnClose", "ActionOut")
	-- self.content = self:FindChild("Frame/notice/Scroll View/Viewport/Content")
	 self:Init()
	 self:setLanguageByText()
	-- self:NoticeContent()
	self:AddClickEvent()
end

function ShakeExplainView:Init()
	self.Frame = self:FindChild("Layer_UI/DetalPanel/Frame")
	self.BtnClose = self.Frame:FindChild("BtnClose")
	self.TopText = self.Frame:FindChild("Top/TopText")
	self.Content = self.Frame:FindChild("Shake/Scroll View/Viewport/Content")
	self.TitleText = self.Content:FindChild("TitleText")
	self.Text = self.Content:FindChild("Text")
	self.TitleText1 = self.Content:FindChild("TitleText1")
	self.Text1 = self.Content:FindChild("Text1")
end

function ShakeExplainView:AddClickEvent()
	self:AddClick(self.BtnClose,"DetalClose")
end

function ShakeExplainView:DetalClose()
	self:ActionOut()
end

--设置语言
function ShakeExplainView:setLanguageByText()
	self.TitleText:GetComponent("Text").text = self.language.title
	self.Text:GetComponent("Text").text = self.language.content
	self.TitleText1:GetComponent("Text").text = self.language.title1
	self.Text1:GetComponent("Text").text = self.language.content1
	self.TopText:GetComponent("Text").text = self.language.title
end

--摇摇乐
function ShakeExplainView:NoticeContent()
	-- self:FindChild("Frame/notice/Scroll View/Viewport/Content/TitleText"):GetComponent("Text").text = self.title
end

function ShakeExplainView:OnDestroy()
	if self.callback then
		self.callback()
	end
end

function ShakeExplainView:ActionOut()
	self:SetCanClick(false)
    self:RunAction(self, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
		self:Destroy()
	end})
end

return ShakeExplainView