
local CC = require("CC")

local RealStoreDataMgr = {};

local GoodsMaps = nil
local IntegralList = nil
local ChipList = nil
local RedEnvelopeList = nil
local AllBuyGoodsInfo = nil
local SelfBuyGoodsInfo = nil
local TreasureMap = nil
local TreasureList = nil
local SuperTreasureList = nil
local TreasureRollInfo = nil
local TradeInfo = nil

-----------------扭蛋Record--------------------
local EggRecord = nil
local CombineEggMarquee = nil
---------------------------------------------
--vip折扣
local vipDiscount = {
	[1] = 10,
	[3] = 30,
	[5] = 50,
	[7] = 60,
	[9] = 70,
	[11] = 80,
}
-- v0-v2兑换红包需要金币保底
local keepMinChip = {
	[0] = 100000,
	[1] = 300000,
	[2] = 300000,
}

function RealStoreDataMgr.InitData()
	GoodsMaps = nil
	BuyGoodsInfo = nil
	AllBuyGoodsInfo = nil
	SelfBuyGoosSInfo = nil
end

function RealStoreDataMgr.SetIntegralList(data)
	GoodsMaps = {}
	IntegralList = {}
	for i,v in ipairs(data.GoodList) do
		local tb = {}
		tb.Id = tostring(v.ID)
		tb.Count = v.Stock
		tb.IsSupplement = v.IsSupplement
        if CC.ConfigCenter.Inst():getConfigDataByKey("PhysicalShop")[tb.Id] then
        	tb.Type = CC.ConfigCenter.Inst():getConfigDataByKey("PhysicalShop")[tb.Id].Currency
        	GoodsMaps[tb.Id] = tb
            if tb.Type == CC.shared_enums_pb.PCT_GiftVoucher or tb.Type == CC.shared_enums_pb.PCT_Card_Pieces or tb.Type == CC.shared_enums_pb.EPC_True_Money_Card 
				or tb.Type == CC.shared_enums_pb.EPC_True_Money_Fifty or tb.Type == CC.shared_enums_pb.EPC_One_Red_env or tb.Type == CC.shared_enums_pb.EPC_Truemoney_20093 then
                table.insert(IntegralList,GoodsMaps[tb.Id])
            end
        else
            logError("当前礼票商城配置中没有该ID商品或者没有对应Icon:"..tb.Id)
        end
    end
end

function RealStoreDataMgr.SetChipList(data)
	GoodsMaps = {}
	ChipList = {}
	for i,v in ipairs(data.GoodList) do
		local tb = {}
		tb.Id = tostring(v.ID)
		tb.Count = v.Stock
		tb.IsSupplement = v.IsSupplement
        if CC.ConfigCenter.Inst():getConfigDataByKey("PhysicalShop")[tb.Id] then
        	tb.Type = CC.ConfigCenter.Inst():getConfigDataByKey("PhysicalShop")[tb.Id].Currency
        	GoodsMaps[tb.Id] = tb
            if tb.Type == CC.shared_enums_pb.PCT_Chouma then
                table.insert(ChipList,GoodsMaps[tb.Id])
            end
        else
            logError("当前筹码商城配置中没有该ID商品或者没有对应Icon:"..tb.Id)
        end
    end
end


function RealStoreDataMgr.GetIntegralList()
	return IntegralList or {}
end

function RealStoreDataMgr.GetChipList()
	return ChipList or {}
end

function RealStoreDataMgr.SetRedEnvelopeList(data)
	GoodsMaps = {}
	RedEnvelopeList = {}
	--logError(CC.uu.Dump(data.GoodList,"RedEnvelopeList",10))
	for i,v in ipairs(data.GoodList) do
		local tb = {}
		tb.Id = tostring(v.ID)
		tb.Count = v.Stock
		tb.GoodsType = v.GoodsType
		tb.Consume = v.Currency
		tb.WePayChannel = v.WePayChannel
		tb.IsSupplement = v.IsSupplement
		if CC.ConfigCenter.Inst():getConfigDataByKey("PhysicalShop")[tb.Id] then
			tb.Type = CC.ConfigCenter.Inst():getConfigDataByKey("PhysicalShop")[tb.Id].Currency
			GoodsMaps[tb.Id] = tb
			--判断红包商城商品
			if v.Currency == CC.shared_enums_pb.EPC_Props_82 or v.Currency == CC.shared_enums_pb.EPC_Props_83 then
				table.insert(RedEnvelopeList,GoodsMaps[tb.Id])
			end
		else
			logError("当前红包商城配置中没有该ID商品或者没有对应Icon:"..tb.Id)
		end
	end
