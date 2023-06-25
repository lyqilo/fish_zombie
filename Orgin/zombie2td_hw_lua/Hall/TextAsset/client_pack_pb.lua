-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf/protobuf"
local pb = {}
local descriptor = {}

descriptor.GIFTPACKOPS = protobuf.EnumDescriptor();
descriptor.GIFTPACKOPS_REQ_STATUS_BUY_ENUM = protobuf.EnumValueDescriptor();
descriptor.GIFTPACKOPS_REQ_RECORD_GET_ENUM = protobuf.EnumValueDescriptor();
descriptor.GIFTPACKOPS_REQ_TIMES_BUY_ENUM = protobuf.EnumValueDescriptor();
descriptor.GIFTPACKOPS_REQ_STOCK_PACK_GET_ENUM = protobuf.EnumValueDescriptor();
descriptor.GIFTPACKOPS_REQ_REMAIN_TIME_ENUM = protobuf.EnumValueDescriptor();
descriptor.GIFTPACKOPS_REQ_BUY_ENUM = protobuf.EnumValueDescriptor();
descriptor.GIFTPACKTYPE = protobuf.EnumDescriptor();
descriptor.GIFTPACKTYPE_VIPRIGHTPACK_ENUM = protobuf.EnumValueDescriptor();
descriptor.GIFTPACKTYPE_CHRISTMASALLPACK_ENUM = protobuf.EnumValueDescriptor();
descriptor.GIFTPACKTYPE_CHRISTMASPERSONPACK_ENUM = protobuf.EnumValueDescriptor();
descriptor.GIFTPACKTYPE_BIRTHDAYPACK_ENUM = protobuf.EnumValueDescriptor();
descriptor.GIFTPACKTYPE_TEMPORARYPACK_ENUM = protobuf.EnumValueDescriptor();
descriptor.BUYSTATUSREQ = protobuf.Descriptor();
descriptor.BUYSTATUSREQ_PACKID_FIELD = protobuf.FieldDescriptor();
descriptor.BROADCASTINFO = protobuf.Descriptor();
descriptor.BROADCASTINFO_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.BROADCASTINFO_PLAYERNAME_FIELD = protobuf.FieldDescriptor();
descriptor.BROADCASTINFO_VIPLEVEL_FIELD = protobuf.FieldDescriptor();
descriptor.BROADCASTINFO_PORTRAIT_FIELD = protobuf.FieldDescriptor();
descriptor.BROADCASTINFO_PROPID_FIELD = protobuf.FieldDescriptor();
descriptor.BROADCASTINFO_PROPNUM_FIELD = protobuf.FieldDescriptor();
descriptor.BROADCASTINFO_TIMESTAMP_FIELD = protobuf.FieldDescriptor();
descriptor.BROADCASTINFO_CURRENCY_FIELD = protobuf.FieldDescriptor();
descriptor.BROADCASTINFO_PRICE_FIELD = protobuf.FieldDescriptor();
descriptor.BROADCASTRECORDREQ = protobuf.Descriptor();
descriptor.BROADCASTRECORDREQ_PACKTYPE_FIELD = protobuf.FieldDescriptor();
descriptor.BROADCASTRECORDRESP = protobuf.Descriptor();
descriptor.BROADCASTRECORDRESP_RECORDLIST_FIELD = protobuf.FieldDescriptor();
descriptor.PACKTIMESBUYREQ = protobuf.Descriptor();
descriptor.PACKTIMESBUYREQ_PACKIDS_FIELD = protobuf.FieldDescriptor();
descriptor.TIMESBUYINFO = protobuf.Descriptor();
descriptor.TIMESBUYINFO_PACKID_FIELD = protobuf.FieldDescriptor();
descriptor.TIMESBUYINFO_TOTALTIMES_FIELD = protobuf.FieldDescriptor();
descriptor.TIMESBUYINFO_DAYTIMES_FIELD = protobuf.FieldDescriptor();
descriptor.TIMESBUYINFO_SHORTTIMES_FIELD = protobuf.FieldDescriptor();
descriptor.TIMESBUYINFO_REMAINTOTALTIMES_FIELD = protobuf.FieldDescriptor();
descriptor.TIMESBUYINFO_REMAINDAYTIMES_FIELD = protobuf.FieldDescriptor();
descriptor.TIMESBUYINFO_REMAINSHORTTIMES_FIELD = protobuf.FieldDescriptor();
descriptor.PACKTIMESBUYRESP = protobuf.Descriptor();
descriptor.PACKTIMESBUYRESP_TIMESBUY_FIELD = protobuf.FieldDescriptor();
descriptor.PACKSTOCKREQ = protobuf.Descriptor();
descriptor.PACKSTOCKREQ_PACKIDS_FIELD = protobuf.FieldDescriptor();
descriptor.PACKSTOCKINFO = protobuf.Descriptor();
descriptor.PACKSTOCKINFO_PACKID_FIELD = protobuf.FieldDescriptor();
descriptor.PACKSTOCKINFO_STOCKNUM_FIELD = protobuf.FieldDescriptor();
descriptor.PACKSTOCKRESP = protobuf.Descriptor();
descriptor.PACKSTOCKRESP_PACKSTOCK_FIELD = protobuf.FieldDescriptor();
descriptor.REMAINTIMEREQ = protobuf.Descriptor();
descriptor.REMAINTIMEREQ_PACKTYPE_FIELD = protobuf.FieldDescriptor();
descriptor.REMAINTIMERESP = protobuf.Descriptor();
descriptor.REMAINTIMERESP_TOOPENTIME_FIELD = protobuf.FieldDescriptor();
descriptor.REMAINTIMERESP_TOENDTIME_FIELD = protobuf.FieldDescriptor();
descriptor.REMAINTIMERESP_ISFINISHED_FIELD = protobuf.FieldDescriptor();
descriptor.REMAINTIMERESP_ISDAYFINISHED_FIELD = protobuf.FieldDescriptor();
descriptor.REMAINTIMERESP_OPENTIMES_FIELD = protobuf.FieldDescriptor();

