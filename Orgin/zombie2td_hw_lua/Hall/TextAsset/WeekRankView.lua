

local CC = require("CC")
local WeekRankView = CC.uu.ClassView("WeekRankView")

function WeekRankView:ctor()
    self.RankDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RankData")
    self.language = CC.LanguageManager.GetLanguage("L_RankingListView");
	self.indexPage = 3
	self.HeadIcon = nil
	self.IconTab = {}
	self.RankNum = 0
end

function WeekRankView:OnCreate()
	self:Init()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
end

function WeekRankView:Init()
	--init页面
	self.WeekendView = self:FindChild("Layer_UI/WeekendView")
	self.Weeken_RankItem = self:FindChild("Layer_UI/WeekendView/WeekenDownTip/RankItem")
	self.WeekendLayer_UI = self:FindChild("Layer_UI/WeekendView")
	self.WeekendLoopScrollRect = self:FindChild("Layer_UI/WeekendView/VerticalScroll"):GetComponent("LoopScrollRect")
	self.WeekendVerticalLayoutGroup = self.WeekendLoopScrollRect.transform:FindChild("Content"):GetComponent("VerticalLayoutGroup")		
	self.WeekendRankItem = self:FindChild("Layer_UI/WeekendView/WeekenDownTip/RankItem")
	
	self.WeekendLoopScrollRect:AddChangeItemListener(function(tran,index) 	
		self:WeenkenItemData(tran,index)
	end)
	
	self.WeekendLoopScrollRect:ToPoolItemListenner(function(tran,index) 	
		self:ReturnToPool(tran,index)
	end)

	self:RegisterEvent()
end

function WeekRankView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ChangeNick,CC.Notifications.ChangeNick)
end


function WeekRankView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.ChangeNick)
end

function WeekRankView:ChangeNick()
	local name = CC.Player.Inst():GetSelfInfoByKey("Nick")
	local id = CC.Player.Inst():GetSelfInfoByKey("Id")
	self.RankDataMgr.SetSuperRankitemName(id,name)
end

function WeekRankView:ReturnToPool(tran,index)
	-- local headNode = tran.transform:FindChild("ItemHeadMask/Node")
	-- self:DeleteHeadIconByKey(headNode)
	-- Util.ClearChild(headNode,false)
end

--延迟0.3秒执行显示排行榜
function WeekRankView:DelatRankShow()
	self.co = CC.uu.DelayRun(0.30,function()
		CC.uu.CancelDelayRun(self.co)
		self:SetNewLen(self.WeekendLoopScrollRect)       
    end)
end

function WeekRankView:HeadItem()
	for i=1,3 do
		self.RankNum = self.RankNum + 1 
		local itemData =  self.RankDataMgr.GetDataByIndexAndPageIndex(self.indexPage,i)
		if not itemData then return end
		local tran = self.WeekendLayer_UI:FindChild("Head"..i)
		tran:FindChild("Name"):SetActive(true)
		tran:FindChild("Name/ItemName"):GetComponent("Text").text = itemData.Player.Nick
		local headNode = tran:FindChild("ItemHeadMask/Node")
		local param = {}
		param.parent = headNode
		param.playerId = itemData.Player.Id
		param.vipLevel = itemData.Level
		param.portrait = itemData.Player.Portrait
		param.headFrame = itemData.Player.Background
		self:SetHeadIcon(param,self.RankNum)
	end
end

function WeekRankView:WeenkenItemData(tran,index)
	local  rankId = index + 1
	self.RankNum = self.RankNum + 1
	tran.name = tostring(rankId)
	local itemData = self.RankDataMgr.GetDataByIndexAndPageIndex(self.indexPage,rankId)
	if not itemData then return end
	tran:FindChild("ItemName"):GetComponent("Text").text = itemData.Player.Nick
	tran:FindChild("ItemText"):GetComponent("Text").text = tostring(rankId)
	tran:FindChild("ItemMoneyImg/ItemMoneyText"):GetComponent("Text").text =  CC.uu.ChipFormat(itemData.Score)
	tran:FindChild("RewardText"):GetComponent("Text").text = CC.uu.ChipFormat(self.viewCtr:GetConfigRwardCount(index))
	local img = tran:FindChild("BtnChat"):GetComponent("Image")
	local imageid = 9 - rankId
	if imageid <= 1 then
		imageid = 1
	end

	self:Qiehuan(img,"Coin"..imageid)
	local headNode = tran:FindChild("ItemHeadMask/Node")
	tran:SetActive(true)
	local param = {}
	param.parent = headNode
	param.playerId = itemData.Player.Id
	param.vipLevel = itemData.Level
	param.portrait = itemData.Player.Portrait
	param.headFrame = itemData.Player.Background
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.IconTab[tonumber(headtran.transform.name)] ~= nil then
			self.IconTab[tonumber(headtran.transform.name)]:RefreshOtherUI(param)
		end
	else
		self:SetHeadIcon(param,self.RankNum)
	end
	self:TranLocalMoveTo(self.WeekendVerticalLayoutGroup,tran,index,rankId,self.WeekendLoopScrollRect,self.RankDataMgr.GetRankMgrLen(self.indexPage))
