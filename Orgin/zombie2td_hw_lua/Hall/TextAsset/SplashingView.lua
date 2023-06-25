

local CC = require("CC")
local SplashingView = CC.uu.ClassView("SplashingView")

function SplashingView:ctor(callback)
	self.callback = callback
	self.CurrentSplashing = 0
	self.SplashingData = CC.DataMgrCenter.Inst():GetDataByKey("SplashingData")
	self.language = CC.LanguageManager.GetLanguage("L_SplashingView")
	--头像对象列表
	self.headObjList = {}
end

function SplashingView:OnCreate()
	self.callback(true)
	self.viewCtr = self:CreateViewCtr()
	self.viewCtr:OnCreate()
	self:Init()
	self:AddClickEvnt()
end

function SplashingView:RegisterEvent()
	--CC.HallNotificationCenter.inst():register(self,self.ChangeNick,CC.Notifications.ChangeNick)
end


function SplashingView:unRegisterEvent()
	--CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.ChangeNick)
end

function SplashingView:Init()
	self.PrivatePanel = self:FindChild("Layer_UI/PrivatePanel")
	self.Splashing = self:FindChild("Layer_UI/Splashing")
	self.BtnRank = self.Splashing:FindChild("BtnRank")
	self.BtnRankClose = self.PrivatePanel:FindChild("BG")
	self.BtnResult = self.Splashing:FindChild("BtnResult")
	self.Winning_List = self:FindChild("Layer_UI/Winning_List")
	self.BtnResultClose = self.Winning_List:FindChild("BG")
	self.Btndetails = self.Splashing:FindChild("Btndetails")
	self.DetalPanel =  self:FindChild("Layer_UI/DetalPanel")
	self.BtnCloseDetal = self.DetalPanel:FindChild("Frame/BtnClose")
	self.BtnSplashing = self.Splashing:FindChild("BtnSplashing")
	self.CurrentPoolNum = self.Splashing:FindChild("CurrentPoolNum")
	self.PoolNum = self.Splashing:FindChild("BG/PoolNum")
	self.forge = self.Splashing:FindChild("BG/forge")
	self.Frame =  self:FindChild("Layer_UI/Frame")
	self.BtnNo = self.Frame:FindChild("BtnFitter/BtnNo")
	self.BtnOk = self.Frame:FindChild("BtnFitter/BtnOk")
	self.BtnSplashingGray = self.Splashing:FindChild("BtnSplashingGray")
	self.scrollController = self:FindChild("Layer_UI/PrivatePanel/ScrollerController"):GetComponent("ScrollerController")
	self.MyRank = self.PrivatePanel:FindChild("Down/CurrentRankText/Rank")
	self.CurrentBonus = self.PrivatePanel:FindChild("Down/CurrentRankText/Rank/CurrentBonusText/CurrentBonus")
	self.Sum = self.PrivatePanel:FindChild("Down/SumText/Sum")
	self.penquan = self.Splashing:FindChild("penquan")
	self.content = self:FindChild("Layer_UI/DetalPanel/Frame/notice/Scroll View/Viewport/Content")
	self.scrollController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		xpcall(function() self:InitItemData(tran,dataIndex,cellIndex) end, function(error) logError(error) end)
	end)
	self:RefreshUI()
	self:CountDownPanel()
	self:InitLanguage()
end

function SplashingView:InitLanguage()
	 self:FindChild("Layer_UI/Splashing/BG/paddlingpool_Text"):SetText(self.language.InputText)
	 self:FindChild("Layer_UI/Splashing/BtnSplashing/Text"):SetText(self.language.SplashingNum)
	 self:FindChild("Layer_UI/Splashing/BtnSplashingGray/Text"):SetText(self.language.SplashingNum)
	 self:FindChild("Layer_UI/PrivatePanel/Panel/Ranktext"):SetText(self.language.RankText)
	 self:FindChild("Layer_UI/PrivatePanel/Panel/Nametext"):SetText(self.language.NameText)
	 self:FindChild("Layer_UI/PrivatePanel/Panel/jianglitext"):SetText(self.language.SumJiangli)
	 self:FindChild("Layer_UI/PrivatePanel/Down/CurrentRankText"):SetText(self.language.CurrentRankText)
	 self:FindChild("Layer_UI/PrivatePanel/Down/CurrentRankText/Rank/CurrentBonusText"):SetText(self.language.SumJiangli)
	 self:FindChild("Layer_UI/PrivatePanel/Down/SumText"):SetText(self.language.SumJiangchi)
	 self.Winning_List:FindChild("NonedataText"):GetComponent("Text").text = self.language.Nokaijiang
	 self:FindChild("Layer_UI/DetalPanel/Frame/Top/TopText"):GetComponent("Text").text = self.language.DetalTitle
	 self.content:FindChild("Text"):GetComponent("Text").text = self.language.DetalCount
	 self.content:FindChild("TitleText"):GetComponent("Text").text = self.language.DetalTitle2 
	 self:FindChild("Layer_UI/Frame/Message (1)"):GetComponent("Text").text = self.language.ConcumeText2
	 self:FindChild("Layer_UI/Frame/Message"):GetComponent("Text").text = self.language.ConcumeText
	 self:FindChild("Layer_UI/Frame/BtnFitter/BtnNo/Text"):GetComponent("Text").text = self.language.cancle
	 self:FindChild("Layer_UI/Frame/BtnFitter/BtnOk/Text"):GetComponent("Text").text = self.language.ok

	 -- self.co = CC.uu.DelayRun(1,
  --       function ()	
		-- 	LayoutRebuilder.ForceRebuildLayoutImmediate(self.content)
  --      		CC.uu.CancelDelayRun(self.co)
  --       end
  --   )