descriptor.GIFTPACKOPS_REQ_STATUS_BUY_ENUM.name = "Req_Status_Buy"
descriptor.GIFTPACKOPS_REQ_STATUS_BUY_ENUM.index = 0
descriptor.GIFTPACKOPS_REQ_STATUS_BUY_ENUM.number = 1
descriptor.GIFTPACKOPS_REQ_RECORD_GET_ENUM.name = "Req_Record_Get"
descriptor.GIFTPACKOPS_REQ_RECORD_GET_ENUM.index = 1
descriptor.GIFTPACKOPS_REQ_RECORD_GET_ENUM.number = 2
descriptor.GIFTPACKOPS_REQ_TIMES_BUY_ENUM.name = "Req_Times_buy"
descriptor.GIFTPACKOPS_REQ_TIMES_BUY_ENUM.index = 2
descriptor.GIFTPACKOPS_REQ_TIMES_BUY_ENUM.number = 3
descriptor.GIFTPACKOPS_REQ_STOCK_PACK_GET_ENUM.name = "Req_Stock_Pack_Get"
descriptor.GIFTPACKOPS_REQ_STOCK_PACK_GET_ENUM.index = 3
descriptor.GIFTPACKOPS_REQ_STOCK_PACK_GET_ENUM.number = 4
descriptor.GIFTPACKOPS_REQ_REMAIN_TIME_ENUM.name = "Req_Remain_Time"
descriptor.GIFTPACKOPS_REQ_REMAIN_TIME_ENUM.index = 4
descriptor.GIFTPACKOPS_REQ_REMAIN_TIME_ENUM.number = 5
descriptor.GIFTPACKOPS_REQ_BUY_ENUM.name = "Req_Buy"
descriptor.GIFTPACKOPS_REQ_BUY_ENUM.index = 5
descriptor.GIFTPACKOPS_REQ_BUY_ENUM.number = 6
descriptor.GIFTPACKOPS.name = "GiftPackOps"
descriptor.GIFTPACKOPS.full_name = ".VK.Proto.GiftPackOps"
descriptor.GIFTPACKOPS.values = {descriptor.GIFTPACKOPS_REQ_STATUS_BUY_ENUM,descriptor.GIFTPACKOPS_REQ_RECORD_GET_ENUM,descriptor.GIFTPACKOPS_REQ_TIMES_BUY_ENUM,descriptor.GIFTPACKOPS_REQ_STOCK_PACK_GET_ENUM,descriptor.GIFTPACKOPS_REQ_REMAIN_TIME_ENUM,descriptor.GIFTPACKOPS_REQ_BUY_ENUM}
descriptor.GIFTPACKTYPE_VIPRIGHTPACK_ENUM.name = "VipRightPack"
descriptor.GIFTPACKTYPE_VIPRIGHTPACK_ENUM.index = 0
descriptor.GIFTPACKTYPE_VIPRIGHTPACK_ENUM.number = 1
descriptor.GIFTPACKTYPE_CHRISTMASALLPACK_ENUM.name = "ChristmasAllPack"
descriptor.GIFTPACKTYPE_CHRISTMASALLPACK_ENUM.index = 1
descriptor.GIFTPACKTYPE_CHRISTMASALLPACK_ENUM.number = 2
descriptor.GIFTPACKTYPE_CHRISTMASPERSONPACK_ENUM.name = "ChristmasPersonPack"
descriptor.GIFTPACKTYPE_CHRISTMASPERSONPACK_ENUM.index = 2
descriptor.GIFTPACKTYPE_CHRISTMASPERSONPACK_ENUM.number = 3
descriptor.GIFTPACKTYPE_BIRTHDAYPACK_ENUM.name = "BirthdayPack"
descriptor.GIFTPACKTYPE_BIRTHDAYPACK_ENUM.index = 3
descriptor.GIFTPACKTYPE_BIRTHDAYPACK_ENUM.number = 4
descriptor.GIFTPACKTYPE_TEMPORARYPACK_ENUM.name = "TemporaryPack"
descriptor.GIFTPACKTYPE_TEMPORARYPACK_ENUM.index = 4
descriptor.GIFTPACKTYPE_TEMPORARYPACK_ENUM.number = 5
descriptor.GIFTPACKTYPE.name = "GiftPackType"
descriptor.GIFTPACKTYPE.full_name = ".VK.Proto.GiftPackType"
descriptor.GIFTPACKTYPE.values = {descriptor.GIFTPACKTYPE_VIPRIGHTPACK_ENUM,descriptor.GIFTPACKTYPE_CHRISTMASALLPACK_ENUM,descriptor.GIFTPACKTYPE_CHRISTMASPERSONPACK_ENUM,descriptor.GIFTPACKTYPE_BIRTHDAYPACK_ENUM,descriptor.GIFTPACKTYPE_TEMPORARYPACK_ENUM}
descriptor.BUYSTATUSREQ_PACKID_FIELD.name = "PackID"
descriptor.BUYSTATUSREQ_PACKID_FIELD.full_name = ".VK.Proto.BuyStatusReq.PackID"
descriptor.BUYSTATUSREQ_PACKID_FIELD.number = 1
descriptor.BUYSTATUSREQ_PACKID_FIELD.index = 0
descriptor.BUYSTATUSREQ_PACKID_FIELD.label = 2
descriptor.BUYSTATUSREQ_PACKID_FIELD.has_default_value = false
descriptor.BUYSTATUSREQ_PACKID_FIELD.default_value = ""
descriptor.BUYSTATUSREQ_PACKID_FIELD.type = 9
descriptor.BUYSTATUSREQ_PACKID_FIELD.cpp_type = 9

