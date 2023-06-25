

local CC = require("CC")
local SplashingSearchView = CC.uu.ClassView("SplashingSearchView")

function SplashingSearchView:ctor()
	self:InitVar();
end

function SplashingSearchView:OnCreate()	
	self.viewCtr = self:CreateViewCtr()
	self.viewCtr:OnCreate()


	self:InitContent()

	self.viewCtr:Guide()
end

function SplashingSearchView:InitVar()
	--在线好友数据
	self.onlineFriendData = {}
	--头像对象列表
	self.headObjList = {}
	--需要显示的好友对象
	self.matchFriendList = {}

	self.friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend")

	self.SplashingData = CC.DataMgrCenter.Inst():GetDataByKey("SplashingData")
	
	self.language = CC.LanguageManager.GetLanguage("L_SplashingSearchView")

	self.CurrentFriendId = 0

	self.CurrentConsume = 0

	self.DianjiEnum  = false
end


function SplashingSearchView:InitContent()
	self.BtnClose = self:FindChild("Frame/BtnClose")
	self.FriendNum = self:FindChild("Frame/Bottom/FriendNum")
	self.PoolNum = self:FindChild("Frame/Bottom/PoolNum")
	self.selectNumPanel = self:FindChild("selectNum")
	self.InputFieldText = self.selectNumPanel:FindChild("InputField")
	self.BtnMax = self.selectNumPanel:FindChild("BtnMax")
	self.BtnBG = self.selectNumPanel:FindChild("BtnBG")
	self.BtnSumit = self.selectNumPanel:FindChild("Btn")
	self.BtnGray = self.selectNumPanel:FindChild("BtnGray")
	self.CurrentPoolNum = self.selectNumPanel:FindChild("CurrentPoolNum")
	self.consumeNum = self.selectNumPanel:FindChild("consumeNum")
	self.NumText = self.selectNumPanel:FindChild("NumText")
	self.Novice_Guide = self:FindChild("Novice_Guide")
	self.GuideColse = self.Novice_Guide:FindChild("BG")
	self.GuideText = self.Novice_Guide:FindChild("Text")
	self.Count = self.Novice_Guide:FindChild("Count")
	self.dianji = self.Novice_Guide:FindChild("dianji")
	local scrollController = self:FindChild("Frame/ScrollerController"):GetComponent("ScrollerController");
	scrollController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		xpcall(function() self:InitItemData(tran,dataIndex,cellIndex) end, function(error) logError(error) end);
	end)
	scrollController:InitScroller(#self.matchFriendList)
	local inputField = self:FindChild("Frame/SearchInputField")
	local placeholder = self:FindChild("Frame/SearchInputField/Placeholder")
	UIEvent.AddInputFieldOnValueChange(inputField, function(str)
		if str == "" then
			return
		end
		self.matchFriendList = self.viewCtr:GetMatchFriendData(str);
		scrollController:RefreshScroller(#self.matchFriendList, 0);
	end)

	UIEvent.AddInputFieldOnValueChange(self.InputFieldText, function(str)
		if str == "" or str == "-" then
			return
		end
		local num = tonumber(str)
		if num < 0 then
			num = 0
			self.InputFieldText:GetComponent("InputField").text = num
		end
		local min_limit = self.SplashingData.GetSplashingSplash().Rest
		if min_limit > self.SplashingData.GetSplashingRest() then min_limit = self.SplashingData.GetSplashingRest() end
		if num > min_limit then
			num = min_limit
			self.InputFieldText:GetComponent("InputField").text = num
		end
		self.CurrentConsume = num * self.viewCtr.Money
		self.consumeNum:GetComponent("Text").text = CC.uu.NumberFormat(self.CurrentConsume)
	end)
	self:AddClickEvnt()
	self:InitUI()
	self:InitLanguage()
end

function SplashingSearchView:InitItemData(trans, dataIndex, cellIndex)
	local index = dataIndex + 1
	local friendData = 	self.matchFriendList[index]
	--清理HeadNode节点下挂载的头像节点
	local headNode = trans:FindChild("HeadNode")
	CC.uu.DestroyAllChilds(headNode)
	if self.headObjList[index] then
		self.headObjList[index]:Destroy()
		self.headObjList[index] = nil
	end
	--创建并挂载头像节点到HeadNode
	local headData = {}
	headData.parent = headNode
	headData.playerId = friendData.PlayerId
	headData.vipLevel = friendData.Level
	headData.portrait = friendData.Portrait
	headData.clickFunc = "unClick"
	self.headObjList[index] = CC.HeadManager.CreateHeadIcon(headData);
	trans:FindChild("Name"):SetText(friendData.Nick)
	trans:FindChild("Id"):SetText(friendData.PlayerId)
	self:AddClick(trans, function()
		self.CurrentFriendId = friendData.PlayerId
		self.selectNumPanel:SetActive(true)
		self:RefreshUI()
	end)
end

function SplashingSearchView:InitLanguage()
	 self:FindChild("Frame/Bottom/pooltext"):SetText(self.language.Splashing)
	 self:FindChild("Frame/Tab/Title"):SetText(self.language.FriendTitle)
	 self.selectNumPanel:FindChild("consumeText"):SetText(self.language.SlpuText)
	 self.selectNumPanel:FindChild("CurrentPoolText"):SetText(self.language.SplashingNum)
	 self.selectNumPanel:FindChild("Btn/Text"):SetText(self.language.ok)
	 self.selectNumPanel:FindChild("BtnGray/Text"):SetText(self.language.ok)
	 self:FindChild("Frame/SearchInputField/Placeholder"):SetText(self.language.InputID)
	 self:FindChild("Frame/BtnSearch/Text"):SetText(self.language.Search)
	 self.GuideText:SetText(self.language.GuideText)
	 self.NumText:SetText(self.language.NumText)
end

function SplashingSearchView:AddClickEvnt()
	self:AddClick("Frame/BtnSearch", "ClickBtnSearch")
	self:AddClick(self.BtnClose,"closeView")
	self:AddClick(self.BtnMax,"MaxSplashing")
	self:AddClick(self.BtnBG,"SlectNumClose")
	self:AddClick(self.BtnSumit,"SumitFunc")
	self:AddClick(self.GuideColse,"GuidePanelFalse")
end
--初始化ui
function SplashingSearchView:InitUI()
	self.FriendNum:GetComponent("Text").text = self.language.FriendText..#self.matchFriendList
	self:MaxSplashing()
	self.PoolNum:GetComponent("Text").text = self.SplashingData.GetSplashingSplash().Total - self.SplashingData.GetSplashingSplash().Rest.."/"..self.SplashingData.GetSplashingSplash().Total
	self:BtnActive()
	self:InitInputFiled(self.InputFieldText:GetComponent("InputField").text)
end

--刷新ui
function SplashingSearchView:RefreshUI()
	self.CurrentPoolNum:GetComponent("Text").text =  self.SplashingData.GetSplashingRest()
	self.PoolNum:GetComponent("Text").text = self.SplashingData.GetSplashingSplash().Total - self.SplashingData.GetSplashingSplash().Rest.."/"..self.SplashingData.GetSplashingSplash().Total
	self:BtnActive()
	self:InitInputFiled(self.InputFieldText:GetComponent("InputField").text)
end
--刷新泼水次数输入框的值
function SplashingSearchView:InitInputFiled(input)
	local num = nil
	if input == "" then 
		num = self.SplashingData.GetSplashingSplash().Rest
	else
		num = tonumber(input)
	end
	local min_limit = self.SplashingData.GetSplashingSplash().Rest
	if min_limit > self.SplashingData.GetSplashingRest() then min_limit = self.SplashingData.GetSplashingRest() end
	if num > min_limit then
		self.InputFieldText:GetComponent("InputField").text = min_limit
	end	
end

function SplashingSearchView:BtnActive()
	if self.SplashingData.GetSplashingSplash().Rest <= 0 then
		self.BtnSumit:SetActive(false)
		self.BtnGray:SetActive(true)
	else		
		self.BtnSumit:SetActive(true)
		self.BtnGray:SetActive(false)
	end
end

function SplashingSearchView:SumitFunc()
	if self.viewCtr.CurrentGuideView == 1 then
		self:GuidePanelFalse()
		self:SlectNumClose()
		 self.CurrentGuideView = 0
	end
	local num = self.InputFieldText:GetComponent("InputField").text
	if num == "" then 
		CC.ViewManager.ShowTip(self.language.illegalInput)
		return 
	end
	CC.ViewManager.ShowConnecting()
	self.viewCtr:ReqsplashwaterUrl(tonumber(num),self.CurrentFriendId)
end

function SplashingSearchView:SlectNumClose()
	self.selectNumPanel:SetActive(false)
end

--点击最大  泼水次数按钮
function SplashingSearchView:MaxSplashing()
	self.InputFieldText:GetComponent("InputField").text = self.viewCtr:SurplusNum()
end

--关闭界面
function SplashingSearchView:closeView()
	self:Destroy()
end
--打開引導界面
function SplashingSearchView:GuidePanelTrue()
	self.Novice_Guide:SetActive(true)
end
--關閉引導界面
function SplashingSearchView:GuidePanelFalse()
	self.Novice_Guide:SetActive(false)
end

--初始化引导界面的item
function SplashingSearchView:GuideItemInit()
	local num = 0
	if #self.matchFriendList >= 3 then
		num = 3
	else
		num = #self.matchFriendList
	end

	for i=1,num do
		local tran = self.Count:FindChild(i)
		tran:SetActive(true)
		self:InitItemData(tran,i - 1,i)
	end
	local time = 0
	self.dianji:SetActive(true)
	self:StartTimer("updateTimer",0.8,
	    function()
	    	if self.DianjiEnum  == false then
	    		self.DianjiEnum = true
	    	else
	    		self.DianjiEnum = false
	    	end
	    	self.dianji:SetActive(self.DianjiEnum)
	    end
    ,-1)
end

function SplashingSearchView:ClickBtnSearch()
	if #self.matchFriendList == 0 then
		CC.ViewManager.ShowTip(self.language.NoSearchResult);
	end
end


function SplashingSearchView:OnDestroy()

	for i,headObj in pairs(self.headObjList) do
		headObj:Destroy();
	end
	self:StopTimer("updateTimer")
	self.viewCtr:Destroy()
	self:ActionOut();
end

return SplashingSearchView
