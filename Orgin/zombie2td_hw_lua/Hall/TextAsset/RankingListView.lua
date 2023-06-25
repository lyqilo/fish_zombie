

local CC = require("CC")
local RankingListView = CC.uu.ClassView("RankingListView")

function RankingListView:ctor()
	self.RankDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RankData")
	self.language = self:GetLanguage()
	self.indexPage = 1
	self.IconTab = {}
	self.RankNum = 0
end

function RankingListView:OnCreate()
	self:Init()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
end

function RankingListView:Init()
	self.ranking = self:FindChild("Layer_UI/Ranking")
	self.LoopScrollRect = self:FindChild("Layer_UI/Ranking/VerticalScroll"):GetComponent("LoopScrollRect")
	self.VerticalLayoutGroup = self.LoopScrollRect.transform:FindChild("Content"):GetComponent("VerticalLayoutGroup")	
	self.chipTog = self.ranking:FindChild("paihanban/tu02")
	self.wintodayTog = self.ranking:FindChild("paihanban/tu01")
	self.zg01 = self.ranking:FindChild("paihanban/zg01")
	self.zg02 = self.ranking:FindChild("paihanban/zg02")
	self.sg = self.ranking:FindChild("paihanban/shaoguan/sg")
	self.sg2 = self.ranking:FindChild("paihanban/shaoguan/sg2")
	self.RankItem = self:FindChild("Layer_UI/Ranking/DownTip/RankItem")
	-- self.UpdateTime = self:FindChild("Layer_UI/Ranking/DownTip/UpdateTip"):GetComponent("Text")
	-- self.UpdateTime.text = "0 "..self.language.timeDes
	self:FindChild("Layer_UI/Ranking/DownTip/UpdateTip"):SetActive(false)
	
	self.LoopScrollRect:AddChangeItemListener(function(tran,index) 	
		self:ItemData(tran,index)
	end)

	self.LoopScrollRect:ToPoolItemListenner(function(tran,index) 	
		self:ReturnToPool(tran,index)
	end)

	-- self:updateTime()
	self:AddClickEvnt()
	self:RegisterEvent()

	self.chipTog:GetComponent("Button"):SetBtnEnable(false)
	self.wintodayTog:GetComponent("Button"):SetBtnEnable(true)

	if CC.ChannelMgr.GetIosTrailStatus() then
		self.wintodayTog:SetActive(false)
		self.zg02:SetActive(false)
		self.sg:SetActive(false)
		self.chipTog:SetActive(false)
		self.zg01:SetActive(false)
		self.sg2:SetActive(false)
	end
end

function RankingListView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ChangeNick,CC.Notifications.ChangeNick)
end


function RankingListView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.ChangeNick)
end

function RankingListView:ChangeNick()
	local name = CC.Player.Inst():GetSelfInfoByKey("Nick")
	local id = CC.Player.Inst():GetSelfInfoByKey("Id")
	self.RankDataMgr.SetSuperRankitemName(id,name)
end

function RankingListView:ReturnToPool(tran,index)
	-- local headNode = tran.transform:FindChild("ItemHeadMask/Node")
	-- self:DeleteHeadIconByKey(headNode)
	-- Util.ClearChild(headNode,false)
end

--延迟0.3秒执行显示排行榜
function RankingListView:DelatRankShow()
	self.co = CC.uu.DelayRun(0.30,function()
		CC.uu.CancelDelayRun(self.co)
		self:SetNewLen(self.LoopScrollRect)       
	end)
	self:DownTip(self.RankItem)
end

--皇冠图片切换
local function SpriteInfo(key,value)
	if key <= 3 then
		if key == 1 then
			value:FindChild("EffectObj/"..tostring(1)):SetActive(true)
			value:FindChild("EffectObj/"..tostring(2)):SetActive(false)
			value:FindChild("EffectObj/"..tostring(3)):SetActive(false)
		elseif key == 2 then
			value:FindChild("EffectObj/"..tostring(1)):SetActive(false)
			value:FindChild("EffectObj/"..tostring(2)):SetActive(true)
			value:FindChild("EffectObj/"..tostring(3)):SetActive(false)
		elseif key == 3 then
			value:FindChild("EffectObj/"..tostring(1)):SetActive(false)
			value:FindChild("EffectObj/"..tostring(2)):SetActive(false)
			value:FindChild("EffectObj/"..tostring(3)):SetActive(true)
		end
		value:FindChild("EffectObj"):SetActive(true)
		value:FindChild("EffectObj/"..tostring(key)):SetActive(true)
		value:FindChild("ItemImg"):SetActive(false)
		value:FindChild("ItemImg/ItemText"):GetComponent("Text").text = ""
	else
		value:FindChild("EffectObj"):SetActive(false)
		value:FindChild("ItemImg"):SetActive(true)
	end
end

