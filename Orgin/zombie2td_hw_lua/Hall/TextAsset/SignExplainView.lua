-- region SignExplainView.lua
-- Date: 2019.7.13
-- Desc: 30天签到的规则说明
-- Author: chris
local CC = require("CC")
local SignExplainView = CC.uu.ClassView("SignExplainView")


--公告
function SignExplainView:ctor()
	  self.language = self:GetLanguage()
end

function SignExplainView:OnCreate()
	self:Init()
	self:setLanguageByText()
	self:AddClickEvent()
end

function SignExplainView:Init()
	self.BtnClose = self:FindChild("Layer_UI/DetalPanel/Frame/BtnClose") 
	self.TitleText = self:FindChild("Layer_UI/DetalPanel/Frame/Sign/Scroll View/Viewport/Content/TitleText")
	self.TopText = self:FindChild("Layer_UI/DetalPanel/Frame/Top/TopText") 
end

function SignExplainView:setLanguageByText()
	local parent = self:FindChild("Layer_UI/DetalPanel/Frame/Sign/Scroll View/Viewport/Content")
	-- CC.uu.ExplainContentSplit(parent,self.TitleText,self.language.content)
	self.TitleText:GetComponent("Text").text = self.language.content
	self.TopText:GetComponent("Text").text = self.language.title
end

function SignExplainView:AddClickEvent()
	self:AddClick(self.BtnClose,"Close")
end

--关闭
function SignExplainView:Close()
	self:Destroy()
end


function SignExplainView:OnDestroy()
	-- self:Destroy()
end

return SignExplainView