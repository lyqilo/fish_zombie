
local CC = require("CC")
local ShakeRankView = CC.uu.ClassView("ShakeRankView")


--排行榜
function ShakeRankView:ctor(callback)
	-- self.language = self:GetLanguage()
	self.ShakeData =CC.DataMgrCenter.Inst():GetDataByKey("ShakeData")
	self.ShakeConfig = CC.ConfigCenter.Inst():getConfigDataByKey("ShakeConfig")
	self.callback = callback
	self.RankIndex = 1
	self.IconTab = {}
	self.RankNum = 0
end

function ShakeRankView:OnCreate()
	self:Init()
	self:AddClickEvent()
	self:RegisterEvent()
end

function ShakeRankView:Init()
	self.BtnColse = self:FindChild("Layer_UI/BtnColse")
	self.ToggleGroup = self:FindChild("Layer_UI/ToggleGroup")
	self.Toggle1 = self.ToggleGroup:FindChild("1")
	self.Toggle2 = self.ToggleGroup:FindChild("2")
	self.RankingPanel = self:FindChild("Layer_UI/RankingPanel")
	self.scrollController = self.RankingPanel:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController2 = self.RankingPanel:FindChild("ScrollerController2"):GetComponent("ScrollerController")
	self.DailyTop = self.RankingPanel:FindChild("Panel/DailyTop")
	self.WeekTop = self.RankingPanel:FindChild("Panel/WeekTop")
	self.Scroller = self.RankingPanel:FindChild("Scroller")
	self.Scroller2 = self.RankingPanel:FindChild("Scroller2")
	self.DailyItem = self:FindChild("Layer_UI/Down/DailyItem")
	self.WeekItem = self:FindChild("Layer_UI/Down/WeekItem")

    self.scrollController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		xpcall(function() self:DailyItemData(tran,dataIndex,cellIndex) end, function(error) logError(error) end)
	end)
	  self.ScrollerController2:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		xpcall(function() self:WeekItemData(tran,dataIndex,cellIndex) end, function(error) logError(error) end)
	end)

	self.scrollController:AddRycycleAction(function (tran)
		self:RycycleItem(tran)
	end)

	self.ScrollerController2:AddRycycleAction(function (tran)
		self:RycycleItem(tran)
	end)
	UIEvent.AddToggleValueChange(self.Toggle1, function(selected)
		if selected	then
			self.RankIndex = 1
			self.RankNum = 0
			self:DownDailyShow()
			self.RankingPanel:FindChild("ScrollerController2"):SetActive(false)
			self.RankingPanel:FindChild("ScrollerController"):SetActive(true)
			self.DailyTop:SetActive(true)
			self.WeekTop:SetActive(false)
			self.Scroller2:SetActive(false)
			self.Scroller:SetActive(true)
			self.DailyItem:SetActive(true)
			self.WeekItem:SetActive(false)
			self.scrollController:InitScroller(self.ShakeData.GetRankLen(self.RankIndex))
			self:DownDailyShow()
		end
    end)

	UIEvent.AddToggleValueChange(self.Toggle2, function(selected)
		if selected	then
			self.RankIndex = 2		
			self.RankNum = 0
			self:DownWeekShow()
			self.RankingPanel:FindChild("ScrollerController2"):SetActive(true)
			self.RankingPanel:FindChild("ScrollerController"):SetActive(false)
			self.DailyTop:SetActive(false)
			self.WeekTop:SetActive(true)
			self.Scroller2:SetActive(true)
			self.Scroller:SetActive(false)
			self.DailyItem:SetActive(false)
			self.WeekItem:SetActive(true)
			self.ScrollerController2:InitScroller(self.ShakeData.GetRankLen(self.RankIndex))
		end
    end)
	self.scrollController:InitScroller(self.ShakeData.GetRankLen(self.RankIndex))	
	self.Toggle1:GetComponent("Toggle").isOn = true

end


function ShakeRankView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnAddShake,CC.Notifications.OnpushShake)
end

function ShakeRankView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnpushShake)
end

function ShakeRankView:RycycleItem(tran)
	local headNode = tran.transform:FindChild("ItemHeadMask/Node")
	Util.ClearChild(headNode,false)
	local id = tonumber(tran.name)
	if self.IconTab[id] then
		self.IconTab[id]:Destroy(true)
	end
end

--皇冠图片切换
local function SpriteInfo(key,value)


	if key <= 3 and key > 0 then
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

--初始化日排行榜item
function ShakeRankView:DailyItemData(trans,dataIndex,cellIndex)
	local index = dataIndex + 1
	self.RankNum = self.RankNum + 1
	trans.transform.name = index
	local itemData = self.ShakeData.GetRankItem(self.RankIndex,index)	
	self:ItemData(trans,index,itemData)
	local GameName = self:GetGameName(itemData.GameId)
	trans:FindChild("ItemGameName"):GetComponent("Text").text = GameName
	local headNode = trans.transform:FindChild("ItemHeadMask/Node")
	trans:FindChild("ItemMoneyImg/ItemDate"):GetComponent("Text").text = CC.uu.TimeOut(itemData.TimeAT)