descriptor.BUYSTATUSREQ.name = "BuyStatusReq"
descriptor.BUYSTATUSREQ.full_name = ".VK.Proto.BuyStatusReq"
descriptor.BUYSTATUSREQ.nested_types = {}
descriptor.BUYSTATUSREQ.enum_types = {}
descriptor.BUYSTATUSREQ.fields = {descriptor.BUYSTATUSREQ_PACKID_FIELD}
descriptor.BUYSTATUSREQ.is_extendable = false
descriptor.BUYSTATUSREQ.extensions = {}
descriptor.BROADCASTINFO_PLAYERID_FIELD.name = "PlayerID"
descriptor.BROADCASTINFO_PLAYERID_FIELD.full_name = ".VK.Proto.BroadCastInfo.PlayerID"
descriptor.BROADCASTINFO_PLAYERID_FIELD.number = 1
descriptor.BROADCASTINFO_PLAYERID_FIELD.index = 0
descriptor.BROADCASTINFO_PLAYERID_FIELD.label = 2
descriptor.BROADCASTINFO_PLAYERID_FIELD.has_default_value = false
descriptor.BROADCASTINFO_PLAYERID_FIELD.default_value = 0
descriptor.BROADCASTINFO_PLAYERID_FIELD.type = 3
descriptor.BROADCASTINFO_PLAYERID_FIELD.cpp_type = 2

descriptor.BROADCASTINFO_PLAYERNAME_FIELD.name = "PlayerName"
descriptor.BROADCASTINFO_PLAYERNAME_FIELD.full_name = ".VK.Proto.BroadCastInfo.PlayerName"
descriptor.BROADCASTINFO_PLAYERNAME_FIELD.number = 2
descriptor.BROADCASTINFO_PLAYERNAME_FIELD.index = 1
descriptor.BROADCASTINFO_PLAYERNAME_FIELD.label = 2
descriptor.BROADCASTINFO_PLAYERNAME_FIELD.has_default_value = false
descriptor.BROADCASTINFO_PLAYERNAME_FIELD.default_value = ""
descriptor.BROADCASTINFO_PLAYERNAME_FIELD.type = 9
descriptor.BROADCASTINFO_PLAYERNAME_FIELD.cpp_type = 9

descriptor.BROADCASTINFO_VIPLEVEL_FIELD.name = "VipLevel"
descriptor.BROADCASTINFO_VIPLEVEL_FIELD.full_name = ".VK.Proto.BroadCastInfo.VipLevel"
descriptor.BROADCASTINFO_VIPLEVEL_FIELD.number = 3
descriptor.BROADCASTINFO_VIPLEVEL_FIELD.index = 2
descriptor.BROADCASTINFO_VIPLEVEL_FIELD.label = 2
descriptor.BROADCASTINFO_VIPLEVEL_FIELD.has_default_value = false
descriptor.BROADCASTINFO_VIPLEVEL_FIELD.default_value = 0
descriptor.BROADCASTINFO_VIPLEVEL_FIELD.type = 3
descriptor.BROADCASTINFO_VIPLEVEL_FIELD.cpp_type = 2

descriptor.BROADCASTINFO_PORTRAIT_FIELD.name = "Portrait"
descriptor.BROADCASTINFO_PORTRAIT_FIELD.full_name = ".VK.Proto.BroadCastInfo.Portrait"
descriptor.BROADCASTINFO_PORTRAIT_FIELD.number = 4
descriptor.BROADCASTINFO_PORTRAIT_FIELD.index = 3
descriptor.BROADCASTINFO_PORTRAIT_FIELD.label = 2
descriptor.BROADCASTINFO_PORTRAIT_FIELD.has_default_value = false
descriptor.BROADCASTINFO_PORTRAIT_FIELD.default_value = ""
descriptor.BROADCASTINFO_PORTRAIT_FIELD.type = 9
descriptor.BROADCASTINFO_PORTRAIT_FIELD.cpp_type = 9

descriptor.BROADCASTINFO_PROPID_FIELD.name = "PropID"
descriptor.BROADCASTINFO_PROPID_FIELD.full_name = ".VK.Proto.BroadCastInfo.PropID"
descriptor.BROADCASTINFO_PROPID_FIELD.number = 5
descriptor.BROADCASTINFO_PROPID_FIELD.index = 4
descriptor.BROADCASTINFO_PROPID_FIELD.label = 2
descriptor.BROADCASTINFO_PROPID_FIELD.has_default_value = false
descriptor.BROADCASTINFO_PROPID_FIELD.default_value = 0
descriptor.BROADCASTINFO_PROPID_FIELD.type = 3
descriptor.BROADCASTINFO_PROPID_FIELD.cpp_type = 2

descriptor.BROADCASTINFO_PROPNUM_FIELD.name = "PropNum"
descriptor.BROADCASTINFO_PROPNUM_FIELD.full_name = ".VK.Proto.BroadCastInfo.PropNum"
descriptor.BROADCASTINFO_PROPNUM_FIELD.number = 6
descriptor.BROADCASTINFO_PROPNUM_FIELD.index = 5
descriptor.BROADCASTINFO_PROPNUM_FIELD.label = 2
descriptor.BROADCASTINFO_PROPNUM_FIELD.has_default_value = false
descriptor.BROADCASTINFO_PROPNUM_FIELD.default_value = 0
descriptor.BROADCASTINFO_PROPNUM_FIELD.type = 3
descriptor.BROADCASTINFO_PROPNUM_FIELD.cpp_type = 2

descriptor.BROADCASTINFO_TIMESTAMP_FIELD.name = "TimeStamp"
descriptor.BROADCASTINFO_TIMESTAMP_FIELD.full_name = ".VK.Proto.BroadCastInfo.TimeStamp"
descriptor.BROADCASTINFO_TIMESTAMP_FIELD.number = 7
descriptor.BROADCASTINFO_TIMESTAMP_FIELD.index = 6
descriptor.BROADCASTINFO_TIMESTAMP_FIELD.label = 2
descriptor.BROADCASTINFO_TIMESTAMP_FIELD.has_default_value = false
descriptor.BROADCASTINFO_TIMESTAMP_FIELD.default_value = 0
descriptor.BROADCASTINFO_TIMESTAMP_FIELD.type = 3
descriptor.BROADCASTINFO_TIMESTAMP_FIELD.cpp_type = 2

descriptor.BROADCASTINFO_CURRENCY_FIELD.name = "Currency"
descriptor.BROADCASTINFO_CURRENCY_FIELD.full_name = ".VK.Proto.BroadCastInfo.Currency"
descriptor.BROADCASTINFO_CURRENCY_FIELD.number = 8
descriptor.BROADCASTINFO_CURRENCY_FIELD.index = 7
descriptor.BROADCASTINFO_CURRENCY_FIELD.label = 1
descriptor.BROADCASTINFO_CURRENCY_FIELD.has_default_value = false
descriptor.BROADCASTINFO_CURRENCY_FIELD.default_value = 0
descriptor.BROADCASTINFO_CURRENCY_FIELD.type = 3
descriptor.BROADCASTINFO_CURRENCY_FIELD.cpp_type = 2

