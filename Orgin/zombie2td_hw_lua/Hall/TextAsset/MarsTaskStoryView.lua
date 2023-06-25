local CC = require("CC")
local MarsTaskStoryView = CC.uu.ClassView("MarsTaskStoryView")
local M = MarsTaskStoryView

--[[
param
storyIdx:第几个活动故事
content: "Begin"故事前言 "Finish"故事后言
callBack:回调
]]
function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param
    self.language = self:GetLanguage()
	self.curPage = 1
end

function M:OnCreate()
    self:InitContent()
	self:InitTextByLanguage()
end

function M:InitContent()
	self.storyTrans = self:FindChild(string.format("Frame/Story%s/%s",self.param.storyIdx,self.param.content))
	self.storyTrans:SetActive(true)
	self:AddClick("Frame/Btn","OnClickScreen")
	if self.param.storyIdx == 1 then
		self.musicName = CC.Sound.GetMusicName()
		CC.Sound.PlayHallBackMusic("MarsStory1_1")
	end
end

function M:InitTextByLanguage()
	local languageTable = self.language[self.param.storyIdx][self.param.content]
	for page,v in ipairs(languageTable) do
		for i,text in pairs(v) do
			self.storyTrans:FindChild(string.format("%s/Content/%s",page,i)).text = text
		end
	end
	self:FindChild("Frame/Story1/Begin/3/Content/Button/Text").text = self.language[1].BtnGetTask
	self:FindChild("Frame/Btn/Text").text = self.language.btnContinue
end

function M:OnClickScreen()
	if self.storyTrans:FindChild(self.curPage+1) then
		self.curPage = self.curPage + 1
		if self.param.storyIdx == 1 and self.curPage == 2 then
			CC.Sound.StopBackMusic()
			CC.Sound.PlayHallEffect("MarsStory1_2")
		end
		self.storyTrans:FindChild(self.curPage):SetActive(true)
	else
		self:OnStoryEnd()
	end
end

function M:OnStoryEnd()
	self:ActionOut()
	if self.param.callBack then self.param.callBack({orgMusic = self.musicName}) end
end

function M:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {"spawn",
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.2},
			{"scaleTo",1,0,0},
			{"scaleTo",1,1,0.2, function() self:SetCanClick(true) end}
		});
end

function M:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {"spawn",
			{"fadeToAll", 0, 0.2},
			{"scaleTo",1,0,0.2, function() self:Destroy() end}
		});

end

function M:OnDestroy()

end

return MarsTaskStoryView