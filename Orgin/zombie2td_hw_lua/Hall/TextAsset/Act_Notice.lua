
local CC = require("CC")
local Act_Notice = CC.uu.ClassView("Act_Notice")
--VIP活动
function Act_Notice:ctor(parent,language)
	self.parent = parent
	self.NoticeData = CC.DataMgrCenter.Inst():GetDataByKey("NoticeData")
	self.language = language
end

function Act_Notice:OnCreate()
	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
	self.NoticeData = CC.DataMgrCenter.Inst():GetDataByKey("NoticeData")

	self.tips = self:FindChild("Tips"):GetComponent("Text");

	if not self.NoticeData.GetContent() then
		local url = self.WebUrlDataManager.GetNoticeUrl()
		self.tips.text = self.language.notice_loading
		local www = CC.HttpMgr.Get(url,function (www)
			local table = Json.decode(www.downloadHandler.text)
			if table.status == 1 then 
				self.NoticeData.SetNotice(table.Title,table.data)
				if not CC.LocalGameData.GetNoticeState() then
					CC.LocalGameData.SetNoticeState(true)
				end
				self:ShowNotice()
			else
				self.tips.text = self.language.notice_fail
			end
		end)
	else
		self:ShowNotice()
	end
	self.transform:SetParent(self.parent.transform, false)
end

function Act_Notice:ShowNotice()
	self.tips:SetActive(false)
	self.title = self.NoticeData.GetTitle()
	self.content = self.NoticeData.GetContent()
	if self.title then
		self:FindChild("Scroll View/Viewport/Content/Title"):GetComponent("Text").text = self.title or ""
	else
		self:FindChild("Scroll View/Viewport/Content/Title"):GetComponent("Text").text = ""
	end
	if self.content then
		self:FindChild("Scroll View/Viewport/Content/Content"):GetComponent("Text").text = self.content or ""
	else
		self:FindChild("Scroll View/Viewport/Content/Content"):GetComponent("Text").text = ""
	end
	LayoutRebuilder.ForceRebuildLayoutImmediate(self:FindChild("Scroll View/Viewport/Content/Content"))
end

function Act_Notice:InitCDView()
end

function Act_Notice:OnDestroy()
end

return Act_Notice