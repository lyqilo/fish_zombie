
local CC = require("CC")
local ActiveRankView = CC.uu.ClassView("ActiveRankView")

function ActiveRankView:ctor()

	self.ranklist = CC.DefineCenter.Inst():getConfigDataByKey("RankDefine")
	self.ActiveRankDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("ActiveRankData")
	self.language = self:GetLanguage()
	self.indexPage = 3
	self.RankItem = nil
	self.HeadIcon = nil
	self.IconTab = {}
	self.RankNum = 0
end

function ActiveRankView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
	self:Init()
end

function ActiveRankView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ChangeNick,CC.Notifications.ChangeNick)
end

function ActiveRankView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.ChangeNick)
end

function ActiveRankView:ChangeNick()
	local name = CC.Player.Inst():GetSelfInfoByKey("Nick")
	local id = CC.Player.Inst():GetSelfInfoByKey("Id")
	self.ActiveRankDataMgr:SetActiveRankitemName(id,name)
end

function ActiveRankView:Init()
	--init页面
	 CC.ViewManager.ShowConnecting()
	self.WeekendView= self:FindChild("Layer_UI/WeekendView")
	self.Weeken_RankItem = self:FindChild("Layer_UI/WeekendView/WeekenDownTip/RankItem")
	self.WeekendLayer_UI = self:FindChild("Layer_UI/WeekendView")
	self.WeekendLoopScrollRect = self:FindChild("Layer_UI/WeekendView/VerticalScroll"):GetComponent("LoopScrollRect")
	self.WeekendVerticalLayoutGroup = self.WeekendLoopScrollRect.transform:FindChild("Content"):GetComponent("VerticalLayoutGroup")
	self.WeekenBtnExit = self:FindChild("Layer_UI/WeekendView/BtnExit")
	self.WeekendRankItem = self:FindChild("Layer_UI/WeekendView/WeekenDownTip/RankItem")
	
	self:AddClickEvnt()
	self:DownTip(self.Weeken_RankItem)
	self:RegisterEvent()
	self.WeekendLoopScrollRect:AddChangeItemListener(function(tran,index)
		self:WeenkenItemData(tran,index)
	end)

	self.WeekendLoopScrollRect:ToPoolItemListenner(function(tran,index)
		self:ReturnToPool(tran,index)
	end)
	self.viewCtr:ReqGetActiveRank()
end

function ActiveRankView:ReturnToPool(tran,index)
	local headNode = tran.transform:FindChild("ItemHeadMask/Node")
	self:DeleteHeadIconByKey(headNode)
	Util.ClearChild(headNode,false)
end

function ActiveRankView:HeadItem()
	for i=1,3 do
		self.RankNum = self.RankNum + 1 
		local itemData =  self.ActiveRankDataMgr:GetActieveRankItemData(i)
		if not itemData then return end
		local tran = self.WeekendLayer_UI:FindChild("Head"..i)
		tran:FindChild("Name"):SetActive(true)
		tran:FindChild("Name/ItemName"):GetComponent("Text").text = itemData.Player.Nick
		local headNode = tran:FindChild("ItemHeadMask/Node")
		local param = {}
		param.parent = headNode
		param.playerId = itemData.PlayerID
		param.vipLevel = itemData.VIPLevel
		param.portrait = itemData.Player.Portrait
		param.headFrame = itemData.Player.Background
		self:SetHeadIcon(param,self.RankNum)
	end
end


function ActiveRankView:Qiehuan(value,path)

	self:SetImage(value.gameObject, path);
end

function ActiveRankView:WeenkenItemData(tran,index)
	local  rankId = index + 1
	self.RankNum = self.RankNum + 1
	tran.name = tostring(rankId)
	local itemData = self.ActiveRankDataMgr:GetActieveRankItemData(rankId)
	if not itemData then return end
	tran:FindChild("ItemName"):GetComponent("Text").text = itemData.Player.Nick
	tran:FindChild("ItemText"):GetComponent("Text").text = tostring(rankId)
	tran:FindChild("ItemMoneyImg/ItemMoneyText"):GetComponent("Text").text =  CC.uu.ChipFormat(itemData.Count)
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
	param.playerId = itemData.PlayerID
	param.vipLevel = itemData.VIPLevel
	param.portrait = itemData.Player.Portrait
	param.headFrame = itemData.Player.Background
	self:SetHeadIcon(param,self.RankNum)
	self:TranLocalMoveTo(self.WeekendVerticalLayoutGroup,tran,index,rankId,self.WeekendLoopScrollRect,self.ActiveRankDataMgr:GetActieveRankLen())
end

--执行dotween
function ActiveRankView:TranLocalMoveTo(VerticalLayoutGroup,tran,index,rankId,LoopScrollRect,len)

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
	  			self:RankListCount(LoopScrollRect,len)
	  			return
	  		end
		end})
	end	
end

--设置循环列表长度
function ActiveRankView:RankListCount(loopscrollrect,len)
	local count = len
	if count  == 0 then
		loopscrollrect:ClearCells()
	else 
		loopscrollrect.totalCount = len
	end
end

--确定初始化的长度
function ActiveRankView:SetNewLen(LoopScrollRect)
	self.WeekendVerticalLayoutGroup.enabled = false
	if self.ActiveRankDataMgr:GetActieveRankLen() < 5 then
		self:RankListCount(LoopScrollRect,self.ActiveRankDataMgr:GetActieveRankLen())
	else
		self:RankListCount(LoopScrollRect,6)
	end
end

function ActiveRankView:AddClickEvnt()
	self:AddClick(self.WeekenBtnExit,"closeView")
end

--设置排行榜底部数据
function ActiveRankView:DownTip(tran_rankitem)
	local MyRank =  self.ActiveRankDataMgr:GetMyRank()
	
	if tostring(MyRank) == "No ranking" then
		tran_rankitem.transform:FindChild("ItemName"):GetComponent("Text").text = self.language.norankin
	else
		tran_rankitem.transform:FindChild("ItemName"):GetComponent("Text").text = MyRank or 0
	end

	local itemscore = 0
	itemscore =  self.ActiveRankDataMgr:GetMyCount() or 0;	
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
function ActiveRankView:closeView()
	self:Destroy()
end

function ActiveRankView:OnDestroy()
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



function ActiveRankView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end	
end

function  ActiveRankView:SetHeadIcon(param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

function ActiveRankView:ActionIn()
	
end

return ActiveRankView
