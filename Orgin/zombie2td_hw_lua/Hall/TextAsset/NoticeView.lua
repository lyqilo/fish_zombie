
local CC = require("CC")
local NoticeView = CC.uu.ClassView("NoticeView")


--公告
function NoticeView:ctor(content,title,callback)
	self.language = self:GetLanguage()
	self.str = content
	self.title = title
	self.callback = callback
end

function NoticeView:OnCreate()
	self.callback(true)
	self:AddClick("Frame/BtnClose", "ActionOut")
	self.content = self:FindChild("Frame/notice/Scroll View/Viewport/Content")
	self:setLanguageByText()
	self:NoticeContent()
end

--设置语言
function NoticeView:setLanguageByText()
	self:FindChild("Frame/top/TopText"):GetComponent("Text").text = self.language.notice
end

--系统公告
function NoticeView:NoticeContent()
	self:FindChild("Frame/notice/Scroll View/Viewport/Content/TitleText"):GetComponent("Text").text = self.title
	self:FindChild("Frame/notice/Scroll View/Viewport/Content/Text"):GetComponent("Text").text = self.str
	LayoutRebuilder.ForceRebuildLayoutImmediate(self.content)
end

function NoticeView:OnDestroy()
	if self.callback then
		self.callback(false)
	end
end

function NoticeView:ActionOut()
	self:SetCanClick(false)
    self:RunAction(self, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
		self:Destroy()
	end})
end

return NoticeView