descriptor.BROADCASTINFO_PRICE_FIELD.name = "Price"
descriptor.BROADCASTINFO_PRICE_FIELD.full_name = ".VK.Proto.BroadCastInfo.Price"
descriptor.BROADCASTINFO_PRICE_FIELD.number = 9
descriptor.BROADCASTINFO_PRICE_FIELD.index = 8
descriptor.BROADCASTINFO_PRICE_FIELD.label = 1
descriptor.BROADCASTINFO_PRICE_FIELD.has_default_value = false
descriptor.BROADCASTINFO_PRICE_FIELD.default_value = 0
descriptor.BROADCASTINFO_PRICE_FIELD.type = 3
descriptor.BROADCASTINFO_PRICE_FIELD.cpp_type = 2

descriptor.BROADCASTINFO.name = "BroadCastInfo"
descriptor.BROADCASTINFO.full_name = ".VK.Proto.BroadCastInfo"
descriptor.BROADCASTINFO.nested_types = {}
descriptor.BROADCASTINFO.enum_types = {}
descriptor.BROADCASTINFO.fields = {descriptor.BROADCASTINFO_PLAYERID_FIELD, descriptor.BROADCASTINFO_PLAYERNAME_FIELD, descriptor.BROADCASTINFO_VIPLEVEL_FIELD, descriptor.BROADCASTINFO_PORTRAIT_FIELD, descriptor.BROADCASTINFO_PROPID_FIELD, descriptor.BROADCASTINFO_PROPNUM_FIELD, descriptor.BROADCASTINFO_TIMESTAMP_FIELD, descriptor.BROADCASTINFO_CURRENCY_FIELD, descriptor.BROADCASTINFO_PRICE_FIELD}
descriptor.BROADCASTINFO.is_extendable = false
descriptor.BROADCASTINFO.extensions = {}
descriptor.BROADCASTRECORDREQ_PACKTYPE_FIELD.name = "packType"
descriptor.BROADCASTRECORDREQ_PACKTYPE_FIELD.full_name = ".VK.Proto.BroadCastRecordReq.packType"
descriptor.BROADCASTRECORDREQ_PACKTYPE_FIELD.number = 1
descriptor.BROADCASTRECORDREQ_PACKTYPE_FIELD.index = 0
descriptor.BROADCASTRECORDREQ_PACKTYPE_FIELD.label = 2
descriptor.BROADCASTRECORDREQ_PACKTYPE_FIELD.has_default_value = false
descriptor.BROADCASTRECORDREQ_PACKTYPE_FIELD.default_value = nil
descriptor.BROADCASTRECORDREQ_PACKTYPE_FIELD.enum_type = descriptor.GIFTPACKTYPE
descriptor.BROADCASTRECORDREQ_PACKTYPE_FIELD.type = 14
descriptor.BROADCASTRECORDREQ_PACKTYPE_FIELD.cpp_type = 8

descriptor.BROADCASTRECORDREQ.name = "BroadCastRecordReq"
descriptor.BROADCASTRECORDREQ.full_name = ".VK.Proto.BroadCastRecordReq"
descriptor.BROADCASTRECORDREQ.nested_types = {}
descriptor.BROADCASTRECORDREQ.enum_types = {}
descriptor.BROADCASTRECORDREQ.fields = {descriptor.BROADCASTRECORDREQ_PACKTYPE_FIELD}
descriptor.BROADCASTRECORDREQ.is_extendable = false
descriptor.BROADCASTRECORDREQ.extensions = {}
descriptor.BROADCASTRECORDRESP_RECORDLIST_FIELD.name = "RecordList"
descriptor.BROADCASTRECORDRESP_RECORDLIST_FIELD.full_name = ".VK.Proto.BroadcastRecordResp.RecordList"
descriptor.BROADCASTRECORDRESP_RECORDLIST_FIELD.number = 1
descriptor.BROADCASTRECORDRESP_RECORDLIST_FIELD.index = 0
descriptor.BROADCASTRECORDRESP_RECORDLIST_FIELD.label = 3
descriptor.BROADCASTRECORDRESP_RECORDLIST_FIELD.has_default_value = false
descriptor.BROADCASTRECORDRESP_RECORDLIST_FIELD.default_value = {}
descriptor.BROADCASTRECORDRESP_RECORDLIST_FIELD.message_type = descriptor.BROADCASTINFO
descriptor.BROADCASTRECORDRESP_RECORDLIST_FIELD.type = 11
descriptor.BROADCASTRECORDRESP_RECORDLIST_FIELD.cpp_type = 10

descriptor.BROADCASTRECORDRESP.name = "BroadcastRecordResp"
descriptor.BROADCASTRECORDRESP.full_name = ".VK.Proto.BroadcastRecordResp"
descriptor.BROADCASTRECORDRESP.nested_types = {}
descriptor.BROADCASTRECORDRESP.enum_types = {}
descriptor.BROADCASTRECORDRESP.fields = {descriptor.BROADCASTRECORDRESP_RECORDLIST_FIELD}
descriptor.BROADCASTRECORDRESP.is_extendable = false
descriptor.BROADCASTRECORDRESP.extensions = {}
descriptor.PACKTIMESBUYREQ_PACKIDS_FIELD.name = "PackIDs"
descriptor.PACKTIMESBUYREQ_PACKIDS_FIELD.full_name = ".VK.Proto.PackTimesBuyReq.PackIDs"
descriptor.PACKTIMESBUYREQ_PACKIDS_FIELD.number = 1
descriptor.PACKTIMESBUYREQ_PACKIDS_FIELD.index = 0
descriptor.PACKTIMESBUYREQ_PACKIDS_FIELD.label = 3
descriptor.PACKTIMESBUYREQ_PACKIDS_FIELD.has_default_value = false
descriptor.PACKTIMESBUYREQ_PACKIDS_FIELD.default_value = {}
descriptor.PACKTIMESBUYREQ_PACKIDS_FIELD.type = 9
descriptor.PACKTIMESBUYREQ_PACKIDS_FIELD.cpp_type = 9