function RankingListView:ItemData(tran,index)
	local  rankId = index + 1
	self.RankNum = self.RankNum + 1
	tran.name = tostring(rankId)
	local itemData =  self.RankDataMgr.GetDataByIndexAndPageIndex(self.indexPage,rankId)
	if not itemData then return end
	tran.transform:FindChild("ItemImg/ItemText"):GetComponent("Text").text = tostring(rankId)
	tran.transform:FindChild("ItemName"):GetComponent("Text").text = itemData.Player.Nick
	tran.transform:FindChild("ItemMoneyImg/ItemMoneyText"):GetComponent("Text").text = CC.uu.ChipFormat(itemData.Score)
	SpriteInfo(rankId,tran,self.RankNum)
	local headNode = tran.transform:FindChild("ItemHeadMask/Node")
	local param = {}
	param.parent = headNode
	param.playerId = itemData.Player.Id
	param.portrait = itemData.Player.Portrait
	param.vipLevel = itemData.Level
	param.headFrame = itemData.Player.Background
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.IconTab[tonumber(headtran.transform.name)] ~= nil then
			self.IconTab[tonumber(headtran.transform.name)]:RefreshOtherUI(param)
		end
	else
		self:SetHeadIcon(param,self.RankNum)
	end
	self:TranLocalMoveTo(self.VerticalLayoutGroup,tran,index,rankId,self.LoopScrollRect,self.RankDataMgr.GetRankMgrLen(self.indexPage))
end

--执行dotween
function RankingListView:TranLocalMoveTo(VerticalLayoutGroup,tran,index,rankId,LoopScrollRect,len)
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

function RankingListView:Buttonxz()
	if self.indexPage == 1 then
		self.chipTog:GetComponent("Button"):SetBtnEnable(false)
		self.wintodayTog:GetComponent("Button"):SetBtnEnable(true)
	elseif self.indexPage == 2 then
		self.chipTog:GetComponent("Button"):SetBtnEnable(true)
		self.wintodayTog:GetComponent("Button"):SetBtnEnable(false)					
	end
end

--设置循环列表长度
function RankingListView:RankListCount(loopscrollrect,len)
	local count = len
	if count  == 0 then
		loopscrollrect:ClearCells()
	else 
		loopscrollrect.totalCount = len
	end
end

function RankingListView:AddClickEvnt()
	self:AddClick(self.chipTog,"chipSetactive")	
	self:AddClick(self.wintodayTog,"wintodayTogSetactive")
end

--确定初始化的长度
function RankingListView:SetNewLen(LoopScrollRect)
	self.VerticalLayoutGroup.enabled = false
	if self.RankDataMgr.GetRankMgrLen(self.indexPage) < 5 then
		self:RankListCount(LoopScrollRect,self.RankDataMgr.GetRankMgrLen(self.indexPage))
	else
		self:RankListCount(LoopScrollRect,6)
	end
end

function RankingListView:Qiehuan(value,path)
	self:SetImage(value.gameObject, path);
end

--切换到最大筹码榜
function RankingListView:chipSetactive()
	self:StopAllAction()
	self.LoopScrollRect:ClearCells()
	self.indexPage = 1
	self:SetNewLen(self.LoopScrollRect)
	self.LoopScrollRect:RefillCells(0)
	self:DownTip(self.RankItem)
	-- self:updateTime()
	self.zg01:SetActive(true)
	self.zg02:SetActive(false)
	self.sg:SetActive(false)
	self.sg2:SetActive(true)
	self:Qiehuan(self.wintodayTog,"wintoday")
	self:Qiehuan(self.chipTog,"chipxz")
	self.chipTog:GetComponent("Button"):SetBtnEnable(false)
	self:Buttonxz()
end

--切换到每日赢取
function RankingListView:wintodayTogSetactive()
	self:StopAllAction()
	self.LoopScrollRect:ClearCells()
	self.indexPage = 2
	self:SetNewLen(self.LoopScrollRect)
	self.LoopScrollRect:RefillCells(0)		
	self:DownTip(self.RankItem)
	-- self:updateTime()
	self.zg01:SetActive(false)
	self.zg02:SetActive(true)
	self.sg:SetActive(true)
	self.sg2:SetActive(false)
	self:Qiehuan(self.wintodayTog,"wintodayxz")
	self:Qiehuan(self.chipTog,"chip")
	self.wintodayTog:GetComponent("Button"):SetBtnEnable(false)		
	self:Buttonxz()
end

--设置排行榜底部数据
function RankingListView:DownTip(tran_rankitem)
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
			--itemscore = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
			itemscore = self.RankDataMgr.GetSuperMyScore()
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
end

--计时
function RankingListView:updateTime()
	self.UpdateTime.text = tostring(0).." "..self.language.timeDes
	local timeNow =  0
	self:StartTimer("updateTimer", 1,
    function()
    	timeNow = timeNow + 1
    	if timeNow % 60 == 0 then    		
    		self.UpdateTime.text = tostring(timeNow / 60).." "..self.language.timeDes
    	end   
    end
    ,-1)
end

function RankingListView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end	
end

function  RankingListView:SetHeadIcon(param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

function RankingListView:ActionIn()
end

function RankingListView:ActionOut()
	self:Destroy()
end

function RankingListView:OnDestroy()
	self:unRegisterEvent()
	CC.uu.CancelDelayRun(self.co)
	-- self:StopTimer("updateTimer")
	for i,v in pairs(self.IconTab) do
	  	if v then
			v:Destroy()
			v = nil
		end
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
	self.LoopScrollRect:DelectPool()
	self.LoopScrollRect = nil
	self.VerticalLayoutGroup = nil

end

return RankingListView
