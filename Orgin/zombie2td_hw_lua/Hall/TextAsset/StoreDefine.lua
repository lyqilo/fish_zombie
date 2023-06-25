--商店页面定义
local CC = require("CC")
local StoreDefine = {}

StoreDefine.StoreTab = {
	Diamond = 1, --钻石
	Prop = 2, --道具
	Bank = 3 --银行渠道
}

StoreDefine.CommodityType = {
	Horn = 12,
	Chip = 13,
	RoomCard = 14,
	Fragment = 16,
	GiftVoucher = 17,
	PropShop = 18,
	Battery = 19, --炮台返场
	AIS = 20,
	Pay12Call = 21,
	Truemoney = 22,
	Molpoints = 23,
	Truewallet = 24,
	Mpay = 25,
	Linepay = 26,
	Psms = 27,
	Dcb = 28,
	Bay = 51,
	Bbl = 52,
	Ktb = 53,
	Scb = 54,
	Kbank = 55,
	Promptpay = 56,
	tiki_truemoney = 61,
	tiki_airpay = 62,
	tiki_promptpay = 63,
	Scb2 = 64,
	Linepay1 = 65,
	Bay1 = 66,
	Ktb1 = 67,
	Kbank1 = 68,
	GuPayKtbZ = 69,
	GuPayKbankZ = 70,
	GuPayKtb = 71,
	GuPayKbank = 72,
	GuPayBay = 74,
	GuPayBayZ = 75,
	GooglePay = 31,
	ApplePay = 41,
	OppoPay = 1001,
	VivoPayBank = 1101,
	VivoPaySms = 1102
}

StoreDefine.ChipChannelIcon = {
	AIS = "channel_ais.png",
	Pay12Call = "channel_12call.png",
	Truemoney = "channel_truemoney.png",
	Molpoints = "channel_molpoints.png",
	Truewallet = "channel_truewallet.png",
	Mpay = "channel_mpay.png",
	Linepay = "channel_linepay.png",
	Psms = "channel_psms.png",
	Dcb = "channel_dcb.png",
	GooglePay = "channel_googlepay.png",
	ApplePay = "channel_applepay.png",
	Bay = "channel_bay.png",
	Bbl = "channel_bbl.png",
	Ktb = "channel_ktb.png",
	Scb = "channel_scb.png",
	Kbank = "channel_kbank.png",
	Promptpay = "channel_promptpay.png",
	OppoPay = "channel_oppo.png",
	VivoPayBank = "channel_vivobank.png",
	VivoPaySms = "channel_vivosms.png",
	tiki_truemoney = "channel_truewallet.png",
	tiki_airpay = "channel_airpay.png",
	tiki_promptpay = "channel_promptpay.png",
	Scb2 = "channel_scb.png",
	Linepay1 = "channel_linepay.png",
	Bay1 = "channel_bay.png",
	Ktb1 = "channel_ktb.png",
	Kbank1 = "channel_kbank.png",
	GuPayKtbZ = "channel_ktb.png",
	GuPayKbankZ = "channel_kbank.png",
	GuPayBayZ = "channel_bay.png",
	GuPayBay = "channel_bay.png",
	GuPayKtb = "channel_ktb.png",
	GuPayKbank = "channel_kbank.png"
}

StoreDefine.PropPirceIcon = {
	Horn = "priceIcon_diamond.png",
	Chip = "priceIcon_diamond.png",
	RoomCard = "priceIcon_diamond.png",
	Fragment = "hb_suipian.png",
	GiftVoucher = "old_zytb_dhb.png",
	PropShop = "priceIcon_diamond.png",
	Battery = "priceIcon_diamond.png"
}