descriptor.PACKTIMESBUYREQ.name = "PackTimesBuyReq"
descriptor.PACKTIMESBUYREQ.full_name = ".VK.Proto.PackTimesBuyReq"
descriptor.PACKTIMESBUYREQ.nested_types = {}
descriptor.PACKTIMESBUYREQ.enum_types = {}
descriptor.PACKTIMESBUYREQ.fields = {descriptor.PACKTIMESBUYREQ_PACKIDS_FIELD}
descriptor.PACKTIMESBUYREQ.is_extendable = false
descriptor.PACKTIMESBUYREQ.extensions = {}
descriptor.TIMESBUYINFO_PACKID_FIELD.name = "PackID"
descriptor.TIMESBUYINFO_PACKID_FIELD.full_name = ".VK.Proto.TimesBuyInfo.PackID"
descriptor.TIMESBUYINFO_PACKID_FIELD.number = 1
descriptor.TIMESBUYINFO_PACKID_FIELD.index = 0
descriptor.TIMESBUYINFO_PACKID_FIELD.label = 2
descriptor.TIMESBUYINFO_PACKID_FIELD.has_default_value = false
descriptor.TIMESBUYINFO_PACKID_FIELD.default_value = ""
descriptor.TIMESBUYINFO_PACKID_FIELD.type = 9
descriptor.TIMESBUYINFO_PACKID_FIELD.cpp_type = 9

descriptor.TIMESBUYINFO_TOTALTIMES_FIELD.name = "TotalTimes"
descriptor.TIMESBUYINFO_TOTALTIMES_FIELD.full_name = ".VK.Proto.TimesBuyInfo.TotalTimes"
descriptor.TIMESBUYINFO_TOTALTIMES_FIELD.number = 2
descriptor.TIMESBUYINFO_TOTALTIMES_FIELD.index = 1
descriptor.TIMESBUYINFO_TOTALTIMES_FIELD.label = 1
descriptor.TIMESBUYINFO_TOTALTIMES_FIELD.has_default_value = false
descriptor.TIMESBUYINFO_TOTALTIMES_FIELD.default_value = 0
descriptor.TIMESBUYINFO_TOTALTIMES_FIELD.type = 5
descriptor.TIMESBUYINFO_TOTALTIMES_FIELD.cpp_type = 1

descriptor.TIMESBUYINFO_DAYTIMES_FIELD.name = "DayTimes"
descriptor.TIMESBUYINFO_DAYTIMES_FIELD.full_name = ".VK.Proto.TimesBuyInfo.DayTimes"
descriptor.TIMESBUYINFO_DAYTIMES_FIELD.number = 3
descriptor.TIMESBUYINFO_DAYTIMES_FIELD.index = 2
descriptor.TIMESBUYINFO_DAYTIMES_FIELD.label = 1
descriptor.TIMESBUYINFO_DAYTIMES_FIELD.has_default_value = false
descriptor.TIMESBUYINFO_DAYTIMES_FIELD.default_value = 0
descriptor.TIMESBUYINFO_DAYTIMES_FIELD.type = 5
descriptor.TIMESBUYINFO_DAYTIMES_FIELD.cpp_type = 1

descriptor.TIMESBUYINFO_SHORTTIMES_FIELD.name = "ShortTimes"
descriptor.TIMESBUYINFO_SHORTTIMES_FIELD.full_name = ".VK.Proto.TimesBuyInfo.ShortTimes"
descriptor.TIMESBUYINFO_SHORTTIMES_FIELD.number = 4
descriptor.TIMESBUYINFO_SHORTTIMES_FIELD.index = 3
descriptor.TIMESBUYINFO_SHORTTIMES_FIELD.label = 1
descriptor.TIMESBUYINFO_SHORTTIMES_FIELD.has_default_value = false
descriptor.TIMESBUYINFO_SHORTTIMES_FIELD.default_value = 0
descriptor.TIMESBUYINFO_SHORTTIMES_FIELD.type = 5
descriptor.TIMESBUYINFO_SHORTTIMES_FIELD.cpp_type = 1

descriptor.TIMESBUYINFO_REMAINTOTALTIMES_FIELD.name = "RemainTotalTimes"
descriptor.TIMESBUYINFO_REMAINTOTALTIMES_FIELD.full_name = ".VK.Proto.TimesBuyInfo.RemainTotalTimes"
descriptor.TIMESBUYINFO_REMAINTOTALTIMES_FIELD.number = 5
descriptor.TIMESBUYINFO_REMAINTOTALTIMES_FIELD.index = 4
descriptor.TIMESBUYINFO_REMAINTOTALTIMES_FIELD.label = 1
descriptor.TIMESBUYINFO_REMAINTOTALTIMES_FIELD.has_default_value = false
descriptor.TIMESBUYINFO_REMAINTOTALTIMES_FIELD.default_value = 0
descriptor.TIMESBUYINFO_REMAINTOTALTIMES_FIELD.type = 5
descriptor.TIMESBUYINFO_REMAINTOTALTIMES_FIELD.cpp_type = 1

descriptor.TIMESBUYINFO_REMAINDAYTIMES_FIELD.name = "RemainDayTimes"
descriptor.TIMESBUYINFO_REMAINDAYTIMES_FIELD.full_name = ".VK.Proto.TimesBuyInfo.RemainDayTimes"
descriptor.TIMESBUYINFO_REMAINDAYTIMES_FIELD.number = 6
descriptor.TIMESBUYINFO_REMAINDAYTIMES_FIELD.index = 5
descriptor.TIMESBUYINFO_REMAINDAYTIMES_FIELD.label = 1
descriptor.TIMESBUYINFO_REMAINDAYTIMES_FIELD.has_default_value = false
descriptor.TIMESBUYINFO_REMAINDAYTIMES_FIELD.default_value = 0
descriptor.TIMESBUYINFO_REMAINDAYTIMES_FIELD.type = 5
descriptor.TIMESBUYINFO_REMAINDAYTIMES_FIELD.cpp_type = 1