end

function RealStoreDataMgr.GetRedEnvelopeList()
	return RedEnvelopeList or {}
end

function RealStoreDataMgr.SetAllBuyGoodsInfo(data)
	AllBuyGoodsInfo = {}
	for i,v in ipairs(data.RecordRecent) do
		if #AllBuyGoodsInfo >= 5 then
			table.remove(AllBuyGoodsInfo)
		end
		table.insert(AllBuyGoodsInfo,v)
	end
end

function RealStoreDataMgr.AddAllBuyGoodsInfo(data)
	local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("PhysicalShop")
	local wareInfo = nil
	for i,v in ipairs(data.RecordRecent) do
        for s,t in pairs(wareCfg) do
		    if t.ProductId == v.GoodsID then
		    	wareInfo = CC.ConfigCenter.Inst():getConfigDataByKey("PhysicalShop")[t.Id]
			    break
		    end
	    end
		if not wareInfo then return end
		if AllBuyGoodsInfo then
			if #AllBuyGoodsInfo >= 5 then
				table.remove(AllBuyGoodsInfo)
			end
			table.insert(AllBuyGoodsInfo,1,v)
		else
			AllBuyGoodsInfo = {}
			table.insert(AllBuyGoodsInfo,1,v)
		end
		if v.PlayerID == CC.Player.Inst():GetLoginInfo().PlayerId then
			table.insert(SelfBuyGoodsInfo,1,v)
		end
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.RefreshRecordRecent)
end

function RealStoreDataMgr.GetAllBuyInfoCount()
	if AllBuyGoodsInfo then
		return #AllBuyGoodsInfo
	else
		return -1
	end
end

function RealStoreDataMgr.GetAllBuyInfoByIndex(index)
	return AllBuyGoodsInfo[index]
end

function RealStoreDataMgr.SetSelfBuyInfo(data)
	SelfBuyGoodsInfo = {}
	for i,v in ipairs(data.RecordBuy) do
		table.insert(SelfBuyGoodsInfo,v)
	end
end

function RealStoreDataMgr.GetSelfBuyInfoCount()
	if SelfBuyGoodsInfo then
		return #SelfBuyGoodsInfo
	else
		return -1
	end
end

function RealStoreDataMgr.GetSelfBuyInfoByIndex(index)
	return SelfBuyGoodsInfo[index]
end

function RealStoreDataMgr.SetTreasureInfo(data)

	if not TreasureMap then
		TreasureMap = {}
	end
	TreasureList = {}
	for i,v in ipairs(data.PrizeList) do
		local tb = {}
		tb = v

		TreasureMap[v.PrizeId] = tb
		table.insert(TreasureList,TreasureMap[v.PrizeId])
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.SetTreasureInfoFinish,TreasureList)
end

function RealStoreDataMgr.SetSuperTreasureInfo(data)
	if not TreasureMap then
		TreasureMap = {}
	end
	SuperTreasureList = {}
	for i,v in ipairs(data.PrizeList) do
		local tb = {}
		tb = v

		TreasureMap[v.PrizeId] = tb
		table.insert(SuperTreasureList,TreasureMap[v.PrizeId])
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.SetSuperTreasureInfoFinish,SuperTreasureList)
end

function RealStoreDataMgr.GetTreasureList()
	return TreasureList
end

function RealStoreDataMgr.GetSuperTreasureList()
	return SuperTreasureList
end

function RealStoreDataMgr.GetPriceIcon(Currency)
	if Currency == CC.shared_enums_pb.EPC_ChouMa then
		return "priceIcon_chip"
	elseif Currency == CC.shared_enums_pb.EPC_GiftVoucher then
		return "old_zytb_dhb"
	elseif Currency == CC.shared_enums_pb.EPC_New_GiftVoucher then
		return "new_zytb_dhb"
	elseif Currency == CC.shared_enums_pb.EPC_ZuanShi then
		return "priceIcon_diamond"
	elseif Currency == CC.shared_enums_pb.EPC_MidMonth_Treasure_Big then
		return "priceIcon_djq"
	elseif Currency == CC.shared_enums_pb.EPC_MidMonth_Treasure_Small then
		return "priceIcon_xjq"
	elseif Currency == CC.shared_enums_pb.PCT_Card_Pieces or Currency == CC.shared_enums_pb.EPC_PointCard_Fragment then
		return "hb_suipian"
	elseif Currency == CC.shared_enums_pb.EPC_One_Red_env then
		return "priceIcon_hb"
	elseif Currency == CC.shared_enums_pb.EPC_True_Money_Fifty then
		return "icon_dhk50"
	elseif Currency == CC.shared_enums_pb.EPC_Truemoney_20093 then
		return "icon_dhk"
	elseif Currency == CC.shared_enums_pb.EPC_Props_82 then
		return "prop_img_82"--"hbsc_icon1"
	elseif Currency == CC.shared_enums_pb.EPC_Props_83 then
		return "prop_img_82"--"hbsc_icon2"
	end