end

function SplashingView:AddClickEvnt()
	self:AddClick("Layer_Mask","closeView")
	self:AddClick(self.BtnRank,"RankOpen")
	self:AddClick(self.BtnRankClose,"RankClose")
	self:AddClick(self.BtnResult,"ResultOpen")
	self:AddClick(self.BtnResultClose,"ResultClose")
	self:AddClick(self.Btndetails,"detailsOpen")
	self:AddClick(self.BtnCloseDetal,"detailsClose")
	self:AddClick(self.BtnSplashing,"SplashingFunc")
	self:AddClick(self.BtnNo,"FitterClose")
	self:AddClick(self.BtnOk,"FitterOpen")
end

--刷新ui
function SplashingView:RefreshUI()
	self.CurrentPoolNum:GetComponent("Text").text = self.SplashingData.GetSplashingSplash().Total - self.SplashingData.GetSplashingSplash().Rest.."/"..self.SplashingData.GetSplashingSplash().Total
	self.PoolNum:GetComponent("Text").text = self.SplashingData.GetSplashingTotal() - self.SplashingData.GetSplashingRest().."/"..self.SplashingData.GetSplashingTotal()
	self.forge:GetComponent("Image").fillAmount =(self.SplashingData.GetSplashingTotal() - self.SplashingData.GetSplashingRest()) /self.SplashingData.GetSplashingTotal()
	self:IsSetActive()
end

function SplashingView:RefreshActive()
	self.DetalPanel:SetActive(false)
	self.Frame:SetActive(false)
	self.PrivatePanel:SetActive(false)
end

--刷新ui
function SplashingView:RefreshRewardUI()
	self.Winning_List:SetActive(true)
	if self.SplashingData.GetSplashingSplashRewardInfo() == nil then
		self.Winning_List:FindChild("NonedataText"):SetActive(true)
		self.Winning_List:FindChild("Item"):SetActive(false)
		return
	end
	self.Winning_List:FindChild("NonedataText"):SetActive(false)
	self.Winning_List:FindChild("Item"):SetActive(true)
	for i,v in ipairs(self.SplashingData.GetSplashingSplashRewardInfo()) do
		if i > 6 then
			return
		end
		self.Winning_List:FindChild("Item/"..i.."/ItemName"):GetComponent("Text").text = v.Name
		self.Winning_List:FindChild("Item/"..i.."/ItemMoneyText"):GetComponent("Text").text = CC.uu.NumberFormat(v.Reward.Count)
		if i <= 3 then
			local headNode = self.Winning_List:FindChild("Item/"..i.."/ItemHeadMask/Node")
			CC.uu.DestroyAllChilds(headNode)
			if self.headObjList[i] then
				self.headObjList[i]:Destroy()
				self.headObjList[i] = nil
			end
			--创建并挂载头像节点到HeadNode
			local headData = {}
			headData.parent = headNode
			headData.playerId = v.PlayerId
			headData.vipLevel = v.VIP
			headData.portrait = v.Portrait
			--headData.clickFunc = "unClick"
			self.headObjList[i] = CC.HeadManager.CreateHeadIcon(headData)
		end		
	end
end

--在倒计时或者  水池剩余次数小于0
function SplashingView:IsSetActive()
	if self.SplashingData.GetSplashingSplashCountDown() > 0 or self.SplashingData.GetSplashingRest() <= 0 then
		self.BtnSplashingGray:SetActive(true)
		self.BtnSplashing:SetActive(false)
		self.penquan:SetActive(true)
	else		
		self.BtnSplashingGray:SetActive(false)
		self.BtnSplashing:SetActive(true)
		self.penquan:SetActive(false)
	end
end