descriptor.TIMESBUYINFO_REMAINSHORTTIMES_FIELD.name = "RemainShortTimes"
descriptor.TIMESBUYINFO_REMAINSHORTTIMES_FIELD.full_name = ".VK.Proto.TimesBuyInfo.RemainShortTimes"
descriptor.TIMESBUYINFO_REMAINSHORTTIMES_FIELD.number = 7
descriptor.TIMESBUYINFO_REMAINSHORTTIMES_FIELD.index = 6
descriptor.TIMESBUYINFO_REMAINSHORTTIMES_FIELD.label = 1
descriptor.TIMESBUYINFO_REMAINSHORTTIMES_FIELD.has_default_value = false
descriptor.TIMESBUYINFO_REMAINSHORTTIMES_FIELD.default_value = 0
descriptor.TIMESBUYINFO_REMAINSHORTTIMES_FIELD.type = 5
descriptor.TIMESBUYINFO_REMAINSHORTTIMES_FIELD.cpp_type = 1

descriptor.TIMESBUYINFO.name = "TimesBuyInfo"
descriptor.TIMESBUYINFO.full_name = ".VK.Proto.TimesBuyInfo"
descriptor.TIMESBUYINFO.nested_types = {}
descriptor.TIMESBUYINFO.enum_types = {}
descriptor.TIMESBUYINFO.fields = {descriptor.TIMESBUYINFO_PACKID_FIELD, descriptor.TIMESBUYINFO_TOTALTIMES_FIELD, descriptor.TIMESBUYINFO_DAYTIMES_FIELD, descriptor.TIMESBUYINFO_SHORTTIMES_FIELD, descriptor.TIMESBUYINFO_REMAINTOTALTIMES_FIELD, descriptor.TIMESBUYINFO_REMAINDAYTIMES_FIELD, descriptor.TIMESBUYINFO_REMAINSHORTTIMES_FIELD}
descriptor.TIMESBUYINFO.is_extendable = false
descriptor.TIMESBUYINFO.extensions = {}
descriptor.PACKTIMESBUYRESP_TIMESBUY_FIELD.name = "TimesBuy"
descriptor.PACKTIMESBUYRESP_TIMESBUY_FIELD.full_name = ".VK.Proto.PackTimesBuyResp.TimesBuy"
descriptor.PACKTIMESBUYRESP_TIMESBUY_FIELD.number = 1
descriptor.PACKTIMESBUYRESP_TIMESBUY_FIELD.index = 0
descriptor.PACKTIMESBUYRESP_TIMESBUY_FIELD.label = 3
descriptor.PACKTIMESBUYRESP_TIMESBUY_FIELD.has_default_value = false
descriptor.PACKTIMESBUYRESP_TIMESBUY_FIELD.default_value = {}
descriptor.PACKTIMESBUYRESP_TIMESBUY_FIELD.message_type = descriptor.TIMESBUYINFO
descriptor.PACKTIMESBUYRESP_TIMESBUY_FIELD.type = 11
descriptor.PACKTIMESBUYRESP_TIMESBUY_FIELD.cpp_type = 10

descriptor.PACKTIMESBUYRESP.name = "PackTimesBuyResp"
descriptor.PACKTIMESBUYRESP.full_name = ".VK.Proto.PackTimesBuyResp"
descriptor.PACKTIMESBUYRESP.nested_types = {}
descriptor.PACKTIMESBUYRESP.enum_types = {}
descriptor.PACKTIMESBUYRESP.fields = {descriptor.PACKTIMESBUYRESP_TIMESBUY_FIELD}
descriptor.PACKTIMESBUYRESP.is_extendable = false
descriptor.PACKTIMESBUYRESP.extensions = {}
descriptor.PACKSTOCKREQ_PACKIDS_FIELD.name = "PackIDs"
descriptor.PACKSTOCKREQ_PACKIDS_FIELD.full_name = ".VK.Proto.PackStockReq.PackIDs"
descriptor.PACKSTOCKREQ_PACKIDS_FIELD.number = 1
descriptor.PACKSTOCKREQ_PACKIDS_FIELD.index = 0
descriptor.PACKSTOCKREQ_PACKIDS_FIELD.label = 3
descriptor.PACKSTOCKREQ_PACKIDS_FIELD.has_default_value = false
descriptor.PACKSTOCKREQ_PACKIDS_FIELD.default_value = {}
descriptor.PACKSTOCKREQ_PACKIDS_FIELD.type = 9
descriptor.PACKSTOCKREQ_PACKIDS_FIELD.cpp_type = 9

descriptor.PACKSTOCKREQ.name = "PackStockReq"
descriptor.PACKSTOCKREQ.full_name = ".VK.Proto.PackStockReq"
descriptor.PACKSTOCKREQ.nested_types = {}
descriptor.PACKSTOCKREQ.enum_types = {}
descriptor.PACKSTOCKREQ.fields = {descriptor.PACKSTOCKREQ_PACKIDS_FIELD}
descriptor.PACKSTOCKREQ.is_extendable = false
descriptor.PACKSTOCKREQ.extensions = {}
descriptor.PACKSTOCKINFO_PACKID_FIELD.name = "PackID"
descriptor.PACKSTOCKINFO_PACKID_FIELD.full_name = ".VK.Proto.PackStockInfo.PackID"
descriptor.PACKSTOCKINFO_PACKID_FIELD.number = 1
descriptor.PACKSTOCKINFO_PACKID_FIELD.index = 0
descriptor.PACKSTOCKINFO_PACKID_FIELD.label = 2
descriptor.PACKSTOCKINFO_PACKID_FIELD.has_default_value = false
descriptor.PACKSTOCKINFO_PACKID_FIELD.default_value = ""
descriptor.PACKSTOCKINFO_PACKID_FIELD.type = 9
descriptor.PACKSTOCKINFO_PACKID_FIELD.cpp_type = 9

