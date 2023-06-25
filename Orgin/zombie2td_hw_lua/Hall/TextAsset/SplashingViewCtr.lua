
local CC = require("CC")

local SplashingViewCtr = CC.class2("SplashingViewCtr")
local configData = nil

function SplashingViewCtr:ctor(view, param)

	self:InitVar(view, param);
	--self.IsShow = true
	
end

function SplashingViewCtr:OnCreate()
	self:InitData();
	self.IsShow = true
end

function SplashingViewCtr:InitVar(view, param)

	-- logError("Rewards traceback"..debug.traceback())
	self.param = param;
	--UI对象
	self.view = view;

	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")

	self.SplashingData = CC.DataMgrCenter.Inst():GetDataByKey("SplashingData")

	self.friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend")
	--CC.uu.Log(self.configData,"configData = ",3)
	self:RegisterEvent()

	self.FriendTab = {}
end

function SplashingViewCtr:InitData()
	for _,v in pairs(self.friendDataMgr.GetFriendListData()) do
		table.insert(self.FriendTab, v)
	end
end

function SplashingViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnPushSplashInfo, CC.Notifications.OnPushSplashInfo)
end

function SplashingViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnPushSplashInfo)
end

--推送泼水节信息
function SplashingViewCtr:OnPushSplashInfo(data)
	local ID = CC.Player.Inst():GetSelfInfoByKey("Id")
	if data.Splash.PlayerId == ID then
		self.SplashingData.SetSplashingSelf(data.Splash)
	end
	self.SplashingData.SetSplashingInfo(data)
	if self.SplashingData.GetSplashingSplashStatus() == 0 then
		self.view:RefreshRewardUI()
		self.SplashingData.SetSplashingSelfRest()
		self.view:RefreshActive()
	end
	self.view:RefreshUI()
	self.view:CountDownPanel()
end

--获取泼水节信息
function SplashingViewCtr:ReqRankInfo()
	local url = self.WebUrlDataManager.GetsplashrankUrl(50)
	local www = CC.HttpMgr.Get(url,
	function (www)
		local table = Json.decode(www.downloadHandler.text)
		CC.ViewManager.CloseConnecting()
		if table.code == 0 then
			self.SplashingData.SetRankInfo(table.data)
			self.view.PrivatePanel:SetActive(true)
			self.view.scrollController:InitScroller(self.SplashingData.GetRankLen())
			self.view:Down()
		elseif table.code == 293 then
			CC.ViewManager.ShowTip(self.language.GetRankingFaile,3)
		else
			CC.ViewManager.ShowTip(self.language.NoneRankData,3)
		end
	end,
	function ()
		CC.ViewManager.CloseConnecting()
	end)
end

function SplashingViewCtr:SetHeadIcon(param,chipNode,IconBool,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

function SplashingViewCtr:Destroy()
	self:UnRegisterEvent()
end

return SplashingViewCtr