local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu
local FormatNum = GC.uu.numberToStrWithComma
local NFTSeasonRecordView = ZTD.ClassView("ZTD_NFTSeasonRecordView")
local OptionData = UnityEngine.UI.Dropdown.OptionData

local boxKindList = {
	[1] = "box_gold",
	[2] = "box_silver",
	[3] = "box_copper"
}

function NFTSeasonRecordView:OnCreate()
	self.config = self._args[1]
	self.seasonRankList = {}
	self.recordSeasonList = {}
	self.seasonId = 1
	self.totalPool = 0
	self:PlayAnimAndEnter()
    self:InitLan()
    self:Init()
end

--初始化信息
function NFTSeasonRecordView:Init()
	
	self.dayPoolText = self:GetCmp("root/DayPool/Text", "Text")
	self.rankDayMineText = self:GetCmp("root/Bottom/TextRankMine", "Text")
	self.powerDayMineText = self:GetCmp("root/Bottom/TextPowerMine", "Text")
	self.rewardDayMineText = self:GetCmp("root/Bottom/TextRewardMine", "Text")
	self.rewardFRTDayMineText = self:GetCmp("root/Bottom/TextRewardFRTMine", "Text")
	self.noRecordText = self:GetCmp("root/CustomScroll/TextNoRecord", "Text")
	self.boxPanel = self:FindChild("root/Bottom/boxPanel")

	--滚动列表相关
	self.dayScrollCtr = self:FindChild("root/CustomScroll/Scroller"):GetComponent("ScrollerController")
	self.dayScrollCtr:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:ItemInit(tran,dataIndex,cellIndex)
	end)
	
	self.seasonDrop = self:GetCmp("root/SeasonDP","Dropdown")
	UIEvent.AddDropdownValueChange(self:FindChild("root/SeasonDP"), function (val)
		val = tonumber(val) + 1
		self.seasonId = self.recordSeasonList[val].id
		self.dayScrollCtr:ClearAll()
		self.dayScrollCtr:InitScroller(0)
		self:ReqSeasonRecord(true,0)

	end)
	
	self:AddClick("root/back", function ()
		self:Destroy()
	end)
	self:ReqRecordList()
end

--请求
function NFTSeasonRecordView:ReqRecordList()
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
function NFTSeasonRecordView:DealRecordList(data)
	--没有数据
	if tostring(data.season_list) == "userdata: NULL" or #data.season_list == 1 then
		ZTD.ViewManager.ShowTip(self.lan.noRecord)
		self.noRecordText:Show()
		return 
	end
	table.remove(data.season_list, 1)
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
	self:ReqSeasonRecord(true,0)
end

function NFTSeasonRecordView:SetDayPool(pool)
	self.dayPoolText.text = FormatNum(pool)
end


function NFTSeasonRecordView:SetMineRank(data)
	self:FindChild("root/Bottom/ImageFrt"):SetActive(not self.isBox)
	self.rewardFRTDayMineText:SetActive(not self.isBox)
	self.boxPanel:SetActive(self.isBox)

	if tostring(data) == "userdata: NULL" or data.rank == 0 then
		self.rankDayMineText.text = self.lan.noRank
		self.powerDayMineText.text = 0
		self.rewardDayMineText.text =  0
		self:SetBoxInfo(self.boxPanel, {}, true)
		self:FindChild("root/Bottom/Top"):Hide()
	else
		self.rankDayMineText.text = data.rank 
		self.powerDayMineText.text = FormatNum(data.power)
		
		local ratio = self:GetRatioByRank(data.rank)
		local str = FormatNum(data.prize.prize.gold or 0)--..string.format("(%.1f%%)",ratio)
		self.rewardDayMineText.text = str

		if self.isBox then
			self:SetBoxInfo(self.boxPanel, data.prize.prize, true)
		else
			local show = ZTD.Extend.FormatSpecNum((data.prize.prize.frt or 0)/1000000, 6)
				--show = show .. string.format("(%.1f%%)",ratio)
			self.rewardFRTDayMineText.text = show
		end
		
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

function NFTSeasonRecordView:SetTop3(data)
	for _,v in ipairs(data) do
		local icon = self:FindChild("root/Top/Top"..v.rank.."/Mask/ImagePortrail")
		local textFRT = self:FindChild("root/Top/Top"..v.rank.."/TextRewardFRT")
		textFRT:SetActive(not self.isBox)
		local boxPanel = self:FindChild("root/Top/Top"..v.rank.."/boxPanel")
		boxPanel:SetActive(self.isBox)
		self:FindChild("root/Top/Top"..v.rank.."/ImageFRT"):SetActive(not self.isBox)
		GC.SubGameInterface.SetHeadIcon(v.avatar, icon, v.uid)
		self:SetText("root/Top/Top"..v.rank.."/TextName", v.name)
		self:SetText("root/Top/Top"..v.rank.."/TextPower", 
			self.lan.power_..v.power)
		
		local ratio = v.prize.prize.gold / self.totalPool * 100
		local str = FormatNum(v.prize.prize.gold or 0)--..string.format("(%.1f%%)",ratio)
		self:SetText("root/Top/Top"..v.rank.."/TextReward", str)

		if self.isBox then
			self:SetBoxInfo(boxPanel, v.prize.prize)
		else
			if v.prize.prize.frt and v.prize.prize.frt > 0 then
				local show = ZTD.Extend.FormatSpecNum(v.prize.prize.frt/1000000, 6)
				--show = show .. string.format("(%.1f%%)",ratio)
				textFRT:SetText(show)
			end
		end
	end