descriptor.PACKSTOCKINFO_STOCKNUM_FIELD.name = "StockNum"
descriptor.PACKSTOCKINFO_STOCKNUM_FIELD.full_name = ".VK.Proto.PackStockInfo.StockNum"
descriptor.PACKSTOCKINFO_STOCKNUM_FIELD.number = 2
descriptor.PACKSTOCKINFO_STOCKNUM_FIELD.index = 1
descriptor.PACKSTOCKINFO_STOCKNUM_FIELD.label = 1
descriptor.PACKSTOCKINFO_STOCKNUM_FIELD.has_default_value = false
descriptor.PACKSTOCKINFO_STOCKNUM_FIELD.default_value = 0
descriptor.PACKSTOCKINFO_STOCKNUM_FIELD.type = 5
descriptor.PACKSTOCKINFO_STOCKNUM_FIELD.cpp_type = 1

descriptor.PACKSTOCKINFO.name = "PackStockInfo"
descriptor.PACKSTOCKINFO.full_name = ".VK.Proto.PackStockInfo"
descriptor.PACKSTOCKINFO.nested_types = {}
descriptor.PACKSTOCKINFO.enum_types = {}
descriptor.PACKSTOCKINFO.fields = {descriptor.PACKSTOCKINFO_PACKID_FIELD, descriptor.PACKSTOCKINFO_STOCKNUM_FIELD}
descriptor.PACKSTOCKINFO.is_extendable = false
descriptor.PACKSTOCKINFO.extensions = {}
descriptor.PACKSTOCKRESP_PACKSTOCK_FIELD.name = "PackStock"
descriptor.PACKSTOCKRESP_PACKSTOCK_FIELD.full_name = ".VK.Proto.PackStockResp.PackStock"
descriptor.PACKSTOCKRESP_PACKSTOCK_FIELD.number = 1
descriptor.PACKSTOCKRESP_PACKSTOCK_FIELD.index = 0
descriptor.PACKSTOCKRESP_PACKSTOCK_FIELD.label = 3
descriptor.PACKSTOCKRESP_PACKSTOCK_FIELD.has_default_value = false
descriptor.PACKSTOCKRESP_PACKSTOCK_FIELD.default_value = {}
descriptor.PACKSTOCKRESP_PACKSTOCK_FIELD.message_type = descriptor.PACKSTOCKINFO
descriptor.PACKSTOCKRESP_PACKSTOCK_FIELD.type = 11
descriptor.PACKSTOCKRESP_PACKSTOCK_FIELD.cpp_type = 10

descriptor.PACKSTOCKRESP.name = "PackStockResp"
descriptor.PACKSTOCKRESP.full_name = ".VK.Proto.PackStockResp"
descriptor.PACKSTOCKRESP.nested_types = {}
descriptor.PACKSTOCKRESP.enum_types = {}
descriptor.PACKSTOCKRESP.fields = {descriptor.PACKSTOCKRESP_PACKSTOCK_FIELD}
descriptor.PACKSTOCKRESP.is_extendable = false
descriptor.PACKSTOCKRESP.extensions = {}
descriptor.REMAINTIMEREQ_PACKTYPE_FIELD.name = "packType"
descriptor.REMAINTIMEREQ_PACKTYPE_FIELD.full_name = ".VK.Proto.RemainTimeReq.packType"
descriptor.REMAINTIMEREQ_PACKTYPE_FIELD.number = 1
descriptor.REMAINTIMEREQ_PACKTYPE_FIELD.index = 0
descriptor.REMAINTIMEREQ_PACKTYPE_FIELD.label = 2
descriptor.REMAINTIMEREQ_PACKTYPE_FIELD.has_default_value = false
descriptor.REMAINTIMEREQ_PACKTYPE_FIELD.default_value = nil
descriptor.REMAINTIMEREQ_PACKTYPE_FIELD.enum_type = descriptor.GIFTPACKTYPE
descriptor.REMAINTIMEREQ_PACKTYPE_FIELD.type = 14
descriptor.REMAINTIMEREQ_PACKTYPE_FIELD.cpp_type = 8

descriptor.REMAINTIMEREQ.name = "RemainTimeReq"
descriptor.REMAINTIMEREQ.full_name = ".VK.Proto.RemainTimeReq"
descriptor.REMAINTIMEREQ.nested_types = {}
descriptor.REMAINTIMEREQ.enum_types = {}
descriptor.REMAINTIMEREQ.fields = {descriptor.REMAINTIMEREQ_PACKTYPE_FIELD}
descriptor.REMAINTIMEREQ.is_extendable = false
descriptor.REMAINTIMEREQ.extensions = {}
descriptor.REMAINTIMERESP_TOOPENTIME_FIELD.name = "ToOpenTime"
descriptor.REMAINTIMERESP_TOOPENTIME_FIELD.full_name = ".VK.Proto.RemainTimeResp.ToOpenTime"
descriptor.REMAINTIMERESP_TOOPENTIME_FIELD.number = 1
descriptor.REMAINTIMERESP_TOOPENTIME_FIELD.index = 0
descriptor.REMAINTIMERESP_TOOPENTIME_FIELD.label = 1
descriptor.REMAINTIMERESP_TOOPENTIME_FIELD.has_default_value = false
descriptor.REMAINTIMERESP_TOOPENTIME_FIELD.default_value = 0
descriptor.REMAINTIMERESP_TOOPENTIME_FIELD.type = 3
descriptor.REMAINTIMERESP_TOOPENTIME_FIELD.cpp_type = 2

descriptor.REMAINTIMERESP_TOENDTIME_FIELD.name = "ToEndTime"
descriptor.REMAINTIMERESP_TOENDTIME_FIELD.full_name = ".VK.Proto.RemainTimeResp.ToEndTime"
descriptor.REMAINTIMERESP_TOENDTIME_FIELD.number = 2
descriptor.REMAINTIMERESP_TOENDTIME_FIELD.index = 1
descriptor.REMAINTIMERESP_TOENDTIME_FIELD.label = 1
descriptor.REMAINTIMERESP_TOENDTIME_FIELD.has_default_value = false
descriptor.REMAINTIMERESP_TOENDTIME_FIELD.default_value = 0
descriptor.REMAINTIMERESP_TOENDTIME_FIELD.type = 3
descriptor.REMAINTIMERESP_TOENDTIME_FIELD.cpp_type = 2

