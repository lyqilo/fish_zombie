
local CC = require("CC")
local GiftDataMgr = CC.class2("GiftDataMgr")

local _giftMgr = nil
local RecommandedGuy = {}
local Information = {}
local InformationSelf = {} --自己个人资讯信息
local LoadNews = false	--是否拉取过资讯
--超v玩家列表
local superList = {}

function GiftDataMgr.Inst()
	if not _giftMgr then
		_giftMgr = GiftDataMgr.new()
	end
	return _giftMgr
end

function GiftDataMgr:ctor()
	self.SeachPersonMsg = {}	--根据id查找个人信息数据
	self.GiftRecord = {}
	self.Collect = {}
	self.Summary = {}
end

--清除资讯
function GiftDataMgr:ClearNewInformation(PlayerID)
	if PlayerID then
		local index = self:FindInformation(PlayerID)
		if index > 0 then
			Information[index] = nil
		end
		if PlayerID == CC.Player.Inst():GetSelfInfoByKey("Id") then
			Information[PlayerID] = {PlayerID = PlayerID}
		end
	end
end

--通过玩家ID找资讯
function GiftDataMgr:FindInformation(PlayerID)
	if PlayerID then
		for k,v in pairs(Information) do
			if PlayerID == v.PlayerID then
				return k
			end
		end
	end
	return -1
end

function GiftDataMgr:GetLoadNews()
	return LoadNews
end

--资讯列表
function GiftDataMgr:SetReInformation(data)
	if not data or not data.News then return end
	local SelfID = CC.Player.Inst():GetSelfInfoByKey("Id")
	LoadNews = true
	for k,v in ipairs(data.News) do
		if self:CheckData(v) then
			if v.PlayerID == SelfID then
				Information[v.PlayerID] = v
			else
				Information[(data.Index - 1) * 5 + k] = v
			end
		end
	end
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= 20 and not Information[SelfID] then
		Information[SelfID] = {PlayerID = SelfID}
	end
end

function GiftDataMgr:CheckData(value)
	if (value.Telephone and value.Telephone ~= "") or (value.Address and value.Address ~= "") or (value.FBAddress and value.FBAddress ~= "")
		or (value.LineAddress and value.LineAddress ~= "") or (value.Content and value.Content ~= "") then
		return true
	end
	return false
end

