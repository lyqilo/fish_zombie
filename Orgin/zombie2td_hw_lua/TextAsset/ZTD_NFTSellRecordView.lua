local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu
--售卖记录页面
local OptionData = UnityEngine.UI.Dropdown.OptionData
local NFTSellRecordView = ZTD.ClassView("ZTD_NFTSellRecordView")



function NFTSellRecordView:OnCreate()
	self:PlayAnimAndEnter()
    self:InitLan()
    

	self:Init()
	
end

--请求数据
function NFTSellRecordView:Init()
	self:AddClick("root/BtnClose", function()
		self:Destroy()
	end)
	self:AddClick("Mask", function()
		self:Destroy()
	end)
	--滚动列表相关
	self.scrollCtr = self:FindChild("root/CustomScroll/Scroller"):GetComponent("ScrollerController")
	self.scrollCtr:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:ItemInit(tran,dataIndex,cellIndex)
	end)
	self.noRecordText = self:GetCmp("root/CustomScroll/TextNoRecord", "Text")
	self.seasonDrop = self:GetCmp("root/seasonDP","Dropdown")
	UIEvent.AddDropdownValueChange(self:FindChild("root/seasonDP"), function (val)
		val = tonumber(val) + 1
		self.seasonId = self.recordSeasonList[val].id
		self.scrollCtr:ClearAll()
		self.scrollCtr:InitScroller(0)
		self:ReqSellRecord(0)
	end)
	self.shopList = {}
	self.recordItemList = {}
	self:ReqRecordList()
end

--清除滚动列表
function NFTSellRecordView:ClearScroll()
	if not self.recordItemList then
		return
	end
	for _,item in pairs(self.recordItemList) do
		if #item > 0 then
			for i=#item, 1, -1 do
				local tab = item[i]
				ZTD.PoolManager.RemoveGameItem(tab.modelName, tab.model)
				GameObject.Destroy(tab.renderTexture)
			end
		end
	end

	self.scrollCtr:ClearAll()
end

--请求
function NFTSellRecordView:ItemInit(tran,dataIndex,cellIndex)
	dataIndex = dataIndex + 1
	if not self.shopList[dataIndex] then
		return
	end
	--最后一条数据，拉新的数据
	if not self.noMoreRecordData and dataIndex == #self.shopList then
		self:ReqSellRecord(dataIndex)
	end
	
	if self.recordItemList[tran] and #self.recordItemList[tran] > 0 then
		for i=#self.recordItemList[tran], 1, -1 do
			local tab = self.recordItemList[tran][i]
			ZTD.PoolManager.RemoveGameItem(tab.modelName, tab.model)
			--ZTD.Extend.Destroy(tab.renderTexture)
		end
	end
	self.recordItemList[tran] = {}
	
	local data = self.shopList[dataIndex]
	for i=1,#ZTD.NFTConfig.Grade do
		tran:FindChild("Card/Grade"..i):SetActive(data.Quality == i)
	end
	
	--模型显示相关
	local cfg = ZTD.NFTConfig.GetGradeConfig(data.Quality)
	local enmeyRoot = tran:FindChild("Card/CameraRoot/Camera/EnemyRoot")

	local cameraTran = tran:FindChild("Card/CameraRoot")
	cameraTran.transform.position = Vector3(0,ZTD.Flow.cameraIdx*2000,0)
	ZTD.Flow.cameraIdx = ZTD.Flow.cameraIdx + 1
	if ZTD.Flow.cameraIdx > ZTD.Flow.maxIdx then
		ZTD.Flow.cameraIdx = 1
	end
	local camera = tran:FindChild("Card/CameraRoot/Camera"):GetComponent("Camera")
	camera.targetTexture = UnityEngine.RenderTexture(215,263,1)
	local monsterImage = tran:FindChild("Card/BG/MonsterShow"):GetComponent("RawImage")
	monsterImage.texture = camera.targetTexture
	monsterImage.gameObject:SetActive(true)

	local monsterModel = ZTD.PoolManager.GetGameItem(cfg.modelName)
	monsterModel:SetParent(enmeyRoot)
	monsterModel.localPosition = cfg.modelPos
	monsterModel.localRotation = Quaternion.Euler(cfg.modelRot.x,cfg.modelRot.y,cfg.modelRot.z)
	monsterModel.localScale = cfg.modelScale
	local animator = monsterModel:GetComponentInChildren(typeof(UnityEngine.Animator))
	animator.speed = math.random(80,120)/100
	
	local tab = {}
	tab.model = monsterModel
	tab.modelName = cfg.modelName
	tab.renderTexture = camera.targetTexture
	table.insert(self.recordItemList[tran], tab)
	
	
	self:SetNodeText(tran,"TextTime",GC.uu.TimeOut3(data.UpdateTime))
	local power = data.BasePower+(data.ExtendPower or 0)
	
	self:SetNodeText(tran,"TextPower",power)
	self:SetNodeText(tran,"TextPerform",string.format("%.2f%%", power/data.Price*10*1000000))
	self:SetNodeText(tran,"TextPrice",data.Price/1000000)
	self:SetNodeText(tran,"TextState",self.lan.status[data.Status])
	
end

--请求
function NFTSellRecordView:ReqRecordList()
	ZTD.Request.HttpRequest("ReqRecordList", {
		limit = 10,
		offset = 0
	}, function (data)
		self:DealRecordList(data)
	end, function ()
		logError("ReqRecordList error")
	end, false)
end

--请求
function NFTSellRecordView:DealRecordList(data)
	--没有数据
	if tostring(data.season_list) == "userdata: NULL" then
		ZTD.ViewManager.ShowTip(self.lan.noRecord)
		self.noRecordText:Show()
		return 
	end
	self.noRecordText:Hide()
	self.recordSeasonList = table.copy(data.season_list)

	
	local list = {}
	for _,v in pairs(data.season_list) do
		local op = OptionData.New(string.format(self.lan.season, v.name))
		self.seasonDrop.options:Add(op)
	end
	self.seasonDrop:RefreshShownValue()
	if data.season_list[1] then
		self.seasonId = data.season_list[1].id
	end
	self:ReqSellRecord()
end

function NFTSellRecordView:DealRecordData(data, reset)

	if not data.data or #data.data == 0 then
		self.shopList = {}
		self:ClearScroll()
		self.scrollCtr:InitScroller(0)
		return
	end
	if reset then--重新拉数据
		self.shopList = table.copy(data.data)
		if #self.shopList > 0 then
			self:ClearScroll()
			self.scrollCtr:InitScroller(#self.shopList)
		end
	else
		for _,v in ipairs(data.data) do
			table.insert(self.shopList, v)
		end
		local progress = 1-self.scrollCtr:GetComponent("ScrollRect").verticalNormalizedPosition
		self.scrollCtr:RefreshScroller(#self.shopList,progress)
	end
end
--请求每日奖池信息
--offset数据偏移量
function NFTSellRecordView:ReqSellRecord(offset)
	--每次拉取的数据量
	local count = 20 
	offset = offset or 0
	ZTD.Request.HttpRequest("ReqSellRecord", {
		SeasonId = self.seasonId,
		Quality = 0,
		Limit = count,
		Offset = offset
	}, function (data)
	
		if not data.data or #data.data < count then
			--没有更多数据了，别拉了
			self.noMoreRecordData = true
		else
			self.noMoreRecordData = false
		end
		self:DealRecordData(data, offset==0)

	end, function ()
		logError("ReqSellRecord error")
	end, true)
end

function NFTSellRecordView:OnDestroy()
	self:ClearScroll()
end


return NFTSellRecordView