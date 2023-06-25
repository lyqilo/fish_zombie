local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu
local FormatNum = GC.uu.numberToStrWithComma
local NFTDayRecordView = ZTD.ClassView("ZTD_NFTDayRecordView")
local OptionData = UnityEngine.UI.Dropdown.OptionData
function NFTDayRecordView:OnCreate()
	self.dayRankList = {}
	self.recordSeasonList = {}
	self.seasonId = 1
	self.dayId = 1
	self:PlayAnimAndEnter()
    self:InitLan()
    self:Init()
end


--初始化信息
function NFTDayRecordView:Init()
	
	self.dayPoolText = self:GetCmp("root/DayPool/Text", "Text")
	self.rankDayMineText = self:GetCmp("root/Bottom/TextRankMine", "Text")
	self.powerDayMineText = self:GetCmp("root/Bottom/TextPowerMine", "Text")
	self.rewardDayMineText = self:GetCmp("root/Bottom/TextRewardMine", "Text")
	self.rewardFRTDayMineText = self:GetCmp("root/Bottom/TextRewardFRTMine", "Text")
	self.noRecordText = self:GetCmp("root/CustomScroll/TextNoRecord", "Text")
	self.totalPowerText = self:GetCmp("root/TextCurAllPower", "Text")
	
	--滚动列表相关
	self.dayScrollCtr = self:FindChild("root/CustomScroll/Scroller"):GetComponent("ScrollerController")
	self.dayScrollCtr:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:ItemInit(tran,dataIndex,cellIndex)
	end)

	
	self.seasonDrop = self:GetCmp("root/SeasonDP","Dropdown")
	self.dayDrop = self:GetCmp("root/DayDP","Dropdown")
	UIEvent.AddDropdownValueChange(self:FindChild("root/SeasonDP"), function (val)
		val = tonumber(val) + 1
		self.seasonId = self.recordSeasonList[val].id
		self.dayScrollCtr:ClearAll()
		self.dayScrollCtr:InitScroller(0)
		self:ReqDayRecord(true,0)
		
	end)
	UIEvent.AddDropdownValueChange(self:FindChild("root/DayDP"), function (val)
		val = tonumber(val) + 1
		self.dayId = tonumber(val)
		self.dayScrollCtr:ClearAll()
		self.dayScrollCtr:InitScroller(0)
		self:ReqDayRecord(true,0)
	
	end)
	
	for i=1,7 do
		local op = OptionData.New(string.format(self.lan.day, i))
		self.dayDrop.options:Add(op)
	end
	self.dayDrop:RefreshShownValue()
	self:ReqRecordList()
	
	self:AddClick("root/back", function ()
		self:Destroy()
	end)
end

--请求
function NFTDayRecordView:ReqRecordList()
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
function NFTDayRecordView:DealRecordList(data)
	
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
	self:ReqDayRecord(true,0)
end

function NFTDayRecordView:SetDayPool(pool)
	self.dayPoolText.text = FormatNum(pool)
end

function NFTDayRecordView:SetMineRank(data)
	if tostring(data) == "userdata: NULL" or data.rank == 0 then
		self.rankDayMineText.text = self.lan.noRank
		self.powerDayMineText.text = 0
		self.rewardDayMineText.text =  0
		self.rewardFRTDayMineText.text =  0
		self:FindChild("root/Bottom/Top"):Hide()
	else
		self.rankDayMineText.text = data.rank 
		self.powerDayMineText.text = FormatNum(data.power)
		self.rewardDayMineText.text = FormatNum(data.prize.prize.gold or 0)
		self.rewardFRTDayMineText.text = ZTD.Extend.FormatSpecNum((data.prize.prize.frt or 0)/1000000, 6)
		if data.rank < 4 then
			self:FindChild("root/Bottom/Top"):Show()
			for i=1,3 do
				self:FindChild("root/Bottom/Top/Top"..i):SetActive(data.rank == i)
			end
		else
			self:FindChild("root/Bottom/Top"):Hide()
		end
	end

end


function NFTDayRecordView:DealDayRecordData(data, reset)
	self:SetDayPool(data.season_info.total_pool)
	self:SetMineRank(data.my_record)
	self.totalPowerText.text = data.season_info.total_power
	
	if not data.records or #data.records == 0 then
		self.dayRankList = {}
		self.dayScrollCtr:ClearAll()
		self.dayScrollCtr:InitScroller(0)
		return
	end
	if reset then--重新拉数据
		self.dayRankList = table.copy(data.records)
		self.dayScrollCtr:ClearAll()
		if #self.dayRankList > 0 then
			self.dayScrollCtr:InitScroller(#self.dayRankList)
		end
	else
		local oldIndex = #self.dayRankList - 5
		oldIndex = oldIndex > 0 and oldIndex or 0
		for _,v in ipairs(data.records) do
			table.insert(self.dayRankList, v)
		end
		local progress = 1-self.dayScrollCtr:GetComponent("ScrollRect").verticalNormalizedPosition
		self.dayScrollCtr:RefreshScroller(#self.dayRankList,progress)
		self.dayScrollCtr.myScroller:JumpToDataIndex(oldIndex)
	end
end
--请求每日奖池信息
--offset数据偏移量
function NFTDayRecordView:ReqDayRecord(showWait, offset)
	--每次拉取的数据量
	local count = 20 
	offset = offset or 0
	ZTD.Request.HttpRequest("ReqDayRecord", {
		season_id = self.seasonId,
		day = self.dayId,
		page = {
			limit = count,
			offset = offset or 0,
		}
	}, function (data)
		--logError("ReqDayRecord " .. GC.uu.Dump(data))
		if not data.records or #data.records < count then
			--没有更多数据了，别拉了
			self.noMoreRecordData = true
		else
			self.noMoreRecordData = false
		end
		self:DealDayRecordData(data, offset==0)

	end, function ()
		logError("ReqDayRecord error")
	end, showWait)
end

--每日奖池玩法
function NFTDayRecordView:ItemInit(tran,dataIndex,cellIndex)
	dataIndex = dataIndex + 1
	if not self.dayRankList[dataIndex] then
		return
	end
	--最后一条数据，拉新的数据
	if not self.noMoreRecordData and dataIndex == #self.dayRankList then
		self:ReqDayRecord(true, dataIndex)
	end
	local data = self.dayRankList[dataIndex]
	local idx = 4
	if data.rank < 4 then
		idx = data.rank
	end
	local item
	for i=1, 4 do
		if i==idx then
			item = tran:FindChild("ImageRank" .. i)
			item:Show()
		else
			tran:FindChild("ImageRank" .. i):Hide()
		end
		
	end

	self:SetNodeText(item, "TextRank", data.rank)
	self:SetNodeText(item, "TextNick", data.name)
	self:SetNodeText(tran, "TextPower", FormatNum(data.power))
	self:SetNodeText(tran, "TextReward", FormatNum(data.prize.prize.gold or 0))
	self:SetNodeText(tran, "TextFRTReward", ZTD.Extend.FormatSpecNum((data.prize.prize.frt or 0)/1000000, 6))
end


return NFTDayRecordView