end

--执行dotween
function WeekRankView:TranLocalMoveTo(VerticalLayoutGroup,tran,index,rankId,LoopScrollRect,len)
	if VerticalLayoutGroup.enabled == false then
		tran.transform.localPosition = Vector3(630,-50 + (index * -108.3),0)
		self:RunAction(tran, {"localMoveTo", 0, -50 + (index * -108.3),0.1 * rankId, function()
			local count = 0
			if len <= 4 then
				count = len
			elseif len >= 6  then
				count = 6
			end
			if rankId >= count then
	  			VerticalLayoutGroup.enabled = true
	  			--logError("len = "..len)
	  			self:RankListCount(LoopScrollRect,len)
	  			return
	  		end
		end})
	end	
end


--设置循环列表长度
function WeekRankView:RankListCount(loopscrollrect,len)
	local count = len
	if count  == 0 then
		loopscrollrect:ClearCells()
	else 
		loopscrollrect.totalCount = len
	end
end

--确定初始化的长度
function WeekRankView:SetNewLen(LoopScrollRect)
	self.WeekendVerticalLayoutGroup.enabled = false
	if self.RankDataMgr.GetRankMgrLen(self.indexPage) < 5 then
		self:RankListCount(LoopScrollRect,self.RankDataMgr.GetRankMgrLen(self.indexPage))
	else
		self:RankListCount(LoopScrollRect,6)
	end
end

function WeekRankView:Qiehuan(value,path)

	self:SetImage(value.gameObject, path);
end

--设置排行榜底部数据
function WeekRankView:DownTip(tran_rankitem)
	local MyRank =  self.RankDataMgr.GetMyRank(self.indexPage)
	local itemData =  self.RankDataMgr.GetDataByIndexAndPageIndex(self.indexPage,MyRank)	
	
	if tostring(MyRank) == "No ranking" then
		tran_rankitem.transform:FindChild("ItemName"):GetComponent("Text").text = self.language.norankin
	else
		tran_rankitem.transform:FindChild("ItemName"):GetComponent("Text").text = tostring(MyRank)
	end

	local itemscore = "0"
	if itemData ~= nil then
	   itemscore = itemData.Score
	else
		if self.indexPage == 1 then
			itemscore = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
		end
	end	
	
	tran_rankitem:FindChild("ItemMoneyImg/ItemMoneyText"):GetComponent("Text").text = CC.uu.ChipFormat(itemscore)

	local headNode = tran_rankitem:FindChild("ItemHeadMask/Node")
	self.RankNum = self.RankNum + 1
	if headNode.childCount <= 0 then
		local param = {}
		param.parent = headNode
		param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id");
		self:SetHeadIcon(param,self.RankNum)
	end

	tran_rankitem:FindChild("RankText"):GetComponent("Text").text = self.language.myrankings
	self.WeekendView:FindChild("WeekenDownTip/UpdateTip"):GetComponent("Text").text = string.format(self.language.weekentext,50)
end

--关闭界面
function WeekRankView:closeView()
	self:Destroy()
end

function WeekRankView:OnDestroy()
	CC.uu.CancelDelayRun(self.co)
	for i,v in pairs(self.IconTab) do
	  	if v then
			v:Destroy()
			v = nil
		end
	end
	self:unRegisterEvent()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
	self.WeekendLoopScrollRect:DelectPool()
	self.WeekendLoopScrollRect = nil
	self.WeekendVerticalLayoutGroup = nil
end

function WeekRankView:ActionIn()
	
end

function WeekRankView:ActionOut()
	self:closeView()
end

function WeekRankView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end	
end

function  WeekRankView:SetHeadIcon(param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

return WeekRankView
