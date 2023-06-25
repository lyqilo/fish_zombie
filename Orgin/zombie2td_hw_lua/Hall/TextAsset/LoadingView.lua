
local CC = require("CC")
local LoadingView = CC.uu.ClassView("LoadingView")

function LoadingView:GlobalNode()
	return GameObject.Find("DontDestroyGNode/GCanvas/GMain").transform
end

--重写view的Create方法,使用已存在节点
function LoadingView:Create()
	self.transform = CC.uu.findObject("Main/Canvas/Main/LoadingView")
	self:OnCreate()

	--设置bugly标签
	CC.ViewManager.SetBuglySceneId("Hall");
end

function LoadingView:OnCreate()
	CC.HallNotificationCenter.inst():register(self,self.CheckUpdate,CC.Notifications.ReqUpdateFinish)
	self.LoadingTip = self:FindChild("LoadingTip")	
	self.LoadingPtg = self:FindChild("LoadingPtg")	
	self:RunAction(self:FindChild("CircleImg"), {'rotateBy', 360, 2, loop=-1})
	if CC.DataMgrCenter.Inst():GetDataByKey("Update").isInitFinish() then
		self:CheckUpdate()
	end
end

function LoadingView:CheckUpdate()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.ReqUpdateFinish)
	local function tipCall(tip)
		self:HallUpdateResTip(tip)
	end
	local function processCall(process)
		--process 0 ~ 1 
		self:HallUpdateResPercentage(process)
	end
	CC.ResDownloadManager.CheckHall(tipCall,processCall)
end

function LoadingView:HallUpdateResTip(tip)
	self.LoadingTip.text = tip
end

function LoadingView:HallUpdateResPercentage(ptg)
	local showPtg = Mathf.Round(ptg * 100) .. "%"
	self.LoadingPtg.text = showPtg
end

return LoadingView