--倒计时
function SplashingView:CountDownPanel()
	local CountDownView = self.Splashing:FindChild("CountDownView")
	local CountDown = CountDownView:FindChild("CountDown")
	local CountDownText = CountDown:GetComponent("Text")
	local num = self.SplashingData.GetSplashingSplashCountDown()
	if num == nil or num <= 0 then return end
	self:StartTimer("updateTimer", 1,
	    function()
	    	num = num - 1
	    	CountDownView:SetActive(true)
			CountDownText.text = num
	    	if num <= 0 then
				--CC.ViewManager.ShowConnecting()
				self.BtnSplashingGray:SetActive(false)
				self.BtnSplashing:SetActive(true)
	    		CountDownView:SetActive(false)
				self:StopTimer("updateTimer")
	    	end	    	
	    end
    ,-1)
end

--打开泼水消耗窗口
function SplashingView:FitterOpen()
	CC.ViewManager.Open("SplashingSearchView")
	self.Frame:SetActive(false)
end

--关闭泼水消耗窗口
function SplashingView:FitterClose()
	self.Frame:SetActive(false)
end

--打开好友界面界面
function SplashingView:SplashingFunc()
	local isSplashing = Util.GetFromPlayerPrefs("Splashing")
	if #self.viewCtr.FriendTab <= 0 then
		CC.ViewManager.ShowTip(self.language.FriendTips,3)
		return
	end

	if isSplashing ~= "true" then 
		self.Frame:SetActive(true)
		Util.SaveToPlayerPrefs("Splashing","true")
	else
		self:FitterOpen()
	end
end

--关闭说明界面
function SplashingView:detailsClose()
	self.DetalPanel:SetActive(false)
end

--打开说明界面
function SplashingView:detailsOpen()
	self.DetalPanel:SetActive(true)
	LayoutRebuilder.ForceRebuildLayoutImmediate(self.content)
end

--关闭回合界面
function SplashingView:ResultClose()
	self.Winning_List:SetActive(false)
end

--打开回合榜界面
function SplashingView:ResultOpen()
	self:RefreshRewardUI()
end

--皇冠图片切换
local function SpriteInfo(key,value)
	if key <= 3 then
		if key == 1 then
			value:FindChild("DragBG/obj/"..tostring(1)):SetActive(true)
			value:FindChild("DragBG/obj/"..tostring(2)):SetActive(false)
			value:FindChild("DragBG/obj/"..tostring(3)):SetActive(false)
		elseif key == 2 then
			value:FindChild("DragBG/obj/"..tostring(1)):SetActive(false)
			value:FindChild("DragBG/obj/"..tostring(2)):SetActive(true)
			value:FindChild("DragBG/obj/"..tostring(3)):SetActive(false)
		elseif key == 3 then
			value:FindChild("DragBG/obj/"..tostring(1)):SetActive(false)
			value:FindChild("DragBG/obj/"..tostring(2)):SetActive(false)
			value:FindChild("DragBG/obj/"..tostring(3)):SetActive(true)
		end
		value:FindChild("DragBG/obj"):SetActive(true)
		value:FindChild("DragBG/Rank"):GetComponent("Text").text = ""
	else
		value:FindChild("DragBG/obj"):SetActive(false)
		value:FindChild("DragBG/Rank"):GetComponent("Text").text = key
	end	
end
--初始化排行榜item
function SplashingView:InitItemData(trans,dataIndex,cellIndex)
	local index = dataIndex + 1
	trans.transform.name = index
	trans:FindChild("DragBG/Name"):GetComponent("Text").text = self.SplashingData.GetRankIndex(index).Name
	trans:FindChild("DragBG/Text"):GetComponent("Text").text = CC.uu.NumberFormat(self.SplashingData.GetRankIndex(index).Reward)
	SpriteInfo(index,trans)
end

function SplashingView:Down()
	if self.SplashingData.GetMyRank() < 0 then
		self.MyRank:GetComponent("Text").text = self.language.noraking	
	else
		self.MyRank:GetComponent("Text").text = self.SplashingData.GetMyRank() + 1
	end
	self.CurrentBonus:GetComponent("Text").text = CC.uu.NumberFormat(self.SplashingData.GetMyRankData().Reward)
	self.Sum:GetComponent("Text").text = CC.uu.NumberFormat(self.SplashingData.GetSplashingSplashTotalCost())
end


--关闭排行榜界面
function SplashingView:RankClose()
	self.PrivatePanel:SetActive(false)
end

--打开排行榜界面
function SplashingView:RankOpen()
	CC.ViewManager.ShowConnecting()
	self.viewCtr:ReqRankInfo()
end

--关闭界面
function SplashingView:closeView()
	self:Destroy()
end

function SplashingView:ActionIn()
	
end

function SplashingView:OnDestroy()
	for i,headObj in pairs(self.headObjList) do
		headObj:Destroy();
	end
	if self.callback then
		self.callback(false)
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
	end
end

return SplashingView
