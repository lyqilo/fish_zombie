--[[
	累计推广页
]]

local CC = require("CC")
local YearView = require("View/Agent/AgentGeneralizeYearView")
local MonthView = require("View/Agent/AgentGeneralizeMonthView")
local BaseClass = CC.uu.ClassView("AgentGeneralizeView")

function BaseClass:ctor()
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView")

	self.curYear = self.agentDataMgr.CurYear()
end

function BaseClass:OnCreate()

	self:LoadHistoryNewer()

	self:InitContent()
	self:InitTextByLanguage();
	-- self:RegisterEvent()

	-- self:UpdateShow()
end

function BaseClass:InitContent()
	self.mask = self:FindChild("mask")

	self:AddClick(self:FindChild("content/closeBtn"),slot(self.ActionOut,self))

	self.totalText = self:FindChild("content/totalText/Text")
	self.totalText.text = "0"
	self:AddClick(self:FindChild("content/totalText/Text/shareBtn"), function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnChangeAgentView, "AgentShareView")
		self:Destroy()
	end)

	self.yearView = YearView.new()
	self.yearView:Init(self:FindChild("content/year"),nil,slot(self.OnYearItemClick,self))
	self.yearView:SetActive(true)

	self.monthView = MonthView.new()
	self.monthView:Init(self:FindChild("content/month"),nil,slot(self.OnMonthBackClick,self))
	self.monthView:SetActive(false)
end

function BaseClass:InitTextByLanguage()
	self:FindChild("content/title").text = self.language.generalizetitle

	self:FindChild("content/totalText").text = self.language.generalizetotal
end

-- function BaseClass:RegisterEvent()
-- 	CC.HallNotificationCenter.inst():register(self,self.OnLimitTimeGiftReward,CC.Notifications.OnLimitTimeGiftReward)
-- end

-- function BaseClass:UnRegisterEvent()
-- 	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnLimitTimeGiftReward)
-- end

function BaseClass:UpdateShow()

end

function BaseClass:LoadHistoryNewer()
	self.agentDataMgr.LoadMonthPromote(function (data)
		if data then
			self.yearView:UpdateShow()

			self.totalText.text = self.agentDataMgr.GetGeneralizeCount()
		else
			self:ActionOut()
		end
	end)

end

function BaseClass:OnYearItemClick(month,year)
	self.agentDataMgr.LoadDayPromote(function (data)
		if data then
			self.yearView:SetActive(false)
			self.monthView:SetActive(true,month,year)
		else
			self:ActionOut()
		end
	end,year*100+month)
end

function BaseClass:OnMonthBackClick()
	self.yearView:SetActive(true)
	self.monthView:SetActive(false)
end

function BaseClass:OnDestroy()

end

-- function BaseClass:ActionIn() end

-- function BaseClass:ActionOut() end

return BaseClass