descriptor.REMAINTIMERESP_ISFINISHED_FIELD.name = "IsFinished"
descriptor.REMAINTIMERESP_ISFINISHED_FIELD.full_name = ".VK.Proto.RemainTimeResp.IsFinished"
descriptor.REMAINTIMERESP_ISFINISHED_FIELD.number = 3
descriptor.REMAINTIMERESP_ISFINISHED_FIELD.index = 2
descriptor.REMAINTIMERESP_ISFINISHED_FIELD.label = 1
descriptor.REMAINTIMERESP_ISFINISHED_FIELD.has_default_value = false
descriptor.REMAINTIMERESP_ISFINISHED_FIELD.default_value = false
descriptor.REMAINTIMERESP_ISFINISHED_FIELD.type = 8
descriptor.REMAINTIMERESP_ISFINISHED_FIELD.cpp_type = 7

descriptor.REMAINTIMERESP_ISDAYFINISHED_FIELD.name = "IsDayFinished"
descriptor.REMAINTIMERESP_ISDAYFINISHED_FIELD.full_name = ".VK.Proto.RemainTimeResp.IsDayFinished"
descriptor.REMAINTIMERESP_ISDAYFINISHED_FIELD.number = 4
descriptor.REMAINTIMERESP_ISDAYFINISHED_FIELD.index = 3
descriptor.REMAINTIMERESP_ISDAYFINISHED_FIELD.label = 1
descriptor.REMAINTIMERESP_ISDAYFINISHED_FIELD.has_default_value = false
descriptor.REMAINTIMERESP_ISDAYFINISHED_FIELD.default_value = false
descriptor.REMAINTIMERESP_ISDAYFINISHED_FIELD.type = 8
descriptor.REMAINTIMERESP_ISDAYFINISHED_FIELD.cpp_type = 7

descriptor.REMAINTIMERESP_OPENTIMES_FIELD.name = "OpenTimes"
descriptor.REMAINTIMERESP_OPENTIMES_FIELD.full_name = ".VK.Proto.RemainTimeResp.OpenTimes"
descriptor.REMAINTIMERESP_OPENTIMES_FIELD.number = 5
descriptor.REMAINTIMERESP_OPENTIMES_FIELD.index = 4
descriptor.REMAINTIMERESP_OPENTIMES_FIELD.label = 1
descriptor.REMAINTIMERESP_OPENTIMES_FIELD.has_default_value = false
descriptor.REMAINTIMERESP_OPENTIMES_FIELD.default_value = 0
descriptor.REMAINTIMERESP_OPENTIMES_FIELD.type = 5
descriptor.REMAINTIMERESP_OPENTIMES_FIELD.cpp_type = 1

descriptor.REMAINTIMERESP.name = "RemainTimeResp"
descriptor.REMAINTIMERESP.full_name = ".VK.Proto.RemainTimeResp"
descriptor.REMAINTIMERESP.nested_types = {}
descriptor.REMAINTIMERESP.enum_types = {}
descriptor.REMAINTIMERESP.fields = {descriptor.REMAINTIMERESP_TOOPENTIME_FIELD, descriptor.REMAINTIMERESP_TOENDTIME_FIELD, descriptor.REMAINTIMERESP_ISFINISHED_FIELD, descriptor.REMAINTIMERESP_ISDAYFINISHED_FIELD, descriptor.REMAINTIMERESP_OPENTIMES_FIELD}
descriptor.REMAINTIMERESP.is_extendable = false
descriptor.REMAINTIMERESP.extensions = {}


pb.BUYSTATUSREQ = descriptor.BUYSTATUSREQ;
pb.BROADCASTINFO = descriptor.BROADCASTINFO;
pb.BROADCASTRECORDREQ = descriptor.BROADCASTRECORDREQ;
pb.BROADCASTRECORDRESP = descriptor.BROADCASTRECORDRESP;
pb.PACKTIMESBUYREQ = descriptor.PACKTIMESBUYREQ;
pb.TIMESBUYINFO = descriptor.TIMESBUYINFO;
pb.PACKTIMESBUYRESP = descriptor.PACKTIMESBUYRESP;
pb.PACKSTOCKREQ = descriptor.PACKSTOCKREQ;
pb.PACKSTOCKINFO = descriptor.PACKSTOCKINFO;
pb.PACKSTOCKRESP = descriptor.PACKSTOCKRESP;
pb.REMAINTIMEREQ = descriptor.REMAINTIMEREQ;
pb.REMAINTIMERESP = descriptor.REMAINTIMERESP;

pb.BirthdayPack = 4
pb.BroadCastInfo = protobuf.Message(descriptor.BROADCASTINFO)
pb.BroadCastRecordReq = protobuf.Message(descriptor.BROADCASTRECORDREQ)
pb.BroadcastRecordResp = protobuf.Message(descriptor.BROADCASTRECORDRESP)
pb.BuyStatusReq = protobuf.Message(descriptor.BUYSTATUSREQ)
pb.ChristmasAllPack = 2
pb.ChristmasPersonPack = 3
pb.PackStockInfo = protobuf.Message(descriptor.PACKSTOCKINFO)
pb.PackStockReq = protobuf.Message(descriptor.PACKSTOCKREQ)
pb.PackStockResp = protobuf.Message(descriptor.PACKSTOCKRESP)
pb.PackTimesBuyReq = protobuf.Message(descriptor.PACKTIMESBUYREQ)
pb.PackTimesBuyResp = protobuf.Message(descriptor.PACKTIMESBUYRESP)
pb.RemainTimeReq = protobuf.Message(descriptor.REMAINTIMEREQ)
pb.RemainTimeResp = protobuf.Message(descriptor.REMAINTIMERESP)
pb.Req_Buy = 6
pb.Req_Record_Get = 2
pb.Req_Remain_Time = 5
pb.Req_Status_Buy = 1
pb.Req_Stock_Pack_Get = 4
pb.Req_Times_buy = 3
pb.TemporaryPack = 5
pb.TimesBuyInfo = protobuf.Message(descriptor.TIMESBUYINFO)
pb.VipRightPack = 1

return pb