end

function NFTSeasonRecordView:SetBoxInfo(boxPanel, data, bShow)
	for i = 1, #boxKindList do
		local box = boxPanel:GetChild(i - 1)
		if data and data[boxKindList[i]] then
			if i == 1 and not bShow then
				box:SetActive(data[boxKindList[i]] > 0)	
			elseif i == 2 and not bShow then
				box:SetActive(data[boxKindList[i]] > 0 or data[boxKindList[i - 1]] > 0)	
			end		
			local num = data[boxKindList[i]] < 10 and "0" .. data[boxKindList[i]] or data[boxKindList[i]]
			box:FindChild("Text"):GetComponent("Text").text = string.format("X<color=#FFD306>%s</color>", num)
		else
			box:FindChild("Text"):GetComponent("Text").text = string.format("X<color=#FFD306>%s</color>", "00")
		end
	end
end

--分红比例
function NFTSeasonRecordView:GetRatioByRank(rank)
	for _,v in ipairs(self.config.rank_prize) do
		if rank >= v.start_rank and rank <= v.end_rank then
			return v.ratio*100
		end
	end
	return 0
end

function NFTSeasonRecordView:DealSeasonRecordData(data, reset)
	self.totalPool = data.season_info.total_pool
	self:SetDayPool(data.season_info.total_pool)
	-- 兼容，判断这个赛季是宝箱还是frt币
	local temp = self.isBox
	if data.records and data.records[1] and data.records[1].prize then
		self.isBox = data.records[1].prize.prize.box_copper and true or false
	end
	self:SetMineRank(data.my_record)
	if not data.records or #data.records == 0 then
		self.seasonRankList	 = {}
		self.dayScrollCtr:ClearAll()
		self.dayScrollCtr:InitScroller(0)
		return
	end

	if reset or temp ~= self.isBox then--重新拉数据
		self.seasonRankList = table.copy(data.records)
		
		local top3 = {}
		for i=1,3 do
			if self.seasonRankList[1] then
				table.insert(top3,self.seasonRankList[1])
				table.remove(self.seasonRankList, 1)
			end
		end
		self:SetTop3(top3)
		self.dayScrollCtr:ClearAll()
		if #self.seasonRankList > 0 then
			self.dayScrollCtr:InitScroller(#self.seasonRankList)
		end
	else
		local oldIndex = #self.seasonRankList - 2
		oldIndex = oldIndex > 0 and oldIndex or 0
		for _,v in ipairs(data.records) do
			table.insert(self.seasonRankList, v)
		end
		local progress = 1-self.dayScrollCtr:GetComponent("ScrollRect").verticalNormalizedPosition
		self.dayScrollCtr:RefreshScroller(#self.seasonRankList,progress)
		self.dayScrollCtr.myScroller:JumpToDataIndex(oldIndex)
	end
end
--请求每日奖池信息
--offset数据偏移量
function NFTSeasonRecordView:ReqSeasonRecord(showWait, offset)
	--每次拉取的数据量
	local count = 20 
	offset = offset or 0
	ZTD.Request.HttpRequest("ReqSeasonRecord", {
		season_id = self.seasonId,
		page = {
			limit = count,
			offset = offset or 0,
		}
	}, function (data)
		--logError("ReqSeasonRecord " .. GC.uu.Dump(data))
		if not data.records or #data.records < count then
			--没有更多数据了，别拉了
			self.noMoreRecordData = true
		else
			self.noMoreRecordData = false
		end
		self:DealSeasonRecordData(data, offset==0)

	end, function ()
		logError("ReqSeasonRecord error")
	end, showWait)
end

--每日奖池玩法
function NFTSeasonRecordView:ItemInit(tran,dataIndex,cellIndex)
	
	dataIndex = dataIndex + 1
	if not self.seasonRankList[dataIndex] then
		return
	end
	--最后一条数据，拉新的数据
	if not self.noMoreCurSeasonRankData and dataIndex == #self.seasonRankList then
		self:ReqSeasonRecord(true, dataIndex+3)
	end

	local data = self.seasonRankList[dataIndex]
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
	local textFRT = tran:FindChild("TextFRTReward")
	textFRT:SetActive(not self.isBox)
	tran:FindChild("ImageFRT"):SetActive(not self.isBox)
	local boxPanel = tran:FindChild("boxPanel")
	boxPanel:SetActive(self.isBox)
	
	local ratio = self:GetRatioByRank(data.rank)
	local str = FormatNum(data.prize.prize.gold or 0)--..string.format("(%.1f%%)",ratio)
	self:SetNodeText(tran, "TextReward", str)
	if self.isBox then
		self:SetBoxInfo(boxPanel, data.prize.prize)
	else
		if data.prize.prize.frt and data.prize.prize.frt > 0 then
			local show = ZTD.Extend.FormatSpecNum(data.prize.prize.frt/1000000, 6)
			--show = show .. string.format("(%.1f%%)",ratio)
			self:SetNodeText(tran, "TextFRTReward", show)
		end
	end
end


return NFTSeasonRecordView