StoreDefine.PayChannel = {
	AIS = "mol_AIS",
	Pay12call = "12call",
	Truemoney = "truemoney",
	Molpoints = "molpoints",
	Truewallet = "mol_truewallet",
	Mpay = "mol_mpay",
	Linepay = "mol_linepay",
	Psms = "mol_truemoveh",
	Dcb = "mol_dcb",
	GooglePay = "GooglePay",
	ApplePay = "ios",
	Bay = "mol_bay",
	Bbl = "mol_bbl",
	Ktb = "mol_ktb",
	Scb = "mol_scb",
	Kbank = "mol_kbank",
	Promptpay = "mol_Promptpay_z",
	OppoPay = "OPPO",
	VivoPayBank = "VivoBank",
	VivoPaySms = "VivoSms",
	tiki_truemoney = "tiki_truemoney",
	tiki_airpay = "tiki_airpay",
	tiki_promptpay = "tiki_promptpay",
	Scb2 = "mol_scb_z",
	Linepay1 = "mol_linepay_z",
	Bay1 = "mol_bay_z",
	Ktb1 = "mol_ktb_z",
	Kbank1 = "mol_kbank_z",
	GuPayKtbZ = "gupay_ktb_z",
	GuPayKbankZ = "gupay_kbank_z",
	GuPayBayZ = "gupay_bay_z",
	GuPayBay = "gupay_bay",
	GuPayKtb = "gupay_ktb",
	GuPayKbank = "gupay_kbank"
}

--PayBySMS 对应shortcode
StoreDefine.ShortcodeRely = {
	THB10 = "4210501",
	THB20 = "4210502",
	THB30 = "4210503",
	THB50 = "4210505",
	THB60 = "4210506",
	THB90 = "42105018",
	THB100 = "4210510",
	THB150 = "4210515",
	THB200 = "4210520",
	THB300 = "4210530",
	THB500 = "4210550"
}

StoreDefine.InputBoxType = {
	Single = 1,
	Double = 2
}

StoreDefine.VIPGiftCfg = {
	-- {
	-- 	Id = 1,
	-- 	count = 0,
	-- 	Detal = "Give",
	-- 	Name = "GiveName",
	-- 	img = "Active1"
	-- },
	{
		Id = 1,
		count = 0,
		Detal = "realStore",
		Name = "realStoreName",
		img = "icon_swsc"
	},
	{
		Id = 2,
		count = 2,
		Detal = "laba",
		Name = "labaName",
		img = "Active2"
	},
	{
		Id = 3,
		count = 0,
		Detal = "Double",
		Name = "DoubleName",
		img = "Active3"
	}
}

StoreDefine.BankWareCfg = {
	["335000"] = {OriginalPrice = 250000, Send = 85000},
	["402000"] = {OriginalPrice = 300000, Send = 102000},
	["603000"] = {OriginalPrice = 450000, Send = 153000},
	["690000"] = {OriginalPrice = 500000, Send = 190000},
	["1035000"] = {OriginalPrice = 750000, Send = 285000},
	["1380000"] = {OriginalPrice = 1000000, Send = 380000},
	["2070000"] = {OriginalPrice = 1500000, Send = 570000},
	["3450000"] = {OriginalPrice = 2500000, Send = 950000},
	["7200000"] = {OriginalPrice = 5000000, Send = 2200000},
	["14400000"] = {OriginalPrice = 10000000, Send = 4400000},
	["21600000"] = {OriginalPrice = 15000000, Send = 6600000},
	["36000000"] = {OriginalPrice = 25000000, Send = 11000000},
	["72000000"] = {OriginalPrice = 50000000, Send = 22000000}
}

StoreDefine.BankChanell = {
	Bay = 51,
	Bbl = 52,
	Ktb = 53,
	Scb = 54,
	Kbank = 55,
	tiki_truemoney = 61,
	tiki_airpay = 62,
	tiki_promptpay = 63,
	Linepay = 26
}

StoreDefine.starttime = os.time({year = 2021, month = 11, day = 26, hour = 10, min = 0, sec = 0})
StoreDefine.endtime = os.time({year = 2021, month = 12, day = 3, hour = 0, min = 0, sec = 0})
StoreDefine.DisplayCDK = function(param, cursertime)
	--兼容左边页签跟顶部页签的CDK显示
	local data = table.copy(param)
	if data.price == nil then
		data.price = 50000000
	end
	if data.commodityType == nil then
		data.commodityType = StoreDefine.CommodityType.Molpoints
	end

	if data.commodityType ~= StoreDefine.CommodityType.Molpoints then
		return false
	end
	if data.price / 100 <= 50 then
		return false
	end

	if cursertime < StoreDefine.starttime then
		return false
	end
	if cursertime > StoreDefine.endtime then
		return false
	end

	return true
end

return StoreDefine
