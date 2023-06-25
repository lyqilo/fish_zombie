
local CC = require("CC")

local SplashingSearchViewCtr = CC.class2("SplashingSearchViewCtr")
local configData = nil

function SplashingSearchViewCtr:ctor(view, param)

	self:InitVar(view, param);
	--self.IsShow = true
	
end

function SplashingSearchViewCtr:OnCreate()
	self:InitData()
end

function SplashingSearchViewCtr:Destroy()
	self:UnRegisterEvent()
end


function SplashingSearchViewCtr:InitVar(view, param)

	-- logError("Rewards traceback"..debug.traceback())
	self.param = param;
	--UI对象
	self.view = view;
	--在线好友数据
	self.onlineFriendData = {}

	self.IconTab = {}

	self.friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend")

	self.material = ResMgr.LoadAsset("material", "MaskDefaultGray")

	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")

	self.SplashingData = CC.DataMgrCenter.Inst():GetDataByKey("SplashingData")
	
	self.language = CC.LanguageManager.GetLanguage("L_SplashingSearchView")

	self.Money = 19999

	self.CurrentGuideView = 0  -- 0 当前不在新手引导，-- 1 在新手引导
	--CC.uu.Log(self.configData,"configData = ",3)
	self:RegisterEvent()
end


function SplashingSearchViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnPushSplashInfo, CC.Notifications.OnPushSplashInfo)
end

function SplashingSearchViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnPushSplashInfo)
end

--推送泼水节信息
function SplashingSearchViewCtr:OnPushSplashInfo(data)
	local ID = CC.Player.Inst():GetSelfInfoByKey("Id")
	if data.Splash.PlayerId == ID then
		self.SplashingData.SetSplashingSelf(data.Splash)
	end
	self.SplashingData.SetSplashingInfo(data)
	self.view:RefreshUI()
	--CC.ViewManager.CloseConnecting()
	if self.SplashingData.GetSplashingSplashStatus() == 0 then
		self.view:OnDestroy()
	end	
end

function SplashingSearchViewCtr:InitData()
	for _,v in pairs(self.friendDataMgr.GetFriendListData()) do
		table.insert(self.onlineFriendData, v)
	end
	self.view.matchFriendList = self:SortFriend()
end

function SplashingSearchViewCtr:SortFriend()
	local Temptab = {}
	for i,v in ipairs(self.onlineFriendData) do
		if v.Online then
			--在线好友
			table.insert(Temptab,1,v)
		else
			--不在线好友
			table.insert(Temptab,table.length(Temptab)+ 1,v)
		end
	end
	return Temptab
end

function SplashingSearchViewCtr:GetMatchFriendData(id)	
	local list = {}
	for _,v in ipairs(self.onlineFriendData) do
		if string.match(tostring(v.PlayerId), id) then
			table.insert(list, v);
		end
	end
	return list;
end


function SplashingSearchViewCtr:SetHeadIcon(param,chipNode,IconBool,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

--剩余泼水次数
function SplashingSearchViewCtr:SurplusNum()
	local Num = 0
	Num = self.SplashingData.GetSplashingSplash().Rest
	if self.SplashingData.GetSplashingRest() <= self.SplashingData.GetSplashingSplash().Rest then
		Num = self.SplashingData.GetSplashingRest()
	end
	return Num
end

function SplashingSearchViewCtr:Guide()
	local isSplashingGuide = Util.GetFromPlayerPrefs("SplashingGuide")
	if isSplashingGuide ~= "true" then 
		Util.SaveToPlayerPrefs("SplashingGuide","true")
		self.view:GuidePanelTrue(true)
		self.view:GuideItemInit()
		self.CurrentGuideView = 1
	end
end

--泼水
function SplashingSearchViewCtr:ReqsplashwaterUrl(times,friendid)
	local url = self.WebUrlDataManager.GetsplashwaterUrl(times,friendid)
	local www = CC.HttpMgr.Get(url,
	function (www)
		local table = Json.decode(www.downloadHandler.text)
		CC.ViewManager.CloseConnecting()
		if table.code == 0 then
			CC.ViewManager.ShowTip(self.language.SplashingSuccess,3)
		end
	end,
	function (err,www)
		CC.ViewManager.CloseConnecting()
		local table = Json.decode(www.downloadHandler.text)
		if table.code == 291 then
			CC.ViewManager.ShowTip(self.language.Faile,3)
		elseif table.code == 292 then
			CC.ViewManager.ShowTip(self.language.Splashingxiaoyu,3)
		elseif table.code == 294 then
			CC.ViewManager.ShowTip(self.language.Faile,3)
		elseif table.code == 295 then
			CC.ViewManager.ShowTip(self.language.Faile,3)
		elseif table.code == 296 then
			CC.ViewManager.ShowTip(self.language.Faile,3)
		elseif table.code == 297 then
			CC.ViewManager.ShowTip(self.language.FaileSplashing,3)	
			self.view:OnDestroy()
			CC.ViewManager.Open("StoreView")
		end
	end)
end



return SplashingSearchViewCtr