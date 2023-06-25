
local CC = require("CC")

local NoticeViewCtr = CC.class2("NoticeViewCtr")

function NoticeViewCtr:ctor(view)
	self.Content = ""
	self:InitVar(view)
end

function NoticeViewCtr:OnCreate()
	self:ReqGetActiveRank()
end

function NoticeViewCtr:Destroy()

end

function NoticeViewCtr:InitVar(view)
	--UI对象
	self.view = view
end
--获取公告内容
function NoticeViewCtr:ReqGetActiveRank()
	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetNoticeUrl()
	local www = CC.HttpMgr.Get(url,function (www)
		local table = Json.decode(www.downloadHandler.text)
		CC.uu.Log(table,"table = ")
		if table.status == 1 then --table.data
			self.view:NoticeContent(table.data,table.Title)
		else
			CC.ViewManager.ShowTip(self.view.language.tip_allocServer)
		end
	end)
end

return NoticeViewCtr