end

function RealStoreDataMgr.GetChipIcon(Count)
	if Count == nil then
		return "swsc_cm_01"
	end

	-- Coin1~11
	return "swsc_cm_0"..RealStoreDataMgr.GetChipLevel(Count)
end

function RealStoreDataMgr.GetChipLevel(Count)
	if Count >= 0 and Count < 50000 then
		return 1
	elseif Count >= 50000 and Count < 100000 then
		return 2
	elseif Count >= 100000 and Count < 500000 then
		return 3
	elseif Count >= 500000 and Count < 1000000 then
		return 4
	elseif Count >= 1000000 then
		return 5
	end
end

function RealStoreDataMgr.GetDescType(Id,Type)
	if Type == 9 then
		return "RechargeCard"
	elseif Id == CC.shared_enums_pb.EPC_ChouMa then
		return "Chip"
	elseif Id == CC.shared_enums_pb.EPC_RoomCard then
		return "RoomCard"
	else
		return "Other"
	end
end

--设置夺宝滚动信息数据
function RealStoreDataMgr.SetTreasureRollInfo(data)
	TreasureRollInfo = {}
	for i,v in ipairs(data.LatelyLuckys) do
		if #TreasureRollInfo >= 5 then
			table.remove(TreasureRollInfo)
		end
		table.insert(TreasureRollInfo,v)
	end
end


function RealStoreDataMgr.GetTreasureRollInfo()
	return TreasureRollInfo
end

function RealStoreDataMgr.GetTreasureRollInfoCount()
	if TreasureRollInfo then
		return #TreasureRollInfo
	else
		return 0
	end
end

function RealStoreDataMgr.GetTreasureRollInfoByIndex(index)
	return TreasureRollInfo[index]
end

function RealStoreDataMgr.SetTradeInfo(data)
	TradeInfo = {}
	TradeInfo.Locked = data.Locked
    TradeInfo.payments = data.arrLockList
    TradeInfo.payNum = #data.arrLockList
end

function RealStoreDataMgr.GetTradeInfo()
	return TradeInfo
end

---------------------------泼水节扭蛋活动-----------------------------------

function RealStoreDataMgr.SetEggRecord(data)
	EggRecord = {}
	for i, v in ipairs(data.Records) do
		table.insert(EggRecord,v)
	end
end

function RealStoreDataMgr.InsertEggRecord(data)
	if EggRecord == nil then
		EggRecord = {}
	end
	local param = {}
	param.Reward = data.Rewards[1]
	param.Name = data.Name
	param.PlayerId = data.PlayerId
	table.insert(EggRecord,param)
	if #EggRecord > 20 then
		table.remove(EggRecord,1)
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.RefrshEggRecord,param)
end

function RealStoreDataMgr.GetEggRecord()
	if EggRecord then
		return EggRecord
	else
		return nil
	end
end

---------------------------合成扭蛋活动-----------------------------------
function RealStoreDataMgr.SetCombineEggMarquee(data)
	CombineEggMarquee = {}
	for i, v in ipairs(data.Records) do
		table.insert(CombineEggMarquee,v)
	end
end

function RealStoreDataMgr.InsertCombineEggMarquee(data)
	if CombineEggMarquee == nil then
		CombineEggMarquee = {}
	end
	table.insert(CombineEggMarquee,1,data)
	CC.HallNotificationCenter.inst():post(CC.Notifications.RefrshCombineEggMarquee)
end

function RealStoreDataMgr.GetCombineEggMarquee()
	if CombineEggMarquee then
		return CombineEggMarquee
	else
		return nil
	end
end

--获取vip对应折扣
function RealStoreDataMgr.GetVipDiscount(lv)
	return vipDiscount[lv] or 0
end

function RealStoreDataMgr.GetKeepMinChip()
	local lv = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	return keepMinChip[lv] or 0
end

function RealStoreDataMgr.GetShowNumById(id,num)
	local num = num or CC.Player.Inst():GetSelfInfoByKey(id)
	local showNum = num or 0
	--红包商城显示红包数量除以1000
	if id == CC.shared_enums_pb.EPC_Props_82 or
		id == CC.shared_enums_pb.EPC_Props_83 then
		return showNum/1000
	end
	return showNum
end

return RealStoreDataMgr;