function GiftDataMgr:PairsByKeys(t)
	local a = {}
	for n in pairs(t) do a[#a + 1] = n end
	table.sort(a)
	local i = 0
	return function ()
		i = i + 1
		return a[i], t[a[i]]
	end
end

--获取资讯列表
function GiftDataMgr:GetReInformation()
	local tab = {}
	if not Information then return tab end
	local i  = 0
	local SelfID = CC.Player.Inst():GetSelfInfoByKey("Id")
	for _,v in self:PairsByKeys(Information) do
		i =  i + 1
		if SelfID == v.PlayerID then
			InformationSelf = {}
			InformationSelf = v
			table.insert(tab, 1, v)
		else
			tab[i] = v
		end
	end
	if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("FreeSwitch") then
		--赠送标示
		return self:TableRand(tab)
	end
	return tab
end

--设置自己资讯列表
function GiftDataMgr:SetReInformationSelf(data)
	if not data or not data.SingleNew then return end
	InformationSelf = data.SingleNew
	if data.SingleNew.PlayerID then
		Information[data.SingleNew.PlayerID] = data.SingleNew
	end
end

--获取自己资讯列表
function GiftDataMgr:GetReInformationSelf()
	return InformationSelf
end

--推荐列表
function GiftDataMgr:SetReCommandGuy(data)
	RecommandedGuy = data
end

--获取推荐列表
function GiftDataMgr:GetReCommandGuy()
	local tab = {}
	local i  = 0
	local SelfID = CC.Player.Inst():GetSelfInfoByKey("Id")
	if not RecommandedGuy.Guies then return tab end
	for k,v in ipairs(RecommandedGuy.Guies) do
		if SelfID ~= v.Player.PlayerId then
			i =  i + 1
			tab[i] = v
		end
	end
	if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("FreeSwitch") then
		--赠送标示
		return self:TableRand(tab)
	end
	return tab
end

function GiftDataMgr:TableRand(tab)
	if not tab then return end
	local newTab = {}
	local num = table.getn(tab)
	while num > 0 do
		local rd = math.random(1, num)
		table.insert(newTab, tab[rd])
		tab[rd] = tab[num]
		num = num -1
	end
	return newTab
end

--搜索好友
function GiftDataMgr:GetSeachPersonData()
	return self.SeachPersonMsg.Data.Player
end

--搜索好友数据
function GiftDataMgr:SetSeachPersonData(data)
	self.SeachPersonMsg = data
end

--赠送记录
function GiftDataMgr:SetGiftRecordData(data)
	if not data:HasField("Index") then
		return
	end
	if data.Index == 1 then
		self.GiftRecord = {}
	end
	for i,v in ipairs(data.Records) do
		table.insert(self.GiftRecord, v)
	end
end

function GiftDataMgr:GetAllGiftRecordData()
	return self.GiftRecord
end

--添加一条赠送记录
function GiftDataMgr:AddGiftRecordData(data)
	if not self.GiftRecord then
		self.GiftRecord = {}
	end
	if #(self.GiftRecord) <= 0 then
		table.insert(self.GiftRecord,data)
	else
		table.insert(self.GiftRecord,1,data)
	end
end

--根据下标获取赠送记录
function GiftDataMgr:GetGiftRecordData(index)
	for i,v in ipairs(self.GiftRecord) do
		if i == index then
			return self.GiftRecord[index]
		end
	end
end

--赠送记录长度
function GiftDataMgr:GiftRecordLen()
	if not self.GiftRecord then
		return 0
	end
	return #self.GiftRecord
end

--收礼记录
function GiftDataMgr:SetCollectData(data)
	if not data:HasField("Index") then
		return
	end
	if data.Index == 1 then
		self.Collect = {}
	end
	local index = self:Deduplication(self.Collect[#self.Collect] or {},data.Records)
	if index <= #data.Records then
		for index,v in ipairs(data.Records) do
			table.insert(self.Collect, v)
		end
	end
end
function GiftDataMgr:GetAllGiftCollectData()
	return self.Collect
end
--根据下标获得收礼记录
function GiftDataMgr:GetCollectData(index)
	for i,v in ipairs(self.Collect) do
		if i == index then
			return self.Collect[index]
		end
	end
end

--收礼
function GiftDataMgr:CollectLen()
	if not self.Collect then
		return 0
	end
	return #self.Collect
end

--数据去重
function GiftDataMgr:Deduplication(his,new)
	for k,v in ipairs(new) do
		if his.Time == v.Time and his.To == v.To and his.From == v.From and his.Amount == v.Amount then
			return k + 1
		end
	end
	return 1
end

--月汇总
function GiftDataMgr:SetSummaryData(data)
	self.Summary = {}
	for i,v in ipairs(data.Summaries) do
		table.insert(self.Summary, v)
	end
end

function GiftDataMgr:GetAllSummaryData()
	return self.Summary
end

--根据下标获取月汇总
function GiftDataMgr:GetSummaryData(index)
	for i,v in ipairs(self.Summary) do
		if i == index then
			return self.Summary[index]
		end
	end
end

--月汇总长度
function GiftDataMgr:SummaryLen()
	if not self.Summary then
		return 0
	end
	return #self.Summary
end

--赠送排行榜
function GiftDataMgr:SetTradeRankData(data)
	self.TradeRank = {}
	self.TradeMyRank = nil
	self.TradeRank = data.Rank
	self.TradeMyRank = data.MyRank
end

--获取排行榜item数据
function GiftDataMgr:GetTradeRankItemData(index)
	if not self.TradeRank then
		return
	end
	for i,v in ipairs(self.TradeRank) do
		if i == index then
			return self.TradeRank[index]
		end
	end
end

--获取排行榜数据
function GiftDataMgr:GetTradeRankData()
	return self.TradeRank or nil
end

--获取排行榜长度
function GiftDataMgr:GetTradeRankLen()
	if not self.TradeRank then
		return 0
	end
	return #self.TradeRank or 0
end

--超v白名单
function GiftDataMgr:SetSuperWhiteAccount(data)
	superList = data.PlayerIds
end

function GiftDataMgr:GetSuperWhiteAccount(playerId)
	for _,v in ipairs(superList) do
		if v == playerId then
			return true
		end
	end
	return false
end

return GiftDataMgr
