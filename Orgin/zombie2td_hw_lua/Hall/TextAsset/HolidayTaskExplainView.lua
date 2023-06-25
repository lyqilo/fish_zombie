local CC = require("CC")
local HolidayTaskExplainView = CC.uu.ClassView("HolidayTaskExplainView")

function HolidayTaskExplainView:ctor(param)
	self:InitVar(param)
end

function HolidayTaskExplainView:InitVar(param)
	self.param = param
    self.language = CC.LanguageManager.GetLanguage("L_HolidayTaskView")
end

function HolidayTaskExplainView:OnCreate()

    self:InitContent()
	self:InitTextByLanguage()
end

function HolidayTaskExplainView:InitContent()
	self:AddClick("Bg/Close","ActionOut")
end

function HolidayTaskExplainView:InitTextByLanguage()
	self:FindChild("Bg/Title").text = self.language.expTitle
	self:FindChild("Frame/TopText").text = self.language.expTopText
	self:FindChild("Frame/BottomText1").text = self.language.expBottomText1
	self:FindChild("Frame/BottomText2").text = self.language.expBottomText2
	for i=1,7 do
		local item = self:FindChild("Frame/Scroll View/Viewport/Content/Item"..i)
		item:FindChild("Title").text = self.language.sandTower[i].Name
		item:FindChild("Desc").text = self.language.expItem[i].Desc
	end
	
end

function HolidayTaskExplainView:OnDestroy()

end

return HolidayTaskExplainView