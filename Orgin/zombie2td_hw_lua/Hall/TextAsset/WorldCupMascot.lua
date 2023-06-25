local CC = require("CC")
local WorldCupMascot = CC.uu.ClassView("WorldCupMascot")
local M = WorldCupMascot

function M:ctor(param)
	self.param = param
	self.language = CC.LanguageManager.GetLanguage("L_WorldCupView")
	self.worldCupData = CC.DataMgrCenter.Inst():GetDataByKey("WorldCupData")
	self.contentList = {}
end

function M:OnCreate()
	self:RegisterEvent()
	self:InitContent()
	
	local data = self.worldCupData.GetMarqueeList()
	if data then
		self.contentList = data
		self.contentText.text = self:GetRandomContent()
		self:StartRandomContent()
	else
		self:ReqGetWorldCupMarquee()
	end
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnGetWorldCupMarqueeRsp, CC.Notifications.NW_ReqGetWorldCupMarquee)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function M:InitContent()
	self.content = self:FindChild("Content")
	self.contentText = self:FindChild("Content/Text")
end

function M:ReqGetWorldCupMarquee()
	CC.Request("ReqGetWorldCupMarquee")
end

function M:OnGetWorldCupMarqueeRsp(err,data)
	if err ~= 0 then
		logError("ReqGetWorldCupMarquee err:"..err)
		return
	end
	CC.uu.Log(data,"OnGetWorldCupMarqueeRsp",1)
	self.contentList = {}
	for _,v in ipairs(data.Content) do
		table.insert(self.contentList,v)
	end
	self.worldCupData.SetMarqueeList(self.contentList)
	self.contentText.text = self:GetRandomContent()
	self:StartRandomContent()
end

function M:StartRandomContent()
	self:DelayRun(0.5,function ()
			self:ShowBubble()
		end)
	self:StartTimer("Timer",8,function ()
			self:ShowBubble()
		end,-1)
end

function M:GetRandomContent()
	local index = math.random(1,#self.contentList)
	return self.contentList[index]
end

function M:ShowBubble()
	local width = self.contentText:GetComponent('RectTransform').rect.width + 20
	local height = self.contentText:GetComponent('RectTransform').rect.height + 30
	self:RunAction(self.content,{"spawn",
			{"to", 0, width, 0.2, function (value)
					self.content.width = value
				end},
			{"to", 0, height, 0.3, function (value)
					self.content.height = value
				end},
			{"delay", 7, function ()
				self:HideBubble()
			end}
		})
end

function M:HideBubble()
	local width = self.content:GetComponent('RectTransform').rect.width
	local height = self.content:GetComponent('RectTransform').rect.height
	self:RunAction(self.content,{"spawn",
			{"to", width, 0, 0.2, function (value)
					self.content.width = value
					if value == 0 then
						self.contentText.text = self:GetRandomContent()
					end
				end},
			{"to", height, 0, 0.3, function (value)
					self.content.height = value
				end},
		})
end

function M:ActionIn()

end

function M:ActionOut()

end

function M:OnDestroy()
	self:StopAllTimer()
	self:UnRegisterEvent()
end

return WorldCupMascot