end

--周排行榜item
function ShakeRankView:WeekItemData(trans,dataIndex,cellIndex)
	local index = dataIndex + 1
	self.RankNum = self.RankNum + 1
	trans.transform.name = index
	local itemData = self.ShakeData.GetRankItem(self.RankIndex,index)
	self:ItemData(trans,index,itemData)
end

--给每一个item设置头像，给text赋值
function ShakeRankView:ItemData(trans,index,itemData)	
	trans:FindChild("ItemHeadMask/Name"):GetComponent("Text").text = itemData.Nick
	trans:FindChild("ItemMoneyImg/ItemMoneyText"):GetComponent("Text").text = CC.uu.numberToStrWithComma(itemData.Score)
	trans:FindChild("ItemHeadMask/Obj/VIPLevel"):GetComponent("Text").text = itemData.Level
	local headNode = trans.transform:FindChild("ItemHeadMask/Node")
	local param = {}
	param.parent = headNode
	param.playerId = itemData.PlayerId
	param.portrait = itemData.Portrait
	param.vipLevel = itemData.Level
	self:SetHeadIcon(headNode,param,self.RankNum)
	SpriteInfo(itemData.Rank + 1,trans)
	trans:FindChild("ItemImg/ItemText"):GetComponent("Text").text = itemData.Rank + 1
end

--设置头像
function  ShakeRankView:SetHeadIcon(headNode,param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

-- 每日排行榜的底部
function ShakeRankView:DownDailyShow()
	local itemData = self.ShakeData.GetSelfRankItem(self.RankIndex)
	local headNode = self.DailyItem.transform:FindChild("ItemHeadMask/Node")
	if headNode.childCount <= 0 then
		self:ItemData(self.DailyItem,itemData.Rank,itemData)
	end
	if itemData.GameId ~= 0 then
		local GameName = self:GetGameName(itemData.GameId)
		self.DailyItem:FindChild("ItemGameName"):GetComponent("Text").text = GameName
	else
		self.DailyItem:FindChild("ItemGameName"):GetComponent("Text").text = ""
	end
	if itemData.TimeAT > 0 then
		self.DailyItem:FindChild("ItemMoneyImg/ItemDate"):GetComponent("Text").text = CC.uu.TimeOut(itemData.TimeAT)
	else
		self.DailyItem:FindChild("ItemMoneyImg/ItemDate"):GetComponent("Text").text = "~"
	end
	if itemData.Rank < 0 or itemData.Rank > 50 then
		self.DailyItem:FindChild("noRanking"):SetActive(true)
		self.DailyItem:FindChild("EffectObj"):SetActive(false)
		self.DailyItem:FindChild("ItemImg"):SetActive(false)
	else
		self.DailyItem:FindChild("noRanking"):SetActive(false)		
	end
end

-- 收到服务器推送关闭当前界面
function ShakeRankView:OnAddShake()
    self:RunAction(self, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    	log("ShakeRankView")
    		self:Destroy()
    	end})
end

-- 周排行榜的底部
function ShakeRankView:DownWeekShow()
	local itemData = self.ShakeData.GetSelfRankItem(self.RankIndex)
    --logError(CC.uu.Dump(itemData,"DownWeekShow =",10))
    local headNode = self.WeekItem.transform:FindChild("ItemHeadMask/Node")
	if headNode.childCount <= 0 then
		self:ItemData(self.WeekItem,itemData.Rank,itemData)
	end

	if itemData.Rank < 0 or itemData.Rank > 50 then
		self.WeekItem:FindChild("noRanking"):SetActive(true)
		self.WeekItem:FindChild("EffectObj"):SetActive(false)
		self.WeekItem:FindChild("ItemImg"):SetActive(false)
	else
		self.WeekItem:FindChild("noRanking"):SetActive(false)		
	end
end

--获取游戏名称
function ShakeRankView:GetGameName(id)
	for i,v in ipairs(self.ShakeConfig) do
		if v.Id == id then
			return v.Name
		end
	end
end

function ShakeRankView:AddClickEvent()
	self:AddClick(self.BtnColse,"Close")
end

function ShakeRankView:Close()
	self:ActionOut()
end

function ShakeRankView:OnDestroy()
	if self.callback then
		self.callback()
	end
	self:unRegisterEvent()
end

function ShakeRankView:ActionOut()
	self:SetCanClick(false)
    self:RunAction(self, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
		self:Destroy()
	end})
end

return ShakeRankView